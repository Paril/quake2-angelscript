// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS
#include <angelscript.h>
#include "as_debugger.h"
#include <bitset>

/*virtual*/ const asIDBVarAddr &asIDBVarView::GetID() const /*override*/
{
    return id;
}

/*virtual*/ asIDBVarState &asIDBVarView::GetState() /*override*/
{
    return state;
}

/*virtual*/ const asIDBVarState &asIDBVarView::GetState() const /*override*/
{
    return state;
}

void asIDBVariableContainer::Cache()
{
    if (cached)
        return;

    if (!source.container)
        __debugbreak(); // error

    asIDBVarState state { dbg->cache->evaluators.Evaluate(*dbg->cache, source.container->named_variables[source.index].address) };
    dbg->cache->evaluators.Expand(*dbg->cache, source.container->named_variables[source.index].address, state);

    if (state.stackMemory)
        __debugbreak(); // todo

    if (state.value.expandable == asIDBExpandType::Children)
    {
        for (auto &child : state.children)
        {
            auto &var = named_variables.emplace_back(asIDBNamedVariable { child.GetID(), child.name, child.type, std::move(child.state.value.value) });

            if (child.state.value.expandable != asIDBExpandType::None)
                var.container = dbg->cache->CreateVariableContainer(asIDBVariableSource { this, named_variables.size() - 1 });
        }
    }
    else if (state.value.expandable == asIDBExpandType::Entries)
    {
        for (auto &child : state.entries)
            named_variables.emplace_back(asIDBNamedVariable { asIDBVarAddr {}, "*", "", std::move(child.value) });
    }
    else if (state.value.expandable == asIDBExpandType::Value)
    {
        named_variables.emplace_back(asIDBNamedVariable { asIDBVarAddr {}, "value", "", std::move(state.value.value) });
    }

    cached = true;
}

asIDBScope::asIDBScope(asUINT offset, asIDBDebugger *dbg, asIScriptFunction *function) :
    offset(offset),
    parameters(dbg->cache->CreateVariableContainer()),
    locals(dbg->cache->CreateVariableContainer()),
    registers(dbg->cache->CreateVariableContainer())
{
    CalcLocals(dbg, function, parameters);
    CalcLocals(dbg, function, locals);
    CalcLocals(dbg, function, registers);
}

void asIDBScope::CalcLocals(asIDBDebugger *dbg, asIScriptFunction *function, asIDBVariableContainer *container)
{
    if (!function || offset == SCOPE_SYSTEM)
        return;

    container->cached = true;

    auto cache = dbg->cache.get();
    auto ctx = cache->ctx;
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

            const std::string_view viewType = dbg->cache->GetTypeNameFromType(typeKey);

            asIDBVarAddr idKey { thisTypeId, false, thisPtr };

            asIDBVarView view { "this", viewType, idKey, asIDBVarState { cache->evaluators.Evaluate(*cache, idKey) } };

            auto &var = container->named_variables.emplace_back(asIDBNamedVariable { idKey, "this", viewType, std::move(view.state.value.value) });

            if (view.state.value.expandable != asIDBExpandType::None)
                var.container = cache->CreateVariableContainer(asIDBVariableSource { container, container->named_variables.size() - 1 });
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

        const std::string_view viewType = dbg->cache->GetTypeNameFromType(typeKey);

        asIDBVarAddr idKey { typeId, (modifiers & asTM_CONST) != 0, ptr };

        asIDBVarView view { std::move(localName), viewType, idKey, asIDBVarState { cache->evaluators.Evaluate(*cache, idKey) } };

        auto &var = container->named_variables.emplace_back(asIDBNamedVariable { idKey, name, viewType, std::move(view.state.value.value) });

        if (view.state.value.expandable != asIDBExpandType::None)
            var.container = cache->CreateVariableContainer(asIDBVariableSource { container, container->named_variables.size() - 1 });
    }
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
        void *propAddr = *reinterpret_cast<uint8_t **>(reinterpret_cast<uint8_t *>(id.resolved) + compositeOffset);

        // if we're null, leave it alone, otherwise point to
        // where we really need to be pointing
        if (propAddr)
            propAddr = reinterpret_cast<uint8_t *>(propAddr) + offset;

        return propAddr;
    }

    return reinterpret_cast<uint8_t *>(id.resolved) + offset + compositeOffset;
}

#include <charconv>

/*virtual*/ asIDBExpected<asIDBExprResult> asIDBCache::ResolveExpression(const std::string_view expr, int stack_index)
{
    if (expr.empty())
        return asIDBExpected<asIDBExprResult>("empty string");

    // isolate the variable name first
    size_t variable_end = expr.find_first_of(".[", 0);
    std::string_view variable_name = expr.substr(0, variable_end);
    asIDBVarAddr variable_key;

    // if it starts with a & it has to be a local variable index
    if (variable_name[0] == '&')
    {
        uint16_t offset;
        auto result = std::from_chars(&variable_name.front(), &variable_name.front() + variable_name.size(), offset);

        if (result.ec != std::errc())
            return asIDBExpected<asIDBExprResult>("invalid numerical offset");

        // check bounds
        int m = ctx->GetVarCount(stack_index);

        if (offset >= m)
            return asIDBExpected<asIDBExprResult>("stack offset out of bounds");

        if (!ctx->IsVarInScope(offset, stack_index))
            return asIDBExpected<asIDBExprResult>("variable out of scope");

        // grab key
        asETypeModifiers modifiers;
        ctx->GetVar(offset, stack_index, 0, &variable_key.typeId, &modifiers);
        variable_key.constant = (modifiers & asTM_CONST) != 0;
        variable_key.address = ctx->GetAddressOfVar(offset, stack_index);
    }
    // check this
    else if (variable_name == "this")
    {
        if (!(variable_key.address = ctx->GetThisPointer(stack_index)))
            return asIDBExpected<asIDBExprResult>("not a method");

        variable_key.typeId = ctx->GetThisTypeId(stack_index);
    }
    else
    {
        struct asIDBNamespacedVar {
            asIDBVarAddr     addr;
            std::string_view name;
            std::string_view ns = "::";
        };

        std::vector<asIDBNamespacedVar> matches;
        std::string_view variable_ns;

        if (auto ns_end = variable_name.find_last_of(':'); ns_end != std::string_view::npos)
        {
            variable_ns = variable_name.substr(0, ns_end - 1);
            variable_name = variable_name.substr(ns_end + 1);
        }

        // not an offset; in order, check the following:
        // - local variables (in reverse order)
        // - function parameters
        // - class member properties (if appropriate)
        // - globals
        for (int i = ctx->GetVarCount(stack_index) - 1; i >= 0; i--)
        {
            if (!ctx->IsVarInScope(i, stack_index))
                continue;

            const char *name;
            int typeId;
            asETypeModifiers modifiers;
            ctx->GetVar(i, stack_index, &name, &typeId, &modifiers);

            if (variable_name != name)
                continue;

            matches.push_back({
                { typeId, (modifiers & asTM_CONST) != 0, ctx->GetAddressOfVar(i, stack_index) },
                name
            });
            break;
        }

        // check `this` parameters
        if (auto thisPtr = ctx->GetThisPointer(stack_index))
        {
            auto thisTypeId = ctx->GetThisTypeId(stack_index);
            auto type = ctx->GetEngine()->GetTypeInfoById(thisTypeId);

            for (asUINT i = 0; i < type->GetPropertyCount(); i++)
            {
                const char *name;
                int typeId;
                int offset;
                int compositeOffset;
                bool isCompositeIndirect;
                bool isReadOnly;

                type->GetProperty(i, &name, &typeId, 0, 0, &offset, 0, 0, &compositeOffset, &isCompositeIndirect, &isReadOnly);

                if (variable_name != name)
                    continue;
                    
                matches.push_back({
                    { typeId, isReadOnly, ResolvePropertyAddress(asIDBVarAddr { thisTypeId, false, thisPtr }, i, offset, compositeOffset, isCompositeIndirect) },
                    name
                });
                break;
            }
        }

        // check globals
        {
            auto main = ctx->GetFunction(0)->GetModule();

            for (asUINT n = 0; n < main->GetGlobalVarCount(); n++)
            {
                const char *name;
                int typeId;
                bool isConst;
                const char *ns;

                main->GetGlobalVar(n, &name, &ns, &typeId, &isConst);

                if (variable_name != name)
                    continue;
                
                matches.push_back({
                    { typeId, isConst, main->GetAddressOfGlobalVar(n) },
                    name,
                    (ns && *ns) ? ns : "::"
                });
            }
        }

        // check host properties
        {
            auto engine = ctx->GetEngine();

            for (asUINT n = 0; n < engine->GetGlobalPropertyCount(); n++)
            {
                const char *name;
                int typeId;
                bool isConst;
                void *ptr;
                const char *ns;

                engine->GetGlobalPropertyByIndex(n, &name, &ns, &typeId, &isConst, nullptr, &ptr);

                if (variable_name != name)
                    continue;
                
                matches.push_back({
                    { typeId, isConst, ptr },
                    name,
                    (ns && *ns) ? ns : "::"
                });
            }
        }

        if (matches.size() == 1)
            variable_key = matches[0].addr;
        // if we didn't specify a ns but had multiple
        // matches, return an error
        else if (variable_ns.empty())
            return asIDBExpected<asIDBExprResult>(matches.empty() ? "can't find variable" : "ambiguous variable name");
        else
        {
            for (auto &match : matches)
            {
                if (variable_ns == match.ns)
                {
                    variable_key = match.addr;
                    break;
                }
            }
        }

        if (!variable_key.typeId)
            return asIDBExpected<asIDBExprResult>("can't find variable");
    }

    // variable_key should be non-null and with
    // a valid type ID here.
    return ResolveSubExpression(variable_key, variable_end == std::string_view::npos ? std::string_view{} : expr.substr(variable_end), stack_index);
}

/*virtual*/ asIDBExpected<asIDBExprResult> asIDBCache::ResolveSubExpression(const asIDBResolvedVarAddr &idKey, const std::string_view rest, int stack_index)
{
    // nothing left, so this is the result.
    if (rest.empty())
        return asIDBExprResult { idKey.source, evaluators.Evaluate(*this, idKey) };

    // make sure we're a type that supports properties
    auto type = ctx->GetEngine()->GetTypeInfoById(idKey.source.typeId);

    if (!type || type->GetFlags() & (asOBJ_ENUM | asOBJ_FUNCDEF))
        return asIDBExpected<asIDBExprResult>("type is not allowed for sub-expressions");
    // uninitialized, etc
    else if (!idKey.resolved)
        return asIDBExpected<asIDBExprResult>("uninitialized or null object");

    // check what kind of sub-evaluator to use
    size_t eval_start = rest.find_first_of(".[", 1);
    std::string_view eval_name = rest.substr(1, eval_start == std::string_view::npos ? eval_start : (eval_start - 1));

    if (rest[0] == '.')
    {
        for (asUINT i = 0; i < type->GetPropertyCount(); i++)
        {
            const char *name;
            int typeId;
            int offset;
            int compositeOffset;
            bool isCompositeIndirect;
            bool isReadOnly;

            type->GetProperty(i, &name, &typeId, 0, 0, &offset, 0, 0, &compositeOffset, &isCompositeIndirect, &isReadOnly);

            if (eval_name != name)
                continue;

            void *propAddr = ResolvePropertyAddress(idKey, i, offset, compositeOffset, isCompositeIndirect);

            return ResolveSubExpression(asIDBVarAddr { typeId, isReadOnly, propAddr }, eval_start == std::string_view::npos ? std::string_view{} : rest.substr(eval_start), stack_index);
        }
    }
    else if (rest[0] == '[')
    {
        // TODO
        return asIDBExpected<asIDBExprResult>("array op not supported yet");
    }

    return asIDBExpected<asIDBExprResult>("can't resolve sub-expression");
}

/*virtual*/ void asIDBCache::CacheCallstack()
{
    if (!ctx || !call_stack.empty())
        return;

    if (auto sysfunc = ctx->GetSystemFunction())
        call_stack.emplace_back(asIDBCallStackEntry {
            dbg->frame_offset++,
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
            dbg->frame_offset++,
            std::move(decl),
            section,
            row,
            column,
            asIDBScope(n, dbg, func)
        });

        dbg->workspace.sections.insert(section);
    }
}

// restore data from the given cache that is
// being replaced by this one.
/*virtual*/ void asIDBCache::Restore(asIDBCache &cache)
{
}

/*virtual*/ void asIDBCache::CacheGlobals()
{
    if (!ctx || global->cached)
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

        asIDBVarView view { std::move(localName), viewType, idKey, asIDBVarState { evaluators.Evaluate(*this, idKey) } };

        auto &var = global->named_variables.emplace_back(asIDBNamedVariable { idKey, name, viewType, std::move(view.state.value.value) });

        if (view.state.value.expandable != asIDBExpandType::None)
            var.container = CreateVariableContainer(asIDBVariableSource { global, global->named_variables.size() - 1 });
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

        asIDBVarView view { std::move(localName), viewType, idKey, asIDBVarState { evaluators.Evaluate(*this, idKey) } };

        auto &var = global->named_variables.emplace_back(asIDBNamedVariable { idKey, name, viewType, std::move(view.state.value.value) });

        if (view.state.value.expandable != asIDBExpandType::None)
            var.container = CreateVariableContainer(asIDBVariableSource { global, global->named_variables.size() - 1 });
    }

    global->cached = true;
}

class asIDBNullTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override { return { "(null)", true }; }
};

class asIDBUninitTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override { return { "(uninit)", true }; }
};

#include <array>

class asIDBEnumTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &cache, const asIDBResolvedVarAddr &id) const override
    {
        // for enums where we have a single matched value
        // just display it directly; it might be a mask but that's OK.
        auto type = cache.ctx->GetEngine()->GetTypeInfoById(id.source.typeId);

        union {
            asINT64 v = 0;
            asQWORD uv;
        };
        
        switch (type->GetTypedefTypeId())
        {
        case asTYPEID_INT8:
            v = *reinterpret_cast<const int8_t *>(id.resolved);
            break;
        case asTYPEID_UINT8:
            uv = *reinterpret_cast<const uint8_t *>(id.resolved);
            break;
        case asTYPEID_INT16:
            v = *reinterpret_cast<const int16_t *>(id.resolved);
            break;
        case asTYPEID_UINT16:
            uv = *reinterpret_cast<const uint16_t *>(id.resolved);
            break;
        case asTYPEID_INT32:
            v = *reinterpret_cast<const int32_t *>(id.resolved);
            break;
        case asTYPEID_UINT32:
            uv = *reinterpret_cast<const uint32_t *>(id.resolved);
            break;
        case asTYPEID_INT64:
            v = *reinterpret_cast<const int64_t *>(id.resolved);
            break;
        case asTYPEID_UINT64:
            uv = *reinterpret_cast<const uint64_t *>(id.resolved);
            break;
        }

        for (asUINT e = 0; e < type->GetEnumValueCount(); e++)
        {
            asINT64 ov = 0;
            const char *name = type->GetEnumValueByIndex(e, &ov);

            if (ov == v)
            {
                if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
                    return fmt::format("{} ({})", name, uv);

                return fmt::format("{} ({})", name, v);
            }
        }
        
        std::bitset<32> bits(v);

        if (bits.count() == 1)
        {
            if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
                return fmt::format("{}", uv );
            return fmt::format("{}", v );
        }

        return { fmt::format("{} bits", bits.count()), false, asIDBExpandType::Entries };
    }

    virtual void Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const override
    {
        auto type = cache.ctx->GetEngine()->GetTypeInfoById(id.source.typeId);

        union {
            asINT64 v = 0;
            asQWORD uv;
        };
        
        switch (type->GetTypedefTypeId())
        {
        case asTYPEID_INT8:
            v = *reinterpret_cast<const int8_t *>(id.resolved);
            break;
        case asTYPEID_UINT8:
            uv = *reinterpret_cast<const uint8_t *>(id.resolved);
            break;
        case asTYPEID_INT16:
            v = *reinterpret_cast<const int16_t *>(id.resolved);
            break;
        case asTYPEID_UINT16:
            uv = *reinterpret_cast<const uint16_t *>(id.resolved);
            break;
        case asTYPEID_INT32:
            v = *reinterpret_cast<const int32_t *>(id.resolved);
            break;
        case asTYPEID_UINT32:
            uv = *reinterpret_cast<const uint32_t *>(id.resolved);
            break;
        case asTYPEID_INT64:
            v = *reinterpret_cast<const int64_t *>(id.resolved);
            break;
        case asTYPEID_UINT64:
            uv = *reinterpret_cast<const uint64_t *>(id.resolved);
            break;
        }
        
        if (type->GetTypedefTypeId() >= asTYPEID_UINT8 && type->GetTypedefTypeId() <= asTYPEID_UINT64)
            state.entries.push_back({ fmt::format("value: {}", uv) });
        else
            state.entries.push_back({ fmt::format("value: {}", v) });
        
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
                if (bit_names[e])
                    state.entries.push_back({ fmt::format("[{:2}] {}", e, bit_names[e]) });
                else
                    state.entries.push_back({ fmt::format("[{:2}] {}", e, 1 << e) });
            }
        }
    }
};

class asIDBFuncDefTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override
    {
        asIScriptFunction *ptr = reinterpret_cast<asIScriptFunction *>(id.resolved);
        return { ptr->GetName(), false };
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

auto asIDBObjectIteratorHelper::Begin(asIScriptContext *ctx) -> IteratorValue
{
    ctx->Prepare(opForBegin);
    ctx->SetObject(obj);
    ctx->Execute();

    return IteratorValue::FromCtxReturn(this, ctx);
}

auto asIDBObjectIteratorHelper::Next(asIScriptContext *ctx, const IteratorValue &val) -> IteratorValue
{
    ctx->Prepare(opForNext);
    ctx->SetObject(obj);
    val.SetArg(ctx, 0);
    ctx->Execute();

    return IteratorValue::FromCtxReturn(this, ctx);
}

bool asIDBObjectIteratorHelper::End(asIScriptContext *ctx, const IteratorValue &val)
{
    ctx->Prepare(opForEnd);
    ctx->SetObject(obj);
    val.SetArg(ctx, 0);
    ctx->Execute();
    return !!ctx->GetReturnByte();
}

/*virtual*/ asIDBVarValue asIDBObjectTypeEvaluator::Evaluate(asIDBCache &cache, const asIDBResolvedVarAddr &id) const /*override*/
{
    auto ctx = cache.ctx;
    auto type = ctx->GetEngine()->GetTypeInfoById(id.source.typeId);
    bool canExpand = type->GetPropertyCount();
    asIDBVarValue val;

    if (ctx->GetState() != asEXECUTION_EXCEPTION)
    {
        asIDBObjectIteratorHelper it(type, id.resolved);

        if (!it)
        {
            if (!it.error.empty())
                return { std::string(it.error), true, canExpand ? asIDBExpandType::Children : asIDBExpandType::None };
        }
        else
        {
            cache.dbg->internal_execution = true;
            ctx->PushState();

            size_t numElements = it.CalculateLength(ctx);

            val.value = fmt::format("{} elements", numElements);
            val.disabled = true;

            if (numElements)
                canExpand = true;

            ctx->PopState();
            cache.dbg->internal_execution = false;
        }
    }

    val.expandable = canExpand ? asIDBExpandType::Children : asIDBExpandType::None;

    return val;
}

/*virtual*/ void asIDBObjectTypeEvaluator::Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const /*override*/
{
    QueryVariableProperties(cache, id, state);

    QueryVariableForEach(cache, id, state);
}

// convenience function that queries the properties of the given
// address (and object, if set) of the given type.
void asIDBObjectTypeEvaluator::QueryVariableProperties(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &var) const
{
    auto type = cache.ctx->GetEngine()->GetTypeInfoById(id.source.typeId);

    asIScriptObject *obj = nullptr;

    if (id.source.typeId & asTYPEID_SCRIPTOBJECT)
        obj = (asIScriptObject *) id.resolved;

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

        propAddr = cache.ResolvePropertyAddress(id, n, offset, compositeOffset, isCompositeIndirect);

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
        var.children.emplace_back(name, cache.GetTypeNameFromType({ propTypeId, isReadOnly ? asTM_CONST : asTM_NONE }), propId, asIDBVarState { cache.evaluators.Evaluate(cache, propId) });
    }
}
    
// convenience function that iterates the opFor* of the given
// address (and object, if set) of the given type. If non-zero,
// a specific index will be used.
void asIDBObjectTypeEvaluator::QueryVariableForEach(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &var, int index) const
{
    auto ctx = cache.ctx;

    if (ctx->GetState() == asEXECUTION_EXCEPTION)
        return;

    auto type = ctx->GetEngine()->GetTypeInfoById(id.source.typeId);

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
    
    cache.dbg->internal_execution = true;
    ctx->PushState();
    ctx->Prepare(opForBegin);
    ctx->SetObject(id.resolved);
    ctx->Execute();

    uint32_t rtn = ctx->GetReturnDWord();

    while (true)
    {
        ctx->Prepare(opForEnd);
        ctx->SetObject(id.resolved);
        ctx->SetArgDWord(0, rtn);
        ctx->Execute();
        bool finished = ctx->GetReturnByte();

        if (finished)
            break;

        int fv = 0;
        for (auto &opfv : opForValues)
        {
            ctx->Prepare(opfv);
            ctx->SetObject(id.resolved);
            ctx->SetArgDWord(0, rtn);
            ctx->Execute();

            void *addr = ctx->GetReturnObject();
            int typeId = opfv->GetReturnTypeId();
            std::unique_ptr<uint8_t[]> stackMemory;

            if (!addr)
            {
                addr = ctx->GetReturnAddress();

                // non-heap stuff has to be copied somewhere
                // so the debugger can read it.
                if (!addr)
                {
                    auto type = ctx->GetEngine()->GetTypeInfoById(typeId);
                    size_t size = type ? type->GetSize() : ctx->GetEngine()->GetSizeOfPrimitiveType(typeId);
                    stackMemory = std::make_unique<uint8_t[]>(size);
                    memcpy(stackMemory.get(), ctx->GetAddressOfReturnValue(), size);
                    addr = stackMemory.get();
                }
            }
            // handles returned by reference have to be copied
            // so that dereferencing works later
            else if (typeId & (asTYPEID_HANDLETOCONST | asTYPEID_OBJHANDLE))
            {
                size_t size = sizeof(addr);
                stackMemory = std::make_unique<uint8_t[]>(size);
                memcpy(stackMemory.get(), &addr, size);
                addr = stackMemory.get();
            }

            asIDBVarAddr elemId { typeId, false, addr };

            var.children.emplace_back(fmt::vformat(opForValues.size() == 1 ? "[{0}]" : "[{0},{1}]", fmt::make_format_args(elementId, fv)), cache.GetTypeNameFromType({ typeId, asTM_NONE }), elemId,
                asIDBVarState { cache.evaluators.Evaluate(cache, elemId), std::move(stackMemory) });
            fv++;
        }
                
        ctx->Prepare(opForNext);
        ctx->SetObject(id.resolved);
        ctx->SetArgDWord(0, rtn);
        ctx->Execute();

        rtn = ctx->GetReturnDWord();

        elementId++;
    }

    ctx->PopState();
    cache.dbg->internal_execution = false;
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

asIDBVarValue asIDBTypeEvaluatorMap::Evaluate(asIDBCache &cache, const asIDBResolvedVarAddr &id) const
{
    return GetEvaluator(cache, id).Evaluate(cache, id);
}

void asIDBTypeEvaluatorMap::Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const
{
    GetEvaluator(cache, id).Expand(cache, id, state);
}

// Register an evaluator.
void asIDBTypeEvaluatorMap::Register(int typeId, std::unique_ptr<asIDBTypeEvaluator> evaluator)
{
    typeId &= asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR;
    evaluators.insert_or_assign(typeId, std::move(evaluator));
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
    int row = ctx->GetLineNumber(0, nullptr, &section);

    if (section)
    {
        std::scoped_lock lock(debugger->mutex);
        
        if (auto entries = debugger->breakpoints.find(section); entries != debugger->breakpoints.end())
        {
            for (auto &lines : entries->second)
            {
                if (row == lines.line)
                {
                    break_from_bp = true;
                    break;
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
    if (ctx->GetState() != asEXECUTION_EXCEPTION && engines.find(ctx->GetEngine()) != engines.end())
        ctx->SetLineCallback(asFUNCTION(asIDBDebugger::LineCallback), this, asCALL_CDECL);
}

void asIDBDebugger::DebugBreak(asIScriptContext *ctx)
{
    if (engines.find(ctx->GetEngine()) == engines.end())
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
