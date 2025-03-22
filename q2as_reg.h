#pragma once

// stuff for error-checking registration of stuff

#define Q2AS_EXPAND(a) a
#define Q2AS_STR(a) #a
#define Q2AS_XSTR(a) Q2AS_STR(a)

#define Ensure(...) \
	if (int r = __VA_ARGS__; r < 0) return false

#define EnsureRegisteredTypeRaw(...) \
	Ensure(engine->RegisterObjectType(__VA_ARGS__))

#define EnsureRegisteredType(traits) EnsureRegisteredTypeRaw(Q2AS_XSTR(Q2AS_OBJECT), sizeof(Q2AS_OBJECT), traits | asGetTypeTraits<Q2AS_OBJECT>())

#define EnsureRegisteredBehaviourRaw(...) \
	Ensure(engine->RegisterObjectBehaviour(__VA_ARGS__))

#define EnsureRegisteredBehaviour(...) EnsureRegisteredBehaviourRaw(Q2AS_XSTR(Q2AS_OBJECT), __VA_ARGS__)

#define EnsureRegisteredPropertyRaw(...) \
	Ensure(engine->RegisterObjectProperty(__VA_ARGS__))

#define EnsureRegisteredProperty(type, name) EnsureRegisteredPropertyRaw(Q2AS_XSTR(Q2AS_OBJECT), type " " #name, asOFFSET(Q2AS_OBJECT, name))

#define EnsureRegisteredMethodRaw(...) \
	Ensure(engine->RegisterObjectMethod(__VA_ARGS__))

#define EnsureRegisteredMethod(...) EnsureRegisteredMethodRaw(Q2AS_XSTR(Q2AS_OBJECT), __VA_ARGS__)

#define EnsureRegisteredGlobalFunction(...) \
	Ensure(engine->RegisterGlobalFunction(__VA_ARGS__))

#define EnsureRegisteredGlobalProperty(...) \
	Ensure(engine->RegisterGlobalProperty(__VA_ARGS__))

#define EnsureRegisteredEnum() \
	Ensure(engine->RegisterEnum(Q2AS_XSTR(Q2AS_OBJECT)))

#define EnsureRegisteredTypedEnum(t) \
	Ensure(engine->RegisterEnum(Q2AS_XSTR(Q2AS_OBJECT), t))

#define EnsureRegisteredEnumRaw(n) \
	Ensure(engine->RegisterEnum(n))

#define EnsureRegisteredEnumValueRaw(...) \
	Ensure(engine->RegisterEnumValue(__VA_ARGS__))

#define EnsureRegisteredEnumValue(prefix, s) EnsureRegisteredEnumValueRaw(Q2AS_XSTR(Q2AS_OBJECT), #s, (asINT64) Q2AS_OBJECT :: prefix##s )

#define EnsureRegisteredEnumValueGlobal(prefix, s) EnsureRegisteredEnumValueRaw(Q2AS_XSTR(Q2AS_OBJECT), #prefix #s, (asINT64) prefix##s )

#define EnsureRegisteredEnumValueGlobalNoPrefix(prefix, s) EnsureRegisteredEnumValueRaw(Q2AS_XSTR(Q2AS_OBJECT), #s, (asINT64) prefix##s )

inline std::string replace_all(std::string_view str, const char *replace, const char *with)
{
	std::string s(str);
    size_t pos = s.rfind(replace);
	size_t l = strlen(replace);

    while (pos != std::string::npos)
	{
        s.replace(pos, l, with);
        pos = s.rfind(replace, pos);
    }

	return s;
}

#define Q2AS_RegisterOverloadedMathFunction(templ, as_type, c_type, func) \
	EnsureRegisteredGlobalFunction(replace_all(templ, "T", #as_type).c_str(), asFUNCTION(func<c_type>), asCALL_CDECL)

#define Q2AS_RegisterOverloadedMathFunctionPr(templ, as_type, c_type, func, params, result) \
    { using T = c_type; EnsureRegisteredGlobalFunction(replace_all(templ, "T", #as_type).c_str(), asFUNCTIONPR(func, params, result), asCALL_CDECL); }

// register only floating point primitives
#define Q2AS_RegisterOverloadedMathFunctionFloat(templ, func) \
	Q2AS_RegisterOverloadedMathFunction(templ, float, float, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, double, double, func);

#define Q2AS_RegisterOverloadedMathFunctionPrFloat(templ, func, params, result) \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, float, float, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, double, double, func, params, result);

// register only integral primitives
#define Q2AS_RegisterOverloadedMathFunctionIntegral(templ, func) \
	Q2AS_RegisterOverloadedMathFunction(templ, int8, int8_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, uint8, uint8_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, int16, int16_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, uint16, uint16_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, int32, int32_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, uint32, uint32_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, int64, int64_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, uint64, uint64_t, func)

#define Q2AS_RegisterOverloadedMathFunctionPrIntegral(templ, func, params, result) \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int8, int8_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, uint8, uint8_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int16, int16_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, uint16, uint16_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int32, int32_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, uint32, uint32_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int64, int64_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, uint64, uint64_t, func, params, result)

// register all (non-bool) primitive types
#define Q2AS_RegisterOverloadedMathFunctionScalars(templ, func) \
    Q2AS_RegisterOverloadedMathFunctionFloat(templ, func); \
    Q2AS_RegisterOverloadedMathFunctionIntegral(templ, func)

#define Q2AS_RegisterOverloadedMathFunctionPrScalars(templ, func, params, result) \
    Q2AS_RegisterOverloadedMathFunctionPrFloat(templ, func, params, result); \
    Q2AS_RegisterOverloadedMathFunctionPrIntegral(templ, func, params, result)

// register only floating point primitives
#define Q2AS_RegisterOverloadedMathFunctionI3264(templ, func) \
	Q2AS_RegisterOverloadedMathFunction(templ, int32, int32_t, func); \
	Q2AS_RegisterOverloadedMathFunction(templ, int64, int64_t, func);

#define Q2AS_RegisterOverloadedMathFunctionPrI3264(templ, func, params, result) \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int32, int32_t, func, params, result); \
	Q2AS_RegisterOverloadedMathFunctionPr(templ, int64, int64_t, func, params, result);

// factory functions for registration

template<typename T, typename A>
void Q2AS_Factory(asIScriptGeneric *gen)
{
	T *ptr = reinterpret_cast<T *>(A::AllocStatic(sizeof(T)));
	*(T **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) T();
}

template<typename T>
void Q2AS_AddRefObject(T *object)
{
	object->refs++;
}

template<typename T, typename A>
void Q2AS_AddRef(asIScriptGeneric *gen)
{
	T *object = (T *)gen->GetObject();
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
	T *object = (T *)gen->GetObject();
	Q2AS_ReleaseObj<T, A>(object);
}