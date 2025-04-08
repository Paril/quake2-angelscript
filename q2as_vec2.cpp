#include "q2as_local.h"
#include "q2as_fixedarray.h"
#include "q2as_vec2.h"

static void vec2_formatter(std::string &str, const std::string &args, const vec2 &in)
{
    fmt::format_to(std::back_inserter(str), "{} {}", in.x, in.y);
}

void Q2AS_RegisterVec2(q2as_registry &registry)
{
	Q2AS_RegisterFixedArray<float, 2>(registry, "vec2_t", "float", asOBJ_APP_CLASS_ALLFLOATS);

    registry
        .for_type("vec2_t")
		.properties({
			{ "float x", asOFFSET(vec2, x) },
			{ "float y", asOFFSET(vec2, y) },
		})
		.methods({
			// equality
			{ "bool opEquals(const vec2_t &in) const",             asMETHODPR(vec2, operator==, (const vec2 &) const, bool),                                                              asCALL_THISCALL },
			{ "bool equals(const vec2_t &in, float) const",        asMETHODPR(vec2, equals, (const vec2 &v, const float relative_tolerance) const, bool),                                 asCALL_THISCALL },
			{ "bool equals(const vec2_t &in, float, float) const", asMETHODPR(vec2, equals, (const vec2 &v, const float relative_tolerance, const float absolute_tolerance) const, bool), asCALL_THISCALL },

			// conversions
			{ "bool opConv() const", asMETHODPR(vec2, operator bool, () const, bool), asCALL_THISCALL },

			// basic methods
			{ "float dot(const vec2_t &in) const",     asMETHODPR(vec2, dot, (const vec2 &) const, float),   asCALL_THISCALL },
			{ "vec2_t scaled(const vec2_t &in) const", asMETHODPR(vec2, scaled, (const vec2 &) const, vec2), asCALL_THISCALL },
			{ "vec2_t &scale(const vec2_t &in)",       asMETHODPR(vec2, scale, (const vec2 &), vec2 &),      asCALL_THISCALL },

			// operators
			{ "vec2_t opSub(const vec2_t &in) const", asMETHODPR(vec2, operator-, (const vec2 &v) const, vec2),  asCALL_THISCALL },
			{ "vec2_t opAdd(const vec2_t &in) const", asMETHODPR(vec2, operator+, (const vec2 &v) const, vec2),  asCALL_THISCALL },
			{ "vec2_t opDiv(const vec2_t &in) const", asMETHODPR(vec2, operator/, (const vec2 &v) const, vec2),  asCALL_THISCALL },
			{ "vec2_t opDiv(const float &in) const",  asMETHODPR(vec2, operator/, (const float &v) const, vec2), asCALL_THISCALL },
			{ "vec2_t opDiv(const int &in) const",    asMETHODPR(vec2, operator/, (const int &v) const, vec2),   asCALL_THISCALL },
			{ "vec2_t opMul(const float &in) const",  asMETHODPR(vec2, operator*, (const float &v) const, vec2), asCALL_THISCALL },
			{ "vec2_t opMul(const int &in) const",    asMETHODPR(vec2, operator*, (const int &v) const, vec2),   asCALL_THISCALL },
			{ "vec2_t opNeg() const",                 asMETHODPR(vec2, operator-, () const, vec2),               asCALL_THISCALL },

			{ "vec2_t &opSubAssign(const vec2_t &in)", asMETHODPR(vec2, operator-=, (const vec2 &v), vec2 &),  asCALL_THISCALL },
			{ "vec2_t &opAddAssign(const vec2_t &in)", asMETHODPR(vec2, operator+=, (const vec2 &v), vec2 &),  asCALL_THISCALL },
			{ "vec2_t &opDivAssign(const vec2_t &in)", asMETHODPR(vec2, operator/=, (const vec2 &v), vec2 &),  asCALL_THISCALL },
			{ "vec2_t &opDivAssign(const float &in)",  asMETHODPR(vec2, operator/=, (const float &v), vec2 &), asCALL_THISCALL },
			{ "vec2_t &opDivAssign(const int &in)",    asMETHODPR(vec2, operator/=, (const int &v), vec2 &),   asCALL_THISCALL },
			{ "vec2_t &opMulAssign(const float &in)",  asMETHODPR(vec2, operator*=, (const float &v), vec2 &), asCALL_THISCALL },
			{ "vec2_t &opMulAssign(const int &in)",    asMETHODPR(vec2, operator*=, (const int &v), vec2 &),   asCALL_THISCALL },

			// useful methods
			{ "float lengthSquared() const",					asMETHODPR(vec2, lengthSquared, () const, float),    asCALL_THISCALL },
			{ "float length() const",							asMETHODPR(vec2, length, () const, float),           asCALL_THISCALL },
			{ "float distanceSquared(const vec2_t &in) const",	asMETHODPR(vec2, distanceSquared, (const vec2 &v) const, float),    asCALL_THISCALL },
			{ "float distance(const vec2_t &in) const",			asMETHODPR(vec2, distance, (const vec2 &v) const, float),           asCALL_THISCALL },
			{ "vec2_t normalized() const",						asMETHODPR(vec2, normalized, () const, vec2),        asCALL_THISCALL },
			{ "vec2_t normalized(float &out) const",			asMETHODPR(vec2, normalized, (float &) const, vec2), asCALL_THISCALL },
			{ "float normalize()",								asMETHODPR(vec2, normalize, (), float),              asCALL_THISCALL }
		});

    registry
        .for_global()
        .functions({
            { "void formatter(string &str, const string &in args, const vec2_t &in vec)",                                                    asFUNCTION(vec2_formatter),                                                       asCALL_CDECL }
        });
}