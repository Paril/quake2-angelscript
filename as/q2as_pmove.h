#pragma once

#include "q2as_local.h"
#include "../bg_local.h"

struct q2as_edict_t;

class as_pmove_t : public q2as_ref_t
{
public:
	as_pmove_t()
	{
	}

	~as_pmove_t()
	{
        if (trace_f)
            trace_f->Release();
        if (clip_f)
            clip_f->Release();
        if (pointcontents_f)
            pointcontents_f->Release();
	}

    // state (in / out)
    pmove_state_t s;

    // command (in)
    usercmd_t cmd;
    bool      snapinitial; // if s has been changed outside pmove

    // results (out)
    //touch_list_t touch;
	//CScriptArray *touch_o;
	std::vector<trace_t> touch_l;

    vec3_t viewangles; // clamped

    vec3_t mins, maxs; // bounding box size

    q2as_edict_t *groundentity;
    cplane_t      groundplane;
    contents_t    watertype;
    water_level_t waterlevel;

    q2as_edict_t *player; // opaque handle

    // clip against world & entities
	asIScriptFunction *trace_f;
    // [Paril-KEX] clip against world only
	asIScriptFunction *clip_f;

	asIScriptFunction *pointcontents_f;

    // [KEX] variables (in)
    vec3_t viewoffset; // last viewoffset (for accurate calculation of blending)

    // [KEX] results (out)
    gvec4_t screen_blend;
    refdef_flags_t rdflags; // merged with rdflags from server
    bool jump_sound; // play jump sound
    bool step_clip; // we clipped on top of an object from below
    float impact_delta; // impact delta, for falling damage

    uint32_t touch_length() const { return touch_l.size(); }
    void touch_push_back(const trace_t &v) { touch_l.push_back(v); }
    const trace_t &touch_get(uint32_t i) { return touch_l[i]; }
    void touch_clear() { return touch_l.clear(); }
};

#include "q2as_reg.h"

// register the factory for pmove itself.
template<typename T>
bool Q2AS_RegisterPmoveFactory(asIScriptEngine *engine)
{
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_FACTORY, "pmove_t@ f()", asFUNCTION((Q2AS_Factory<as_pmove_t, T>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<as_pmove_t, T>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_RELEASE, "void f()", asFUNCTION((Q2AS_Release<as_pmove_t, T>)), asCALL_GENERIC);

    return true;
}