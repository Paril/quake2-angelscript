// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

GUARDIAN

==============================================================================
*/

#include "g_local.h"
#include "m_guardian.h"
#include "m_flash.h"

static cached_soundindex sound_sight;
static cached_soundindex sound_pain1;
static cached_soundindex sound_pain2;
static cached_soundindex sound_death;

//
// stand
//

mframe_t guardian_frames_stand[] = {
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand },
	{ ai_stand }
};
MMOVE_T(guardian_move_stand) = { FRAME_idle1, FRAME_idle52, guardian_frames_stand, nullptr };

constexpr spawnflags_t SPAWNFLAG_GUARDIAN_SLEEPY = 8_spawnflag;

/*
=============
ai_sleep

honk shoo honk shoo
==============
*/
void ai_sleep(edict_t *self, float dist)
{
}

mframe_t guardian_frames_sleep[] = {
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep }
};
MMOVE_T(guardian_move_sleep) = { FRAME_sleep1, FRAME_sleep14, guardian_frames_sleep, nullptr };

MONSTERINFO_STAND(guardian_stand) (edict_t *self) -> void
{
	if (self->spawnflags.has(SPAWNFLAG_GUARDIAN_SLEEPY))
		M_SetAnimation(self, &guardian_move_sleep);
	else
		M_SetAnimation(self, &guardian_move_stand);
}

void guardian_run(edict_t *self);

mframe_t guardian_frames_wake[] = {
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep },
	{ ai_sleep }
};
MMOVE_T(guardian_move_wake) = { FRAME_wake1, FRAME_wake5, guardian_frames_wake, guardian_run };

USE(guardian_use) (edict_t *self, edict_t *other, edict_t *activator) -> void
{
	self->spawnflags &= ~SPAWNFLAG_GUARDIAN_SLEEPY;
	M_SetAnimation(self, &guardian_move_wake);
	self->use = monster_use;
	gi.sound(self, CHAN_BODY, sound_sight, 1.f, 0.1f, 0.0f);
}

//
// walk
//

static cached_soundindex sound_step;

void guardian_footstep(edict_t *self)
{
	gi.sound(self, CHAN_BODY, sound_step, 1.f, 0.1f, 0.0f);
}

mframe_t guardian_frames_walk[] = {
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8, guardian_footstep },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8 },
	{ ai_walk, 8, guardian_footstep },
	{ ai_walk, 8 }
};
MMOVE_T(guardian_move_walk) = { FRAME_walk1, FRAME_walk19, guardian_frames_walk, nullptr };

MONSTERINFO_WALK(guardian_walk) (edict_t *self) -> void
{
	M_SetAnimation(self, &guardian_move_walk);
}

//
// run
//

mframe_t guardian_frames_run[] = {
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8, guardian_footstep },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8 },
	{ ai_run, 8, guardian_footstep },
	{ ai_run, 8 }
};
MMOVE_T(guardian_move_run) = { FRAME_walk1, FRAME_walk19, guardian_frames_run, nullptr };

MONSTERINFO_RUN(guardian_run) (edict_t *self) -> void
{
	self->monsterinfo.aiflags &= ~AI_MANUAL_STEERING;

	if (self->monsterinfo.aiflags & AI_STAND_GROUND)
	{
		M_SetAnimation(self, &guardian_move_stand);
		return;
	}

	M_SetAnimation(self, &guardian_move_run);
}

//
// pain
//

mframe_t guardian_frames_pain1[] = {
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move }
};
MMOVE_T(guardian_move_pain1) = { FRAME_pain1_1, FRAME_pain1_8, guardian_frames_pain1, guardian_run };

PAIN(guardian_pain) (edict_t *self, edict_t *other, float kick, int damage, const mod_t &mod) -> void
{
	if (mod.id != MOD_CHAINFIST && damage <= 10)
		return;

	if (level.time < self->pain_debounce_time)
		return;

	if (mod.id != MOD_CHAINFIST && damage <= 75)
		if (frandom() > 0.2f)
			return;

	// don't go into pain while attacking
	if ((self->s.frame >= FRAME_atk1_spin1) && (self->s.frame <= FRAME_atk1_spin15))
		return;
	if ((self->s.frame >= FRAME_atk2_fire1) && (self->s.frame <= FRAME_atk2_fire4))
		return;
	if ((self->s.frame >= FRAME_kick_in1) && (self->s.frame <= FRAME_kick_in13))
		return;

	self->pain_debounce_time = level.time + 3_sec;

	if (brandom())
		gi.sound(self, CHAN_BODY, sound_pain1, 1.f, 0.1f, 0.0f);
	else
		gi.sound(self, CHAN_BODY, sound_pain2, 1.f, 0.1f, 0.0f);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	M_SetAnimation(self, &guardian_move_pain1);
	self->monsterinfo.weapon_sound = 0;
	self->monsterinfo.aiflags &= ~AI_MANUAL_STEERING;
}

mframe_t guardian_frames_atk1_out[] = {
	{ ai_charge },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_atk1_out) = { FRAME_atk1_out1, FRAME_atk1_out3, guardian_frames_atk1_out, guardian_run };

void guardian_atk1_finish(edict_t *self)
{
	M_SetAnimation(self, &guardian_atk1_out);
	self->monsterinfo.weapon_sound = 0;
}

static cached_soundindex sound_charge;
static cached_soundindex sound_spin_loop;

void guardian_atk1_charge(edict_t *self)
{
	self->monsterinfo.weapon_sound = sound_spin_loop;
	gi.sound(self, CHAN_WEAPON, sound_charge, 1.f, ATTN_NORM, 0.f);
}

void guardian_fire_blaster(edict_t *self)
{
	vec3_t forward, right, up;
	vec3_t start;
	monster_muzzleflash_id_t id = MZ2_GUARDIAN_BLASTER;

	if (!self->enemy || !self->enemy->inuse)
	{
		self->monsterinfo.nextframe = FRAME_atk1_spin13;
		return;
	}

	AngleVectors(self->s.angles, forward, right, up);
	start = M_ProjectFlashSource(self, monster_flash_offset[id], forward, right);
	PredictAim(self, self->enemy, start, 1000, false, crandom() * 0.1f, &forward, nullptr);
	forward += right * crandom() * 0.02f;
	forward += up * crandom() * 0.02f;
	forward.normalize();

	edict_t *bolt = monster_fire_blaster(self, start, forward, 3, 1100, id, (self->s.frame % 4) ? EF_NONE : EF_HYPERBLASTER);
	bolt->s.scale = 2.0f;

	if (self->enemy && self->enemy->health > 0 && 
		self->s.frame == FRAME_atk1_spin12 && self->timestamp > level.time && visible(self, self->enemy))
		self->monsterinfo.nextframe = FRAME_atk1_spin5;
}

mframe_t guardian_frames_atk1_spin[] = {
	{ ai_charge, 0, guardian_atk1_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0, guardian_fire_blaster },
	{ ai_charge, 0 },
	{ ai_charge, 0 },
	{ ai_charge, 0 }
};
MMOVE_T(guardian_move_atk1_spin) = { FRAME_atk1_spin1, FRAME_atk1_spin15, guardian_frames_atk1_spin, guardian_atk1_finish };

void guardian_atk1(edict_t *self)
{
	M_SetAnimation(self, &guardian_move_atk1_spin);
	self->timestamp = level.time + 650_ms + random_time(1.5_sec);
}

mframe_t guardian_frames_atk1_in[] = {
	{ ai_charge },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_move_atk1_in) = { FRAME_atk1_in1, FRAME_atk1_in3, guardian_frames_atk1_in, guardian_atk1 };

mframe_t guardian_frames_atk2_out[] = {
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_footstep },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_move_atk2_out) = { FRAME_atk2_out1, FRAME_atk2_out7, guardian_frames_atk2_out, guardian_run };

void guardian_atk2_out(edict_t *self)
{
	M_SetAnimation(self, &guardian_move_atk2_out);
}

static cached_soundindex sound_laser;
static cached_soundindex sound_pew;

constexpr vec3_t laser_positions[] = {
	{ 125.0f, -70.f, 60.f },
	{ 112.0f, -62.f, 60.f }
};

PRETHINK(guardian_fire_update) (edict_t *laser) -> void
{
	if (!laser->spawnflags.has(SPAWNFLAG_DABEAM_SPAWNED))
	{
		edict_t *self = laser->owner;

		vec3_t forward, right, target;
		vec3_t start;

		AngleVectors(self->s.angles, forward, right, nullptr);
		start = M_ProjectFlashSource(self, laser_positions[laser->spawnflags.has(SPAWNFLAG_DABEAM_SECONDARY) ? 1 : 0], forward, right);
		PredictAim(self, self->enemy, start, 0, false, 0.3f, &forward, &target);

		laser->s.origin = start;
		forward[0] += crandom() * 0.02f;
		forward[1] += crandom() * 0.02f;
		forward.normalize();
		laser->movedir = forward;
		gi.linkentity(laser);
	}
	dabeam_update(laser, false);
}

void guardian_laser_fire(edict_t *self)
{
	gi.sound(self, CHAN_WEAPON, sound_laser, 1.f, ATTN_NORM, 0.f);
	monster_fire_dabeam(self, 15, self->s.frame & 1, guardian_fire_update);
}

mframe_t guardian_frames_atk2_fire[] = {
	{ ai_charge, 0, guardian_laser_fire },
	{ ai_charge, 0, guardian_laser_fire },
	{ ai_charge, 0, guardian_laser_fire },
	{ ai_charge, 0, guardian_laser_fire }
};
MMOVE_T(guardian_move_atk2_fire) = { FRAME_atk2_fire1, FRAME_atk2_fire4, guardian_frames_atk2_fire, guardian_atk2_out };

void guardian_atk2(edict_t *self)
{
	M_SetAnimation(self, &guardian_move_atk2_fire);
}

mframe_t guardian_frames_atk2_in[] = {
	{ ai_charge, 0, guardian_footstep },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_footstep },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_footstep },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_move_atk2_in) = { FRAME_atk2_in1, FRAME_atk2_in12, guardian_frames_atk2_in, guardian_atk2 };

void guardian_kick(edict_t *self)
{
	if (!fire_hit(self, { 160.f, 0, -80.f }, 85, 700))
		self->monsterinfo.melee_debounce_time = level.time + 3500_ms;
}

mframe_t guardian_frames_kick[] = {
	{ ai_charge, 12.f },
	{ ai_charge, 18.f, guardian_footstep },
	{ ai_charge, 11.f },
	{ ai_charge, 9.f },
	{ ai_charge, 8.f },
	{ ai_charge, 0, guardian_kick },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_footstep },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_move_kick) = { FRAME_kick_in1, FRAME_kick_in13, guardian_frames_kick, guardian_run };


// RAFAEL
/*
fire_heat
*/

static inline vec3_t heat_guardian_get_dist_vec(edict_t *heat, edict_t *target, float dist_to_target)
{
	return (((target->s.origin + vec3_t{0.f, 0.f, target->mins.z}) + (target->velocity * (clamp(dist_to_target / 500.f, 0.f, 1.f)) * 0.5f)) - heat->s.origin).normalized();
}

THINK(heat_guardian_think) (edict_t *self) -> void
{
	edict_t *acquire = nullptr;
	float	 oldlen = 0;
	float	 olddot = 1;

	if (self->timestamp < level.time)
	{
		vec3_t fwd = AngleVectors(self->s.angles).forward;

		if (self->oldenemy)
		{
			self->enemy = self->oldenemy;
			self->oldenemy = nullptr;
		}
	
		if (self->enemy)
		{
			acquire = self->enemy;

			if (acquire->health <= 0 ||
				!visible(self, acquire))
			{
				self->enemy = acquire = nullptr;
			}
			else
			{
				float dist_to_target = (self->s.origin - acquire->s.origin).normalize();
				self->pos1 = heat_guardian_get_dist_vec(self, acquire, dist_to_target);
			}
		}

		if (!acquire)
		{
			// acquire new target
			edict_t *target = nullptr;

			while ((target = findradius(target, self->s.origin, 1024)) != nullptr)
			{
				if (self->owner == target)
					continue;
				if (!target->client)
					continue;
				if (target->health <= 0)
					continue;
				if (!visible(self, target))
					continue;

				float dist_to_target = (self->s.origin - target->s.origin).normalize();
				vec3_t vec = heat_guardian_get_dist_vec(self, target, dist_to_target);

				float len = vec.normalize();
				float dot = vec.dot(fwd);

				// targets that require us to turn less are preferred
				if (dot >= olddot)
					continue;

				if (acquire == nullptr || dot < olddot || len < oldlen)
				{
					acquire = target;
					oldlen = len;
					olddot = dot;
					self->pos1 = vec;
				}
			}
		}
	}

	vec3_t preferred_dir = self->pos1;

	if (acquire != nullptr)
	{
		if (self->enemy != acquire)
		{
			gi.sound(self, CHAN_WEAPON, gi.soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
			self->enemy = acquire;
		}
	}
	else
		self->enemy = nullptr;

	float t = self->accel;

	if (self->enemy)
		t *= 0.85f;

	float d = self->movedir.dot(preferred_dir);

	self->movedir = slerp(self->movedir, preferred_dir, t).normalized();
	self->s.angles = vectoangles(self->movedir);

	if (self->speed < self->yaw_speed)
	{
		self->speed += self->yaw_speed * gi.frame_time_s;
	}

	self->velocity = self->movedir * self->speed;
	self->nextthink = level.time + FRAME_TIME_MS;
}

DIE(guardian_heat_die) (edict_t *self, edict_t *inflictor, edict_t *attacker, int damage, const vec3_t &point, const mod_t &mod) -> void
{
	BecomeExplosion1(self);
}

// RAFAEL
void fire_guardian_heat(edict_t *self, const vec3_t &start, const vec3_t &dir, const vec3_t &rest_dir, int damage, int speed, float damage_radius, int radius_damage, float turn_fraction)
{
	edict_t *heat;

	heat = G_Spawn();
	heat->s.origin = start;
	heat->movedir = dir;
	heat->s.angles = vectoangles(dir);
	heat->velocity = dir * speed;
	heat->movetype = MOVETYPE_FLYMISSILE;
	heat->clipmask = MASK_PROJECTILE;
	heat->flags |= FL_DAMAGEABLE;
	heat->solid = SOLID_BBOX;
	heat->s.effects |= EF_ROCKET;
	heat->s.modelindex = gi.modelindex("models/objects/rocket/tris.md2");
	heat->s.scale = 1.5f;
	heat->owner = self;
	heat->touch = rocket_touch;
	heat->speed = speed / 2;
	heat->yaw_speed = speed * 2;
	heat->accel = turn_fraction;
	heat->pos1 = rest_dir;
	heat->mins = { -5, -5, -5 };
	heat->maxs = { 5, 5, 5 };
	heat->health = 15;
	heat->takedamage = true;
	heat->die = guardian_heat_die;

	heat->nextthink = level.time + 0.20_sec;
	heat->think = heat_guardian_think;

	heat->dmg = damage;
	heat->radius_dmg = radius_damage;
	heat->dmg_radius = damage_radius;
	heat->s.sound = gi.soundindex("weapons/rockfly.wav");

	if (visible(heat, self->enemy))
	{
		heat->oldenemy = self->enemy;
		heat->timestamp = level.time + 0.6_sec;
		gi.sound(heat, CHAN_WEAPON, gi.soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
	}

	gi.linkentity(heat);
}

// RAFAEL

static void guardian_fire_rocket(edict_t *self, float offset)
{
	vec3_t forward, right, up;
	vec3_t start;

	AngleVectors(self->s.angles, forward, right, up);
	start = self->s.origin;
	start -= forward * 8.0f;
	start += right * offset;
	start += up * 50.f;

	AngleVectors({ 20.0f, self->s.angles[1] - offset, 0.f }, forward, nullptr, nullptr);

	fire_guardian_heat(self, start, up, forward, 20, 250, 150, 35, 0.085f);
	gi.sound(self, CHAN_WEAPON, sound_pew, 1.f, 0.5f, 0.0f);
}

static void guardian_fire_rocket_l(edict_t *self)
{
	guardian_fire_rocket(self, -14.0f);
}

static void guardian_fire_rocket_r(edict_t *self)
{
	guardian_fire_rocket(self, 14.0f);
}

static void guardian_blind_fire_check(edict_t *self)
{
	if (self->monsterinfo.aiflags & AI_MANUAL_STEERING)
	{
		vec3_t aim = self->monsterinfo.blind_fire_target - self->s.origin;
		self->ideal_yaw = vectoyaw(aim);
	}
}

mframe_t guardian_frames_rocket[] = {
	{ ai_charge, 0, guardian_blind_fire_check },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_fire_rocket_l },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_fire_rocket_r },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_fire_rocket_l },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge, 0, guardian_fire_rocket_r },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge },
	{ ai_charge }
};
MMOVE_T(guardian_move_rocket) = { FRAME_turnl_1, FRAME_turnr_11, guardian_frames_rocket, guardian_run };

MONSTERINFO_ATTACK(guardian_attack) (edict_t *self) -> void
{
	if (!self->enemy || !self->enemy->inuse)
		return;

	if (self->monsterinfo.attack_state == AS_BLIND)
	{
		float chance;

		// setup shot probabilities
		if (self->count == 0)
			chance = 1.0;
		else if (self->count <= 2)
			chance = 0.4f;
		else
			chance = 0.1f;

		float r = frandom();

		self->monsterinfo.blind_fire_delay += random_time(8.5_sec, 15.5_sec);

		// don't shoot at the origin
		if (!self->monsterinfo.blind_fire_target)
			return;

		// shot the rockets way too soon
		if (self->count)
		{
			self->count--;
			return;
		}

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		// turn on manual steering to signal both manual steering and blindfire
		self->monsterinfo.aiflags |= AI_MANUAL_STEERING;
		M_SetAnimation(self, &guardian_move_rocket);
		self->monsterinfo.attack_finished = level.time + random_time(3_sec);
		return;
	}
	else if (self->bad_area)
	{
		M_SetAnimation(self, &guardian_move_atk1_in);
		return;
	}

	float r = range_to(self, self->enemy);
	bool changedAttack = false;

	if (self->monsterinfo.melee_debounce_time < level.time && r < 160.f)
	{
		M_SetAnimation(self, &guardian_move_kick);
		changedAttack = true;
		self->style = 0;
	}
	else if (r > 300.f && frandom() < (max(r, 1000.f) / 1200.f))
	{
		if (self->count <= 0 && frandom() < 0.25f)
		{
			M_SetAnimation(self, &guardian_move_rocket);
			self->count = 6;
			self->style = 0;
			return;
		}
		else if (M_CheckClearShot(self, laser_positions[0]) && self->style != 1)
		{
			M_SetAnimation(self, &guardian_move_atk2_in);
			self->style = 1;
			changedAttack = true;

			if (skill->integer >= 2)
				self->monsterinfo.nextframe = FRAME_atk2_in8;
		}
		else if (M_CheckClearShot(self, monster_flash_offset[MZ2_GUARDIAN_BLASTER]))
		{
			M_SetAnimation(self, &guardian_move_atk1_in);
			changedAttack = true;
			self->style = 0;
		}
	}
	else if (M_CheckClearShot(self, monster_flash_offset[MZ2_GUARDIAN_BLASTER]))
	{
		M_SetAnimation(self, &guardian_move_atk1_in);
		changedAttack = true;
		self->style = 0;
	}

	if (changedAttack && self->count)
		self->count--;
}

//
// death
//

void guardian_explode(edict_t *self)
{
	gi.WriteByte(svc_temp_entity);
	gi.WriteByte(TE_EXPLOSION1_BIG);
	gi.WritePosition((self->s.origin + self->mins) + vec3_t { frandom() * self->size[0], frandom() * self->size[1], frandom() * self->size[2] });
	gi.multicast(self->s.origin, MULTICAST_ALL, false);
}

constexpr const char *gibs[] = {
	"models/monsters/guardian/gib1.md2",
	"models/monsters/guardian/gib2.md2",
	"models/monsters/guardian/gib3.md2",
	"models/monsters/guardian/gib4.md2",
	"models/monsters/guardian/gib5.md2",
	"models/monsters/guardian/gib6.md2",
	"models/monsters/guardian/gib7.md2"
};

void guardian_dead(edict_t *self)
{
	for (int i = 0; i < 3; i++)
		guardian_explode(self);

	ThrowGibs(self, 125, {
		{ 2, "models/objects/gibs/sm_meat/tris.md2" },
		{ 4, "models/objects/gibs/sm_metal/tris.md2", GIB_METALLIC },
		{ 2, gibs[0], GIB_METALLIC },
		{ 2, gibs[1], GIB_METALLIC },
		{ 2, gibs[2], GIB_METALLIC },
		{ 2, gibs[3], GIB_METALLIC },
		{ 2, gibs[4], GIB_METALLIC },
		{ 2, gibs[5], GIB_METALLIC },
		{ gibs[6], GIB_METALLIC | GIB_HEAD }
	});
}

mframe_t guardian_frames_death1[FRAME_death26 - FRAME_death1 + 1] = {
	{ ai_move, 0, BossExplode },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move },
	{ ai_move }
};
MMOVE_T(guardian_move_death) = { FRAME_death1, FRAME_death26, guardian_frames_death1, guardian_dead };

DIE(guardian_die) (edict_t *self, edict_t *inflictor, edict_t *attacker, int damage, const vec3_t &point, const mod_t &mod) -> void
{
	if (self->deadflag)
		return;

	// regular death
	self->monsterinfo.weapon_sound = 0;
	self->deadflag = true;
	self->takedamage = true;

	M_SetAnimation(self, &guardian_move_death);
	gi.sound(self, CHAN_BODY, sound_death, 1.f, 0.1f, 0.0f);
}

void GuardianPowerArmor(edict_t *self)
{
	self->monsterinfo.power_armor_type = IT_ITEM_POWER_SHIELD;
	// I don't like this, but it works
	if (self->monsterinfo.power_armor_power <= 0)
		self->monsterinfo.power_armor_power += 200 * skill->integer;
}

void GuardianRespondPowerup(edict_t *self, edict_t *other)
{
	if (other->s.effects & (EF_QUAD | EF_DOUBLE | EF_DUALFIRE | EF_PENT))
	{
		GuardianPowerArmor(self);
	}
}

static void GuardianPowerups(edict_t *self)
{
	edict_t *ent;

	if (!coop->integer)
	{
		GuardianRespondPowerup(self, self->enemy);
	}
	else
	{
		for (uint32_t player = 1; player <= game.maxclients; player++)
		{
			ent = &g_edicts[player];
			if (!ent->inuse)
				continue;
			if (!ent->client)
				continue;
			GuardianRespondPowerup(self, ent);
		}
	}
}

MONSTERINFO_CHECKATTACK(Guardian_CheckAttack) (edict_t *self) -> bool
{
	if (!self->enemy)
		return false;

	GuardianPowerups(self);

	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.6f, 0.7f, 0.85f, 0.f);
}

MONSTERINFO_SETSKIN(guardian_setskin) (edict_t *self) -> void
{
	if (self->health < (self->max_health / 2))
		self->s.skinnum = 1;
	else
		self->s.skinnum = 0;
}


//
// monster_guardian
//

/*QUAKED monster_guardian (1 .5 0) (-96 -96 -66) (96 96 62) Ambush Trigger_Spawn Sight
 */
void SP_monster_guardian(edict_t *self)
{
	const spawn_temp_t &st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	sound_step.assign("zortemp/step.wav");
	sound_charge.assign("weapons/hyprbu1a.wav");
	sound_spin_loop.assign("weapons/hyprbl1a.wav");
	sound_laser.assign("weapons/laser2.wav");
	sound_pew.assign("makron/blaster.wav");
	
	sound_sight.assign("guardian/sight.wav");
	sound_pain1.assign("guardian/pain1.wav");
	sound_pain2.assign("guardian/pain2.wav");
	sound_death.assign("guardian/death.wav");

	for (auto &gib : gibs)
		gi.modelindex(gib);

	self->s.modelindex = gi.modelindex("models/monsters/guardian/tris.md2");
	self->mins = { -78, -78, -66 };
	self->maxs = { 78, 78, 76 };
	self->movetype = MOVETYPE_STEP;
	self->solid = SOLID_BBOX;

	self->health = 2500 * st.health_multiplier;
	self->gib_health = -200;

	if (skill->integer >= 3 || coop->integer)
		self->health *= 2;
	else if (skill->integer == 2)
		self->health *= 1.5f;

	self->monsterinfo.scale = MODEL_SCALE;

	self->mass = 1650;

	self->pain = guardian_pain;
	self->die = guardian_die;
	self->monsterinfo.stand = guardian_stand;
	self->monsterinfo.walk = guardian_walk;
	self->monsterinfo.run = guardian_run;
	self->monsterinfo.attack = guardian_attack;
	self->monsterinfo.checkattack = Guardian_CheckAttack;
	self->monsterinfo.setskin = guardian_setskin;

	self->monsterinfo.aiflags |= AI_IGNORE_SHOTS;
	self->monsterinfo.blindfire = true;

	gi.linkentity(self);

	guardian_stand(self);

	walkmonster_start(self);

	self->use = guardian_use;
}
