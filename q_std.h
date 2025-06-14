// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#pragma once

// q_std.h -- 'standard' library stuff for game module
// not meant to be included by engine, etc

#include <algorithm>
#include <array>
#include <cinttypes>
#include <cmath>
#include <cstdarg>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <functional>
#include <numeric>
#include <optional>
#include <string_view>
#include <type_traits>

// format!
#ifndef USE_CPP20_FORMAT
#ifdef __cpp_lib_format
#define USE_CPP20_FORMAT
#endif
#endif

#ifdef USE_CPP20_FORMAT
#include <format>
namespace fmt = std;
#else
#include <fmt/format.h>
#endif

using std::clamp;
using std::max;
using std::min;

template<typename T>
constexpr T lerp(T from, T to, float t)
{
    return (to * t) + (from * (1.f - t));
}

/*
==============================================================

MATHLIB

==============================================================
*/

constexpr double PI = 3.14159265358979323846; // matches value in gcc v2 math.h
constexpr float  PIf = static_cast<float>(PI);

[[nodiscard]] constexpr float RAD2DEG(float x)
{
    return (x * 180.0f / PIf);
}

[[nodiscard]] constexpr float DEG2RAD(float x)
{
    return (x * PIf / 180.0f);
}

//============================================================================

/*
===============
LerpAngle

===============
*/
[[nodiscard]] constexpr float LerpAngle(float a2, float a1, float frac)
{
    if (a1 - a2 > 180)
        a1 -= 360;
    if (a1 - a2 < -180)
        a1 += 360;
    return a2 + frac * (a1 - a2);
}

[[nodiscard]] inline float anglemod(float a)
{
    float v = fmod(a, 360.0f);

    if (v < 0)
        return 360.f + v;

    return v;
}

#include "q_vec3.h"

// EOF