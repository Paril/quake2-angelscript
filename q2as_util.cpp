#include "q2as_local.h"
#include "q2as_fixedarray.h"

struct vec4_t
{
    float x, y, z, w;
};

static void q2as_AddBlend(const vec4_t &color, vec4_t &v)
{
    float a_blend = v.w;
    float a_prime = a_blend + (1.0f - a_blend) * color.w;
    float f = 0.0f;
    if (a_blend > 0.0f)
    {
        f = a_blend / a_prime;
    }

    v.x = v.x * f + color.x * (1.0f - f);
    v.y = v.y * f + color.y * (1.0f - f);
    v.z = v.z * f + color.z * (1.0f - f);
    v.w = a_prime;
}

static bool q2as_vec4_empty(const vec4_t &v)
{
    return v.x || v.y || v.z || v.w;
}

static vec3_t &q2as_vec4_vec3(const vec4_t &v)
{
    return (vec3_t &) v;
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
        });

    Q2AS_RegisterFixedArray<float, 4>(registry, "vec4_t", "float", asOBJ_APP_CLASS_ALLFLOATS);

    registry
        .for_type("vec4_t")
        .properties({
            { "float x", asOFFSET(vec4_t, x) },
            { "float y", asOFFSET(vec4_t, y) },
            { "float z", asOFFSET(vec4_t, z) },
            { "float w", asOFFSET(vec4_t, w) },

            { "float r", asOFFSET(vec4_t, x) },
            { "float g", asOFFSET(vec4_t, y) },
            { "float b", asOFFSET(vec4_t, z) },
            { "float a", asOFFSET(vec4_t, w) }
        })
        .methods({
            { "bool opEquals(const vec4_t &in) const", asFUNCTION(Q2AS_type_equals<vec4_t>), asCALL_CDECL_OBJLAST },
            { "void accum_blend(const vec4_t &in color)", asFUNCTION(q2as_AddBlend), asCALL_CDECL_OBJLAST },
            { "bool opConv() const", asFUNCTION(q2as_vec4_empty), asCALL_CDECL_OBJLAST },
            { "vec3_t &xyz()", asFUNCTION(q2as_vec4_vec3), asCALL_CDECL_OBJLAST },
            { "const vec3_t &xyz() const", asFUNCTION(q2as_vec4_vec3), asCALL_CDECL_OBJLAST }
        });

    Q2AS_RegisterFixedArray<vec3_t, 3>(registry, "mat3_t", "vec3_t", asOBJ_APP_CLASS_ALLFLOATS);
}