// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
// g_turret.c

namespace spawnflags::turret
{
    const spawnflags_t BREACH_FIRE = spawnflag_dec(65536);
}

namespace spawnflags::turret_brain
{
    const spawnflags_t IGNORE_SIGHT = spawnflag_dec(1);
}

vec3_t AnglesNormalize(vec3_t vec)
{
	while (vec[0] > 360)
		vec[0] -= 360;
	while (vec[0] < 0)
		vec[0] += 360;
	while (vec[1] > 360)
		vec[1] -= 360;
	while (vec[1] < 0)
		vec[1] += 360;

    return vec;
}

void turret_blocked(ASEntity &self, ASEntity &other)
{
	ASEntity @attacker;

	if (other.takedamage)
	{
		if (self.teammaster.owner !is null)
			@attacker = self.teammaster.owner;
		else
			@attacker = self.teammaster;
		T_Damage(other, self, attacker, vec3_origin, other.e.s.origin, vec3_origin, self.teammaster.dmg, 10, damageflags_t::NONE, mod_id_t::CRUSH);
	}
}

/*QUAKED turret_breach (0 0 0) ?
This portion of the turret can change both pitch and yaw.
The model  should be made with a flat pitch.
It (and the associated base) need to be oriented towards 0.
Use "angle" to set the starting angle.

"speed"		default 50
"dmg"		default 10
"angle"		point this forward
"target"	point this at an info_notnull at the muzzle tip
"minpitch"	min acceptable pitch angle : default -30
"maxpitch"	max acceptable pitch angle : default 30
"minyaw"	min acceptable yaw angle   : default 0
"maxyaw"	max acceptable yaw angle   : default 360
*/

void turret_breach_fire(ASEntity &self)
{
	vec3_t f, r, u;
	vec3_t start;
	int	   damage;
	int	   speed;

	AngleVectors(self.e.s.angles, f, r, u);
	start = self.e.s.origin + (f * self.move_origin[0]);
	start += (r * self.move_origin[1]);
	start += (u * self.move_origin[2]);

	if (self.count != 0)
		damage = self.count;
	else
		damage = int(frandom(100, 150));
	speed = 550 + 50 * skill.integer;
	ASEntity @rocket = fire_rocket(self.teammaster.owner.activator !is null ? self.teammaster.owner.activator : self.teammaster.owner, start, f, damage, speed, 150, damage);
	rocket.e.s.scale = self.teammaster.dmg_radius;

	gi_positioned_sound(start, self.e, soundchan_t::WEAPON, gi_soundindex("weapons/rocklf1a.wav"), 1, ATTN_NORM, 0);
}

void turret_breach_think(ASEntity &self)
{
	ASEntity @ent;
	vec3_t	 current_angles;
	vec3_t	 delta;

	current_angles = AnglesNormalize(self.e.s.angles);

	self.move_angles = AnglesNormalize(self.move_angles);
	if (self.move_angles.pitch > 180)
		self.move_angles.pitch -= 360;

	// clamp angles to mins & maxs
	if (self.move_angles.pitch > self.pos1.pitch)
		self.move_angles.pitch = self.pos1.pitch;
	else if (self.move_angles.pitch < self.pos2.pitch)
		self.move_angles.pitch = self.pos2.pitch;

	if ((self.move_angles.yaw < self.pos1.yaw) || (self.move_angles.yaw > self.pos2.yaw))
	{
		float dmin, dmax;

		dmin = abs(self.pos1.yaw - self.move_angles.yaw);
		if (dmin < -180)
			dmin += 360;
		else if (dmin > 180)
			dmin -= 360;
		dmax = abs(self.pos2.yaw - self.move_angles.yaw);
		if (dmax < -180)
			dmax += 360;
		else if (dmax > 180)
			dmax -= 360;
		if (abs(dmin) < abs(dmax))
			self.move_angles.yaw = self.pos1.yaw;
		else
			self.move_angles.yaw = self.pos2.yaw;
	}

	delta = self.move_angles - current_angles;
	if (delta[0] < -180)
		delta[0] += 360;
	else if (delta[0] > 180)
		delta[0] -= 360;
	if (delta[1] < -180)
		delta[1] += 360;
	else if (delta[1] > 180)
		delta[1] -= 360;
	delta[2] = 0;

	if (delta[0] > self.speed * gi_frame_time_s)
		delta[0] = self.speed * gi_frame_time_s;
	if (delta[0] < -1 * self.speed * gi_frame_time_s)
		delta[0] = -1 * self.speed * gi_frame_time_s;
	if (delta[1] > self.speed * gi_frame_time_s)
		delta[1] = self.speed * gi_frame_time_s;
	if (delta[1] < -1 * self.speed * gi_frame_time_s)
		delta[1] = -1 * self.speed * gi_frame_time_s;

	for (@ent = self.teammaster; ent !is null; @ent = ent.teamchain)
	{
		if (ent.noise_index != 0)
		{
			if (delta[0] != 0 || delta[1] != 0)
			{
				ent.e.s.sound = ent.noise_index;
				ent.e.s.loop_attenuation = ATTN_NORM;
			}
			else
				ent.e.s.sound = 0;
		}
	}

	self.avelocity = delta * (1.0f / gi_frame_time_s);

	self.nextthink = level.time + FRAME_TIME_S;

	for (@ent = self.teammaster; ent !is null; @ent = ent.teamchain)
		ent.avelocity[1] = self.avelocity[1];

	// if we have a driver, adjust his velocities
	if (self.owner !is null)
	{
		float  angle;
		float  target_z;
		float  diff;
		vec3_t target;
		vec3_t dir;

		// angular is easy, just copy ours
		self.owner.avelocity[0] = self.avelocity[0];
		self.owner.avelocity[1] = self.avelocity[1];

		// x & y
		angle = self.e.s.angles[1] + self.owner.move_origin[1];
		angle *= float(PI * 2 / 360);
		target[0] = self.e.s.origin[0] + cos(angle) * self.owner.move_origin[0];
		target[1] = self.e.s.origin[1] + sin(angle) * self.owner.move_origin[0];
		target[2] = self.owner.e.s.origin[2];

		dir = target - self.owner.e.s.origin;
		self.owner.velocity[0] = dir[0] * 1.0f / gi_frame_time_s;
		self.owner.velocity[1] = dir[1] * 1.0f / gi_frame_time_s;

		// z
		angle = self.e.s.angles.pitch * float(PI * 2 / 360);
		target_z = self.e.s.origin[2] + self.owner.move_origin[0] * tan(angle) + self.owner.move_origin[2];

		diff = target_z - self.owner.e.s.origin[2];
		self.owner.velocity[2] = diff * 1.0f / gi_frame_time_s;

		if (self.spawnflags.has(spawnflags::turret::BREACH_FIRE))
		{
			turret_breach_fire(self);
			self.spawnflags &= ~spawnflags::turret::BREACH_FIRE;
		}
	}
}

void turret_breach_finish_init(ASEntity &self)
{
	// get and save info for muzzle location
	if (self.target.empty())
	{
		gi_Com_Print("{}: needs a target\n", self);
	}
	else
	{
		@self.target_ent = G_PickTarget(self.target);
		if (self.target_ent !is null)
		{
			self.move_origin = self.target_ent.e.s.origin - self.e.s.origin;
			G_FreeEdict(self.target_ent);
		}
		else
			gi_Com_Print("{}: could not find target entity \"{}\"\n", self, self.target);
	}

	self.teammaster.dmg = self.dmg;
	self.teammaster.dmg_radius = self.dmg_radius; // scale
	@self.think = turret_breach_think;
	self.think(self);
}

void SP_turret_breach(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	self.e.solid = solid_t::BSP;
	self.movetype = movetype_t::PUSH;

	if (!st.noise.empty())
		self.noise_index = gi_soundindex(st.noise);

	gi_setmodel(self.e, self.model);

	if (self.speed == 0)
		self.speed = 50;
	if (self.dmg == 0)
		self.dmg = 10;

	float minpitch = st.minpitch;
	float maxpitch = st.maxpitch;
	float maxyaw = st.maxyaw;

	if (minpitch == 0)
		minpitch = -30;
	if (maxpitch == 0)
		maxpitch = 30;
	if (maxyaw == 0)
		maxyaw = 360;

	self.pos1.pitch = -1 * minpitch;
	self.pos1.yaw = st.minyaw;
	self.pos2.pitch = -1 * maxpitch;
	self.pos2.yaw = maxyaw;

	// scale used for rocket scale
	self.dmg_radius = self.e.s.scale;
	self.e.s.scale = 0;

	self.ideal_yaw = self.e.s.angles.yaw;
	self.move_angles.yaw = self.ideal_yaw;

	@self.moveinfo.blocked = turret_blocked;

	@self.think = turret_breach_finish_init;
	self.nextthink = level.time + FRAME_TIME_S;
	gi_linkentity(self.e);
}

/*QUAKED turret_base (0 0 0) ?
This portion of the turret changes yaw only.
MUST be teamed with a turret_breach.
*/

void SP_turret_base(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	self.e.solid = solid_t::BSP;
	self.movetype = movetype_t::PUSH;

	if (!st.noise.empty())
		self.noise_index = gi_soundindex(st.noise);

	gi_setmodel(self.e, self.model);
	@self.moveinfo.blocked = turret_blocked;
	gi_linkentity(self.e);
}

/*QUAKED turret_driver (1 .5 0) (-16 -16 -24) (16 16 32)
Must NOT be on the team with the rest of the turret parts.
Instead it must target the turret_breach.
*/

void turret_driver_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (!self.deadflag)
	{
		ASEntity @ent;

		// level the gun
		self.target_ent.move_angles[0] = 0;

		// remove the driver from the end of them team chain
		for (@ent = self.target_ent.teammaster; ent.teamchain !is self; @ent = ent.teamchain)
			;
		@ent.teamchain = null;
		@self.teammaster = null;
		self.flags = ent_flags_t(self.flags & ~ent_flags_t::TEAMSLAVE);

		@self.target_ent.owner = null;
		@self.target_ent.teammaster.owner = null;

		@self.target_ent.moveinfo.blocked = null;

		// clear pitch
		self.e.s.angles[0] = 0;
		self.movetype = movetype_t::STEP;

		@self.think = monster_think;
		self.classname = "monster_infantry"; // [Paril-KEX] fix revive
	}

	infantry_die(self, inflictor, attacker, damage, point, mod);

	G_FixStuckObject(self, self.e.s.origin);
	AngleVectors(self.e.s.angles, self.velocity);
	self.velocity *= -50;
	self.velocity.z += 110.f;
}

void turret_driver_think(ASEntity &self)
{
	vec3_t target;
	vec3_t dir;

	self.nextthink = level.time + FRAME_TIME_S;

	if (self.enemy !is null && (!self.enemy.e.inuse || self.enemy.health <= 0))
		@self.enemy = null;

	if (self.enemy is null)
	{
		if (!FindTarget(self))
			return;
		self.monsterinfo.trail_time = level.time;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);
	}
	else
	{
		if (visible(self, self.enemy))
		{
			if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) != 0)
			{
				self.monsterinfo.trail_time = level.time;
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);
			}
		}
		else
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::LOST_SIGHT);
			return;
		}
	}

	// let the turret know where we want it to aim
	target = self.enemy.e.s.origin;
	target[2] += self.enemy.viewheight;
	dir = target - self.target_ent.e.s.origin;
	self.target_ent.move_angles = vectoangles(dir);

	// decide if we should shoot
	if (level.time < self.monsterinfo.attack_finished)
		return;

	gtime_t reaction_time = time_sec(3 - skill.integer);
	if ((level.time - self.monsterinfo.trail_time) < reaction_time)
		return;

	self.monsterinfo.attack_finished = level.time + reaction_time + time_sec(1);
	// FIXME how do we really want to pass this along?
	self.target_ent.spawnflags |= spawnflags::turret::BREACH_FIRE;
}

void turret_driver_link(ASEntity &self)
{
	vec3_t	 vec;
	ASEntity @ent;

	@self.think = turret_driver_think;
	self.nextthink = level.time + FRAME_TIME_S;

	@self.target_ent = G_PickTarget(self.target);
	@self.target_ent.owner = self;
	@self.target_ent.teammaster.owner = self;
	self.e.s.angles = self.target_ent.e.s.angles;

	vec[0] = self.target_ent.e.s.origin[0] - self.e.s.origin[0];
	vec[1] = self.target_ent.e.s.origin[1] - self.e.s.origin[1];
	vec[2] = 0;
	self.move_origin[0] = vec.length();

	vec = self.e.s.origin - self.target_ent.e.s.origin;
	vec = AnglesNormalize(vectoangles(vec));
	self.move_origin[1] = vec[1];

	self.move_origin[2] = self.e.s.origin[2] - self.target_ent.e.s.origin[2];

	// add the driver to the end of them team chain
	for (@ent = self.target_ent.teammaster; ent.teamchain !is null; @ent = ent.teamchain)
		;
	@ent.teamchain = self;
	@self.teammaster = self.target_ent.teammaster;
	self.flags = ent_flags_t(self.flags | ent_flags_t::TEAMSLAVE);
}

void SP_turret_driver(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	InfantryPrecache();

	self.movetype = movetype_t::PUSH;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/infantry/tris.md2");
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };

	self.health = self.max_health = 100;
	self.gib_health = -40;
	self.mass = 200;
	self.viewheight = 24;

	@self.pain = infantry_pain;
	@self.die = turret_driver_die;
	@self.monsterinfo.stand = infantry_stand;

	self.flags = ent_flags_t(self.flags | ent_flags_t::NO_KNOCKBACK);

    // AS_TODO
	//if (g_debug_monster_kills.integer)
	//	level.monsters_registered[level.total_monsters] = self;
	level.total_monsters++;

	self.e.svflags = svflags_t(self.e.svflags | svflags_t::MONSTER);
	self.takedamage = true;
	@self.use = monster_use;
	self.e.clipmask = MASK_MONSTERSOLID;
	self.e.s.old_origin = self.e.s.origin;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::STAND_GROUND);
	@self.monsterinfo.setskin = infantry_setskin;

	if (!st.item.empty())
	{
		@self.item = FindItemByClassname(st.item);
		if (self.item is null)
			gi_Com_Print("{}: bad item: {}\n", self, st.item);
	}

	@self.think = turret_driver_link;
	self.nextthink = level.time + FRAME_TIME_S;

	gi_linkentity(self.e);
}

//============
// ROGUE

// invisible turret drivers so we can have unmanned turrets.
// originally designed to shoot at func_trains and such, so they
// fire at the center of the bounding box, rather than the entity's
// origin.

void turret_brain_think(ASEntity &self)
{
	vec3_t	target;
	vec3_t	dir;
	vec3_t	endpos;
	trace_t trace;

	self.nextthink = level.time + FRAME_TIME_S;

	if (self.enemy !is null)
	{
		if (!self.enemy.e.inuse)
			@self.enemy = null;
		else if (self.enemy.takedamage && self.enemy.health <= 0)
			@self.enemy = null;
	}

	if (self.enemy is null)
	{
		if (!FindTarget(self))
			return;
		self.monsterinfo.trail_time = level.time;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);
	}

	endpos = self.enemy.e.absmax + self.enemy.e.absmin;
	endpos *= 0.5f;

	if (!self.spawnflags.has(spawnflags::turret_brain::IGNORE_SIGHT))
	{
		trace = gi_traceline(self.target_ent.e.s.origin, endpos, self.target_ent.e, contents_t::MASK_SHOT);
		if (trace.fraction == 1 || trace.ent is self.enemy.e)
		{
			if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT)  != 0)
			{
				self.monsterinfo.trail_time = level.time;
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);
			}
		}
		else
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::LOST_SIGHT);
			return;
		}
	}

	// let the turret know where we want it to aim
	target = endpos;
	dir = target - self.target_ent.e.s.origin;
	self.target_ent.move_angles = vectoangles(dir);

	// decide if we should shoot
	if (level.time < self.monsterinfo.attack_finished)
		return;

	gtime_t reaction_time;

	if (self.delay != 0)
		reaction_time = time_sec(self.delay);
	else
		reaction_time = time_sec(3 - skill.integer);

	if ((level.time - self.monsterinfo.trail_time) < reaction_time)
		return;

	self.monsterinfo.attack_finished = level.time + reaction_time + time_sec(1);
	// FIXME how do we really want to pass this along?
	self.target_ent.spawnflags |= spawnflags::turret::BREACH_FIRE;
}

// =================
// =================
void turret_brain_link(ASEntity &self)
{
	vec3_t	 vec;
	ASEntity @ent;

	if (!self.killtarget.empty())
	{
		@self.enemy = G_PickTarget(self.killtarget);
	}

	@self.think = turret_brain_think;
	self.nextthink = level.time + FRAME_TIME_S;

	@self.target_ent = G_PickTarget(self.target);
	@self.target_ent.owner = self;
	@self.target_ent.teammaster.owner = self;
	self.e.s.angles = self.target_ent.e.s.angles;

	vec[0] = self.target_ent.e.s.origin[0] - self.e.s.origin[0];
	vec[1] = self.target_ent.e.s.origin[1] - self.e.s.origin[1];
	vec[2] = 0;
	self.move_origin[0] = vec.length();

	vec = self.e.s.origin - self.target_ent.e.s.origin;
	vec = AnglesNormalize(vectoangles(vec));
	self.move_origin[1] = vec[1];

	self.move_origin[2] = self.e.s.origin[2] - self.target_ent.e.s.origin[2];

	// add the driver to the end of them team chain
	for (@ent = self.target_ent.teammaster; ent.teamchain !is null; @ent = ent.teamchain)
		@ent.activator = self.activator; // pass along activator to breach, etc

	@ent.teamchain = self;
	@self.teammaster = self.target_ent.teammaster;
	self.flags = ent_flags_t(self.flags | ent_flags_t::TEAMSLAVE);
}

// =================
// =================
void turret_brain_deactivate(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.think = null;
	self.nextthink = time_zero;
}

// =================
// =================
void turret_brain_activate(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.enemy is null)
		@self.enemy = activator;

	// wait at least 3 seconds to fire.
	if (self.wait != 0)
		self.monsterinfo.attack_finished = level.time + time_sec(self.wait);
	else
		self.monsterinfo.attack_finished = level.time + time_sec(3);
	@self.use = turret_brain_deactivate;

	// Paril NOTE: rhangar1 has a turret_invisible_brain that breaks the
	// hangar ceiling; once the final rocket explodes the barrier,
	// it attempts to print "Barrier neutralized." to the rocket owner
	// who happens to be this brain rather than the player that activated
	// the turret. this resolves this by passing it along to fire_rocket.
	@self.activator = activator;

	@self.think = turret_brain_link;
	self.nextthink = level.time + FRAME_TIME_S;
}

/*QUAKED turret_invisible_brain (1 .5 0) (-16 -16 -16) (16 16 16)
Invisible brain to drive the turret.

Does not search for targets. If targeted, can only be turned on once
and then off once. After that they are completely disabled.

"delay" the delay between firing (default ramps for skill level)
"Target" the turret breach
"Killtarget" the item you want it to attack.
Target the brain if you want it activated later, instead of immediately. It will wait 3 seconds
before firing to acquire the target.
*/
void SP_turret_invisible_brain(ASEntity &self)
{
	if (self.killtarget.empty())
	{
		gi_Com_Print("turret_invisible_brain with no killtarget!\n");
		G_FreeEdict(self);
		return;
	}
	if (self.target.empty())
	{
		gi_Com_Print("turret_invisible_brain with no target!\n");
		G_FreeEdict(self);
		return;
	}

	if (!self.targetname.empty())
	{
		@self.use = turret_brain_activate;
	}
	else
	{
		@self.think = turret_brain_link;
		self.nextthink = level.time + FRAME_TIME_S;
	}

	self.movetype = movetype_t::PUSH;
	gi_linkentity(self.e);
}

// ROGUE
//============
