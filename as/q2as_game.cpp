#include "q2as_game.h"
#include "../g_local.h"
#include <chrono>

#include "q2as_reg.h"
#include "q2as_fixedarray.h"
#include "q2as_stringex.h"
#include "q2as_json.h"
#include "thirdparty/scriptany/scriptany.h"
#include "thirdparty/scriptarray/scriptarray.h"

#include "q2as_modules.h"
#include "q2as_pmove.h"

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
enum { STAT_LAYOUTS = 13 };

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
}

static void    Q2AS_Bot_SetWeapon(edict_t * botEdict, const int weaponIndex, const bool instantSwitch)
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

static void    Q2AS_Bot_TriggerEdict(edict_t * botEdict, edict_t * edict)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
	ctx->Prepare(svas.Bot_TriggerEdict);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgAddress(1, edict);
	ctx.Execute();
}

static void    Q2AS_Bot_UseItem(edict_t * botEdict, const int32_t itemID)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
	ctx->Prepare(svas.Bot_UseItem);
    ctx->SetArgAddress(0, botEdict);
    ctx->SetArgDWord(1, itemID);
	ctx.Execute();
}

static int32_t Q2AS_Bot_GetItemID(const char * classname)
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

static void    Q2AS_Edict_ForceLookAtPoint(edict_t * edict, gvec3_cref_t point)
{
    if (q2as_state_t::CheckExceptionState())
        return;

    auto ctx = svas.RequestContext();
	ctx->Prepare(svas.Edict_ForceLookAtPoint);
    ctx->SetArgAddress(0, edict);
    ctx->SetArgAddress(1, (void *) &point);
	ctx.Execute();
}

static bool    Q2AS_Bot_PickedUpItem(edict_t * botEdict, edict_t * itemEdict)
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

static bool Q2AS_Entity_IsVisibleToPlayer(edict_t* ent, edict_t* player)
{
	return false;
}

static bool Q2AS_RegisterGameImports(asIScriptEngine *engine)
{
#define Q2AS_OBJECT gesture_type_t
#define Q2AS_ENUM_PREFIX GESTURE_

	EnsureRegisteredEnumRaw("gesture_type_t");
	EnsureRegisteredEnumValueRaw("gesture_type_t", "NONE", GESTURE_NONE);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "FLIP_OFF", GESTURE_FLIP_OFF);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "SALUTE", GESTURE_SALUTE);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "TAUNT", GESTURE_TAUNT);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "WAVE", GESTURE_WAVE);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "POINT", GESTURE_POINT);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "POINT_NO_PING", GESTURE_POINT_NO_PING);
	EnsureRegisteredEnumValueRaw("gesture_type_t", "MAX", GESTURE_MAX);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT print_type_t
#define Q2AS_ENUM_PREFIX PRINT_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(PRINT_, LOW);
	EnsureRegisteredEnumValue(PRINT_, MEDIUM);
	EnsureRegisteredEnumValue(PRINT_, HIGH);
	EnsureRegisteredEnumValue(PRINT_, CHAT);
	EnsureRegisteredEnumValue(PRINT_, TYPEWRITER);
	EnsureRegisteredEnumValue(PRINT_, CENTER);
	EnsureRegisteredEnumValue(PRINT_, TTS);

	EnsureRegisteredEnumValue(PRINT_, BROADCAST);
	EnsureRegisteredEnumValue(PRINT_, NO_NOTIFY);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT BoxEdictsResult_t

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueRaw("BoxEdictsResult_t", "Keep", (int) BoxEdictsResult_t::Keep);
	EnsureRegisteredEnumValueRaw("BoxEdictsResult_t", "Skip", (int) BoxEdictsResult_t::Skip);
	EnsureRegisteredEnumValueRaw("BoxEdictsResult_t", "End", (int) BoxEdictsResult_t::End);
	EnsureRegisteredEnumValueRaw("BoxEdictsResult_t", "Flags", (int) BoxEdictsResult_t::Flags);

#undef Q2AS_OBJECT
	
#define Q2AS_OBJECT multicast_t
#define Q2AS_ENUM_PREFIX MULTICAST_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(MULTICAST_, ALL);
	EnsureRegisteredEnumValue(MULTICAST_, PHS);
	EnsureRegisteredEnumValue(MULTICAST_, PVS);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	

#define Q2AS_OBJECT solidity_area_t
#define Q2AS_ENUM_PREFIX AREA_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(AREA_, SOLID);
	EnsureRegisteredEnumValue(AREA_, TRIGGERS);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT soundchan_t
#define Q2AS_ENUM_PREFIX CHAN_
	
	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(CHAN_, AUTO);
	EnsureRegisteredEnumValue(CHAN_, WEAPON);
	EnsureRegisteredEnumValue(CHAN_, VOICE);
	EnsureRegisteredEnumValue(CHAN_, ITEM);
	EnsureRegisteredEnumValue(CHAN_, BODY);
	EnsureRegisteredEnumValue(CHAN_, AUX);
	EnsureRegisteredEnumValue(CHAN_, FOOTSTEP);
	EnsureRegisteredEnumValue(CHAN_, AUX3);

	EnsureRegisteredEnumValue(CHAN_, NO_PHS_ADD);
	EnsureRegisteredEnumValue(CHAN_, RELIABLE);
	EnsureRegisteredEnumValue(CHAN_, FORCE_POS);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT svc_t
#define Q2AS_ENUM_PREFIX svc_
	
	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, bad);

	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, muzzleflash);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, muzzleflash2);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, temp_entity);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, layout);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, inventory);

	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, nop);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, disconnect);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, reconnect);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, sound);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, print);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, stufftext);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, serverdata);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, configstring);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, spawnbaseline);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, centerprint);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, download);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, playerinfo);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, packetentities);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, deltapacketentities);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, frame);

	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, configblast);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, spawnbaselineblast);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, level_restart);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, damage);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, locprint);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, fog);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, waitingforplayers);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, bot_chat);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, poi);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, help_path);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, muzzleflash3);
	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, achievement);

	EnsureRegisteredEnumValueGlobalNoPrefix(svc_, last);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT player_muzzle_t
#define Q2AS_ENUM_PREFIX MZ_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, MACHINEGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, SHOTGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, CHAINGUN1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, CHAINGUN2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, CHAINGUN3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, RAILGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, ROCKET);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, GRENADE);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, LOGIN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, LOGOUT);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, RESPAWN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, BFG);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, SSHOTGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, HYPERBLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, ITEMRESPAWN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, IONRIPPER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, BLUEHYPERBLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, PHALANX);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, BFG2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, PHALANX2);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, ETF_RIFLE);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, PROX);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, ETF_RIFLE_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, HEATBEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, BLASTER2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, TRACKER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, NUKE1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, NUKE2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, NUKE4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, NUKE8);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, SILENCED);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ_, NONE);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT temp_event_t
#define Q2AS_ENUM_PREFIX TE_

	EnsureRegisteredEnum();

	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GUNSHOT);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BLOOD);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, RAILTRAIL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, SHOTGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION1);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION2);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, ROCKET_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GRENADE_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, SPLASH);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BUBBLETRAIL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, SCREEN_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, SHIELD_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BULLET_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, LASER_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, PARASITE_ATTACK);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, ROCKET_EXPLOSION_WATER);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GRENADE_EXPLOSION_WATER);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, MEDIC_CABLE_ATTACK);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BFG_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BFG_BIGEXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BOSSTPORT);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BFG_LASER);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GRAPPLE_CABLE);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, WELDING_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GREENBLOOD);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BLUEHYPERBLASTER_DUMMY);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, PLASMA_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, TUNNEL_SPARKS);

	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BLASTER2);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, RAILTRAIL2);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, FLAME);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, LIGHTNING);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, DEBUGTRAIL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, PLAIN_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, FLASHLIGHT);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, FORCEWALL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, HEATBEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, MONSTER_HEATBEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, STEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BUBBLETRAIL2);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, MOREBLOOD);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, HEATBEAM_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, HEATBEAM_STEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, CHAINFIST_SMOKE);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, ELECTRIC_SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, TRACKER_EXPLOSION);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, TELEPORT_EFFECT);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, DBALL_GOAL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, WIDOWBEAMOUT);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, NUKEBLAST);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, WIDOWSPLASH);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION1_BIG);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION1_NP);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, FLECHETTE);

	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BLUEHYPERBLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BFG_ZAP);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, BERSERK_SLAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, GRAPPLE_CABLE_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, POWER_SPLASH);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, LIGHTNING_BEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION1_NL);
	EnsureRegisteredEnumValueGlobalNoPrefix(TE_, EXPLOSION2_NL);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT splash_color_t
#define Q2AS_ENUM_PREFIX SPLASH_

	EnsureRegisteredEnum();
	
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, UNKNOWN);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, SPARKS);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, BLUE_WATER);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, BROWN_WATER);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, SLIME);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, LAVA);
	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, BLOOD);

	EnsureRegisteredEnumValueGlobalNoPrefix(SPLASH_, ELECTRIC);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT server_flags_t
#define Q2AS_ENUM_PREFIX SERVER_FLAG_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(SERVER_FLAGS_, NONE);
	EnsureRegisteredEnumValue(SERVER_FLAG_,  SLOW_TIME);
	EnsureRegisteredEnumValue(SERVER_FLAG_,  INTERMISSION);
	EnsureRegisteredEnumValue(SERVER_FLAG_,  LOADING);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

    return true;
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

static bool Q2AS_RegisterEntity(asIScriptEngine *engine)
{
#define Q2AS_OBJECT renderfx_t
#define Q2AS_ENUM_PREFIX RF_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(RF_, NONE);
	EnsureRegisteredEnumValue(RF_, MINLIGHT);
	EnsureRegisteredEnumValue(RF_, VIEWERMODEL);
	EnsureRegisteredEnumValue(RF_, WEAPONMODEL);
	EnsureRegisteredEnumValue(RF_, FULLBRIGHT);
	EnsureRegisteredEnumValue(RF_, DEPTHHACK);
	EnsureRegisteredEnumValue(RF_, TRANSLUCENT);
	EnsureRegisteredEnumValue(RF_, NO_ORIGIN_LERP);
	EnsureRegisteredEnumValue(RF_, BEAM);
	EnsureRegisteredEnumValue(RF_, CUSTOMSKIN);
	EnsureRegisteredEnumValue(RF_, GLOW);
	EnsureRegisteredEnumValue(RF_, SHELL_RED);
	EnsureRegisteredEnumValue(RF_, SHELL_GREEN);
	EnsureRegisteredEnumValue(RF_, SHELL_BLUE);
	EnsureRegisteredEnumValue(RF_, NOSHADOW);
	EnsureRegisteredEnumValue(RF_, CASTSHADOW);
	
	EnsureRegisteredEnumValue(RF_, IR_VISIBLE);
	EnsureRegisteredEnumValue(RF_, SHELL_DOUBLE);
	EnsureRegisteredEnumValue(RF_, SHELL_HALF_DAM);
	EnsureRegisteredEnumValue(RF_, USE_DISGUISE);
	
	EnsureRegisteredEnumValue(RF_, SHELL_LITE_GREEN);
	EnsureRegisteredEnumValue(RF_, CUSTOM_LIGHT);
	EnsureRegisteredEnumValue(RF_, FLARE);
	EnsureRegisteredEnumValue(RF_, OLD_FRAME_LERP);
	EnsureRegisteredEnumValue(RF_, DOT_SHADOW);
	EnsureRegisteredEnumValue(RF_, LOW_PRIORITY);
	EnsureRegisteredEnumValue(RF_, NO_LOD);
	EnsureRegisteredEnumValue(RF_, NO_STEREO);
	EnsureRegisteredEnumValue(RF_, STAIR_STEP);
	
	EnsureRegisteredEnumValue(RF_, FLARE_LOCK_ANGLE);
	EnsureRegisteredEnumValueGlobalNoPrefix(RF_, BEAM_LIGHTNING);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	
#define Q2AS_OBJECT effects_t

	EnsureRegisteredTypedEnum("uint64");
	
	EnsureRegisteredEnumValue(EF_, NONE        );
	EnsureRegisteredEnumValue(EF_, ROTATE      );
	EnsureRegisteredEnumValue(EF_, GIB         );
	EnsureRegisteredEnumValue(EF_, BOB         );
	EnsureRegisteredEnumValue(EF_, BLASTER     );
	EnsureRegisteredEnumValue(EF_, ROCKET      );
	EnsureRegisteredEnumValue(EF_, GRENADE     );
	EnsureRegisteredEnumValue(EF_, HYPERBLASTER);
	EnsureRegisteredEnumValue(EF_, BFG         );
	EnsureRegisteredEnumValue(EF_, COLOR_SHELL );
	EnsureRegisteredEnumValue(EF_, POWERSCREEN );
	EnsureRegisteredEnumValue(EF_, ANIM01      );
	EnsureRegisteredEnumValue(EF_, ANIM23      );
	EnsureRegisteredEnumValue(EF_, ANIM_ALL    );
	EnsureRegisteredEnumValue(EF_, ANIM_ALLFAST);
	EnsureRegisteredEnumValue(EF_, FLIES       );
	EnsureRegisteredEnumValue(EF_, QUAD        );
	EnsureRegisteredEnumValue(EF_, PENT        );
	EnsureRegisteredEnumValue(EF_, TELEPORTER  );
	EnsureRegisteredEnumValue(EF_, FLAG1       );
	EnsureRegisteredEnumValue(EF_, FLAG2       );
	EnsureRegisteredEnumValue(EF_, IONRIPPER       );
	EnsureRegisteredEnumValue(EF_, GREENGIB        );
	EnsureRegisteredEnumValue(EF_, BLUEHYPERBLASTER);
	EnsureRegisteredEnumValue(EF_, SPINNINGLIGHTS  );
	EnsureRegisteredEnumValue(EF_, PLASMA          );
	EnsureRegisteredEnumValue(EF_, TRAP            );
	EnsureRegisteredEnumValue(EF_, TRACKER     );
	EnsureRegisteredEnumValue(EF_, DOUBLE      );
	EnsureRegisteredEnumValue(EF_, SPHERETRANS );
	EnsureRegisteredEnumValue(EF_, TAGTRAIL    );
	EnsureRegisteredEnumValue(EF_, HALF_DAMAGE );
	EnsureRegisteredEnumValue(EF_, TRACKERTRAIL);
	EnsureRegisteredEnumValue(EF_, DUALFIRE        );
	EnsureRegisteredEnumValue(EF_, HOLOGRAM        );
	EnsureRegisteredEnumValue(EF_, FLASHLIGHT      );
	EnsureRegisteredEnumValue(EF_, BARREL_EXPLODING);
	EnsureRegisteredEnumValue(EF_, TELEPORTER2     );
	EnsureRegisteredEnumValue(EF_, GRENADE_LIGHT   );
	EnsureRegisteredEnumValueRaw("effects_t", "FIREBALL", EF_FIREBALL);

#undef Q2AS_OBJECT
	
#define Q2AS_OBJECT entity_event_t
#define Q2AS_ENUM_PREFIX EV_

	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(EV_, NONE);
	EnsureRegisteredEnumValue(EV_, ITEM_RESPAWN);
	EnsureRegisteredEnumValue(EV_, FOOTSTEP);
	EnsureRegisteredEnumValue(EV_, FALLSHORT);
	EnsureRegisteredEnumValue(EV_, FALL);
	EnsureRegisteredEnumValue(EV_, FALLFAR);
	EnsureRegisteredEnumValue(EV_, PLAYER_TELEPORT);
	EnsureRegisteredEnumValue(EV_, OTHER_TELEPORT);
	EnsureRegisteredEnumValue(EV_, OTHER_FOOTSTEP);
	EnsureRegisteredEnumValue(EV_, LADDER_STEP);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT entity_state_t
	
	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);

    // behaviors
	EnsureRegisteredMethod("entity_state_t &opAssign(const entity_state_t &in)", asFUNCTION(Q2AS_entity_state_t_assign), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredProperty("const uint32", number);
	EnsureRegisteredProperty("vec3_t", origin);
	EnsureRegisteredProperty("vec3_t", angles);
	EnsureRegisteredProperty("vec3_t", old_origin);
	EnsureRegisteredProperty("int32", modelindex);
	EnsureRegisteredProperty("int32", modelindex2);
	EnsureRegisteredProperty("int32", modelindex3);
	EnsureRegisteredProperty("int32", modelindex4);
	EnsureRegisteredProperty("int32", frame);
	EnsureRegisteredProperty("int32", skinnum);
	EnsureRegisteredProperty("effects_t", effects);
	EnsureRegisteredProperty("renderfx_t", renderfx);
	EnsureRegisteredProperty("int32", sound);
	EnsureRegisteredProperty("entity_event_t", event);
	EnsureRegisteredProperty("float", alpha);
	EnsureRegisteredProperty("float", scale);
	EnsureRegisteredProperty("float", loop_volume);
	EnsureRegisteredProperty("float", loop_attenuation);
	EnsureRegisteredProperty("int32", old_frame);

    // these members are server-only
	Ensure(engine->RegisterObjectProperty("entity_state_t", "const uint32 solid_bits", asOFFSET(entity_state_t, solid)));
	Ensure(engine->RegisterObjectProperty("entity_state_t", "const int32 owner_id", asOFFSET(entity_state_t, owner)));
	Ensure(engine->RegisterObjectProperty("entity_state_t", "const uint8 instance_bits", asOFFSET(entity_state_t, instance_bits)));

#undef Q2AS_OBJECT

#define Q2AS_OBJECT svflags_t
#define Q2AS_ENUM_PREFIX SVF_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(SVF_, NONE);
	EnsureRegisteredEnumValue(SVF_, NOCLIENT);
	EnsureRegisteredEnumValue(SVF_, DEADMONSTER);
	EnsureRegisteredEnumValue(SVF_, MONSTER);
	EnsureRegisteredEnumValue(SVF_, PLAYER);
	EnsureRegisteredEnumValue(SVF_, BOT);
	EnsureRegisteredEnumValue(SVF_, NOBOTS);
	EnsureRegisteredEnumValue(SVF_, RESPAWNING);
	EnsureRegisteredEnumValue(SVF_, PROJECTILE);
	EnsureRegisteredEnumValue(SVF_, INSTANCED);
	EnsureRegisteredEnumValue(SVF_, DOOR);
	EnsureRegisteredEnumValue(SVF_, NOCULL);
	EnsureRegisteredEnumValue(SVF_, HULL);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT solid_t
#define Q2AS_ENUM_PREFIX SOLID_

	EnsureRegisteredTypedEnum("uint8");
	EnsureRegisteredEnumValue(SOLID_, NOT);
	EnsureRegisteredEnumValue(SOLID_, TRIGGER);
	EnsureRegisteredEnumValue(SOLID_, BBOX);
	EnsureRegisteredEnumValue(SOLID_, BSP);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT gclient_t

	// client handle; special handle, always active and allocated
	// by the host, wrapped by AngelScript.

	EnsureRegisteredTypeRaw("gclient_t", sizeof(gclient_t), asOBJ_REF | asOBJ_NOCOUNT);

	EnsureRegisteredProperty("player_state_t", ps);

    // convenience
    {
        auto ti = engine->GetTypeInfoByName("player_state_t");

        for (asUINT prop = 0; prop < ti->GetPropertyCount(); prop++)
        {
            const char *decl = ti->GetPropertyDeclaration(prop, false);
            int offset;
            ti->GetProperty(prop, nullptr, nullptr, nullptr, nullptr, &offset);

            Ensure(engine->RegisterObjectProperty("gclient_t", decl, offset));
        }
    }

	EnsureRegisteredProperty("const int", ping);

#undef Q2AS_OBJECT

#define Q2AS_OBJECT armorInfo_t

	// client handle; special handle, always active and allocated
	// by the host, wrapped by AngelScript.

	EnsureRegisteredTypeRaw("armorInfo_t", sizeof(armorInfo_t), asOBJ_VALUE | asOBJ_POD);

	EnsureRegisteredProperty("int", item_id);
	EnsureRegisteredProperty("int", max_count);

#undef Q2AS_OBJECT

    Ensure(Q2AS_RegisterFixedArray<int, MAX_ITEMS>(engine, "inventoryArray_t", "int", asOBJ_APP_CLASS_ALLINTS));
    Ensure(Q2AS_RegisterFixedArray<armorInfo_t, Max_Armor_Types>(engine, "armorInfoArray_t", "armorInfo_t", asOBJ_APP_CLASS_ALLINTS));
	
#define Q2AS_OBJECT edict_t
	
	// entity handle; special handle, always active and allocated
	// by the host, wrapped by AngelScript.

	EnsureRegisteredTypeRaw("edict_t", sizeof(q2as_edict_t), asOBJ_REF | asOBJ_NOCOUNT);

	EnsureRegisteredMethodRaw("edict_t", "void reset()", asFUNCTION(q2as_edict_t_reset), asCALL_CDECL_OBJLAST);

	EnsureRegisteredProperty("entity_state_t", s);

    // convenience
    {
        auto ti = engine->GetTypeInfoByName("entity_state_t");

        for (asUINT prop = 0; prop < ti->GetPropertyCount(); prop++)
        {
            const char *name;
            const char *decl = ti->GetPropertyDeclaration(prop, false);
            int offset;
            ti->GetProperty(prop, &name, nullptr, nullptr, nullptr, &offset);

            if (strcmp(name, "solid_bits") == 0 ||
                strcmp(name, "owner_id") == 0)
                continue;

            Ensure(engine->RegisterObjectProperty("edict_t", decl, offset));
        }
    }

    Ensure(engine->RegisterObjectProperty("edict_t", "player_state_t ps", asOFFSET(gclient_t, ps), asOFFSET(edict_t, client), true));

	EnsureRegisteredProperty("gclient_t @", client);
	EnsureRegisteredProperty("bool", inuse);
	EnsureRegisteredProperty("const bool", linked);
	EnsureRegisteredProperty("const int32", linkcount);
	EnsureRegisteredProperty("const int32", areanum);
	EnsureRegisteredProperty("const int32", areanum2);
	EnsureRegisteredProperty("svflags_t", svflags);
	EnsureRegisteredProperty("vec3_t", mins);
	EnsureRegisteredProperty("vec3_t", maxs);
	EnsureRegisteredProperty("vec3_t", absmin);
	EnsureRegisteredProperty("vec3_t", absmax);
	EnsureRegisteredProperty("vec3_t", size);
	EnsureRegisteredProperty("solid_t", solid);
	EnsureRegisteredProperty("contents_t", clipmask);
	EnsureRegisteredProperty("edict_t @", owner);
	
#undef Q2AS_OBJECT
    
#define Q2AS_OBJECT sv_entity_t
	
	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD);
    
    EnsureRegisteredProperty("bool", init);
    EnsureRegisteredProperty("uint64", ent_flags);
    EnsureRegisteredProperty("button_t", buttons);
    EnsureRegisteredProperty("uint32", spawnflags);
    EnsureRegisteredProperty("int32", item_id);
    EnsureRegisteredProperty("int32", armor_type);
    EnsureRegisteredProperty("int32", armor_value);
    EnsureRegisteredProperty("int32", health);
    EnsureRegisteredProperty("int32", max_health);
    EnsureRegisteredProperty("int32", starting_health);
    EnsureRegisteredProperty("int32", weapon);
    EnsureRegisteredProperty("int32", team);
    EnsureRegisteredProperty("int32", lobby_usernum);
    EnsureRegisteredProperty("int32", respawntime);
    EnsureRegisteredProperty("int32", viewheight);
    EnsureRegisteredProperty("int32", last_attackertime);
    EnsureRegisteredProperty("water_level_t", waterlevel);
    EnsureRegisteredProperty("vec3_t", viewangles);
    EnsureRegisteredProperty("vec3_t", viewforward);
    EnsureRegisteredProperty("vec3_t", velocity);
    EnsureRegisteredProperty("vec3_t", start_origin);
    EnsureRegisteredProperty("vec3_t", end_origin);
    EnsureRegisteredProperty("edict_t @", enemy);
    EnsureRegisteredProperty("edict_t @", ground_entity);
    EnsureRegisteredMethod("void set_classname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_classname), asCALL_CDECL_OBJLAST);
    EnsureRegisteredMethod("void set_targetname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_targetname), asCALL_CDECL_OBJLAST);
    EnsureRegisteredMethod("void set_netname(const string &in) property", asFUNCTION(q2as_sv_entity_t_set_netname), asCALL_CDECL_OBJLAST);
    EnsureRegisteredProperty("inventoryArray_t", inventory);
    EnsureRegisteredProperty("armorInfoArray_t", armor_info);

#undef Q2AS_OBJECT
    
    EnsureRegisteredPropertyRaw("edict_t", "sv_entity_t sv", asOFFSET(q2as_edict_t, sv));

	engine->RegisterGlobalFunction("edict_t @G_EdictForNum(uint n)", asFUNCTION(G_EdictForNum), asCALL_CDECL);
	engine->RegisterGlobalFunction("gclient_t @G_ClientForNum(uint n)", asFUNCTION(G_ClientForNum), asCALL_CDECL);

	Ensure(engine->RegisterFuncdef("BoxEdictsResult_t BoxEdictsFilter_t(edict_t @, any @const)"));
	
	engine->RegisterInterface("IASEntity");

	engine->RegisterInterfaceMethod("IASEntity", "edict_t @get_handle() const property");

    EnsureRegisteredPropertyRaw("edict_t", "IASEntity @as_obj", asOFFSET(q2as_edict_t, as_obj));

	return true;
}


static uint32_t q2as_spawnflag_dec(uint32_t f)
{
	return f;
}

static uint32_t q2as_spawnflag_bit(uint32_t f)
{
	return (1 << f);
}

static void q2as_spawnflag_copy(uint32_t f, uint32_t *o)
{
	*o = f;
}

static uint32_t &q2as_spawnflag_opAssign(uint32_t val, uint32_t &obj)
{
	obj = val;
	return obj;
}

static uint32_t q2as_spawnflag_to_uint(uint32_t f)
{
	return f;
}

static void q2as_spawnflags_t_uint(asIScriptGeneric *gen)
{
	uint32_t *a = (uint32_t*)gen->GetObject();
	*(uint32_t*)gen->GetAddressOfReturnLocation() = *a;
}

static void q2as_spawnflags_t_has(asIScriptGeneric *gen)
{
	uint32_t *a = (uint32_t*)gen->GetObject();
	gen->SetReturnByte(!!(*a & *((uint32_t *)gen->GetAddressOfArg(0))));
}

static void q2as_spawnflags_t_has_all(asIScriptGeneric *gen)
{
	uint32_t *a = (uint32_t*)gen->GetObject();
	uint32_t f = *((uint32_t *)gen->GetAddressOfArg(0));
	gen->SetReturnByte((*a & f) == f);
}

static void q2as_spawnflags_opCom(asIScriptGeneric *gen)
{
	uint32_t a = *((uint32_t *)gen->GetObject());
	a = ~a;
	gen->SetReturnObject(&a);
}

static void q2as_spawnflags_opAnd(asIScriptGeneric *gen)
{
	uint32_t a = *((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	uint32_t c = a & b;
	gen->SetReturnObject(&c);
}

static void q2as_spawnflags_opOr(asIScriptGeneric *gen)
{
	uint32_t a = *((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	uint32_t c = a | b;
	gen->SetReturnObject(&c);
}

static void q2as_spawnflags_opXor(asIScriptGeneric *gen)
{
	uint32_t a = *((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	uint32_t c = a ^ b;
	gen->SetReturnObject(&c);
}

static void q2as_spawnflags_opAndAssign(asIScriptGeneric *gen)
{
	uint32_t *a = ((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	*a &= b;
	gen->SetReturnObject(a);
}

static void q2as_spawnflags_opOrAssign(asIScriptGeneric *gen)
{
	uint32_t *a = ((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	*a |= b;
	gen->SetReturnObject(a);
}

static void q2as_spawnflags_opXorAssign(asIScriptGeneric *gen)
{
	uint32_t *a = ((uint32_t *)gen->GetObject());
	uint32_t b = *((uint32_t *)gen->GetAddressOfArg(0));
	*a ^= b;
	gen->SetReturnObject(a);
}

// register spawnflags_t type for use in scripts. just helps
// manage spawnflags.
static bool Q2AS_RegisterSpawnflags(asIScriptEngine *engine)
{
	Ensure(engine->RegisterObjectType("spawnflags_t", sizeof(int), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS | asOBJ_APP_CLASS_ALLINTS));
	Ensure(engine->RegisterGlobalFunction("spawnflags_t spawnflag_dec(uint)", asFUNCTION(q2as_spawnflag_dec), asCALL_CDECL));
	Ensure(engine->RegisterGlobalFunction("spawnflags_t spawnflag_bit(uint)", asFUNCTION(q2as_spawnflag_bit), asCALL_CDECL));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t opCom() const", asFUNCTION(q2as_spawnflags_opCom), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t opAnd(spawnflags_t) const", asFUNCTION(q2as_spawnflags_opAnd), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t opOr(spawnflags_t) const", asFUNCTION(q2as_spawnflags_opOr), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t opXor(spawnflags_t) const", asFUNCTION(q2as_spawnflags_opXor), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t &opAndAssign(spawnflags_t)", asFUNCTION(q2as_spawnflags_opAndAssign), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t &opOrAssign(spawnflags_t)", asFUNCTION(q2as_spawnflags_opOrAssign), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "spawnflags_t &opXorAssign(spawnflags_t)", asFUNCTION(q2as_spawnflags_opXorAssign), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "uint opConv() const", asFUNCTION(q2as_spawnflags_t_uint), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "bool has(spawnflags_t) const", asFUNCTION(q2as_spawnflags_t_has), asCALL_GENERIC));
	Ensure(engine->RegisterObjectMethod("spawnflags_t", "bool has_all(spawnflags_t) const", asFUNCTION(q2as_spawnflags_t_has_all), asCALL_GENERIC));

    return true;
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

		edict = *(q2as_edict_t **)ctx->GetAddressOfReturnValue();
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
            *(asIScriptObject **)gen->GetAddressOfReturnLocation() = edict->as_obj;
            return;
        }
	}

    *(asIScriptObject **)gen->GetAddressOfReturnLocation() = nullptr;
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
		void* ref = gen->GetArgAddress(i);
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

	gi.Loc_Print(nullptr, (print_type_t)(t | print_type_t::PRINT_BROADCAST), base->c_str(), args.ptrs.data(), gen->GetArgCount() - 1);
}

static void q2as_gi_LocBroadcast_Print_Zero(print_type_t t, const std::string &base)
{
	gi.Loc_Print(nullptr, (print_type_t)(t | print_type_t::PRINT_BROADCAST), base.c_str(), nullptr, 0);
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

static bool Q2AS_RegisterGame(asIScriptEngine *engine)
{
	// game imports
	EnsureRegisteredGlobalFunction("trace_t gi_trace(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, edict_t @passent, contents_t contentmask) nodiscard", asFUNCTION(gi.game_import_t::trace), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("trace_t gi_traceline(const vec3_t &in start, const vec3_t &in end, edict_t @passent, contents_t contentmask) nodiscard", asFUNCTION(q2as_traceline), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("trace_t gi_clip(edict_t @entity, const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, contents_t) nodiscard", asFUNCTION(gi.game_import_t::clip), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("contents_t gi_pointcontents(const vec3_t &in point) nodiscard", asFUNCTION(gi.game_import_t::pointcontents), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_linkentity(edict_t @ent)", asFUNCTION(gi.game_import_t::linkentity), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_unlinkentity(edict_t @ent)", asFUNCTION(gi.game_import_t::unlinkentity), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_positioned_sound(const vec3_t &in origin, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs)", asFUNCTION(gi.game_import_t::positioned_sound), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_sound(edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs)", asFUNCTION(gi.game_import_t::sound), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_local_sound(edict_t @target, const vec3_t &in origin, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs, uint dupe_key)", asFUNCTION(gi.game_import_t::local_sound), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_local_sound(edict_t @target, edict_t @ent, uint8 channel, int soundindex, float volume, float attenuation, float timeofs, uint dupe_key)", asFUNCTION(q2as_local_sound_nullptr), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int gi_soundindex(const string &in str)", asFUNCTION(q2as_soundindex), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int gi_modelindex(const string &in str)", asFUNCTION(q2as_modelindex), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int gi_imageindex(const string &in str)", asFUNCTION(q2as_imageindex), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteByte(int c)", asFUNCTION(gi.game_import_t::WriteByte), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteChar(int c)", asFUNCTION(gi.game_import_t::WriteChar), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteShort(int c)", asFUNCTION(gi.game_import_t::WriteShort), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteLong(int c)", asFUNCTION(gi.game_import_t::WriteLong), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteFloat(float f)", asFUNCTION(gi.game_import_t::WriteFloat), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteString(const string &in s)", asFUNCTION(q2as_WriteString), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WritePosition(const vec3_t &in pos)", asFUNCTION(gi.game_import_t::WritePosition), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteDir(const vec3_t &in dir)", asFUNCTION(gi.game_import_t::WriteDir), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteAngle(float f)", asFUNCTION(gi.game_import_t::WriteAngle), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_WriteEntity(edict_t @ent)", asFUNCTION(gi.game_import_t::WriteEntity), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_multicast(const vec3_t &in origin, multicast_t to, bool reliable)", asFUNCTION(gi.game_import_t::multicast), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_unicast(edict_t @ent, bool reliable, uint dupe_key)", asFUNCTION(gi.game_import_t::unicast), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Com_Error(const string &in message)", asFUNCTION(q2as_Com_Error), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Com_Error(const string &in fmt, const ?&in...)", asFUNCTION(q2as_Com_ErrorFmt), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_Com_Print(const string &in message)", asFUNCTION(q2as_Com_Print), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Com_Print(const string &in fmt, const ?&in...)", asFUNCTION(q2as_Com_PrintFmt), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_cvar_set(const string &in var_name, const string &in value)", asFUNCTION(q2as_cvar_set), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_cvar_forceset(const string &in var_name, const string &in value)", asFUNCTION(q2as_cvar_forceset), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("uint gi_Info_ValueForKey(const string &in, const string &in, const string &out)", asFUNCTION(q2as_Info_ValueForKey), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("bool gi_Info_SetValueForKey(const string &in, const string &in, const string &in, string &out)", asFUNCTION(q2as_Info_SetValueForKey), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_configstring(int num, const string &in str)", asFUNCTION(q2as_configstring), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("string gi_get_configstring(int num) nodiscard", asFUNCTION(q2as_get_configstring), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("uint gi_ServerFrame() nodiscard", asFUNCTION(gi.ServerFrame), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_setmodel(edict_t @ent, const string &in name)", asFUNCTION(q2as_setmodel), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("bool gi_inPHS(const vec3_t &in p1, const vec3_t &in p2, bool portals) nodiscard", asFUNCTION(gi.game_import_t::inPHS), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("bool gi_inPVS(const vec3_t &in p1, const vec3_t &in p2, bool portals) nodiscard", asFUNCTION(gi.game_import_t::inPVS), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("bool gi_AreasConnected(int area1, int area2) nodiscard", asFUNCTION(gi.game_import_t::AreasConnected), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("uint gi_BoxEdicts(const vec3_t &in mins, const vec3_t &in maxs, array<edict_t@> @+list, uint maxcount, solidity_area_t areatype, BoxEdictsFilter_t @+filter, any @const+ filter_data, bool append)", asFUNCTION(q2as_boxedicts), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int gi_argc() nodiscard", asFUNCTION(q2as_argc), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("const string &gi_args() nodiscard", asFUNCTION(q2as_args), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("const string &gi_argv(int n) nodiscard", asFUNCTION(q2as_argv), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_LocClient_Print(edict_t @, print_type_t printlevel, const string &in message)", asFUNCTION(q2as_gi_LocClient_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_LocClient_Print(edict_t @, print_type_t printlevel, const string &in fmt, const ?&in...)", asFUNCTION(q2as_gi_LocClient_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_Client_Print(edict_t @ent, print_type_t printlevel, const string &in message)", asFUNCTION(q2as_gi_Client_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Client_Print(edict_t @ent, print_type_t printlevel, const string &in fmt, const ?&in...)", asFUNCTION(q2as_gi_Client_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_Center_Print(edict_t @ent, const string &in)", asFUNCTION(q2as_gi_Center_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Center_Print(edict_t @ent, const string &in, const ?&in...)", asFUNCTION(q2as_gi_Center_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_LocCenter_Print(edict_t @ent, const string &in message)", asFUNCTION(q2as_gi_LocCenter_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_LocCenter_Print(edict_t @ent, const string &in fmt, const ?&in...)", asFUNCTION(q2as_gi_LocCenter_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_Loc_Print(edict_t @ent, print_type_t printlevel, const string &in base)", asFUNCTION(q2as_gi_Loc_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Loc_Print(edict_t @ent, print_type_t printlevel, const string &in base, const ?&in...)", asFUNCTION(q2as_gi_Loc_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_LocBroadcast_Print(print_type_t printlevel, const string &in message)", asFUNCTION(q2as_gi_LocBroadcast_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_LocBroadcast_Print(print_type_t printlevel, const string &in fmt, const ?&in...)", asFUNCTION(q2as_gi_LocBroadcast_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_Broadcast_Print(print_type_t printlevel, const string &in message)", asFUNCTION(q2as_gi_LocBroadcast_Print_Zero), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_Broadcast_Print(print_type_t printlevel, const string &in fmt, const ?&in...)", asFUNCTION(q2as_gi_LocBroadcast_Print), asCALL_GENERIC);
	EnsureRegisteredGlobalFunction("void gi_SetAreaPortalState(int portalnum, bool open)", asFUNCTION(gi.game_import_t::SetAreaPortalState), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("cvar_t @gi_cvar(const string &in var_name, const string &in value, cvar_flags_t flags)", asFUNCTION(Q2AS_cvar), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_AddCommandString(const string &in text)", asFUNCTION(Q2AS_AddCommandString_Zero), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_AddCommandString(const string &in fmt, const ?&in...)", asFUNCTION(Q2AS_AddCommandString), asCALL_GENERIC);
    EnsureRegisteredGlobalFunction("void gi_Bot_RegisterEdict(edict_t @)", asFUNCTION(gi.game_import_t::Bot_RegisterEdict), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Bot_UnRegisterEdict(edict_t @)", asFUNCTION(gi.game_import_t::Bot_UnRegisterEdict), asCALL_CDECL);

	EnsureRegisteredGlobalProperty("const uint gi_tick_rate", (void *) &gi.tick_rate);
	EnsureRegisteredGlobalProperty("const float gi_frame_time_s", (void *) &gi.frame_time_s);
	EnsureRegisteredGlobalProperty("const uint gi_frame_time_ms", (void *) &gi.frame_time_ms);
    
    EnsureRegisteredGlobalFunction("void gi_Draw_Line(const vec3_t &in start, const vec3_t &in end, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Line), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Point(const vec3_t &in point, float size, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Point), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Circle(const vec3_t &in origin, float size, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Circle), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Bounds(const vec3_t &in mins, const vec3_t &in maxs, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Bounds), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Sphere(const vec3_t &in origin, float radius, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Sphere), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_OrientedWorldText(const vec3_t &in origin, const string &in text, const rgba_t &in color, float size, float lifeTime, bool depthTest)", asFUNCTION(Q2AS_Draw_OrientedWorldText), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_StaticWorldText(const vec3_t &in origin, const vec3_t &in angles, const string &in text, const rgba_t &in color, float size, float lifeTime, bool depthTest)", asFUNCTION(Q2AS_Draw_StaticWorldText), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Cylinder(const vec3_t &in origin, float halfHeight, float radius, const rgba_t &in color, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Cylinder), asCALL_CDECL);
    EnsureRegisteredGlobalFunction("void gi_Draw_Arrow(const vec3_t &in start, const vec3_t &in end, float size, const rgba_t &in lineColor, const rgba_t &in arrowColor, float lifeTime, bool depthTest)", asFUNCTION(gi.game_import_t::Draw_Arrow), asCALL_CDECL);

	EnsureRegisteredGlobalFunction("void SendToClipBoard(const string &in text)", asFUNCTION(q2as_SendToClipBoard), asCALL_CDECL);

	// edict stuff
	EnsureRegisteredGlobalProperty("const uint max_edicts", (void *) &globals.max_edicts);
	EnsureRegisteredGlobalProperty("uint num_edicts", (void *) &globals.num_edicts);
	EnsureRegisteredGlobalProperty("const uint max_clients", (void *) &svas.maxclients);
	EnsureRegisteredGlobalProperty("server_flags_t server_flags", (void *) &globals.server_flags);

    // helpers
    EnsureRegisteredGlobalFunction("T @+find_by_str<T>(T @+from, const string &in member, const string &in value) nodiscard", asFUNCTION(q2as_find_by_str), asCALL_GENERIC);

	return true;
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

static bool Q2AS_RegisterShadowLightData(asIScriptEngine *engine)
{
#define Q2AS_OBJECT shadow_light_type_t

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueRaw("shadow_light_type_t", "point", (int) shadow_light_type_t::point);
	EnsureRegisteredEnumValueRaw("shadow_light_type_t", "cone", (int) shadow_light_type_t::cone);
	
#undef Q2AS_OBJECT

#define Q2AS_OBJECT shadow_light_data_t

	EnsureRegisteredType(asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C);

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<shadow_light_data_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const shadow_light_data_t &in)", asFUNCTION(Q2AS_init_construct_copy<shadow_light_data_t>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("shadow_light_data_t &opAssign (const shadow_light_data_t &in)", asFUNCTION(Q2AS_assign<shadow_light_data_t>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredProperty("shadow_light_type_t", lighttype);
	EnsureRegisteredProperty("float", radius);
	EnsureRegisteredProperty("int", resolution);
	EnsureRegisteredProperty("float", intensity);
	EnsureRegisteredProperty("float", fade_start);
	EnsureRegisteredProperty("float", fade_end);
	EnsureRegisteredProperty("int", lightstyle);
	EnsureRegisteredProperty("float", coneangle);
	EnsureRegisteredProperty("vec3_t", conedirection);

#undef Q2AS_OBJECT

	EnsureRegisteredGlobalFunction("void gi_SetShadowLightData(uint, const shadow_light_data_t &in)", asFUNCTION(q2as_gi_SetShadowLightData), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_GetShadowLightData(uint, shadow_light_data_t &out)", asFUNCTION(q2as_gi_GetShadowLightData), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("void gi_RemoveShadowLightData(int)", asFUNCTION(q2as_gi_RemoveShadowLightData), asCALL_CDECL);

	return true;
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
	new(&out) q2as_PathInfo{};
	// just to be sure nobody does any fun nonsense...
	// 256 should be more than enough.
	static vec3_t points[256];
	const_cast<PathRequest &>(in).pathPoints = { points, min((int64_t) q_countof(points), in.pathPoints.count) };

	bool result = gi.GetPathToGoal(in, out.info);

	if (result && out.info.numPathPoints)
	{
		out.points.resize(out.info.numPathPoints);
		memcpy(out.points.data(), in.pathPoints.array, sizeof(vec3_t) * out.info.numPathPoints);
	}

	return result;
}

static bool Q2AS_RegisterPathFinding(asIScriptEngine *engine)
{
#define Q2AS_OBJECT GoalReturnCode
#define Q2AS_ENUM_PREFIX

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(, Error);
	EnsureRegisteredEnumValue(, Started);
	EnsureRegisteredEnumValue(, InProgress);
	EnsureRegisteredEnumValue(, Finished);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT gesture_type
#define Q2AS_ENUM_PREFIX GESTURE_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(GESTURE_, NONE);
	EnsureRegisteredEnumValue(GESTURE_, FLIP_OFF);
	EnsureRegisteredEnumValue(GESTURE_, SALUTE);
	EnsureRegisteredEnumValue(GESTURE_, TAUNT);
	EnsureRegisteredEnumValue(GESTURE_, WAVE);
	EnsureRegisteredEnumValue(GESTURE_, POINT);
	EnsureRegisteredEnumValue(GESTURE_, POINT_NO_PING);
	EnsureRegisteredEnumValue(GESTURE_, MAX);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	
#define Q2AS_OBJECT PathReturnCode
#define Q2AS_ENUM_PREFIX

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(, ReachedGoal);
	EnsureRegisteredEnumValue(, ReachedPathEnd);
	EnsureRegisteredEnumValue(, TraversalPending);
	EnsureRegisteredEnumValue(, RawPathFound);
	EnsureRegisteredEnumValue(, InProgress);
	EnsureRegisteredEnumValue(, StartPathErrors);
	EnsureRegisteredEnumValue(, InvalidStart);
	EnsureRegisteredEnumValue(, InvalidGoal);
	EnsureRegisteredEnumValue(, NoNavAvailable);
	EnsureRegisteredEnumValue(, NoStartNode);
	EnsureRegisteredEnumValue(, NoGoalNode);
	EnsureRegisteredEnumValue(, NoPathFound);
	EnsureRegisteredEnumValue(, MissingWalkOrSwimFlag);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX
	
#define Q2AS_OBJECT PathLinkType
#define Q2AS_ENUM_PREFIX

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(, Walk);
	EnsureRegisteredEnumValue(, WalkOffLedge);
	EnsureRegisteredEnumValue(, LongJump);
	EnsureRegisteredEnumValue(, BarrierJump);
	EnsureRegisteredEnumValue(, Elevator);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT PathFlags
#define Q2AS_ENUM_PREFIX

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValue(, All);
	EnsureRegisteredEnumValue(, Water);
	EnsureRegisteredEnumValue(, Walk);
	EnsureRegisteredEnumValue(, WalkOffLedge);
	EnsureRegisteredEnumValue(, LongJump);
	EnsureRegisteredEnumValue(, BarrierJump);
	EnsureRegisteredEnumValue(, Elevator);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT PathDebugSettings

	EnsureRegisteredTypeRaw("PathDebugSettings", sizeof(PathRequest::DebugSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::DebugSettings>());

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<PathRequest::DebugSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const PathDebugSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::DebugSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("PathDebugSettings &opAssign (const PathDebugSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::DebugSettings>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredPropertyRaw("PathDebugSettings", "float drawTime", asOFFSET(PathRequest::DebugSettings, drawTime));

#undef Q2AS_OBJECT

#define Q2AS_OBJECT PathNodeSettings

	EnsureRegisteredTypeRaw("PathNodeSettings", sizeof(PathRequest::NodeSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::NodeSettings>());

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<PathRequest::NodeSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const PathNodeSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::NodeSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("PathNodeSettings &opAssign (const PathNodeSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::NodeSettings>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredPropertyRaw("PathNodeSettings", "bool ignoreNodeFlags", asOFFSET(PathRequest::NodeSettings, ignoreNodeFlags));
	EnsureRegisteredPropertyRaw("PathNodeSettings", "float minHeight", asOFFSET(PathRequest::NodeSettings, minHeight));
	EnsureRegisteredPropertyRaw("PathNodeSettings", "float maxHeight", asOFFSET(PathRequest::NodeSettings, maxHeight));
	EnsureRegisteredPropertyRaw("PathNodeSettings", "float radius", asOFFSET(PathRequest::NodeSettings, radius));

#undef Q2AS_OBJECT

#define Q2AS_OBJECT PathTraversalSettings

	EnsureRegisteredTypeRaw("PathTraversalSettings", sizeof(PathRequest::TraversalSettings), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLFLOATS | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest::TraversalSettings>());

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<PathRequest::TraversalSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const PathTraversalSettings &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest::TraversalSettings>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("PathTraversalSettings &opAssign (const PathTraversalSettings &in)", asFUNCTION(Q2AS_assign<PathRequest::TraversalSettings>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredPropertyRaw("PathTraversalSettings", "float dropHeight", asOFFSET(PathRequest::TraversalSettings, dropHeight));
	EnsureRegisteredPropertyRaw("PathTraversalSettings", "float jumpHeight", asOFFSET(PathRequest::TraversalSettings, jumpHeight));

#undef Q2AS_OBJECT

#define Q2AS_OBJECT PathRequest

	EnsureRegisteredTypeRaw("PathRequest", sizeof(PathRequest), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_C | asGetTypeTraits<PathRequest>());

	// behaviors
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<PathRequest>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredBehaviour(asBEHAVE_CONSTRUCT, "void f(const PathRequest &in)", asFUNCTION(Q2AS_init_construct_copy<PathRequest>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethod("PathRequest &opAssign (const PathRequest &in)", asFUNCTION(Q2AS_assign<PathRequest>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredProperty("vec3_t", start);
	EnsureRegisteredProperty("vec3_t", goal);
	EnsureRegisteredProperty("PathFlags", pathFlags);
	EnsureRegisteredProperty("float", moveDist);
	
	EnsureRegisteredProperty("PathDebugSettings", debugging);
	EnsureRegisteredProperty("PathNodeSettings", nodeSearch);
	EnsureRegisteredProperty("PathTraversalSettings", traversals);

	EnsureRegisteredPropertyRaw("PathRequest", "int64 maxPathPoints", asOFFSET(PathRequest, pathPoints.count));

#undef Q2AS_OBJECT

#define Q2AS_OBJECT PathInfo

	EnsureRegisteredTypeRaw("PathInfo", sizeof(q2as_PathInfo), asOBJ_REF);

	// behaviors
	EnsureRegisteredBehaviourRaw("PathInfo", asBEHAVE_FACTORY, "PathInfo@ f()", asFUNCTION((Q2AS_Factory<q2as_PathInfo, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("PathInfo", asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<q2as_PathInfo, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("PathInfo", asBEHAVE_RELEASE, "void f()", asFUNCTION((Q2AS_Release<q2as_PathInfo, q2as_sv_state_t>)), asCALL_GENERIC);

	EnsureRegisteredMethod("PathInfo &opAssign (const PathInfo &in)", asFUNCTION(Q2AS_assign<q2as_PathInfo>), asCALL_CDECL_OBJLAST);

	// props
	EnsureRegisteredPropertyRaw("PathInfo", "uint numPathPoints", asOFFSET(q2as_PathInfo, info.numPathPoints));
	EnsureRegisteredPropertyRaw("PathInfo", "float pathDistSqr", asOFFSET(q2as_PathInfo, info.pathDistSqr));
	EnsureRegisteredPropertyRaw("PathInfo", "vec3_t firstMovePoint", asOFFSET(q2as_PathInfo, info.firstMovePoint));
	EnsureRegisteredPropertyRaw("PathInfo", "vec3_t secondMovePoint", asOFFSET(q2as_PathInfo, info.secondMovePoint));
	EnsureRegisteredPropertyRaw("PathInfo", "PathLinkType pathLinkType", asOFFSET(q2as_PathInfo, info.pathLinkType));
	EnsureRegisteredPropertyRaw("PathInfo", "PathReturnCode returnCode", asOFFSET(q2as_PathInfo, info.returnCode));

	EnsureRegisteredMethodRaw("PathInfo", "const vec3_t &getPathPoint(uint i) const", asMETHOD(q2as_PathInfo, getPathPoint), asCALL_THISCALL);

#undef Q2AS_OBJECT

	EnsureRegisteredGlobalFunction("bool gi_GetPathToGoal(const PathRequest &in, PathInfo &out)", asFUNCTION(q2as_gi_GetPathToGoal), asCALL_CDECL);

	return true;
}

// unused import
static void Q2AS_Pmove(pmove_t *pmove)
{
}

#include "q2as_predefined.h"

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
        Q2AS_RegisterGameImports,
        Q2AS_RegisterEntity,
        Q2AS_RegisterTrace,
        Q2AS_RegisterPmove,
        Q2AS_RegisterPmoveFactory<q2as_sv_state_t>,
        Q2AS_RegisterImportTypes,
        Q2AS_RegisterJson,
		Q2AS_RegisterGame,
		Q2AS_RegisterPathFinding,
        Q2AS_RegisterSpawnflags,
        Q2AS_RegisterShadowLightData,
        Q2AS_RegisterTokenizer
	};

    if (!svas.LoadLibraries(libraries, std::extent_v<decltype(libraries)>))
        return nullptr;
	
	const cvar_t *q2as_developer = gi.cvar("q2as_developer", "0", CVAR_NOFLAGS);

	if (q2as_developer->integer)
		WritePredefined(svas.engine, "game.as.predefined");

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