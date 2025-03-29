#include "q2as_local.h"
#include "q2as_fixedarray.h"
#include "bg_local.h"

static void Q2AS_rgba_t_init_construct_u8u8u8u8(const byte r, const byte g, const byte b, const byte a, rgba_t *v)
{
	v->r = r;
	v->g = g;
	v->b = b;
	v->a = a;
}

static void Q2AS_vec2_t_init_construct_ff(const float x, const float y, vec2_t *v)
{
	v->x = x;
	v->y = y;
}

struct vec4_t
{
	float x, y, z, w;
};

static void Q2AS_vec4_t_init_construct_ffff(const float x, const float y, const float z, const float w, vec4_t *v)
{
	v->x = x;
	v->y = y;
	v->z = z;
	v->w = w;
}

static void q2as_AddBlend(float r, float g, float b, float a, const vec4_t &src, std::array<float, 4> &dst)
{
    dst = { src.x, src.y, src.z, src.w };
    G_AddBlend(r, g, b, a, dst);
}

// utility types (rgba_t, vec2_t, vec4_t)
void Q2AS_RegisterUtil(q2as_registry &registry)
{
	Q2AS_RegisterFixedArray<uint8_t, 4>(registry, "rgba_t", "uint8", asOBJ_APP_CLASS_ALLINTS);

	registry
		.for_type("rgba_t")
		.properties({
			{ "uint8 r", asOFFSET(rgba_t, r) },
			{ "uint8 g", asOFFSET(rgba_t, g) },
			{ "uint8 b", asOFFSET(rgba_t, b) },
			{ "uint8 a", asOFFSET(rgba_t, a) },
		})
		.behaviors({
			{ asBEHAVE_CONSTRUCT, "void f(uint8, uint8, uint8, uint8)", asFUNCTION(Q2AS_rgba_t_init_construct_u8u8u8u8), asCALL_CDECL_OBJLAST }
		});

	Q2AS_RegisterFixedArray<float, 2>(registry, "vec2_t", "float", asOBJ_APP_CLASS_ALLFLOATS);

	registry
		.for_type("vec2_t")
		.properties({
			{ "float x", asOFFSET(vec2_t, x) },
			{ "float y", asOFFSET(vec2_t, y) }
		})
		.behaviors({
			{ asBEHAVE_CONSTRUCT, "void f(float, float)", asFUNCTION(Q2AS_vec2_t_init_construct_ff), asCALL_CDECL_OBJLAST }
		});

	Q2AS_RegisterFixedArray<float, 4>(registry, "vec4_t", "float", asOBJ_APP_CLASS_ALLFLOATS);

	registry
		.for_type("vec4_t")
		.properties({
			{ "float x", asOFFSET(vec4_t, x) },
			{ "float y", asOFFSET(vec4_t, y) },
			{ "float z", asOFFSET(vec4_t, z) },
			{ "float w", asOFFSET(vec4_t, w) }
		})
		.behaviors({
			{ asBEHAVE_CONSTRUCT, "void f(float, float, float, float)", asFUNCTION(Q2AS_vec4_t_init_construct_ffff), asCALL_CDECL_OBJLAST }
		})
		.methods({
			{ "bool opEquals(const vec4_t &in) const", asFUNCTION(Q2AS_type_equals<vec4_t>), asCALL_CDECL_OBJLAST }
		});

	Q2AS_RegisterFixedArray<vec3_t, 3>(registry, "mat3_t", "vec3_t", asOBJ_APP_CLASS_ALLFLOATS);

	registry
		.for_global()
		.functions({
			{ "void G_AddBlend(float r, float g, float b, float a, const vec4_t &in, vec4_t &out)", asFUNCTION(q2as_AddBlend), asCALL_CDECL }
		});
}