#include "mum-prng.h"
#include <algorithm>
#include <random>

extern mum_prng_generator mum_prng;

// uniform float [0, 1)
[[nodiscard]] inline float frandom()
{
    return std::uniform_real_distribution<float>()(mum_prng);
}

// uniform float [min_inclusive, max_exclusive)
[[nodiscard]] inline float frandom(float min_inclusive, float max_exclusive)
{
    return std::uniform_real_distribution<float>(min_inclusive, max_exclusive)(mum_prng);
}

// uniform float [0, max_exclusive)
[[nodiscard]] inline float frandom(float max_exclusive)
{
    return std::uniform_real_distribution<float>(0, max_exclusive)(mum_prng);
}

// uniform time [min_inclusive, max_exclusive)
[[nodiscard]] inline gtime_t random_time(gtime_t min_inclusive, gtime_t max_exclusive)
{
    return gtime_t::from_ms(std::uniform_int_distribution<int64_t>(min_inclusive.milliseconds(), max_exclusive.milliseconds())(mum_prng));
}

// uniform time [0, max_exclusive)
[[nodiscard]] inline gtime_t random_time(gtime_t max_exclusive)
{
    return gtime_t::from_ms(std::uniform_int_distribution<int64_t>(0, max_exclusive.milliseconds())(mum_prng));
}

// uniform float [-1, 1)
// note: closed on min but not max
// to match vanilla behavior
[[nodiscard]] inline float crandom()
{
    return std::uniform_real_distribution<float>(-1.f, 1.f)(mum_prng);
}

// uniform float (-1, 1)
[[nodiscard]] inline float crandom_open()
{
    return std::uniform_real_distribution<float>(std::nextafterf(-1.f, 0.f), 1.f)(mum_prng);
}

// raw unsigned int32 value from random
[[nodiscard]] inline uint32_t irandom()
{
    return mum_prng.get_mum_prn();
}

// uniform int [min, max)
// always returns min if min == (max - 1)
// undefined behavior if min > (max - 1)
[[nodiscard]] inline int32_t irandom(int32_t min_inclusive, int32_t max_exclusive)
{
    if (min_inclusive == max_exclusive - 1)
        return min_inclusive;

    return std::uniform_int_distribution<int32_t>(min_inclusive, max_exclusive - 1)(mum_prng);
}

// uniform int [0, max)
// always returns 0 if max <= 0
// note for Q2 code:
// - to fix rand()%x, do irandom(x)
// - to fix rand()&x, do irandom(x + 1)
[[nodiscard]] inline int32_t irandom(int32_t max_exclusive)
{
    if (max_exclusive <= 0)
        return 0;

    return irandom(0, max_exclusive);
}

// flip a coin
[[nodiscard]] inline bool brandom()
{
    return irandom(2) == 0;
}
