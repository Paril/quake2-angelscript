#include "q2as_local.h"
#include "q2as_dynamic_bitset.h"

static void Q2AS_bitset_construct(uint32_t count, dynamic_bitset *self)
{
    new(self) dynamic_bitset(count);
}

static void Q2AS_bitset_construct_str(const std::string &str, dynamic_bitset *self)
{
    new(self) dynamic_bitset(str);
}

void Q2AS_RegisterDynamicBitset(q2as_registry &registry)
{
    registry
        .type("dynamic_bitset", sizeof(dynamic_bitset), asOBJ_VALUE | asOBJ_APP_CLASS_CDK)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",						   asFUNCTION(Q2AS_init_construct<dynamic_bitset>),		 asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const dynamic_bitset &in)",  asFUNCTION(Q2AS_init_construct_copy<dynamic_bitset>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const string &in) explicit", asFUNCTION(Q2AS_bitset_construct_str),                    asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()",						   asFUNCTION(Q2AS_destruct<dynamic_bitset>),			 asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(uint count) explicit",       asFUNCTION(Q2AS_bitset_construct),                asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "dynamic_bitset &opAssign(const dynamic_bitset &in)", asMETHODPR(dynamic_bitset, operator=, (const dynamic_bitset &), dynamic_bitset &), asCALL_THISCALL },

            { "bool opIndex(uint) const", asMETHODPR(dynamic_bitset, operator[], (unsigned int) const, bool), asCALL_THISCALL },
            { "bool get_bit(uint) const", asMETHODPR(dynamic_bitset, get_bit, (unsigned int) const, bool),    asCALL_THISCALL },
            { "void set_bit(uint, bool)", asMETHODPR(dynamic_bitset, set_bit, (unsigned int, bool), void),    asCALL_THISCALL },

            { "void clear()",                   asMETHODPR(dynamic_bitset, clear, (), void),              asCALL_THISCALL },
            { "void resize(uint)",              asMETHODPR(dynamic_bitset, resize, (unsigned int), void), asCALL_THISCALL },
            { "uint get_size() const property", asMETHODPR(dynamic_bitset, size, () const, unsigned int), asCALL_THISCALL },

            { "void set_all(bool value)", asMETHODPR(dynamic_bitset, set_all, (bool), void), asCALL_THISCALL },
            { "void flip_all()",          asMETHODPR(dynamic_bitset, flip_all, (), void),    asCALL_THISCALL },

            { "bool any() const",  asMETHODPR(dynamic_bitset, any, () const, bool),  asCALL_THISCALL },
            { "bool all() const",  asMETHODPR(dynamic_bitset, all, () const, bool),  asCALL_THISCALL },
            { "bool none() const", asMETHODPR(dynamic_bitset, none, () const, bool), asCALL_THISCALL },
            
            { "bool opEquals(const dynamic_bitset &in) const", asMETHODPR(dynamic_bitset, operator==, (const dynamic_bitset &) const, bool), asCALL_THISCALL },

            { "string to_string() const", asMETHOD(dynamic_bitset, to_string), asCALL_THISCALL },
            
            { "uint opForBegin() const",     asMETHOD(dynamic_bitset, opForBegin), asCALL_THISCALL },
            { "uint opForNext(uint) const",  asMETHOD(dynamic_bitset, opForNext),  asCALL_THISCALL },
            { "bool opForValue(uint) const", asMETHOD(dynamic_bitset, opForValue), asCALL_THISCALL },
            { "bool opForEnd(uint) const",   asMETHOD(dynamic_bitset, opForEnd),   asCALL_THISCALL },
        });
}