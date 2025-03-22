// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

mutant

==============================================================================
*/

namespace mutant
{
    enum frames
    {
        attack01,
        attack02,
        attack03,
        attack04,
        attack05,
        attack06,
        attack07,
        attack08,
        attack09,
        attack10,
        attack11,
        attack12,
        attack13,
        attack14,
        attack15,
        death101,
        death102,
        death103,
        death104,
        death105,
        death106,
        death107,
        death108,
        death109,
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
        pain206,
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
        run03,
        run04,
        run05,
        run06,
        run07,
        run08,
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
        stand131,
        stand132,
        stand133,
        stand134,
        stand135,
        stand136,
        stand137,
        stand138,
        stand139,
        stand140,
        stand141,
        stand142,
        stand143,
        stand144,
        stand145,
        stand146,
        stand147,
        stand148,
        stand149,
        stand150,
        stand151,
        stand152,
        stand153,
        stand154,
        stand155,
        stand156,
        stand157,
        stand158,
        stand159,
        stand160,
        stand161,
        stand162,
        stand163,
        stand164,
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
        // ROGUE
        jump01,
        jump02,
        jump03,
        jump04,
        jump05
        // ROGUE
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::mutant
{
    const spawnflags_t NOJUMPING = spawnflag_dec(8);
}

namespace mutant::sounds
{
    cached_soundindex swing("mutant/mutatck1.wav");
    cached_soundindex hit("mutant/mutatck2.wav");
    cached_soundindex hit2("mutant/mutatck3.wav");
    cached_soundindex death("mutant/mutdeth1.wav");
    cached_soundindex idle("mutant/mutidle1.wav");
    cached_soundindex pain1("mutant/mutpain1.wav");
    cached_soundindex pain2("mutant/mutpain2.wav");
    cached_soundindex sight("mutant/mutsght1.wav");
    cached_soundindex search("mutant/mutsrch1.wav");
    cached_soundindex step1("mutant/step1.wav");
    cached_soundindex step2("mutant/step2.wav");
    cached_soundindex step3("mutant/step3.wav");
    cached_soundindex thud("mutant/thud1.wav");
}

//
// SOUNDS
//

void mutant_step(ASEntity &self)
{
	int n = irandom(3);
	if (n == 0)
		gi_sound(self.e, soundchan_t::BODY, mutant::sounds::step1, 1, ATTN_NORM, 0);
	else if (n == 1)
		gi_sound(self.e, soundchan_t::BODY, mutant::sounds::step2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::BODY, mutant::sounds::step3, 1, ATTN_NORM, 0);
}

void mutant_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::sight, 1, ATTN_NORM, 0);
}

void mutant_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::search, 1, ATTN_NORM, 0);
}

void mutant_swing(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::swing, 1, ATTN_NORM, 0);
}

//
// STAND
//

const array<mframe_t> mutant_frames_stand = {
	mframe_t(ai_stand),
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
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // 40

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // 50

	mframe_t(ai_stand)
};
const mmove_t mutant_move_stand = mmove_t(mutant::frames::stand101, mutant::frames::stand151, mutant_frames_stand, null);

void mutant_stand(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_stand);
}

//
// IDLE
//

void mutant_idle_loop(ASEntity &self)
{
	if (frandom() < 0.75f)
		self.monsterinfo.nextframe = mutant::frames::stand155;
}

const array<mframe_t> mutant_frames_idle = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand), // scratch loop start
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, mutant_idle_loop), // scratch loop end
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t mutant_move_idle = mmove_t(mutant::frames::stand152, mutant::frames::stand164, mutant_frames_idle, mutant_stand);

void mutant_idle(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_idle);
	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::idle, 1, ATTN_IDLE, 0);
}

//
// WALK
//

const array<mframe_t> mutant_frames_walk = {
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 1),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 13),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 16),
	mframe_t(ai_walk, 15),
	mframe_t(ai_walk, 6)
};
const mmove_t mutant_move_walk = mmove_t(mutant::frames::walk05, mutant::frames::walk16, mutant_frames_walk, null);

void mutant_walk_loop(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_walk);
}

const array<mframe_t> mutant_frames_start_walk = {
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, -2),
	mframe_t(ai_walk, 1)
};
const mmove_t mutant_move_start_walk = mmove_t(mutant::frames::walk01, mutant::frames::walk04, mutant_frames_start_walk, mutant_walk_loop);

void mutant_walk(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_start_walk);
}

//
// RUN
//

const array<mframe_t> mutant_frames_run = {
	mframe_t(ai_run, 40),
	mframe_t(ai_run, 40, mutant_step),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 5, mutant_step),
	mframe_t(ai_run, 17),
	mframe_t(ai_run, 10)
};
const mmove_t mutant_move_run = mmove_t(mutant::frames::run03, mutant::frames::run08, mutant_frames_run, null);

void mutant_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, mutant_move_stand);
	else
		M_SetAnimation(self, mutant_move_run);
}

//
// MELEE
//

void mutant_hit_left(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], 8 };
	if (fire_hit(self, aim, irandom(5, 15), 100))
		gi_sound(self.e, soundchan_t::WEAPON, mutant::sounds::hit, 1, ATTN_NORM, 0);
	else
	{
		gi_sound(self.e, soundchan_t::WEAPON, mutant::sounds::swing, 1, ATTN_NORM, 0);
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	}
}

void mutant_hit_right(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.maxs[0], 8 };
	if (fire_hit(self, aim, irandom(5, 15), 100))
		gi_sound(self.e, soundchan_t::WEAPON, mutant::sounds::hit2, 1, ATTN_NORM, 0);
	else
	{
		gi_sound(self.e, soundchan_t::WEAPON, mutant::sounds::swing, 1, ATTN_NORM, 0);
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	}
}

void mutant_check_refire(ASEntity &self)
{
	if (self.enemy is null || !self.enemy.e.inuse || self.enemy.health <= 0)
		return;

	if ((self.monsterinfo.melee_debounce_time <= level.time) && ((frandom() < 0.5f) || (range_to(self, self.enemy) <= RANGE_MELEE)))
		self.monsterinfo.nextframe = mutant::frames::attack09;
}

const array<mframe_t> mutant_frames_attack = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, mutant_hit_left),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, mutant_hit_right),
	mframe_t(ai_charge, 0, mutant_check_refire)
};
const mmove_t mutant_move_attack = mmove_t(mutant::frames::attack09, mutant::frames::attack15, mutant_frames_attack, mutant_run);

void mutant_melee(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_attack);
}

//
// ATTACK
//

void mutant_jump_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.health <= 0)
	{
		@self.touch = null;
		return;
	}

	if (self.style == 1 && other.takedamage)
	{
		// [Paril-KEX] only if we're actually moving fast enough to hurt
		if (self.velocity.length() > 30)
		{
			vec3_t point;
			vec3_t normal;
			int	   damage;

			normal = self.velocity;
			normal.normalize();
			point = self.e.s.origin + (normal * self.e.maxs[0]);
			damage = int(frandom(40, 50));
			T_Damage(other, self, self, self.velocity, point, normal, damage, damage, damageflags_t::NONE, mod_id_t::UNKNOWN);
			self.style = 0;
		}
	}

	if (!M_CheckBottom(self))
	{
		if (self.groundentity !is null)
		{
			self.monsterinfo.nextframe = mutant::frames::attack02;
			@self.touch = null;
		}
		return;
	}

	@self.touch = null;
}

void mutant_jump_takeoff(ASEntity &self)
{
	vec3_t forward;

	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::sight, 1, ATTN_NORM, 0);
	AngleVectors(self.e.s.angles, forward);
	self.e.s.origin[2] += 1;
	self.velocity = forward * 425;
	self.velocity[2] = 160;
	@self.groundentity = null;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::DUCKED);
	self.monsterinfo.attack_finished = level.time + time_sec(3);
	self.style = 1;
	@self.touch = mutant_jump_touch;
}

void mutant_check_landing(ASEntity &self)
{
	monster_jump_finished(self);

	if (self.groundentity !is null)
	{
		gi_sound(self.e, soundchan_t::WEAPON, mutant::sounds::thud, 1, ATTN_NORM, 0);
		self.monsterinfo.attack_finished = level.time + random_time(time_ms(500), time_sec(1.5));

		if (self.monsterinfo.unduck !is null)
			self.monsterinfo.unduck(self);

		if (range_to(self, self.enemy) <= RANGE_MELEE * 2.f)
			self.monsterinfo.melee(self);

		return;
	}

	if (level.time > self.monsterinfo.attack_finished)
		self.monsterinfo.nextframe = mutant::frames::attack02;
	else
		self.monsterinfo.nextframe = mutant::frames::attack05;
}

const array<mframe_t> mutant_frames_jump = {
	mframe_t(ai_charge),
	mframe_t(ai_charge, 17),
	mframe_t(ai_charge, 15, mutant_jump_takeoff),
	mframe_t(ai_charge, 15),
	mframe_t(ai_charge, 15, mutant_check_landing),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge)
};
const mmove_t mutant_move_jump = mmove_t(mutant::frames::attack01, mutant::frames::attack08, mutant_frames_jump, mutant_run);

void mutant_jump(ASEntity &self)
{
	M_SetAnimation(self, mutant_move_jump);
}

//
// CHECKATTACK
//

bool mutant_check_melee(ASEntity &self)
{
	return range_to(self, self.enemy) <= RANGE_MELEE && self.monsterinfo.melee_debounce_time <= level.time;
}

bool mutant_check_jump(ASEntity &self)
{
	vec3_t v;
	float  distance;

	// Paril: no harm in letting them jump down if you're below them
	// if (self.e.absmin[2] > (self.enemy.e.absmin[2] + 0.75 * self.enemy.e.size[2]))
	//	return false;

	// don't jump if there's no way we can reach standing height
	if (self.e.absmin[2] + 125 < self.enemy.e.absmin[2])
		return false;

	v[0] = self.e.s.origin[0] - self.enemy.e.s.origin[0];
	v[1] = self.e.s.origin[1] - self.enemy.e.s.origin[1];
	v[2] = 0;
	distance = v.length();

	// if we're not trying to avoid a melee, then don't jump
	if (distance < 100 && self.monsterinfo.melee_debounce_time <= level.time)
		return false;
	// only use it to close distance gaps
	if (distance > 265)
		return false;

	return self.monsterinfo.attack_finished < level.time && brandom();
}

bool mutant_checkattack(ASEntity &self)
{
	if (self.enemy is null || self.enemy.health <= 0)
		return false;

	if (mutant_check_melee(self))
	{
		self.monsterinfo.attack_state = ai_attack_state_t::MELEE;
		return true;
	}

	if (!self.spawnflags.has(spawnflags::mutant::NOJUMPING) && mutant_check_jump(self))
	{
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		return true;
	}

	return false;
}

//
// PAIN
//

const array<mframe_t> mutant_frames_pain1 = {
	mframe_t(ai_move, 4),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 5)
};
const mmove_t mutant_move_pain1 = mmove_t(mutant::frames::pain101, mutant::frames::pain105, mutant_frames_pain1, mutant_run);

const array<mframe_t> mutant_frames_pain2 = {
	mframe_t(ai_move, -24),
	mframe_t(ai_move, 11),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 4)
};
const mmove_t mutant_move_pain2 = mmove_t(mutant::frames::pain201, mutant::frames::pain206, mutant_frames_pain2, mutant_run);

const array<mframe_t> mutant_frames_pain3 = {
	mframe_t(ai_move, -22),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move, 1)
};
const mmove_t mutant_move_pain3 = mmove_t(mutant::frames::pain301, mutant::frames::pain311, mutant_frames_pain3, mutant_run);

void mutant_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	float r;

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	r = frandom();
	if (r < 0.33f)
		gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::pain1, 1, ATTN_NORM, 0);
	else if (r < 0.66f)
		gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::pain2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::pain1, 1, ATTN_NORM, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (r < 0.33f)
		M_SetAnimation(self, mutant_move_pain1);
	else if (r < 0.66f)
		M_SetAnimation(self, mutant_move_pain2);
	else
		M_SetAnimation(self, mutant_move_pain3);
}

void mutant_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

//
// DEATH
//

void mutant_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

// [Paril-KEX]
void ai_move_slide_right(ASEntity &self, float dist)
{
	M_walkmove(self, self.e.s.angles.yaw + 90, dist);
}

void ai_move_slide_left(ASEntity &self, float dist)
{
	M_walkmove(self, self.e.s.angles.yaw - 90, dist);
}

const array<mframe_t> mutant_frames_death1 = {
	mframe_t(ai_move_slide_right),
	mframe_t(ai_move_slide_right),
	mframe_t(ai_move_slide_right),
	mframe_t(ai_move_slide_right, 2),
	mframe_t(ai_move_slide_right, 5),
	mframe_t(ai_move_slide_right, 7, mutant_shrink),
	mframe_t(ai_move_slide_right, 6),
	mframe_t(ai_move_slide_right, 2),
	mframe_t(ai_move_slide_right)
};
const mmove_t mutant_move_death1 = mmove_t(mutant::frames::death101, mutant::frames::death109, mutant_frames_death1, monster_dead);

const array<mframe_t> mutant_frames_death2 = {
	mframe_t(ai_move_slide_left),
	mframe_t(ai_move_slide_left),
	mframe_t(ai_move_slide_left),
	mframe_t(ai_move_slide_left, 1),
	mframe_t(ai_move_slide_left, 3, mutant_shrink),
	mframe_t(ai_move_slide_left, 6),
	mframe_t(ai_move_slide_left, 8),
	mframe_t(ai_move_slide_left, 5),
	mframe_t(ai_move_slide_left, 2),
	mframe_t(ai_move_slide_left)
};
const mmove_t mutant_move_death2 = mmove_t(mutant::frames::death201, mutant::frames::death210, mutant_frames_death2, monster_dead);

void mutant_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(2, "models/monsters/mutant/gibs/hand.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t(2, "models/monsters/mutant/gibs/foot.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/mutant/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/mutant/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});

		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	gi_sound(self.e, soundchan_t::VOICE, mutant::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	if (frandom() < 0.5f)
		M_SetAnimation(self, mutant_move_death1);
	else
		M_SetAnimation(self, mutant_move_death2);
}

//================
// ROGUE
void mutant_jump_down(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void mutant_jump_up(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 200);
	self.velocity += (up * 450);
}

void mutant_jump_wait_land(ASEntity &self)
{
	if (!monster_jump_finished(self) && self.groundentity is null)
		self.monsterinfo.nextframe = self.e.s.frame;
	else
		self.monsterinfo.nextframe = self.e.s.frame + 1;
}

const array<mframe_t> mutant_frames_jump_up = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8, mutant_jump_up),
	mframe_t(ai_move, 0, mutant_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t mutant_move_jump_up = mmove_t(mutant::frames::jump01, mutant::frames::jump05, mutant_frames_jump_up, mutant_run);

const array<mframe_t> mutant_frames_jump_down = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, mutant_jump_down),
	mframe_t(ai_move, 0, mutant_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t mutant_move_jump_down = mmove_t(mutant::frames::jump01, mutant::frames::jump05, mutant_frames_jump_down, mutant_run);

void mutant_jump_updown(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, mutant_move_jump_up);
	else
		M_SetAnimation(self, mutant_move_jump_down);
}

/*
===
Blocked
===
*/
bool mutant_blocked(ASEntity &self, float dist)
{
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			mutant_jump_updown(self, result);
		return true;
	}

	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// ROGUE
//================

//
// SPAWN
//

/*QUAKED monster_mutant (1 .5 0) (-32 -32 -24) (32 32 32) Ambush Trigger_Spawn Sight NoJumping
model="models/monsters/mutant/tris.md2"
*/
void SP_monster_mutant(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	mutant::sounds::swing.precache();
	mutant::sounds::hit.precache();
	mutant::sounds::hit2.precache();
	mutant::sounds::death.precache();
	mutant::sounds::idle.precache();
	mutant::sounds::pain1.precache();
	mutant::sounds::pain2.precache();
	mutant::sounds::sight.precache();
	mutant::sounds::search.precache();
	mutant::sounds::step1.precache();
	mutant::sounds::step2.precache();
	mutant::sounds::step3.precache();
	mutant::sounds::thud.precache();

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STINKY);

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/mutant/tris.md2");
	
	gi_modelindex("models/monsters/mutant/gibs/head.md2");
	gi_modelindex("models/monsters/mutant/gibs/chest.md2");
	gi_modelindex("models/monsters/mutant/gibs/hand.md2");
	gi_modelindex("models/monsters/mutant/gibs/foot.md2");

	self.e.mins = { -18, -18, -24 };
	self.e.maxs = { 18, 18, 30 };

	self.health = int(300 * st.health_multiplier);
	self.gib_health = -120;
	self.mass = 300;

	@self.pain = mutant_pain;
	@self.die = mutant_die;

	@self.monsterinfo.stand = mutant_stand;
	@self.monsterinfo.walk = mutant_walk;
	@self.monsterinfo.run = mutant_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = mutant_jump;
	@self.monsterinfo.melee = mutant_melee;
	@self.monsterinfo.sight = mutant_sight;
	@self.monsterinfo.search = mutant_search;
	@self.monsterinfo.idle = mutant_idle;
	@self.monsterinfo.checkattack = mutant_checkattack;
	@self.monsterinfo.blocked = mutant_blocked; // PGM
	@self.monsterinfo.setskin = mutant_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, mutant_move_stand);

	self.monsterinfo.combat_style = combat_style_t::MELEE;

	self.monsterinfo.scale = mutant::SCALE;
	self.monsterinfo.can_jump = !self.spawnflags.has(spawnflags::mutant::NOJUMPING);
	self.monsterinfo.drop_height = 256;
	self.monsterinfo.jump_height = 68;

	walkmonster_start(self);
}
