// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

TANK

==============================================================================
*/

namespace tank
{
    enum frames
    {
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
        walk01,
        walk02,
        walk03,
        walk04,
        walk05,
        walk06,
        walk07,
        walk08,
        walk09,
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
        walk21,
        walk22,
        walk23,
        walk24,
        walk25,
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
        attak122,
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
        attak218,
        attak219,
        attak220,
        attak221,
        attak222,
        attak223,
        attak224,
        attak225,
        attak226,
        attak227,
        attak228,
        attak229,
        attak230,
        attak231,
        attak232,
        attak233,
        attak234,
        attak235,
        attak236,
        attak237,
        attak238,
        attak301,
        attak302,
        attak303,
        attak304,
        attak305,
        attak306,
        attak307,
        attak308,
        attak309,
        attak310,
        attak311,
        attak312,
        attak313,
        attak314,
        attak315,
        attak316,
        attak317,
        attak318,
        attak319,
        attak320,
        attak321,
        attak322,
        attak323,
        attak324,
        attak325,
        attak326,
        attak327,
        attak328,
        attak329,
        attak330,
        attak331,
        attak332,
        attak333,
        attak334,
        attak335,
        attak336,
        attak337,
        attak338,
        attak339,
        attak340,
        attak341,
        attak342,
        attak343,
        attak344,
        attak345,
        attak346,
        attak347,
        attak348,
        attak349,
        attak350,
        attak351,
        attak352,
        attak353,
        attak401,
        attak402,
        attak403,
        attak404,
        attak405,
        attak406,
        attak407,
        attak408,
        attak409,
        attak410,
        attak411,
        attak412,
        attak413,
        attak414,
        attak415,
        attak416,
        attak417,
        attak418,
        attak419,
        attak420,
        attak421,
        attak422,
        attak423,
        attak424,
        attak425,
        attak426,
        attak427,
        attak428,
        attak429,
        pain101,
        pain102,
        pain103,
        pain104,
        pain201,
        pain202,
        pain203,
        pain204,
        pain205,
        pain301,
        pain302,
        pain303,
        pain304,
        pain305,
        pain306,
        pain307,
        pain308,
        pain309,
        pain310,
        pain311,
        pain312,
        pain313,
        pain314,
        pain315,
        pain316,
        death101,
        death102,
        death103,
        death104,
        death105,
        death106,
        death107,
        death108,
        death109,
        death110,
        death111,
        death112,
        death113,
        death114,
        death115,
        death116,
        death117,
        death118,
        death119,
        death120,
        death121,
        death122,
        death123,
        death124,
        death125,
        death126,
        death127,
        death128,
        death129,
        death130,
        death131,
        death132,
        recln101,
        recln102,
        recln103,
        recln104,
        recln105,
        recln106,
        recln107,
        recln108,
        recln109,
        recln110,
        recln111,
        recln112,
        recln113,
        recln114,
        recln115,
        recln116,
        recln117,
        recln118,
        recln119,
        recln120,
        recln121,
        recln122,
        recln123,
        recln124,
        recln125,
        recln126,
        recln127,
        recln128,
        recln129,
        recln130,
        recln131,
        recln132,
        recln133,
        recln134,
        recln135,
        recln136,
        recln137,
        recln138,
        recln139,
        recln140
    };

    const float SCALE = 1.000000f;
}

namespace tank::sounds
{
    cached_soundindex thud("tank/tnkdeth2.wav");
    cached_soundindex pain("tank/tnkpain2.wav");
    cached_soundindex pain2("tank/pain.wav");
    cached_soundindex idle("tank/tnkidle1.wav");
    cached_soundindex die("tank/death.wav");
    cached_soundindex step("tank/step.wav");
    cached_soundindex windup("tank/tnkatck4.wav");
    cached_soundindex strike("tank/tnkatck5.wav");
    cached_soundindex sight("tank/sight1.wav");
}

namespace spawnflags::tank
{
    const spawnflags_t COMMANDER_GUARDIAN = spawnflag_dec(8);
    const spawnflags_t COMMANDER_HEAT_SEEKING = spawnflag_dec(16);
}

//
// misc
//

void tank_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, tank::sounds::sight, 1, ATTN_NORM, 0);
}

void tank_footstep(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, tank::sounds::step, 1, ATTN_NORM, 0);
}

void tank_thud(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, tank::sounds::thud, 1, ATTN_NORM, 0);
}

void tank_windup(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, tank::sounds::windup, 1, ATTN_NORM, 0);
}

void tank_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, tank::sounds::idle, 1, ATTN_IDLE, 0);
}

//
// stand
//

const array<mframe_t> tank_frames_stand = {
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
const mmove_t tank_move_stand = mmove_t(tank::frames::stand01, tank::frames::stand30, tank_frames_stand, null);

void tank_stand(ASEntity &self)
{
	M_SetAnimation(self, tank_move_stand);
}

//
// walk
//

/*
const array<mframe_t> tank_frames_start_walk = {
	mframe_t(ai_walk),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 11, tank_footstep)
};
const mmove_t tank_move_start_walk = mmove_t(tank::frames::walk01, tank::frames::walk04, tank_frames_start_walk, tank_walk);
*/

const array<mframe_t> tank_frames_walk = {
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4, tank_footstep),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 6, tank_footstep)
};
const mmove_t tank_move_walk = mmove_t(tank::frames::walk05, tank::frames::walk20, tank_frames_walk, null);

/*
const array<mframe_t> tank_frames_stop_walk = {
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 4, tank_footstep)
};
const mmove_t tank_move_stop_walk = mmove_t(tank::frames::walk21, tank::frames::walk25, tank_frames_stop_walk, tank_stand);
*/

void tank_walk(ASEntity &self)
{
	M_SetAnimation(self, tank_move_walk);
}

//
// run
//

const array<mframe_t> tank_frames_start_run = {
	mframe_t(ai_run),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 11, tank_footstep)
};
const mmove_t tank_move_start_run = mmove_t(tank::frames::walk01, tank::frames::walk04, tank_frames_start_run, tank_run);

const array<mframe_t> tank_frames_run = {
	mframe_t(ai_run, 4),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 2),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 4),
	mframe_t(ai_run, 4, tank_footstep),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 4),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 7),
	mframe_t(ai_run, 7),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 6, tank_footstep)
};
const mmove_t tank_move_run = mmove_t(tank::frames::walk05, tank::frames::walk20, tank_frames_run, null);

/*
const array<mframe_t> tank_frames_stop_run = {
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 2),
	mframe_t(ai_run, 2),
	mframe_t(ai_run, 4, tank_footstep)
};
const mmove_t tank_move_stop_run = mmove_t(tank::frames::walk21, tank::frames::walk25, tank_frames_stop_run, tank_walk);
*/

void tank_run(ASEntity &self)
{
	if (self.enemy !is null && self.enemy.client !is null)
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BRUTAL);
	else
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BRUTAL);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		M_SetAnimation(self, tank_move_stand);
		return;
	}

	if (self.monsterinfo.active_move is tank_move_walk ||
		self.monsterinfo.active_move is tank_move_start_run)
	{
		M_SetAnimation(self, tank_move_run);
	}
	else
	{
		M_SetAnimation(self, tank_move_start_run);
	}
}

//
// pain
//

const array<mframe_t> tank_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t tank_move_pain1 = mmove_t(tank::frames::pain101, tank::frames::pain104, tank_frames_pain1, tank_run);

const array<mframe_t> tank_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t tank_move_pain2 = mmove_t(tank::frames::pain201, tank::frames::pain205, tank_frames_pain2, tank_run);

const array<mframe_t> tank_frames_pain3 = {
	mframe_t(ai_move, -7),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 3),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, tank_footstep)
};
const mmove_t tank_move_pain3 = mmove_t(tank::frames::pain301, tank::frames::pain316, tank_frames_pain3, tank_run);

void tank_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (mod.id != mod_id_t::CHAINFIST && damage <= 10)
		return;

	if (level.time < self.pain_debounce_time)
		return;

	if (mod.id != mod_id_t::CHAINFIST)
	{
		if (damage <= 30)
			if (frandom() > 0.2f)
				return;

		// don't go into pain while attacking
		if ((self.e.s.frame >= tank::frames::attak301) && (self.e.s.frame <= tank::frames::attak330))
			return;
		if ((self.e.s.frame >= tank::frames::attak101) && (self.e.s.frame <= tank::frames::attak116))
			return;
	}

	self.pain_debounce_time = level.time + time_sec(3);

	if (self.count != 0)
		gi_sound(self.e, soundchan_t::VOICE, tank::sounds::pain2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, tank::sounds::pain, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	// PMM - blindfire cleanup
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
	// pmm

	if (damage <= 30)
		M_SetAnimation(self, tank_move_pain1);
	else if (damage <= 60)
		M_SetAnimation(self, tank_move_pain2);
	else
		M_SetAnimation(self, tank_move_pain3);
}

void tank_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

//
// attacks
//

void TankBlaster(ASEntity &self)
{
	vec3_t					 forward, right;
	vec3_t					 start;
	vec3_t					 dir;
	monster_muzzle_t         flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	bool   blindfire = (self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0;

	if (self.e.s.frame == tank::frames::attak110)
		flash_number = monster_muzzle_t::TANK_BLASTER_1;
	else if (self.e.s.frame == tank::frames::attak113)
		flash_number = monster_muzzle_t::TANK_BLASTER_2;
	else // (self.e.s.frame == tank::frames::attak116)
		flash_number = monster_muzzle_t::TANK_BLASTER_3;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	// pmm - blindfire support
	vec3_t target;

	// PMM
	if (blindfire)
	{
		target = self.monsterinfo.blind_fire_target;

		if (!M_AdjustBlindfireTarget(self, start, target, right, dir))
			return;
	}
	else
    {
		PredictAim(self, self.enemy, start, 0, false, 0.f, dir, target);
    }
	// pmm

	monster_fire_blaster(self, start, dir, 30, 800, flash_number, effects_t::BLASTER);
}

void TankStrike(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, tank::sounds::strike, 1, ATTN_NORM, 0);
}

void TankRocket(ASEntity &self)
{
	vec3_t					 forward, right;
	vec3_t					 start;
	vec3_t					 dir;
	vec3_t					 vec;
	monster_muzzle_t         flash_number;
	int						 rocketSpeed; // PGM
	// pmm - blindfire support
	vec3_t                   target;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	bool   blindfire = (self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0;

	if (self.e.s.frame == tank::frames::attak324)
		flash_number = monster_muzzle_t::TANK_ROCKET_1;
	else if (self.e.s.frame == tank::frames::attak327)
		flash_number = monster_muzzle_t::TANK_ROCKET_2;
	else // (self.e.s.frame == tank::frames::attak330)
		flash_number = monster_muzzle_t::TANK_ROCKET_3;

	AngleVectors(self.e.s.angles, forward, right);

	// [Paril-KEX] scale
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	if (self.speed != 0)
		rocketSpeed = int(self.speed);
	else if (self.spawnflags.has(spawnflags::tank::COMMANDER_HEAT_SEEKING))
		rocketSpeed = 500;
	else
		rocketSpeed = 650;

	// PMM
	if (blindfire)
		target = self.monsterinfo.blind_fire_target;
	else
		target = self.enemy.e.s.origin;
	// pmm

	// PGM
	//  PMM - blindfire shooting
	if (blindfire)
	{
		vec = target;
		dir = vec - start;
	}
	// pmm
	// don't shoot at feet if they're above me.
	else if (frandom() < 0.66f || (start[2] < self.enemy.e.absmin[2]))
	{
		vec = self.enemy.e.s.origin;
		vec[2] += self.enemy.viewheight;
		dir = vec - start;
	}
	else
	{
		vec = self.enemy.e.s.origin;
		vec[2] = self.enemy.e.absmin[2] + 1;
		dir = vec - start;
	}
	// PGM

	//======
	// PMM - lead target  (not when blindfiring)
	// 20, 35, 50, 65 chance of leading
	if ((!blindfire) && ((frandom() < (0.2f + ((3 - skill.integer) * 0.15f)))))
		PredictAim(self, self.enemy, start, rocketSpeed, false, 0, dir, vec);
	// PMM - lead target
	//======

	dir.normalize();

	// pmm blindfire doesn't check target (done in checkattack)
	// paranoia, make sure we're not shooting a target right next to us
	if (blindfire)
	{
		// blindfire has different fail criteria for the trace
		if (M_AdjustBlindfireTarget(self, start, vec, right, dir))
		{
			if (self.spawnflags.has(spawnflags::tank::COMMANDER_HEAT_SEEKING))
				monster_fire_heat(self, start, dir, 50, rocketSpeed, flash_number, self.accel);
			else
				monster_fire_rocket(self, start, dir, 50, rocketSpeed, flash_number);
		}
	}
	else
	{
		trace_t trace = gi_traceline(start, vec, self.e, contents_t::PROJECTILE);

		if (trace.fraction > 0.5f || trace.ent.solid != solid_t::BSP)
		{
			if (self.spawnflags.has(spawnflags::tank::COMMANDER_HEAT_SEEKING))
				monster_fire_heat(self, start, dir, 50, rocketSpeed, flash_number, self.accel);
			else
				monster_fire_rocket(self, start, dir, 50, rocketSpeed, flash_number);
		}
	}
}

void TankMachineGun(ASEntity &self)
{
	vec3_t					 dir;
	vec3_t					 vec;
	vec3_t					 start;
	vec3_t					 forward, right;
	monster_muzzle_t         flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	flash_number = monster_muzzle_t(monster_muzzle_t::TANK_MACHINEGUN_1 + (self.e.s.frame - tank::frames::attak406));

	AngleVectors(self.e.s.angles, forward, right);

	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	if (self.enemy !is null)
	{
		vec = self.enemy.e.s.origin;
		vec[2] += self.enemy.viewheight;
		vec -= start;
		vec = vectoangles(vec);
		dir[0] = vec[0];
	}
	else
	{
		dir[0] = 0;
	}
	if (self.e.s.frame <= tank::frames::attak415)
		dir[1] = self.e.s.angles[1] - 8 * (self.e.s.frame - tank::frames::attak411);
	else
		dir[1] = self.e.s.angles[1] + 8 * (self.e.s.frame - tank::frames::attak419);
	dir[2] = 0;

	AngleVectors(dir, forward);

	monster_fire_bullet(self, start, forward, 20, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, flash_number);
}

void tank_blind_check(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		vec3_t aim = self.monsterinfo.blind_fire_target - self.e.s.origin;
		self.ideal_yaw = vectoyaw(aim);
	}
}

const array<mframe_t> tank_frames_attack_blast = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -1, tank_blind_check),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankBlaster), // 10
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankBlaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankBlaster) // 16
};
const mmove_t tank_move_attack_blast = mmove_t(tank::frames::attak101, tank::frames::attak116, tank_frames_attack_blast, tank_reattack_blaster);

const array<mframe_t> tank_frames_reattack_blast = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankBlaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankBlaster) // 16
};
const mmove_t tank_move_reattack_blast = mmove_t(tank::frames::attak111, tank::frames::attak116, tank_frames_reattack_blast, tank_reattack_blaster);

const array<mframe_t> tank_frames_attack_post_blast = {
	mframe_t(ai_move), // 17
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, -2, tank_footstep) // 22
};
const mmove_t tank_move_attack_post_blast = mmove_t(tank::frames::attak117, tank::frames::attak122, tank_frames_attack_post_blast, tank_run);

void tank_reattack_blaster(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		M_SetAnimation(self, tank_move_attack_post_blast);
		return;
	}
	
	if (visible(self, self.enemy))
		if (self.enemy.health > 0)
			if (frandom() <= 0.6f)
			{
				M_SetAnimation(self, tank_move_reattack_blast);
				return;
			}
	M_SetAnimation(self, tank_move_attack_post_blast);
}

void tank_poststrike(ASEntity &self)
{
	@self.enemy = null;
	// [Paril-KEX]
	self.monsterinfo.pausetime = HOLD_FOREVER;
	self.monsterinfo.stand(self);
}

const array<mframe_t> tank_frames_attack_strike = {
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 7),
	mframe_t(ai_move, 9, tank_footstep),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 2, tank_footstep),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 0, tank_windup),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, TankStrike),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -10),
	mframe_t(ai_move, -10),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -2, tank_footstep)
};
const mmove_t tank_move_attack_strike = mmove_t(tank::frames::attak201, tank::frames::attak238, tank_frames_attack_strike, tank_poststrike);

const array<mframe_t> tank_frames_attack_pre_rocket = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge), // 10

	mframe_t(ai_charge),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 7),
	mframe_t(ai_charge, 7),
	mframe_t(ai_charge, 7, tank_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge), // 20

	mframe_t(ai_charge, -3)
};
const mmove_t tank_move_attack_pre_rocket = mmove_t(tank::frames::attak301, tank::frames::attak321, tank_frames_attack_pre_rocket, tank_doattack_rocket);

const array<mframe_t> tank_frames_attack_fire_rocket = {
	mframe_t(ai_charge, -3, tank_blind_check), // Loop Start	22
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankRocket), // 24
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, TankRocket),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -1, TankRocket) // 30	Loop End
};
const mmove_t tank_move_attack_fire_rocket = mmove_t(tank::frames::attak322, tank::frames::attak330, tank_frames_attack_fire_rocket, tank_refire_rocket);

const array<mframe_t> tank_frames_attack_post_rocket = {
	mframe_t(ai_charge), // 31
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge),
	mframe_t(ai_charge), // 40

	mframe_t(ai_charge),
	mframe_t(ai_charge, -9),
	mframe_t(ai_charge, -8),
	mframe_t(ai_charge, -7),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -1, tank_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge), // 50

	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t tank_move_attack_post_rocket = mmove_t(tank::frames::attak331, tank::frames::attak353, tank_frames_attack_post_rocket, tank_run);

const array<mframe_t> tank_frames_attack_chain = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(null, 0, TankMachineGun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t tank_move_attack_chain = mmove_t(tank::frames::attak401, tank::frames::attak429, tank_frames_attack_chain, tank_run);

void tank_refire_rocket(ASEntity &self)
{
	// PMM - blindfire cleanup
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		M_SetAnimation(self, tank_move_attack_post_rocket);
		return;
	}
	// pmm

	if (self.enemy.health > 0)
		if (visible(self, self.enemy))
			if (frandom() <= 0.4f)
			{
				M_SetAnimation(self, tank_move_attack_fire_rocket);
				return;
			}
	M_SetAnimation(self, tank_move_attack_post_rocket);
}

void tank_doattack_rocket(ASEntity &self)
{
	M_SetAnimation(self, tank_move_attack_fire_rocket);
}

void tank_attack(ASEntity &self)
{
	vec3_t vec;
	float  range;
	float  r;
	// PMM
	float chance;

	// PMM
	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	if (self.enemy.health <= 0)
	{
		M_SetAnimation(self, tank_move_attack_strike);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BRUTAL);
		return;
	}

	// PMM
	if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
	{
		// setup shot probabilities
		if (self.monsterinfo.blind_fire_delay < time_sec(1))
			chance = 1.0f;
		else if (self.monsterinfo.blind_fire_delay < time_sec(7.5))
			chance = 0.4f;
		else
			chance = 0.1f;

		r = frandom();

		self.monsterinfo.blind_fire_delay += time_sec(5.2) + random_time(time_sec(3));

		// don't shoot at the origin
		if (!self.monsterinfo.blind_fire_target)
			return;

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		bool rocket_visible = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_ROCKET_1]);
		bool blaster_visible = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_BLASTER_1]);

		if (!rocket_visible && !blaster_visible)
			return;

		bool use_rocket = (rocket_visible && blaster_visible) ? brandom() : rocket_visible;

		// turn on manual steering to signal both manual steering and blindfire
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);

		if (use_rocket)
			M_SetAnimation(self, tank_move_attack_fire_rocket);
		else
		{
			M_SetAnimation(self, tank_move_attack_blast);
			self.monsterinfo.nextframe = tank::frames::attak108;
		}

		self.monsterinfo.attack_finished = level.time + random_time(time_sec(3), time_sec(5));
		self.pain_debounce_time = level.time + time_sec(5); // no pain for a while
		return;
	}
	// pmm

	vec = self.enemy.e.s.origin - self.e.s.origin;
	range = vec.length();

	r = frandom();

	if (range <= 125)
	{
		bool can_machinegun = (self.enemy.classname != "tesla_mine") && M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_MACHINEGUN_5]);

		if (can_machinegun && r < 0.5f)
			M_SetAnimation(self, tank_move_attack_chain);
		else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_BLASTER_1]))
			M_SetAnimation(self, tank_move_attack_blast);
	}
	else if (range <= 250)
	{
		bool can_machinegun = (self.enemy.classname != "tesla_mine") && M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_MACHINEGUN_5]);

		if (can_machinegun && r < 0.25f)
			M_SetAnimation(self, tank_move_attack_chain);
		else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_BLASTER_1]))
			M_SetAnimation(self, tank_move_attack_blast);
	}
	else
	{
		bool can_machinegun = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_MACHINEGUN_5]);
		bool can_rocket = M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_ROCKET_1]);

		if (can_machinegun && r < 0.33f)
			M_SetAnimation(self, tank_move_attack_chain);
		else if (can_rocket && r < 0.66f)
		{
			M_SetAnimation(self, tank_move_attack_pre_rocket);
			self.pain_debounce_time = level.time + time_sec(5); // no pain for a while
		}
		else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::TANK_BLASTER_1]))
			M_SetAnimation(self, tank_move_attack_blast);
	}
}

//
// death
//

void tank_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -16 };
	self.e.maxs = { 16, 16, -0 };
	monster_dead(self);
}

void tank_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> tank_frames_death1 = {
	mframe_t(ai_move, -7),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -3),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -7, tank_shrink),
	mframe_t(ai_move, -15, tank_thud),
	mframe_t(ai_move, -5),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t tank_move_death = mmove_t(tank::frames::death101, tank::frames::death132, tank_frames_death1, tank_dead);

void tank_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t("models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(3, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
			gib_def_t("models/objects/gibs/gear/tris.md2", gib_type_t::METALLIC),
			gib_def_t(2, "models/monsters/tank/gibs/foot.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC)),
			gib_def_t(2, "models/monsters/tank/gibs/thigh.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC)),
			gib_def_t("models/monsters/tank/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/tank/gibs/head.md2", gib_type_t(gib_type_t::HEAD | gib_type_t::SKINNED))
		});

		if (self.style == 0)
			ThrowGib(self, "models/monsters/tank/gibs/barm.md2", damage, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT), self.e.s.scale);

		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// [Paril-KEX] dropped arm
	if (self.style == 0)
	{
		self.style = 1;

		vec3_t fwd, rgt, up;
        AngleVectors(self.e.s.angles, fwd, rgt, up);

		ASEntity @arm_gib = ThrowGib(self, "models/monsters/tank/gibs/barm.md2", damage, gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT), self.e.s.scale);
		arm_gib.e.s.origin = self.e.s.origin + (rgt * -16.f) + (up * 23.f);
		arm_gib.e.s.old_origin = arm_gib.e.s.origin;
		arm_gib.avelocity = { crandom() * 15.f, crandom() * 15.f, 180.f };
		arm_gib.velocity = (up * 100.f) + (rgt * -120.f);
		arm_gib.e.s.angles = self.e.s.angles;
		arm_gib.e.s.angles[2] = -90.f;
		arm_gib.e.s.skinnum /= 2;
		gi_linkentity(arm_gib.e);
	}

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, tank::sounds::die, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	M_SetAnimation(self, tank_move_death);
}

//===========
// PGM
bool tank_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

//
// monster_tank
//

/*QUAKED monster_tank (1 .5 0) (-32 -32 -16) (32 32 72) Ambush Trigger_Spawn Sight
model="models/monsters/tank/tris.md2"
*/
/*QUAKED monster_tank_commander (1 .5 0) (-32 -32 -16) (32 32 72) Ambush Trigger_Spawn Sight Guardian HeatSeeking
 */
void SP_monster_tank(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}
	
	self.e.s.modelindex = gi_modelindex("models/monsters/tank/tris.md2");
	self.e.mins = { -32, -32, -16 };
	self.e.maxs = { 32, 32, 64 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	
	gi_modelindex("models/monsters/tank/gibs/barm.md2");
	gi_modelindex("models/monsters/tank/gibs/head.md2");
	gi_modelindex("models/monsters/tank/gibs/chest.md2");
	gi_modelindex("models/monsters/tank/gibs/foot.md2");
	gi_modelindex("models/monsters/tank/gibs/thigh.md2");

	tank::sounds::thud.precache();
	tank::sounds::idle.precache();
	tank::sounds::die.precache();
	tank::sounds::step.precache();
	tank::sounds::windup.precache();
	tank::sounds::strike.precache();
	tank::sounds::sight.precache();

	gi_soundindex("tank/tnkatck1.wav");
	gi_soundindex("tank/tnkatk2a.wav");
	gi_soundindex("tank/tnkatk2b.wav");
	gi_soundindex("tank/tnkatk2c.wav");
	gi_soundindex("tank/tnkatk2d.wav");
	gi_soundindex("tank/tnkatk2e.wav");
	gi_soundindex("tank/tnkatck3.wav");

	if (self.classname == "monster_tank_commander")
	{
		self.health = int(1000 * st.health_multiplier);
		self.gib_health = -225;
		self.count = 1;
		tank::sounds::pain2.precache();
	}
	else
	{
		self.health = int(750 * st.health_multiplier);
		self.gib_health = -200;
		tank::sounds::pain.precache();
	}

	self.monsterinfo.scale = tank::SCALE;

	// [Paril-KEX] N64 tank commander is a chonky boy
	if (self.spawnflags.has(spawnflags::tank::COMMANDER_GUARDIAN))
	{
		if (self.e.s.scale == 0)
			self.e.s.scale = 1.5f;
		self.health = int(1500 * st.health_multiplier);
	}

	// heat seekingness
	if (self.accel == 0)
		self.accel = 0.075f;

	self.mass = 500;

	@self.pain = tank_pain;
	@self.die = tank_die;
	@self.monsterinfo.stand = tank_stand;
	@self.monsterinfo.walk = tank_walk;
	@self.monsterinfo.run = tank_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = tank_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = tank_sight;
	@self.monsterinfo.idle = tank_idle;
	@self.monsterinfo.blocked = tank_blocked; // PGM
	@self.monsterinfo.setskin = tank_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, tank_move_stand);

	walkmonster_start(self);

	// PMM
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	self.monsterinfo.blindfire = true;
	// pmm
	if (self.classname == "monster_tank_commander")
		self.e.s.skinnum = 2;
}

void Think_TankStand(ASEntity &ent)
{
	if (ent.e.s.frame == tank::frames::stand30)
		ent.e.s.frame = tank::frames::stand01;
	else
		ent.e.s.frame++;
	ent.nextthink = level.time + time_hz(10);
}

/*QUAKED monster_tank_stand (1 .5 0) (-32 -32 0) (32 32 90)

Just stands and cycles in one place until targeted, then teleports away.
N64 edition!
*/
void SP_monster_tank_stand(ASEntity &self)
{
	if( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.model = "models/monsters/tank/tris.md2";
	self.e.s.modelindex = gi_modelindex(self.model);
	self.e.s.frame = tank::frames::stand01;
	self.e.s.skinnum = 2;

	gi_soundindex("misc/bigtele.wav");
	
	self.e.mins = { -32, -32, -16 };
	self.e.maxs = { 32, 32, 64 };

	if (self.e.s.scale == 0)
		self.e.s.scale = 1.5f;

	self.e.mins *= self.e.s.scale;
	self.e.maxs *= self.e.s.scale;

	@self.use = Use_Boss3;
	@self.think = Think_TankStand;
	self.nextthink = level.time + time_hz(10);
	gi_linkentity(self.e);
}