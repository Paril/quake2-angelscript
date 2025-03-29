#include "q2as_local.h"

static const float q2as_pif = PIf;
static const double q2as_pi = PI;

static const double q2as_RAD2DEG = 180.0 / PI;
static const double q2as_DEG2RAD = PI / 180.0;

static const float q2as_RAD2DEGf = 180.0f / PIf;
static const float q2as_DEG2RADf = PIf / 180.0f;

template<typename T>
static T Q2AS_clamp(T a, T b, T c)
{
	return clamp(a, b, c);
}

template<typename T>
static T Q2AS_min(T a, T b)
{
	return min(a, b);
}

template<typename T>
static T Q2AS_max(T a, T b)
{
	return max(a, b);
}

bool q2as_isinf(float f)
{
	return std::isinf(f);
}

bool q2as_isnan(float f)
{
	return std::isnan(f);
}

template<typename T>
static void Q2AS_div(T x, T y, T &quot, T &rem)
{
    auto r = div(x, y);
    quot = r.quot;
    rem = r.rem;
}

template<typename T>
T Q2AS_nexttoward(T v, double a)
{
    return nexttoward(v, (long double) a);
}

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

#define Q2AS_T(T) T
#define Q2AS_VOID(T) void
#define Q2AS_BOOL(T) bool
#define Q2AS_INT(T) int
#define Q2AS_INTP(T) int *
#define Q2AS_DOUBLE(T) double
#define Q2AS_PARAMS_T(T) (T)
#define Q2AS_PARAMS_TT(T) (T, T)
#define Q2AS_PARAMS_TTp(T) (T, T *)
#define Q2AS_PARAMS_Tintp(T) (T, int *)
#define Q2AS_PARAMS_Tint(T) (T, int)
#define Q2AS_PARAMS_Tdouble(T) (T, double)
#define Q2AS_PARAMS_TTT(T) (T, T, T)
#define Q2AS_PARAMS_TTintp(T) (T, T, int *)
#define Q2AS_PARAMS_TTrTrT(T) (T, T, T&, T&)

#define MATH_FUNC(templ, as_type, T, func) \
	{ replace_all(templ, "T", #as_type).c_str(), asFUNCTION(func<T>), asCALL_CDECL }

#define MATH_FUNCPR(templ, as_type, T, func, params, result) \
    { replace_all(templ, "T", #as_type).c_str(), asFUNCTIONPR(func, params(T), result(T)), asCALL_CDECL }

// register only floating point primitives
#define MATH_FLOATFUNC(templ, func) \
	MATH_FUNC(templ, float, float, func), \
	MATH_FUNC(templ, double, double, func)

// register only integral primitives
#define MATH_INTFUNC(templ, func) \
	MATH_FUNC(templ, int8, int8_t, func), \
	MATH_FUNC(templ, uint8, uint8_t, func), \
	MATH_FUNC(templ, int16, int16_t, func), \
	MATH_FUNC(templ, uint16, uint16_t, func), \
	MATH_FUNC(templ, int32, int32_t, func), \
	MATH_FUNC(templ, uint32, uint32_t, func), \
	MATH_FUNC(templ, int64, int64_t, func), \
	MATH_FUNC(templ, uint64, uint64_t, func)

// register all (non-bool) primitive types
#define MATH_SCALARSFUNC(templ, func) \
    MATH_FLOATFUNC(templ, func), \
    MATH_INTFUNC(templ, func)

#define MATH_INTFUNCPR(templ, func, params, result) \
	MATH_FUNCPR(templ, int8, int8_t, func, params, result), \
	MATH_FUNCPR(templ, uint8, uint8_t, func, params, result), \
	MATH_FUNCPR(templ, int16, int16_t, func, params, result), \
	MATH_FUNCPR(templ, uint16, uint16_t, func, params, result), \
	MATH_FUNCPR(templ, int32, int32_t, func, params, result), \
	MATH_FUNCPR(templ, uint32, uint32_t, func, params, result), \
	MATH_FUNCPR(templ, int64, int64_t, func, params, result), \
	MATH_FUNCPR(templ, uint64, uint64_t, func, params, result)

#define MATH_FLOATFUNCPR(templ, func, params, result) \
	MATH_FUNCPR(templ, float, float, func, params, result), \
	MATH_FUNCPR(templ, double, double, func, params, result)

#define MATH_SCALARFUNCPR(templ, func, params, result) \
    MATH_FLOATFUNCPR(templ, func, params, result), \
    MATH_INTFUNCPR(templ, func, params, result)

#define MATH_I32I64FUNCPR(templ, func, params, result) \
	MATH_FUNCPR(templ, int32, int32_t, func, params, result), \
	MATH_FUNCPR(templ, int64, int64_t, func, params, result)

void Q2AS_RegisterMath(q2as_registry &registry)
{
    // math constants
	registry
		.for_global()
		.properties({
			{ "const float PIf",      &q2as_pif },
			{ "const double PI",      &q2as_pi },
			{ "const float RAD2DEGf", &q2as_RAD2DEGf },
			{ "const double RAD2DEG", &q2as_RAD2DEG },
			{ "const float DEG2RADf", &q2as_DEG2RADf },
			{ "const double DEG2RAD", &q2as_DEG2RAD }
		});

    // C math functions
	registry
		.for_global()
		.functions({
			MATH_I32I64FUNCPR("void div(T, T, T &out quot = void, T &out rem = void)", Q2AS_div,        Q2AS_PARAMS_TTrTrT, Q2AS_VOID),
			MATH_I32I64FUNCPR("T abs(T)",                                              abs,             Q2AS_PARAMS_T,      Q2AS_T),
			MATH_FLOATFUNCPR("T abs(T)",                                               fabs,            Q2AS_PARAMS_T,      Q2AS_T),
			MATH_FLOATFUNCPR("T fmod(T, T)",                                           fmod,            Q2AS_PARAMS_TT,     Q2AS_T),
			MATH_FLOATFUNCPR("T remainder(T, T)",                                      remainder,       Q2AS_PARAMS_TT,     Q2AS_T),
			MATH_FLOATFUNCPR("T remquo(T, T, int &out)",                               remquo,          Q2AS_PARAMS_TTintp, Q2AS_T),
			MATH_FLOATFUNCPR("T fma(T, T, T)",                                         fma,             Q2AS_PARAMS_TTT,    Q2AS_T),
			MATH_SCALARSFUNC("T max(T, T)",                                            Q2AS_max),
			MATH_SCALARSFUNC("T min(T, T)",                                            Q2AS_min),
			MATH_FLOATFUNCPR("T exp(T)",                                               exp,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double exp(T)",                                            exp,             Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T exp2(T)",                                              exp2,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double exp2(T)",                                           exp2,            Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T expm1(T)",                                             expm1,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double expm1(T)",                                          expm1,           Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T log(T)",                                               log,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double log(T)",                                            log,             Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T log10(T)",                                             log10,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double log10(T)",                                          log10,           Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T log2(T)",                                              log2,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double log2(T)",                                           log2,            Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T log1p(T)",                                             log1p,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_INTFUNCPR("double log1p(T)",                                          log1p,           Q2AS_PARAMS_T,        Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T pow(T, T)",                                            pow,             Q2AS_PARAMS_TT,       Q2AS_T),
			MATH_INTFUNCPR("double pow(T, T)",                                         pow,             Q2AS_PARAMS_TT,       Q2AS_DOUBLE),
			MATH_FLOATFUNCPR("T sqrt(T)",                                              sqrt,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T cbrt(T)",                                              cbrt,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T hypot(T, T)",                                          hypot,           Q2AS_PARAMS_TT,       Q2AS_T),
			MATH_FLOATFUNCPR("T sin(T)",                                               sin,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T cos(T)",                                               cos,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T tan(T)",                                               tan,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T asin(T)",                                              asin,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T acos(T)",                                              acos,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T atan(T)",                                              atan,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T atan2(T, T)",                                          atan2,           Q2AS_PARAMS_TT,       Q2AS_T),
			MATH_FLOATFUNCPR("T sinh(T)",                                              sinh,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T cosh(T)",                                              cosh,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T tanh(T)",                                              tanh,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T asinh(T)",                                             asinh,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T acosh(T)",                                             acosh,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T atanh(T)",                                             atanh,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T erf(T)",                                               erf,             Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T erfc(T)",                                              erfc,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T tgamma(T)",                                            tgamma,          Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T lgamma(T)",                                            lgamma,          Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T ceil(T)",                                              ceil,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T floor(T)",                                             floor,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T trunc(T)",                                             trunc,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T round(T)",                                             round,           Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T nearbyint(T)",                                         nearbyint,       Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T rint(T)",                                              rint,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T frexp(T, int &out)",                                   frexp,           Q2AS_PARAMS_Tintp,    Q2AS_T),
			MATH_FLOATFUNCPR("T ldexp(T, int)",                                        ldexp,           Q2AS_PARAMS_Tint,     Q2AS_T),
			MATH_FLOATFUNCPR("T modf(T, T &out)",                                      modf,            Q2AS_PARAMS_TTp,      Q2AS_T),
			MATH_FLOATFUNCPR("T scalbn(T, int)",                                       scalbn,          Q2AS_PARAMS_Tint,     Q2AS_T),
			MATH_FLOATFUNCPR("int ilogb(T)",                                           ilogb,           Q2AS_PARAMS_T,        Q2AS_INT),
			MATH_FLOATFUNCPR("T logb(T)",                                              logb,            Q2AS_PARAMS_T,        Q2AS_T),
			MATH_FLOATFUNCPR("T nextafter(T, T)",                                      nextafter,       Q2AS_PARAMS_TT,       Q2AS_T),
			MATH_FLOATFUNCPR("T nexttoward(T, double)",                                Q2AS_nexttoward, Q2AS_PARAMS_Tdouble,  Q2AS_T),
			MATH_FLOATFUNCPR("T copysign(T, T)",                                       copysign,        Q2AS_PARAMS_TT,       Q2AS_T),
			MATH_FLOATFUNCPR("bool isinf(T)",                                          std::isinf,      Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_FLOATFUNCPR("bool isfinite(T)",                                       std::isfinite,   Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_FLOATFUNCPR("bool isnan(T)",                                          std::isnan,      Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_FLOATFUNCPR("bool isnormal(T)",                                       std::isnormal,   Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_FLOATFUNCPR("bool signbit(T)",                                        std::signbit,    Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_INTFUNCPR("bool signbit(T)",                                          std::signbit,    Q2AS_PARAMS_T,        Q2AS_BOOL),
			MATH_SCALARFUNCPR("T clamp(T, T, T)",                                      Q2AS_clamp,      Q2AS_PARAMS_TTT,      Q2AS_T)
		});

	// Quake-y functions
	registry
		.for_global()
		.functions({
			{ "float lerp(float, float, float)",      asFUNCTIONPR(lerp, (float, float, float), float), asCALL_CDECL },
			{ "float LerpAngle(float, float, float)", asFUNCTION(LerpAngle),                            asCALL_CDECL },
			{ "float anglemod(float)",                asFUNCTION(anglemod),                             asCALL_CDECL }
		});
}