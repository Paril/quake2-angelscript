#include "q2as_local.h"
#include "q2as_reg.h"

static void q2as_reflect_global_from_name(asIScriptGeneric *gen)
{
    const std::string *in_name = (std::string *) gen->GetArgAddress(0);
    *((bool *)gen->GetAddressOfReturnLocation()) = false;
    bool silent = gen->GetArgByte(2);
    auto ref = reinterpret_cast<void**>(gen->GetArgAddress(1));
    *ref = nullptr;

    if (!in_name || in_name->empty())
    {
        // always silent, otherwise save/load would be rough
        return;
    }

    auto typeId = gen->GetArgTypeId(1);
    auto typeInfo = gen->GetEngine()->GetTypeInfoById(typeId);
    auto as = (q2as_state_t *) gen->GetEngine()->GetUserData();
    
    if (auto sig = typeInfo->GetFuncdefSignature())
    {
        // engine?
        asIScriptFunction *func = as->mainModule->GetFunctionByName(in_name->c_str());

        if (func)
        {
            gen->GetEngine()->RefCastObject(func, as->engine->GetTypeInfoById(func->GetTypeId()), typeInfo, ref);
            *((bool *)gen->GetAddressOfReturnLocation()) = (*ref != nullptr);
            return;
        }
    }
    else
    {
        std::string str;

        // engine?
        for (asUINT i = 0; i < as->mainModule->GetGlobalVarCount(); i++)
        {
            const char *name, *ns;
            int typeId;

            as->mainModule->GetGlobalVar(i, &name, &ns, &typeId);

            if (!ns || !*ns)
                str = name;
            else
                str = G_Fmt("{}::{}", ns, name);

            if (*in_name != str)
                continue;

            gen->GetEngine()->RefCastObject(as->mainModule->GetAddressOfGlobalVar(i), as->engine->GetTypeInfoById(typeId), typeInfo, ref);
            *((bool *)gen->GetAddressOfReturnLocation()) = (*ref != nullptr);
            return;
        }
    }
    
    if (!silent)
        asGetActiveContext()->SetException(G_Fmt("Missing global {}", *in_name).data());
}

static void q2as_reflect_name_of_global(asIScriptGeneric *gen)
{
    asUINT i = 0;
    void *addr = gen->GetArgAddress(0);
    auto typeId = gen->GetArgTypeId(0);
    auto typeInfo = gen->GetEngine()->GetTypeInfoById(typeId);
    auto as = (q2as_state_t *) gen->GetEngine()->GetUserData();

    if (addr == nullptr)
    {
        new(gen->GetAddressOfReturnLocation()) std::string();
        return;
    }

    if (auto sig = typeInfo->GetFuncdefSignature())
    {
        auto func = (asIScriptFunction *) addr;
        const char *name = func->GetName(), *ns = func->GetNamespace();
        std::string str;
        if (!ns || !*ns)
            str = name;
        else
            str = G_Fmt("{}::{}", ns, name);

        new(gen->GetAddressOfReturnLocation()) std::string(std::move(str));
        
        func->Release();
        return;
    }
    else
    {
        // engine?
        for (; i < as->mainModule->GetGlobalVarCount(); i++)
        {
            if (as->mainModule->GetAddressOfGlobalVar(i) == addr)
            {
                std::string str;
                const char *name, *ns;
                as->mainModule->GetGlobalVar(i, &name, &ns);

                if (!ns || !*ns)
                    str = name;
                else
                    str = G_Fmt("{}::{}", ns, name);

                new(gen->GetAddressOfReturnLocation()) std::string(std::move(str));
                ((asIScriptObject *) addr)->Release();
                return;
            }
        }
    }

    asGetActiveContext()->SetException("Missing global!");
    ((asIScriptObject *) addr)->Release();
}

bool Q2AS_RegisterReflection(asIScriptEngine *engine)
{
    // reflection
    EnsureRegisteredGlobalFunction("string reflect_name_of_global<T>(const T @)", asFUNCTION(q2as_reflect_name_of_global), asCALL_GENERIC);
    EnsureRegisteredGlobalFunction("bool reflect_global_from_name<T>(const string &in, T @&out, bool = false)", asFUNCTION(q2as_reflect_global_from_name), asCALL_GENERIC);

    return true;
}