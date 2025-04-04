namespace infantry
{
    enum frames
    {
        gun02,
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
        stand71,
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
        run01,
        run02,
        run03,
        run04,
        run05,
        run06,
        run07,
        run08,
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
        pain201,
        pain202,
        pain203,
        pain204,
        pain205,
        pain206,
        pain207,
        pain208,
        pain209,
        pain210,
        duck01,
        duck02,
        duck03,
        duck04,
        duck05,
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
        death119,
        death120,
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
        death301,
        death302,
        death303,
        death304,
        death305,
        death306,
        death307,
        death308,
        death309,
        block01,
        block02,
        block03,
        block04,
        block05,
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
        attak201,
        attak202,
        attak203,
        attak204,
        attak205,
        attak206,
        attak207,
        attak208,
        // ROGUE
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
        // ROGUE
        // [Paril-KEX] old attack, for demos
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
        // [Paril-KEX] run attack
        run201,
        run202,
        run203,
        run204,
        run205,
        run206,
        run207,
        run208,
        // [Paril-KEX]
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
        attak424
    };

    const float SCALE = 1.000000f;
}

namespace infantry::sounds
{
    cached_soundindex pain1("infantry/infpain1.wav");
    cached_soundindex pain2("infantry/infpain2.wav");
    cached_soundindex die1("infantry/infdeth1.wav");
    cached_soundindex die2("infantry/infdeth2.wav");

    cached_soundindex gunshot("infantry/infatck1.wav");
    cached_soundindex weapon_cock("infantry/infatck3.wav");
    cached_soundindex punch_swing("infantry/infatck2.wav");
    cached_soundindex punch_hit("infantry/melee2.wav");

    cached_soundindex sight("infantry/infsght1.wav");
    cached_soundindex search("infantry/infsrch1.wav");
    cached_soundindex idle("infantry/infidle1.wav");
}

// range at which we'll try to initiate a run-attack to close distance
const float RANGE_RUN_ATTACK = RANGE_NEAR * 0.75f;

const array<mframe_t> infantry_frames_stand = {
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
const mmove_t infantry_move_stand = mmove_t(infantry::frames::stand50, infantry::frames::stand71, infantry_frames_stand, null);

void infantry_stand(ASEntity &self)
{
	M_SetAnimation(self, infantry_move_stand);
}

const array<mframe_t> infantry_frames_fidget = {
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand, 3),
	mframe_t(ai_stand, 6),
	mframe_t(ai_stand, 3, monster_footstep),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -2),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 1),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand, -1),
	mframe_t(ai_stand),
	mframe_t(ai_stand, -3),
	mframe_t(ai_stand, -2),
	mframe_t(ai_stand, -3),
	mframe_t(ai_stand, -3, monster_footstep),
	mframe_t(ai_stand, -2)
};
const mmove_t infantry_move_fidget = mmove_t(infantry::frames::stand01, infantry::frames::stand49, infantry_frames_fidget, infantry_stand);

void infantry_fidget(ASEntity &self)
{
	if (self.enemy !is null)
		return;

	M_SetAnimation(self, infantry_move_fidget);
	gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::idle, 1, ATTN_IDLE, 0);
}

const array<mframe_t> infantry_frames_walk = {
	mframe_t(ai_walk, 5, monster_footstep),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 6, monster_footstep),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 5)
};
const mmove_t infantry_move_walk = mmove_t(infantry::frames::walk03, infantry::frames::walk14, infantry_frames_walk, null);

void infantry_walk(ASEntity &self)
{
	M_SetAnimation(self, infantry_move_walk);
}

const array<mframe_t> infantry_frames_run = {
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 15, monster_footstep),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 7, monster_done_dodge),
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 20, monster_footstep),
	mframe_t(ai_run, 2),
	mframe_t(ai_run, 6)
};
const mmove_t infantry_move_run = mmove_t(infantry::frames::run01, infantry::frames::run08, infantry_frames_run, null);

void infantry_run(ASEntity &self)
{
	monster_done_dodge(self);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, infantry_move_stand);
	else
		M_SetAnimation(self, infantry_move_run);
}

const array<mframe_t> infantry_frames_pain1 = {
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, -1, monster_footstep),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 6),
	mframe_t(ai_move, 2, monster_footstep)
};
const mmove_t infantry_move_pain1 = mmove_t(infantry::frames::pain101, infantry::frames::pain110, infantry_frames_pain1, infantry_run);

const array<mframe_t> infantry_frames_pain2 = {
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -3),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -2, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, 2, monster_footstep)
};
const mmove_t infantry_move_pain2 = mmove_t(infantry::frames::pain201, infantry::frames::pain210, infantry_frames_pain2, infantry_run);

void infantry_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	int n;

	// allow turret to pain
	if ((self.monsterinfo.active_move is infantry_move_jump ||
		self.monsterinfo.active_move is infantry_move_jump2) && self.think is monster_think)
		return;

	monster_done_dodge(self);

	if (level.time < self.pain_debounce_time)
	{
		if (self.think is monster_think && frandom() < 0.33f)
			self.monsterinfo.dodge(self, other, FRAME_TIME_S, null_trace, false, true);

		return;
	}

	self.pain_debounce_time = level.time + time_sec(3);

	n = brandom() ? 1 : 0;

	if (n == 0)
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::pain2, 1, ATTN_NORM, 0);

	if (self.think !is monster_think)
		return;
	
	if (!M_ShouldReactToPain(self, mod))
	{
		if (self.think is monster_think && frandom() < 0.33f)
			self.monsterinfo.dodge(self, other, FRAME_TIME_S, null_trace, false, true);

		return; // no pain anims in nightmare
	}

	if (n == 0)
		M_SetAnimation(self, infantry_move_pain1);
	else
		M_SetAnimation(self, infantry_move_pain2);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);
}

void infantry_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

const array<vec3_t> aimangles = {
	{ 0.0f, 5.0f, 0.0f },
	{ 10.0f, 15.0f, 0.0f },
	{ 20.0f, 25.0f, 0.0f },
	{ 25.0f, 35.0f, 0.0f },
	{ 30.0f, 40.0f, 0.0f },
	{ 30.0f, 45.0f, 0.0f },
	{ 25.0f, 50.0f, 0.0f },
	{ 20.0f, 40.0f, 0.0f },
	{ 15.0f, 35.0f, 0.0f },
	{ 40.0f, 35.0f, 0.0f },
	{ 70.0f, 35.0f, 0.0f },
	{ 90.0f, 35.0f, 0.0f }
};

void InfantryMachineGun(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right;
	vec3_t					 vec;
	monster_muzzle_t flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	bool is_run_attack = (self.e.s.frame >= infantry::frames::run201 && self.e.s.frame <= infantry::frames::run208);

	if (self.e.s.frame == infantry::frames::attak103 || self.e.s.frame == infantry::frames::attak311 || is_run_attack || self.e.s.frame == infantry::frames::attak416)
	{
		if (is_run_attack)
			flash_number = monster_muzzle_t(monster_muzzle_t::INFANTRY_MACHINEGUN_14 + (self.e.s.frame - monster_muzzle_t::INFANTRY_MACHINEGUN_14));
		else if (self.e.s.frame == infantry::frames::attak416)
			flash_number = monster_muzzle_t::INFANTRY_MACHINEGUN_22;
		else
			flash_number = monster_muzzle_t::INFANTRY_MACHINEGUN_1;
		AngleVectors(self.e.s.angles, forward, right);
		start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

		if (self.enemy !is null)
			PredictAim(self, self.enemy, start, 0, true, -0.2f, forward);
		else
			AngleVectors(self.e.s.angles, forward, right);
	}
	else
	{
		flash_number = monster_muzzle_t(monster_muzzle_t::INFANTRY_MACHINEGUN_2 + (self.e.s.frame - infantry::frames::death211));

		AngleVectors(self.e.s.angles, forward, right);
		start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

		vec = self.e.s.angles - aimangles[flash_number - monster_muzzle_t::INFANTRY_MACHINEGUN_2];
		AngleVectors(vec, forward);
	}

	monster_fire_bullet(self, start, forward, 3, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, flash_number);
}

void infantry_sight(ASEntity &self, ASEntity &other)
{
	if (brandom())
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::sight, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::search, 1, ATTN_NORM, 0);
}

void infantry_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void infantry_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> infantry_frames_death1 = {
	mframe_t(ai_move, -4, null, infantry::frames::death102),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -4, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -1, monster_footstep),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, -2),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 9, function(self) { infantry_shrink(self); monster_footstep(self); }),
	mframe_t(ai_move, 9),
	mframe_t(ai_move, 5, monster_footstep),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -3)
};
const mmove_t infantry_move_death1 = mmove_t(infantry::frames::death101, infantry::frames::death120, infantry_frames_death1, infantry_dead);

// Off with his head
const array<mframe_t> infantry_frames_death2 = {
	mframe_t(ai_move, 0, null, infantry::frames::death202),
	mframe_t(ai_move, 1),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, -1),
	mframe_t(ai_move),
	mframe_t(ai_move, 1, monster_footstep),
	mframe_t(ai_move, 1, monster_footstep),
	mframe_t(ai_move, 4),
	mframe_t(ai_move, 3),
	mframe_t(ai_move),
	mframe_t(ai_move, -2, InfantryMachineGun),
	mframe_t(ai_move, -2, InfantryMachineGun),
	mframe_t(ai_move, -3, InfantryMachineGun),
	mframe_t(ai_move, -1, InfantryMachineGun),
	mframe_t(ai_move, -2, InfantryMachineGun),
	mframe_t(ai_move, 0, InfantryMachineGun),
	mframe_t(ai_move, 2, InfantryMachineGun),
	mframe_t(ai_move, 2, InfantryMachineGun),
	mframe_t(ai_move, 3, InfantryMachineGun),
	mframe_t(ai_move, -10, InfantryMachineGun),
	mframe_t(ai_move, -7, InfantryMachineGun),
	mframe_t(ai_move, -8, InfantryMachineGun),
	mframe_t(ai_move, -6, function(self) { infantry_shrink(self); monster_footstep(self); }),
	mframe_t(ai_move, 4),
	mframe_t(ai_move)
};
const mmove_t infantry_move_death2 = mmove_t(infantry::frames::death201, infantry::frames::death225, infantry_frames_death2, infantry_dead);

const array<mframe_t> infantry_frames_death3 = {
	mframe_t(ai_move, 0),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, function(self) { infantry_shrink(self); monster_footstep(self); }),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -11, function(self) { self.monsterinfo.nextframe = infantry::frames::death307; }),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, -11),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move)
};
const mmove_t infantry_move_death3 = mmove_t(infantry::frames::death301, infantry::frames::death309, infantry_frames_death3, infantry_dead);

void infantry_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	int n;
	
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		string head_gib = (self.monsterinfo.active_move !is infantry_move_death3) ? "models/objects/gibs/sm_meat/tris.md2" : "models/monsters/infantry/gibs/head.md2";

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t("models/objects/gibs/bone/tris.md2"),
			gib_def_t(3, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/monsters/infantry/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/infantry/gibs/gun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t(2, "models/monsters/infantry/gibs/foot.md2", gib_type_t::SKINNED),
			gib_def_t(2, "models/monsters/infantry/gibs/arm.md2", gib_type_t::SKINNED),
			gib_def_t(head_gib, gib_type_t(gib_type_t::HEAD | gib_type_t::SKINNED))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	self.deadflag = true;
	self.takedamage = true;

	n = irandom(3);

	if (n == 0)
	{
		M_SetAnimation(self, infantry_move_death1);
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::die2, 1, ATTN_NORM, 0);
	}
	else if (n == 1)
	{
		M_SetAnimation(self, infantry_move_death2);
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::die1, 1, ATTN_NORM, 0);
	}
	else
	{
		M_SetAnimation(self, infantry_move_death3);
		gi_sound(self.e, soundchan_t::VOICE, infantry::sounds::die2, 1, ATTN_NORM, 0);
	}

	// don't always pop a head gib, it gets old
	if (n != 2 && frandom() <= 0.25f)
	{
		ASEntity @head = ThrowGib(self, "models/monsters/infantry/gibs/head.md2", damage, gib_type_t::NONE, self.e.s.scale);

		if (head !is null)
		{
			head.e.s.angles = self.e.s.angles;
			head.e.s.origin = self.e.s.origin + vec3_t(0, 0, 32.0f);
			vec3_t headDir = (self.e.s.origin - inflictor.e.s.origin);
			head.velocity = headDir / headDir.length() * 100.0f;
			head.velocity[2] = 200.0f;
			head.avelocity *= 0.15f;
			head.e.s.skinnum = 0;
			gi_linkentity(head.e);
		}
	}
}

const array<mframe_t> infantry_frames_duck = {
	mframe_t(ai_move, -2, monster_duck_down),
	mframe_t(ai_move, -5, monster_duck_hold),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 4, monster_duck_up),
	mframe_t(ai_move)
};
const mmove_t infantry_move_duck = mmove_t(infantry::frames::duck01, infantry::frames::duck05, infantry_frames_duck, infantry_run);

// PMM - dodge code moved below so I can see the attack frames

void infantry_set_firetime(ASEntity &self)
{
	self.monsterinfo.fire_wait = level.time + random_time(time_sec(0.7), time_sec(2));

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0 && self.enemy !is null && range_to(self, self.enemy) >= RANGE_RUN_ATTACK && ai_check_move(self, 8.0f))
		M_SetAnimation(self, infantry_move_attack4, false);
}

void infantry_cock_gun(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, infantry::sounds::weapon_cock, 1, ATTN_NORM, 0);

	// gun cocked
	self.count = 1;
}

// cock-less attack, used if he has already cocked his gun
const array<mframe_t> infantry_frames_attack1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge, 6, function(self) { infantry_set_firetime(self); monster_footstep(self); }),
	mframe_t(ai_charge, 0, infantry_fire),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, -7),
	mframe_t(ai_charge, -6, function(self) { self.monsterinfo.nextframe = infantry::frames::attak114; monster_footstep(self); }),
	// dead frames start
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, 0, infantry_cock_gun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	// dead frames end
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -1)
};
const mmove_t infantry_move_attack1 = mmove_t(infantry::frames::attak101, infantry::frames::attak115, infantry_frames_attack1, infantry_run);

// old animation, full cock + shoot
const array<mframe_t> infantry_frames_attack3 = {
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, 0,  infantry_cock_gun),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -3, function(self) { infantry_set_firetime(self); monster_footstep(self); } ),
	mframe_t(ai_charge, 1,  infantry_fire),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, -1),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -3),
};
const mmove_t infantry_move_attack3 = mmove_t(infantry::frames::attak301, infantry::frames::attak315, infantry_frames_attack3, infantry_run);

// even older animation, full cock + shoot
const array<mframe_t> infantry_frames_attack5 = {
	// skipped frames
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_charge, 0, infantry_cock_gun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, function(self) { self.monsterinfo.nextframe = self.e.s.frame + 1; }),
	mframe_t(ai_charge), // skipped frame
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, infantry_set_firetime),
	mframe_t(ai_charge, 0, infantry_fire),

	// skipped frames
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_footstep)
};
const mmove_t infantry_move_attack5 = mmove_t(infantry::frames::attak401, infantry::frames::attak423, infantry_frames_attack5, infantry_run);

void infantry_fire(ASEntity &self)
{
	InfantryMachineGun(self);

	// we fired, so we must cock again before firing
	self.count = 0;

	// check if we ran out of firing time
	if (self.monsterinfo.active_move is infantry_move_attack4)
	{
		if (level.time >= self.monsterinfo.fire_wait)
		{
			monster_done_dodge(self);
			M_SetAnimation(self, infantry_move_attack1, false);
			self.monsterinfo.nextframe = infantry::frames::attak114;
		}
		// got close to an edge
		else if (!ai_check_move(self, 8.0f))
		{
			M_SetAnimation(self, infantry_move_attack1, false);
			self.monsterinfo.nextframe = infantry::frames::attak103;
			monster_done_dodge(self);
			self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
		}
	}
	else if ((self.e.s.frame >= infantry::frames::attak101 && self.e.s.frame <= infantry::frames::attak115) ||
		(self.e.s.frame >= infantry::frames::attak301 && self.e.s.frame <= infantry::frames::attak315) ||
		(self.e.s.frame >= infantry::frames::attak401 && self.e.s.frame <= infantry::frames::attak424))
	{
		if (level.time >= self.monsterinfo.fire_wait)
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

			if (self.e.s.frame == infantry::frames::attak416)
				self.monsterinfo.nextframe = infantry::frames::attak420;
		}
		else
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HOLD_FRAME);
	}
}

void infantry_swing(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, infantry::sounds::punch_swing, 1, ATTN_NORM, 0);
}

void infantry_smack(ASEntity &self)
{
	vec3_t aim = { MELEE_DISTANCE, 0, 0 };

	if (fire_hit(self, aim, irandom(5, 10), 50))
		gi_sound(self.e, soundchan_t::WEAPON, infantry::sounds::punch_hit, 1, ATTN_NORM, 0);
	else
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
}

const array<mframe_t> infantry_frames_attack2 = {
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 0, infantry_swing),
	mframe_t(ai_charge, 8, monster_footstep),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 8, infantry_smack),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 3)
};
const mmove_t infantry_move_attack2 = mmove_t(infantry::frames::attak201, infantry::frames::attak208, infantry_frames_attack2, infantry_run);

// [Paril-KEX] run-attack, inspired by q2test
void infantry_attack4_refire(ASEntity &self)
{
	// ran out of firing time
	if (level.time >= self.monsterinfo.fire_wait)
	{
		monster_done_dodge(self);
		M_SetAnimation(self, infantry_move_attack1, false);
		self.monsterinfo.nextframe = infantry::frames::attak114;
	}
	// we got too close, or we can't move forward, switch us back to regular attack
	else if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0 || (self.enemy !is null && (range_to(self, self.enemy) < RANGE_RUN_ATTACK || !ai_check_move(self, 8.0f))))
	{
		M_SetAnimation(self, infantry_move_attack1, false);
		self.monsterinfo.nextframe = infantry::frames::attak103;
		monster_done_dodge(self);
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
	}
	else
		self.monsterinfo.nextframe = infantry::frames::run201;

	infantry_fire(self);
}

const array<mframe_t> infantry_frames_attack4 = {
	mframe_t(ai_charge, 16, infantry_fire),
	mframe_t(ai_charge, 16, function(self) { monster_footstep(self); infantry_fire(self); }),
	mframe_t(ai_charge, 13, infantry_fire),
	mframe_t(ai_charge, 10, infantry_fire),
	mframe_t(ai_charge, 16, infantry_fire),
	mframe_t(ai_charge, 16, function(self) { monster_footstep(self); infantry_fire(self); }),
	mframe_t(ai_charge, 16, infantry_fire),
	mframe_t(ai_charge, 16, infantry_attack4_refire)
};
const mmove_t infantry_move_attack4 = mmove_t(infantry::frames::run201, infantry::frames::run208, infantry_frames_attack4, infantry_run, 0.5f);

void infantry_attack(ASEntity &self)
{
	monster_done_dodge(self);

	float r = range_to(self, self.enemy);

	if (r <= RANGE_MELEE && self.monsterinfo.melee_debounce_time <= level.time)
		M_SetAnimation(self, infantry_move_attack2);
	else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::INFANTRY_MACHINEGUN_1]))
	{
		if (self.count != 0)
			M_SetAnimation(self, infantry_move_attack1);
		else
		{
			M_SetAnimation(self, frandom() <= 0.1f ? infantry_move_attack5 : infantry_move_attack3);
			self.monsterinfo.nextframe = infantry::frames::attak405;
		}
	}
}

//===========
// PGM
void infantry_jump_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void infantry_jump2_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 150);
	self.velocity += (up * 400);
}

void infantry_jump_wait_land(ASEntity &self)
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

const array<mframe_t> infantry_frames_jump = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, infantry_jump_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, infantry_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t infantry_move_jump = mmove_t(infantry::frames::jump01, infantry::frames::jump10, infantry_frames_jump, infantry_run);

const array<mframe_t> infantry_frames_jump2 = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, 0, infantry_jump2_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, infantry_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t infantry_move_jump2 = mmove_t(infantry::frames::jump01, infantry::frames::jump10, infantry_frames_jump2, infantry_run);

void infantry_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	monster_done_dodge(self);

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, infantry_move_jump2);
	else
		M_SetAnimation(self, infantry_move_jump);
}

bool infantry_blocked(ASEntity &self, float dist)
{
	auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			infantry_jump(self, result);
		return true;
	}

	if (blocked_checkplat(self, dist))
		return true;

	return false;
}

bool infantry_duck(ASEntity &self, gtime_t eta)
{
	// if we're jumping, don't dodge
	if ((self.monsterinfo.active_move is infantry_move_jump) ||
		(self.monsterinfo.active_move is infantry_move_jump2))
	{
		return false;
	}

	// don't duck during our firing or melee frames
	if (self.e.s.frame == infantry::frames::attak103 ||
		self.e.s.frame == infantry::frames::attak315 ||
		(self.monsterinfo.active_move is infantry_move_attack2))
	{
		self.monsterinfo.unduck(self);
		return false;
	}

	M_SetAnimation(self, infantry_move_duck);

	return true;
}

bool infantry_sidestep(ASEntity &self)
{
	// if we're jumping, don't dodge
	if ((self.monsterinfo.active_move is infantry_move_jump) ||
		(self.monsterinfo.active_move is infantry_move_jump2))
	{
		return false;
	}

	if (self.monsterinfo.active_move is infantry_move_run)
		return true;

	// Don't sidestep if we're already sidestepping, and def not unless we're actually shooting
	// or if we already cocked
	if (self.monsterinfo.active_move !is infantry_move_attack4 &&
		self.monsterinfo.next_move !is infantry_move_attack4 &&
		((self.e.s.frame == infantry::frames::attak103 ||
		self.e.s.frame == infantry::frames::attak311 ||
		self.e.s.frame == infantry::frames::attak416) &&
		self.count == 0))
	{
		// give us a fire time boost so we don't end up firing for 1 frame
		self.monsterinfo.fire_wait += random_time(time_ms(300), time_ms(600));

		M_SetAnimation(self, infantry_move_attack4, false);
	}

	return true;
}

void InfantryPrecache()
{
	infantry::sounds::pain1.precache();
	infantry::sounds::pain2.precache();
	infantry::sounds::die1.precache();
	infantry::sounds::die2.precache();

	infantry::sounds::gunshot.precache();
	infantry::sounds::weapon_cock.precache();
	infantry::sounds::punch_swing.precache();
	infantry::sounds::punch_hit.precache();

	infantry::sounds::sight.precache();
	infantry::sounds::search.precache();
	infantry::sounds::idle.precache();
}

namespace spawnflags::infantry
{
    const uint32 NOJUMPING = 8;
}

/*QUAKED monster_infantry (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight NoJumping
 */
void SP_monster_infantry(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	InfantryPrecache();

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STINKY);

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/infantry/tris.md2");
	
	gi_modelindex("models/monsters/infantry/gibs/head.md2");
	gi_modelindex("models/monsters/infantry/gibs/chest.md2");
	gi_modelindex("models/monsters/infantry/gibs/gun.md2");
	gi_modelindex("models/monsters/infantry/gibs/arm.md2");
	gi_modelindex("models/monsters/infantry/gibs/foot.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };

	self.health = int(100 * st.health_multiplier);
	self.gib_health = -65;
	self.mass = 200;

	@self.pain = infantry_pain;
	@self.die = infantry_die;

	self.monsterinfo.combat_style = combat_style_t::MIXED;

	@self.monsterinfo.stand = infantry_stand;
	@self.monsterinfo.walk = infantry_walk;
	@self.monsterinfo.run = infantry_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = infantry_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = infantry_sidestep;
	@self.monsterinfo.blocked = infantry_blocked;
	// pmm
	@self.monsterinfo.attack = infantry_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = infantry_sight;
	@self.monsterinfo.idle = infantry_fidget;
	@self.monsterinfo.setskin = infantry_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, infantry_move_stand);
	self.monsterinfo.scale = infantry::SCALE;
	self.monsterinfo.can_jump = (self.spawnflags & spawnflags::infantry::NOJUMPING) == 0;
	self.monsterinfo.drop_height = 192;
	self.monsterinfo.jump_height = 40;

	walkmonster_start(self);
}
