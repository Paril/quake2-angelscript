#pragma once

#include "q2as_local.h"
#include "bg_local.h"
#include "q2as_pmove.h"

struct q2as_cg_state_t : q2as_state_t
{
	asIScriptFunction *CG_ClearCenterprint = nullptr;
	asIScriptFunction *CG_ClearNotify = nullptr;
	asIScriptFunction *CG_DrawHUD = nullptr;
	asIScriptFunction *CG_GetActiveWeaponWheelWeapon = nullptr;
	asIScriptFunction *CG_GetHitMarkerDamage = nullptr;
	asIScriptFunction *CG_GetMonsterFlashOffset = nullptr;
	asIScriptFunction *CG_GetOwnedWeaponWheelWeapons = nullptr;
	asIScriptFunction *CG_GetPowerupWheelCount = nullptr;
	asIScriptFunction *CG_GetWeaponWheelAmmoCount = nullptr;
	asIScriptFunction *CG_Init = nullptr;
	asIScriptFunction *CG_LayoutFlags = nullptr;
	asIScriptFunction *CG_NotifyMessage = nullptr;
	asIScriptFunction *CG_ParseConfigString = nullptr;
	asIScriptFunction *CG_ParseCenterPrint = nullptr;
    asIScriptFunction *CG_Shutdown = nullptr;
    asIScriptFunction *CG_TouchPics = nullptr;
	asIScriptFunction *CG_Pmove = nullptr;
	as_pmove_t *pmove_inst;
    cvar_t *instrumentation;
    bool instrumenting = false;

    void LoadFunctions();

    virtual void Print(const char *text) override;
    virtual void Error(const char *text) override;
    virtual bool InstrumentationEnabled() override;
    virtual void *Alloc(size_t size) override;
    virtual void Free(void *ptr) override;
    virtual cvar_t *Cvar(const char *name, const char *value, cvar_flags_t flags) override;

    static void *AllocStatic(size_t size);
    static void FreeStatic(void *ptr);
};

extern q2as_cg_state_t cgas;