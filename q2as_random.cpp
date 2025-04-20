#include "q2as_local.h"
#include "q2as_time.h"
#include "g_local.h"

// FIXME: new randomness system
static q2as_gtime q2as_random_time_2(const q2as_gtime &a, const q2as_gtime &b)
{
    return q2as_gtime::from_ms(irandom(min(a.milliseconds(), b.milliseconds()), max(a.milliseconds(), b.milliseconds())));
}

static q2as_gtime q2as_random_time_1(const q2as_gtime &a)
{
    return q2as_gtime::from_ms(irandom(a.milliseconds()));
}

void Q2AS_RegisterRandom(q2as_registry &registry)
{
    registry
        .for_global()
        .functions({
            { "float frandom()",             asFUNCTIONPR(frandom, (), float),             asCALL_CDECL },
            { "float frandom(float, float)", asFUNCTIONPR(frandom, (float, float), float), asCALL_CDECL },
            { "float frandom(float)",        asFUNCTIONPR(frandom, (float), float),        asCALL_CDECL },

            // AS bug: can't do by value?
            { "gtime_t random_time(const gtime_t &in, const gtime_t &in)", asFUNCTION(q2as_random_time_2), asCALL_CDECL },
            { "gtime_t random_time(const gtime_t &in)",                    asFUNCTION(q2as_random_time_1), asCALL_CDECL },

            { "float crandom()",      asFUNCTIONPR(crandom, (), float),      asCALL_CDECL },
            { "float crandom_open()", asFUNCTIONPR(crandom_open, (), float), asCALL_CDECL },

            { "uint32 irandom()",            asFUNCTIONPR(irandom, (), uint32_t),                asCALL_CDECL },
            { "int32 irandom(int32, int32)", asFUNCTIONPR(irandom, (int32_t, int32_t), int32_t), asCALL_CDECL },
            { "int32 irandom(int32)",        asFUNCTIONPR(irandom, (int32_t), int32_t),          asCALL_CDECL },

            { "bool brandom()", asFUNCTIONPR(brandom, (), bool), asCALL_CDECL }
        });
}