// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

GUARDIAN

==============================================================================
*/

namespace guardian
{
    enum frames {
        sleep1,
        sleep2,
        sleep3,
        sleep4,
        sleep5,
        sleep6,
        sleep7,
        sleep8,
        sleep9,
        sleep10,
        sleep11,
        sleep12,
        sleep13,
        sleep14,
        death1,
        death2,
        death3,
        death4,
        death5,
        death6,
        death7,
        death8,
        death9,
        death10,
        death11,
        death12,
        death13,
        death14,
        death15,
        death16,
        death17,
        death18,
        death19,
        death20,
        death21,
        death22,
        death23,
        death24,
        death25,
        death26,
        atk1_out1,
        atk1_out2,
        atk1_out3,
        atk2_out1,
        atk2_out2,
        atk2_out3,
        atk2_out4,
        atk2_out5,
        atk2_out6,
        atk2_out7,
        kick_out1,
        kick_out2,
        kick_out3,
        kick_out4,
        kick_out5,
        kick_out6,
        kick_out7,
        kick_out8,
        kick_out9,
        kick_out10,
        kick_out11,
        kick_out12,
        pain1_1,
        pain1_2,
        pain1_3,
        pain1_4,
        pain1_5,
        pain1_6,
        pain1_7,
        pain1_8,
        idle1,
        idle2,
        idle3,
        idle4,
        idle5,
        idle6,
        idle7,
        idle8,
        idle9,
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
        idle22,
        idle23,
        idle24,
        idle25,
        idle26,
        idle27,
        idle28,
        idle29,
        idle30,
        idle31,
        idle32,
        idle33,
        idle34,
        idle35,
        idle36,
        idle37,
        idle38,
        idle39,
        idle40,
        idle41,
        idle42,
        idle43,
        idle44,
        idle45,
        idle46,
        idle47,
        idle48,
        idle49,
        idle50,
        idle51,
        idle52,
        atk1_in1,
        atk1_in2,
        atk1_in3,
        kick_in1,
        kick_in2,
        kick_in3,
        kick_in4,
        kick_in5,
        kick_in6,
        kick_in7,
        kick_in8,
        kick_in9,
        kick_in10,
        kick_in11,
        kick_in12,
        kick_in13,
        walk1,
        walk2,
        walk3,
        walk4,
        walk5,
        walk6,
        walk7,
        walk8,
        walk9,
        walk10,
        walk11,
        walk12,
        walk13,
        walk14,
        walk15,
        walk16,
        walk17,
        walk18,
        walk19,
        wake1,
        wake2,
        wake3,
        wake4,
        wake5,
        atk1_spin1,
        atk1_spin2,
        atk1_spin3,
        atk1_spin4,
        atk1_spin5,
        atk1_spin6,
        atk1_spin7,
        atk1_spin8,
        atk1_spin9,
        atk1_spin10,
        atk1_spin11,
        atk1_spin12,
        atk1_spin13,
        atk1_spin14,
        atk1_spin15,
        atk2_fire1,
        atk2_fire2,
        atk2_fire3,
        atk2_fire4,
        turnl_1,
        turnl_2,
        turnl_3,
        turnl_4,
        turnl_5,
        turnl_6,
        turnl_7,
        turnl_8,
        turnl_9,
        turnl_10,
        turnl_11,
        turnr_1,
        turnr_2,
        turnr_3,
        turnr_4,
        turnr_5,
        turnr_6,
        turnr_7,
        turnr_8,
        turnr_9,
        turnr_10,
        turnr_11,
        atk2_in1,
        atk2_in2,
        atk2_in3,
        atk2_in4,
        atk2_in5,
        atk2_in6,
        atk2_in7,
        atk2_in8,
        atk2_in9,
        atk2_in10,
        atk2_in11,
        atk2_in12
    };

    const float SCALE	= 1.000000;
}

namespace guardian::sounds
{
    cached_soundindex step("zortemp/step.wav");
    cached_soundindex charge("weapons/hyprbu1a.wav");
    cached_soundindex spin_loop("weapons/hyprbl1a.wav");
    cached_soundindex laser("weapons/laser2.wav");
    cached_soundindex pew("makron/blaster.wav");

    cached_soundindex sight("guardian/sight.wav");
    cached_soundindex pain1("guardian/pain1.wav");
    cached_soundindex pain2("guardian/pain2.wav");
    cached_soundindex death("guardian/death.wav");
}

//
// stand
//

const array<mframe_t> guardian_frames_stand = {
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
const mmove_t guardian_move_stand = mmove_t(guardian::frames::idle1, guardian::frames::idle52, guardian_frames_stand, null);

namespace spawnflags::guardian
{
    const spawnflags_t SLEEPY = spawnflag_dec(8);
}

/*
=============
ai_sleep

honk shoo honk shoo
==============
*/
void ai_sleep(ASEntity &self, float dist)
{
}

const array<mframe_t> guardian_frames_sleep = {
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep)
};
const mmove_t guardian_move_sleep = mmove_t(guardian::frames::sleep1, guardian::frames::sleep14, guardian_frames_sleep, null);

void guardian_stand(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::guardian::SLEEPY))
		M_SetAnimation(self, guardian_move_sleep);
	else
		M_SetAnimation(self, guardian_move_stand);
}

const array<mframe_t> guardian_frames_wake = {
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep),
	mframe_t(ai_sleep)
};
const mmove_t guardian_move_wake = mmove_t(guardian::frames::wake1, guardian::frames::wake5, guardian_frames_wake, guardian_run);

void guardian_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.spawnflags &= ~spawnflags::guardian::SLEEPY;
	M_SetAnimation(self, guardian_move_wake);
	@self.use = monster_use;
	gi_sound(self.e, soundchan_t::BODY, guardian::sounds::sight, 1.f, 0.1f, 0.0f);
}

//
// walk
//

void guardian_footstep(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, guardian::sounds::step, 1.f, 0.1f, 0.0f);
}

const array<mframe_t> guardian_frames_walk = {
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8, guardian_footstep),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8, guardian_footstep),
	mframe_t(ai_walk, 8)
};
const mmove_t guardian_move_walk = mmove_t(guardian::frames::walk1, guardian::frames::walk19, guardian_frames_walk, null);

void guardian_walk(ASEntity &self)
{
	M_SetAnimation(self, guardian_move_walk);
}

//
// run
//

const array<mframe_t> guardian_frames_run = {
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8, guardian_footstep),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8, guardian_footstep),
	mframe_t(ai_run, 8)
};
const mmove_t guardian_move_run = mmove_t(guardian::frames::walk1, guardian::frames::walk19, guardian_frames_run, null);

void guardian_run(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		M_SetAnimation(self, guardian_move_stand);
		return;
	}

	M_SetAnimation(self, guardian_move_run);
}

//
// pain
//

const array<mframe_t> guardian_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guardian_move_pain1 = mmove_t(guardian::frames::pain1_1, guardian::frames::pain1_8, guardian_frames_pain1, guardian_run);

void guardian_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (mod.id != mod_id_t::CHAINFIST && damage <= 10)
		return;

	if (level.time < self.pain_debounce_time)
		return;

	if (mod.id != mod_id_t::CHAINFIST && damage <= 75)
		if (frandom() > 0.2f)
			return;

	// don't go into pain while attacking
	if ((self.e.s.frame >= guardian::frames::atk1_spin1) && (self.e.s.frame <= guardian::frames::atk1_spin15))
		return;
	if ((self.e.s.frame >= guardian::frames::atk2_fire1) && (self.e.s.frame <= guardian::frames::atk2_fire4))
		return;
	if ((self.e.s.frame >= guardian::frames::kick_in1) && (self.e.s.frame <= guardian::frames::kick_in13))
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	if (brandom())
		gi_sound(self.e, soundchan_t::BODY, guardian::sounds::pain1, 1.f, 0.1f, 0.0f);
	else
		gi_sound(self.e, soundchan_t::BODY, guardian::sounds::pain2, 1.f, 0.1f, 0.0f);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	M_SetAnimation(self, guardian_move_pain1);
	self.monsterinfo.weapon_sound = 0;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
}

const array<mframe_t> guardian_frames_atk1_out = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_atk1_out = mmove_t(guardian::frames::atk1_out1, guardian::frames::atk1_out3, guardian_frames_atk1_out, guardian_run);

void guardian_atk1_finish(ASEntity &self)
{
	M_SetAnimation(self, guardian_atk1_out);
	self.monsterinfo.weapon_sound = 0;
}

void guardian_atk1_charge(ASEntity &self)
{
	self.monsterinfo.weapon_sound = guardian::sounds::spin_loop;
	gi_sound(self.e, soundchan_t::WEAPON, guardian::sounds::charge, 1.f, ATTN_NORM, 0.f);
}

void guardian_fire_blaster(ASEntity &self)
{
	vec3_t forward, right, up, aimpt;
	vec3_t start;
	monster_muzzle_t id = monster_muzzle_t::GUARDIAN_BLASTER;

	if (self.enemy is null || !self.enemy.e.inuse)
	{
		self.monsterinfo.nextframe = guardian::frames::atk1_spin13;
		return;
	}

	AngleVectors(self.e.s.angles, forward, right, up);
	start = M_ProjectFlashSource(self, monster_flash_offset[id], forward, right);
	PredictAim(self, self.enemy, start, 1000, false, crandom() * 0.1f, forward, aimpt);
	forward += right * crandom() * 0.02f;
	forward += up * crandom() * 0.02f;
	forward.normalize();

	ASEntity @bolt = monster_fire_blaster(self, start, forward, 3, 1100, id, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::HYPERBLASTER);
	bolt.e.s.scale = 2.0f;

	if (self.enemy !is null && self.enemy.health > 0 && 
		self.e.s.frame == guardian::frames::atk1_spin12 && self.timestamp > level.time && visible(self, self.enemy))
		self.monsterinfo.nextframe = guardian::frames::atk1_spin5;
}

const array<mframe_t> guardian_frames_atk1_spin = {
	mframe_t(ai_charge, 0, guardian_atk1_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0, guardian_fire_blaster),
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 0)
};
const mmove_t guardian_move_atk1_spin = mmove_t(guardian::frames::atk1_spin1, guardian::frames::atk1_spin15, guardian_frames_atk1_spin, guardian_atk1_finish);

void guardian_atk1(ASEntity &self)
{
	M_SetAnimation(self, guardian_move_atk1_spin);
	self.timestamp = level.time + time_ms(650) + random_time(time_sec(1.5));
}

const array<mframe_t> guardian_frames_atk1_in = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_move_atk1_in = mmove_t(guardian::frames::atk1_in1, guardian::frames::atk1_in3, guardian_frames_atk1_in, guardian_atk1);

const array<mframe_t> guardian_frames_atk2_out = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_move_atk2_out = mmove_t(guardian::frames::atk2_out1, guardian::frames::atk2_out7, guardian_frames_atk2_out, guardian_run);

void guardian_atk2_out(ASEntity &self)
{
	M_SetAnimation(self, guardian_move_atk2_out);
}

const array<vec3_t> laser_positions = {
	{ 125.0f, -70.f, 60.f },
	{ 112.0f, -62.f, 60.f }
};

void guardian_fire_update(ASEntity &laser)
{
	if (!laser.spawnflags.has(spawnflags::dabeam::SPAWNED))
	{
		ASEntity @self = laser.owner;

		vec3_t forward, right, target;
		vec3_t start;

		AngleVectors(self.e.s.angles, forward, right);
		start = M_ProjectFlashSource(self, laser_positions[laser.spawnflags.has(spawnflags::dabeam::SECONDARY) ? 1 : 0], forward, right);
		PredictAim(self, self.enemy, start, 0, false, 0.3f, forward, target);

		laser.e.s.origin = start;
		forward[0] += crandom() * 0.02f;
		forward[1] += crandom() * 0.02f;
		forward.normalize();
		laser.movedir = forward;
		gi_linkentity(laser.e);
	}
	dabeam_update(laser, false);
}

void guardian_laser_fire(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, guardian::sounds::laser, 1.f, ATTN_NORM, 0.f);
	monster_fire_dabeam(self, 15, (self.e.s.frame & 1) != 0, guardian_fire_update);
}

const array<mframe_t> guardian_frames_atk2_fire = {
	mframe_t(ai_charge, 0, guardian_laser_fire),
	mframe_t(ai_charge, 0, guardian_laser_fire),
	mframe_t(ai_charge, 0, guardian_laser_fire),
	mframe_t(ai_charge, 0, guardian_laser_fire)
};
const mmove_t guardian_move_atk2_fire = mmove_t(guardian::frames::atk2_fire1, guardian::frames::atk2_fire4, guardian_frames_atk2_fire, guardian_atk2_out);

void guardian_atk2(ASEntity &self)
{
	M_SetAnimation(self, guardian_move_atk2_fire);
}

const array<mframe_t> guardian_frames_atk2_in = {
	mframe_t(ai_charge, 0, guardian_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_move_atk2_in = mmove_t(guardian::frames::atk2_in1, guardian::frames::atk2_in12, guardian_frames_atk2_in, guardian_atk2);

void guardian_kick(ASEntity &self)
{
	if (!fire_hit(self, { 160.f, 0, -80.f }, 85, 700))
		self.monsterinfo.melee_debounce_time = level.time + time_ms(3500);
}

const array<mframe_t> guardian_frames_kick = {
	mframe_t(ai_charge, 12.f),
	mframe_t(ai_charge, 18.f, guardian_footstep),
	mframe_t(ai_charge, 11.f),
	mframe_t(ai_charge, 9.f),
	mframe_t(ai_charge, 8.f),
	mframe_t(ai_charge, 0, guardian_kick),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_move_kick = mmove_t(guardian::frames::kick_in1, guardian::frames::kick_in13, guardian_frames_kick, guardian_run);


// RAFAEL
/*
fire_heat
*/

vec3_t heat_guardian_get_dist_vec(ASEntity &heat, ASEntity &target, float dist_to_target)
{
	return (((target.e.s.origin + vec3_t(0.f, 0.f, target.e.mins.z)) + (target.velocity * (clamp(dist_to_target / 500.f, 0.f, 1.f)) * 0.5f)) - heat.e.s.origin).normalized();
}

void heat_guardian_think(ASEntity &self)
{
	ASEntity @acquire = null;
	float	 oldlen = 0;
	float	 olddot = 1;

	if (self.timestamp < level.time)
	{
		vec3_t fwd;
        AngleVectors(self.e.s.angles, fwd);

		if (self.oldenemy !is null)
		{
			@self.enemy = self.oldenemy;
			@self.oldenemy = null;
		}
	
		if (self.enemy !is null)
		{
			@acquire = self.enemy;

			if (acquire.health <= 0 ||
				!visible(self, acquire))
			{
				@self.enemy = @acquire = null;
			}
			else
			{
				float dist_to_target = (self.e.s.origin - acquire.e.s.origin).normalize();
				self.pos1 = heat_guardian_get_dist_vec(self, acquire, dist_to_target);
			}
		}

		if (acquire is null)
		{
			// acquire new target
			ASEntity @target = null;

			while ((@target = findradius(target, self.e.s.origin, 1024)) !is null)
			{
				if (self.owner is target)
					continue;
				if (target.client is null)
					continue;
				if (target.health <= 0)
					continue;
				if (!visible(self, target))
					continue;

				float dist_to_target = (self.e.s.origin - target.e.s.origin).normalize();
				vec3_t vec = heat_guardian_get_dist_vec(self, target, dist_to_target);

				float len = vec.normalize();
				float dot = vec.dot(fwd);

				// targets that require us to turn less are preferred
				if (dot >= olddot)
					continue;

				if (acquire is null || dot < olddot || len < oldlen)
				{
					@acquire = target;
					oldlen = len;
					olddot = dot;
					self.pos1 = vec;
				}
			}
		}
	}

	vec3_t preferred_dir = self.pos1;

	if (acquire !is null)
	{
		if (self.enemy !is acquire)
		{
			gi_sound(self.e, soundchan_t::WEAPON, gi_soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
			@self.enemy = acquire;
		}
	}
	else
		@self.enemy = null;

	float t = self.accel;

	if (self.enemy !is null)
		t *= 0.85f;

	float d = self.movedir.dot(preferred_dir);

	self.movedir = slerp(self.movedir, preferred_dir, t).normalized();
	self.e.s.angles = vectoangles(self.movedir);

	if (self.speed < self.yaw_speed)
	{
		self.speed += self.yaw_speed * gi_frame_time_s;
	}

	self.velocity = self.movedir * self.speed;
	self.nextthink = level.time + FRAME_TIME_MS;
}

void guardian_heat_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	BecomeExplosion1(self);
}

// RAFAEL
void fire_guardian_heat(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, const vec3_t &in rest_dir,
                        int damage, int speed, float damage_radius, int radius_damage, float turn_fraction)
{
	ASEntity @heat;

	@heat = G_Spawn();
	heat.e.s.origin = start;
	heat.movedir = dir;
	heat.e.s.angles = vectoangles(dir);
	heat.velocity = dir * speed;
	heat.movetype = movetype_t::FLYMISSILE;
	heat.e.clipmask = MASK_PROJECTILE;
	heat.flags = ent_flags_t(heat.flags | ent_flags_t::DAMAGEABLE);
	heat.e.solid = solid_t::BBOX;
	heat.e.s.effects = effects_t(heat.e.s.effects | effects_t::ROCKET);
	heat.e.s.modelindex = gi_modelindex("models/objects/rocket/tris.md2");
	heat.e.s.scale = 1.5f;
	@heat.owner = self;
	@heat.touch = rocket_touch;
	heat.speed = speed / 2;
	heat.yaw_speed = speed * 2;
	heat.accel = turn_fraction;
	heat.pos1 = rest_dir;
	heat.e.mins = { -5, -5, -5 };
	heat.e.maxs = { 5, 5, 5 };
	heat.health = 15;
	heat.takedamage = true;
	@heat.die = guardian_heat_die;

	heat.nextthink = level.time + time_sec(0.20);
	@heat.think = heat_guardian_think;

	heat.dmg = damage;
	heat.radius_dmg = radius_damage;
	heat.dmg_radius = damage_radius;
	heat.e.s.sound = gi_soundindex("weapons/rockfly.wav");

	if (visible(heat, self.enemy))
	{
		@heat.oldenemy = self.enemy;
		heat.timestamp = level.time + time_sec(0.6);
		gi_sound(heat.e, soundchan_t::WEAPON, gi_soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
	}

	gi_linkentity(heat.e);
}

// RAFAEL

void guardian_fire_rocket(ASEntity &self, float offset)
{
	vec3_t forward, right, up;
	vec3_t start;

	AngleVectors(self.e.s.angles, forward, right, up);
	start = self.e.s.origin;
	start -= forward * 8.0f;
	start += right * offset;
	start += up * 50.f;

	AngleVectors({ 20.0f, self.e.s.angles[1] - offset, 0.f }, forward);

	fire_guardian_heat(self, start, up, forward, 20, 250, 150, 35, 0.085f);
	gi_sound(self.e, soundchan_t::WEAPON, guardian::sounds::pew, 1.f, 0.5f, 0.0f);
}

void guardian_fire_rocket_l(ASEntity &self)
{
	guardian_fire_rocket(self, -14.0f);
}

void guardian_fire_rocket_r(ASEntity &self)
{
	guardian_fire_rocket(self, 14.0f);
}

void guardian_blind_fire_check(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		vec3_t aim = self.monsterinfo.blind_fire_target - self.e.s.origin;
		self.ideal_yaw = vectoyaw(aim);
	}
}

const array<mframe_t> guardian_frames_rocket = {
	mframe_t(ai_charge, 0, guardian_blind_fire_check),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_fire_rocket_l),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_fire_rocket_r),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_fire_rocket_l),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guardian_fire_rocket_r),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guardian_move_rocket = mmove_t(guardian::frames::turnl_1, guardian::frames::turnr_11, guardian_frames_rocket, guardian_run);

void guardian_attack(ASEntity &self)
{
	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
	{
		float chance;

		// setup shot probabilities
		if (self.count == 0)
			chance = 1.0;
		else if (self.count <= 2)
			chance = 0.4f;
		else
			chance = 0.1f;

		float r = frandom();

		self.monsterinfo.blind_fire_delay += random_time(time_sec(8.5), time_sec(15.5));

		// don't shoot at the origin
		if (!self.monsterinfo.blind_fire_target)
			return;

		// shot the rockets way too soon
		if (self.count != 0 )
		{
			self.count--;
			return;
		}

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		// turn on manual steering to signal both manual steering and blindfire
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
		M_SetAnimation(self, guardian_move_rocket);
		self.monsterinfo.attack_finished = level.time + random_time(time_sec(3));
		return;
	}
	else if (self.bad_area !is null)
	{
		M_SetAnimation(self, guardian_move_atk1_in);
		return;
	}

	float r = range_to(self, self.enemy);
	bool changedAttack = false;

	if (self.monsterinfo.melee_debounce_time < level.time && r < 160.f)
	{
		M_SetAnimation(self, guardian_move_kick);
		changedAttack = true;
		self.style = 0;
	}
	else if (r > 300.f && frandom() < (max(r, 1000.f) / 1200.f))
	{
		if (self.count <= 0 && frandom() < 0.25f)
		{
			M_SetAnimation(self, guardian_move_rocket);
			self.count = 6;
			self.style = 0;
			return;
		}
		else if (M_CheckClearShot(self, laser_positions[0]) && self.style != 1)
		{
			M_SetAnimation(self, guardian_move_atk2_in);
			self.style = 1;
			changedAttack = true;

			if (skill.integer >= 2)
				self.monsterinfo.nextframe = guardian::frames::atk2_in8;
		}
		else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUARDIAN_BLASTER]))
		{
			M_SetAnimation(self, guardian_move_atk1_in);
			changedAttack = true;
			self.style = 0;
		}
	}
	else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUARDIAN_BLASTER]))
	{
		M_SetAnimation(self, guardian_move_atk1_in);
		changedAttack = true;
		self.style = 0;
	}

	if (changedAttack && self.count != 0)
		self.count--;
}

//
// death
//

void guardian_explode(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition((self.e.s.origin + self.e.mins) + vec3_t(frandom() * self.e.size[0], frandom() * self.e.size[1], frandom() * self.e.size[2]));
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);
}

namespace guardian
{
    const array<string> gibs = {
        "models/monsters/guardian/gib1.md2",
        "models/monsters/guardian/gib2.md2",
        "models/monsters/guardian/gib3.md2",
        "models/monsters/guardian/gib4.md2",
        "models/monsters/guardian/gib5.md2",
        "models/monsters/guardian/gib6.md2",
        "models/monsters/guardian/gib7.md2"
    };
}

void guardian_dead(ASEntity &self)
{
	for (int i = 0; i < 3; i++)
		guardian_explode(self);

	ThrowGibs(self, 125, {
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t(4, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[0], gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[1], gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[2], gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[3], gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[4], gib_type_t::METALLIC),
		gib_def_t(2, guardian::gibs[5], gib_type_t::METALLIC),
		gib_def_t(guardian::gibs[6], gib_type_t(gib_type_t::METALLIC | gib_type_t::HEAD))
	});
}

const array<mframe_t> guardian_frames_death1 = {
	mframe_t(ai_move, 0, BossExplode),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guardian_move_death = mmove_t(guardian::frames::death1, guardian::frames::death26, guardian_frames_death1, guardian_dead);

void guardian_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.deadflag)
		return;

	// regular death
	self.monsterinfo.weapon_sound = 0;
	self.deadflag = true;
	self.takedamage = true;

	M_SetAnimation(self, guardian_move_death);
	gi_sound(self.e, soundchan_t::BODY, guardian::sounds::death, 1.f, 0.1f, 0.0f);
}

void GuardianPowerArmor(ASEntity &self)
{
	self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
	// I don't like this, but it works
	if (self.monsterinfo.power_armor_power <= 0)
		self.monsterinfo.power_armor_power += 200 * skill.integer;
}

void GuardianRespondPowerup(ASEntity &self, ASEntity &other)
{
	if ((other.e.s.effects & (effects_t::QUAD | effects_t::DOUBLE | effects_t::DUALFIRE | effects_t::PENT)) != 0)
	{
		GuardianPowerArmor(self);
	}
}

void GuardianPowerups(ASEntity &self)
{
	ASEntity @ent;

	if (coop.integer == 0)
	{
		GuardianRespondPowerup(self, self.enemy);
	}
	else
	{
		for (uint player = 1; player <= max_clients; player++)
		{
			@ent = entities[player];
			if (!ent.e.inuse)
				continue;
			if (ent.client is null)
				continue;
			GuardianRespondPowerup(self, ent);
		}
	}
}

bool Guardian_CheckAttack(ASEntity &self)
{
	if (self.enemy is null)
		return false;

	GuardianPowerups(self);

	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.6f, 0.7f, 0.85f, 0.f);
}

void guardian_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}


//
// monster_guardian
//

/*QUAKED monster_guardian (1 .5 0) (-96 -96 -66) (96 96 62) Ambush Trigger_Spawn Sight
 */
void SP_monster_guardian(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	guardian::sounds::step.precache();
	guardian::sounds::charge.precache();
	guardian::sounds::spin_loop.precache();
	guardian::sounds::laser.precache();
	guardian::sounds::pew.precache();
	
	guardian::sounds::sight.precache();
	guardian::sounds::pain1.precache();
	guardian::sounds::pain2.precache();
	guardian::sounds::death.precache();

	foreach (auto gib : guardian::gibs)
		gi_modelindex(gib);

	self.e.s.modelindex = gi_modelindex("models/monsters/guardian/tris.md2");
	self.e.mins = { -78, -78, -66 };
	self.e.maxs = { 78, 78, 76 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(2500 * st.health_multiplier);
	self.gib_health = -200;

	if (skill.integer >= 3 || coop.integer != 0)
		self.health *= 2;
	else if (skill.integer == 2)
		self.health = int(self.health * 1.5f);

	self.monsterinfo.scale = guardian::SCALE;

	self.mass = 1650;

	@self.pain = guardian_pain;
	@self.die = guardian_die;
	@self.monsterinfo.stand = guardian_stand;
	@self.monsterinfo.walk = guardian_walk;
	@self.monsterinfo.run = guardian_run;
	@self.monsterinfo.attack = guardian_attack;
	@self.monsterinfo.checkattack = Guardian_CheckAttack;
	@self.monsterinfo.setskin = guardian_setskin;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	self.monsterinfo.blindfire = true;

	gi_linkentity(self.e);

	guardian_stand(self);

	walkmonster_start(self);

	@self.use = guardian_use;
}
