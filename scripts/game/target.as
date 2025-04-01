/*QUAKED target_temp_entity (1 0 0) (-8 -8 -8) (8 8 8)
Fire an origin based temp entity event to the clients.
"style"		type byte
*/
void Use_Target_Tent(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(ent.style);
	gi_WritePosition(ent.e.s.origin);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
}

void SP_target_temp_entity(ASEntity &ent)
{
	if (level.is_n64 && ent.style == 27)
		ent.style = temp_event_t::TELEPORT_EFFECT;

	@ent.use = Use_Target_Tent;
}

//==========================================================

//==========================================================

/*QUAKED target_speaker (1 0 0) (-8 -8 -8) (8 8 8) looped-on looped-off reliable
"noise"		wav file to play
"attenuation"
-1 = none, send to whole level
1 = normal fighting sounds
2 = idle sound level
3 = ambient sound level
"volume"	0.0 to 1.0

Normal sounds play each time the target is used.  The reliable flag can be set for crucial voiceovers.

[Paril-KEX] looped sounds are by default atten 3 / vol 1, and the use function toggles it on/off.
*/

namespace spawnflags::speaker
{
    const uint32 LOOPED_ON = 1;
    const uint32 LOOPED_OFF = 2;
    const uint32 RELIABLE = 4;
    const uint32 NO_STEREO = 8;
}

void Use_Target_Speaker(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	soundchan_t chan;

	if ((ent.spawnflags & (spawnflags::speaker::LOOPED_ON | spawnflags::speaker::LOOPED_OFF)) != 0)
	{ // looping sound toggles
		if (ent.e.s.sound != 0)
			ent.e.s.sound = 0; // turn it off
		else
			ent.e.s.sound = ent.noise_index; // start it
	}
	else
	{ // normal sound
		if ((ent.spawnflags & spawnflags::speaker::RELIABLE) != 0)
			chan = soundchan_t(soundchan_t::VOICE | soundchan_t::RELIABLE);
		else
			chan = soundchan_t::VOICE;
		// use a positioned_sound, because this entity won't normally be
		// sent to any clients because it is invisible
		gi_positioned_sound(ent.e.s.origin, ent.e, chan, ent.noise_index, ent.volume, ent.attenuation, 0);
	}
}

void SP_target_speaker(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (st.noise.empty())
	{
		gi_Com_Print("{}: no noise set\n", ent);
		return;
	}

	if (st.noise.findLast(".wav") == -1) // AS_TODO: endsWith?
		ent.noise_index = gi_soundindex(st.noise + ".wav");
	else
		ent.noise_index = gi_soundindex(st.noise);

	if (ent.volume == 0)
		ent.volume = ent.e.s.loop_volume = 1.0;

	if (ent.attenuation == 0)
	{
		if ((ent.spawnflags & (spawnflags::speaker::LOOPED_OFF | spawnflags::speaker::LOOPED_ON)) != 0)
			ent.attenuation = ATTN_STATIC;
		else
			ent.attenuation = ATTN_NORM;
	}
	else if (ent.attenuation == -1) // use -1 so 0 defaults to 1
	{
		if ((ent.spawnflags & (spawnflags::speaker::LOOPED_OFF | spawnflags::speaker::LOOPED_ON)) != 0)
		{
			ent.attenuation = ATTN_LOOP_NONE;
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCULL);
		}
		else
			ent.attenuation = ATTN_NONE;
	}

	ent.e.s.loop_attenuation = ent.attenuation;

	// check for prestarted looping sound
	if ((ent.spawnflags & spawnflags::speaker::LOOPED_ON) != 0)
		ent.e.s.sound = ent.noise_index;

	if ((ent.spawnflags & spawnflags::speaker::NO_STEREO) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::NO_STEREO);

	@ent.use = Use_Target_Speaker;

	// must link the entity so we get areas and clusters so
	// the server can determine who to send updates to
	gi_linkentity(ent.e);
}

//==========================================================

namespace spawnflags::help
{
    const uint32 HELP1 = 1;
    const uint32 SET_POI = 2;
}

void Use_Target_Help(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
    if ((ent.spawnflags & spawnflags::help::HELP1) != 0)
	{
		if (game.helpmessage1 != ent.message)
		{
	        game.helpmessage1 = ent.message;
		    game.help1changed++;
		}
	}
    else
	{
		if (game.helpmessage2 != ent.message)
		{
			game.helpmessage2 = ent.message;
			game.help2changed++;
		}
	}

	if ((ent.spawnflags & spawnflags::help::SET_POI) != 0)
	{
		target_poi_use(ent, other, activator);
	}
}

/*QUAKED target_help (1 0 1) (-16 -16 -24) (16 16 24) help1 setpoi
When fired, the "message" key becomes the current personal computer string, and the message light will be set on all clients status bars.
*/
void SP_target_help(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	if (ent.message.empty())
	{
        gi_Com_Print("{}: no message\n", ent);
		G_FreeEdict(ent);
		return;
	}

	@ent.use = Use_Target_Help;

	if ((ent.spawnflags & spawnflags::help::SET_POI) != 0)
	{
		if (!st.image.empty())
			ent.noise_index = gi_imageindex(st.image);
		else
			ent.noise_index = gi_imageindex("friend");
	}
}

//==========================================================

/*QUAKED target_secret (1 0 1) (-8 -8 -8) (8 8 8)
Counts a secret found.
These are single use targets.
*/
void use_target_secret(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	gi_sound(ent.e, soundchan_t::VOICE, ent.noise_index, 1, ATTN_NORM, 0);

	level.found_secrets++;

	G_UseTargets(ent, activator);
	G_FreeEdict(ent);
}

void G_VerifyTargetted(ASEntity &ent)
{
	if (ent.targetname.empty())
		gi_Com_Print("WARNING: missing targetname on {}\n", ent);
    // AS_TODO: this doesn't check other fields
	//else if (G_FindByStringTarget(null, ent.targetname) is null)
	//	gi_Com_Print("WARNING: doesn't appear to be anything targeting {}\n", ent);
}

void SP_target_secret(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	@ent.think = G_VerifyTargetted;
	ent.nextthink = level.time + time_ms(10);

	@ent.use = use_target_secret;
	if (st.noise.empty())
		ent.noise_index = gi_soundindex("misc/secret.wav");
	else
		ent.noise_index = gi_soundindex(st.noise);
	ent.e.svflags = svflags_t::NOCLIENT;
	level.total_secrets++;
}


//==========================================================
// [Paril-KEX] notify this player of a goal change
void G_PlayerNotifyGoal(ASEntity &player)
{
	// no goals in DM
	if (deathmatch.integer != 0)
		return;

	if (!player.client.pers.spawned)
		return;
	else if ((level.time - player.client.resp.entertime) < time_ms(300))
		return;

	// N64 goals
    if (!level.goals.empty())
	{
		// if the goal has updated, commit it first
		if (game.help1changed != game.help2changed)
		{
            int goal_start = 0;

			// skip ahead by the number of goals we've finished
			for (int i = 0; i < level.goal_num; i++)
			{
                goal_start = level.goals.findFirstOf("\t", goal_start + 1);

                if (goal_start == -1)
					gi_Com_Error("invalid n64 goals\n");
			}

			// find the end of this goal
            int goal_end = level.goals.findFirstOf("\t", goal_start + 1);
            game.helpmessage1 = level.goals.substr(uint(goal_start + 1), goal_end != -1 ? goal_end - 1 : -1);

			game.help2changed = game.help1changed;
		}
		
		if (player.client.pers.game_help1changed != game.help1changed)
		{
			gi_LocClient_Print(player.e, print_type_t::TYPEWRITER, game.helpmessage1);
			gi_local_sound(player.e, player.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("misc/talk.wav"), 1.0f, ATTN_NONE, 0.0f, GetUnicastKey());

			player.client.pers.game_help1changed = game.help1changed;
		}

		// no regular goals
		return;
	}

	if (player.client.pers.game_help1changed != game.help1changed)
	{
		player.client.pers.game_help1changed = game.help1changed;
		player.client.pers.helpchanged = 1;
		player.client.pers.help_time = level.time + time_sec(5);

		if (!game.helpmessage1.empty())
			// [Sam-KEX] Print objective to screen
			gi_LocClient_Print(player.e, print_type_t::TYPEWRITER, level.primary_objective_string, game.helpmessage1);
	}
	
	if (player.client.pers.game_help2changed != game.help2changed)
	{
		player.client.pers.game_help2changed = game.help2changed;
		player.client.pers.helpchanged = 1;
		player.client.pers.help_time = level.time + time_sec(5);

		if (!game.helpmessage2.empty())
			// [Sam-KEX] Print objective to screen
			gi_LocClient_Print(player.e, print_type_t::TYPEWRITER, level.secondary_objective_string, game.helpmessage2);
	}
}

/*QUAKED target_goal (1 0 1) (-8 -8 -8) (8 8 8) KEEP_MUSIC
Counts a goal completed.
These are single use targets.
*/

namespace spawnflags::goal
{
    const uint32 KEEP_MUSIC = 1;
}

void use_target_goal(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	gi_sound(ent.e, soundchan_t::VOICE, ent.noise_index, 1, ATTN_NORM, 0);

	level.found_goals++;

	if (level.found_goals == level.total_goals && (ent.spawnflags & spawnflags::goal::KEEP_MUSIC) == 0)
	{
		if (ent.sounds != 0)
			gi_configstring(configstring_id_t::CDTRACK, format("{}", ent.sounds));
		else
			gi_configstring(configstring_id_t::CDTRACK, "0");
	}

	// [Paril-KEX] n64 goals
	if (!level.goals.empty())
	{
		level.goal_num++;
		game.help1changed++;

        foreach (ASEntity @player : active_players)
		    G_PlayerNotifyGoal(player);
	}

	G_UseTargets(ent, activator);
	G_FreeEdict(ent);
}

void SP_target_goal(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	@ent.use = use_target_goal;
	if (st.noise.empty())
		ent.noise_index = gi_soundindex("misc/secret.wav");
	else
		ent.noise_index = gi_soundindex(st.noise);
	ent.e.svflags = svflags_t::NOCLIENT;
	level.total_goals++;
}

//==========================================================

/*QUAKED target_explosion (1 0 0) (-8 -8 -8) (8 8 8)
Spawns an explosion temporary entity when used.

"delay"		wait this long before going off
"dmg"		how much radius damage should be done, defaults to 0
*/
void target_explosion_explode(ASEntity &self)
{
	float save;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	T_RadiusDamage(self, self.activator, float(self.dmg), null, float(self.dmg + 40), damageflags_t::NONE, mod_id_t::EXPLOSIVE);

	save = self.delay;
	self.delay = 0;
	G_UseTargets(self, self.activator);
	self.delay = save;
}

void use_target_explosion(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;

	if (self.delay == 0)
	{
		target_explosion_explode(self);
		return;
	}

	@self.think = target_explosion_explode;
	self.nextthink = level.time + time_sec(self.delay);
}

void SP_target_explosion(ASEntity &ent)
{
	@ent.use = use_target_explosion;
	ent.e.svflags = svflags_t::NOCLIENT;
}

//==========================================================

/*QUAKED target_changelevel (1 0 0) (-8 -8 -8) (8 8 8) END_OF_UNIT UNKNOWN UNKNOWN CLEAR_INVENTORY NO_END_OF_UNIT FADE_OUT IMMEDIATE_LEAVE
Changes level to "map" when fired
*/

namespace spawnflags::changelevel
{
    const uint32 CLEAR_INVENTORY = 8;
    const uint32 NO_END_OF_UNIT = 16;
    const uint32 FADE_OUT = 32;
    const uint32 IMMEDIATE_LEAVE = 64;
}

void use_target_changelevel(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (level.intermissiontime)
		return; // already activated

	if (deathmatch.integer == 0 && coop.integer == 0)
	{
		if (players[0].health <= 0)
			return;
	}

	// if noexit, do a ton of damage to other
	if (deathmatch.integer != 0 && g_dm_allow_exit.integer == 0 && other !is world)
	{
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 10 * other.max_health, 1000, damageflags_t::NONE, mod_id_t::EXIT);
		return;
	}

	// if multiplayer, let everyone know who hit the exit
	if (deathmatch.integer != 0)
	{
		if (level.time < time_sec(10))
			return;

		if (activator !is null && activator.client !is null)
			gi_LocBroadcast_Print(print_type_t::HIGH, "$g_exited_level", activator.client.pers.netname);
	}

	// if going to a new unit, clear cross triggers
	if (self.map.findFirstOf("*") != -1)
		game.cross_level_flags &= ~(SFL_CROSS_TRIGGER_MASK);

	// if map has a landmark, store position instead of using spawn next map
	if (activator !is null && activator.client !is null && deathmatch.integer == 0)
	{
		activator.client.landmark_name = "";
		activator.client.landmark_rel_pos = vec3_origin;

		@self.target_ent = G_PickTarget(self.target);

		if (self.target_ent !is null)
		{
			activator.client.landmark_name = self.target_ent.targetname;

			// get relative vector to landmark pos, and unrotate by the landmark angles in preparation to be
			// rotated by the next map
			activator.client.landmark_rel_pos = activator.e.s.origin - self.target_ent.e.s.origin;

			activator.client.landmark_rel_pos = RotatePointAroundVector({ 1, 0, 0 }, activator.client.landmark_rel_pos, -self.target_ent.e.s.angles.x);
			activator.client.landmark_rel_pos = RotatePointAroundVector({ 0, 1, 0 }, activator.client.landmark_rel_pos, -self.target_ent.e.s.angles.z);
			activator.client.landmark_rel_pos = RotatePointAroundVector({ 0, 0, 1 }, activator.client.landmark_rel_pos, -self.target_ent.e.s.angles.y);

			activator.client.oldvelocity = RotatePointAroundVector({ 1, 0, 0 }, activator.client.oldvelocity, -self.target_ent.e.s.angles.x);
			activator.client.oldvelocity = RotatePointAroundVector({ 0, 1, 0 }, activator.client.oldvelocity, -self.target_ent.e.s.angles.z);
			activator.client.oldvelocity = RotatePointAroundVector({ 0, 0, 1 }, activator.client.oldvelocity, -self.target_ent.e.s.angles.y);

			// unrotate our view angles for the next map too
			activator.client.oldviewangles = activator.e.client.ps.viewangles - self.target_ent.e.s.angles;
		}
	}

	BeginIntermission(self);
}

void SP_target_changelevel(ASEntity &ent)
{
	if (ent.map.empty())
	{
		gi_Com_Print("{}: no map\n", ent);
		G_FreeEdict(ent);
		return;
	}

	@ent.use = use_target_changelevel;
	ent.e.svflags = svflags_t::NOCLIENT;
}

//==========================================================

/*QUAKED target_splash (1 0 0) (-8 -8 -8) (8 8 8)
Creates a particle splash effect when used.

Set "sounds" to one of the following:
  1) sparks
  2) blue water
  3) brown water
  4) slime
  5) lava
  6) blood

"count"	how many pixels in the splash
"dmg"	if set, does a radius damage at this location when it splashes
		useful for lava/sparks
*/

void use_target_splash(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::SPLASH);
	gi_WriteByte(self.count);
	gi_WritePosition(self.e.s.origin);
	gi_WriteDir(self.movedir);
	gi_WriteByte(self.sounds);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	if (self.dmg != 0)
		T_RadiusDamage(self, activator, float(self.dmg), null, float(self.dmg + 40), damageflags_t::NONE, mod_id_t::SPLASH);
}

void SP_target_splash(ASEntity &self)
{
	@self.use = use_target_splash;
	G_SetMovedir(self, self.movedir);

	if (self.count == 0)
		self.count = 32;

	// N64 "sparks" are blue, not yellow.
	if (level.is_n64 && self.sounds == 1)
		self.sounds = 7;

	self.e.svflags = svflags_t::NOCLIENT;
}

//==========================================================

/*QUAKED target_spawner (1 0 0) (-8 -8 -8) (8 8 8)
Set target to the type of entity you want spawned.
Useful for spawning monsters and gibs in the factory levels.

For monsters:
	Set direction to the facing you want it to have.

For gibs:
	Set direction if you want it moving and
	speed how fast it should be moving otherwise it
	will just be dropped
*/

void use_target_spawner(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @ent = G_Spawn();
	ent.classname = self.target;
	// RAFAEL
	ent.flags = self.flags;
	// RAFAEL
	ent.e.s.origin = self.e.s.origin;
	ent.e.s.angles = self.e.s.angles;

	// [Paril-KEX] although I fixed these in our maps, this is just
	// in case anybody else does this by accident. Don't count these monsters
	// so they don't inflate the monster count.
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

	ED_CallSpawn(ent);
	gi_linkentity(ent.e);

	if (ent.e.solid == solid_t::BBOX || (G_GetClipMask(ent) & (contents_t::PLAYER)) != 0)
		KillBox(ent, false);

	if (self.speed != 0)
		ent.velocity = self.movedir;

	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::IR_VISIBLE); // PGM
}

void SP_target_spawner(ASEntity &self)
{
	@self.use = use_target_spawner;
	self.e.svflags = svflags_t::NOCLIENT;
	if (self.speed != 0)
	{
		G_SetMovedir(self, self.movedir);
		self.movedir *= self.speed;
	}
}

//==========================================================

/*QUAKED target_blaster (1 0 0) (-8 -8 -8) (8 8 8) NOTRAIL NOEFFECTS
Fires a blaster bolt in the set direction when triggered.

dmg		default is 15
speed	default is 1000
*/

namespace spawnflags::blaster
{
    const uint32 NOTRAIL = 1;
    const uint32 NOEFFECTS = 2;
}

void use_target_blaster(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	effects_t effect;

	if ((self.spawnflags & spawnflags::blaster::NOEFFECTS) != 0)
		effect = effects_t::NONE;
	else if ((self.spawnflags & spawnflags::blaster::NOTRAIL) != 0)
		effect = effects_t::HYPERBLASTER;
	else
		effect = effects_t::BLASTER;

	fire_blaster(self, self.e.s.origin, self.movedir, self.dmg, int(self.speed), effect, mod_id_t::TARGET_BLASTER);
	gi_sound(self.e, soundchan_t::VOICE, self.noise_index, 1, ATTN_NORM, 0);
}

void SP_target_blaster(ASEntity &self)
{
	@self.use = use_target_blaster;
	G_SetMovedir(self, self.movedir);
	self.noise_index = gi_soundindex("weapons/laser2.wav");

	if (self.dmg == 0)
		self.dmg = 15;
	if (self.speed == 0)
		self.speed = 1000;

	self.e.svflags = svflags_t::NOCLIENT;
}

//==========================================================

/*QUAKED target_crosslevel_trigger (.5 .5 .5) (-8 -8 -8) (8 8 8) trigger1 trigger2 trigger3 trigger4 trigger5 trigger6 trigger7 trigger8
Once this trigger is touched/used, any trigger_crosslevel_target with the same trigger number is automatically used when a level is started within the same unit.  It is OK to check multiple triggers.  Message, delay, target, and killtarget also work.
*/
void trigger_crosslevel_trigger_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	game.cross_level_flags |= uint(self.spawnflags);
	G_FreeEdict(self);
}

void SP_target_crosslevel_trigger(ASEntity &self)
{
	self.e.svflags = svflags_t::NOCLIENT;
	@self.use = trigger_crosslevel_trigger_use;
}

/*QUAKED target_crosslevel_target (.5 .5 .5) (-8 -8 -8) (8 8 8) trigger1 trigger2 trigger3 trigger4 trigger5 trigger6 trigger7 trigger8 - - - - - - - - trigger9 trigger10 trigger11 trigger12 trigger13 trigger14 trigger15 trigger16
Triggered by a trigger_crosslevel elsewhere within a unit.  If multiple triggers are checked, all must be true.  Delay, target and
killtarget also work.

"delay"		delay before using targets if the trigger has been activated (default 1)
*/
void target_crosslevel_target_think(ASEntity &self)
{
	if (uint(self.spawnflags) == (game.cross_level_flags & SFL_CROSS_TRIGGER_MASK & uint(self.spawnflags)))
	{
		G_UseTargets(self, self);
		G_FreeEdict(self);
	}
}

void SP_target_crosslevel_target(ASEntity &self)
{
	if (self.delay == 0)
		self.delay = 1;
	self.e.svflags = svflags_t::NOCLIENT;

	@self.think = target_crosslevel_target_think;
	self.nextthink = level.time + time_sec(self.delay);
}

//==========================================================

/*QUAKED target_laser (0 .5 .8) (-8 -8 -8) (8 8 8) START_ON RED GREEN BLUE YELLOW ORANGE FAT WINDOWSTOP
When triggered, fires a laser.  You can either set a target or a direction.

WINDOWSTOP - stops at CONTENTS_WINDOW
*/

//======
// PGM
namespace spawnflags::laser
{
    const uint32 ON = 0x0001;
    const uint32 RED = 0x0002;
    const uint32 GREEN = 0x0004;
    const uint32 BLUE = 0x0008;
    const uint32 YELLOW = 0x0010;
    const uint32 ORANGE = 0x0020;
    const uint32 FAT = 0x0040;
    const uint32 STOPWINDOW = 0x0080;
    const uint32 ZAP = 0x80000000;
    const uint32 LIGHTNING = 0x10000;
    const uint32 REACTOR = 0x20000; // PSX reactor effect instead of beam
    const uint32 NO_PROTECTION = 0x40000; // no protection
}
// PGM
//======

class laser_pierce_t : pierce_args_t
{
	ASEntity @self;
	int32 count;
	bool damaged_thing = false;

	laser_pierce_t(ASEntity @self, int32 count)
	{
        super();
        @this.self = self;
        this.count = count;
	}

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
	bool hit(contents_t &mask, vec3_t &end) override
	{
        ASEntity @hit = entities[tr.ent.s.number];

		// hurt it if we can
		if (self.dmg > 0 && (hit.takedamage) && (hit.flags & ent_flags_t::IMMUNE_LASER) == 0 && self.damage_debounce_time <= level.time)
		{
			damaged_thing = true;
			damageflags_t dmg = damageflags_t::ENERGY;

			if ((self.spawnflags & spawnflags::laser::NO_PROTECTION) != 0)
				dmg = damageflags_t(dmg | damageflags_t::NO_PROTECTION);

			T_Damage(hit, self, self.activator, self.movedir, tr.endpos, vec3_origin, self.dmg, 1, dmg, mod_id_t::TARGET_LASER);
		}

		// if we hit something that's not a monster or player or is immune to lasers, we're done
		// ROGUE
		if ((tr.ent.svflags & svflags_t::MONSTER) == 0 && (tr.ent.client is null) && (hit.flags & ent_flags_t::DAMAGEABLE) == 0)
		// ROGUE
		{
			if ((self.spawnflags & spawnflags::laser::ZAP) != 0)
			{
				self.spawnflags &= ~spawnflags::laser::ZAP;
				gi_WriteByte(svc_t::temp_entity);
				gi_WriteByte(temp_event_t::LASER_SPARKS);
				gi_WriteByte(count);
				gi_WritePosition(tr.endpos);
				gi_WriteDir(tr.plane.normal);
				gi_WriteByte(self.e.s.skinnum);
				gi_multicast(tr.endpos, multicast_t::PVS, false);
			}
			
			return false;
		}

		if (!mark(hit))
			return false;

		return true;
	}
};

void target_laser_think(ASEntity &self)
{
	int32 count;

	if ((self.spawnflags & spawnflags::laser::ZAP) != 0)
		count = 8;
	else
		count = 4;
	
	if (self.enemy !is null)
	{
		vec3_t last_movedir = self.movedir;
		vec3_t point = (self.enemy.e.absmin + self.enemy.e.absmax) * 0.5f;
		self.movedir = point - self.e.s.origin;
		self.movedir.normalize();
		if (self.movedir != last_movedir)
			self.spawnflags |= spawnflags::laser::ZAP;
	}

	vec3_t start = self.e.s.origin;
	vec3_t end = start + (self.movedir * 2048);
	
	laser_pierce_t args(
		self,
		count
    );

	contents_t mask = (self.spawnflags & spawnflags::laser::STOPWINDOW) != 0 ? contents_t::MASK_SHOT : contents_t(contents_t::SOLID | contents_t::MONSTER | contents_t::PLAYER | contents_t::DEADMONSTER);

	if (self.dmg == 0)
		mask = contents_t(mask & ~(contents_t::MONSTER | contents_t::PLAYER | contents_t::DEADMONSTER));

	pierce_trace(start, end, self, args, mask);

	self.e.s.old_origin = args.tr.endpos;

	if (args.damaged_thing)
		self.damage_debounce_time = level.time + time_hz(10);

	self.nextthink = level.time + FRAME_TIME_S;
	gi_linkentity(self.e);
}

void target_laser_on(ASEntity &self)
{
	if (self.activator is null)
		@self.activator = self;
	self.spawnflags |= spawnflags::laser::ZAP | spawnflags::laser::ON;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	self.flags = ent_flags_t(self.flags | ent_flags_t::TRAP);
	target_laser_think(self);
}

void target_laser_off(ASEntity &self)
{
	self.spawnflags &= ~spawnflags::laser::ON;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.flags = ent_flags_t(self.flags & ~ent_flags_t::TRAP);
	self.nextthink = time_zero;
}

void target_laser_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;
	if ((self.spawnflags & spawnflags::laser::ON) != 0)
		target_laser_off(self);
	else
		target_laser_on(self);
}

void target_laser_start(ASEntity &self)
{
	ASEntity @ent;

	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::NOT;
	self.e.s.renderfx = renderfx_t(self.e.s.renderfx | renderfx_t::BEAM);
	self.e.s.modelindex = MODELINDEX_WORLD; // must be non-zero

	// [Sam-KEX] On Q2N64, spawnflag of 128 turns it into a lightning bolt
	if (level.is_n64)
	{
		// Paril: fix for N64
		if ((self.spawnflags & spawnflags::laser::STOPWINDOW) != 0)
		{
			self.spawnflags &= ~spawnflags::laser::STOPWINDOW;
			self.spawnflags |= spawnflags::laser::LIGHTNING;
		}
	}

	// set the color
	// [Paril-KEX] moved it here so that color takes place
	// before lightning/reactor check
	if (self.e.s.skinnum == 0)
	{
		if ((self.spawnflags & spawnflags::laser::RED) != 0)
			self.e.s.skinnum = int(0xf2f2f0f0);
		else if ((self.spawnflags & spawnflags::laser::GREEN) != 0)
			self.e.s.skinnum = int(0xd0d1d2d3);
		else if ((self.spawnflags & spawnflags::laser::BLUE) != 0)
			self.e.s.skinnum = int(0xf3f3f1f1);
		else if ((self.spawnflags & spawnflags::laser::YELLOW) != 0)
			self.e.s.skinnum = int(0xdcdddedf);
		else if ((self.spawnflags & spawnflags::laser::ORANGE) != 0)
			self.e.s.skinnum = int(0xe0e1e2e3);
	}

	if ((self.spawnflags & spawnflags::laser::REACTOR) != 0)
		self.spawnflags |= spawnflags::laser::LIGHTNING;

	if ((self.spawnflags & spawnflags::laser::LIGHTNING) != 0)
	{
		self.e.s.renderfx = renderfx_t(self.e.s.renderfx | renderfx_t::BEAM_LIGHTNING); // tell renderer it is lightning

		if (self.e.s.skinnum == 0)
			self.e.s.skinnum = int(0xf3f3f1f1); // default lightning color
	}
	/*
	else if ((self.spawnflags & spawnflags::laser::REACTOR) != 0)
	{
		self.s.renderfx |= RF_BEAM_REACTOR;

		if (!self.s.skinnum)
			self.s.skinnum = 0xf3f3f1f1; // default reactor color
	}
	*/

	if (self.enemy is null)
	{
		if (!self.target.empty())
		{
			@ent = find_by_str<ASEntity>(null, "targetname", self.target);
			if (ent is null)
				gi_Com_Print("{}: {} is a bad target\n", self, self.target);
			else
			{
				@self.enemy = ent;

				// N64 fix
				// FIXME: which map was this for again? oops
				if (level.is_n64 && self.enemy.classname == "func_train" && (self.enemy.spawnflags & spawnflags::train::START_ON) == 0)
					self.enemy.use(self.enemy, self, self);
			}
		}
		else
		{
			G_SetMovedir(self, self.movedir);
		}
	}
	@self.use = target_laser_use;
	@self.think = target_laser_think;

	self.e.mins = { -8, -8, -8 };
	self.e.maxs = { 8, 8, 8 };
	gi_linkentity(self.e);

	if ((self.spawnflags & spawnflags::laser::ON) != 0)
		target_laser_on(self);
	else
		target_laser_off(self);
}

void SP_target_laser(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	// set the beam diameter
	// [Paril-KEX] lab has this set prob before lightning was implemented
	// [Paril-KEX] moved this here because st
	if (!st.was_key_specified("frame"))
	{
		if (!level.is_n64 && (self.spawnflags & spawnflags::laser::FAT) != 0)
			self.e.s.frame = 16;
		else
			self.e.s.frame = 4;
	}

	// [Paril-KEX] upper 2 bytes of reactor laser are count
	/*
	if ((self.spawnflags & spawnflags::laser::REACTOR) != 0)
	{
		self.s.frame &= 0xFFFF;

		self.s.frame |= (self.count << 16) & 0xFFFF0000;
	}
	*/

	// [Paril-KEX] moved this here because st
	if (!st.was_key_specified("dmg"))
		self.dmg = 1;

	// let everything else get spawned before we start firing
	@self.think = target_laser_start;
	self.flags = ent_flags_t(self.flags | ent_flags_t::TRAP_LASER_FIELD);
	self.nextthink = level.time + time_sec(1);
}

//==========================================================

/*QUAKED target_lightramp (0 .5 .8) (-8 -8 -8) (8 8 8) TOGGLE
speed		How many seconds the ramping will take
message		two letters; starting lightlevel and ending lightlevel
*/

namespace spawnflags::lightramp
{
    const uint32 TOGGLE = 1;
}

void target_lightramp_think(ASEntity &self)
{
	string style;

	style.appendChar('a' + int(self.movedir[0] + ((level.time - self.timestamp) / gi_frame_time_s).secondsf() * self.movedir[2]));

	gi_configstring(configstring_id_t(configstring_id_t::LIGHTS + self.enemy.style), style);

	if ((level.time - self.timestamp).secondsf() < self.speed)
	{
		self.nextthink = level.time + FRAME_TIME_S;
	}
	else if ((self.spawnflags & spawnflags::lightramp::TOGGLE) != 0)
	{
		uint8 temp = uint8(self.movedir[0]);
		self.movedir[0] = self.movedir[1];
		self.movedir[1] = temp;
		self.movedir[2] *= -1;
	}
}

void target_lightramp_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.enemy is null)
	{
		ASEntity @e;

		// check all the targets
		@e = null;
		while (true)
		{
			@e = find_by_str<ASEntity>(e, "targetname", self.target);
			if (e is null)
				break;
			if (e.classname != "light")
			{
				gi_Com_Print("{}: target {} ({}) is not a light\n", self, self.target, e);
			}
			else
			{
				@self.enemy = e;
			}
		}

		if (self.enemy is null)
		{
			gi_Com_Print("{}: target {} not found\n", self, self.target);
			G_FreeEdict(self);
			return;
		}
	}

	self.timestamp = level.time;
	target_lightramp_think(self);
}

void SP_target_lightramp(ASEntity &self)
{
	if (self.message.length() != 2 ||
        self.message[0] < 'a' || self.message[0] > 'z' ||
        self.message[1] < 'a' || self.message[1] > 'z' ||
        self.message[0] == self.message[1])
	{
		gi_Com_Print("{}: bad ramp ({})\n", self, self.message);
		G_FreeEdict(self);
		return;
	}

	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.target.empty())
	{
		gi_Com_Print("{}: no target\n", self);
		G_FreeEdict(self);
		return;
	}

    if (self.speed == 0)
        self.speed = 1;

	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.use = target_lightramp_use;
	@self.think = target_lightramp_think;

	self.movedir.x = float(self.message[0] - 'a');
	self.movedir.y = float(self.message[1] - 'a');
	self.movedir.z = (self.movedir.y - self.movedir.x) / (self.speed / gi_frame_time_s);
}

//==========================================================

/*QUAKED target_earthquake (1 0 0) (-8 -8 -8) (8 8 8) SILENT TOGGLE UNKNOWN_ROGUE ONE_SHOT
When triggered, this initiates a level-wide earthquake.
All players are affected with a screen shake.
"speed"		severity of the quake (default:200)
"count"		duration of the quake (default:5)
*/

namespace spawnflags::earthquake
{
    const uint32 SILENT = 1;
    const uint32 TOGGLE = 2;
    const uint32 UNKNOWN_ROGUE = 4;
    const uint32 ONE_SHOT = 8;
}

void target_earthquake_think(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::earthquake::SILENT) == 0) // PGM
	{														// PGM
		if (self.last_move_time < level.time)
		{
			gi_positioned_sound(self.e.s.origin, self.e, soundchan_t::VOICE, self.noise_index, 1.0, ATTN_NONE, 0);
			self.last_move_time = level.time + time_sec(6.5);
		}
	} // PGM

	for (uint i = 0; i < players.length(); i++)
	{
        ASEntity @e = players[i];

		if (!e.e.inuse)
			continue;
		if (e.client is null)
			break;

		e.client.quake_time = level.time + time_ms(1000);
	}

	if (level.time < self.timestamp)
		self.nextthink = level.time + time_hz(10);
}

void target_earthquake_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if ((self.spawnflags & spawnflags::earthquake::ONE_SHOT) != 0)
	{
        for (uint i = 0; i < players.length(); i++)
        {
            ASEntity @e = players[i];

            if (!e.e.inuse)
                continue;
            if (e.client is null)
                break;

			e.client.v_dmg_pitch = -self.speed * 0.1f;
			e.client.v_dmg_time = level.time + DAMAGE_TIME;
		}

		return;
	}

	self.timestamp = level.time + time_sec(self.count);

	if ((self.spawnflags & spawnflags::earthquake::TOGGLE) != 0)
	{
		if (self.style != 0)
			self.nextthink = time_zero;
		else
			self.nextthink = level.time + FRAME_TIME_S;

		self.style ^= 1;
	}
	else
	{
		self.nextthink = level.time + FRAME_TIME_S;
		self.last_move_time = time_zero;
	}

	@self.activator = activator;
}

void SP_target_earthquake(ASEntity &self)
{
	if (self.targetname.empty())
		gi_Com_Print("{}: untargeted\n", self);

	if (level.is_n64)
	{
		self.spawnflags |= spawnflags::earthquake::TOGGLE;
		self.speed = 5;
	}
	
	if (self.count == 0)
		self.count = 5;

	if (self.speed == 0)
		self.speed = 200;

	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.think = target_earthquake_think;
	@self.use = target_earthquake_use;

	if ((self.spawnflags & spawnflags::earthquake::SILENT) == 0) // PGM
		self.noise_index = gi_soundindex("world/quake.wav");
}

/*QUAKED target_camera (1 0 0) (-8 -8 -8) (8 8 8)
[Sam-KEX] Creates a camera path as seen in the N64 version.
*/

const uint HACKFLAG_TELEPORT_OUT = 2;
const uint HACKFLAG_SKIPPABLE = 64;
const uint HACKFLAG_END_OF_UNIT = 128;

void camera_lookat_pathtarget(ASEntity &self, const vec3_t &in origin, vec3_t &out dest)
{
    dest = vec3_origin;

    if(!self.pathtarget.empty())
    {
        ASEntity @pt = null;
        @pt = find_by_str<ASEntity>(pt, "targetname", self.pathtarget);
        if(pt !is null)
        {
            float yaw, pitch;
            vec3_t delta = pt.e.s.origin - origin;

            float d = delta.x * delta.x + delta.y * delta.y;
            if(d == 0.0f)
            {
                yaw = 0.0f;
                pitch = (delta[2] > 0.0f) ? 90.0f : -90.0f;
            }
            else
            {
                yaw = atan2(delta.y, delta[0]) * (180.0f / PIf);
                pitch = atan2(delta.z, sqrt(d)) * (180.0f / PIf);
            }

            dest.y = yaw;
            dest.x = -pitch;
            dest.z = 0;
        }
    }
}

void update_target_camera(ASEntity &self)
{
	bool do_skip = false;

	// only allow skipping after 2 seconds
	if ((self.hackflags & HACKFLAG_SKIPPABLE) != 0 && level.time > time_sec(2))
	{
        for (uint32 i = 0; i < max_clients; i++)
        {
            ASEntity @client = players[i];
            if (!client.e.inuse || !client.client.pers.connected)
                continue;

			if ((client.client.buttons & button_t::ANY) != 0)
			{
				do_skip = true;
				break;
			}
		}
	}

	if (!do_skip && self.movetarget !is null)
    {
		self.moveinfo.remaining_distance -= (self.moveinfo.move_speed * gi_frame_time_s) * 0.8f;

		if(self.moveinfo.remaining_distance <= 0)
        {
			if ((self.movetarget.hackflags & HACKFLAG_TELEPORT_OUT) != 0)
			{
				if (self.enemy !is null)
				{
					self.enemy.e.s.event = entity_event_t::PLAYER_TELEPORT;
					self.enemy.hackflags = HACKFLAG_TELEPORT_OUT;
					self.enemy.pain_debounce_time = self.enemy.timestamp = time_sec(self.movetarget.wait);
				}
			}

            self.e.s.origin = self.movetarget.e.s.origin;
            self.nextthink = level.time + time_sec(self.movetarget.wait);
			if (!self.movetarget.target.empty())
			{
				@self.movetarget = G_PickTarget(self.movetarget.target);

				if (self.movetarget !is null)
				{
					self.moveinfo.move_speed = self.movetarget.speed != 0 ? self.movetarget.speed : 55;
					self.moveinfo.remaining_distance = (self.movetarget.e.s.origin - self.e.s.origin).normalize();
					self.moveinfo.distance = self.moveinfo.remaining_distance;
				}
			}
			else
				@self.movetarget = null;

            return;
        }
        else
        {
            float frac = 1.0f - (self.moveinfo.remaining_distance / self.moveinfo.distance);

			if (self.enemy !is null && (self.enemy.hackflags & HACKFLAG_TELEPORT_OUT) != 0)
				self.enemy.e.s.alpha = max(1.0f / 255.0f, frac);

            vec3_t delta = self.movetarget.e.s.origin - self.e.s.origin;
            delta *= frac;
            vec3_t newpos = self.e.s.origin + delta;

            camera_lookat_pathtarget(self, newpos, level.intermission_angle);
			level.intermission_origin = newpos;

            // move all clients to the intermission point
            for (uint32 i = 0; i < max_clients; i++)
            {
                ASEntity @client = players[i];
                if (!client.e.inuse)
                {
                    continue;
                }

                MoveClientToIntermission(client);
            }
        }
    }
    else
    {
		if (!self.killtarget.empty())
        {
			// destroy dummy player
			if (self.enemy !is null)
				G_FreeEdict(self.enemy);

            ASEntity @t = null;
            level.intermissiontime = time_zero;
			level.level_intermission_set = true;

			while ((@t = find_by_str<ASEntity>(t, "targetname", self.killtarget)) !is null)
            {
                t.use(t, self, self.activator);
            }

            level.intermissiontime = level.time;
			level.intermission_server_frame = gi_ServerFrame();

			// end of unit requires a wait
			if (!level.changemap.empty() && level.changemap.findFirstOf("*") != -1)
				level.exitintermission = true;
        }

        @self.think = null;
        return;
    }
    
    self.nextthink = level.time + FRAME_TIME_S;
}

void target_camera_dummy_think(ASEntity &self)
{
	// bit of a hack, but this will let the dummy
	// move like a player
	@self.client = self.owner.client;
    @self.e.client = self.owner.e.client;

	step_parameters_t step();
	step.xyspeed = sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y);
	G_SetClientFrame(self, step);

	@self.client = null;
    @self.e.client = null;

	// alpha fade out for voops
	if ((self.hackflags & HACKFLAG_TELEPORT_OUT) != 0)
	{
		self.timestamp = max(time_zero, (self.timestamp - time_hz(10)));
		self.e.s.alpha = max(1.0f / 255.0f, (self.timestamp.secondsf() / self.pain_debounce_time.secondsf()));
	}

	self.nextthink = level.time + time_hz(10);
}

void use_target_camera(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.sounds != 0)
		gi_configstring (configstring_id_t::CDTRACK, format("{}", self.sounds) );

	if (self.target.empty())
		return;

    @self.movetarget = G_PickTarget(self.target);

    if (self.movetarget is null)
        return;

    level.intermissiontime = level.time;
	level.intermission_server_frame = gi_ServerFrame();
    level.exitintermission = false;
    
	// spawn fake player dummy where we were
	if (activator.client !is null)
	{
		ASEntity @dummy = @self.enemy = G_Spawn();
		@dummy.owner = activator;
		dummy.e.clipmask = activator.e.clipmask;
		dummy.e.s.origin = activator.e.s.origin;
		dummy.e.s.angles = activator.e.s.angles;
		@dummy.groundentity = activator.groundentity;
		dummy.groundentity_linkcount = dummy.groundentity !is null ? dummy.groundentity.e.linkcount : 0;
		@dummy.think = target_camera_dummy_think;
		dummy.nextthink = level.time + time_hz(10);
		dummy.e.solid = solid_t::BBOX;
		dummy.movetype = movetype_t::STEP;
		dummy.e.mins = activator.e.mins;
		dummy.e.maxs = activator.e.maxs;
		dummy.e.s.modelindex = dummy.e.s.modelindex2 = MODELINDEX_PLAYER;
		dummy.e.s.skinnum = activator.e.s.skinnum;
		dummy.velocity = activator.velocity;
		dummy.e.s.renderfx = renderfx_t::MINLIGHT;
		dummy.e.s.frame = activator.e.s.frame;
		gi_linkentity(dummy.e);
	}

    camera_lookat_pathtarget(self, self.e.s.origin, level.intermission_angle);
    level.intermission_origin = self.e.s.origin;

    // move all clients to the intermission point
    for (uint32 i = 0; i < max_clients; i++)
    {
        ASEntity @client = players[i];
        if (!client.e.inuse)
        {
            continue;
        }
		
        // respawn any dead clients
		if (client.health <= 0)
		{
			// give us our max health back since it will reset
			// to pers.health; in instanced items we'd lose the items
			// we touched so we always want to respawn with our max.
			if (P_UseCoopInstancedItems())
				client.client.pers.health = client.client.pers.max_health = client.max_health;

			respawn(client);
		}

        MoveClientToIntermission(client);
    }
    
    @self.activator = activator;
    @self.think = update_target_camera;
    self.nextthink = level.time + time_sec(self.wait);
    self.moveinfo.move_speed = self.speed;

    self.moveinfo.remaining_distance = (self.movetarget.e.s.origin - self.e.s.origin).normalize();
    self.moveinfo.distance = self.moveinfo.remaining_distance;

	if ((self.hackflags & HACKFLAG_END_OF_UNIT) != 0)
		G_EndOfUnitMessage();
}

void SP_target_camera(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(self);
		return;
	}

    @self.use = use_target_camera;
    self.e.svflags = svflags_t::NOCLIENT;
}

/*QUAKED target_gravity (1 0 0) (-8 -8 -8) (8 8 8) NOTRAIL NOEFFECTS
[Sam-KEX] Changes gravity, as seen in the N64 version
*/

void use_target_gravity(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	gi_cvar_set("sv_gravity", format("{}", self.gravity));
	level.gravity = self.gravity;
}

void SP_target_gravity(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	@self.use = use_target_gravity;
	self.gravity = parseFloat(st.gravity);
}

/*QUAKED target_soundfx (1 0 0) (-8 -8 -8) (8 8 8) NOTRAIL NOEFFECTS
[Sam-KEX] Plays a sound fx, as seen in the N64 version
*/

void update_target_soundfx(ASEntity &self)
{
	gi_positioned_sound(self.e.s.origin, self.e, soundchan_t::VOICE, self.noise_index, self.volume, self.attenuation, 0);
}

void use_target_soundfx(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.think = update_target_soundfx;
	self.nextthink = level.time + time_sec(self.delay);
}

void SP_target_soundfx(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (self.volume == 0)
		self.volume = 1.0;

	if (self.attenuation == 0)
		self.attenuation = 1.0;
	else if (self.attenuation == -1) // use -1 so 0 defaults to 1
		self.attenuation = 0;

	self.noise_index = parseInt(st.noise);

	switch(self.noise_index)
	{
	case 1:
		self.noise_index = gi_soundindex("world/x_alarm.wav");
		break;
	case 2:
		self.noise_index = gi_soundindex("world/flyby1.wav");
		break;
	case 4:
		self.noise_index = gi_soundindex("world/amb12.wav");
		break;
	case 5:
		self.noise_index = gi_soundindex("world/amb17.wav");
		break;
	case 7:
		self.noise_index = gi_soundindex("world/bigpump2.wav");
		break;
	default:
		gi_Com_Print("{}: unknown noise {}\n", self, self.noise_index);
		return;
	}

	@self.use = use_target_soundfx;
}

/*QUAKED target_light (1 0 0) (-8 -8 -8) (8 8 8) START_ON NO_LERP FLICKER
[Paril-KEX] dynamic light entity that follows a lightstyle.

*/

namespace spawnflags::target_light
{
    const uint32 START_ON = 1;
    const uint32 NO_LERP = 2; // not used in N64, but I'll use it for this
    const uint32 FLICKER = 4;
}

void target_light_flicker_think(ASEntity &self)
{
	if (brandom())
		self.e.svflags = svflags_t(self.e.svflags ^ svflags_t::NOCLIENT);

	self.nextthink = level.time + time_hz(10);
}

// think function handles interpolation from start to finish.
void target_light_think(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::target_light::FLICKER) != 0)
		target_light_flicker_think(self);

	string style = gi_get_configstring(configstring_id_t::LIGHTS + self.style);
	self.delay += self.speed;

	int32 index = int32(self.delay) % style.length();
	uint8 style_value = style[index];
	float current_lerp = float(style_value - 'a') / float('z' - 'a');
	float lerp;

	if ((self.spawnflags & spawnflags::target_light::NO_LERP) == 0)
	{
		int32 next_index = (index + 1) % style.length();
		uint8 next_style_value = style[next_index];

		float next_lerp = float(next_style_value - 'a') / float('z' - 'a');

		float mod_lerp = fmod(self.delay, 1.0f);
		lerp = (next_lerp * mod_lerp) + (current_lerp * (1.0f - mod_lerp));
	}
	else
		lerp = current_lerp;

	int my_rgb = self.count;
	int target_rgb = self.chain.e.s.skinnum;
	
	int my_b = ((my_rgb >> 8 ) & 0xff);
	int my_g = ((my_rgb >> 16) & 0xff);
	int my_r = ((my_rgb >> 24) & 0xff);

	int target_b = ((target_rgb >> 8 ) & 0xff);
	int target_g = ((target_rgb >> 16) & 0xff);
	int target_r = ((target_rgb >> 24) & 0xff);

	float backlerp = 1.0f - lerp;
	
	int b = int((target_b * lerp) + (my_b * backlerp));
	int g = int((target_g * lerp) + (my_g * backlerp));
	int r = int((target_r * lerp) + (my_r * backlerp));

	self.e.s.skinnum = (b << 8) | (g << 16) | (r << 24);

	self.nextthink = level.time + time_hz(10);
}

void target_light_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.health ^= 1;

	if (self.health != 0)
		self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	else
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);

	if (self.health == 0)
	{
		@self.think = null;
		self.nextthink = time_zero;
		return;
	}
	
	// has dynamic light "target"
	if (self.chain !is null)
	{
		@self.think = target_light_think;
		self.nextthink = level.time + time_hz(10);
	}
	else if ((self.spawnflags & spawnflags::target_light::FLICKER) != 0)
	{
		@self.think = target_light_flicker_think;
		self.nextthink = level.time + time_hz(10);
	}
}

void SP_target_light(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	self.e.s.modelindex = 1;
	self.e.s.renderfx = renderfx_t::CUSTOM_LIGHT;
	self.e.s.frame = int(st.radius != 0 ? st.radius : 150);
	self.count = self.e.s.skinnum;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.health = 0;

	if (!self.target.empty())
		@self.chain = G_PickTarget(self.target);

	if ((self.spawnflags & spawnflags::target_light::START_ON) != 0)
		target_light_use(self, self, self);
	
	if (self.speed == 0)
		self.speed = 1.0f;
	else
		self.speed = 0.1f / self.speed;

	if (level.is_n64)
		self.style += 10;

	@self.use = target_light_use;

	gi_linkentity(self.e);
}

/*QUAKED target_poi (1 0 0) (-4 -4 -4) (4 4 4) NEAREST DUMMY DYNAMIC
[Paril-KEX] point of interest for help in player navigation.
Without any additional setup, targeting this entity will switch
the current POI in the level to the one this is linked to.

"count": if set, this value is the 'stage' linked to this POI. A POI
with this set that is activated will only take effect if the current
level's stage value is <= this value, and if it is, will also set
the current level's stage value to this value.

"style": only used for teamed POIs; the POI with the lowest style will
be activated when checking for which POI to activate. This is mainly
useful during development, to easily insert or change the order of teamed
POIs without needing to manually move the entity definitions around.

"team": if set, this will create a team of POIs. Teamed POIs act like
a single unit; activating any of them will do the same thing. When activated,
it will filter through all of the POIs on the team selecting the one that
best fits the current situation. This includes checking "count" and "style"
values. You can also set the NEAREST spawnflag on any of the teamed POIs,
which will additionally cause activation to prefer the nearest one to the player.
Killing a POI via killtarget will remove it from the chain, allowing you to
adjust valid POIs at runtime.

The DUMMY spawnflag is to allow you to use a single POI as a team member
that can be activated, if you're using killtargets to remove POIs.

The DYNAMIC spawnflag is for very specific circumstances where you want
to direct the player to the nearest teamed POI, but want the path to pick
the nearest at any given time rather than only when activated.

The DISABLED flag is mainly intended to work with DYNAMIC & teams; the POI
will be disabled until it is targeted, and afterwards will be enabled until
it is killed.
*/
namespace spawnflags::poi
{
    const uint32 NEAREST = 1;
    const uint32 DUMMY = 2;
    const uint32 DYNAMIC = 4;
    const uint32 DISABLED = 8;
}

float distance_to_poi(const vec3_t &in start, const vec3_t &in end)
{
	PathRequest request;
	request.start = start;
	request.goal = end;
	request.moveDist = 64.0f;
	request.pathFlags = PathFlags::All;
	request.nodeSearch.ignoreNodeFlags = true;
	request.nodeSearch.minHeight = 128.0f;
	request.nodeSearch.maxHeight = 128.0f;
	request.nodeSearch.radius = 1024.0f;
	request.maxPathPoints = 0;

	PathInfo info;

	if (gi_GetPathToGoal(request, info))
		return info.pathDistSqr;

	if (info.returnCode == PathReturnCode::NoNavAvailable)
		return (end - start).lengthSquared();

	return float_limits::infinity;
}

void target_poi_use(ASEntity &ent_in, ASEntity &other, ASEntity @activator)
{
	ASEntity @ent = ent_in;
	bool debug = g_debug_poi.integer != 0;

	if (debug)
		gi_Com_Print("POI {} used by {}\n", ent, other);

	// we were disabled, so remove the disable check
	if ((ent.spawnflags & spawnflags::poi::DISABLED) != 0)
	{
		ent.spawnflags &= ~spawnflags::poi::DISABLED;
		if (debug)
			gi_Com_Print(" - POI was disabled, made re-enabled\n");
	}

	// early stage check
	if (ent.count != 0 && level.current_poi_stage > ent.count)
	{
		if (debug)
			gi_Com_Print(" - POI count is {}, current stage {}, early exit\n", ent.count, level.current_poi_stage);
		return;
	}

	// teamed POIs work a bit differently
	if (!ent.team.empty())
	{
		ASEntity @poi_master = ent.teammaster;

		if (debug)
			gi_Com_Print(" - teamed POI \"{}\"; master is {}\n", ent.team, poi_master);

		// unset ent, since we need to find one that matches
		@ent = null;

		float best_distance = float_limits::infinity;
		int32 best_style = int32_limits::max;

		ASEntity @dummy_fallback = null;

		for (ASEntity @poi = poi_master; poi !is null; @poi = poi.teamchain)
		{
			if (debug)
				gi_Com_Print("  - checking team member {}\n", poi);

			// currently disabled
			if ((poi.spawnflags & spawnflags::poi::DISABLED) != 0)
			{
				if (debug)
					gi_Com_Print("  - disabled, skipping\n");

				continue;
			}

			// ignore dummy POI
			if ((poi.spawnflags & spawnflags::poi::DUMMY) != 0)
			{
				if (debug)
					gi_Com_Print("  - dummy, skipping (but storing as fallback)\n");

				@dummy_fallback = poi;
				continue;
			}
			// POI is not part of current stage
			else if (poi.count != 0 && level.current_poi_stage > poi.count)
			{
				if (debug)
					gi_Com_Print("  - staged POI; level stage {} = POI count {}, skipping\n", level.current_poi_stage, poi.count);

				continue;
			// POI isn't the right style
			}
			else if (poi.style > best_style)
			{
				if (debug)
					gi_Com_Print("  - style {} > current best style {}, skipping\n", poi.style, best_style);

				continue;
			}

			float dist = distance_to_poi(activator.e.s.origin, poi.e.s.origin);

			if (debug)
				gi_Com_Print("  - resolved distance as {} (used for nearest)\n", dist);

			// we have one already and it's farther away, don't bother
			if ((poi_master.spawnflags & spawnflags::poi::NEAREST) != 0 &&
				ent !is null &&
				dist > best_distance)
			{
				if (debug)
					gi_Com_Print("  - nearest used; distance > best distance of {}, skipping\n", best_distance);
				continue;
			}

			// found a better style; overwrite dist
			if (poi.style < best_style)
			{
				if (debug)
					gi_Com_Print("  - style {} < current best style {} - potentially better pick\n", poi.style, best_style);

				// unless we weren't reachable...
				if ((poi_master.spawnflags & spawnflags::poi::NEAREST) != 0 && isinf(dist))
				{
					if (debug)
						gi_Com_Print("  - not reachable; skipped\n");
					continue;
				}

				best_style = poi.style;
				if ((poi_master.spawnflags & spawnflags::poi::NEAREST) != 0)
					best_distance = dist;
				@ent = poi;
				if (debug)
					gi_Com_Print("  - marked as current best due to style\n");
				continue;
			}

			// if we're picking by nearest, check distance
			if ((poi_master.spawnflags & spawnflags::poi::NEAREST) != 0)
			{
				if (dist < best_distance)
				{
					best_distance = dist;
					@ent = poi;
					if (debug)
						gi_Com_Print("  - marked as current best due to distance\n");
					continue;
				}
			}
			else
			{
				// not picking by distance, so it's order of appearance
				@ent = poi;
				if (debug)
					gi_Com_Print("  - marked as current best due to order of appearance\n");
			}
		}

		// no valid POI found; this isn't always an error,
		// some valid techniques may require this to happen.
		if (ent is null)
		{
			if (dummy_fallback !is null && (dummy_fallback.spawnflags & spawnflags::poi::DYNAMIC) != 0)
			{
				if (debug)
					gi_Com_Print(" - no valid POI found, but we had a dummy fallback\n");
				@ent = dummy_fallback;
			}
			else
			{
				if (debug)
					gi_Com_Print(" - no valid POI found, skipping\n");
				return;
			}
		}

		// copy over POI stage value
		if (ent.count != 0)
		{
			if (level.current_poi_stage <= ent.count)
			{
				level.current_poi_stage = ent.count;
				if (debug)
					gi_Com_Print(" - current POI stage set to {}\n", ent.count);
			}
		}
	}
	else
	{
		if (debug)
			gi_Com_Print(" - non-teamed POI\n");

		if (ent.count != 0)
		{
			if (level.current_poi_stage <= ent.count)
			{
				level.current_poi_stage = ent.count;
				if (debug)
					gi_Com_Print(" - level stage {} <= POI count {}, using new stage value\n", level.current_poi_stage, ent.count);
			}
			else
			{
				if (debug)
					gi_Com_Print(" - level stage {} <= POI count {}, not part of current stage, skipping\n", level.current_poi_stage, ent.count);
				return; // this POI is not part of our current stage
			}
		}
	}

	// dummy POI; not valid
	if (ent.classname == "target_poi" && (ent.spawnflags & spawnflags::poi::DUMMY) != 0 && (ent.spawnflags & spawnflags::poi::DYNAMIC) == 0)
	{
		if (debug)
			gi_Com_Print(" - POI is target_poi, dummy & not dynamic; not a valid POI\n");
		return;
	}

	level.valid_poi = true;
	level.current_poi = ent.e.s.origin;
	level.current_poi_image = ent.noise_index;
	
	if (debug)
		gi_Com_Print(" - got valid POI!\n");

	if (ent.classname == "target_poi" && (ent.spawnflags & spawnflags::poi::DYNAMIC) != 0)
	{
		@level.current_dynamic_poi = null;

		// pick the dummy POI, since it isn't supposed to get freed
		// FIXME maybe store the team string instead?

		for (ASEntity @m = ent.teammaster; m !is null; @m = m.teamchain)
			if ((m.spawnflags & spawnflags::poi::DUMMY) != 0)
			{
				@level.current_dynamic_poi = m;
				if (debug)
					gi_Com_Print(" - setting dynamic POI\n");
				break;
			}

		if (level.current_dynamic_poi is null)
			gi_Com_Print("can't activate dynamic poi for {}; need DUMMY in chain\n", ent);
	}
	else
		@level.current_dynamic_poi = null;
}

void target_poi_setup(ASEntity &self)
{
	if (!self.team.empty())
	{
		// copy dynamic/nearest over to all teammates
		if (self.spawnflags & (spawnflags::poi::NEAREST | spawnflags::poi::DYNAMIC) != 0)
			for (ASEntity @m = self.teammaster; m !is null; @m = m.teamchain)
				m.spawnflags |= self.spawnflags & (spawnflags::poi::NEAREST | spawnflags::poi::DYNAMIC);

		for (ASEntity @m = self.teammaster; m !is null; @m = m.teamchain)
		{
			if (m.classname != "target_poi")
				gi_Com_Print("WARNING: {} is teamed with target_poi's; unintentional\n", m);
		}
	}
}

void SP_target_poi(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(self);
		return;
	}

	if (!st.image.empty())
		self.noise_index = gi_imageindex(st.image);
	else
		self.noise_index = gi_imageindex("friend");

	@self.use = target_poi_use;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.think = target_poi_setup;
	self.nextthink = level.time + time_ms(1);

	if (self.team.empty())
	{
		if ((self.spawnflags & spawnflags::poi::NEAREST) != 0)
			gi_Com_Print("{} has useless spawnflag 'NEAREST'\n", self);
		if ((self.spawnflags & spawnflags::poi::DYNAMIC) != 0)
			gi_Com_Print("{} has useless spawnflag 'DYNAMIC'\n", self);
	}
}

/*QUAKED target_music (1 0 0) (-8 -8 -8) (8 8 8)
Change music when used
*/

void use_target_music(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	gi_configstring(configstring_id_t::CDTRACK, format("{}", ent.sounds));
}

void SP_target_music(ASEntity &self)
{
	@self.use = use_target_music;
}

/*QUAKED target_healthbar (0 1 0) (-8 -8 -8) (8 8 8) PVS_ONLY
* 
* Hook up health bars to monsters.
* "delay" is how long to show the health bar for after death.
* "message" is their name
*/

namespace spawnflag::healthbar
{
    const uint32 PVS_ONLY = 1;
}

const uint MAX_HEALTH_BARS = 2;

void use_target_healthbar(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ASEntity @target = G_PickTarget(ent.target);

	if (target is null || ent.health != target.spawn_count)
	{
		if (target !is null)
			gi_Com_Print("{}: target {} changed from what it used to be\n", ent, target);
		else
			gi_Com_Print("{}: no target\n", ent);
		G_FreeEdict(ent);
		return;
	}

	for (uint i = 0; i < MAX_HEALTH_BARS; i++)
	{
		if (level.health_bar_entities[i] !is null)
			continue;

		@ent.enemy = target;
		@level.health_bar_entities[i] = ent;
		gi_configstring(configstring_id_t(int(game_configstring_id_t::HEALTH_BAR_NAME)), ent.message);
		return;
	}

	gi_Com_Print("{}: too many health bars\n", ent);
	G_FreeEdict(ent);
}

void check_target_healthbar(ASEntity &ent)
{
	ASEntity @target = G_PickTarget(ent.target);
	if (target is null || (target.e.svflags & svflags_t::MONSTER) == 0)
	{
		if ( target !is null ) {
			gi_Com_Print( "{}: target {} does not appear to be a monster\n", ent, target );
		}
		G_FreeEdict(ent);
		return;
	}

	// just for sanity check
	ent.health = target.spawn_count;
}

void SP_target_healthbar(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.target.empty())
	{
        gi_Com_Print("{}: missing target\n", self);
		G_FreeEdict(self);
		return;
	}

	if (self.message.empty())
	{
		gi_Com_Print("{}: missing message\n", self);
		G_FreeEdict(self);
		return;
	}

	@self.use = use_target_healthbar;
	@self.think = check_target_healthbar;
	self.nextthink = level.time + time_ms(25);
}

/*QUAKED target_autosave (0 1 0) (-8 -8 -8) (8 8 8)
* 
* Auto save on command.
*/

void use_target_autosave(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	gtime_t save_time = time_sec(gi_cvar("g_athena_auto_save_min_time", "60", cvar_flags_t::NOSET).value);

	if (level.time - level.next_auto_save > save_time)
	{
		gi_AddCommandString("autosave\n");
		level.next_auto_save = level.time;
	}
}

void SP_target_autosave(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	@self.use = use_target_autosave;
}

/*QUAKED target_sky (0 1 0) (-8 -8 -8) (8 8 8)
* 
* Change sky parameters.
"sky"	environment map name
"skyaxis"	vector axis for rotating sky
"skyrotate"	speed of rotation in degrees/second
*/

void use_target_sky(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (!self.map.empty())
		gi_configstring(configstring_id_t::SKY, self.map);

	if ((self.count & 3) != 0)
	{
		float rotate;
		int32 autorotate;
        uint offset = 0;
        tokenizer_t tokenizer(configstring_id_t::SKYROTATE);

        tokenizer.next();
        rotate = tokenizer.as_float();
        tokenizer.next();
        autorotate = tokenizer.as_int32();

		if ((self.count & 1) != 0)
			rotate = self.accel;

		if ((self.count & 2) != 0)
			autorotate = self.style;

		gi_configstring(configstring_id_t::SKYROTATE, format("{} {}", rotate, autorotate));
	}

	if ((self.count & 4)  != 0)
		gi_configstring(configstring_id_t::SKYAXIS, format("{}", self.movedir));
}

void SP_target_sky(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	@self.use = use_target_sky;
	if (st.was_key_specified("sky"))
		self.map = st.sky;
	if (st.was_key_specified("skyaxis"))
	{
		self.count |= 4;
		self.movedir = st.skyaxis;
	}
	if (st.was_key_specified("skyrotate"))
	{
		self.count |= 1;
		self.accel = st.skyrotate;
	}
	if (st.was_key_specified("skyautorotate"))
	{
		self.count |= 2;
		self.style = st.skyautorotate;
	}
}

//==========================================================

/*QUAKED target_crossunit_trigger (.5 .5 .5) (-8 -8 -8) (8 8 8) trigger1 trigger2 trigger3 trigger4 trigger5 trigger6 trigger7 trigger8
Once this trigger is touched/used, any trigger_crossunit_target with the same trigger number is automatically used when a level is started within the same unit.  It is OK to check multiple triggers.  Message, delay, target, and killtarget also work.
*/
void trigger_crossunit_trigger_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	game.cross_unit_flags |= uint(self.spawnflags);
	G_FreeEdict(self);
}

void SP_target_crossunit_trigger(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	self.e.svflags = svflags_t::NOCLIENT;
	@self.use = trigger_crossunit_trigger_use;
}

/*QUAKED target_crossunit_target (.5 .5 .5) (-8 -8 -8) (8 8 8) trigger1 trigger2 trigger3 trigger4 trigger5 trigger6 trigger7 trigger8 - - - - - - - - trigger9 trigger10 trigger11 trigger12 trigger13 trigger14 trigger15 trigger16
Triggered by a trigger_crossunit elsewhere within a unit.  If multiple triggers are checked, all must be true.  Delay, target and
killtarget also work.

"delay"		delay before using targets if the trigger has been activated (default 1)
*/
void target_crossunit_target_think(ASEntity &self)
{
	if (uint(self.spawnflags) == (game.cross_unit_flags & SFL_CROSS_TRIGGER_MASK & uint(self.spawnflags)))
	{
		G_UseTargets(self, self);
		G_FreeEdict(self);
	}
}

void SP_target_crossunit_target(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.delay == 0)
		self.delay = 1;
	self.e.svflags = svflags_t::NOCLIENT;

	@self.think = target_crossunit_target_think;
	self.nextthink = level.time + time_sec(self.delay);
}

/*QUAKED target_achievement (.5 .5 .5) (-8 -8 -8) (8 8 8)
Give an achievement.

"achievement"		cheevo to give
*/
void use_target_achievement(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	gi_WriteByte(svc_t::achievement);
	gi_WriteString(self.map);
	gi_multicast(vec3_origin, multicast_t::ALL, true);
}

void SP_target_achievement(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	self.map = st.achievement;
	@self.use = use_target_achievement;
}

void use_target_story(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (!self.message.empty())
		level.story_active = true;
	else
		level.story_active = false;

	gi_configstring(game_configstring_id_t::STORY, self.message);
}

void SP_target_story(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	@self.use = use_target_story;
}