#include "q2as_local.h"
#include "q2as_reg.h"

// registers a limits namespace for the given type.
// it will be in `T_limits` (eg double_limits).
template<typename T>
static bool Q2AS_RegisterLimitsForType(asIScriptEngine *engine, const char *type_str)
{
    engine->SetDefaultNamespace(G_Fmt("{}_limits", type_str).data());

#define RegisterLimitGlobal(gtype, name) \
        { static gtype _g = std::numeric_limits<T>::name; EnsureRegisteredGlobalProperty(G_Fmt("const {0} {1}", #gtype, #name).data(), &_g); }
#define RegisterLimitGlobalTFunc(gtype, name) \
        { static gtype _g = std::numeric_limits<T>::name(); EnsureRegisteredGlobalProperty(G_Fmt("const {0} {1}", type_str, #name).data(), &_g); }
    
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

    engine->SetDefaultNamespace("");

    return true;
}

bool Q2AS_RegisterLimits(asIScriptEngine *engine)
{
    // limits
    return Q2AS_RegisterLimitsForType<uint8_t>(engine, "uint8") &&
           Q2AS_RegisterLimitsForType<uint16_t>(engine, "uint16") &&
           Q2AS_RegisterLimitsForType<uint32_t>(engine, "uint32") &&
           Q2AS_RegisterLimitsForType<uint64_t>(engine, "uint64") &&
           Q2AS_RegisterLimitsForType<int8_t>(engine, "int8") &&
           Q2AS_RegisterLimitsForType<int16_t>(engine, "int16") &&
           Q2AS_RegisterLimitsForType<int32_t>(engine, "int32") &&
           Q2AS_RegisterLimitsForType<int64_t>(engine, "int64") &&
           Q2AS_RegisterLimitsForType<float>(engine, "float") &&
           Q2AS_RegisterLimitsForType<double>(engine, "double");
}