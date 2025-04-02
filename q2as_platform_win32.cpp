#include "q2as_platform.h"
#include <Windows.h>

const char *directory_name = "baseq2";
const char *game_name = "game_x64.dll";

struct HInstanceDeleter
{
    void operator()(HINSTANCE h) const
    {
        if (h)
            FreeLibrary(h);
    }
};
using unique_hinstance = std::unique_ptr<std::remove_pointer<HINSTANCE>::type, HInstanceDeleter>;

module_path_result_t Q2AS_GetModulePath()
{
    module_path_result_t result = {};
    result.success = false;

    HMODULE hm = nullptr;

    if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
        GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        (LPCSTR) &Q2AS_GetModulePath, &hm) == 0)
    {
        return result;
    }

    std::string buffer(MAX_PATH, '\0');
    if (GetModuleFileName(hm, buffer.data(), buffer.size()) == 0)
    {
        return result;
    }

    result.success = true;
    result.path = std::filesystem::path(buffer);
    return result;
}

HINSTANCE Q2AS_GetGameAPIFromCurrentDirectory()
{
    auto base_directory = std::filesystem::current_path();
    auto path = base_directory / directory_name / game_name;
    return LoadLibrary(path.string().c_str());
}

HINSTANCE Q2AS_GetGameAPIFromModuleDirectory()
{
    auto module_path_result = Q2AS_GetModulePath();
    if (!module_path_result.success)
    {
        return nullptr;
    }

    auto base_directory = module_path_result.path.parent_path().parent_path();
    auto path = base_directory / directory_name / game_name;
    return LoadLibrary(path.string().c_str());
}

HINSTANCE Q2AS_GetGameLibrary(game_import_t *import)
{
    HINSTANCE game_library = Q2AS_GetGameAPIFromCurrentDirectory();
    if (!game_library)
    {
        game_library = Q2AS_GetGameAPIFromModuleDirectory();
        if (!game_library)
        {
            import->Com_Error("Failed to locate baseq2 game API\n");
            return nullptr;
        }
    }

    return game_library;
}

HINSTANCE Q2AS_GetGameLibrary(cgame_import_t *import)
{
    HINSTANCE game_library = Q2AS_GetGameAPIFromCurrentDirectory();
    if (!game_library)
    {
        game_library = Q2AS_GetGameAPIFromModuleDirectory();
        if (!game_library)
        {
            import->Com_Error("Failed to locate baseq2 game API\n");
            return nullptr;
        }
    }

    return game_library;
}

GetGameAPIEXTERNAL Q2AS_GetGameAPI(game_import_t *import)
{
    unique_hinstance game_library = { Q2AS_GetGameLibrary(import), {} };
    if (!game_library)
    {
        return nullptr;
    }

    GetGameAPIEXTERNAL external_game_api = nullptr;
    external_game_api = (GetGameAPIEXTERNAL) GetProcAddress(game_library.get(), "GetGameAPI");
    if (!external_game_api)
    {
        import->Com_Error("Failed to load baseq2 game API\n");
        return nullptr;
    }

    game_library.release();
    return external_game_api;
}

GetCGameAPIEXTERNAL Q2AS_GetCGameAPI(cgame_import_t *import)
{
    unique_hinstance game_library = { Q2AS_GetGameLibrary(import), {} };
    if (!game_library)
    {
        return nullptr;
    }

    GetCGameAPIEXTERNAL external_cgame_api = NULL;
    external_cgame_api = (GetCGameAPIEXTERNAL) GetProcAddress(game_library.get(), "GetCGameAPI");
    if (!external_cgame_api)
    {
        import->Com_Error("Failed to load baseq2 game API\n");
        return nullptr;
    }

    game_library.release();
    return external_cgame_api;
}