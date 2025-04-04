// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

jorg

==============================================================================
*/

namespace boss31
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
        death01,
        death02,
        death03,
        death04,
        death05,
        death06,
        death07,
        death08,
        death09,
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
        death50,
        pain101,
        pain102,
        pain103,
        pain201,
        pain202,
        pain203,
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
        pain322,
        pain323,
        pain324,
        pain325,
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
        stand46,
        stand47,
        stand48,
        stand49,
        stand50,
        stand51,
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
        walk25
    };

    const float SCALE = 1.000000f;
}

namespace boss31::sounds
{
    cached_soundindex pain1("boss3/bs3pain1.wav");
    cached_soundindex pain2("boss3/bs3pain2.wav");
    cached_soundindex pain3("boss3/bs3pain3.wav");
    cached_soundindex death("boss3/bs3deth1.wav");
    cached_soundindex attack1("boss3/bs3atck1.wav");
    cached_soundindex attack1_loop("boss3/bs3atck1_loop.wav");
    cached_soundindex attack1_end("boss3/bs3atck1_end.wav");
    cached_soundindex attack2("boss3/bs3atck2.wav");
    cached_soundindex search1("boss3/bs3srch1.wav");
    cached_soundindex search2("boss3/bs3srch2.wav");
    cached_soundindex search3("boss3/bs3srch3.wav");
    cached_soundindex idle("boss3/bs3idle1.wav");
    cached_soundindex step_left("boss3/step1.wav");
    cached_soundindex step_right("boss3/step2.wav");
    cached_soundindex firegun("boss3/xfire.wav");
    cached_soundindex death_hit("boss3/d_hit.wav");
    cached_soundindex bfg_fire("makron/bfg_fire.wav");
}

void jorg_attack1_end_sound(ASEntity &self)
{
	if (self.monsterinfo.weapon_sound != 0)
	{
		gi_sound(self.e, soundchan_t::WEAPON, boss31::sounds::attack1_end, 1, ATTN_NORM, 0);
		self.monsterinfo.weapon_sound = 0;
	}
}

void jorg_search(ASEntity &self)
{
	float r;

	r = frandom();

	if (r <= 0.3f)
		gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::search1, 1, ATTN_NORM, 0);
	else if (r <= 0.6f)
		gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::search2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::search3, 1, ATTN_NORM, 0);
}

//
// stand
//

const array<mframe_t> jorg_frames_stand = {
	mframe_t(ai_stand, 0, jorg_idle),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // 10
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // 20
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // 30
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 19),
	mframe_t(ai_stand, 11, jorg_step_left),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 6),
	mframe_t(ai_stand, 9, jorg_step_right),
	mframe_t(ai_stand), // 40
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -2, null),
	mframe_t(ai_stand, -17, jorg_step_left),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -12),				   // 50
	mframe_t(ai_stand, -14, jorg_step_right) // 51
};
const mmove_t jorg_move_stand = mmove_t(boss31::frames::stand01, boss31::frames::stand51, jorg_frames_stand, null);

void jorg_idle (ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::idle, 1, ATTN_NORM, 0);
}

void jorg_death_hit(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss31::sounds::death_hit, 1, ATTN_NORM, 0);
}

void jorg_step_left(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss31::sounds::step_left, 1, ATTN_NORM, 0);
}

void jorg_step_right(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss31::sounds::step_right, 1, ATTN_NORM, 0);
}

void jorg_stand(ASEntity &self)
{
	M_SetAnimation(self, jorg_move_stand);

	jorg_attack1_end_sound(self);
}

const array<mframe_t> jorg_frames_run = {
	mframe_t(ai_run, 17, jorg_step_left),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 33, jorg_step_right),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 9)
};
const mmove_t jorg_move_run = mmove_t(boss31::frames::walk06, boss31::frames::walk19, jorg_frames_run, null);

//
// walk
//
/*
const array<mframe_t> jorg_frames_start_walk = {
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 15)
};
const mmove_t jorg_move_start_walk = mmove_t(boss31::frames::walk01, boss31::frames::walk05, jorg_frames_start_walk, null);
*/

const array<mframe_t> jorg_frames_walk = {
	mframe_t(ai_walk, 17),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 33),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 9)
};
const mmove_t jorg_move_walk = mmove_t(boss31::frames::walk06, boss31::frames::walk19, jorg_frames_walk, null);

/*
const array<mframe_t> jorg_frames_end_walk = {
	mframe_t(ai_walk, 11),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, -8)
};
const mmove_t jorg_move_end_walk = mmove_t(boss31::frames::walk20, boss31::frames::walk25, jorg_frames_end_walk, null);
*/

void jorg_walk(ASEntity &self)
{
	M_SetAnimation(self, jorg_move_walk);
}

void jorg_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, jorg_move_stand);
	else
		M_SetAnimation(self, jorg_move_run);

	jorg_attack1_end_sound(self);
}

const array<mframe_t> jorg_frames_pain3 = {
	mframe_t(ai_move, -28),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -3, jorg_step_left),
	mframe_t(ai_move, -9),
	mframe_t(ai_move, 0, jorg_step_right),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -7),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, -11),
	mframe_t(ai_move, -4),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 10),
	mframe_t(ai_move, 11),
	mframe_t(ai_move),
	mframe_t(ai_move, 10),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 10),
	mframe_t(ai_move, 7, jorg_step_left),
	mframe_t(ai_move, 17),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, jorg_step_right)
};
const mmove_t jorg_move_pain3 = mmove_t(boss31::frames::pain301, boss31::frames::pain325, jorg_frames_pain3, jorg_run);

const array<mframe_t> jorg_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t jorg_move_pain2 = mmove_t(boss31::frames::pain201, boss31::frames::pain203, jorg_frames_pain2, jorg_run);

const array<mframe_t> jorg_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t jorg_move_pain1 = mmove_t(boss31::frames::pain101, boss31::frames::pain103, jorg_frames_pain1, jorg_run);

const array<mframe_t> jorg_frames_death1 = {
	mframe_t(ai_move, 0, BossExplode),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -15, jorg_step_left),
	mframe_t(ai_move), // 10
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -11),
	mframe_t(ai_move, -25),
	mframe_t(ai_move, -10, jorg_step_right),
	mframe_t(ai_move),
	mframe_t(ai_move), // 20
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -21),
	mframe_t(ai_move, -10),
	mframe_t(ai_move, -16, jorg_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 30
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 22),
	mframe_t(ai_move, 33, jorg_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 28),
	mframe_t(ai_move, 28, jorg_step_right),
	mframe_t(ai_move),
	mframe_t(ai_move), // 40
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -19),
	mframe_t(ai_move, 0, jorg_death_hit),
	mframe_t(ai_move),
	mframe_t(ai_move) // 50
};
const mmove_t jorg_move_death = mmove_t(boss31::frames::death01, boss31::frames::death50, jorg_frames_death1, jorg_dead);

const array<mframe_t> jorg_frames_attack2 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, jorgBFG),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t jorg_move_attack2 = mmove_t(boss31::frames::attak201, boss31::frames::attak213, jorg_frames_attack2, jorg_run);

const array<mframe_t> jorg_frames_start_attack1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t jorg_move_start_attack1 = mmove_t(boss31::frames::attak101, boss31::frames::attak108, jorg_frames_start_attack1, jorg_attack1);

const array<mframe_t> jorg_frames_attack1 = {
	mframe_t(ai_charge, 0, jorg_firebullet),
	mframe_t(ai_charge, 0, jorg_firebullet),
	mframe_t(ai_charge, 0, jorg_firebullet),
	mframe_t(ai_charge, 0, jorg_firebullet),
	mframe_t(ai_charge, 0, jorg_firebullet),
	mframe_t(ai_charge, 0, jorg_firebullet)
};
const mmove_t jorg_move_attack1 = mmove_t(boss31::frames::attak109, boss31::frames::attak114, jorg_frames_attack1, jorg_reattack1);

const array<mframe_t> jorg_frames_end_attack1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t jorg_move_end_attack1 = mmove_t(boss31::frames::attak115, boss31::frames::attak118, jorg_frames_end_attack1, jorg_run);

void jorg_reattack1(ASEntity &self)
{
	if (visible(self, self.enemy))
	{
		if (frandom() < 0.9f)
			M_SetAnimation(self, jorg_move_attack1);
		else
		{
			M_SetAnimation(self, jorg_move_end_attack1);
			jorg_attack1_end_sound(self);
		}
	}
	else
	{
		M_SetAnimation(self, jorg_move_end_attack1);
		jorg_attack1_end_sound(self);
	}
}

void jorg_attack1(ASEntity &self)
{
	M_SetAnimation(self, jorg_move_attack1);
}

void jorg_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	// Lessen the chance of him going into his pain frames if he takes little damage
	if (mod.id != mod_id_t::CHAINFIST)
	{
		if (damage <= 40)
			if (frandom() <= 0.6f)
				return;

		/*
		If he's entering his attack1 or using attack1, lessen the chance of him
		going into pain
		*/

		if ((self.e.s.frame >= boss31::frames::attak101) && (self.e.s.frame <= boss31::frames::attak108))
			if (frandom() <= 0.005f)
				return;

		if ((self.e.s.frame >= boss31::frames::attak109) && (self.e.s.frame <= boss31::frames::attak114))
			if (frandom() <= 0.00005f)
				return;

		if ((self.e.s.frame >= boss31::frames::attak201) && (self.e.s.frame <= boss31::frames::attak208))
			if (frandom() <= 0.005f)
				return;
	}

	self.pain_debounce_time = level.time + time_sec(3);

	bool do_pain3 = false;

	if (damage > 50)
	{
		if (damage <= 100)
		{
			gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::pain2, 1, ATTN_NORM, 0);
		}
		else
		{
			if (frandom() <= 0.3f)
			{
				do_pain3 = true;
				gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::pain3, 1, ATTN_NORM, 0);
			}
		}
	}

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare
	
	jorg_attack1_end_sound(self);

	if (damage <= 50)
		M_SetAnimation(self, jorg_move_pain1);
	else if (damage <= 100)
		M_SetAnimation(self, jorg_move_pain2);
	else if (do_pain3)
		M_SetAnimation(self, jorg_move_pain3);
}

void jorg_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void jorgBFG(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;
	vec3_t vec;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::JORG_BFG_1], forward, right);

	vec = self.enemy.e.s.origin;
	vec[2] += self.enemy.viewheight;
	dir = vec - start;
	dir.normalize();
	gi_sound(self.e, soundchan_t::WEAPON, boss31::sounds::bfg_fire, 1, ATTN_NORM, 0);
	monster_fire_bfg(self, start, dir, 50, 300, 100, 200, monster_muzzle_t::JORG_BFG_1);
}

void jorg_firebullet_right(ASEntity &self)
{
	vec3_t forward, right, start;
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::JORG_MACHINEGUN_R1], forward, right);
	PredictAim(self, self.enemy, start, 0, false, -0.2f, forward);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, monster_muzzle_t::JORG_MACHINEGUN_R1);
}

void jorg_firebullet_left(ASEntity &self)
{
	vec3_t forward, right, start;
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::JORG_MACHINEGUN_L1], forward, right);
	PredictAim(self, self.enemy, start, 0, false, 0.2f, forward);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, monster_muzzle_t::JORG_MACHINEGUN_L1);
}

void jorg_firebullet(ASEntity &self)
{
	jorg_firebullet_left(self);
	jorg_firebullet_right(self);
}

void jorg_attack(ASEntity &self)
{
	if (frandom() <= 0.75f)
	{
		gi_sound(self.e, soundchan_t::WEAPON, boss31::sounds::attack1, 1, ATTN_NORM, 0);
		self.monsterinfo.weapon_sound = gi_soundindex("boss3/w_loop.wav");
		M_SetAnimation(self, jorg_move_start_attack1);
	}
	else
	{
		gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::attack2, 1, ATTN_NORM, 0);
		M_SetAnimation(self, jorg_move_attack2);
	}
}

void jorg_dead(ASEntity &self)
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
		gib_def_t("models/monsters/boss3/jorg/gibs/chest.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/boss3/jorg/gibs/foot.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/boss3/jorg/gibs/gun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t(2, "models/monsters/boss3/jorg/gibs/thigh.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/boss3/jorg/gibs/spine.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t(4, "models/monsters/boss3/jorg/gibs/tube.md2", gib_type_t::SKINNED),
		gib_def_t(6, "models/monsters/boss3/jorg/gibs/spike.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/boss3/jorg/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC | gib_type_t::HEAD))
	});

	MakronToss(self);
}

void jorg_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_sound(self.e, soundchan_t::VOICE, boss31::sounds::death, 1, ATTN_NORM, 0);
	jorg_attack1_end_sound(self);
	self.deadflag = true;
	self.takedamage = false;
	self.count = 0;
	M_SetAnimation(self, jorg_move_death);
}

// [Paril-KEX] use generic function
bool Jorg_CheckAttack(ASEntity &self)
{
	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.4f, 0.2f, 0.0f, 0.f);
}

/*QUAKED monster_jorg (1 .5 0) (-80 -80 0) (90 90 140) Ambush Trigger_Spawn Sight
 */
void SP_monster_jorg(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	boss31::sounds::pain1.precache();
	boss31::sounds::pain2.precache();
	boss31::sounds::pain3.precache();
	boss31::sounds::death.precache();
	boss31::sounds::attack1.precache();
	boss31::sounds::attack1_loop.precache();
	boss31::sounds::attack1_end.precache();
	boss31::sounds::attack2.precache();
	boss31::sounds::search1.precache();
	boss31::sounds::search2.precache();
	boss31::sounds::search3.precache();
	boss31::sounds::idle.precache();
	boss31::sounds::step_left.precache();
	boss31::sounds::step_right.precache();
	boss31::sounds::firegun.precache();
	boss31::sounds::death_hit.precache();
	boss31::sounds::bfg_fire.precache();

	MakronPrecache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/boss3/jorg/tris.md2");
	self.e.s.modelindex2 = gi_modelindex("models/monsters/boss3/rider/tris.md2");
	
	gi_modelindex("models/monsters/boss3/jorg/gibs/chest.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/foot.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/gun.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/head.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/spike.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/spine.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/thigh.md2");
	gi_modelindex("models/monsters/boss3/jorg/gibs/tube.md2");

	self.e.mins = { -80, -80, 0 };
	self.e.maxs = { 80, 80, 140 };

	self.health = int(8000 * st.health_multiplier);
	self.gib_health = -2000;
	self.mass = 1000;

	@self.pain = jorg_pain;
	@self.die = jorg_die;
	@self.monsterinfo.stand = jorg_stand;
	@self.monsterinfo.walk = jorg_walk;
	@self.monsterinfo.run = jorg_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = jorg_attack;
	@self.monsterinfo.search = jorg_search;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = null;
	@self.monsterinfo.checkattack = Jorg_CheckAttack;
	@self.monsterinfo.setskin = jorg_setskin;
	gi_linkentity(self.e);

	M_SetAnimation(self, jorg_move_stand);
	self.monsterinfo.scale = boss31::SCALE;

	walkmonster_start(self);
	// PMM
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	// pmm
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::DOUBLE_TROUBLE);
}
