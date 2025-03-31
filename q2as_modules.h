#pragma once

#include "angelscript.h"

// Since these modules aren't exactly standalone,
// this is the file that you need to look at
// for modules.

// registers third party stuff; StdString, ScriptArray,
// ScriptAny, ScriptDictionary, StdStringUtils, ScriptDateTime,
// WeakRef
// requires:
void Q2AS_RegisterThirdParty(q2as_registry &registry);

// registers T_limits namespaces.
// requires:
void Q2AS_RegisterLimits(q2as_registry &registry);

// registers C stdlib math functions, game-specific
// math functions (angle stuff) and constants (pi, etc)
// requires:
void Q2AS_RegisterMath(q2as_registry &registry);

// registers vec3_t and related functions
// requires:
void Q2AS_RegisterVec3(q2as_registry &registry);

// registers dynamic_bitset and related functions
// requires: 
void Q2AS_RegisterDynamicBitset(q2as_registry& registry);

// gtime_t type
// requires:
void Q2AS_RegisterTime(q2as_registry &registry);

// random library
// requires: Time
void Q2AS_RegisterRandom(q2as_registry &registry);

// extensions to string
// requires: ThirdParty
void Q2AS_RegisterStringEx(q2as_registry &registry);

// cvar_t and related
// requires: ThirdParty
void Q2AS_RegisterCvar(q2as_registry &registry);

// debugging features
// requires: ThirdParty
void Q2AS_RegisterDebugging(q2as_registry &registry);

// reflection
// requires: ThirdParty
void Q2AS_RegisterReflection(q2as_registry &registry);

// string hash set
// requires: ThirdParty
void Q2AS_RegisterStringHashSet(q2as_registry &registry);

// registers player_state_t and dependents
// requires: ThirdParty, Vec3
void Q2AS_RegisterPlayerState(q2as_registry &registry);

// registers pmove_t and dependents
// requires: ThirdParty, Vec3, and a handle type for `edict_t`
void Q2AS_RegisterPmove(q2as_registry &registry);

// registers trace_t
// requires: Vec3, Pmove, PlayerState, and a handle type for `edict_t`
void Q2AS_RegisterTrace(q2as_registry &registry);

// registers some both-game import types.
// requires:
void Q2AS_RegisterImportTypes(q2as_registry &registry);

// registers JSON stuff.
// requires: String
// only supports game DLL atm.
void Q2AS_RegisterJson(q2as_registry &registry);

// registers some utility types.
// requires: Vec3
void Q2AS_RegisterUtil(q2as_registry &registry);

// registers tokenizer
// requires: ThirdParty
void Q2AS_RegisterTokenizer(q2as_registry &registry);