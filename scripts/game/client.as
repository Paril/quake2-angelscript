namespace player
{
    enum frames
    {
        stand01,
        stand02,
        stand03,
        stand04,
        stand05,
        stand06,
        stand07,
        stand08,
        stand09,
        stand10,
        stand11,
        stand12,
        stand13,
        stand14,
        stand15,
        stand16,
        stand17,
        stand18,
        stand19,
        stand20,
        stand21,
        stand22,
        stand23,
        stand24,
        stand25,
        stand26,
        stand27,
        stand28,
        stand29,
        stand30,
        stand31,
        stand32,
        stand33,
        stand34,
        stand35,
        stand36,
        stand37,
        stand38,
        stand39,
        stand40,
        run1,
        run2,
        run3,
        run4,
        run5,
        run6,
        attack1,
        attack2,
        attack3,
        attack4,
        attack5,
        attack6,
        attack7,
        attack8,
        pain101,
        pain102,
        pain103,
        pain104,
        pain201,
        pain202,
        pain203,
        pain204,
        pain301,
        pain302,
        pain303,
        pain304,
        jump1,
        jump2,
        jump3,
        jump4,
        jump5,
        jump6,
        flip01,
        flip02,
        flip03,
        flip04,
        flip05,
        flip06,
        flip07,
        flip08,
        flip09,
        flip10,
        flip11,
        flip12,
        salute01,
        salute02,
        salute03,
        salute04,
        salute05,
        salute06,
        salute07,
        salute08,
        salute09,
        salute10,
        salute11,
        taunt01,
        taunt02,
        taunt03,
        taunt04,
        taunt05,
        taunt06,
        taunt07,
        taunt08,
        taunt09,
        taunt10,
        taunt11,
        taunt12,
        taunt13,
        taunt14,
        taunt15,
        taunt16,
        taunt17,
        wave01,
        wave02,
        wave03,
        wave04,
        wave05,
        wave06,
        wave07,
        wave08,
        wave09,
        wave10,
        wave11,
        point01,
        point02,
        point03,
        point04,
        point05,
        point06,
        point07,
        point08,
        point09,
        point10,
        point11,
        point12,
        crstnd01,
        crstnd02,
        crstnd03,
        crstnd04,
        crstnd05,
        crstnd06,
        crstnd07,
        crstnd08,
        crstnd09,
        crstnd10,
        crstnd11,
        crstnd12,
        crstnd13,
        crstnd14,
        crstnd15,
        crstnd16,
        crstnd17,
        crstnd18,
        crstnd19,
        crwalk1,
        crwalk2,
        crwalk3,
        crwalk4,
        crwalk5,
        crwalk6,
        crattak1,
        crattak2,
        crattak3,
        crattak4,
        crattak5,
        crattak6,
        crattak7,
        crattak8,
        crattak9,
        crpain1,
        crpain2,
        crpain3,
        crpain4,
        crdeath1,
        crdeath2,
        crdeath3,
        crdeath4,
        crdeath5,
        death101,
        death102,
        death103,
        death104,
        death105,
        death106,
        death201,
        death202,
        death203,
        death204,
        death205,
        death206,
        death301,
        death302,
        death303,
        death304,
        death305,
        death306,
        death307,
        death308
    };
}

// never turn back shield on automatically; this is
// the legacy behavior.
const int32 AUTO_SHIELD_MANUAL = -1;
// when it is >= 0, the shield will turn back on
// when we have that many cells in our inventory
// if possible.
const int32 AUTO_SHIELD_AUTO = 0;

// handedness values
enum handedness_t
{
	RIGHT,
	LEFT,
	CENTER
};

enum auto_switch_t
{
	SMART,
	ALWAYS,
	ALWAYS_NO_AMMO,
	NEVER
};

// client_t.anim_priority
enum anim_priority_t
{
	BASIC, // stand / run
	WAVE,
	JUMP,
	PAIN,
	ATTACK,
	DEATH,

	// flags
	REVERSED	= 1 << 8
};

// client data that stays across multiple level loads
class client_persistant_t
{
	string userinfo;
	string social_id;
	string netname;
	handedness_t hand;
	auto_switch_t autoswitch;
	int32 autoshield; // see AUTO_SHIELD_*

	bool connected, spawned; // a loadgame will leave valid entities that
					// just don't have a connection yet

	// values saved and restored from edicts when changing levels
	int32		health;
	int32		max_health;
	ent_flags_t savedFlags;

	item_id_t selected_item;
	gtime_t   selected_item_time;

	inventoryArray_t inventory;

	// ammo capacities
	array<int16> max_ammo = array<int16>(ammo_t::MAX);

	const gitem_t @weapon;
	const gitem_t @lastweapon;

	int32 power_cubes;   // used for tracking the cubes in coop games
	int32 score;		 // for calculating total unit score in coop games

	int32 game_help1changed, game_help2changed;
	int32 helpchanged; // flash F1 icon if non 0, play sound
						 // and increment only if 1, 2, or 3
	gtime_t help_time;

	bool spectator; // client wants to be a spectator
	bool bob_skip; // [Paril-KEX] client wants no movement bob

	// [Paril-KEX] fog that we want to achieve
	fog_t wanted_fog;
	height_fog_t wanted_heightfog;
	// relative time value, copied from last touched trigger
	gtime_t fog_transition_time;
	gtime_t megahealth_time; // relative megahealth time value
	int32 lives; // player lives left (1 = no respawns remaining)
	uint8 n64_crouch_warn_times;
	gtime_t n64_crouch_warning;
};

enum ctfteam_t
{
	NOTEAM,
	TEAM1,
	TEAM2,

    INVALID = -1
};

class ghost_t
{
	string netname;
	int	 number;

	// stats
	int deaths;
	int kills;
	int caps;
	int basedef;
	int carrierdef;

	int			code;	// ghost code
	ctfteam_t	team;	// team
	int			score; // frags at time of disconnect
	ASEntity    @ent;
};

// client data that stays across deathmatch respawns
class client_respawn_t
{
	client_persistant_t coop_respawn; // what to set client.pers to on a respawn
	gtime_t				entertime;	  // level.time the client entered the game
	int32				score;		  // frags, etc
	vec3_t				cmd_angles;	  // angles sent over in the last command

	bool spectator; // client is a spectator

	// ZOID
	ctfteam_t ctf_team; // CTF team
	int32	  ctf_state;
	gtime_t	  ctf_lasthurtcarrier;
	gtime_t	  ctf_lastreturnedflag;
	gtime_t	  ctf_flagsince;
	gtime_t	  ctf_lastfraggedcarrier;
	bool	  id_state;
	gtime_t	  lastidtime;
	bool	  voted; // for elections
	bool	  ready;
	bool	  admin;
    ghost_t   @ghost;
	// ZOID
}

class kick_params_t
{
    vec3_t	angles, origin;
    gtime_t	time, total;
}

// max number of individual damage indicators we'll track
const uint MAX_DAMAGE_INDICATORS = 4;

class damage_indicator_t
{
	vec3_t from;
	int32 health, armor, power;
}

enum ctfgrapplestate_t
{
	FLY,
	PULL,
	HANG
}

class ASClient
{
    //ASClient(const ASClient &inout) delete;
    //ASClient &opAssign(const ASClient &inout) delete;
    no_value_assign nva;

    gclient_t @c;

	// private to game
	client_persistant_t pers;
	client_respawn_t	resp;
	pmove_state_t		old_pmove; // for detecting out-of-pmove changes

	bool showscores;	// set layout stat
	bool showeou;       // end of unit screen
	bool showinventory; // set layout stat
	bool showhelp;

	button_t buttons;
	button_t oldbuttons;
	button_t latched_buttons;
	usercmd_t cmd; // last CMD send

	// weapon cannot fire until this time is up
	gtime_t weapon_fire_finished;
	// time between processing individual animation frames
	gtime_t weapon_think_time;
	// if we latched fire between server frames but before
	// the weapon fire finish has elapsed, we'll "press" it
	// automatically when we have a chance
	bool weapon_fire_buffered;
	bool weapon_thunk;

	const gitem_t @newweapon;

	// sum up damage over an entire frame, so
	// shotgun blasts give a single big kick
	int32 damage_armor;	  // damage absorbed by armor
	int32 damage_parmor;  // damage absorbed by power armor
	int32 damage_blood;	  // damage taken out of health
	int32 damage_knockback; // impact damage
	vec3_t	damage_from;	  // origin for vector calculation

	array<damage_indicator_t> damage_indicators;

	float killer_yaw; // when dead, look at killer

	weaponstate_t weaponstate;
    kick_params_t kick;
	gtime_t		  quake_time;
	vec3_t		  kick_origin;
	float		  v_dmg_roll, v_dmg_pitch;
	gtime_t		  v_dmg_time; // damage kicks
	gtime_t		  fall_time;
	float		  fall_value; // for view drop on fall
	vec4_t		  damage_blend;
	vec3_t		  v_angle, v_forward; // aiming direction
	float		  bobtime;			  // so off-ground doesn't change it
	vec3_t		  oldviewangles;
	vec3_t		  oldvelocity;
	ASEntity      @oldgroundentity; // [Paril-KEX]
	gtime_t		  flash_time; // [Paril-KEX] for high tickrate

	gtime_t		  next_drown_time;
	water_level_t old_waterlevel;
	int32		  breather_sound;

	int32		  machinegun_shots; // for weapon raising

	// animation vars
	int32			anim_end;
	anim_priority_t anim_priority;
	bool			anim_duck;
	bool			anim_run;
	gtime_t			anim_time;

	// powerup timers
	gtime_t quad_time;
	gtime_t invincible_time;
	gtime_t breather_time;
	gtime_t enviro_time;
	gtime_t invisible_time;

	bool	grenade_blew_up;
	gtime_t grenade_time, grenade_finished_time;
	// RAFAEL
	gtime_t quadfire_time;
	// RAFAEL
	int32 silencer_shots;
	int32 weapon_sound;

	gtime_t pickup_msg_time;

	gtime_t flood_locktill; // locked from talking
	array<gtime_t> flood_when = array<gtime_t>(10); // when messages were said
	int32 flood_whenhead; // head pointer for when said

	gtime_t respawn_time; // can respawn when time > this

	ASEntity @chase_target; // player we are chasing
	bool	 update_chase; // need to update chase info?

	//=======
	// ROGUE
	gtime_t double_time;
	gtime_t ir_time;
	gtime_t nuke_time;
	gtime_t tracker_pain_time;

	ASEntity @owned_sphere; // this points to the player's sphere
						   // ROGUE
	//=======

	gtime_t empty_click_sound;

	// ZOID
	bool		inmenu;	  // in menu
	pmenuhnd_t  @menu;	  // current menu
	gtime_t		menutime; // time to update menu
	bool		menudirty;
	ASEntity	@ctf_grapple;			// entity of grapple
	ctfgrapplestate_t		ctf_grapplestate;		// true if pulling
	gtime_t		ctf_grapplereleasetime; // time of grapple release
	gtime_t		ctf_regentime;			// regen tech
	gtime_t		ctf_techsndtime;
	gtime_t		ctf_lasttechmsg;
	// ZOID

	// used for player trails.
	ASEntity @trail_head, trail_tail;
	// whether to use weapon chains
	bool no_weapon_chains;

	// seamless level transitions
	bool landmark_free_fall;
	string landmark_name;
	vec3_t landmark_rel_pos; // position relative to landmark, un-rotated from landmark angle
	gtime_t landmark_noise_time;

	gtime_t invisibility_fade_time; // [Paril-KEX] at this time, the player will be mostly fully cloaked
	gtime_t chase_msg_time; // to prevent CTF message spamming
	int32 menu_sign; // menu sign
	vec3_t last_ladder_pos; // for ladder step sounds
	gtime_t last_ladder_sound;
	coop_respawn_t coop_respawn_state;
	gtime_t last_damage_time;

	// [Paril-KEX] these are now per-player, to work better in coop
	ASEntity @sight_entity;
	gtime_t	 sight_entity_time;
	ASEntity @sound_entity;
	gtime_t	 sound_entity_time;
	ASEntity @sound2_entity;
	gtime_t  sound2_entity_time;
	// saved positions for lag compensation
	uint8	 num_lag_origins; // 0 to MAX_LAG_ORIGINS, how many we can go back
	uint8    next_lag_origin; // the next one to write to
	bool     is_lag_compensated;
	vec3_t	 lag_restore_origin;
	// for high tickrate weapon angles
	vec3_t	 slow_view_angles;
	gtime_t	 slow_view_angle_time;

	// not saved
	bool help_draw_points;
	uint help_draw_index, help_draw_count;
	gtime_t help_draw_time;
	uint32 step_frame;
	int32 help_poi_image;
	vec3_t help_poi_location;

	// only set temporarily
	bool awaiting_respawn;
	gtime_t respawn_timeout; // after this time, force a respawn

	// [Paril-KEX] current active fog values
	fog_t fog;
	height_fog_t heightfog;

	gtime_t	 last_attacker_time;
	// saved - for coop; last time we were in a firing state
	gtime_t	 last_firing_time;

	ASEntity @mynoise;
	ASEntity @mynoise2;

    ASClient(gclient_t @c) explicit
    {
        @this.c = @c;
    }
};

void info_player_start_drop(ASEntity &self)
{
	// allow them to drop
	self.e.solid = solid_t::TRIGGER;
	self.movetype = movetype_t::TOSS;
	self.e.mins = PLAYER_MINS;
	self.e.maxs = PLAYER_MAXS;
	gi_linkentity(self.e);
}

namespace spawnflags::player_start
{
    const uint32 SPAWN_RIDE = 1;
}

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 32)
The normal starting point for a level.
*/
void SP_info_player_start(ASEntity &self)
{
	// fix stuck spawn points
	if (gi_trace(self.e.s.origin, PLAYER_MINS, PLAYER_MAXS, self.e.s.origin, self.e, contents_t::SOLID).startsolid)
		G_FixStuckObject(self, self.e.s.origin);

	// [Paril-KEX] on n64, since these can spawn riding elevators,
	// allow them to "ride" the elevators so respawning works
	if (level.is_n64 || level.is_psx || (self.spawnflags & spawnflags::player_start::SPAWN_RIDE) != 0)
	{
		@self.think = info_player_start_drop;
		self.nextthink = level.time + FRAME_TIME_S;
	}

	if ((pm_config.physics_flags & physics_flags_t::PSX_SCALE) != 0)
		self.e.s.origin[2] -= PLAYER_MINS[2] - (PLAYER_MINS[2] * PSX_PHYSICS_SCALAR);
}

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 32)
potential spawning position for deathmatch games
*/
void SP_info_player_deathmatch(ASEntity &self)
{
	if (deathmatch.integer == 0)
	{
        self.Free();
		return;
	}
	SP_misc_teleporter_dest(self);
}

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 32)
potential spawning position for coop games
*/
void SP_info_player_coop(ASEntity &self)
{
	if (coop.integer == 0)
	{
		G_FreeEdict(self);
		return;
	}

	SP_info_player_start(self);
}

/*QUAKED info_player_coop_lava (1 0 1) (-16 -16 -24) (16 16 32)
potential spawning position for coop games on rmine2 where lava level
needs to be checked
*/
void SP_info_player_coop_lava(ASEntity &self)
{
	if (coop.integer == 0)
	{
		G_FreeEdict(self);
		return;
	}

	// fix stuck spawn points
	if (gi_trace(self.e.s.origin, PLAYER_MINS, PLAYER_MAXS, self.e.s.origin, self.e, contents_t::SOLID).startsolid)
		G_FixStuckObject(self, self.e.s.origin);
}

/*QUAKED info_player_intermission (1 0 1) (-16 -16 -24) (16 16 32)
The deathmatch intermission point will be at one of these
Use 'angles' instead of 'angle', so you can set pitch or roll as well as yaw.  'pitch yaw roll'
*/
void SP_info_player_intermission(ASEntity &self)
{
}

//=======================================================================

void ClientObituary(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, mod_t mod)
{
    string base;

	if (coop.integer != 0 && attacker.client !is null)
		mod.friendly_fire = true;

	switch (mod.id)
	{
	case mod_id_t::SUICIDE:
		base = "$g_mod_generic_suicide";
		break;
	case mod_id_t::FALLING:
		base = "$g_mod_generic_falling";
		break;
	case mod_id_t::CRUSH:
		base = "$g_mod_generic_crush";
		break;
	case mod_id_t::WATER:
		base = "$g_mod_generic_water";
		break;
	case mod_id_t::SLIME:
		base = "$g_mod_generic_slime";
		break;
	case mod_id_t::LAVA:
		base = "$g_mod_generic_lava";
		break;
	case mod_id_t::EXPLOSIVE:
	case mod_id_t::BARREL:
		base = "$g_mod_generic_explosive";
		break;
	case mod_id_t::EXIT:
		base = "$g_mod_generic_exit";
		break;
	case mod_id_t::TARGET_LASER:
		base = "$g_mod_generic_laser";
		break;
	case mod_id_t::TARGET_BLASTER:
		base = "$g_mod_generic_blaster";
		break;
	case mod_id_t::BOMB:
	case mod_id_t::SPLASH:
	case mod_id_t::TRIGGER_HURT:
		base = "$g_mod_generic_hurt";
		break;
	// RAFAEL
	case mod_id_t::GEKK:
	case mod_id_t::BRAINTENTACLE:
		base = "$g_mod_generic_gekk";
		break;
	// RAFAEL
	default:
		break;
	}

	if (attacker is self)
	{
		switch (mod.id)
		{
		case mod_id_t::HELD_GRENADE:
			base = "$g_mod_self_held_grenade";
			break;
		case mod_id_t::HG_SPLASH:
		case mod_id_t::G_SPLASH:
			base = "$g_mod_self_grenade_splash";
			break;
		case mod_id_t::R_SPLASH:
			base = "$g_mod_self_rocket_splash";
			break;
		case mod_id_t::BFG_BLAST:
			base = "$g_mod_self_bfg_blast";
			break;
		// RAFAEL 03-MAY-98
		case mod_id_t::TRAP:
			base = "$g_mod_self_trap";
			break;
			// RAFAEL
			// ROGUE
		case mod_id_t::DOPPLE_EXPLODE:
			base = "$g_mod_self_dopple_explode";
			break;
			// ROGUE
		default:
			base = "$g_mod_self_default";
			break;
		}
	}

	// send generic/self
	if (!base.empty())
	{
		gi_LocBroadcast_Print(print_type_t::MEDIUM, base, self.client.pers.netname);
		if (deathmatch.integer != 0 && !mod.no_point_loss)
		{
			self.client.resp.score--;

			if (teamplay.integer != 0)
				G_AdjustTeamScore(self.client.resp.ctf_team, -1);
		}
		@self.enemy = null;
		return;
	}

	// has a killer
	@self.enemy = attacker;
	if (attacker.client !is null)
	{
		switch (mod.id)
		{
		case mod_id_t::BLASTER:
			base = "$g_mod_kill_blaster";
			break;
		case mod_id_t::SHOTGUN:
			base = "$g_mod_kill_shotgun";
			break;
		case mod_id_t::SSHOTGUN:
			base = "$g_mod_kill_sshotgun";
			break;
		case mod_id_t::MACHINEGUN:
			base = "$g_mod_kill_machinegun";
			break;
		case mod_id_t::CHAINGUN:
			base = "$g_mod_kill_chaingun";
			break;
		case mod_id_t::GRENADE:
			base = "$g_mod_kill_grenade";
			break;
		case mod_id_t::G_SPLASH:
			base = "$g_mod_kill_grenade_splash";
			break;
		case mod_id_t::ROCKET:
			base = "$g_mod_kill_rocket";
			break;
		case mod_id_t::R_SPLASH:
			base = "$g_mod_kill_rocket_splash";
			break;
		case mod_id_t::HYPERBLASTER:
			base = "$g_mod_kill_hyperblaster";
			break;
		case mod_id_t::RAILGUN:
			base = "$g_mod_kill_railgun";
			break;
		case mod_id_t::BFG_LASER:
			base = "$g_mod_kill_bfg_laser";
			break;
		case mod_id_t::BFG_BLAST:
			base = "$g_mod_kill_bfg_blast";
			break;
		case mod_id_t::BFG_EFFECT:
			base = "$g_mod_kill_bfg_effect";
			break;
		case mod_id_t::HANDGRENADE:
			base = "$g_mod_kill_handgrenade";
			break;
		case mod_id_t::HG_SPLASH:
			base = "$g_mod_kill_handgrenade_splash";
			break;
		case mod_id_t::HELD_GRENADE:
			base = "$g_mod_kill_held_grenade";
			break;
		case mod_id_t::TELEFRAG:
		case mod_id_t::TELEFRAG_SPAWN:
			base = "$g_mod_kill_telefrag";
			break;
		// RAFAEL 14-APR-98
		case mod_id_t::RIPPER:
			base = "$g_mod_kill_ripper";
			break;
		case mod_id_t::PHALANX:
			base = "$g_mod_kill_phalanx";
			break;
		case mod_id_t::TRAP:
			base = "$g_mod_kill_trap";
			break;
			// RAFAEL
			//===============
			// ROGUE
		case mod_id_t::CHAINFIST:
			base = "$g_mod_kill_chainfist";
			break;
		case mod_id_t::DISINTEGRATOR:
			base = "$g_mod_kill_disintegrator";
			break;
		case mod_id_t::ETF_RIFLE:
			base = "$g_mod_kill_etf_rifle";
			break;
		case mod_id_t::HEATBEAM:
			base = "$g_mod_kill_heatbeam";
			break;
		case mod_id_t::TESLA:
			base = "$g_mod_kill_tesla";
			break;
		case mod_id_t::PROX:
			base = "$g_mod_kill_prox";
			break;
		case mod_id_t::NUKE:
			base = "$g_mod_kill_nuke";
			break;
		case mod_id_t::VENGEANCE_SPHERE:
			base = "$g_mod_kill_vengeance_sphere";
			break;
		case mod_id_t::DEFENDER_SPHERE:
			base = "$g_mod_kill_defender_sphere";
			break;
		case mod_id_t::HUNTER_SPHERE:
			base = "$g_mod_kill_hunter_sphere";
			break;
		case mod_id_t::TRACKER:
			base = "$g_mod_kill_tracker";
			break;
		case mod_id_t::DOPPLE_EXPLODE:
			base = "$g_mod_kill_dopple_explode";
			break;
		case mod_id_t::DOPPLE_VENGEANCE:
			base = "$g_mod_kill_dopple_vengeance";
			break;
		case mod_id_t::DOPPLE_HUNTER:
			base = "$g_mod_kill_dopple_hunter";
			break;
			// ROGUE
			//===============
			// ZOID
		case mod_id_t::GRAPPLE:
			base = "$g_mod_kill_grapple";
			break;
			// ZOID
		default:
			base = "$g_mod_kill_generic";
			break;
		}

		gi_LocBroadcast_Print(print_type_t::MEDIUM, base, self.client.pers.netname, attacker.client.pers.netname);

		if (G_TeamplayEnabled())
		{
			// ZOID
			//  if at start and same team, clear.
			// [Paril-KEX] moved here so it's not an outlier in player_die.
			if (mod.id == mod_id_t::TELEFRAG_SPAWN &&
				self.client.resp.ctf_state < 2 &&
				self.client.resp.ctf_team == attacker.client.resp.ctf_team)
			{
				self.client.resp.ctf_state = 0;
				return;
			}
		}

		if (deathmatch.integer != 0)
		{
			if (mod.friendly_fire)
			{
				if (!mod.no_point_loss)
				{
					attacker.client.resp.score--;

					if (teamplay.integer != 0)
						G_AdjustTeamScore(attacker.client.resp.ctf_team, -1);
				}
			}
			else
			{
				attacker.client.resp.score++;

				if (teamplay.integer != 0)
					G_AdjustTeamScore(attacker.client.resp.ctf_team, 1);
			}
		}
		else if (coop.integer == 0)
			self.client.resp.score--;

		return;
	}

	gi_LocBroadcast_Print(print_type_t::MEDIUM, "$g_mod_generic_died", self.client.pers.netname);

	if (deathmatch.integer != 0 && !mod.no_point_loss)
	{
        self.client.resp.score--;

        if (teamplay.integer != 0)
            G_AdjustTeamScore(attacker.client.resp.ctf_team, -1);
	}
}

void TossClientWeapon(ASEntity &self)
{
	const gitem_t @item;
	ASEntity @drop;
	bool	 quad;
	// RAFAEL
	bool quadfire;
	// RAFAEL
	float spread;

	if (deathmatch.integer == 0)
		return;

	@item = self.client.pers.weapon;
	if (item !is null && g_instagib.integer != 0)
		@item = null;
	if (item !is null && self.client.pers.inventory[self.client.pers.weapon.ammo] == 0)
		@item = null;
	if (item !is null && item.drop is null)
		@item = null;

	if (g_dm_no_quad_drop.integer != 0)
		quad = false;
	else
		quad = (self.client.quad_time > level.time + time_sec(1));

	// RAFAEL
	if (g_dm_no_quadfire_drop.integer != 0)
		quadfire = false;
	else
		quadfire = (self.client.quadfire_time > level.time + time_sec(1));
	// RAFAEL

	if (item !is null && quad)
		spread = 22.5;
	// RAFAEL
	else if (item !is null && quadfire)
		spread = 12.5;
	// RAFAEL
	else
		spread = 0.0;

	if (item !is null)
	{
		self.client.v_angle.yaw -= spread;
		@drop = Drop_Item(self, item);
		self.client.v_angle.yaw += spread;
		drop.spawnflags |= spawnflags::item::DROPPED_PLAYER;
		drop.spawnflags &= ~spawnflags::item::DROPPED;
		drop.e.svflags = svflags_t(drop.e.svflags & ~svflags_t::INSTANCED);
	}

	if (quad)
	{
		self.client.v_angle.yaw += spread;
		@drop = Drop_Item(self, GetItemByIndex(item_id_t::ITEM_QUAD));
		self.client.v_angle.yaw -= spread;
		drop.spawnflags |= spawnflags::item::DROPPED_PLAYER;
		drop.spawnflags &= ~spawnflags::item::DROPPED;
		drop.e.svflags = svflags_t(drop.e.svflags & ~svflags_t::INSTANCED);

		@drop.touch = Touch_Item;
		drop.nextthink = self.client.quad_time;
		@drop.think = G_FreeEdict;
	}

	// RAFAEL
	if (quadfire)
	{
		self.client.v_angle.yaw += spread;
		@drop = Drop_Item(self, GetItemByIndex(item_id_t::ITEM_QUADFIRE));
		self.client.v_angle.yaw -= spread;
		drop.spawnflags |= spawnflags::item::DROPPED_PLAYER;
		drop.spawnflags &= ~spawnflags::item::DROPPED;
		drop.e.svflags = svflags_t(drop.e.svflags & ~svflags_t::INSTANCED);

		@drop.touch = Touch_Item;
		drop.nextthink = self.client.quadfire_time;
		@drop.think = G_FreeEdict;
	}
	// RAFAEL
}

/*
==================
LookAtKiller
==================
*/
void LookAtKiller(ASEntity &self, ASEntity &inflictor, ASEntity &attacker)
{
	vec3_t dir;

	if (attacker !is world && attacker !is self)
	{
		dir = attacker.e.s.origin - self.e.s.origin;
	}
	else if (inflictor !is world && inflictor !is self)
	{
		dir = inflictor.e.s.origin - self.e.s.origin;
	}
	else
	{
		self.client.killer_yaw = self.e.s.angles.yaw;
		return;
	}
	// PMM - fixed to correct for pitch of 0
	if (dir.x != 0)
		self.client.killer_yaw = 180 / PIf * atan2(dir.y, dir.x);
	else if (dir.y > 0)
		self.client.killer_yaw = 90;
	else if (dir.y < 0)
		self.client.killer_yaw = 270;
	else
		self.client.killer_yaw = 0;
}

/*
==================
player_die
==================
*/
const array<string> player_death_sounds = {
    "*death1.wav",
    "*death2.wav",
    "*death3.wav",
    "*death4.wav"
};

void player_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	PlayerTrail_Destroy(self);

	self.avelocity = vec3_origin;

	self.takedamage = true;
	self.movetype = movetype_t::TOSS;

	self.e.s.modelindex2 = 0; // remove linked weapon model
							 // ZOID
	self.e.s.modelindex3 = 0; // remove linked ctf flag
							 // ZOID

	self.e.s.angles.x = 0;
	self.e.s.angles.z = 0;

	self.e.s.sound = 0;
	self.client.weapon_sound = 0;

	self.e.maxs[2] = -8;

	//	self.solid = SOLID_NOT;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);

	if (!self.deadflag)
	{
		self.client.respawn_time = ( level.time + time_sec(1) );
		if ( deathmatch.integer != 0 && g_dm_force_respawn_time.integer != 0 ) {
			self.client.respawn_time = ( level.time + time_sec( g_dm_force_respawn_time.value ) );
		}

		LookAtKiller(self, inflictor, attacker);
		self.e.client.ps.pmove.pm_type = pmtype_t::DEAD;
		ClientObituary(self, inflictor, attacker, mod);

		CTFFragBonuses(self, inflictor, attacker);
		// ZOID
		TossClientWeapon(self);
		// ZOID
		CTFPlayerResetGrapple(self);
		CTFDeadDropFlag(self);
		CTFDeadDropTech(self);
		// ZOID
		if (deathmatch.integer != 0 && !self.client.showscores)
			Cmd_Help_f(self); // show scores

		if (coop.integer != 0 && !P_UseCoopInstancedItems())
		{
			// clear inventory
			// this is kind of ugly, but it's how we want to handle keys in coop
			for (item_id_t n = item_id_t(item_id_t::NULL + 1); n < item_id_t::TOTAL; n = item_id_t(n + 1))
			{
				if (coop.integer != 0 && (itemlist[n].flags & item_flags_t::KEY) != 0)
					self.client.resp.coop_respawn.inventory[n] = self.client.pers.inventory[n];
				self.client.pers.inventory[n] = 0;
			}
		}
	}

	// remove powerups
	self.client.quad_time = time_zero;
	self.client.invincible_time = time_zero;
	self.client.breather_time = time_zero;
	self.client.enviro_time = time_zero;
	self.client.invisible_time = time_zero;
	self.flags = ent_flags_t(self.flags & ~ent_flags_t::POWER_ARMOR);

	// clear inventory
	if (G_TeamplayEnabled())
        for (uint i = 0; i < item_id_t::TOTAL; i++)
            self.client.pers.inventory[i] = 0;

	// RAFAEL
	self.client.quadfire_time = time_zero;
	// RAFAEL

	//==============
	// ROGUE stuff
	self.client.double_time = time_zero;

	// if there's a sphere around, let it know the player died.
	// vengeance and hunter will die if they're not attacking,
	// defender should always die
	if (self.client.owned_sphere !is null)
	{
		ASEntity @sphere;

		@sphere = self.client.owned_sphere;
		sphere.die(sphere, self, self, 0, vec3_origin, mod);
	}

	// if we've been killed by the tracker, GIB!
	if (mod.id == mod_id_t::TRACKER)
	{
		self.health = -100;
		damage = 400;
	}

	// make sure no trackers are still hurting us.
	if (self.client.tracker_pain_time)
	{
		RemoveAttackingPainDaemons(self);
	}

	// if we got obliterated by the nuke, don't gib
	if ((self.health < -80) && (mod.id == mod_id_t::NUKE))
		self.flags = ent_flags_t(self.flags | ent_flags_t::NOGIB);

	// ROGUE
	//==============

	if (self.health < -40)
	{
		// PMM
		// don't toss gibs if we got vaped by the nuke
		if ((self.flags & ent_flags_t::NOGIB) == 0)
		{
			// pmm
			// gib
			gi_sound(self.e, soundchan_t::BODY, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

			// more meaty gibs for your dollar!
			if (deathmatch.integer != 0 && (self.health < -80))
				ThrowGibs(self, damage, { gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2") });
			
			ThrowGibs(self, damage, { gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2") });
			// PMM
		}
		self.flags = ent_flags_t(self.flags & ~ent_flags_t::NOGIB);
		// pmm

		ThrowClientHead(self, damage);
		// ZOID
		self.client.anim_priority = anim_priority_t::DEATH;
		self.client.anim_end = 0;
		// ZOID
		self.takedamage = false;
	}
	else
	{ // normal death
		if (!self.deadflag)
		{
			// start a death animation
			self.client.anim_priority = anim_priority_t::DEATH;
			if ((self.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
			{
				self.e.s.frame = player::frames::crdeath1 - 1;
				self.client.anim_end = player::frames::crdeath5;
			}
			else
			{
				switch (irandom(3))
				{
				case 0:
					self.e.s.frame = player::frames::death101 - 1;
					self.client.anim_end = player::frames::death106;
					break;
				case 1:
					self.e.s.frame = player::frames::death201 - 1;
					self.client.anim_end = player::frames::death206;
					break;
				case 2:
					self.e.s.frame = player::frames::death301 - 1;
					self.client.anim_end = player::frames::death308;
					break;
				}
			}
			gi_sound(self.e, soundchan_t::VOICE, gi_soundindex(player_death_sounds[irandom(player_death_sounds.length())]), 1, ATTN_NORM, 0);
			self.client.anim_time = time_zero;
		}
	}

	if (!self.deadflag)
	{
		if (coop.integer != 0 && (g_coop_squad_respawn.integer != 0 || g_coop_enable_lives.integer != 0))
		{
			if (g_coop_enable_lives.integer != 0 && self.client.pers.lives != 0)
			{
				self.client.pers.lives--;
				self.client.resp.coop_respawn.lives--;
			}

			bool allPlayersDead = true;

            foreach (ASEntity @player : active_players)
            {
				if (player.health > 0 || (!level.deadly_kill_box && g_coop_enable_lives.integer != 0 && player.client.pers.lives > 0))
				{
					allPlayersDead = false;
					break;
				}
            }

			if (allPlayersDead) // allow respawns for telefrags and weird shit
			{
				level.coop_level_restart_time = level.time + time_sec(5);

                foreach (ASEntity @player : active_players)
					gi_LocCenter_Print(player.e, "$g_coop_lose");
			}
		
			// in 3 seconds, attempt a respawn or put us into
			// spectator mode
			if (!level.coop_level_restart_time)
				self.client.respawn_time = level.time + time_sec(3);
		}
	}

	self.deadflag = true;

	gi_linkentity(self.e);
}

// [Paril-KEX]
void Player_GiveStartItems(ASEntity &ent, const string &in items)
{
    tokenizer_t tokenizer(items);
    tokenizer.separators = ";";

	while (tokenizer.next())
	{
		if (!tokenizer.has_token)
        {
            gi_Com_Print("start_items string too long or ends early\n");
			break;
        }

        tokenizer.push_state();
        tokenizer.separators = " ";

        if (!tokenizer.next())
            gi_Com_Error("Invalid start_items string");

		const gitem_t @item = FindItemByClassname(tokenizer.as_string());

		if (item is null || item.pickup is null)
			gi_Com_Error("Invalid g_start_item entry: {}\n", tokenizer.as_string());

		int count = 1;

		if (tokenizer.next())
			count = tokenizer.as_int32();

		if (count == 0)
			ent.client.pers.inventory[item.id] = 0;
        else
        {
            ASEntity @dummy = G_Spawn();
            @dummy.item = item;
            dummy.count = count;
            dummy.spawnflags |= spawnflags::item::DROPPED;
            item.pickup(dummy, ent);
            G_FreeEdict(dummy);
        }

        tokenizer.pop_state();
        tokenizer.separators = ";";
	}
}

/*
==============
InitClientPersistant

This is only called when the game first initializes in single player,
but is called after each death and level change in deathmatch
==============
*/
void InitClientPersistant(ASEntity &ent)
{
	// backup & restore userinfo
	string userinfo = ent.client.pers.userinfo;
    ent.client.pers = client_persistant_t();
	ClientUserinfoChanged(ent.e, userinfo);

	ent.client.pers.health = 100;
	ent.client.pers.max_health = 100;

	// don't give us weapons if we shouldn't have any
	if ((G_TeamplayEnabled() && ent.client.resp.ctf_team != ctfteam_t::NOTEAM) ||
		(!G_TeamplayEnabled() && !ent.client.resp.spectator))
	{
		// in coop, if there's already a player in the game and we're new,
		// steal their loadout. this would fix a potential softlock where a new
		// player may not have weapons at all.
		bool taken_loadout = false;

		if (coop.integer != 0)
		{
			foreach (ASEntity @player : active_players)
			{
				if (player is ent || !player.client.pers.spawned ||
					player.client.resp.spectator || player.movetype == movetype_t::NOCLIP)
					continue;

				ent.client.pers.inventory = player.client.pers.inventory;
				ent.client.pers.max_ammo = player.client.pers.max_ammo;
				ent.client.pers.power_cubes = player.client.pers.power_cubes;
				taken_loadout = true;
				break;
			}
		}

		if (!taken_loadout)
		{
			// fill with 50s, since it's our most common value
            for (uint i = 0; i < ent.client.pers.max_ammo.length(); i++)
                ent.client.pers.max_ammo[i] = 50;
			//ent.client.pers.max_ammo.fill(50);
			ent.client.pers.max_ammo[ammo_t::BULLETS] = 200;
			ent.client.pers.max_ammo[ammo_t::SHELLS] = 100;
			ent.client.pers.max_ammo[ammo_t::CELLS] = 200;

			// RAFAEL
			ent.client.pers.max_ammo[ammo_t::TRAP] = 5;
			// RAFAEL
			// ROGUE
			ent.client.pers.max_ammo[ammo_t::FLECHETTES] = 200;
			ent.client.pers.max_ammo[ammo_t::DISRUPTOR] = 12;
			ent.client.pers.max_ammo[ammo_t::TESLA] = 5;
			// ROGUE

			if (deathmatch.integer == 0 || g_instagib.integer == 0)
				ent.client.pers.inventory[item_id_t::WEAPON_BLASTER] = 1;

			// [Kex]
			// start items!
			if (!g_start_items.stringval.empty())
				Player_GiveStartItems(ent, g_start_items.stringval);
			else if (deathmatch.integer != 0 && g_instagib.integer != 0)
			{
				ent.client.pers.inventory[item_id_t::WEAPON_RAILGUN] = 1;
				ent.client.pers.inventory[item_id_t::AMMO_SLUGS] = 99;
			}

			if (!level.start_items.empty())
				Player_GiveStartItems(ent, level.start_items);

			// power armor from start items
			G_CheckPowerArmor(ent);

			if (deathmatch.integer == 0)
				ent.client.pers.inventory[item_id_t::ITEM_COMPASS] = 1;

			// ZOID
			bool give_grapple = (g_allow_grapple.stringval == "auto") ?
				(ctf.integer != 0 ? !level.no_grapple : false) :
				g_allow_grapple.integer != 0;

			if (give_grapple)
				ent.client.pers.inventory[item_id_t::WEAPON_GRAPPLE] = 1;
			// ZOID
		}

		NoAmmoWeaponChange(ent, false);

		@ent.client.pers.weapon = @ent.client.newweapon;
		if (ent.client.newweapon !is null)
			ent.client.pers.selected_item = ent.client.newweapon.id;
		@ent.client.newweapon = null;
		// ZOID
		@ent.client.pers.lastweapon = @ent.client.pers.weapon;
		// ZOID
	}

	if (coop.integer != 0 && g_coop_enable_lives.integer != 0)
		ent.client.pers.lives = g_coop_num_lives.integer + 1;

	if (ent.client.pers.autoshield >= AUTO_SHIELD_AUTO)
		ent.client.pers.savedFlags = ent_flags_t(ent.client.pers.savedFlags | ent_flags_t::WANTS_POWER_ARMOR);

	ent.client.pers.connected = true;
	ent.client.pers.spawned = true;
}

void InitClientResp(ASEntity &ent)
{
	// ZOID
	ctfteam_t ctf_team = ent.client.resp.ctf_team;
	bool id_state = ent.client.resp.id_state;
	// ZOID

    ent.client.resp = client_respawn_t();

	// ZOID
	ent.client.resp.ctf_team = ctf_team;
	ent.client.resp.id_state = id_state;
	// ZOID

	ent.client.resp.entertime = level.time;
	ent.client.resp.coop_respawn = ent.client.pers;
}

/*
==================
Some information that should be persistant, like health,
is still stored in the edict structure, so it needs to
be mirrored out to the client structure before all the
edicts are wiped.
==================
*/
void SaveClientData()
{
	ASEntity @ent;

	for (uint i = 0; i < players.length(); i++)
	{
		@ent = @players[i];
		if (!ent.e.inuse)
			continue;
		ent.client.pers.health = ent.health;
		ent.client.pers.max_health = ent.max_health;
		ent.client.pers.savedFlags = ent_flags_t(ent.flags & (ent_flags_t::FLASHLIGHT | ent_flags_t::GODMODE | ent_flags_t::NOTARGET | ent_flags_t::POWER_ARMOR | ent_flags_t::WANTS_POWER_ARMOR));
		if (coop.integer != 0)
			ent.client.pers.score = ent.client.resp.score;
	}
}

void FetchClientEntData(ASEntity &ent)
{
	ent.health = ent.client.pers.health;
	ent.max_health = ent.client.pers.max_health;
	ent.flags = ent_flags_t(ent.flags | ent.client.pers.savedFlags);
	if (coop.integer != 0)
		ent.client.resp.score = ent.client.pers.score;
}

/*
=======================================================================

  SelectSpawnPoint

=======================================================================
*/

/*
================
PlayersRangeFromSpot

Returns the distance to the nearest player from the given spot
================
*/
float PlayersRangeFromSpot(ASEntity &spot)
{
	ASEntity @player;
	float	 bestplayerdistance;
	vec3_t	 v;
	float	 playerdistance;

	bestplayerdistance = 9999999;

	for (uint32 n = 1; n <= max_clients; n++)
	{
		@player = @entities[n];

		if (!player.e.inuse)
			continue;

		if (player.health <= 0)
			continue;

		v = spot.e.s.origin - player.e.s.origin;
		playerdistance = v.length();

		if (playerdistance < bestplayerdistance)
			bestplayerdistance = playerdistance;
	}

	return bestplayerdistance;
}

bool SpawnPointClear(ASEntity &spot)
{
	vec3_t p = spot.e.s.origin + vec3_t(0, 0, 9.0f);
	return !gi_trace(p, PLAYER_MINS, PLAYER_MAXS, p, spot.e, contents_t(contents_t::PLAYER | contents_t::MONSTER)).startsolid;
}

class spawn_point_t
{
	ASEntity    @point = null;
    float       dist = 0;

	spawn_point_t() { }

    spawn_point_t(ASEntity @point, float dist)
    {
        @this.point = @point;
        this.dist = dist;
    }
}

class select_spawn_result_t
{
	ASEntity    @spot;
	bool		any_valid; // set if a spawn point was found, even if it was taken

    select_spawn_result_t(ASEntity @spot = null, bool any_valid = false)
    {
        @this.spot = @spot;
        this.any_valid = any_valid;
    }
};

select_spawn_result_t SelectDeathmatchSpawnPoint(bool farthest, bool force_spawn, bool fallback_to_ctf_or_start)
{
	array<spawn_point_t> spawn_points;

	// gather all spawn points 
	ASEntity @spot = null;
	while ((@spot = find_by_str<ASEntity>(spot, "classname", "info_player_deathmatch")) !is null)
		spawn_points.push_back(spawn_point_t(spot, PlayersRangeFromSpot(spot)));

	// no points
	if (spawn_points.empty())
	{
		// try CTF spawns...
		if (fallback_to_ctf_or_start)
		{
			@spot = null;
			while ((@spot = find_by_str<ASEntity>(spot, "classname", "info_player_team1")) !is null)
				spawn_points.push_back(spawn_point_t(spot, PlayersRangeFromSpot(spot)));
			@spot = null;
			while ((@spot = find_by_str<ASEntity>(spot, "classname", "info_player_team2")) !is null)
				spawn_points.push_back(spawn_point_t(spot, PlayersRangeFromSpot(spot)));

			// we only have an info_player_start then
			if (spawn_points.empty())
			{
				@spot = find_by_str<ASEntity>(null, "classname", "info_player_start");

				if (spot !is null)
					spawn_points.push_back(spawn_point_t(spot, PlayersRangeFromSpot(spot)));

				// map is malformed
				if (spawn_points.empty())
					return select_spawn_result_t();
			}
		}
		else
			return select_spawn_result_t();
	}

	// if there's only one spawn point, that's the one.
	if (spawn_points.length() == 1)
	{
		if (force_spawn || SpawnPointClear(spawn_points[0].point))
			return select_spawn_result_t(spawn_points[0].point, true);

		return select_spawn_result_t(null, true);
	}

	// order by distances ascending (top of list has closest players to point)
    spawn_points.sort(function(a, b) { return a.dist < b.dist; });

	// farthest spawn is simple
	if (farthest)
	{
		for (int64 i = spawn_points.length() - 1; i >= 0; --i)
		{
			if (SpawnPointClear(spawn_points[i].point))
				return select_spawn_result_t(spawn_points[i].point, true);
		}

		// none clear
	}
	else
	{
		// for random, select a random point other than the two
		// that are closest to the player if possible.
		// shuffle the non-distance-related spawn points
		spawn_points.shuffle(2);

		// run down the list and pick the first one that we can use
		for (uint i = 2; i != spawn_points.length(); ++i)
		{
			@spot = @spawn_points[i].point;

			if (SpawnPointClear(spot))
				return select_spawn_result_t(spot, true);
		}

		// none clear, so we have to pick one of the other two
		if (SpawnPointClear(spawn_points[1].point))
			return select_spawn_result_t(spawn_points[1].point, true);
		else if (SpawnPointClear(spawn_points[0].point))
			return select_spawn_result_t(spawn_points[0].point, true);
	}
		
	if (force_spawn)
        return select_spawn_result_t(spawn_points[irandom(spawn_points.length())].point, true);
        // AS_TODO: random_element?
		//return { random_element(spawn_points).point, true };

	return select_spawn_result_t(null, true);
}

/*
//===============
// ROGUE
edict_t *SelectLavaCoopSpawnPoint(edict_t *ent)
{
	int		 index;
	edict_t *spot = null;
	float	 lavatop;
	edict_t *lava;
	edict_t *pointWithLeastLava;
	float	 lowest;
	edict_t *spawnPoints[64];
	vec3_t	 center;
	int		 numPoints;
	edict_t *highestlava;

	lavatop = -99999;
	highestlava = null;

	// first, find the highest lava
	// remember that some will stop moving when they've filled their
	// areas...
	lava = null;
	while (1)
	{
		lava = G_FindByStringClassname(lava, "func_water");
		if (!lava)
			break;

		center = lava.absmax + lava.absmin;
		center *= 0.5f;

		if (lava.spawnflags.has(SPAWNFLAG_WATER_SMART) && (gi.pointcontents(center) & MASK_WATER))
		{
			if (lava.absmax[2] > lavatop)
			{
				lavatop = lava.absmax[2];
				highestlava = lava;
			}
		}
	}

	// if we didn't find ANY lava, then return null
	if (!highestlava)
		return null;

	// find the top of the lava and include a small margin of error (plus bbox size)
	lavatop = highestlava.absmax[2] + 64;

	// find all the lava spawn points and store them in spawnPoints[]
	spot = null;
	numPoints = 0;
	while ((spot = G_FindByStringClassname(spot, "info_player_coop_lava")))
	{
		if (numPoints == 64)
			break;

		spawnPoints[numPoints++] = spot;
	}

	// walk up the sorted list and return the lowest, open, non-lava spawn point
	spot = null;
	lowest = 999999;
	pointWithLeastLava = null;
	for (index = 0; index < numPoints; index++)
	{
		if (spawnPoints[index].s.origin[2] < lavatop)
			continue;

		if (PlayersRangeFromSpot(spawnPoints[index]) > 32)
		{
			if (spawnPoints[index].s.origin[2] < lowest)
			{
				// save the last point
				pointWithLeastLava = spawnPoints[index];
				lowest = spawnPoints[index].s.origin[2];
			}
		}
	}

	return pointWithLeastLava;
}
// ROGUE
//===============
*/

// [Paril-KEX]
ASEntity @SelectSingleSpawnPoint(ASEntity &ent)
{
	ASEntity @spot = null;

	while ((@spot = find_by_str<ASEntity>(spot, "classname", "info_player_start")) != null)
	{
		if (game.spawnpoint.empty() && spot.targetname.empty())
			break;

		if (game.spawnpoint.empty() || spot.targetname.empty())
			continue;

		if (Q_strcasecmp(game.spawnpoint, spot.targetname) == 0)
			break;
	}

	if (spot is null)
	{
		// there wasn't a matching targeted spawnpoint, use one that has no targetname
		while ((@spot = find_by_str<ASEntity>(spot, "classname", "info_player_start")) !is null)
			if (spot.targetname.empty())
				return spot;
	}

	// none at all, so just pick any
	if (spot is null)
		return find_by_str<ASEntity>(spot, "classname", "info_player_start");

	return spot;
}

namespace internal
{
    contents_t unsafe_spawn_position_mask;
}

// [Paril-KEX]
ASEntity @G_UnsafeSpawnPosition(vec3_t spot, bool check_players)
{
	contents_t mask = contents_t::MASK_PLAYERSOLID;

	if (!check_players)
		mask = contents_t(mask & ~contents_t::PLAYER);

	trace_t tr = gi_trace(spot, PLAYER_MINS, PLAYER_MAXS, spot, null, mask);

	// sometimes the spot is too close to the ground, give it a bit of slack
	if (tr.startsolid && tr.ent.client is null)
	{
		spot[2] += 1;
		tr = gi_trace(spot, PLAYER_MINS, PLAYER_MAXS, spot, null, mask);
	}

	// no idea why this happens in some maps..
	if (tr.startsolid && tr.ent.client is null)
	{
		// try a nudge
        internal::unsafe_spawn_position_mask = mask;
		if (G_FixStuckObject_Generic(spot, PLAYER_MINS, PLAYER_MAXS, function(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end) {
			return gi_trace(start, mins, maxs, end, null, internal::unsafe_spawn_position_mask);
		}, spot) == stuck_result_t::NO_GOOD_POSITION)
			return entities[tr.ent.number]; // what do we do here...?

		trace_t tr2 = gi_trace(spot, PLAYER_MINS, PLAYER_MAXS, spot, null, mask);

		if (tr2.startsolid && tr2.ent.client is null)
			return entities[tr2.ent.number]; // what do we do here...?
	}

	if (tr.fraction == 1.f)
		return null;
	else if (check_players && tr.ent !is null && tr.ent.client !is null)
		return entities[tr.ent.number];

	return null;
}

ASEntity @SelectCoopSpawnPoint(ASEntity &ent, bool force_spawn, bool check_players)
{
    return null;
/*
	edict_t	*spot = null;
	const char *target;

	// ROGUE
	//  rogue hack, but not too gross...
	if (!Q_strcasecmp(level.mapname, "rmine2"))
		return SelectLavaCoopSpawnPoint(ent);
	// ROGUE

	// try the main spawn point first
	spot = SelectSingleSpawnPoint(ent);

	if (spot && !G_UnsafeSpawnPosition(spot.s.origin, check_players))
		return spot;

	spot = null;

	// assume there are four coop spots at each spawnpoint
	int32_t num_valid_spots = 0;

	while (1)
	{
		spot = G_FindByStringClassname(spot, "info_player_coop");
		if (!spot)
			break; // we didn't have enough...

		target = spot.targetname;
		if (!target)
			target = "";
		if (Q_strcasecmp(game.spawnpoint, target) == 0)
		{ // this is a coop spawn point for one of the clients here
			num_valid_spots++;

			if (!G_UnsafeSpawnPosition(spot.s.origin, check_players))
				return spot; // this is it
		}
	}

	bool use_targetname = true;

	// if we didn't find any spots, map is probably set up wrong.
	// use empty targetname ones.
	if (!num_valid_spots)
	{
		use_targetname = false;

		while (1)
		{
			spot = G_FindByStringClassname(spot, "info_player_coop");
			if (!spot)
				break; // we didn't have enough...

			target = spot.targetname;
			if (!target)
			{
				// this is a coop spawn point for one of the clients here
				num_valid_spots++;

				if (!G_UnsafeSpawnPosition(spot.s.origin, check_players))
					return spot; // this is it
			}
		}
	}

	// if player collision is disabled, just pick a random spot
	if (!g_coop_player_collision.integer)
	{
		spot = null;

		num_valid_spots = irandom(num_valid_spots);

		while (1)
		{
			spot = G_FindByStringClassname(spot, "info_player_coop");

			if (!spot)
				break; // we didn't have enough...

			target = spot.targetname;
			if (use_targetname && !target)
				target = "";
			if (use_targetname ? (Q_strcasecmp(game.spawnpoint, target) == 0) : !target)
			{ // this is a coop spawn point for one of the clients here
				num_valid_spots++;

				if (!num_valid_spots)
					return spot;

				--num_valid_spots;
			}
		}

		// if this fails, just fall through to some other spawn.
	}

	// no safe spots..?
	if (force_spawn || !g_coop_player_collision.integer)
		return SelectSingleSpawnPoint(spot);
	
	return null;
*/
}

namespace internal
{
    ASEntity @landmark_ent;
}

bool TryLandmarkSpawn(ASEntity &ent, const vec3_t &in spot_origin, vec3_t &out origin, vec3_t &out angles)
{
	// if transitioning from another level with a landmark seamless transition
	// just set the location here
	if (ent.client.landmark_name.empty())
	{
		return false;
	}

	ASEntity @landmark = G_PickTarget(ent.client.landmark_name);
	if (landmark is null)
	{
		return false;
	}

	vec3_t old_origin = spot_origin;
	origin = ent.client.landmark_rel_pos;
	
	// rotate our relative landmark into our new landmark's frame of reference
	origin = RotatePointAroundVector({ 1, 0, 0 }, origin, landmark.e.s.angles[0]);
	origin = RotatePointAroundVector({ 0, 1, 0 }, origin, landmark.e.s.angles[2]);
	origin = RotatePointAroundVector({ 0, 0, 1 }, origin, landmark.e.s.angles[1]);

	origin += landmark.e.s.origin;

	angles = ent.client.oldviewangles + landmark.e.s.angles;

	if ((landmark.spawnflags & spawnflags::landmark::KEEP_Z) != 0)
		origin.z = spot_origin.z;

	// sometimes, landmark spawns can cause slight inconsistencies in collision;
	// we'll do a bit of tracing to make sure the bbox is clear
    @internal::landmark_ent = ent;
	if (G_FixStuckObject_Generic(origin, PLAYER_MINS, PLAYER_MAXS, function(start, mins, maxs, end) {
			return gi_trace(start, mins, maxs, end, internal::landmark_ent.e, contents_t(contents_t::MASK_PLAYERSOLID & ~contents_t::PLAYER));
		}, origin) == stuck_result_t::NO_GOOD_POSITION)
	{
		origin = old_origin;
		return false;
	}

	ent.e.s.origin = origin;

	// rotate the velocity that we grabbed from the map
	if (ent.velocity)
	{
		ent.velocity = RotatePointAroundVector({ 1, 0, 0 }, ent.velocity, landmark.e.s.angles[0]);
		ent.velocity = RotatePointAroundVector({ 0, 1, 0 }, ent.velocity, landmark.e.s.angles[2]);
		ent.velocity = RotatePointAroundVector({ 0, 0, 1 }, ent.velocity, landmark.e.s.angles[1]);
	}

	return true;
}


//======================================================================

const uint BODY_QUEUE_SIZE = 8;

void InitBodyQue()
{
	int		 i;
	ASEntity @ent;

	level.body_que = 0;
	for (i = 0; i < BODY_QUEUE_SIZE; i++)
	{
		@ent = G_Spawn();
		ent.classname = "bodyque";
	}
}

void body_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.e.s.modelindex == MODELINDEX_PLAYER &&
		self.health < self.gib_health)
	{
		gi_sound(self.e, soundchan_t::BODY, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
		ThrowGibs(self, damage, { gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2") });
		self.e.s.origin[2] -= 48;
		ThrowClientHead(self, damage);
	}

	if (mod.id == mod_id_t::CRUSH)
	{
		// prevent explosion singularities
		self.e.svflags = svflags_t::NOCLIENT;
		self.takedamage = false;
		self.e.solid = solid_t::NOT;
		self.movetype = movetype_t::NOCLIP;
		gi_linkentity(self.e);
	}
}

void CopyToBodyQue(ASEntity &ent)
{
	// if we were completely removed, don't bother with a body
	if (ent.e.s.modelindex == 0)
		return;

	ASEntity @body;

	// grab a body que and cycle to the next one
	@body = entities[max_clients + level.body_que + 1];
	level.body_que = (level.body_que + 1) % BODY_QUEUE_SIZE;

	// FIXME: send an effect on the removed body

	gi_unlinkentity(ent.e);

	gi_unlinkentity(body.e);
	body.e.s = ent.e.s;
	body.e.s.skinnum = ent.e.s.skinnum & 0xFF; // only copy the client #
	body.e.s.effects = effects_t::NONE;
	body.e.s.renderfx = renderfx_t::NONE;

	body.e.svflags = ent.e.svflags;
	body.e.absmin = ent.e.absmin;
	body.e.absmax = ent.e.absmax;
	body.e.size = ent.e.size;
	body.e.solid = ent.e.solid;
	body.e.clipmask = ent.e.clipmask;
	@body.owner = ent.owner;
	body.movetype = ent.movetype;
	body.health = ent.health;
	body.gib_health = ent.gib_health;
	body.e.s.event = entity_event_t::OTHER_TELEPORT;
	body.velocity = ent.velocity;
	body.avelocity = ent.avelocity;
	@body.groundentity = ent.groundentity;
	body.groundentity_linkcount = ent.groundentity_linkcount;

	if (ent.takedamage)
	{
		body.e.mins = ent.e.mins;
		body.e.maxs = ent.e.maxs;
	}
	else
		body.e.mins = body.e.maxs = vec3_origin;

	@body.die = body_die;
	body.takedamage = true;

	gi_linkentity(body.e);
}

void G_PostRespawn(ASEntity &self)
{
	if ((self.e.svflags & svflags_t::NOCLIENT) != 0)
		return;

	// add a teleportation effect
	self.e.s.event = entity_event_t::PLAYER_TELEPORT;

	// hold in place briefly
	self.e.client.ps.pmove.pm_flags = pmflags_t::TIME_TELEPORT;
	self.e.client.ps.pmove.pm_time = 112;

	self.client.respawn_time = level.time;
}

void respawn(ASEntity &self)
{
	if (deathmatch.integer != 0 || coop.integer != 0)
	{
		// spectators don't leave bodies
		if (!self.client.resp.spectator)
			CopyToBodyQue(self);
		self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
		PutClientInServer(self);

		G_PostRespawn(self);
		return;
	}

	// restart the entire server
	gi_AddCommandString("menu_loadgame\n");
}

/*
 * only called when pers.spectator changes
 * note that resp.spectator should be the opposite of pers.spectator here
 */
void spectator_respawn(ASEntity &ent)
{
	uint i, numspec;

	// if the user wants to become a spectator, make sure he doesn't
	// exceed max_spectators

	if (ent.client.pers.spectator)
	{
		string value;
		gi_Info_ValueForKey(ent.client.pers.userinfo, "spectator", value);

		if (!spectator_password.stringval.empty() &&
			spectator_password.stringval != "none" &&
			spectator_password.stringval != value)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "Spectator password incorrect.\n");
			ent.client.pers.spectator = false;
			gi_WriteByte(svc_t::stufftext);
			gi_WriteString("spectator 0\n");
			gi_unicast(ent.e, true);
			return;
		}

		// count spectators
        i = 1;
        numspec = 0;
		for (; i <= max_clients; i++)
			if (entities[i].e.inuse && entities[i].client.pers.spectator)
				numspec++;

		if (numspec >= uint(maxspectators.integer))
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "Server spectator limit is full.");
			ent.client.pers.spectator = false;
			// reset his spectator var
			gi_WriteByte(svc_t::stufftext);
			gi_WriteString("spectator 0\n");
			gi_unicast(ent.e, true);
			return;
		}
	}
	else
	{
		// he was a spectator and wants to join the game
		// he must have the right password
		string value;
		gi_Info_ValueForKey(ent.client.pers.userinfo, "password", value);

		if (!password.stringval.empty() &&
            password.stringval != "none" &&
			password.stringval != value)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "Password incorrect.\n");
			ent.client.pers.spectator = true;
			gi_WriteByte(svc_t::stufftext);
			gi_WriteString("spectator 1\n");
			gi_unicast(ent.e, true);
			return;
		}
	}

	// clear score on respawn
	ent.client.resp.score = ent.client.pers.score = 0;

	// move us to no team
	ent.client.resp.ctf_team = ctfteam_t::NOTEAM;

	// change spectator mode
	ent.client.resp.spectator = ent.client.pers.spectator;

	ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::NOCLIENT);
	PutClientInServer(ent);

	// add a teleportation effect
	if (!ent.client.pers.spectator)
	{
		// send effect
		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(player_muzzle_t::LOGIN);
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

		// hold in place briefly
		ent.e.client.ps.pmove.pm_flags = pmflags_t::TIME_TELEPORT;
		ent.e.client.ps.pmove.pm_time = 112;
	}

	ent.client.respawn_time = level.time;

	if (ent.client.pers.spectator)
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_observing", ent.client.pers.netname);
	else
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_joined_game", ent.client.pers.netname);
}

// [Paril-KEX]
// skinnum was historically used to pack data
// so we're going to build onto that.
void P_AssignClientSkinnum(ASEntity &ent)
{
	if (ent.e.s.modelindex != MODELINDEX_PLAYER)
		return;

    uint8     client_num;
    uint8     vwep_index;
    int8      viewheight;
    uint8     team_index;
    uint8     poi_icon;

	client_num = ent.e.s.number - 1;
	if (ent.client.pers.weapon !is null)
		vwep_index = ent.client.pers.weapon.vwep_index - level.vwep_offset + 1;
	else
		vwep_index = 0;
	viewheight = int8(ent.e.client.ps.viewoffset.z + ent.e.client.ps.pmove.viewheight);
	
	if (coop.integer != 0)
		team_index = 1; // all players are teamed in coop
	else if (G_TeamplayEnabled())
		team_index = ent.client.resp.ctf_team;
	else
		team_index = 0;

	if (ent.deadflag)
		poi_icon = 1;
	else
		poi_icon = 0;

	ent.e.s.skinnum = client_num | (vwep_index << 8) | (viewheight << 16) | (team_index << 24) | (poi_icon << 28);
}

// AS_TODO, enum?
// POI tags used by this mod
namespace pois_t// : uint16_t
{
	uint16 POI_OBJECTIVE = MAX_EDICTS; // current objective
	uint16 POI_RED_FLAG = POI_OBJECTIVE + 1; // red flag/carrier
	uint16 POI_BLUE_FLAG = POI_RED_FLAG + 1; // blue flag/carrier
	uint16 POI_PING = POI_BLUE_FLAG + 1;
	uint16 POI_PING_END = POI_PING + MAX_CLIENTS - 1;

    uint16 POI_FLAG_NONE = 0;
    uint16 POI_FLAG_HIDE_ON_AIM = 1; // hide the POI if we get close to it with our aim
};

// [Paril-KEX] send player level POI
void P_SendLevelPOI(ASEntity &ent)
{
	if (!level.valid_poi)
		return;

	gi_WriteByte(svc_t::poi);
	gi_WriteShort(pois_t::POI_OBJECTIVE);
	gi_WriteShort(10000);
	gi_WritePosition(ent.client.help_poi_location);
	gi_WriteShort(ent.client.help_poi_image);
	gi_WriteByte(208);
	gi_WriteByte(pois_t::POI_FLAG_NONE);
	gi_unicast(ent.e, true);
}

// AS_TODO register in native?
enum svc_fog_bits_t
{
    // global fog
    BIT_DENSITY     = 1 << 0,
    BIT_R           = 1 << 1,
    BIT_G           = 1 << 2,
    BIT_B           = 1 << 3,
    BIT_TIME        = 1 << 4, // if set, the transition takes place over N milliseconds

    // height fog
    BIT_HEIGHTFOG_FALLOFF   = 1 << 5,
    BIT_HEIGHTFOG_DENSITY   = 1 << 6,
    BIT_MORE_BITS           = 1 << 7, // read additional bit
    BIT_HEIGHTFOG_START_R   = 1 << 8,
    BIT_HEIGHTFOG_START_G   = 1 << 9,
    BIT_HEIGHTFOG_START_B   = 1 << 10,
    BIT_HEIGHTFOG_START_DIST= 1 << 11,
    BIT_HEIGHTFOG_END_R     = 1 << 12,
    BIT_HEIGHTFOG_END_G     = 1 << 13,
    BIT_HEIGHTFOG_END_B     = 1 << 14,
    BIT_HEIGHTFOG_END_DIST  = 1 << 15
};

// [Paril-KEX] force the fog transition on the given player,
// optionally instantaneously (ignore any transition time)
void P_ForceFogTransition(ASEntity &ent, bool instant)
{
	// sanity check; if we're not changing the values, don't bother
    // AS_TODO we can probably speed this up with a boolean
    // that is tripped when fog values change or something
	if (ent.client.fog == ent.client.pers.wanted_fog &&
		ent.client.heightfog == ent.client.pers.wanted_heightfog)
		return;

	uint16 bits = 0;
    float density;
    uint8 skyfactor, red, green, blue;
    int16 time;
	float hf_falloff, hf_density;
    uint8 hf_start_r, hf_start_g, hf_start_b;
    int32 hf_start_dist;
    uint8 hf_end_r, hf_end_g, hf_end_b;
    int32 hf_end_dist;

    auto @f = ent.client.fog;
    const auto @wanted_f = ent.client.pers.wanted_fog;
	
	// check regular fog
	if (wanted_f.density != f.density ||
		wanted_f.skyfactor != f.skyfactor)
	{
		bits |= svc_fog_bits_t::BIT_DENSITY;
		density = wanted_f.density;
		skyfactor = uint8(wanted_f.skyfactor * 255.f);
	}
	if (wanted_f.rgb.x != f.rgb.x)
	{
		bits |= svc_fog_bits_t::BIT_R;
		red = uint8(wanted_f.rgb.x * 255.f);
	}
	if (wanted_f.rgb.y != f.rgb.y)
	{
		bits |= svc_fog_bits_t::BIT_G;
		green = uint8(wanted_f.rgb.y * 255.f);
	}
	if (wanted_f.rgb.z != f.rgb.z)
	{
		bits |= svc_fog_bits_t::BIT_B;
		blue = uint8(wanted_f.rgb.z * 255.f);
	}

	if (!instant && ent.client.pers.fog_transition_time)
	{
		bits |= svc_fog_bits_t::BIT_TIME;
		time = uint16(clamp(ent.client.pers.fog_transition_time.milliseconds, int64(0), int64(int64_limits::max)));
	}
	
	// check heightfog stuff
	auto @hf = ent.client.heightfog;
	const auto @wanted_hf = ent.client.pers.wanted_heightfog;
	
	if (hf.falloff != wanted_hf.falloff)
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_FALLOFF;
		hf_falloff = wanted_hf.falloff;
	}
	if (hf.density != wanted_hf.density)
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_DENSITY;
		hf_density = wanted_hf.density;
	}

	if (hf.start[0] != wanted_hf.start[0])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_START_R;
		hf_start_r = uint8(wanted_hf.start[0] * 255.f);
	}
	if (hf.start[1] != wanted_hf.start[1])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_START_G;
		hf_start_g = uint8(wanted_hf.start[1] * 255.f);
	}
	if (hf.start[2] != wanted_hf.start[2])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_START_B;
		hf_start_b = uint8(wanted_hf.start[2] * 255.f);
	}
	if (hf.start[3] != wanted_hf.start[3])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_START_DIST;
		hf_start_dist = int(wanted_hf.start[3]);
	}

	if (hf.end[0] != wanted_hf.end[0])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_END_R;
		hf_end_r = uint8(wanted_hf.end[0] * 255.f);
	}
	if (hf.end[1] != wanted_hf.end[1])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_END_G;
		hf_end_g = uint8(wanted_hf.end[1] * 255.f);
	}
	if (hf.end[2] != wanted_hf.end[2])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_END_B;
		hf_end_b = uint8(wanted_hf.end[2] * 255.f);
	}
	if (hf.end[3] != wanted_hf.end[3])
	{
		bits |= svc_fog_bits_t::BIT_HEIGHTFOG_END_DIST;
		hf_end_dist = int(wanted_hf.end[3]);
	}

	if ((bits & 0xFF00) != 0)
		bits |= svc_fog_bits_t::BIT_MORE_BITS;

	gi_WriteByte(svc_t::fog);

	if ((bits & svc_fog_bits_t::BIT_MORE_BITS) != 0)
		gi_WriteShort(bits);
	else
		gi_WriteByte(bits);

	if ((bits & svc_fog_bits_t::BIT_DENSITY) != 0)
	{
		gi_WriteFloat(density);
		gi_WriteByte(skyfactor);
	}
	if ((bits & svc_fog_bits_t::BIT_R) != 0)
		gi_WriteByte(red);
	if ((bits & svc_fog_bits_t::BIT_G) != 0)
		gi_WriteByte(green);
	if ((bits & svc_fog_bits_t::BIT_B) != 0)
		gi_WriteByte(blue);
	if ((bits & svc_fog_bits_t::BIT_TIME) != 0)
		gi_WriteShort(time);
	
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_FALLOFF) != 0)
		gi_WriteFloat(hf_falloff);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_DENSITY) != 0)
		gi_WriteFloat(hf_density);

	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_START_R) != 0)
		gi_WriteByte(hf_start_r);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_START_G) != 0)
		gi_WriteByte(hf_start_g);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_START_B) != 0)
		gi_WriteByte(hf_start_b);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_START_DIST) != 0)
		gi_WriteLong(hf_start_dist);

	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_END_R) != 0)
		gi_WriteByte(hf_end_r);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_END_G) != 0)
		gi_WriteByte(hf_end_g);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_END_B) != 0)
		gi_WriteByte(hf_end_b);
	if ((bits & svc_fog_bits_t::BIT_HEIGHTFOG_END_DIST) != 0)
		gi_WriteLong(hf_end_dist);

	gi_unicast(ent.e, true);

	f = wanted_f;
	hf = wanted_hf;
}

/*
===========
SelectSpawnPoint

Chooses a player start, deathmatch start, coop start, etc
============
*/
bool SelectSpawnPoint(ASEntity @ent, vec3_t &out origin, vec3_t &out angles, bool force_spawn, bool &out landmark)
{
	ASEntity @spot = null;

	// DM spots are simple
	if (deathmatch.integer != 0)
	{
		if (G_TeamplayEnabled())
			@spot = SelectCTFSpawnPoint(ent, force_spawn);
		else
		{
			select_spawn_result_t result = SelectDeathmatchSpawnPoint(g_dm_spawn_farthest.integer != 0, force_spawn, true);

			if (!result.any_valid)
				gi_Com_Error("no valid spawn points found");

			@spot = @result.spot;
		}

		if (spot !is null)
		{
			origin = spot.e.s.origin + vec3_t(0, 0, 9);
			angles = spot.e.s.angles;

			return true;
		}

		return false;
	}
	
	if (coop.integer != 0)
	{
		@spot = SelectCoopSpawnPoint(ent, force_spawn, true);

		if (spot is null)
			@spot = SelectCoopSpawnPoint(ent, force_spawn, false);

		// no open spot yet
		if (spot is null)
		{
			// in worst case scenario in coop during intermission, just spawn us at intermission
			// spot. this only happens for a single frame, and won't break
			// anything if they come back.
			if (level.intermissiontime)
			{
				origin = level.intermission_origin;
				angles = level.intermission_angle;
				return true;
			}

			return false;
		}
	}
	else
	{
		@spot = SelectSingleSpawnPoint(ent);

		// in SP, just put us at the origin if spawn fails
		if (spot is null)
		{
			gi_Com_Print("Couldn't find spawn point {}\n", game.spawnpoint);

			origin = vec3_origin;
			angles = vec3_origin;

			return true;
		}
	}

	// spot should always be non-null here
	origin = spot.e.s.origin;
	angles = spot.e.s.angles;

	// check landmark
    vec3_t landmark_origin, landmark_angles;
	if (TryLandmarkSpawn(ent, origin, landmark_origin, landmark_angles))
    {
        origin = landmark_origin;
        angles = landmark_angles;
		landmark = true;
    }

	return true;
}

// [Paril-KEX] ugly global to handle squad respawn origin
bool use_squad_respawn = false;
bool spawn_from_begin = false;
vec3_t squad_respawn_position, squad_respawn_angles;

void PutClientOnSpawnPoint(ASEntity &ent, const vec3_t &in spawn_origin, const vec3_t &in spawn_angles)
{
	ent.e.client.ps.pmove.origin = spawn_origin;

	ent.e.s.origin = spawn_origin;
	if (!use_squad_respawn)
		ent.e.s.origin[2] += 1; // make sure off ground
	ent.e.s.old_origin = ent.e.s.origin;

	// set the delta angle
	ent.e.client.ps.pmove.delta_angles = spawn_angles - ent.client.resp.cmd_angles;

	ent.e.s.angles = spawn_angles;
	ent.e.s.angles.pitch /= 3;

	ent.e.client.ps.viewangles = ent.e.s.angles;
	ent.client.v_angle = ent.e.s.angles;

	AngleVectors(ent.client.v_angle, ent.client.v_forward);
}

const vec3_t PLAYER_MINS = { -16, -16, -24 };
const vec3_t PLAYER_MAXS = { 16, 16, 32 };

/*
===========
PutClientInServer

Called when a player connects to a server or respawns in
a deathmatch.
============
*/
void PutClientInServer(ASEntity &ent)
{
	int					index;
	vec3_t				spawn_origin, spawn_angles;
	client_persistant_t saved;
	client_respawn_t	resp;

	// clear velocity now, since landmark may change it
	bool keepVelocity = !ent.client.landmark_name.empty();

	if (keepVelocity)
		ent.velocity = ent.client.oldvelocity;
    else
    	ent.velocity = vec3_origin;

	// find a spawn point
	// do it before setting health back up, so farthest
	// ranging doesn't count this client
	bool valid_spawn = false;
	bool force_spawn = ent.client.awaiting_respawn && level.time > ent.client.respawn_timeout;
	bool is_landmark = false;

	if (use_squad_respawn)
	{
		spawn_origin = squad_respawn_position;
		spawn_angles = squad_respawn_angles;
		valid_spawn = true;
	}
	else
		valid_spawn = SelectSpawnPoint(ent, spawn_origin, spawn_angles, force_spawn, is_landmark);

	// [Paril-KEX] if we didn't get a valid spawn, hold us in
	// limbo for a while until we do get one
	if (!valid_spawn)
	{
		// only do this once per spawn
		if (!ent.client.awaiting_respawn)
		{
			ClientUserinfoChanged(ent.e, ent.client.pers.userinfo);

			ent.client.respawn_timeout = level.time + time_sec(3);
		}

		// find a spot to place us
		if (!level.respawn_intermission)
		{
			// find an intermission spot
            ASEntity @pt = find_by_str<ASEntity>(null, "classname", "info_player_intermission");
			if (pt is null)
			{ // the map creator forgot to put in an intermission point...
				@pt = find_by_str<ASEntity>(null, "classname", "info_player_start");
				if (pt is null)
					@pt = find_by_str<ASEntity>(null, "classname", "info_player_deathmatch");
			}
			else
			{ // choose one of four spots
				int32 i = irandom(4);
				while (i-- != 0)
				{
					@pt = find_by_str<ASEntity>(pt, "classname", "info_player_intermission");
					if (pt is null) // wrap around the list
						@pt = find_by_str<ASEntity>(pt, "classname", "info_player_intermission");
				}
			}

			level.intermission_origin = pt.e.s.origin;
			level.intermission_angle = pt.e.s.angles;
			level.respawn_intermission = true;
		}

		ent.e.s.origin = level.intermission_origin;
		ent.e.client.ps.pmove.origin = level.intermission_origin;
		ent.e.client.ps.viewangles = level.intermission_angle;

		ent.client.awaiting_respawn = true;
		ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;
		ent.e.client.ps.rdflags = refdef_flags_t::NONE;
		ent.deadflag = false;
		ent.e.solid = solid_t::NOT;
		ent.movetype = movetype_t::NOCLIP;
		ent.e.s.modelindex = 0;
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.e.client.ps.team_id = ent.client.resp.ctf_team;
		gi_linkentity(ent.e);

		return;
	}
	
	ent.client.resp.ctf_state++;

	bool was_waiting_for_respawn = ent.client.awaiting_respawn;

	if (ent.client.awaiting_respawn)
		ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::NOCLIENT);

	ent.client.awaiting_respawn = false;
	ent.client.respawn_timeout = time_zero;

	string social_id = ent.client.pers.social_id;

	// deathmatch wipes most client data every spawn
	if (deathmatch.integer != 0)
	{
		ent.client.pers.health = 0;
		resp = ent.client.resp;
	}
	else
	{
		// [Kex] Maintain user info in singleplayer to keep the player skin. 
		string userinfo = ent.client.pers.userinfo;

		if (coop.integer != 0)
		{
			resp = ent.client.resp;

			if (!P_UseCoopInstancedItems())
			{
				resp.coop_respawn.game_help1changed = ent.client.pers.game_help1changed;
				resp.coop_respawn.game_help2changed = ent.client.pers.game_help2changed;
				resp.coop_respawn.helpchanged = ent.client.pers.helpchanged;
				ent.client.pers = resp.coop_respawn;
			}
			else
			{
				// fix weapon
				if (ent.client.pers.weapon is null)
					@ent.client.pers.weapon = @ent.client.pers.lastweapon;
			}
		}

		ClientUserinfoChanged(ent.e, userinfo);

		if (coop.integer != 0)
		{
			if (resp.score > ent.client.pers.score)
				ent.client.pers.score = resp.score;
		}
        else
            resp = client_respawn_t();
	}

	// clear everything but the persistant data
	saved = ent.client.pers;
    internal::allow_value_assign = true;
    ent.client = ASClient(ent.e.client);
    internal::allow_value_assign = false;
	ent.client.pers = saved;
	ent.client.resp = resp;

	// on a new, fresh spawn (always in DM, clear inventory
	// or new spawns in SP/coop)
	if (ent.client.pers.health <= 0)
		InitClientPersistant(ent);

	// restore social ID
    ent.client.pers.social_id = social_id;

	// fix level switch issue
	ent.client.pers.connected = true;

	// slow time will be unset here
	server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);

	// copy some data from the client to the entity
	FetchClientEntData(ent);

	// clear entity values
	@ent.groundentity = null;
	ent.takedamage = true;
	ent.movetype = movetype_t::WALK;
	ent.viewheight = 22;
	ent.e.inuse = true;
	ent.classname = "player";
	ent.mass = 200;
	ent.e.solid = solid_t::BBOX;
	ent.deadflag = false;
	ent.air_finished = level.time + time_sec(12);
	ent.e.clipmask = contents_t::MASK_PLAYERSOLID;
	//ent.model = "players/male/tris.md2";
	@ent.die = player_die;
	ent.waterlevel = water_level_t::NONE;
	ent.watertype = contents_t::NONE;
	ent.flags = ent_flags_t(ent.flags & ~( ent_flags_t::NO_KNOCKBACK | ent_flags_t::ALIVE_KNOCKBACK_ONLY | ent_flags_t::NO_DAMAGE_EFFECTS ));
	ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::DEADMONSTER);
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::PLAYER);

	ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::SAM_RAIMI); // PGM - turn off sam raimi flag

	ent.e.mins = PLAYER_MINS;
	ent.e.maxs = PLAYER_MAXS;

	// clear playerstate values
    ent.e.client.ps = player_state_t();

	string val;
	gi_Info_ValueForKey(ent.client.pers.userinfo, "fov", val);
	ent.e.client.ps.fov = clamp(parseFloat(val), 1.0f, 160.0f);

	ent.e.client.ps.pmove.viewheight = ent.viewheight;
	ent.e.client.ps.team_id = ent.client.resp.ctf_team;

	if (!G_ShouldPlayersCollide(false))
		ent.e.clipmask = contents_t(ent.e.clipmask & ~contents_t::PLAYER);

	// PGM
	if (ent.client.pers.weapon !is null)
		ent.e.client.ps.gunindex = gi_modelindex(ent.client.pers.weapon.view_model);
	else
		ent.e.client.ps.gunindex = 0;
	ent.e.client.ps.gunskin = 0;
	// PGM

	// clear entity state values
	ent.e.s.effects = effects_t::NONE;
	ent.e.s.modelindex = MODELINDEX_PLAYER;	// will use the skin specified model
	ent.e.s.modelindex2 = MODELINDEX_PLAYER; // custom gun model
	// sknum is player num and weapon number
	// weapon number will be added in changeweapon
	P_AssignClientSkinnum(ent);

	ent.e.s.frame = 0;

	PutClientOnSpawnPoint(ent, spawn_origin, spawn_angles);

	// [Paril-KEX] set up world fog & send it instantly
    ent.client.pers.wanted_fog = world.fog;
    ent.client.pers.wanted_heightfog = world.heightfog;
	P_ForceFogTransition(ent, true);

	// ZOID
	if (CTFStartClient(ent))
		return;
	// ZOID

	// spawn a spectator
	if (ent.client.pers.spectator)
	{
		@ent.client.chase_target = null;

		ent.client.resp.spectator = true;

		ent.movetype = movetype_t::NOCLIP;
		ent.e.solid = solid_t::NOT;
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.e.client.ps.gunindex = 0;
		ent.e.client.ps.gunskin = 0;
		gi_linkentity(ent.e);
		return;
	}

	ent.client.resp.spectator = false;

	// [Paril-KEX] a bit of a hack, but landmark spawns can sometimes cause
	// intersecting spawns, so we'll do a sanity check here...
	if (spawn_from_begin)
	{
		if (coop.integer != 0)
		{
			ASEntity @collision = G_UnsafeSpawnPosition(ent.e.origin, true);

			if (collision !is null)
			{
				gi_linkentity(ent.e);

				if (collision.client !is null)
				{
					// we spawned in somebody else, so we're going to change their spawn position
					bool lm = false;
					SelectSpawnPoint(collision, spawn_origin, spawn_angles, true, lm);
					PutClientOnSpawnPoint(collision, spawn_origin, spawn_angles);
				}
				// else, no choice but to accept where ever we spawned :(
			}
		}

		// give us one (1) free fall ticket even if
		// we didn't spawn from landmark
		ent.client.landmark_free_fall = true;
	}

	gi_linkentity(ent.e);

	if (!KillBox(ent, true, mod_id_t::TELEFRAG_SPAWN))
	{ // could't spawn in?
	}

	// my tribute to cash's level-specific hacks. I hope I live
	// up to his trailblazing cheese.
	if (level.mapname == "rboss")
	{
		// if you get on to rboss in single player or coop, ensure
		// the player has the nuke key. (not in DM)
		if (deathmatch.integer == 0)
			ent.client.pers.inventory[item_id_t::KEY_NUKE] = 1;
	}

	// force the current weapon up
	@ent.client.newweapon = @ent.client.pers.weapon;
	ChangeWeapon(ent);

	if (was_waiting_for_respawn)
		G_PostRespawn(ent);
}

/*
=====================
ClientBeginDeathmatch

A client has just connected to the server in
deathmatch mode, so clear everything out before starting them.
=====================
*/
void ClientBeginDeathmatch(ASEntity &ent)
{
    ent.Init();
	
	// make sure we have a known default
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::PLAYER);

	InitClientResp(ent);

	// ZOID
	if (G_TeamplayEnabled() && ent.client.resp.ctf_team < ctfteam_t::TEAM1)
		CTFAssignTeam(ent);
	// ZOID

	// locate ent at a spawn point
	PutClientInServer(ent);

	if (level.intermissiontime)
	{
		MoveClientToIntermission(ent);
	}
	else
	{
		if ((ent.e.svflags & svflags_t::NOCLIENT) == 0)
		{
			// send effect
			gi_WriteByte(svc_t::muzzleflash);
			gi_WriteEntity(ent.e);
			gi_WriteByte(player_muzzle_t::LOGIN);
			gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
		}
	}

	gi_LocBroadcast_Print(print_type_t::HIGH, "$g_entered_game", ent.client.pers.netname);

	// make sure all view stuff is valid
	ClientEndServerFrame(ent);
}

void G_SetLevelEntry()
{
	if (deathmatch.integer != 0)
		return;
	// map is a hub map, so we shouldn't bother tracking any of this.
	// the next map will pick up as the start.
	else if (level.hub_map)
		return;

	level_entry_t @found_entry = null;
	int highest_order = 0;

	for (uint i = 0; i < game.level_entries.length(); i++)
	{
		level_entry_t @entry = game.level_entries[i];

		highest_order = max(highest_order, entry.visit_order);

		if (entry.map_name == level.mapname)
		{
			@found_entry = entry;
			break;
		}
	}

	if (found_entry is null)
	{
        if (game.level_entries.length() >= MAX_LEVELS_PER_UNIT)
        {
    		gi_Com_Print("WARNING: more than {} maps in unit, can't track the rest\n", MAX_LEVELS_PER_UNIT);
    		return;
        }

        game.level_entries.push_back(level_entry_t());
        @found_entry = game.level_entries[game.level_entries.length() - 1];
	}

	@level.entry = found_entry;
	level.entry.map_name = level.mapname;

	// we're visiting this map for the first time, so
	// mark it in our order as being recent
	if (level.entry.pretty_name.empty())
	{
		level.entry.pretty_name = level.level_name;
		level.entry.visit_order = highest_order + 1;

		// give all of the clients an extra life back
		if (g_coop_enable_lives.integer != 0)
			for (uint i = 0; i < max_clients; i++)
				players[i].client.pers.lives = min(g_coop_num_lives.integer + 1, players[i].client.pers.lives + 1);
	}

	// scan for all new maps we can go to, for secret levels
	ASEntity @changelevel = null;
	while ((@changelevel = find_by_str<ASEntity>(changelevel, "classname", "target_changelevel")) !is null)
	{
		if (changelevel.map.empty())
			continue;

		// next unit map, don't count it
		if (changelevel.map.findFirstOf("*") != -1)
			continue;

        int nextmap = changelevel.map.findFirstOf("+");
        string level;

		if (nextmap != -1)
			level = changelevel.map.substr(nextmap + 1);
		else
        {
            nextmap = 0;
			level = changelevel.map;
        }

		// don't include end screen levels
		if (level.findFirst(".cin") != -1 || level.findFirst(".pcx") != -1)
			continue;

		uint level_length;

		int spawnpoint = level.findFirstOf("$");

		if (spawnpoint != -1)
        {
			level_length = uint(spawnpoint - nextmap);
            level = level.substr(0, level_length);
        }
		else
			level_length = level.length();

		// make an entry for this level that we may or may not visit
		@found_entry = null;

		for (uint i = 0; i < game.level_entries.length(); i++)
		{
			level_entry_t @entry = game.level_entries[i];

			if (entry.map_name == level)
			{
				@found_entry = entry;
				break;
			}
		}

		if (found_entry is null)
		{
            if (game.level_entries.length() >= MAX_LEVELS_PER_UNIT)
            {
                gi_Com_Print("WARNING: more than {} maps in unit, can't track the rest\n", MAX_LEVELS_PER_UNIT);
                return;
            }

            game.level_entries.push_back(level_entry_t());
            @found_entry = game.level_entries[game.level_entries.length() - 1];
		}

		found_entry.map_name = level;
	}
}

/*
===========
called when a client has finished connecting, and is ready
to be placed into the game.  This will happen every level load.
============
*/
void ClientBegin(edict_t @ent_handle)
{
    ASEntity @ent = players[ent_handle.s.number - 1];

	ent.client.awaiting_respawn = false;
	ent.client.respawn_timeout = time_zero;

	// [Paril-KEX] we're always connected by this point...
	ent.client.pers.connected = true;

	if (deathmatch.integer != 0)
	{
		ClientBeginDeathmatch(ent);
		return;
	}

	// [Paril-KEX] set enter time now, so we can send messages slightly
	// after somebody first joins
	ent.client.resp.entertime = level.time;
	ent.client.pers.spawned = true;

	// if there is already a body waiting for us (a loadgame), just
	// take it, otherwise spawn one from scratch
	if (ent.e.inuse)
	{
		// the client has cleared the client side viewangles upon
		// connecting to the server, which is different than the
		// state when the game is saved, so we need to compensate
		// with deltaangles
		ent.e.client.ps.pmove.delta_angles = ent.e.client.ps.viewangles;
	}
	else
	{
		// a spawn point will completely reinitialize the entity
		// except for the persistant data that was initialized at
		// ClientConnect() time
        ent.Init();
		ent.classname = "player";
		InitClientResp(ent);
		spawn_from_begin = true;
		PutClientInServer(ent);
		spawn_from_begin = false;
	}
	
	// make sure we have a known default
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::PLAYER);

	if (level.intermissiontime)
	{
		MoveClientToIntermission(ent);
	}
	else
	{
		// send effect if in a multiplayer game
		if (max_clients > 1 && (ent.e.svflags & svflags_t::NOCLIENT) == 0)
			gi_LocBroadcast_Print(print_type_t::HIGH, "$g_entered_game", ent.client.pers.netname);
	}

	level.coop_scale_players++;
    // AS_TODO
	//G_Monster_CheckCoopHealthScaling();

	// make sure all view stuff is valid
	ClientEndServerFrame(ent);

	// [Paril-KEX] send them goal, if needed
	G_PlayerNotifyGoal(ent);

	// [Paril-KEX] we're going to set this here just to be certain
	// that the level entry timer only starts when a player is actually
	// *in* the level
	G_SetLevelEntry();
}

/*
================
G_EncodedPlayerName

Gets a token version of the players "name" to be decoded on the client.
================
*/
string G_EncodedPlayerName(ASEntity &player)
{
    return format("##P{}", player.e.s.number - 1);
}

/*
===========
ClientUserInfoChanged

called whenever the player updates a userinfo variable.
============
*/
void ClientUserinfoChanged(edict_t @ent_handle, const string &in userinfo)
{
    ASEntity @ent = entities[ent_handle.s.number];

	// set name
	if (gi_Info_ValueForKey(userinfo, "name", ent.client.pers.netname) == 0)
        ent.client.pers.netname = "badinfo";

	// set spectator
	string val;
	gi_Info_ValueForKey(userinfo, "spectator", val);

	// spectators are only supported in deathmatch
	if (deathmatch.integer != 0 && !G_TeamplayEnabled() && !val.empty() && val != "0")
		ent.client.pers.spectator = true;
	else
		ent.client.pers.spectator = false;

	// set skin
	if (gi_Info_ValueForKey(userinfo, "skin", val) == 0)
        val = "male/grunt";

	int playernum = ent.e.s.number - 1;

	// combine name and skin into a configstring
	// ZOID
	if (G_TeamplayEnabled())
		CTFAssignSkin(ent, val);
	else
	{
		// set dogtag
		string dogtag;
		gi_Info_ValueForKey(userinfo, "dogtag", dogtag);

		// ZOID
		gi_configstring(int(configstring_id_t::PLAYERSKINS) + playernum, format("{}\\{}\\{}", ent.client.pers.netname, val, dogtag));
	}

	// ZOID
	//  set player name field (used in id_state view)
	gi_configstring(configstring_id_t(game_configstring_id_t::CTF_PLAYER_NAME + playernum), ent.client.pers.netname);
	// ZOID

	// [Kex] netname is used for a couple of other things, so we update this after those.
	if ( ( ent.e.svflags & svflags_t::BOT ) == 0 ) {
        ent.client.pers.netname = G_EncodedPlayerName(ent);
	}

	// fov
	gi_Info_ValueForKey(userinfo, "fov", val);
	ent.e.client.ps.fov = clamp(parseFloat(val), 1.0f, 160.0f);

	// handedness
	if (gi_Info_ValueForKey(userinfo, "hand", val) != 0)
	{
		ent.client.pers.hand = handedness_t(clamp(parseInt(val), int32(handedness_t::RIGHT), int32(handedness_t::CENTER)));
	}
	else
	{
		ent.client.pers.hand = handedness_t::RIGHT;
	}

	// [Paril-KEX] auto-switch
	if (gi_Info_ValueForKey(userinfo, "autoswitch", val) != 0)
	{
		ent.client.pers.autoswitch = auto_switch_t(clamp(parseInt(val), int32(auto_switch_t::SMART), int32(auto_switch_t::NEVER)));
	}
	else
	{
		ent.client.pers.autoswitch = auto_switch_t::SMART;
	}

	if (gi_Info_ValueForKey(userinfo, "autoshield", val) != 0)
	{
		ent.client.pers.autoshield = parseInt(val);
	}
	else
	{
		ent.client.pers.autoshield = -1;
	}

	// [Paril-KEX] wants bob
	if (gi_Info_ValueForKey(userinfo, "bobskip", val) != 0)
	{
		ent.client.pers.bob_skip = parseInt(val) == 1;
	}
	else
	{
		ent.client.pers.bob_skip = false;
	}

	// save off the userinfo in case we want to check something later
    ent.client.pers.userinfo = userinfo;
}

bool IsSlotIgnored(edict_t @slot, const array<edict_t @> &in ignore)
{
    foreach (edict_t @ignored : ignore)
        if (slot is ignored)
            return true;

    return false;
}

edict_t @ClientChooseSlot_Any(const array<edict_t @> &in ignore)
{
	for (uint i = 0; i < max_clients; i++)
		if (!IsSlotIgnored(G_EdictForNum(i + 1), ignore) && !players[i].client.pers.connected)
			return G_EdictForNum(i + 1);

	return null;
}

enum slot_match_type_t {
    USERNAME,
    SOCIAL,
    BOTH,

    TYPES
};

class slot_match_t
{
    edict_t @slot = null;
    uint total = 0;
};

edict_t @ClientChooseSlot_Coop(const string &in userinfo, const string &in social_id, bool isBot, const array<edict_t @> &in ignore)
{
	string name;
	gi_Info_ValueForKey(userinfo, "name", name);

	// the host should always occupy slot 0, some systems rely on this
	// (CHECK: is this true? is it just bots?)
	{
		uint num_players = 0;

		for (uint i = 0; i < max_clients; i++)
			if (IsSlotIgnored(G_EdictForNum(i + 1), ignore) || players[i].client.pers.connected)
				num_players++;

		if (num_players == 0)
		{
			gi_Com_Print("coop slot {} is host {}+{}\n", 1, name, social_id);
			return G_EdictForNum(1);
		}
	}

	// grab matches from players that we have connected
	array<slot_match_t> matches(slot_match_type_t::TYPES);

	for (uint i = 0; i < max_clients; i++)
	{
		if (IsSlotIgnored(G_EdictForNum(i + 1), ignore) || players[i].client.pers.connected)
			continue;

		string check_name;
		gi_Info_ValueForKey(players[i].client.pers.userinfo, "name", check_name);

		bool username_match = !players[i].client.pers.userinfo.empty() &&
			check_name == name;

		bool social_match = !social_id.empty() && !players[i].client.pers.social_id.empty() &&
			players[i].client.pers.social_id == social_id;

		slot_match_type_t type;

        if (username_match && social_match)
            type = slot_match_type_t::BOTH;
		else if (username_match)
			type = slot_match_type_t::USERNAME;
		else if (social_match)
			type = slot_match_type_t::SOCIAL;
        else
            continue;

		@matches[type].slot = G_EdictForNum(i + 1);
		matches[type].total++;
	}

	// pick matches in descending order, only if the total matches
	// is 1 in the particular set; this will prefer to pick
	// social+username matches first, then social, then username last.
	for (int i = slot_match_type_t::BOTH; i >= slot_match_type_t::USERNAME; i--)
	{
		if (matches[i].total == 1)
		{
			gi_Com_Print("coop slot {} restored for {}+{}\n", matches[i].slot.s.number, name, social_id);

			// spawn us a ghost now since we're gonna spawn eventually
			if (!matches[i].slot.inuse)
			{
                ASEntity @ent = entities[matches[i].slot.s.number];

				ent.e.s.modelindex = MODELINDEX_PLAYER;
				ent.e.solid = solid_t::BBOX;

                ent.Init();

				ent.classname = "player";
				InitClientResp(ent);
				spawn_from_begin = true;
				PutClientInServer(ent);
				spawn_from_begin = false;

				// make sure we have a known default
				ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::PLAYER);

				ent.e.sv.init = false;
				ent.classname = "player";
				ent.client.pers.connected = true;
				ent.client.pers.spawned = true;
				P_AssignClientSkinnum(ent);
				gi_linkentity(ent.e);
			}

			return matches[i].slot;
		}
	}

	// in the case where we can't find a match, we're probably a new
	// player, so pick a slot that hasn't been occupied yet
	for (uint i = 0; i < max_clients; i++)
		if (!IsSlotIgnored(G_EdictForNum(i + 1), ignore) && players[i].client.pers.userinfo.empty())
		{
			gi_Com_Print("coop slot {} issuing new for {}+{}\n", i + 1, name, social_id);
			return G_EdictForNum(i + 1);
		}

	// all slots have some player data in them, we're forced to replace one.
	edict_t @any_slot = ClientChooseSlot_Any(ignore);

	gi_Com_Print("coop slot {} any slot for {}+{}\n", any_slot is null ? -1 : any_slot.s.number, name, social_id);

	return any_slot;
}

// [Paril-KEX] for coop, we want to try to ensure that players will always get their
// proper slot back when they connect.
edict_t @ClientChooseSlot(const string &in userinfo, const string &in social_id, bool isBot, const array<edict_t@> &in ignore, bool cinematic)
{
	// coop and non-bots is the only thing that we need to do special behavior on
	if (!cinematic && coop.integer != 0 && !isBot)
		return ClientChooseSlot_Coop(userinfo, social_id, isBot, ignore);

	// just find any free slot
	return ClientChooseSlot_Any(ignore);
}

/*
===========
ClientConnect

Called when a player begins connecting to the server.
The game can refuse entrance to a client by returning false.
If the client is allowed, the connection process will continue
and eventually get to ClientBegin()
Changing levels will NOT cause this to be called again, but
loadgames will.
============
*/
bool ClientConnect(edict_t @ent, string &in userinfo, string &in social_id, bool isBot, string &out reject_userinfo)
{
    string value;

    /*
	// check to see if they are on the banned IP list
	value = Info_ValueForKey(userinfo, "ip");
	if (SV_FilterPacket(value))
	{
		Info_SetValueForKey(userinfo, "rejmsg", "Banned.", reject_userinfo);
		return false;
	}
    */

    // AS_TODO
    /*
	// check for a spectator
	gi.Info_ValueForKey(userinfo, "spectator", value, sizeof(value));

	if (deathmatch.integer && *value && strcmp(value, "0"))
	{
		uint32_t i, numspec;

		if (*spectator_password.stringval &&
			strcmp(spectator_password.stringval, "none") &&
			strcmp(spectator_password.stringval, value))
		{
			gi.Info_SetValueForKey(userinfo, "rejmsg", "Spectator password required or incorrect.", reject_userinfo);
			return false;
		}

		// count spectators
		for (i = numspec = 0; i < game.maxclients; i++)
			if (g_edicts[i + 1].inuse && g_edicts[i + 1].client.pers.spectator)
				numspec++;

		if (numspec >= (uint32_t) maxspectators.integer)
		{
			gi.Info_SetValueForKey(userinfo, "rejmsg", "Server spectator limit is full.", reject_userinfo);
			return false;
		}
	}
	else
	{
		// check for a password ( if not a bot! )
		gi.Info_ValueForKey(userinfo, "password", value, sizeof(value));
		if ( !isBot && *password.stringval && strcmp(password.stringval, "none") &&
			strcmp(password.string, value))
		{
			gi.Info_SetValueForKey(userinfo, "rejmsg", "Password required or incorrect.", reject_userinfo);
			return false;
		}
	}
    */

	// they can connect
    ASEntity @clent = players[ent.s.number - 1];

	// set up userinfo early
	ClientUserinfoChanged(ent, userinfo);

	// if there is already a body waiting for us (a loadgame), just
	// take it, otherwise spawn one from scratch
	if (ent.inuse == false)
	{
		// clear the respawning variables
		// ZOID -- force team join
		clent.client.resp.ctf_team = ctfteam_t::NOTEAM;
		clent.client.resp.id_state = true;
		// ZOID
		InitClientResp(clent);
		if (!game.autosaved || clent.client.pers.weapon is null)
			InitClientPersistant(clent);
	}

	// make sure we start with known default(s)
	ent.svflags = svflags_t::PLAYER;
	if ( isBot ) {
		ent.svflags = svflags_t(ent.svflags | svflags_t::BOT);

        level.num_bots++;
	}

    clent.client.pers.social_id = social_id;

	if (max_clients > 1)
	{
		// [Paril-KEX] fetch name because now netname is kinda unsuitable
		gi_Info_ValueForKey(userinfo, "name", value);
		gi_LocClient_Print(null, print_type_t::HIGH, "$g_player_connected", value);
	}

	clent.client.pers.connected = true;

	// [Paril-KEX] force a state update
	ent.sv.init = false;

	return true;
}

/*
===========
ClientDisconnect

Called when a player drops from the server.
Will not be called between levels.
============
*/
void ClientDisconnect(ASEntity &ent)
{
	if (ent.client is null)
		return;

	// ZOID
	CTFDeadDropFlag(ent);
	CTFDeadDropTech(ent);
	// ZOID

	PlayerTrail_Destroy(ent);

	//============
	// ROGUE
	// make sure no trackers are still hurting us.
	if (ent.client.tracker_pain_time)
		RemoveAttackingPainDaemons(ent);

	if (ent.client.owned_sphere !is null)
	{
		if (ent.client.owned_sphere.e.inuse)
			G_FreeEdict(ent.client.owned_sphere);
		@ent.client.owned_sphere = null;
	}

	// ROGUE
	//============

	// send effect
	if ((ent.e.svflags & svflags_t::NOCLIENT) == 0)
	{
		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(player_muzzle_t::LOGOUT);
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
	}

    if ((ent.e.svflags & svflags_t::BOT) != 0)
    {
        level.num_bots--;
    }

	gi_unlinkentity(ent.e);
	ent.e.s.modelindex = 0;
	ent.e.solid = solid_t::NOT;
	ent.e.inuse = false;
	ent.e.sv.init = false;
	ent.classname = "disconnected";
	ent.client.pers.connected = false;
	ent.client.pers.spawned = false;
	ent.timestamp = level.time + time_sec(1);

	// update active scoreboards
	if (deathmatch.integer != 0)
        foreach (ASEntity @player : active_players)
			if (player.client.showscores)
				player.client.menutime = level.time;
}

//==============================================================

bool G_ShouldPlayersCollide(bool weaponry)
{
	if (g_disable_player_collision.integer != 0) 
		return false; // only for debugging.

	// always collide on dm
	if (coop.integer == 0)
		return true;

	// weaponry collides if friendly fire is enabled
	if (weaponry && g_friendly_fire.integer != 0)
		return true;

	// check collision cvar
	return g_coop_player_collision.integer != 0;
}


//==============================================================

trace_t SV_PM_Clip(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, contents_t mask)
{
	return gi_clip(world.e, start, mins, maxs, end, mask);
}

/*
=================
P_FallingDamage

Paril-KEX: this is moved here and now reacts directly
to ClientThink rather than being delayed.
=================
*/
void P_FallingDamage(ASEntity &ent, const pmove_t @pm)
{
	int	   damage;
	vec3_t dir;

	// dead stuff can't crater
	if (ent.health <= 0 || ent.deadflag)
		return;

	if (ent.e.s.modelindex != MODELINDEX_PLAYER)
		return; // not in the player model

	if (ent.movetype == movetype_t::NOCLIP)
		return;

	// never take falling damage if completely underwater
	if (pm.waterlevel == water_level_t::UNDER)
		return;

	// ZOID
	//  never take damage if just release grapple or on grapple
	if (ent.client.ctf_grapplereleasetime >= level.time ||
		(ent.client.ctf_grapple !is null &&
		 ent.client.ctf_grapplestate > ctfgrapplestate_t::FLY))
		return;
	// ZOID

	float delta = pm.impact_delta;

	if ((pm_config.physics_flags & physics_flags_t::PSX_SCALE) != 0)
		delta = delta * delta * 0.000078f;
	else
		delta = delta * delta * 0.0001f;

	if (pm.waterlevel == water_level_t::WAIST)
		delta *= 0.25f;
	if (pm.waterlevel == water_level_t::FEET)
		delta *= 0.5f;

	if (delta < 1)
		return;

	// restart footstep timer
	ent.client.bobtime = 0;

	if (ent.client.landmark_free_fall)
	{
		delta = min(30.0f, delta);
		ent.client.landmark_free_fall = false;
		ent.client.landmark_noise_time = level.time + time_ms(100);
	}

	if (delta < 15)
	{
		if ((pm.s.pm_flags & pmflags_t::ON_LADDER) == 0)
			ent.e.s.event = entity_event_t::FOOTSTEP;
		return;
	}

	ent.client.fall_value = delta * 0.5f;
	if (ent.client.fall_value > 40)
		ent.client.fall_value = 40;
	ent.client.fall_time = level.time + FALL_TIME;

	if (delta > 30)
	{
		if (delta >= 55)
			ent.e.s.event = entity_event_t::FALLFAR;
		else
			ent.e.s.event = entity_event_t::FALL;

		ent.pain_debounce_time = level.time + FRAME_TIME_S; // no normal pain sound
		damage = max(int((delta - 30) / 2), 1);

		if ((pm_config.physics_flags & physics_flags_t::PSX_MOVEMENT) != 0)
			damage = min(4, damage);

		dir = { 0, 0, 1 };

		if (deathmatch.integer == 0 || g_dm_no_fall_damage.integer == 0)
			T_Damage(ent, world, world, dir, ent.e.s.origin, vec3_origin, damage, 0, damageflags_t::NONE, mod_id_t::FALLING);
	}
	else
		ent.e.s.event = entity_event_t::FALLSHORT;

	// Paril: falling damage noises alert monsters
	if (ent.health != 0)
		PlayerNoise(ent, pm.s.origin, player_noise_t::SELF);
}

bool HandleMenuMovement(ASEntity &ent, const usercmd_t &in ucmd)
{
	if (ent.client.menu is null)
		return false;

	// [Paril-KEX] handle menu movement
	int menu_sign = ucmd.forwardmove > 0 ? 1 : ucmd.forwardmove < 0 ? -1 : 0;

	if (ent.client.menu_sign != menu_sign)
	{
		ent.client.menu_sign = menu_sign;

		if (menu_sign > 0)
		{
			PMenu_Prev(ent);
			return true;
		}
		else if (menu_sign < 0)
		{
			PMenu_Next(ent);
			return true;
		}
	}

	if ((ent.client.latched_buttons & (button_t::ATTACK | button_t::JUMP)) != 0)
	{
		PMenu_Select(ent);
		return true;
	}

	return false;
}

// time between ladder sounds
const gtime_t LADDER_SOUND_TIME = time_ms(300);

/*
==============
ClientThink

This will be called once for each client frame, which will
usually be a couple times for each server frame.
==============
*/
void ClientThink(edict_t @ent_handle, const usercmd_t &in ucmd)
{
    ASEntity   @other;
	uint32     i;
	pmove_t	   pm;

    ASEntity   @ent = @entities[ent_handle.s.number];

	@level.current_entity = @ent;

	// [Paril-KEX] pass buttons through even if we are in intermission or
	// chasing.
	ent.client.oldbuttons = ent.client.buttons;
	ent.client.buttons = button_t(ucmd.buttons);
	ent.client.latched_buttons = button_t(ent.client.latched_buttons | (ent.client.buttons & ~ent.client.oldbuttons));
	ent.client.cmd = ucmd;

	if ((ucmd.buttons & button_t::CROUCH) != 0 && PM_CrouchingDisabled(pm_config.physics_flags))
	{
		if (ent.client.pers.n64_crouch_warn_times < 12 &&
			ent.client.pers.n64_crouch_warning < level.time &&
			(++ent.client.pers.n64_crouch_warn_times % 3) == 0)
		{
			ent.client.pers.n64_crouch_warning = level.time + time_sec(10);
			gi_LocClient_Print(ent.e, print_type_t::CENTER, "$g_n64_crouching");
		}
	}

	if (level.intermissiontime || ent.client.awaiting_respawn)
	{
		ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;

		bool n64_sp = false;

		if (level.intermissiontime)
		{
			n64_sp = deathmatch.integer == 0 && level.is_n64;

			// can exit intermission after five seconds
			// Paril: except in N64. the camera handles it.
			// Paril again: except on unit exits, we can leave immediately after camera finishes
			if (!level.changemap.empty() && (!n64_sp || level.level_intermission_set) &&
                level.time > level.intermissiontime + time_sec(5) && (ucmd.buttons & button_t::ANY) != 0)
				level.exitintermission = true;
		}

		if (!n64_sp)
			ent.e.client.ps.pmove.viewheight = ent.viewheight = 22;
		else
			ent.e.client.ps.pmove.viewheight = ent.viewheight = 0;
		ent.movetype = movetype_t::NOCLIP;
		return;
	}

	if (ent.client.chase_target !is null)
	{
		ent.client.resp.cmd_angles = ucmd.angles;
		ent.movetype = movetype_t::NOCLIP;
	}
	else
	{
		// set up for pmove

		if (ent.movetype == movetype_t::NOCLIP)
		{
            if (ent.client.menu !is null)
			{
				ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;
				
				// [Paril-KEX] handle menu movement
				HandleMenuMovement(ent, ucmd);
			}
			else if (ent.client.awaiting_respawn)
				ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;
			else if (ent.client.resp.spectator || (G_TeamplayEnabled() && ent.client.resp.ctf_team == ctfteam_t::NOTEAM))
				ent.e.client.ps.pmove.pm_type = pmtype_t::SPECTATOR;
			else
				ent.e.client.ps.pmove.pm_type = pmtype_t::NOCLIP;
		}
		else if (ent.e.s.modelindex != MODELINDEX_PLAYER)
			ent.e.client.ps.pmove.pm_type = pmtype_t::GIB;
		else if (ent.deadflag)
			ent.e.client.ps.pmove.pm_type = pmtype_t::DEAD;
		else if (ent.client.ctf_grapplestate >= ctfgrapplestate_t::PULL)
			ent.e.client.ps.pmove.pm_type = pmtype_t::GRAPPLE;
		else
			ent.e.client.ps.pmove.pm_type = pmtype_t::NORMAL;

		// [Paril-KEX]
		if (!G_ShouldPlayersCollide(false) ||
				(coop.integer != 0 && (ent.e.clipmask & contents_t::PLAYER) == 0) // if player collision is on and we're temporarily ghostly...
			)
			ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags | pmflags_t::IGNORE_PLAYER_COLLISION);
		else
			ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~pmflags_t::IGNORE_PLAYER_COLLISION);

		// PGM	trigger_gravity support
		if (ent.no_gravity_time > level.time)
		{
			ent.e.client.ps.pmove.gravity = 0;
			ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags | pmflags_t::NO_GROUND_SEEK);
		}
		else
		{
			ent.e.client.ps.pmove.gravity = int16(level.gravity * ent.gravity);
			ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~pmflags_t::NO_GROUND_SEEK);
		}

		pm.s = ent.e.client.ps.pmove;

		pm.s.origin = ent.e.s.origin;
		pm.s.velocity = ent.velocity;

        if (ent.client.old_pmove != pm.s)
			pm.snapinitial = true;

		pm.cmd = ucmd;
		@pm.player = ent.e;
		@pm.trace = gi_trace;
		@pm.clip = SV_PM_Clip;
		@pm.pointcontents = @gi_pointcontents;
		pm.viewoffset = ent.e.client.ps.viewoffset;

		// perform a pmove
		Pmove(pm);
		
		if (pm.groundentity !is null && ent.groundentity !is null)
		{
			float stepsize = abs(ent.e.s.origin[2] - pm.s.origin[2]);

			if (stepsize > 4.0f && stepsize < STEPSIZE)
			{
				ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::STAIR_STEP);
				ent.client.step_frame = gi_ServerFrame() + 1;
			}
		}

		P_FallingDamage(ent, pm);

		if (ent.client.landmark_free_fall && pm.groundentity !is null)
		{
			ent.client.landmark_free_fall = false;
			ent.client.landmark_noise_time = level.time + time_ms(100);
		}

		// [Paril-KEX] save old position for G_TouchProjectiles
		vec3_t old_origin = ent.e.s.origin;

		ent.e.s.origin = pm.s.origin;
		ent.velocity = pm.s.velocity;

		// [Paril-KEX] if we stepped onto/off of a ladder, reset the
		// last ladder pos
		if ((pm.s.pm_flags & pmflags_t::ON_LADDER) != (ent.e.client.ps.pmove.pm_flags & pmflags_t::ON_LADDER))
		{
			ent.client.last_ladder_pos = ent.e.s.origin;

			if ((pm.s.pm_flags & pmflags_t::ON_LADDER) != 0)
			{
				if (deathmatch.integer == 0 && 
					ent.client.last_ladder_sound < level.time)
				{
					ent.e.s.event = entity_event_t::LADDER_STEP;
					ent.client.last_ladder_sound = level.time + LADDER_SOUND_TIME;
				}
			}
		}

		// save results of pmove
		ent.e.client.ps.pmove = pm.s;
		ent.client.old_pmove = pm.s;

		ent.e.mins = pm.mins;
		ent.e.maxs = pm.maxs;

		if (ent.client.menu is null)
			ent.client.resp.cmd_angles = ucmd.angles;

		if (pm.jump_sound && (pm.s.pm_flags & pmflags_t::ON_LADDER) == 0)
		{
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("*jump1.wav"), 1, ATTN_NORM, 0);
			// Paril: removed to make ambushes more effective and to
			// not have monsters around corners come to jumps
			// PlayerNoise(ent, ent.s.origin, PNOISE_SELF);
		}

		// ROGUE sam raimi cam support
		if ((ent.flags & ent_flags_t::SAM_RAIMI) != 0)
			ent.viewheight = 8;
		else
			ent.viewheight = int(pm.s.viewheight);
		// ROGUE

		ent.waterlevel = water_level_t(pm.waterlevel);
		ent.watertype = pm.watertype;
		if (pm.groundentity !is null)
        {
    		@ent.groundentity = @entities[pm.groundentity.s.number];
			ent.groundentity_linkcount = pm.groundentity.linkcount;
        }
        else
            @ent.groundentity = null;

		if (ent.deadflag)
		{
			ent.e.client.ps.viewangles.roll = 40;
			ent.e.client.ps.viewangles.pitch = -15;
			ent.e.client.ps.viewangles.yaw = ent.client.killer_yaw;
		}
		else if (ent.client.menu is null)
		{
			ent.client.v_angle = pm.viewangles;
			ent.e.client.ps.viewangles = pm.viewangles;
			AngleVectors(ent.client.v_angle, ent.client.v_forward);
		}

		// ZOID
		if (ent.client.ctf_grapple !is null)
			CTFGrapplePull(ent.client.ctf_grapple);
		// ZOID

		gi_linkentity(ent.e);

		// PGM trigger_gravity support
		ent.gravity = 1.0f;
		// PGM

		if (ent.movetype != movetype_t::NOCLIP)
		{
			G_TouchTriggers(ent);
			G_TouchProjectiles(ent, old_origin);
		}

		// touch other objects
		for (i = 0; i < pm.touch_length(); i++)
		{
			@other = entities[pm.touch_get(i).ent.s.number];

			if (other.touch !is null)
				other.touch(other, ent, pm.touch_get(i), true);
		}
	}

	// fire weapon from final position if needed
	if ((ent.client.latched_buttons & button_t::ATTACK) != 0)
	{
		if (ent.client.resp.spectator)
		{
			ent.client.latched_buttons = button_t::NONE;

			if (ent.client.chase_target !is null)
			{
				@ent.client.chase_target = null;
				ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~(pmflags_t::NO_POSITIONAL_PREDICTION | pmflags_t::NO_ANGULAR_PREDICTION));
			}
			else
				GetChaseTarget(ent);
		}
		else if (!ent.client.weapon_thunk)
		{
			// we can only do this during a ready state and
			// if enough time has passed from last fire
			if (ent.client.weaponstate == weaponstate_t::READY)
			{
				ent.client.weapon_fire_buffered = true;

				if (ent.client.weapon_fire_finished <= level.time)
				{
					ent.client.weapon_thunk = true;
					Think_Weapon(ent);
				}
			}
		}
	}

	if (ent.client.resp.spectator)
	{
		if (!HandleMenuMovement(ent, ucmd))
		{
			if ((ucmd.buttons & button_t::JUMP) != 0)
			{
				if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::JUMP_HELD) == 0)
				{
					ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags | pmflags_t::JUMP_HELD);
					if (ent.client.chase_target !is null)
						ChaseNext(ent);
					else
						GetChaseTarget(ent);
				}
			}
			else
				ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~pmflags_t::JUMP_HELD);
		}
	}

	// update chase cam if being followed
	for (i = 1; i <= max_clients; i++)
	{
		@other = entities[i];
		if (other.e.inuse && other.client.chase_target is ent)
			UpdateChaseCam(other);
	}
}

/*
// active monsters
struct active_monsters_filter_t
{
	inline bool operator()(edict_t *ent) const
	{
		return (ent->inuse && (ent->svflags & SVF_MONSTER) && ent->health > 0);
	}
};

inline entity_iterable_t<active_monsters_filter_t> active_monsters()
{
	return entity_iterable_t<active_monsters_filter_t> { game.maxclients + (uint32_t)BODY_QUEUE_SIZE + 1U };
}

inline bool G_MonstersSearchingFor(edict_t *player)
{
	for (auto ent : active_monsters())
	{
		// check for *any* player target
		if (player == null && ent->enemy && !ent->enemy->client)
			continue;
		// they're not targeting us, so who cares
		else if (player != nullptr && ent->enemy != player)
			continue;

		// they lost sight of us
		if ((ent->monsterinfo.aiflags & AI_LOST_SIGHT) && level.time > ent->monsterinfo.trail_time + 5_sec)
			continue;

		// no sir
		return true;
	}

	// yes sir
	return false;
}

// [Paril-KEX] from the given player, find a good spot to
// spawn a player
inline bool G_FindRespawnSpot(edict_t *player, vec3_t &spot)
{
	// sanity check; make sure there's enough room for ourselves.
	// (crouching in a small area, etc)
	trace_t tr = gi.trace(player->s.origin, PLAYER_MINS, PLAYER_MAXS, player->s.origin, player, MASK_PLAYERSOLID);

	if (tr.startsolid || tr.allsolid)
		return false;

	// throw five boxes a short-ish distance from the player and see if they land in a good, visible spot
	constexpr float yaw_spread[] = { 0, 90, 45, -45, -90 };
	constexpr float back_distance = 128.f;
	constexpr float up_distance = 128.f;
	constexpr float player_viewheight = 22.f;

	// we don't want to spawn inside of these
	contents_t mask = MASK_PLAYERSOLID | CONTENTS_LAVA | CONTENTS_SLIME;

	for (auto &yaw : yaw_spread)
	{
		vec3_t angles = { 0, (player->s.angles.yaw + 180) + yaw, 0 };

		// throw the box three times:
		// one up & back
		// one back
		// one up, then back
		// pick the one that went the farthest
		vec3_t start = player->s.origin;
		vec3_t end = start + vec3_t { 0, 0, up_distance };

		tr = gi.trace(start, PLAYER_MINS, PLAYER_MAXS, end, player, mask);

		// stuck
		if (tr.startsolid || tr.allsolid || (tr.contents & (CONTENTS_LAVA | CONTENTS_SLIME)))
			continue;

		vec3_t fwd;
		AngleVectors(angles, fwd);

		start = tr.endpos;
		end = start + fwd * back_distance;

		tr = gi.trace(start, PLAYER_MINS, PLAYER_MAXS, end, player, mask);

		// stuck
		if (tr.startsolid || tr.allsolid || (tr.contents & (CONTENTS_LAVA | CONTENTS_SLIME)))
			continue;

		// plop us down now
		start = tr.endpos;
		end = tr.endpos - vec3_t { 0, 0, up_distance * 4 };

		tr = gi.trace(start, PLAYER_MINS, PLAYER_MAXS, end, player, mask);

		// stuck, or floating, or touching some other entity
		if (tr.startsolid || tr.allsolid || (tr.contents & (CONTENTS_LAVA | CONTENTS_SLIME)) || tr.fraction == 1.0f || tr.ent != world)
			continue;

		// don't spawn us *inside* liquids
		if (gi.pointcontents(tr.endpos + vec3_t{0, 0, player_viewheight}) & MASK_WATER)
			continue;

		// don't spawn us on steep slopes
		if (tr.plane.normal.z < 0.7f)
			continue;

		spot = tr.endpos;

		float z_diff = fabsf(player->s.origin[2] - tr.endpos[2]);

		// 5 steps is way too many steps
		if (z_diff > STEPSIZE * 4.f)
			continue;

		// if we went up or down 1 step, make sure we can still see their origin and their head
		if (z_diff > STEPSIZE)
		{
			tr = gi.traceline(player->s.origin, tr.endpos, player, mask);

			if (tr.fraction != 1.0f)
				continue;

			tr = gi.traceline(player->s.origin + vec3_t{0, 0, player_viewheight}, tr.endpos + vec3_t{0, 0, player_viewheight}, player, mask);

			if (tr.fraction != 1.0f)
				continue;
		}

		// good spot!
		return true;
	}

	return false;
}

// [Paril-KEX] check each player to find a good
// respawn target & position
inline std::tuple<edict_t *, vec3_t> G_FindSquadRespawnTarget()
{
	bool monsters_searching_for_anybody = G_MonstersSearchingFor(nullptr);

	for (auto player : active_players())
	{
		// no dead players
		if (player->deadflag)
			continue;
		
		// check combat state; we can't have taken damage recently
		if (player->client->last_damage_time >= level.time)
		{
			player->client->coop_respawn_state = COOP_RESPAWN_IN_COMBAT;
			continue;
		}

		// check if any monsters are currently targeting us
		// or searching for us
		if (G_MonstersSearchingFor(player))
		{
			player->client->coop_respawn_state = COOP_RESPAWN_IN_COMBAT;
			continue;
		}

		// check firing state; if any enemies are mad at any players,
		// don't respawn until everybody has cooled down
		if (monsters_searching_for_anybody && player->client->last_firing_time >= level.time)
		{
			player->client->coop_respawn_state = COOP_RESPAWN_IN_COMBAT;
			continue;
		}

		// check positioning; we must be on world ground
		if (player->groundentity != world)
		{
			player->client->coop_respawn_state = COOP_RESPAWN_BAD_AREA;
			continue;
		}

		// can't be in liquid
		if (player->waterlevel >= WATER_UNDER)
		{
			player->client->coop_respawn_state = COOP_RESPAWN_BAD_AREA;
			continue;
		}

		// good player; pick a spot
		vec3_t spot;
		
		if (!G_FindRespawnSpot(player, spot))
		{
			player->client->coop_respawn_state = COOP_RESPAWN_BLOCKED;
			continue;
		}

		// good player most likely
		return { player, spot };
	}

	// no good player
	return { nullptr, {} };
}
*/

enum respawn_state_t
{
	NONE,     // invalid state
	SPECTATE, // move to spectator
	SQUAD,    // move to good squad point
	START     // move to start of map
};

// [Paril-KEX] return false to fall back to click-to-respawn behavior.
// note that this is only called if they are allowed to respawn (not
// restarting the level due to all being dead)
bool G_CoopRespawn(ASEntity &ent)
{
	// don't do this in non-coop
	if (coop.integer == 0)
		return false;
	// if we don't have squad or lives, it doesn't matter
	else if (g_coop_squad_respawn.integer == 0 && g_coop_enable_lives.integer == 0)
		return false;

/*
	respawn_state_t state = RESPAWN_NONE;

	// first pass: if we have no lives left, just move to spectator
	if (g_coop_enable_lives->integer)
	{
		if (ent->client->pers.lives == 0)
		{
			state = RESPAWN_SPECTATE;
			ent->client->coop_respawn_state = COOP_RESPAWN_NO_LIVES;
		}
	}

	// second pass: check for where to spawn
	if (state == RESPAWN_NONE)
	{
		// if squad respawn, don't respawn until we can find a good player to spawn on.
		if (g_coop_squad_respawn->integer)
		{
			bool allDead = true;

			for (auto player : active_players())
			{
				if (player->health > 0)
				{
					allDead = false;
					break;
				}
			}

			// all dead, so if we ever get here we have lives enabled;
			// we should just respawn at the start of the level
			if (allDead)
				state = RESPAWN_START;
			else
			{
				auto [ good_player, good_spot ] = G_FindSquadRespawnTarget();

				if (good_player) {
					state = RESPAWN_SQUAD;

					squad_respawn_position = good_spot;
					squad_respawn_angles = good_player->s.angles;
					squad_respawn_angles[2] = 0;

					use_squad_respawn = true;
				} else {
					state = RESPAWN_SPECTATE;
				}
			}
		}
		else
			state = RESPAWN_START;
	}

	if (state == RESPAWN_SQUAD || state == RESPAWN_START)
	{
		// give us our max health back since it will reset
		// to pers.health; in instanced items we'd lose the items
		// we touched so we always want to respawn with our max.
		if (P_UseCoopInstancedItems())
			ent->client->pers.health = ent->client->pers.max_health = ent->max_health;

		respawn(ent);

		ent->client->latched_buttons = BUTTON_NONE;
		use_squad_respawn = false;
	}
	else if (state == RESPAWN_SPECTATE)
	{
		if (!ent->client->coop_respawn_state)
			ent->client->coop_respawn_state = COOP_RESPAWN_WAITING;

		if (!ent->client->resp.spectator)
		{
			// move us to spectate just so we don't have to twiddle
			// our thumbs forever
			CopyToBodyQue(ent);
			ent->client->resp.spectator = true;
			ent->solid = SOLID_NOT;
			ent->takedamage = false;
			ent->s.modelindex = 0;
			ent->svflags |= SVF_NOCLIENT;
			ent->client->ps.damage_blend[3] = ent->client->ps.screen_blend[3] = 0;
			ent->client->ps.rdflags = RDF_NONE;
			ent->movetype = MOVETYPE_NOCLIP;
			// TODO: check if anything else needs to be reset
			gi.linkentity(ent);
			GetChaseTarget(ent);
		}
	}
*/
	return true;
}

/*
==============
ClientBeginServerFrame

This will be called once for each server frame, before running
any other entities in the world.
==============
*/
void ClientBeginServerFrame(ASEntity &ent)
{
	int		   buttonMask;

	if (gi_ServerFrame() != ent.client.step_frame)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx & ~renderfx_t::STAIR_STEP);

	if (level.intermissiontime)
		return;

	if (ent.client.awaiting_respawn)
	{
		if ((level.time.milliseconds % 500) == 0)
			PutClientInServer(ent);
		return;
	}

	if ( ( ent.e.svflags & svflags_t::BOT ) != 0 ) {
        // AS_TODO
		//Bot_BeginFrame( ent );
	}

	if (deathmatch.integer != 0 && !G_TeamplayEnabled() &&
		ent.client.pers.spectator != ent.client.resp.spectator &&
		(level.time - ent.client.respawn_time) >= time_sec(5))
	{
		spectator_respawn(ent);
		return;
	}

	// run weapon animations if it hasn't been done by a ucmd_t
	if (!ent.client.weapon_thunk && !ent.client.resp.spectator)
		Think_Weapon(ent);
	else
		ent.client.weapon_thunk = false;

	if (ent.deadflag)
	{
		// don't respawn if level is waiting to restart
        if (level.time > ent.client.respawn_time && !level.coop_level_restart_time)
		{
			// check for coop handling
			if (!G_CoopRespawn(ent))
			{
				// in deathmatch, only wait for attack button
				if (deathmatch.integer != 0)
					buttonMask = button_t::ATTACK;
				else
					buttonMask = button_t(-1);

				if ((ent.client.latched_buttons & buttonMask) != 0 ||
					(deathmatch.integer != 0 && g_dm_force_respawn.integer != 0))
				{
					respawn(ent);
					ent.client.latched_buttons = button_t::NONE;
				}
			}
		}
		return;
	}

	// add player trail so monsters can follow
	if (deathmatch.integer == 0)
		PlayerTrail_Add(ent);

	ent.client.latched_buttons = button_t::NONE;
}

/*
==============
RemoveAttackingPainDaemons

This is called to clean up the pain daemons that the disruptor attaches
to clients to damage them.
==============
*/
void RemoveAttackingPainDaemons(ASEntity &self)
{
	ASEntity @tracker;

	@tracker = find_by_str<ASEntity>(null, "classname", "pain daemon");
	while (tracker !is null)
	{
		if (tracker.enemy is self)
			G_FreeEdict(tracker);
		@tracker = find_by_str<ASEntity>(tracker, "classname", "pain daemon");
	}

	if (self.client !is null)
		self.client.tracker_pain_time = time_zero;
}
