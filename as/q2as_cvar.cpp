#include "q2as_local.h"
#include "../bg_local.h"
#include "q2as_reg.h"

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

bool Q2AS_RegisterCvar(asIScriptEngine *engine)
{
#define Q2AS_OBJECT cvar_flags_t
#define Q2AS_ENUM_PREFIX CVAR_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(CVAR_, NOFLAGS);
	EnsureRegisteredEnumValue(CVAR_, ARCHIVE);
	EnsureRegisteredEnumValue(CVAR_, USERINFO);
	EnsureRegisteredEnumValue(CVAR_, SERVERINFO);
	EnsureRegisteredEnumValue(CVAR_, NOSET);

	EnsureRegisteredEnumValue(CVAR_, LATCH);
	EnsureRegisteredEnumValue(CVAR_, USER_PROFILE);

	// cvar is a bit special (handle type)

	EnsureRegisteredTypeRaw("cvar_t", sizeof(cvar_t), asOBJ_REF | asOBJ_NOCOUNT);

	engine->RegisterObjectMethod("cvar_t", "string get_name() const property", asFUNCTION(Q2AS_cvar_t_name), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("cvar_t", "string get_stringval() const property", asFUNCTION(Q2AS_cvar_t_stringval), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("cvar_t", "string get_latched_stringval() const property", asFUNCTION(Q2AS_cvar_t_latched_stringval), asCALL_CDECL_OBJLAST);
	EnsureRegisteredPropertyRaw("cvar_t", "const cvar_flags_t flags", asOFFSET(cvar_t, flags));
	EnsureRegisteredPropertyRaw("cvar_t", "const int modified_count", asOFFSET(cvar_t, modified_count));
	EnsureRegisteredPropertyRaw("cvar_t", "const float value", asOFFSET(cvar_t, value));
	EnsureRegisteredPropertyRaw("cvar_t", "const int integer", asOFFSET(cvar_t, integer));
	engine->RegisterObjectMethod("cvar_t", "const bool get_boolean() const property", asFUNCTION(Q2AS_cvar_t_boolean), asCALL_CDECL_OBJLAST);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

    return true;
}