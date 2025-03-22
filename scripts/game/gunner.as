// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

GUNNER

==============================================================================
*/

namespace gunner
{
	enum frames {
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
		stand60,
		stand61,
		stand62,
		stand63,
		stand64,
		stand65,
		stand66,
		stand67,
		stand68,
		stand69,
		stand70,
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
		run01,
		run02,
		run03,
		run04,
		run05,
		run06,
		run07,
		run08,
		runs01,
		runs02,
		runs03,
		runs04,
		runs05,
		runs06,
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
		duck01,
		duck02,
		duck03,
		duck04,
		duck05,
		duck06,
		duck07,
		duck08,
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
		shield01,
		shield02,
		shield03,
		shield04,
		shield05,
		shield06,
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
		c_stand101,
		c_stand102,
		c_stand103,
		c_stand104,
		c_stand105,
		c_stand106,
		c_stand107,
		c_stand108,
		c_stand109,
		c_stand110,
		c_stand111,
		c_stand112,
		c_stand113,
		c_stand114,
		c_stand115,
		c_stand116,
		c_stand117,
		c_stand118,
		c_stand119,
		c_stand120,
		c_stand121,
		c_stand122,
		c_stand123,
		c_stand124,
		c_stand125,
		c_stand126,
		c_stand127,
		c_stand128,
		c_stand129,
		c_stand130,
		c_stand131,
		c_stand132,
		c_stand133,
		c_stand134,
		c_stand135,
		c_stand136,
		c_stand137,
		c_stand138,
		c_stand139,
		c_stand140,
		c_stand201,
		c_stand202,
		c_stand203,
		c_stand204,
		c_stand205,
		c_stand206,
		c_stand207,
		c_stand208,
		c_stand209,
		c_stand210,
		c_stand211,
		c_stand212,
		c_stand213,
		c_stand214,
		c_stand215,
		c_stand216,
		c_stand217,
		c_stand218,
		c_stand219,
		c_stand220,
		c_stand221,
		c_stand222,
		c_stand223,
		c_stand224,
		c_stand225,
		c_stand226,
		c_stand227,
		c_stand228,
		c_stand229,
		c_stand230,
		c_stand231,
		c_stand232,
		c_stand233,
		c_stand234,
		c_stand235,
		c_stand236,
		c_stand237,
		c_stand238,
		c_stand239,
		c_stand240,
		c_stand241,
		c_stand242,
		c_stand243,
		c_stand244,
		c_stand245,
		c_stand246,
		c_stand247,
		c_stand248,
		c_stand249,
		c_stand250,
		c_stand251,
		c_stand252,
		c_stand253,
		c_stand254,
		c_attack101,
		c_attack102,
		c_attack103,
		c_attack104,
		c_attack105,
		c_attack106,
		c_attack107,
		c_attack108,
		c_attack109,
		c_attack110,
		c_attack111,
		c_attack112,
		c_attack113,
		c_attack114,
		c_attack115,
		c_attack116,
		c_attack117,
		c_attack118,
		c_attack119,
		c_attack120,
		c_attack121,
		c_attack122,
		c_attack123,
		c_attack124,
		c_jump01,
		c_jump02,
		c_jump03,
		c_jump04,
		c_jump05,
		c_jump06,
		c_jump07,
		c_jump08,
		c_jump09,
		c_jump10,
		c_attack201,
		c_attack202,
		c_attack203,
		c_attack204,
		c_attack205,
		c_attack206,
		c_attack207,
		c_attack208,
		c_attack209,
		c_attack210,
		c_attack211,
		c_attack212,
		c_attack213,
		c_attack214,
		c_attack215,
		c_attack216,
		c_attack217,
		c_attack218,
		c_attack219,
		c_attack220,
		c_attack221,
		c_attack301,
		c_attack302,
		c_attack303,
		c_attack304,
		c_attack305,
		c_attack306,
		c_attack307,
		c_attack308,
		c_attack309,
		c_attack310,
		c_attack311,
		c_attack312,
		c_attack313,
		c_attack314,
		c_attack315,
		c_attack316,
		c_attack317,
		c_attack318,
		c_attack319,
		c_attack320,
		c_attack321,
		c_attack401,
		c_attack402,
		c_attack403,
		c_attack404,
		c_attack405,
		c_attack501,
		c_attack502,
		c_attack503,
		c_attack504,
		c_attack505,
		c_attack601,
		c_attack602,
		c_attack603,
		c_attack604,
		c_attack605,
		c_attack701,
		c_attack702,
		c_attack703,
		c_attack704,
		c_attack705,
		c_pain101,
		c_pain102,
		c_pain103,
		c_pain104,
		c_pain201,
		c_pain202,
		c_pain203,
		c_pain204,
		c_pain301,
		c_pain302,
		c_pain303,
		c_pain304,
		c_pain401,
		c_pain402,
		c_pain403,
		c_pain404,
		c_pain405,
		c_pain406,
		c_pain407,
		c_pain408,
		c_pain409,
		c_pain410,
		c_pain411,
		c_pain412,
		c_pain413,
		c_pain414,
		c_pain415,
		c_pain501,
		c_pain502,
		c_pain503,
		c_pain504,
		c_pain505,
		c_pain506,
		c_pain507,
		c_pain508,
		c_pain509,
		c_pain510,
		c_pain511,
		c_pain512,
		c_pain513,
		c_pain514,
		c_pain515,
		c_pain516,
		c_pain517,
		c_pain518,
		c_pain519,
		c_pain520,
		c_pain521,
		c_pain522,
		c_pain523,
		c_pain524,
		c_death101,
		c_death102,
		c_death103,
		c_death104,
		c_death105,
		c_death106,
		c_death107,
		c_death108,
		c_death109,
		c_death110,
		c_death111,
		c_death112,
		c_death113,
		c_death114,
		c_death115,
		c_death116,
		c_death117,
		c_death118,
		c_death201,
		c_death202,
		c_death203,
		c_death204,
		c_death301,
		c_death302,
		c_death303,
		c_death304,
		c_death305,
		c_death306,
		c_death307,
		c_death308,
		c_death309,
		c_death310,
		c_death311,
		c_death312,
		c_death313,
		c_death314,
		c_death315,
		c_death316,
		c_death317,
		c_death318,
		c_death319,
		c_death320,
		c_death321,
		c_death401,
		c_death402,
		c_death403,
		c_death404,
		c_death405,
		c_death406,
		c_death407,
		c_death408,
		c_death409,
		c_death410,
		c_death411,
		c_death412,
		c_death413,
		c_death414,
		c_death415,
		c_death416,
		c_death417,
		c_death418,
		c_death419,
		c_death420,
		c_death421,
		c_death422,
		c_death423,
		c_death424,
		c_death425,
		c_death426,
		c_death427,
		c_death428,
		c_death429,
		c_death430,
		c_death431,
		c_death432,
		c_death433,
		c_death434,
		c_death435,
		c_death436,
		c_death501,
		c_death502,
		c_death503,
		c_death504,
		c_death505,
		c_death506,
		c_death507,
		c_death508,
		c_death509,
		c_death510,
		c_death511,
		c_death512,
		c_death513,
		c_death514,
		c_death515,
		c_death516,
		c_death517,
		c_death518,
		c_death519,
		c_death520,
		c_death521,
		c_death522,
		c_death523,
		c_death524,
		c_death525,
		c_death526,
		c_death527,
		c_death528,
		c_run101,
		c_run102,
		c_run103,
		c_run104,
		c_run105,
		c_run106,
		c_run201,
		c_run202,
		c_run203,
		c_run204,
		c_run205,
		c_run206,
		c_run301,
		c_run302,
		c_run303,
		c_run304,
		c_run305,
		c_run306,
		c_walk101,
		c_walk102,
		c_walk103,
		c_walk104,
		c_walk105,
		c_walk106,
		c_walk107,
		c_walk108,
		c_walk109,
		c_walk110,
		c_walk111,
		c_walk112,
		c_walk113,
		c_walk114,
		c_walk115,
		c_walk116,
		c_walk117,
		c_walk118,
		c_walk119,
		c_walk120,
		c_walk121,
		c_walk122,
		c_walk123,
		c_walk124,
		c_pain601,
		c_pain602,
		c_pain603,
		c_pain604,
		c_pain605,
		c_pain606,
		c_pain607,
		c_pain608,
		c_pain609,
		c_pain610,
		c_pain611,
		c_pain612,
		c_pain613,
		c_pain614,
		c_pain615,
		c_pain616,
		c_pain617,
		c_pain618,
		c_pain619,
		c_pain620,
		c_pain621,
		c_pain622,
		c_pain623,
		c_pain624,
		c_pain625,
		c_pain626,
		c_pain627,
		c_pain628,
		c_pain629,
		c_pain630,
		c_pain631,
		c_pain632,
		c_death601,
		c_death602,
		c_death603,
		c_death604,
		c_death605,
		c_death606,
		c_death607,
		c_death608,
		c_death609,
		c_death610,
		c_death611,
		c_death612,
		c_death613,
		c_death614,
		c_death701,
		c_death702,
		c_death703,
		c_death704,
		c_death705,
		c_death706,
		c_death707,
		c_death708,
		c_death709,
		c_death710,
		c_death711,
		c_death712,
		c_death713,
		c_death714,
		c_death715,
		c_death716,
		c_death717,
		c_death718,
		c_death719,
		c_death720,
		c_death721,
		c_death722,
		c_death723,
		c_death724,
		c_death725,
		c_death726,
		c_death727,
		c_death728,
		c_death729,
		c_death730,
		c_pain701,
		c_pain702,
		c_pain703,
		c_pain704,
		c_pain705,
		c_pain706,
		c_pain707,
		c_pain708,
		c_pain709,
		c_pain710,
		c_pain711,
		c_pain712,
		c_pain713,
		c_pain714,
		c_attack801,
		c_attack802,
		c_attack803,
		c_attack804,
		c_attack805,
		c_attack806,
		c_attack807,
		c_attack808,
		c_attack809,
		c_attack901,
		c_attack902,
		c_attack903,
		c_attack904,
		c_attack905,
		c_attack906,
		c_attack907,
		c_attack908,
		c_attack909,
		c_attack910,
		c_attack911,
		c_attack912,
		c_attack913,
		c_attack914,
		c_attack915,
		c_attack916,
		c_attack917,
		c_attack918,
		c_attack919,
		c_duck01,
		c_duck02,
		c_duckstep01,
		c_duckstep02,
		c_duckstep03,
		c_duckstep04,
		c_duckstep05,
		c_duckstep06,
		c_duckpain01,
		c_duckpain02,
		c_duckpain03,
		c_duckpain04,
		c_duckpain05,
		c_duckdeath01,
		c_duckdeath02,
		c_duckdeath03,
		c_duckdeath04,
		c_duckdeath05,
		c_duckdeath06,
		c_duckdeath07,
		c_duckdeath08,
		c_duckdeath09,
		c_duckdeath10,
		c_duckdeath11,
		c_duckdeath12,
		c_duckdeath13,
		c_duckdeath14,
		c_duckdeath15,
		c_duckdeath16,
		c_duckdeath17,
		c_duckdeath18,
		c_duckdeath19,
		c_duckdeath20,
		c_duckdeath21,
		c_duckdeath22,
		c_duckdeath23,
		c_duckdeath24,
		c_duckdeath25,
		c_duckdeath26,
		c_duckdeath27,
		c_duckdeath28,
		c_duckdeath29
	};

	const float SCALE		= 1.150000f;
}

namespace gunner::sounds
{
	cached_soundindex pain("gunner/gunpain2.wav");
	cached_soundindex pain2("gunner/gunpain1.wav");
	cached_soundindex death("gunner/death1.wav");
	cached_soundindex idle("gunner/gunidle1.wav");
	cached_soundindex open("gunner/gunatck1.wav");
	cached_soundindex search("gunner/gunsrch1.wav");
	cached_soundindex sight("gunner/sight1.wav");
}

void gunner_idlesound(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::idle, 1, ATTN_IDLE, 0);
}

void gunner_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::sight, 1, ATTN_NORM, 0);
}

void gunner_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::search, 1, ATTN_NORM, 0);
}

const array<mframe_t> gunner_frames_fidget = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, gunner_idlesound),
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
const mmove_t gunner_move_fidget = mmove_t(gunner::frames::stand31, gunner::frames::stand70, gunner_frames_fidget, gunner_stand);

void gunner_fidget(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		return;
	else if (self.enemy !is null)
		return;
	if (frandom() <= 0.05f)
		M_SetAnimation(self, gunner_move_fidget);
}

const array<mframe_t> gunner_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, gunner_fidget),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, gunner_fidget),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, gunner_fidget)
};
const mmove_t gunner_move_stand = mmove_t(gunner::frames::stand01, gunner::frames::stand30, gunner_frames_stand, null);

void gunner_stand(ASEntity &self)
{
	M_SetAnimation(self, gunner_move_stand);
}

const array<mframe_t> gunner_frames_walk = {
	mframe_t(ai_walk),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 2, monster_footstep),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 4, monster_footstep)
};
const mmove_t gunner_move_walk = mmove_t(gunner::frames::walk07, gunner::frames::walk19, gunner_frames_walk, null);

void gunner_walk(ASEntity &self)
{
	M_SetAnimation(self, gunner_move_walk);
}

const array<mframe_t> gunner_frames_run = {
	mframe_t(ai_run, 26),
	mframe_t(ai_run, 9, monster_footstep),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 9, monster_done_dodge),
	mframe_t(ai_run, 15),
	mframe_t(ai_run, 10, monster_footstep),
	mframe_t(ai_run, 13),
	mframe_t(ai_run, 6)
};

const mmove_t gunner_move_run = mmove_t(gunner::frames::run01, gunner::frames::run08, gunner_frames_run, null);

void gunner_run(ASEntity &self)
{
	monster_done_dodge(self);
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, gunner_move_stand);
	else
		M_SetAnimation(self, gunner_move_run);
}

const array<mframe_t> gunner_frames_runandshoot = {
	mframe_t(ai_run, 32),
	mframe_t(ai_run, 15),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 20)
};

const mmove_t gunner_move_runandshoot = mmove_t(gunner::frames::runs01, gunner::frames::runs06, gunner_frames_runandshoot, null);

void gunner_runandshoot(ASEntity &self)
{
	M_SetAnimation(self, gunner_move_runandshoot);
}

const array<mframe_t> gunner_frames_pain3 = {
	mframe_t(ai_move, -3),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move),
	mframe_t(ai_move, 1)
};
const mmove_t gunner_move_pain3 = mmove_t(gunner::frames::pain301, gunner::frames::pain305, gunner_frames_pain3, gunner_run);

const array<mframe_t> gunner_frames_pain2 = {
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 11),
	mframe_t(ai_move, 6, monster_footstep),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -7),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -7, monster_footstep)
};
const mmove_t gunner_move_pain2 = mmove_t(gunner::frames::pain201, gunner::frames::pain208, gunner_frames_pain2, gunner_run);

const array<mframe_t> gunner_frames_pain1 = {
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, -1, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 1, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -2),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t gunner_move_pain1 = mmove_t(gunner::frames::pain101, gunner::frames::pain118, gunner_frames_pain1, gunner_run);

void gunner_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	monster_done_dodge(self);
	
	if (self.monsterinfo.active_move is gunner_move_jump || 
		self.monsterinfo.active_move is gunner_move_jump2)
		return;

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	if (brandom())
		gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::pain, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::pain2, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (damage <= 10)
		M_SetAnimation(self, gunner_move_pain3);
	else if (damage <= 25)
		M_SetAnimation(self, gunner_move_pain2);
	else
		M_SetAnimation(self, gunner_move_pain1);

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);
}

void gunner_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void gunner_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void gunner_shrink(ASEntity &self)
{
	self.e.maxs[2] = -4;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> gunner_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move, -7, gunner_shrink),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -5),
	mframe_t(ai_move, 8),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gunner_move_death = mmove_t(gunner::frames::death01, gunner::frames::death11, gunner_frames_death, gunner_dead);

void gunner_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/monsters/gunner/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/gunner/gibs/garm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gunner/gibs/gun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gunner/gibs/foot.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/gunner/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});

		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;
	M_SetAnimation(self, gunner_move_death);
}

// PMM - changed to duck code for new dodge

const array<mframe_t> gunner_frames_duck = {
	mframe_t(ai_move, 1, monster_duck_down),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1, monster_duck_hold),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, 0, monster_duck_up),
	mframe_t(ai_move, -1)
};
const mmove_t gunner_move_duck = mmove_t(gunner::frames::duck01, gunner::frames::duck08, gunner_frames_duck, gunner_run);

// PMM - gunner dodge moved below so I know about attack sequences

void gunner_opengun(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gunner::sounds::open, 1, ATTN_IDLE, 0);
}

void GunnerFire(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right;
	vec3_t					 aim, aimpoint;
	monster_muzzle_t         flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	flash_number = monster_muzzle_t(monster_muzzle_t::GUNNER_MACHINEGUN_1 + (self.e.s.frame - gunner::frames::attak216));

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.2f, aim, aimpoint);
	monster_fire_bullet(self, start, aim, 3, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, flash_number);
}

bool gunner_grenade_check(ASEntity &self)
{
	vec3_t	dir;

	if (self.enemy is null)
		return false;

	vec3_t start;

	if (!M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNNER_GRENADE_1], start))
		return false;

	vec3_t target;

	// check for flag telling us that we're blindfiring
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		target = self.monsterinfo.blind_fire_target;
	else
		target = self.enemy.e.s.origin;

	// see if we're too close
	dir = target - start;

	if (dir.length() < 100)
		return false;

	// check to see that we can trace to the player before we start
	// tossing grenades around.
	vec3_t aim = dir.normalized();
	return M_CalculatePitchToFire(self, target, start, aim, 600, 2.5f, false);
}

void GunnerGrenade(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right, up;
	vec3_t					 aim;
	monster_muzzle_t flash_number;
	float					 spread;
	float					 pitch = 0;
	// PMM
	vec3_t target;
	bool   blindfire = false;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	// pmm
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		blindfire = true;

	if (self.e.s.frame == gunner::frames::attak105 || self.e.s.frame == gunner::frames::attak309)
	{
		spread = -0.10f;
		flash_number = monster_muzzle_t::GUNNER_GRENADE_1;
	}
	else if (self.e.s.frame == gunner::frames::attak108 || self.e.s.frame == gunner::frames::attak312)
	{
		spread = -0.05f;
		flash_number = monster_muzzle_t::GUNNER_GRENADE_2;
	}
	else if (self.e.s.frame == gunner::frames::attak111 || self.e.s.frame == gunner::frames::attak315)
	{
		spread = 0.05f;
		flash_number = monster_muzzle_t::GUNNER_GRENADE_3;
	}
	else // (self.e.s.frame == gunner::frames::attak114)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		spread = 0.10f;
		flash_number = monster_muzzle_t::GUNNER_GRENADE_4;
	}

	if (self.e.s.frame >= gunner::frames::attak301 && self.e.s.frame <= gunner::frames::attak324)
		flash_number = monster_muzzle_t(monster_muzzle_t::GUNNER_GRENADE2_1 + (monster_muzzle_t::GUNNER_GRENADE_4 - flash_number));

	//	pmm
	// if we're shooting blind and we still can't see our enemy
	if ((blindfire) && (!visible(self, self.enemy)))
	{
		// and we have a valid blind_fire_target
		if (!self.monsterinfo.blind_fire_target)
			return;

		target = self.monsterinfo.blind_fire_target;
	}
	else
		target = self.enemy.e.s.origin;
	// pmm

	AngleVectors(self.e.s.angles, forward, right, up); // PGM
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	// PGM
	if (self.enemy !is null)
	{
		float dist;

		aim = target - self.e.s.origin;
		dist = aim.length();

		// aim up if they're on the same level as me and far away.
		if ((dist > 512) && (aim[2] < 64) && (aim[2] > -64))
		{
			aim[2] += (dist - 512);
		}

		aim.normalize();
		pitch = aim[2];
		if (pitch > 0.4f)
			pitch = 0.4f;
		else if (pitch < -0.5f)
			pitch = -0.5f;
	}
	// PGM

	aim = forward + (right * spread);
	aim += (up * pitch);

	// try search for best pitch
	if (M_CalculatePitchToFire(self, target, start, aim, 600, 2.5f, false))
		monster_fire_grenade(self, start, aim, 50, 600, flash_number, (crandom_open() * 10.0f), frandom() * 10.f);
	else
		// normal shot
		monster_fire_grenade(self, start, aim, 50, 600, flash_number, (crandom_open() * 10.0f), 200.f + (crandom_open() * 10.0f));
}

const array<mframe_t> gunner_frames_attack_chain = {
	mframe_t(ai_charge, 0, gunner_opengun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t gunner_move_attack_chain = mmove_t(gunner::frames::attak209, gunner::frames::attak215, gunner_frames_attack_chain, gunner_fire_chain);

const array<mframe_t> gunner_frames_fire_chain = {
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire),
	mframe_t(ai_charge, 0, GunnerFire)
};
const mmove_t gunner_move_fire_chain = mmove_t(gunner::frames::attak216, gunner::frames::attak223, gunner_frames_fire_chain, gunner_refire_chain);

const array<mframe_t> gunner_frames_endfire_chain = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_footstep)
};
const mmove_t gunner_move_endfire_chain = mmove_t(gunner::frames::attak224, gunner::frames::attak230, gunner_frames_endfire_chain, gunner_run);

void gunner_blind_check(ASEntity &self)
{
	vec3_t aim;

	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		aim = self.monsterinfo.blind_fire_target - self.e.s.origin;
		self.ideal_yaw = vectoyaw(aim);
	}
}

const array<mframe_t> gunner_frames_attack_grenade = {
	mframe_t(ai_charge, 0, gunner_blind_check),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t gunner_move_attack_grenade = mmove_t(gunner::frames::attak101, gunner::frames::attak121, gunner_frames_attack_grenade, gunner_run);

const array<mframe_t> gunner_frames_attack_grenade2 = {
	//mframe_t(ai_charge),
	//mframe_t(ai_charge),
	//mframe_t(ai_charge),
	//mframe_t(ai_charge),

	mframe_t(ai_charge, 0, gunner_blind_check),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t gunner_move_attack_grenade2 = mmove_t(gunner::frames::attak305, gunner::frames::attak324, gunner_frames_attack_grenade2, gunner_run);

void gunner_attack(ASEntity &self)
{
	float chance, r;

	monster_done_dodge(self);

	// PMM
	if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
	{
		if (self.timestamp > level.time)
			return;

		// setup shot probabilities
		if (self.monsterinfo.blind_fire_delay < time_sec(1))
			chance = 1.0f;
		else if (self.monsterinfo.blind_fire_delay < time_sec(7.5))
			chance = 0.4f;
		else
			chance = 0.1f;

		r = frandom();

		// minimum of 4.1 seconds, plus 0-3, after the shots are done
		self.monsterinfo.blind_fire_delay += time_sec(4.1) + random_time(time_sec(3));

		// don't shoot at the origin
		if (!self.monsterinfo.blind_fire_target)
			return;

		// don't shoot if the dice say not to
		if (r > chance)
			return;

		// turn on manual steering to signal both manual steering and blindfire
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);

		if (gunner_grenade_check(self))
		{
			// if the check passes, go for the attack
			M_SetAnimation(self, brandom() ? gunner_move_attack_grenade2 : gunner_move_attack_grenade);
			self.monsterinfo.attack_finished = level.time + random_time(time_sec(2));
		}
		else
			// turn off blindfire flag
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

		self.timestamp = level.time + random_time(time_sec(2), time_sec(3));

		return;
	}
	// pmm

	// PGM - gunner needs to use his chaingun if he's being attacked by a tesla.
	if (self.bad_area !is null || self.timestamp > level.time || 
		(range_to(self, self.enemy) <= RANGE_NEAR * 0.35f && M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNNER_MACHINEGUN_1])))
	{
		M_SetAnimation(self, gunner_move_attack_chain);
	}
	else
	{
		if (self.timestamp <= level.time && frandom() <= 0.5f && gunner_grenade_check(self))
		{
			M_SetAnimation(self, brandom() ? gunner_move_attack_grenade2 : gunner_move_attack_grenade);
			self.timestamp = level.time + random_time(time_sec(2), time_sec(3));
		}
		else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNNER_MACHINEGUN_1]))
			M_SetAnimation(self, gunner_move_attack_chain);
	}
}

void gunner_fire_chain(ASEntity &self)
{
	M_SetAnimation(self, gunner_move_fire_chain);
}

void gunner_refire_chain(ASEntity &self)
{
	if (self.enemy.health > 0)
		if (visible(self, self.enemy))
			if (frandom() <= 0.5f)
			{
				M_SetAnimation(self, gunner_move_fire_chain, false);
				return;
			}
	M_SetAnimation(self, gunner_move_endfire_chain, false);
}

//===========
// PGM
void gunner_jump_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void gunner_jump2_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 150);
	self.velocity += (up * 400);
}

void gunner_jump_wait_land(ASEntity &self)
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

const array<mframe_t> gunner_frames_jump = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gunner_jump_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gunner_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gunner_move_jump = mmove_t(gunner::frames::jump01, gunner::frames::jump10, gunner_frames_jump, gunner_run);

const array<mframe_t> gunner_frames_jump2 = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, 0, gunner_jump2_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gunner_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gunner_move_jump2 = mmove_t(gunner::frames::jump01, gunner::frames::jump10, gunner_frames_jump2, gunner_run);

void gunner_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	monster_done_dodge(self);

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, gunner_move_jump2);
	else
		M_SetAnimation(self, gunner_move_jump);
}

//===========
// PGM
bool gunner_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;
	
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			gunner_jump(self, result);
		return true;
	}

	return false;
}
// PGM
//===========

// PMM - new duck code
bool gunner_duck(ASEntity &self, gtime_t eta)
{
	if ((self.monsterinfo.active_move is gunner_move_jump2) ||
		(self.monsterinfo.active_move is gunner_move_jump))
	{
		return false;
	}

	if ((self.monsterinfo.active_move is gunner_move_attack_chain) ||
		(self.monsterinfo.active_move is gunner_move_fire_chain) ||
		(self.monsterinfo.active_move is gunner_move_attack_grenade) ||
		(self.monsterinfo.active_move is gunner_move_attack_grenade2))
	{
		// if we're shooting don't dodge
		self.monsterinfo.unduck(self);
		return false;
	}

	if (frandom() > 0.5f)
		GunnerGrenade(self);

	M_SetAnimation(self, gunner_move_duck);

	return true;
}

bool gunner_sidestep(ASEntity &self)
{
	if ((self.monsterinfo.active_move is gunner_move_jump2) ||
		(self.monsterinfo.active_move is gunner_move_jump) ||
		(self.monsterinfo.active_move is gunner_move_pain1))
		return false;

	if ((self.monsterinfo.active_move is gunner_move_attack_chain) ||
		(self.monsterinfo.active_move is gunner_move_fire_chain) ||
		(self.monsterinfo.active_move is gunner_move_attack_grenade) ||
		(self.monsterinfo.active_move is gunner_move_attack_grenade2))
	{
		// if we're shooting, don't dodge
		return false;
	}

	if (self.monsterinfo.active_move !is gunner_move_run)
		M_SetAnimation(self, gunner_move_run);

	return true;
}

namespace spawnflags::gunner
{
    const spawnflags_t NOJUMPING = spawnflag_dec(8);
}

/*QUAKED monster_gunner (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight NoJumping
model="models/monsters/gunner/tris.md2"
*/
void SP_monster_gunner(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	gunner::sounds::pain.precache();
	gunner::sounds::pain2.precache();
	gunner::sounds::death.precache();
	gunner::sounds::idle.precache();
	gunner::sounds::open.precache();
	gunner::sounds::search.precache();
	gunner::sounds::sight.precache();

	gi_soundindex("gunner/gunatck2.wav");
	gi_soundindex("gunner/gunatck3.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/gunner/tris.md2");
	
	gi_modelindex("models/monsters/gunner/gibs/chest.md2");
	gi_modelindex("models/monsters/gunner/gibs/foot.md2");
	gi_modelindex("models/monsters/gunner/gibs/garm.md2");
	gi_modelindex("models/monsters/gunner/gibs/gun.md2");
	gi_modelindex("models/monsters/gunner/gibs/head.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 36 };

	self.health = int(175 * st.health_multiplier);
	self.gib_health = -70;
	self.mass = 200;

	@self.pain = gunner_pain;
	@self.die = gunner_die;

	@self.monsterinfo.stand = gunner_stand;
	@self.monsterinfo.walk = gunner_walk;
	@self.monsterinfo.run = gunner_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = gunner_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = gunner_sidestep;
	@self.monsterinfo.blocked = gunner_blocked; // PGM
	// pmm
	@self.monsterinfo.attack = gunner_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = gunner_sight;
	@self.monsterinfo.search = gunner_search;
	@self.monsterinfo.setskin = gunner_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, gunner_move_stand);
	self.monsterinfo.scale = gunner::SCALE;

	// PMM
	self.monsterinfo.blindfire = true;
	self.monsterinfo.can_jump = !self.spawnflags.has(spawnflags::gunner::NOJUMPING);
	self.monsterinfo.drop_height = 192;
	self.monsterinfo.jump_height = 40;

	walkmonster_start(self);
}
