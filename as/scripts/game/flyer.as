// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

flyer

==============================================================================
*/

namespace flyer
{
    enum frames
    {
        start01,
        start02,
        start03,
        start04,
        start05,
        start06,
        stop01,
        stop02,
        stop03,
        stop04,
        stop05,
        stop06,
        stop07,
        stand01,
        stand02,
        stand03,
        stand04,
        stand05,
        stand06,
        stand07,
        stand08,
        stand09,
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
        attak101,
        attak102,
        attak103,
        attak104,
        attak105,
        attak106,
        attak107,
        attak108,
        attak109,
        attak110,
        attak111,
        attak112,
        attak113,
        attak114,
        attak115,
        attak116,
        attak117,
        attak118,
        attak119,
        attak120,
        attak121,
        attak201,
        attak202,
        attak203,
        attak204,
        attak205,
        attak206,
        attak207,
        attak208,
        attak209,
        attak210,
        attak211,
        attak212,
        attak213,
        attak214,
        attak215,
        attak216,
        attak217,
        bankl01,
        bankl02,
        bankl03,
        bankl04,
        bankl05,
        bankl06,
        bankl07,
        bankr01,
        bankr02,
        bankr03,
        bankr04,
        bankr05,
        bankr06,
        bankr07,
        rollf01,
        rollf02,
        rollf03,
        rollf04,
        rollf05,
        rollf06,
        rollf07,
        rollf08,
        rollf09,
        rollr01,
        rollr02,
        rollr03,
        rollr04,
        rollr05,
        rollr06,
        rollr07,
        rollr08,
        rollr09,
        defens01,
        defens02,
        defens03,
        defens04,
        defens05,
        defens06,
        pain101,
        pain102,
        pain103,
        pain104,
        pain105,
        pain106,
        pain107,
        pain108,
        pain109,
        pain201,
        pain202,
        pain203,
        pain204,
        pain301,
        pain302,
        pain303,
        pain304
    };

    const float SCALE = 1.000000f;
}

namespace flyer::sounds
{
    cached_soundindex sight("flyer/flysght1.wav");
    cached_soundindex idle("flyer/flysrch1.wav");
    cached_soundindex pain1("flyer/flypain1.wav");
    cached_soundindex pain2("flyer/flypain2.wav");
    cached_soundindex slash("flyer/flyatck2.wav");
    cached_soundindex sproing("flyer/flyatck1.wav");
    cached_soundindex die("flyer/flydeth1.wav");
}

void flyer_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::sight, 1, ATTN_NORM, 0);
}

void flyer_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::idle, 1, ATTN_IDLE, 0);
}

void flyer_pop_blades(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::sproing, 1, ATTN_NORM, 0);
}

const array<mframe_t> flyer_frames_stand = {
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
const mmove_t flyer_move_stand = mmove_t(flyer::frames::stand01, flyer::frames::stand45, flyer_frames_stand, null);

const array<mframe_t> flyer_frames_walk = {
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5)
};
const mmove_t flyer_move_walk = mmove_t(flyer::frames::stand01, flyer::frames::stand45, flyer_frames_walk, null);

const array<mframe_t> flyer_frames_run = {
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
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10)
};
const mmove_t flyer_move_run = mmove_t(flyer::frames::stand01, flyer::frames::stand45, flyer_frames_run, null);

const array<mframe_t> flyer_frames_kamizake = {
	mframe_t(ai_charge, 40, flyer_kamikaze_check),
	mframe_t(ai_charge, 40, flyer_kamikaze_check),
	mframe_t(ai_charge, 40, flyer_kamikaze_check),
	mframe_t(ai_charge, 40, flyer_kamikaze_check),
	mframe_t(ai_charge, 40, flyer_kamikaze_check)
};
const mmove_t flyer_move_kamikaze = mmove_t(flyer::frames::rollr02, flyer::frames::rollr06, flyer_frames_kamizake, flyer_kamikaze);

void flyer_run(ASEntity &self)
{
	if (self.mass > 50)
		M_SetAnimation(self, flyer_move_kamikaze);
	else if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, flyer_move_stand);
	else
		M_SetAnimation(self, flyer_move_run);
}

void flyer_walk(ASEntity &self)
{
	if (self.mass > 50)
		flyer_run(self);
	else
		M_SetAnimation(self, flyer_move_walk);
}

void flyer_stand(ASEntity &self)
{
	if (self.mass > 50)
		flyer_run(self);
	else
		M_SetAnimation(self, flyer_move_stand);
}

// ROGUE - kamikaze stuff

void flyer_kamikaze_explode(ASEntity &self)
{
	vec3_t dir;

	if (self.monsterinfo.commander !is null && self.monsterinfo.commander.e.inuse &&
		self.monsterinfo.commander.classname == "monster_carrier")
		self.monsterinfo.commander.monsterinfo.monster_slots++;

	if (self.enemy !is null)
	{
		dir = self.enemy.e.s.origin - self.e.s.origin;
		T_Damage(self.enemy, self, self, dir, self.e.s.origin, vec3_origin, 50, 50, damageflags_t::RADIUS, mod_id_t::UNKNOWN);
	}

	flyer_die(self, world, world, 0, dir, mod_id_t::EXPLOSIVE);
}

void flyer_kamikaze(ASEntity &self)
{
	M_SetAnimation(self, flyer_move_kamikaze);
}

void flyer_kamikaze_check(ASEntity &self)
{
	float dist;

	// PMM - this needed because we could have gone away before we get here (blocked code)
	if (!self.e.inuse)
		return;

	if ((self.enemy is null) || (!self.enemy.e.inuse))
	{
		flyer_kamikaze_explode(self);
		return;
	}

	self.e.s.angles.x = vectoangles(self.enemy.e.s.origin - self.e.s.origin).x;

	@self.goalentity = self.enemy;

	dist = realrange(self, self.enemy);

	if (dist < 90)
		flyer_kamikaze_explode(self);
}

/*
const array<mframe_t> flyer_frames_rollright = {
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
const mmove_t flyer_move_rollright = mmove_t(flyer::frames::rollr01, flyer::frames::rollr09, flyer_frames_rollright, null);

const array<mframe_t> flyer_frames_rollleft = {
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
const mmove_t flyer_move_rollleft = mmove_t(flyer::frames::rollf01, flyer::frames::rollf09, flyer_frames_rollleft, null);
*/

const array<mframe_t> flyer_frames_pain3 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flyer_move_pain3 = mmove_t(flyer::frames::pain301, flyer::frames::pain304, flyer_frames_pain3, flyer_run);

const array<mframe_t> flyer_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flyer_move_pain2 = mmove_t(flyer::frames::pain201, flyer::frames::pain204, flyer_frames_pain2, flyer_run);

const array<mframe_t> flyer_frames_pain1 = {
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
const mmove_t flyer_move_pain1 = mmove_t(flyer::frames::pain101, flyer::frames::pain109, flyer_frames_pain1, flyer_run);

/*
const array<mframe_t> flyer_frames_defense = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // Hold this frame
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flyer_move_defense = mmove_t(flyer::frames::defens01, flyer::frames::defens06, flyer_frames_defense, null);

const array<mframe_t> flyer_frames_bankright = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flyer_move_bankright = mmove_t(flyer::frames::bankr01, flyer::frames::bankr07, flyer_frames_bankright, null);

const array<mframe_t> flyer_frames_bankleft = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flyer_move_bankleft = mmove_t(flyer::frames::bankl01, flyer::frames::bankl07, flyer_frames_bankleft, null);
*/

void flyer_fire(ASEntity &self, monster_muzzle_t flash_number)
{
	vec3_t	  start;
	vec3_t	  forward, right;
	vec3_t	  end;
	vec3_t	  dir;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	monster_fire_blaster(self, start, dir, 1, 1000, flash_number, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::HYPERBLASTER);
}

void flyer_fireleft(ASEntity &self)
{
	flyer_fire(self, monster_muzzle_t::FLYER_BLASTER_1);
}

void flyer_fireright(ASEntity &self)
{
	flyer_fire(self, monster_muzzle_t::FLYER_BLASTER_2);
}

const array<mframe_t> flyer_frames_attack2 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -10, flyer_fireleft),	 // left gun
	mframe_t(ai_charge, -10, flyer_fireright), // right gun
	mframe_t(ai_charge, -10, flyer_fireleft),	 // left gun
	mframe_t(ai_charge, -10, flyer_fireright), // right gun
	mframe_t(ai_charge, -10, flyer_fireleft),	 // left gun
	mframe_t(ai_charge, -10, flyer_fireright), // right gun
	mframe_t(ai_charge, -10, flyer_fireleft),	 // left gun
	mframe_t(ai_charge, -10, flyer_fireright), // right gun
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t flyer_move_attack2 = mmove_t(flyer::frames::attak201, flyer::frames::attak217, flyer_frames_attack2, flyer_run);

// PMM
// circle strafe frames

const array<mframe_t> flyer_frames_attack3 = {
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10, flyer_fireleft),	// left gun
	mframe_t(ai_charge, 10, flyer_fireright), // right gun
	mframe_t(ai_charge, 10, flyer_fireleft),	// left gun
	mframe_t(ai_charge, 10, flyer_fireright), // right gun
	mframe_t(ai_charge, 10, flyer_fireleft),	// left gun
	mframe_t(ai_charge, 10, flyer_fireright), // right gun
	mframe_t(ai_charge, 10, flyer_fireleft),	// left gun
	mframe_t(ai_charge, 10, flyer_fireright), // right gun
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10)
};
const mmove_t flyer_move_attack3 = mmove_t(flyer::frames::attak201, flyer::frames::attak217, flyer_frames_attack3, flyer_run);
// pmm

void flyer_slash_left(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.mins.x, 0 };
	if (!fire_hit(self, aim, 5, 0))
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	gi_sound(self.e, soundchan_t::WEAPON, flyer::sounds::slash, 1, ATTN_NORM, 0);
}

void flyer_slash_right(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.maxs.x, 0 };
	if (!fire_hit(self, aim, 5, 0))
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	gi_sound(self.e, soundchan_t::WEAPON, flyer::sounds::slash, 1, ATTN_NORM, 0);
}

const array<mframe_t> flyer_frames_start_melee = {
	mframe_t(ai_charge, 0, flyer_pop_blades),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t flyer_move_start_melee = mmove_t(flyer::frames::attak101, flyer::frames::attak106, flyer_frames_start_melee, flyer_loop_melee);

const array<mframe_t> flyer_frames_end_melee = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t flyer_move_end_melee = mmove_t(flyer::frames::attak119, flyer::frames::attak121, flyer_frames_end_melee, flyer_run);

const array<mframe_t> flyer_frames_loop_melee = {
	mframe_t(ai_charge), // Loop Start
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, flyer_slash_left), // Left Wing Strike
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, flyer_slash_right), // Right Wing Strike
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge) // Loop Ends

};
const mmove_t flyer_move_loop_melee = mmove_t(flyer::frames::attak107, flyer::frames::attak118, flyer_frames_loop_melee, flyer_check_melee);

void flyer_loop_melee(ASEntity &self)
{
	M_SetAnimation(self, flyer_move_loop_melee);
}

void flyer_set_fly_parameters(ASEntity &self, bool melee)
{
	if (melee)
	{
		// engage thrusters for a slice
		self.monsterinfo.fly_pinned = false;
		self.monsterinfo.fly_thrusters = true;
		self.monsterinfo.fly_position_time = time_sec(0);
		self.monsterinfo.fly_acceleration = 20.f;
		self.monsterinfo.fly_speed = 210.f;
		self.monsterinfo.fly_min_distance = 0.f;
		self.monsterinfo.fly_max_distance = 10.f;
	}
	else
	{
		self.monsterinfo.fly_thrusters = false;
		self.monsterinfo.fly_acceleration = 15.f;
		self.monsterinfo.fly_speed = 165.f;
		self.monsterinfo.fly_min_distance = 45.f;
		self.monsterinfo.fly_max_distance = 200.f;
	}
}

void flyer_attack(ASEntity &self)
{
	if (self.mass > 50)
	{
		flyer_run(self);
		return;
	}

	float range = range_to(self, self.enemy);

	if (self.enemy !is null && visible(self, self.enemy) && range <= 225.f && frandom() > (range / 225.f) * 0.35f)
	{
		// fly-by slicing!
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		M_SetAnimation(self, flyer_move_start_melee);
		flyer_set_fly_parameters(self, true);
	}
	else
	{
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		M_SetAnimation(self, flyer_move_attack2);
	}

	// [Paril-KEX] for alternate fly mode, sometimes we'll pin us
	// down, kind of like a pseudo-stand ground
	if (!self.monsterinfo.fly_pinned && brandom() && self.enemy !is null && visible(self, self.enemy))
	{
		self.monsterinfo.fly_pinned = true;
		self.monsterinfo.fly_position_time = max(self.monsterinfo.fly_position_time, self.monsterinfo.fly_position_time + time_sec(1.7)); // make sure there's enough time for attack2/3

		if (brandom())
			self.monsterinfo.fly_ideal_position = self.e.s.origin + (self.velocity * frandom()); // pin to our current position
		else
			self.monsterinfo.fly_ideal_position += self.enemy.e.s.origin; // make un-relative
	}

	// if we're currently pinned, fly_position_time will unpin us eventually
}

void flyer_melee(ASEntity &self)
{
	if (self.mass > 50)
		flyer_run(self);
	else
	{
		M_SetAnimation(self, flyer_move_start_melee);
		flyer_set_fly_parameters(self, true);
	}
}

void flyer_check_melee(ASEntity &self)
{
	if (range_to(self, self.enemy) <= RANGE_MELEE)
	{
		if (self.monsterinfo.melee_debounce_time <= level.time)
		{
			M_SetAnimation(self, flyer_move_loop_melee);
			return;
		}
	}

	M_SetAnimation(self, flyer_move_end_melee);
	flyer_set_fly_parameters(self, false);
}

void flyer_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	int n;

	//	pmm	 - kamikaze's don't feel pain
	if (self.mass != 50)
		return;
	// pmm

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	n = irandom(3);
	if (n == 0)
		gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::pain1, 1, ATTN_NORM, 0);
	else if (n == 1)
		gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::pain2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::pain1, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	flyer_set_fly_parameters(self, false);

	if (n == 0)
		M_SetAnimation(self, flyer_move_pain1);
	else if (n == 1)
		M_SetAnimation(self, flyer_move_pain2);
	else
		M_SetAnimation(self, flyer_move_pain3);
}

void flyer_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void flyer_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_sound(self.e, soundchan_t::VOICE, flyer::sounds::die, 1, ATTN_NORM, 0);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.skinnum /= 2;

	ThrowGibs(self, 55, {
		gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2"),
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t("models/monsters/flyer/gibs/base.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/flyer/gibs/gun.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/flyer/gibs/wing.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/flyer/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
	});
	
	@self.touch = null;
}

// PMM - kamikaze code .. blow up if blocked
bool flyer_blocked(ASEntity &self, float dist)
{
	// kamikaze = 100, normal = 50
	if (self.mass == 100)
	{
		flyer_kamikaze_check(self);

		// if the above didn't blow us up (i.e. I got blocked by the player)
		if (self.e.inuse)
			T_Damage(self, self, self, vec3_origin, self.e.s.origin, vec3_origin, 9999, 100, damageflags_t::NONE, mod_id_t::UNKNOWN);

		return true;
	}

	return false;
}

void kamikaze_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	T_Damage(ent, ent, ent, ent.velocity.normalized(), ent.e.s.origin, ent.velocity.normalized(), 9999, 100, damageflags_t::NONE, mod_id_t::UNKNOWN);
}

void flyer_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if ((other.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0 && (other.flags & ent_flags_t::FLY) != 0 &&
		(ent.monsterinfo.duck_wait_time < level.time))
	{
		ent.monsterinfo.duck_wait_time = level.time + time_sec(1);
		ent.monsterinfo.fly_thrusters = false;

		vec3_t dir = (ent.e.s.origin - other.e.s.origin).normalized();
		ent.velocity = dir * 500.f;

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::SPLASH);
		gi_WriteByte(32);
		gi_WritePosition(tr.endpos);
		gi_WriteDir(dir);
		gi_WriteByte(splash_color_t::SPARKS);
		gi_multicast(tr.endpos, multicast_t::PVS, false);
	}
}

/*QUAKED monster_flyer (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_flyer(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	flyer::sounds::sight.precache();
	flyer::sounds::idle.precache();
	flyer::sounds::pain1.precache();
	flyer::sounds::pain2.precache();
	flyer::sounds::slash.precache();
	flyer::sounds::sproing.precache();
	flyer::sounds::die.precache();

	gi_soundindex("flyer/flyatck3.wav");

	self.e.s.modelindex = gi_modelindex("models/monsters/flyer/tris.md2");
	
	gi_modelindex("models/monsters/flyer/gibs/base.md2");
	gi_modelindex("models/monsters/flyer/gibs/wing.md2");
	gi_modelindex("models/monsters/flyer/gibs/gun.md2");
	gi_modelindex("models/monsters/flyer/gibs/head.md2");

	self.e.mins = { -16, -16, -24 };
	// PMM - shortened to 16 from 32
	self.e.maxs = { 16, 16, 16 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.viewheight = 12;

	self.monsterinfo.engine_sound = gi_soundindex("flyer/flyidle1.wav");

	self.health = int(50 * st.health_multiplier);
	self.mass = 50;

	@self.pain = flyer_pain;
	@self.die = flyer_die;

	@self.monsterinfo.stand = flyer_stand;
	@self.monsterinfo.walk = flyer_walk;
	@self.monsterinfo.run = flyer_run;
	@self.monsterinfo.attack = flyer_attack;
	@self.monsterinfo.melee = flyer_melee;
	@self.monsterinfo.sight = flyer_sight;
	@self.monsterinfo.idle = flyer_idle;
	@self.monsterinfo.blocked = flyer_blocked;
	@self.monsterinfo.setskin = flyer_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, flyer_move_stand);
	self.monsterinfo.scale = flyer::SCALE;

	if ((self.e.s.effects & effects_t::ROCKET) != 0)
	{
		// PMM - normal flyer has mass of 50
		self.mass = 100;
		self.yaw_speed = 5;
		@self.touch = kamikaze_touch;
	}
	else
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
		self.monsterinfo.fly_buzzard = true;
		flyer_set_fly_parameters(self, false);
		@self.touch = flyer_touch;
	}

	flymonster_start(self);
}

// PMM - suicide fliers
void SP_monster_kamikaze(ASEntity &self)
{
	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.e.s.effects = effects_t(self.e.s.effects | effects_t::ROCKET);

	SP_monster_flyer(self);
}
