#include "q2as_predefined.h"
#include "q2as_platform.h"
#include <angelscript.h>
#include <fstream>
#include <map>
#include <string>
#include <string_view>
#include <vector>

static std::string TypeToTypeName(asIScriptEngine *engine, int typeId, asETypeModifiers modifiers, bool variadic,
                                  std::string_view right_name)
{
    asITypeInfo *type = engine->GetTypeInfoById(typeId);

    std::string name;

    if (modifiers & asTM_CONST)
        name += "const ";

    const char *rawName;

    if (!type)
    {
        switch (typeId & asTYPEID_MASK_SEQNBR)
        {
        case asTYPEID_VOID:   rawName = "void"; break;
        case asTYPEID_BOOL:   rawName = "bool"; break;
        case asTYPEID_INT8:   rawName = "int8"; break;
        case asTYPEID_INT16:  rawName = "int16"; break;
        case asTYPEID_INT32:  rawName = "int32"; break;
        case asTYPEID_INT64:  rawName = "int64"; break;
        case asTYPEID_UINT8:  rawName = "uint8"; break;
        case asTYPEID_UINT16: rawName = "uint16"; break;
        case asTYPEID_UINT32: rawName = "uint32"; break;
        case asTYPEID_UINT64: rawName = "uint64"; break;
        case asTYPEID_FLOAT:  rawName = "float"; break;
        case asTYPEID_DOUBLE: rawName = "double"; break;
        default:              rawName = "?"; break;
        }
    }
    else
        rawName = type->GetName();

    name += rawName;

    if (type && type->GetSubTypeCount())
    {
        name += "<";

        for (asUINT v = 0; v < type->GetSubTypeCount(); v++)
        {
            if (v != 0)
                name += ", ";

            name += TypeToTypeName(engine, type->GetSubTypeId(v), (asETypeModifiers) 0, false, "");
        }

        name += ">";
    }

    bool is_handle = false;

    /*if (modifiers & asTM_HANDLE_TO_AUTO)
        name += " @+";
    else */
    if (!variadic && (typeId & (asTYPEID_OBJHANDLE | asTYPEID_HANDLETOCONST)))
    {
        // TODO: why are variadics handles?

        name += " @";
        is_handle = true;
    }
    else if (modifiers || variadic || !right_name.empty())
        name += " ";

    if (modifiers & asTM_INOUTREF)
    {
        name += (modifiers & asTM_INOUTREF) == asTM_INOUTREF ? "&"
                : (modifiers & asTM_INOUTREF) == asTM_OUTREF ? "&out"
                : (modifiers & asTM_INOUTREF) == asTM_INREF  ? "&in"
                                                             : "";

        if (variadic || (!right_name.empty() && (modifiers & asTM_INOUTREF) != asTM_INOUTREF))
            name += " ";
    }

    if (modifiers & asTM_IF_HANDLE_THEN_CONST)
    {
        name += "if_handle_then_const ";
    }

    if (variadic)
        name += "...";
    else if (!right_name.empty())
        name += right_name;

    return name;
}

static std::string FunctionToString(asIScriptEngine *engine, asIScriptFunction *func, asITypeInfo *type = nullptr,
                                    bool factory = false)
{
    std::string f;

    if (factory)
    {
        f = fmt::format("{}(", type->GetName());
    }
    else
    {
        asDWORD returnTypeFlags;
        int     returnTypeId = func->GetReturnTypeId(&returnTypeFlags);

        std::string templateParameters, prefix;

        if (func->GetSubTypeCount())
        {
            templateParameters = "<";

            for (asUINT t = 0; t < func->GetSubTypeCount(); t++)
            {
                asITypeInfo *ti = func->GetSubType(t);

                if (t != 0)
                    templateParameters += ", ";

                templateParameters += ti->GetName();
            }

            templateParameters += ">";
        }

        std::string returnType = TypeToTypeName(engine, returnTypeId, (asETypeModifiers) returnTypeFlags, false,
                                                fmt::format("{}{}", prefix, func->GetName()));

        f = fmt::format("{}{}(", returnType, templateParameters);
    }

    for (asUINT p = 0; p < func->GetParamCount(); p++)
    {
        int         paramTypeId;
        asDWORD     paramFlags;
        const char *paramName;
        const char *paramDefault;

        func->GetParam(p, &paramTypeId, &paramFlags, &paramName, &paramDefault);

        if (p != 0)
            f += ", ";

        bool is_variadic = p == func->GetParamCount() - 1 && func->IsVariadic();

        std::string paramType =
            TypeToTypeName(engine, paramTypeId, (asETypeModifiers) paramFlags, is_variadic, paramName);

        f += fmt::format("{}", paramType);

        if (paramDefault)
            f += fmt::format(" = {}", paramDefault);
    }

    f += ")";

    if (func->IsReadOnly())
        f += " const";
    if (func->IsProperty())
        f += " property";
    if (func->IsNoDiscard())
        f += " nodiscard";
    if (func->IsExplicit())
        f += " explicit";
    if (func->IsOverride())
        f += " override";
    if (func->IsFinal())
        f += " final";

    f += ";";

    return f;
}

struct EnumInfo
{
    std::string              decl;
    std::vector<std::string> values;
};

static std::string EnumToDecl(asITypeInfo *type)
{
    const char *primType;

    switch (type->GetTypedefTypeId())
    {
    case asTYPEID_INT8:   primType = "int8"; break;
    case asTYPEID_INT16:  primType = "int16"; break;
    default:
    case asTYPEID_INT32:  primType = "int32"; break;
    case asTYPEID_INT64:  primType = "int64"; break;
    case asTYPEID_UINT8:  primType = "uint8"; break;
    case asTYPEID_UINT16: primType = "uint16"; break;
    case asTYPEID_UINT32: primType = "uint32"; break;
    case asTYPEID_UINT64: primType = "uint64"; break;
    }

    return fmt::format("enum {} : {}", type->GetName(), primType);
}

static void GetEnumInfo(EnumInfo &enuminfo, asITypeInfo *type)
{
    for (asUINT v = 0; v < type->GetEnumValueCount(); v++)
    {
        // TODO: proper signedness
        asINT64     ev;
        const char *name = type->GetEnumValueByIndex(v, &ev);
        std::string val = fmt::format("{} = {}", name, ev);

        if (std::find(enuminfo.values.begin(), enuminfo.values.end(), val) == enuminfo.values.end())
            enuminfo.values.push_back(val);
    }
}

static std::vector<std::string> EnumToLines(const EnumInfo &enuminfo)
{
    std::vector<std::string> lines;

    lines.push_back(enuminfo.decl);
    lines.push_back("{");

    for (size_t i = 0; i < enuminfo.values.size(); i++)
        lines.push_back(fmt::format("\t{}{}", enuminfo.values[i], i == enuminfo.values.size() - 1 ? "" : ","));

    lines.push_back("}");

    return lines;
}

struct ObjectInfo
{
    std::string              decl;
    std::vector<std::string> funcdefs;
    std::vector<std::string> properties;
    std::vector<std::string> behaviors;
    std::vector<std::string> factories;
    std::vector<std::string> methods;
};

static std::string ObjectToDecl(asITypeInfo *type)
{
    std::string class_decl = fmt::format("class {}", type->GetName());

    if (type->GetSubTypeCount())
    {
        class_decl += "<";

        for (asUINT t = 0; t < type->GetSubTypeCount(); t++)
        {
            if (t != 0)
                class_decl += ", ";

            class_decl += type->GetSubType(t)->GetName();
        }

        class_decl += ">";
    }

    return class_decl;
}

static void stream_line(std::ofstream &of, int depth, const std::string_view v)
{
    for (int i = 0; i < depth; i++)
        of << '\t';

    of << v;
    of << '\n';
}

static void stream_block(std::ofstream &of, int depth, const std::string_view header,
                         const std::vector<std::vector<std::string>> &lines)
{
    if (!header.empty())
        stream_line(of, depth, fmt::format("// {}", header));

    for (auto &ls : lines)
        for (auto &l : ls)
            stream_line(of, depth, l);
}

static void stream_block(std::ofstream &of, int depth, const std::string_view header,
                         const std::vector<std::string> &lines)
{
    if (!header.empty())
        stream_line(of, depth, fmt::format("// {}", header));

    for (auto &l : lines)
        stream_line(of, depth, l);
}

static void GetObjectInfo(ObjectInfo &obj, asIScriptEngine *engine, asITypeInfo *type)
{
    for (asUINT f = 0; f < type->GetChildFuncdefCount(); f++)
    {
        asITypeInfo *funcdef = type->GetChildFuncdef(f);
        std::string  decl = "funcdef " + FunctionToString(engine, funcdef->GetFuncdefSignature(), funcdef);

        if (std::find(obj.funcdefs.begin(), obj.funcdefs.end(), decl) == obj.funcdefs.end())
            obj.funcdefs.push_back(decl);
    }

    for (asUINT p = 0; p < type->GetPropertyCount(); p++)
    {
        const char *propName;
        int         propTypeId;
        bool        propIsPrivate;
        bool        propIsProtected;
        int         propOffset;
        bool        propReference;
        asDWORD     propAccessMask;
        int         propCompositeOffset;
        bool        propIsCompositeIndirect;
        bool        propReadOnly;
        type->GetProperty(p, &propName, &propTypeId, &propIsPrivate, &propIsProtected, &propOffset, &propReference,
                          &propAccessMask, &propCompositeOffset, &propIsCompositeIndirect, &propReadOnly);

        std::string typeName =
            TypeToTypeName(engine, propTypeId, (asETypeModifiers) (propReference ? asTM_INOUTREF : 0), false, propName);
        std::string decl = fmt::format("{}{}{};",
                                       propIsPrivate     ? "private "
                                       : propIsProtected ? "protected "
                                                         : "",
                                       propReadOnly ? "const " : "", typeName);

        if (std::find(obj.properties.begin(), obj.properties.end(), decl) == obj.properties.end())
            obj.properties.push_back(decl);
    }

    for (asUINT f = 0; f < type->GetBehaviourCount(); f++)
    {
        asEBehaviours      beh;
        asIScriptFunction *func = type->GetBehaviourByIndex(f, &beh);

        if (beh == asEBehaviours::asBEHAVE_ADDREF || beh == asEBehaviours::asBEHAVE_ENUMREFS ||
            beh == asEBehaviours::asBEHAVE_FIRST_GC || beh == asEBehaviours::asBEHAVE_GETGCFLAG ||
            beh == asEBehaviours::asBEHAVE_GETREFCOUNT || beh == asEBehaviours::asBEHAVE_GET_WEAKREF_FLAG ||
            beh == asEBehaviours::asBEHAVE_LAST_GC || beh == asEBehaviours::asBEHAVE_RELEASE ||
            beh == asEBehaviours::asBEHAVE_RELEASEREFS || beh == asEBehaviours::asBEHAVE_SETGCFLAG ||
            beh == asEBehaviours::asBEHAVE_TEMPLATE_CALLBACK)
            continue;

        std::string decl = func->GetDeclaration(false, false, true);

        if (beh == asEBehaviours::asBEHAVE_LIST_CONSTRUCT || beh == asEBehaviours::asBEHAVE_LIST_FACTORY)
            decl = type->GetName() + decl.substr(decl.find("$list") + 5);

        if (type->GetSubTypeCount() != 0 &&
            (beh == asEBehaviours::asBEHAVE_LIST_CONSTRUCT || beh == asEBehaviours::asBEHAVE_LIST_FACTORY ||
             beh == asEBehaviours::asBEHAVE_FACTORY || beh == asEBehaviours::asBEHAVE_CONSTRUCT))
        {
            size_t s = decl.find_first_of('(');
            size_t i = decl.find_first_of(",)");

            if (i != std::string::npos)
            {
                if (decl[i] == ',')
                {
                    decl.erase(s + 1, (i - s));

                    while ((s + 1) < decl.size() && decl[s + 1] == ' ')
                        decl.erase(s + 1, 1);
                }
                else
                    decl.erase(s + 1, (i - s) - 1);
            }
        }

        if (func->IsExplicit())
            decl += " explicit";

        decl = decl + ";";

        if (std::find(obj.behaviors.begin(), obj.behaviors.end(), decl) == obj.behaviors.end())
            obj.behaviors.push_back(decl);
    }

    for (asUINT f = 0; f < type->GetFactoryCount(); f++)
    {
        std::string str = FunctionToString(engine, type->GetFactoryByIndex(f), type, true);

        if (type->GetSubTypeCount() != 0)
        {
            size_t s = str.find_first_of('(');
            size_t i = str.find_first_of(",)");

            if (i != std::string::npos)
            {
                if (str[i] == ',')
                {
                    str.erase(s + 1, (i - s));

                    while ((s + 1) < str.size() && str[s + 1] == ' ')
                        str.erase(s + 1, 1);
                }
                else
                    str.erase(s + 1, (i - s) - 1);
            }
        }

        if (std::find(obj.factories.begin(), obj.factories.end(), str) == obj.factories.end())
            obj.factories.push_back(str);
    }

    for (asUINT f = 0; f < type->GetMethodCount(); f++)
    {
        std::string str = FunctionToString(engine, type->GetMethodByIndex(f, false));

        if (std::find(obj.methods.begin(), obj.methods.end(), str) == obj.methods.end())
            obj.methods.push_back(str);
    }
}

static std::vector<std::string> ObjectToLines(std::ofstream &of, int depth, const ObjectInfo &obj)
{
    std::vector<std::string> lines;

    stream_line(of, depth, obj.decl);
    stream_line(of, depth, "{");

    if (!obj.funcdefs.empty())
        stream_block(of, depth + 1, "funcdefs", obj.funcdefs);
    if (!obj.properties.empty())
        stream_block(of, depth + 1, "properties", obj.properties);
    if (!obj.behaviors.empty())
        stream_block(of, depth + 1, "behaviors", obj.behaviors);
    if (!obj.factories.empty())
        stream_block(of, depth + 1, "factories", obj.factories);
    if (!obj.methods.empty())
        stream_block(of, depth + 1, "methods", obj.methods);

    stream_line(of, depth, "}");

    return lines;
}

struct NamespaceInfo
{
    std::vector<std::vector<std::string>> typedefs;
    std::vector<EnumInfo>                 enums;
    std::vector<std::string>              funcdefs;
    std::vector<ObjectInfo>               objects;
    std::vector<std::string>              properties;
    std::vector<std::string>              functions;

    void block(std::ofstream &of, int depth, const std::string_view header, const decltype(enums) &enuminfos)
    {
        if (!header.empty())
            stream_line(of, depth, fmt::format("// {}", header));

        for (auto &i : enuminfos)
            stream_block(of, depth, "", EnumToLines(i));
    }

    void block(std::ofstream &of, int depth, const std::string_view header, const decltype(objects) &objectinfos)
    {
        if (!header.empty())
            stream_line(of, depth, fmt::format("// {}", header));

        for (auto &i : objectinfos)
            stream_block(of, depth, "", ObjectToLines(of, depth, i));
    }

    void write(std::ofstream &of, int depth)
    {
        if (!typedefs.empty())
            stream_block(of, depth, "typedefs", typedefs);
        if (!enums.empty())
            block(of, depth, "enums", enums);
        if (!funcdefs.empty())
            stream_block(of, depth, "funcdefs", funcdefs);
        if (!objects.empty())
            block(of, depth, "objects", objects);
        if (!properties.empty())
            stream_block(of, depth, "properties", properties);
        if (!functions.empty())
            stream_block(of, depth, "functions", functions);
    }
};

template<size_t N>
static void WritePredefinedEngines(std::array<asIScriptEngine *, N> engines, const char *filename)
{
    std::ofstream of(Q2AS_GetModulePath().path.parent_path() / filename, std::ios_base::binary | std::ios_base::out);

    std::map<std::string, NamespaceInfo> namespaces;

    for (auto &engine : engines)
    {
        if (!engine)
            continue;
        // TODO: no typedefs used
        /*
        for (asUINT i = 0; i < engine->GetTypedefCount(); i++)
        {
            asITypeInfo *type = engine->GetTypedefByIndex(i);
        }
        */

        for (asUINT i = 0; i < engine->GetEnumCount(); i++)
        {
            asITypeInfo *type = engine->GetEnumByIndex(i);
            auto        &ns = namespaces[type->GetNamespace()];
            std::string  decl = EnumToDecl(type);
            EnumInfo    *info = nullptr;

            for (auto &e : ns.enums)
                if (e.decl == decl)
                {
                    info = &e;
                    break;
                }

            if (!info)
            {
                info = &ns.enums.emplace_back();
                info->decl = std::move(decl);
            }

            GetEnumInfo(*info, type);
        }

        for (asUINT i = 0; i < engine->GetFuncdefCount(); i++)
        {
            asITypeInfo *funcdef = engine->GetFuncdefByIndex(i);

            if (funcdef->GetParentType())
                continue;

            auto &ns = namespaces[funcdef->GetNamespace()];

            std::string line = "funcdef " + FunctionToString(engine, funcdef->GetFuncdefSignature(), funcdef);

            if (std::find(ns.funcdefs.begin(), ns.funcdefs.end(), line) == ns.funcdefs.end())
                ns.funcdefs.emplace_back(line);
        }

        for (asUINT i = 0; i < engine->GetObjectTypeCount(); i++)
        {
            asITypeInfo *type = engine->GetObjectTypeByIndex(i);
            auto        &ns = namespaces[type->GetNamespace()];
            std::string  decl = ObjectToDecl(type);
            ObjectInfo  *info = nullptr;

            for (auto &e : ns.objects)
                if (e.decl == decl)
                {
                    info = &e;
                    break;
                }

            if (!info)
            {
                info = &ns.objects.emplace_back();
                info->decl = std::move(decl);
            }

            GetObjectInfo(*info, engine, type);
        }

        for (asUINT i = 0; i < engine->GetGlobalPropertyCount(); i++)
        {
            const char *name;
            const char *nameSpace;
            int         typeId;
            bool        isConst;
            const char *configGroup;
            void       *pointer;
            asDWORD     accessMask;
            engine->GetGlobalPropertyByIndex(i, &name, &nameSpace, &typeId, &isConst, &configGroup, &pointer,
                                             &accessMask);

            auto       &ns = namespaces[nameSpace];
            std::string typeName =
                TypeToTypeName(engine, typeId, (asETypeModifiers) (isConst ? asTM_CONST : 0), false, name) + ';';

            if (std::find(ns.properties.begin(), ns.properties.end(), typeName) == ns.properties.end())
                ns.properties.emplace_back(typeName);
        }

        for (asUINT i = 0; i < engine->GetGlobalFunctionCount(); i++)
        {
            asIScriptFunction *func = engine->GetGlobalFunctionByIndex(i);
            auto              &ns = namespaces[func->GetNamespace()];
            std::string        line = FunctionToString(engine, engine->GetGlobalFunctionByIndex(i));

            if (std::find(ns.functions.begin(), ns.functions.end(), line) == ns.functions.end())
                ns.functions.push_back(line);
        }
    }

    for (auto &ns : namespaces)
        if (!ns.first.empty())
        {
            of << fmt::format("namespace {}\n{{\n", ns.first);
            ns.second.write(of, 1);
            of << "}\n";
        }

    namespaces[""].write(of, 0);

    of << '\n';
}

#include "q2as_cgame.h"
#include "q2as_game.h"
#include "thirdparty/scripthelper/scripthelper.h"

void WritePredefined()
{
    WritePredefinedEngines(std::array<asIScriptEngine *, 2>({ svas.engine, cgas.engine }), "as.predefined");

    WriteConfigToFile(svas.engine,
                      (Q2AS_GetModulePath().path.parent_path() / "engine.config").generic_string().c_str());
}