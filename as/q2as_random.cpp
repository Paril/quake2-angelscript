#include "q2as_local.h"
#include "q2as_reg.h"
#include "../g_local.h"

static gtime_t q2as_random_time_2(const gtime_t &a, const gtime_t &b)
{
	return random_time(a, b);
}

static gtime_t q2as_random_time_1(const gtime_t &a)
{
	return random_time(a);
}

bool Q2AS_RegisterRandom(asIScriptEngine *engine)
{
	EnsureRegisteredGlobalFunction("float frandom()", asFUNCTIONPR(frandom, (), float), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("float frandom(float, float)", asFUNCTIONPR(frandom, (float, float), float), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("float frandom(float)", asFUNCTIONPR(frandom, (float), float), asCALL_CDECL);

	// AS bug: can't do by value?
	EnsureRegisteredGlobalFunction("gtime_t random_time(const gtime_t &in, const gtime_t &in)", asFUNCTION(q2as_random_time_2), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t random_time(const gtime_t &in)", asFUNCTION(q2as_random_time_1), asCALL_CDECL);

	EnsureRegisteredGlobalFunction("float crandom()", asFUNCTIONPR(crandom, (), float), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("float crandom_open()", asFUNCTIONPR(crandom_open, (), float), asCALL_CDECL);

	EnsureRegisteredGlobalFunction("uint32 irandom()", asFUNCTIONPR(irandom, (), uint32_t), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int32 irandom(int32, int32)", asFUNCTIONPR(irandom, (int32_t, int32_t), int32_t), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int32 irandom(int32)", asFUNCTIONPR(irandom, (int32_t), int32_t), asCALL_CDECL);

	EnsureRegisteredGlobalFunction("bool brandom()", asFUNCTIONPR(brandom, (), bool), asCALL_CDECL);

	return true;
}