// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

#include "g_local.h"
#include "as/q2as_main.h"

CHECK_GCLIENT_INTEGRITY;
//CHECK_EDICT_INTEGRITY;

std::mt19937 mt_rand;

game_locals_t  game;
level_locals_t level;

local_game_import_t  gi;

/*static*/ char local_game_import_t::print_buffer[0x10000];

/*static*/ std::array<char[MAX_INFO_STRING], MAX_LOCALIZATION_ARGS> local_game_import_t::buffers;
/*static*/ std::array<const char*, MAX_LOCALIZATION_ARGS> local_game_import_t::buffer_ptrs;

game_export_t  globals;

cached_modelindex		sm_meat_index;
cached_soundindex		snd_fry;

edict_t *g_edicts;

#ifdef KEX_Q2GAME_STATIC
extern
#endif
cvar_t *developer;
cvar_t *deathmatch;
cvar_t *coop;
cvar_t *skill;
cvar_t *fraglimit;
cvar_t *timelimit;
// ZOID
cvar_t *capturelimit;
cvar_t *g_quick_weapon_switch;
cvar_t *g_instant_weapon_switch;
// ZOID
cvar_t		*password;
cvar_t		*spectator_password;
cvar_t		*needpass;
static cvar_t *maxclients;
cvar_t		*maxspectators;
static cvar_t *maxentities;
cvar_t		*g_select_empty;
cvar_t		*sv_dedicated;

cvar_t *filterban;

cvar_t *sv_maxvelocity;
cvar_t *sv_gravity;

cvar_t *g_skipViewModifiers;

cvar_t *sv_rollspeed;
cvar_t *sv_rollangle;
cvar_t *gun_x;
cvar_t *gun_y;
cvar_t *gun_z;

cvar_t *run_pitch;
cvar_t *run_roll;
cvar_t *bob_up;
cvar_t *bob_pitch;
cvar_t *bob_roll;

cvar_t *sv_cheats;

cvar_t *g_debug_monster_paths;
cvar_t *g_debug_monster_kills;
cvar_t *g_debug_poi;

cvar_t *bot_debug_follow_actor;
cvar_t *bot_debug_move_to_point;

cvar_t *flood_msgs;
cvar_t *flood_persecond;
cvar_t *flood_waitdelay;

cvar_t *sv_stopspeed; // PGM	 (this was a define in g_phys.c)

cvar_t *g_strict_saves;

// ROGUE cvars
cvar_t *gamerules;
cvar_t *huntercam;
cvar_t *g_dm_strong_mines;
cvar_t *g_dm_random_items;
// ROGUE

// [Kex]
cvar_t* g_instagib;
cvar_t* g_coop_player_collision;
cvar_t* g_coop_squad_respawn;
cvar_t* g_coop_enable_lives;
cvar_t* g_coop_num_lives;
cvar_t* g_coop_instanced_items;
cvar_t* g_allow_grapple;
cvar_t* g_grapple_fly_speed;
cvar_t* g_grapple_pull_speed;
cvar_t* g_grapple_damage;
cvar_t* g_coop_health_scaling;
cvar_t* g_weapon_respawn_time;

// dm"flags"
cvar_t* g_no_health;
cvar_t* g_no_items;
cvar_t* g_dm_weapons_stay;
cvar_t* g_dm_no_fall_damage;
cvar_t* g_dm_instant_items;
cvar_t* g_dm_same_level;
cvar_t* g_friendly_fire;
cvar_t* g_dm_force_respawn;
cvar_t* g_dm_force_respawn_time;
cvar_t* g_dm_spawn_farthest;
cvar_t* g_no_armor;
cvar_t* g_dm_allow_exit;
cvar_t* g_infinite_ammo;
cvar_t* g_dm_no_quad_drop;
cvar_t* g_dm_no_quadfire_drop;
cvar_t* g_no_mines;
cvar_t* g_dm_no_stack_double;
cvar_t* g_no_nukes;
cvar_t* g_no_spheres;
cvar_t* g_teamplay_armor_protect;
cvar_t* g_allow_techs;
cvar_t* g_start_items;
cvar_t* g_map_list;
cvar_t* g_map_list_shuffle;
cvar_t *g_lag_compensation;

cvar_t *sv_airaccelerate;
cvar_t *g_damage_scale;
cvar_t *g_disable_player_collision;
cvar_t *ai_damage_scale;
cvar_t *ai_model_scale;
cvar_t *ai_allow_dm_spawn;
cvar_t *ai_movement_disabled;

static cvar_t *g_frames_per_frame;

void SpawnEntities(const char *mapname, const char *entities, const char *spawnpoint);
void ClientThink(edict_t *ent, usercmd_t *cmd);
edict_t *ClientChooseSlot(const char *userinfo, const char *social_id, bool isBot, edict_t **ignore, size_t num_ignore, bool cinematic);
bool  ClientConnect(edict_t *ent, char *userinfo, const char *social_id, bool isBot);
char *WriteGameJson(bool autosave, size_t *out_size);
void  ReadGameJson(const char *jsonString);
char *WriteLevelJson(bool transition, size_t *out_size);
void  ReadLevelJson(const char *jsonString);
bool  G_CanSave();
void ClientDisconnect(edict_t *ent);
void ClientBegin(edict_t *ent);
void ClientCommand(edict_t *ent);
void G_RunFrame(bool main_loop);
void G_PrepFrame();
void InitSave();

#include <chrono>

gtime_t FRAME_TIME_S;
gtime_t FRAME_TIME_MS;

/*
=================
GetGameAPI

Returns a pointer to the structure with all entry points
and global variables
=================
*/
Q2GAME_API game_export_t *GetGameAPI(game_import_t *import)
{
	gi = *import;

	// see if Q2AS needs to be initialized
	if (auto api = Q2AS_GetGameAPI())
	{
		return api;
	}

	import->Com_Error("Failed to load AngleScript game API\n");

	return NULL;
}

//======================================================================
