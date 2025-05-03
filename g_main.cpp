// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "g_local.h"
#include "q2as_main.h"
#include "q2as_random.h"

mum_prng_generator mum_prng;

local_game_import_t gi;

game_export_t globals;

#ifdef Q2AS_DLL_FALLBACK
#include "q2as_platform.h"
#endif

/*
=================
GetGameAPI

Returns a pointer to the structure with all entry points
and global variables
=================
*/
Q2GAME_API game_export_t *GetGameAPI(game_import_t *import)
{
    gi = *import;

    globals.apiversion = GAME_API_VERSION;

    // see if Q2AS needs to be initialized
    if (auto api = Q2AS_GetGameAPI())
    {
        return api;
    }
    
#ifdef Q2AS_DLL_FALLBACK
    import->Com_Print("Failed to load AngelScript game API\n");

    // Fall back to loading baseq2 game api.
    GetGameAPIEXTERNAL external_game_api = Q2AS_GetGameAPI(import);
    return external_game_api(import);
#else
    import->Com_Error("Failed to load AngelScript game API\n");
#endif
}
