#include "q2as_local.h"
#include "q2as_reg.h"
#include <unordered_set>

using StringHashSet = std::unordered_set<std::string>;

static void ConstructStringHashSet(StringHashSet *s)
{
	new(s) StringHashSet;
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

bool Q2AS_RegisterStringHashSet(asIScriptEngine *engine)
{
	const char *name = "string_hashset";

	Ensure(engine->RegisterObjectType(name, sizeof(StringHashSet), asOBJ_VALUE | asGetTypeTraits<StringHashSet>()));

	Ensure(engine->RegisterObjectBehaviour(name, asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(ConstructStringHashSet), asCALL_CDECL_OBJLAST));
	Ensure(engine->RegisterObjectBehaviour(name, asBEHAVE_DESTRUCT,  "void f()", asFUNCTION(DestructStringHashSet),  asCALL_CDECL_OBJLAST));
	
	Ensure(engine->RegisterObjectMethod(name,  "bool empty() const", asFUNCTION(EmptyStringHashSet),  asCALL_CDECL_OBJLAST));
	Ensure(engine->RegisterObjectMethod(name,  "void clear()",       asFUNCTION(ClearStringHashSet),  asCALL_CDECL_OBJLAST));
	
	Ensure(engine->RegisterObjectMethod(name,  "bool contains(const string &in) const", asFUNCTION(ContainsStringHashSet),  asCALL_CDECL_OBJLAST));
	Ensure(engine->RegisterObjectMethod(name,  "void add(const string &in)",            asFUNCTION(AddStringHashSet),  asCALL_CDECL_OBJLAST));
	Ensure(engine->RegisterObjectMethod(name,  "void remove(const string &in)",         asFUNCTION(AddStringHashSet),  asCALL_CDECL_OBJLAST));

	return true;
}