// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

chick

==============================================================================
*/

namespace chick
{
    enum frames
    {
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
        attak123,
        attak124,
        attak125,
        attak126,
        attak127,
        attak128,
        attak129,
        attak130,
        attak131,
        attak132,
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
        death201,
        death202,
        death203,
        death204,
        death205,
        death206,
        death207,
        death208,
        death209,
        death210,
        death211,
        death212,
        death213,
        death214,
        death215,
        death216,
        death217,
        death218,
        death219,
        death220,
        death221,
        death222,
        death223,
        duck01,
        duck02,
        duck03,
        duck04,
        duck05,
        duck06,
        duck07,
        pain101,
        pain102,
        pain103,
        pain104,
        pain105,
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
        pain317,
        pain318,
        pain319,
        pain320,
        pain321,
        stand101,
        stand102,
        stand103,
        stand104,
        stand105,
        stand106,
        stand107,
        stand108,
        stand109,
        stand110,
        stand111,
        stand112,
        stand113,
        stand114,
        stand115,
        stand116,
        stand117,
        stand118,
        stand119,
        stand120,
        stand121,
        stand122,
        stand123,
        stand124,
        stand125,
        stand126,
        stand127,
        stand128,
        stand129,
        stand130,
        stand201,
        stand202,
        stand203,
        stand204,
        stand205,
        stand206,
        stand207,
        stand208,
        stand209,
        stand210,
        stand211,
        stand212,
        stand213,
        stand214,
        stand215,
        stand216,
        stand217,
        stand218,
        stand219,
        stand220,
        stand221,
        stand222,
        stand223,
        stand224,
        stand225,
        stand226,
        stand227,
        stand228,
        stand229,
        stand230,
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
        walk26,
        walk27,
        recln201,
        recln202,
        recln203,
        recln204,
        recln205,
        recln206,
        recln207,
        recln208,
        recln209,
        recln210,
        recln211,
        recln212,
        recln213,
        recln214,
        recln215,
        recln216,
        recln217,
        recln218,
        recln219,
        recln220,
        recln221,
        recln222,
        recln223,
        recln224,
        recln225,
        recln226,
        recln227,
        recln228,
        recln229,
        recln230,
        recln231,
        recln232,
        recln233,
        recln234,
        recln235,
        recln236,
        recln237,
        recln238,
        recln239,
        recln240,
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

namespace chick::sounds
{
    cached_soundindex missile_prelaunch("chick/chkatck1.wav");
    cached_soundindex missile_launch("chick/chkatck2.wav");
    cached_soundindex melee_swing("chick/chkatck3.wav");
    cached_soundindex melee_hit("chick/chkatck4.wav");
    cached_soundindex missile_reload("chick/chkatck5.wav");
    cached_soundindex death1("chick/chkdeth1.wav");
    cached_soundindex death2("chick/chkdeth2.wav");
    cached_soundindex fall_down("chick/chkfall1.wav");
    cached_soundindex idle1("chick/chkidle1.wav");
    cached_soundindex idle2("chick/chkidle2.wav");
    cached_soundindex pain1("chick/chkpain1.wav");
    cached_soundindex pain2("chick/chkpain2.wav");
    cached_soundindex pain3("chick/chkpain3.wav");
    cached_soundindex sight("chick/chksght1.wav");
    cached_soundindex search("chick/chksrch1.wav");
}

void ChickMoan(ASEntity &self)
{
	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::idle1, 1, ATTN_IDLE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::idle2, 1, ATTN_IDLE, 0);
}

const array<mframe_t> chick_frames_fidget = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, ChickMoan),
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
const mmove_t chick_move_fidget = mmove_t(chick::frames::stand201, chick::frames::stand230, chick_frames_fidget, chick_stand);

void chick_fidget(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		return;
	else if (self.enemy !is null)
		return;
	if (frandom() <= 0.3f)
		M_SetAnimation(self, chick_move_fidget);
}

const array<mframe_t> chick_frames_stand = {
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
	mframe_t(ai_stand, 0, chick_fidget),
};
const mmove_t chick_move_stand = mmove_t(chick::frames::stand101, chick::frames::stand130, chick_frames_stand, null);

void chick_stand(ASEntity &self)
{
	M_SetAnimation(self, chick_move_stand);
}

const array<mframe_t> chick_frames_start_run = {
	mframe_t(ai_run, 1),
	mframe_t(ai_run),
	mframe_t(ai_run, 0, monster_footstep),
	mframe_t(ai_run, -1),
	mframe_t(ai_run, -1, monster_footstep),
	mframe_t(ai_run),
	mframe_t(ai_run, 1),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 3)
};
const mmove_t chick_move_start_run = mmove_t(chick::frames::walk01, chick::frames::walk10, chick_frames_start_run, chick_run);

const array<mframe_t> chick_frames_run = {
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 8, monster_footstep),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 5, monster_done_dodge), // make sure to clear dodge bit
	mframe_t(ai_run, 7),
	mframe_t(ai_run, 4),
	mframe_t(ai_run, 11, monster_footstep),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 7)
};

const mmove_t chick_move_run = mmove_t(chick::frames::walk11, chick::frames::walk20, chick_frames_run, null);

const array<mframe_t> chick_frames_walk = {
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 8, monster_footstep),
	mframe_t(ai_walk, 13),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 11, monster_footstep),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 7)
};

const mmove_t chick_move_walk = mmove_t(chick::frames::walk11, chick::frames::walk20, chick_frames_walk, null);

void chick_walk(ASEntity &self)
{
	M_SetAnimation(self, chick_move_walk);
}

void chick_run(ASEntity &self)
{
	monster_done_dodge(self);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		M_SetAnimation(self, chick_move_stand);
		return;
	}

	if (self.monsterinfo.active_move is chick_move_walk ||
		self.monsterinfo.active_move is chick_move_start_run)
	{
		M_SetAnimation(self, chick_move_run);
	}
	else
	{
		M_SetAnimation(self, chick_move_start_run);
	}
}

const array<mframe_t> chick_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t chick_move_pain1 = mmove_t(chick::frames::pain101, chick::frames::pain105, chick_frames_pain1, chick_run);

const array<mframe_t> chick_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t chick_move_pain2 = mmove_t(chick::frames::pain201, chick::frames::pain205, chick_frames_pain2, chick_run);

const array<mframe_t> chick_frames_pain3 = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, 3, monster_footstep),
	mframe_t(ai_move, 11),
	mframe_t(ai_move, 3, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 4),
	mframe_t(ai_move, 1),
	mframe_t(ai_move),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, 7),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, 2, monster_footstep)
};
const mmove_t chick_move_pain3 = mmove_t(chick::frames::pain301, chick::frames::pain321, chick_frames_pain3, chick_run);

void chick_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	float r;

	monster_done_dodge(self);

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	r = frandom();
	if (r < 0.33f)
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::pain1, 1, ATTN_NORM, 0);
	else if (r < 0.66f)
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::pain2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::pain3, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	// PMM - clear this from blindfire
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	if (damage <= 10)
		M_SetAnimation(self, chick_move_pain1);
	else if (damage <= 25)
		M_SetAnimation(self, chick_move_pain2);
	else
		M_SetAnimation(self, chick_move_pain3);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);
}

void chick_setpain(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

void chick_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, 0 };
	self.e.maxs = { 16, 16, 8 };
	monster_dead(self);
}

void chick_shrink(ASEntity &self)
{
	self.e.maxs[2] = 12;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> chick_frames_death2 = {
	mframe_t(ai_move, -6),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -5, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 10),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 3, monster_footstep),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 1, monster_footstep),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, 4),
	mframe_t(ai_move, 15, chick_shrink),
	mframe_t(ai_move, 14, monster_footstep),
	mframe_t(ai_move, 1)
};
const mmove_t chick_move_death2 = mmove_t(chick::frames::death201, chick::frames::death223, chick_frames_death2, chick_dead);

const array<mframe_t> chick_frames_death1 = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, -7),
	mframe_t(ai_move, 4, monster_footstep),
	mframe_t(ai_move, 11, chick_shrink),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move)
};
const mmove_t chick_move_death1 = mmove_t(chick::frames::death101, chick::frames::death112, chick_frames_death1, chick_dead);

void chick_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(3, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/monsters/bitch/gibs/arm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/bitch/gibs/foot.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/bitch/gibs/tube.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/bitch/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/bitch/gibs/head.md2", gib_type_t(gib_type_t::HEAD | gib_type_t::SKINNED))
		});
		self.deadflag = true;

		return;
	}

	if (self.deadflag)
		return;

	// regular death
	self.deadflag = true;
	self.takedamage = true;

	bool n = brandom();

	if (!n)
	{
		M_SetAnimation(self, chick_move_death1);
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::death1, 1, ATTN_NORM, 0);
	}
	else
	{
		M_SetAnimation(self, chick_move_death2);
		gi_sound(self.e, soundchan_t::VOICE, chick::sounds::death2, 1, ATTN_NORM, 0);
	}
}

// PMM - changes to duck code for new dodge

const array<mframe_t> chick_frames_duck = {
	mframe_t(ai_move, 0, monster_duck_down),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 4, monster_duck_hold),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -5, monster_duck_up),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 1)
};
const mmove_t chick_move_duck = mmove_t(chick::frames::duck01, chick::frames::duck07, chick_frames_duck, chick_run);

void ChickSlash(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], 10 };
	gi_sound(self.e, soundchan_t::WEAPON, chick::sounds::melee_swing, 1, ATTN_NORM, 0);
	fire_hit(self, aim, irandom(10, 16), 100);
}

void ChickRocket(ASEntity &self)
{
	vec3_t	forward, right;
	vec3_t	start;
	vec3_t	dir;
	vec3_t	vec;
	trace_t trace; // PMM - check target
	int		rocketSpeed;
	// pmm - blindfire
	vec3_t target;
	bool   blindfire = false;

	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		blindfire = true;
	else
		blindfire = false;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CHICK_ROCKET_1], forward, right);
	
	// [Paril-KEX]
	if (self.e.s.skinnum > 1)
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
	// don't shoot at feet if they're above where i'm shooting from.
	else if (frandom() < 0.33f || (start[2] < self.enemy.e.absmin[2]))
	{
		vec = target;
		vec[2] += self.enemy.viewheight;
		dir = vec - start;
	}
	else
	{
		vec = target;
		vec[2] = self.enemy.e.absmin[2] + 1;
		dir = vec - start;
	}
	// PGM

	//======
	// PMM - lead target  (not when blindfiring)
	// 20, 35, 50, 65 chance of leading
	if ((!blindfire) && (frandom() < 0.35f))
		PredictAim(self, self.enemy, start, rocketSpeed, false, 0.f, dir, vec);
	// PMM - lead target
	//======

	dir.normalize();

	// pmm blindfire doesn't check target (done in checkattack)
	// paranoia, make sure we're not shooting a target right next to us
	trace = gi_traceline(start, vec, self.e, contents_t::MASK_PROJECTILE);
	if (blindfire)
	{
		// blindfire has different fail criteria for the trace
		if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
		{
			// RAFAEL
			if (self.e.s.skinnum > 1)
				monster_fire_heat(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1, 0.075f);
			else
				// RAFAEL
				monster_fire_rocket(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1);
		}
		else
		{
			// geez, this is bad.  she's avoiding about 80% of her blindfires due to hitting things.
			// hunt around for a good shot
			// try shifting the target to the left a little (to help counter her large offset)
			vec = target;
			vec += (right * -10);
			dir = vec - start;
			dir.normalize();
			trace = gi_traceline(start, vec, self.e, contents_t::MASK_PROJECTILE);
			if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
			{
				// RAFAEL
				if (self.e.s.skinnum > 1)
					monster_fire_heat(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1, 0.075f);
				else
					// RAFAEL
					monster_fire_rocket(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1);
			}
			else
			{
				// ok, that failed.  try to the right
				vec = target;
				vec += (right * 10);
				dir = vec - start;
				dir.normalize();
				trace = gi_traceline(start, vec, self.e, contents_t::MASK_PROJECTILE);
				if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
				{
					// RAFAEL
					if (self.e.s.skinnum > 1)
						monster_fire_heat(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1, 0.075f);
					else
						// RAFAEL
						monster_fire_rocket(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1);
				}
			}
		}
	}
	else
	{
		if (trace.fraction > 0.5f || trace.ent.solid != solid_t::BSP)
		{
			// RAFAEL
			if (self.e.s.skinnum > 1)
				monster_fire_heat(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1, 0.15f);
			else
				// RAFAEL
				monster_fire_rocket(self, start, dir, 50, rocketSpeed, monster_muzzle_t::CHICK_ROCKET_1);
		}
	}
}

void Chick_PreAttack1(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, chick::sounds::missile_prelaunch, 1, ATTN_NORM, 0);

	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		vec3_t aim = self.monsterinfo.blind_fire_target - self.e.s.origin;
		self.ideal_yaw = vectoyaw(aim);
	}
}

void ChickReload(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, chick::sounds::missile_reload, 1, ATTN_NORM, 0);
}

const array<mframe_t> chick_frames_start_attack1 = {
	mframe_t(ai_charge, 0, Chick_PreAttack1),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 7, monster_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, chick_attack1)
};
const mmove_t chick_move_start_attack1 = mmove_t(chick::frames::attak101, chick::frames::attak113, chick_frames_start_attack1, null);

const array<mframe_t> chick_frames_attack1 = {
	mframe_t(ai_charge, 19, ChickRocket),
	mframe_t(ai_charge, -6, monster_footstep),
	mframe_t(ai_charge, -5),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -7, monster_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 10, ChickReload),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 5, monster_footstep),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 3, function(self) { chick_rerocket(self); monster_footstep(self); })
};
const mmove_t chick_move_attack1 = mmove_t(chick::frames::attak114, chick::frames::attak127, chick_frames_attack1, null);

const array<mframe_t> chick_frames_end_attack1 = {
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -6),
	mframe_t(ai_charge, -4),
	mframe_t(ai_charge, -2, monster_footstep)
};
const mmove_t chick_move_end_attack1 = mmove_t(chick::frames::attak128, chick::frames::attak132, chick_frames_end_attack1, chick_run);

void chick_rerocket(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		M_SetAnimation(self, chick_move_end_attack1);
		return;
	}

	if (!M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::CHICK_ROCKET_1]))
	{
		M_SetAnimation(self, chick_move_end_attack1);
		return;
	}

	if (self.enemy.health > 0)
	{
		if (range_to(self, self.enemy) > RANGE_MELEE)
			if (visible(self, self.enemy))
				if (frandom() <= 0.7f)
				{
					M_SetAnimation(self, chick_move_attack1);
					return;
				}
	}
	M_SetAnimation(self, chick_move_end_attack1);
}

void chick_attack1(ASEntity &self)
{
	M_SetAnimation(self, chick_move_attack1);
}

const array<mframe_t> chick_frames_slash = {
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 7, ChickSlash),
	mframe_t(ai_charge, -7, monster_footstep),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, -2, chick_reslash)
};
const mmove_t chick_move_slash = mmove_t(chick::frames::attak204, chick::frames::attak212, chick_frames_slash, null);

const array<mframe_t> chick_frames_end_slash = {
	mframe_t(ai_charge, -6),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -6),
	mframe_t(ai_charge, 0, monster_footstep)
};
const mmove_t chick_move_end_slash = mmove_t(chick::frames::attak213, chick::frames::attak216, chick_frames_end_slash, chick_run);

void chick_reslash(ASEntity &self)
{
	if (self.enemy.health > 0)
	{
		if (range_to(self, self.enemy) <= RANGE_MELEE)
		{
			if (frandom() <= 0.9f)
			{
				M_SetAnimation(self, chick_move_slash);
				return;
			}
			else
			{
				M_SetAnimation(self, chick_move_end_slash);
				return;
			}
		}
	}
	M_SetAnimation(self, chick_move_end_slash);
}

void chick_slash(ASEntity &self)
{
	M_SetAnimation(self, chick_move_slash);
}

const array<mframe_t> chick_frames_start_slash = {
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 8),
	mframe_t(ai_charge, 3)
};
const mmove_t chick_move_start_slash = mmove_t(chick::frames::attak201, chick::frames::attak203, chick_frames_start_slash, chick_slash);

void chick_melee(ASEntity &self)
{
	M_SetAnimation(self, chick_move_start_slash);
}

void chick_attack(ASEntity &self)
{
	if (!M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::CHICK_ROCKET_1]))
		return;

	float r, chance;

	monster_done_dodge(self);

	// PMM
	if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
	{
		// setup shot probabilities
		if (self.monsterinfo.blind_fire_delay < time_sec(1.0))
			chance = 1.0;
		else if (self.monsterinfo.blind_fire_delay < time_sec(7.5))
			chance = 0.4f;
		else
			chance = 0.1f;

		r = frandom();

		// minimum of 5.5 seconds, plus 0-1, after the shots are done
		self.monsterinfo.blind_fire_delay += random_time(time_sec(5.5), time_sec(6.5));

		// don't shoot at the origin
		if (!self.monsterinfo.blind_fire_target)
			return;

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		// turn on manual steering to signal both manual steering and blindfire
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
		M_SetAnimation(self, chick_move_start_attack1);
		self.monsterinfo.attack_finished = level.time + random_time(time_sec(2));
		return;
	}
	// pmm

	M_SetAnimation(self, chick_move_start_attack1);
}

void chick_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, chick::sounds::sight, 1, ATTN_NORM, 0);
}

//===========
// PGM
bool chick_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

bool chick_duck(ASEntity &self, gtime_t eta)
{
	if ((self.monsterinfo.active_move is chick_move_start_attack1) ||
		(self.monsterinfo.active_move is chick_move_attack1))
	{
		// if we're shooting don't dodge
		self.monsterinfo.unduck(self);
		return false;
	}

	M_SetAnimation(self, chick_move_duck);

	return true;
}

bool chick_sidestep(ASEntity &self)
{
	if ((self.monsterinfo.active_move is chick_move_start_attack1) ||
		(self.monsterinfo.active_move is chick_move_attack1) ||
		(self.monsterinfo.active_move is chick_move_pain3))
	{
		// if we're shooting, don't dodge
		return false;
	}

	if (self.monsterinfo.active_move !is chick_move_run)
		M_SetAnimation(self, chick_move_run);

	return true;
}

/*QUAKED monster_chick (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_chick(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	chick::sounds::missile_prelaunch.precache();
	chick::sounds::missile_launch.precache();
	chick::sounds::melee_swing.precache();
	chick::sounds::melee_hit.precache();
	chick::sounds::missile_reload.precache();
	chick::sounds::death1.precache();
	chick::sounds::death2.precache();
	chick::sounds::fall_down.precache();
	chick::sounds::idle1.precache();
	chick::sounds::idle2.precache();
	chick::sounds::pain1.precache();
	chick::sounds::pain2.precache();
	chick::sounds::pain3.precache();
	chick::sounds::sight.precache();
	chick::sounds::search.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/bitch/tris.md2");
	
	gi_modelindex("models/monsters/bitch/gibs/arm.md2");
	gi_modelindex("models/monsters/bitch/gibs/chest.md2");
	gi_modelindex("models/monsters/bitch/gibs/foot.md2");
	gi_modelindex("models/monsters/bitch/gibs/head.md2");
	gi_modelindex("models/monsters/bitch/gibs/tube.md2");

	self.e.mins = { -16, -16, 0 };
	self.e.maxs = { 16, 16, 56 };

	self.health = int(175 * st.health_multiplier);
	self.gib_health = -70;
	self.mass = 200;

	@self.pain = chick_pain;
	@self.die = chick_die;

	@self.monsterinfo.stand = chick_stand;
	@self.monsterinfo.walk = chick_walk;
	@self.monsterinfo.run = chick_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = chick_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = chick_sidestep;
	@self.monsterinfo.blocked = chick_blocked; // PGM
	// pmm
	@self.monsterinfo.attack = chick_attack;
	@self.monsterinfo.melee = chick_melee;
	@self.monsterinfo.sight = chick_sight;
	@self.monsterinfo.setskin = chick_setpain;

	gi_linkentity(self.e);

	M_SetAnimation(self, chick_move_stand);
	self.monsterinfo.scale = chick::SCALE;

	// PMM
	self.monsterinfo.blindfire = true;
	// pmm
	walkmonster_start(self);
}

// RAFAEL
/*QUAKED monster_chick_heat (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_chick_heat(ASEntity &self)
{
	SP_monster_chick(self);
	self.e.s.skinnum = 2;
	gi_soundindex("weapons/railgr1a.wav");
}
// RAFAEL
