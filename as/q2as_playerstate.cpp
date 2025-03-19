#include "q2as_local.h"
#include "../bg_local.h"
#include "q2as_reg.h"
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

bool Q2AS_RegisterPlayerState(asIScriptEngine *engine)
{
#define Q2AS_OBJECT contents_t
#define Q2AS_ENUM_PREFIX CONTENTS_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(CONTENTS_, NONE);
	EnsureRegisteredEnumValue(CONTENTS_, SOLID);
	EnsureRegisteredEnumValue(CONTENTS_, WINDOW);
	EnsureRegisteredEnumValue(CONTENTS_, AUX);
	EnsureRegisteredEnumValue(CONTENTS_, LAVA);
	EnsureRegisteredEnumValue(CONTENTS_, SLIME);
	EnsureRegisteredEnumValue(CONTENTS_, WATER);
	EnsureRegisteredEnumValue(CONTENTS_, MIST);
	EnsureRegisteredEnumValue(CONTENTS_, NO_WATERJUMP);
	EnsureRegisteredEnumValue(CONTENTS_, PROJECTILECLIP);
	EnsureRegisteredEnumValue(CONTENTS_, AREAPORTAL);
	EnsureRegisteredEnumValue(CONTENTS_, PLAYERCLIP);
	EnsureRegisteredEnumValue(CONTENTS_, MONSTERCLIP);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_0);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_90);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_180);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_270);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_UP);
	EnsureRegisteredEnumValue(CONTENTS_, CURRENT_DOWN);
	EnsureRegisteredEnumValue(CONTENTS_, ORIGIN);
	EnsureRegisteredEnumValue(CONTENTS_, MONSTER);
	EnsureRegisteredEnumValue(CONTENTS_, DEADMONSTER);
	EnsureRegisteredEnumValue(CONTENTS_, DETAIL);
	EnsureRegisteredEnumValue(CONTENTS_, TRANSLUCENT);
	EnsureRegisteredEnumValue(CONTENTS_, LADDER);
	EnsureRegisteredEnumValue(CONTENTS_, PLAYER);
	EnsureRegisteredEnumValue(CONTENTS_, PROJECTILE);

	// TODO: LAST_VISIBLE_CONTENTS?
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT contents_t
#define Q2AS_ENUM_PREFIX MASK_
	
	EnsureRegisteredEnumValueGlobal(MASK_, ALL);
	EnsureRegisteredEnumValueGlobal(MASK_, SOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, PLAYERSOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, DEADSOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, MONSTERSOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, WATER);
	EnsureRegisteredEnumValueGlobal(MASK_, OPAQUE);
	EnsureRegisteredEnumValueGlobal(MASK_, SHOT);
	EnsureRegisteredEnumValueGlobal(MASK_, CURRENT);
	EnsureRegisteredEnumValueGlobal(MASK_, BLOCK_SIGHT);
	EnsureRegisteredEnumValueGlobal(MASK_, NAV_SOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, LADDER_NAV_SOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, WALK_NAV_SOLID);
	EnsureRegisteredEnumValueGlobal(MASK_, PROJECTILE);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	
#define Q2AS_OBJECT surfflags_t
#define Q2AS_ENUM_PREFIX SURF_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(SURF_, NONE);
	EnsureRegisteredEnumValue(SURF_, LIGHT);
	EnsureRegisteredEnumValue(SURF_, SLICK);
	EnsureRegisteredEnumValue(SURF_, SKY);
	EnsureRegisteredEnumValue(SURF_, WARP);
	EnsureRegisteredEnumValue(SURF_, TRANS33);
	EnsureRegisteredEnumValue(SURF_, TRANS66);
	EnsureRegisteredEnumValue(SURF_, FLOWING);
	EnsureRegisteredEnumValue(SURF_, NODRAW);
	EnsureRegisteredEnumValue(SURF_, ALPHATEST);
	EnsureRegisteredEnumValue(SURF_, N64_UV);
	EnsureRegisteredEnumValue(SURF_, N64_SCROLL_X);
	EnsureRegisteredEnumValue(SURF_, N64_SCROLL_Y);
	EnsureRegisteredEnumValue(SURF_, N64_SCROLL_FLIP);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT cplane_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);

	// props
	EnsureRegisteredProperty("vec3_t", normal);
	EnsureRegisteredProperty("float", dist);
	EnsureRegisteredProperty("uint8", type);
	EnsureRegisteredProperty("uint8", signbits);

#undef Q2AS_OBJECT

	// csurface is a bit special (handle type)

	EnsureRegisteredTypeRaw("csurface_t", sizeof(csurface_t), asOBJ_REF | asOBJ_NOCOUNT);

	Ensure(engine->RegisterObjectMethod("csurface_t", "string get_name() const property", asFUNCTION(Q2AS_csurface_t_name), asCALL_CDECL_OBJLAST));
	EnsureRegisteredPropertyRaw("csurface_t", "const surfflags_t flags", asOFFSET(csurface_t, flags));
	EnsureRegisteredPropertyRaw("csurface_t", "const int value", asOFFSET(csurface_t, value));
	EnsureRegisteredPropertyRaw("csurface_t", "const uint id", asOFFSET(csurface_t, id));
	Ensure(engine->RegisterObjectMethod("csurface_t", "string get_material() const property", asFUNCTION(Q2AS_csurface_t_material), asCALL_CDECL_OBJLAST));

	Ensure(Q2AS_RegisterFixedArray<int16_t, MAX_STATS>(engine, "stat_array_t", "int16", asOBJ_APP_CLASS_ALLINTS));
    
	EnsureRegisteredMethodRaw("stat_array_t", "uint8 get_stat_uint8(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<uint8_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_uint8(uint byte_offset, uint8 value)", asFUNCTION(q2as_stat_array_set_stat<uint8_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "uint16 get_stat_uint16(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<uint16_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_uint16(uint byte_offset, uint16 value)", asFUNCTION(q2as_stat_array_set_stat<uint16_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "uint32 get_stat_uint32(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<uint32_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_uint32(uint byte_offset, uint32 value)", asFUNCTION(q2as_stat_array_set_stat<uint32_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "uint64 get_stat_uint64(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<uint64_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_uint64(uint byte_offset, uint64 value)", asFUNCTION(q2as_stat_array_set_stat<uint64_t>), asCALL_CDECL_OBJLAST);

	EnsureRegisteredMethodRaw("stat_array_t", "int8 get_stat_int8(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<int8_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_int8(uint byte_offset, int8 value)", asFUNCTION(q2as_stat_array_set_stat<int8_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "int16 get_stat_int16(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<int16_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_int16(uint byte_offset, int16 value)", asFUNCTION(q2as_stat_array_set_stat<int16_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "int32 get_stat_int32(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<int32_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_int32(uint byte_offset, int32 value)", asFUNCTION(q2as_stat_array_set_stat<int32_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "int64 get_stat_int64(uint byte_offset) const", asFUNCTION(q2as_stat_array_get_stat<int64_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("stat_array_t", "void set_stat_int64(uint byte_offset, int64 value)", asFUNCTION(q2as_stat_array_set_stat<int64_t>), asCALL_CDECL_OBJLAST);

	EnsureRegisteredMethodRaw("stat_array_t", "void fill(uint byte_offset, uint8 value, uint count)", asFUNCTION(q2as_stat_array_fill), asCALL_CDECL_OBJLAST);

#define Q2AS_OBJECT refdef_flags_t
#define Q2AS_ENUM_PREFIX RDF_

	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(RDF_, NONE);
	EnsureRegisteredEnumValue(RDF_, UNDERWATER);
	EnsureRegisteredEnumValue(RDF_, NOWORLDMODEL);
	EnsureRegisteredEnumValue(RDF_, IRGOGGLES);
	EnsureRegisteredEnumValue(RDF_, UVGOGGLES);
	EnsureRegisteredEnumValue(RDF_, NO_WEAPON_LERP);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT pmtype_t
#define Q2AS_ENUM_PREFIX PM_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(PM_, NORMAL);
	EnsureRegisteredEnumValue(PM_, GRAPPLE);
	EnsureRegisteredEnumValue(PM_, NOCLIP);
	EnsureRegisteredEnumValue(PM_, SPECTATOR);
	EnsureRegisteredEnumValue(PM_, DEAD);
	EnsureRegisteredEnumValue(PM_, GIB);
	EnsureRegisteredEnumValue(PM_, FREEZE);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	
#define Q2AS_OBJECT pmflags_t
#define Q2AS_ENUM_PREFIX PMF_

	EnsureRegisteredTypedEnum("uint16");
	EnsureRegisteredEnumValue(PMF_, NONE);
	EnsureRegisteredEnumValue(PMF_, DUCKED);
	EnsureRegisteredEnumValue(PMF_, JUMP_HELD);
	EnsureRegisteredEnumValue(PMF_, ON_GROUND);
	EnsureRegisteredEnumValue(PMF_, TIME_WATERJUMP);
	EnsureRegisteredEnumValue(PMF_, TIME_LAND);
	EnsureRegisteredEnumValue(PMF_, TIME_TELEPORT);
	EnsureRegisteredEnumValue(PMF_, NO_POSITIONAL_PREDICTION);
	EnsureRegisteredEnumValue(PMF_, ON_LADDER);
	EnsureRegisteredEnumValue(PMF_, NO_ANGULAR_PREDICTION);
	EnsureRegisteredEnumValue(PMF_, IGNORE_PLAYER_COLLISION);
	EnsureRegisteredEnumValue(PMF_, TIME_TRICK);
	EnsureRegisteredEnumValue(PMF_, NO_GROUND_SEEK);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT button_t
#define Q2AS_ENUM_PREFIX BUTTON_

	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(BUTTON_, NONE);
	EnsureRegisteredEnumValue(BUTTON_, ATTACK);
	EnsureRegisteredEnumValue(BUTTON_, USE);
	EnsureRegisteredEnumValue(BUTTON_, HOLSTER);
	EnsureRegisteredEnumValue(BUTTON_, JUMP);
	EnsureRegisteredEnumValue(BUTTON_, CROUCH);
	EnsureRegisteredEnumValue(BUTTON_, ANY);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT water_level_t
#define Q2AS_ENUM_PREFIX WATER_

	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(WATER_, NONE);
	EnsureRegisteredEnumValue(WATER_, FEET);
	EnsureRegisteredEnumValue(WATER_, WAIST);
	EnsureRegisteredEnumValue(WATER_, UNDER);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT pmove_state_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);

	EnsureRegisteredMethod("bool opEquals(const pmove_state_t &in) const", asFUNCTION(Q2AS_type_equals<pmove_state_t>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredProperty("pmtype_t", pm_type);
	EnsureRegisteredProperty("vec3_t", origin);
	EnsureRegisteredProperty("vec3_t", velocity);
	EnsureRegisteredProperty("uint16", pm_time);
	EnsureRegisteredProperty("pmflags_t", pm_flags);
	EnsureRegisteredProperty("int16", gravity);
	EnsureRegisteredProperty("vec3_t", delta_angles);
	EnsureRegisteredProperty("int8", viewheight);

#undef Q2AS_OBJECT
    
#define Q2AS_OBJECT player_state_t
	
	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);
	
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<player_state_t>), asCALL_CDECL_OBJLAST);
	
	EnsureRegisteredProperty("pmove_state_t", pmove);

	EnsureRegisteredProperty("vec3_t", viewangles);
	EnsureRegisteredProperty("vec3_t", viewoffset);
	EnsureRegisteredProperty("vec3_t", kick_angles);
	
	EnsureRegisteredProperty("vec3_t", gunangles);
	EnsureRegisteredProperty("vec3_t", gunoffset);
	EnsureRegisteredProperty("int", gunindex);
	EnsureRegisteredProperty("int", gunskin);
	EnsureRegisteredProperty("int", gunframe);
	EnsureRegisteredProperty("int", gunrate);
	
	EnsureRegisteredProperty("vec4_t", screen_blend);
	EnsureRegisteredProperty("vec4_t", damage_blend);
	
	EnsureRegisteredProperty("float", fov);
	EnsureRegisteredProperty("refdef_flags_t", rdflags);

	EnsureRegisteredProperty("stat_array_t", stats);

	EnsureRegisteredProperty("uint8", team_id);

#undef Q2AS_OBJECT

    return true;
}