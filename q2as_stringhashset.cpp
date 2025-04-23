#include "q2as_local.h"
#include <unordered_set>

/*
 * NOTE: this is kind of a temporary type, but it's just because
 * a string set is kind of a necessary type and other set types aren't.
 * Eventually I'd like to add more generic set types.
 */

using StringHashSet = std::unordered_set<std::string>;

static void ConstructStringHashSet(StringHashSet *s)
{
    new (s) StringHashSet;
}

static void DestructStringHashSet(StringHashSet *s)
{
    s->~StringHashSet();
}

static void ClearStringHashSet(StringHashSet *s)
{
    s->clear();
}

static uint32_t SizeStringHashSet(StringHashSet *s)
{
    return s->size();
}

static bool EmptyStringHashSet(StringHashSet *s)
{
    return s->empty();
}

static bool ContainsStringHashSet(const std::string &str, StringHashSet *s)
{
    return s->find(str) != s->end();
}

static void AddStringHashSet(const std::string &str, StringHashSet *s)
{
    s->insert(str);
}

static void RemoveStringHashSet(const std::string &str, StringHashSet *s)
{
    s->erase(str);
}

static uint32_t StringHashOpForBegin(StringHashSet *s)
{
    return 0;
}

static bool StringHashOpForEnd(uint32_t v, StringHashSet *s)
{
    return v >= s->size();
}

static uint32_t StringHashOpForNext(uint32_t v, StringHashSet *s)
{
    return v + 1;
}

static const std::string &StringHashOpForValue(uint32_t v, StringHashSet *s)
{
    auto it = s->begin();
    std::advance(it, v);
    return *it;
}

void Q2AS_RegisterStringHashSet(q2as_registry &registry)
{
    registry
        .type("string_hashset", sizeof(StringHashSet), asOBJ_VALUE | asGetTypeTraits<StringHashSet>())
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(ConstructStringHashSet), asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()", asFUNCTION(DestructStringHashSet),  asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "uint size() const",  asFUNCTION(SizeStringHashSet),  asCALL_CDECL_OBJLAST },
            { "bool empty() const", asFUNCTION(EmptyStringHashSet), asCALL_CDECL_OBJLAST },
            { "void clear()",       asFUNCTION(ClearStringHashSet), asCALL_CDECL_OBJLAST },

            { "bool contains(const string &in) const", asFUNCTION(ContainsStringHashSet), asCALL_CDECL_OBJLAST },
            { "void add(const string &in)",            asFUNCTION(AddStringHashSet),	  asCALL_CDECL_OBJLAST },
            { "void remove(const string &in)",         asFUNCTION(AddStringHashSet),	  asCALL_CDECL_OBJLAST },

            { "uint opForBegin() const",              asFUNCTION(StringHashOpForBegin), asCALL_CDECL_OBJLAST },
            { "bool opForEnd(uint) const",            asFUNCTION(StringHashOpForEnd),   asCALL_CDECL_OBJLAST },
            { "uint opForNext(uint) const",           asFUNCTION(StringHashOpForNext),  asCALL_CDECL_OBJLAST },
            { "const string &opForValue(uint) const", asFUNCTION(StringHashOpForValue), asCALL_CDECL_OBJLAST }
        });
}