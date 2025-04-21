#include "q2as_local.h"
#include <unordered_set>

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

void Q2AS_RegisterStringHashSet(q2as_registry &registry)
{
    registry
        .type("string_hashset", sizeof(StringHashSet), asOBJ_VALUE | asGetTypeTraits<StringHashSet>())
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(ConstructStringHashSet), asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()", asFUNCTION(DestructStringHashSet),  asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "bool empty() const", asFUNCTION(EmptyStringHashSet), asCALL_CDECL_OBJLAST },
            { "void clear()",       asFUNCTION(ClearStringHashSet), asCALL_CDECL_OBJLAST },

            { "bool contains(const string &in) const", asFUNCTION(ContainsStringHashSet), asCALL_CDECL_OBJLAST },
            { "void add(const string &in)",            asFUNCTION(AddStringHashSet),	  asCALL_CDECL_OBJLAST },
            { "void remove(const string &in)",         asFUNCTION(AddStringHashSet),	  asCALL_CDECL_OBJLAST }
        });
}