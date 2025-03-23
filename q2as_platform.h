#include "g_local.h"
#include <filesystem>

typedef game_export_t* (*GetGameAPIEXTERNAL)(game_import_t*);
typedef cgame_export_t* (*GetCGameAPIEXTERNAL)(cgame_import_t*);

struct module_path_result_t
{
	bool success;
	std::filesystem::path path;
};

module_path_result_t Q2AS_GetModulePath();