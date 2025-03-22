// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

insane

==============================================================================
*/

namespace insane
{
    enum frames
    {
        stand1,
        stand2,
        stand3,
        stand4,
        stand5,
        stand6,
        stand7,
        stand8,
        stand9,
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
        stand71,
        stand72,
        stand73,
        stand74,
        stand75,
        stand76,
        stand77,
        stand78,
        stand79,
        stand80,
        stand81,
        stand82,
        stand83,
        stand84,
        stand85,
        stand86,
        stand87,
        stand88,
        stand89,
        stand90,
        stand91,
        stand92,
        stand93,
        stand94,
        stand95,
        stand96,
        stand97,
        stand98,
        stand99,
        stand100,
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
        walk27,
        walk28,
        walk29,
        walk30,
        walk31,
        walk32,
        walk33,
        walk34,
        walk35,
        walk36,
        walk37,
        walk38,
        walk39,
        walk1,
        walk2,
        walk3,
        walk4,
        walk5,
        walk6,
        walk7,
        walk8,
        walk9,
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
        st_pain2,
        st_pain3,
        st_pain4,
        st_pain5,
        st_pain6,
        st_pain7,
        st_pain8,
        st_pain9,
        st_pain10,
        st_pain11,
        st_pain12,
        st_death2,
        st_death3,
        st_death4,
        st_death5,
        st_death6,
        st_death7,
        st_death8,
        st_death9,
        st_death10,
        st_death11,
        st_death12,
        st_death13,
        st_death14,
        st_death15,
        st_death16,
        st_death17,
        st_death18,
        crawl1,
        crawl2,
        crawl3,
        crawl4,
        crawl5,
        crawl6,
        crawl7,
        crawl8,
        crawl9,
        cr_pain2,
        cr_pain3,
        cr_pain4,
        cr_pain5,
        cr_pain6,
        cr_pain7,
        cr_pain8,
        cr_pain9,
        cr_pain10,
        cr_death10,
        cr_death11,
        cr_death12,
        cr_death13,
        cr_death14,
        cr_death15,
        cr_death16,
        cross1,
        cross2,
        cross3,
        cross4,
        cross5,
        cross6,
        cross7,
        cross8,
        cross9,
        cross10,
        cross11,
        cross12,
        cross13,
        cross14,
        cross15,
        cross16,
        cross17,
        cross18,
        cross19,
        cross20,
        cross21,
        cross22,
        cross23,
        cross24,
        cross25,
        cross26,
        cross27,
        cross28,
        cross29,
        cross30
    };

    const float SCALE = 1.000000f;
}

namespace spawnflags::insane
{
    spawnflags_t CRAWL = spawnflag_dec(4);
    spawnflags_t CRUCIFIED = spawnflag_dec(8);
    spawnflags_t STAND_GROUND = spawnflag_dec(16);
    spawnflags_t ALWAYS_STAND = spawnflag_dec(32);
    spawnflags_t QUIET = spawnflag_dec(64);
}

namespace insane::sounds
{
    cached_soundindex fist("insane/insane11.wav");
    cached_soundindex shake("insane/insane5.wav");
    cached_soundindex moan("insane/insane7.wav");
    array<cached_soundindex@> scream = {
        cached_soundindex("insane/insane1.wav"),
        cached_soundindex("insane/insane2.wav"),
        cached_soundindex("insane/insane3.wav"),
        cached_soundindex("insane/insane4.wav"),
        cached_soundindex("insane/insane6.wav"),
        cached_soundindex("insane/insane8.wav"),
        cached_soundindex("insane/insane9.wav"),
        cached_soundindex("insane/insane10.wav")
    };
}

void insane_fist(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, insane::sounds::fist, 1, ATTN_IDLE, 0);
}

void insane_shake(ASEntity &self)
{
	if (!self.spawnflags.has(spawnflags::insane::QUIET))
		gi_sound(self.e, soundchan_t::VOICE, insane::sounds::shake, 1, ATTN_IDLE, 0);
}

void insane_moan(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::QUIET))
		return;

	// Paril: don't moan every second
	if (self.monsterinfo.attack_finished < level.time)
	{
		gi_sound(self.e, soundchan_t::VOICE, insane::sounds::moan, 1, ATTN_IDLE, 0);
		self.monsterinfo.attack_finished = level.time + random_time(time_sec(1), time_sec(3));
	}
}

void insane_scream(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::QUIET))
		return;

	// Paril: don't moan every second
	if (self.monsterinfo.attack_finished < level.time)
	{
		gi_sound(self.e, soundchan_t::VOICE, insane::sounds::scream[irandom(insane::sounds::scream.length())], 1, ATTN_IDLE, 0);
		self.monsterinfo.attack_finished = level.time + random_time(time_sec(1), time_sec(3));
	}
}

// Paril: unused atm because it breaks N64.
// may fix later
void insane_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> insane_frames_stand_normal = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, insane_checkdown)
};
const mmove_t insane_move_stand_normal = mmove_t(insane::frames::stand60, insane::frames::stand65, insane_frames_stand_normal, insane_stand);

const array<mframe_t> insane_frames_stand_insane = {
	mframe_t(ai_stand, 0, insane_shake),
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
	mframe_t(ai_stand, 0, insane_checkdown)
};
const mmove_t insane_move_stand_insane = mmove_t(insane::frames::stand65, insane::frames::stand94, insane_frames_stand_insane, insane_stand);

const array<mframe_t> insane_frames_uptodown = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, insane_moan),
	mframe_t(ai_move),//, 0, monster_duck_down),
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

	mframe_t(ai_move, 2.7f),
	mframe_t(ai_move, 4.1f),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 7.6f),
	mframe_t(ai_move, 3.6f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, insane_fist),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, insane_fist),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t insane_move_uptodown = mmove_t(insane::frames::stand1, insane::frames::stand40, insane_frames_uptodown, insane_onground);

const array<mframe_t> insane_frames_downtoup = {
	mframe_t(ai_move, -0.7f), // 41
	mframe_t(ai_move, -1.2f), // 42
	mframe_t(ai_move, -1.5f), // 43
	mframe_t(ai_move, -4.5f), // 44
	mframe_t(ai_move, -3.5f), // 45
	mframe_t(ai_move, -0.2f), // 46
	mframe_t(ai_move),		// 47
	mframe_t(ai_move, -1.3f), // 48
	mframe_t(ai_move, -3),	// 49
	mframe_t(ai_move, -2),	// 50
	mframe_t(ai_move),//, 0, monster_duck_up),		// 51
	mframe_t(ai_move),		// 52
	mframe_t(ai_move),		// 53
	mframe_t(ai_move, -3.3f), // 54
	mframe_t(ai_move, -1.6f), // 55
	mframe_t(ai_move, -0.3f), // 56
	mframe_t(ai_move),		// 57
	mframe_t(ai_move),		// 58
	mframe_t(ai_move)			// 59
};
const mmove_t insane_move_downtoup = mmove_t(insane::frames::stand41, insane::frames::stand59, insane_frames_downtoup, insane_stand);

const array<mframe_t> insane_frames_jumpdown = {
	mframe_t(ai_move, 0.2f),
	mframe_t(ai_move, 11.5f),
	mframe_t(ai_move, 5.1f),
	mframe_t(ai_move, 7.1f),
	mframe_t(ai_move)
};
const mmove_t insane_move_jumpdown = mmove_t(insane::frames::stand96, insane::frames::stand100, insane_frames_jumpdown, insane_onground);

const array<mframe_t> insane_frames_down = {
	mframe_t(ai_move), // 100
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 110
	mframe_t(ai_move, -1.7f),
	mframe_t(ai_move, -1.6f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, insane_fist),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 120
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 130
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, insane_moan),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 140
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 150
	mframe_t(ai_move, 0.5f),
	mframe_t(ai_move),
	mframe_t(ai_move, -0.2f, insane_scream),
	mframe_t(ai_move),
	mframe_t(ai_move, 0.2f),
	mframe_t(ai_move, 0.4f),
	mframe_t(ai_move, 0.6f),
	mframe_t(ai_move, 0.8f),
	mframe_t(ai_move, 0.7f),
	mframe_t(ai_move, 0, insane_checkup) // 160
};
const mmove_t insane_move_down = mmove_t(insane::frames::stand100, insane::frames::stand160, insane_frames_down, insane_onground);

const array<mframe_t> insane_frames_walk_normal = {
	mframe_t(ai_walk, 0, insane_scream),
	mframe_t(ai_walk, 2.5f),
	mframe_t(ai_walk, 3.5f),
	mframe_t(ai_walk, 1.7f),
	mframe_t(ai_walk, 2.3f),
	mframe_t(ai_walk, 2.4f),
	mframe_t(ai_walk, 2.2f, monster_footstep),
	mframe_t(ai_walk, 4.2f),
	mframe_t(ai_walk, 5.6f),
	mframe_t(ai_walk, 3.3f),
	mframe_t(ai_walk, 2.4f),
	mframe_t(ai_walk, 0.9f),
	mframe_t(ai_walk, 0, monster_footstep)
};
const mmove_t insane_move_walk_normal = mmove_t(insane::frames::walk27, insane::frames::walk39, insane_frames_walk_normal, insane_walk);
const mmove_t insane_move_run_normal = mmove_t(insane::frames::walk27, insane::frames::walk39, insane_frames_walk_normal, insane_run);

const array<mframe_t> insane_frames_walk_insane = {
	mframe_t(ai_walk, 0, insane_scream), // walk 1
	mframe_t(ai_walk, 3.4f),			   // walk 2
	mframe_t(ai_walk, 3.6f),			   // 3
	mframe_t(ai_walk, 2.9f),			   // 4
	mframe_t(ai_walk, 2.2f),			   // 5
	mframe_t(ai_walk, 2.6f, monster_footstep),			   // 6
	mframe_t(ai_walk),				   // 7
	mframe_t(ai_walk, 0.7f),			   // 8
	mframe_t(ai_walk, 4.8f),			   // 9
	mframe_t(ai_walk, 5.3f),			   // 10
	mframe_t(ai_walk, 1.1f),			   // 11
	mframe_t(ai_walk, 2, monster_footstep),				   // 12
	mframe_t(ai_walk, 0.5f),			   // 13
	mframe_t(ai_walk),				   // 14
	mframe_t(ai_walk),				   // 15
	mframe_t(ai_walk, 4.9f),			   // 16
	mframe_t(ai_walk, 6.7f),			   // 17
	mframe_t(ai_walk, 3.8f),			   // 18
	mframe_t(ai_walk, 2, monster_footstep),				   // 19
	mframe_t(ai_walk, 0.2f),			   // 20
	mframe_t(ai_walk),				   // 21
	mframe_t(ai_walk, 3.4f),			   // 22
	mframe_t(ai_walk, 6.4f),			   // 23
	mframe_t(ai_walk, 5),				   // 24
	mframe_t(ai_walk, 1.8f, monster_footstep),			   // 25
	mframe_t(ai_walk)					   // 26
};
const mmove_t insane_move_walk_insane = mmove_t(insane::frames::walk1, insane::frames::walk26, insane_frames_walk_insane, insane_walk);
const mmove_t insane_move_run_insane = mmove_t(insane::frames::walk1, insane::frames::walk26, insane_frames_walk_insane, insane_run);

const array<mframe_t> insane_frames_stand_pain = {
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
const mmove_t insane_move_stand_pain = mmove_t(insane::frames::st_pain2, insane::frames::st_pain12, insane_frames_stand_pain, insane_run);

const array<mframe_t> insane_frames_stand_death = {
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
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t insane_move_stand_death = mmove_t(insane::frames::st_death2, insane::frames::st_death18, insane_frames_stand_death, insane_dead);

const array<mframe_t> insane_frames_crawl = {
	mframe_t(ai_walk, 0, insane_scream),
	mframe_t(ai_walk, 1.5f),
	mframe_t(ai_walk, 2.1f),
	mframe_t(ai_walk, 3.6f),
	mframe_t(ai_walk, 2, monster_footstep),
	mframe_t(ai_walk, 0.9f),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 3.4f),
	mframe_t(ai_walk, 2.4f, monster_footstep)
};
const mmove_t insane_move_crawl = mmove_t(insane::frames::crawl1, insane::frames::crawl9, insane_frames_crawl, null);
const mmove_t insane_move_runcrawl = mmove_t(insane::frames::crawl1, insane::frames::crawl9, insane_frames_crawl, null);

const array<mframe_t> insane_frames_crawl_pain = {
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
const mmove_t insane_move_crawl_pain = mmove_t(insane::frames::cr_pain2, insane::frames::cr_pain10, insane_frames_crawl_pain, insane_run);

const array<mframe_t> insane_frames_crawl_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t insane_move_crawl_death = mmove_t(insane::frames::cr_death10, insane::frames::cr_death16, insane_frames_crawl_death, insane_dead);

const array<mframe_t> insane_frames_cross = {
	mframe_t(ai_move, 0, insane_moan),
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
const mmove_t insane_move_cross = mmove_t(insane::frames::cross1, insane::frames::cross15, insane_frames_cross, insane_cross);

const array<mframe_t> insane_frames_struggle_cross = {
	mframe_t(ai_move, 0, insane_scream),
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
const mmove_t insane_move_struggle_cross = mmove_t(insane::frames::cross16, insane::frames::cross30, insane_frames_struggle_cross, insane_cross);

void insane_cross(ASEntity &self)
{
	if (frandom() < 0.8f)
		M_SetAnimation(self, insane_move_cross);
	else
		M_SetAnimation(self, insane_move_struggle_cross);
}

void insane_walk(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::STAND_GROUND)) // Hold Ground?
		if (self.e.s.frame == insane::frames::cr_pain10)
		{
			M_SetAnimation(self, insane_move_down);
			//monster_duck_down(self);
			return;
		}
	if (self.spawnflags.has(spawnflags::insane::CRAWL))
		M_SetAnimation(self, insane_move_crawl);
	else if (frandom() <= 0.5f)
		M_SetAnimation(self, insane_move_walk_normal);
	else
		M_SetAnimation(self, insane_move_walk_insane);
}

void insane_run(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::STAND_GROUND)) // Hold Ground?
		if (self.e.s.frame == insane::frames::cr_pain10)
		{
			M_SetAnimation(self, insane_move_down);
			//monster_duck_down(self);
			return;
		}
	if (self.spawnflags.has(spawnflags::insane::CRAWL) || (self.e.s.frame >= insane::frames::cr_pain2 && self.e.s.frame <= insane::frames::cr_pain10) || (self.e.s.frame >= insane::frames::crawl1 && self.e.s.frame <= insane::frames::crawl9) ||
		(self.e.s.frame >= insane::frames::stand99 && self.e.s.frame <= insane::frames::stand160)) // Crawling?
		M_SetAnimation(self, insane_move_runcrawl);
	else if (frandom() <= 0.5f) // Else, mix it up
	{
		M_SetAnimation(self, insane_move_run_normal);
		//monster_duck_up(self);
	}
	else
	{
		M_SetAnimation(self, insane_move_run_insane);
		//monster_duck_up(self);
	}
}

void insane_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	int l, r;

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	r = 1 + (brandom() ? 1 : 0);
	if (self.health < 25)
		l = 25;
	else if (self.health < 50)
		l = 50;
	else if (self.health < 75)
		l = 75;
	else
		l = 100;
	gi_sound(self.e, soundchan_t::VOICE, gi_soundindex(format("player/male/pain{}_{}.wav", l, r)), 1, ATTN_IDLE, 0);

	// Don't go into pain frames if crucified.
	if (self.spawnflags.has(spawnflags::insane::CRUCIFIED))
	{
		M_SetAnimation(self, insane_move_struggle_cross);
		return;
	}

	if (((self.e.s.frame >= insane::frames::crawl1) && (self.e.s.frame <= insane::frames::crawl9)) || ((self.e.s.frame >= insane::frames::stand99) && (self.e.s.frame <= insane::frames::stand160)) || ((self.e.s.frame >= insane::frames::stand1 && self.e.s.frame <= insane::frames::stand40)))
	{
		M_SetAnimation(self, insane_move_crawl_pain);
	}
	else
	{
		M_SetAnimation(self, insane_move_stand_pain);
		//monster_duck_up(self);
	}
}

void insane_onground(ASEntity &self)
{
	M_SetAnimation(self, insane_move_down);
	//monster_duck_down(self);
}

void insane_checkdown(ASEntity &self)
{
	//	if ( (self.e.s.frame == insane::frames::stand94) || (self.e.s.frame == insane::frames::stand65) )
	if (self.spawnflags.has(spawnflags::insane::ALWAYS_STAND)) // Always stand
		return;
	if (frandom() < 0.3f)
	{
		if (frandom() < 0.5f)
			M_SetAnimation(self, insane_move_uptodown);
		else
			M_SetAnimation(self, insane_move_jumpdown);
	}
}

void insane_checkup(ASEntity &self)
{
	// If Hold_Ground and Crawl are set
	if (self.spawnflags.has_all(spawnflags::insane::CRAWL | spawnflags::insane::STAND_GROUND))
		return;
	if (frandom() < 0.5f)
	{
		M_SetAnimation(self, insane_move_downtoup);
		//monster_duck_up(self);
	}
}

void insane_stand(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::CRUCIFIED)) // If crucified
	{
		M_SetAnimation(self, insane_move_cross);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::STAND_GROUND);
	}
	// If Hold_Ground and Crawl are set
	else if (self.spawnflags.has_all(spawnflags::insane::CRAWL | spawnflags::insane::STAND_GROUND))
	{
		M_SetAnimation(self, insane_move_down);
		//monster_duck_down(self);
	}
	else if (frandom() < 0.5f)
		M_SetAnimation(self, insane_move_stand_normal);
	else
		M_SetAnimation(self, insane_move_stand_insane);
}

void insane_dead(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::insane::CRUCIFIED))
	{
		self.flags = ent_flags_t(self.flags | ent_flags_t::FLY);
	}
	else
	{
		self.e.mins = { -16, -16, -24 };
		self.e.maxs = { 16, 16, -8 };
		self.movetype = movetype_t::TOSS;
	}
	monster_dead(self);
}

void insane_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_IDLE, 0);
		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	gi_sound(self.e, soundchan_t::VOICE, gi_soundindex(format("player/male/death{}.wav", irandom(1, 5))), 1, ATTN_IDLE, 0);

	self.deadflag = true;
	self.takedamage = true;

	if (self.spawnflags.has(spawnflags::insane::CRUCIFIED))
	{
		insane_dead(self);
	}
	else
	{
		if (((self.e.s.frame >= insane::frames::crawl1) && (self.e.s.frame <= insane::frames::crawl9)) || ((self.e.s.frame >= insane::frames::stand99) && (self.e.s.frame <= insane::frames::stand160)))
			M_SetAnimation(self, insane_move_crawl_death);
		else
			M_SetAnimation(self, insane_move_stand_death);
	}
}

/*QUAKED misc_insane (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn CRAWL CRUCIFIED STAND_GROUND ALWAYS_STAND QUIET
 */
void SP_misc_insane(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	//	int skin = 0;	//@@

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	insane::sounds::fist.precache();
	if (!self.spawnflags.has(spawnflags::insane::QUIET))
	{
		insane::sounds::shake.precache();
		insane::sounds::moan.precache();
        foreach (auto @sound : insane::sounds::scream)
            sound.precache();
	}

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/insane/tris.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };

	self.health = int(100 * st.health_multiplier);
	self.gib_health = -50;
	self.mass = 300;

	@self.pain = insane_pain;
	@self.die = insane_die;

	@self.monsterinfo.stand = insane_stand;
	@self.monsterinfo.walk = insane_walk;
	@self.monsterinfo.run = insane_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = null;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = null;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::GOOD_GUY);

	//@@
	//	self.e.s.skinnum = skin;
	//	skin++;
	//	if (skin > 12)
	//		skin = 0;

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::insane::STAND_GROUND)) // Stand Ground
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::STAND_GROUND);

	M_SetAnimation(self, insane_move_stand_normal);

	self.monsterinfo.scale = insane::SCALE;

	if (self.spawnflags.has(spawnflags::insane::CRUCIFIED)) // Crucified ?
	{
		self.flags = ent_flags_t(self.flags | ent_flags_t::NO_KNOCKBACK | ent_flags_t::STATIONARY);
		stationarymonster_start(self, st);
	}
	else
		walkmonster_start(self);

	self.e.s.skinnum = irandom(3);
}
