// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

FLIPPER

==============================================================================
*/

namespace flipper
{
    enum frames
    {
        flpbit01,
        flpbit02,
        flpbit03,
        flpbit04,
        flpbit05,
        flpbit06,
        flpbit07,
        flpbit08,
        flpbit09,
        flpbit10,
        flpbit11,
        flpbit12,
        flpbit13,
        flpbit14,
        flpbit15,
        flpbit16,
        flpbit17,
        flpbit18,
        flpbit19,
        flpbit20,
        flptal01,
        flptal02,
        flptal03,
        flptal04,
        flptal05,
        flptal06,
        flptal07,
        flptal08,
        flptal09,
        flptal10,
        flptal11,
        flptal12,
        flptal13,
        flptal14,
        flptal15,
        flptal16,
        flptal17,
        flptal18,
        flptal19,
        flptal20,
        flptal21,
        flphor01,
        flphor02,
        flphor03,
        flphor04,
        flphor05,
        flphor06,
        flphor07,
        flphor08,
        flphor09,
        flphor10,
        flphor11,
        flphor12,
        flphor13,
        flphor14,
        flphor15,
        flphor16,
        flphor17,
        flphor18,
        flphor19,
        flphor20,
        flphor21,
        flphor22,
        flphor23,
        flphor24,
        flpver01,
        flpver02,
        flpver03,
        flpver04,
        flpver05,
        flpver06,
        flpver07,
        flpver08,
        flpver09,
        flpver10,
        flpver11,
        flpver12,
        flpver13,
        flpver14,
        flpver15,
        flpver16,
        flpver17,
        flpver18,
        flpver19,
        flpver20,
        flpver21,
        flpver22,
        flpver23,
        flpver24,
        flpver25,
        flpver26,
        flpver27,
        flpver28,
        flpver29,
        flppn101,
        flppn102,
        flppn103,
        flppn104,
        flppn105,
        flppn201,
        flppn202,
        flppn203,
        flppn204,
        flppn205,
        flpdth01,
        flpdth02,
        flpdth03,
        flpdth04,
        flpdth05,
        flpdth06,
        flpdth07,
        flpdth08,
        flpdth09,
        flpdth10,
        flpdth11,
        flpdth12,
        flpdth13,
        flpdth14,
        flpdth15,
        flpdth16,
        flpdth17,
        flpdth18,
        flpdth19,
        flpdth20,
        flpdth21,
        flpdth22,
        flpdth23,
        flpdth24,
        flpdth25,
        flpdth26,
        flpdth27,
        flpdth28,
        flpdth29,
        flpdth30,
        flpdth31,
        flpdth32,
        flpdth33,
        flpdth34,
        flpdth35,
        flpdth36,
        flpdth37,
        flpdth38,
        flpdth39,
        flpdth40,
        flpdth41,
        flpdth42,
        flpdth43,
        flpdth44,
        flpdth45,
        flpdth46,
        flpdth47,
        flpdth48,
        flpdth49,
        flpdth50,
        flpdth51,
        flpdth52,
        flpdth53,
        flpdth54,
        flpdth55,
        flpdth56
    };

    const float SCALE = 1.000000f;
}

namespace flipper::sounds
{
    cached_soundindex chomp("flipper/flpatck2.wav");
    cached_soundindex attack("flipper/flpatck1.wav");
    cached_soundindex pain1("flipper/flppain1.wav");
    cached_soundindex pain2("flipper/flppain2.wav");
    cached_soundindex death("flipper/flpdeth1.wav");
    cached_soundindex idle("flipper/flpidle1.wav");
    cached_soundindex search("flipper/flpsrch1.wav");
    cached_soundindex sight("flipper/flpsght1.wav");
}

const array<mframe_t> flipper_frames_stand = {
	mframe_t(ai_stand)
};

const mmove_t flipper_move_stand = mmove_t(flipper::frames::flphor01, flipper::frames::flphor01, flipper_frames_stand, null);

void flipper_stand(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_stand);
}

const float FLIPPER_RUN_SPEED = 24;

const array<mframe_t> flipper_frames_run = {
	mframe_t(ai_run, FLIPPER_RUN_SPEED), // 6
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED), // 10

	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED), // 20

	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED),
	mframe_t(ai_run, FLIPPER_RUN_SPEED) // 29
};
const mmove_t flipper_move_run_loop = mmove_t(flipper::frames::flpver06, flipper::frames::flpver29, flipper_frames_run, null);

void flipper_run_loop(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_run_loop);
}

const array<mframe_t> flipper_frames_run_start = {
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 8)
};
const mmove_t flipper_move_run_start = mmove_t(flipper::frames::flpver01, flipper::frames::flpver06, flipper_frames_run_start, flipper_run_loop);

void flipper_run(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_run_start);
}

/* Standard Swimming */
const array<mframe_t> flipper_frames_walk = {
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4)
};
const mmove_t flipper_move_walk = mmove_t(flipper::frames::flphor01, flipper::frames::flphor24, flipper_frames_walk, null);

void flipper_walk(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_walk);
}

const array<mframe_t> flipper_frames_start_run = {
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run),
	mframe_t(ai_run, 8, flipper_run)
};
const mmove_t flipper_move_start_run = mmove_t(flipper::frames::flphor01, flipper::frames::flphor05, flipper_frames_start_run, null);

void flipper_start_run(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_start_run);
}

const array<mframe_t> flipper_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flipper_move_pain2 = mmove_t(flipper::frames::flppn101, flipper::frames::flppn105, flipper_frames_pain2, flipper_run);

const array<mframe_t> flipper_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t flipper_move_pain1 = mmove_t(flipper::frames::flppn201, flipper::frames::flppn205, flipper_frames_pain1, flipper_run);

void flipper_bite(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, 0, 0 };
	fire_hit(self, aim, 5, 0);
}

void flipper_preattack(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, flipper::sounds::chomp, 1, ATTN_NORM, 0);
}

const array<mframe_t> flipper_frames_attack = {
	mframe_t(ai_charge, 0, flipper_preattack),
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
	mframe_t(ai_charge, 0, flipper_bite),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, flipper_bite),
	mframe_t(ai_charge)
};
const mmove_t flipper_move_attack = mmove_t(flipper::frames::flpbit01, flipper::frames::flpbit20, flipper_frames_attack, flipper_run);

void flipper_melee(ASEntity &self)
{
	M_SetAnimation(self, flipper_move_attack);
}

void flipper_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);
	bool n = brandom();

	if (!n)
		gi_sound(self.e, soundchan_t::VOICE, flipper::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, flipper::sounds::pain2, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (!n)
		M_SetAnimation(self, flipper_move_pain1);
	else
		M_SetAnimation(self, flipper_move_pain2);
}

void flipper_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void flipper_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -8 };
	self.e.maxs = { 16, 16, 8 };
	monster_dead(self);
}

const array<mframe_t> flipper_frames_death = {
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
const mmove_t flipper_move_death = mmove_t(flipper::frames::flpdth01, flipper::frames::flpdth56, flipper_frames_death, flipper_dead);

void flipper_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, flipper::sounds::sight, 1, ATTN_NORM, 0);
}

void flipper_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, flipper::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	M_SetAnimation(self, flipper_move_death);
}

void flipper_set_fly_parameters(ASEntity &self)
{
	self.monsterinfo.fly_thrusters = false;
	self.monsterinfo.fly_acceleration = 30.f;
	self.monsterinfo.fly_speed = 110.f;
	// only melee, so get in close
	self.monsterinfo.fly_min_distance = 10.f;
	self.monsterinfo.fly_max_distance = 10.f;
}

/*QUAKED monster_flipper (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_flipper(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	flipper::sounds::attack.precache();
	flipper::sounds::chomp.precache();
	flipper::sounds::pain1.precache();
	flipper::sounds::pain2.precache();
	flipper::sounds::death.precache();
	flipper::sounds::idle.precache();
	flipper::sounds::search.precache();
	flipper::sounds::sight.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/flipper/tris.md2");
	self.e.mins = { -16, -16, -8 };
	self.e.maxs = { 16, 16, 20 };

	self.health = int(50 * st.health_multiplier);
	self.gib_health = -30;
	self.mass = 100;

	@self.pain = flipper_pain;
	@self.die = flipper_die;

	@self.monsterinfo.stand = flipper_stand;
	@self.monsterinfo.walk = flipper_walk;
	@self.monsterinfo.run = flipper_start_run;
	@self.monsterinfo.melee = flipper_melee;
	@self.monsterinfo.sight = flipper_sight;
	@self.monsterinfo.setskin = flipper_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, flipper_move_stand);
	self.monsterinfo.scale = flipper::SCALE;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	flipper_set_fly_parameters(self);

	swimmonster_start(self);
}
