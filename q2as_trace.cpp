#include "q2as_local.h"

void Q2AS_RegisterTrace(q2as_registry &registry)
{
    registry
        .type("trace_t", sizeof(trace_t), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C)
        .properties({
            { "bool allsolid",        asOFFSET(trace_t, allsolid) },
            { "bool startsolid",      asOFFSET(trace_t, startsolid) },
            { "float fraction",       asOFFSET(trace_t, fraction) },
            { "vec3_t endpos",        asOFFSET(trace_t, endpos) },
            { "cplane_t plane",       asOFFSET(trace_t, plane) },
            { "csurface_t @surface",  asOFFSET(trace_t, surface) },
            { "contents_t contents",  asOFFSET(trace_t, contents) },
            { "edict_t @ent",         asOFFSET(trace_t, ent) },
            { "cplane_t plane2",      asOFFSET(trace_t, plane2) },
            { "csurface_t @surface2", asOFFSET(trace_t, surface2) }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<trace_t>), asCALL_CDECL_OBJLAST }
        });
}