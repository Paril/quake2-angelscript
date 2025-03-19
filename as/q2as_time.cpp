#include "q2as_local.h"
#include "q2as_reg.h"
#include "../g_local.h"

static void Q2AS_gtime_t_copy_construct(const gtime_t &t, gtime_t *o)
{
	*o = t;
}

static int Q2AS_gtime_t_compare(const gtime_t &t, gtime_t *o)
{
	if (t == *o)
		return 0;
	else if (*o < t)
		return -1;
	else
		return 1;
}

static gtime_t *Q2AS_gtime_t_assign(const gtime_t &t, gtime_t *o)
{
	*o = t;
	return o;
}

enum class timeunit_t
{
	ms,
	sec,
	min,
	hz
};

template<typename T>
static void Q2AS_gtime_t_timeunit_construct(T value, timeunit_t unit, gtime_t *t)
{
	if (unit == timeunit_t::ms)
		*t = gtime_t::from_ms((int64_t) value);
	else if (unit == timeunit_t::sec)
		*t = gtime_t::from_sec(value);
	else if (unit == timeunit_t::min)
		*t = gtime_t::from_min(value);
	else
		*t = gtime_t::from_hz(value);
}

static gtime_t Q2AS_gtime_t_timeunit_ms(int64_t t)
{
	return gtime_t::from_ms(t);
}

template<typename T>
static gtime_t Q2AS_gtime_t_timeunit_sec(T t)
{
	return gtime_t::from_sec(t);
}

template<typename T>
static gtime_t Q2AS_gtime_t_timeunit_min(T t)
{
	return gtime_t::from_min(t);
}

static gtime_t Q2AS_gtime_t_timeunit_hz(uint64_t t)
{
	return gtime_t::from_hz(t);
}

static gtime_t Q2AS_clamp_time(const gtime_t &a, const gtime_t &b, const gtime_t &c)
{
	return clamp(a, b, c);
}

static gtime_t Q2AS_min_time(const gtime_t &a, const gtime_t &b)
{
	return min(a, b);
}

static gtime_t Q2AS_max_time(const gtime_t &a, const gtime_t &b)
{
	return max(a, b);
}

bool Q2AS_RegisterTime(asIScriptEngine *engine)
{
#define Q2AS_OBJECT timeunit_t
#define Q2AS_ENUM_PREFIX PRINT_

	EnsureRegisteredEnum();
	engine->RegisterEnumValue("timeunit_t", "ms", (int) timeunit_t::ms);
	engine->RegisterEnumValue("timeunit_t", "sec", (int) timeunit_t::sec);
	engine->RegisterEnumValue("timeunit_t", "min", (int) timeunit_t::min);
	engine->RegisterEnumValue("timeunit_t", "hz", (int) timeunit_t::hz);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT gtime_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLINTS | asOBJ_APP_CLASS_CAK);

	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(int64, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<int64_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(float, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<float>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_copy_construct), asCALL_CDECL_OBJLAST);
	
	Ensure(engine->RegisterObjectProperty("gtime_t", "int64 milliseconds", 0));
	EnsureRegisteredMethod("int64 secondsi() const", asMETHOD(gtime_t, seconds<int64_t>), asCALL_THISCALL);
	EnsureRegisteredMethod("float secondsf() const", asMETHOD(gtime_t, seconds<float>), asCALL_THISCALL);
	EnsureRegisteredMethod("int64 minutesi() const", asMETHOD(gtime_t, minutes<int64_t>), asCALL_THISCALL);
	EnsureRegisteredMethod("float minutesf() const", asMETHOD(gtime_t, minutes<float>), asCALL_THISCALL);
	EnsureRegisteredMethod("int64 frames() const", asMETHOD(gtime_t, frames), asCALL_THISCALL);

	// equality
	EnsureRegisteredMethod("bool opEquals(const gtime_t &in) const", asMETHODPR(gtime_t, operator==, (const gtime_t &) const, bool), asCALL_THISCALL);
	EnsureRegisteredMethod("int opCmp(const gtime_t &in) const", asFUNCTION(Q2AS_gtime_t_compare), asCALL_CDECL_OBJLAST);

	EnsureRegisteredMethod("gtime_t &opAssign(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_assign), asCALL_CDECL_OBJLAST);

	EnsureRegisteredMethod("gtime_t opSub(const gtime_t &in) const", asMETHODPR(gtime_t, operator-, (const gtime_t &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opAdd(const gtime_t &in) const", asMETHODPR(gtime_t, operator+, (const gtime_t &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opDiv(const int &in) const", asMETHODPR(gtime_t, operator/, (const int &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opMul(const int &in) const", asMETHODPR(gtime_t, operator*, (const int &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opDiv(const float &in) const", asMETHODPR(gtime_t, operator/, (const float &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opMul(const float &in) const", asMETHODPR(gtime_t, operator*, (const float &v) const, gtime_t), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t opNeg() const", asMETHODPR(gtime_t, operator-, () const, gtime_t), asCALL_THISCALL);

	EnsureRegisteredMethod("gtime_t &opSubAssign(const gtime_t &in)", asMETHODPR(gtime_t, operator-=, (const gtime_t &v), gtime_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t &opAddAssign(const gtime_t &in)", asMETHODPR(gtime_t, operator+=, (const gtime_t &v), gtime_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t &opDivAssign(const int &in)", asMETHODPR(gtime_t, operator/=, (const int &v), gtime_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t &opMulAssign(const int &in)", asMETHODPR(gtime_t, operator*=, (const int &v), gtime_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t &opDivAssign(const float &in)", asMETHODPR(gtime_t, operator/=, (const float &v), gtime_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("gtime_t &opMulAssign(const float &in)", asMETHODPR(gtime_t, operator*=, (const float &v), gtime_t &), asCALL_THISCALL);

	// conversion
	EnsureRegisteredMethod("bool opImplConv() const", asMETHODPR(gtime_t, operator bool, () const, bool), asCALL_THISCALL);
	
	EnsureRegisteredGlobalFunction("gtime_t time_ms(int64)", asFUNCTION(Q2AS_gtime_t_timeunit_ms), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t time_sec(int64)", asFUNCTION(Q2AS_gtime_t_timeunit_sec<int64_t>), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t time_sec(float)", asFUNCTION(Q2AS_gtime_t_timeunit_sec<float>), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t time_min(int64)", asFUNCTION(Q2AS_gtime_t_timeunit_min<int64_t>), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t time_min(float)", asFUNCTION(Q2AS_gtime_t_timeunit_min<float>), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t time_hz(uint64)", asFUNCTION(Q2AS_gtime_t_timeunit_hz), asCALL_CDECL);

    // math specializations
    // FIXME: why do these only work by ref? does it matter?
	EnsureRegisteredGlobalFunction("gtime_t clamp(const gtime_t &in, const gtime_t &in, const gtime_t &in)", asFUNCTION(Q2AS_clamp_time), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t min(const gtime_t &in, const gtime_t &in)", asFUNCTION(Q2AS_min_time), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("gtime_t max(const gtime_t &in, const gtime_t &in)", asFUNCTION(Q2AS_max_time), asCALL_CDECL);

#undef Q2AS_OBJECT
	
	return true;
}