#pragma once

#include <angelscript.h>

struct q2as_registry_exception : public std::runtime_error
{
    using runtime_error::runtime_error;
};

struct q2as_type_registry
{
    asIScriptEngine *engine;
    const std::string_view name;

    q2as_type_registry(asIScriptEngine *engine, const std::string_view name) :
        engine(engine),
        name(name)
    {
    }

    struct property_defn
    {
        std::string decl;
        int offset;
        int compositeOffset = 0;
        bool isCompositeIndirect = false;
    };

    struct behavior_defn
    {
        asEBehaviours beh = (asEBehaviours) 0;
        std::string decl {};
        asSFuncPtr funcPointer {};
        asDWORD callConv = 0;
        void *auxiliary = nullptr;
        int compositeOffset = 0;
        bool isCompositeIndirect = false;
    };

    struct method_defn
    {
        std::string decl;
        asSFuncPtr funcPointer {};
        asDWORD callConv = 0;
        void *auxiliary = nullptr;
        int compositeOffset = 0;
        bool isCompositeIndirect = false;
    };

    q2as_type_registry &property(const property_defn &prop)
    {
        if (name.empty())
            throw q2as_registry_exception("missing type name");

        if (engine->RegisterObjectProperty(name.data(), prop.decl.c_str(), prop.offset, prop.compositeOffset, prop.isCompositeIndirect) < 0)
            throw q2as_registry_exception("can't register property");

        return *this;
    }
    template<size_t N>
    q2as_type_registry &properties(const property_defn (&props)[N])
    {
        for (auto &prop : props)
            property(prop);

        return *this;
    }
    q2as_type_registry &behavior(const behavior_defn behavior)
    {
        if (name.empty())
            throw q2as_registry_exception("missing type name");

        if (engine->RegisterObjectBehaviour(name.data(), behavior.beh, behavior.decl.c_str(), behavior.funcPointer, behavior.callConv, behavior.auxiliary, behavior.compositeOffset, behavior.isCompositeIndirect) < 0)
            throw q2as_registry_exception("can't register property");

        return *this;
    }
    template<size_t N>
    q2as_type_registry &behaviors(const behavior_defn (&behaviors)[N])
    {
        for (auto &beh : behaviors)
            behavior(beh);

        return *this;
    }
    q2as_type_registry &method(const method_defn &method)
    {
        if (name.empty())
            throw q2as_registry_exception("missing type name");

        if (engine->RegisterObjectMethod(name.data(), method.decl.c_str(), method.funcPointer, method.callConv, method.auxiliary, method.compositeOffset, method.isCompositeIndirect) < 0)
            throw q2as_registry_exception("can't register property");

        return *this;
    }
    template<size_t N>
    q2as_type_registry &methods(const method_defn (&methods)[N])
    {
        for (auto &in_method : methods)
            method(in_method);

        return *this;
    }
};

struct q2as_global_registry
{
    asIScriptEngine *engine;

    q2as_global_registry(asIScriptEngine *engine) :
        engine(engine)
    {
    }

    struct global_property_defn
    {
        std::string decl;

        template<typename T>
        global_property_defn(std::string_view decl, T *ptr) :
            decl(decl),
            ptr(ptr)
        {
        }

        template<typename T>
        global_property_defn(std::string_view decl, const T *ptr) :
            decl(decl),
            cptr(ptr)
        {
        }

        void *ptr = nullptr;
        const void *cptr = nullptr;
    };

    struct function_defn
    {
        std::string decl;
        asSFuncPtr funcPointer {};
        asDWORD callConv = 0;
        void *auxiliary = nullptr;
    };

    q2as_global_registry &property(const global_property_defn &prop)
    {
        bool is_constant = std::string_view(prop.decl).find("const ") == 0;

        if (is_constant != !!prop.cptr)
            throw q2as_registry_exception("global property constant mismatch");

        if (engine->RegisterGlobalProperty(prop.decl.c_str(), prop.ptr ? prop.ptr : const_cast<void *>(prop.cptr)) < 0)
            throw q2as_registry_exception("can't register global property");

        return *this;
    }
    template<size_t N>
    q2as_global_registry &properties(const global_property_defn (&props)[N])
    {
        for (auto &prop : props)
            property(prop);

        return *this;
    }
    q2as_global_registry &function(const function_defn &method)
    {
        if (engine->RegisterGlobalFunction(method.decl.c_str(), method.funcPointer, method.callConv, method.auxiliary) < 0)
            throw q2as_registry_exception("can't register property");

        return *this;
    }
    template<size_t N>
    q2as_global_registry &functions(const function_defn (&methods)[N])
    {
        for (auto &method : methods)
            function(method);

        return *this;
    }
};

struct q2as_enum_registry
{
    asIScriptEngine *engine;
    const std::string_view name;

    q2as_enum_registry(asIScriptEngine *engine, const std::string_view name) :
        engine(engine),
        name(name)
    {
    }

    struct enum_defn
    {
        std::string name;
        asINT64 value;
    };

    q2as_enum_registry &value(const enum_defn &val)
    {
        engine->RegisterEnumValue(this->name.data(), val.name.c_str(), val.value);
        return *this;
    }
    template<size_t N>
    q2as_enum_registry &values(const enum_defn (&vals)[N])
    {
        for (auto &val : vals)
            value(val);

        return *this;
    }
};

struct q2as_interface_registry
{
    asIScriptEngine *engine;
    const std::string_view name;

    q2as_interface_registry(asIScriptEngine *engine, const std::string_view name) :
        engine(engine),
        name(name)
    {
    }

    q2as_interface_registry &method(const std::string_view declaration)
    {
        engine->RegisterInterfaceMethod(name.data(), declaration.data());
        return *this;
    }
    template<size_t N>
    q2as_interface_registry &methods(const std::string_view (&declarations)[N])
    {
        for (auto &decl : declarations)
            method(decl);

        return *this;
    }
};

// replacing the older dumb globals with these.
struct q2as_registry
{
    asIScriptEngine *engine;

    q2as_registry(asIScriptEngine *engine) :
        engine(engine)
    {
    }

    // change type context
    q2as_type_registry for_type(const std::string_view name)
    {
        if (!engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("missing type");

        return q2as_type_registry(engine, name);
    }
    // create new type + change type context
    q2as_type_registry type(const std::string_view name, size_t size, asQWORD flags)
    {
        if (engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("type already exists");
        else if (engine->RegisterObjectType(name.data(), size, flags) < 0)
            throw q2as_registry_exception("can't register type");

        return q2as_type_registry(engine, name);
    }

    // change type context
    q2as_interface_registry for_interface(const std::string_view name)
    {
        if (!engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("missing interface");

        return q2as_interface_registry(engine, name);
    }
    // create new interface + change type context
    q2as_interface_registry interface(const std::string_view name)
    {
        if (engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("interface already exists");
        else if (engine->RegisterInterface(name.data()) < 0)
            throw q2as_registry_exception("can't register interface");

        return q2as_interface_registry(engine, name);
    }

    // change type context
    q2as_enum_registry for_enumeration(const std::string_view name)
    {
        if (!engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("missing enum");

        return q2as_enum_registry(engine, name);
    }
    // create new type + change type context
    q2as_enum_registry enumeration(const std::string_view name, const std::string_view type = "int32")
    {
        if (engine->GetTypeInfoByName(name.data()))
            throw q2as_registry_exception("enum already exists");
        else if (engine->RegisterEnum(name.data(), type.data()) < 0)
            throw q2as_registry_exception("can't register enum");

        return q2as_enum_registry(engine, name);
    }

    // change to global context
    q2as_global_registry for_global()
    {
        return q2as_global_registry(engine);
    }

    q2as_registry &funcdef(const std::string_view def)
    {
        engine->RegisterFuncdef(def.data());
        return *this;
    }

    template<size_t N>
    q2as_registry &funcdefs(const std::string_view (&defs)[N])
    {
        for (auto &def : defs)
            funcdef(def);

        return *this;
    }

    q2as_registry &set_namespace()
    {
        engine->SetDefaultNamespace("");
        return *this;
    }

    q2as_registry &set_namespace(const std::string_view str)
    {
        engine->SetDefaultNamespace(str.data());
        return *this;
    }
};

#define Ensure(...) \
	if (int r = __VA_ARGS__; r < 0) throw q2as_registry_exception("AngelScript registration failed")

// factory functions for registration

template<typename T, typename A>
void Q2AS_Factory(asIScriptGeneric *gen)
{
    T *ptr = reinterpret_cast<T *>(A::AllocStatic(sizeof(T)));
    *(T **) gen->GetAddressOfReturnLocation() = ptr;
    new(ptr) T();
}

template<typename T>
void Q2AS_AddRefObject(T *object)
{
    object->refs++;
}

template<typename T>
void Q2AS_AddRef(asIScriptGeneric *gen)
{
    T *object = (T *) gen->GetObject();
    Q2AS_AddRefObject(object);
}

template<typename T, typename A>
bool Q2AS_ReleaseObj(T *object)
{
    if (!(--object->refs))
    {
        object->~T();
        A::FreeStatic(object);
        return true;
    }

    return false;
}

template<typename T, typename A>
void Q2AS_Release(asIScriptGeneric *gen)
{
    T *object = (T *) gen->GetObject();
    Q2AS_ReleaseObj<T, A>(object);
}