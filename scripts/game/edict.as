/*
	edict handles are managed by the host (it's just an always-allocated array).
	if an edict handle has a handle set in code, it will only be managed by AS.
	it won't have any of the non-edict_shared_t members set so native entities
	won't see it correctly, though.

	for now, the host also manages the entity handle allocation. in the future
	this will be moved here.
*/

enum ent_flags_t : uint64
{
	NONE                 = 0, // no flags
	FLY                  = 1 << 0, 
	SWIM                 = 1 << 1, // implied immunity to drowning
	IMMUNE_LASER         = 1 << 2, 
	INWATER              = 1 << 3, 
	GODMODE              = 1 << 4, 
	NOTARGET             = 1 << 5, 
	IMMUNE_SLIME         = 1 << 6, 
	IMMUNE_LAVA          = 1 << 7, 
	PARTIALGROUND        = 1 << 8, // not all corners are valid
	WATERJUMP            = 1 << 9, // player jumping out of water
	TEAMSLAVE            = 1 << 10, // not the first on the team
	NO_KNOCKBACK         = 1 << 11, 
	POWER_ARMOR          = 1 << 12, // power armor (if any) is active

	// ROGUE
	MECHANICAL           = 1 << 13, // entity is mechanical, use sparks not blood
	SAM_RAIMI            = 1 << 14, // entity is in sam raimi cam mode
	DISGUISED            = 1 << 15, // entity is in disguise, monsters will not recognize.
	NOGIB                = 1 << 16, // player has been vaporized by a nuke, drop no gibs
	DAMAGEABLE           = 1 << 17,
	STATIONARY           = 1 << 18,
	// ROGUE

	ALIVE_KNOCKBACK_ONLY = 1 << 19, // only apply knockback if alive or on same frame as death
	NO_DAMAGE_EFFECTS    = 1 << 20,

	// [Paril-KEX] gets scaled by coop health scaling
	COOP_HEALTH_SCALE   = 1 << 21,
	FLASHLIGHT			= 1 << 22, // enable flashlight
	KILL_VELOCITY		= 1 << 23, // for berserker slam
	NOVISIBLE           = 1 << 24, // super invisibility
	DODGE				= 1 << 25, // monster should try to dodge this
	TEAMMASTER			= 1 << 26, // is a team master (only here so that entities abusing teammaster/teamchain for stuff don't break)
	LOCKED				= 1 << 27, // entity is locked for the purposes of navigation
	ALWAYS_TOUCH        = 1 << 28, // always touch, even if we normally wouldn't
	NO_STANDING		    = 1 << 29, // don't allow "standing" on non-brush entities
	WANTS_POWER_ARMOR   = 1 << 30, // for players, auto-shield

	RESPAWN             = uint64(1) << 31, // used for item respawning
	TRAP			    = uint64(1) << 32, // entity is a trap of some kind
	TRAP_LASER_FIELD    = uint64(1) << 33, // enough of a special case to get it's own flag...
	IMMORTAL            = uint64(1) << 34  // never go below 1hp
}

enum movetype_t
{
	NONE,	 // never moves
	NOCLIP, // origin and angles change with no interaction
	PUSH,	 // no clip to world, push on box contact
	STOP,	 // no clip to world, stops on box contact

	WALK, // gravity
	STEP, // gravity, special edge handling
	FLY,
	TOSS,		 // gravity
	FLYMISSILE, // extra size to monsters
	BOUNCE,
	// RAFAEL
	WALLBOUNCE
	// RAFAEL
}

// means of death
enum mod_id_t : uint8
{
	UNKNOWN,
	BLASTER,
	SHOTGUN,
	SSHOTGUN,
	MACHINEGUN,
	CHAINGUN,
	GRENADE,
	G_SPLASH,
	ROCKET,
	R_SPLASH,
	HYPERBLASTER,
	RAILGUN,
	BFG_LASER,
	BFG_BLAST,
	BFG_EFFECT,
	HANDGRENADE,
	HG_SPLASH,
	WATER,
	SLIME,
	LAVA,
	CRUSH,
	TELEFRAG,
	TELEFRAG_SPAWN,
	FALLING,
	SUICIDE,
	HELD_GRENADE,
	EXPLOSIVE,
	BARREL,
	BOMB,
	EXIT,
	SPLASH,
	TARGET_LASER,
	TRIGGER_HURT,
	HIT,
	TARGET_BLASTER,
	// RAFAEL 14-APR-98
	RIPPER,
	PHALANX,
	BRAINTENTACLE,
	BLASTOFF,
	GEKK,
	TRAP,
	// END 14-APR-98
	//========
	// ROGUE
	CHAINFIST,
	DISINTEGRATOR,
	ETF_RIFLE,
	BLASTER2,
	HEATBEAM,
	TESLA,
	PROX,
	NUKE,
	VENGEANCE_SPHERE,
	HUNTER_SPHERE,
	DEFENDER_SPHERE,
	TRACKER,
	DBALL_CRUSH,
	DOPPLE_EXPLODE,
	DOPPLE_VENGEANCE,
	DOPPLE_HUNTER,
	// ROGUE
	//========
	GRAPPLE,
	BLUEBLASTER
};

class mod_t
{
	mod_id_t	id;
	bool		friendly_fire;
	bool		no_point_loss;

	mod_t()
	{
	}

	mod_t(mod_id_t id, bool no_point_loss)
	{
		this.id = id;
		this.no_point_loss = no_point_loss;
	}

	mod_t(mod_id_t id)
	{
		this.id = id;
	}
}

enum move_state_t
{
	TOP,
	BOTTOM,
	UP,
	DOWN
};

funcdef void endfunc_f(ASEntity &);
funcdef void blocked_f(ASEntity &, ASEntity &);

class moveinfo_t
{
	// fixed data
	vec3_t start_origin;
	vec3_t start_angles;
	vec3_t end_origin;
	vec3_t end_angles, end_angles_reversed;

	int32 sound_start;
	int32 sound_middle;
	int32 sound_end;

	float accel;
	float speed;
	float decel;
	float distance;

	float wait;

	// state data
	move_state_t state;
	bool		 reversing;
	vec3_t		 dir;
	vec3_t		 dest;
	float		 current_speed;
	float		 move_speed;
	float		 next_speed;
	float		 remaining_distance;
	float		 decel_distance;
	endfunc_f    @endfunc;
	blocked_f    @blocked;

	// [Paril-KEX] new accel state
	vec3_t        curve_ref;
	array<float>  curve_positions;
	uint	      curve_frame;
	uint8	      subframe, num_subframes;
	uint          num_frames_done;
};

funcdef void aifunc_f(ASEntity &, float);
funcdef void aithink_f(ASEntity &);

class mframe_t
{
	aifunc_f @aifunc = null;
	float dist = 0;
	aithink_f @thinkfunc = null;
	int32 lerp_frame = -1;

	mframe_t() { }
	mframe_t(aifunc_f @aifunc)
	{
		@this.aifunc = aifunc;
	}
	mframe_t(aifunc_f @aifunc, float dist)
	{
		@this.aifunc = aifunc;
		this.dist = dist;
	}
	mframe_t(aifunc_f @aifunc, float dist, aithink_f @thinkfunc)
	{
		@this.aifunc = aifunc;
		this.dist = dist;
		@this.thinkfunc = thinkfunc;
	}
	mframe_t(aifunc_f @aifunc, float dist, aithink_f @thinkfunc, int lerp_frame)
	{
		@this.aifunc = aifunc;
		this.dist = dist;
		@this.thinkfunc = thinkfunc;
		this.lerp_frame = lerp_frame;
	}
};

funcdef void move_endfunc_f(ASEntity &);

class mmove_t
{
	int32 firstframe;
	int32 lastframe;
	const array<mframe_t> @frames;
	move_endfunc_f @endfunc;
	float sidestep_scale;

	mmove_t(int32 firstframe, int32 lastframe, const array<mframe_t> @frames, move_endfunc_f @endfunc = null, float sidestep_scale = 0.0f)
	{
		this.firstframe = firstframe;
		this.lastframe = lastframe;
		@this.frames = @frames;
		@this.endfunc = @endfunc;
		this.sidestep_scale = sidestep_scale;
	}
};

// combat styles, for navigation
enum combat_style_t
{
	UNKNOWN, // automatically choose based on attack functions
	MELEE, // should attempt to get up close for melee
	MIXED, // has mixed melee/ranged; runs to get up close if far enough away
	RANGED // don't bother pathing if we can see the player
};

class reinforcement_t
{
	string classname;
	int32 strength;
	vec3_t mins, maxs;
};

// monster attack state
enum ai_attack_state_t
{
	NONE,
	STRAIGHT,
	SLIDING,
	MELEE,
	MISSILE,
	BLIND // PMM - used by boss code to do nasty things even if it can't see you
};

// monster ai flags
enum ai_flags_t : uint64
{
	NONE              = 0,
	STAND_GROUND      = 1 << 0,
	TEMP_STAND_GROUND = 1 << 1,
	SOUND_TARGET      = 1 << 2,
	LOST_SIGHT        = 1 << 3,
	PURSUIT_LAST_SEEN = 1 << 4,
	PURSUE_NEXT       = 1 << 5,
	PURSUE_TEMP       = 1 << 6,
	HOLD_FRAME        = 1 << 7,
	GOOD_GUY          = 1 << 8,
	BRUTAL            = 1 << 9,
	NOSTEP            = 1 << 10,
	DUCKED            = 1 << 11,
	COMBAT_POINT      = 1 << 12,
	MEDIC             = 1 << 13,
	RESURRECTING      = 1 << 14,

	// ROGUE
	MANUAL_STEERING = 1 << 15,
	TARGET_ANGER    = 1 << 16,
	DODGING         = 1 << 17,
	CHARGING        = 1 << 18,
	HINT_PATH_UNUSED= 1 << 19,
	IGNORE_SHOTS    = 1 << 20,
	// PMM - FIXME - last second added for E3 .. there's probably a better way to do this, but
	// this works
	DO_NOT_COUNT      = 1 << 21,	 // set for healed monsters
	SPAWNED_COMMANDER = 1 << 22, // both do_not_count and spawned are set for spawned monsters
	SPAWNED_NEEDS_GIB = 1 << 23, // only return commander slots when gibbed
	BLOCKED           = 1 << 25, // used by blocked_checkattack: set to say I'm attacking while blocked
												// (prevents run-attacks)
												// ROGUE
	SPAWNED_ALIVE   = 1 << 26, // [Paril-KEX] for spawning dead
	SPAWNED_DEAD    = 1 << 27,
	HIGH_TICK_RATE  = 1 << 28, // not limited by 10hz actions
	NO_PATH_FINDING = 1 << 29, // don't try nav nodes for path finding
	PATHING         = 1 << 30, // using nav nodes currently
	STINKY          = uint64(1) << 31, // spawn flies
	STUNK           = uint64(1) << 32, // already spawned files

	ALTERNATE_FLY       = uint64(1) << 33, // use alternate flying mechanics; see monsterinfo.fly_xxx
	TEMP_MELEE_COMBAT   = uint64(1) << 34, // temporarily switch to the melee combat style
	FORGET_ENEMY        = uint64(1) << 35,			// forget the current enemy
	DOUBLE_TROUBLE      = uint64(1) << 36, // JORG only
	REACHED_HOLD_COMBAT = uint64(1) << 37,
	THIRD_EYE           = uint64(1) << 38,

	// flags saved when monster is respawned
	RESPAWN_MASK = STINKY | SPAWNED_COMMANDER | SPAWNED_NEEDS_GIB,
	// flags saved when a monster dies
	DEATH_MASK   = DOUBLE_TROUBLE | GOOD_GUY | RESPAWN_MASK
};

funcdef void monsterinfo_stand_f(ASEntity &);
funcdef void monsterinfo_idle_f(ASEntity &);
funcdef void monsterinfo_search_f(ASEntity &);
funcdef void monsterinfo_walk_f(ASEntity &);
funcdef void monsterinfo_run_f(ASEntity &);
funcdef void monsterinfo_dodge_f(ASEntity &, ASEntity &, gtime_t, const trace_t &in, bool, bool);
funcdef void monsterinfo_attack_f(ASEntity &);
funcdef void monsterinfo_melee_f(ASEntity &);
funcdef void monsterinfo_sight_f(ASEntity &, ASEntity &);
funcdef bool monsterinfo_checkattack_f(ASEntity &);
funcdef void monsterinfo_setskin_f(ASEntity &);
funcdef void monsterinfo_physicschange_f(ASEntity &);

funcdef bool monsterinfo_blocked_f(ASEntity &, float);

funcdef bool monsterinfo_duck_f(ASEntity &, gtime_t eta);
funcdef void monsterinfo_unduck_f(ASEntity &);
funcdef bool monsterinfo_sidestep_f(ASEntity &);

class monsterinfo_t
{
	// [Paril-KEX] allow some moves to be done instantaneously, but
	// others can wait the full frame.
	// NB: always use `M_SetAnimation` as it handles edge cases.
	const mmove_t	   @active_move, next_move;
	ai_flags_t         aiflags; // PGM - unsigned, since we're close to the max
	int32			   nextframe; // if next_move is set, this is ignored until a frame is ran
	float			   scale;

	monsterinfo_stand_f @stand;
	monsterinfo_idle_f @idle;
	monsterinfo_search_f @search;
	monsterinfo_walk_f @walk;
	monsterinfo_run_f @run;
	monsterinfo_dodge_f @dodge;
	monsterinfo_attack_f @attack;
	monsterinfo_melee_f @melee;
	monsterinfo_sight_f @sight;
	monsterinfo_checkattack_f @checkattack;
	monsterinfo_setskin_f @setskin;
	monsterinfo_physicschange_f @physics_change;

	gtime_t pausetime;
	gtime_t attack_finished;
	gtime_t fire_wait;

	vec3_t				   saved_goal;
	gtime_t				   search_time;
	gtime_t				   trail_time;
	vec3_t				   last_sighting;
	ai_attack_state_t      attack_state;
	bool				   lefty;
	gtime_t				   idle_time;
	int32				   linkcount;

	item_id_t power_armor_type;
	int32	  power_armor_power;

	// for monster revive
	item_id_t initial_power_armor_type;
	int32	  max_power_armor_power;
	int32	  weapon_sound, engine_sound;

	// ROGUE
	monsterinfo_blocked_f @blocked;
	int32	 medicTries;
	ASEntity @badMedic1, badMedic2; // these medics have declared this monster "unhealable"
	ASEntity @healer;				// this is who is healing this monster
	monsterinfo_duck_f @duck;
	monsterinfo_unduck_f @unduck;
	monsterinfo_sidestep_f @sidestep;
	float	 base_height;
	gtime_t	 next_duck_time;
	gtime_t	 duck_wait_time;
	ASEntity @last_player_enemy;
	// blindfire stuff .. the boolean says whether the monster will do it, and blind_fire_time is the timing
	// (set in the monster) of the next shot
	bool	blindfire;		// will the monster blindfire?
	bool    can_jump;       // will the monster jump?
	bool	had_visibility; // Paril: used for blindfire
	float	drop_height, jump_height;
	gtime_t blind_fire_delay;
	vec3_t	blind_fire_target;
	// used by the spawners to not spawn too much and keep track of #s of monsters spawned
	int32    slots_from_commander; // for spawned monsters, this is how many slots we took from our commander
	int32	 monster_slots; // for commanders, total slots we can occupy
	int32	 monster_used; // for commanders, total slots currently used
	ASEntity @commander;
	// powerup timers, used by widow, our friend
	gtime_t quad_time;
	gtime_t invincible_time;
	gtime_t double_time;
	// ROGUE

	// Paril
	gtime_t	  surprise_time;
	item_id_t armor_type;
	int32	  armor_power;
	bool	  close_sight_tripped = false;
	gtime_t   melee_debounce_time; // don't melee until this time has passed
	gtime_t	  strafe_check_time; // time until we should reconsider strafing
	int32	  base_health; // health that we had on spawn, before any co-op adjustments
	int32     health_scaling; // number of players we've been scaled up to
	gtime_t   next_move_time; // high tick rate
	gtime_t	  bad_move_time; // don't try straight moves until this is over
	gtime_t	  bump_time; // don't slide against walls for a bit
	gtime_t	  random_change_time; // high tickrate
	gtime_t	  path_blocked_counter; // break out of paths when > a certain time
	gtime_t	  path_wait_time; // don't try nav nodes until this is over
	PathInfo  nav_path; // if AI_PATHING, this is where we are trying to reach
	gtime_t	  nav_path_cache_time; // cache nav_path result for this much time
	combat_style_t combat_style; // pathing style

	ASEntity  @damage_attacker;
	ASEntity  @damage_inflictor;
	int32     damage_blood, damage_knockback;
	vec3_t	  damage_from;
	mod_t	  damage_mod;

	// alternate flying mechanics
	float fly_max_distance, fly_min_distance; // how far we should try to stay
	float fly_acceleration; // accel/decel speed
	float fly_speed; // max speed from flying
	vec3_t fly_ideal_position; // ideally where we want to end up to hover, relative to our target if not pinned
	gtime_t fly_position_time; // if <= level.time, we can try changing positions
	bool fly_buzzard, fly_above; // orbit around all sides of their enemy, not just the sides
	bool fly_pinned; // whether we're currently pinned to ideal position (made absolute)
	bool fly_thrusters; // slightly different flight mechanics, for melee attacks
	gtime_t fly_recovery_time; // time to try a new dir to get away from hazards
	vec3_t fly_recovery_dir;

	gtime_t checkattack_time;
	int32 start_frame;
	gtime_t dodge_time;
	int32 move_block_counter;
	gtime_t move_block_change_time;
	gtime_t react_to_damage_time;

	array<reinforcement_t> reinforcements;
	array<uint8> chosen_reinforcements; // readied for spawn

	gtime_t jump_time;

	// NOTE: if adding new elements, make sure to add them
	// in g_save.cpp too!
};

funcdef void prethink_f(ASEntity &);
funcdef void postthink_f(ASEntity &);
funcdef void think_f(ASEntity &);
funcdef void touch_f(ASEntity &, ASEntity &, const trace_t &in, bool);
funcdef void use_f(ASEntity &, ASEntity &, ASEntity @);
funcdef void pain_f(ASEntity &, ASEntity &, float kick, int, const mod_t &in);
funcdef void die_f(ASEntity &, ASEntity &, ASEntity &, int, const vec3_t &in, const mod_t &in);

enum plat2flags_t
{
	NONE = 0,
	CALLED = 1,
	MOVING = 2,
	WAITING = 4
};

class fog_t
{
    float density;
    vec3_t rgb;
    float skyfactor;

	bool opEquals(const fog_t &in o) const
	{
		return density == o.density && rgb == o.rgb && skyfactor == o.skyfactor;
	}
}

class height_fog_t
{
	// r g b dist
	vec4_t start;
	vec4_t end;
	float falloff;
	float density;

	bool opEquals(const height_fog_t &in o) const
	{
		return start == o.start && end == o.end && falloff == o.falloff && density == o.density;
	}
}

enum bmodel_animstyle_t
{
	FORWARDS,
	BACKWARDS,
	RANDOM
};

class bmodel_anim_t
{
	// range, inclusive
	int32				start, end;
	bmodel_animstyle_t	style;
	int32				speed; // in milliseconds
	bool				nowrap;

	int32				alt_start, alt_end;
	bmodel_animstyle_t	alt_style;
	int32				alt_speed; // in milliseconds
	bool				alt_nowrap;

	// game-only
	bool				enabled;
	bool				alternate, currently_alternate;
	gtime_t				next_tick;
};

namespace internal
{
    int allow_value_assign = 0;
}

// a special framework type that will throw if
// constructed or value-assign is used without first setting
// the `internal::allow_value_assign` integer.
class no_value_assign
{
    no_value_assign()
    {
        if (internal::allow_value_assign == 0)
            throw("value assign not allowed");
    }

    no_value_assign(const no_value_assign &in)
    {
        if (!internal::allow_value_assign == 0)
            throw("value assign not allowed");
    }

    no_value_assign &opAssign(const no_value_assign &in)
    {
        if (!internal::allow_value_assign == 0)
            throw("value assign not allowed");
        return this;
    }
};
class ASEntity : IASEntity
{
    no_value_assign nva;
    //ASEntity(const ASEntity &inout) delete;
    //ASEntity &opAssign(const ASEntity &inout) delete;

	edict_t @e;

    /*protected edict_t @e_;
    edict_t @e
    {
        get const { return e_; }
    }*/

	edict_t @get_handle() const property override
	{
		return e;
	}

	ASClient @client; // only set for entities 1 to maxclients

	// properties
	ASEntity @owner
	{
		 get { return e.owner is null ? null : entities[e.owner.s.number]; }
         set { @e.owner = value is null ? null : value.e; }
	}

	//================================

	// private to game
	int spawn_count; // [Paril-KEX] used to differentiate different entities that may be in the same slot
	movetype_t	movetype;
	ent_flags_t flags;

	string      model;
	gtime_t		freetime; // sv.time when the object was freed

	//
	// only used locally in game, not by server
	//
	string  message;
	string  classname;
	uint32	spawnflags;

	gtime_t timestamp;

	float		angle; // set in qe3, -1 = up, -2 = down
	string      target;
	string      targetname;
	string      killtarget;
	string      team;
	string      pathtarget;
	string      deathtarget;
	string      healthtarget;
	string      itemtarget; // [Paril-KEX]
	string      combattarget;
	ASEntity    @target_ent;

	float  speed, accel, decel;
	vec3_t movedir;
	vec3_t pos1, pos2, pos3;

	vec3_t	velocity;
	vec3_t	avelocity;
	int32   mass;
	gtime_t air_finished;
	float	gravity = 1.0f; // per entity gravity multiplier (1.0 is normal)
					 // use for lowgrav artifact, flares

	ASEntity @goalentity;
	ASEntity @movetarget;
	float	 yaw_speed;
	float	 ideal_yaw;

	gtime_t nextthink;
	prethink_f @prethink;
	postthink_f @postthink;
	think_f @think;
	touch_f @touch;
	use_f @use;
	pain_f @pain;
	die_f @die;

	gtime_t touch_debounce_time; // are all these legit?  do we need more/less of them?
	gtime_t pain_debounce_time;
	gtime_t damage_debounce_time;
	gtime_t fly_sound_debounce_time; // move to clientinfo
	gtime_t last_move_time;

	int32		health;
	int32		max_health;
	int32		gib_health;
	gtime_t		show_hostile;

	gtime_t powerarmor_time;

	string map; // target_changelevel

	int32   viewheight; // height above origin where eyesight is determined
	bool	deadflag;
	bool	takedamage;
	int32   dmg;
	int32   radius_dmg;
	float	dmg_radius;
	int32   sounds; // make this a spawntemp var?
	int32   count;

	ASEntity @chain;
	ASEntity @enemy;
	ASEntity @oldenemy;
	ASEntity @activator;
	ASEntity @groundentity;
	int32	 groundentity_linkcount;
	ASEntity @teamchain;
	ASEntity @teammaster;

	int32   noise_index;
	int32   noise_index2;
	float	volume;
	float	attenuation;

	// timing variables
	float wait;
	float delay; // before firing targets
	float random;

	gtime_t teleport_time;

	contents_t	  watertype;
	water_level_t waterlevel;

	vec3_t move_origin;
	vec3_t move_angles;

	int32 style; // also used as areaportal number

	const gitem_t @item; // for bonus items

	// common data blocks
	moveinfo_t	  moveinfo;
	monsterinfo_t monsterinfo;

	//=========
	// ROGUE
	plat2flags_t plat2flags;
	vec3_t		 offset;
	vec3_t		 gravityVector = vec3_t(0, 0, -1);
	ASEntity     @bad_area;
	// ROGUE
	//=========

	string clock_message;

	// Paril: we died on this frame, apply knockback even if we're dead
	gtime_t dead_time;
	// used for dabeam monsters
	ASEntity @beam, beam2;
	// proboscus for Parasite
	ASEntity @proboscus;
	// for vooping things
	ASEntity @disintegrator;
	gtime_t disintegrator_time;
	int32 hackflags; // n64

	// fog stuff
	fog_t fog;
	height_fog_t heightfog;
	fog_t fog_off;
	height_fog_t heightfog_off;

	// instanced coop items
	dynamic_bitset  item_picked_up_by;
	gtime_t			slime_debounce_time;

	// [Paril-KEX]
	bmodel_anim_t bmodel_anim;

	mod_t	lastMOD;
	string style_on, style_off;
	uint32 crosslevel_flags;
	gtime_t no_gravity_time;
	float vision_cone; // TODO: migrate vision_cone on old loads to -2.0f
	// NOTE: if adding new elements, make sure to add them
	// in g_save.cpp too!

	// do not call directly; use G_Spawn.
	ASEntity(edict_t @e) explicit
	{
		@this.e = @e;
	}

    // Internal; do not use
    void MarkAsFreed()
    {
		if (e.s.number <= max_clients + BODY_QUEUE_SIZE)
		{
			gi_Com_Print("WARNING: preventing mark free of entity {}\n", e.s.number);
            gi_Com_Print("Backtrace:\n{}\n", backtrace());
			return;
		}

        internal::allow_value_assign++;
		this = ASEntity(e);
        internal::allow_value_assign--;
		this.classname = "freed";
		e.sv.init = false;
    }

	/*
	=================
	Marks the entity as free.
	=================
	*/
	void Free()
	{
        if (e is null)
        {
			gi_Com_Print("WARNING: preventing null free of an entity\n");
            gi_Com_Print("Backtrace:\n{}\n", backtrace());
			return;
        }

        // not linked?
        if (e.linked)
    		gi_unlinkentity(e);

        // no need to free, already freed
        if (!e.inuse)
            return;

		if (e.s.number <= max_clients + BODY_QUEUE_SIZE || !e.inuse)
		{
			gi_Com_Print("WARNING: preventing bad free of entity {}\n", e.s.number);
            gi_Com_Print("Backtrace:\n{}\n", backtrace());
			return;
		}

        gi_Bot_UnRegisterEdict( e );

		e.reset();
		int id = this.spawn_count + 1;
        MarkAsFreed();
		this.spawn_count = id;
		this.freetime = level.time;
	}

	/*
	=================
	Marks the entity as inuse.
	=================
	*/
	void Init()
	{
		e.inuse = true;
		e.sv.init = false;
        classname = "";
        freetime = time_zero;
        @e.as_obj = this;
	}
}

ASEntity @world;
array<ASEntity@> players;
array<ASEntity@> entities;

bool G_EdictExpired(ASEntity &e)
{
	return !e.e.inuse && (((server_flags & server_flags_t::LOADING) != 0) || e.freetime < time_sec(2) || level.time - e.freetime > time_ms(500));
}

void SetupEntityArrays(bool loadgame)
{
	num_edicts = max_clients + 1;
    internal::allow_value_assign++;

    if (!loadgame)
    {
        entities = array<ASEntity@>(max_edicts);

        @world = ASEntity(G_EdictForNum(0));
        @entities[0] = @world;
    
        players = array<ASEntity@>(max_clients);
    }

    for (uint i = 0; i < max_clients; i++)
    {
        ASEntity p(G_EdictForNum(i + 1));
        ASClient @cl;

        if (loadgame)
            @p.client = players[i].client;
        else
            @p.client = ASClient(G_ClientForNum(i));

        @entities[i + 1] = @p;
        @players[i] = p;
    }

    internal::allow_value_assign--;
}

/*
=================
G_Spawn

Either finds a free edict, or allocates a new one.
Try to avoid reusing an entity that was recently freed, because it
can cause the client to think the entity morphed into something else
instead of being removed and recreated, which can cause interpolated
angles and bad trails.
=================
*/
ASEntity @G_Spawn()
{
	ASEntity @e;

	for (uint i = max_clients + 1; i < num_edicts; i++)
	{
        @e = entities[i];

		if (G_EdictExpired(e))
		{
			e.Init();
			return e;
		}
	}

	if (num_edicts == max_edicts)
		gi_Com_Error("ED_Alloc: no free edicts");

    internal::allow_value_assign++;
	@e = ASEntity(G_EdictForNum(num_edicts));
    internal::allow_value_assign--;
	e.Init();
	@entities[e.e.s.number] = @e;
	num_edicts++;
	return e;
}

/*
=================
G_FreeEdict

Marks the edict as free
=================
*/
void G_FreeEdict(ASEntity &e)
{
	e.Free();
}

// formatter support
void formatter(string &str, const string &in args, const ASEntity &in ent)
{
    format_to(str, "{} @ {}", ent.classname, ent.e.origin);
}