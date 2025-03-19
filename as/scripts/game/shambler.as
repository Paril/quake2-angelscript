// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

SHAMBLER

==============================================================================
*/

namespace shambler
{
    enum frames
    {
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
        run01,
        run02,
        run03,
        run04,
        run05,
        run06,
        smash01,
        smash02,
        smash03,
        smash04,
        smash05,
        smash06,
        smash07,
        smash08,
        smash09,
        smash10,
        smash11,
        smash12,
        swingr01,
        swingr02,
        swingr03,
        swingr04,
        swingr05,
        swingr06,
        swingr07,
        swingr08,
        swingr09,
        swingl01,
        swingl02,
        swingl03,
        swingl04,
        swingl05,
        swingl06,
        swingl07,
        swingl08,
        swingl09,
        magic01,
        magic02,
        magic03,
        magic04,
        magic05,
        magic06,
        magic07,
        magic08,
        magic09,
        magic10,
        magic11,
        magic12,
        pain01,
        pain02,
        pain03,
        pain04,
        pain05,
        pain06,
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
        death11
    };

    const float SCALE = 1.000000f;
}

namespace shambler::sounds
{
    cached_soundindex pain("shambler/shurt2.wav");
    cached_soundindex idle("shambler/sidle.wav");
    cached_soundindex die("shambler/sdeath.wav");
    cached_soundindex windup("shambler/sattck1.wav");
    cached_soundindex melee1("shambler/melee1.wav");
    cached_soundindex melee2("shambler/melee2.wav");
    cached_soundindex sight("shambler/ssight.wav");
    cached_soundindex smack("shambler/smack.wav");
    cached_soundindex boom("shambler/sboom.wav");
}

//
// misc
//

void shambler_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, shambler::sounds::sight, 1, ATTN_NORM, 0);
}

const array<vec3_t> lightning_left_hand = {
	{ 44, 36, 25 },
	{ 10, 44, 57 },
	{ -1, 40, 70 },
	{ -10, 34, 75 },
	{ 7.4f, 24, 89 }
};

const array<vec3_t> lightning_right_hand = {
	{ 28, -38, 25 },
	{ 31, -7, 70 },
	{ 20, 0, 80 },
	{ 16, 1.2f, 81 },
	{ 27, -11, 83 }
};

void shambler_lightning_update(ASEntity &self)
{
	ASEntity @lightning = self.beam;

	if (self.e.s.frame >= int(shambler::frames::magic01 + lightning_left_hand.length()))
	{
		G_FreeEdict(lightning);
		@self.beam = null;
		return;
	}

	vec3_t f, r;
	AngleVectors(self.e.s.angles, f, r);
	lightning.e.s.origin = M_ProjectFlashSource(self, lightning_left_hand[self.e.s.frame - shambler::frames::magic01], f, r);
	lightning.e.s.old_origin = M_ProjectFlashSource(self, lightning_right_hand[self.e.s.frame - shambler::frames::magic01], f, r);
	gi_linkentity(lightning.e);
}

void shambler_windup(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::windup, 1, ATTN_NORM, 0);

	ASEntity @lightning = @self.beam = G_Spawn();
	lightning.e.s.modelindex = gi_modelindex("models/proj/lightning/tris.md2");
	lightning.e.s.renderfx = renderfx_t(lightning.e.s.renderfx | renderfx_t::BEAM);
	@lightning.owner = self;
	shambler_lightning_update(self);
}

void shambler_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, shambler::sounds::idle, 1, ATTN_IDLE, 0);
}

void shambler_maybe_idle(ASEntity &self)
{
	if (frandom() > 0.8)
		gi_sound(self.e, soundchan_t::VOICE, shambler::sounds::idle, 1, ATTN_IDLE, 0);
}

//
// stand
//

const array<mframe_t> shambler_frames_stand = {
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
const mmove_t shambler_move_stand = mmove_t(shambler::frames::stand01, shambler::frames::stand17, shambler_frames_stand, null);

void shambler_stand(ASEntity &self)
{
	M_SetAnimation(self, shambler_move_stand);
}

//
// walk
//

const array<mframe_t> shambler_frames_walk = {
	mframe_t(ai_walk, 10), // FIXME: add footsteps?
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 3),
	mframe_t(ai_walk, 13),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 7, shambler_maybe_idle),
	mframe_t(ai_walk, 5),
};
const mmove_t shambler_move_walk = mmove_t(shambler::frames::walk01, shambler::frames::walk12, shambler_frames_walk, null);

void shambler_walk(ASEntity &self)
{
	M_SetAnimation(self, shambler_move_walk);
}

//
// run
//

const array<mframe_t> shambler_frames_run = {
	mframe_t(ai_run, 20), // FIXME: add footsteps?
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 20, shambler_maybe_idle),
};
const mmove_t shambler_move_run = mmove_t(shambler::frames::run01, shambler::frames::run06, shambler_frames_run, null);

void shambler_run(ASEntity &self)
{
	if (self.enemy !is null && self.enemy.client !is null)
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BRUTAL);
	else
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BRUTAL);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		M_SetAnimation(self, shambler_move_stand);
		return;
	}

	M_SetAnimation(self, shambler_move_run);
}

//
// pain
//

// FIXME: needs halved explosion damage

const array<mframe_t> shambler_frames_pain = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
};
const mmove_t shambler_move_pain = mmove_t(shambler::frames::pain01, shambler::frames::pain06, shambler_frames_pain, shambler_run);

void shambler_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.timestamp)
		return;

	self.timestamp = level.time + time_ms(1);
	gi_sound(self.e, soundchan_t::AUTO, shambler::sounds::pain, 1, ATTN_NORM, 0);

	if (mod.id != mod_id_t::CHAINFIST && damage <= 30 && frandom() > 0.2f)
		return;

	// If hard or nightmare, don't go into pain while attacking
	if (skill.integer >= 2)
	{
		if ((self.e.s.frame >= shambler::frames::smash01) && (self.e.s.frame <= shambler::frames::smash12))
			return;

		if ((self.e.s.frame >= shambler::frames::swingl01) && (self.e.s.frame <= shambler::frames::swingl09))
			return;

		if ((self.e.s.frame >= shambler::frames::swingr01) && (self.e.s.frame <= shambler::frames::swingr09))
			return;
	}
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(2);
	M_SetAnimation(self, shambler_move_pain);
}

void shambler_setskin(ASEntity &self)
{
	// FIXME: create pain skin?
	//if (self.health < (self.max_health / 2))
	//	self.e.s.skinnum |= 1;
	//else
	//	self.e.s.skinnum &= ~1;
}

//
// attacks
//

/*
void() sham_magic3     =[      $magic3,       sham_magic4    ] {
	ai_face();
	self.nextthink = self.nextthink + 0.2;
	local entity o;

	self.effects = self.effects | EF_MUZZLEFLASH;
	ai_face();
	self.owner = spawn();
	o = self.owner;
	setmodel (o, "progs/s_light.mdl");
	setorigin (o, self.origin);
	o.angles = self.angles;
	o.nextthink = time + 0.7;
	o.think = SUB_Remove;
};
*/

void ShamblerSaveLoc(ASEntity &self)
{
	self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	self.pos1[2] += self.enemy.viewheight;
	self.monsterinfo.nextframe = shambler::frames::magic09;

	gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::boom, 1, ATTN_NORM, 0);
	shambler_lightning_update(self);
}

namespace spawnflags::shambler
{
    // FIXME: bad flag
    const spawnflags_t PRECISE = spawnflag_dec(1);
}

vec3_t FindShamblerOffset(ASEntity &self)
{
	vec3_t offset = { 0, 0, 48.f };

	for (int i = 0; i < 8; i++)
	{
		if (M_CheckClearShot(self, offset))
			return offset;

		offset.z -= 4.f;
	}

	return { 0, 0, 48.f };
}

void ShamblerCastLightning(ASEntity &self)
{
	if (self.enemy is null)
		return;

	vec3_t start;
	vec3_t dir;
	vec3_t forward, right, aimpt;
	vec3_t offset = FindShamblerOffset(self);

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, offset, forward, right);

	// calc direction to where we targted
	PredictAim(self, self.enemy, start, 0, false, self.spawnflags.has(spawnflags::shambler::PRECISE) ? 0.f : 0.1f, dir, aimpt);

	vec3_t end = start + (dir * 8192);
	trace_t tr = gi_traceline(start, end, self.e, contents_t(contents_t::MASK_PROJECTILE | contents_t::SLIME | contents_t::LAVA));

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::LIGHTNING);
	gi_WriteEntity(self.e);	// source entity
	gi_WriteEntity(world.e); // destination entity
	gi_WritePosition(start);
	gi_WritePosition(tr.endpos);
	gi_multicast(start, multicast_t::PVS, false);

	fire_bullet(self, start, dir, irandom(8, 12), 15, 0, 0, mod_id_t::TESLA);
}

const array<mframe_t> shambler_frames_magic = {
	mframe_t(ai_charge, 0, shambler_windup),
	mframe_t(ai_charge, 0, shambler_lightning_update),
	mframe_t(ai_charge, 0, shambler_lightning_update),
	mframe_t(ai_move, 0, shambler_lightning_update),
	mframe_t(ai_move, 0, shambler_lightning_update),
	mframe_t(ai_move, 0, ShamblerSaveLoc),
	mframe_t(ai_move),
	mframe_t(ai_charge),
	mframe_t(ai_move, 0, ShamblerCastLightning),
	mframe_t(ai_move, 0, ShamblerCastLightning),
	mframe_t(ai_move, 0, ShamblerCastLightning),
	mframe_t(ai_move),
};

const mmove_t shambler_attack_magic = mmove_t(shambler::frames::magic01, shambler::frames::magic12, shambler_frames_magic, shambler_run);

void shambler_attack(ASEntity &self)
{
	M_SetAnimation(self, shambler_attack_magic);
}

//
// melee
//

void shambler_melee1(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::melee1, 1, ATTN_NORM, 0);
}

void shambler_melee2(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::melee2, 1, ATTN_NORM, 0);
}

void sham_smash10(ASEntity &self)
{
	if (self.enemy is null)
		return;

	ai_charge(self, 0);

	if (!CanDamage(self.enemy, self))
		return;

	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], -4 };
	bool hit = fire_hit(self, aim, irandom(110, 120), 120); // Slower attack

	if (hit)
		gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::smack, 1, ATTN_NORM, 0);

	// SpawnMeatSpray(self.origin + v_forward * 16, crandom() * 100 * v_right);
	// SpawnMeatSpray(self.origin + v_forward * 16, crandom() * 100 * v_right);
};

void ShamClaw(ASEntity &self)
{
	if (self.enemy is null)
		return;

	ai_charge(self, 10);

	if (!CanDamage(self.enemy, self))
		return;

	vec3_t aim = { MELEE_DISTANCE, self.e.mins[0], -4 };
	bool hit = fire_hit(self, aim, irandom(70, 80), 80); // Slower attack

	if (hit)
		gi_sound(self.e, soundchan_t::WEAPON, shambler::sounds::smack, 1, ATTN_NORM, 0);
	
	// 250 if left, -250 if right
	/*
	if (side)
	{
		makevectorsfixed(self.angles);
		SpawnMeatSpray(self.origin + v_forward * 16, side * v_right);
	}
	*/
};

const array<mframe_t> shambler_frames_smash = {
	mframe_t(ai_charge, 2, shambler_melee1),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 0, sham_smash10),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 4),
};

const mmove_t shambler_attack_smash = mmove_t(shambler::frames::smash01, shambler::frames::smash12, shambler_frames_smash, shambler_run);

const array<mframe_t> shambler_frames_swingl = {
	mframe_t(ai_charge, 5, shambler_melee1),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 7),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 7),
	mframe_t(ai_charge, 9),
	mframe_t(ai_charge, 5, ShamClaw),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 8, sham_swingl9),
};

const mmove_t shambler_attack_swingl = mmove_t(shambler::frames::swingl01, shambler::frames::swingl09, shambler_frames_swingl, shambler_run);

const array<mframe_t> shambler_frames_swingr = {
	mframe_t(ai_charge, 1, shambler_melee2),
	mframe_t(ai_charge, 8),
	mframe_t(ai_charge, 14),
	mframe_t(ai_charge, 7),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 6, ShamClaw),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 8, sham_swingr9),
};

const mmove_t shambler_attack_swingr = mmove_t(shambler::frames::swingr01, shambler::frames::swingr09, shambler_frames_swingr, shambler_run);

void sham_swingl9(ASEntity &self)
{
	ai_charge(self, 8);

	if (brandom() && self.enemy !is null && range_to(self, self.enemy) < MELEE_DISTANCE)
		M_SetAnimation(self, shambler_attack_swingr);
}

void sham_swingr9(ASEntity &self)
{
	ai_charge(self, 1);
	ai_charge(self, 10);

	if (brandom() && self.enemy !is null && range_to(self, self.enemy) < MELEE_DISTANCE)
		M_SetAnimation(self, shambler_attack_swingl);
}

void shambler_melee(ASEntity &self)
{
	float chance = frandom();
	if (chance > 0.6 || self.health == 600)
		M_SetAnimation(self, shambler_attack_smash);
	else if (chance > 0.3)
		M_SetAnimation(self, shambler_attack_swingl);
	else
		M_SetAnimation(self, shambler_attack_swingr);
}

//
// death
//

void shambler_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -0 };
	monster_dead(self);
}

void shambler_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> shambler_frames_death = {
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0, shambler_shrink),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0),
	mframe_t(ai_move, 0), // FIXME: thud?
};
const mmove_t shambler_move_death = mmove_t(shambler::frames::death01, shambler::frames::death11, shambler_frames_death, shambler_dead);

void shambler_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
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

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
		// FIXME: better gibs for shambler, shambler head
		ThrowGibs(self, damage, {
			gib_def_t("models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/objects/gibs/chest/tris.md2"),
			gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, shambler::sounds::die, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	M_SetAnimation(self, shambler_move_death);
}

void SP_monster_shambler(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.e.s.modelindex = gi_modelindex("models/monsters/shambler/tris.md2");
	self.e.mins = { -32, -32, -24 };
	self.e.maxs = { 32, 32, 64 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	gi_modelindex("models/proj/lightning/tris.md2");
	shambler::sounds::pain.precache();
	shambler::sounds::idle.precache();
	shambler::sounds::die.precache();
	shambler::sounds::windup.precache();
	shambler::sounds::melee1.precache();
	shambler::sounds::melee2.precache();
	shambler::sounds::sight.precache();
	shambler::sounds::smack.precache();
	shambler::sounds::boom.precache();

	self.health = int(600 * st.health_multiplier);
	self.gib_health = -60;

	self.mass = 500;

	@self.pain = shambler_pain;
	@self.die = shambler_die;
	@self.monsterinfo.stand = shambler_stand;
	@self.monsterinfo.walk = shambler_walk;
	@self.monsterinfo.run = shambler_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = shambler_attack;
	@self.monsterinfo.melee = shambler_melee;
	@self.monsterinfo.sight = shambler_sight;
	@self.monsterinfo.idle = shambler_idle;
	@self.monsterinfo.blocked = null;
	@self.monsterinfo.setskin = shambler_setskin;

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::shambler::PRECISE))
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	M_SetAnimation(self, shambler_move_stand);
	self.monsterinfo.scale = shambler::SCALE;

	walkmonster_start(self);
}
