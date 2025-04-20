#include "q2as_local.h"
#include "q2as_time.h"
#include "g_local.h"

int64_t q2as_gtime::frames() const
{
    return _duration.count() / gi.frame_time_ms;
}

static void Q2AS_gtime_t_copy_construct(const q2as_gtime &t, q2as_gtime*o)
{
    *o = t;
}

static int Q2AS_gtime_t_compare(const q2as_gtime&t, q2as_gtime*o)
{
    if (t == *o)
        return 0;
    else if (*o < t)
        return -1;
    else
        return 1;
}

static q2as_gtime*Q2AS_gtime_t_assign(const q2as_gtime&t, q2as_gtime*o)
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
static void Q2AS_gtime_t_timeunit_construct(T value, timeunit_t unit, q2as_gtime*t)
{
    if (unit == timeunit_t::ms)
        *t = q2as_gtime::from_ms((int64_t) value);
    else if (unit == timeunit_t::sec)
        *t = q2as_gtime::from_sec(value);
    else if (unit == timeunit_t::min)
        *t = q2as_gtime::from_min(value);
    else
        *t = q2as_gtime::from_hz(value);
}

static q2as_gtime Q2AS_gtime_t_timeunit_ms(int64_t t)
{
    return q2as_gtime::from_ms(t);
}

template<typename T>
static q2as_gtime Q2AS_gtime_t_timeunit_sec(T t)
{
    return q2as_gtime::from_sec(t);
}

template<typename T>
static q2as_gtime Q2AS_gtime_t_timeunit_min(T t)
{
    return q2as_gtime::from_min(t);
}

static q2as_gtime Q2AS_gtime_t_timeunit_hz(uint64_t t)
{
    return q2as_gtime::from_hz(t);
}

static q2as_gtime Q2AS_clamp_time(const q2as_gtime&a, const q2as_gtime&b, const q2as_gtime&c)
{
    return clamp(a, b, c);
}

static q2as_gtime Q2AS_min_time(const q2as_gtime&a, const q2as_gtime&b)
{
    return min(a, b);
}

static q2as_gtime Q2AS_max_time(const q2as_gtime&a, const q2as_gtime&b)
{
    return max(a, b);
}

static void gtime_formatter(std::string &str, const std::string &args, const q2as_gtime&time)
{
    if (abs(time.minutes<float>()) >= 1)
        fmt::format_to(std::back_inserter(str), "{} min", time.minutes<float>());
    else if (abs(time.seconds<float>()) >= 1)
        fmt::format_to(std::back_inserter(str), "{} sec", time.seconds<float>());
    else
        fmt::format_to(std::back_inserter(str), "{} ms", time.milliseconds());
}

class q2as_asIDBGTimeTypeEvaluator : public asIDBObjectTypeEvaluator
{
    static constexpr std::tuple<uint64_t, const char *> time_suffixes[] = {
        { 1000 * 60 * 60, "hr" },
        { 1000 * 60, "min" },
        { 1000, "sec" }
    };

public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override
    {
        const q2as_gtime*s = var->address.ResolveAs<const q2as_gtime>();

        const char *sfx = "ms";
        uint64_t divisor = 1;

        for (auto &suffix : time_suffixes)
            if ((uint64_t) abs(s->milliseconds()) >= std::get<0>(suffix))
            {
                divisor = std::get<0>(suffix);
                sfx = std::get<1>(suffix);
                break;
            }

        var->value = fmt::format("{} {}", s->milliseconds() / (double) divisor, sfx);
        var->expandable = true;
    }

    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        const q2as_gtime*s = var->address.ResolveAs<const q2as_gtime>();

        for (auto &suffix : time_suffixes)
            if ((uint64_t) abs(s->milliseconds()) >= std::get<0>(suffix))
            {
                asIDBVariable::Ptr child = var->dbg.cache->CreateVariable();
                child->owner = var;
                child->identifier = std::get<1>(suffix);
                child->value = fmt::format("{}", s->milliseconds() / (double) std::get<0>(suffix));
                child->evaluated = true;
                var->namedProps.insert(child);
            }

        {
            asIDBVariable::Ptr child = var->dbg.cache->CreateVariable();
            child->owner = var;
            child->identifier = "ms";
            child->value = fmt::format("{}", s->milliseconds());
            child->evaluated = true;
            var->namedProps.insert(child);
        }
    }
};

void Q2AS_RegisterTime(q2as_registry &registry)
{
    registry
        .enumeration("timeunit_t")
        .values({
            { "ms",  (asINT64) timeunit_t::ms },
            { "sec", (asINT64) timeunit_t::sec },
            { "min", (asINT64) timeunit_t::min },
            { "hz",  (asINT64) timeunit_t::hz }
        });

    registry
        .type("gtime_t", sizeof(q2as_gtime), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLINTS | asOBJ_APP_CLASS_CAK)
        .properties({
            { "int64 milliseconds", 0 }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                  asFUNCTION(Q2AS_init_construct<q2as_gtime>),          asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(int64, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<int64_t>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(float, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<float>),   asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_copy_construct),              asCALL_CDECL_OBJLAST }
        })
        .methods({
            // getters
            { "int64 secondsi() const", asMETHOD(q2as_gtime, seconds<int64_t>), asCALL_THISCALL },
            { "float secondsf() const", asMETHOD(q2as_gtime, seconds<float>),   asCALL_THISCALL },
            { "int64 minutesi() const", asMETHOD(q2as_gtime, minutes<int64_t>), asCALL_THISCALL },
            { "float minutesf() const", asMETHOD(q2as_gtime, minutes<float>),   asCALL_THISCALL },
            { "int64 frames() const",   asMETHOD(q2as_gtime, frames),           asCALL_THISCALL },

            // equality
            { "bool opEquals(const gtime_t &in) const", asMETHODPR(q2as_gtime, operator==, (const q2as_gtime&) const, bool), asCALL_THISCALL },
            { "int opCmp(const gtime_t &in) const",     asFUNCTION(Q2AS_gtime_t_compare),                               asCALL_CDECL_OBJLAST },

            // operators
            { "gtime_t &opAssign(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_assign), asCALL_CDECL_OBJLAST },

            { "gtime_t opSub(const gtime_t &in) const", asMETHODPR(q2as_gtime, operator-, (const q2as_gtime & v) const, q2as_gtime), asCALL_THISCALL },
            { "gtime_t opAdd(const gtime_t &in) const", asMETHODPR(q2as_gtime, operator+, (const q2as_gtime & v) const, q2as_gtime), asCALL_THISCALL },
            { "gtime_t opDiv(const int &in) const",     asMETHODPR(q2as_gtime, operator/, (const int& v) const, q2as_gtime),     asCALL_THISCALL },
            { "gtime_t opMul(const int &in) const",     asMETHODPR(q2as_gtime, operator*, (const int& v) const, q2as_gtime),     asCALL_THISCALL },
            { "gtime_t opDiv(const float &in) const",   asMETHODPR(q2as_gtime, operator/, (const float& v) const, q2as_gtime),   asCALL_THISCALL },
            { "gtime_t opMul(const float &in) const",   asMETHODPR(q2as_gtime, operator*, (const float& v) const, q2as_gtime),   asCALL_THISCALL },
            { "gtime_t opNeg() const",                  asMETHODPR(q2as_gtime, operator-, () const, q2as_gtime),                 asCALL_THISCALL },

            { "gtime_t &opSubAssign(const gtime_t &in)", asMETHODPR(q2as_gtime, operator-=, (const q2as_gtime & v), q2as_gtime&), asCALL_THISCALL },
            { "gtime_t &opAddAssign(const gtime_t &in)", asMETHODPR(q2as_gtime, operator+=, (const q2as_gtime & v), q2as_gtime&), asCALL_THISCALL },
            { "gtime_t &opDivAssign(const int &in)",     asMETHODPR(q2as_gtime, operator/=, (const int& v), q2as_gtime&),     asCALL_THISCALL },
            { "gtime_t &opMulAssign(const int &in)",     asMETHODPR(q2as_gtime, operator*=, (const int& v), q2as_gtime&),     asCALL_THISCALL },
            { "gtime_t &opDivAssign(const float &in)",   asMETHODPR(q2as_gtime, operator/=, (const float& v), q2as_gtime&),   asCALL_THISCALL },
            { "gtime_t &opMulAssign(const float &in)",   asMETHODPR(q2as_gtime, operator*=, (const float &v), q2as_gtime&),   asCALL_THISCALL },

            // conversions
            { "bool opConv() const", asMETHODPR(q2as_gtime, operator bool, () const, bool), asCALL_THISCALL }
        });

    registry
        .for_global()
        .functions({
            // create times
            { "gtime_t time_ms(int64)",  asFUNCTION(Q2AS_gtime_t_timeunit_ms),           asCALL_CDECL },
            { "gtime_t time_sec(int64)", asFUNCTION(Q2AS_gtime_t_timeunit_sec<int64_t>), asCALL_CDECL },
            { "gtime_t time_sec(float)", asFUNCTION(Q2AS_gtime_t_timeunit_sec<float>),   asCALL_CDECL },
            { "gtime_t time_min(int64)", asFUNCTION(Q2AS_gtime_t_timeunit_min<int64_t>), asCALL_CDECL },
            { "gtime_t time_min(float)", asFUNCTION(Q2AS_gtime_t_timeunit_min<float>),   asCALL_CDECL },
            { "gtime_t time_hz(uint64)", asFUNCTION(Q2AS_gtime_t_timeunit_hz),           asCALL_CDECL },

            // math specializations
            // FIXME: why do these only work by ref? does it matter?
            { "gtime_t clamp(const gtime_t &in, const gtime_t &in, const gtime_t &in)", asFUNCTION(Q2AS_clamp_time), asCALL_CDECL },
            { "gtime_t min(const gtime_t &in, const gtime_t &in)",                      asFUNCTION(Q2AS_min_time),   asCALL_CDECL },
            { "gtime_t max(const gtime_t &in, const gtime_t &in)",                      asFUNCTION(Q2AS_max_time),   asCALL_CDECL },

            { "void formatter(string &str, const string &in args, const gtime_t &in time)", asFUNCTION(gtime_formatter), asCALL_CDECL }
        });

    debugger_state.RegisterEvaluator<q2as_asIDBGTimeTypeEvaluator>(registry.engine, "gtime_t");
}