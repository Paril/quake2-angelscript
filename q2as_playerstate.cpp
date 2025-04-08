#include "q2as_local.h"
#include "q2as_fixedarray.h"

static std::string Q2AS_csurface_t_name(csurface_t *n)
{
    return n->name;
}

static std::string Q2AS_csurface_t_material(csurface_t *n)
{
    return n->material;
}

template<typename T>
static T q2as_stat_array_get_stat(uint32_t byte_offset, const decltype(player_state_t::stats) &stats)
{
    if (byte_offset > sizeof(stats) - sizeof(T))
        return 0;
    return *(reinterpret_cast<const T *>((reinterpret_cast<const uint8_t *>(stats.data()) + byte_offset)));
}

template<typename T>
static void q2as_stat_array_set_stat(uint32_t byte_offset, T value, decltype(player_state_t::stats) &stats)
{
    if (byte_offset > sizeof(stats) - sizeof(T))
        return;
    *(reinterpret_cast<T *>((reinterpret_cast<uint8_t *>(stats.data()) + byte_offset))) = value;
}

static void q2as_stat_array_fill(uint32_t byte_offset, uint8_t value, uint32_t length, decltype(player_state_t::stats) &stats)
{
    if (byte_offset + length > sizeof(stats))
        return;
    std::fill_n((reinterpret_cast<uint8_t *>(stats.data()) + byte_offset), length, value);
}

void Q2AS_RegisterPlayerState(q2as_registry &registry)
{
    // TODO: LAST_VISIBLE_CONTENTS? might be too internal to bother with
    registry
        .enumeration("contents_t")
        .values({
            { "NONE",           CONTENTS_NONE },
            { "SOLID",          CONTENTS_SOLID },
            { "WINDOW",         CONTENTS_WINDOW },
            { "AUX",            CONTENTS_AUX },
            { "LAVA",           CONTENTS_LAVA },
            { "SLIME",          CONTENTS_SLIME },
            { "WATER",          CONTENTS_WATER },
            { "MIST",           CONTENTS_MIST },
            { "NO_WATERJUMP",   CONTENTS_NO_WATERJUMP },
            { "PROJECTILECLIP", CONTENTS_PROJECTILECLIP },
            { "AREAPORTAL",     CONTENTS_AREAPORTAL },
            { "PLAYERCLIP",     CONTENTS_PLAYERCLIP },
            { "MONSTERCLIP",    CONTENTS_MONSTERCLIP },
            { "CURRENT_0",      CONTENTS_CURRENT_0 },
            { "CURRENT_90",     CONTENTS_CURRENT_90 },
            { "CURRENT_180",    CONTENTS_CURRENT_180 },
            { "CURRENT_270",    CONTENTS_CURRENT_270 },
            { "CURRENT_UP",     CONTENTS_CURRENT_UP },
            { "CURRENT_DOWN",   CONTENTS_CURRENT_DOWN },
            { "ORIGIN",         CONTENTS_ORIGIN },
            { "MONSTER",        CONTENTS_MONSTER },
            { "DEADMONSTER",    CONTENTS_DEADMONSTER },
            { "DETAIL",         CONTENTS_DETAIL },
            { "TRANSLUCENT",    CONTENTS_TRANSLUCENT },
            { "LADDER",         CONTENTS_LADDER },
            { "PLAYER",         CONTENTS_PLAYER },
            { "PROJECTILE",     CONTENTS_PROJECTILE }
        })
        .values({
            { "MASK_ALL",              MASK_ALL },
            { "MASK_SOLID",            MASK_SOLID },
            { "MASK_PLAYERSOLID",      MASK_PLAYERSOLID },
            { "MASK_DEADSOLID",        MASK_DEADSOLID },
            { "MASK_MONSTERSOLID",     MASK_MONSTERSOLID },
            { "MASK_WATER",            MASK_WATER },
            { "MASK_OPAQUE",           MASK_OPAQUE },
            { "MASK_SHOT",             MASK_SHOT },
            { "MASK_CURRENT",          MASK_CURRENT },
            { "MASK_BLOCK_SIGHT",      MASK_BLOCK_SIGHT },
            { "MASK_NAV_SOLID",        MASK_NAV_SOLID },
            { "MASK_LADDER_NAV_SOLID", MASK_LADDER_NAV_SOLID },
            { "MASK_WALK_NAV_SOLID",   MASK_WALK_NAV_SOLID },
            { "MASK_PROJECTILE",       MASK_PROJECTILE }
        });

    registry
        .enumeration("surfflags_t")
        .values({
            { "NONE",            SURF_NONE },
            { "LIGHT",           SURF_LIGHT },
            { "SLICK",           SURF_SLICK },
            { "SKY",             SURF_SKY },
            { "WARP",            SURF_WARP },
            { "TRANS33",         SURF_TRANS33 },
            { "TRANS66",         SURF_TRANS66 },
            { "FLOWING",         SURF_FLOWING },
            { "NODRAW",          SURF_NODRAW },
            { "ALPHATEST",       SURF_ALPHATEST },
            { "N64_UV",          SURF_N64_UV },
            { "N64_SCROLL_X",    SURF_N64_SCROLL_X },
            { "N64_SCROLL_Y",    SURF_N64_SCROLL_Y },
            { "N64_SCROLL_FLIP", SURF_N64_SCROLL_FLIP }
        });

    registry
        .type("cplane_t", sizeof(cplane_t), asOBJ_VALUE | asOBJ_POD)
        .properties({
            { "vec3_t normal",  asOFFSET(cplane_t, normal) },
            { "float dist",     asOFFSET(cplane_t, dist) },
            { "uint8 type",     asOFFSET(cplane_t, type) },
            { "uint8 signbits", asOFFSET(cplane_t, signbits) }
        });

    // csurface is a bit special (handle type)
    registry
        .type("csurface_t", sizeof(csurface_t), asOBJ_REF | asOBJ_NOCOUNT)
        .methods({
            { "string get_name() const property",     asFUNCTION(Q2AS_csurface_t_name),     asCALL_CDECL_OBJLAST },
            { "string get_material() const property", asFUNCTION(Q2AS_csurface_t_material), asCALL_CDECL_OBJLAST }
        })
        .properties({
            { "const surfflags_t flags", asOFFSET(csurface_t, flags) },
            { "const int value",         asOFFSET(csurface_t, value) },
            { "const uint id",           asOFFSET(csurface_t, id) }
        });

    Q2AS_RegisterFixedArray<int16_t, MAX_STATS>(registry, "stat_array_t", "int16", asOBJ_APP_CLASS_ALLINTS, false);

    registry
        .for_type("stat_array_t")
        .methods({
            { "uint8 get_stat_uint8(uint byte_offset) const",         asFUNCTION(q2as_stat_array_get_stat<uint8_t>),  asCALL_CDECL_OBJLAST },
            { "void set_stat_uint8(uint byte_offset, uint8 value)",   asFUNCTION(q2as_stat_array_set_stat<uint8_t>),  asCALL_CDECL_OBJLAST },
            { "uint16 get_stat_uint16(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<uint16_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_uint16(uint byte_offset, uint16 value)", asFUNCTION(q2as_stat_array_set_stat<uint16_t>), asCALL_CDECL_OBJLAST },
            { "uint32 get_stat_uint32(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<uint32_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_uint32(uint byte_offset, uint32 value)", asFUNCTION(q2as_stat_array_set_stat<uint32_t>), asCALL_CDECL_OBJLAST },
            { "uint64 get_stat_uint64(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<uint64_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_uint64(uint byte_offset, uint64 value)", asFUNCTION(q2as_stat_array_set_stat<uint64_t>), asCALL_CDECL_OBJLAST },

            { "int8 get_stat_int8(uint byte_offset) const",         asFUNCTION(q2as_stat_array_get_stat<int8_t>),  asCALL_CDECL_OBJLAST },
            { "void set_stat_int8(uint byte_offset, int8 value)",   asFUNCTION(q2as_stat_array_set_stat<int8_t>),  asCALL_CDECL_OBJLAST },
            { "int16 get_stat_int16(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<int16_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_int16(uint byte_offset, int16 value)", asFUNCTION(q2as_stat_array_set_stat<int16_t>), asCALL_CDECL_OBJLAST },
            { "int32 get_stat_int32(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<int32_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_int32(uint byte_offset, int32 value)", asFUNCTION(q2as_stat_array_set_stat<int32_t>), asCALL_CDECL_OBJLAST },
            { "int64 get_stat_int64(uint byte_offset) const",       asFUNCTION(q2as_stat_array_get_stat<int64_t>), asCALL_CDECL_OBJLAST },
            { "void set_stat_int64(uint byte_offset, int64 value)", asFUNCTION(q2as_stat_array_set_stat<int64_t>), asCALL_CDECL_OBJLAST },

            { "void fill(uint byte_offset, uint8 value, uint count)", asFUNCTION(q2as_stat_array_fill), asCALL_CDECL_OBJLAST }
        });

    registry
        .enumeration("refdef_flags_t", "uint8")
        .values({
            { "NONE",           RDF_NONE },
            { "UNDERWATER",     RDF_UNDERWATER },
            { "NOWORLDMODEL",   RDF_NOWORLDMODEL },
            { "IRGOGGLES",      RDF_IRGOGGLES },
            { "UVGOGGLES",      RDF_UVGOGGLES },
            { "NO_WEAPON_LERP", RDF_NO_WEAPON_LERP }
        });

    registry
        .enumeration("pmtype_t")
        .values({
            { "NORMAL",    PM_NORMAL },
            { "GRAPPLE",   PM_GRAPPLE },
            { "NOCLIP",    PM_NOCLIP },
            { "SPECTATOR", PM_SPECTATOR },
            { "DEAD",      PM_DEAD },
            { "GIB",       PM_GIB },
            { "FREEZE",    PM_FREEZE }
        });

    registry
        .enumeration("pmflags_t", "uint16")
        .values({
            { "NONE",                     PMF_NONE },
            { "DUCKED",                   PMF_DUCKED },
            { "JUMP_HELD",                PMF_JUMP_HELD },
            { "ON_GROUND",                PMF_ON_GROUND },
            { "TIME_WATERJUMP",           PMF_TIME_WATERJUMP },
            { "TIME_LAND",                PMF_TIME_LAND },
            { "TIME_TELEPORT",            PMF_TIME_TELEPORT },
            { "NO_POSITIONAL_PREDICTION", PMF_NO_POSITIONAL_PREDICTION },
            { "ON_LADDER",                PMF_ON_LADDER },
            { "NO_ANGULAR_PREDICTION",    PMF_NO_ANGULAR_PREDICTION },
            { "IGNORE_PLAYER_COLLISION",  PMF_IGNORE_PLAYER_COLLISION },
            { "TIME_TRICK",               PMF_TIME_TRICK },
            { "NO_GROUND_SEEK",           PMF_NO_GROUND_SEEK }
        });

    registry
        .enumeration("button_t", "uint8")
        .values({
            { "NONE",    BUTTON_NONE },
            { "ATTACK",  BUTTON_ATTACK },
            { "USE",     BUTTON_USE },
            { "HOLSTER", BUTTON_HOLSTER },
            { "JUMP",    BUTTON_JUMP },
            { "CROUCH",  BUTTON_CROUCH },
            { "ANY",     BUTTON_ANY }
        });

    registry
        .enumeration("water_level_t", "uint8")
        .values({
            { "NONE", WATER_NONE },
            { "FEET", WATER_FEET },
            { "WAIST", WATER_WAIST },
            { "UNDER", WATER_UNDER }
        });

    registry
        .type("pmove_state_t", sizeof(pmove_state_t), asOBJ_VALUE | asOBJ_POD)
        .methods({
            { "bool opEquals(const pmove_state_t &in) const", asFUNCTION(Q2AS_type_equals<pmove_state_t>), asCALL_CDECL_OBJLAST }
        })
        .properties({
            { "pmtype_t pm_type",    asOFFSET(pmove_state_t, pm_type) },
            { "vec3_t origin",       asOFFSET(pmove_state_t, origin) },
            { "vec3_t velocity",     asOFFSET(pmove_state_t, velocity) },
            { "uint16 pm_time",      asOFFSET(pmove_state_t, pm_time) },
            { "pmflags_t pm_flags",  asOFFSET(pmove_state_t, pm_flags) },
            { "int16 gravity",       asOFFSET(pmove_state_t, gravity) },
            { "vec3_t delta_angles", asOFFSET(pmove_state_t, delta_angles) },
            { "int8 viewheight",     asOFFSET(pmove_state_t, viewheight) }
        });

    registry
        .type("player_state_t", sizeof(player_state_t), asOBJ_VALUE | asOBJ_POD)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<player_state_t>), asCALL_CDECL_OBJLAST }
        })
        .properties({
            { "pmove_state_t pmove", asOFFSET(player_state_t, pmove) },

            { "vec3_t viewangles",  asOFFSET(player_state_t, viewangles) },
            { "vec3_t viewoffset",  asOFFSET(player_state_t, viewoffset) },
            { "vec3_t kick_angles", asOFFSET(player_state_t, kick_angles) },

            { "vec3_t gunangles", asOFFSET(player_state_t, gunangles) },
            { "vec3_t gunoffset", asOFFSET(player_state_t, gunoffset) },
            { "int gunindex",     asOFFSET(player_state_t, gunindex) },
            { "int gunskin",      asOFFSET(player_state_t, gunskin) },
            { "int gunframe",     asOFFSET(player_state_t, gunframe) },
            { "int gunrate",      asOFFSET(player_state_t, gunrate) },

            { "vec4_t screen_blend", asOFFSET(player_state_t, screen_blend) },
            { "vec4_t damage_blend", asOFFSET(player_state_t, damage_blend) },

            { "float fov",              asOFFSET(player_state_t, fov) },
            { "refdef_flags_t rdflags", asOFFSET(player_state_t, rdflags) },

            { "stat_array_t stats", asOFFSET(player_state_t, stats) },

            { "uint8 team_id", asOFFSET(player_state_t, team_id) }
        });
}