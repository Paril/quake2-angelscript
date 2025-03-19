#include "q2as_local.h"
#include "q2as_reg.h"
#include "q2as_fixedarray.h"
#include "../bg_local.h"

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
bool Q2AS_RegisterUtil(asIScriptEngine *engine)
{
#define Q2AS_OBJECT rgba_t

	Ensure(Q2AS_RegisterFixedArray<uint8_t, 4>(engine, "rgba_t", "uint8", asOBJ_APP_CLASS_ALLINTS));

	// props
	EnsureRegisteredProperty("uint8", r);
	EnsureRegisteredProperty("uint8", g);
	EnsureRegisteredProperty("uint8", b);
	EnsureRegisteredProperty("uint8", a);

	// constructors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(uint8, uint8, uint8, uint8)", asFUNCTION(Q2AS_rgba_t_init_construct_u8u8u8u8), asCALL_CDECL_OBJLAST);

#undef Q2AS_OBJECT
	
#define Q2AS_OBJECT vec2_t

	Ensure(Q2AS_RegisterFixedArray<float, 4>(engine, "vec2_t", "float", asOBJ_APP_CLASS_ALLFLOATS));

	// props
	EnsureRegisteredProperty("float", x);
	EnsureRegisteredProperty("float", y);

	// constructors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(float, float)", asFUNCTION(Q2AS_vec2_t_init_construct_ff), asCALL_CDECL_OBJLAST);

#undef Q2AS_OBJECT
	
#define Q2AS_OBJECT vec4_t
	
	Ensure(Q2AS_RegisterFixedArray<float, 4>(engine, "vec4_t", "float", asOBJ_APP_CLASS_ALLFLOATS));

	// props
	EnsureRegisteredProperty("float", x);
	EnsureRegisteredProperty("float", y);
	EnsureRegisteredProperty("float", z);
	EnsureRegisteredProperty("float", w);

	// constructors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(float, float, float, float)", asFUNCTION(Q2AS_vec4_t_init_construct_ffff), asCALL_CDECL_OBJLAST);

    // operators
	EnsureRegisteredMethod("bool opEquals(const vec4_t &in) const", asFUNCTION(Q2AS_type_equals<vec4_t>), asCALL_CDECL_OBJLAST);

    // global functions (color mixing)
    EnsureRegisteredGlobalFunction("void G_AddBlend(float r, float g, float b, float a, const vec4_t &in, vec4_t &out)", asFUNCTION(q2as_AddBlend), asCALL_CDECL);

#undef Q2AS_OBJECT

	Ensure(Q2AS_RegisterFixedArray<vec3_t, 3>(engine, "mat3_t", "vec3_t", asOBJ_APP_CLASS_ALLFLOATS));

	return true;
}