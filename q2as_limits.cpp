#include "q2as_local.h"

// registers a limits namespace for the given type.
// it will be in `T_limits` (eg double_limits).
template<typename T>
static void Q2AS_RegisterLimitsForType(q2as_registry &registry, const char *type_str)
{
    registry.set_namespace(fmt::format("{}_limits", type_str));

#define RegisterLimitGlobal(gtype, name) \
        { static const gtype _g = std::numeric_limits<T>::name; registry.for_global().property({ fmt::format("const {0} {1}", #gtype, #name), &_g }); }
#define RegisterLimitGlobalTFunc(gtype, name) \
        { static const gtype _g = std::numeric_limits<T>::name(); registry.for_global().property({ fmt::format("const {0} {1}", type_str, #name), &_g }); }

    RegisterLimitGlobal(int, digits);
    RegisterLimitGlobal(int, digits10);
    RegisterLimitGlobal(int, max_digits10);

    RegisterLimitGlobalTFunc(T, min);
    RegisterLimitGlobalTFunc(T, lowest);
    RegisterLimitGlobalTFunc(T, max);

    if constexpr (std::is_floating_point_v<T>)
    {
        RegisterLimitGlobalTFunc(T, epsilon);
        RegisterLimitGlobalTFunc(T, round_error);
        RegisterLimitGlobalTFunc(T, infinity);
        RegisterLimitGlobalTFunc(T, quiet_NaN);
        RegisterLimitGlobalTFunc(T, signaling_NaN);
        RegisterLimitGlobalTFunc(T, denorm_min);

        RegisterLimitGlobal(int, min_exponent);
        RegisterLimitGlobal(int, min_exponent10);
        RegisterLimitGlobal(int, max_exponent);
        RegisterLimitGlobal(int, max_exponent10);
    }

    registry.set_namespace();
}

void Q2AS_RegisterLimits(q2as_registry &registry)
{
    // limits
    Q2AS_RegisterLimitsForType<uint8_t>(registry, "uint8");
    Q2AS_RegisterLimitsForType<uint16_t>(registry, "uint16");
    Q2AS_RegisterLimitsForType<uint32_t>(registry, "uint32");
    Q2AS_RegisterLimitsForType<uint64_t>(registry, "uint64");
    Q2AS_RegisterLimitsForType<int8_t>(registry, "int8");
    Q2AS_RegisterLimitsForType<int16_t>(registry, "int16");
    Q2AS_RegisterLimitsForType<int32_t>(registry, "int32");
    Q2AS_RegisterLimitsForType<int64_t>(registry, "int64");
    Q2AS_RegisterLimitsForType<float>(registry, "float");
    Q2AS_RegisterLimitsForType<double>(registry, "double");
}