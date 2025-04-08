// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "q2as_cgame.h"
#include "q2as_main.h"
#include "q2as_platform.h"

cgame_import_t cgi;
cgame_export_t cglobals;

typedef cgame_export_t *(*GetCGameAPIEXTERNAL)(cgame_import_t *);

/*
=================
GetCGameAPI

Returns a pointer to the structure with all entry points
and global variables
=================
*/
Q2GAME_API cgame_export_t *GetCGameAPI(cgame_import_t *import)
{
    cgi = *import;

    cglobals.apiversion = CGAME_API_VERSION;

    // see if Q2AS needs to be initialized
    if (auto api = Q2AS_GetCGameAPI())
    {
        return api;
    }

    import->Com_Error("Failed to load AngelScript CGame API\n");

    // Fall back to loading baseq2 cgame api.
    GetCGameAPIEXTERNAL external_cgame_api = Q2AS_GetCGameAPI(import);
    return external_cgame_api(import);
}
