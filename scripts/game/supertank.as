// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

SUPERTANK

==============================================================================
*/

namespace supertank
{
    enum frames
    {
        attak1_1,
        attak1_2,
        attak1_3,
        attak1_4,
        attak1_5,
        attak1_6,
        attak1_7,
        attak1_8,
        attak1_9,
        attak1_10,
        attak1_11,
        attak1_12,
        attak1_13,
        attak1_14,
        attak1_15,
        attak1_16,
        attak1_17,
        attak1_18,
        attak1_19,
        attak1_20,
        attak2_1,
        attak2_2,
        attak2_3,
        attak2_4,
        attak2_5,
        attak2_6,
        attak2_7,
        attak2_8,
        attak2_9,
        attak2_10,
        attak2_11,
        attak2_12,
        attak2_13,
        attak2_14,
        attak2_15,
        attak2_16,
        attak2_17,
        attak2_18,
        attak2_19,
        attak2_20,
        attak2_21,
        attak2_22,
        attak2_23,
        attak2_24,
        attak2_25,
        attak2_26,
        attak2_27,
        attak3_1,
        attak3_2,
        attak3_3,
        attak3_4,
        attak3_5,
        attak3_6,
        attak3_7,
        attak3_8,
        attak3_9,
        attak3_10,
        attak3_11,
        attak3_12,
        attak3_13,
        attak3_14,
        attak3_15,
        attak3_16,
        attak3_17,
        attak3_18,
        attak3_19,
        attak3_20,
        attak3_21,
        attak3_22,
        attak3_23,
        attak3_24,
        attak3_25,
        attak3_26,
        attak3_27,
        attak4_1,
        attak4_2,
        attak4_3,
        attak4_4,
        attak4_5,
        attak4_6,
        backwd_1,
        backwd_2,
        backwd_3,
        backwd_4,
        backwd_5,
        backwd_6,
        backwd_7,
        backwd_8,
        backwd_9,
        backwd_10,
        backwd_11,
        backwd_12,
        backwd_13,
        backwd_14,
        backwd_15,
        backwd_16,
        backwd_17,
        backwd_18,
        death_1,
        death_2,
        death_3,
        death_4,
        death_5,
        death_6,
        death_7,
        death_8,
        death_9,
        death_10,
        death_11,
        death_12,
        death_13,
        death_14,
        death_15,
        death_16,
        death_17,
        death_18,
        death_19,
        death_20,
        death_21,
        death_22,
        death_23,
        death_24,
        death_31,
        death_32,
        death_33,
        death_45,
        death_46,
        death_47,
        forwrd_1,
        forwrd_2,
        forwrd_3,
        forwrd_4,
        forwrd_5,
        forwrd_6,
        forwrd_7,
        forwrd_8,
        forwrd_9,
        forwrd_10,
        forwrd_11,
        forwrd_12,
        forwrd_13,
        forwrd_14,
        forwrd_15,
        forwrd_16,
        forwrd_17,
        forwrd_18,
        left_1,
        left_2,
        left_3,
        left_4,
        left_5,
        left_6,
        left_7,
        left_8,
        left_9,
        left_10,
        left_11,
        left_12,
        left_13,
        left_14,
        left_15,
        left_16,
        left_17,
        left_18,
        pain1_1,
        pain1_2,
        pain1_3,
        pain1_4,
        pain2_5,
        pain2_6,
        pain2_7,
        pain2_8,
        pain3_9,
        pain3_10,
        pain3_11,
        pain3_12,
        right_1,
        right_2,
        right_3,
        right_4,
        right_5,
        right_6,
        right_7,
        right_8,
        right_9,
        right_10,
        right_11,
        right_12,
        right_13,
        right_14,
        right_15,
        right_16,
        right_17,
        right_18,
        stand_1,
        stand_2,
        stand_3,
        stand_4,
        stand_5,
        stand_6,
        stand_7,
        stand_8,
        stand_9,
        stand_10,
        stand_11,
        stand_12,
        stand_13,
        stand_14,
        stand_15,
        stand_16,
        stand_17,
        stand_18,
        stand_19,
        stand_20,
        stand_21,
        stand_22,
        stand_23,
        stand_24,
        stand_25,
        stand_26,
        stand_27,
        stand_28,
        stand_29,
        stand_30,
        stand_31,
        stand_32,
        stand_33,
        stand_34,
        stand_35,
        stand_36,
        stand_37,
        stand_38,
        stand_39,
        stand_40,
        stand_41,
        stand_42,
        stand_43,
        stand_44,
        stand_45,
        stand_46,
        stand_47,
        stand_48,
        stand_49,
        stand_50,
        stand_51,
        stand_52,
        stand_53,
        stand_54,
        stand_55,
        stand_56,
        stand_57,
        stand_58,
        stand_59,
        stand_60
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::supertank
{
    const spawnflags_t POWERSHIELD = spawnflag_dec(8);
    // n64
    const spawnflags_t LONG_DEATH = spawnflag_dec(16);
}

namespace supertank::sounds
{
    cached_soundindex pain1("bosstank/btkpain1.wav");
    cached_soundindex pain2("bosstank/btkpain2.wav");
    cached_soundindex pain3("bosstank/btkpain3.wav");
    cached_soundindex death("bosstank/btkdeth1.wav");
    cached_soundindex search1("bosstank/btkunqv1.wav");
    cached_soundindex search2("bosstank/btkunqv2.wav");

    cached_soundindex tread("bosstank/btkengn1.wav");
}

void TreadSound(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, supertank::sounds::tread, 1, ATTN_NORM, 0);
}

void supertank_search(ASEntity &self)
{
	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::search1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::search2, 1, ATTN_NORM, 0);
}

//
// stand
//

const array<mframe_t> supertank_frames_stand = {
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
const mmove_t supertank_move_stand = mmove_t(supertank::frames::stand_1, supertank::frames::stand_60, supertank_frames_stand, null);

void supertank_stand(ASEntity &self)
{
	M_SetAnimation(self, supertank_move_stand);
}

const array<mframe_t> supertank_frames_run = {
	mframe_t(ai_run, 12, TreadSound),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 12)
};
const mmove_t supertank_move_run = mmove_t(supertank::frames::forwrd_1, supertank::frames::forwrd_18, supertank_frames_run, null);

//
// walk
//

const array<mframe_t> supertank_frames_forward = {
	mframe_t(ai_walk, 4, TreadSound),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4)
};
const mmove_t supertank_move_forward = mmove_t(supertank::frames::forwrd_1, supertank::frames::forwrd_18, supertank_frames_forward, null);

void supertank_forward(ASEntity &self)
{
	M_SetAnimation(self, supertank_move_forward);
}

void supertank_walk(ASEntity &self)
{
	M_SetAnimation(self, supertank_move_forward);
}

void supertank_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, supertank_move_stand);
	else
		M_SetAnimation(self, supertank_move_run);
}

/*
const array<mframe_t> supertank_frames_turn_right = {
	mframe_t(ai_move, 0, TreadSound),
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
const mmove_t supertank_move_turn_right = mmove_t(supertank::frames::right_1, supertank::frames::right_18, supertank_frames_turn_right, supertank_run);

const array<mframe_t> supertank_frames_turn_left = {
	mframe_t(ai_move, 0, TreadSound),
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
const mmove_t supertank_move_turn_left = mmove_t(supertank::frames::left_1, supertank::frames::left_18, supertank_frames_turn_left, supertank_run);
*/

const array<mframe_t> supertank_frames_pain3 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t supertank_move_pain3 = mmove_t(supertank::frames::pain3_9, supertank::frames::pain3_12, supertank_frames_pain3, supertank_run);

const array<mframe_t> supertank_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t supertank_move_pain2 = mmove_t(supertank::frames::pain2_5, supertank::frames::pain2_8, supertank_frames_pain2, supertank_run);

const array<mframe_t> supertank_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t supertank_move_pain1 = mmove_t(supertank::frames::pain1_1, supertank::frames::pain1_4, supertank_frames_pain1, supertank_run);

void BossLoop(ASEntity &self)
{
	if (!self.spawnflags.has(spawnflags::supertank::LONG_DEATH))
		return;

	if (self.count != 0)
		self.count--;
	else
		self.spawnflags &= ~spawnflags::supertank::LONG_DEATH;

	self.monsterinfo.nextframe = supertank::frames::death_19;
}

void supertankGrenade(ASEntity &self)
{
	vec3_t					 forward, right;
	vec3_t					 start;
	monster_muzzle_t         flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	if (self.e.s.frame == supertank::frames::attak4_1)
		flash_number = monster_muzzle_t::SUPERTANK_GRENADE_1;
	else
		flash_number = monster_muzzle_t::SUPERTANK_GRENADE_2;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	vec3_t aim_point;
	PredictAim(self, self.enemy, start, 0, false, crandom_open() * 0.1f, forward, aim_point);

	for (float speed = 500.f; speed < 1000.f; speed += 100.f)
	{
		if (!M_CalculatePitchToFire(self, aim_point, start, forward, speed, 2.5f, true))
			continue;

		monster_fire_grenade(self, start, forward, 50, int(speed), flash_number, 0.f, 0.f);
		break;
	}
}

const array<mframe_t> supertank_frames_death1 = {
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
	mframe_t(ai_move, 0, BossLoop)
};
const mmove_t supertank_move_death = mmove_t(supertank::frames::death_1, supertank::frames::death_24, supertank_frames_death1, supertank_dead);

const array<mframe_t> supertank_frames_attack4 = {
	mframe_t(ai_move, 0, supertankGrenade),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, supertankGrenade),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t supertank_move_attack4 = mmove_t(supertank::frames::attak4_1, supertank::frames::attak4_6, supertank_frames_attack4, supertank_run);

const array<mframe_t> supertank_frames_attack2 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, supertankRocket),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, supertankRocket),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, supertankRocket),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t supertank_move_attack2 = mmove_t(supertank::frames::attak2_1, supertank::frames::attak2_27, supertank_frames_attack2, supertank_run);

const array<mframe_t> supertank_frames_attack1 = {
	mframe_t(ai_charge, 0, supertankMachineGun),
	mframe_t(ai_charge, 0, supertankMachineGun),
	mframe_t(ai_charge, 0, supertankMachineGun),
	mframe_t(ai_charge, 0, supertankMachineGun),
	mframe_t(ai_charge, 0, supertankMachineGun),
	mframe_t(ai_charge, 0, supertankMachineGun),
};
const mmove_t supertank_move_attack1 = mmove_t(supertank::frames::attak1_1, supertank::frames::attak1_6, supertank_frames_attack1, supertank_reattack1);

const array<mframe_t> supertank_frames_end_attack1 = {
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
const mmove_t supertank_move_end_attack1 = mmove_t(supertank::frames::attak1_7, supertank::frames::attak1_20, supertank_frames_end_attack1, supertank_run);

void supertank_reattack1(ASEntity &self)
{
	if (visible(self, self.enemy))
	{
		if (self.timestamp >= level.time || frandom() < 0.3f)
			M_SetAnimation(self, supertank_move_attack1);
		else
			M_SetAnimation(self, supertank_move_end_attack1);
	}
	else
		M_SetAnimation(self, supertank_move_end_attack1);
}

void supertank_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	// Lessen the chance of him going into his pain frames
	if (mod.id != mod_id_t::CHAINFIST)
	{
		if (damage <= 25)
			if (frandom() < 0.2f)
				return;

		// Don't go into pain if he's firing his rockets
		if ((self.e.s.frame >= supertank::frames::attak2_1) && (self.e.s.frame <= supertank::frames::attak2_14))
			return;
	}

	if (damage <= 10)
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::pain1, 1, ATTN_NORM, 0);
	else if (damage <= 25)
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::pain3, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::pain2, 1, ATTN_NORM, 0);

	self.pain_debounce_time = level.time + time_sec(3);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (damage <= 10)
		M_SetAnimation(self, supertank_move_pain1);
	else if (damage <= 25)
		M_SetAnimation(self, supertank_move_pain2);
	else
		M_SetAnimation(self, supertank_move_pain3);
}

void supertank_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

void supertankRocket(ASEntity &self)
{
	vec3_t					 forward, right;
	vec3_t					 start;
	vec3_t					 dir;
	vec3_t					 vec;
	monster_muzzle_t flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	if (self.e.s.frame == supertank::frames::attak2_8)
		flash_number = monster_muzzle_t::SUPERTANK_ROCKET_1;
	else if (self.e.s.frame == supertank::frames::attak2_11)
		flash_number = monster_muzzle_t::SUPERTANK_ROCKET_2;
	else // (self.e.s.frame == supertank::frames::attak2_14)
		flash_number = monster_muzzle_t::SUPERTANK_ROCKET_3;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	if (self.spawnflags.has(spawnflags::supertank::POWERSHIELD))
	{
		vec = self.enemy.e.s.origin;
		vec[2] += self.enemy.viewheight;
		dir = vec - start;
		dir.normalize();
		monster_fire_heat(self, start, dir, 40, 500, flash_number, 0.075f);
	}
	else
	{
		PredictAim(self, self.enemy, start, 750, false, 0.f, forward, dir);
		monster_fire_rocket(self, start, forward, 50, 750, flash_number);
	}
}

void supertankMachineGun(ASEntity &self)
{
	vec3_t					 dir;
	vec3_t					 start;
	vec3_t					 forward, right;
	monster_muzzle_t flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	flash_number = monster_muzzle_t(monster_muzzle_t::SUPERTANK_MACHINEGUN_1 + (self.e.s.frame - supertank::frames::attak1_1));

	dir[0] = 0;
	dir[1] = self.e.s.angles[1];
	dir[2] = 0;

	AngleVectors(dir, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.1f, forward, dir);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD * 3, DEFAULT_BULLET_VSPREAD * 3, flash_number);
}

void supertank_attack(ASEntity &self)
{
	vec3_t vec;
	float  range;

	vec = self.enemy.e.s.origin - self.e.s.origin;
	range = range_to(self, self.enemy);

	// Attack 1 == Chaingun
	// Attack 2 == Rocket Launcher
	// Attack 3 == Grenade Launcher
	bool chaingun_good = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::SUPERTANK_MACHINEGUN_1]);
	bool rocket_good = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::SUPERTANK_ROCKET_1]);
	bool grenade_good = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::SUPERTANK_GRENADE_1]);

	// fire rockets more often at distance
	if (chaingun_good && (!rocket_good || range <= 540 || frandom() < 0.3f))
	{
		// prefer grenade if the enemy is above us
		if (grenade_good && (range >= 350 || vec.z > 120.f || frandom() < 0.2f))
			M_SetAnimation(self, supertank_move_attack4);
		else
		{
			M_SetAnimation(self, supertank_move_attack1);
			self.timestamp = level.time + random_time(time_ms(1500), time_ms(2700));
		}
	}
	else if (rocket_good)
	{
		// prefer grenade if the enemy is above us
		if (grenade_good && (vec.z > 120.f || frandom() < 0.2f))
			M_SetAnimation(self, supertank_move_attack4);
		else
			M_SetAnimation(self, supertank_move_attack2);
	}
	else if (grenade_good)
		M_SetAnimation(self, supertank_move_attack4);
}

//
// death
//

void supertank_gib(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.sound = 0;
	self.e.s.skinnum /= 2;

	ThrowGibs(self, 500, {
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
		gib_def_t("models/monsters/boss1/gibs/cgun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC)),
		gib_def_t("models/monsters/boss1/gibs/chest.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/boss1/gibs/core.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/boss1/gibs/ltread.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss1/gibs/rgun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss1/gibs/rtread.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss1/gibs/tube.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss1/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC | gib_type_t::HEAD))
	});
}

void supertank_dead(ASEntity &self)
{
	// no blowy on deady
	if (self.spawnflags.has(spawnflags::monsters::DEAD))
	{
		self.deadflag = false;
		self.takedamage = true;
		return;
	}

	supertank_gib(self);
}

void supertank_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.spawnflags.has(spawnflags::monsters::DEAD))
	{
		// check for gib
		if (M_CheckGib(self, mod))
		{
			supertank_gib(self);
			self.deadflag = true;
			return;
		}

		if (self.deadflag)
			return;
	}
	else
	{
		gi_sound(self.e, soundchan_t::VOICE, supertank::sounds::death, 1, ATTN_NORM, 0);
		self.deadflag = true;
		self.takedamage = false;
	}

	M_SetAnimation(self, supertank_move_death);
}

//===========
// PGM
bool supertank_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

//
// monster_supertank
//

// RAFAEL (Powershield)

/*QUAKED monster_supertank (1 .5 0) (-64 -64 0) (64 64 72) Ambush Trigger_Spawn Sight Powershield LongDeath
 */
void SP_monster_supertank(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	supertank::sounds::pain1.precache();
	supertank::sounds::pain2.precache();
	supertank::sounds::pain3.precache();
	supertank::sounds::death.precache();
	supertank::sounds::search1.precache();
	supertank::sounds::search2.precache();

	supertank::sounds::tread.precache();

	gi_soundindex("gunner/gunatck3.wav");
	gi_soundindex("infantry/infatck1.wav");
	gi_soundindex("tank/rocket.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/boss1/tris.md2");
	
	gi_modelindex("models/monsters/boss1/gibs/cgun.md2");
	gi_modelindex("models/monsters/boss1/gibs/chest.md2");
	gi_modelindex("models/monsters/boss1/gibs/core.md2");
	gi_modelindex("models/monsters/boss1/gibs/head.md2");
	gi_modelindex("models/monsters/boss1/gibs/ltread.md2");
	gi_modelindex("models/monsters/boss1/gibs/rgun.md2");
	gi_modelindex("models/monsters/boss1/gibs/rtread.md2");
	gi_modelindex("models/monsters/boss1/gibs/tube.md2");

	self.e.mins = { -64, -64, 0 };
	self.e.maxs = { 64, 64, 112 };

	self.health = int(1500 * st.health_multiplier);
	self.gib_health = -500;
	self.mass = 800;

	@self.pain = supertank_pain;
	@self.die = supertank_die;
	@self.monsterinfo.stand = supertank_stand;
	@self.monsterinfo.walk = supertank_walk;
	@self.monsterinfo.run = supertank_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = supertank_attack;
	@self.monsterinfo.search = supertank_search;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = null;
	@self.monsterinfo.blocked = supertank_blocked; // PGM
	@self.monsterinfo.setskin = supertank_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, supertank_move_stand);
	self.monsterinfo.scale = supertank::SCALE;

	// RAFAEL
	if (self.spawnflags.has(spawnflags::supertank::POWERSHIELD))
	{
		if (!st.was_key_specified("power_armor_type"))
			self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
		if (!st.was_key_specified("power_armor_power"))
			self.monsterinfo.power_armor_power = 400;
	}
	// RAFAEL

	walkmonster_start(self);

	// PMM
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	// pmm

	// TODO
	if (level.is_n64)
	{
		self.spawnflags |= spawnflags::supertank::LONG_DEATH;
		self.count = 10;
	}
}

//
// monster_boss5
// RAFAEL
//

/*QUAKED monster_boss5 (1 .5 0) (-64 -64 0) (64 64 72) Ambush Trigger_Spawn Sight
 */
void SP_monster_boss5(ASEntity &self)
{
	self.spawnflags |= spawnflags::supertank::POWERSHIELD;
	SP_monster_supertank(self);
	gi_soundindex("weapons/railgr1a.wav");
	self.e.s.skinnum = 2;
}