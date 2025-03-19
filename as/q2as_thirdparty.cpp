#include "q2as_local.h"

#include "thirdparty/scriptstdstring/scriptstdstring.h"
#include "thirdparty/scriptany/scriptany.h"
#include "thirdparty/scriptarray/scriptarray.h"
#include "thirdparty/scriptdictionary/scriptdictionary.h"
#include "thirdparty/datetime/datetime.h"
#include "thirdparty/weakref/weakref.h"
#include "thirdparty/scripthelper/scripthelper.h"

bool Q2AS_RegisterThirdParty(asIScriptEngine *engine)
{
	RegisterStdString(engine);
	RegisterScriptArray(engine, true);

	RegisterScriptAny(engine);
	RegisterScriptDictionary(engine);

	RegisterStdStringUtils(engine);

	RegisterScriptDateTime(engine);
	RegisterScriptWeakRef(engine);

    RegisterExceptionRoutines(engine);

	return true;
}