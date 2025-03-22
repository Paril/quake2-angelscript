// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "g_local.h"
#include "q2as_main.h"

std::mt19937 mt_rand;

local_game_import_t  gi;

/*static*/ char local_game_import_t::print_buffer[0x10000];

/*static*/ std::array<char[MAX_INFO_STRING], MAX_LOCALIZATION_ARGS> local_game_import_t::buffers;
/*static*/ std::array<const char*, MAX_LOCALIZATION_ARGS> local_game_import_t::buffer_ptrs;

game_export_t  globals;

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

	import->Com_Error("Failed to load AngleScript game API\n");

	return NULL;
}

//======================================================================
