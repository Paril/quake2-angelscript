// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

floater

==============================================================================
*/

namespace floater
{
    enum frames
    {
        actvat01,
        actvat02,
        actvat03,
        actvat04,
        actvat05,
        actvat06,
        actvat07,
        actvat08,
        actvat09,
        actvat10,
        actvat11,
        actvat12,
        actvat13,
        actvat14,
        actvat15,
        actvat16,
        actvat17,
        actvat18,
        actvat19,
        actvat20,
        actvat21,
        actvat22,
        actvat23,
        actvat24,
        actvat25,
        actvat26,
        actvat27,
        actvat28,
        actvat29,
        actvat30,
        actvat31,
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
        pain101,
        pain102,
        pain103,
        pain104,
        pain105,
        pain106,
        pain107,
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
        pain307,
        pain308,
        pain309,
        pain310,
        pain311,
        pain312,
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
        stand231,
        stand232,
        stand233,
        stand234,
        stand235,
        stand236,
        stand237,
        stand238,
        stand239,
        stand240,
        stand241,
        stand242,
        stand243,
        stand244,
        stand245,
        stand246,
        stand247,
        stand248,
        stand249,
        stand250,
        stand251,
        stand252
    };

    const float SCALE = 1.000000f;
}

namespace floater::sounds
{
    cached_soundindex attack2("floater/fltatck2.wav");
    cached_soundindex attack3("floater/fltatck3.wav");
    cached_soundindex death1("floater/fltdeth1.wav");
    cached_soundindex idle("floater/fltidle1.wav");
    cached_soundindex pain1("floater/fltpain1.wav");
    cached_soundindex pain2("floater/fltpain2.wav");
    cached_soundindex sight("floater/fltsght1.wav");
}

void floater_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, floater::sounds::sight, 1, ATTN_NORM, 0);
}

void floater_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, floater::sounds::idle, 1, ATTN_IDLE, 0);
}

void floater_fire_blaster(ASEntity &self)
{
	vec3_t	  start;
	vec3_t	  forward, right;
	vec3_t	  end;
	vec3_t	  dir;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::FLOAT_BLASTER_1], forward, right);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	monster_fire_blaster(self, start, dir, 1, 1000, monster_muzzle_t::FLOAT_BLASTER_1, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::HYPERBLASTER);
}

const array<mframe_t> floater_frames_stand1 = {
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
const mmove_t floater_move_stand1 = mmove_t(floater::frames::stand101, floater::frames::stand152, floater_frames_stand1, null);

const array<mframe_t> floater_frames_stand2 = {
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
const mmove_t floater_move_stand2 = mmove_t(floater::frames::stand201, floater::frames::stand252, floater_frames_stand2, null);

const array<mframe_t> floater_frames_pop = {
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t(),
	mframe_t()
};
const mmove_t floater_move_pop = mmove_t(floater::frames::actvat05, floater::frames::actvat31, floater_frames_pop, floater_run);

const array<mframe_t> floater_frames_disguise = {
	mframe_t(ai_stand)
};
const mmove_t floater_move_disguise = mmove_t(floater::frames::actvat01, floater::frames::actvat01, floater_frames_disguise, null);

void floater_stand(ASEntity &self)
{
	if (self.monsterinfo.active_move is floater_move_disguise)
		M_SetAnimation(self, floater_move_disguise);
	else if (frandom() <= 0.5f)
		M_SetAnimation(self, floater_move_stand1);
	else
		M_SetAnimation(self, floater_move_stand2);
}

const array<mframe_t> floater_frames_attack1 = {
	mframe_t(ai_charge), // Blaster attack
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, floater_fire_blaster), // BOOM (0, -25.8, 32.5)	-- LOOP Starts
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge, 0, floater_fire_blaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge) //							-- LOOP Ends
};
const mmove_t floater_move_attack1 = mmove_t(floater::frames::attak101, floater::frames::attak114, floater_frames_attack1, floater_run);

// PMM - circle strafe frames
const array<mframe_t> floater_frames_attack1a = {
	mframe_t(ai_charge, 10), // Blaster attack
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10, floater_fire_blaster), // BOOM (0, -25.8, 32.5)	-- LOOP Starts
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10, floater_fire_blaster),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10) //							-- LOOP Ends
};
const mmove_t floater_move_attack1a = mmove_t(floater::frames::attak101, floater::frames::attak114, floater_frames_attack1a, floater_run);
// pmm

const array<mframe_t> floater_frames_attack2 = {
	mframe_t(ai_charge), // Claws
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, floater_wham), // WHAM (0, -45, 29.6)		-- LOOP Starts
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge), //							-- LOOP Ends
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t floater_move_attack2 = mmove_t(floater::frames::attak201, floater::frames::attak225, floater_frames_attack2, floater_run);

const array<mframe_t> floater_frames_attack3 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, floater_zap), //								-- LOOP Starts
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge), //								-- LOOP Ends
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t floater_move_attack3 = mmove_t(floater::frames::attak301, floater::frames::attak334, floater_frames_attack3, floater_run);

/*
const array<mframe_t> floater_frames_death = {
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
const mmove_t floater_move_death = mmove_t(floater::frames::death01, floater::frames::death13, floater_frames_death, floater_dead);
*/

const array<mframe_t> floater_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t floater_move_pain1 = mmove_t(floater::frames::pain101, floater::frames::pain107, floater_frames_pain1, floater_run);

const array<mframe_t> floater_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t floater_move_pain2 = mmove_t(floater::frames::pain201, floater::frames::pain208, floater_frames_pain2, floater_run);

/*
const array<mframe_t> floater_frames_pain3 = {
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
const mmove_t floater_move_pain3 = mmove_t(floater::frames::pain301, floater::frames::pain312, floater_frames_pain3, floater_run);
*/

const array<mframe_t> floater_frames_walk = {
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
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5)
};
const mmove_t floater_move_walk = mmove_t(floater::frames::stand101, floater::frames::stand152, floater_frames_walk, null);

const array<mframe_t> floater_frames_run = {
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 13)
};
const mmove_t floater_move_run = mmove_t(floater::frames::stand101, floater::frames::stand152, floater_frames_run, null);

void floater_run(ASEntity &self)
{
	if (self.monsterinfo.active_move is floater_move_disguise)
		M_SetAnimation(self, floater_move_pop);
	else if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, floater_move_stand1);
	else
		M_SetAnimation(self, floater_move_run);
}

void floater_walk(ASEntity &self)
{
	M_SetAnimation(self, floater_move_walk);
}

void floater_wham(ASEntity &self)
{
	const vec3_t aim = { MELEE_DISTANCE, 0, 0 };
	gi_sound(self.e, soundchan_t::WEAPON, floater::sounds::attack3, 1, ATTN_NORM, 0);

	if (!fire_hit(self, aim, irandom(5, 11), -50))
		self.monsterinfo.melee_debounce_time = level.time + time_sec(3);
}

void floater_zap(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t origin;
	vec3_t dir;
	vec3_t offset;

	dir = self.enemy.e.s.origin - self.e.s.origin;

	AngleVectors(self.e.s.angles, forward, right);
	// FIXME use a flash and replace these two lines with the commented one
	offset = { 18.5f, -0.9f, 10 };
	origin = M_ProjectFlashSource(self, offset, forward, right);

	gi_sound(self.e, soundchan_t::WEAPON, floater::sounds::attack2, 1, ATTN_NORM, 0);

	// FIXME use the flash, Luke
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::SPLASH);
	gi_WriteByte(32);
	gi_WritePosition(origin);
	gi_WriteDir(dir);
	gi_WriteByte(splash_color_t::SPARKS);
	gi_multicast(origin, multicast_t::PVS, false);

	T_Damage(self.enemy, self, self, dir, self.enemy.e.s.origin, vec3_origin, irandom(5, 11), -10, damageflags_t::ENERGY, mod_id_t::UNKNOWN);
}

void floater_attack(ASEntity &self)
{
	float chance = 0.5f;

	if (frandom() > chance)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		M_SetAnimation(self, floater_move_attack1);
	}
	else // circle strafe
	{
		if (frandom() <= 0.5f) // switch directions
			self.monsterinfo.lefty = !self.monsterinfo.lefty;
		self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
		M_SetAnimation(self, floater_move_attack1a);
	}
}

void floater_melee(ASEntity &self)
{
	if (frandom() < 0.5f)
		M_SetAnimation(self, floater_move_attack3);
	else
		M_SetAnimation(self, floater_move_attack2);
}

void floater_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	int n;

	if (level.time < self.pain_debounce_time)
		return;

	// no pain anims if poppin'
	if (self.monsterinfo.active_move is floater_move_disguise ||
		self.monsterinfo.active_move is floater_move_pop)
		return;

	n = irandom(3);
	if (n == 0)
		gi_sound(self.e, soundchan_t::VOICE, floater::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, floater::sounds::pain2, 1, ATTN_NORM, 0);

	self.pain_debounce_time = level.time + time_sec(3);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (n == 0)
		M_SetAnimation(self, floater_move_pain1);
	else
		M_SetAnimation(self, floater_move_pain2);
}

void floater_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void floater_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.nextthink = time_zero;
	gi_linkentity(self.e);
}

void floater_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_sound(self.e, soundchan_t::VOICE, floater::sounds::death1, 1, ATTN_NORM, 0);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.skinnum /= 2;

	ThrowGibs(self, 55, {
		gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2"),
		gib_def_t(3, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t("models/monsters/float/gibs/piece.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/float/gibs/gun.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/float/gibs/base.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/float/gibs/jar.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
	});
}

void float_set_fly_parameters(ASEntity &self)
{
	self.monsterinfo.fly_thrusters = false;
	self.monsterinfo.fly_acceleration = 10.f;
	self.monsterinfo.fly_speed = 100.f;
	// Technician gets in closer because he has two melee attacks
	self.monsterinfo.fly_min_distance = 20.f;
	self.monsterinfo.fly_max_distance = 200.f;
}

namespace spawnflags::floater
{
    const spawnflags_t DISGUISE = spawnflag_dec(8);
}

/*QUAKED monster_floater (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight Disguise
 */
void SP_monster_floater(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	floater::sounds::attack2.precache();
	floater::sounds::attack3.precache();
	floater::sounds::death1.precache();
	floater::sounds::idle.precache();
	floater::sounds::pain1.precache();
	floater::sounds::pain2.precache();
	floater::sounds::sight.precache();

	gi_soundindex("floater/fltatck1.wav");

	self.monsterinfo.engine_sound = gi_soundindex("floater/fltsrch1.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/float/tris.md2");

	gi_modelindex("models/monsters/float/gibs/base.md2");
	gi_modelindex("models/monsters/float/gibs/gun.md2");
	gi_modelindex("models/monsters/float/gibs/jar.md2");
	gi_modelindex("models/monsters/float/gibs/piece.md2");

	self.e.mins = { -24, -24, -24 };
	self.e.maxs = { 24, 24, 48 };

	self.health = int(200 * st.health_multiplier);
	self.gib_health = -80;
	self.mass = 300;

	@self.pain = floater_pain;
	@self.die = floater_die;

	@self.monsterinfo.stand = floater_stand;
	@self.monsterinfo.walk = floater_walk;
	@self.monsterinfo.run = floater_run;
	@self.monsterinfo.attack = floater_attack;
	@self.monsterinfo.melee = floater_melee;
	@self.monsterinfo.sight = floater_sight;
	@self.monsterinfo.idle = floater_idle;
	@self.monsterinfo.setskin = floater_setskin;

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::floater::DISGUISE))
		M_SetAnimation(self, floater_move_disguise);
	else if (frandom() <= 0.5f)
		M_SetAnimation(self, floater_move_stand1);
	else
		M_SetAnimation(self, floater_move_stand2);

	self.monsterinfo.scale = floater::SCALE;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	float_set_fly_parameters(self);

	flymonster_start(self);
}
