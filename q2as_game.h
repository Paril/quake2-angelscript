#pragma once

#include "q2as_local.h"

#include <string>
#include <vector>

struct q2as_sv_state_t : q2as_state_t
{
    uint32_t             maxentities = 0, maxclients = 0;
    struct q2as_edict_t *edicts = nullptr;
    gclient_t           *clients = nullptr;

    std::string              cmd_args;
    std::vector<std::string> cmd_argv;

    asIScriptFunction *PreInitGame = nullptr;
    asIScriptFunction *InitGame = nullptr;
    asIScriptFunction *ShutdownGame = nullptr;
    asIScriptFunction *SpawnEntities = nullptr;
    asIScriptFunction *WriteGameJson = nullptr;
    asIScriptFunction *ReadGameJson = nullptr;
    asIScriptFunction *WriteLevelJson = nullptr;
    asIScriptFunction *ReadLevelJson = nullptr;
    asIScriptFunction *CanSave = nullptr;
    asIScriptFunction *ClientChooseSlot = nullptr;
    asIScriptFunction *ClientConnect = nullptr;
    asIScriptFunction *ClientBegin = nullptr;
    asIScriptFunction *ClientUserinfoChanged = nullptr;
    asIScriptFunction *ClientDisconnect = nullptr;
    asIScriptFunction *ClientCommand = nullptr;
    asIScriptFunction *ClientThink = nullptr;
    asIScriptFunction *RunFrame = nullptr;
    asIScriptFunction *PrepFrame = nullptr;
    asIScriptFunction *Bot_SetWeapon = nullptr;
    asIScriptFunction *Bot_TriggerEdict = nullptr;
    asIScriptFunction *Bot_UseItem = nullptr;
    asIScriptFunction *Bot_GetItemID = nullptr;
    asIScriptFunction *Edict_ForceLookAtPoint = nullptr;
    asIScriptFunction *Bot_PickedUpItem = nullptr;
    asIScriptFunction *Entity_IsVisibleToPlayer = nullptr;

    q2as_sv_state_t() :
        q2as_state_t("game")
    {
#ifdef Q2AS_DEBUGGER
        instrumentation_bit = 1;
#endif
    }

    void LoadFunctions();

    virtual void    Print(const char *text) override;
    virtual void    Error(const char *text) override;
    virtual void   *Alloc(size_t size) override;
    virtual void    Free(void *ptr) override;
    virtual cvar_t *Cvar(const char *name, const char *value, cvar_flags_t flags) override;

    static void *AllocStatic(size_t size);
    static void  FreeStatic(void *ptr);
};

extern q2as_sv_state_t svas;