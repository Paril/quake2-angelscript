// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS
#include <angelscript.h>
#include "as_debugger.h"
#include <bitset>
#include <array>
#include <charconv>
#include <../source/as_scriptfunction.h>

void asIDBVariable::MakeExpandable()
{
    if (!ref_id)
    {
        int64_t next_id = dbg.cache->variable_refs.size() + 1;
        ref_id = next_id;
        dbg.cache->variable_refs.emplace(next_id, ptr);
    }
}

void asIDBVariable::PushChild(WeakPtr ptr)
{
    MakeExpandable();
    children.push_back(ptr);
}

void asIDBVariable::Expand()
{
    if (expanded)
        return;
    else if (!ref_id)
        __debugbreak(); // error

    dbg.cache->evaluators.Expand(ptr.lock());
    expanded = true;
}

asIDBScope::asIDBScope(asUINT offset, asIDBDebugger &dbg, asIScriptFunction *function) :
    offset(offset),
    parameters(dbg.cache->CreateVariable()),
    locals(dbg.cache->CreateVariable()),
    registers(dbg.cache->CreateVariable())
{
    CalcLocals(dbg, function, parameters);
    CalcLocals(dbg, function, locals);
    CalcLocals(dbg, function, registers);
}

void asIDBScope::CalcLocals(asIDBDebugger &dbg, asIScriptFunction *function, asIDBVariable::Ptr &container)
{
    if (!function || offset == SCOPE_SYSTEM)
        return;

    auto &cache = *dbg.cache.get();
    auto ctx = cache.ctx;
    asUINT numParams = function->GetParamCount();
    asUINT numLocals = ctx->GetVarCount(offset);

    asUINT start = 0, end = 0;

    if (container == parameters)
        end = numParams;
    else
    {
        start = numParams;
        end = numLocals;
    }

    if (container == locals)
    {
        if (auto thisPtr = ctx->GetThisPointer(offset))
        {
            int thisTypeId = ctx->GetThisTypeId(offset);

            asIDBTypeId typeKey { thisTypeId, asTM_NONE };

            const std::string_view viewType = cache.GetTypeNameFromType(typeKey);

            asIDBVarAddr idKey { thisTypeId, false, thisPtr };

            asIDBVariable::Ptr var = cache.CreateVariable();
            var->name = "this";
            var->address = idKey;
            var->typeName = viewType;
            var->stackIndex = (asUINT) -1;
            cache.evaluators.Evaluate(var);
            container->PushChild(var);

            this_ptr = var;
        }
    }

    for (asUINT n = start; n < end; n++)
    {
        const char *name;
        int typeId;
        asETypeModifiers modifiers;
        int stackOffset;
        ctx->GetVar(n, offset, &name, &typeId, &modifiers, 0, &stackOffset);

        bool isTemporary = (container != parameters) && (!name || !*name);
        
        if (!ctx->IsVarInScope(n, offset))
            continue;
        else if (isTemporary != (container == registers))
            continue;

        void *ptr = ctx->GetAddressOfVar(n, offset);

        asIDBTypeId typeKey { typeId, modifiers };

        std::string localName = (name && *name) ? fmt::format("{} (&{})", name, n) : fmt::format("&{}", n);

        const std::string_view viewType = cache.GetTypeNameFromType(typeKey);

        asIDBVarAddr idKey { typeId, (modifiers & asTM_CONST) != 0, ptr };
        
        asIDBVariable::Ptr var = cache.CreateVariable();
        var->name = std::move(localName);
        var->address = idKey;
        var->typeName = viewType;
        var->stackIndex = n;
        cache.evaluators.Evaluate(var);
        container->PushChild(var);

        local_by_index.emplace(n, var);
    }

    container->expanded = true;
}

/*virtual*/ void asIDBCache::Refresh()
{
}

/*virtual*/ const std::string_view asIDBCache::GetTypeNameFromType(asIDBTypeId id)
{
    if (auto f = type_names.find(id); f != type_names.end())
        return f->second.c_str();

    auto type = ctx->GetEngine()->GetTypeInfoById(id.typeId);
    const char *rawName = "???";

    if (!type)
    {
        // a primitive
        switch (id.typeId & asTYPEID_MASK_SEQNBR)
        {
        case asTYPEID_BOOL: rawName = "bool"; break;
        case asTYPEID_INT8: rawName = "int8"; break;
        case asTYPEID_INT16: rawName = "int16"; break;
        case asTYPEID_INT32: rawName = "int32"; break;
        case asTYPEID_INT64: rawName = "int64"; break;
        case asTYPEID_UINT8: rawName = "uint8"; break;
        case asTYPEID_UINT16: rawName = "uint16"; break;
        case asTYPEID_UINT32: rawName = "uint32"; break;
        case asTYPEID_UINT64: rawName = "uint64"; break;
        case asTYPEID_FLOAT: rawName = "float"; break;
        case asTYPEID_DOUBLE: rawName = "double"; break;
        default: rawName = "???"; break;
        }
    }
    else
    {
        rawName = type->GetName();
    }

    std::string name = fmt::format("{}{}{}", (id.modifiers & asTM_CONST) ? "const " : "", rawName,
        ((id.modifiers & asTM_INOUTREF) == asTM_INOUTREF) ? "&" :
        ((id.modifiers & asTM_INOUTREF) == asTM_INREF) ? "&in" :
        ((id.modifiers & asTM_INOUTREF) == asTM_OUTREF) ? "&out" :
        "");

    return type_names.emplace(id, std::move(name)).first->second;
}

void *asIDBCache::ResolvePropertyAddress(const asIDBResolvedVarAddr &id, int propertyIndex, int offset, int compositeOffset, bool isCompositeIndirect)
{
    if (id.source.typeId & asTYPEID_SCRIPTOBJECT)
    {
        asIScriptObject *obj = (asIScriptObject *) id.resolved;
        return obj->GetAddressOfProperty(propertyIndex);
    }

    // indirect changes our ptr to
    // *(object + compositeOffset) + offset
    if (isCompositeIndirect)
    {
        void *propAddr = *reinterpret_cast<uint8_t **>(id.ResolveAs<uint8_t>() + compositeOffset);

        // if we're null, leave it alone, otherwise point to
        // where we really need to be pointing
        if (propAddr)
            propAddr = reinterpret_cast<uint8_t *>(propAddr) + offset;

        return propAddr;
    }

    return id.ResolveAs<uint8_t>() + offset + compositeOffset;
}

/*virtual*/ asIDBExpected<asIDBVariable::WeakPtr> asIDBCache::ResolveExpression(const std::string_view expr, std::optional<int> stack_index)
{
    if (expr.empty())
        return asIDBExpected("empty string");

    CacheCallstack();

    // isolate the variable name first
    size_t variable_end = expr.find_first_of(".[", 0);
    std::string_view variable_name = expr.substr(0, variable_end);

    if (variable_name.empty())
        return asIDBExpected("bad expression");

    asIDBExpected<asIDBVariable::WeakPtr> variable;
    asIDBCallStackEntry *stack = nullptr;
    
    if (stack_index.has_value())
        stack = &call_stack[stack_index.value()];

    // if it starts with a & it has to be a local variable index
    if (stack && variable_name[0] == '&')
    {
        uint32_t offset;
        auto result = std::from_chars(&variable_name.front(), &variable_name.front() + variable_name.size(), offset);

        if (result.ec != std::errc())
            return asIDBExpected("invalid numerical offset");

        // check bounds
        int m = ctx->GetVarCount(stack_index.value());

        if (offset >= m)
            return asIDBExpected("stack offset out of bounds");

        if (!ctx->IsVarInScope(offset, stack_index.value()))
            return asIDBExpected("variable out of scope");

        if (auto varit = stack->scope.local_by_index.find(offset); varit != stack->scope.local_by_index.end())
            variable = varit->second;
        else
            return asIDBExpected("missing local index");
    }
    // check this
    else if (stack && variable_name == "this")
    {
        if (stack->scope.this_ptr.expired())
            return asIDBExpected("not a method");

        variable = stack->scope.this_ptr;
    }
    else
    {
        struct asIDBNamespacedVar {
            asIDBVariable::WeakPtr     var;
            std::string_view           name;
            std::string_view           ns = "::";
        };

        std::vector<asIDBNamespacedVar> matches;
        std::string_view variable_ns;

        if (auto ns_end = variable_name.find_last_of(':'); ns_end != std::string_view::npos)
        {
            variable_ns = variable_name.substr(0, ns_end - 1);
            variable_name = variable_name.substr(ns_end + 1);
        }

        if (stack)
        {
            // not an offset; in order, check the following:
            // - local variables (in reverse order)
            // - function parameters
            // - class member properties (if appropriate)
            // - globals
            for (int i = ctx->GetVarCount(stack_index.value()) - 1; i >= 0; i--)
            {
                if (!ctx->IsVarInScope(i, stack_index.value()))
                    continue;

                const char *name;
                int typeId;
                asETypeModifiers modifiers;
                ctx->GetVar(i, stack_index.value(), &name, &typeId, &modifiers);

                if (variable_name != name)
                    continue;

                if (auto varit = stack->scope.local_by_index.find(i); varit != stack->scope.local_by_index.end())
                    matches.push_back({ varit->second, name });

                break;
            }

            // check `this` parameters
            if (!stack->scope.this_ptr.expired())
            {
                auto var = stack->scope.this_ptr.lock();
                var->Expand();

                for (auto &param : var->Children())
                {
                    auto paramvar = param.lock();

                    if (variable_name != paramvar->name)
                        continue;

                    matches.push_back({
                        paramvar,
                        paramvar->name
                    });
                }
            }
        }

        // check globals
        CacheGlobals();

        for (auto &global : globals->Children())
        {
            auto globalvar = global.lock();
                
            if (variable_name == globalvar->name)
                matches.push_back({
                    globalvar,
                    globalvar->name,
                    globalvar->ns
                });
        }

        if (matches.size() == 1)
            variable = matches[0].var;
        // if we didn't specify a ns but had multiple
        // matches, return an error
        else if (variable_ns.empty())
            return asIDBExpected(matches.empty() ? "can't find variable" : "ambiguous variable name");
        else
        {
            for (auto &match : matches)
            {
                if (variable_ns == match.ns)
                {
                    variable = match.var;
                    break;
                }
            }
        }

        if (!variable)
            return asIDBExpected("can't find variable");
    }

    // variable_key should be non-null and with
    // a valid type ID here.
    return ResolveSubExpression(variable.value(), variable_end == std::string_view::npos ? std::string_view{} : expr.substr(variable_end));
}

/*virtual*/ asIDBExpected<asIDBVariable::WeakPtr> asIDBCache::ResolveSubExpression(asIDBVariable::WeakPtr var, const std::string_view rest)
{
    // nothing left, so this is the result.
    if (rest.empty())
        return var;

    // make sure we're a type that supports properties
    auto varp = var.lock();

    varp->Expand();

    // FIXME: this will also work for "fake" variables like
    // bits expanded from enums
    if (varp->Children().empty())
        return asIDBExpected("type is not allowed for sub-expressions");

    // check what kind of sub-evaluator to use
    size_t eval_start = rest.find_first_of(".[", 1);
    std::string_view eval_name = rest.substr(0, eval_start);

    if (eval_name[0] == '.')
        eval_name.remove_prefix(1);

    for (auto &child : varp->Children())
    {
        auto childp = child.lock();
        
        if (childp->name == eval_name)
            return ResolveSubExpression(child, eval_start == std::string_view::npos ? std::string_view{} : rest.substr(eval_start));
    }

    return asIDBExpected("can't resolve sub-expression");
}

/*virtual*/ void asIDBCache::CacheCallstack()
{
    if (!ctx || !call_stack.empty())
        return;

    if (auto sysfunc = ctx->GetSystemFunction())
        call_stack.emplace_back(asIDBCallStackEntry {
            dbg.frame_offset++,
            sysfunc->GetDeclaration(true, false, true),
            "(system function)",
            0,
            0,
            asIDBScope(SCOPE_SYSTEM, dbg, sysfunc)
        });

    for (asUINT n = 0; n < ctx->GetCallstackSize(); n++)
    {
        asIScriptFunction *func = nullptr;
        int column = 0;
        const char *section = "";
        int row = 0;

        // FIXME: check this, because this will skip GetFunction(n).
        // I think this is correct though...?
        if (n == 0 && ctx->GetState() == asEXECUTION_EXCEPTION)
        {
            func = ctx->GetExceptionFunction();
            if (func)
                row = ctx->GetExceptionLineNumber(&column, &section);
        }
        else
        {
            func = ctx->GetFunction(n);
            if (func)
                row = ctx->GetLineNumber(n, &column, &section);
        }

        std::string decl;
        
        if (func)
            decl = func->GetDeclaration(true, false, true);
        else
            decl = "???"; // FIXME: why does this happen?

        call_stack.push_back(asIDBCallStackEntry {
            dbg.frame_offset++,
            std::move(decl),
            section,
            row,
            column,
            asIDBScope(func->GetFuncType() == asFUNC_SYSTEM ? SCOPE_SYSTEM : n, dbg, func)
        });
    }
}

// restore data from the given cache that is
// being replaced by this one.
/*virtual*/ void asIDBCache::Restore(asIDBCache &cache)
{
}

/*virtual*/ void asIDBCache::CacheGlobals()
{
    if (!ctx)
        return;
    
    if (!globals)
        globals = CreateVariable();

    if (globals->expanded)
        return;

    auto main = ctx->GetFunction(0)->GetModule();

    for (asUINT n = 0; n < main->GetGlobalVarCount(); n++)
    {
        const char *name;
        const char *nameSpace;
        int typeId;
        void *ptr;
        bool isConst;

        main->GetGlobalVar(n, &name, &nameSpace, &typeId, &isConst);
        ptr = main->GetAddressOfGlobalVar(n);

        asIDBTypeId typeKey { typeId, isConst ? asTM_CONST : asTM_NONE };
        const std::string_view viewType = GetTypeNameFromType(typeKey);

        asIDBVarAddr idKey { typeId, isConst, ptr };

        std::string localName = ((nameSpace && nameSpace[0]) ? fmt::format("{}::{}", nameSpace, name) : name);

        asIDBVariable::Ptr var = dbg.cache->CreateVariable();
        var->name = std::move(localName);
        if (nameSpace && nameSpace[0])
            var->ns = nameSpace;
        var->address = idKey;
        var->typeName = viewType;
        evaluators.Evaluate(var);
        globals->PushChild(var);
    }

    for (asUINT n = 0; n < main->GetEngine()->GetGlobalPropertyCount(); n++)
    {
        const char *name;
        const char *nameSpace;
        int typeId;
        void *ptr;
        bool isConst;

        main->GetEngine()->GetGlobalPropertyByIndex(n, &name, &nameSpace, &typeId, &isConst, nullptr, &ptr);

        asIDBTypeId typeKey { typeId, isConst ? asTM_CONST : asTM_NONE };
        const std::string_view viewType = GetTypeNameFromType(typeKey);

        asIDBVarAddr idKey { typeId, isConst, ptr };

        std::string localName = (nameSpace && nameSpace[0]) ? fmt::format("{}::{}", nameSpace, name) : name;
        
        asIDBVariable::Ptr var = dbg.cache->CreateVariable();
        var->name = std::move(localName);
        var->address = idKey;
        var->typeName = viewType;
        evaluators.Evaluate(var);
        globals->PushChild(var);
    }

    globals->expanded = true;
}

class asIDBNullTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        var->value = "(null)";
    }
};

class asIDBUninitTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        var->value = "(uninit)";
    }
};

class asIDBEnumTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        auto &dbg = var->dbg;

        // for enums where we have a single matched value
        // just display it directly; it might be a mask but that's OK.
        auto type = dbg.cache->ctx->GetEngine()->GetTypeInfoById(var->address.source.typeId);

        union {
            asINT64 v = 0;
            asQWORD uv;
        };
        
        switch (type->GetTypedefTypeId())
        {
        case asTYPEID_INT8:
            v = *var->address.ResolveAs<const int8_t>();
            break;
        case asTYPEID_UINT8:
            uv = *var->address.ResolveAs<const uint8_t>();
            break;
        case asTYPEID_INT16:
            v = *var->address.ResolveAs<const int16_t>();
            break;
        case asTYPEID_UINT16:
            uv = *var->address.ResolveAs<const uint16_t>();
            break;
        case asTYPEID_INT32:
            v = *var->address.ResolveAs<const int32_t>();
            break;
        case asTYPEID_UINT32:
            uv = *var->address.ResolveAs<const uint32_t>();
            break;
        case asTYPEID_INT64:
            v = *var->address.ResolveAs<const int64_t>();
            break;
        case asTYPEID_UINT64:
            uv = *var->address.ResolveAs<const uint64_t>();
            break;
        }

        for (asUINT e = 0; e < type->GetEnumValueCount(); e++)
        {
            asINT64 ov = 0;
            const char *name = type->GetEnumValueByIndex(e, &ov);

            if (ov == v)
            {
                if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
                {
                    var->value = fmt::format("{} ({})", name, uv);
                    return;
                }

                var->value = fmt::format("{} ({})", name, v);
                return;
            }
        }
        
        std::bitset<32> bits(v);

        if (bits.count() == 1)
        {
            if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
            {
                var->value = fmt::format("{}", uv);
                return;
            }

            var->value = fmt::format("{}", v);
            return;
        }

        var->value = fmt::format("{} bits", bits.count());
        var->MakeExpandable();
    }

    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        auto &dbg = var->dbg;
        auto &cache = *dbg.cache;
        auto type = cache.ctx->GetEngine()->GetTypeInfoById(var->address.source.typeId);

        union {
            asINT64 v = 0;
            asQWORD uv;
        };

        auto resolved = asIDBResolvedVarAddr(var->address);
        
        switch (type->GetTypedefTypeId())
        {
        case asTYPEID_INT8:
            v = *resolved.ResolveAs<const int8_t>();
            break;
        case asTYPEID_UINT8:
            uv = *resolved.ResolveAs<const uint8_t>();
            break;
        case asTYPEID_INT16:
            v = *resolved.ResolveAs<const int16_t>();
            break;
        case asTYPEID_UINT16:
            uv = *resolved.ResolveAs<const uint16_t>();
            break;
        case asTYPEID_INT32:
            v = *resolved.ResolveAs<const int32_t>();
            break;
        case asTYPEID_UINT32:
            uv = *resolved.ResolveAs<const uint32_t>();
            break;
        case asTYPEID_INT64:
            v = *resolved.ResolveAs<const int64_t>();
            break;
        case asTYPEID_UINT64:
            uv = *resolved.ResolveAs<const uint64_t>();
            break;
        }

        {
            std::string rawValue;

            if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
                rawValue = fmt::format("{}", uv);
            else
                rawValue = fmt::format("{}", v);

            auto child = cache.CreateVariable();
            child->owner = var;
            child->name = "value";
            child->value = std::move(rawValue);
            var->PushChild(child);
        }
        
        // find bit names
        asINT64 ov = 0;
        std::array<const char *, sizeof(ov) * 8> bit_names { };

        for (asUINT e = 0; e < type->GetEnumValueCount(); e++)
        {
            const char *name = type->GetEnumValueByIndex(e, &ov);
            std::bitset<sizeof(ov) * 8> obits(ov);

            // skip masks
            if (obits.count() != 1)
                continue;

            if (ov & v)
            {
                int p = 0;

                while (ov && !(ov & 1))
                {
                    ov >>= 1;
                    p++;
                }

                // only take the first name, just incase
                // there's later overrides
                if (p <= (obits.size() - 1) && !bit_names[p])
                    bit_names[p] = name;
            }
        }

        // display bits
        for (asQWORD e = 0; e < bit_names.size(); e++)
        {
            if (v & (1ull << e))
            {
                std::string bitEntry;

                if (bit_names[e])
                    bitEntry = bit_names[e];
                else
                    bitEntry = fmt::format("{}", 1 << e);

                auto child = cache.CreateVariable();
                child->owner = var;
                child->name = fmt::format("[{:2}]", e);
                child->value = std::move(bitEntry);
                var->PushChild(child);
            }
        }
    }
};

class asIDBFuncDefTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        asIScriptFunction *ptr = var->address.ResolveAs<asIScriptFunction>();
        auto &dbg = var->dbg;
        var->value = ptr->GetName();
    }
};

asIDBObjectIteratorHelper::asIDBObjectIteratorHelper(asITypeInfo *type, void *obj) :
    type(type),
    obj(obj),
    opForBegin(type->GetMethodByName("opForBegin")),
    opForEnd(type->GetMethodByName("opForEnd")),
    opForNext(type->GetMethodByName("opForNext"))
{
    if (!Validate())
    {
        opForBegin = nullptr;
        return;
    }

    // TODO: don't need opForValues unless we're iterating
    // TODO: verify opForValue{n} selection
    auto opForValue = type->GetMethodByName("opForValue");

    if (!opForValue)
    {
        for (int i = 0; ; i++)
        {
            auto f = type->GetMethodByName(fmt::format("opForValue{}", i).c_str());

            if (!f)
                break;

            opForValues.push_back(f);
        }
    }
    else
        opForValues.push_back(opForValue);
}

auto asIDBObjectIteratorHelper::Begin(asIScriptContext *ctx) const -> IteratorValue
{
    ctx->Prepare(opForBegin);
    ctx->SetObject(obj);
    ctx->Execute();

    return IteratorValue::FromCtxReturn(this, ctx);
}

auto asIDBObjectIteratorHelper::Next(asIScriptContext *ctx, const IteratorValue &val) const -> IteratorValue
{
    ctx->Prepare(opForNext);
    ctx->SetObject(obj);
    val.SetArg(ctx, 0);
    ctx->Execute();

    return IteratorValue::FromCtxReturn(this, ctx);
}

bool asIDBObjectIteratorHelper::End(asIScriptContext *ctx, const IteratorValue &val) const
{
    ctx->Prepare(opForEnd);
    ctx->SetObject(obj);
    val.SetArg(ctx, 0);
    ctx->Execute();
    return !!ctx->GetReturnByte();
}

/*virtual*/ void asIDBObjectTypeEvaluator::Evaluate(asIDBVariable::Ptr var) const /*override*/
{
    auto &dbg = var->dbg;
    auto &cache = *dbg.cache;
    auto ctx = cache.ctx;
    auto type = ctx->GetEngine()->GetTypeInfoById(var->address.source.typeId);
    bool canExpand = type->GetPropertyCount();

    if (ctx->GetState() != asEXECUTION_EXCEPTION)
    {
        asIDBObjectIteratorHelper it(type, var->address.resolved);

        if (!it)
        {
            if (!it.error.empty())
            {
                var->value = std::string(it.error);
                return;
            }

            var->value = fmt::format("{{{}}}", var->typeName);
        }
        else
        {
            cache.dbg.internal_execution = true;
            ctx->PushState();

            size_t numElements = it.CalculateLength(ctx);

            var->value = fmt::format("{} elements", numElements);

            if (numElements)
                canExpand = true;

            ctx->PopState();
            cache.dbg.internal_execution = false;
        }
    }

    if (canExpand)
        var->MakeExpandable();
}

/*virtual*/ void asIDBObjectTypeEvaluator::Expand(asIDBVariable::Ptr var) const /*override*/
{
    QueryVariableProperties(var);

    QueryVariableForEach(var);
}

// convenience function that queries the properties of the given
// address (and object, if set) of the given type.
void asIDBObjectTypeEvaluator::QueryVariableProperties(asIDBVariable::Ptr var) const
{
    auto &dbg = var->dbg;
    auto &cache = *dbg.cache;
    auto type = cache.ctx->GetEngine()->GetTypeInfoById(var->address.source.typeId);

    asIScriptObject *obj = nullptr;

    if (var->address.source.typeId & asTYPEID_SCRIPTOBJECT)
        obj = (asIScriptObject *) var->address.resolved;

    for (asUINT n = 0; n < (obj ? obj->GetPropertyCount() : type->GetPropertyCount()); n++)
    {
        const char *name;
        int propTypeId;
        void *propAddr = nullptr;
        int offset;
        int compositeOffset;
        bool isCompositeIndirect;
        bool isReadOnly;

        type->GetProperty(n, &name, &propTypeId, 0, 0, &offset, 0, 0, &compositeOffset, &isCompositeIndirect, &isReadOnly);

        propAddr = cache.ResolvePropertyAddress(var->address, n, offset, compositeOffset, isCompositeIndirect);

        asIDBVarAddr propId { propTypeId, isReadOnly, propAddr };

        // TODO: variables that overlap memory space will
        // get culled by this. this helps in the case of
        // vec3_t::x and vec3_t::pitch for instance, but
        // causes some confusion for edict_t::number and
        // edict_t::s::number, where `s` is now just an empty
        // struct. it'd be ideal if, in this case, it prefers
        // the deeper nested ones. not sure how we'd express that
        // with the limited context we have, though.

        // TODO 2.0: this causes an issue with Watch variables
        // because of the way dereferencing works. For now, it
        // will add duplicates, and the old var state cache is gone.
        asIDBVariable::Ptr child = cache.CreateVariable();
        child->owner = var;
        child->address = propId;
        child->name = name;
        child->typeName = cache.GetTypeNameFromType({ propTypeId, isReadOnly ? asTM_CONST : asTM_NONE });
        cache.evaluators.Evaluate(child);
        var->PushChild(child);
    }
}

// convenience function that iterates the opFor* of the given
// address (and object, if set) of the given type. If non-zero,
// a specific index will be used.
void asIDBObjectTypeEvaluator::QueryVariableForEach(asIDBVariable::Ptr var, int index) const
{
    auto &dbg = var->dbg;
    auto &cache = *dbg.cache;
    auto ctx = cache.ctx;

    if (ctx->GetState() == asEXECUTION_EXCEPTION)
        return;

    auto type = ctx->GetEngine()->GetTypeInfoById(var->address.source.typeId);

    auto opForBegin = type->GetMethodByName("opForBegin");

    if (!opForBegin || opForBegin->GetReturnTypeId() != asTYPEID_UINT32)
        return;

    auto opForEnd = type->GetMethodByName("opForEnd");
    auto opForNext = type->GetMethodByName("opForNext");
    auto opForValue = type->GetMethodByName("opForValue");

    std::vector<asIScriptFunction *> opForValues;

    if (!opForValue)
    {
        for (int i = 0; ; i++)
        {
            auto f = type->GetMethodByName(fmt::format("opForValue{}", i).c_str());

            if (!f)
                break;

            opForValues.push_back(f);
        }
    }
    else
        opForValues.push_back(opForValue);

    if (index >= 0 && index < opForValues.size())
        opForValues = { opForValues[index] };

    // if we haven't got anything special yet, and we're
    // iterable, we'll show how many elements we have.
    // we'll also just assume the code isn't busted.
    int elementId = 0;
    
    cache.dbg.internal_execution = true;
    ctx->PushState();
    ctx->Prepare(opForBegin);
    ctx->SetObject(var->address.resolved);
    ctx->Execute();

    uint32_t rtn = ctx->GetReturnDWord();

    while (true)
    {
        ctx->Prepare(opForEnd);
        ctx->SetObject(var->address.resolved);
        ctx->SetArgDWord(0, rtn);
        ctx->Execute();
        bool finished = ctx->GetReturnByte();

        if (finished)
            break;

        int fv = 0;
        for (auto &opfv : opForValues)
        {
            ctx->Prepare(opfv);
            ctx->SetObject(var->address.resolved);
            ctx->SetArgDWord(0, rtn);
            ctx->Execute();

            void *addr = ctx->GetReturnAddress();
            asDWORD returnFlags;
            int typeId = opfv->GetReturnTypeId(&returnFlags);
            std::unique_ptr<uint8_t[]> stackMemory;
            
            // non-heap stuff has to be copied somewhere
            // so the debugger can read it.
            if ((returnFlags & asTM_INOUTREF) == 0)
            {
                auto type = ctx->GetEngine()->GetTypeInfoById(typeId);
                size_t size = type ? type->GetSize() : ctx->GetEngine()->GetSizeOfPrimitiveType(typeId);
                stackMemory = std::make_unique<uint8_t[]>(size);
                memcpy(stackMemory.get(), ctx->GetAddressOfReturnValue(), size);
                addr = stackMemory.get();
            }

            asIDBVarAddr elemId { typeId, false, addr };

            asIDBVariable::Ptr child = cache.CreateVariable();
            child->owner = var;
            child->address = elemId;
            child->name = fmt::vformat(opForValues.size() == 1 ? "[{0}]" : "[{0},{1}]", fmt::make_format_args(elementId, fv));
            child->typeName = cache.GetTypeNameFromType({ typeId, asTM_NONE });
            child->stackData = std::move(stackMemory);
            cache.evaluators.Evaluate(child);
            var->PushChild(child);

            fv++;
        }
                
        ctx->Prepare(opForNext);
        ctx->SetObject(var->address.resolved);
        ctx->SetArgDWord(0, rtn);
        ctx->Execute();

        rtn = ctx->GetReturnDWord();

        elementId++;
    }

    ctx->PopState();
    cache.dbg.internal_execution = false;
}

const asIDBTypeEvaluator &asIDBTypeEvaluatorMap::GetEvaluator(asIDBCache &cache, const asIDBResolvedVarAddr &id) const
{
    // the only way the base address is null is if
    // it's uninitialized.
    static constexpr const asIDBUninitTypeEvaluator uninitType;
    static constexpr const asIDBNullTypeEvaluator nullType;

    if (id.source.address == nullptr)
        return uninitType;
    else if (id.resolved == nullptr)
        return nullType;

    // do we have a custom evaluator?
    if (auto f = evaluators.find(id.source.typeId & (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR)); f != evaluators.end())
        return *f->second.get();

    auto type = cache.ctx->GetEngine()->GetTypeInfoById(id.source.typeId);

    // are we a template?
    if (id.source.typeId & asTYPEID_TEMPLATE)
    {
        // fetch the base type, see if we have a
        // evaluator for that one
        auto baseType = cache.ctx->GetEngine()->GetTypeInfoByName(type->GetName());

        if (auto f = evaluators.find(baseType->GetTypeId() & (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR)); f != evaluators.end())
            return *f->second.get();
    }

    // we'll use the fall back evaluators.
    // check primitives first.
#define CHECK_PRIMITIVE_EVAL(asTypeId, cTypeName) \
    if (id.source.typeId == asTypeId) \
    { \
        static constexpr const asIDBPrimitiveTypeEvaluator<cTypeName> cTypeName##Type; \
        return cTypeName##Type; \
    }
    
    CHECK_PRIMITIVE_EVAL(asTYPEID_BOOL, bool);
    CHECK_PRIMITIVE_EVAL(asTYPEID_INT8, int8_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_INT16, int16_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_INT32, int32_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_INT64, int64_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_UINT8, uint8_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_UINT16, uint16_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_UINT32, uint32_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_UINT64, uint64_t);
    CHECK_PRIMITIVE_EVAL(asTYPEID_FLOAT, float);
    CHECK_PRIMITIVE_EVAL(asTYPEID_DOUBLE, double);

#undef CHECK_PRIMITIVE_EVAL

    if (type->GetFlags() & asOBJ_ENUM)
    {
        static constexpr const asIDBEnumTypeEvaluator enumType;
        return enumType;
    }
    else if (type->GetFlags() & asOBJ_FUNCDEF)
    {
        static constexpr const asIDBFuncDefTypeEvaluator funcdefType;
        return funcdefType;
    }

    // finally, just return the base one.
    static constexpr const asIDBObjectTypeEvaluator objectType;
    return objectType;
}

void asIDBTypeEvaluatorMap::Evaluate(asIDBVariable::Ptr var) const
{
    GetEvaluator(*var->dbg.cache, var->address).Evaluate(var);
}

void asIDBTypeEvaluatorMap::Expand(asIDBVariable::Ptr var) const
{
    GetEvaluator(*var->dbg.cache, var->address).Expand(var);
}

// Register an evaluator.
void asIDBTypeEvaluatorMap::Register(int typeId, std::unique_ptr<asIDBTypeEvaluator> evaluator)
{
    typeId &= asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR;
    evaluators.insert_or_assign(typeId, std::move(evaluator));
}

void asIDBWorkspace::CompileScriptSources()
{
    for (auto &engine : engines)
    {
        for (size_t i = 0; i < engine->GetModuleCount(); i++)
        {
            auto module = engine->GetModuleByIndex(i);

            for (size_t f = 0; f < module->GetFunctionCount(); f++)
                AddSection(module->GetFunctionByIndex(f)->GetScriptSectionName());
        }
    }
}

void asIDBWorkspace::CompileBreakpointPositions()
{
    potential_breakpoints.clear();

    for (auto &engine : engines)
    {
        for (size_t i = 0; i < engine->GetModuleCount(); i++)
        {
            auto module = engine->GetModuleByIndex(i);

            for (size_t f = 0; f < module->GetFunctionCount(); f++)
            {
                auto func = module->GetFunctionByIndex(f);
                asCScriptFunction *internal_func = reinterpret_cast<asCScriptFunction *>(func);

                // TODO: not supported
                if (internal_func->scriptData->sectionIdxs.GetLength() > 0)
                    continue;

                auto section = func->GetScriptSectionName();
                for (size_t i = 0; i < internal_func->scriptData->lineNumbers.GetLength(); i += 2)
                {
                    auto pos = internal_func->scriptData->lineNumbers[i];
                    auto linecol = internal_func->scriptData->lineNumbers[i + 1];
                    auto line = linecol & 0xFFFFF;
                    auto col = linecol >> 20;

                    potential_breakpoints[section].insert(asIDBLineCol { line, col });
                }
            }

            for (size_t t = 0; t < module->GetObjectTypeCount(); t++)
            {
                asITypeInfo *type = module->GetObjectTypeByIndex(t);

                for (size_t m = 0; m < type->GetMethodCount(); m++)
                {
                    auto func = type->GetMethodByIndex(m, false);
                    asCScriptFunction *internal_func = reinterpret_cast<asCScriptFunction *>(func);

                    // TODO: not supported
                    if (!internal_func || !internal_func->scriptData || internal_func->scriptData->sectionIdxs.GetLength() > 0)
                        continue;

                    auto section = func->GetScriptSectionName();
                    for (size_t i = 0; i < internal_func->scriptData->lineNumbers.GetLength(); i += 2)
                    {
                        auto pos = internal_func->scriptData->lineNumbers[i];
                        auto linecol = internal_func->scriptData->lineNumbers[i + 1];
                        auto line = linecol & 0xFFFFF;
                        auto col = linecol >> 20;

                        potential_breakpoints[section].insert(asIDBLineCol { line, col });
                    }
                }
            }
        }
    }
}

/*static*/ void asIDBDebugger::LineCallback(asIScriptContext *ctx, asIDBDebugger *debugger)
{
    if (debugger->internal_execution)
        return;

    // we might not have an action - functions called from within
    // the debugger will never have this set.
    if (debugger->action != asIDBAction::None)
    {
        // Step Into just breaks on whatever happens to be next.
        if (debugger->action == asIDBAction::StepInto)
        {
            debugger->DebugBreak(ctx);
            return;
        }
        // Step Over breaks on the next line that is <= the
        // current stack level.
        else if (debugger->action == asIDBAction::StepOver)
        {
            if (ctx->GetCallstackSize() <= debugger->stack_size)
                debugger->DebugBreak(ctx);
            return;
        }
        // Step Out breaks on the next line that is < the
        // current stack level.
        else if (debugger->action == asIDBAction::StepOut)
        {
            if (ctx->GetCallstackSize() < debugger->stack_size)
                debugger->DebugBreak(ctx);
            return;
        }
    }

    // breakpoints are handled here. note that a single
    // breakpoint can be hit by multiple things on the same
    // line.
    bool break_from_bp = false;
    const char *section = nullptr;
    int col;
    int row = ctx->GetLineNumber(0, &col, &section);

    if (section)
    {
        std::scoped_lock lock(debugger->mutex);
        
        if (auto entries = debugger->breakpoints.find(section); entries != debugger->breakpoints.end())
        {
            for (auto &lines : entries->second)
            {
                if (row == lines.line)
                {
                    if (!lines.column.has_value() || lines.column.value() == col)
                    {
                        break_from_bp = true;
                        break;
                    }
                }
            }
        }
    }

    if (break_from_bp)
        debugger->DebugBreak(ctx);
}

void asIDBDebugger::HookContext(asIScriptContext *ctx)
{
    // TODO: is this safe to be called even if
    // the context is being switched?
    if (ctx->GetState() != asEXECUTION_EXCEPTION && workspace->engines.find(ctx->GetEngine()) != workspace->engines.end())
        ctx->SetLineCallback(asFUNCTION(asIDBDebugger::LineCallback), this, asCALL_CDECL);
}

void asIDBDebugger::DebugBreak(asIScriptContext *ctx)
{
    if (workspace->engines.find(ctx->GetEngine()) == workspace->engines.end())
        return;

    {
        std::scoped_lock lock(mutex);
        action = asIDBAction::None;
        std::unique_ptr<asIDBCache> new_cache = CreateCache(ctx);

        if (cache)
            new_cache->Restore(*cache);

        std::swap(cache, new_cache);
    }
    HookContext(ctx);
    Suspend();
}

bool asIDBDebugger::HasWork()
{
    std::scoped_lock lock(mutex);
    return !breakpoints.empty() && action == asIDBAction::None;
}

// debugger operations; these set the next breakpoint
// and call Resume.
void asIDBDebugger::SetAction(asIDBAction new_action)
{
    // should never happen
    if (new_action == asIDBAction::None)
        return;

    if (new_action != asIDBAction::Continue)
    {
        std::scoped_lock lock(mutex);
        action = new_action;
        stack_size = cache->ctx->GetCallstackSize();
    }
    
    Resume();
}

bool asIDBDebugger::ToggleBreakpoint(std::string_view section, int line)
{
    auto it = breakpoints.find(section);

    if (it == breakpoints.end())
        it = breakpoints.emplace(section, asIDBSectionBreakpoints {}).first;

    for (auto lit = it->second.begin(); lit != it->second.end(); lit++)
    {
        if (lit->line == line)
        {
            it->second.erase(lit);

            if (it->second.empty())
                breakpoints.erase(it);

            return false;
        }
    }

    it->second.push_back({ line });
    return true;
}
