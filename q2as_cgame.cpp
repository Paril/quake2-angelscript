#include "q2as_cgame.h"
#include "cg_local.h"
#include "q2as_fixedarray.h"
#include "q2as_stringex.h"

#include "q2as_modules.h"
#include "q2as_pmove.h"

/*virtual*/ void q2as_cg_state_t::Print(const char *text) /*override*/
{
    cgi.Com_Print(text);
}

/*virtual*/ void q2as_cg_state_t::Error(const char *text) /*override*/
{
    cgi.Com_Error(text);
}

/*virtual*/ bool q2as_cg_state_t::InstrumentationEnabled() /*override*/
{
    return instrumenting;
}

/*virtual*/ cvar_t *q2as_cg_state_t::Cvar(const char *name, const char *value, cvar_flags_t flags) /*override*/
{
    return cgi.cvar(name, value, flags);
}

enum
{
	TAG_ANGELSCRIPT_CG = 765//768
};

/*virtual*/ void *q2as_cg_state_t::Alloc(size_t size) /*override*/
{
    return cgi.TagMalloc(size, TAG_ANGELSCRIPT_CG);
}

/*virtual*/ void q2as_cg_state_t::Free(void *ptr) /*override*/
{
    cgi.TagFree(ptr);
}

/*static*/ void *q2as_cg_state_t::AllocStatic(size_t size)
{
    return cgi.TagMalloc(size, TAG_ANGELSCRIPT_CG);
}

/*static*/ void q2as_cg_state_t::FreeStatic(void *ptr)
{
    cgi.TagFree(ptr);
}

void q2as_cg_state_t::LoadFunctions()
{
    CG_TouchPics = mainModule->GetFunctionByDecl("void CG_TouchPics()");
    CG_Shutdown = mainModule->GetFunctionByDecl("void CG_Shutdown()");
    CG_ParseConfigString = mainModule->GetFunctionByDecl("void CG_ParseConfigString(int32, const string &in)");
    CG_ParseCenterPrint = mainModule->GetFunctionByDecl("void CG_ParseCenterPrint (const string &in, int, bool)");
    CG_NotifyMessage = mainModule->GetFunctionByDecl("void CG_NotifyMessage(int32, const string &in, bool)");
    CG_LayoutFlags = mainModule->GetFunctionByDecl("layout_flags_t CG_LayoutFlags(const player_state_t &in)");
    CG_Init = mainModule->GetFunctionByDecl("void CG_Init()");
    CG_GetWeaponWheelAmmoCount = mainModule->GetFunctionByDecl("int16 CG_GetWeaponWheelAmmoCount(const player_state_t &in, int32)");
    CG_GetPowerupWheelCount = mainModule->GetFunctionByDecl("int16 CG_GetPowerupWheelCount(const player_state_t &in, int32)");
    CG_GetOwnedWeaponWheelWeapons = mainModule->GetFunctionByDecl("uint32 CG_GetOwnedWeaponWheelWeapons(const player_state_t &in)");
    CG_GetMonsterFlashOffset = mainModule->GetFunctionByDecl("void CG_GetMonsterFlashOffset(monster_muzzle_t, vec3_t &out)");
    CG_GetHitMarkerDamage = mainModule->GetFunctionByDecl("int16 CG_GetHitMarkerDamage(const player_state_t &in)");
    CG_GetActiveWeaponWheelWeapon = mainModule->GetFunctionByDecl("int32 CG_GetActiveWeaponWheelWeapon(const player_state_t &in)");
    CG_DrawHUD = mainModule->GetFunctionByDecl("void CG_DrawHUD (int32, const cg_server_data_t &, const vrect_t &in, const vrect_t &in, int32, int32, const player_state_t &in)");
    CG_ClearNotify = mainModule->GetFunctionByDecl("void CG_ClearNotify(int32)");
    CG_ClearCenterprint = mainModule->GetFunctionByDecl("void CG_ClearCenterprint(int32)");
    CG_Pmove = mainModule->GetFunctionByDecl("void Pmove(pmove_t @pmove)");
    
	pmove_inst = reinterpret_cast<as_pmove_t *>(Alloc(sizeof(as_pmove_t)));
	new(pmove_inst) as_pmove_t();
    pmove_inst->trace_f = engine->GetGlobalFunctionByDecl("trace_t _cg_trace(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, edict_t@, contents_t)");
    pmove_inst->clip_f = engine->GetGlobalFunctionByDecl("trace_t _cg_clip(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, contents_t)");
    pmove_inst->pointcontents_f = engine->GetGlobalFunctionByDecl("contents_t _cg_pointcontents(const vec3_t &in)");

    pmove_inst->trace_f->AddRef();
    pmove_inst->clip_f->AddRef();
    pmove_inst->pointcontents_f->AddRef();
}

q2as_cg_state_t cgas;

static cvar_t *Q2AS_CG_cvar(const std::string &name, const std::string &value, cvar_flags_t flags)
{
	return cgi.cvar(name.c_str(), value.c_str(), flags);
}

static std::string q2as_CG_get_configstring(uint16_t index)
{
	return cgi.get_configstring(index);
}

static bool q2as_CG_Draw_RegisterPic(const std::string &name)
{
    return cgi.Draw_RegisterPic(name.c_str());
}

static void q2as_CG_Draw_GetPicSize(int *w, int *h, const std::string &name)
{
    cgi.Draw_GetPicSize(w, h, name.c_str());
}

static void q2as_CG_SCR_DrawPic(int x, int y, int w, int h, const std::string &name)
{
    cgi.SCR_DrawPic(x, y, w, h, name.c_str());
}

static void q2as_CG_SCR_DrawColorPic(int x, int y, int w, int h, const std::string &name, rgba_t color)
{
    cgi.SCR_DrawColorPic(x, y, w, h, name.c_str(), color);
}

static void q2as_CG_SCR_DrawFontString(const std::string &str, int x, int y, int scale, rgba_t color, bool shadow, text_align_t align)
{
    cgi.SCR_DrawFontString(str.c_str(), x, y, scale, color, shadow, align);
}

static void q2as_CG_SCR_MeasureFontString(asIScriptGeneric *gen)
{
    // vec2_t(const std::string &str, int scale)
    std::string *s = (std::string *) gen->GetArgAddress(0);
    int scale = gen->GetArgDWord(1);

    *((vec2_t *) gen->GetAddressOfReturnLocation()) = cgi.SCR_MeasureFontString(s->c_str(), scale);
}

static void q2as_CG_Com_Error(const std::string &s)
{
	cgi.Com_Error(s.c_str());
}

static void q2as_CG_Com_Print(const std::string &s)
{
	cgi.Com_Print(s.c_str());
}

static void q2as_CG_Com_ErrorFmt(asIScriptGeneric *gen)
{
    std::string data = q2as_format_to(cgas, gen, 0);

	cgi.Com_Error(data.c_str());
}

static void q2as_CG_Com_PrintFmt(asIScriptGeneric *gen)
{
    std::string data = q2as_format_to(cgas, gen, 0);

	cgi.Com_Print(data.c_str());
}

static std::string q2as_CG_Localize_zero(const std::string &s)
{
	return cgi.Localize(s.c_str(), nullptr, 0);
}

static void q2as_CG_Localize(asIScriptGeneric *gen)
{
    std::string result;
    static const char *arg_buffers[MAX_LOCALIZATION_ARGS];

    std::string *base = (std::string *) gen->GetAddressOfArg(0);

    for (int i = 1; i < gen->GetArgCount(); i++)
    {
        std::string *arg = (std::string *) gen->GetAddressOfArg(i);
        arg_buffers[i] = arg->data();
    }

    *((std::string *) gen->GetAddressOfReturnLocation()) = cgi.Localize(base->c_str(), arg_buffers, gen->GetArgCount() - 1);
}

static int32_t q2as_CG_SCR_DrawBind(int32_t isplit, const std::string &binding, const std::string &purpose, int x, int y, int scale)
{
    return cgi.SCR_DrawBind(isplit, binding.c_str(), purpose.c_str(), x, y, scale);
}

static bool q2as_CG_CL_GetTextInput(std::string &out_str, bool &out_isteam)
{
    const char *msg;
    bool is_team;

    bool result = cgi.CL_GetTextInput(&msg, &is_team);

    if (!result)
        return false;

    out_str = msg;
    out_isteam = is_team;
    return true;
}

static std::string q2as_CG_CL_GetClientDogtag(int index)
{
    return cgi.CL_GetClientDogtag(index);
}

static std::string q2as_CG_CL_GetClientName(int index)
{
    return cgi.CL_GetClientName(index);
}

static trace_t Q2AS_CG_Trace(const vec3_t &start, const vec3_t &mins, const vec3_t &maxs, const vec3_t &end, edict_t *passent, contents_t contentmask)
{
    return cgas.pmove_inst->pm.trace(start, &mins, &maxs, end, passent, contentmask);
}

static trace_t Q2AS_CG_Clip(const vec3_t &start, const vec3_t &mins, const vec3_t &maxs, const vec3_t &end, contents_t contentmask)
{
    return cgas.pmove_inst->pm.clip(start, &mins, &maxs, end, contentmask);
}

static contents_t Q2AS_CG_Pointcontents(const vec3_t &p)
{
    return cgas.pmove_inst->pm.pointcontents(p);
}

static void Q2AS_RegisterCGamePmove(q2as_registry &registry)
{
    // TODO these names suck
    registry
        .for_global()
        .functions({
            { "trace_t _cg_trace(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, edict_t@, contents_t)", asFUNCTION(Q2AS_CG_Trace),         asCALL_CDECL },
            { "trace_t _cg_clip(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in, contents_t)",            asFUNCTION(Q2AS_CG_Clip),          asCALL_CDECL },
            { "contents_t _cg_pointcontents(const vec3_t &in)",                                                                  asFUNCTION(Q2AS_CG_Pointcontents), asCALL_CDECL }
        });
}

static void Q2AS_RegisterCGame(q2as_registry &registry)
{
    registry
        .enumeration("text_align_t")
        .values({
	        { "LEFT",   (asINT64) text_align_t::LEFT },
	        { "CENTER", (asINT64) text_align_t::CENTER },
	        { "RIGHT",  (asINT64) text_align_t::RIGHT }
        });

    registry
        .for_global()
        .functions({
            { "cvar_t @cgi_cvar(const string &in, const string &in, cvar_flags_t)",                       asFUNCTION(Q2AS_CG_cvar),                  asCALL_CDECL },
            { "uint64 cgi_CL_ClientRealTime()",                                                           asFUNCTION(cgi.CL_ClientRealTime),         asCALL_CDECL },
            { "uint64 cgi_CL_ClientTime()",                                                               asFUNCTION(cgi.CL_ClientTime),             asCALL_CDECL },
            { "bool cgi_CL_FrameValid()",                                                                 asFUNCTION(cgi.CL_FrameValid),             asCALL_CDECL },
            { "float cgi_CL_FrameTime()",                                                                 asFUNCTION(cgi.CL_FrameTime),              asCALL_CDECL },
            { "int32 cgi_CL_ServerFrame()",                                                               asFUNCTION(cgi.CL_ServerFrame),            asCALL_CDECL },
            { "int32 cgi_CL_ServerProtocol()",                                                            asFUNCTION(cgi.CL_ServerProtocol),         asCALL_CDECL },
            { "void cgi_SCR_DrawChar(int32, int32, int32, int32, bool)",                                  asFUNCTION(cgi.SCR_DrawChar),              asCALL_CDECL },
            { "void cgi_SCR_SetAltTypeface(bool)",                                                        asFUNCTION(cgi.SCR_SetAltTypeface),        asCALL_CDECL },
            { "float cgi_SCR_FontLineHeight(int)",                                                        asFUNCTION(cgi.SCR_FontLineHeight),        asCALL_CDECL },
            { "int cgi_CL_GetWarnAmmoCount(int)",                                                         asFUNCTION(cgi.CL_GetWarnAmmoCount),       asCALL_CDECL },
            { "bool cgi_CL_InAutoDemoLoop()",                                                             asFUNCTION(cgi.CL_InAutoDemoLoop),         asCALL_CDECL },
	        { "string cgi_get_configstring(uint16)",                                                      asFUNCTION(q2as_CG_get_configstring),      asCALL_CDECL },
	        { "bool cgi_Draw_RegisterPic(const string &in)",                                              asFUNCTION(q2as_CG_Draw_RegisterPic),      asCALL_CDECL },
	        { "void cgi_Draw_GetPicSize(int &out, int &out, const string &in)",                           asFUNCTION(q2as_CG_Draw_GetPicSize),       asCALL_CDECL },
	        { "void cgi_SCR_DrawPic(int, int, int, int, const string &in)",                               asFUNCTION(q2as_CG_SCR_DrawPic),           asCALL_CDECL },
	        { "void cgi_SCR_DrawColorPic(int, int, int, int, const string &in, rgba_t)",                  asFUNCTION(q2as_CG_SCR_DrawColorPic),      asCALL_CDECL },
	        { "void cgi_SCR_DrawFontString(const string &in, int, int, int, rgba_t, bool, text_align_t)", asFUNCTION(q2as_CG_SCR_DrawFontString),    asCALL_CDECL },
	        { "vec2_t cgi_SCR_MeasureFontString(const string &in, int)",                                  asFUNCTION(q2as_CG_SCR_MeasureFontString), asCALL_GENERIC },
	        { "void cgi_Com_Error(const string &in)",                                                     asFUNCTION(q2as_CG_Com_Error),             asCALL_CDECL },
	        { "void cgi_Com_Print(const string &in)",                                                     asFUNCTION(q2as_CG_Com_Print),             asCALL_CDECL },
	        { "void cgi_Com_Error(const string &in, const ? &in ...)",                                    asFUNCTION(q2as_CG_Com_ErrorFmt),          asCALL_GENERIC },
	        { "void cgi_Com_Print(const string &in, const ? &in ...)",                                    asFUNCTION(q2as_CG_Com_PrintFmt),          asCALL_GENERIC },
	        { "string cgi_Localize(const string &in)",                                                    asFUNCTION(q2as_CG_Localize_zero),         asCALL_CDECL },
	        { "string cgi_Localize(const string &in, const string &in ...)",                              asFUNCTION(q2as_CG_Localize),              asCALL_GENERIC },
	        { "int cgi_SCR_DrawBind(int, const string &in, const string &in, int, int, int)",             asFUNCTION(q2as_CG_SCR_DrawBind),          asCALL_CDECL },
	        { "bool cgi_CL_GetTextInput(string &out, bool &out)",                                         asFUNCTION(q2as_CG_CL_GetTextInput),       asCALL_CDECL },
	        { "string cgi_CL_GetClientName(int)",                                                         asFUNCTION(q2as_CG_CL_GetClientName),      asCALL_CDECL },
	        { "string cgi_CL_GetClientDogtag(int)",                                                       asFUNCTION(q2as_CG_CL_GetClientDogtag),    asCALL_CDECL }
        })
        .properties({
            { "const float cgi_frame_time_s", (const void *) &cgi.frame_time_s },
	        { "const uint cgi_frame_time_ms", (const void *) &cgi.frame_time_ms },
	        { "const uint cgi_tick_rate",     (const void *) &cgi.tick_rate }
        });
}

std::string q2as_cg_server_data_t_get_layout(const cg_server_data_t *data)
{
    return data->layout;
}

static void Q2AS_RegisterCGameUtil(q2as_registry &registry)
{
	Q2AS_RegisterFixedArray<int32_t, 4>(registry, "vrect_t", "int32", asOBJ_APP_CLASS_ALLINTS);

    registry
        .for_type("vrect_t")
        .properties({
            { "int32 x",      asOFFSET(vrect_t, x) },
	        { "int32 y",      asOFFSET(vrect_t, y) },
	        { "int32 width",  asOFFSET(vrect_t, width) },
	        { "int32 height", asOFFSET(vrect_t, height) },
        });
	
	Q2AS_RegisterFixedArray<int16_t, MAX_ITEMS>(registry, "item_array_t", "int16", asOBJ_APP_CLASS_ALLINTS);
    
	// special handle, always active and allocated
	// by the host, wrapped by AngelScript.
    registry
        .type("cg_server_data_t", sizeof(cg_server_data_t), asOBJ_REF | asOBJ_NOCOUNT)
        .properties({
            { "item_array_t inventory", asOFFSET(cg_server_data_t, inventory) }
        })
        .methods({
            { "string get_layout() const property", asFUNCTION(q2as_cg_server_data_t_get_layout), asCALL_CDECL_OBJLAST }
        });
	
	// entity handle; special handle, always active and allocated
	// by the host, wrapped by AngelScript.
    // the cgame just has a blank version.
    registry
        .type("edict_t", 0, asOBJ_REF | asOBJ_NOCOUNT);
}

static void Q2AS_CG_ClearCenterprint(int32_t isplit)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_ClearCenterprint);
    ctx->SetArgDWord(0, isplit);
	ctx.Execute();
}

static void Q2AS_CG_ClearNotify(int32_t isplit)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_ClearNotify);
    ctx->SetArgDWord(0, isplit);
	ctx.Execute();
}

static void Q2AS_CG_DrawHUD (int32_t isplit, const cg_server_data_t *data, vrect_t hud_vrect, vrect_t hud_safe, int32_t scale, int32_t playernum, const player_state_t *ps)
{
    if (q2as_state_t::CheckExceptionState())
    {
        auto measure = cgi.SCR_MeasureFontString("AngelScript", scale);
        int x = (hud_vrect.width / 2) * scale;
        int y = ((hud_vrect.height / 2) - 100) * scale;
        cgi.SCR_DrawColorPic(x - (measure.x / 2) - (scale * 4), y, measure.x + (scale * 8), measure.y, "_white", rgba_t{(uint8_t) 200, (uint8_t) 200, (uint8_t) 200, (uint8_t) 255});
        cgi.SCR_DrawFontString("AngelScript", x, y, scale,
            rgba_t{(uint8_t) 0, (uint8_t) 0, (uint8_t) 190, (uint8_t) 255}, false, text_align_t::CENTER);

        y += cgi.SCR_FontLineHeight(scale) * 3;
        cgi.SCR_DrawFontString("Quake II has encountered an unhandled exception and must be shut down.\nPlease take a screenshot of this and send it to Paril.\nUse the console or press ESCAPE/START to quit.\n\n", x - (160 * scale), y, 1, rgba_t{(uint8_t) 200, (uint8_t) 200, (uint8_t) 200, (uint8_t) 255}, false, text_align_t::LEFT);

        y += cgi.SCR_FontLineHeight(1) * 6;
        cgi.SCR_DrawFontString(q2as_state_t::GetExceptionData().c_str(), x - (160 * scale), y, 1, rgba_t{(uint8_t) 200, (uint8_t) 200, (uint8_t) 200, (uint8_t) 255}, false, text_align_t::LEFT);
        return;
    }

#ifdef RUNFRAME_PROFILING
    CTRACK;
#endif
    
    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_DrawHUD);
	ctx->SetArgDWord(0, isplit);
	ctx->SetArgAddress(1, (void *) data);
	ctx->SetArgAddress(2, &hud_vrect);
	ctx->SetArgAddress(3, &hud_safe);
	ctx->SetArgDWord(4, scale);
	ctx->SetArgDWord(5, playernum);
	ctx->SetArgAddress(6, (void *) ps);
	ctx.Execute();
}

static int32_t Q2AS_CG_GetActiveWeaponWheelWeapon(const player_state_t *ps)
{
    if (q2as_state_t::CheckExceptionState())
        return 0;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetActiveWeaponWheelWeapon);
	ctx->SetArgAddress(0, (void *) ps);
	ctx.Execute();

    return ctx->GetReturnDWord();
}

static int16_t Q2AS_CG_GetHitMarkerDamage(const player_state_t *ps)
{
    if (q2as_state_t::CheckExceptionState())
        return 0;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetHitMarkerDamage);
	ctx->SetArgAddress(0, (void *) ps);
	ctx.Execute();

    return ctx->GetReturnWord();
}

static void Q2AS_CG_GetMonsterFlashOffset(monster_muzzleflash_id_t id, gvec3_ref_t offset)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetMonsterFlashOffset);
	ctx->SetArgDWord(0, id);
	ctx->SetArgAddress(1, &offset);
	ctx.Execute();
}

static uint32_t Q2AS_CG_GetOwnedWeaponWheelWeapons(const player_state_t *ps)
{
    if (q2as_state_t::CheckExceptionState())
        return 0;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetOwnedWeaponWheelWeapons);
	ctx->SetArgAddress(0, (void *) ps);
	ctx.Execute();

    return (uint32_t) ctx->GetReturnDWord();
}

static int16_t Q2AS_CG_GetPowerupWheelCount(const player_state_t *ps, int32_t powerup_id)
{
    if (q2as_state_t::CheckExceptionState())
        return 0;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetPowerupWheelCount);
	ctx->SetArgAddress(0, (void *) ps);
	ctx->SetArgDWord(1, powerup_id);
	ctx.Execute();

    return ctx->GetReturnWord();
}

static int16_t Q2AS_CG_GetWeaponWheelAmmoCount(const player_state_t *ps, int32_t ammo_id)
{
    if (q2as_state_t::CheckExceptionState())
        return 0;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_GetWeaponWheelAmmoCount);
	ctx->SetArgAddress(0, (void *) ps);
	ctx->SetArgDWord(1, ammo_id);
	ctx.Execute();

    return ctx->GetReturnWord();
}

static void Q2AS_CG_Init()
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_Init);
	ctx.Execute();
}

static layout_flags_t Q2AS_CG_LayoutFlags(const player_state_t *ps)
{
    if (q2as_state_t::CheckExceptionState())
        return LAYOUTS_NONE;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_LayoutFlags);
	ctx->SetArgAddress(0, (void *) ps);
	ctx.Execute();

    return (layout_flags_t) ctx->GetReturnWord();
}

static void Q2AS_CG_NotifyMessage(int32_t isplit, const char *msg, bool is_chat)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    std::string msg_ = msg;
    
    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_NotifyMessage);
	ctx->SetArgDWord(0, isplit);
	ctx->SetArgAddress(1, &msg_);
	ctx->SetArgByte(2, isplit);
	ctx.Execute();
}

static void Q2AS_CG_ParseConfigString(int32_t i, const char *s)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    std::string s_ = s;
    
    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_ParseConfigString);
	ctx->SetArgDWord(0, i);
	ctx->SetArgAddress(1, &s_);
	ctx.Execute();
}

//void CG_ParseCenterPrint (const string &in str, int isplit, bool instant)
static void Q2AS_CG_ParseCenterPrint(const char *s, int32_t i, bool instant)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    std::string s_ = s;
    
    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_ParseCenterPrint);
	ctx->SetArgAddress(0, &s_);
	ctx->SetArgDWord(1, i);
	ctx->SetArgByte(2, instant);
	ctx.Execute();
}

static void Q2AS_CG_Shutdown()
{
    if (!q2as_state_t::CheckExceptionState())
    {
        auto ctx = cgas.RequestContext();
	    ctx->Prepare(cgas.CG_Shutdown);
    	ctx.Execute();
    }

    Q2AS_ReleaseObj<as_pmove_t, q2as_cg_state_t>(cgas.pmove_inst);

    cgas.Destroy();
}

static void Q2AS_CG_TouchPics()
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_TouchPics);
	ctx.Execute();
}

static void Q2AS_CG_Pmove(pmove_t *pm)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    cgas.pmove_inst->pm = *pm;

    auto ctx = cgas.RequestContext();
	ctx->Prepare(cgas.CG_Pmove);
    ctx->SetArgObject(0, cgas.pmove_inst);
	ctx.Execute();

    *pm = cgas.pmove_inst->pm;
}

cgame_export_t *Q2AS_GetCGameAPI()
{
	const cvar_t *q2as_use = cgi.cvar("q2as_use_cgame", "1", CVAR_NOFLAGS);

	if (q2as_use->integer != 1)
		return nullptr;

    if (!cgas.Load(q2as_cg_state_t::AllocStatic, q2as_cg_state_t::FreeStatic))
        return nullptr;

    cgas.instrumentation = cgi.cvar("q2as_instrumentation", "0", CVAR_NOFLAGS);
    cgas.instrumenting = cgas.instrumentation->integer & 2;

	constexpr library_reg_t *const libraries[] = {
		Q2AS_RegisterThirdParty,
        Q2AS_RegisterLimits,
		Q2AS_RegisterMath,
		Q2AS_RegisterVec3,
        Q2AS_RegisterUtil,
		Q2AS_RegisterTime,
		Q2AS_RegisterRandom,
		Q2AS_RegisterStringEx,
        Q2AS_RegisterCvar,
        Q2AS_RegisterDebugging,
        Q2AS_RegisterReflection,
        Q2AS_RegisterStringHashSet,
        Q2AS_RegisterPlayerState,
        Q2AS_RegisterCGameUtil,
        Q2AS_RegisterTrace,
        Q2AS_RegisterPmove,
        Q2AS_RegisterPmoveFactory<q2as_cg_state_t>,
        Q2AS_RegisterCGamePmove,
        Q2AS_RegisterImportTypes,
        Q2AS_RegisterTokenizer,
		Q2AS_RegisterCGame
	};

    if (!cgas.LoadLibraries(libraries, std::extent_v<decltype(libraries)>))
        return nullptr;

    if (!cgas.CreateMainModule())
        return nullptr;

    if (!cgas.LoadFiles("cgame", cgas.mainModule))
        return nullptr;

    if (!cgas.Build())
        return nullptr;

    cgas.LoadFunctions();

    cglobals.ClearCenterprint = Q2AS_CG_ClearCenterprint;
    cglobals.ClearNotify = Q2AS_CG_ClearNotify;
    cglobals.DrawHUD = Q2AS_CG_DrawHUD;
    cglobals.GetActiveWeaponWheelWeapon = Q2AS_CG_GetActiveWeaponWheelWeapon;
    cglobals.GetHitMarkerDamage = Q2AS_CG_GetHitMarkerDamage;
    cglobals.GetMonsterFlashOffset = Q2AS_CG_GetMonsterFlashOffset;
    cglobals.GetOwnedWeaponWheelWeapons = Q2AS_CG_GetOwnedWeaponWheelWeapons;
    cglobals.GetPowerupWheelCount = Q2AS_CG_GetPowerupWheelCount;
    cglobals.GetWeaponWheelAmmoCount = Q2AS_CG_GetWeaponWheelAmmoCount;
    cglobals.Init = Q2AS_CG_Init;
    cglobals.LayoutFlags = Q2AS_CG_LayoutFlags;
    cglobals.NotifyMessage = Q2AS_CG_NotifyMessage;
    cglobals.ParseConfigString = Q2AS_CG_ParseConfigString;
    cglobals.ParseCenterPrint = Q2AS_CG_ParseCenterPrint;
    cglobals.Shutdown = Q2AS_CG_Shutdown;
    cglobals.TouchPics = Q2AS_CG_TouchPics;
    cglobals.Pmove = Q2AS_CG_Pmove;

    return &cglobals;
}