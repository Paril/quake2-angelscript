// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

brain

==============================================================================
*/

namespace brain
{
    enum frames
    {
        walk101,
        walk102,
        walk103,
        walk104,
        walk105,
        walk106,
        walk107,
        walk108,
        walk109,
        walk110,
        walk111,
        walk112,
        walk113,
        walk201,
        walk202,
        walk203,
        walk204,
        walk205,
        walk206,
        walk207,
        walk208,
        walk209,
        walk210,
        walk211,
        walk212,
        walk213,
        walk214,
        walk215,
        walk216,
        walk217,
        walk218,
        walk219,
        walk220,
        walk221,
        walk222,
        walk223,
        walk224,
        walk225,
        walk226,
        walk227,
        walk228,
        walk229,
        walk230,
        walk231,
        walk232,
        walk233,
        walk234,
        walk235,
        walk236,
        walk237,
        walk238,
        walk239,
        walk240,
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
        attak214,
        attak215,
        attak216,
        attak217,
        pain101,
        pain102,
        pain103,
        pain104,
        pain105,
        pain106,
        pain107,
        pain108,
        pain109,
        pain110,
        pain111,
        pain112,
        pain113,
        pain114,
        pain115,
        pain116,
        pain117,
        pain118,
        pain119,
        pain120,
        pain121,
        pain201,
        pain202,
        pain203,
        pain204,
        pain205,
        pain206,
        pain207,
        pain208,
        pain301,
        pain302,
        pain303,
        pain304,
        pain305,
        pain306,
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
        death201,
        death202,
        death203,
        death204,
        death205,
        duck01,
        duck02,
        duck03,
        duck04,
        duck05,
        duck06,
        duck07,
        duck08,
        defens01,
        defens02,
        defens03,
        defens04,
        defens05,
        defens06,
        defens07,
        defens08,
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
        stand52,
        stand53,
        stand54,
        stand55,
        stand56,
        stand57,
        stand58,
        stand59,
        stand60
    };

    const float SCALE = 1.000000f;
}

namespace brain::sounds
{
    cached_soundindex chest_open("brain/brnatck1.wav");
    cached_soundindex tentacles_extend("brain/brnatck2.wav");
    cached_soundindex tentacles_retract("brain/brnatck3.wav");
    cached_soundindex death("brain/brndeth1.wav");
    cached_soundindex idle1("brain/brnidle1.wav");
    cached_soundindex idle2("brain/brnidle2.wav");
    cached_soundindex idle3("brain/brnlens1.wav");
    cached_soundindex pain1("brain/brnpain1.wav");
    cached_soundindex pain2("brain/brnpain2.wav");
    cached_soundindex sight("brain/brnsght1.wav");
    cached_soundindex search("brain/brnsrch1.wav");
    cached_soundindex melee1("brain/melee1.wav");
    cached_soundindex melee2("brain/melee2.wav");
    cached_soundindex melee3("brain/melee3.wav");
}

void brain_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, brain::sounds::sight, 1, ATTN_NORM, 0);
}

void brain_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, brain::sounds::search, 1, ATTN_NORM, 0);
}

namespace spawnflags::brain
{
    const spawnflags_t NO_LASERS = spawnflag_dec(8);
}

//
// STAND
//

const array<mframe_t> brain_frames_stand = {
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
const mmove_t brain_move_stand = mmove_t(brain::frames::stand01, brain::frames::stand30, brain_frames_stand, null);

void brain_stand(ASEntity &self)
{
	M_SetAnimation(self, brain_move_stand);
}

//
// IDLE
//

const array<mframe_t> brain_frames_idle = {
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
const mmove_t brain_move_idle = mmove_t(brain::frames::stand31, brain::frames::stand60, brain_frames_idle, brain_stand);

void brain_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::AUTO, brain::sounds::idle3, 1, ATTN_IDLE, 0);
	M_SetAnimation(self, brain_move_idle);
}

//
// WALK
//
const array<mframe_t> brain_frames_walk1 = {
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 3, monster_footstep),
	mframe_t(ai_walk, 1),
	mframe_t(ai_walk),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, -4),
	mframe_t(ai_walk, -1, monster_footstep),
	mframe_t(ai_walk, 2)
};
const mmove_t brain_move_walk1 = mmove_t(brain::frames::walk101, brain::frames::walk111, brain_frames_walk1, null);

void brain_walk(ASEntity &self)
{
	M_SetAnimation(self, brain_move_walk1);
}

/*
const array<mframe_t> brain_frames_defense = {
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
const mmove_t brain_move_defense = mmove_t(brain::frames::defens01, brain::frames::defens08, brain_frames_defense, null);
*/

const array<mframe_t> brain_frames_pain3 = {
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 3),
	mframe_t(ai_move),
	mframe_t(ai_move, -4)
};
const mmove_t brain_move_pain3 = mmove_t(brain::frames::pain301, brain::frames::pain306, brain_frames_pain3, brain_run);

const array<mframe_t> brain_frames_pain2 = {
	mframe_t(ai_move, -2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, -2)
};
const mmove_t brain_move_pain2 = mmove_t(brain::frames::pain201, brain::frames::pain208, brain_frames_pain2, brain_run);

const array<mframe_t> brain_frames_pain1 = {
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -6, monster_footstep),
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
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 7),
	mframe_t(ai_move),
	mframe_t(ai_move, 3, monster_footstep),
	mframe_t(ai_move, -1)
};
const mmove_t brain_move_pain1 = mmove_t(brain::frames::pain101, brain::frames::pain121, brain_frames_pain1, brain_run);

const array<mframe_t> brain_frames_duck = {
	mframe_t(ai_move),
	mframe_t(ai_move, -2, function(self) { monster_duck_down(self); monster_footstep(self); }),
	mframe_t(ai_move, 17, monster_duck_hold),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -1, monster_duck_up),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -6, monster_footstep)
};
const mmove_t brain_move_duck = mmove_t(brain::frames::duck01, brain::frames::duck08, brain_frames_duck, brain_run);

void brain_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> brain_frames_death2 = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, 0, brain_shrink),
	mframe_t(ai_move, 9),
	mframe_t(ai_move)
};
const mmove_t brain_move_death2 = mmove_t(brain::frames::death201, brain::frames::death205, brain_frames_death2, brain_dead);

const array<mframe_t> brain_frames_death1 = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 9, function(self) { brain_shrink(self); monster_footstep(self); }),
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
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t brain_move_death1 = mmove_t(brain::frames::death101, brain::frames::death118, brain_frames_death1, brain_dead);

//
// MELEE
//

void brain_swing_right(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, brain::sounds::melee1, 1, ATTN_NORM, 0);
}

void brain_hit_right(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.maxs[0], 8 };
	if (fire_hit(self, aim, irandom(15, 20), 40))
		gi_sound(self.e, soundchan_t::WEAPON, brain::sounds::melee3, 1, ATTN_NORM, 0);
	else
		self.monsterinfo.melee_debounce_time = level.time + time_sec(3);
}

void brain_swing_left(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, brain::sounds::melee2, 1, ATTN_NORM, 0);
}

void brain_hit_left(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], 8 };
	if (fire_hit(self, aim, irandom(15, 20), 40))
		gi_sound(self.e, soundchan_t::WEAPON, brain::sounds::melee3, 1, ATTN_NORM, 0);
	else
		self.monsterinfo.melee_debounce_time = level.time + time_sec(3);
}

const array<mframe_t> brain_frames_attack1 = {
	mframe_t(ai_charge, 8),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_charge, -3, brain_swing_right),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -5),
	mframe_t(ai_charge, -7, brain_hit_right),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 6, brain_swing_left),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 2, brain_hit_left),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, -11, monster_footstep)
};
const mmove_t brain_move_attack1 = mmove_t(brain::frames::attak101, brain::frames::attak118, brain_frames_attack1, brain_run);

void brain_chest_open(ASEntity &self)
{
	self.count = 0;
	self.monsterinfo.power_armor_type = item_id_t::NULL;
	gi_sound(self.e, soundchan_t::BODY, brain::sounds::chest_open, 1, ATTN_NORM, 0);
}

void brain_tentacle_attack(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, 0, 8 };
	if (fire_hit(self, aim, irandom(10, 15), -600))
		self.count = 1;
	else
		self.monsterinfo.melee_debounce_time = level.time + time_sec(3);
	gi_sound(self.e, soundchan_t::WEAPON, brain::sounds::tentacles_retract, 1, ATTN_NORM, 0);
}

void brain_chest_closed(ASEntity &self)
{
	self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SCREEN;
	if (self.count != 0)
	{
		self.count = 0;
		M_SetAnimation(self, brain_move_attack1);
	}
}

const array<mframe_t> brain_frames_attack2 = {
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, -4),
	mframe_t(ai_charge, -4),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, 0, brain_chest_open),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 13, brain_tentacle_attack),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -9, brain_chest_closed),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, -6)
};
const mmove_t brain_move_attack2 = mmove_t(brain::frames::attak201, brain::frames::attak217, brain_frames_attack2, brain_run);

void brain_melee(ASEntity &self)
{
	if (frandom() <= 0.5f)
		M_SetAnimation(self, brain_move_attack1);
	else
		M_SetAnimation(self, brain_move_attack2);
}

// RAFAEL
bool brain_tounge_attack_ok(const vec3_t &in start, const vec3_t &in end)
{
	vec3_t dir, angles;

	// check for max distance
	dir = start - end;
	if (dir.length() > 512)
		return false;

	// check for min/max pitch
	angles = vectoangles(dir);
	if (angles[0] < -180)
		angles[0] += 360;
	if (abs(angles[0]) > 30)
		return false;

	return true;
}

void brain_tounge_attack(ASEntity &self)
{
	vec3_t	offset, start, f, r, end, dir;
	trace_t tr;
	int		damage;

	AngleVectors(self.e.s.angles, f, r);
	// offset = { 24, 0, 6 };
	offset = { 24, 0, 16 };
	start = M_ProjectFlashSource(self, offset, f, r);

	end = self.enemy.e.s.origin;
	if (!brain_tounge_attack_ok(start, end))
	{
		end[2] = self.enemy.e.s.origin[2] + self.enemy.e.maxs[2] - 8;
		if (!brain_tounge_attack_ok(start, end))
		{
			end[2] = self.enemy.e.s.origin[2] + self.enemy.e.mins[2] + 8;
			if (!brain_tounge_attack_ok(start, end))
				return;
		}
	}
	end = self.enemy.e.s.origin;

	tr = gi_traceline(start, end, self.e, contents_t::MASK_PROJECTILE);
	if (tr.ent !is self.enemy.e)
		return;

	damage = 5;
	gi_sound(self.e, soundchan_t::WEAPON, brain::sounds::tentacles_retract, 1, ATTN_NORM, 0);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::PARASITE_ATTACK);
	gi_WriteEntity(self.e);
	gi_WritePosition(start);
	gi_WritePosition(end);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	dir = start - end;
	T_Damage(self.enemy, self, self, dir, self.enemy.e.s.origin, vec3_origin, damage, 0, damageflags_t::NO_KNOCKBACK, mod_id_t::BRAINTENTACLE);

	// pull the enemy in
	vec3_t forward;
	self.e.s.origin[2] += 1;
	AngleVectors(self.e.s.angles, forward);
	self.enemy.velocity = forward * -1200;
}

// Brian right eye center
const array<vec3_t> brain_reye = {
	{ 0.746700f, 0.238370f, 34.167690f },
	{ -1.076390f, 0.238370f, 33.386372f },
	{ -1.335500f, 5.334300f, 32.177170f },
	{ -0.175360f, 8.846370f, 30.635479f },
	{ -2.757590f, 7.804610f, 30.150860f },
	{ -5.575090f, 5.152840f, 30.056160f },
	{ -7.017550f, 3.262470f, 30.552521f },
	{ -7.915740f, 0.638800f, 33.176189f },
	{ -3.915390f, 8.285730f, 33.976349f },
	{ -0.913540f, 10.933030f, 34.141811f },
	{ -0.369900f, 8.923900f, 34.189079f }
};

// Brain left eye center
const array<vec3_t> brain_leye = {
	{ -3.364710f, 0.327750f, 33.938381f },
	{ -5.140450f, 0.493480f, 32.659851f },
	{ -5.341980f, 5.646980f, 31.277901f },
	{ -4.134480f, 9.277440f, 29.925621f },
	{ -6.598340f, 6.815090f, 29.322620f },
	{ -8.610840f, 2.529650f, 29.251591f },
	{ -9.231360f, 0.093280f, 29.747959f },
	{ -11.004110f, 1.936930f, 32.395260f },
	{ -7.878310f, 7.648190f, 33.148151f },
	{ -4.947370f, 11.430050f, 33.313610f },
	{ -4.332820f, 9.444570f, 33.526340f }
};

void brain_right_eye_laser_update(ASEntity &laser)
{
	ASEntity @self = laser.owner;

	vec3_t start, forward, right, up, dir, aimpoint;

	// check for max distance
	AngleVectors(self.e.s.angles, forward, right, up);

	// dis is my right eye
	start = self.e.s.origin + (right * brain_reye[self.e.s.frame - brain::frames::walk101].x);
	start += forward * brain_reye[self.e.s.frame - brain::frames::walk101].y;
	start += up * brain_reye[self.e.s.frame - brain::frames::walk101].z;

	PredictAim(self, self.enemy, start, 0, false, frandom(0.1f, 0.2f), dir, aimpoint);

	laser.e.s.origin = start;
	laser.movedir = dir;
	gi_linkentity(laser.e);
}

void brain_left_eye_laser_update(ASEntity &laser)
{
	ASEntity @self = laser.owner;

	vec3_t start, forward, right, up, dir, aimpoint;

	// check for max distance
	AngleVectors(self.e.s.angles, forward, right, up);

	// dis is my right eye
	start = self.e.s.origin + (right * brain_leye[self.e.s.frame - brain::frames::walk101].x);
	start += forward * brain_leye[self.e.s.frame - brain::frames::walk101].y;
	start += up * brain_leye[self.e.s.frame - brain::frames::walk101].z;

	PredictAim(self, self.enemy, start, 0, false, frandom(0.1f, 0.2f), dir, aimpoint);

	laser.e.s.origin = start;
	laser.movedir = dir;
	gi_linkentity(laser.e);
	dabeam_update(laser, false);
}

void brain_laserbeam(ASEntity &self)
{
	// dis is my right eye
	monster_fire_dabeam(self, 1, false, brain_right_eye_laser_update);

	// dis is me left eye
	monster_fire_dabeam(self, 1, true, brain_left_eye_laser_update);
}

void brain_laserbeam_reattack(ASEntity &self)
{
	if (frandom() < 0.5f)
		if (visible(self, self.enemy))
			if (self.enemy.health > 0)
				self.e.s.frame = brain::frames::walk101;
}

const array<mframe_t> brain_frames_attack3 = {
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, -4),
	mframe_t(ai_charge, -4),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, 0, brain_chest_open),
	mframe_t(ai_charge, 0, brain_tounge_attack),
	mframe_t(ai_charge, 13),
	mframe_t(ai_charge, 0, brain_tentacle_attack),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 0, brain_tounge_attack),
	mframe_t(ai_charge, -9, brain_chest_closed),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, -3),
	mframe_t(ai_charge, -6)
};
const mmove_t brain_move_attack3 = mmove_t(brain::frames::attak201, brain::frames::attak217, brain_frames_attack3, brain_run);

const array<mframe_t> brain_frames_attack4 = {
	mframe_t(ai_charge, 9, brain_laserbeam),
	mframe_t(ai_charge, 2, brain_laserbeam),
	mframe_t(ai_charge, 3, brain_laserbeam),
	mframe_t(ai_charge, 3, brain_laserbeam),
	mframe_t(ai_charge, 1, brain_laserbeam),
	mframe_t(ai_charge, 0, brain_laserbeam),
	mframe_t(ai_charge, 0, brain_laserbeam),
	mframe_t(ai_charge, 10, brain_laserbeam),
	mframe_t(ai_charge, -4, brain_laserbeam),
	mframe_t(ai_charge, -1, brain_laserbeam),
	mframe_t(ai_charge, 2, brain_laserbeam_reattack)
};
const mmove_t brain_move_attack4 = mmove_t(brain::frames::walk101, brain::frames::walk111, brain_frames_attack4, brain_run);

// RAFAEL
void brain_attack(ASEntity &self)
{
	float r = range_to(self, self.enemy);
	if (r <= RANGE_NEAR)
	{
		if (frandom() < 0.5f)
			M_SetAnimation(self, brain_move_attack3);
		else if (!self.spawnflags.has(spawnflags::brain::NO_LASERS))
			M_SetAnimation(self, brain_move_attack4);
	}
	else if (!self.spawnflags.has(spawnflags::brain::NO_LASERS))
		M_SetAnimation(self, brain_move_attack4);
}
// RAFAEL

//
// RUN
//

const array<mframe_t> brain_frames_run = {
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 2),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 3),
	mframe_t(ai_run, 1),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, -4),
	mframe_t(ai_run, -1),
	mframe_t(ai_run, 2)
};
const mmove_t brain_move_run = mmove_t(brain::frames::walk101, brain::frames::walk111, brain_frames_run, null);

void brain_run(ASEntity &self)
{
	self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SCREEN;
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, brain_move_stand);
	else
		M_SetAnimation(self, brain_move_run);
}

void brain_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	float r;

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	r = frandom();

	if (r < 0.33f)
		gi_sound(self.e, soundchan_t::VOICE, brain::sounds::pain1, 1, ATTN_NORM, 0);
	else if (r < 0.66f)
		gi_sound(self.e, soundchan_t::VOICE, brain::sounds::pain2, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, brain::sounds::pain1, 1, ATTN_NORM, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (r < 0.33f)
		M_SetAnimation(self, brain_move_pain1);
	else if (r < 0.66f)
		M_SetAnimation(self, brain_move_pain2);
	else
		M_SetAnimation(self, brain_move_pain3);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);
}

void brain_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void brain_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void brain_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.e.s.effects = effects_t::NONE;
	self.monsterinfo.power_armor_type = item_id_t::NULL;

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		if (self.beam !is null)
		{
			G_FreeEdict(self.beam);
			@self.beam = null;
		}
		if (self.beam2 !is null)
		{
			G_FreeEdict(self.beam2);
			@self.beam2 = null;
		}

		ThrowGibs(self, damage, {
			gib_def_t(1, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(2, "models/monsters/brain/gibs/arm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/brain/gibs/boot.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/brain/gibs/pelvis.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/brain/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t(2, "models/monsters/brain/gibs/door.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/brain/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, brain::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;
	if (frandom() <= 0.5f)
		M_SetAnimation(self, brain_move_death1);
	else
		M_SetAnimation(self, brain_move_death2);
}

bool brain_duck(ASEntity &self, gtime_t eta)
{
	M_SetAnimation(self, brain_move_duck);

	return true;
}

/*QUAKED monster_brain (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_brain(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	brain::sounds::chest_open.precache();
	brain::sounds::tentacles_extend.precache();
	brain::sounds::tentacles_retract.precache();
	brain::sounds::death.precache();
	brain::sounds::idle1.precache();
	brain::sounds::idle2.precache();
	brain::sounds::idle3.precache();
	brain::sounds::pain1.precache();
	brain::sounds::pain2.precache();
	brain::sounds::sight.precache();
	brain::sounds::search.precache();
	brain::sounds::melee1.precache();
	brain::sounds::melee2.precache();
	brain::sounds::melee3.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/brain/tris.md2");
	
	gi_modelindex("models/monsters/brain/gibs/arm.md2");
	gi_modelindex("models/monsters/brain/gibs/boot.md2");
	gi_modelindex("models/monsters/brain/gibs/chest.md2");
	gi_modelindex("models/monsters/brain/gibs/door.md2");
	gi_modelindex("models/monsters/brain/gibs/head.md2");
	gi_modelindex("models/monsters/brain/gibs/pelvis.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };

	self.health = int(300 * st.health_multiplier);
	self.gib_health = -150;
	self.mass = 400;

	@self.pain = brain_pain;
	@self.die = brain_die;

	@self.monsterinfo.stand = brain_stand;
	@self.monsterinfo.walk = brain_walk;
	@self.monsterinfo.run = brain_run;
	// PMM
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = brain_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	// pmm
	// RAFAEL
	@self.monsterinfo.attack = brain_attack;
	// RAFAEL
	@self.monsterinfo.melee = brain_melee;
	@self.monsterinfo.sight = brain_sight;
	@self.monsterinfo.search = brain_search;
	@self.monsterinfo.idle = brain_idle;
	@self.monsterinfo.setskin = brain_setskin;
	
	if (!st.was_key_specified("power_armor_type"))
		self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SCREEN;
	if (!st.was_key_specified("power_armor_power"))
		self.monsterinfo.power_armor_power = 100;

	gi_linkentity(self.e);

	M_SetAnimation(self, brain_move_stand);
	self.monsterinfo.scale = brain::SCALE;

	walkmonster_start(self);
}
