#include "q2as_platform.h"
#include <Windows.h>

const char* directory_name = "baseq2";
const char* game_name = "game_x64.dll";

module_path_result_t Q2AS_GetModulePath()
{
	module_path_result_t result = {};
	result.success = false;

	char path[MAX_PATH];
	HMODULE hm = NULL;

	if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
		GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
		(LPCSTR)&Q2AS_GetModulePath, &hm) == 0)
	{
		return result;
	}
	if (GetModuleFileName(hm, path, sizeof(path)) == 0)
	{
		return result;
	}

	result.success = true;
	result.path = std::filesystem::path(path);
	return result;
}

HINSTANCE Q2AS_GetGameAPIFromCurrentDirectory()
{
	auto path = (std::filesystem::current_path() / directory_name / game_name).string();
	return LoadLibrary(path.c_str());
}

HINSTANCE Q2AS_GetGameAPIFromModuleDirectory()
{
	auto module_path_result = Q2AS_GetModulePath();
	if (!module_path_result.success)
	{
		return NULL;
	}

	auto path = (module_path_result.path.parent_path().parent_path() / directory_name / game_name).string();
	return LoadLibrary(path.c_str());
}

HINSTANCE Q2AS_GetGameLibrary(game_import_t* import)
{
	HINSTANCE game_library = Q2AS_GetGameAPIFromCurrentDirectory();
	if (!game_library)
	{
		game_library = Q2AS_GetGameAPIFromModuleDirectory();
		if (!game_library)
		{
			import->Com_Error("Failed to locate baseq2 game API\n");
			return NULL;
		}
	}

	return game_library;
}

GetGameAPIEXTERNAL Q2AS_GetGameAPI(game_import_t* import)
{
	HINSTANCE game_library = Q2AS_GetGameLibrary(import);

	GetGameAPIEXTERNAL external_game_api = NULL; 
	external_game_api = (GetGameAPIEXTERNAL)GetProcAddress(game_library, "GetGameAPI");
	if (!external_game_api)
	{
		import->Com_Error("Failed to load baseq2 game API\n");
	}

	return external_game_api;
}

GetCGameAPIEXTERNAL Q2AS_GetCGameAPI(game_import_t* import)
{
	HINSTANCE game_library = Q2AS_GetGameLibrary(import);

	GetCGameAPIEXTERNAL external_cgame_api = NULL;
	external_cgame_api = (GetCGameAPIEXTERNAL)GetProcAddress(game_library, "GetCGameAPI");
	if (!external_cgame_api)
	{
		import->Com_Error("Failed to load baseq2 game API\n");
	}

	return external_cgame_api;
}