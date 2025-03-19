#include <angelscript.h>
#include <fstream>
#include <fmt/format.h>
#include <vector>
#include <map>
#include <string>
#include <string_view>
#include "q2as_predefined.h"

static std::string TypeToTypeName(asIScriptEngine *engine, int typeId, asETypeModifiers modifiers, bool variadic, std::string_view right_name)
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
	else */if (!variadic && (typeId & (asTYPEID_OBJHANDLE | asTYPEID_HANDLETOCONST)))
	{
		// TODO: why are variadics handles?

		name += " @";
		is_handle = true;
	}
	else if (modifiers || variadic || !right_name.empty())
		name += " ";

	if (modifiers & asTM_INOUTREF)
	{
		name += (modifiers & asTM_INOUTREF) == asTM_INOUTREF ? "&" :
				(modifiers & asTM_INOUTREF) == asTM_OUTREF ? "&out" :
				(modifiers & asTM_INOUTREF) == asTM_INREF ? "&in" :
				"";

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

static std::string FunctionToString(asIScriptEngine *engine, asIScriptFunction *func, asITypeInfo *type = nullptr, bool factory = false)
{
	std::string f;

	if (factory)
	{
		f = fmt::format("{}(", type->GetName());
	}
	else
	{
		asDWORD returnTypeFlags;
		int returnTypeId = func->GetReturnTypeId(&returnTypeFlags);

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

		std::string returnType = TypeToTypeName(engine, returnTypeId, (asETypeModifiers) returnTypeFlags, false, fmt::format("{}{}", prefix, func->GetName()));

		f = fmt::format("{}{}(", returnType, templateParameters);
	}

	for (asUINT p = 0; p < func->GetParamCount(); p++)
	{
		int paramTypeId;
		asDWORD paramFlags;
		const char *paramName;
		const char *paramDefault;

		func->GetParam(p, &paramTypeId, &paramFlags, &paramName, &paramDefault);

		if (p != 0)
			f += ", ";

		bool is_variadic = p == func->GetParamCount() - 1 && func->IsVariadic();
			
		std::string paramType = TypeToTypeName(engine, paramTypeId, (asETypeModifiers) paramFlags, is_variadic, paramName);

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

	f += ";";
	
	return f;
}

static std::vector<std::string> EnumToLines(asITypeInfo *type)
{
	std::vector<std::string> lines;
	const char *primType;

	switch (type->GetTypedefTypeId())
	{
	case asTYPEID_INT8: primType = "int8"; break;
	case asTYPEID_INT16: primType = "int16"; break;
	default: case asTYPEID_INT32: primType = "int32"; break;
	case asTYPEID_INT64: primType = "int64"; break;
	case asTYPEID_UINT8: primType = "uint8"; break;
	case asTYPEID_UINT16: primType = "uint16"; break;
	case asTYPEID_UINT32: primType = "uint32"; break;
	case asTYPEID_UINT64: primType = "uint64"; break;
	}

	lines.insert(lines.end(), {
		fmt::format("enum {} : {}", type->GetName(), primType),
		"{"
	});

	for (asUINT v = 0; v < type->GetEnumValueCount(); v++)
	{
		// TODO: proper signedness
		asINT64 ev;
		const char *name = type->GetEnumValueByIndex(v, &ev);

		lines.insert(lines.end(), {
			fmt::format("\t{} = {}{}", name, ev, v == type->GetEnumValueCount() - 1 ? "" : ",")
		});
	}

	lines.insert(lines.end(), "}");

	return lines;
}

static std::vector<std::string> TypeToLines(asIScriptEngine *engine, asITypeInfo *type)
{
	std::vector<std::string> lines;
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

	lines.insert(lines.end(), {
		class_decl,
		"{"
	});
		
	lines.insert(lines.end(), "\t// funcdefs");

	for (asUINT f = 0; f < type->GetChildFuncdefCount(); f++)
	{
		asITypeInfo *funcdef = type->GetChildFuncdef(f);

		lines.insert(lines.end(), {
			"\tfuncdef " + FunctionToString(engine, funcdef->GetFuncdefSignature(), funcdef)
		});
	}
		
	lines.insert(lines.end(), "\t// properties");

	for (asUINT p = 0; p < type->GetPropertyCount(); p++)
	{
		const char *propName;
		int propTypeId;
		bool propIsPrivate;
		bool propIsProtected;
		int propOffset;
		bool propReference;
		asDWORD propAccessMask;
		int propCompositeOffset;
		bool propIsCompositeIndirect;
		bool propReadOnly;
		type->GetProperty(p, &propName, &propTypeId, &propIsPrivate, &propIsProtected, &propOffset, &propReference, &propAccessMask, &propCompositeOffset, &propIsCompositeIndirect, &propReadOnly);

		std::string typeName = TypeToTypeName(engine, propTypeId, (asETypeModifiers) (propReference ? asTM_INOUTREF : 0), false, propName);
			
		lines.insert(lines.end(), {
			fmt::format("\t{}{}{};", propIsPrivate ? "private " : propIsProtected ? "protected " : "", propReadOnly ? "const " : "", typeName)
		});
	}
		
	lines.insert(lines.end(), "\t// behaviors");

	for (asUINT f = 0; f < type->GetBehaviourCount(); f++)
	{
		asEBehaviours beh;
		asIScriptFunction *func = type->GetBehaviourByIndex(f, &beh);

		if (beh == asEBehaviours::asBEHAVE_ADDREF ||
			beh == asEBehaviours::asBEHAVE_ENUMREFS ||
			beh == asEBehaviours::asBEHAVE_FIRST_GC ||
			beh == asEBehaviours::asBEHAVE_GETGCFLAG ||
			beh == asEBehaviours::asBEHAVE_GETREFCOUNT ||
			beh == asEBehaviours::asBEHAVE_GET_WEAKREF_FLAG ||
			beh == asEBehaviours::asBEHAVE_LAST_GC ||
			beh == asEBehaviours::asBEHAVE_RELEASE ||
			beh == asEBehaviours::asBEHAVE_RELEASEREFS ||
			beh == asEBehaviours::asBEHAVE_SETGCFLAG ||
			beh == asEBehaviours::asBEHAVE_TEMPLATE_CALLBACK)
			continue;

		std::string decl = func->GetDeclaration(false, false, true);

		if (beh == asEBehaviours::asBEHAVE_LIST_CONSTRUCT ||
			beh == asEBehaviours::asBEHAVE_LIST_FACTORY)
			decl = type->GetName() + decl.substr(decl.find("$list") + 5);

		lines.insert(lines.end(), {
			std::string("\t") + decl + ";"
		});
	}
		
	lines.insert(lines.end(), "\t// factories");

	for (asUINT f = 0; f < type->GetFactoryCount(); f++)
	{
		lines.insert(lines.end(), {
			"\t" + FunctionToString(engine, type->GetFactoryByIndex(f), type, true)
		});
	}

	lines.insert(lines.end(), "\t// methods");

	for (asUINT f = 0; f < type->GetMethodCount(); f++)
	{
		lines.insert(lines.end(), {
			"\t" + FunctionToString(engine, type->GetMethodByIndex(f, false))
		});
	}

	lines.insert(lines.end(), "}");

	return lines;
}

struct NamespaceInfo
{
	std::vector<std::vector<std::string>> typedefs;
	std::vector<std::vector<std::string>> enums;
	std::vector<std::vector<std::string>> funcdefs;
	std::vector<std::vector<std::string>> objects;
	std::vector<std::vector<std::string>> properties;
	std::vector<std::vector<std::string>> functions;

	void line(std::ofstream &of, int depth, const std::string_view v)
	{
		for (int i = 0; i < depth; i++)
			of << '\t';

		of << v;
		of << '\n';
	}

	void block(std::ofstream &of, int depth, const std::string_view header, const decltype(typedefs) &lines)
	{
		line(of, depth, fmt::format("// {}", header));

		for (auto &ls : lines)
			for (auto &l : ls)
				line(of, depth, l);
	}

	void write(std::ofstream &of, int depth)
	{
		if (!typedefs.empty())
			block(of, depth, "typedefs", typedefs);
		if (!enums.empty())
			block(of, depth, "enums", enums);
		if (!funcdefs.empty())
			block(of, depth, "funcdefs", funcdefs);
		if (!objects.empty())
			block(of, depth, "objects", objects);
		if (!properties.empty())
			block(of, depth, "properties", properties);
		if (!functions.empty())
			block(of, depth, "functions", functions);
	}
};

void WritePredefined(asIScriptEngine *engine, const char *filename)
{
	std::ofstream of(filename, std::ios_base::binary | std::ios_base::out);

	std::map<std::string, NamespaceInfo> namespaces;

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
		auto &ns = namespaces[type->GetNamespace()];
		ns.enums.emplace_back(EnumToLines(type));
	}

	for (asUINT i = 0; i < engine->GetFuncdefCount(); i++)
	{
		asITypeInfo *funcdef = engine->GetFuncdefByIndex(i);

		if (funcdef->GetParentType())
			continue;

		auto &ns = namespaces[funcdef->GetNamespace()];

		std::vector<std::string> lines;

		lines.insert(lines.end(), {
			"funcdef " + FunctionToString(engine, funcdef->GetFuncdefSignature(), funcdef)
		});

		ns.funcdefs.emplace_back(std::move(lines));
	}

	for (asUINT i = 0; i < engine->GetObjectTypeCount(); i++)
	{
		asITypeInfo *type = engine->GetObjectTypeByIndex(i);
		auto &ns = namespaces[type->GetNamespace()];
		ns.objects.emplace_back(TypeToLines(engine, type));
	}

	for (asUINT i = 0; i < engine->GetGlobalPropertyCount(); i++)
	{
		std::vector<std::string> lines;
		const char *name;
		const char *nameSpace;
		int typeId;
		bool isConst;
		const char *configGroup;
		void *pointer;
		asDWORD accessMask;
		engine->GetGlobalPropertyByIndex(i, &name, &nameSpace, &typeId, &isConst, &configGroup, &pointer, &accessMask);
		
		auto &ns = namespaces[nameSpace];
		std::string typeName = TypeToTypeName(engine, typeId, (asETypeModifiers) (isConst ? asTM_CONST : 0), false, name);

		lines.insert(lines.end(), {
			fmt::format("{};", typeName),
		});

		ns.properties.emplace_back(std::move(lines));
	}

	for (asUINT i = 0; i < engine->GetGlobalFunctionCount(); i++)
	{
		asIScriptFunction *func = engine->GetGlobalFunctionByIndex(i);
		auto &ns = namespaces[func->GetNamespace()];
		std::vector<std::string> lines;
		
		lines.insert(lines.end(), {
			FunctionToString(engine, engine->GetGlobalFunctionByIndex(i))
		});

		ns.functions.emplace_back(std::move(lines));
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