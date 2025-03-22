#include "q2as_local.h"
#include "q2as_reg.h"
#include "bg_local.h"

bool Q2AS_RegisterTrace(asIScriptEngine *engine)
{
#define Q2AS_OBJECT trace_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS | asOBJ_APP_CLASS_COPY_CONSTRUCTOR | asOBJ_APP_CLASS_ASSIGNMENT);

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const trace_t &in)", asFUNCTION(Q2AS_init_construct_copy<trace_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("trace_t &opAssign (const trace_t &in)", asFUNCTION(Q2AS_assign<trace_t>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredProperty("bool", allsolid);
	EnsureRegisteredProperty("bool", startsolid);
	EnsureRegisteredProperty("float", fraction);
	EnsureRegisteredProperty("vec3_t", endpos);
	EnsureRegisteredProperty("cplane_t", plane);
	EnsureRegisteredProperty("csurface_t @", surface);
	EnsureRegisteredProperty("contents_t", contents);
	EnsureRegisteredProperty("edict_t @", ent);
	EnsureRegisteredProperty("cplane_t", plane2);
	EnsureRegisteredProperty("csurface_t @", surface2);

#undef Q2AS_OBJECT

	return true;
}