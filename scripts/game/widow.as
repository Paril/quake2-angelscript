// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

black widow

==============================================================================
*/

// self.timestamp used to prevent rapid fire of railgun
// self.plat2flags used for fire count (flashes)

namespace widow
{
    enum frames
    {
        idle01,
        idle02,
        idle03,
        idle04,
        idle05,
        idle06,
        idle07,
        idle08,
        idle09,
        idle10,
        idle11,
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
        run01,
        run02,
        run03,
        run04,
        run05,
        run06,
        run07,
        run08,
        firea01,
        firea02,
        firea03,
        firea04,
        firea05,
        firea06,
        firea07,
        firea08,
        firea09,
        fireb01,
        fireb02,
        fireb03,
        fireb04,
        fireb05,
        fireb06,
        fireb07,
        fireb08,
        fireb09,
        firec01,
        firec02,
        firec03,
        firec04,
        firec05,
        firec06,
        firec07,
        firec08,
        firec09,
        fired01,
        fired02,
        fired02a,
        fired03,
        fired04,
        fired05,
        fired06,
        fired07,
        fired08,
        fired09,
        fired10,
        fired11,
        fired12,
        fired13,
        fired14,
        fired15,
        fired16,
        fired17,
        fired18,
        fired19,
        fired20,
        fired21,
        fired22,
        spawn01,
        spawn02,
        spawn03,
        spawn04,
        spawn05,
        spawn06,
        spawn07,
        spawn08,
        spawn09,
        spawn10,
        spawn11,
        spawn12,
        spawn13,
        spawn14,
        spawn15,
        spawn16,
        spawn17,
        spawn18,
        pain01,
        pain02,
        pain03,
        pain04,
        pain05,
        pain06,
        pain07,
        pain08,
        pain09,
        pain10,
        pain11,
        pain12,
        pain13,
        pain201,
        pain202,
        pain203,
        transa01,
        transa02,
        transa03,
        transa04,
        transa05,
        transb01,
        transb02,
        transb03,
        transb04,
        transb05,
        transc01,
        transc02,
        transc03,
        transc04,
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
        kick01,
        kick02,
        kick03,
        kick04,
        kick05,
        kick06,
        kick07,
        kick08
    };

    const float SCALE = 2.000000f;
}

const gtime_t RAIL_TIME = time_sec(3);
const gtime_t BLASTER_TIME = time_sec(2);
const int	  BLASTER2_DAMAGE = 10;
const int	  WIDOW_RAIL_DAMAGE = 50;

namespace widow::sounds
{
    cached_soundindex pain1("widow/bw1pain1.wav");
    cached_soundindex pain2("widow/bw1pain2.wav");
    cached_soundindex pain3("widow/bw1pain3.wav");
    cached_soundindex rail("gladiator/railgun.wav");
}

namespace widow
{
    // AS_TODO: move to local
    uint shotsfired;

    const array<vec3_t> spawnpoints = {
        vec3_t(30, 100, 16),
        vec3_t(30, -100, 16)
    };

    const array<vec3_t> beameffects = {
        { 12.58f, -43.71f, 68.88f },
        { 3.43f, 58.72f, 68.41f }
    };

    const array<float> sweep_angles = {
        32.f, 26.f, 20.f, 10.f, 0.f, -6.5f, -13.f, -27.f, -41.f
    };

    const vec3_t stalker_mins = { -28, -28, -18 };
    const vec3_t stalker_maxs = { 28, 28, 18 };

    uint widow_damage_multiplier;
}

void widow_search(ASEntity &self)
{
}

void widow_sight(ASEntity &self, ASEntity &other)
{
	self.monsterinfo.fire_wait = time_zero;
}

float target_angle(ASEntity &self)
{
	vec3_t target;
	float  enemy_yaw;

	target = self.e.s.origin - self.enemy.e.s.origin;
	enemy_yaw = self.e.s.angles.yaw - vectoyaw(target);
	if (enemy_yaw < 0)
		enemy_yaw += 360.0f;

	// this gets me 0 degrees = forward
	enemy_yaw -= 180.0f;
	// positive is to right, negative to left

	return enemy_yaw;
}

int WidowTorso(ASEntity &self)
{
	float enemy_yaw = target_angle(self);

	if (enemy_yaw >= 105)
	{
		M_SetAnimation(self, widow_move_attack_post_blaster_r);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		return 0;
	}

	if (enemy_yaw <= -75.0f)
	{
		M_SetAnimation(self, widow_move_attack_post_blaster_l);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		return 0;
	}

	if (enemy_yaw >= 95)
		return widow::frames::fired03;
	else if (enemy_yaw >= 85)
		return widow::frames::fired04;
	else if (enemy_yaw >= 75)
		return widow::frames::fired05;
	else if (enemy_yaw >= 65)
		return widow::frames::fired06;
	else if (enemy_yaw >= 55)
		return widow::frames::fired07;
	else if (enemy_yaw >= 45)
		return widow::frames::fired08;
	else if (enemy_yaw >= 35)
		return widow::frames::fired09;
	else if (enemy_yaw >= 25)
		return widow::frames::fired10;
	else if (enemy_yaw >= 15)
		return widow::frames::fired11;
	else if (enemy_yaw >= 5)
		return widow::frames::fired12;
	else if (enemy_yaw >= -5)
		return widow::frames::fired13;
	else if (enemy_yaw >= -15)
		return widow::frames::fired14;
	else if (enemy_yaw >= -25)
		return widow::frames::fired15;
	else if (enemy_yaw >= -35)
		return widow::frames::fired16;
	else if (enemy_yaw >= -45)
		return widow::frames::fired17;
	else if (enemy_yaw >= -55)
		return widow::frames::fired18;
	else if (enemy_yaw >= -65)
		return widow::frames::fired19;
	else if (enemy_yaw >= -75)
		return widow::frames::fired20;

	return 0;
}

const float VARIANCE = 15.0f;

void WidowBlaster(ASEntity &self)
{
	vec3_t					 forward, right, target, vec, targ_angles;
	vec3_t					 start;
	monster_muzzle_t flashnum;
	effects_t				 effect;

	if (self.enemy is null)
		return;

	widow::shotsfired++;
	if ((widow::shotsfired % 4) == 0)
		effect = effects_t::BLASTER;
	else
		effect = effects_t::NONE;

	AngleVectors(self.e.s.angles, forward, right);
	if ((self.e.s.frame >= widow::frames::spawn05) && (self.e.s.frame <= widow::frames::spawn13))
	{
		// sweep
		flashnum = monster_muzzle_t(monster_muzzle_t::WIDOW_BLASTER_SWEEP1 + self.e.s.frame - widow::frames::spawn05);
		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flashnum], forward, right);
		target = self.enemy.e.s.origin - start;
		targ_angles = vectoangles(target);

		vec = self.e.s.angles;

		vec.pitch += targ_angles.pitch;
		vec.yaw -= widow::sweep_angles[flashnum - monster_muzzle_t::WIDOW_BLASTER_SWEEP1];

		AngleVectors(vec, forward);
		monster_fire_blaster2(self, start, forward, BLASTER2_DAMAGE * widow::widow_damage_multiplier, 1000, flashnum, effect);
	}
	else if ((self.e.s.frame >= widow::frames::fired02a) && (self.e.s.frame <= widow::frames::fired20))
	{
		vec3_t angles;
		float  aim_angle, target_angle;
		float  error;

		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);

		self.monsterinfo.nextframe = WidowTorso(self);

		if (self.monsterinfo.nextframe == 0)
			self.monsterinfo.nextframe = self.e.s.frame;

		if (self.e.s.frame == widow::frames::fired02a)
			flashnum = monster_muzzle_t::WIDOW_BLASTER_0;
		else
			flashnum = monster_muzzle_t(monster_muzzle_t::WIDOW_BLASTER_100 + self.e.s.frame - widow::frames::fired03);

		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flashnum], forward, right);

		PredictAim(self, self.enemy, start, 1000, true, crandom() * 0.1f, forward);

		// clamp it to within 10 degrees of the aiming angle (where she's facing)
		angles = vectoangles(forward);
		// give me 100 . -70
		aim_angle = float(100 - (10 * (flashnum - monster_muzzle_t::WIDOW_BLASTER_100)));
		if (aim_angle <= 0)
			aim_angle += 360;
		target_angle = self.e.s.angles.yaw - angles.yaw;
		if (target_angle <= 0)
			target_angle += 360;

		error = aim_angle - target_angle;

		// positive error is to entity's left, aka positive direction in engine
		// unfortunately, I decided that for the aim_angle, positive was right.  *sigh*
		if (error > VARIANCE)
		{
			angles.yaw = (self.e.s.angles.yaw - aim_angle) + VARIANCE;
			AngleVectors(angles, forward);
		}
		else if (error < -VARIANCE)
		{
			angles.yaw = (self.e.s.angles.yaw - aim_angle) - VARIANCE;
			AngleVectors(angles, forward);
		}

		monster_fire_blaster2(self, start, forward, BLASTER2_DAMAGE * widow::widow_damage_multiplier, 1000, flashnum, effect);
	}
	else if ((self.e.s.frame >= widow::frames::run01) && (self.e.s.frame <= widow::frames::run08))
	{
		flashnum = monster_muzzle_t(monster_muzzle_t::WIDOW_RUN_1 + self.e.s.frame - widow::frames::run01);
		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flashnum], forward, right);

		target = self.enemy.e.s.origin - start;
		target[2] += self.enemy.viewheight;
		target.normalize();

		monster_fire_blaster2(self, start, target, BLASTER2_DAMAGE * widow::widow_damage_multiplier, 1000, flashnum, effect);
	}
}

void WidowSpawn(ASEntity &self)
{
	vec3_t	 f, r, u, offset, startpoint, spawnpoint;
	ASEntity @ent, designated_enemy;
	int		 i;

	AngleVectors(self.e.s.angles, f, r, u);

	for (i = 0; i < 2; i++)
	{
		offset = widow::spawnpoints[i];

		startpoint = G_ProjectSource2(self.e.s.origin, offset, f, r, u);

		if (FindSpawnPoint(startpoint, widow::stalker_mins, widow::stalker_maxs, spawnpoint, 64))
		{
			@ent = CreateGroundMonster(spawnpoint, self.e.s.angles, widow::stalker_mins, widow::stalker_maxs, "monster_stalker", 256);

			if (ent is null)
				continue;

			self.monsterinfo.monster_used++;
			@ent.monsterinfo.commander = self;
			ent.monsterinfo.slots_from_commander = 1;

			ent.nextthink = level.time;
			ent.think(ent);

			ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::SPAWNED_COMMANDER | ai_flags_t::DO_NOT_COUNT | ai_flags_t::IGNORE_SHOTS);

			if (coop.integer == 0)
			{
				@designated_enemy = self.enemy;
			}
			else
			{
				@designated_enemy = PickCoopTarget(ent);
				if (designated_enemy !is null)
				{
					// try to avoid using my enemy
					if (designated_enemy is self.enemy)
					{
						@designated_enemy = PickCoopTarget(ent);
						if (designated_enemy is null)
							@designated_enemy = self.enemy;
					}
				}
				else
					@designated_enemy = self.enemy;
			}

			if ((designated_enemy.e.inuse) && (designated_enemy.health > 0))
			{
				@ent.enemy = designated_enemy;
				FoundTarget(ent);
				ent.monsterinfo.attack(ent);
			}
		}
	}
}

void widow_spawn_check(ASEntity &self)
{
	WidowBlaster(self);
	WidowSpawn(self);
}

void widow_ready_spawn(ASEntity &self)
{
	vec3_t f, r, u, offset, startpoint, spawnpoint;
	int	   i;

	WidowBlaster(self);
	AngleVectors(self.e.s.angles, f, r, u);

	for (i = 0; i < 2; i++)
	{
		offset = widow::spawnpoints[i];
		startpoint = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		if (FindSpawnPoint(startpoint, widow::stalker_mins, widow::stalker_maxs, spawnpoint, 64))
		{
			float radius = (widow::stalker_maxs - widow::stalker_mins).length() * 0.5f;

			SpawnGrow_Spawn(spawnpoint + (widow::stalker_mins + widow::stalker_maxs), radius, radius * 2.f);
		}
	}
}

void widow_step(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("widow/bwstep3.wav"), 1, ATTN_NORM, 0);
}

const array<mframe_t> widow_frames_stand = {
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
const mmove_t widow_move_stand = mmove_t(widow::frames::idle01, widow::frames::idle11, widow_frames_stand, null);

const array<mframe_t> widow_frames_walk = {
	mframe_t(ai_walk, 2.79f, widow_step),
	mframe_t(ai_walk, 2.77f),
	mframe_t(ai_walk, 3.53f),
	mframe_t(ai_walk, 3.97f),
	mframe_t(ai_walk, 4.13f), // 5
	mframe_t(ai_walk, 4.09f),
	mframe_t(ai_walk, 3.84f),
	mframe_t(ai_walk, 3.62f, widow_step),
	mframe_t(ai_walk, 3.29f),
	mframe_t(ai_walk, 6.08f), // 10
	mframe_t(ai_walk, 6.94f),
	mframe_t(ai_walk, 5.73f),
	mframe_t(ai_walk, 2.85f)
};
const mmove_t widow_move_walk = mmove_t(widow::frames::walk01, widow::frames::walk13, widow_frames_walk, null);

const array<mframe_t> widow_frames_run = {
	mframe_t(ai_run, 2.79f, widow_step),
	mframe_t(ai_run, 2.77f),
	mframe_t(ai_run, 3.53f),
	mframe_t(ai_run, 3.97f),
	mframe_t(ai_run, 4.13f), // 5
	mframe_t(ai_run, 4.09f),
	mframe_t(ai_run, 3.84f),
	mframe_t(ai_run, 3.62f, widow_step),
	mframe_t(ai_run, 3.29f),
	mframe_t(ai_run, 6.08f), // 10
	mframe_t(ai_run, 6.94f),
	mframe_t(ai_run, 5.73f),
	mframe_t(ai_run, 2.85f)
};
const mmove_t widow_move_run = mmove_t(widow::frames::walk01, widow::frames::walk13, widow_frames_run, null);

void widow_stepshoot(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("widow/bwstep2.wav"), 1, ATTN_NORM, 0);
	WidowBlaster(self);
}

const array<mframe_t> widow_frames_run_attack = {
	mframe_t(ai_charge, 13, widow_stepshoot),
	mframe_t(ai_charge, 11.72f, WidowBlaster),
	mframe_t(ai_charge, 18.04f, WidowBlaster),
	mframe_t(ai_charge, 14.58f, WidowBlaster),
	mframe_t(ai_charge, 13, widow_stepshoot), // 5
	mframe_t(ai_charge, 12.12f, WidowBlaster),
	mframe_t(ai_charge, 19.63f, WidowBlaster),
	mframe_t(ai_charge, 11.37f, WidowBlaster)
};
const mmove_t widow_move_run_attack = mmove_t(widow::frames::run01, widow::frames::run08, widow_frames_run_attack, widow_run);

//
// These three allow specific entry into the run sequence
//

void widow_start_run_5(ASEntity &self)
{
	M_SetAnimation(self, widow_move_run);
	self.monsterinfo.nextframe = widow::frames::walk05;
}

void widow_start_run_10(ASEntity &self)
{
	M_SetAnimation(self, widow_move_run);
	self.monsterinfo.nextframe = widow::frames::walk10;
}

void widow_start_run_12(ASEntity &self)
{
	M_SetAnimation(self, widow_move_run);
	self.monsterinfo.nextframe = widow::frames::walk12;
}

const array<mframe_t> widow_frames_attack_pre_blaster = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_attack_blaster)
};
const mmove_t widow_move_attack_pre_blaster = mmove_t(widow::frames::fired01, widow::frames::fired02a, widow_frames_attack_pre_blaster, null);

// Loop this
const array<mframe_t> widow_frames_attack_blaster = {
	mframe_t(ai_charge, 0, widow_reattack_blaster), // straight ahead
	mframe_t(ai_charge, 0, widow_reattack_blaster), // 100 degrees right
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster), // 50 degrees right
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster), // straight
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster), // 50 degrees left
	mframe_t(ai_charge, 0, widow_reattack_blaster),
	mframe_t(ai_charge, 0, widow_reattack_blaster) // 70 degrees left
};
const mmove_t widow_move_attack_blaster = mmove_t(widow::frames::fired02a, widow::frames::fired20, widow_frames_attack_blaster, null);

const array<mframe_t> widow_frames_attack_post_blaster = {
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t widow_move_attack_post_blaster = mmove_t(widow::frames::fired21, widow::frames::fired22, widow_frames_attack_post_blaster, widow_run);

const array<mframe_t> widow_frames_attack_post_blaster_r = {
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_start_run_12)
};
const mmove_t widow_move_attack_post_blaster_r = mmove_t(widow::frames::transa01, widow::frames::transa05, widow_frames_attack_post_blaster_r, null);

const array<mframe_t> widow_frames_attack_post_blaster_l = {
	mframe_t(ai_charge),
	mframe_t(ai_charge, 14),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, 10),
	mframe_t(ai_charge, 10, widow_start_run_12)
};
const mmove_t widow_move_attack_post_blaster_l = mmove_t(widow::frames::transb01, widow::frames::transb05, widow_frames_attack_post_blaster_l, null);

void WidowRail(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 dir;
	vec3_t					 forward, right;
	monster_muzzle_t flash;

	AngleVectors(self.e.s.angles, forward, right);

	if (self.monsterinfo.active_move is widow_move_attack_rail_l)
	{
		flash = monster_muzzle_t::WIDOW_RAIL_LEFT;
	}
	else if (self.monsterinfo.active_move is widow_move_attack_rail_r)
	{
		flash = monster_muzzle_t::WIDOW_RAIL_RIGHT;
	}
	else
		flash = monster_muzzle_t::WIDOW_RAIL;

	start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flash], forward, right);

	// calc direction to where we targeted
	dir = self.pos1 - start;
	dir.normalize();

	monster_fire_railgun(self, start, dir, WIDOW_RAIL_DAMAGE * widow::widow_damage_multiplier, 100, flash);
	self.timestamp = level.time + RAIL_TIME;
}

void WidowSaveLoc(ASEntity &self)
{
	self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	self.pos1[2] += self.enemy.viewheight;
};

void widow_start_rail(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
}

void widow_rail_done(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
}

const array<mframe_t> widow_frames_attack_pre_rail = {
	mframe_t(ai_charge, 0, widow_start_rail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_attack_rail)
};
const mmove_t widow_move_attack_pre_rail = mmove_t(widow::frames::transc01, widow::frames::transc04, widow_frames_attack_pre_rail, null);

const array<mframe_t> widow_frames_attack_rail = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, WidowSaveLoc),
	mframe_t(ai_charge, -10, WidowRail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_rail_done)
};
const mmove_t widow_move_attack_rail = mmove_t(widow::frames::firea01, widow::frames::firea09, widow_frames_attack_rail, widow_run);

const array<mframe_t> widow_frames_attack_rail_r = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, WidowSaveLoc),
	mframe_t(ai_charge, -10, WidowRail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_rail_done)
};
const mmove_t widow_move_attack_rail_r = mmove_t(widow::frames::fireb01, widow::frames::fireb09, widow_frames_attack_rail_r, widow_run);

const array<mframe_t> widow_frames_attack_rail_l = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, WidowSaveLoc),
	mframe_t(ai_charge, -10, WidowRail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_rail_done)
};
const mmove_t widow_move_attack_rail_l = mmove_t(widow::frames::firec01, widow::frames::firec09, widow_frames_attack_rail_l, widow_run);

void widow_attack_rail(ASEntity &self)
{
	float enemy_angle;

	enemy_angle = target_angle(self);

	if (enemy_angle < -15)
		M_SetAnimation(self, widow_move_attack_rail_l);
	else if (enemy_angle > 15)
		M_SetAnimation(self, widow_move_attack_rail_r);
	else
		M_SetAnimation(self, widow_move_attack_rail);
}

void widow_start_spawn(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
}

void widow_done_spawn(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
}

const array<mframe_t> widow_frames_spawn = {
	mframe_t(ai_charge), // 1
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_start_spawn),
	mframe_t(ai_charge),						 // 5
	mframe_t(ai_charge, 0, WidowBlaster),		 // 6
	mframe_t(ai_charge, 0, widow_ready_spawn), // 7
	mframe_t(ai_charge, 0, WidowBlaster),
	mframe_t(ai_charge, 0, WidowBlaster), // 9
	mframe_t(ai_charge, 0, widow_spawn_check),
	mframe_t(ai_charge, 0, WidowBlaster), // 11
	mframe_t(ai_charge, 0, WidowBlaster),
	mframe_t(ai_charge, 0, WidowBlaster), // 13
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow_done_spawn)
};
const mmove_t widow_move_spawn = mmove_t(widow::frames::spawn01, widow::frames::spawn18, widow_frames_spawn, widow_run);

const array<mframe_t> widow_frames_pain_heavy = {
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
const mmove_t widow_move_pain_heavy = mmove_t(widow::frames::pain01, widow::frames::pain13, widow_frames_pain_heavy, widow_run);

const array<mframe_t> widow_frames_pain_light = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t widow_move_pain_light = mmove_t(widow::frames::pain201, widow::frames::pain203, widow_frames_pain_light, widow_run);

void spawn_out_start(ASEntity &self)
{
	vec3_t startpoint, f, r, u;

	//	gi.sound (self, soundchan_t::VOICE, widow::sounds::death, 1, ATTN_NONE, 0);
	AngleVectors(self.e.s.angles, f, r, u);

	startpoint = G_ProjectSource2(self.e.s.origin, widow::beameffects[0], f, r, u);
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WIDOWBEAMOUT);
	gi_WriteShort(20001);
	gi_WritePosition(startpoint);
	gi_multicast(startpoint, multicast_t::ALL, false);

	startpoint = G_ProjectSource2(self.e.s.origin, widow::beameffects[1], f, r, u);
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WIDOWBEAMOUT);
	gi_WriteShort(20002);
	gi_WritePosition(startpoint);
	gi_multicast(startpoint, multicast_t::ALL, false);

	gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/bwidowbeamout.wav"), 1, ATTN_NORM, 0);
}

void spawn_out_do(ASEntity &self)
{
	vec3_t startpoint, f, r, u;

	AngleVectors(self.e.s.angles, f, r, u);
	startpoint = G_ProjectSource2(self.e.s.origin, widow::beameffects[0], f, r, u);
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WIDOWSPLASH);
	gi_WritePosition(startpoint);
	gi_multicast(startpoint, multicast_t::ALL, false);

	startpoint = G_ProjectSource2(self.e.s.origin, widow::beameffects[1], f, r, u);
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WIDOWSPLASH);
	gi_WritePosition(startpoint);
	gi_multicast(startpoint, multicast_t::ALL, false);

	startpoint = self.e.s.origin;
	startpoint[2] += 36;
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::BOSSTPORT);
	gi_WritePosition(startpoint);
	gi_multicast(startpoint, multicast_t::PHS, false);

	Widowlegs_Spawn(self.e.s.origin, self.e.s.angles);

	G_FreeEdict(self);
}

const array<mframe_t> widow_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 5
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, spawn_out_start), // 10
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 15
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 20
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 25
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 30
	mframe_t(ai_move, 0, spawn_out_do)
};
const mmove_t widow_move_death = mmove_t(widow::frames::death01, widow::frames::death31, widow_frames_death, null);

void widow_attack_kick(ASEntity &self)
{
	vec3_t aim = { 100, 0, 4 };
	if (self.enemy.groundentity !is null)
		fire_hit(self, aim, irandom(50, 56), 500);
	else // not as much kick if they're in the air .. makes it harder to land on her head
		fire_hit(self, aim, irandom(50, 56), 250);
}

const array<mframe_t> widow_frames_attack_kick = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, widow_attack_kick),
	mframe_t(ai_move), // 5
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};

const mmove_t widow_move_attack_kick = mmove_t(widow::frames::kick01, widow::frames::kick08, widow_frames_attack_kick, widow_run);

void widow_stand(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, gi_soundindex("widow/laugh.wav"), 1, ATTN_NORM, 0);
	M_SetAnimation(self, widow_move_stand);
}

void widow_run(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, widow_move_stand);
	else
		M_SetAnimation(self, widow_move_run);
}

void widow_walk(ASEntity &self)
{
	M_SetAnimation(self, widow_move_walk);
}

void widow_attack(ASEntity &self)
{
	float luck;
	bool  rail_frames = false, blaster_frames = false, blocked = false, anger = false;

	@self.movetarget = null;

	if ((self.monsterinfo.aiflags & ai_flags_t::BLOCKED) != 0)
	{
		blocked = true;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
	}

	if ((self.monsterinfo.aiflags & ai_flags_t::TARGET_ANGER) != 0)
	{
		anger = true;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TARGET_ANGER);
	}

	if ((self.enemy is null) || (!self.enemy.e.inuse))
		return;

	if (self.bad_area !is null)
	{
		if ((frandom() < 0.1f) || (level.time < self.timestamp))
			M_SetAnimation(self, widow_move_attack_pre_blaster);
		else
		{
			gi_sound(self.e, soundchan_t::WEAPON, widow::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, widow_move_attack_pre_rail);
		}
		return;
	}

	// frames widow::frames::walk13, widow::frames::walk01, widow::frames::walk02, widow::frames::walk03 are rail gun start frames
	// frames widow::frames::walk09, widow::frames::walk10, widow::frames::walk11, widow::frames::walk12 are spawn & blaster start frames

	if ((self.e.s.frame == widow::frames::walk13) || ((self.e.s.frame >= widow::frames::walk01) && (self.e.s.frame <= widow::frames::walk03)))
		rail_frames = true;

	if ((self.e.s.frame >= widow::frames::walk09) && (self.e.s.frame <= widow::frames::walk12))
		blaster_frames = true;

	WidowCalcSlots(self);

	// if we can't see the target, spawn stuff regardless of frame
	if ((self.monsterinfo.attack_state == ai_attack_state_t::BLIND) && (M_SlotsLeft(self) >= 2))
	{
		M_SetAnimation(self, widow_move_spawn);
		return;
	}

	// accept bias towards spawning regardless of frame
	if (blocked && (M_SlotsLeft(self) >= 2))
	{
		M_SetAnimation(self, widow_move_spawn);
		return;
	}

	if ((realrange(self, self.enemy) > 300) && (!anger) && (frandom() < 0.5f) && (!blocked))
	{
		M_SetAnimation(self, widow_move_run_attack);
		return;
	}

	if (blaster_frames)
	{
		if (M_SlotsLeft(self) >= 2)
		{
			M_SetAnimation(self, widow_move_spawn);
			return;
		}
		else if (self.monsterinfo.fire_wait + BLASTER_TIME <= level.time)
		{
			M_SetAnimation(self, widow_move_attack_pre_blaster);
			return;
		}
	}

	if (rail_frames)
	{
		if (!(level.time < self.timestamp))
		{
			gi_sound(self.e, soundchan_t::WEAPON, widow::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, widow_move_attack_pre_rail);
		}
	}

	if ((rail_frames) || (blaster_frames))
		return;

	luck = frandom();
	if (M_SlotsLeft(self) >= 2)
	{
		if ((luck <= 0.40f) && (self.monsterinfo.fire_wait + BLASTER_TIME <= level.time))
			M_SetAnimation(self, widow_move_attack_pre_blaster);
		else if ((luck <= 0.7f) && !(level.time < self.timestamp))
		{
			gi_sound(self.e, soundchan_t::WEAPON, widow::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, widow_move_attack_pre_rail);
		}
		else
			M_SetAnimation(self, widow_move_spawn);
	}
	else
	{
		if (level.time < self.timestamp)
			M_SetAnimation(self, widow_move_attack_pre_blaster);
		else if ((luck <= 0.50f) || (level.time + BLASTER_TIME >= self.monsterinfo.fire_wait))
		{
			gi_sound(self.e, soundchan_t::WEAPON, widow::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, widow_move_attack_pre_rail);
		}
		else // holdout to blaster
			M_SetAnimation(self, widow_move_attack_pre_blaster);
	}
}

void widow_attack_blaster(ASEntity &self)
{
	self.monsterinfo.fire_wait = level.time + random_time(time_sec(1), time_sec(3));
	M_SetAnimation(self, widow_move_attack_blaster);
	self.monsterinfo.nextframe = WidowTorso(self);
}

void widow_reattack_blaster(ASEntity &self)
{
	WidowBlaster(self);

	// if WidowBlaster bailed us out of the frames, just bail
	if ((self.monsterinfo.active_move is widow_move_attack_post_blaster_l) ||
		(self.monsterinfo.active_move is widow_move_attack_post_blaster_r))
		return;

	// if we're not done with the attack, don't leave the sequence
	if (self.monsterinfo.fire_wait >= level.time)
		return;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	M_SetAnimation(self, widow_move_attack_post_blaster);
}

void widow_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(5);

	if (damage < 15)
		gi_sound(self.e, soundchan_t::VOICE, widow::sounds::pain1, 1, ATTN_NONE, 0);
	else if (damage < 75)
		gi_sound(self.e, soundchan_t::VOICE, widow::sounds::pain2, 1, ATTN_NONE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, widow::sounds::pain3, 1, ATTN_NONE, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	self.monsterinfo.fire_wait = time_zero;

	if (damage >= 15)
	{
		if (damage < 75)
		{
			if ((skill.integer < 3) && (frandom() < (0.6f - (0.2f * skill.integer))))
			{
				M_SetAnimation(self, widow_move_pain_light);
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
			}
		}
		else
		{
			if ((skill.integer < 3) && (frandom() < (0.75f - (0.1f * skill.integer))))
			{
				M_SetAnimation(self, widow_move_pain_heavy);
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
			}
		}
	}
}

void widow_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void widow_dead(ASEntity &self)
{
	self.e.mins = { -56, -56, 0 };
	self.e.maxs = { 56, 56, 80 };
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.nextthink = time_zero;
	gi_linkentity(self.e);
}

void widow_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.deadflag = true;
	self.takedamage = false;
	self.count = 0;
	self.monsterinfo.quad_time = time_zero;
	self.monsterinfo.double_time = time_zero;
	self.monsterinfo.invincible_time = time_zero;
	M_SetAnimation(self, widow_move_death);
}

void widow_melee(ASEntity &self)
{
	//	monster_done_dodge (self);
	M_SetAnimation(self, widow_move_attack_kick);
}

void WidowGoinQuad(ASEntity &self, gtime_t time)
{
	self.monsterinfo.quad_time = time;
	widow::widow_damage_multiplier = 4;
}

void WidowDouble(ASEntity &self, gtime_t time)
{
	self.monsterinfo.double_time = time;
	widow::widow_damage_multiplier = 2;
}

void WidowPent(ASEntity &self, gtime_t time)
{
	self.monsterinfo.invincible_time = time;
}

void WidowPowerArmor(ASEntity &self)
{
	self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
	// I don't like this, but it works
	if (self.monsterinfo.power_armor_power <= 0)
		self.monsterinfo.power_armor_power += 250 * skill.integer;
}

void WidowRespondPowerup(ASEntity &self, ASEntity &other)
{
	if ((other.e.s.effects & effects_t::QUAD) != 0)
	{
		if (skill.integer == 1)
			WidowDouble(self, other.client.quad_time);
		else if (skill.integer == 2)
			WidowGoinQuad(self, other.client.quad_time);
		else if (skill.integer == 3)
		{
			WidowGoinQuad(self, other.client.quad_time);
			WidowPowerArmor(self);
		}
	}
	else if ((other.e.s.effects & effects_t::DOUBLE) != 0)
	{
		if (skill.integer == 2)
			WidowDouble(self, other.client.double_time);
		else if (skill.integer == 3)
		{
			WidowDouble(self, other.client.double_time);
			WidowPowerArmor(self);
		}
	}
	else
		widow::widow_damage_multiplier = 1;

	if ((other.e.s.effects & effects_t::PENT) != 0)
	{
		if (skill.integer == 1)
			WidowPowerArmor(self);
		else if (skill.integer == 2)
			WidowPent(self, other.client.invincible_time);
		else if (skill.integer == 3)
		{
			WidowPent(self, other.client.invincible_time);
			WidowPowerArmor(self);
		}
	}
}

void WidowPowerups(ASEntity &self)
{
	ASEntity @ent;

	if (coop.integer == 0)
	{
		WidowRespondPowerup(self, self.enemy);
	}
	else
	{
		// in coop, check for pents, then quads, then doubles
		for (uint player = 1; player <= max_clients; player++)
		{
			@ent = entities[player];
			if (!ent.e.inuse)
				continue;
			if (ent.client is null)
				continue;
			if ((ent.e.s.effects & (effects_t::PENT | effects_t::QUAD | effects_t::DOUBLE)) != 0)
			{
				WidowRespondPowerup(self, ent);
				return;
			}
		}
	}
}

bool Widow_CheckAttack(ASEntity &self)
{
	if (self.enemy is null)
		return false;

	WidowPowerups(self);

	if (self.monsterinfo.active_move is widow_move_run)
	{
		// if we're in run, make sure we're in a good frame for attacking before doing anything else
		// frames 1,2,3,9,10,11,13 good to fire
		switch (self.e.s.frame)
		{
		case widow::frames::walk04:
		case widow::frames::walk05:
		case widow::frames::walk06:
		case widow::frames::walk07:
		case widow::frames::walk08:
		case widow::frames::walk12:
			return false;
		default:
			break;
		}
	}

	// give a LARGE bias to spawning things when we have room
	// use ai_flags_t::BLOCKED as a signal to attack to spawn
	if ((frandom() < 0.8f) && (M_SlotsLeft(self) >= 2) && (realrange(self, self.enemy) > 150))
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		return true;
	}

	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.7f, 0.6f, 0.5f, 0.f);
}

bool widow_blocked(ASEntity &self, float dist)
{
	// if we get blocked while we're in our run/attack mode, turn on a meaningless (in this context)AI flag,
	// and call attack to get a new attack sequence.  make sure to turn it off when we're done.
	//
	// I'm using ai_flags_t::TARGET_ANGER for this purpose

	if (self.monsterinfo.active_move is widow_move_run_attack)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::TARGET_ANGER);
		if (self.monsterinfo.checkattack(self))
			self.monsterinfo.attack(self);
		else
			self.monsterinfo.run(self);
		return true;
	}

	return false;
}

// only meant to be used in coop
uint CountPlayers()
{
	ASEntity @ent;
	int		 count = 0;

	// if we're not in coop, this is a noop
	if (coop.integer == 0)
		return 1;

	for (uint player = 1; player <= max_clients; player++)
	{
		@ent = entities[player];
		if (!ent.e.inuse)
			continue;
		if (ent.client is null)
			continue;
		count++;
	}

	return count;
}

void WidowCalcSlots(ASEntity &self)
{
	switch (skill.integer)
	{
	case 0:
	case 1:
		self.monsterinfo.monster_slots = 3;
		break;
	case 2:
		self.monsterinfo.monster_slots = 4;
		break;
	case 3:
		self.monsterinfo.monster_slots = 6;
		break;
	default:
		self.monsterinfo.monster_slots = 3;
		break;
	}
	if (coop.integer != 0)
	{
		self.monsterinfo.monster_slots = min(6, self.monsterinfo.monster_slots + (skill.integer * (CountPlayers() - 1)));
	}
}

void WidowPrecache()
{
	// cache in all of the stalker stuff, widow stuff, spawngro stuff, gibs
	gi_soundindex("stalker/pain.wav");
	gi_soundindex("stalker/death.wav");
	gi_soundindex("stalker/sight.wav");
	gi_soundindex("stalker/melee1.wav");
	gi_soundindex("stalker/melee2.wav");
	gi_soundindex("stalker/idle.wav");

	gi_soundindex("tank/tnkatck3.wav");
	gi_modelindex("models/objects/laser/tris.md2");

	gi_modelindex("models/monsters/stalker/tris.md2");
	gi_modelindex("models/items/spawngro3/tris.md2");
	gi_modelindex("models/objects/gibs/sm_metal/tris.md2");
	gi_modelindex("models/objects/gibs/gear/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib1/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib2/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib3/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib4/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib1/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib2/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib3/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib4/tris.md2");
	gi_modelindex("models/monsters/legs/tris.md2");
	gi_soundindex("misc/bwidowbeamout.wav");

	gi_soundindex("misc/bigtele.wav");
	gi_soundindex("widow/bwstep3.wav");
	gi_soundindex("widow/bwstep2.wav");
	gi_soundindex("widow/bwstep1.wav");
}

/*QUAKED monster_widow (1 .5 0) (-40 -40 0) (40 40 144) Ambush Trigger_Spawn Sight
 */
void SP_monster_widow(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	widow::sounds::pain1.precache();
	widow::sounds::pain2.precache();
	widow::sounds::pain3.precache();
	widow::sounds::rail.precache();

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/blackwidow/tris.md2");
	self.e.mins = { -40, -40, 0 };
	self.e.maxs = { 40, 40, 144 };

	self.health = int((2000 + 1000 * skill.integer) * st.health_multiplier);
	if (coop.integer != 0)
		self.health += 500 * skill.integer;
	self.gib_health = -5000;
	self.mass = 1500;

	if (skill.integer == 3)
	{
		if (!st.was_key_specified("power_armor_type"))
			self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
		if (!st.was_key_specified("power_armor_power"))
			self.monsterinfo.power_armor_power = 500;
	}

	self.yaw_speed = 30;

	self.flags = ent_flags_t(self.flags | ent_flags_t::IMMUNE_LASER);
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	@self.pain = widow_pain;
	@self.die = widow_die;

	@self.monsterinfo.melee = widow_melee;
	@self.monsterinfo.stand = widow_stand;
	@self.monsterinfo.walk = widow_walk;
	@self.monsterinfo.run = widow_run;
	@self.monsterinfo.attack = widow_attack;
	@self.monsterinfo.search = widow_search;
	@self.monsterinfo.checkattack = Widow_CheckAttack;
	@self.monsterinfo.sight = widow_sight;
	@self.monsterinfo.setskin = widow_setskin;
	@self.monsterinfo.blocked = widow_blocked;

	gi_linkentity(self.e);

	M_SetAnimation(self, widow_move_stand);
	self.monsterinfo.scale = widow::SCALE;

	WidowPrecache();
	WidowCalcSlots(self);
	widow::widow_damage_multiplier = 1;

	walkmonster_start(self);
}