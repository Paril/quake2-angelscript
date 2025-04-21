#include "q2as_pmove.h"
#include "q2as_local.h"

void Q2AS_RegisterPmove(q2as_registry &registry)
{
    registry
        .type("usercmd_t", sizeof(usercmd_t), asOBJ_VALUE | asOBJ_POD)
        .properties({
            { "uint8 msec",          asOFFSET(usercmd_t, msec) },
            { "button_t buttons",    asOFFSET(usercmd_t, buttons) },
            { "vec3_t angles",       asOFFSET(usercmd_t, angles) },
            { "float forwardmove",   asOFFSET(usercmd_t, forwardmove) },
            { "float sidemove",      asOFFSET(usercmd_t, sidemove) },
            { "uint32 server_frame", asOFFSET(usercmd_t, server_frame) }
        });

    // pmove_t is a bit special since it's a ref type
    // that we create on the code side and pass over to
    // the scripting engine.
    registry
        .funcdefs({
            "trace_t pm_trace_f(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, edict_t@, contents_t)",
            "trace_t pm_clip_f(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, contents_t)",
            "contents_t pm_pointcontents_f(const vec3_t &in)"
        });

    registry
        .type("pmove_t", sizeof(as_pmove_t), asOBJ_REF)
        .properties({
            //EnsureRegisteredPropertyRaw("pmove_t", "array<trace_t> @touch", asOFFSET(as_pmove_t, touch_o));
            { "pmove_state_t s",                   asOFFSET(as_pmove_t, pm.s) },
            { "usercmd_t cmd",                     asOFFSET(as_pmove_t, pm.cmd) },
            { "bool snapinitial",                  asOFFSET(as_pmove_t, pm.snapinitial) },
            { "vec3_t viewangles",                 asOFFSET(as_pmove_t, pm.viewangles) },
            { "vec3_t mins",                       asOFFSET(as_pmove_t, pm.mins) },
            { "vec3_t maxs",                       asOFFSET(as_pmove_t, pm.maxs) },
            { "edict_t @groundentity",             asOFFSET(as_pmove_t, pm.groundentity) },
            { "cplane_t groundplane",              asOFFSET(as_pmove_t, pm.groundplane) },
            { "contents_t watertype",              asOFFSET(as_pmove_t, pm.watertype) },
            { "water_level_t waterlevel",          asOFFSET(as_pmove_t, pm.waterlevel) },
            { "edict_t @player",                   asOFFSET(as_pmove_t, pm.player) },
            { "pm_trace_f @trace",                 asOFFSET(as_pmove_t, trace_f) },
            { "pm_clip_f @clip",                   asOFFSET(as_pmove_t, clip_f) },
            { "pm_pointcontents_f @pointcontents", asOFFSET(as_pmove_t, pointcontents_f) },
            { "vec3_t viewoffset",                 asOFFSET(as_pmove_t, pm.viewoffset) },
            { "vec4_t screen_blend",               asOFFSET(as_pmove_t, pm.screen_blend) },
            { "refdef_flags_t rdflags",            asOFFSET(as_pmove_t, pm.rdflags) },
            { "bool jump_sound",                   asOFFSET(as_pmove_t, pm.jump_sound) },
            { "bool step_clip",                    asOFFSET(as_pmove_t, pm.step_clip) },
            { "float impact_delta",                asOFFSET(as_pmove_t, pm.impact_delta) }
        })
        .behaviors({
            { asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<as_pmove_t>)), asCALL_GENERIC }
        })
        .methods({
            { "uint touch_length() const",              asMETHOD(as_pmove_t, touch_length),    asCALL_THISCALL },
            { "void touch_push_back(trace_t &in)",      asMETHOD(as_pmove_t, touch_push_back), asCALL_THISCALL },
            { "const trace_t &touch_get(uint i) const", asMETHOD(as_pmove_t, touch_get),       asCALL_THISCALL },
            { "void touch_clear()",                     asMETHOD(as_pmove_t, touch_clear),     asCALL_THISCALL }
        });
}