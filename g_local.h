// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

// g_local.h -- local definitions for game module
#pragma once

#include "q_std.h"

#define USE_VEC3_TYPE
#include "game.h"

// memory tags to allow dynamic memory to be cleaned up
enum
{
    TAG_GAME = 765, // clear when unloading the dll
    TAG_LEVEL = 766 // clear when loading a new level
};

// the "gameversion" client command will print this plus compile date
constexpr const char *GAMEVERSION = "baseq2";

//==================================================================

struct local_game_import_t : game_import_t
{
    inline local_game_import_t() = default;
    inline local_game_import_t(const game_import_t &imports) :
        game_import_t(imports)
    {
    }

public:
    // collision detection
    [[nodiscard]] inline trace_t trace(const vec3_t &start, const vec3_t &mins, const vec3_t &maxs, const vec3_t &end,
                                       const edict_t *passent, contents_t contentmask)
    {
        return game_import_t::trace(start, &mins, &maxs, end, passent, contentmask);
    }

    [[nodiscard]] inline trace_t traceline(const vec3_t &start, const vec3_t &end, const edict_t *passent,
                                           contents_t contentmask)
    {
        return game_import_t::trace(start, nullptr, nullptr, end, passent, contentmask);
    }

    // [Paril-KEX] clip the box against the specified entity
    [[nodiscard]] inline trace_t clip(edict_t *entity, const vec3_t &start, const vec3_t &mins, const vec3_t &maxs,
                                      const vec3_t &end, contents_t contentmask)
    {
        return game_import_t::clip(entity, start, &mins, &maxs, end, contentmask);
    }

    [[nodiscard]] inline trace_t clip(edict_t *entity, const vec3_t &start, const vec3_t &end, contents_t contentmask)
    {
        return game_import_t::clip(entity, start, nullptr, nullptr, end, contentmask);
    }

    void unicast(edict_t *ent, bool reliable, uint32_t dupe_key = 0)
    {
        game_import_t::unicast(ent, reliable, dupe_key);
    }

    void local_sound(edict_t *target, const vec3_t &origin, edict_t *ent, soundchan_t channel, int soundindex,
                     float volume, float attenuation, float timeofs, uint32_t dupe_key = 0)
    {
        game_import_t::local_sound(target, &origin, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
    }

    void local_sound(edict_t *target, edict_t *ent, soundchan_t channel, int soundindex, float volume,
                     float attenuation, float timeofs, uint32_t dupe_key = 0)
    {
        game_import_t::local_sound(target, nullptr, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
    }

    void local_sound(const vec3_t &origin, edict_t *ent, soundchan_t channel, int soundindex, float volume,
                     float attenuation, float timeofs, uint32_t dupe_key = 0)
    {
        game_import_t::local_sound(ent, &origin, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
    }

    void local_sound(edict_t *ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs,
                     uint32_t dupe_key = 0)
    {
        game_import_t::local_sound(ent, nullptr, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
    }
};

extern local_game_import_t gi;
extern game_export_t       globals;

#include <random>
extern std::mt19937 mt_rand;

// uniform float [0, 1)
[[nodiscard]] inline float frandom()
{
    return std::uniform_real_distribution<float>()(mt_rand);
}

// uniform float [min_inclusive, max_exclusive)
[[nodiscard]] inline float frandom(float min_inclusive, float max_exclusive)
{
    return std::uniform_real_distribution<float>(min_inclusive, max_exclusive)(mt_rand);
}

// uniform float [0, max_exclusive)
[[nodiscard]] inline float frandom(float max_exclusive)
{
    return std::uniform_real_distribution<float>(0, max_exclusive)(mt_rand);
}

// uniform float [-1, 1)
// note: closed on min but not max
// to match vanilla behavior
[[nodiscard]] inline float crandom()
{
    return std::uniform_real_distribution<float>(-1.f, 1.f)(mt_rand);
}

// uniform float (-1, 1)
[[nodiscard]] inline float crandom_open()
{
    return std::uniform_real_distribution<float>(std::nextafterf(-1.f, 0.f), 1.f)(mt_rand);
}

// raw unsigned int32 value from random
[[nodiscard]] inline uint32_t irandom()
{
    return mt_rand();
}

// uniform int [min, max)
// always returns min if min == (max - 1)
// undefined behavior if min > (max - 1)
[[nodiscard]] inline int32_t irandom(int32_t min_inclusive, int32_t max_exclusive)
{
    if (min_inclusive == max_exclusive - 1)
        return min_inclusive;

    return std::uniform_int_distribution<int32_t>(min_inclusive, max_exclusive - 1)(mt_rand);
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
