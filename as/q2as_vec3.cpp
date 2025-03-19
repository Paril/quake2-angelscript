#include "q2as_local.h"
#include "q2as_reg.h"



static void Q2AS_vec3_t_init_construct_fff(const float x, const float y, const float z, vec3_t *v)
{
	(*v)[0] = x;
	(*v)[1] = y;
	(*v)[2] = z;
}

static void Q2AS_vec3_t_list_construct(const float *in, vec3_t *v)
{
	(*v)[0] = in[0];
	(*v)[1] = in[1];
	(*v)[2] = in[2];
}

static void Q2AS_vec3_t_list_copy(const vec3_t &in, vec3_t *v)
{
	(*v)[0] = in[0];
	(*v)[1] = in[1];
	(*v)[2] = in[2];
}

bool Q2AS_RegisterVec3(asIScriptEngine *engine)
{
#define Q2AS_OBJECT vec3_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_CAK);

	// props
	EnsureRegisteredProperty("float", x);
	EnsureRegisteredProperty("float", y);
	EnsureRegisteredProperty("float", z);
	EnsureRegisteredPropertyRaw("vec3_t", "float pitch", asOFFSET(vec3_t, x));
	EnsureRegisteredPropertyRaw("vec3_t", "float yaw", asOFFSET(vec3_t, y));
	EnsureRegisteredPropertyRaw("vec3_t", "float roll", asOFFSET(vec3_t, z));

	// constructors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(float, float, float)", asFUNCTION(Q2AS_vec3_t_init_construct_fff), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const vec3_t &in)", asFUNCTION(Q2AS_vec3_t_list_copy), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_LIST_CONSTRUCT, "void f(int &in) {float, float, float}", asFUNCTION(Q2AS_vec3_t_list_construct), asCALL_CDECL_OBJLAST);

	// array
	EnsureRegisteredMethod("float &opIndex(uint)",             asMETHODPR(vec3_t, operator[], (int), float &), asCALL_THISCALL);
	EnsureRegisteredMethod("const float &opIndex(uint) const", asMETHODPR(vec3_t, operator[], (int) const, const float &), asCALL_THISCALL);
	
	// equality
	EnsureRegisteredMethod("bool opEquals(const vec3_t &in) const", asMETHODPR(vec3_t, operator==, (const vec3_t &) const, bool), asCALL_THISCALL);
	EnsureRegisteredMethod("bool equals(const vec3_t &in, const float &in) const", asMETHODPR(vec3_t, equals, (const vec3_t &v, const float &epsilon) const, bool), asCALL_THISCALL);

	// conversion
	EnsureRegisteredMethod("bool opImplConv() const", asMETHODPR(vec3_t, operator bool, () const, bool), asCALL_THISCALL);

	// basic methods
	EnsureRegisteredMethod("float dot(const vec3_t &in) const", asMETHODPR(vec3_t, dot, (const vec3_t &) const, float), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t scaled(const vec3_t &in) const", asMETHODPR(vec3_t, scaled, (const vec3_t &) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &scale(const vec3_t &in)", asMETHODPR(vec3_t, scale, (const vec3_t &), vec3_t &), asCALL_THISCALL);

	// operators
	EnsureRegisteredMethod("vec3_t opSub(const vec3_t &in) const", asMETHODPR(vec3_t, operator-, (const vec3_t &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opAdd(const vec3_t &in) const", asMETHODPR(vec3_t, operator+, (const vec3_t &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opDiv(const vec3_t &in) const", asMETHODPR(vec3_t, operator/, (const vec3_t &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opDiv(const float &in) const", asMETHODPR(vec3_t, operator/, (const float &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opDiv(const int &in) const", asMETHODPR(vec3_t, operator/, (const int &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opMul(const float &in) const", asMETHODPR(vec3_t, operator*, (const float &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opMul(const int &in) const", asMETHODPR(vec3_t, operator*, (const int &v) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t opNeg() const", asMETHODPR(vec3_t, operator-, () const, vec3_t), asCALL_THISCALL);

	EnsureRegisteredMethod("vec3_t &opSubAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator-=, (const vec3_t &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opAddAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator+=, (const vec3_t &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opDivAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator/=, (const vec3_t &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opDivAssign(const float &in)", asMETHODPR(vec3_t, operator/=, (const float &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opDivAssign(const int &in)", asMETHODPR(vec3_t, operator/=, (const int &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opMulAssign(const float &in)", asMETHODPR(vec3_t, operator*=, (const float &v), vec3_t &), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t &opMulAssign(const int &in)", asMETHODPR(vec3_t, operator*=, (const int &v), vec3_t &), asCALL_THISCALL);

	// useful methods
	EnsureRegisteredMethod("float lengthSquared() const", asMETHODPR(vec3_t, lengthSquared, () const, float), asCALL_THISCALL);
	EnsureRegisteredMethod("float length() const", asMETHODPR(vec3_t, length, () const, float), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t normalized() const", asMETHODPR(vec3_t, normalized, () const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t normalized(float &out) const", asMETHODPR(vec3_t, normalized, (float &) const, vec3_t), asCALL_THISCALL);
	EnsureRegisteredMethod("float normalize()", asMETHODPR(vec3_t, normalize, (), float ), asCALL_THISCALL);
	EnsureRegisteredMethod("vec3_t cross(const vec3_t &in) const", asMETHODPR(vec3_t, cross, (const vec3_t &) const, vec3_t), asCALL_THISCALL);

	// globals
	EnsureRegisteredGlobalProperty("const vec3_t vec3_origin", (void *) &vec3_origin);

    // global methods
    EnsureRegisteredGlobalFunction("void AngleVectors(const vec3_t &in, vec3_t &out forward = void, vec3_t &out right = void, vec3_t &out up = void)", asFUNCTIONPR(AngleVectors, (const vec3_t &, vec3_t &, vec3_t &, vec3_t &), void), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t ProjectPointOnPlane(const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(ProjectPointOnPlane), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t PerpendicularVector(const vec3_t &in) nodiscard", asFUNCTION(PerpendicularVector), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t RotatePointAroundVector(const vec3_t &in, const vec3_t &in, float) nodiscard", asFUNCTION(RotatePointAroundVector), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("bool boxes_intersect(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(boxes_intersect), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("float distance_between_boxes(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(distance_between_boxes), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t closest_point_to_box(const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(closest_point_to_box), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t ClipVelocity(const vec3_t &in, const vec3_t &in, float) nodiscard", asFUNCTION(ClipVelocity), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t SlideClipVelocity(const vec3_t &in, const vec3_t &in, float) nodiscard", asFUNCTION(SlideClipVelocity), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("float vectoyaw(const vec3_t &in) nodiscard", asFUNCTION(vectoyaw), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t vectoangles(const vec3_t &in) nodiscard", asFUNCTION(vectoangles), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t G_ProjectSource(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(G_ProjectSource), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t G_ProjectSource2(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(G_ProjectSource2), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t slerp(const vec3_t &in, const vec3_t &in, float) nodiscard", asFUNCTION(slerp), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("vec3_t lerp(vec3_t, vec3_t, float) nodiscard", asFUNCTIONPR(lerp, (vec3_t, vec3_t, float), vec3_t), asCALL_CDECL);

#undef Q2AS_OBJECT

	return true;
}