#pragma once

#include "q2as_local.h"
#include "bg_local.h"

#include <vector>
#include <string>

// server game stuff
struct q2as_edict_t : edict_t
{
    asIScriptObject *as_obj; // handle to "entity" object set by AS
};

struct q2as_sv_state_t : q2as_state_t
{
    uint32_t maxentities, maxclients;
	q2as_edict_t *edicts;
	gclient_t *clients;

	std::string cmd_args;
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

    cvar_t *instrumentation;
    bool instrumenting = false;

    void LoadFunctions();

    virtual void Print(const char *text) override;
    virtual void Error(const char *text) override;
    virtual bool InstrumentationEnabled() override;
    virtual void *Alloc(size_t size) override;
    virtual void Free(void *ptr) override;

    static void *AllocStatic(size_t size);
    static void FreeStatic(void *ptr);
};

extern q2as_sv_state_t svas;