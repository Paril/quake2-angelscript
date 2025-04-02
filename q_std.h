// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#pragma once

// q_std.h -- 'standard' library stuff for game module
// not meant to be included by engine, etc

#include <cmath>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <cstdlib>
#include <cstddef>
#include <cinttypes>
#include <ctime>
#include <type_traits>
#include <algorithm>
#include <array>
#include <string_view>
#include <numeric>
#include <functional>
#include <optional>

// format!
#ifndef USE_CPP20_FORMAT
#ifdef __cpp_lib_format
#define USE_CPP20_FORMAT
#endif
#endif

#ifdef USE_CPP20_FORMAT
#include <format>
namespace fmt = std;
#define FMT_STRING(s) s
#else
#include <fmt/format.h>
#endif

struct g_fmt_data_t
{
    char string[2][4096];
    int  istr;
};

// static data for fmt; internal, do not touch
extern g_fmt_data_t g_fmt_data;

// like fmt::format_to_n, but automatically null terminates the output;
// returns the length of the string written (up to N)
#ifdef USE_CPP20_FORMAT
#define G_FmtTo_ G_FmtTo

template<size_t N, typename... Args>
inline size_t G_FmtTo(char(&buffer)[N], std::format_string<Args...> format_str, Args &&... args)
#else
#define G_FmtTo(buffer, str, ...) \
	G_FmtTo_(buffer, FMT_STRING(str), __VA_ARGS__)

template<size_t N, typename S, typename... Args>
inline size_t G_FmtTo_(char(&buffer)[N], const S &format_str, Args &&... args)
#endif
{
    auto end = fmt::format_to_n(buffer, N - 1, format_str, std::forward<Args>(args)...);

    *(end.out) = '\0';

    return end.out - buffer;
}

// format to temp buffers; doesn't use heap allocation
// unlike `fmt::format` does directly
#ifdef USE_CPP20_FORMAT
template<typename... Args>
[[nodiscard]] inline std::string_view G_Fmt(std::format_string<Args...> format_str, Args &&... args)
#else

#define G_Fmt(str, ...) \
	G_Fmt_(FMT_STRING(str), __VA_ARGS__)

template<typename S, typename... Args>
[[nodiscard]] inline std::string_view G_Fmt_(const S &format_str, Args &&... args)
#endif
{
    g_fmt_data.istr ^= 1;

    size_t len = G_FmtTo_(g_fmt_data.string[g_fmt_data.istr], format_str, std::forward<Args>(args)...);

    return std::string_view(g_fmt_data.string[g_fmt_data.istr], len);
}

using byte = uint8_t;

using std::max;
using std::min;
using std::clamp;

template<typename T>
constexpr T lerp(T from, T to, float t)
{
    return (to * t) + (from * (1.f - t));
}

// angle indexes
enum
{
    PITCH,
    YAW,
    ROLL
};

/*
==============================================================

MATHLIB

==============================================================
*/

constexpr double PI = 3.14159265358979323846; // matches value in gcc v2 math.h
constexpr float PIf = static_cast<float>(PI);

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

//=============================================

std::optional<std::string_view> COM_ParseView(std::string_view &data_p, const char *seps = "\r\n\t ");

//=============================================

// portable case insensitive compare
[[nodiscard]] int Q_strcasecmp(const char *s1, const char *s2);
[[nodiscard]] int Q_strncasecmp(const char *s1, const char *s2, size_t n);

// BSD string utils - haleyjd
size_t Q_strlcpy(char *dst, const char *src, size_t siz);

// EOF