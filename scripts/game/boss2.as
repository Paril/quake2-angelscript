// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

boss2

==============================================================================
*/

namespace boss2
{
    enum frames
    {
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
        stand41,
        stand42,
        stand43,
        stand44,
        stand45,
        stand46,
        stand47,
        stand48,
        stand49,
        stand50,
        stand1,
        stand2,
        stand3,
        stand4,
        stand5,
        stand6,
        stand7,
        stand8,
        stand9,
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
        walk20,
        attack1,
        attack2,
        attack3,
        attack4,
        attack5,
        attack6,
        attack7,
        attack8,
        attack9,
        attack10,
        attack11,
        attack12,
        attack13,
        attack14,
        attack15,
        attack16,
        attack17,
        attack18,
        attack19,
        attack20,
        attack21,
        attack22,
        attack23,
        attack24,
        attack25,
        attack26,
        attack27,
        attack28,
        attack29,
        attack30,
        attack31,
        attack32,
        attack33,
        attack34,
        attack35,
        attack36,
        attack37,
        attack38,
        attack39,
        attack40,
        pain2,
        pain3,
        pain4,
        pain5,
        pain6,
        pain7,
        pain8,
        pain9,
        pain10,
        pain11,
        pain12,
        pain13,
        pain14,
        pain15,
        pain16,
        pain17,
        pain18,
        pain19,
        pain20,
        pain21,
        pain22,
        pain23,
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
        death27,
        death28,
        death29,
        death30,
        death31,
        death32,
        death33,
        death34,
        death35,
        death36,
        death37,
        death38,
        death39,
        death40,
        death41,
        death42,
        death43,
        death44,
        death45,
        death46,
        death47,
        death48,
        death49,
        death50
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::boss2
{
    // [Paril-KEX]
    const uint32 N64 = 8;
}

namespace boss2::sounds
{
    cached_soundindex pain1("bosshovr/bhvpain1.wav");
    cached_soundindex pain2("bosshovr/bhvpain2.wav");
    cached_soundindex pain3("bosshovr/bhvpain3.wav");
    cached_soundindex death("bosshovr/bhvdeth1.wav");
    cached_soundindex search1("bosshovr/bhvunqv1.wav");
}

// he fly
void boss2_set_fly_parameters(ASEntity &self, bool firing)
{
	self.monsterinfo.fly_thrusters = false;
	self.monsterinfo.fly_acceleration = firing ? 1.5f : 3.f;
	self.monsterinfo.fly_speed = firing ? 10.f : 80.f;
	// BOSS2 stays far-ish away if he's in the open
	self.monsterinfo.fly_min_distance = 400.f;
	self.monsterinfo.fly_max_distance = 600.f;
}

void boss2_search(ASEntity &self)
{
	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, boss2::sounds::search1, 1, ATTN_NONE, 0);
}

const int BOSS2_ROCKET_SPEED = 750;

void Boss2PredictiveRocket(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;

	AngleVectors(self.e.s.angles, forward, right);

	// 1
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_1], forward, right);
	PredictAim(self, self.enemy, start, BOSS2_ROCKET_SPEED, false, -0.10f, dir);
	monster_fire_rocket(self, start, dir, 50, BOSS2_ROCKET_SPEED, monster_muzzle_t::BOSS2_ROCKET_1);

	// 2
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_2], forward, right);
	PredictAim(self, self.enemy, start, BOSS2_ROCKET_SPEED, false, -0.05f, dir);
	monster_fire_rocket(self, start, dir, 50, BOSS2_ROCKET_SPEED, monster_muzzle_t::BOSS2_ROCKET_2);

	// 3
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_3], forward, right);
	PredictAim(self, self.enemy, start, BOSS2_ROCKET_SPEED, false, 0.05f, dir);
	monster_fire_rocket(self, start, dir, 50, BOSS2_ROCKET_SPEED, monster_muzzle_t::BOSS2_ROCKET_3);

	// 4
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_4], forward, right);
	PredictAim(self, self.enemy, start, BOSS2_ROCKET_SPEED, false, 0.10f, dir);
	monster_fire_rocket(self, start, dir, 50, BOSS2_ROCKET_SPEED, monster_muzzle_t::BOSS2_ROCKET_4);
}

void Boss2Rocket(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;
	vec3_t vec;

	if (self.enemy !is null)
	{
		if (self.enemy.client !is null && frandom() < 0.9f)
		{
			Boss2PredictiveRocket(self);
			return;
		}
	}

	AngleVectors(self.e.s.angles, forward, right);

	// 1
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_1], forward, right);
	vec = self.enemy.e.s.origin;
	vec[2] -= 15;
	dir = vec - start;
	dir.normalize();
	dir += (right * 0.4f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::BOSS2_ROCKET_1);

	// 2
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_2], forward, right);
	vec = self.enemy.e.s.origin;
	dir = vec - start;
	dir.normalize();
	dir += (right * 0.025f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::BOSS2_ROCKET_2);

	// 3
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_3], forward, right);
	vec = self.enemy.e.s.origin;
	dir = vec - start;
	dir.normalize();
	dir += (right * -0.025f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::BOSS2_ROCKET_3);

	// 4
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_4], forward, right);
	vec = self.enemy.e.s.origin;
	vec[2] -= 15;
	dir = vec - start;
	dir.normalize();
	dir += (right * -0.4f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::BOSS2_ROCKET_4);
}

void Boss2Rocket64(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;
	vec3_t vec;
	float  time, dist;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_ROCKET_1], forward, right);

	float scale = self.e.s.scale != 0 ? self.e.s.scale : 1;

	start[2] += 10.f * scale;
	start -= right * 2.f * scale;
	start -= right * ((self.count++ % 4) * 8.f * scale);
	
	if (self.enemy !is null && self.enemy.client !is null && frandom() < 0.9f)
	{
		// 1
		dir = self.enemy.e.s.origin - start;
		dist = dir.length();
		time = dist / BOSS2_ROCKET_SPEED;
		vec = self.enemy.e.s.origin + (self.enemy.velocity * (time - 0.3f));
	}
	else
	{
		// 1
		vec = self.enemy.e.s.origin;
		vec[2] -= 15;
	}
	
	dir = vec - start;
	dir.normalize();

	monster_fire_rocket(self, start, dir, 35, BOSS2_ROCKET_SPEED, monster_muzzle_t::BOSS2_ROCKET_1);
}

void boss2_firebullet_right(ASEntity &self)
{
	vec3_t forward, right, start;
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_MACHINEGUN_R1], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.2f, forward);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD * 3, DEFAULT_BULLET_VSPREAD, monster_muzzle_t::BOSS2_MACHINEGUN_R1);
}

void boss2_firebullet_left(ASEntity &self)
{
	vec3_t forward, right, start;
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::BOSS2_MACHINEGUN_L1], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.2f, forward);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD * 3, DEFAULT_BULLET_VSPREAD, monster_muzzle_t::BOSS2_MACHINEGUN_L1);
}

void Boss2MachineGun(ASEntity &self)
{
	boss2_firebullet_left(self);
	boss2_firebullet_right(self);
}

const array<mframe_t> boss2_frames_stand = {
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
const mmove_t boss2_move_stand = mmove_t(boss2::frames::stand30, boss2::frames::stand50, boss2_frames_stand, null);

const array<mframe_t> boss2_frames_walk = {
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 10)
};
const mmove_t boss2_move_walk = mmove_t(boss2::frames::walk1, boss2::frames::walk20, boss2_frames_walk, null);

const array<mframe_t> boss2_frames_run = {
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10)
};
const mmove_t boss2_move_run = mmove_t(boss2::frames::walk1, boss2::frames::walk20, boss2_frames_run, null);

const array<mframe_t> boss2_frames_attack_pre_mg = {
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, boss2_attack_mg)
};
const mmove_t boss2_move_attack_pre_mg = mmove_t(boss2::frames::attack1, boss2::frames::attack9, boss2_frames_attack_pre_mg, null);

// Loop this
const array<mframe_t> boss2_frames_attack_mg = {
	mframe_t(ai_charge, 2, Boss2MachineGun),
	mframe_t(ai_charge, 2, Boss2MachineGun),
	mframe_t(ai_charge, 2, Boss2MachineGun),
	mframe_t(ai_charge, 2, Boss2MachineGun),
	mframe_t(ai_charge, 2, Boss2MachineGun),
	mframe_t(ai_charge, 2, boss2_reattack_mg)
};
const mmove_t boss2_move_attack_mg = mmove_t(boss2::frames::attack10, boss2::frames::attack15, boss2_frames_attack_mg, null);

// [Paril-KEX]
void Boss2HyperBlaster(ASEntity &self)
{
	vec3_t forward, right, target;
	vec3_t start;
	monster_muzzle_t id = (self.e.s.frame & 1) != 0 ? monster_muzzle_t::BOSS2_MACHINEGUN_L2 : monster_muzzle_t::BOSS2_MACHINEGUN_R2;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[id], forward, right);
	target = self.enemy.e.s.origin;
	target[2] += self.enemy.viewheight;
	forward = target - start;
	forward.normalize();

	monster_fire_blaster(self, start, forward, 2, 1000, id, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::HYPERBLASTER);
}

const array<mframe_t> boss2_frames_attack_hb = {
	mframe_t(ai_charge, 2, Boss2HyperBlaster),
	mframe_t(ai_charge, 2, Boss2HyperBlaster),
	mframe_t(ai_charge, 2, Boss2HyperBlaster),
	mframe_t(ai_charge, 2, Boss2HyperBlaster),
	mframe_t(ai_charge, 2, Boss2HyperBlaster),
	mframe_t(ai_charge, 2, function(self) { Boss2HyperBlaster(self); boss2_reattack_mg(self); })
};
const mmove_t boss2_move_attack_hb = mmove_t(boss2::frames::attack10, boss2::frames::attack15, boss2_frames_attack_hb, null);

const array<mframe_t> boss2_frames_attack_post_mg = {
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2)
};
const mmove_t boss2_move_attack_post_mg = mmove_t(boss2::frames::attack16, boss2::frames::attack19, boss2_frames_attack_post_mg, boss2_run);

const array<mframe_t> boss2_frames_attack_rocket = {
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_move, -5, Boss2Rocket),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2)
};
const mmove_t boss2_move_attack_rocket = mmove_t(boss2::frames::attack20, boss2::frames::attack40, boss2_frames_attack_rocket, boss2_run);

// [Paril-KEX] n64 rocket behavior
const array<mframe_t> boss2_frames_attack_rocket2 = {
	mframe_t(ai_charge, 2, Boss2Rocket64),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, Boss2Rocket64),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, Boss2Rocket64),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, Boss2Rocket64),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, Boss2Rocket64),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2)
};
const mmove_t boss2_move_attack_rocket2 = mmove_t(boss2::frames::attack20, boss2::frames::attack39, boss2_frames_attack_rocket2, boss2_run);

const array<mframe_t> boss2_frames_pain_heavy = {
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
const mmove_t boss2_move_pain_heavy = mmove_t(boss2::frames::pain2, boss2::frames::pain19, boss2_frames_pain_heavy, boss2_run);

const array<mframe_t> boss2_frames_pain_light = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t boss2_move_pain_light = mmove_t(boss2::frames::pain20, boss2::frames::pain23, boss2_frames_pain_light, boss2_run);

void boss2_shrink(ASEntity &self)
{
	self.e.maxs.z = 50.f;
	gi_linkentity(self.e);
}

const array<mframe_t> boss2_frames_death = {
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
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, boss2_shrink),
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
const mmove_t boss2_move_death = mmove_t(boss2::frames::death2, boss2::frames::death50, boss2_frames_death, boss2_dead);

void boss2_stand(ASEntity &self)
{
	M_SetAnimation(self, boss2_move_stand);
}

void boss2_run(ASEntity &self)
{
	boss2_set_fly_parameters(self, false);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, boss2_move_stand);
	else
		M_SetAnimation(self, boss2_move_run);
}

void boss2_walk(ASEntity &self)
{
	M_SetAnimation(self, boss2_move_walk);
}

void boss2_attack(ASEntity &self)
{
	vec3_t vec;
	float  range;

	vec = self.enemy.e.s.origin - self.e.s.origin;
	range = vec.length();

	if (range <= 125 || frandom() <= 0.6f)
		M_SetAnimation(self, (self.spawnflags & spawnflags::boss2::N64) != 0 ? boss2_move_attack_hb : boss2_move_attack_pre_mg);
	else
		M_SetAnimation(self, (self.spawnflags & spawnflags::boss2::N64) != 0 ? boss2_move_attack_rocket2 : boss2_move_attack_rocket);

	boss2_set_fly_parameters(self, true);
}

void boss2_attack_mg(ASEntity &self)
{
	M_SetAnimation(self, (self.spawnflags & spawnflags::boss2::N64) != 0 ? boss2_move_attack_hb : boss2_move_attack_mg);
}

void boss2_reattack_mg(ASEntity &self)
{
	if (infront(self, self.enemy) && frandom() <= 0.7f)
		boss2_attack_mg(self);
	else
		M_SetAnimation(self, boss2_move_attack_post_mg);
}

void boss2_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	// American wanted these at no attenuation
	if (damage < 10)
		gi_sound(self.e, soundchan_t::VOICE, boss2::sounds::pain3, 1, ATTN_NONE, 0);
	else if (damage < 30)
		gi_sound(self.e, soundchan_t::VOICE, boss2::sounds::pain1, 1, ATTN_NONE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, boss2::sounds::pain2, 1, ATTN_NONE, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (damage < 10)
		M_SetAnimation(self, boss2_move_pain_light);
	else if (damage < 30)
		M_SetAnimation(self, boss2_move_pain_light);
	else
		M_SetAnimation(self, boss2_move_pain_heavy);
}

void boss2_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void boss2_gib(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.sound = 0;
	self.e.s.skinnum /= 2;

	self.gravityVector.z = -1.0f;

	ThrowGibs(self, 500, {
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
		gib_def_t("models/monsters/boss2/gibs/chest.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/boss2/gibs/chaingun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/cpu.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/engine.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/boss2/gibs/rocket.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/spine.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/boss2/gibs/wing.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/larm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/rarm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/larm.md2", 2.0f, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/rarm.md2", 2.0f, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/larm.md2", 1.35f, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/rarm.md2", 1.35f, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss2/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC | gib_type_t::HEAD))
	});
}

void boss2_dead(ASEntity &self)
{
	// no blowy on deady
	if ((self.spawnflags & spawnflags::monsters::DEAD) != 0)
	{
		self.deadflag = false;
		self.takedamage = true;
		return;
	}

	boss2_gib(self);
}

void boss2_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if ((self.spawnflags & spawnflags::monsters::DEAD) != 0)
	{
		// check for gib
		if (M_CheckGib(self, mod))
		{
			boss2_gib(self);
			self.deadflag = true;
			return;
		}

		if (self.deadflag)
			return;
	}
	else
	{
		gi_sound(self.e, soundchan_t::VOICE, boss2::sounds::death, 1, ATTN_NONE, 0);
		self.deadflag = true;
		self.takedamage = false;
		self.count = 0;
		self.velocity = vec3_origin;
		self.gravityVector.z *= 0.30f;
	}

	M_SetAnimation(self, boss2_move_death);
}

// [Paril-KEX] use generic function
bool Boss2_CheckAttack(ASEntity &self)
{
	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.8f, 0.8f, 0.f, 0.f);
}

/*QUAKED monster_boss2 (1 .5 0) (-56 -56 0) (56 56 80) Ambush Trigger_Spawn Sight Hyperblaster
 */
void SP_monster_boss2(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	boss2::sounds::pain1.precache();
	boss2::sounds::pain2.precache();
	boss2::sounds::pain3.precache();
	boss2::sounds::death.precache();
	boss2::sounds::search1.precache();

	gi_soundindex("tank/rocket.wav");

	if ((self.spawnflags & spawnflags::boss2::N64) != 0)
		gi_soundindex("flyer/flyatck3.wav");
	else
		gi_soundindex("infantry/infatck1.wav");

	self.monsterinfo.weapon_sound = gi_soundindex("bosshovr/bhvengn1.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/boss2/tris.md2");
	
	gi_modelindex("models/monsters/boss2/gibs/chaingun.md2");
	gi_modelindex("models/monsters/boss2/gibs/chest.md2");
	gi_modelindex("models/monsters/boss2/gibs/cpu.md2");
	gi_modelindex("models/monsters/boss2/gibs/engine.md2");
	gi_modelindex("models/monsters/boss2/gibs/head.md2");
	gi_modelindex("models/monsters/boss2/gibs/larm.md2");
	gi_modelindex("models/monsters/boss2/gibs/rarm.md2");
	gi_modelindex("models/monsters/boss2/gibs/rocket.md2");
	gi_modelindex("models/monsters/boss2/gibs/spine.md2");
	gi_modelindex("models/monsters/boss2/gibs/wing.md2");

	self.e.mins = { -56, -56, 0 };
	self.e.maxs = { 56, 56, 80 };

	self.health = int(2000 * st.health_multiplier);
	self.gib_health = -200;
	self.mass = 2000;

	self.yaw_speed = 50;

	self.flags = ent_flags_t(self.flags | ent_flags_t::IMMUNE_LASER);

	@self.pain = boss2_pain;
	@self.die = boss2_die;

	@self.monsterinfo.stand = boss2_stand;
	@self.monsterinfo.walk = boss2_walk;
	@self.monsterinfo.run = boss2_run;
	@self.monsterinfo.attack = boss2_attack;
	@self.monsterinfo.search = boss2_search;
	@self.monsterinfo.checkattack = Boss2_CheckAttack;
	@self.monsterinfo.setskin = boss2_setskin;
	gi_linkentity(self.e);

	M_SetAnimation(self, boss2_move_stand);
	self.monsterinfo.scale = boss2::SCALE;

	// [Paril-KEX]
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	boss2_set_fly_parameters(self, false);

	flymonster_start(self);
}
