namespace gladiator
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
        run1,
        run2,
        run3,
        run4,
        run5,
        run6,
        melee1,
        melee2,
        melee3,
        melee4,
        melee5,
        melee6,
        melee7,
        melee8,
        melee9,
        melee10,
        melee11,
        melee12,
        melee13,
        melee14,
        melee15,
        melee16,
        melee17,
        attack1,
        attack2,
        attack3,
        attack4,
        attack5,
        attack6,
        attack7,
        attack8,
        attack9,
        pain1,
        pain2,
        pain3,
        pain4,
        pain5,
        pain6,
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
        death14,
        death15,
        death16,
        death17,
        death18,
        death19,
        death20,
        death21,
        death22,
        painup1,
        painup2,
        painup3,
        painup4,
        painup5,
        painup6,
        painup7
    };

    const float SCALE = 1.000000f;
}

namespace gladiator::sounds
{
    cached_soundindex pain1("gladiator/pain.wav");
    cached_soundindex pain2("gladiator/gldpain2.wav");
    cached_soundindex die("gladiator/glddeth2.wav");
    cached_soundindex die2("gladiator/death.wav");
    cached_soundindex gun("gladiator/railgun.wav");
    cached_soundindex gunb("weapons/plasshot.wav");
    cached_soundindex cleaver_swing("gladiator/melee1.wav");
    cached_soundindex cleaver_hit("gladiator/melee2.wav");
    cached_soundindex cleaver_miss("gladiator/melee3.wav");
    cached_soundindex idle("gladiator/gldidle1.wav");
    cached_soundindex search("gladiator/gldsrch1.wav");
    cached_soundindex sight("gladiator/sight.wav");
}

void gladiator_idle(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::idle, 1, ATTN_IDLE, 0);
}

void gladiator_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::sight, 1, ATTN_NORM, 0);
}

void gladiator_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::search, 1, ATTN_NORM, 0);
}

void gladiator_cleaver_swing(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, gladiator::sounds::cleaver_swing, 1, ATTN_NORM, 0);
}

const array<mframe_t> gladiator_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t gladiator_move_stand = mmove_t(gladiator::frames::stand1, gladiator::frames::stand7, gladiator_frames_stand);

void gladiator_stand(ASEntity &self)
{
	M_SetAnimation(self, gladiator_move_stand);
}

const array<mframe_t> gladiator_frames_walk = {
	mframe_t(ai_walk, 15),
	mframe_t(ai_walk, 7),
	mframe_t(ai_walk, 6),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 2, monster_footstep),
	mframe_t(ai_walk),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 2, monster_footstep),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 1),
	mframe_t(ai_walk, 8)
};
const mmove_t gladiator_move_walk = mmove_t(gladiator::frames::walk1, gladiator::frames::walk16, gladiator_frames_walk);

void gladiator_walk(ASEntity &self)
{
	M_SetAnimation(self, gladiator_move_walk);
}

const array<mframe_t> gladiator_frames_run = {
	mframe_t(ai_run, 23),
	mframe_t(ai_run, 14),
	mframe_t(ai_run, 14, monster_footstep),
	mframe_t(ai_run, 21),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 13, monster_footstep)
};
const mmove_t gladiator_move_run = mmove_t(gladiator::frames::run1, gladiator::frames::run6, gladiator_frames_run);

void gladiator_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, gladiator_move_stand);
	else
		M_SetAnimation(self, gladiator_move_run);
}

void GladiatorMelee(ASEntity &self)
{
	const vec3_t aim(MELEE_DISTANCE, self.e.mins.x, -4);
	if (fire_hit(self, aim, irandom(20, 25), 300))
		gi_sound(self.e, soundchan_t::AUTO, gladiator::sounds::cleaver_hit, 1, ATTN_NORM, 0);
	else
	{
		gi_sound(self.e, soundchan_t::AUTO, gladiator::sounds::cleaver_miss, 1, ATTN_NORM, 0);
		self.monsterinfo.melee_debounce_time = level.time + time_sec(1.5);
	}
}

const array<mframe_t> gladiator_frames_attack_melee = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gladiator_cleaver_swing),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GladiatorMelee),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gladiator_cleaver_swing),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GladiatorMelee),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t gladiator_move_attack_melee = mmove_t(gladiator::frames::melee3, gladiator::frames::melee16, gladiator_frames_attack_melee, gladiator_run);

void gladiator_melee(ASEntity &self)
{
	M_SetAnimation(self, gladiator_move_attack_melee);
}

void GladiatorGun(ASEntity &self)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::GLADIATOR_RAILGUN_1], forward, right);

	// calc direction to where we targted
	dir = self.pos1 - start;
	dir.normalize();

	monster_fire_railgun(self, start, dir, 50, 100, monster_muzzle_t::GLADIATOR_RAILGUN_1);
}

const array<mframe_t> gladiator_frames_attack_gun = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GladiatorGun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_charge)
};
const mmove_t gladiator_move_attack_gun = mmove_t(gladiator::frames::attack1, gladiator::frames::attack9, gladiator_frames_attack_gun, gladiator_run);

// RAFAEL
void gladbGun(ASEntity &self)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::GLADIATOR_RAILGUN_1], forward, right);

	// calc direction to where we targeted
	dir = self.pos1 - start;
	dir.normalize();

	int damage = 35;
	int radius_damage = 45;

	if (self.e.s.frame > gladiator::frames::attack3)
	{
		damage /= 2;
		radius_damage /= 2;
	}

	fire_plasma(self, start, dir, damage, 725, radius_damage, radius_damage);

	// save for aiming the shot
	self.pos1 = self.enemy.e.s.origin;
	self.pos1[2] += self.enemy.viewheight;
}

void gladbGun_check(ASEntity &self)
{
	if (skill.integer == 3)
		gladbGun(self);
}

const array<mframe_t> gladb_frames_attack_gun = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gladbGun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gladbGun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, gladbGun_check)
};
const mmove_t gladb_move_attack_gun = mmove_t(gladiator::frames::attack1, gladiator::frames::attack9, gladb_frames_attack_gun, gladiator_run);
// RAFAEL

void gladiator_attack(ASEntity &self)
{
	float  range;
	vec3_t v;

	// a small safe zone
	v = self.e.s.origin - self.enemy.e.s.origin;
	range = v.length();
	if (range <= (MELEE_DISTANCE + 32) && self.monsterinfo.melee_debounce_time <= level.time)
		return;
	else if (!M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GLADIATOR_RAILGUN_1]))
		return;

	// charge up the railgun
	self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	self.pos1[2] += self.enemy.viewheight;
	// RAFAEL
	if (self.style == 1)
	{
		gi_sound(self.e, soundchan_t::WEAPON, gladiator::sounds::gunb, 1, ATTN_NORM, 0);
		M_SetAnimation(self, gladb_move_attack_gun);
	}
	else
	{
		// RAFAEL
		gi_sound(self.e, soundchan_t::WEAPON, gladiator::sounds::gun, 1, ATTN_NORM, 0);
		M_SetAnimation(self, gladiator_move_attack_gun);
		// RAFAEL
	}
	// RAFAEL
}

const array<mframe_t> gladiator_frames_pain = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gladiator_move_pain = mmove_t(gladiator::frames::pain2, gladiator::frames::pain5, gladiator_frames_pain, gladiator_run);

const array<mframe_t> gladiator_frames_pain_air = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gladiator_move_pain_air = mmove_t(gladiator::frames::painup2, gladiator::frames::painup6, gladiator_frames_pain_air, gladiator_run);

void gladiator_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
	{
		if ((self.velocity[2] > 100) && (self.monsterinfo.active_move is gladiator_move_pain))
			M_SetAnimation(self, gladiator_move_pain_air);
		return;
	}

	self.pain_debounce_time = level.time + time_sec(3);

	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::pain2, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (self.velocity[2] > 100)
		M_SetAnimation(self, gladiator_move_pain_air);
	else
		M_SetAnimation(self, gladiator_move_pain);
}

void gladiator_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void gladiator_shrink(ASEntity &self)
{
	self.e.maxs[2] = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> gladiator_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, gladiator_shrink),
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
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t gladiator_move_death = mmove_t(gladiator::frames::death2, gladiator::frames::death22, gladiator_frames_death, gladiator_dead);

void gladiator_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(2, "models/monsters/gladiatr/gibs/thigh.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/gladiatr/gibs/larm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gladiatr/gibs/rarm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gladiatr/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/gladiatr/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::BODY, gladiator::sounds::die, 1, ATTN_NORM, 0);

	if (brandom())
		gi_sound(self.e, soundchan_t::VOICE, gladiator::sounds::die2, 1, ATTN_NORM, 0);

	self.deadflag = true;
	self.takedamage = true;

	M_SetAnimation(self, gladiator_move_death);
}

//===========
// PGM
bool gladiator_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

/*QUAKED monster_gladiator (1 .5 0) (-32 -32 -24) (32 32 64) Ambush Trigger_Spawn Sight
 */
void SP_monster_gladiator(ASEntity &self)
{
	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	gladiator::sounds::pain1.precache();
	gladiator::sounds::pain2.precache();
	gladiator::sounds::die.precache();
	gladiator::sounds::die2.precache();
	gladiator::sounds::cleaver_swing.precache();
	gladiator::sounds::cleaver_hit.precache();
	gladiator::sounds::cleaver_miss.precache();
	gladiator::sounds::idle.precache();
	gladiator::sounds::search.precache();
	gladiator::sounds::sight.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/gladiatr/tris.md2");
	
	gi_modelindex("models/monsters/gladiatr/gibs/chest.md2");
	gi_modelindex("models/monsters/gladiatr/gibs/head.md2");
	gi_modelindex("models/monsters/gladiatr/gibs/larm.md2");
	gi_modelindex("models/monsters/gladiatr/gibs/rarm.md2");
	gi_modelindex("models/monsters/gladiatr/gibs/thigh.md2");

	const spawn_temp_t @st = ED_GetSpawnTemp();

	// RAFAEL
	if (self.classname == "monster_gladb")
	{
		gladiator::sounds::gunb.precache();

		self.health = int(250 * st.health_multiplier);
		self.mass = 350;

		if (!st.was_key_specified("power_armor_type"))
			self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
		if (!st.was_key_specified("power_armor_power"))
			self.monsterinfo.power_armor_power = 250;

		self.e.s.skinnum = 2;

		self.style = 1;

		self.monsterinfo.weapon_sound = gi_soundindex("weapons/phaloop.wav");
	}
	else
	{
		// RAFAEL
		gladiator::sounds::gun.precache();

		self.health = int(400 * st.health_multiplier);
		self.mass = 400;
		// RAFAEL

		self.monsterinfo.weapon_sound = gi_soundindex("weapons/rg_hum.wav");
	}
	// RAFAEL

	self.gib_health = -175;

	self.e.mins = { -32, -32, -24 };
	self.e.maxs = { 32, 32, 42 };

	@self.pain = gladiator_pain;
	@self.die = gladiator_die;

	@self.monsterinfo.stand = gladiator_stand;
	@self.monsterinfo.walk = gladiator_walk;
	@self.monsterinfo.run = gladiator_run;
	@self.monsterinfo.dodge = null;
	@self.monsterinfo.attack = gladiator_attack;
	@self.monsterinfo.melee = gladiator_melee;
	@self.monsterinfo.sight = gladiator_sight;
	@self.monsterinfo.idle = gladiator_idle;
	@self.monsterinfo.search = gladiator_search;
	@self.monsterinfo.blocked = gladiator_blocked; // PGM
	@self.monsterinfo.setskin = setskin_basic;

	gi_linkentity(self.e);
	M_SetAnimation(self, gladiator_move_stand);
	self.monsterinfo.scale = gladiator::SCALE;

	walkmonster_start(self);
}

//
// monster_gladb
// RAFAEL
//
/*QUAKED monster_gladb (1 .5 0) (-32 -32 -24) (32 32 64) Ambush Trigger_Spawn Sight
 */
void SP_monster_gladb(ASEntity &self)
{
	SP_monster_gladiator(self);
}