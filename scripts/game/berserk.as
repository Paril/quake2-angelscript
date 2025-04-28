// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

BERSERK

==============================================================================
*/

namespace berserk
{
    enum frames
    {
        stand1,
        stand2,
        stand3,
        stand4,
        stand5,
        standb1,
        standb2,
        standb3,
        standb4,
        standb5,
        standb6,
        standb7,
        standb8,
        standb9,
        standb10,
        standb11,
        standb12,
        standb13,
        standb14,
        standb15,
        standb16,
        standb17,
        standb18,
        standb19,
        standb20,
        walkc1,
        walkc2,
        walkc3,
        walkc4,
        walkc5,
        walkc6,
        walkc7,
        walkc8,
        walkc9,
        walkc10,
        walkc11,
        run1,
        run2,
        run3,
        run4,
        run5,
        run6,
        att_a1,
        att_a2,
        att_a3,
        att_a4,
        att_a5,
        att_a6,
        att_a7,
        att_a8,
        att_a9,
        att_a10,
        att_a11,
        att_a12,
        att_a13,
        att_b1,
        att_b2,
        att_b3,
        att_b4,
        att_b5,
        att_b6,
        att_b7,
        att_b8,
        att_b9,
        att_b10,
        att_b11,
        att_b12,
        att_b13,
        att_b14,
        att_b15,
        att_b16,
        att_b17,
        att_b18,
        att_b19,
        att_b20,
        att_b21,
        att_c1,
        att_c2,
        att_c3,
        att_c4,
        att_c5,
        att_c6,
        att_c7,
        att_c8,
        att_c9,
        att_c10,
        att_c11,
        att_c12,
        att_c13,
        att_c14,
        att_c15,
        att_c16,
        att_c17,
        att_c18,
        att_c19,
        att_c20,
        att_c21,
        att_c22,
        att_c23,
        att_c24,
        att_c25,
        att_c26,
        att_c27,
        att_c28,
        att_c29,
        att_c30,
        att_c31,
        att_c32,
        att_c33,
        att_c34,
        r_att1,
        r_att2,
        r_att3,
        r_att4,
        r_att5,
        r_att6,
        r_att7,
        r_att8,
        r_att9,
        r_att10,
        r_att11,
        r_att12,
        r_att13,
        r_att14,
        r_att15,
        r_att16,
        r_att17,
        r_att18,
        r_attb1,
        r_attb2,
        r_attb3,
        r_attb4,
        r_attb5,
        r_attb6,
        r_attb7,
        r_attb8,
        r_attb9,
        r_attb10,
        r_attb11,
        r_attb12,
        r_attb13,
        r_attb14,
        r_attb15,
        r_attb16,
        r_attb17,
        r_attb18,
        slam1,
        slam2,
        slam3,
        slam4,
        slam5,
        slam6,
        slam7,
        slam8,
        slam9,
        slam10,
        slam11,
        slam12,
        slam13,
        slam14,
        slam15,
        slam16,
        slam17,
        slam18,
        slam19,
        slam20,
        slam21,
        slam22,
        slam23,
        duck1,
        duck2,
        duck3,
        duck4,
        duck5,
        duck6,
        duck7,
        duck8,
        duck9,
        duck10,
        fall1,
        fall2,
        fall3,
        fall4,
        fall5,
        fall6,
        fall7,
        fall8,
        fall9,
        fall10,
        fall11,
        fall12,
        fall13,
        fall14,
        fall15,
        fall16,
        fall17,
        fall18,
        fall19,
        fall20,
        painc1,
        painc2,
        painc3,
        painc4,
        painb1,
        painb2,
        painb3,
        painb4,
        painb5,
        painb6,
        painb7,
        painb8,
        painb9,
        painb10,
        painb11,
        painb12,
        painb13,
        painb14,
        painb15,
        painb16,
        painb17,
        painb18,
        painb19,
        painb20,
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
        deathc1,
        deathc2,
        deathc3,
        deathc4,
        deathc5,
        deathc6,
        deathc7,
        deathc8,
        // PGM
        jump1,
        jump2,
        jump3,
        jump4,
        jump5,
        jump6,
        jump7,
        jump8,
        jump9
        // PGM
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::berserk
{
    const uint32 NOJUMPING = 8;
}

namespace berserk::sounds
{
    cached_soundindex pain("berserk/berpain2.wav");
    cached_soundindex die("berserk/berdeth2.wav");
    cached_soundindex idle("berserk/beridle1.wav");
    cached_soundindex idle2("berserk/idle.wav");
    cached_soundindex punch("berserk/attack.wav");
    cached_soundindex sight("berserk/sight.wav");
    cached_soundindex search("berserk/bersrch1.wav");
    cached_soundindex thud("mutant/thud1.wav");
    cached_soundindex explod("world/explod2.wav");
    cached_soundindex jump("berserk/jump.wav");
}

void berserk_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, berserk::sounds::sight, 1, ATTN_NORM, 0);
}

void berserk_search(ASEntity &self)
{
	if (brandom())
		gi_sound(self.e, soundchan_t::VOICE, berserk::sounds::idle2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, berserk::sounds::search, 1, ATTN_NORM, 0);
}

const array<mframe_t> berserk_frames_stand = {
	mframe_t(ai_stand, 0, berserk_fidget),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t berserk_move_stand = mmove_t(berserk::frames::stand1, berserk::frames::stand5, berserk_frames_stand, null);

void berserk_stand(ASEntity &self)
{
	M_SetAnimation(self, berserk_move_stand);
}

const array<mframe_t> berserk_frames_stand_fidget = {
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
const mmove_t berserk_move_stand_fidget = mmove_t(berserk::frames::standb1, berserk::frames::standb20, berserk_frames_stand_fidget, berserk_stand);

void berserk_fidget(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		return;
	else if (self.enemy !is null)
		return;
	if (frandom() > 0.15f)
		return;

	M_SetAnimation(self, berserk_move_stand_fidget);
	gi_sound(self.e, soundchan_t::WEAPON, berserk::sounds::idle, 1, ATTN_IDLE, 0);
}

const array<mframe_t> berserk_frames_walk = {
	mframe_t(ai_walk, 9.1f),
	mframe_t(ai_walk, 6.3f),
	mframe_t(ai_walk, 4.9f),
	mframe_t(ai_walk, 6.7f, monster_footstep),
	mframe_t(ai_walk, 6.0f),
	mframe_t(ai_walk, 8.2f),
	mframe_t(ai_walk, 7.2f),
	mframe_t(ai_walk, 6.1f),
	mframe_t(ai_walk, 4.9f),
	mframe_t(ai_walk, 4.7f, monster_footstep),
	mframe_t(ai_walk, 4.7f)
};
const mmove_t berserk_move_walk = mmove_t(berserk::frames::walkc1, berserk::frames::walkc11, berserk_frames_walk, null);

void berserk_walk(ASEntity &self)
{
	M_SetAnimation(self, berserk_move_walk);
}

/*

  *****************************
  SKIPPED THIS FOR NOW!
  *****************************

   Running . Arm raised in air

void()	berserk_runb1	=[	$r_att1 ,	berserk_runb2	] {ai_run(21);};
void()	berserk_runb2	=[	$r_att2 ,	berserk_runb3	] {ai_run(11);};
void()	berserk_runb3	=[	$r_att3 ,	berserk_runb4	] {ai_run(21);};
void()	berserk_runb4	=[	$r_att4 ,	berserk_runb5	] {ai_run(25);};
void()	berserk_runb5	=[	$r_att5 ,	berserk_runb6	] {ai_run(18);};
void()	berserk_runb6	=[	$r_att6 ,	berserk_runb7	] {ai_run(19);};
// running with arm in air : start loop
void()	berserk_runb7	=[	$r_att7 ,	berserk_runb8	] {ai_run(21);};
void()	berserk_runb8	=[	$r_att8 ,	berserk_runb9	] {ai_run(11);};
void()	berserk_runb9	=[	$r_att9 ,	berserk_runb10	] {ai_run(21);};
void()	berserk_runb10	=[	$r_att10 ,	berserk_runb11	] {ai_run(25);};
void()	berserk_runb11	=[	$r_att11 ,	berserk_runb12	] {ai_run(18);};
void()	berserk_runb12	=[	$r_att12 ,	berserk_runb7	] {ai_run(19);};
// running with arm in air : end loop
*/

const array<mframe_t> berserk_frames_run1 = {
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 11, monster_footstep),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 25, monster_done_dodge),
	mframe_t(ai_run, 18, monster_footstep),
	mframe_t(ai_run, 19)
};
const mmove_t berserk_move_run1 = mmove_t(berserk::frames::run1, berserk::frames::run6, berserk_frames_run1, null);

void berserk_run(ASEntity &self)
{
	monster_done_dodge(self);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, berserk_move_stand);
	else
		M_SetAnimation(self, berserk_move_run1);
}

void berserk_attack_spike(ASEntity &self)
{
	const vec3_t aim = { MELEE_DISTANCE, 0, -24 };
	
	if (!fire_hit(self, aim, irandom(5, 11), 400)) //	Faster attack -- upwards and backwards
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.2);
}

void berserk_swing(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, berserk::sounds::punch, 1, ATTN_NORM, 0);
}

const array<mframe_t> berserk_frames_attack_spike = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, berserk_swing),
	mframe_t(ai_charge, 0, berserk_attack_spike),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t berserk_move_attack_spike = mmove_t(berserk::frames::att_c1, berserk::frames::att_c8, berserk_frames_attack_spike, berserk_run);

void berserk_attack_club(ASEntity &self)
{
	const vec3_t aim = { MELEE_DISTANCE, self.e.mins.x, -4 };
	
	if (!fire_hit(self, aim, irandom(15, 21), 250)) // Slower attack
		self.monsterinfo.melee_debounce_time = level.time + time_sec(2.5);
}

const array<mframe_t> berserk_frames_attack_club = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, berserk_swing),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, berserk_attack_club),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t berserk_move_attack_club = mmove_t(berserk::frames::att_c9, berserk::frames::att_c20, berserk_frames_attack_club, berserk_run);


/*
============
T_RadiusDamage
============
*/
void T_SlamRadiusDamage(vec3_t point, ASEntity &inflictor, ASEntity &attacker, float damage, float kick, ASEntity &ignore, float radius, mod_t mod)
{
	float	 points;
	ASEntity @ent = null;
	vec3_t	 v;
	vec3_t	 dir;

	while ((@ent = findradius(ent, inflictor.e.s.origin, radius * 2.f)) !is null)
	{
		if (ent is ignore)
			continue;
		if (!ent.takedamage)
			continue;
		if (!CanDamage(ent, inflictor))
			continue;
		// don't hit players in mid air
		if (ent.client !is null && ent.groundentity is null)
			continue;

		v = closest_point_to_box(point, ent.e.s.origin + ent.e.mins, ent.e.s.origin + ent.e.maxs) - point;

		// calculate contribution amount
		float amount = min(1.f, 1.f - (v.length() / radius));

		// too far away
		if (amount <= 0.f)
			continue;

		amount *= amount;

		// damage & kick are exponentially scaled
		points = max(1.f, damage * amount);

		dir = (ent.e.s.origin - point).normalized();

		// keep the point at their feet so they always get knocked up
		point[2] = ent.e.absmin[2];
		T_Damage(ent, inflictor, attacker, dir, point, dir, int(points), int(kick * amount),
					damageflags_t::RADIUS, mod);

		if (ent.client !is null)
			ent.velocity.z = max(270.f, ent.velocity.z);
	}
}

void berserk_attack_slam(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, berserk::sounds::thud, 1, ATTN_NORM, 0);
	gi_sound(self.e, soundchan_t::AUTO, berserk::sounds::explod, 0.75f, ATTN_NORM, 0);
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::BERSERK_SLAM);
	vec3_t f, r, start;
	AngleVectors(self.e.s.angles, f, r);
	start = M_ProjectFlashSource(self, { 20.f, -14.3f, -21.f }, f, r);
	trace_t tr = gi_traceline(self.e.s.origin, start, self.e, contents_t::MASK_SOLID);
	gi_WritePosition(tr.endpos);
	gi_WriteDir({ 0.f, 0.f, 1.f });
	gi_multicast(tr.endpos, multicast_t::PHS, false);
	self.gravity = 1.0f;
	self.velocity = vec3_origin;
	self.flags = ent_flags_t(self.flags | ent_flags_t::KILL_VELOCITY);

	T_SlamRadiusDamage(tr.endpos, self, self, 8, 300.f, self, 165, mod_id_t::UNKNOWN);
}

void berserk_jump_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.health <= 0)
	{
		@self.touch = null;
		return;
	}

	if (self.groundentity !is null)
	{
		self.e.s.frame = berserk::frames::slam18;

		if (self.touch !is null)
			berserk_attack_slam(self);

		@self.touch = null;
	}
}

void berserk_high_gravity(ASEntity &self)
{
	float gravity_scale = (800.f / level.gravity);

	if (self.velocity[2] < 0)
		self.gravity = 2.25f;
	else
		self.gravity = 5.25f;

	self.gravity *= gravity_scale;
}

void berserk_jump_takeoff(ASEntity &self)
{
	vec3_t forward;

	if (self.enemy is null)
		return;

	// immediately turn to where we need to go
	float length = (self.e.s.origin - self.enemy.e.s.origin).length();
	float fwd_speed = length * 1.95f;
	vec3_t dir;
	PredictAim(self, self.enemy, self.e.s.origin, fwd_speed, false, 0.f, dir);
	self.e.s.angles.y = vectoyaw(dir);
	AngleVectors(self.e.s.angles, forward);
	self.e.s.origin.z += 1;
	self.velocity = forward * fwd_speed;
	self.velocity.z = 400;
	@self.groundentity = null;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DUCKED);
	self.monsterinfo.attack_finished = level.time + time_sec(3);
	@self.touch = berserk_jump_touch;
	berserk_high_gravity(self);

	self.gravity = -self.gravity;
	SV_AddGravity(self);
	self.gravity = -self.gravity;

	gi_linkentity(self.e);
}

void berserk_check_landing(ASEntity &self)
{
	berserk_high_gravity(self);

	if (self.groundentity !is null)
	{
		self.monsterinfo.attack_finished = time_zero;
		self.monsterinfo.unduck(self);
		self.e.s.frame = berserk::frames::slam18;
		if (self.touch !is null)
		{
			berserk_attack_slam(self);
			@self.touch = null;
		}
		self.flags = ent_flags_t(self.flags & ~ent_flags_t::KILL_VELOCITY);
		return;
	}

	if (level.time > self.monsterinfo.attack_finished)
		self.monsterinfo.nextframe = berserk::frames::slam3;
	else
		self.monsterinfo.nextframe = berserk::frames::slam5;
}

const array<mframe_t> berserk_frames_attack_strike = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_move, 0, berserk_jump_takeoff),
	mframe_t(ai_move, 0, berserk_high_gravity),
	mframe_t(ai_move, 0, berserk_check_landing),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
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
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t berserk_move_attack_strike = mmove_t(berserk::frames::slam1, berserk::frames::slam23, berserk_frames_attack_strike, berserk_run);

void berserk_melee(ASEntity &self)
{
	if (self.monsterinfo.melee_debounce_time > level.time)
		return;
	// if we're *almost* ready to land down the hammer from run-attack
	// don't switch us
	else if (self.monsterinfo.active_move is berserk_move_run_attack1 && self.e.s.frame >= berserk::frames::r_att13)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		self.monsterinfo.attack_finished = time_zero;
		return;
	}

	monster_done_dodge(self);

	if (brandom())
		M_SetAnimation(self, berserk_move_attack_spike);
	else
		M_SetAnimation(self, berserk_move_attack_club);
}

void berserk_run_attack_speed(ASEntity &self)
{
	if (self.enemy !is null && range_to(self, self.enemy) < MELEE_DISTANCE)
	{
		self.monsterinfo.nextframe = self.e.s.frame + 6;
		monster_done_dodge(self);
	}
}

void berserk_run_swing(ASEntity &self)
{
	berserk_swing(self);
	self.monsterinfo.melee_debounce_time = level.time + time_sec(0.6);

	if (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		monster_done_dodge(self);
	}
}

const array<mframe_t> berserk_frames_run_attack1 = {
	mframe_t(ai_run, 21, berserk_run_attack_speed),
	mframe_t(ai_run, 11, function(self) { berserk_run_attack_speed(self); monster_footstep(self); }),
	mframe_t(ai_run, 21, berserk_run_attack_speed),
	mframe_t(ai_run, 25, function(self) { berserk_run_attack_speed(self); monster_done_dodge(self); }),
	mframe_t(ai_run, 18, function(self) { berserk_run_attack_speed(self); monster_footstep(self); }),
	mframe_t(ai_run, 19, berserk_run_attack_speed),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 11, monster_footstep),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 25),
	mframe_t(ai_run, 18, monster_footstep),
	mframe_t(ai_run, 19),
	mframe_t(ai_run, 21, berserk_run_swing),
	mframe_t(ai_run, 11, monster_footstep),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 25),
	mframe_t(ai_run, 18, monster_footstep),
	mframe_t(ai_run, 19, berserk_attack_club)
};
const mmove_t berserk_move_run_attack1 = mmove_t(berserk::frames::r_att1, berserk::frames::r_att18, berserk_frames_run_attack1, berserk_run);

void berserk_attack(ASEntity &self)
{
	if (self.monsterinfo.melee_debounce_time <= level.time && (range_to(self, self.enemy) < MELEE_DISTANCE))
		berserk_melee(self);
	// only jump if they are far enough away for it to make sense (otherwise
	// it gets annoying to have them keep hopping over and over again)
	else if ((self.spawnflags & spawnflags::berserk::NOJUMPING) == 0 && (self.timestamp < level.time && brandom()) && range_to(self, self.enemy) > 150.f)
	{
		M_SetAnimation(self, berserk_move_attack_strike);
		// don't do this for a while, otherwise we just keep doing it
		gi_sound(self.e, soundchan_t::WEAPON, berserk::sounds::jump, 1, ATTN_NORM, 0);
		self.timestamp = level.time + time_sec(5);
	}
	else if (self.monsterinfo.active_move is berserk_move_run1 && (range_to(self, self.enemy) <= RANGE_NEAR))
	{
		M_SetAnimation(self, berserk_move_run_attack1);
		self.monsterinfo.nextframe = berserk::frames::r_att1 + (self.e.s.frame - berserk::frames::run1) + 1;
	}
}

const array<mframe_t> berserk_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_pain1 = mmove_t(berserk::frames::painc1, berserk::frames::painc4, berserk_frames_pain1, berserk_run);

const array<mframe_t> berserk_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t berserk_move_pain2 = mmove_t(berserk::frames::painb1, berserk::frames::painb20, berserk_frames_pain2, berserk_run);

void berserk_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	// if we're jumping, don't pain
	if ((self.monsterinfo.active_move is berserk_move_jump) ||
		(self.monsterinfo.active_move is berserk_move_jump2) ||
		(self.monsterinfo.active_move is berserk_move_attack_strike))
	{
		return;
	}

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);
	gi_sound(self.e, soundchan_t::VOICE, berserk::sounds::pain, 1, ATTN_NORM, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	monster_done_dodge(self);

	if ((damage <= 50) || (frandom() < 0.5f))
		M_SetAnimation(self, berserk_move_pain1);
	else
		M_SetAnimation(self, berserk_move_pain2);
}

void berserk_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void berserk_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void berserk_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> berserk_frames_death1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, berserk_shrink),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_death1 = mmove_t(berserk::frames::death1, berserk::frames::death13, berserk_frames_death1, berserk_dead);

const array<mframe_t> berserk_frames_death2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, berserk_shrink),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_death2 = mmove_t(berserk::frames::deathc1, berserk::frames::deathc8, berserk_frames_death2, berserk_dead);

void berserk_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum = 0;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(3, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(1, "models/objects/gibs/gear/tris.md2"),
			gib_def_t("models/monsters/berserk/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/berserk/gibs/hammer.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/berserk/gibs/thigh.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/berserk/gibs/head.md2", gib_type_t(gib_type_t::HEAD | gib_type_t::SKINNED))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	gi_sound(self.e, soundchan_t::VOICE, berserk::sounds::die, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	if (damage >= 50)
		M_SetAnimation(self, berserk_move_death1);
	else
		M_SetAnimation(self, berserk_move_death2);
}

//===========
// PGM
void berserk_jump_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void berserk_jump2_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 150);
	self.velocity += (up * 400);
}

void berserk_jump_wait_land(ASEntity &self)
{
	if (self.groundentity is null)
	{
		self.monsterinfo.nextframe = self.e.s.frame;

		if (monster_jump_finished(self))
			self.monsterinfo.nextframe = self.e.s.frame + 1;
	}
	else
		self.monsterinfo.nextframe = self.e.s.frame + 1;
}

const array<mframe_t> berserk_frames_jump = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, berserk_jump_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, berserk_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_jump = mmove_t(berserk::frames::jump1, berserk::frames::jump9, berserk_frames_jump, berserk_run);

const array<mframe_t> berserk_frames_jump2 = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, 0, berserk_jump2_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, berserk_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_jump2 = mmove_t(berserk::frames::jump1, berserk::frames::jump9, berserk_frames_jump2, berserk_run);

void berserk_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, berserk_move_jump2);
	else
		M_SetAnimation(self, berserk_move_jump);
}

bool berserk_blocked(ASEntity &self, float dist)
{
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			berserk_jump(self, result);

		return true;
	}

	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

bool berserk_sidestep(ASEntity &self)
{
	// if we're jumping or in long pain, don't dodge
	if ((self.monsterinfo.active_move is berserk_move_jump) ||
		(self.monsterinfo.active_move is berserk_move_jump2) ||
		(self.monsterinfo.active_move is berserk_move_attack_strike) ||
		(self.monsterinfo.active_move is berserk_move_pain2))
		return false;

	if (self.monsterinfo.active_move !is berserk_move_run1)
		M_SetAnimation(self, berserk_move_run1);

	return true;
}

const array<mframe_t> berserk_frames_duck = {
	mframe_t(ai_move, 0, monster_duck_down),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_duck_hold),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_duck_up),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t berserk_move_duck = mmove_t(berserk::frames::duck1, berserk::frames::duck10, berserk_frames_duck, berserk_run);

const array<mframe_t> berserk_frames_duck2 = {
	mframe_t(ai_move, 21, monster_duck_down),
	mframe_t(ai_move, 28),
	mframe_t(ai_move, 20),
	mframe_t(ai_move, 12, monster_footstep),
	mframe_t(ai_move, 7),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_duck_hold),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, 0, monster_duck_up),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
};
const mmove_t berserk_move_duck2 = mmove_t(berserk::frames::fall2, berserk::frames::fall18, berserk_frames_duck2, berserk_run);

bool berserk_duck(ASEntity &self, gtime_t eta)
{
	// berserk only dives forward, and very rarely
	if (frandom() >= 0.05f)
	{
		return false;
	}

	// if we're jumping, don't dodge
	if ((self.monsterinfo.active_move is berserk_move_jump) ||
		(self.monsterinfo.active_move is berserk_move_jump2))
	{
		return false;
	}

	M_SetAnimation(self, berserk_move_duck2);

	return true;
}

/*QUAKED monster_berserk (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_berserk(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	// pre-caches
	berserk::sounds::pain.precache();
	berserk::sounds::die.precache();
	berserk::sounds::idle.precache();
	berserk::sounds::idle2.precache();
	berserk::sounds::punch.precache();
	berserk::sounds::search.precache();
	berserk::sounds::sight.precache();
	berserk::sounds::thud.precache();
	berserk::sounds::explod.precache();
	berserk::sounds::jump.precache();

	self.e.s.modelindex = gi_modelindex("models/monsters/berserk/tris.md2");
	
	gi_modelindex("models/monsters/berserk/gibs/head.md2");
	gi_modelindex("models/monsters/berserk/gibs/chest.md2");
	gi_modelindex("models/monsters/berserk/gibs/hammer.md2");
	gi_modelindex("models/monsters/berserk/gibs/thigh.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(240 * st.health_multiplier);
	self.gib_health = -60;
	self.mass = 250;

	@self.pain = berserk_pain;
	@self.die = berserk_die;

	@self.monsterinfo.stand = berserk_stand;
	@self.monsterinfo.walk = berserk_walk;
	@self.monsterinfo.run = berserk_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = berserk_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = berserk_sidestep;
	@self.monsterinfo.blocked = berserk_blocked; // PGM
	// pmm
	@self.monsterinfo.attack = berserk_attack;
	@self.monsterinfo.melee = berserk_melee;
	@self.monsterinfo.sight = berserk_sight;
	@self.monsterinfo.search = berserk_search;
	@self.monsterinfo.setskin = berserk_setskin;

	M_SetAnimation(self, berserk_move_stand);
	self.monsterinfo.scale = berserk::SCALE;

	self.monsterinfo.combat_style = combat_style_t::MELEE;
	self.monsterinfo.can_jump = (self.spawnflags & spawnflags::berserk::NOJUMPING) == 0;
	self.monsterinfo.drop_height = 256;
	self.monsterinfo.jump_height = 40;

	gi_linkentity(self.e);

	walkmonster_start(self);
}
