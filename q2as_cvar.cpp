#include "q2as_local.h"
#include "bg_local.h"

static std::string Q2AS_cvar_t_name(cvar_t *n)
{
	return n->name;
}

static std::string Q2AS_cvar_t_stringval(cvar_t *n)
{
	return n->string;
}

static std::string Q2AS_cvar_t_latched_stringval(cvar_t *n)
{
	return n->latched_string;
}

static bool Q2AS_cvar_t_boolean(cvar_t *n)
{
    return !!n->integer;
}

void Q2AS_RegisterCvar(q2as_registry &registry)
{
	registry
		.enumeration("cvar_flags_t")
		.values({
			{ "NOFLAGS",    CVAR_NOFLAGS },
			{ "ARCHIVE",    CVAR_ARCHIVE },
			{ "USERINFO",   CVAR_USERINFO },
			{ "SERVERINFO", CVAR_SERVERINFO },
			{ "NOSET",      CVAR_NOSET },

			{ "LATCH",        CVAR_LATCH },
			{ "USER_PROFILE", CVAR_USER_PROFILE }
		});

	// cvar is a bit special (handle type)
	registry
		.type("cvar_t", sizeof(cvar_t), asOBJ_REF | asOBJ_NOCOUNT)
		.properties({
			{ "const cvar_flags_t flags", asOFFSET(cvar_t, flags) },
			{ "const int modified_count", asOFFSET(cvar_t, modified_count) },
			{ "const float value",        asOFFSET(cvar_t, value) },
			{ "const int integer",        asOFFSET(cvar_t, integer) }
		})
		.methods({
			{ "string get_name() const property",              asFUNCTION(Q2AS_cvar_t_name),              asCALL_CDECL_OBJLAST },
			{ "string get_stringval() const property",         asFUNCTION(Q2AS_cvar_t_stringval),         asCALL_CDECL_OBJLAST },
			{ "string get_latched_stringval() const property", asFUNCTION(Q2AS_cvar_t_latched_stringval), asCALL_CDECL_OBJLAST },
			{ "const bool get_boolean() const property",       asFUNCTION(Q2AS_cvar_t_boolean),           asCALL_CDECL_OBJLAST },
		});
}