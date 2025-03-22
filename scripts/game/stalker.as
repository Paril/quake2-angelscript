// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

stalker

==============================================================================
*/

namespace stalker
{
    enum frames
    {
        idle01,
        idle02,
        idle03,
        idle04,
        idle05,
        idle06,
        idle07,
        idle08,
        idle09,
        idle10,
        idle11,
        idle12,
        idle13,
        idle14,
        idle15,
        idle16,
        idle17,
        idle18,
        idle19,
        idle20,
        idle21,
        idle201,
        idle202,
        idle203,
        idle204,
        idle205,
        idle206,
        idle207,
        idle208,
        idle209,
        idle210,
        idle211,
        idle212,
        idle213,
        walk01,
        walk02,
        walk03,
        walk04,
        walk05,
        walk06,
        walk07,
        walk08,
        jump01,
        jump02,
        jump03,
        jump04,
        jump05,
        jump06,
        jump07,
        run01,
        run02,
        run03,
        run04,
        attack01,
        attack02,
        attack03,
        attack04,
        attack05,
        attack06,
        attack07,
        attack08,
        attack11,
        attack12,
        attack13,
        attack14,
        attack15,
        pain01,
        pain02,
        pain03,
        pain04,
        death01,
        death02,
        death03,
        death04,
        death05,
        death06,
        death07,
        death08,
        death09,
        twitch01,
        twitch02,
        twitch03,
        twitch04,
        twitch05,
        twitch06,
        twitch07,
        twitch08,
        twitch09,
        twitch10,
        reactive01,
        reactive02,
        reactive03,
        reactive04
    };

    const float SCALE = 1.000000f;
}

namespace stalker::sounds
{
    cached_soundindex pain("stalker/pain.wav");
    cached_soundindex die("stalker/death.wav");
    cached_soundindex sight("stalker/sight.wav");
    cached_soundindex punch_hit1("stalker/melee1.wav");
    cached_soundindex punch_hit2("stalker/melee2.wav");
    cached_soundindex idle("stalker/idle.wav");
}

bool STALKER_ON_CEILING(ASEntity &ent)
{
	return (ent.gravityVector[2] > 0);
}

//=========================
//=========================
bool stalker_ok_to_transition(ASEntity &self)
{
	trace_t trace;
	vec3_t	pt, start;
	float	max_dist;
	float	margin;
	float	end_height;

	if (STALKER_ON_CEILING(self))
	{
		// [Paril-KEX] if we get knocked off the ceiling, always
		// fall downwards
		if (self.groundentity is null)
			return true;

		max_dist = -384;
		margin = self.e.mins[2] - 8;
	}
	else
	{
		// her stalkers are just better
		if (self.monsterinfo.commander !is null && self.monsterinfo.commander.e.inuse &&
            Q_strncasecmp(self.monsterinfo.commander.classname, "monster_widow", 13) == 0)
			max_dist = 256;
		else
			max_dist = 180;
		margin = self.e.maxs[2] + 8;
	}

	pt = self.e.s.origin;
	pt[2] += max_dist;
	trace = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, pt, self.e, contents_t::MASK_MONSTERSOLID);

	if (trace.fraction == 1.0f ||
		(trace.contents & contents_t::SOLID) == 0 ||
		(trace.ent !is world.e))
	{
		if (STALKER_ON_CEILING(self))
		{
			if (trace.plane.normal[2] < 0.9f)
				return false;
		}
		else
		{
			if (trace.plane.normal[2] > -0.9f)
				return false;
		}
	}

	end_height = trace.endpos[2];

	// check the four corners, tracing only to the endpoint of the center trace (vertically).
	pt[0] = self.e.absmin[0];
	pt[1] = self.e.absmin[1];
	pt[2] = trace.endpos[2] + margin; // give a little margin of error to allow slight inclines
	start = pt;
	start[2] = self.e.s.origin[2];
	trace = gi_traceline(start, pt, self.e, contents_t::MASK_MONSTERSOLID);
	if (trace.fraction == 1.0f || (trace.contents & contents_t::SOLID) == 0 || (trace.ent !is world.e))
		return false;
	if (abs(end_height + margin - trace.endpos[2]) > 8)
		return false;

	pt[0] = self.e.absmax[0];
	pt[1] = self.e.absmin[1];
	start = pt;
	start[2] = self.e.s.origin[2];
	trace = gi_traceline(start, pt, self.e, contents_t::MASK_MONSTERSOLID);
	if (trace.fraction == 1.0f || (trace.contents & contents_t::SOLID) == 0 || (trace.ent !is world.e))
		return false;
	if (abs(end_height + margin - trace.endpos[2]) > 8)
		return false;

	pt[0] = self.e.absmax[0];
	pt[1] = self.e.absmax[1];
	start = pt;
	start[2] = self.e.s.origin[2];
	trace = gi_traceline(start, pt, self.e, contents_t::MASK_MONSTERSOLID);
	if (trace.fraction == 1.0f || (trace.contents & contents_t::SOLID) == 0 || (trace.ent !is world.e))
		return false;
	if (abs(end_height + margin - trace.endpos[2]) > 8)
		return false;

	pt[0] = self.e.absmin[0];
	pt[1] = self.e.absmax[1];
	start = pt;
	start[2] = self.e.s.origin[2];
	trace = gi_traceline(start, pt, self.e, contents_t::MASK_MONSTERSOLID);
	if (trace.fraction == 1.0f || (trace.contents & contents_t::SOLID) == 0 || (trace.ent !is world.e))
		return false;
	if (abs(end_height + margin - trace.endpos[2]) > 8)
		return false;

	return true;
}

//=========================
//=========================
void stalker_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, stalker::sounds::sight, 1, ATTN_NORM, 0);
}

// ******************
// IDLE
// ******************

void stalker_idle_noise(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, stalker::sounds::idle, 0.5, ATTN_IDLE, 0);
}

const array<mframe_t> stalker_frames_idle = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, stalker_idle_noise),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand)
};
const mmove_t stalker_move_idle = mmove_t(stalker::frames::idle01, stalker::frames::idle21, stalker_frames_idle, stalker_stand);

const array<mframe_t> stalker_frames_idle2 = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t stalker_move_idle2 = mmove_t(stalker::frames::idle201, stalker::frames::idle213, stalker_frames_idle2, stalker_stand);

void stalker_idle(ASEntity &self)
{
	if (frandom() < 0.35f)
		M_SetAnimation(self, stalker_move_idle);
	else
		M_SetAnimation(self, stalker_move_idle2);
}

// ******************
// STAND
// ******************

const array<mframe_t> stalker_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, stalker_idle_noise),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand)
};
const mmove_t stalker_move_stand = mmove_t(stalker::frames::idle01, stalker::frames::idle21, stalker_frames_stand, stalker_stand);

void stalker_stand(ASEntity &self)
{
	if (frandom() < 0.25f)
		M_SetAnimation(self, stalker_move_stand);
	else
		M_SetAnimation(self, stalker_move_idle2);
}

// ******************
// RUN
// ******************

const array<mframe_t> stalker_frames_run = {
	mframe_t(ai_run, 13, monster_footstep),
	mframe_t(ai_run, 17),
	mframe_t(ai_run, 21, monster_footstep),
	mframe_t(ai_run, 18)
};
const mmove_t stalker_move_run = mmove_t(stalker::frames::run01, stalker::frames::run04, stalker_frames_run, null);

void stalker_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, stalker_move_stand);
	else
		M_SetAnimation(self, stalker_move_run);
}

// ******************
// WALK
// ******************

const array<mframe_t> stalker_frames_walk = {
	mframe_t(ai_walk, 4, monster_footstep),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 5),

	mframe_t(ai_walk, 4, monster_footstep),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 4)
};
const mmove_t stalker_move_walk = mmove_t(stalker::frames::walk01, stalker::frames::walk08, stalker_frames_walk, stalker_walk);

void stalker_walk(ASEntity &self)
{
	M_SetAnimation(self, stalker_move_walk);
}

// ******************
// false death
// ******************
const array<mframe_t> stalker_frames_reactivate = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t stalker_move_false_death_end = mmove_t(stalker::frames::reactive01, stalker::frames::reactive04, stalker_frames_reactivate, stalker_run);

void stalker_reactivate(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STAND_GROUND);
	M_SetAnimation(self, stalker_move_false_death_end);
}

void stalker_heal(ASEntity &self)
{
	if (skill.integer == 2)
		self.health += 2;
	else if (skill.integer == 3)
		self.health += 3;
	else
		self.health++;

	self.monsterinfo.setskin(self);

	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		stalker_reactivate(self);
	}
}

const array<mframe_t> stalker_frames_false_death = {
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),

	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal),
	mframe_t(ai_move, 0, stalker_heal)
};
const mmove_t stalker_move_false_death = mmove_t(stalker::frames::twitch01, stalker::frames::twitch10, stalker_frames_false_death, stalker_false_death);

void stalker_false_death(ASEntity &self)
{
	M_SetAnimation(self, stalker_move_false_death);
}

const array<mframe_t> stalker_frames_false_death_start = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
};
const mmove_t stalker_move_false_death_start = mmove_t(stalker::frames::death01, stalker::frames::death09, stalker_frames_false_death_start, stalker_false_death);

void stalker_false_death_start(ASEntity &self)
{
	self.e.s.angles[2] = 0;
	self.gravityVector = vec3_t(0, 0, -1);

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::STAND_GROUND);
	M_SetAnimation(self, stalker_move_false_death_start);
}

// ******************
// PAIN
// ******************

const array<mframe_t> stalker_frames_pain = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t stalker_move_pain = mmove_t(stalker::frames::pain01, stalker::frames::pain04, stalker_frames_pain, stalker_run);

void stalker_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (self.deadflag)
		return;

	if (self.groundentity is null)
		return;

	// if we're reactivating or false dying, ignore the pain.
	if (self.monsterinfo.active_move is stalker_move_false_death_end ||
		self.monsterinfo.active_move is stalker_move_false_death_start)
		return;

	if (self.monsterinfo.active_move is stalker_move_false_death)
	{
		stalker_reactivate(self);
		return;
	}

	if ((self.health > 0) && (self.health < (self.max_health / 4)))
	{
		if (frandom() < 0.30f)
		{
			if (!STALKER_ON_CEILING(self) || stalker_ok_to_transition(self))
			{
				stalker_false_death_start(self);
				return;
			}
		}
	}

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	gi_sound(self.e, soundchan_t::VOICE, stalker::sounds::pain, 1, ATTN_NORM, 0);

	if (mod.id == mod_id_t::CHAINFIST || damage > 10) // don't react unless the damage was significant
	{
		// stalker should dodge jump periodically to help avoid damage.
		if (self.groundentity !is null && (frandom() < 0.5f))
			stalker_dodge_jump(self);
		else if (M_ShouldReactToPain(self, mod)) // no pain anims in nightmare
			M_SetAnimation(self, stalker_move_pain);
	}
}

void stalker_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

// ******************
// STALKER ATTACK
// ******************

void stalker_shoot_attack(ASEntity &self)
{
	vec3_t	offset, start, f, r, dir;
	vec3_t	end;
	float	dist;
	trace_t trace;

	if (!has_valid_enemy(self))
		return;

	if (self.groundentity !is null && frandom() < 0.33f)
	{
		dir = self.enemy.e.s.origin - self.e.s.origin;
		dist = dir.length();

		if ((dist > 256) || (frandom() < 0.5f))
			stalker_do_pounce(self, self.enemy.e.s.origin);
		else
			stalker_jump_straightup(self);
	}

	AngleVectors(self.e.s.angles, f, r);
	offset = { 24, 0, 6 };
	start = M_ProjectFlashSource(self, offset, f, r);

	dir = self.enemy.e.s.origin - start;
	if (frandom() < 0.3f)
		PredictAim(self, self.enemy, start, 1000, true, 0, dir, end);
	else
		end = self.enemy.e.s.origin;

	trace = gi_traceline(start, end, self.e, contents_t::MASK_PROJECTILE);
	if (trace.ent is self.enemy.e || trace.ent is world.e)
	{
		dir.normalize();
		monster_fire_blaster2(self, start, dir, 5, 800, monster_muzzle_t::STALKER_BLASTER, effects_t::BLASTER);
	}
}

void stalker_shoot_attack2(ASEntity &self)
{
	if (frandom() < 0.5)
		stalker_shoot_attack(self);
}

const array<mframe_t> stalker_frames_shoot = {
	mframe_t(ai_charge, 13),
	mframe_t(ai_charge, 17, stalker_shoot_attack),
	mframe_t(ai_charge, 21),
	mframe_t(ai_charge, 18, stalker_shoot_attack2)
};
const mmove_t stalker_move_shoot = mmove_t(stalker::frames::run01, stalker::frames::run04, stalker_frames_shoot, stalker_run);

void stalker_attack_ranged(ASEntity &self)
{
	if (!has_valid_enemy(self))
		return;

	// PMM - circle strafe stuff
	if (frandom() > 0.5f)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
	}
	else
	{
		if (frandom() <= 0.5f) // switch directions
			self.monsterinfo.lefty = !self.monsterinfo.lefty;
		self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
	}
	M_SetAnimation(self, stalker_move_shoot);
}

// ******************
// close combat
// ******************

void stalker_swing_attack(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, 0, 0 };
	if (fire_hit(self, aim, irandom(5, 10), 50))
	{
		if (self.e.s.frame < stalker::frames::attack08)
			gi_sound(self.e, soundchan_t::WEAPON, stalker::sounds::punch_hit2, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::WEAPON, stalker::sounds::punch_hit1, 1, ATTN_NORM, 0);
	}
	else
		self.monsterinfo.melee_debounce_time = level.time + time_sec(0.8);
}

const array<mframe_t> stalker_frames_swing_l = {
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 10, monster_footstep),

	mframe_t(ai_charge, 5, stalker_swing_attack),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 5, monster_footstep) // stalker_swing_check_l
};
const mmove_t stalker_move_swing_l = mmove_t(stalker::frames::attack01, stalker::frames::attack08, stalker_frames_swing_l, stalker_run);

const array<mframe_t> stalker_frames_swing_r = {
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 6, monster_footstep),
	mframe_t(ai_charge, 6, stalker_swing_attack),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 5, monster_footstep) // stalker_swing_check_r
};
const mmove_t stalker_move_swing_r = mmove_t(stalker::frames::attack11, stalker::frames::attack15, stalker_frames_swing_r, stalker_run);

void stalker_attack_melee(ASEntity &self)
{
	if (!has_valid_enemy(self))
		return;

	if (frandom() < 0.5f)
		M_SetAnimation(self, stalker_move_swing_l);
	else
		M_SetAnimation(self, stalker_move_swing_r);
}

// ******************
// POUNCE
// ******************

// ====================
// ====================
bool stalker_check_lz(ASEntity &self, ASEntity &target, const vec3_t &in dest)
{
	if ((gi_pointcontents(dest) & contents_t::MASK_WATER) != 0 || (target.waterlevel != water_level_t::NONE))
		return false;

	if (target.groundentity is null)
		return false;

	vec3_t jumpLZ;

	// check under the player's four corners
	// if they're not solid, bail.
	jumpLZ[0] = self.enemy.e.mins[0];
	jumpLZ[1] = self.enemy.e.mins[1];
	jumpLZ[2] = self.enemy.e.mins[2] - 0.25f;
	if ((gi_pointcontents(jumpLZ) & contents_t::MASK_SOLID) == 0)
		return false;

	jumpLZ[0] = self.enemy.e.maxs[0];
	jumpLZ[1] = self.enemy.e.mins[1];
	if ((gi_pointcontents(jumpLZ) & contents_t::MASK_SOLID) == 0)
		return false;

	jumpLZ[0] = self.enemy.e.maxs[0];
	jumpLZ[1] = self.enemy.e.maxs[1];
	if ((gi_pointcontents(jumpLZ) & contents_t::MASK_SOLID) == 0)
		return false;

	jumpLZ[0] = self.enemy.e.mins[0];
	jumpLZ[1] = self.enemy.e.maxs[1];
	if ((gi_pointcontents(jumpLZ) & contents_t::MASK_SOLID) == 0)
		return false;

	return true;
}

// ====================
// ====================
bool stalker_do_pounce(ASEntity &self, const vec3_t &in dest)
{
	vec3_t	dist;
	float	length;
	vec3_t	jumpAngles;
	vec3_t	jumpLZ;
	float	velocity = 400.1f;

	// don't pounce when we're on the ceiling
	if (STALKER_ON_CEILING(self))
		return false;

	if (!stalker_check_lz(self, self.enemy, dest))
		return false;

	dist = dest - self.e.s.origin;

	// make sure we're pointing in that direction 15deg margin of error.
	jumpAngles = vectoangles(dist);
	if (abs(jumpAngles.yaw - self.e.s.angles.yaw) > 45)
		return false; // not facing the player...

	if (isnan(jumpAngles.yaw))
		return false; // Switch why

	self.ideal_yaw = jumpAngles.yaw;
	M_ChangeYaw(self);

	length = dist.length();
	if (length > 450)
		return false; // can't jump that far...

	jumpLZ = dest;
	vec3_t dir = dist.normalized();

	// find a valid angle/velocity combination
	while (velocity <= 800)
	{
		if (M_CalculatePitchToFire(self, jumpLZ, self.e.s.origin, dir, velocity, 3, false, true))
			break;

		velocity += 200;
	}

	// nothing found
	if (velocity > 800)
		return false;

	self.velocity = dir * velocity;
	return true;
}

// ******************
// DODGE
// ******************

//===================
// stalker_jump_straightup
//===================
void stalker_jump_straightup(ASEntity &self)
{
	if (self.deadflag)
		return;

	if (STALKER_ON_CEILING(self))
	{
		if (stalker_ok_to_transition(self))
		{
			self.gravityVector[2] = -1;
			self.e.s.angles[2] += 180.0f;
			if (self.e.s.angles[2] > 360.0f)
				self.e.s.angles[2] -= 360.0f;
			@self.groundentity = null;
		}
	}
	else if (self.groundentity !is null) // make sure we're standing on SOMETHING...
	{
		self.velocity[0] += crandom() * 5;
		self.velocity[1] += crandom() * 5;
		self.velocity[2] += -400 * self.gravityVector[2];
		if (stalker_ok_to_transition(self))
		{
			self.gravityVector[2] = 1;
			self.e.s.angles[2] = 180.0;
			@self.groundentity = null;
		}
	}
}

const array<mframe_t> stalker_frames_jump_straightup = {
	mframe_t(ai_move, 1, stalker_jump_straightup),
	mframe_t(ai_move, 1, stalker_jump_wait_land),
	mframe_t(ai_move, -1, monster_footstep),
	mframe_t(ai_move, -1)
};

const mmove_t stalker_move_jump_straightup = mmove_t(stalker::frames::jump04, stalker::frames::jump07, stalker_frames_jump_straightup, stalker_run);

//===================
// stalker_dodge_jump - abstraction so pain function can trigger a dodge jump too without
//		faking the inputs to stalker_dodge
//===================
void stalker_dodge_jump(ASEntity &self)
{
	M_SetAnimation(self, stalker_move_jump_straightup);
}

/*
const array<mframe_t> stalker_frames_dodge_run = {
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 17),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 18, monster_done_dodge)
};
const mmove_t stalker_move_dodge_run = mmove_t(stalker::frames::run01, stalker::frames::run04, stalker_frames_dodge_run, null);
*/

void stalker_dodge(ASEntity &self, ASEntity &attacker, gtime_t eta, const trace_t &in tr, bool gravity, bool not_trace)
{
	if (self.groundentity is null || self.health <= 0)
		return;

	if (self.enemy is null)
	{
		@self.enemy = attacker;
		FoundTarget(self);
		return;
	}

	// PMM - don't bother if it's going to hit anyway; fix for weird in-your-face etas (I was
	// seeing numbers like 13 and 14)
	if ((eta < FRAME_TIME_MS) || (eta > time_sec(5)))
		return;

	if (self.timestamp > level.time)
		return;

	self.timestamp = level.time + random_time(time_sec(1), time_sec(5));
	// this will override the foundtarget call of stalker_run
	stalker_dodge_jump(self);
}

// ******************
// Jump onto / off of things
// ******************

//===================
//===================
void stalker_jump_down(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

//===================
//===================
void stalker_jump_up(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 200);
	self.velocity += (up * 450);
}

//===================
//===================
void stalker_jump_wait_land(ASEntity &self)
{
	if ((frandom() < 0.4f) && (level.time >= self.monsterinfo.attack_finished))
	{
		self.monsterinfo.attack_finished = level.time + time_ms(300);
		stalker_shoot_attack(self);
	}

	if (self.groundentity is null)
	{
		self.gravity = 1.3f;
		self.monsterinfo.nextframe = self.e.s.frame;

		if (monster_jump_finished(self))
		{
			self.gravity = 1;
			self.monsterinfo.nextframe = self.e.s.frame + 1;
		}
	}
	else
	{
		self.gravity = 1;
		self.monsterinfo.nextframe = self.e.s.frame + 1;
	}
}

const array<mframe_t> stalker_frames_jump_up = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8),

	mframe_t(ai_move, 0, stalker_jump_up),
	mframe_t(ai_move, 0, stalker_jump_wait_land),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t stalker_move_jump_up = mmove_t(stalker::frames::jump01, stalker::frames::jump07, stalker_frames_jump_up, stalker_run);

const array<mframe_t> stalker_frames_jump_down = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move, 0, stalker_jump_down),
	mframe_t(ai_move, 0, stalker_jump_wait_land),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t stalker_move_jump_down = mmove_t(stalker::frames::jump01, stalker::frames::jump07, stalker_frames_jump_down, stalker_run);

//============
// stalker_jump - this is only used for jumping onto or off of things. for dodge jumping,
//		use stalker_dodge_jump
//============
void stalker_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, stalker_move_jump_up);
	else
		M_SetAnimation(self, stalker_move_jump_down);
}

// ******************
// Blocked
// ******************
bool stalker_blocked(ASEntity &self, float dist)
{
	if (!has_valid_enemy(self))
		return false;

	bool onCeiling = STALKER_ON_CEILING(self);

	if (!onCeiling)
	{
        auto result = blocked_checkjump(self, dist);

		if (result != blocked_jump_result_t::NO_JUMP)
		{
			if (result != blocked_jump_result_t::JUMP_TURN)
				stalker_jump(self, result);
			return true;
		}

		if (blocked_checkplat(self, dist))
			return true;

		if (visible(self, self.enemy) && frandom() < 0.1f)
		{
			stalker_do_pounce(self, self.enemy.e.s.origin);
			return true;
		}
	}
	else
	{
		if (stalker_ok_to_transition(self))
		{
			self.gravityVector[2] = -1;
			self.e.s.angles[2] += 180.0f;
			if (self.e.s.angles[2] > 360.0f)
				self.e.s.angles[2] -= 360.0f;
			@self.groundentity = null;
			return true;
		}
	}

	return false;
}

// [Paril-KEX] quick patch-job to fix stalkers endlessly floating up into the sky
void stalker_physics_change(ASEntity &self)
{
	if (STALKER_ON_CEILING(self) && self.groundentity is null)
	{
		self.gravityVector[2] = -1;
		self.e.s.angles[2] += 180.0f;
		if (self.e.s.angles[2] > 360.0f)
			self.e.s.angles[2] -= 360.0f;
	}
}

// ******************
// Death
// ******************

void stalker_dead(ASEntity &self)
{
	self.e.mins = { -28, -28, -18 };
	self.e.maxs = { 28, 28, -4 };
	monster_dead(self);
}

const array<mframe_t> stalker_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -10),
	mframe_t(ai_move, -20),

	mframe_t(ai_move, -10),
	mframe_t(ai_move, -10),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -5),

	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t stalker_move_death = mmove_t(stalker::frames::death01, stalker::frames::death09, stalker_frames_death, stalker_dead);

void stalker_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// dude bit it, make him fall!
	self.movetype = movetype_t::TOSS;
	self.e.s.angles[2] = 0;
	self.gravityVector = { 0, 0, -1 };

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
			gib_def_t("models/monsters/stalker/gibs/bodya.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/stalker/gibs/bodyb.md2", gib_type_t::SKINNED),
			gib_def_t(2, "models/monsters/stalker/gibs/claw.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t(2, "models/monsters/stalker/gibs/leg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t(2, "models/monsters/stalker/gibs/foot.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/stalker/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, stalker::sounds::die, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;
	M_SetAnimation(self, stalker_move_death);
}

// ******************
// SPAWN
// ******************

/*QUAKED monster_stalker (1 .5 0) (-28 -28 -18) (28 28 18) Ambush Trigger_Spawn Sight OnRoof NoJumping
Spider Monster

  ONROOF - Monster starts sticking to the roof.
*/

namespace spawnflags::stalker
{
    const spawnflags_t ONROOF = spawnflag_dec(8);
    const spawnflags_t NOJUMPING = spawnflag_dec(16);
}

void SP_monster_stalker(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	stalker::sounds::pain.precache();
	stalker::sounds::die.precache();
	stalker::sounds::sight.precache();
	stalker::sounds::punch_hit1.precache();
	stalker::sounds::punch_hit2.precache();
	stalker::sounds::idle.precache();

	// PMM - precache bolt2
	gi_modelindex("models/objects/laser/tris.md2");

	self.e.s.modelindex = gi_modelindex("models/monsters/stalker/tris.md2");

	gi_modelindex("models/monsters/stalker/gibs/bodya.md2");
	gi_modelindex("models/monsters/stalker/gibs/bodyb.md2");
	gi_modelindex("models/monsters/stalker/gibs/claw.md2");
	gi_modelindex("models/monsters/stalker/gibs/foot.md2");
	gi_modelindex("models/monsters/stalker/gibs/head.md2");
	gi_modelindex("models/monsters/stalker/gibs/leg.md2");

	self.e.mins = { -28, -28, -18 };
	self.e.maxs = { 28, 28, 18 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(250 * st.health_multiplier);
	self.gib_health = -50;
	self.mass = 250;

	@self.pain = stalker_pain;
	@self.die = stalker_die;

	@self.monsterinfo.stand = stalker_stand;
	@self.monsterinfo.walk = stalker_walk;
	@self.monsterinfo.run = stalker_run;
	@self.monsterinfo.attack = stalker_attack_ranged;
	@self.monsterinfo.sight = stalker_sight;
	@self.monsterinfo.idle = stalker_idle;
	@self.monsterinfo.dodge = stalker_dodge;
	@self.monsterinfo.blocked = stalker_blocked;
	@self.monsterinfo.melee = stalker_attack_melee;
	@self.monsterinfo.setskin = stalker_setskin;
	@self.monsterinfo.physics_change = stalker_physics_change;

	gi_linkentity(self.e);

	M_SetAnimation(self, stalker_move_stand);
	self.monsterinfo.scale = stalker::SCALE;

	if (self.spawnflags.has(spawnflags::stalker::ONROOF))
	{
		self.e.s.angles[2] = 180;
		self.gravityVector[2] = 1;
	}

	self.monsterinfo.can_jump = !self.spawnflags.has(spawnflags::stalker::NOJUMPING);
	self.monsterinfo.drop_height = 256;
	self.monsterinfo.jump_height = 68;

	walkmonster_start(self);
}
