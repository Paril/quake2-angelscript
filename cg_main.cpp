// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "cg_local.h"
#include "q2as_main.h"
#include <Windows.h>
#include <filesystem>

cgame_import_t cgi;
cgame_export_t cglobals;

typedef cgame_export_t* (*GetCGameAPIEXTERNAL)(cgame_import_t*);

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
	/*if (auto api = Q2AS_GetCGameAPI())
	{
		return api;
	}*/

	//import->Com_Error("Failed to load AngelScript CGame API\n");


	{
		const char* directory_name = "baseq2";
		const char* game_name = "game_x64.dll";
		HINSTANCE game_library;

		auto path = (std::filesystem::current_path() / directory_name / game_name).string().c_str();
		game_library = LoadLibrary(path);
		if (game_library)
		{
			GetCGameAPIEXTERNAL external_cgame_api = NULL;
			external_cgame_api = (GetCGameAPIEXTERNAL)GetProcAddress(game_library, "GetGameAPI");
			if (!external_cgame_api)
			{
				import->Com_Error("Failed to load GetCGameAPIP\n");
			}

			return external_cgame_api(import);
		}
		else
		{
			import->Com_Error("Failed to load baseq2 game API\n");
		}
	}

	return NULL;
}
