#include "q2as_local.h"
#include "g_local.h"

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

static void gtime_formatter(std::string &str, const std::string &args, const gtime_t &time)
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
        const gtime_t *s = var->address.ResolveAs<const gtime_t>();

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
        var->MakeExpandable();
    }

    virtual void Expand(asIDBVariable::Ptr var) const override
    {
        const gtime_t *s = var->address.ResolveAs<const gtime_t>();

        for (auto &suffix : time_suffixes)
            if ((uint64_t) abs(s->milliseconds()) >= std::get<0>(suffix))
            {
                asIDBVariable::Ptr child = var->dbg.cache->CreateVariable();
                child->owner = var;
                child->name = std::get<1>(suffix);
                child->value = fmt::format("{}", s->milliseconds() / (double) std::get<0>(suffix));
                child->evaluated = true;
                var->PushChild(child);
            }

        {
            asIDBVariable::Ptr child = var->dbg.cache->CreateVariable();
            child->owner = var;
            child->name = "ms";
            child->value = fmt::format("{}", s->milliseconds());
            child->evaluated = true;
            var->PushChild(child);
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
        .type("gtime_t", sizeof(gtime_t), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLINTS | asOBJ_APP_CLASS_CAK)
        .properties({
            { "int64 milliseconds", 0 }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f(int64, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<int64_t>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(float, timeunit_t)", asFUNCTION(Q2AS_gtime_t_timeunit_construct<float>),   asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_copy_construct),              asCALL_CDECL_OBJLAST }
        })
        .methods({
            // getters
            { "int64 secondsi() const", asMETHOD(gtime_t, seconds<int64_t>), asCALL_THISCALL },
            { "float secondsf() const", asMETHOD(gtime_t, seconds<float>),   asCALL_THISCALL },
            { "int64 minutesi() const", asMETHOD(gtime_t, minutes<int64_t>), asCALL_THISCALL },
            { "float minutesf() const", asMETHOD(gtime_t, minutes<float>),   asCALL_THISCALL },
            { "int64 frames() const",   asMETHOD(gtime_t, frames),           asCALL_THISCALL },

            // equality
            { "bool opEquals(const gtime_t &in) const", asMETHODPR(gtime_t, operator==, (const gtime_t &) const, bool), asCALL_THISCALL },
            { "int opCmp(const gtime_t &in) const",     asFUNCTION(Q2AS_gtime_t_compare),                               asCALL_CDECL_OBJLAST },

            // operators
            { "gtime_t &opAssign(const gtime_t &in)", asFUNCTION(Q2AS_gtime_t_assign), asCALL_CDECL_OBJLAST },

            { "gtime_t opSub(const gtime_t &in) const", asMETHODPR(gtime_t, operator-, (const gtime_t &v) const, gtime_t), asCALL_THISCALL },
            { "gtime_t opAdd(const gtime_t &in) const", asMETHODPR(gtime_t, operator+, (const gtime_t &v) const, gtime_t), asCALL_THISCALL },
            { "gtime_t opDiv(const int &in) const",     asMETHODPR(gtime_t, operator/, (const int &v) const, gtime_t),     asCALL_THISCALL },
            { "gtime_t opMul(const int &in) const",     asMETHODPR(gtime_t, operator*, (const int &v) const, gtime_t),     asCALL_THISCALL },
            { "gtime_t opDiv(const float &in) const",   asMETHODPR(gtime_t, operator/, (const float &v) const, gtime_t),   asCALL_THISCALL },
            { "gtime_t opMul(const float &in) const",   asMETHODPR(gtime_t, operator*, (const float &v) const, gtime_t),   asCALL_THISCALL },
            { "gtime_t opNeg() const",                  asMETHODPR(gtime_t, operator-, () const, gtime_t),                 asCALL_THISCALL },

            { "gtime_t &opSubAssign(const gtime_t &in)", asMETHODPR(gtime_t, operator-=, (const gtime_t &v), gtime_t &), asCALL_THISCALL },
            { "gtime_t &opAddAssign(const gtime_t &in)", asMETHODPR(gtime_t, operator+=, (const gtime_t &v), gtime_t &), asCALL_THISCALL },
            { "gtime_t &opDivAssign(const int &in)",     asMETHODPR(gtime_t, operator/=, (const int &v), gtime_t &),     asCALL_THISCALL },
            { "gtime_t &opMulAssign(const int &in)",     asMETHODPR(gtime_t, operator*=, (const int &v), gtime_t &),     asCALL_THISCALL },
            { "gtime_t &opDivAssign(const float &in)",   asMETHODPR(gtime_t, operator/=, (const float &v), gtime_t &),   asCALL_THISCALL },
            { "gtime_t &opMulAssign(const float &in)",   asMETHODPR(gtime_t, operator*=, (const float &v), gtime_t &),   asCALL_THISCALL },

            // conversions
            { "bool opConv() const", asMETHODPR(gtime_t, operator bool, () const, bool), asCALL_THISCALL }
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