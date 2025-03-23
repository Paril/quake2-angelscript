#pragma once

template<typename T, size_t N>
struct q2as_fixedarray
{
	using array = std::array<T, N>;

	static void ListConstruct(int *buffer, array &v)
	{
		int n = *buffer;

		if (n != N)
		{
			asGetActiveContext()->SetException("List needs exactly N params");
			return;
		}

		T *p = (T *) (buffer + 1);

		for (int i = 0; i < n; i++)
		{
			v[i] = *p;

			if constexpr (sizeof(T) <= 4)
				p++;
			else
				p = (T *) (((uint8_t *) p) + sizeof(T) + (sizeof(T) % 4));
		}
	}

	static T &IndexRef(uint32_t i, array &v)
	{
		if (i < 0 || i >= N)
		{
			asGetActiveContext()->SetException("Index out of range");
			return v[0];
		}

		return v[i];
	}

	static const T &IndexRefConst(uint32_t i, const array &v)
	{
		if (i < 0 || i >= N)
		{
			asGetActiveContext()->SetException("Index out of range");
			return v[0];
		}

		return v[i];
	}

	static uint32_t Size() { return N; }
};

template<typename T, size_t N>
inline bool Q2AS_RegisterFixedArray(asIScriptEngine *engine, const char *name, const char *underlying, int traits)
{
	using AT = std::array<T, N>;
	Ensure(engine->RegisterObjectType(name, sizeof(AT), asOBJ_VALUE | asOBJ_POD | traits | asGetTypeTraits<AT>()));

	const char *decl = G_Fmt("void f(int &in) {{ repeat {} }}", underlying).data();

	// list construct
	Ensure(engine->RegisterObjectBehaviour(name, asBEHAVE_LIST_CONSTRUCT, decl, asFunctionPtr(q2as_fixedarray<T, N>::ListConstruct), asCALL_CDECL_OBJLAST));
	
	// array
	decl = G_Fmt("{} &opIndex(uint)", underlying).data();
	Ensure(engine->RegisterObjectMethod(name, decl,asFunctionPtr(q2as_fixedarray<T, N>::IndexRef), asCALL_CDECL_OBJLAST));
	decl = G_Fmt("const {} &opIndex(uint) const", underlying).data();
	Ensure(engine->RegisterObjectMethod(name, decl, asFunctionPtr(q2as_fixedarray<T, N>::IndexRefConst), asCALL_CDECL_OBJLAST));
	Ensure(engine->RegisterObjectMethod(name, "uint32 size() const", asFunctionPtr(q2as_fixedarray<T, N>::Size), asCALL_CDECL_OBJLAST));

	return true;
}