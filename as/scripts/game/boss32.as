// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

Makron -- Final Boss

==============================================================================
*/

namespace boss32
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
        walk25,
        active01,
        active02,
        active03,
        active04,
        active05,
        active06,
        active07,
        active08,
        active09,
        active10,
        active11,
        active12,
        active13,
        attak301,
        attak302,
        attak303,
        attak304,
        attak305,
        attak306,
        attak307,
        attak308,
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
        attak501,
        attak502,
        attak503,
        attak504,
        attak505,
        attak506,
        attak507,
        attak508,
        attak509,
        attak510,
        attak511,
        attak512,
        attak513,
        attak514,
        attak515,
        attak516,
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
        death224,
        death225,
        death226,
        death227,
        death228,
        death229,
        death230,
        death231,
        death232,
        death233,
        death234,
        death235,
        death236,
        death237,
        death238,
        death239,
        death240,
        death241,
        death242,
        death243,
        death244,
        death245,
        death246,
        death247,
        death248,
        death249,
        death250,
        death251,
        death252,
        death253,
        death254,
        death255,
        death256,
        death257,
        death258,
        death259,
        death260,
        death261,
        death262,
        death263,
        death264,
        death265,
        death266,
        death267,
        death268,
        death269,
        death270,
        death271,
        death272,
        death273,
        death274,
        death275,
        death276,
        death277,
        death278,
        death279,
        death280,
        death281,
        death282,
        death283,
        death284,
        death285,
        death286,
        death287,
        death288,
        death289,
        death290,
        death291,
        death292,
        death293,
        death294,
        death295,
        death301,
        death302,
        death303,
        death304,
        death305,
        death306,
        death307,
        death308,
        death309,
        death310,
        death311,
        death312,
        death313,
        death314,
        death315,
        death316,
        death317,
        death318,
        death319,
        death320,
        jump01,
        jump02,
        jump03,
        jump04,
        jump05,
        jump06,
        jump07,
        jump08,
        jump09,
        jump10,
        jump11,
        jump12,
        jump13,
        pain401,
        pain402,
        pain403,
        pain404,
        pain501,
        pain502,
        pain503,
        pain504,
        pain601,
        pain602,
        pain603,
        pain604,
        pain605,
        pain606,
        pain607,
        pain608,
        pain609,
        pain610,
        pain611,
        pain612,
        pain613,
        pain614,
        pain615,
        pain616,
        pain617,
        pain618,
        pain619,
        pain620,
        pain621,
        pain622,
        pain623,
        pain624,
        pain625,
        pain626,
        pain627,
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
        stand252,
        stand253,
        stand254,
        stand255,
        stand256,
        stand257,
        stand258,
        stand259,
        stand260,
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
        walk217
    };

    const float SCALE = 1.000000f;
}

namespace boss32::sounds
{
    cached_soundindex pain4("makron/pain3.wav");
    cached_soundindex pain5("makron/pain2.wav");
    cached_soundindex pain6("makron/pain1.wav");
    cached_soundindex death("makron/death.wav");
    cached_soundindex step_left("makron/step1.wav");
    cached_soundindex step_right("makron/step2.wav");
    cached_soundindex attack_bfg("makron/bfg_fire.wav");
    cached_soundindex brainsplorch("makron/brain1.wav");
    cached_soundindex prerailgun("makron/rail_up.wav");
    cached_soundindex popup("makron/popup.wav");
    cached_soundindex taunt1("makron/voice4.wav");
    cached_soundindex taunt2("makron/voice3.wav");
    cached_soundindex taunt3("makron/voice.wav");
    cached_soundindex hit("makron/bhit.wav");
}

void makron_taunt(ASEntity &self)
{
	float r;

	r = frandom();
	if (r <= 0.3f)
		gi_sound(self.e, soundchan_t::AUTO, boss32::sounds::taunt1, 1, ATTN_NONE, 0);
	else if (r <= 0.6f)
		gi_sound(self.e, soundchan_t::AUTO, boss32::sounds::taunt2, 1, ATTN_NONE, 0);
	else
		gi_sound(self.e, soundchan_t::AUTO, boss32::sounds::taunt3, 1, ATTN_NONE, 0);
}

//
// stand
//

const array<mframe_t> makron_frames_stand = {
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
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand) // 60
};
const mmove_t makron_move_stand = mmove_t(boss32::frames::stand201, boss32::frames::stand260, makron_frames_stand, null);

void makron_stand(ASEntity &self)
{
	M_SetAnimation(self, makron_move_stand);
}

const array<mframe_t> makron_frames_run = {
	mframe_t(ai_run, 3, makron_step_left),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8, makron_step_right),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 6),
	mframe_t(ai_run, 12)
};
const mmove_t makron_move_run = mmove_t(boss32::frames::walk204, boss32::frames::walk213, makron_frames_run, null);

void makron_hit(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::AUTO, boss32::sounds::hit, 1, ATTN_NONE, 0);
}

void makron_popup(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss32::sounds::popup, 1, ATTN_NONE, 0);
}

void makron_step_left(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss32::sounds::step_left, 1, ATTN_NORM, 0);
}

void makron_step_right(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, boss32::sounds::step_right, 1, ATTN_NORM, 0);
}

void makron_brainsplorch(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::brainsplorch, 1, ATTN_NORM, 0);
}

void makron_prerailgun(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, boss32::sounds::prerailgun, 1, ATTN_NORM, 0);
}

const array<mframe_t> makron_frames_walk = {
	mframe_t(ai_walk, 3, makron_step_left),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 8, makron_step_right),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 12)
};
const mmove_t makron_move_walk = mmove_t(boss32::frames::walk204, boss32::frames::walk213, makron_frames_run, null);

void makron_walk(ASEntity &self)
{
	M_SetAnimation(self, makron_move_walk);
}

void makron_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, makron_move_stand);
	else
		M_SetAnimation(self, makron_move_run);
}

const array<mframe_t> makron_frames_pain6 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 10
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, makron_popup),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 20
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, makron_taunt),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_pain6 = mmove_t(boss32::frames::pain601, boss32::frames::pain627, makron_frames_pain6, makron_run);

const array<mframe_t> makron_frames_pain5 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_pain5 = mmove_t(boss32::frames::pain501, boss32::frames::pain504, makron_frames_pain5, makron_run);

const array<mframe_t> makron_frames_pain4 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_pain4 = mmove_t(boss32::frames::pain401, boss32::frames::pain404, makron_frames_pain4, makron_run);

/*
---
Makron Torso. This needs to be spawned in
---
*/

void makron_torso_think(ASEntity &self)
{
	if (++self.e.s.frame >= 365)
		self.e.s.frame = 346;
	
	self.nextthink = level.time + time_hz(10);

	if (self.e.s.angles[0] > 0)
		self.e.s.angles[0] = max(0.f, self.e.s.angles[0] - 15);
}

void makron_torso(ASEntity &ent)
{
	ent.e.s.frame = 346;
	ent.e.s.modelindex = gi_modelindex("models/monsters/boss3/rider/tris.md2");
	ent.e.s.skinnum = 1;
	@ent.think = makron_torso_think;
	ent.nextthink = level.time + time_hz(10);
	ent.e.s.sound = gi_soundindex("makron/spine.wav");
	ent.movetype = movetype_t::TOSS;
	ent.e.s.effects = effects_t::GIB;
	vec3_t forward, up;
	AngleVectors(ent.e.s.angles, forward, up: up);
	ent.velocity += (up * 120);
	ent.velocity += (forward * -120);
	ent.e.s.origin += (forward * -10);
	ent.e.s.angles[0] = 90;
	ent.avelocity = vec3_origin;
	gi_linkentity(ent.e);
}

void makron_spawn_torso(ASEntity &self)
{
	ASEntity @tempent = ThrowGib(self, "models/monsters/boss3/rider/tris.md2", 0, gib_type_t::NONE, self.e.s.scale);
	tempent.e.s.origin = self.e.s.origin;
	tempent.e.s.angles = self.e.s.angles;
	self.e.maxs[2] -= tempent.e.maxs[2];
	tempent.e.s.origin[2] += self.e.maxs[2] - 15;
	makron_torso(tempent);
}

const array<mframe_t> makron_frames_death2 = {
	mframe_t(ai_move, -15),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, -12),
	mframe_t(ai_move, 0, makron_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 10
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 11),
	mframe_t(ai_move, 12),
	mframe_t(ai_move, 11, makron_step_right),
	mframe_t(ai_move),
	mframe_t(ai_move), // 20
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 30
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, 7),
	mframe_t(ai_move, 6, makron_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, 2), // 40
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 50
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -6, makron_step_right),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4, makron_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move), // 60
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, -3, makron_step_right),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -3, makron_step_left),
	mframe_t(ai_move, -7),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4, makron_step_right), // 70
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -7),
	mframe_t(ai_move, 0, makron_step_left),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 80
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move), // 90
	mframe_t(ai_move, 27, makron_hit),
	mframe_t(ai_move, 26),
	mframe_t(ai_move, 0, makron_brainsplorch),
	mframe_t(ai_move),
	mframe_t(ai_move) // 95
};
const mmove_t makron_move_death2 = mmove_t(boss32::frames::death201, boss32::frames::death295, makron_frames_death2, makron_dead);

/*
const array<mframe_t> makron_frames_death3 = {
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
	mframe_t(ai_move)
};
const mmove_t makron_move_death3 = mmove_t(boss32::frames::death301, boss32::frames::death320, makron_frames_death3, null);
*/

const array<mframe_t> makron_frames_sight = {
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
const mmove_t makron_move_sight = mmove_t(boss32::frames::active01, boss32::frames::active13, makron_frames_sight, makron_run);

void makronBFG(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;
	vec3_t vec;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::MAKRON_BFG], forward, right);

	vec = self.enemy.e.s.origin;
	vec[2] += self.enemy.viewheight;
	dir = vec - start;
	dir.normalize();
	gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::attack_bfg, 1, ATTN_NORM, 0);
	monster_fire_bfg(self, start, dir, 50, 300, 100, 300, monster_muzzle_t::MAKRON_BFG);
}

const array<mframe_t> makron_frames_attack3 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, makronBFG),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_attack3 = mmove_t(boss32::frames::attak301, boss32::frames::attak308, makron_frames_attack3, makron_run);

const array<mframe_t> makron_frames_attack4 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move, 0, MakronHyperblaster), // fire
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_attack4 = mmove_t(boss32::frames::attak401, boss32::frames::attak426, makron_frames_attack4, makron_run);

const array<mframe_t> makron_frames_attack5 = {
	mframe_t(ai_charge, 0, makron_prerailgun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, MakronSaveloc),
	mframe_t(ai_move, 0, MakronRailgun), // Fire railgun
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t makron_move_attack5 = mmove_t(boss32::frames::attak501, boss32::frames::attak516, makron_frames_attack5, makron_run);

void MakronSaveloc(ASEntity &self)
{
	self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	self.pos1[2] += self.enemy.viewheight;
};

void MakronRailgun(ASEntity &self)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::MAKRON_RAILGUN_1], forward, right);

	// calc direction to where we targted
	dir = self.pos1 - start;
	dir.normalize();

	monster_fire_railgun(self, start, dir, 50, 100, monster_muzzle_t::MAKRON_RAILGUN_1);
}

void MakronHyperblaster(ASEntity &self)
{
	vec3_t dir;
	vec3_t vec;
	vec3_t start;
	vec3_t forward, right;

	monster_muzzle_t flash_number = monster_muzzle_t(monster_muzzle_t::MAKRON_BLASTER_1 + (self.e.s.frame - boss32::frames::attak405));

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
	if (self.e.s.frame <= boss32::frames::attak413)
		dir[1] = self.e.s.angles[1] - 10 * (self.e.s.frame - boss32::frames::attak413);
	else
		dir[1] = self.e.s.angles[1] + 10 * (self.e.s.frame - boss32::frames::attak421);
	dir[2] = 0;

	AngleVectors(dir, forward);

	monster_fire_blaster(self, start, forward, 15, 1000, flash_number, effects_t::BLASTER);
}

void makron_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (self.monsterinfo.active_move is makron_move_sight)
		return;

	if (level.time < self.pain_debounce_time)
		return;

	// Lessen the chance of him going into his pain frames
	if (mod.id != mod_id_t::CHAINFIST && damage <= 25)
		if (frandom() < 0.2f)
			return;

	self.pain_debounce_time = level.time + time_sec(3);

	bool do_pain6 = false;

	if (damage <= 40)
		gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::pain4, 1, ATTN_NONE, 0);
	else if (damage <= 110)
		gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::pain5, 1, ATTN_NONE, 0);
	else
	{
		if (damage <= 150)
		{
			if (frandom() <= 0.45f)
			{
				do_pain6 = true;
				gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::pain6, 1, ATTN_NONE, 0);
			}
		}
		else
		{
			if (frandom() <= 0.35f)
			{
				do_pain6 = true;
				gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::pain6, 1, ATTN_NONE, 0);
			}
		}
	}
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (damage <= 40)
		M_SetAnimation(self, makron_move_pain4);
	else if (damage <= 110)
		M_SetAnimation(self, makron_move_pain5);
	else if (do_pain6)
		M_SetAnimation(self, makron_move_pain6);
}

void makron_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void makron_sight(ASEntity &self, ASEntity &other)
{
	M_SetAnimation(self, makron_move_sight);
}

void makron_attack(ASEntity &self)
{
	float r;

	r = frandom();

	if (r <= 0.3f)
		M_SetAnimation(self, makron_move_attack3);
	else if (r <= 0.6f)
		M_SetAnimation(self, makron_move_attack4);
	else
		M_SetAnimation(self, makron_move_attack5);
}

//
// death
//

void makron_dead(ASEntity &self)
{
	self.e.mins = { -60, -60, 0 };
	self.e.maxs = { 60, 60, 24 };
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
	monster_dead(self);
}

void makron_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.e.s.sound = 0;

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
		ThrowGibs(self, damage, {
			gib_def_t("models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(4, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
			gib_def_t("models/objects/gibs/gear/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::HEAD))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, boss32::sounds::death, 1, ATTN_NONE, 0);
	self.deadflag = true;
	self.takedamage = true;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);

	M_SetAnimation(self, makron_move_death2);

	makron_spawn_torso(self);

	self.e.mins = { -60, -60, 0 };
	self.e.maxs = { 60, 60, 48 };
}

// [Paril-KEX] use generic function
bool Makron_CheckAttack(ASEntity &self)
{
	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.4f, 0.2f, 0.0f, 0.f);
}

//
// monster_makron
//

void MakronPrecache()
{
	boss32::sounds::pain4.precache();
	boss32::sounds::pain5.precache();
	boss32::sounds::pain6.precache();
	boss32::sounds::death.precache();
	boss32::sounds::step_left.precache();
	boss32::sounds::step_right.precache();
	boss32::sounds::attack_bfg.precache();
	boss32::sounds::brainsplorch.precache();
	boss32::sounds::prerailgun.precache();
	boss32::sounds::popup.precache();
	boss32::sounds::taunt1.precache();
	boss32::sounds::taunt2.precache();
	boss32::sounds::taunt3.precache();
	boss32::sounds::hit.precache();

	gi_modelindex("models/monsters/boss3/rider/tris.md2");
}

/*QUAKED monster_makron (1 .5 0) (-30 -30 0) (30 30 90) Ambush Trigger_Spawn Sight
 */
void SP_monster_makron(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	MakronPrecache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/boss3/rider/tris.md2");
	self.e.mins = { -30, -30, 0 };
	self.e.maxs = { 30, 30, 90 };

	self.health = int(3000 * st.health_multiplier);
	self.gib_health = -2000;
	self.mass = 500;

	@self.pain = makron_pain;
	@self.die = makron_die;
	@self.monsterinfo.stand = makron_stand;
	@self.monsterinfo.walk = makron_walk;
	@self.monsterinfo.run = makron_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = makron_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = makron_sight;
	@self.monsterinfo.checkattack = Makron_CheckAttack;
	@self.monsterinfo.setskin = makron_setskin;

	gi_linkentity(self.e);

	//	M_SetAnimation(self, makron_move_stand);
	M_SetAnimation(self, makron_move_sight);
	self.monsterinfo.scale = boss32::SCALE;

	walkmonster_start(self);

	// PMM
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);
	// pmm
}

/*
=================
MakronSpawn

=================
*/
void MakronSpawn(ASEntity &self)
{
	vec3_t	 vec;
	ASEntity @player;

	SP_monster_makron(self);
	self.think(self);

	// jump at player
	if (self.enemy !is null && self.enemy.e.inuse && self.enemy.health > 0)
		@player = self.enemy;
	else
		@player = AI_GetSightClient(self);

	if (player is null)
		return;

	vec = player.e.s.origin - self.e.s.origin;
	self.e.s.angles.yaw = vectoyaw(vec);
	vec.normalize();
	self.velocity = vec * 400;
	self.velocity[2] = 200;
	@self.groundentity = null;
	@self.enemy = player;
	FoundTarget(self);
	self.monsterinfo.sight(self, self.enemy);
	self.e.s.frame = self.monsterinfo.nextframe = boss32::frames::active01; // FIXME: why????
}

/*
=================
MakronToss

Jorg is just about dead, so set up to launch Makron out
=================
*/
void MakronToss(ASEntity &self)
{
	ASEntity @ent = G_Spawn();
	ent.classname = "monster_makron";
	ent.target = self.target;
	ent.e.s.origin = self.e.s.origin;
	@ent.enemy = self.enemy;

	MakronSpawn(ent);

	// [Paril-KEX] set health bar over to Makron when we throw him out
	for (uint i = 0; i < 2; i++)
		if (level.health_bar_entities[i] !is null && level.health_bar_entities[i].enemy is self)
			@level.health_bar_entities[i].enemy = ent;
}
