#include "q2as_local.h"

#include "thirdparty/scriptstdstring/scriptstdstring.h"
#include "thirdparty/scriptany/scriptany.h"
#include "thirdparty/scriptarray/scriptarray.h"
#include "thirdparty/scriptdictionary/scriptdictionary.h"
#include "thirdparty/datetime/datetime.h"
#include "thirdparty/weakref/weakref.h"
#include "thirdparty/scripthelper/scripthelper.h"

class q2as_asIDBStringTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        const std::string *s = var->address.ResolveAs<const std::string>();

        if (s->empty())
            var->value = "(empty)";
        else
            var->value = *s;
    }
};

class q2as_asIDBArrayTypeEvaluator : public asIDBObjectTypeEvaluator
{
public:
    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        QueryVariableForEach(var, 0);
    }
};

class q2as_asIDBAnyTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        const CScriptAny *v = var->address.ResolveAs<const CScriptAny>();

        if (v->GetTypeId() == 0)
        {
            var->value = "(no stored value)";
            return;
        }
        
        var->value = fmt::format("any<{}>", var->dbg.cache->GetTypeNameFromType({ v->GetTypeId(), asTM_NONE }));
        var->MakeExpandable();
    }

    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        const CScriptAny *v = var->address.ResolveAs<const CScriptAny>();

        asIDBVarAddr id(v->value.typeId, false, nullptr);

        if (v->value.typeId == asTYPEID_DOUBLE)
            id.address = (void *) &v->value.valueFlt;
        else if (v->value.typeId == asTYPEID_INT64)
            id.address = (void *) &v->value.valueInt;
        else if (v->value.typeId & (asTYPEID_HANDLETOCONST | asTYPEID_OBJHANDLE))
            id.address = (void *) &v->value.valueObj;
        else
            id.address = v->value.valueObj;

        var->CreateChildVariable("value", "", id, var->dbg.cache->GetTypeNameFromType({ v->GetTypeId(), asTM_NONE }));
    }
};

class q2as_asIDBDictionaryTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        const CScriptDictionary *v = var->address.ResolveAs<const CScriptDictionary>();

        size_t size = v->GetSize();

        var->value = fmt::format("{{{} key/value pairs}}", size);

        if (size)
            var->MakeExpandable();
    }

    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        const CScriptDictionary *v = var->address.ResolveAs<const CScriptDictionary>();

        for (auto &kvp : *v)
        {
            auto child = var->CreateChildVariable(
                fmt::format("[{}]", kvp.GetKey()),
                "",
                { kvp.GetTypeId(), false, const_cast<void *>(kvp.GetAddressOfValue()) },
                var->dbg.cache->GetTypeNameFromType({ kvp.GetTypeId(), asTM_NONE }));
            child->Evaluate();
        }
    }
};

void Q2AS_RegisterThirdParty(q2as_registry &registry)
{
    RegisterStdString(registry.engine);
    RegisterScriptArray(registry.engine, true);

    RegisterScriptAny(registry.engine);
    RegisterScriptDictionary(registry.engine);

    RegisterStdStringUtils(registry.engine);

    RegisterScriptDateTime(registry.engine);
    RegisterScriptWeakRef(registry.engine);

    RegisterExceptionRoutines(registry.engine);

    debugger_state.RegisterEvaluator<q2as_asIDBStringTypeEvaluator>(registry.engine, "string");
    debugger_state.RegisterEvaluator<q2as_asIDBArrayTypeEvaluator>(registry.engine, "array");
    debugger_state.RegisterEvaluator<q2as_asIDBAnyTypeEvaluator>(registry.engine, "any");
    debugger_state.RegisterEvaluator<q2as_asIDBDictionaryTypeEvaluator>(registry.engine, "dictionary");
}