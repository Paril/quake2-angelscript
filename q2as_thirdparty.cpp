#include "q2as_local.h"

#include "thirdparty/scriptstdstring/scriptstdstring.h"
#include "thirdparty/scriptany/scriptany.h"
#include "thirdparty/scriptarray/scriptarray.h"
#include "thirdparty/scriptdictionary/scriptdictionary.h"
#include "thirdparty/datetime/datetime.h"
#include "thirdparty/weakref/weakref.h"
#include "thirdparty/scripthelper/scripthelper.h"

void Q2AS_RegisterThirdParty(q2as_registry &registry)
{
	RegisterStdString(registry.engine);
	RegisterScriptArray(registry.engine, true);

	RegisterScriptAny(registry.engine);
	RegisterScriptDictionary(registry.engine);

	RegisterStdStringUtils(registry.engine);

	RegisterScriptDateTime(registry.engine);
	RegisterScriptWeakRef(registry.engine);

    RegisterExceptionRoutines(registry.engine);
}