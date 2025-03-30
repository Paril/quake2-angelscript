#include "q2as_local.h"

void Q2AS_RegisterDynamicBitset(q2as_registry& registry)
{
	registry
		.type("dynamic_bitset", sizeof(dynamic_bitset), asOBJ_VALUE)
		.methods({
			// Index
			{ "bool opIndex(uint)", asMETHODPR(dynamic_bitset, operator[], (unsigned int) const, bool), asCALL_THISCALL },
			{ "bool get_bit(uint)", asMETHODPR(dynamic_bitset, get_bit, (unsigned int) const, bool), asCALL_THISCALL },
			{ "void set_bit(uint, bool)", asMETHODPR(dynamic_bitset, set_bit, (unsigned int, bool), void), asCALL_THISCALL },

			{ "void clear()", asMETHODPR(dynamic_bitset, clear, (), void), asCALL_THISCALL },
			{ "void resize(uint)", asMETHODPR(dynamic_bitset, resize, (unsigned int), void), asCALL_THISCALL },
			{ "uint size()", asMETHODPR(dynamic_bitset, size, () const, unsigned int), asCALL_THISCALL },

			{ "void set_all()", asMETHODPR(dynamic_bitset, set_all, (bool), void), asCALL_THISCALL },
			{ "void flip_all()", asMETHODPR(dynamic_bitset, flip_all, (), void), asCALL_THISCALL },


			{ "bool any()", asMETHODPR(dynamic_bitset, any, () const, bool), asCALL_THISCALL },
			{ "bool all()", asMETHODPR(dynamic_bitset, all, () const, bool), asCALL_THISCALL },
			{ "bool none()", asMETHODPR(dynamic_bitset, none, () const, bool), asCALL_THISCALL },

			{ "bool opEquals(const dynamic_bitset &in)", asMETHODPR(dynamic_bitset, operator==, (const dynamic_bitset &), bool), asCALL_THISCALL },
		});
}