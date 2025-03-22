#pragma once

#include "angelscript.h"

// Since these modules aren't exactly standalone,
// this is the file that you need to look at
// for modules.

// registers third party stuff; StdString, ScriptArray,
// ScriptAny, ScriptDictionary, StdStringUtils, ScriptDateTime,
// WeakRef
// requires:
bool Q2AS_RegisterThirdParty(asIScriptEngine *engine);

// registers T_limits namespaces.
// requires:
bool Q2AS_RegisterLimits(asIScriptEngine *engine);

// registers C stdlib math functions, game-specific
// math functions (angle stuff) and constants (pi, etc)
// requires:
bool Q2AS_RegisterMath(asIScriptEngine *engine);

// registers vec3_t and related functions
// requires:
bool Q2AS_RegisterVec3(asIScriptEngine *engine);

// gtime_t function
// requires:
bool Q2AS_RegisterTime(asIScriptEngine *engine);

// random library
// requires: Time
bool Q2AS_RegisterRandom(asIScriptEngine *engine);

// extensions to string
// requires: ThirdParty
bool Q2AS_RegisterStringEx(asIScriptEngine *engine);

// cvar_t and related
// requires: ThirdParty
bool Q2AS_RegisterCvar(asIScriptEngine *engine);

// debugging features
// requires: ThirdParty
bool Q2AS_RegisterDebugging(asIScriptEngine *engine);

// reflection
// requires: ThirdParty
bool Q2AS_RegisterReflection(asIScriptEngine *engine);

// string hash set
// requires: ThirdParty
bool Q2AS_RegisterStringHashSet(asIScriptEngine *engine);

// registers player_state_t and dependents
// requires: ThirdParty, Vec3
bool Q2AS_RegisterPlayerState(asIScriptEngine *engine);

// registers pmove_t and dependents
// requires: ThirdParty, Vec3, and a handle type for `edict_t`
bool Q2AS_RegisterPmove(asIScriptEngine *engine);

// registers trace_t
// requires: Vec3, Pmove, PlayerState, and a handle type for `edict_t`
bool Q2AS_RegisterTrace(asIScriptEngine *engine);

// registers some both-game import types.
// requires:
bool Q2AS_RegisterImportTypes(asIScriptEngine *engine);

// registers JSON stuff.
// requires: String
// only supports game DLL atm.
bool Q2AS_RegisterJson(asIScriptEngine *engine);

// registers some utility types.
// requires: Vec3
bool Q2AS_RegisterUtil(asIScriptEngine *engine);

// registers tokenizer
// requires: ThirdParty
bool Q2AS_RegisterTokenizer(asIScriptEngine *engine);