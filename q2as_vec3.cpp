#include "q2as_local.h"

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

void Q2AS_RegisterVec3(q2as_registry &registry)
{
	registry
		.type("vec3_t", sizeof(vec3_t), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_CAK)
		.properties({
			{ "float x", asOFFSET(vec3_t, x) },
			{ "float y", asOFFSET(vec3_t, y) },
			{ "float z", asOFFSET(vec3_t, z) },

			{ "float pitch", asOFFSET(vec3_t, x) },
			{ "float yaw", asOFFSET(vec3_t, y) },
			{ "float roll", asOFFSET(vec3_t, z) }
		})
		.behaviors({
			{ asBEHAVE_CONSTRUCT,      "void vec3_t(float, float, float)",           asFUNCTION(Q2AS_vec3_t_init_construct_fff), asCALL_CDECL_OBJLAST },
			{ asBEHAVE_CONSTRUCT,      "void vec3_t(const vec3_t &in)",              asFUNCTION(Q2AS_vec3_t_list_copy),          asCALL_CDECL_OBJLAST },
			{ asBEHAVE_LIST_CONSTRUCT, "void vec3_t(int &in) {float, float, float}", asFUNCTION(Q2AS_vec3_t_list_construct),     asCALL_CDECL_OBJLAST }
		})
		.methods({
			// indexing
			{ "float &opIndex(uint)",             asMETHODPR(vec3_t, operator[], (int), float &),             asCALL_THISCALL },
			{ "const float &opIndex(uint) const", asMETHODPR(vec3_t, operator[], (int) const, const float &), asCALL_THISCALL },

			// equality
			{ "bool opEquals(const vec3_t &in) const",                asMETHODPR(vec3_t, operator==, (const vec3_t &) const, bool),                    asCALL_THISCALL },
			{ "bool equals(const vec3_t &in, const float &in) const", asMETHODPR(vec3_t, equals, (const vec3_t &v, const float &epsilon) const, bool), asCALL_THISCALL },

			// conversions
			{ "bool opImplConv() const", asMETHODPR(vec3_t, operator bool, () const, bool), asCALL_THISCALL },

			// basic methods
			{ "float dot(const vec3_t &in) const",     asMETHODPR(vec3_t, dot, (const vec3_t &) const, float),     asCALL_THISCALL },
			{ "vec3_t scaled(const vec3_t &in) const", asMETHODPR(vec3_t, scaled, (const vec3_t &) const, vec3_t), asCALL_THISCALL },
			{ "vec3_t &scale(const vec3_t &in)",       asMETHODPR(vec3_t, scale, (const vec3_t &), vec3_t &),      asCALL_THISCALL },

			// operators
			{ "vec3_t opSub(const vec3_t &in) const", asMETHODPR(vec3_t, operator-, (const vec3_t &v) const, vec3_t), asCALL_THISCALL },
			{ "vec3_t opAdd(const vec3_t &in) const", asMETHODPR(vec3_t, operator+, (const vec3_t &v) const, vec3_t), asCALL_THISCALL },
			{ "vec3_t opDiv(const vec3_t &in) const", asMETHODPR(vec3_t, operator/, (const vec3_t &v) const, vec3_t), asCALL_THISCALL },
			{ "vec3_t opDiv(const float &in) const",  asMETHODPR(vec3_t, operator/, (const float &v) const, vec3_t),  asCALL_THISCALL },
			{ "vec3_t opDiv(const int &in) const",    asMETHODPR(vec3_t, operator/, (const int &v) const, vec3_t),    asCALL_THISCALL },
			{ "vec3_t opMul(const float &in) const",  asMETHODPR(vec3_t, operator*, (const float &v) const, vec3_t),  asCALL_THISCALL },
			{ "vec3_t opMul(const int &in) const",    asMETHODPR(vec3_t, operator*, (const int &v) const, vec3_t),    asCALL_THISCALL },
			{ "vec3_t opNeg() const",                 asMETHODPR(vec3_t, operator-, () const, vec3_t),                asCALL_THISCALL },

			{ "vec3_t &opSubAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator-=, (const vec3_t &v), vec3_t &), asCALL_THISCALL },
			{ "vec3_t &opAddAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator+=, (const vec3_t &v), vec3_t &), asCALL_THISCALL },
			{ "vec3_t &opDivAssign(const vec3_t &in)", asMETHODPR(vec3_t, operator/=, (const vec3_t &v), vec3_t &), asCALL_THISCALL },
			{ "vec3_t &opDivAssign(const float &in)",  asMETHODPR(vec3_t, operator/=, (const float &v), vec3_t &),  asCALL_THISCALL },
			{ "vec3_t &opDivAssign(const int &in)",    asMETHODPR(vec3_t, operator/=, (const int &v), vec3_t &),    asCALL_THISCALL },
			{ "vec3_t &opMulAssign(const float &in)",  asMETHODPR(vec3_t, operator*=, (const float &v), vec3_t &),  asCALL_THISCALL },
			{ "vec3_t &opMulAssign(const int &in)",    asMETHODPR(vec3_t, operator*=, (const int &v), vec3_t &),    asCALL_THISCALL },

			// useful methods
			{ "float lengthSquared() const",          asMETHODPR(vec3_t, lengthSquared, () const, float),        asCALL_THISCALL },
			{ "float length() const",                 asMETHODPR(vec3_t, length, () const, float),               asCALL_THISCALL },
			{ "vec3_t normalized() const",            asMETHODPR(vec3_t, normalized, () const, vec3_t),          asCALL_THISCALL },
			{ "vec3_t normalized(float &out) const",  asMETHODPR(vec3_t, normalized, (float &) const, vec3_t),   asCALL_THISCALL },
			{ "float normalize()",                    asMETHODPR(vec3_t, normalize, (), float ),                 asCALL_THISCALL },
			{ "vec3_t cross(const vec3_t &in) const", asMETHODPR(vec3_t, cross, (const vec3_t &) const, vec3_t), asCALL_THISCALL }
		});

	registry
		.for_global()
		.properties({
			{ "const vec3_t vec3_origin", &vec3_origin }
		})
		.functions({
			{ "void AngleVectors(const vec3_t &in, vec3_t &out forward = void, vec3_t &out right = void, vec3_t &out up = void)",            asFUNCTIONPR(AngleVectors, (const vec3_t &, vec3_t &, vec3_t &, vec3_t &), void), asCALL_CDECL },
			{ "vec3_t ProjectPointOnPlane(const vec3_t &in, const vec3_t &in) nodiscard",                                                    asFUNCTION(ProjectPointOnPlane),                                                  asCALL_CDECL },
			{ "vec3_t PerpendicularVector(const vec3_t &in) nodiscard",                                                                      asFUNCTION(PerpendicularVector),                                                  asCALL_CDECL },
			{ "vec3_t RotatePointAroundVector(const vec3_t &in, const vec3_t &in, float) nodiscard",                                         asFUNCTION(RotatePointAroundVector),                                              asCALL_CDECL },
			{ "bool boxes_intersect(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard",                      asFUNCTION(boxes_intersect),                                                      asCALL_CDECL },
			{ "float distance_between_boxes(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard",              asFUNCTION(distance_between_boxes),                                               asCALL_CDECL },
			{ "vec3_t closest_point_to_box(const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard",                                 asFUNCTION(closest_point_to_box),                                                 asCALL_CDECL },
			{ "vec3_t ClipVelocity(const vec3_t &in, const vec3_t &in, float) nodiscard",                                                    asFUNCTION(ClipVelocity),                                                         asCALL_CDECL },
			{ "vec3_t SlideClipVelocity(const vec3_t &in, const vec3_t &in, float) nodiscard",                                               asFUNCTION(SlideClipVelocity),                                                    asCALL_CDECL },
			{ "float vectoyaw(const vec3_t &in) nodiscard",                                                                                  asFUNCTION(vectoyaw),                                                             asCALL_CDECL },
			{ "vec3_t vectoangles(const vec3_t &in) nodiscard",                                                                              asFUNCTION(vectoangles),                                                          asCALL_CDECL },
			{ "vec3_t G_ProjectSource(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard",                    asFUNCTION(G_ProjectSource),                                                      asCALL_CDECL },
			{ "vec3_t G_ProjectSource2(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in) nodiscard", asFUNCTION(G_ProjectSource2),                                                     asCALL_CDECL },
			{ "vec3_t slerp(const vec3_t &in, const vec3_t &in, float) nodiscard",                                                           asFUNCTION(slerp),                                                                asCALL_CDECL },
			{ "vec3_t lerp(vec3_t, vec3_t, float) nodiscard",                                                                                asFUNCTIONPR(lerp, (vec3_t, vec3_t, float), vec3_t),                              asCALL_CDECL }
		});
}