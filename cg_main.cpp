// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "cg_local.h"
#include "as/q2as_main.h"

cgame_import_t cgi;
cgame_export_t cglobals;

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

	return NULL;
}
