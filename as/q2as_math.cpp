#include "q2as_local.h"
#include "q2as_reg.h"

static float q2as_pif = PIf;
static double q2as_pi = PI;

static double q2as_RAD2DEG = 180.0 / PI;
static double q2as_DEG2RAD = PI / 180.0;

static float q2as_RAD2DEGf = 180.0f / PIf;
static float q2as_DEG2RADf = PIf / 180.0f;

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

bool Q2AS_RegisterMath(asIScriptEngine *engine)
{
    /*
    asUINT sp = engine->GetGlobalPropertyCount();
    asUINT fc = engine->GetGlobalFunctionCount();
    */

    // math constants
	EnsureRegisteredGlobalProperty("const float PIf", &q2as_pif);
	EnsureRegisteredGlobalProperty("const double PI", &q2as_pi);
	EnsureRegisteredGlobalProperty("const float RAD2DEGf", &q2as_RAD2DEGf);
	EnsureRegisteredGlobalProperty("const float DEG2RADf", &q2as_DEG2RADf);
	EnsureRegisteredGlobalProperty("const double RAD2DEG", &q2as_RAD2DEG);
	EnsureRegisteredGlobalProperty("const double DEG2RAD", &q2as_DEG2RAD);

    // C math functions
	Q2AS_RegisterOverloadedMathFunctionPrI3264("void div(T, T, T &out quot = void, T &out rem = void)", Q2AS_div, (T, T, T&, T&), void);
	Q2AS_RegisterOverloadedMathFunctionPrI3264("T abs(T)", abs, (T), T);
    Q2AS_RegisterOverloadedMathFunctionPrFloat("T abs(T)", fabs, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T fmod(T, T)", fmod, (T, T),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T remainder(T, T)", remainder, (T, T),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T remquo(T, T, int &out)", remquo, (T, T, int *),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T fma(T, T, T)", fma, (T, T, T),  T);
	Q2AS_RegisterOverloadedMathFunctionScalars("T max(T, T)", Q2AS_max);
	Q2AS_RegisterOverloadedMathFunctionScalars("T min(T, T)", Q2AS_min);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T exp(T)", exp, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double exp(T)", exp, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T exp2(T)", exp2, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double exp2(T)", exp2, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T expm1(T)", expm1, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double expm1(T)", expm1, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T log(T)", log, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double log(T)", log, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T log10(T)", log10, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double log10(T)", log10, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T log2(T)", log2, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double log2(T)", log2, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T log1p(T)", log1p, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double log1p(T)", log1p, (T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T pow(T, T)", pow, (T, T), T);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("double pow(T, T)", pow, (T, T), double);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T sqrt(T)", sqrt, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T cbrt(T)", cbrt, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T hypot(T, T)", hypot, (T, T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T sin(T)", sin, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T cos(T)", cos, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T tan(T)", tan, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T asin(T)", asin, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T acos(T)", acos, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T atan(T)", atan, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T atan2(T, T)", atan2, (T, T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T sinh(T)", sinh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T cosh(T)", cosh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T tanh(T)", tanh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T asinh(T)", asinh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T acosh(T)", acosh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T atanh(T)", atanh, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T erf(T)", erf, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T erfc(T)", erfc, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T tgamma(T)", tgamma, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T lgamma(T)", lgamma, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T ceil(T)", ceil, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T floor(T)", floor, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T trunc(T)", trunc, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T round(T)", round, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T nearbyint(T)", nearbyint, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T rint(T)", rint, (T), T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T frexp(T, int &out)", frexp, (T, int *),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T ldexp(T, int)", ldexp, (T, int),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T modf(T, T &out)", modf, (T, T *),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T scalbn(T, int)", scalbn, (T, int),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("int ilogb(T)", ilogb, (T),  int);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T logb(T)", logb, (T),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T nextafter(T, T)", nextafter, (T, T),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T nexttoward(T, double)", Q2AS_nexttoward, (T, double),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("T copysign(T, T)", copysign, (T, T),  T);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("bool isinf(T)", std::isinf, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("bool isfinite(T)", std::isfinite, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("bool isnan(T)", std::isnan, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("bool isnormal(T)", std::isnormal, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrFloat("bool signbit(T)", std::signbit, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrIntegral("bool signbit(T)", std::signbit, (T), bool);
	Q2AS_RegisterOverloadedMathFunctionPrScalars("T clamp(T, T, T)", Q2AS_clamp, (T, T, T), T);

    EnsureRegisteredGlobalFunction("float lerp(float, float, float)", asFUNCTIONPR(lerp, (float, float, float), float), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("float LerpAngle(float, float, float)", asFUNCTION(LerpAngle), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("float anglemod(float)", asFUNCTION(anglemod), asCALL_CDECL);

    /*
    const char *last_ns = "";

    for (asUINT i = sp; i < engine->GetGlobalPropertyCount(); i++)
    {
        const char *name, *ns;
        int type;
        bool isConst;
        auto prop = engine->GetGlobalPropertyByIndex(i, &name, &ns, &type, &isConst);

        if (strcmp(ns, last_ns))
        {
            if (strcmp(last_ns, ""))
                gi.Com_Print("}\n");
            if (strcmp(ns, ""))
                gi.Com_PrintFmt("namespace {}\n{{\n", ns);
            last_ns = ns;
        }

        const char *tn;

        if (type <= asTYPEID_DOUBLE)
        {
            switch (type)
            {
	        case asTYPEID_VOID  : tn = "void"; break;
	        case asTYPEID_BOOL  : tn = "bool"; break;
	        case asTYPEID_INT8  : tn = "int8"; break;
	        case asTYPEID_INT16 : tn = "int16"; break;
	        case asTYPEID_INT32 : tn = "int32"; break;
	        case asTYPEID_INT64 : tn = "int64"; break;
	        case asTYPEID_UINT8 : tn = "uint8"; break;
	        case asTYPEID_UINT16: tn = "uint16"; break;
	        case asTYPEID_UINT32: tn = "uint32"; break;
	        case asTYPEID_UINT64: tn = "uint64"; break;
	        case asTYPEID_FLOAT : tn = "float"; break;
            case asTYPEID_DOUBLE: tn = "double"; break;
            }
        }
        else
            tn = engine->GetTypeInfoById(type)->GetName();

        gi.Com_PrintFmt("{}{}{} {};\n", ns[0] ? "\t" : "", isConst ? "const " : "", tn, name);
    }

    if (strcmp(last_ns, ""))
        gi.Com_Print("}\n");
    
    for (asUINT i = fc; i < engine->GetGlobalFunctionCount(); i++)
    {
        gi.Com_PrintFmt("{};\n", engine->GetGlobalFunctionByIndex(i)->GetDeclaration(true, false, true));
    }
    */

	return true;
}