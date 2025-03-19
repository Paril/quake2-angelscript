#include "q2as_local.h"
#include "q2as_reg.h"
#include "q2as_pmove.h"
#include "../bg_local.h"

bool Q2AS_RegisterPmove(asIScriptEngine *engine)
{
#define Q2AS_OBJECT usercmd_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);

	// props
	EnsureRegisteredProperty("uint8", msec);
	EnsureRegisteredProperty("button_t", buttons);
	EnsureRegisteredProperty("vec3_t", angles);
	EnsureRegisteredProperty("float", forwardmove);
	EnsureRegisteredProperty("float", sidemove);
	EnsureRegisteredProperty("uint32", server_frame);

#undef Q2AS_OBJECT
	
	// pmove_t is a bit special since it's a script type
	// that we create on the code side and pass over to
	// the scripting engine.

	Ensure(engine->RegisterFuncdef("trace_t pm_trace_f(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, edict_t@, contents_t)"));
	Ensure(engine->RegisterFuncdef("trace_t pm_clip_f(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, contents_t)"));
	Ensure(engine->RegisterFuncdef("contents_t pm_pointcontents_f(const vec3_t &in)"));

	EnsureRegisteredTypeRaw("pmove_t", sizeof(as_pmove_t), asOBJ_REF);
	EnsureRegisteredPropertyRaw("pmove_t", "pmove_state_t s", asOFFSET(as_pmove_t, s));
	EnsureRegisteredPropertyRaw("pmove_t", "usercmd_t cmd", asOFFSET(as_pmove_t, cmd));
	EnsureRegisteredPropertyRaw("pmove_t", "bool snapinitial", asOFFSET(as_pmove_t, snapinitial));
	// TODO figure this out
	//EnsureRegisteredPropertyRaw("pmove_t", "array<trace_t> @touch", asOFFSET(as_pmove_t, touch_o));
	EnsureRegisteredMethodRaw("pmove_t", "uint touch_length() const", asMETHOD(as_pmove_t, touch_length), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("pmove_t", "void touch_push_back(trace_t &in)", asMETHOD(as_pmove_t, touch_push_back), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("pmove_t", "const trace_t &touch_get(uint i) const", asMETHOD(as_pmove_t, touch_get), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("pmove_t", "void touch_clear()", asMETHOD(as_pmove_t, touch_clear), asCALL_THISCALL);
	EnsureRegisteredPropertyRaw("pmove_t", "vec3_t viewangles", asOFFSET(as_pmove_t, viewangles));
	EnsureRegisteredPropertyRaw("pmove_t", "vec3_t mins", asOFFSET(as_pmove_t, mins));
	EnsureRegisteredPropertyRaw("pmove_t", "vec3_t maxs", asOFFSET(as_pmove_t, maxs));
	EnsureRegisteredPropertyRaw("pmove_t", "edict_t @groundentity", asOFFSET(as_pmove_t, groundentity));
	EnsureRegisteredPropertyRaw("pmove_t", "cplane_t groundplane", asOFFSET(as_pmove_t, groundplane));
	EnsureRegisteredPropertyRaw("pmove_t", "contents_t watertype", asOFFSET(as_pmove_t, watertype));
	EnsureRegisteredPropertyRaw("pmove_t", "water_level_t waterlevel", asOFFSET(as_pmove_t, waterlevel));
	EnsureRegisteredPropertyRaw("pmove_t", "edict_t @player", asOFFSET(as_pmove_t, player));
	EnsureRegisteredPropertyRaw("pmove_t", "pm_trace_f @trace", asOFFSET(as_pmove_t, trace_f));
	EnsureRegisteredPropertyRaw("pmove_t", "pm_clip_f @clip", asOFFSET(as_pmove_t, clip_f));
	EnsureRegisteredPropertyRaw("pmove_t", "pm_pointcontents_f @pointcontents", asOFFSET(as_pmove_t, pointcontents_f));
	EnsureRegisteredPropertyRaw("pmove_t", "vec3_t viewoffset", asOFFSET(as_pmove_t, viewoffset));
	EnsureRegisteredPropertyRaw("pmove_t", "vec4_t screen_blend", asOFFSET(as_pmove_t, screen_blend));
	EnsureRegisteredPropertyRaw("pmove_t", "refdef_flags_t rdflags", asOFFSET(as_pmove_t, rdflags));
	EnsureRegisteredPropertyRaw("pmove_t", "bool jump_sound", asOFFSET(as_pmove_t, jump_sound));
	EnsureRegisteredPropertyRaw("pmove_t", "bool step_clip", asOFFSET(as_pmove_t, step_clip));
	EnsureRegisteredPropertyRaw("pmove_t", "float impact_delta", asOFFSET(as_pmove_t, impact_delta));

	return true;
}