// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

TURRET

==============================================================================
*/

namespace turret
{
    enum frames
    {
        stand01,
        stand02,
        active01,
        active02,
        active03,
        active04,
        active05,
        active06,
        run01,
        run02,
        pow01,
        pow02,
        pow03,
        pow04,
        death01,
        death02
    };

    const float SCALE = 3.500000f;
}

namespace spawnflags::turret
{
    const uint32 BLASTER = 0x0008;
    const uint32 MACHINEGUN = 0x0010;
    const uint32 ROCKET = 0x0020;
    const uint32 HEATBEAM = 0x0040;
    const uint32 WEAPONCHOICE = HEATBEAM | ROCKET | MACHINEGUN | BLASTER;
    const uint32 WALL_UNIT = 0x0080;
    const uint32 NO_LASERSIGHT = 1 << 18;
}

namespace turret::sounds
{
    cached_soundindex moved("turret/moved.wav");
    cached_soundindex moving("turret/moving.wav");
}

void TurretAim(ASEntity &self)
{
	vec3_t end, dir;
	vec3_t ang;
	float  move, idealPitch, idealYaw, current, speed;
	int	   orientation;

	if (self.enemy is null || self.enemy is world)
	{
		if (!FindTarget(self))
			return;
	}

	// if turret is still in inactive mode, ready the gun, but don't aim
	if (self.e.s.frame < turret::frames::active01)
	{
		turret_ready_gun(self);
		return;
	}
	// if turret is still readying, don't aim.
	if (self.e.s.frame < turret::frames::run01)
		return;

	// PMM - blindfire aiming here
	if (self.monsterinfo.active_move is turret_move_fire_blind)
	{
		end = self.monsterinfo.blind_fire_target;
		if (self.enemy.e.s.origin[2] < self.monsterinfo.blind_fire_target[2])
			end[2] += self.enemy.viewheight + 10;
		else
			end[2] += self.enemy.e.mins[2] - 10;
	}
	else
	{
		end = self.enemy.e.s.origin;
		if (self.enemy.client !is null)
			end[2] += self.enemy.viewheight;
	}

	dir = end - self.e.s.origin;
	ang = vectoangles(dir);

	//
	// Clamp first
	//

	idealPitch = ang.pitch;
	idealYaw = ang.yaw;

	orientation = int(self.offset[1]);
	switch (orientation)
	{
	case -1: // up		pitch: 0 to 90
		if (idealPitch < -90)
			idealPitch += 360;
		if (idealPitch > -5)
			idealPitch = -5;
		break;
	case -2: // down		pitch: -180 to -360
		if (idealPitch > -90)
			idealPitch -= 360;
		if (idealPitch < -355)
			idealPitch = -355;
		else if (idealPitch > -185)
			idealPitch = -185;
		break;
	case 0: // +X		pitch: 0 to -90, -270 to -360 (or 0 to 90)
		if (idealPitch < -180)
			idealPitch += 360;

		if (idealPitch > 85)
			idealPitch = 85;
		else if (idealPitch < -85)
			idealPitch = -85;

		//			yaw: 270 to 360, 0 to 90
		//			yaw: -90 to 90 (270-360 == -90-0)
		if (idealYaw > 180)
			idealYaw -= 360;
		if (idealYaw > 85)
			idealYaw = 85;
		else if (idealYaw < -85)
			idealYaw = -85;
		break;
	case 90: // +Y	pitch: 0 to 90, -270 to -360 (or 0 to 90)
		if (idealPitch < -180)
			idealPitch += 360;

		if (idealPitch > 85)
			idealPitch = 85;
		else if (idealPitch < -85)
			idealPitch = -85;

		//			yaw: 0 to 180
		if (idealYaw > 270)
			idealYaw -= 360;
		if (idealYaw > 175)
			idealYaw = 175;
		else if (idealYaw < 5)
			idealYaw = 5;

		break;
	case 180: // -X	pitch: 0 to 90, -270 to -360 (or 0 to 90)
		if (idealPitch < -180)
			idealPitch += 360;

		if (idealPitch > 85)
			idealPitch = 85;
		else if (idealPitch < -85)
			idealPitch = -85;

		//			yaw: 90 to 270
		if (idealYaw > 265)
			idealYaw = 265;
		else if (idealYaw < 95)
			idealYaw = 95;

		break;
	case 270: // -Y	pitch: 0 to 90, -270 to -360 (or 0 to 90)
		if (idealPitch < -180)
			idealPitch += 360;

		if (idealPitch > 85)
			idealPitch = 85;
		else if (idealPitch < -85)
			idealPitch = -85;

		//			yaw: 180 to 360
		if (idealYaw < 90)
			idealYaw += 360;
		if (idealYaw > 355)
			idealYaw = 355;
		else if (idealYaw < 185)
			idealYaw = 185;
		break;
	}

	//
	// adjust pitch
	//
	current = self.e.s.angles.pitch;
	speed = self.yaw_speed / (gi_tick_rate / 10);

	if (idealPitch != current)
	{
		move = idealPitch - current;

		while (move >= 360)
			move -= 360;
		if (move >= 90)
		{
			move = move - 360;
		}

		while (move <= -360)
			move += 360;
		if (move <= -90)
		{
			move = move + 360;
		}

		if (move > 0)
		{
			if (move > speed)
				move = speed;
		}
		else
		{
			if (move < -speed)
				move = -speed;
		}

		self.e.s.angles.pitch = anglemod(current + move);
	}

	//
	// adjust yaw
	//
	current = self.e.s.angles.yaw;

	if (idealYaw != current)
	{
		move = idealYaw - current;

		//		while(move >= 360)
		//			move -= 360;
		if (move >= 180)
		{
			move = move - 360;
		}

		//		while(move <= -360)
		//			move += 360;
		if (move <= -180)
		{
			move = move + 360;
		}

		if (move > 0)
		{
			if (move > speed)
				move = speed;
		}
		else
		{
			if (move < -speed)
				move = -speed;
		}

		self.e.s.angles.yaw = anglemod(current + move);
	}

	if ((self.spawnflags & spawnflags::turret::NO_LASERSIGHT) != 0)
		return;

	// Paril: improved turrets; draw lasersight
	if (self.target_ent is null)
	{
		@self.target_ent = G_Spawn();
		self.target_ent.e.s.modelindex = MODELINDEX_WORLD;
		self.target_ent.e.s.renderfx = renderfx_t::BEAM;
		self.target_ent.e.s.frame = 1;
		self.target_ent.e.s.skinnum = int(0xf0f0f0f0);
		self.target_ent.classname = "turret_lasersight";
		self.target_ent.e.s.origin = self.e.s.origin;
	}

	vec3_t forward;
	AngleVectors(self.e.s.angles, forward);
	end = self.e.s.origin + (forward * 8192);
	trace_t tr = gi_traceline(self.e.s.origin, end, self.e, contents_t::MASK_SOLID);

	float scan_range = 64.f;

	if (visible(self, self.enemy))
		scan_range = 12.f;

	tr.endpos[0] += sin(level.time.secondsf() + self.e.s.number) * scan_range;
	tr.endpos[1] += cos((level.time.secondsf() - self.e.s.number) * 3.f) * scan_range;
	tr.endpos[2] += sin((level.time.secondsf() - self.e.s.number) * 2.5f) * scan_range;

	forward = tr.endpos - self.e.s.origin;
	forward.normalize();

	end = self.e.s.origin + (forward * 8192);
	tr = gi_traceline(self.e.s.origin, end, self.e, contents_t::MASK_SOLID);

	self.target_ent.e.s.old_origin = tr.endpos;
	gi_linkentity(self.target_ent.e);
}

void turret_sight(ASEntity &self, ASEntity &other)
{
}

void turret_search(ASEntity &self)
{
}

const array<mframe_t> turret_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t turret_move_stand = mmove_t(turret::frames::stand01, turret::frames::stand02, turret_frames_stand, null);

void turret_stand(ASEntity &self)
{
	M_SetAnimation(self, turret_move_stand);
	if (self.target_ent !is null)
	{
		G_FreeEdict(self.target_ent);
		@self.target_ent = null;
	}
}

const array<mframe_t> turret_frames_ready_gun = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand)
};
const mmove_t turret_move_ready_gun = mmove_t(turret::frames::active01, turret::frames::run01, turret_frames_ready_gun, turret_run);

void turret_ready_gun(ASEntity &self)
{
	if (self.monsterinfo.active_move !is turret_move_ready_gun)
	{
		M_SetAnimation(self, turret_move_ready_gun);
		self.monsterinfo.weapon_sound = turret::sounds::moving;
	}
}

const array<mframe_t> turret_frames_seek = {
	mframe_t(ai_walk, 0, TurretAim),
	mframe_t(ai_walk, 0, TurretAim)
};
const mmove_t turret_move_seek = mmove_t(turret::frames::run01, turret::frames::run02, turret_frames_seek, null);

void turret_walk(ASEntity &self)
{
	if (self.e.s.frame < turret::frames::run01)
		turret_ready_gun(self);
	else
		M_SetAnimation(self, turret_move_seek);
}

const array<mframe_t> turret_frames_run = {
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretAim)
};
const mmove_t turret_move_run = mmove_t(turret::frames::run01, turret::frames::run02, turret_frames_run, turret_run);

void turret_run(ASEntity &self)
{
	if (self.e.s.frame < turret::frames::run01)
		turret_ready_gun(self);
	else
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HIGH_TICK_RATE);
		M_SetAnimation(self, turret_move_run);

		if (self.monsterinfo.weapon_sound != 0)
		{
			self.monsterinfo.weapon_sound = 0;
			gi_sound(self.e, soundchan_t::WEAPON, turret::sounds::moved, 1.0f, ATTN_NORM, 0.f);
		}
	}
}

// **********************
//  ATTACK
// **********************

const int TURRET_BLASTER_DAMAGE = 8;
const int TURRET_BULLET_DAMAGE = 2;
// unused
// const int TURRET_HEAT_DAMAGE	= 4;

void TurretFire(ASEntity &self)
{
	vec3_t	forward;
	vec3_t	start, end, dir, aimpoint;
	float	dist, chance;
	trace_t trace;
	int		rocketSpeed;

	TurretAim(self);

	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) != 0)
		end = self.monsterinfo.blind_fire_target;
	else
		end = self.enemy.e.s.origin;
	dir = end - self.e.s.origin;
	dir.normalize();
	AngleVectors(self.e.s.angles, forward);
	chance = dir.dot(forward);
	if (chance < 0.98f)
		return;

	chance = frandom();

	if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
		rocketSpeed = 650;
	else if ((self.spawnflags & spawnflags::turret::BLASTER) != 0)
		rocketSpeed = 800;
	else
		rocketSpeed = 0;

	if ((self.spawnflags & spawnflags::turret::MACHINEGUN) != 0 || visible(self, self.enemy))
	{
		start = self.e.s.origin;

		// aim for the head.
		if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) == 0)
		{
			if ((self.enemy !is null) && (self.enemy.client !is null))
				end[2] += self.enemy.viewheight;
			else
				end[2] += 22;
		}

		dir = end - start;
		dist = dir.length();

		// check for predictive fire
		// Paril: adjusted to be a bit more fair
		if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) == 0)
		{
			// on harder difficulties, randomly fire directly at enemy
			// more often; makes them more unpredictable
			if ((self.spawnflags & spawnflags::turret::MACHINEGUN) != 0)
				PredictAim(self, self.enemy, start, 0, true, 0.3f, dir, aimpoint);
			else if (frandom() < skill.integer / 5.f)
				PredictAim(self, self.enemy, start, float(rocketSpeed), true, (frandom(3.f - skill.integer) / 3.f) - frandom(0.05f * (3.f - skill.integer)), dir, aimpoint);
		}

		dir.normalize();
		trace = gi_traceline(start, end, self.e, contents_t::MASK_PROJECTILE);
		if (trace.ent is self.enemy.e || trace.ent is world.e)
		{
			if ((self.spawnflags & spawnflags::turret::BLASTER) != 0)
				monster_fire_blaster(self, start, dir, TURRET_BLASTER_DAMAGE, rocketSpeed, monster_muzzle_t::TURRET_BLASTER, effects_t::BLASTER);
			else if ((self.spawnflags & spawnflags::turret::MACHINEGUN) != 0)
			{
				if ((self.monsterinfo.aiflags & ai_flags_t::HOLD_FRAME) == 0)
				{
					self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HOLD_FRAME);
					self.monsterinfo.duck_wait_time = level.time + time_sec(2) + time_sec(frandom(skill.value));
					self.monsterinfo.next_duck_time = level.time + time_sec(1);
					gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("weapons/chngnu1a.wav"), 1, ATTN_NORM, 0);
				}
				else
				{
					if (self.monsterinfo.next_duck_time < level.time &&
						self.monsterinfo.melee_debounce_time <= level.time)
					{
						monster_fire_bullet(self, start, dir, TURRET_BULLET_DAMAGE, 0, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, monster_muzzle_t::TURRET_MACHINEGUN);
						self.monsterinfo.melee_debounce_time = level.time + time_hz(10);
					}

					if (self.monsterinfo.duck_wait_time < level.time)
						self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);
				}
			}
			else if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
			{
				if (dist * trace.fraction > 72)
					monster_fire_rocket(self, start, dir, 40, rocketSpeed, monster_muzzle_t::TURRET_ROCKET);
			}
		}
	}
}

// PMM
void TurretFireBlind(ASEntity &self)
{
	vec3_t forward;
	vec3_t start, end, dir;
	float  chance;
	int	   rocketSpeed = 550;

	TurretAim(self);

	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	dir = self.monsterinfo.blind_fire_target - self.e.s.origin;
	dir.normalize();
	AngleVectors(self.e.s.angles, forward);
	chance = dir.dot(forward);
	if (chance < 0.98f)
		return;

	if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
		rocketSpeed = 650;
	else if ((self.spawnflags & spawnflags::turret::BLASTER) != 0)
		rocketSpeed = 800;
	else
		rocketSpeed = 0;

	start = self.e.s.origin;
	end = self.monsterinfo.blind_fire_target;

	if (self.enemy.e.s.origin[2] < self.monsterinfo.blind_fire_target[2])
		end[2] += self.enemy.viewheight + 10;
	else
		end[2] += self.enemy.e.mins[2] - 10;

	dir = end - start;

	dir.normalize();

	if ((self.spawnflags & spawnflags::turret::BLASTER) != 0)
		monster_fire_blaster(self, start, dir, TURRET_BLASTER_DAMAGE, rocketSpeed, monster_muzzle_t::TURRET_BLASTER, effects_t::BLASTER);
	else if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
		monster_fire_rocket(self, start, dir, 40, rocketSpeed, monster_muzzle_t::TURRET_ROCKET);
}
// pmm

const array<mframe_t> turret_frames_fire = {
	mframe_t(ai_run, 0, TurretFire),
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretAim)
};
const mmove_t turret_move_fire = mmove_t(turret::frames::pow01, turret::frames::pow04, turret_frames_fire, turret_run);

// PMM

// the blind frames need to aim first
const array<mframe_t> turret_frames_fire_blind = {
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretAim),
	mframe_t(ai_run, 0, TurretFireBlind)
};
const mmove_t turret_move_fire_blind = mmove_t(turret::frames::pow01, turret::frames::pow04, turret_frames_fire_blind, turret_run);
// pmm

void turret_attack(ASEntity &self)
{
	float r, chance;

	if (self.e.s.frame < turret::frames::run01)
		turret_ready_gun(self);
	// PMM
	else if (self.monsterinfo.attack_state != ai_attack_state_t::BLIND)
	{
		M_SetAnimation(self, turret_move_fire);
	}
	else
	{
		// setup shot probabilities
		if (self.monsterinfo.blind_fire_delay < time_sec(1))
			chance = 1.0;
		else if (self.monsterinfo.blind_fire_delay < time_sec(7.5))
			chance = 0.4f;
		else
			chance = 0.1f;

		r = frandom();

		// minimum of 3 seconds, plus 0-4, after the shots are done - total time should be max less than 7.5
		self.monsterinfo.blind_fire_delay += random_time(time_sec(3.4), time_sec(7.4));
		// don't shoot at the origin
		if (!self.monsterinfo.blind_fire_target)
			return;

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		M_SetAnimation(self, turret_move_fire_blind);
	}
	// pmm
}

// **********************
//  PAIN
// **********************

void turret_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
}

// **********************
//  DEATH
// **********************

void turret_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	vec3_t	 forward;
	ASEntity @base;

	AngleVectors(self.e.s.angles, forward);
	self.e.s.origin += forward;

	ThrowGibs(self, 2, {
		gib_def_t(2, "models/objects/debris1/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
	});
	ThrowGibs(self, 1, {
		gib_def_t(2, "models/objects/debris1/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
	});

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::PLAIN_EXPLOSION);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	if (self.teamchain !is null)
	{
		@base = self.teamchain;
		base.e.solid = solid_t::NOT;
		base.takedamage = false;
		base.movetype = movetype_t::NONE;
		@base.teammaster = base;
		@base.teamchain = null;
		base.flags = ent_flags_t(base.flags & ~ent_flags_t::TEAMSLAVE);
		base.flags = ent_flags_t(base.flags | ent_flags_t::TEAMMASTER);
		gi_linkentity(base.e);

		@self.teammaster = @self.teamchain = null;
		self.flags = ent_flags_t(self.flags & ~(ent_flags_t::TEAMSLAVE | ent_flags_t::TEAMMASTER));
	}

	if (!self.target.empty())
	{
		if (self.enemy !is null && self.enemy.e.inuse)
			G_UseTargets(self, self.enemy);
		else
			G_UseTargets(self, self);
	}

	if (self.target_ent !is null)
	{
		G_FreeEdict(self.target_ent);
		@self.target_ent = null;
	}

	ASEntity @gib = ThrowGib(self, "models/monsters/turret/tris.md2", damage,
        gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC | gib_type_t::HEAD | gib_type_t::DEBRIS), self.e.s.scale);
	gib.e.s.frame = 14;
}

// **********************
//  WALL SPAWN
// **********************

void turret_wall_spawn(ASEntity &turret)
{
	ASEntity @ent;
	int		 angle;

	@ent = G_Spawn();
	ent.e.s.origin = turret.e.s.origin;
	ent.e.s.angles = turret.e.s.angles;

	angle = int(ent.e.s.angles[1]);
	if (ent.e.s.angles[0] == 90)
		angle = -1;
	else if (ent.e.s.angles[0] == 270)
		angle = -2;
	switch (angle)
	{
	case -1:
		ent.e.mins = { -16, -16, -8 };
		ent.e.maxs = { 16, 16, 0 };
		break;
	case -2:
		ent.e.mins = { -16, -16, 0 };
		ent.e.maxs = { 16, 16, 8 };
		break;
	case 0:
		ent.e.mins = { -8, -16, -16 };
		ent.e.maxs = { 0, 16, 16 };
		break;
	case 90:
		ent.e.mins = { -16, -8, -16 };
		ent.e.maxs = { 16, 0, 16 };
		break;
	case 180:
		ent.e.mins = { 0, -16, -16 };
		ent.e.maxs = { 8, 16, 16 };
		break;
	case 270:
		ent.e.mins = { -16, 0, -16 };
		ent.e.maxs = { 16, 8, 16 };
		break;
	}

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::NOT;

	@ent.teammaster = turret;
	turret.flags = ent_flags_t(turret.flags | ent_flags_t::TEAMMASTER);
	@turret.teammaster = turret;
	@turret.teamchain = ent;
	@ent.teamchain = null;
	ent.flags = ent_flags_t(ent.flags | ent_flags_t::TEAMSLAVE);
	@ent.owner = turret;

	ent.e.s.modelindex = gi_modelindex("models/monsters/turretbase/tris.md2");

	gi_linkentity(ent.e);
}

void turret_wake(ASEntity &ent)
{
	// the wall section will call this when it stops moving.
	// just return without doing anything. easiest way to have a null function.
	if ((ent.flags & ent_flags_t::TEAMSLAVE) != 0)
	{
		ent.e.s.sound = 0;
		return;
	}

	@ent.monsterinfo.stand = turret_stand;
	@ent.monsterinfo.walk = turret_walk;
	@ent.monsterinfo.run = turret_run;
	@ent.monsterinfo.dodge = null;
	@ent.monsterinfo.attack = turret_attack;
	@ent.monsterinfo.melee = null;
	@ent.monsterinfo.sight = turret_sight;
	@ent.monsterinfo.search = turret_search;
	M_SetAnimation(ent, turret_move_stand);
	ent.takedamage = true;
	ent.movetype = movetype_t::NONE;
	// prevent counting twice
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

	gi_linkentity(ent.e);

    spawn_temp_t st;
	stationarymonster_start(ent, st);

	if ((ent.spawnflags & spawnflags::turret::MACHINEGUN) != 0)
	{
		ent.e.s.skinnum = 1;
	}
	else if ((ent.spawnflags & spawnflags::turret::ROCKET) != 0)
	{
		ent.e.s.skinnum = 2;
	}

	// but we do want the death to count
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::DO_NOT_COUNT);
}

void turret_activate(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	vec3_t	 endpos;
	vec3_t	 forward;
	ASEntity @base;

	self.movetype = movetype_t::PUSH;
	if (self.speed == 0)
		self.speed = 15;
	self.moveinfo.speed = self.speed;
	self.moveinfo.accel = self.speed;
	self.moveinfo.decel = self.speed;

	if (self.e.s.angles[0] == 270)
	{
		forward = { 0, 0, 1 };
	}
	else if (self.e.s.angles[0] == 90)
	{
		forward = { 0, 0, -1 };
	}
	else if (self.e.s.angles[1] == 0)
	{
		forward = { 1, 0, 0 };
	}
	else if (self.e.s.angles[1] == 90)
	{
		forward = { 0, 1, 0 };
	}
	else if (self.e.s.angles[1] == 180)
	{
		forward = { -1, 0, 0 };
	}
	else if (self.e.s.angles[1] == 270)
	{
		forward = { 0, -1, 0 };
	}

	// start up the turret
	endpos = self.e.s.origin + (forward * 32);
	Move_Calc(self, endpos, turret_wake);

	@base = self.teamchain;
	if (base !is null)
	{
		base.movetype = movetype_t::PUSH;
		base.speed = self.speed;
		base.moveinfo.speed = base.speed;
		base.moveinfo.accel = base.speed;
		base.moveinfo.decel = base.speed;

		// start up the wall section
		endpos = self.teamchain.e.s.origin + (forward * 32);
		Move_Calc(self.teamchain, endpos, turret_wake);

		base.e.s.sound = turret::sounds::moving;
		base.e.s.loop_attenuation = ATTN_NORM;
	}
}

// PMM
// checkattack .. ignore range, just attack if available
bool turret_checkattack(ASEntity &self)
{
	vec3_t	spot1, spot2;
	float	chance;
	trace_t tr;

	if (self.enemy.health > 0)
	{
		// see if any entities are in the way of the shot
		spot1 = self.e.s.origin;
		spot1[2] += self.viewheight;
		spot2 = self.enemy.e.s.origin;
		spot2[2] += self.enemy.viewheight;

		tr = gi_traceline(spot1, spot2, self.e, contents_t(contents_t::SOLID | contents_t::PLAYER | contents_t::MONSTER | contents_t::SLIME | contents_t::LAVA | contents_t::WINDOW));

		// do we have a clear shot?
		if (tr.ent !is self.enemy.e && (tr.ent.svflags & svflags_t::PLAYER) == 0)
		{
			// PGM - we want them to go ahead and shoot at info_notnulls if they can.
			if (self.enemy.e.solid != solid_t::NOT || tr.fraction < 1.0f) // PGM
			{
				// PMM - if we can't see our target, and we're not blocked by a monster, go into blind fire if available
				if (((tr.ent.svflags & svflags_t::MONSTER) == 0) && (!visible(self, self.enemy)))
				{
					if ((self.monsterinfo.blindfire) && (self.monsterinfo.blind_fire_delay <= time_sec(10)))
					{
						if (level.time < self.monsterinfo.attack_finished)
						{
							return false;
						}
						if (level.time < (self.monsterinfo.trail_time + self.monsterinfo.blind_fire_delay))
						{
							// wait for our time
							return false;
						}
						else
						{
							// make sure we're not going to shoot something we don't want to shoot
							tr = gi_traceline(spot1, self.monsterinfo.blind_fire_target, self.e, contents_t(contents_t::MONSTER | contents_t::PLAYER));
							if (tr.allsolid || tr.startsolid || ((tr.fraction < 1.0f) && (tr.ent !is self.enemy.e && (tr.ent.svflags & svflags_t::PLAYER) == 0)))
							{
								return false;
							}

							self.monsterinfo.attack_state = ai_attack_state_t::BLIND;
							self.monsterinfo.attack_finished = level.time + random_time(time_ms(500), time_sec(2.5));
							return true;
						}
					}
				}
				// pmm
				return false;
			}
		}
	}

	if (level.time < self.monsterinfo.attack_finished)
		return false;

	gtime_t nexttime;

	if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
	{
		chance = 0.10f;
		nexttime = (time_sec(1.8) - (time_sec(0.2) * skill.integer));
	}
	else if ((self.spawnflags & spawnflags::turret::BLASTER) != 0)
	{
		chance = 0.35f;
		nexttime = (time_sec(1.2) - (time_sec(0.2) * skill.integer));
	}
	else
	{
		chance = 0.50f;
		nexttime = (time_sec(0.8) - (time_sec(0.1) * skill.integer));
	}

	if (skill.integer == 0)
		chance *= 0.5f;
	else if (skill.integer > 1)
		chance *= 2;

	// PGM - go ahead and shoot every time if it's a info_notnull
	// PMM - added visibility check
	if (((frandom() < chance) && (visible(self, self.enemy))) || (self.enemy.e.solid == solid_t::NOT))
	{
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		self.monsterinfo.attack_finished = level.time + nexttime;
		return true;
	}

	self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;

	return false;
}

// **********************
//  SPAWN
// **********************

/*QUAKED monster_turret (1 .5 0) (-16 -16 -16) (16 16 16) Ambush Trigger_Spawn Sight Blaster MachineGun Rocket Heatbeam WallUnit

The automated defense turret that mounts on walls.
Check the weapon you want it to use: blaster, machinegun, rocket, heatbeam.
Default weapon is blaster.
When activated, wall units move 32 units in the direction they're facing.
*/
void SP_monster_turret(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	int angle;

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	// pre-caches
	turret::sounds::moved.precache();
	turret::sounds::moving.precache();
	gi_modelindex("models/objects/debris1/tris.md2");

	self.e.s.modelindex = gi_modelindex("models/monsters/turret/tris.md2");

	self.e.mins = { -12, -12, -12 };
	self.e.maxs = { 12, 12, 12 };
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::BBOX;

	self.health = int(50 * st.health_multiplier);
	self.gib_health = -100;
	self.mass = 250;
	self.yaw_speed = 10 * skill.integer;

	self.monsterinfo.armor_type = item_id_t::ARMOR_COMBAT;
	self.monsterinfo.armor_power = 50;

	self.flags = ent_flags_t(self.flags | ent_flags_t::MECHANICAL);

	@self.pain = turret_pain;
	@self.die = turret_die;

	// map designer didn't specify weapon type. set it now.
	if ((self.spawnflags & spawnflags::turret::WEAPONCHOICE) == 0)
		self.spawnflags |= spawnflags::turret::BLASTER;

	if ((self.spawnflags & spawnflags::turret::HEATBEAM) != 0)
	{
		self.spawnflags &= ~spawnflags::turret::HEATBEAM;
		self.spawnflags |= spawnflags::turret::BLASTER;
	}

	if ((self.spawnflags & spawnflags::turret::WALL_UNIT) == 0)
	{
		@self.monsterinfo.stand = turret_stand;
		@self.monsterinfo.walk = turret_walk;
		@self.monsterinfo.run = turret_run;
		@self.monsterinfo.dodge = null;
		@self.monsterinfo.attack = turret_attack;
		@self.monsterinfo.melee = null;
		@self.monsterinfo.sight = turret_sight;
		@self.monsterinfo.search = turret_search;
		M_SetAnimation(self, turret_move_stand);
	}

	// PMM
	@self.monsterinfo.checkattack = turret_checkattack;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
	self.monsterinfo.scale = turret::SCALE;
	self.gravity = 0;

	self.offset = self.e.s.angles;
	angle = int(self.e.s.angles[1]);
	switch (angle)
	{
	case -1: // up
		self.e.s.angles[0] = 270;
		self.e.s.angles[1] = 0;
		self.e.s.origin[2] += 2;
		break;
	case -2: // down
		self.e.s.angles[0] = 90;
		self.e.s.angles[1] = 0;
		self.e.s.origin[2] -= 2;
		break;
	case 0:
		self.e.s.origin[0] += 2;
		break;
	case 90:
		self.e.s.origin[1] += 2;
		break;
	case 180:
		self.e.s.origin[0] -= 2;
		break;
	case 270:
		self.e.s.origin[1] -= 2;
		break;
	default:
		break;
	}

	gi_linkentity(self.e);

	if ((self.spawnflags & spawnflags::turret::WALL_UNIT) != 0)
	{
		if (self.targetname.empty())
		{
			G_FreeEdict(self);
			return;
		}

		self.takedamage = false;
		@self.use = turret_activate;
		turret_wall_spawn(self);
		if ((self.monsterinfo.aiflags & ai_flags_t::DO_NOT_COUNT) == 0)
		{
            // AS_TODO
			//if (g_debug_monster_kills.integer)
			//	level.monsters_registered[level.total_monsters] = self;
			//level.total_monsters++;
		}
	}
	else
	{
		stationarymonster_start(self, ED_GetSpawnTemp());
	}

	if ((self.spawnflags & spawnflags::turret::MACHINEGUN) != 0)
	{
		gi_soundindex("infantry/infatck1.wav");
		gi_soundindex("weapons/chngnu1a.wav");
		self.e.s.skinnum = 1;

		self.spawnflags &= ~spawnflags::turret::WEAPONCHOICE;
		self.spawnflags |= spawnflags::turret::MACHINEGUN;
	}
	else if ((self.spawnflags & spawnflags::turret::ROCKET) != 0)
	{
		gi_soundindex("weapons/rockfly.wav");
		gi_modelindex("models/objects/rocket/tris.md2");
		gi_soundindex("chick/chkatck2.wav");
		self.e.s.skinnum = 2;

		self.spawnflags &= ~spawnflags::turret::WEAPONCHOICE;
		self.spawnflags |= spawnflags::turret::ROCKET;
	}
	else
	{
		gi_modelindex("models/objects/laser/tris.md2");
		gi_soundindex("misc/lasfly.wav");
		gi_soundindex("soldier/solatck2.wav");

		self.spawnflags &= ~spawnflags::turret::WEAPONCHOICE;
		self.spawnflags |= spawnflags::turret::BLASTER;
	}

	// PMM  - turrets don't get mad at monsters, and visa versa
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	// PMM - blindfire
	if ((self.spawnflags & (spawnflags::turret::ROCKET | spawnflags::turret::BLASTER)) != 0)
		self.monsterinfo.blindfire = true;
}
