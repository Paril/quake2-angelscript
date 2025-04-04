#include "q2as_game.h"
#include "g_local.h"
#include <chrono>

#include "q2as_fixedarray.h"
#include "q2as_stringex.h"
#include "q2as_json.h"
#include "thirdparty/scriptany/scriptany.h"
#include "thirdparty/scriptarray/scriptarray.h"

#include "q2as_modules.h"
#include "q2as_pmove.h"

#include "q2as_predefined.h"

/*virtual*/ void q2as_sv_state_t::Print(const char *text) /*override*/
{
    gi.Com_Print(text);
}

/*virtual*/ void q2as_sv_state_t::Error(const char *text) /*override*/
{
    gi.Com_Error(text);
}

/*virtual*/ bool q2as_sv_state_t::InstrumentationEnabled() /*override*/
{
    return instrumenting;
}

/*virtual*/ cvar_t *q2as_sv_state_t::Cvar(const char *name, const char *value, cvar_flags_t flags) /*override*/
{
    return gi.cvar(name, value, flags);
}

enum
{
    TAG_ANGELSCRIPT_SV = 765//767
};

/*virtual*/ void *q2as_sv_state_t::Alloc(size_t size) /*override*/
{
    return gi.TagMalloc(size, TAG_ANGELSCRIPT_SV);
}

/*virtual*/ void q2as_sv_state_t::Free(void *ptr) /*override*/
{
    gi.TagFree(ptr);
}

/*virtual*/ void *q2as_sv_state_t::AllocStatic(size_t size) /*override*/
{
    return gi.TagMalloc(size, TAG_ANGELSCRIPT_SV);
}

/*virtual*/ void q2as_sv_state_t::FreeStatic(void *ptr) /*override*/
{
    gi.TagFree(ptr);
}

void q2as_sv_state_t::LoadFunctions()
{
    PreInitGame = mainModule->GetFunctionByDecl("void PreInitGame()");
    InitGame = mainModule->GetFunctionByDecl("void InitGame()");
    ShutdownGame = mainModule->GetFunctionByDecl("void ShutdownGame()");
    SpawnEntities = mainModule->GetFunctionByDecl("void SpawnEntities(string &in mapname, string &in entstring, string &in spawnpoint)");
    WriteGameJson = mainModule->GetFunctionByDecl("void WriteGame(bool autosave, json_mutdoc &)");
    ReadGameJson = mainModule->GetFunctionByDecl("void ReadGame(json_doc &)");
    WriteLevelJson = mainModule->GetFunctionByDecl("void WriteLevel(bool transition, json_mutdoc &)");
    ReadLevelJson = mainModule->GetFunctionByDecl("void ReadLevel(json_doc &)");
    CanSave = mainModule->GetFunctionByDecl("bool CanSave()");
    ClientChooseSlot = mainModule->GetFunctionByDecl("edict_t @ClientChooseSlot(const string &in userinfo, const string &in social_id, bool isBot, const array<edict_t@> &in ignore, bool cinematic)");
    ClientConnect = mainModule->GetFunctionByDecl("bool ClientConnect(edict_t @ent, string &in userinfo, string &in social_id, bool isBot, string &out reject_userinfo)");
    ClientBegin = mainModule->GetFunctionByDecl("void ClientBegin(edict_t @ent)");
    ClientUserinfoChanged = mainModule->GetFunctionByDecl("void ClientUserinfoChanged(edict_t @ent_handle, const string &in userinfo)");
    ClientDisconnect = mainModule->GetFunctionByDecl("void ClientDisconnect(edict_t @ent_handle)");
    ClientCommand = mainModule->GetFunctionByDecl("void ClientCommand(edict_t @ent_handle)");
    ClientThink = mainModule->GetFunctionByDecl("void ClientThink(edict_t @ent_handle, const usercmd_t &in ucmd)");
    RunFrame = mainModule->GetFunctionByDecl("void RunFrame(bool)");
    PrepFrame = mainModule->GetFunctionByDecl("void PrepFrame()");
    Bot_SetWeapon = mainModule->GetFunctionByDecl("void Bot_SetWeapon(edict_t @, int, bool)");
    Bot_TriggerEdict = mainModule->GetFunctionByDecl("void Bot_TriggerEdict( edict_t @, edict_t @ )");
    Bot_UseItem = mainModule->GetFunctionByDecl("void Bot_UseItem( edict_t @, int )");
    Bot_GetItemID = mainModule->GetFunctionByDecl("int Bot_GetItemID( const string &in )");
    Edict_ForceLookAtPoint = mainModule->GetFunctionByDecl("void Edict_ForceLookAtPoint( edict_t @, const vec3_t &in )");
    Bot_PickedUpItem = mainModule->GetFunctionByDecl("bool Bot_PickedUpItem( edict_t @, edict_t @ )");
    Entity_IsVisibleToPlayer = mainModule->GetFunctionByDecl("bool Entity_IsVisibleToPlayer( edict_t @, edict_t @ )");
}

q2as_sv_state_t svas;

static void Q2AS_PreInitGame()
{
    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.PreInitGame);
    ctx.Execute();
}

static void Q2AS_InitGame()
{
    cvar_t *maxentities = gi.cvar("maxentities", G_Fmt("{}", MAX_EDICTS).data(), CVAR_LATCH);
    cvar_t *maxclients = gi.cvar("maxclients", G_Fmt("{}", MAX_SPLIT_PLAYERS).data(), CVAR_SERVERINFO | CVAR_LATCH);

    // seed RNG
    mt_rand.seed((uint32_t) std::chrono::system_clock::now().time_since_epoch().count());

    // initialize all entities for this game
    svas.maxentities = maxentities->integer;
    svas.edicts = (q2as_edict_t *) gi.TagMalloc(svas.maxentities * sizeof(q2as_edict_t), TAG_GAME);

    globals.edicts = (edict_t *) svas.edicts;
    globals.max_edicts = svas.maxentities;

    // initialize all clients for this game
    svas.maxclients = maxclients->integer;
    svas.clients = (gclient_t *) gi.TagMalloc(svas.maxclients * sizeof(gclient_t), TAG_GAME);
    globals.num_edicts = svas.maxclients + 1;

    for (uint32_t i = 0; i < svas.maxentities; i++)
    {
        svas.edicts[i].s.number = i;

        if (i >= 1 && i <= svas.maxclients)
            svas.edicts[i].client = (gclient_t *) &svas.clients[i - 1];
    }

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.InitGame);
    ctx.Execute();
}

static void Q2AS_ShutdownGame()
{
    // already shut down
    if (!svas.engine)
        return;

    if (!q2as_state_t::CheckExceptionState())
    {
        {
            auto ctx = svas.RequestContext();
            ctx->Prepare(svas.ShutdownGame);
            ctx.Execute();
        }

#ifdef RUNFRAME_PROFILING
        gi.Com_Print(ctrack::result_as_string().c_str());
#endif

        // disconnect all entities
        for (q2as_edict_t *e = svas.edicts; e < svas.edicts + svas.maxentities; e++)
            if (e->as_obj)
                e->as_obj->Release();

        svas.Destroy();
    }

    gi.FreeTags(TAG_LEVEL);
    gi.FreeTags(TAG_GAME);
    gi.FreeTags(TAG_ANGELSCRIPT_SV);
}

static void Q2AS_SpawnEntities(const char *mapname, const char *entstring, const char *spawnpoint)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    std::string mapname_ = mapname;
    std::string entstring_ = entstring;
    std::string spawnpoint_ = spawnpoint;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.SpawnEntities);
    ctx->SetArgAddress(0, &mapname_);
    ctx->SetArgAddress(1, &entstring_);
    ctx->SetArgAddress(2, &spawnpoint_);
    ctx.Execute();
}

static char *Q2AS_WriteGameJson(bool autosave, size_t *out_size)
{
    if (q2as_state_t::CheckExceptionState())
    {
        *out_size = 0;
        return (char *) gi.TagMalloc(1, TAG_GAME);
    }

    auto ti = svas.engine->GetTypeInfoByName("json_mutdoc");
    q2as_yyjson_mut_doc *doc = (q2as_yyjson_mut_doc *) svas.engine->CreateScriptObject(ti);

    {
        auto ctx = svas.RequestContext();
        ctx->Prepare(svas.WriteGameJson);
        ctx->SetArgByte(0, autosave);
        ctx->SetArgAddress(1, doc);
        ctx.Execute();
    }

    char *data = doc->as_string(out_size);

    svas.engine->ReleaseScriptObject(doc, ti);

    return data;
}

static void Q2AS_ReadGameJson(const char *json)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ti = svas.engine->GetTypeInfoByName("json_doc");
    q2as_yyjson_doc *doc = (q2as_yyjson_doc *) q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc));
    new(doc) q2as_yyjson_doc(std::string_view(json));

    {
        auto ctx = svas.RequestContext();
        ctx->Prepare(svas.ReadGameJson);
        ctx->SetArgAddress(0, doc);
        ctx.Execute();
    }

    svas.engine->ReleaseScriptObject(doc, ti);
}

static char *Q2AS_WriteLevelJson(bool transition, size_t *out_size)
{
    if (q2as_state_t::CheckExceptionState())
    {
        *out_size = 0;
        return (char *) gi.TagMalloc(1, TAG_GAME);
    }

    auto ti = svas.engine->GetTypeInfoByName("json_mutdoc");
    q2as_yyjson_mut_doc *doc = (q2as_yyjson_mut_doc *) svas.engine->CreateScriptObject(ti);

    {
        auto ctx = svas.RequestContext();
        ctx->Prepare(svas.WriteLevelJson);
        ctx->SetArgByte(0, transition);
        ctx->SetArgAddress(1, doc);
        ctx.Execute();
    }

    char *data = doc->as_string(out_size);

    svas.engine->ReleaseScriptObject(doc, ti);

    return data;
}

static void Q2AS_ReadLevelJson(const char *json)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ti = svas.engine->GetTypeInfoByName("json_doc");
    q2as_yyjson_doc *doc = (q2as_yyjson_doc *) q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc));
    new(doc) q2as_yyjson_doc(std::string_view(json));

    {
        auto ctx = svas.RequestContext();
        ctx->Prepare(svas.ReadLevelJson);
        ctx->SetArgAddress(0, doc);
        ctx.Execute();
    }

    svas.engine->ReleaseScriptObject(doc, ti);
}

static bool Q2AS_CanSave()
{
    if (q2as_state_t::CheckExceptionState())
        return false;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.CanSave);
    ctx.Execute();

    return ctx->GetReturnByte();
}

static void *Q2AS_GetExtension(const char *name)
{
    return nullptr;
}

static edict_t *Q2AS_ClientChooseSlot(const char *userinfo, const char *social_id, bool isBot, edict_t **ignore, size_t num_ignore, bool cinematic)
{
    if (q2as_state_t::CheckExceptionState())
        return nullptr;

    std::string userinfo_ = userinfo;
    std::string social_id_ = social_id;

    CScriptArray *ignore_array = CScriptArray::Create(svas.engine->GetTypeInfoByDecl("array<edict_t @>"), num_ignore);

    for (uint32_t i = 0; i < num_ignore; i++)
        ignore_array->SetValue(i, &ignore[i]);

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientChooseSlot);
    ctx->SetArgAddress(0, &userinfo_);
    ctx->SetArgAddress(1, &social_id_);
    ctx->SetArgByte(2, isBot);
    ctx->SetArgObject(3, ignore_array);
    ctx->SetArgByte(4, cinematic);
    ctx.Execute();

    ignore_array->Release();

    return (edict_t *) ctx->GetReturnAddress();
}

static bool Q2AS_ClientConnect(edict_t *ent, char *userinfo, const char *social_id, bool isBot)
{
    if (q2as_state_t::CheckExceptionState())
        return false;

    std::string userinfo_ = userinfo;
    std::string social_id_ = social_id;
    std::string out_userinfo;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientConnect);
    ctx->SetArgAddress(0, ent);
    ctx->SetArgAddress(1, &userinfo_);
    ctx->SetArgAddress(2, &social_id_);
    ctx->SetArgByte(3, isBot);
    ctx->SetArgAddress(4, &out_userinfo);
    ctx.Execute();

    bool allow = !!ctx->GetReturnByte();

    if (!allow)
        Q_strlcpy(userinfo, out_userinfo.c_str(), MAX_INFO_STRING);

    return allow;
}

static void Q2AS_ClientBegin(edict_t *ent)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientBegin);
    ctx->SetArgAddress(0, ent);
    ctx.Execute();
}

static void Q2AS_ClientUserinfoChanged(edict_t *ent, const char *userinfo)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    std::string userinfo_ = userinfo;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientUserinfoChanged);
    ctx->SetArgAddress(0, ent);
    ctx->SetArgAddress(1, &userinfo_);
    ctx.Execute();
}

static void Q2AS_ClientDisconnect(edict_t *ent)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientDisconnect);
    ctx->SetArgAddress(0, ent);
    ctx.Execute();
}

static void Q2AS_ClientCommand(edict_t *ent)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    svas.cmd_args = gi.args();

    if (svas.cmd_argv.size() < gi.argc())
        svas.cmd_argv.resize(gi.argc());

    for (int i = 0; i < gi.argc(); i++)
        svas.cmd_argv[i] = gi.argv(i);

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientCommand);
    ctx->SetArgAddress(0, ent);
    ctx.Execute();
}

static void Q2AS_ClientThink(edict_t *ent, usercmd_t *cmd)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.ClientThink);
    ctx->SetArgAddress(0, ent);
    ctx->SetArgAddress(1, cmd);
    ctx.Execute();
}

void Q2AS_RunFrame(bool main_loop)
{
    if (q2as_state_t::CheckExceptionState())
        return;

#ifdef RUNFRAME_PROFILING
    CTRACK;
#endif

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.RunFrame);
    ctx->SetArgByte(0, main_loop);
    ctx.Execute();
}

// just for the exception state thing
enum
{
    STAT_LAYOUTS = 13
};

static void Q2AS_PrepFrame()
{
    if (q2as_state_t::CheckExceptionState())
    {
        // clear entities just so we don't hear endless noises
        for (q2as_edict_t *e = svas.edicts + 1; e < svas.edicts + globals.num_edicts; e++)
        {
            if (!e->inuse)
                continue;

            e->s = {};
            e->s.number = e - svas.edicts;
        }

        // black out player 1's screen
        if (auto *e = &svas.edicts[1]; e->inuse && e->client)
        {
            e->client->ps.screen_blend = { 0, 0, 0.66666f, 1 };
            e->client->ps.pmove.pm_type = PM_FREEZE;
            e->client->ps.gunindex = 0;
            e->client->ps.stats[STAT_LAYOUTS] = LAYOUTS_LAYOUT | LAYOUTS_HIDE_CROSSHAIR | LAYOUTS_HIDE_HUD;
        }

        return;
    }

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.PrepFrame);
    ctx.Execute();
}

static void Q2AS_ServerCommand()
{
    if (q2as_state_t::CheckExceptionState())
        return;

    if (!strcmp(gi.argv(1), "q2as_write_predefined"))
        WritePredefined();
}

static void    Q2AS_Bot_SetWeapon(edict_t *botEdict, const int weaponIndex, const bool instantSwitch)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Bot_SetWeapon);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgDWord(1, weaponIndex);
    ctx->SetArgByte(2, instantSwitch);
    ctx.Execute();
}

static void    Q2AS_Bot_TriggerEdict(edict_t *botEdict, edict_t *edict)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Bot_TriggerEdict);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgAddress(1, edict);
    ctx.Execute();
}

static void    Q2AS_Bot_UseItem(edict_t *botEdict, const int32_t itemID)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Bot_UseItem);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgDWord(1, itemID);
    ctx.Execute();
}

static int32_t Q2AS_Bot_GetItemID(const char *classname)
{
    if (q2as_state_t::CheckExceptionState())
        return Item_Null;

    std::string classname_ = classname;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Bot_GetItemID);
    ctx->SetArgAddress(0, &classname_);
    ctx.Execute();

    return ctx->GetReturnDWord();
}

static void    Q2AS_Edict_ForceLookAtPoint(edict_t *edict, gvec3_cref_t point)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Edict_ForceLookAtPoint);
    ctx->SetArgAddress(0, edict);
    ctx->SetArgAddress(1, (void *) &point);
    ctx.Execute();
}

static bool    Q2AS_Bot_PickedUpItem(edict_t *botEdict, edict_t *itemEdict)
{
    if (q2as_state_t::CheckExceptionState())
        return false;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Bot_PickedUpItem);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgAddress(1, itemEdict);
    ctx.Execute();

    return ctx->GetReturnByte();
}

static bool Q2AS_Entity_IsVisibleToPlayer(edict_t *ent, edict_t *player)
{
    if (q2as_state_t::CheckExceptionState())
        return false;

    auto ctx = svas.RequestContext();
    ctx->Prepare(svas.Entity_IsVisibleToPlayer);
    ctx->SetArgAddress(0, ent);
    ctx->SetArgAddress(1, player);
    ctx.Execute();

    return ctx->GetReturnByte();
}

static void Q2AS_RegisterGameImports(q2as_registry &registry)
{
    registry
        .enumeration("gesture_type_t")
        .values({
            { "NONE", GESTURE_NONE },
            { "FLIP_OFF", GESTURE_FLIP_OFF },
            { "SALUTE", GESTURE_SALUTE },
            { "TAUNT", GESTURE_TAUNT },
            { "WAVE", GESTURE_WAVE },
            { "POINT", GESTURE_POINT },
            { "POINT_NO_PING", GESTURE_POINT_NO_PING },
            { "MAX", GESTURE_MAX }
        });

    registry
        .enumeration("print_type_t")
        .values({
            { "LOW",         PRINT_LOW },
            { "MEDIUM",      PRINT_MEDIUM },
            { "HIGH",        PRINT_HIGH },
            { "CHAT",        PRINT_CHAT },
            { "TYPEWRITER",  PRINT_TYPEWRITER },
            { "CENTER",      PRINT_CENTER },
            { "TTS",         PRINT_TTS },

            { "BROADCAST", PRINT_BROADCAST },
            { "NO_NOTIFY", PRINT_NO_NOTIFY }
        });

    registry
        .enumeration("BoxEdictsResult_t")
        .values({
            { "Keep", (asINT64) BoxEdictsResult_t::Keep },
            { "Skip", (asINT64) BoxEdictsResult_t::Skip },
            { "End", (asINT64) BoxEdictsResult_t::End },
            { "Flags", (asINT64) BoxEdictsResult_t::Flags }
        });

    registry
        .enumeration("multicast_t")
        .values({
            { "ALL", MULTICAST_ALL },
            { "PHS", MULTICAST_PHS },
            { "PVS", MULTICAST_PVS }
        });

    registry
        .enumeration("solidity_area_t")
        .values({
            { "SOLID",    AREA_SOLID },
            { "TRIGGERS", AREA_TRIGGERS }
        });

    registry
        .enumeration("soundchan_t", "uint8")
        .values({
            { "AUTO",     CHAN_AUTO },
            { "WEAPON",   CHAN_WEAPON },
            { "VOICE",    CHAN_VOICE },
            { "ITEM",     CHAN_ITEM },
            { "BODY",     CHAN_BODY },
            { "AUX",      CHAN_AUX },
            { "FOOTSTEP", CHAN_FOOTSTEP },
            { "AUX3",     CHAN_AUX3 },

            { "NO_PHS_ADD", CHAN_NO_PHS_ADD },
            { "RELIABLE",   CHAN_RELIABLE },
            { "FORCE_POS",  CHAN_FORCE_POS }
        });

    registry
        .enumeration("svc_t")
        .values({
            { "bad", svc_bad },

            { "muzzleflash",  svc_muzzleflash },
            { "muzzleflash2", svc_muzzleflash2 },
            { "temp_entity",  svc_temp_entity },
            { "layout",       svc_layout },
            { "inventory",    svc_inventory },

            { "nop",                 svc_nop },
            { "disconnect",          svc_disconnect },
            { "reconnect",           svc_reconnect },
            { "sound",               svc_sound },
            { "print",               svc_print },
            { "stufftext",           svc_stufftext },
            { "serverdata",          svc_serverdata },
            { "configstring",        svc_configstring },
            { "spawnbaseline",       svc_spawnbaseline },
            { "centerprint",         svc_centerprint },
            { "download",            svc_download },
            { "playerinfo",          svc_playerinfo },
            { "packetentities",      svc_packetentities },
            { "deltapacketentities", svc_deltapacketentities },
            { "frame",               svc_frame },

            { "configblast",        svc_configblast },
            { "spawnbaselineblast", svc_spawnbaselineblast },
            { "level_restart",      svc_level_restart },
            { "damage",             svc_damage },
            { "locprint",           svc_locprint },
            { "fog",                svc_fog },
            { "waitingforplayers",  svc_waitingforplayers },
            { "bot_chat",           svc_bot_chat },
            { "poi",                svc_poi },
            { "help_path",          svc_help_path },
            { "muzzleflash3",       svc_muzzleflash3 },
            { "achievement",        svc_achievement },

            { "last", svc_last }
        });

    registry
        .enumeration("player_muzzle_t")
        .values({
            { "BLASTER",          MZ_BLASTER },
            { "MACHINEGUN",       MZ_MACHINEGUN },
            { "SHOTGUN",          MZ_SHOTGUN },
            { "CHAINGUN1",        MZ_CHAINGUN1 },
            { "CHAINGUN2",        MZ_CHAINGUN2 },
            { "CHAINGUN3",        MZ_CHAINGUN3 },
            { "RAILGUN",          MZ_RAILGUN },
            { "ROCKET",           MZ_ROCKET },
            { "GRENADE",          MZ_GRENADE },
            { "LOGIN",            MZ_LOGIN },
            { "LOGOUT",           MZ_LOGOUT },
            { "RESPAWN",          MZ_RESPAWN },
            { "BFG",              MZ_BFG },
            { "SSHOTGUN",         MZ_SSHOTGUN },
            { "HYPERBLASTER",     MZ_HYPERBLASTER },
            { "ITEMRESPAWN",      MZ_ITEMRESPAWN },
            { "IONRIPPER",        MZ_IONRIPPER },
            { "BLUEHYPERBLASTER", MZ_BLUEHYPERBLASTER },
            { "PHALANX",          MZ_PHALANX },
            { "BFG2",             MZ_BFG2 },
            { "PHALANX2",         MZ_PHALANX2 },

            { "ETF_RIFLE",   MZ_ETF_RIFLE },
            { "PROX",        MZ_PROX },
            { "ETF_RIFLE_2", MZ_ETF_RIFLE_2 },
            { "HEATBEAM",    MZ_HEATBEAM },
            { "BLASTER2",    MZ_BLASTER2 },
            { "TRACKER",     MZ_TRACKER },
            { "NUKE1",       MZ_NUKE1 },
            { "NUKE2",       MZ_NUKE2 },
            { "NUKE4",       MZ_NUKE4 },
            { "NUKE8",       MZ_NUKE8 },

            { "SILENCED", MZ_SILENCED },
            { "NONE",     MZ_NONE }
        });

    registry
        .enumeration("temp_event_t")
        .values({
            { "GUNSHOT",                 TE_GUNSHOT },
            { "BLOOD",                   TE_BLOOD },
            { "BLASTER",                 TE_BLASTER },
            { "RAILTRAIL",               TE_RAILTRAIL },
            { "SHOTGUN",                 TE_SHOTGUN },
            { "EXPLOSION1",              TE_EXPLOSION1 },
            { "EXPLOSION2",              TE_EXPLOSION2 },
            { "ROCKET_EXPLOSION",        TE_ROCKET_EXPLOSION },
            { "GRENADE_EXPLOSION",       TE_GRENADE_EXPLOSION },
            { "SPARKS",                  TE_SPARKS },
            { "SPLASH",                  TE_SPLASH },
            { "BUBBLETRAIL",             TE_BUBBLETRAIL },
            { "SCREEN_SPARKS",           TE_SCREEN_SPARKS },
            { "SHIELD_SPARKS",           TE_SHIELD_SPARKS },
            { "BULLET_SPARKS",           TE_BULLET_SPARKS },
            { "LASER_SPARKS",            TE_LASER_SPARKS },
            { "PARASITE_ATTACK",         TE_PARASITE_ATTACK },
            { "ROCKET_EXPLOSION_WATER",  TE_ROCKET_EXPLOSION_WATER },
            { "GRENADE_EXPLOSION_WATER", TE_GRENADE_EXPLOSION_WATER },
            { "MEDIC_CABLE_ATTACK",      TE_MEDIC_CABLE_ATTACK },
            { "BFG_EXPLOSION",           TE_BFG_EXPLOSION },
            { "BFG_BIGEXPLOSION",        TE_BFG_BIGEXPLOSION },
            { "BOSSTPORT",               TE_BOSSTPORT },
            { "BFG_LASER",               TE_BFG_LASER },
            { "GRAPPLE_CABLE",           TE_GRAPPLE_CABLE },
            { "WELDING_SPARKS",          TE_WELDING_SPARKS },
            { "GREENBLOOD",              TE_GREENBLOOD },
            { "BLUEHYPERBLASTER_DUMMY",  TE_BLUEHYPERBLASTER_DUMMY },
            { "PLASMA_EXPLOSION",        TE_PLASMA_EXPLOSION },
            { "TUNNEL_SPARKS",           TE_TUNNEL_SPARKS },

            { "BLASTER2",          TE_BLASTER2 },
            { "RAILTRAIL2",        TE_RAILTRAIL2 },
            { "FLAME",             TE_FLAME },
            { "LIGHTNING",         TE_LIGHTNING },
            { "DEBUGTRAIL",        TE_DEBUGTRAIL },
            { "PLAIN_EXPLOSION",   TE_PLAIN_EXPLOSION },
            { "FLASHLIGHT",        TE_FLASHLIGHT },
            { "FORCEWALL",         TE_FORCEWALL },
            { "HEATBEAM",          TE_HEATBEAM },
            { "MONSTER_HEATBEAM",  TE_MONSTER_HEATBEAM },
            { "STEAM",             TE_STEAM },
            { "BUBBLETRAIL2",      TE_BUBBLETRAIL2 },
            { "MOREBLOOD",         TE_MOREBLOOD },
            { "HEATBEAM_SPARKS",   TE_HEATBEAM_SPARKS },
            { "HEATBEAM_STEAM",    TE_HEATBEAM_STEAM },
            { "CHAINFIST_SMOKE",   TE_CHAINFIST_SMOKE },
            { "ELECTRIC_SPARKS",   TE_ELECTRIC_SPARKS },
            { "TRACKER_EXPLOSION", TE_TRACKER_EXPLOSION },
            { "TELEPORT_EFFECT",   TE_TELEPORT_EFFECT },
            { "DBALL_GOAL",        TE_DBALL_GOAL },
            { "WIDOWBEAMOUT",      TE_WIDOWBEAMOUT },
            { "NUKEBLAST",         TE_NUKEBLAST },
            { "WIDOWSPLASH",       TE_WIDOWSPLASH },
            { "EXPLOSION1_BIG",    TE_EXPLOSION1_BIG },
            { "EXPLOSION1_NP",     TE_EXPLOSION1_NP },
            { "FLECHETTE",         TE_FLECHETTE },

            { "BLUEHYPERBLASTER", TE_BLUEHYPERBLASTER },
            { "BFG_ZAP",          TE_BFG_ZAP },
            { "BERSERK_SLAM",     TE_BERSERK_SLAM },
            { "GRAPPLE_CABLE_2",  TE_GRAPPLE_CABLE_2 },
            { "POWER_SPLASH",     TE_POWER_SPLASH },
            { "LIGHTNING_BEAM",   TE_LIGHTNING_BEAM },
            { "EXPLOSION1_NL",    TE_EXPLOSION1_NL },
            { "EXPLOSION2_NL",    TE_EXPLOSION2_NL }
        });

    registry
        .enumeration("splash_color_t")
        .values({
            { "UNKNOWN",     SPLASH_UNKNOWN },
            { "SPARKS",      SPLASH_SPARKS },
            { "BLUE_WATER",  SPLASH_BLUE_WATER },
            { "BROWN_WATER", SPLASH_BROWN_WATER },
            { "SLIME",       SPLASH_SLIME },
            { "LAVA",        SPLASH_LAVA },
            { "BLOOD",       SPLASH_BLOOD },

            { "ELECTRIC", SPLASH_ELECTRIC }
        });

    registry
        .enumeration("server_flags_t")
        .values({
            { "NONE",         SERVER_FLAG_NONE },
            { "SLOW_TIME",    SERVER_FLAG_SLOW_TIME },
            { "INTERMISSION", SERVER_FLAG_INTERMISSION },
            { "LOADING",      SERVER_FLAG_LOADING },
        });
}

static q2as_edict_t *G_EdictForNum(uint32_t n)
{
    return svas.edicts + n;
}

static gclient_t *G_ClientForNum(uint32_t n)
{
    return svas.clients + n;
}

static void q2as_edict_t_reset(q2as_edict_t *ed)
{
    if (ed->as_obj)
        ed->as_obj->Release();

    memset(ed, 0, sizeof(*ed));
    ed->s.number = ed - svas.edicts;

    if (ed->s.number >= 1 && ed->s.number <= svas.maxclients)
        ed->client = (gclient_t *) &svas.clients[ed->s.number - 1];
}

static entity_state_t &Q2AS_entity_state_t_assign(const entity_state_t &other, entity_state_t &self)
{
    int n = self.number;
    self = other;
    self.number = n;
    return self;
}

static void q2as_sv_entity_t_set_netname(const std::string &s, sv_entity_t &sv)
{
    Q_strlcpy(sv.netname, s.c_str(), sizeof(sv.netname));
}

static void q2as_sv_entity_t_set_classname(const std::string &s, sv_entity_t &sv)
{
    // FIXME
    using cln = char[32];
    static cln estoy[MAX_EDICTS];
    static uint32_t loopin = 0;

    if (s.empty())
    {
        sv.classname = nullptr;
        return;
    }

    Q_strlcpy(estoy[loopin], s.c_str(), sizeof(cln));
    sv.classname = estoy[loopin];

    loopin = (loopin + 1) % MAX_EDICTS;
}

static void q2as_sv_entity_t_set_targetname(const std::string &s, sv_entity_t &sv)
{
    // FIXME
    using cln = char[32];
    static cln estoy[MAX_EDICTS];
    static uint32_t loopin = 0;

    if (s.empty())
    {
        sv.targetname = nullptr;
        return;
    }

    Q_strlcpy(estoy[loopin], s.c_str(), sizeof(cln));
    sv.targetname = estoy[loopin];

    loopin = (loopin + 1) % MAX_EDICTS;
}

static void Q2AS_RegisterEntity(q2as_registry &registry)
{
    registry
        .enumeration("renderfx_t")
        .values({
            { "NONE",           RF_NONE },
            { "MINLIGHT",       RF_MINLIGHT },
            { "VIEWERMODEL",    RF_VIEWERMODEL },
            { "WEAPONMODEL",    RF_WEAPONMODEL },
            { "FULLBRIGHT",     RF_FULLBRIGHT },
            { "DEPTHHACK",      RF_DEPTHHACK },
            { "TRANSLUCENT",    RF_TRANSLUCENT },
            { "NO_ORIGIN_LERP", RF_NO_ORIGIN_LERP },
            { "BEAM",           RF_BEAM },
            { "CUSTOMSKIN",     RF_CUSTOMSKIN },
            { "GLOW",           RF_GLOW },
            { "SHELL_RED",      RF_SHELL_RED },
            { "SHELL_GREEN",    RF_SHELL_GREEN },
            { "SHELL_BLUE",     RF_SHELL_BLUE },
            { "NOSHADOW",       RF_NOSHADOW },
            { "CASTSHADOW",     RF_CASTSHADOW },

            { "IR_VISIBLE",     RF_IR_VISIBLE },
            { "SHELL_DOUBLE",   RF_SHELL_DOUBLE },
            { "SHELL_HALF_DAM", RF_SHELL_HALF_DAM },
            { "USE_DISGUISE",   RF_USE_DISGUISE },

            { "SHELL_LITE_GREEN", RF_SHELL_LITE_GREEN },
            { "CUSTOM_LIGHT",     RF_CUSTOM_LIGHT },
            { "FLARE",            RF_FLARE },
            { "OLD_FRAME_LERP",   RF_OLD_FRAME_LERP },
            { "DOT_SHADOW",       RF_DOT_SHADOW },
            { "LOW_PRIORITY",     RF_LOW_PRIORITY },
            { "NO_LOD",           RF_NO_LOD },
            { "NO_STEREO",        RF_NO_STEREO },
            { "STAIR_STEP",       RF_STAIR_STEP },

            { "FLARE_LOCK_ANGLE", RF_FLARE_LOCK_ANGLE },
            { "BEAM_LIGHTNING",   RF_BEAM_LIGHTNING }
        });

    registry
        .enumeration("effects_t", "uint64")
        .values({
            { "NONE",             EF_NONE },
            { "ROTATE",           EF_ROTATE },
            { "GIB",              EF_GIB },
            { "BOB",              EF_BOB },
            { "BLASTER",          EF_BLASTER },
            { "ROCKET",           EF_ROCKET },
            { "GRENADE",          EF_GRENADE },
            { "HYPERBLASTER",     EF_HYPERBLASTER },
            { "BFG",              EF_BFG },
            { "COLOR_SHELL",      EF_COLOR_SHELL },
            { "POWERSCREEN",      EF_POWERSCREEN },
            { "ANIM01",           EF_ANIM01 },
            { "ANIM23",           EF_ANIM23 },
            { "ANIM_ALL",         EF_ANIM_ALL },
            { "ANIM_ALLFAST",     EF_ANIM_ALLFAST },
            { "FLIES",            EF_FLIES },
            { "QUAD",             EF_QUAD },
            { "PENT",             EF_PENT },
            { "TELEPORTER",       EF_TELEPORTER },
            { "FLAG1",            EF_FLAG1 },
            { "FLAG2",            EF_FLAG2 },
            { "IONRIPPER",        EF_IONRIPPER },
            { "GREENGIB",         EF_GREENGIB },
            { "BLUEHYPERBLASTER", EF_BLUEHYPERBLASTER },
            { "SPINNINGLIGHTS",   EF_SPINNINGLIGHTS },
            { "PLASMA",           EF_PLASMA },
            { "TRAP",             EF_TRAP },
            { "TRACKER",          EF_TRACKER },
            { "DOUBLE",           EF_DOUBLE },
            { "SPHERETRANS",      EF_SPHERETRANS },
            { "TAGTRAIL",         EF_TAGTRAIL },
            { "HALF_DAMAGE",      EF_HALF_DAMAGE },
            { "TRACKERTRAIL",     EF_TRACKERTRAIL },
            { "DUALFIRE",         EF_DUALFIRE },
            { "HOLOGRAM",         EF_HOLOGRAM },
            { "FLASHLIGHT",       EF_FLASHLIGHT },
            { "BARREL_EXPLODING", EF_BARREL_EXPLODING },
            { "TELEPORTER2",      EF_TELEPORTER2 },
            { "GRENADE_LIGHT",    EF_GRENADE_LIGHT },
            { "FIREBALL",         EF_FIREBALL }
        });

    registry
        .enumeration("entity_event_t", "uint8")
        .values({
            { "NONE",            EV_NONE },
            { "ITEM_RESPAWN",    EV_ITEM_RESPAWN },
            { "FOOTSTEP",        EV_FOOTSTEP },
            { "FALLSHORT",       EV_FALLSHORT },
            { "FALL",            EV_FALL },
            { "FALLFAR",         EV_FALLFAR },
            { "PLAYER_TELEPORT", EV_PLAYER_TELEPORT },
            { "OTHER_TELEPORT",  EV_OTHER_TELEPORT },
            { "OTHER_FOOTSTEP",  EV_OTHER_FOOTSTEP },
            { "LADDER_STEP",     EV_LADDER_STEP }
        });

    registry
        .type("entity_state_t", sizeof(entity_state_t), asOBJ_VALUE | asOBJ_POD)
        .properties({
            { "const uint32 number",       asOFFSET(entity_state_t, number) },
            { "vec3_t origin",             asOFFSET(entity_state_t, origin) },
            { "vec3_t angles",             asOFFSET(entity_state_t, angles) },
            { "vec3_t old_origin",         asOFFSET(entity_state_t, old_origin) },
            { "int32 modelindex",          asOFFSET(entity_state_t, modelindex) },
            { "int32 modelindex2",         asOFFSET(entity_state_t, modelindex2) },
            { "int32 modelindex3",         asOFFSET(entity_state_t, modelindex3) },
            { "int32 modelindex4",         asOFFSET(entity_state_t, modelindex4) },
            { "int32 frame",               asOFFSET(entity_state_t, frame) },
            { "int32 skinnum",             asOFFSET(entity_state_t, skinnum) },
            { "effects_t effects",         asOFFSET(entity_state_t, effects) },
            { "renderfx_t renderfx",       asOFFSET(entity_state_t, renderfx) },
            { "int32 sound",               asOFFSET(entity_state_t, sound) },
            { "entity_event_t event",      asOFFSET(entity_state_t, event) },
            { "float alpha",               asOFFSET(entity_state_t, alpha) },
            { "float scale",               asOFFSET(entity_state_t, scale) },
            { "float loop_volume",         asOFFSET(entity_state_t, loop_volume) },
            { "float loop_attenuation",    asOFFSET(entity_state_t, loop_attenuation) },
            { "int32 old_frame",           asOFFSET(entity_state_t, old_frame) },
            // these members are server-only
            { "const uint32 solid_bits",   asOFFSET(entity_state_t, solid) },
            { "const int32 owner_id",      asOFFSET(entity_state_t, owner) },
            { "const uint8 instance_bits", asOFFSET(entity_state_t, instance_bits) }
        })
        .methods({
            { "entity_state_t &opAssign(const entity_state_t &in)", asFUNCTION(Q2AS_entity_state_t_assign), asCALL_CDECL_OBJLAST }
        });

    registry
        .enumeration("svflags_t", "uint32")
        .values({
            { "NONE",       SVF_NONE },
            { "NOCLIENT",   SVF_NOCLIENT },
            { "DEADMONSTER",SVF_DEADMONSTER },
            { "MONSTER",    SVF_MONSTER },
            { "PLAYER",     SVF_PLAYER },
            { "BOT",        SVF_BOT },
            { "NOBOTS",     SVF_NOBOTS },
            { "RESPAWNING", SVF_RESPAWNING },
            { "PROJECTILE", SVF_PROJECTILE },
            { "INSTANCED",  SVF_INSTANCED },
            { "DOOR",       SVF_DOOR },
            { "NOCULL",     SVF_NOCULL },
            { "HULL",       SVF_HULL },
        });

    registry
        .enumeration("solid_t", "uint8")
        .values({
            { "NOT",     SOLID_NOT },
            { "TRIGGER", SOLID_TRIGGER },
            { "BBOX",    SOLID_BBOX },
            { "BSP",     SOLID_BSP }
        });

    // client handle; special handle, always active and allocated
    // by the host, wrapped by AngelScript.
    registry
        .type("gclient_t", sizeof(gclient_t), asOBJ_REF | asOBJ_NOCOUNT)
        .properties({
            { "player_state_t ps", asOFFSET(gclient_t, ps) },
            { "int ping",          asOFFSET(gclient_t, ping) }
        });

    // convenience
    {
        auto ti = registry.engine->GetTypeInfoByName("player_state_t");

        for (asUINT prop = 0; prop < ti->GetPropertyCount(); prop++)
        {
            const char *decl = ti->GetPropertyDeclaration(prop, false);
            int offset;
            ti->GetProperty(prop, nullptr, nullptr, nullptr, nullptr, &offset);

            Ensure(registry.engine->RegisterObjectProperty("gclient_t", decl, offset));
        }
    }

    registry
        .type("armorInfo_t", sizeof(armorInfo_t), asOBJ_VALUE | asOBJ_POD)
        .properties({
            { "int item_id",   asOFFSET(armorInfo_t, item_id) },
            { "int max_count", asOFFSET(armorInfo_t, max_count) }
        });

    registry
        .for_global()
        .properties({
            { "const int Max_Armor_Types", &Max_Armor_Types }
        });

    Q2AS_RegisterFixedArray<int, MAX_ITEMS>(registry, "inventoryArray_t", "int", asOBJ_APP_CLASS_ALLINTS);
    Q2AS_RegisterFixedArray<armorInfo_t, Max_Armor_Types>(registry, "armorInfoArray_t", "armorInfo_t", asOBJ_APP_CLASS_ALLINTS);

    // entity handle; special handle, always active and allocated
    // by the host, wrapped by AngelScript.

    registry
        .type("edict_t", sizeof(q2as_edict_t), asOBJ_REF | asOBJ_NOCOUNT)
        .properties({
            { "entity_state_t s",  asOFFSET(q2as_edict_t, s) },
            { "player_state_t ps", asOFFSET(gclient_t, ps), asOFFSET(edict_t, client), true },

            { "gclient_t @client",     asOFFSET(q2as_edict_t, client) },
            { "bool inuse",            asOFFSET(q2as_edict_t, inuse) },
            { "const bool linked",     asOFFSET(q2as_edict_t, linked) },
            { "const int32 linkcount", asOFFSET(q2as_edict_t, linkcount) },
            { "const int32 areanum",   asOFFSET(q2as_edict_t, areanum) },
            { "const int32 areanum2",  asOFFSET(q2as_edict_t, areanum2) },
            { "svflags_t svflags",     asOFFSET(q2as_edict_t, svflags) },
            { "vec3_t mins",           asOFFSET(q2as_edict_t, mins) },
            { "vec3_t maxs",           asOFFSET(q2as_edict_t, maxs) },
            { "vec3_t absmin",         asOFFSET(q2as_edict_t, absmin) },
            { "vec3_t absmax",         asOFFSET(q2as_edict_t, absmax) },
            { "vec3_t size",           asOFFSET(q2as_edict_t, size) },
            { "solid_t solid",         asOFFSET(q2as_edict_t, solid) },
            { "contents_t clipmask",   asOFFSET(q2as_edict_t, clipmask) },
            { "edict_t @owner",        asOFFSET(q2as_edict_t, owner) }
        })
        .methods({
            { "void reset()", asFUNCTION(q2as_edict_t_reset), asCALL_CDECL_OBJLAST }
        });

    // convenience
    {
        auto ti = registry.engine->GetTypeInfoByName("entity_state_t");

        for (asUINT prop = 0; prop < ti->GetPropertyCount(); prop++)
        {
            const char *name;
            const char *decl = ti->GetPropertyDeclaration(prop, false);
            int offset;
            ti->GetProperty(prop, &name, nullptr, nullptr, nullptr, &offset);

            if (strcmp(name, "solid_bits") == 0 ||
                strcmp(name, "owner_id") == 0)
                continue;

            Ensure(registry.engine->RegisterObjectProperty("edict_t", decl, offset));
        }
    }

    registry
        .type("sv_entity_t", sizeof(sv_entity_t), asOBJ_VALUE | asOBJ_POD)
        .properties({
            { "bool init",                   asOFFSET(sv_entity_t, init)  },
            { "uint64 ent_flags",            asOFFSET(sv_entity_t, ent_flags) },
            { "button_t buttons",            asOFFSET(sv_entity_t, buttons) },
            { "uint32 spawnflags",           asOFFSET(sv_entity_t, spawnflags) },
            { "int32 item_id",               asOFFSET(sv_entity_t, item_id) },
            { "int32 armor_type",            asOFFSET(sv_entity_t, armor_type) },
            { "int32 armor_value",           asOFFSET(sv_entity_t, armor_value) },
            { "int32 health",                asOFFSET(sv_entity_t, health) },
            { "int32 max_health",            asOFFSET(sv_entity_t, max_health) },
            { "int32 starting_health",       asOFFSET(sv_entity_t, starting_health) },
            { "int32 weapon",                asOFFSET(sv_entity_t, weapon) },
            { "int32 team",                  asOFFSET(sv_entity_t, team) },
            { "int32 lobby_usernum",         asOFFSET(sv_entity_t, lobby_usernum) },
            { "int32 respawntime",           asOFFSET(sv_entity_t, respawntime) },
            { "int32 viewheight",            asOFFSET(sv_entity_t, viewheight) },
            { "int32 last_attackertime",     asOFFSET(sv_entity_t, last_attackertime) },
            { "water_level_t waterlevel",    asOFFSET(sv_entity_t, waterlevel) },
            { "vec3_t viewangles",           asOFFSET(sv_entity_t, viewangles) },
            { "vec3_t viewforward",          asOFFSET(sv_entity_t, viewforward) },
            { "vec3_t velocity",             asOFFSET(sv_entity_t, velocity) },
            { "vec3_t start_origin",         asOFFSET(sv_entity_t, start_origin) },
            { "vec3_t end_origin",           asOFFSET(sv_entity_t, end_origin) },
            { "edict_t @ enemy",             asOFFSET(sv_entity_t, enemy) },
            { "edict_t @ ground_entity",     asOFFSET(sv_entity_t, ground_entity) },
            { "inventoryArray_t inventory",  asOFFSET(sv_entity_t, inventory) },
            { "armorInfoArray_t armor_info", asOFFSET(sv_entity_t, armor_info) }
        })
        .methods({
            { "void set_classname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_classname), asCALL_CDECL_OBJLAST },
            { "void set_targetname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_targetname), asCALL_CDECL_OBJLAST },
            { "void set_netname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_netname), asCALL_CDECL_OBJLAST }
        });

    registry
        .for_type("edict_t")
        .properties({
            { "sv_entity_t sv", asOFFSET(q2as_edict_t, sv) }
        });

    registry
        .for_global()
        .functions({
            { "edict_t @G_EdictForNum(uint n)",    asFUNCTION(G_EdictForNum),  asCALL_CDECL },
            { "gclient_t @G_ClientForNum(uint n)", asFUNCTION(G_ClientForNum), asCALL_CDECL }
        });

    Ensure(registry.engine->RegisterFuncdef("BoxEdictsResult_t BoxEdictsFilter_t(edict_t @, any @const)"));

    registry
        .interface("IASEntity")
        .methods({
            "edict_t @get_handle() const property"
        });

    registry
        .for_type("edict_t")
        .properties({
            { "IASEntity @as_obj", asOFFSET(q2as_edict_t, as_obj) }
        });
}

static void q2as_find_by_str(asIScriptGeneric *gen)
{
    int c = gen->GetArgCount();
    asIScriptObject *from = (asIScriptObject *) gen->GetArgAddress(0);
    const std::string *key = (std::string *) gen->GetArgAddress(1);
    const std::string *value = (std::string *) gen->GetArgAddress(2);

    q2as_edict_t *edict;
    asITypeInfo *typeinfo;

    typeinfo = svas.engine->GetTypeInfoById(gen->GetArgTypeId(0));

    // null = start at world
    if (from == nullptr)
    {
        edict = &svas.edicts[0];
    }
    else
    {
        auto func = typeinfo->GetMethodByName("get_handle");
        auto ctx = asGetActiveContext();
        ctx->PushState();
        ctx->Prepare(func);
        ctx->SetObject(from);
        svas.Execute(ctx);

        edict = *(q2as_edict_t **) ctx->GetAddressOfReturnValue();
        ctx->PopState();
        edict = &svas.edicts[edict->s.number + 1];
    }

    if (!edict)
    {
        gi.Com_Error("world has no attached entity");
        return;
    }

    // find property
    asUINT propId = 0;

    for (; propId < typeinfo->GetPropertyCount(); propId++)
    {
        const char *propName;
        typeinfo->GetProperty(propId, &propName);

        if (!strcmp(propName, key->c_str()))
            break;
    }

    if (propId == typeinfo->GetPropertyCount())
    {
        gi.Com_ErrorFmt("invalid key to search for in find_by_str: {}", *key);
        return;
    }

    for (; edict < &svas.edicts[globals.num_edicts]; edict++)
    {
        if (!edict->inuse)
            continue;
        if (!edict->as_obj)
            gi.Com_Error("missing as_obj on active entity");
        else if (edict->as_obj->GetTypeId() != typeinfo->GetTypeId())
            gi.Com_Error("as_obj has wrong type id");

        std::string *edict_val = (std::string *) edict->as_obj->GetAddressOfProperty(propId);

        if (!edict_val)
            continue;
        else if (!strcmp(value->c_str(), edict_val->c_str()))
        {
            *(asIScriptObject **) gen->GetAddressOfReturnLocation() = edict->as_obj;
            return;
        }
    }

    *(asIScriptObject **) gen->GetAddressOfReturnLocation() = nullptr;
}



static trace_t q2as_traceline(const vec3_t &start, const vec3_t &end, const q2as_edict_t *passent, contents_t contentmask)
{
    return gi.traceline(start, end, (edict_t *) passent, contentmask);
}

static int q2as_soundindex(const std::string &s)
{
    return gi.soundindex(s.c_str());
}

static int q2as_modelindex(const std::string &s)
{
    return gi.modelindex(s.c_str());
}

static int q2as_imageindex(const std::string &s)
{
    return gi.imageindex(s.c_str());
}

static void q2as_WriteString(const std::string &s)
{
    gi.WriteString(s.c_str());
}

static void q2as_Com_Error(const std::string &s)
{
    gi.Com_Error(s.c_str());
}

static void q2as_Com_Print(const std::string &s)
{
    gi.Com_Print(s.c_str());
}

static void q2as_cvar_set(const std::string &n, const std::string &v)
{
    gi.cvar_set(n.c_str(), v.c_str());
}

static void q2as_cvar_forceset(const std::string &n, const std::string &v)
{
    gi.cvar_forceset(n.c_str(), v.c_str());
}

static uint32_t q2as_Info_ValueForKey(const std::string &userinfo, const std::string &name, std::string &value)
{
    static char info_buffer[MAX_INFO_VALUE];
    size_t v;

    if ((v = gi.Info_ValueForKey(userinfo.c_str(), name.c_str(), info_buffer, sizeof(info_buffer))))
        value = info_buffer;
    else
        value = "";

    return v;
}

static bool q2as_Info_SetValueForKey(const std::string &in_userinfo, const std::string &name, const std::string &value, std::string &out_userinfo)
{
    static char userinfo[MAX_INFO_STRING];
    Q_strlcpy(userinfo, in_userinfo.data(), sizeof(userinfo));
    bool set = gi.Info_SetValueForKey(userinfo, name.c_str(), value.c_str());
    out_userinfo = userinfo;
    return set;
}

static void q2as_setmodel(edict_t *e, const std::string &s)
{
    gi.setmodel(e, s.c_str());
}

static void q2as_configstring(int index, const std::string &value)
{
    gi.configstring(index, value.c_str());
}

static std::string q2as_get_configstring(int index)
{
    return gi.get_configstring(index);
}

static uint32_t q2as_boxedicts(const vec3_t &mins, const vec3_t &maxs, CScriptArray *array, uint32_t max_count, solidity_area_t solidity, asIScriptFunction *cb, CScriptAny *any, bool append)
{
    static std::array<edict_t *, MAX_EDICTS> results;
    static asIScriptFunction *filter_cb;
    static asIScriptContext *ctxptr;

    filter_cb = cb;

    auto ctx = ctxptr = asGetActiveContext();

    ctxptr->PushState();

    size_t num = gi.BoxEdicts(mins, maxs, array ? results.data() : nullptr, max_count, solidity, [](edict_t *ent, void *obj) {
        ctxptr->Prepare(filter_cb);
        ctxptr->SetArgAddress(0, ent);
        ctxptr->SetArgObject(1, obj);
        svas.Execute(ctxptr);

        return (BoxEdictsResult_t) ctxptr->GetReturnDWord();
    }, (void *) any);

    ctxptr->PopState();

    if (array)
    {
        uint32_t offset = 0;

        if (append)
            offset = array->GetSize();

        array->Resize(offset + num);

        for (uint32_t i = 0; i < num; i++)
            array->SetValue(offset + i, &results[i]);
    }

    return num;
}

static int q2as_argc()
{
    return gi.argc();
}

static const std::string &q2as_args()
{
    return svas.cmd_args;
}

static const std::string &q2as_argv(int i)
{
    static std::string empty;

    if (i < 0 || i >= svas.cmd_argv.size())
        return empty;

    return svas.cmd_argv[i];
}

static void q2as_gi_Client_Print(asIScriptGeneric *gen)
{
    edict_t *ent = (edict_t *) gen->GetArgAddress(0);
    print_type_t level = (print_type_t) gen->GetArgDWord(1);
    const std::string *base = (std::string *) gen->GetArgAddress(2);
    std::string result = q2as_format_to(svas, gen, 3);
    gi.Client_Print(ent, level, result.c_str());
}

static void q2as_gi_Client_Print_Zero(edict_t *e, print_type_t t, const std::string &base)
{
    gi.Client_Print(e, t, base.c_str());
}

struct loc_args_t
{
    std::array<char[MAX_INFO_STRING], MAX_LOCALIZATION_ARGS> args;
    std::array<const char *, MAX_LOCALIZATION_ARGS> ptrs {
        args[0], args[1], args[2], args[3],
        args[4], args[5], args[6], args[7]
    };
    bool error = false;
};

static loc_args_t &q2as_set_loc_args(q2as_state_t &as, asIScriptGeneric *gen, int start_arg)
{
    static loc_args_t args;

    args.error = false;

    for (int i = start_arg, o = 0; i < gen->GetArgCount(); i++, o++)
    {
        int typeId = gen->GetArgTypeId(i);
        void *ref = gen->GetArgAddress(i);
        char *begin = args.args[o], *end = args.args[o] + MAX_INFO_STRING - 1;

        if (typeId == as.stringTypeId)
        {
            Q_strlcpy(begin, ((std::string *) ref)->data(), MAX_INFO_STRING);
            continue;
        }

        std::to_chars_result result;

        if (typeId == asTYPEID_INT8)
            result = std::to_chars(begin, end, *(int8_t *) ref);
        else if (typeId == asTYPEID_INT16)
            result = std::to_chars(begin, end, *(int16_t *) ref);
        else if (typeId == asTYPEID_INT32)
            result = std::to_chars(begin, end, *(int32_t *) ref);
        else if (typeId == asTYPEID_INT64)
            result = std::to_chars(begin, end, *(int64_t *) ref);
        else if (typeId == asTYPEID_UINT8)
            result = std::to_chars(begin, end, *(uint8_t *) ref);
        else if (typeId == asTYPEID_UINT16)
            result = std::to_chars(begin, end, *(uint16_t *) ref);
        else if (typeId == asTYPEID_UINT32)
            result = std::to_chars(begin, end, *(uint32_t *) ref);
        else if (typeId == asTYPEID_UINT64)
            result = std::to_chars(begin, end, *(uint64_t *) ref);
        else if (typeId == asTYPEID_FLOAT)
            result = std::to_chars(begin, end, *(float *) ref);
        else if (typeId == asTYPEID_DOUBLE)
            result = std::to_chars(begin, end, *(float *) ref);
        // TODO: vec3_t
        // TODO: gtime_t
        // TODO: edict_t*
        // TODO: ASEntity@
        // TODO: custom formatter
        else
        {
            asGetActiveContext()->SetException("unformattable");
            args.error = true;
            return args;
        }

        if (!result.ptr)
        {
            asGetActiveContext()->SetException("format error");
            args.error = true;
            return args;
        }

        *result.ptr = '\0';
    }

    return args;
}

static void q2as_Com_ErrorFmt(asIScriptGeneric *gen)
{
    std::string result = q2as_format_to(svas, gen, 0);
    gi.Com_Error(result.c_str());
}

static void q2as_Com_PrintFmt(asIScriptGeneric *gen)
{
    std::string result = q2as_format_to(svas, gen, 0);
    gi.Com_Print(result.c_str());
}

static void q2as_sv_format(asIScriptGeneric *gen)
{
    std::string result = q2as_format_to(svas, gen, 0);
    new(gen->GetAddressOfReturnLocation()) std::string(std::move(result));
}

static void q2as_gi_LocClient_Print(asIScriptGeneric *gen)
{
    edict_t *ent = (edict_t *) gen->GetArgAddress(0);
    print_type_t t = (print_type_t) gen->GetArgDWord(1);
    const std::string *base = (std::string *) gen->GetArgAddress(2);
    auto &args = q2as_set_loc_args(svas, gen, 3);

    if (args.error)
        return;

    gi.Loc_Print(ent, t, base->c_str(), args.ptrs.data(), gen->GetArgCount() - 2);
}

static void q2as_gi_LocClient_Print_Zero(edict_t *e, print_type_t t, const std::string &base)
{
    gi.Loc_Print(e, t, base.c_str(), nullptr, 0);
}

static void q2as_gi_LocCenter_Print(asIScriptGeneric *gen)
{
    edict_t *ent = (edict_t *) gen->GetArgAddress(0);
    const std::string *base = (std::string *) gen->GetArgAddress(1);
    auto &args = q2as_set_loc_args(svas, gen, 2);

    if (args.error)
        return;

    gi.Loc_Print(ent, PRINT_CENTER, base->c_str(), args.ptrs.data(), gen->GetArgCount() - 1);
}

static void q2as_gi_LocCenter_Print_Zero(edict_t *e, const std::string &base)
{
    gi.Loc_Print(e, PRINT_CENTER, base.c_str(), nullptr, 0);
}

static void q2as_gi_Center_Print(asIScriptGeneric *gen)
{
    edict_t *ent = (edict_t *) gen->GetArgAddress(0);
    const std::string *base = (std::string *) gen->GetArgAddress(1);
    std::string result = q2as_format_to(svas, gen, 2);
    gi.Center_Print(ent, result.c_str());
}

static void q2as_gi_Center_Print_Zero(edict_t *e, const std::string &base)
{
    gi.Center_Print(e, base.c_str());
}

static void q2as_gi_Loc_Print(asIScriptGeneric *gen)
{
    edict_t *ent = (edict_t *) gen->GetArgAddress(0);
    print_type_t t = (print_type_t) gen->GetArgDWord(1);
    const std::string *base = (std::string *) gen->GetArgAddress(2);
    auto &args = q2as_set_loc_args(svas, gen, 3);

    if (args.error)
        return;

    gi.Loc_Print(ent, t, base->c_str(), args.ptrs.data(), gen->GetArgCount() - 1);
}

static void q2as_gi_Loc_Print_Zero(edict_t *ent, print_type_t t, const std::string &base)
{
    gi.Loc_Print(ent, t, base.c_str(), nullptr, 0);
}

static void q2as_gi_LocBroadcast_Print(asIScriptGeneric *gen)
{
    print_type_t t = (print_type_t) gen->GetArgDWord(0);
    const std::string *base = (std::string *) gen->GetArgAddress(1);
    auto &args = q2as_set_loc_args(svas, gen, 2);

    if (args.error)
        return;

    gi.Loc_Print(nullptr, (print_type_t) (t | print_type_t::PRINT_BROADCAST), base->c_str(), args.ptrs.data(), gen->GetArgCount() - 1);
}

static void q2as_gi_LocBroadcast_Print_Zero(print_type_t t, const std::string &base)
{
    gi.Loc_Print(nullptr, (print_type_t) (t | print_type_t::PRINT_BROADCAST), base.c_str(), nullptr, 0);
}

static void q2as_gi_Broadcast_Print(asIScriptGeneric *gen)
{
    print_type_t t = (print_type_t) gen->GetArgDWord(0);
    std::string result = q2as_format_to(svas, gen, 1);
    gi.Broadcast_Print(t, result.c_str());
}

static void q2as_gi_Broadcast_Print_Zero(asIScriptGeneric *gen)
{
    print_type_t t = (print_type_t) gen->GetArgDWord(0);
    const std::string *base = (std::string *) gen->GetArgAddress(1);
    gi.Broadcast_Print(t, base->c_str());
}

static void q2as_local_sound_nullptr(edict_t *target, edict_t *ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs, uint32_t dupe_key)
{
    gi.game_import_t::local_sound(target, nullptr, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
}

static void Q2AS_AddCommandString_Zero(const std::string &str)
{
    gi.AddCommandString(str.c_str());
}

static void Q2AS_AddCommandString(asIScriptGeneric *gen)
{
    std::string result = q2as_format_to(svas, gen, 0);
    gi.AddCommandString(result.c_str());
}
static cvar_t *Q2AS_cvar(const std::string &name, const std::string &value, cvar_flags_t flags)
{
    return gi.cvar(name.c_str(), value.c_str(), flags);
}

static void Q2AS_Draw_OrientedWorldText(gvec3_cref_t origin, const std::string &text, const rgba_t &color, const float size, const float lifeTime, const bool depthTest)
{
    gi.Draw_OrientedWorldText(origin, text.c_str(), color, size, lifeTime, depthTest);
}

static void Q2AS_Draw_StaticWorldText(gvec3_cref_t origin, gvec3_cref_t angles, const std::string &text, const rgba_t &color, const float size, const float lifeTime, const bool depthTest)
{
    gi.Draw_StaticWorldText(origin, angles, text.c_str(), color, size, lifeTime, depthTest);
}

static void q2as_SendToClipBoard(const std::string &text)
{
    gi.SendToClipBoard(text.c_str());
}

static void Q2AS_RegisterGame(q2as_registry &registry)
{
    // game imports
    registry
        .for_global()
        .functions({
            { "trace_t gi_trace(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, edict_t @passent, contents_t contentmask) nodiscard",                                   asFUNCTION(gi.game_import_t::trace),               asCALL_CDECL },
            { "trace_t gi_traceline(const vec3_t &in start, const vec3_t &in end, edict_t @passent, contents_t contentmask) nodiscard",                                                                             asFUNCTION(q2as_traceline),                        asCALL_CDECL },
            { "trace_t gi_clip(edict_t @entity, const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, contents_t) nodiscard",                                                 asFUNCTION(gi.game_import_t::clip),                asCALL_CDECL },
            { "contents_t gi_pointcontents(const vec3_t &in point) nodiscard",                                                                                                                                      asFUNCTION(gi.game_import_t::pointcontents),       asCALL_CDECL },
            { "void gi_linkentity(edict_t @ent)",                                                                                                                                                                   asFUNCTION(gi.game_import_t::linkentity),          asCALL_CDECL },
            { "void gi_unlinkentity(edict_t @ent)",                                                                                                                                                                 asFUNCTION(gi.game_import_t::unlinkentity),        asCALL_CDECL },
            { "void gi_positioned_sound(const vec3_t &in origin, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs)",                                                     asFUNCTION(gi.game_import_t::positioned_sound),    asCALL_CDECL },
            { "void gi_sound(edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs)",                                                                                   asFUNCTION(gi.game_import_t::sound),               asCALL_CDECL },
            { "void gi_local_sound(edict_t @target, const vec3_t &in origin, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs, uint dupe_key)",                          asFUNCTION(gi.game_import_t::local_sound),         asCALL_CDECL },
            { "void gi_local_sound(edict_t @target, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs, uint dupe_key)",                                                   asFUNCTION(q2as_local_sound_nullptr),              asCALL_CDECL },
            { "int gi_soundindex(const string &in str)",                                                                                                                                                            asFUNCTION(q2as_soundindex),                       asCALL_CDECL },
            { "int gi_modelindex(const string &in str)",                                                                                                                                                            asFUNCTION(q2as_modelindex),                       asCALL_CDECL },
            { "int gi_imageindex(const string &in str)",                                                                                                                                                            asFUNCTION(q2as_imageindex),                       asCALL_CDECL },
            { "void gi_WriteByte(int c)",                                                                                                                                                                           asFUNCTION(gi.game_import_t::WriteByte),           asCALL_CDECL },
            { "void gi_WriteChar(int c)",                                                                                                                                                                           asFUNCTION(gi.game_import_t::WriteChar),           asCALL_CDECL },
            { "void gi_WriteShort(int c)",                                                                                                                                                                          asFUNCTION(gi.game_import_t::WriteShort),          asCALL_CDECL },
            { "void gi_WriteLong(int c)",                                                                                                                                                                           asFUNCTION(gi.game_import_t::WriteLong),           asCALL_CDECL },
            { "void gi_WriteFloat(float f)",                                                                                                                                                                        asFUNCTION(gi.game_import_t::WriteFloat),          asCALL_CDECL },
            { "void gi_WriteString(const string &in s)",                                                                                                                                                            asFUNCTION(q2as_WriteString),                      asCALL_CDECL },
            { "void gi_WritePosition(const vec3_t &in pos)",                                                                                                                                                        asFUNCTION(gi.game_import_t::WritePosition),       asCALL_CDECL },
            { "void gi_WriteDir(const vec3_t &in dir)",                                                                                                                                                             asFUNCTION(gi.game_import_t::WriteDir),            asCALL_CDECL },
            { "void gi_WriteAngle(float f)",                                                                                                                                                                        asFUNCTION(gi.game_import_t::WriteAngle),          asCALL_CDECL },
            { "void gi_WriteEntity(edict_t @ent)",                                                                                                                                                                  asFUNCTION(gi.game_import_t::WriteEntity),         asCALL_CDECL },
            { "void gi_multicast(const vec3_t &in origin, multicast_t to, bool reliable)",                                                                                                                          asFUNCTION(gi.game_import_t::multicast),           asCALL_CDECL },
            { "void gi_unicast(edict_t @ent, bool reliable, uint dupe_key)",                                                                                                                                        asFUNCTION(gi.game_import_t::unicast),             asCALL_CDECL },
            { "void gi_Com_Error(const string &in message)",                                                                                                                                                        asFUNCTION(q2as_Com_Error),                        asCALL_CDECL },
            { "void gi_Com_Error(const string &in fmt, const ?&in...)",                                                                                                                                             asFUNCTION(q2as_Com_ErrorFmt),                     asCALL_GENERIC },
            { "void gi_Com_Print(const string &in message)",                                                                                                                                                        asFUNCTION(q2as_Com_Print),                        asCALL_CDECL },
            { "void gi_Com_Print(const string &in fmt, const ?&in...)",                                                                                                                                             asFUNCTION(q2as_Com_PrintFmt),                     asCALL_GENERIC },
            { "void gi_cvar_set(const string &in var_name, const string &in value)",                                                                                                                                asFUNCTION(q2as_cvar_set),                         asCALL_CDECL },
            { "void gi_cvar_forceset(const string &in var_name, const string &in value)",                                                                                                                           asFUNCTION(q2as_cvar_forceset),                    asCALL_CDECL },
            { "uint gi_Info_ValueForKey(const string &in, const string &in, const string &out)",                                                                                                                    asFUNCTION(q2as_Info_ValueForKey),                 asCALL_CDECL },
            { "bool gi_Info_SetValueForKey(const string &in, const string &in, const string &in, string &out)",                                                                                                     asFUNCTION(q2as_Info_SetValueForKey),              asCALL_CDECL },
            { "void gi_configstring(int num, const string &in str)",                                                                                                                                                asFUNCTION(q2as_configstring),                     asCALL_CDECL },
            { "string gi_get_configstring(int num) nodiscard",                                                                                                                                                      asFUNCTION(q2as_get_configstring),                 asCALL_CDECL },
            { "uint gi_ServerFrame() nodiscard",                                                                                                                                                                    asFUNCTION(gi.ServerFrame),                        asCALL_CDECL },
            { "void gi_setmodel(edict_t @ent, const string &in name)",                                                                                                                                              asFUNCTION(q2as_setmodel),                         asCALL_CDECL },
            { "bool gi_inPHS(const vec3_t &in p1, const vec3_t &in p2, bool portals) nodiscard",                                                                                                                    asFUNCTION(gi.game_import_t::inPHS),               asCALL_CDECL },
            { "bool gi_inPVS(const vec3_t &in p1, const vec3_t &in p2, bool portals) nodiscard",                                                                                                                    asFUNCTION(gi.game_import_t::inPVS),               asCALL_CDECL },
            { "bool gi_AreasConnected(int area1, int area2) nodiscard",                                                                                                                                             asFUNCTION(gi.game_import_t::AreasConnected),      asCALL_CDECL },
            { "uint gi_BoxEdicts(const vec3_t &in mins, const vec3_t &in maxs, array<edict_t@> @+list, uint maxcount, solidity_area_t areatype, BoxEdictsFilter_t @+filter, any @const+ filter_data, bool append)", asFUNCTION(q2as_boxedicts),                        asCALL_CDECL },
            { "int gi_argc() nodiscard",                                                                                                                                                                            asFUNCTION(q2as_argc),                             asCALL_CDECL },
            { "const string &gi_args() nodiscard",                                                                                                                                                                  asFUNCTION(q2as_args),                             asCALL_CDECL },
            { "const string &gi_argv(int n) nodiscard",                                                                                                                                                             asFUNCTION(q2as_argv),                             asCALL_CDECL },
            { "void gi_LocClient_Print(edict_t @, print_type_t printlevel, const string &in message)",                                                                                                              asFUNCTION(q2as_gi_LocClient_Print_Zero),          asCALL_CDECL },
            { "void gi_LocClient_Print(edict_t @, print_type_t printlevel, const string &in fmt, const ?&in...)",                                                                                                   asFUNCTION(q2as_gi_LocClient_Print),               asCALL_GENERIC },
            { "void gi_Client_Print(edict_t @ent, print_type_t printlevel, const string &in message)",                                                                                                              asFUNCTION(q2as_gi_Client_Print_Zero),             asCALL_CDECL },
            { "void gi_Client_Print(edict_t @ent, print_type_t printlevel, const string &in fmt, const ?&in...)",                                                                                                   asFUNCTION(q2as_gi_Client_Print),                  asCALL_GENERIC },
            { "void gi_Center_Print(edict_t @ent, const string &in)",                                                                                                                                               asFUNCTION(q2as_gi_Center_Print_Zero),             asCALL_CDECL },
            { "void gi_Center_Print(edict_t @ent, const string &in, const ?&in...)",                                                                                                                                asFUNCTION(q2as_gi_Center_Print),                  asCALL_GENERIC },
            { "void gi_LocCenter_Print(edict_t @ent, const string &in message)",                                                                                                                                    asFUNCTION(q2as_gi_LocCenter_Print_Zero),          asCALL_CDECL },
            { "void gi_LocCenter_Print(edict_t @ent, const string &in fmt, const ?&in...)",                                                                                                                         asFUNCTION(q2as_gi_LocCenter_Print),               asCALL_GENERIC },
            { "void gi_Loc_Print(edict_t @ent, print_type_t printlevel, const string &in base)",                                                                                                                    asFUNCTION(q2as_gi_Loc_Print_Zero),                asCALL_CDECL },
            { "void gi_Loc_Print(edict_t @ent, print_type_t printlevel, const string &in base, const ?&in...)",                                                                                                     asFUNCTION(q2as_gi_Loc_Print),                     asCALL_GENERIC },
            { "void gi_LocBroadcast_Print(print_type_t printlevel, const string &in message)",                                                                                                                      asFUNCTION(q2as_gi_LocBroadcast_Print_Zero),       asCALL_CDECL },
            { "void gi_LocBroadcast_Print(print_type_t printlevel, const string &in fmt, const ?&in...)",                                                                                                           asFUNCTION(q2as_gi_LocBroadcast_Print),            asCALL_GENERIC },
            { "void gi_Broadcast_Print(print_type_t printlevel, const string &in message)",                                                                                                                         asFUNCTION(q2as_gi_LocBroadcast_Print_Zero),       asCALL_CDECL },
            { "void gi_Broadcast_Print(print_type_t printlevel, const string &in fmt, const ?&in...)",                                                                                                              asFUNCTION(q2as_gi_LocBroadcast_Print),            asCALL_GENERIC },
            { "void gi_SetAreaPortalState(int portalnum, bool open)",                                                                                                                                               asFUNCTION(gi.game_import_t::SetAreaPortalState),  asCALL_CDECL },
            { "cvar_t @gi_cvar(const string &in var_name, const string &in value, cvar_flags_t flags)",                                                                                                             asFUNCTION(Q2AS_cvar),                             asCALL_CDECL },
            { "void gi_AddCommandString(const string &in text)",                                                                                                                                                    asFUNCTION(Q2AS_AddCommandString_Zero),            asCALL_CDECL },
            { "void gi_AddCommandString(const string &in fmt, const ?&in...)",                                                                                                                                      asFUNCTION(Q2AS_AddCommandString),                 asCALL_GENERIC },
            { "void gi_Bot_RegisterEdict(edict_t @)",                                                                                                                                                               asFUNCTION(gi.game_import_t::Bot_RegisterEdict),   asCALL_CDECL },
            { "void gi_Bot_UnRegisterEdict(edict_t @)",                                                                                                                                                             asFUNCTION(gi.game_import_t::Bot_UnRegisterEdict), asCALL_CDECL }
        })
        .properties({
            { "const uint gi_tick_rate",     (const void *) &gi.tick_rate },
            { "const float gi_frame_time_s", (const void *) &gi.frame_time_s },
            { "const uint gi_frame_time_ms", (const void *) &gi.frame_time_ms }
        })
        .functions({
            { "void gi_Draw_Line(const vec3_t &in start, const vec3_t &in end, const rgba_t &in color, float lifeTime, bool depthTest)",                                                   asFUNCTION(gi.game_import_t::Draw_Line),     asCALL_CDECL },
            { "void gi_Draw_Point(const vec3_t &in point, float size, const rgba_t &in color, float lifeTime, bool depthTest)",                                                            asFUNCTION(gi.game_import_t::Draw_Point),    asCALL_CDECL },
            { "void gi_Draw_Circle(const vec3_t &in origin, float size, const rgba_t &in color, float lifeTime, bool depthTest)",                                                          asFUNCTION(gi.game_import_t::Draw_Circle),   asCALL_CDECL },
            { "void gi_Draw_Bounds(const vec3_t &in mins, const vec3_t &in maxs, const rgba_t &in color, float lifeTime, bool depthTest)",                                                 asFUNCTION(gi.game_import_t::Draw_Bounds),   asCALL_CDECL },
            { "void gi_Draw_Sphere(const vec3_t &in origin, float radius, const rgba_t &in color, float lifeTime, bool depthTest)",                                                        asFUNCTION(gi.game_import_t::Draw_Sphere),   asCALL_CDECL },
            { "void gi_Draw_OrientedWorldText(const vec3_t &in origin, const string &in text, const rgba_t &in color, float size, float lifeTime, bool depthTest)",                        asFUNCTION(Q2AS_Draw_OrientedWorldText),     asCALL_CDECL },
            { "void gi_Draw_StaticWorldText(const vec3_t &in origin, const vec3_t &in angles, const string &in text, const rgba_t &in color, float size, float lifeTime, bool depthTest)", asFUNCTION(Q2AS_Draw_StaticWorldText),       asCALL_CDECL },
            { "void gi_Draw_Cylinder(const vec3_t &in origin, float halfHeight, float radius, const rgba_t &in color, float lifeTime, bool depthTest)",                                    asFUNCTION(gi.game_import_t::Draw_Cylinder), asCALL_CDECL },
            { "void gi_Draw_Arrow(const vec3_t &in start, const vec3_t &in end, float size, const rgba_t &in lineColor, const rgba_t &in arrowColor, float lifeTime, bool depthTest)",     asFUNCTION(gi.game_import_t::Draw_Arrow),    asCALL_CDECL },

            { "void gi_SendToClipBoard(const string &in text)", asFUNCTION(q2as_SendToClipBoard), asCALL_CDECL }
        })
        .properties({
            { "const uint max_edicts",       (const void *) &globals.max_edicts },
            { "uint num_edicts",             (void *) &globals.num_edicts },
            { "const uint max_clients",      (const void *) &svas.maxclients },
            { "server_flags_t server_flags", (void *) &globals.server_flags }
        })
        .functions({
            { "T @+find_by_str<T>(T @+from, const string &in member, const string &in value) nodiscard", asFUNCTION(q2as_find_by_str), asCALL_GENERIC }
        });
}

static std::unordered_map<int, shadow_light_data_t> shadowlightinfo;

const shadow_light_data_t *Q2AS_GetShadowLightData(int32_t entity_number)
{
    if (auto f = shadowlightinfo.find(entity_number); f != shadowlightinfo.end())
        return &f->second;

    return nullptr;
}

void q2as_gi_SetShadowLightData(uint32_t index, const shadow_light_data_t &data)
{
    shadowlightinfo.insert_or_assign(index, data);
}

void q2as_gi_GetShadowLightData(uint32_t index, shadow_light_data_t &data)
{
    if (auto f = shadowlightinfo.find(index); f != shadowlightinfo.end())
        data = f->second;
    else
        data = {};
}

void q2as_gi_RemoveShadowLightData(int index)
{
    shadowlightinfo.erase(index);
}

static void Q2AS_RegisterShadowLightData(q2as_registry &registry)
{
    registry
        .enumeration("shadow_light_type_t")
        .values({
            { "point", (asINT64) shadow_light_type_t::point },
            { "cone", (asINT64) shadow_light_type_t::cone }
        });

    registry
        .type("shadow_light_data_t", sizeof(shadow_light_data_t), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<shadow_light_data_t>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const shadow_light_data_t &in)", asFUNCTION(Q2AS_init_construct_copy<shadow_light_data_t>), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "shadow_light_data_t &opAssign (const shadow_light_data_t &in)", asFUNCTION(Q2AS_assign<shadow_light_data_t>), asCALL_CDECL_OBJLAST }
        })
        .properties({
            { "shadow_light_type_t lighttype", asOFFSET(shadow_light_data_t, lighttype) },
            { "float radius",                  asOFFSET(shadow_light_data_t, radius) },
            { "int resolution",                asOFFSET(shadow_light_data_t, resolution) },
            { "float intensity",               asOFFSET(shadow_light_data_t, intensity) },
            { "float fade_start",              asOFFSET(shadow_light_data_t, fade_start) },
            { "float fade_end",                asOFFSET(shadow_light_data_t, fade_end) },
            { "int lightstyle",                asOFFSET(shadow_light_data_t, lightstyle) },
            { "float coneangle",               asOFFSET(shadow_light_data_t, coneangle) },
            { "vec3_t conedirection",          asOFFSET(shadow_light_data_t, conedirection) }
        });

    registry
        .for_global()
        .functions({
            { "void gi_SetShadowLightData(uint, const shadow_light_data_t &in)", asFUNCTION(q2as_gi_SetShadowLightData),    asCALL_CDECL },
            { "void gi_GetShadowLightData(uint, shadow_light_data_t &out)",      asFUNCTION(q2as_gi_GetShadowLightData),    asCALL_CDECL },
            { "void gi_RemoveShadowLightData(int)",                              asFUNCTION(q2as_gi_RemoveShadowLightData), asCALL_CDECL }
        });
}

struct q2as_PathInfo : q2as_ref_t
{
    PathInfo info;
    std::vector<vec3_t> points;

    const vec3_t &getPathPoint(uint32_t n) const
    {
        if (n >= points.size())
            return vec3_origin;

        return points[n];
    }
};

static bool q2as_gi_GetPathToGoal(const PathRequest &in, q2as_PathInfo &out)
{
    new(&out) q2as_PathInfo {};
    // just to be sure nobody does any fun nonsense...
    // 256 should be more than enough.
    static vec3_t points[256];
    const_cast<PathRequest &>(in).pathPoints = { points, min((int64_t) std::extent_v<decltype(points)>, in.pathPoints.count) };

    bool result = gi.GetPathToGoal(in, out.info);

    if (result && out.info.numPathPoints)
    {
        out.points.resize(out.info.numPathPoints);
        memcpy(out.points.data(), in.pathPoints.array, sizeof(vec3_t) * out.info.numPathPoints);
    }

    return result;
}

static void Q2AS_RegisterPathFinding(q2as_registry &registry)
{
    registry
        .enumeration("GoalReturnCode")
        .values({
            { "Error",      GoalReturnCode::Error },
            { "Started",    GoalReturnCode::Started },
            { "InProgress", GoalReturnCode::InProgress },
            { "Finished",   GoalReturnCode::Finished }
        });

    registry
        .enumeration("gesture_type")
        .values({
            { "NONE",          GESTURE_NONE },
            { "FLIP_OFF",      GESTURE_FLIP_OFF },
            { "SALUTE",        GESTURE_SALUTE },
            { "TAUNT",         GESTURE_TAUNT },
            { "WAVE",          GESTURE_WAVE },
            { "POINT",         GESTURE_POINT },
            { "POINT_NO_PING", GESTURE_POINT_NO_PING },
            { "MAX",           GESTURE_MAX }
        });

    registry
        .enumeration("PathReturnCode")
        .values({
            { "ReachedGoal",           (asINT64) PathReturnCode::ReachedGoal },
            { "ReachedPathEnd",        (asINT64) PathReturnCode::ReachedPathEnd },
            { "TraversalPending",      (asINT64) PathReturnCode::TraversalPending },
            { "RawPathFound",          (asINT64) PathReturnCode::RawPathFound },
            { "InProgress",            (asINT64) PathReturnCode::InProgress },
            { "StartPathErrors",       (asINT64) PathReturnCode::StartPathErrors },
            { "InvalidStart",          (asINT64) PathReturnCode::InvalidStart },
            { "InvalidGoal",           (asINT64) PathReturnCode::InvalidGoal },
            { "NoNavAvailable",        (asINT64) PathReturnCode::NoNavAvailable },
            { "NoStartNode",           (asINT64) PathReturnCode::NoStartNode },
            { "NoGoalNode",            (asINT64) PathReturnCode::NoGoalNode },
            { "NoPathFound",           (asINT64) PathReturnCode::NoPathFound },
            { "MissingWalkOrSwimFlag", (asINT64) PathReturnCode::MissingWalkOrSwimFlag }
        });

    registry
        .enumeration("PathLinkType")
        .values({
            { "Walk",         (asINT64) PathLinkType::Walk },
            { "WalkOffLedge", (asINT64) PathLinkType::WalkOffLedge },
            { "LongJump",     (asINT64) PathLinkType::LongJump },
            { "BarrierJump",  (asINT64) PathLinkType::BarrierJump },
            { "Elevator",     (asINT64) PathLinkType::Elevator }
        });

    registry
        .enumeration("PathFlags")
        .values({
            { "All",          PathFlags::All },
            { "Water",        PathFlags::Water },
            { "Walk",         PathFlags::Walk },
            { "WalkOffLedge", PathFlags::WalkOffLedge },
            { "LongJump",     PathFlags::LongJump },
            { "BarrierJump",  PathFlags::BarrierJump },
            { "Elevator",     PathFlags::Elevator },
        });

    registry
        .type("PathDebugSettings", sizeof(PathRequest::DebugSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::DebugSettings>())
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                            asFUNCTION(Q2AS_init_construct<PathRequest::DebugSettings>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const PathDebugSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::DebugSettings>), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "PathDebugSettings &opAssign (const PathDebugSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::DebugSettings>), asCALL_CDECL_OBJLAST }
        })
        .properties({
            { "float drawTime", asOFFSET(PathRequest::DebugSettings, drawTime) }
        });

    registry
        .type("PathNodeSettings", sizeof(PathRequest::NodeSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::NodeSettings>())
        .properties({
            { "bool ignoreNodeFlags", asOFFSET(PathRequest::NodeSettings, ignoreNodeFlags) },
            { "float minHeight",      asOFFSET(PathRequest::NodeSettings, minHeight) },
            { "float maxHeight",      asOFFSET(PathRequest::NodeSettings, maxHeight) },
            { "float radius",         asOFFSET(PathRequest::NodeSettings, radius) }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                           asFUNCTION(Q2AS_init_construct<PathRequest::NodeSettings>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const PathNodeSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::NodeSettings>), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "PathNodeSettings &opAssign (const PathNodeSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::NodeSettings>), asCALL_CDECL_OBJLAST }
        });

    registry
        .type("PathTraversalSettings", sizeof(PathRequest::TraversalSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::TraversalSettings>())
        .properties({
            { "float dropHeight", asOFFSET(PathRequest::TraversalSettings, dropHeight) },
            { "float jumpHeight", asOFFSET(PathRequest::TraversalSettings, jumpHeight) }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                                asFUNCTION(Q2AS_init_construct<PathRequest::TraversalSettings>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const PathTraversalSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::TraversalSettings>), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "PathTraversalSettings &opAssign (const PathTraversalSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::TraversalSettings>), asCALL_CDECL_OBJLAST }
        });

    registry
        .type("PathRequest", sizeof(PathRequest), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest>())
        .properties({
            { "vec3_t start",        asOFFSET(PathRequest, start) },
            { "vec3_t goal",         asOFFSET(PathRequest, goal) },
            { "PathFlags pathFlags", asOFFSET(PathRequest, pathFlags) },
            { "float moveDist",      asOFFSET(PathRequest, moveDist) },

            { "PathDebugSettings debugging",      asOFFSET(PathRequest, debugging) },
            { "PathNodeSettings nodeSearch",      asOFFSET(PathRequest, nodeSearch) },
            { "PathTraversalSettings traversals", asOFFSET(PathRequest, traversals) },

            { "int64 maxPathPoints", asOFFSET(PathRequest, pathPoints.count) }
        })
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                      asFUNCTION(Q2AS_init_construct<PathRequest>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const PathRequest &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest>), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "PathRequest &opAssign (const PathRequest &in)", asFUNCTION(Q2AS_assign<PathRequest>), asCALL_CDECL_OBJLAST }
        });

    registry
        .type("PathInfo", sizeof(q2as_PathInfo), asOBJ_REF)
        .properties({
            { "uint numPathPoints",        asOFFSET(q2as_PathInfo, info.numPathPoints) },
            { "float pathDistSqr",         asOFFSET(q2as_PathInfo, info.pathDistSqr) },
            { "vec3_t firstMovePoint",     asOFFSET(q2as_PathInfo, info.firstMovePoint) },
            { "vec3_t secondMovePoint",    asOFFSET(q2as_PathInfo, info.secondMovePoint) },
            { "PathLinkType pathLinkType", asOFFSET(q2as_PathInfo, info.pathLinkType) },
            { "PathReturnCode returnCode", asOFFSET(q2as_PathInfo, info.returnCode) }
        })
        .behaviors({
            { asBEHAVE_FACTORY, "PathInfo@ f()", asFUNCTION((Q2AS_Factory<q2as_PathInfo, q2as_sv_state_t>)), asCALL_GENERIC },
            { asBEHAVE_ADDREF, "void f()",       asFUNCTION((Q2AS_AddRef<q2as_PathInfo>)),                   asCALL_GENERIC },
            { asBEHAVE_RELEASE, "void f()",      asFUNCTION((Q2AS_Release<q2as_PathInfo, q2as_sv_state_t>)), asCALL_GENERIC }
        })
        .methods({
            { "PathInfo &opAssign (const PathInfo &in)",  asFUNCTION(Q2AS_assign<q2as_PathInfo>), asCALL_CDECL_OBJLAST },
            { "const vec3_t &getPathPoint(uint i) const", asMETHOD(q2as_PathInfo, getPathPoint),  asCALL_THISCALL }
        });

    registry
        .for_global()
        .functions({
            { "bool gi_GetPathToGoal(const PathRequest &in, PathInfo &out)", asFUNCTION(q2as_gi_GetPathToGoal), asCALL_CDECL }
        });
}

// unused import
static void Q2AS_Pmove(pmove_t *pmove)
{
}

// Q2 AngelScript support entry point. If AngelScript
// support is used, the regular C++ API is rerouted
// to AngelScript instead.
// For Q2AS to load, the following three conditions must be true:
// - cvar "q2as_use" must be 1
// - the file "scripts/init.as" must exist in the current mod dir
// - "scripts/init.as" (and the AS engine) must successfully
//   initialize.
// Any of these failing will cause the regular game API to load.
game_export_t *Q2AS_GetGameAPI()
{
    const cvar_t *q2as_use = gi.cvar("q2as_use_game", "1", CVAR_NOFLAGS);

    if (q2as_use->integer != 1)
        return nullptr;

    if (!svas.Load(q2as_sv_state_t::AllocStatic, q2as_sv_state_t::FreeStatic))
        return nullptr;

    svas.instrumentation = gi.cvar("q2as_instrumentation", "0", CVAR_NOFLAGS);
    svas.instrumenting = svas.instrumentation->integer & 1;

    constexpr library_reg_t *const libraries[] = {
        Q2AS_RegisterThirdParty,
        Q2AS_RegisterLimits,
        Q2AS_RegisterMath,
        Q2AS_RegisterVec2,
        Q2AS_RegisterVec3,
        Q2AS_RegisterDynamicBitset,
        Q2AS_RegisterUtil,
        Q2AS_RegisterTime,
        Q2AS_RegisterRandom,
        Q2AS_RegisterStringEx,
        Q2AS_RegisterCvar,
        Q2AS_RegisterDebugging,
        Q2AS_RegisterReflection,
        Q2AS_RegisterStringHashSet,
        Q2AS_RegisterPlayerState,
        Q2AS_RegisterGameImports,
        Q2AS_RegisterEntity,
        Q2AS_RegisterTrace,
        Q2AS_RegisterPmove,
        Q2AS_RegisterPmoveFactory<q2as_sv_state_t>,
        Q2AS_RegisterImportTypes,
        Q2AS_RegisterJson,
        Q2AS_RegisterGame,
        Q2AS_RegisterPathFinding,
        Q2AS_RegisterShadowLightData,
        Q2AS_RegisterTokenizer
    };

    if (!svas.LoadLibraries(libraries, std::extent_v<decltype(libraries)>))
        return nullptr;

    if (!svas.CreateMainModule())
        return nullptr;

    if (!svas.LoadFiles("game", svas.mainModule))
        return nullptr;

    if (!svas.Build())
        return nullptr;

    svas.LoadFunctions();

    globals.PreInit = Q2AS_PreInitGame;
    globals.Init = Q2AS_InitGame;
    globals.Shutdown = Q2AS_ShutdownGame;
    globals.SpawnEntities = Q2AS_SpawnEntities;
    globals.WriteGameJson = Q2AS_WriteGameJson;
    globals.ReadGameJson = Q2AS_ReadGameJson;
    globals.WriteLevelJson = Q2AS_WriteLevelJson;
    globals.ReadLevelJson = Q2AS_ReadLevelJson;
    globals.CanSave = Q2AS_CanSave;
    globals.ClientChooseSlot = Q2AS_ClientChooseSlot;
    globals.ClientConnect = Q2AS_ClientConnect;
    globals.ClientBegin = Q2AS_ClientBegin;
    globals.ClientUserinfoChanged = Q2AS_ClientUserinfoChanged;
    globals.ClientDisconnect = Q2AS_ClientDisconnect;
    globals.ClientCommand = Q2AS_ClientCommand;
    globals.ClientThink = Q2AS_ClientThink;
    globals.RunFrame = Q2AS_RunFrame;
    globals.PrepFrame = Q2AS_PrepFrame;
    globals.ServerCommand = Q2AS_ServerCommand;
    globals.Pmove = Q2AS_Pmove;
    globals.Bot_SetWeapon = Q2AS_Bot_SetWeapon;
    globals.Bot_TriggerEdict = Q2AS_Bot_TriggerEdict;
    globals.Bot_UseItem = Q2AS_Bot_UseItem;
    globals.Bot_GetItemID = Q2AS_Bot_GetItemID;
    globals.Edict_ForceLookAtPoint = Q2AS_Edict_ForceLookAtPoint;
    globals.Bot_PickedUpItem = Q2AS_Bot_PickedUpItem;
    globals.Entity_IsVisibleToPlayer = Q2AS_Entity_IsVisibleToPlayer;
    globals.GetShadowLightData = Q2AS_GetShadowLightData;

    globals.edict_size = sizeof(q2as_edict_t);

    return &globals;
}