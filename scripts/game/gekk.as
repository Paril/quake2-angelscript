// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
	xatrix
	gekk.c
*/

namespace gekk
{
    enum frames
    {
        stand_01,
        stand_02,
        stand_03,
        stand_04,
        stand_05,
        stand_06,
        stand_07,
        stand_08,
        stand_09,
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
        run_01,
        run_02,
        run_03,
        run_04,
        run_05,
        run_06,
        clawatk3_01,
        clawatk3_02,
        clawatk3_03,
        clawatk3_04,
        clawatk3_05,
        clawatk3_06,
        clawatk3_07,
        clawatk3_08,
        clawatk3_09,
        clawatk4_01,
        clawatk4_02,
        clawatk4_03,
        clawatk4_04,
        clawatk4_05,
        clawatk4_06,
        clawatk4_07,
        clawatk4_08,
        clawatk5_01,
        clawatk5_02,
        clawatk5_03,
        clawatk5_04,
        clawatk5_05,
        clawatk5_06,
        clawatk5_07,
        clawatk5_08,
        clawatk5_09,
        leapatk_01,
        leapatk_02,
        leapatk_03,
        leapatk_04,
        leapatk_05,
        leapatk_06,
        leapatk_07,
        leapatk_08,
        leapatk_09,
        leapatk_10,
        leapatk_11,
        leapatk_12,
        leapatk_13,
        leapatk_14,
        leapatk_15,
        leapatk_16,
        leapatk_17,
        leapatk_18,
        leapatk_19,
        pain3_01,
        pain3_02,
        pain3_03,
        pain3_04,
        pain3_05,
        pain3_06,
        pain3_07,
        pain3_08,
        pain3_09,
        pain3_10,
        pain3_11,
        pain4_01,
        pain4_02,
        pain4_03,
        pain4_04,
        pain4_05,
        pain4_06,
        pain4_07,
        pain4_08,
        pain4_09,
        pain4_10,
        pain4_11,
        pain4_12,
        pain4_13,
        death1_01,
        death1_02,
        death1_03,
        death1_04,
        death1_05,
        death1_06,
        death1_07,
        death1_08,
        death1_09,
        death1_10,
        death2_01,
        death2_02,
        death2_03,
        death2_04,
        death2_05,
        death2_06,
        death2_07,
        death2_08,
        death2_09,
        death2_10,
        death2_11,
        death3_01,
        death3_02,
        death3_03,
        death3_04,
        death3_05,
        death3_06,
        death3_07,
        death4_01,
        death4_02,
        death4_03,
        death4_04,
        death4_05,
        death4_06,
        death4_07,
        death4_08,
        death4_09,
        death4_10,
        death4_11,
        death4_12,
        death4_13,
        death4_14,
        death4_15,
        death4_16,
        death4_17,
        death4_18,
        death4_19,
        death4_20,
        death4_21,
        death4_22,
        death4_23,
        death4_24,
        death4_25,
        death4_26,
        death4_27,
        death4_28,
        death4_29,
        death4_30,
        death4_31,
        death4_32,
        death4_33,
        death4_34,
        death4_35,
        rduck_01,
        rduck_02,
        rduck_03,
        rduck_04,
        rduck_05,
        rduck_06,
        rduck_07,
        rduck_08,
        rduck_09,
        rduck_10,
        rduck_11,
        rduck_12,
        rduck_13,
        lduck_01,
        lduck_02,
        lduck_03,
        lduck_04,
        lduck_05,
        lduck_06,
        lduck_07,
        lduck_08,
        lduck_09,
        lduck_10,
        lduck_11,
        lduck_12,
        lduck_13,
        idle_01,
        idle_02,
        idle_03,
        idle_04,
        idle_05,
        idle_06,
        idle_07,
        idle_08,
        idle_09,
        idle_10,
        idle_11,
        idle_12,
        idle_13,
        idle_14,
        idle_15,
        idle_16,
        idle_17,
        idle_18,
        idle_19,
        idle_20,
        idle_21,
        idle_22,
        idle_23,
        idle_24,
        idle_25,
        idle_26,
        idle_27,
        idle_28,
        idle_29,
        idle_30,
        idle_31,
        idle_32,
        spit_01,
        spit_02,
        spit_03,
        spit_04,
        spit_05,
        spit_06,
        spit_07,
        amb_01,
        amb_02,
        amb_03,
        amb_04,
        wdeath_01,
        wdeath_02,
        wdeath_03,
        wdeath_04,
        wdeath_05,
        wdeath_06,
        wdeath_07,
        wdeath_08,
        wdeath_09,
        wdeath_10,
        wdeath_11,
        wdeath_12,
        wdeath_13,
        wdeath_14,
        wdeath_15,
        wdeath_16,
        wdeath_17,
        wdeath_18,
        wdeath_19,
        wdeath_20,
        wdeath_21,
        wdeath_22,
        wdeath_23,
        wdeath_24,
        wdeath_25,
        wdeath_26,
        wdeath_27,
        wdeath_28,
        wdeath_29,
        wdeath_30,
        wdeath_31,
        wdeath_32,
        wdeath_33,
        wdeath_34,
        wdeath_35,
        wdeath_36,
        wdeath_37,
        wdeath_38,
        wdeath_39,
        wdeath_40,
        wdeath_41,
        wdeath_42,
        wdeath_43,
        wdeath_44,
        wdeath_45,
        swim_01,
        swim_02,
        swim_03,
        swim_04,
        swim_05,
        swim_06,
        swim_07,
        swim_08,
        swim_09,
        swim_10,
        swim_11,
        swim_12,
        swim_13,
        swim_14,
        swim_15,
        swim_16,
        swim_17,
        swim_18,
        swim_19,
        swim_20,
        swim_21,
        swim_22,
        swim_23,
        swim_24,
        swim_25,
        swim_26,
        swim_27,
        swim_28,
        swim_29,
        swim_30,
        swim_31,
        swim_32,
        attack_01,
        attack_02,
        attack_03,
        attack_04,
        attack_05,
        attack_06,
        attack_07,
        attack_08,
        attack_09,
        attack_10,
        attack_11,
        attack_12,
        attack_13,
        attack_14,
        attack_15,
        attack_16,
        attack_17,
        attack_18,
        attack_19,
        attack_20,
        attack_21,
        pain_01,
        pain_02,
        pain_03,
        pain_04,
        pain_05,
        pain_06
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::gekk
{
    const uint32 CHANT = 8;
    const uint32 NOJUMPING = 16;
    const uint32 NOSWIM = 32;
}

namespace gekk::sounds
{
    cached_soundindex swing("gek/gk_atck1.wav");
    cached_soundindex hit("gek/gk_atck2.wav");
    cached_soundindex hit2("gek/gk_atck3.wav");
    cached_soundindex speet("gek/gk_atck4.wav");
    cached_soundindex loogie_hit("gek/loogie_hit.wav");
    cached_soundindex death("gek/gk_deth1.wav");
    cached_soundindex pain1("gek/gk_pain1.wav");
    cached_soundindex sight("gek/gk_sght1.wav");
    cached_soundindex search("gek/gk_idle1.wav");
    cached_soundindex step1("gek/gk_step1.wav");
    cached_soundindex step2("gek/gk_step2.wav");
    cached_soundindex step3("gek/gk_step3.wav");
    cached_soundindex thud("mutant/thud1.wav");
    cached_soundindex chantlow("gek/gek_low.wav");
    cached_soundindex chantmid("gek/gek_mid.wav");
    cached_soundindex chanthigh("gek/gek_high.wav");
}

//
// CHECKATTACK
//

bool gekk_check_melee(ASEntity &self)
{
	if (self.enemy is null || self.enemy.health <= 0 || self.monsterinfo.melee_debounce_time > level.time)
		return false;

	return range_to(self, self.enemy) <= RANGE_MELEE;
}

bool gekk_check_jump(ASEntity &self)
{
	vec3_t v;
	float  distance;

	// don't jump if there's no way we can reach standing height
	if (self.e.absmin[2] + 125 < self.enemy.e.absmin[2])
		return false;

	v[0] = self.e.s.origin[0] - self.enemy.e.s.origin[0];
	v[1] = self.e.s.origin[1] - self.enemy.e.s.origin[1];
	v[2] = 0;
	distance = v.length();

	if (distance < 100)
	{
		return false;
	}
	if (distance > 100)
	{
		if (frandom() < (self.waterlevel >= water_level_t::WAIST ? 0.2f : 0.9f))
			return false;
	}

	return true;
}

bool gekk_check_jump_close(ASEntity &self)
{
	vec3_t v;
	float  distance;

	v[0] = self.e.s.origin[0] - self.enemy.e.s.origin[0];
	v[1] = self.e.s.origin[1] - self.enemy.e.s.origin[1];
	v[2] = 0;

	distance = v.length();

	if (distance < 100)
	{
		// don't do this if our head is below their feet
		if (self.e.absmax[2] <= self.enemy.e.absmin[2])
			return false;
	}

	return true;
}

bool gekk_checkattack(ASEntity &self)
{
	if (self.enemy is null || self.enemy.health <= 0)
		return false;

	if (gekk_check_melee(self))
	{
		self.monsterinfo.attack_state = ai_attack_state_t::MELEE;
		return true;
	}

	if (self.monsterinfo.attack_state == ai_attack_state_t::STRAIGHT && self.monsterinfo.attack_finished > level.time)
	{
		// keep running fool
		return false;
	}

	if (visible(self, self.enemy, false))
	{
		if (gekk_check_jump(self))
		{
			self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
			return true;
		}

		if (gekk_check_jump_close(self) && (self.flags & ent_flags_t::SWIM) == 0)
		{
			self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
			return true;
		}
	}

	return false;
}

//
// SOUNDS
//

void gekk_step(ASEntity &self)
{
	int n = irandom(3);
	if (n == 0)
		gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::step1, 1, ATTN_NORM, 0);
	else if (n == 1)
		gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::step2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::step3, 1, ATTN_NORM, 0);
}

void gekk_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::sight, 1, ATTN_NORM, 0);
}

void gekk_search(ASEntity &self)
{
	float r;

	if ((self.spawnflags & spawnflags::gekk::CHANT) != 0)
	{
		r = frandom();
		if (r < 0.33f)
			gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::chantlow, 1, ATTN_NORM, 0);
		else if (r < 0.66f)
			gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::chantmid, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::chanthigh, 1, ATTN_NORM, 0);
	}
	else
		gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::search, 1, ATTN_NORM, 0);

	self.health += irandom(10, 20);
	if (self.health > self.max_health)
		self.health = self.max_health;

	self.monsterinfo.setskin(self);
}

void gekk_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 4))
		self.e.s.skinnum = 2;
	else if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void gekk_swing(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::swing, 1, ATTN_NORM, 0);
}

void gekk_face(ASEntity &self)
{
	M_SetAnimation(self, gekk_move_run);
}

//
// STAND
//

void ai_stand_gekk(ASEntity &self, float dist)
{
	if ((self.spawnflags & spawnflags::gekk::CHANT) != 0)
	{
		ai_move(self, dist);
		if ((self.spawnflags & spawnflags::monsters::AMBUSH) == 0 && (self.monsterinfo.idle !is null) && (level.time > self.monsterinfo.idle_time))
		{
			if (self.monsterinfo.idle_time)
			{
				self.monsterinfo.idle(self);
				self.monsterinfo.idle_time = level.time + random_time(time_sec(15), time_sec(30));
			}
			else
			{
				self.monsterinfo.idle_time = level.time + random_time(time_sec(15));
			}
		}
	}
	else
		ai_stand(self, dist);
}

const array<mframe_t> gekk_frames_stand = {
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk), // 10

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk), // 20

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk), // 30

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),

	mframe_t(ai_stand_gekk, 0, gekk_check_underwater),
};
const mmove_t gekk_move_stand = mmove_t(gekk::frames::stand_01, gekk::frames::stand_39, gekk_frames_stand, null);

const array<mframe_t> gekk_frames_standunderwater = {
	mframe_t(ai_stand_gekk, 14),
	mframe_t(ai_stand_gekk, 14),
	mframe_t(ai_stand_gekk, 14),
	mframe_t(ai_stand_gekk, 14),
	mframe_t(ai_stand_gekk, 16),
	mframe_t(ai_stand_gekk, 16),
	mframe_t(ai_stand_gekk, 16),
	mframe_t(ai_stand_gekk, 18),
	mframe_t(ai_stand_gekk, 18),
	mframe_t(ai_stand_gekk, 18),

	mframe_t(ai_stand_gekk, 20),
	mframe_t(ai_stand_gekk, 20),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 24),
	mframe_t(ai_stand_gekk, 24),
	mframe_t(ai_stand_gekk, 26),
	mframe_t(ai_stand_gekk, 26),
	mframe_t(ai_stand_gekk, 24),
	mframe_t(ai_stand_gekk, 24),

	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 22),
	mframe_t(ai_stand_gekk, 18),
	mframe_t(ai_stand_gekk, 18),

	mframe_t(ai_stand_gekk, 18),
	mframe_t(ai_stand_gekk, 18)
};

const mmove_t gekk_move_standunderwater = mmove_t(gekk::frames::swim_01, gekk::frames::swim_32, gekk_frames_standunderwater, null);

void gekk_swim_loop(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	self.flags = ent_flags_t(self.flags | ent_flags_t::SWIM);
	M_SetAnimation(self, gekk_move_swim_loop);
}

const array<mframe_t> gekk_frames_swim = {
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18),

	mframe_t(ai_run, 20),
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 26),
	mframe_t(ai_run, 26),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 24),

	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18),

	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18)
};
const mmove_t gekk_move_swim_loop = mmove_t(gekk::frames::swim_01, gekk::frames::swim_32, gekk_frames_swim, gekk_swim_loop);

const array<mframe_t> gekk_frames_swim_start = {
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18, gekk_hit_left),
	mframe_t(ai_run, 18),

	mframe_t(ai_run, 20),
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 24, gekk_hit_right),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 26),
	mframe_t(ai_run, 26),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 24),

	mframe_t(ai_run, 22, gekk_bite),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 22),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18),

	mframe_t(ai_run, 18),
	mframe_t(ai_run, 18)
};
const mmove_t gekk_move_swim_start = mmove_t(gekk::frames::swim_01, gekk::frames::swim_32, gekk_frames_swim_start, gekk_swim_loop);

void water_to_land(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::ALTERNATE_FLY);
	self.flags = ent_flags_t(self.flags & ~ent_flags_t::SWIM);
	self.yaw_speed = 20;
	self.viewheight = 25;

	M_SetAnimation(self, gekk_move_leapatk2);

	self.e.mins = { -18, -18, -24 };
	self.e.maxs = { 18, 18, 24 };
}

void land_to_water(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	self.flags = ent_flags_t(self.flags | ent_flags_t::SWIM);
	self.yaw_speed = 10;
	self.viewheight = 10;

	M_SetAnimation(self, gekk_move_swim_start);

	self.e.mins = { -18, -18, -24 };
	self.e.maxs = { 18, 18, 16 };
}

void gekk_swim(ASEntity &self)
{
	if (gekk_checkattack(self))
	{
		if (self.enemy.waterlevel < water_level_t::WAIST && frandom() > 0.7f)
			water_to_land(self);
		else
			M_SetAnimation(self, gekk_move_swim_start);
	}
	else
		M_SetAnimation(self, gekk_move_swim_start);
}

void gekk_stand(ASEntity &self)
{
	if (self.waterlevel >= water_level_t::WAIST)
	{
		self.flags = ent_flags_t(self.flags | ent_flags_t::SWIM);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
		M_SetAnimation(self, gekk_move_standunderwater);
	}
	else
		// Don't break out of the chant loop, which is initiated in the spawn function
		if (self.monsterinfo.active_move !is gekk_move_chant)
			M_SetAnimation(self, gekk_move_stand);
}

void gekk_chant(ASEntity &self)
{
	M_SetAnimation(self, gekk_move_chant);
}

//
// IDLE
//

void gekk_idle_loop(ASEntity &self)
{
	if (frandom() > 0.75f && self.health < self.max_health)
		self.monsterinfo.nextframe = gekk::frames::idle_01;
}

const array<mframe_t> gekk_frames_idle = {
	mframe_t(ai_stand_gekk, 0, gekk_search),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk),

	mframe_t(ai_stand_gekk),
	mframe_t(ai_stand_gekk, 0, gekk_idle_loop)
};
const mmove_t gekk_move_idle = mmove_t(gekk::frames::idle_01, gekk::frames::idle_32, gekk_frames_idle, gekk_stand);
const mmove_t gekk_move_idle2 = mmove_t(gekk::frames::idle_01, gekk::frames::idle_32, gekk_frames_idle, gekk_face);

const array<mframe_t> gekk_frames_idle2 = {
	mframe_t(ai_move, 0, gekk_search),
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
	mframe_t(ai_move, 0, gekk_idle_loop)
};
const mmove_t gekk_move_chant = mmove_t(gekk::frames::idle_01, gekk::frames::idle_32, gekk_frames_idle2, gekk_chant);

void gekk_idle(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::gekk::NOSWIM) != 0 || self.waterlevel < water_level_t::WAIST)
		M_SetAnimation(self, gekk_move_idle);
	else
		M_SetAnimation(self, gekk_move_swim_start);
	// gi.sound (self, soundchan_t::VOICE, gekk::sounds::idle, 1, ATTN_IDLE, 0);
}

//
// WALK
//

const array<mframe_t> gekk_frames_walk = {
	mframe_t(ai_walk, 3.849f, gekk_check_underwater), // frame 0
	mframe_t(ai_walk, 19.606f),						// frame 1
	mframe_t(ai_walk, 25.583f),						// frame 2
	mframe_t(ai_walk, 34.625f, gekk_step),			// frame 3
	mframe_t(ai_walk, 27.365f),						// frame 4
	mframe_t(ai_walk, 28.480f),						// frame 5
};

const mmove_t gekk_move_walk = mmove_t(gekk::frames::run_01, gekk::frames::run_06, gekk_frames_walk, null);

void gekk_walk(ASEntity &self)
{
	M_SetAnimation(self, gekk_move_walk);
}

//
// RUN
//

void gekk_run_start(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::gekk::NOSWIM) == 0 && self.waterlevel >= water_level_t::WAIST)
	{
		M_SetAnimation(self, gekk_move_swim_start);
	}
	else
	{
		M_SetAnimation(self, gekk_move_run_start);
	}
}

void gekk_run(ASEntity &self)
{

	if ((self.spawnflags & spawnflags::gekk::NOSWIM) == 0 && self.waterlevel >= water_level_t::WAIST)
	{
		M_SetAnimation(self, gekk_move_swim_start);
		return;
	}
	else
	{
		if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
			M_SetAnimation(self, gekk_move_stand);
		else
			M_SetAnimation(self, gekk_move_run);
	}
}

const array<mframe_t> gekk_frames_run = {
	mframe_t(ai_run, 3.849f, gekk_check_underwater), // frame 0
	mframe_t(ai_run, 19.606f),					   // frame 1
	mframe_t(ai_run, 25.583f),					   // frame 2
	mframe_t(ai_run, 34.625f, gekk_step),			   // frame 3
	mframe_t(ai_run, 27.365f),					   // frame 4
	mframe_t(ai_run, 28.480f),					   // frame 5
};
const mmove_t gekk_move_run = mmove_t(gekk::frames::run_01, gekk::frames::run_06, gekk_frames_run, null);

const array<mframe_t> gekk_frames_run_st = {
	mframe_t(ai_run, 0.212f),	 // frame 0
	mframe_t(ai_run, 19.753f), // frame 1
};
const mmove_t gekk_move_run_start = mmove_t(gekk::frames::stand_01, gekk::frames::stand_02, gekk_frames_run_st, gekk_run);

//
// MELEE
//

void gekk_hit_left(ASEntity &self)
{
	if (self.enemy is null)
		return;

	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], 8 };
	if (fire_hit(self, aim, irandom(5, 10), 100))
		gi_sound(self.e, soundchan_t::WEAPON, gekk::sounds::hit, 1, ATTN_NORM, 0);
	else
	{
		gi_sound(self.e, soundchan_t::WEAPON, gekk::sounds::swing, 1, ATTN_NORM, 0);
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	}
}

void gekk_hit_right(ASEntity &self)
{
	if (self.enemy is null)
		return;

	vec3_t aim = { MELEE_DISTANCE, self.e.maxs[0], 8 };
	if (fire_hit(self, aim, irandom(5, 10), 100))
		gi_sound(self.e, soundchan_t::WEAPON, gekk::sounds::hit2, 1, ATTN_NORM, 0);
	else
	{
		gi_sound(self.e, soundchan_t::WEAPON, gekk::sounds::swing, 1, ATTN_NORM, 0);
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	}
}

void gekk_check_refire(ASEntity &self)
{
	if (self.enemy is null || !self.enemy.e.inuse || self.enemy.health <= 0)
		return;

	if (range_to(self, self.enemy) <= RANGE_MELEE &&
		self.monsterinfo.melee_debounce_time <= level.time)
	{
		if (self.e.s.frame == gekk::frames::clawatk3_09)
			M_SetAnimation(self, gekk_move_attack2);
		else if (self.e.s.frame == gekk::frames::clawatk5_09)
			M_SetAnimation(self, gekk_move_attack1);
	}
}

void loogie_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other is self.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.owner.client !is null)
		PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
		T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::ENERGY, mod_id_t::GEKK);
	
	gi_sound(self.e, soundchan_t::AUTO, gekk::sounds::loogie_hit, 1.0f, ATTN_NORM, 0);

	G_FreeEdict(self);
};

void fire_loogie(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed)
{
	ASEntity @loogie;
	trace_t	 tr;

	@loogie = G_Spawn();
	loogie.e.s.origin = start;
	loogie.e.s.old_origin = start;
	loogie.e.s.angles = vectoangles(dir);
	loogie.velocity = dir * speed;
	loogie.movetype = movetype_t::FLYMISSILE;
	loogie.e.clipmask = contents_t::MASK_PROJECTILE;
	loogie.e.solid = solid_t::BBOX;
	// Paril: this was originally the wrong effect,
	// but it makes it look more acid-y.
	loogie.e.s.effects = effects_t(loogie.e.s.effects | effects_t::BLASTER);
	loogie.e.s.renderfx = renderfx_t(loogie.e.s.renderfx | renderfx_t::FULLBRIGHT);
	loogie.e.s.modelindex = gi_modelindex("models/objects/loogy/tris.md2");
	@loogie.owner = self;
	@loogie.touch = loogie_touch;
	loogie.nextthink = level.time + time_sec(2);
	@loogie.think = G_FreeEdict;
	loogie.dmg = damage;
	loogie.e.svflags = svflags_t(loogie.e.svflags | svflags_t::PROJECTILE);
	gi_linkentity(loogie.e);

	tr = gi_traceline(self.e.s.origin, loogie.e.s.origin, loogie.e, contents_t::MASK_PROJECTILE);
	if (tr.fraction < 1.0f)
	{
		loogie.e.s.origin = tr.endpos + (tr.plane.normal * 1.f);
		loogie.touch(loogie, cast<ASEntity>(tr.ent.as_obj), tr, false);
	}
}

void loogie(ASEntity &self)
{
	vec3_t start;
	vec3_t forward, right, up;
	vec3_t end;
	vec3_t dir;
	vec3_t gekkoffset = { -18, -0.8f, 24 };

	if (self.enemy is null || self.enemy.health <= 0)
		return;

	AngleVectors(self.e.s.angles, forward, right, up);
	start = M_ProjectFlashSource(self, gekkoffset, forward, right);

	start += (up * 2);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	fire_loogie(self, start, dir, 5, 550);

	gi_sound(self.e, soundchan_t::BODY, gekk::sounds::speet, 1.0f, ATTN_NORM, 0);
}

void reloogie(ASEntity &self)
{
	if (frandom() > 0.8f && self.health < self.max_health)
	{
		M_SetAnimation(self, gekk_move_idle2);
		return;
	}

	if (self.enemy.health > 0)
		if (frandom() > 0.7f && (range_to(self, self.enemy) <= RANGE_NEAR))
			M_SetAnimation(self, gekk_move_spit);
}

const array<mframe_t> gekk_frames_spit = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge, 0, loogie),
	mframe_t(ai_charge, 0, reloogie)
};
const mmove_t gekk_move_spit = mmove_t(gekk::frames::spit_01, gekk::frames::spit_07, gekk_frames_spit, gekk_run_start);

const array<mframe_t> gekk_frames_attack1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge, 0, gekk_hit_left),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gekk_check_refire)
};
const mmove_t gekk_move_attack1 = mmove_t(gekk::frames::clawatk3_01, gekk::frames::clawatk3_09, gekk_frames_attack1, gekk_run_start);

const array<mframe_t> gekk_frames_attack2 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gekk_hit_left),

	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gekk_hit_right),

	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gekk_check_refire)
};
const mmove_t gekk_move_attack2 = mmove_t(gekk::frames::clawatk5_01, gekk::frames::clawatk5_09, gekk_frames_attack2, gekk_run_start);

void gekk_check_underwater(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::gekk::NOSWIM) == 0 && self.waterlevel >= water_level_t::WAIST)
		land_to_water(self);
}

const array<mframe_t> gekk_frames_leapatk = {
	mframe_t(ai_charge),								// frame 0
	mframe_t(ai_charge, -0.387f),						// frame 1
	mframe_t(ai_charge, -1.113f),						// frame 2
	mframe_t(ai_charge, -0.237f),						// frame 3
	mframe_t(ai_charge, 6.720f, gekk_jump_takeoff),	// frame 4  last frame on ground
	mframe_t(ai_charge, 6.414f),						// frame 5  leaves ground
	mframe_t(ai_charge, 0.163f),						// frame 6
	mframe_t(ai_charge, 28.316f),						// frame 7
	mframe_t(ai_charge, 24.198f),						// frame 8
	mframe_t(ai_charge, 31.742f),						// frame 9
	mframe_t(ai_charge, 35.977f, gekk_check_landing), // frame 10  last frame in air
	mframe_t(ai_charge, 12.303f, gekk_stop_skid),		// frame 11  feet back on ground
	mframe_t(ai_charge, 20.122f, gekk_stop_skid),		// frame 12
	mframe_t(ai_charge, -1.042f, gekk_stop_skid),		// frame 13
	mframe_t(ai_charge, 2.556f, gekk_stop_skid),		// frame 14
	mframe_t(ai_charge, 0.544f, gekk_stop_skid),		// frame 15
	mframe_t(ai_charge, 1.862f, gekk_stop_skid),		// frame 16
	mframe_t(ai_charge, 1.224f, gekk_stop_skid),		// frame 17

	mframe_t(ai_charge, -0.457f, gekk_check_underwater), // frame 18
};
const mmove_t gekk_move_leapatk = mmove_t(gekk::frames::leapatk_01, gekk::frames::leapatk_19, gekk_frames_leapatk, gekk_run_start);

const array<mframe_t> gekk_frames_leapatk2 = {
	mframe_t(ai_charge),								// frame 0
	mframe_t(ai_charge, -0.387f),						// frame 1
	mframe_t(ai_charge, -1.113f),						// frame 2
	mframe_t(ai_charge, -0.237f),						// frame 3
	mframe_t(ai_charge, 6.720f, gekk_jump_takeoff2),	// frame 4  last frame on ground
	mframe_t(ai_charge, 6.414f),						// frame 5  leaves ground
	mframe_t(ai_charge, 0.163f),						// frame 6
	mframe_t(ai_charge, 28.316f),						// frame 7
	mframe_t(ai_charge, 24.198f),						// frame 8
	mframe_t(ai_charge, 31.742f),						// frame 9
	mframe_t(ai_charge, 35.977f, gekk_check_landing), // frame 10  last frame in air
	mframe_t(ai_charge, 12.303f, gekk_stop_skid),		// frame 11  feet back on ground
	mframe_t(ai_charge, 20.122f, gekk_stop_skid),		// frame 12
	mframe_t(ai_charge, -1.042f, gekk_stop_skid),		// frame 13
	mframe_t(ai_charge, 2.556f, gekk_stop_skid),		// frame 14
	mframe_t(ai_charge, 0.544f, gekk_stop_skid),		// frame 15
	mframe_t(ai_charge, 1.862f, gekk_stop_skid),		// frame 16
	mframe_t(ai_charge, 1.224f, gekk_stop_skid),		// frame 17

	mframe_t(ai_charge, -0.457f, gekk_check_underwater), // frame 18
};
const mmove_t gekk_move_leapatk2 = mmove_t(gekk::frames::leapatk_01, gekk::frames::leapatk_19, gekk_frames_leapatk2, gekk_run_start);

void gekk_bite(ASEntity &self)
{
	if (self.enemy is null)
		return;

	vec3_t aim = { MELEE_DISTANCE, 0, 0 };
	fire_hit(self, aim, 5, 0);
}

void gekk_preattack(ASEntity &self)
{
	// underwater attack sound
	// gi.sound (self, soundchan_t::WEAPON, something something underwater sound, 1, ATTN_NORM, 0);
	return;
}

const array<mframe_t> gekk_frames_attack = {
	mframe_t(ai_charge, 16, gekk_preattack),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16, gekk_bite),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16, gekk_bite),

	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16, gekk_hit_left),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16),
	mframe_t(ai_charge, 16, gekk_hit_right),
	mframe_t(ai_charge, 16),

	mframe_t(ai_charge, 16)
};
const mmove_t gekk_move_attack = mmove_t(gekk::frames::attack_01, gekk::frames::attack_21, gekk_frames_attack, gekk_run_start);

void gekk_melee(ASEntity &self)
{
	if (self.waterlevel >= water_level_t::WAIST)
	{
		M_SetAnimation(self, gekk_move_attack);
	}
	else
	{
		float r = frandom();

		if (r > 0.66f)
			M_SetAnimation(self, gekk_move_attack1);
		else
			M_SetAnimation(self, gekk_move_attack2);
	}
}

//
// ATTACK
//

void gekk_jump_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.health <= 0)
	{
		@self.touch = null;
		return;
	}

	if (self.style == 1 && other.takedamage)
	{
		if (self.velocity.length() > 200)
		{
			vec3_t point;
			vec3_t normal;
			int	   damage;

			normal = self.velocity;
			normal.normalize();
			point = self.e.s.origin + (normal * self.e.maxs[0]);
			damage = irandom(10, 20);
			T_Damage(other, self, self, self.velocity, point, normal, damage, damage, damageflags_t::NONE, mod_id_t::GEKK);
			self.style = 0;
		}
	}

	if (!M_CheckBottom(self))
	{
		if (self.groundentity !is null)
		{
			self.monsterinfo.nextframe = gekk::frames::leapatk_11;
			@self.touch = null;
		}
		return;
	}

	@self.touch = null;
}

void gekk_jump_takeoff(ASEntity &self)
{
	vec3_t forward;

	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::sight, 1, ATTN_NORM, 0);
	AngleVectors(self.e.s.angles, forward);
	self.e.s.origin[2] += 1;

	// high jump
	if (gekk_check_jump(self))
	{
		self.velocity = forward * 700;
		self.velocity[2] = 250;
	}
	else
	{
		self.velocity = forward * 250;
		self.velocity[2] = 400;
	}

	@self.groundentity = null;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DUCKED);
	self.monsterinfo.attack_finished = level.time + time_sec(3);
	@self.touch = gekk_jump_touch;
	self.style = 1;
}

void gekk_jump_takeoff2(ASEntity &self)
{
	vec3_t forward;

	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::sight, 1, ATTN_NORM, 0);
	AngleVectors(self.e.s.angles, forward);
	self.e.s.origin[2] = self.enemy.e.s.origin[2];

	if (gekk_check_jump(self))
	{
		self.velocity = forward * 300;
		self.velocity[2] = 250;
	}
	else
	{
		self.velocity = forward * 150;
		self.velocity[2] = 300;
	}

	@self.groundentity = null;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DUCKED);
	self.monsterinfo.attack_finished = level.time + time_sec(3);
	@self.touch = gekk_jump_touch;
	self.style = 1;
}

void gekk_stop_skid(ASEntity &self)
{
	if (self.groundentity !is null)
		self.velocity = vec3_origin;
}

void gekk_check_landing(ASEntity &self)
{
	if (self.groundentity !is null)
	{
		gi_sound(self.e, soundchan_t::WEAPON, gekk::sounds::thud, 1, ATTN_NORM, 0);
		self.monsterinfo.attack_finished = time_zero;

		if (self.monsterinfo.unduck !is null)
			self.monsterinfo.unduck(self);

		self.velocity = vec3_origin;
		return;
	}

	// Paril: allow them to "pull" up ledges
	vec3_t fwd;
	AngleVectors(self.e.s.angles, fwd);

	if (fwd.dot(self.velocity) < 200)
		self.velocity += (fwd * 200.f);

	// note to self
	// causing skid
	if (level.time > self.monsterinfo.attack_finished)
		self.monsterinfo.nextframe = gekk::frames::leapatk_11;
	else
	{
		self.monsterinfo.nextframe = gekk::frames::leapatk_12;
	}
}

void gekk_attack(ASEntity &self)
{
	float r = range_to(self, self.enemy);

	if ((self.flags & ent_flags_t::SWIM) != 0)
	{
		if (self.enemy !is null && self.enemy.waterlevel >= water_level_t::WAIST && r <= RANGE_NEAR)
			return;

		self.flags = ent_flags_t(self.flags & ~ent_flags_t::SWIM);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::ALTERNATE_FLY);
		M_SetAnimation(self, gekk_move_leapatk);
		self.monsterinfo.nextframe = gekk::frames::leapatk_05;
	}
	else
	{
		if (r >= RANGE_MID) {
			if (frandom() > 0.5f) {
				M_SetAnimation(self, gekk_move_spit);
			} else {
				M_SetAnimation(self, gekk_move_run_start);
				self.monsterinfo.attack_finished = level.time + time_sec(2);
			}
		} else if (frandom() > 0.7f) {
			M_SetAnimation(self, gekk_move_spit);
		} else {
			if ((self.spawnflags & spawnflags::gekk::NOJUMPING) != 0 || frandom() > 0.7f) {
				M_SetAnimation(self, gekk_move_run_start);
				self.monsterinfo.attack_finished = level.time + time_sec(1.4);
			} else {
				M_SetAnimation(self, gekk_move_leapatk);
			}
		}
	}
}

//
// PAIN
//

const array<mframe_t> gekk_frames_pain = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
};
const mmove_t gekk_move_pain = mmove_t(gekk::frames::pain_01, gekk::frames::pain_06, gekk_frames_pain, gekk_run_start);

const array<mframe_t> gekk_frames_pain1 = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
	mframe_t(ai_move), // frame 6
	mframe_t(ai_move), // frame 7
	mframe_t(ai_move), // frame 8
	mframe_t(ai_move), // frame 9

	mframe_t(ai_move, 0, gekk_check_underwater)
};
const mmove_t gekk_move_pain1 = mmove_t(gekk::frames::pain3_01, gekk::frames::pain3_11, gekk_frames_pain1, gekk_run_start);

const array<mframe_t> gekk_frames_pain2 = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
	mframe_t(ai_move), // frame 6
	mframe_t(ai_move), // frame 7
	mframe_t(ai_move), // frame 8
	mframe_t(ai_move), // frame 9

	mframe_t(ai_move), // frame 10
	mframe_t(ai_move), // frame 11
	mframe_t(ai_move, 0, gekk_check_underwater),
};
const mmove_t gekk_move_pain2 = mmove_t(gekk::frames::pain4_01, gekk::frames::pain4_13, gekk_frames_pain2, gekk_run_start);

void gekk_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	float r;

	if ((self.spawnflags & spawnflags::gekk::CHANT) != 0)
	{
		self.spawnflags &= ~spawnflags::gekk::CHANT;
		return;
	}

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::pain1, 1, ATTN_NORM, 0);

	if (self.waterlevel >= water_level_t::WAIST)
	{
		if ((self.flags & ent_flags_t::SWIM) == 0)
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
			self.flags = ent_flags_t(self.flags | ent_flags_t::SWIM);
		}

		if (M_ShouldReactToPain(self, mod)) // no pain anims in nightmare
			M_SetAnimation(self, gekk_move_pain);
	}
	else if (M_ShouldReactToPain(self, mod)) // no pain anims in nightmare
	{
		r = frandom();

		if (r > 0.5f)
			M_SetAnimation(self, gekk_move_pain1);
		else
			M_SetAnimation(self, gekk_move_pain2);
	}
}

//
// DEATH
//

void gekk_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void gekk_gib(ASEntity &self, int damage)
{
	gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

	ThrowGibs(self, damage, {
		gib_def_t("models/objects/gekkgib/pelvis/tris.md2", gib_type_t::ACID),
		gib_def_t(2, "models/objects/gekkgib/arm/tris.md2", gib_type_t::ACID),
		gib_def_t("models/objects/gekkgib/torso/tris.md2", gib_type_t::ACID),
		gib_def_t("models/objects/gekkgib/claw/tris.md2", gib_type_t::ACID),
		gib_def_t(2, "models/objects/gekkgib/leg/tris.md2", gib_type_t::ACID),
		gib_def_t("models/objects/gekkgib/head/tris.md2", gib_type_t(gib_type_t::ACID | gib_type_t::HEAD))
	});
}

void gekk_gibfest(ASEntity &self)
{
	gekk_gib(self, 20);
	self.deadflag = true;
}

void isgibfest(ASEntity &self)
{
	if (frandom() > 0.9f)
		gekk_gibfest(self);
}

void gekk_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> gekk_frames_death1 = {
	mframe_t(ai_move, -5.151f),			   // frame 0
	mframe_t(ai_move, -12.223f),			   // frame 1
	mframe_t(ai_move, -11.484f),			   // frame 2
	mframe_t(ai_move, -17.952f),			   // frame 3
	mframe_t(ai_move, -6.953f),			   // frame 4
	mframe_t(ai_move, -7.393f, gekk_shrink), // frame 5
	mframe_t(ai_move, -10.713f),			   // frame 6
	mframe_t(ai_move, -17.464f),			   // frame 7
	mframe_t(ai_move, -11.678f),			   // frame 8
	mframe_t(ai_move, -11.678f)			   // frame 9
};
const mmove_t gekk_move_death1 = mmove_t(gekk::frames::death1_01, gekk::frames::death1_10, gekk_frames_death1, gekk_dead);

const array<mframe_t> gekk_frames_death3 = {
	mframe_t(ai_move),					 // frame 0
	mframe_t(ai_move, 0.022f),			 // frame 1
	mframe_t(ai_move, 0.169f),			 // frame 2
	mframe_t(ai_move, -0.710f),			 // frame 3
	mframe_t(ai_move, -13.446f),			 // frame 4
	mframe_t(ai_move, -7.654f, isgibfest), // frame 5
	mframe_t(ai_move, -31.951f),			 // frame 6
};
const mmove_t gekk_move_death3 = mmove_t(gekk::frames::death3_01, gekk::frames::death3_07, gekk_frames_death3, gekk_dead);

const array<mframe_t> gekk_frames_death4 = {
	mframe_t(ai_move, 5.103f),			   // frame 0
	mframe_t(ai_move, -4.808f),			   // frame 1
	mframe_t(ai_move, -10.509f),			   // frame 2
	mframe_t(ai_move, -9.899f),			   // frame 3
	mframe_t(ai_move, 4.033f, isgibfest),	   // frame 4
	mframe_t(ai_move, -5.197f),			   // frame 5
	mframe_t(ai_move, -0.919f),			   // frame 6
	mframe_t(ai_move, -8.821f),			   // frame 7
	mframe_t(ai_move, -5.626f),			   // frame 8
	mframe_t(ai_move, -8.865f, isgibfest),   // frame 9
	mframe_t(ai_move, -0.845f),			   // frame 10
	mframe_t(ai_move, 1.986f),			   // frame 11
	mframe_t(ai_move, 0.170f),			   // frame 12
	mframe_t(ai_move, 1.339f, isgibfest),	   // frame 13
	mframe_t(ai_move, -0.922f),			   // frame 14
	mframe_t(ai_move, 0.818f),			   // frame 15
	mframe_t(ai_move, -1.288f),			   // frame 16
	mframe_t(ai_move, -1.408f, isgibfest),   // frame 17
	mframe_t(ai_move, -7.787f),			   // frame 18
	mframe_t(ai_move, -3.995f),			   // frame 19
	mframe_t(ai_move, -4.604f),			   // frame 20
	mframe_t(ai_move, -1.715f, isgibfest),   // frame 21
	mframe_t(ai_move, -0.564f),			   // frame 22
	mframe_t(ai_move, -0.597f),			   // frame 23
	mframe_t(ai_move, 0.074f),			   // frame 24
	mframe_t(ai_move, -0.309f, isgibfest),   // frame 25
	mframe_t(ai_move, -0.395f),			   // frame 26
	mframe_t(ai_move, -0.501f),			   // frame 27
	mframe_t(ai_move, -0.325f),			   // frame 28
	mframe_t(ai_move, -0.931f, isgibfest),   // frame 29
	mframe_t(ai_move, -1.433f),			   // frame 30
	mframe_t(ai_move, -1.626f),			   // frame 31
	mframe_t(ai_move, 4.680f),			   // frame 32
	mframe_t(ai_move, 0.560f),			   // frame 33
	mframe_t(ai_move, -0.549f, gekk_gibfest) // frame 34
};
const mmove_t gekk_move_death4 = mmove_t(gekk::frames::death4_01, gekk::frames::death4_35, gekk_frames_death4, gekk_dead);

const array<mframe_t> gekk_frames_wdeath = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
	mframe_t(ai_move), // frame 6
	mframe_t(ai_move), // frame 7
	mframe_t(ai_move), // frame 8
	mframe_t(ai_move), // frame 9
	mframe_t(ai_move), // frame 10
	mframe_t(ai_move), // frame 11
	mframe_t(ai_move), // frame 12
	mframe_t(ai_move), // frame 13
	mframe_t(ai_move), // frame 14
	mframe_t(ai_move), // frame 15
	mframe_t(ai_move), // frame 16
	mframe_t(ai_move), // frame 17
	mframe_t(ai_move), // frame 18
	mframe_t(ai_move), // frame 19
	mframe_t(ai_move), // frame 20
	mframe_t(ai_move), // frame 21
	mframe_t(ai_move), // frame 22
	mframe_t(ai_move), // frame 23
	mframe_t(ai_move), // frame 24
	mframe_t(ai_move), // frame 25
	mframe_t(ai_move), // frame 26
	mframe_t(ai_move), // frame 27
	mframe_t(ai_move), // frame 28
	mframe_t(ai_move), // frame 29
	mframe_t(ai_move), // frame 30
	mframe_t(ai_move), // frame 31
	mframe_t(ai_move), // frame 32
	mframe_t(ai_move), // frame 33
	mframe_t(ai_move), // frame 34
	mframe_t(ai_move), // frame 35
	mframe_t(ai_move), // frame 36
	mframe_t(ai_move), // frame 37
	mframe_t(ai_move), // frame 38
	mframe_t(ai_move), // frame 39
	mframe_t(ai_move), // frame 40
	mframe_t(ai_move), // frame 41
	mframe_t(ai_move), // frame 42
	mframe_t(ai_move), // frame 43
	mframe_t(ai_move)	 // frame 44
};
const mmove_t gekk_move_wdeath = mmove_t(gekk::frames::wdeath_01, gekk::frames::wdeath_45, gekk_frames_wdeath, gekk_dead);

void gekk_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	float r;

	if (M_CheckGib(self, mod))
	{
		gekk_gib(self, damage);
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	gi_sound(self.e, soundchan_t::VOICE, gekk::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	if (self.waterlevel >= water_level_t::WAIST)
	{
		gekk_shrink(self);
		M_SetAnimation(self, gekk_move_wdeath);
	}
	else
	{
		r = frandom();
		if (r > 0.66f)
			M_SetAnimation(self, gekk_move_death1);
		else if (r > 0.33f)
			M_SetAnimation(self, gekk_move_death3);
		else
			M_SetAnimation(self, gekk_move_death4);
	}
}

/*
	duck
*/
const array<mframe_t> gekk_frames_lduck = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
	mframe_t(ai_move), // frame 6
	mframe_t(ai_move), // frame 7
	mframe_t(ai_move), // frame 8
	mframe_t(ai_move), // frame 9

	mframe_t(ai_move), // frame 10
	mframe_t(ai_move), // frame 11
	mframe_t(ai_move)	 // frame 12
};
const mmove_t gekk_move_lduck = mmove_t(gekk::frames::lduck_01, gekk::frames::lduck_13, gekk_frames_lduck, gekk_run_start);

const array<mframe_t> gekk_frames_rduck = {
	mframe_t(ai_move), // frame 0
	mframe_t(ai_move), // frame 1
	mframe_t(ai_move), // frame 2
	mframe_t(ai_move), // frame 3
	mframe_t(ai_move), // frame 4
	mframe_t(ai_move), // frame 5
	mframe_t(ai_move), // frame 6
	mframe_t(ai_move), // frame 7
	mframe_t(ai_move), // frame 8
	mframe_t(ai_move), // frame 9
	mframe_t(ai_move), // frame 10
	mframe_t(ai_move), // frame 11
	mframe_t(ai_move)	 // frame 12
};
const mmove_t gekk_move_rduck = mmove_t(gekk::frames::rduck_01, gekk::frames::rduck_13, gekk_frames_rduck, gekk_run_start);

void gekk_dodge(ASEntity &self, ASEntity &attacker, gtime_t eta, const trace_t &in tr, bool gravity, bool not_trace)
{
	// [Paril-KEX] this dodge is bad
/*
	float r;

	r = frandom();
	if (r > 0.25f)
		return;

	if (!self.enemy)
		self.enemy = attacker;

	if (self.waterlevel)
	{
		M_SetAnimation(self, gekk_move_attack);
		return;
	}

	if (skill.integer == 0)
	{
		r = frandom();
		if (r > 0.5f)
			M_SetAnimation(self, gekk_move_lduck);
		else
			M_SetAnimation(self, gekk_move_rduck);
		return;
	}

	self.monsterinfo.pausetime = level.time + eta + time_ms(300);
	r = frandom();

	if (skill.integer == 1)
	{
		if (r > 0.33f)
		{
			r = frandom();
			if (r > 0.5f)
				M_SetAnimation(self, gekk_move_lduck);
			else
				M_SetAnimation(self, gekk_move_rduck);
		}
		else
		{
			r = frandom();
			if (r > 0.66f)
				M_SetAnimation(self, gekk_move_attack1);
			else
				M_SetAnimation(self, gekk_move_attack2);
		}
		return;
	}

	if (skill.integer == 2)
	{
		if (r > 0.66f)
		{
			r = frandom();
			if (r > 0.5f)
				M_SetAnimation(self, gekk_move_lduck);
			else
				M_SetAnimation(self, gekk_move_rduck);
		}
		else
		{
			r = frandom();
			if (r > 0.66f)
				M_SetAnimation(self, gekk_move_attack1);
			else
				M_SetAnimation(self, gekk_move_attack2);
		}
		return;
	}

	r = frandom();
	if (r > 0.66f)
		M_SetAnimation(self, gekk_move_attack1);
	else
		M_SetAnimation(self, gekk_move_attack2);
*/
}

//
// SPAWN
//

void gekk_set_fly_parameters(ASEntity &self)
{
	self.monsterinfo.fly_thrusters = false;
	self.monsterinfo.fly_acceleration = 25.f;
	self.monsterinfo.fly_speed = 150.f;
	// only melee, so get in close
	self.monsterinfo.fly_min_distance = 10.f;
	self.monsterinfo.fly_max_distance = 10.f;
}


//================
// ROGUE
void gekk_jump_down(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void gekk_jump_up(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 200);
	self.velocity += (up * 450);
}

void gekk_jump_wait_land(ASEntity &self)
{
	if (!monster_jump_finished(self) && self.groundentity is null)
		self.monsterinfo.nextframe = self.e.s.frame;
	else
		self.monsterinfo.nextframe = self.e.s.frame + 1;
}

const array<mframe_t> gekk_frames_jump_up = {
	mframe_t(ai_move, -8, gekk_jump_up),
	mframe_t(ai_move, -8),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gekk_jump_wait_land),
	mframe_t(ai_move)
};
const mmove_t gekk_move_jump_up = mmove_t(gekk::frames::leapatk_04, gekk::frames::leapatk_11, gekk_frames_jump_up, gekk_run);

const array<mframe_t> gekk_frames_jump_down = {
	mframe_t(ai_move, 0, gekk_jump_down),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gekk_jump_wait_land),
	mframe_t(ai_move)
};
const mmove_t gekk_move_jump_down = mmove_t(gekk::frames::leapatk_04, gekk::frames::leapatk_11, gekk_frames_jump_down, gekk_run);

void gekk_jump_updown(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, gekk_move_jump_up);
	else
		M_SetAnimation(self, gekk_move_jump_down);
}

/*
===
Blocked
===
*/
bool gekk_blocked(ASEntity &self, float dist)
{
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			gekk_jump_updown(self, result);
		return true;
	}

	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// ROGUE
//================

/*QUAKED monster_gekk (1 .5 0) (-16 -16 -24) (16 16 24) Ambush Trigger_Spawn Sight Chant NoJumping
 */
void SP_monster_gekk(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	gekk::sounds::swing.precache();
	gekk::sounds::hit.precache();
	gekk::sounds::hit2.precache();
	gekk::sounds::speet.precache();
	gekk::sounds::loogie_hit.precache();
	gekk::sounds::death.precache();
	gekk::sounds::pain1.precache();
	gekk::sounds::sight.precache();
	gekk::sounds::search.precache();
	gekk::sounds::step1.precache();
	gekk::sounds::step2.precache();
	gekk::sounds::step3.precache();
	gekk::sounds::thud.precache();
	gekk::sounds::chantlow.precache();
	gekk::sounds::chantmid.precache();
	gekk::sounds::chanthigh.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/gekk/tris.md2");
	self.e.mins = { -18, -18, -24 };
	self.e.maxs = { 18, 18, 24 };

	gi_modelindex("models/objects/gekkgib/pelvis/tris.md2");
	gi_modelindex("models/objects/gekkgib/arm/tris.md2");
	gi_modelindex("models/objects/gekkgib/torso/tris.md2");
	gi_modelindex("models/objects/gekkgib/claw/tris.md2");
	gi_modelindex("models/objects/gekkgib/leg/tris.md2");
	gi_modelindex("models/objects/gekkgib/head/tris.md2");

	self.health = int(125 * st.health_multiplier);
	self.gib_health = -30;
	self.mass = 300;

	@self.pain = gekk_pain;
	@self.die = gekk_die;

	@self.monsterinfo.stand = gekk_stand;

	@self.monsterinfo.walk = gekk_walk;
	@self.monsterinfo.run = gekk_run_start;
	@self.monsterinfo.dodge = gekk_dodge;
	@self.monsterinfo.attack = gekk_attack;
	@self.monsterinfo.melee = gekk_melee;
	@self.monsterinfo.sight = gekk_sight;
	@self.monsterinfo.search = gekk_search;
	@self.monsterinfo.idle = gekk_idle;
	@self.monsterinfo.checkattack = gekk_checkattack;
	@self.monsterinfo.setskin = gekk_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, gekk_move_stand);

	self.monsterinfo.scale = gekk::SCALE;
	
	walkmonster_start(self);

	if ((self.spawnflags & spawnflags::gekk::CHANT) != 0)
		M_SetAnimation(self, gekk_move_chant);

	self.monsterinfo.can_jump = (self.spawnflags & spawnflags::gekk::NOJUMPING) == 0;
	self.monsterinfo.drop_height = 256;
	self.monsterinfo.jump_height = 68;
	@self.monsterinfo.blocked = gekk_blocked;

	gekk_set_fly_parameters(self);
}