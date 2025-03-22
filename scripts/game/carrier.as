// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

/*
==============================================================================

carrier

==============================================================================
*/

// self.timestamp used for frame calculations in grenade & spawn code
// self.monsterinfo.fire_wait used to prevent rapid refire of rocket launcher

namespace carrier
{
    enum frames
    {
        search01,
        search02,
        search03,
        search04,
        search05,
        search06,
        search07,
        search08,
        search09,
        search10,
        search11,
        search12,
        search13,
        firea01,
        firea02,
        firea03,
        firea04,
        firea05,
        firea06,
        firea07,
        firea08,
        firea09,
        firea10,
        firea11,
        firea12,
        firea13,
        firea14,
        firea15,
        fireb01,
        fireb02,
        fireb03,
        fireb04,
        fireb05,
        fireb06,
        fireb07,
        fireb08,
        fireb09,
        fireb10,
        fireb11,
        fireb12,
        fireb13,
        fireb14,
        fireb15,
        fireb16,
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
        death16
    };

    const float SCALE = 1.000000f;
}

namespace carrier
{
    // nb: specifying flyer multiple times so it has a higher chance
    const string default_reinforcements = "monster_flyer 1;monster_flyer 1;monster_flyer 1;monster_kamikaze 1";
    const int default_monster_slots_base = 3;
}

const gtime_t CARRIER_ROCKET_TIME = time_sec(2); // number of seconds between rocket shots
const int CARRIER_ROCKET_SPEED = 750;
const gtime_t RAIL_FIRE_TIME = time_sec(3);

namespace carrier::sounds
{
    cached_soundindex pain1("carrier/pain_md.wav");
    cached_soundindex pain2("carrier/pain_lg.wav");
    cached_soundindex pain3("carrier/pain_sm.wav");
    cached_soundindex death("carrier/death.wav");
    cached_soundindex sight("gladiator/railgun.wav");
    cached_soundindex rail("carrier/sight.wav");
    cached_soundindex spawn("medic_commander/monsterspawn1.wav");

    cached_soundindex cg_down("weapons/chngnd1a.wav");
    cached_soundindex cg_loop("weapons/chngnl1a.wav");
    cached_soundindex cg_up("weapons/chngnu1a.wav");
}

// AS_TODO move this to an entity local
float orig_yaw_speed;

void carrier_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, carrier::sounds::sight, 1, ATTN_NORM, 0);
}

//
// this is the smarts for the rocket launcher in coop
//
// if there is a player behind/below the carrier, and we can shoot, and we can trace a LOS to them ..
// pick one of the group, and let it rip
void CarrierCoopCheck(ASEntity &self)
{
	array<ASEntity @> targets;
	int      target;
	ASEntity @ent;
	trace_t	 tr;

	// if we're not in coop, this is a noop
	// [Paril-KEX] might as well let this work in SP too, so he fires it
	// if you get below him
	//if (!coop.integer)
	//	return;
	// if we are, and we have recently fired, bail
	if (self.monsterinfo.fire_wait > level.time)
		return;

	// cycle through players
	for (uint player = 1; player <= max_clients; player++)
	{
		@ent = entities[player];
		if (!ent.e.inuse)
			continue;
		if (ent.client is null)
			continue;
		if (inback(self, ent) || below(self, ent))
		{
			tr = gi_traceline(self.e.s.origin, ent.e.s.origin, self.e, contents_t::MASK_SOLID);
			if (tr.fraction == 1.0f)
				targets.push_back(ent);
		}
	}

	if (targets.empty())
		return;

	// get a number from 0 to (num_targets-1)
	target = irandom(targets.length());

	// make sure to prevent rapid fire rockets
	self.monsterinfo.fire_wait = level.time + CARRIER_ROCKET_TIME;

	// save off the real enemy
	@ent = self.enemy;
	// set the new guy as temporary enemy
	@self.enemy = targets[target];
	CarrierRocket(self);
	// put the real enemy back
	@self.enemy = ent;

	// we're done
	return;
}

void CarrierGrenade(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right, up;
	vec3_t					 aim;
	monster_muzzle_t flash_number;
	float					 direction; // from lower left to upper right, or lower right to upper left
	float					 spreadR, spreadU;
	int						 mytime;

	CarrierCoopCheck(self);

	if (self.enemy is null)
		return;

	if (frandom() < 0.5f)
		direction = -1.0f;
	else
		direction = 1.0f;

	mytime = ((level.time - self.timestamp) / 0.4f).secondsi();

	if (mytime == 0)
	{
		spreadR = 0.15f * direction;
		spreadU = 0.1f - 0.1f * direction;
	}
	else if (mytime == 1)
	{
		spreadR = 0;
		spreadU = 0.1f;
	}
	else if (mytime == 2)
	{
		spreadR = -0.15f * direction;
		spreadU = 0.1f - -0.1f * direction;
	}
	else if (mytime == 3)
	{
		spreadR = 0;
		spreadU = 0.1f;
	}
	else
	{
		// error, shoot straight
		spreadR = 0;
		spreadU = 0;
	}

	AngleVectors(self.e.s.angles, forward, right, up);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_GRENADE], forward, right);

	aim = self.enemy.e.s.origin - start;
	aim.normalize();

	aim += (right * spreadR);
	aim += (up * spreadU);

	if (aim[2] > 0.15f)
		aim[2] = 0.15f;
	else if (aim[2] < -0.5f)
		aim[2] = -0.5f;

	flash_number = monster_muzzle_t::GUNNER_GRENADE_1;
	monster_fire_grenade(self, start, aim, 50, 600, flash_number, (crandom_open() * 10.0f), 200.f + (crandom_open() * 10.0f));
}

void CarrierPredictiveRocket(ASEntity &self)
{
	vec3_t forward, right, aimpt;
	vec3_t start;
	vec3_t dir;

	AngleVectors(self.e.s.angles, forward, right);

	// 1
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_1], forward, right);
	PredictAim(self, self.enemy, start, CARRIER_ROCKET_SPEED, false, -0.3f, dir, aimpt);
	monster_fire_rocket(self, start, dir, 50, CARRIER_ROCKET_SPEED, monster_muzzle_t::CARRIER_ROCKET_1);

	// 2
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_2], forward, right);
	PredictAim(self, self.enemy, start, CARRIER_ROCKET_SPEED, false, -0.15f, dir, aimpt);
	monster_fire_rocket(self, start, dir, 50, CARRIER_ROCKET_SPEED, monster_muzzle_t::CARRIER_ROCKET_2);

	// 3
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_3], forward, right);
	PredictAim(self, self.enemy, start, CARRIER_ROCKET_SPEED, false, 0, dir, aimpt);
	monster_fire_rocket(self, start, dir, 50, CARRIER_ROCKET_SPEED, monster_muzzle_t::CARRIER_ROCKET_3);

	// 4
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_4], forward, right);
	PredictAim(self, self.enemy, start, CARRIER_ROCKET_SPEED, false, 0.15f, dir, aimpt);
	monster_fire_rocket(self, start, dir, 50, CARRIER_ROCKET_SPEED, monster_muzzle_t::CARRIER_ROCKET_4);
}

void CarrierRocket(ASEntity &self)
{
	vec3_t forward, right;
	vec3_t start;
	vec3_t dir;
	vec3_t vec;

	if (self.enemy !is null)
	{
		if (self.enemy.client !is null && frandom() < 0.5f)
		{
			CarrierPredictiveRocket(self);
			return;
		}
	}
	else
		return;

	AngleVectors(self.e.s.angles, forward, right);

	// 1
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_1], forward, right);
	vec = self.enemy.e.s.origin;
	vec[2] -= 15;
	dir = vec - start;
	dir.normalize();
	dir += (right * 0.4f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::CARRIER_ROCKET_1);

	// 2
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_2], forward, right);
	vec = self.enemy.e.s.origin;
	dir = vec - start;
	dir.normalize();
	dir += (right * 0.025f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::CARRIER_ROCKET_2);

	// 3
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_3], forward, right);
	vec = self.enemy.e.s.origin;
	dir = vec - start;
	dir.normalize();
	dir += (right * -0.025f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::CARRIER_ROCKET_3);

	// 4
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_ROCKET_4], forward, right);
	vec = self.enemy.e.s.origin;
	vec[2] -= 15;
	dir = vec - start;
	dir.normalize();
	dir += (right * -0.4f);
	dir.normalize();
	monster_fire_rocket(self, start, dir, 50, 500, monster_muzzle_t::CARRIER_ROCKET_4);
}

void carrier_firebullet_right(ASEntity &self)
{
	vec3_t					 forward, right, start, aimpoint;
	monster_muzzle_t flashnum;

	// if we're in manual steering mode, it means we're leaning down .. use the lower shot
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		flashnum = monster_muzzle_t::CARRIER_MACHINEGUN_R2;
	else
		flashnum = monster_muzzle_t::CARRIER_MACHINEGUN_R1;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flashnum], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.3f, forward, aimpoint);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, flashnum);
}

void carrier_firebullet_left(ASEntity &self)
{
	vec3_t					 forward, right, start, aimpoint;
	monster_muzzle_t flashnum;

	// if we're in manual steering mode, it means we're leaning down .. use the lower shot
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		flashnum = monster_muzzle_t::CARRIER_MACHINEGUN_L2;
	else
		flashnum = monster_muzzle_t::CARRIER_MACHINEGUN_L1;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flashnum], forward, right);
	PredictAim(self, self.enemy, start, 0, true, -0.3f, forward, aimpoint);
	monster_fire_bullet(self, start, forward, 6, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, flashnum);
}

void CarrierMachineGun(ASEntity &self)
{
	CarrierCoopCheck(self);
	if (self.enemy !is null)
		carrier_firebullet_left(self);
	if (self.enemy !is null)
		carrier_firebullet_right(self);
}

void CarrierSpawn(ASEntity &self)
{
	vec3_t	 f, r, offset, startpoint, spawnpoint;
	ASEntity @ent;

	//	offset = { 105, 0, -30 }; // real distance needed is (sqrt (56*56*2) + sqrt(16*16*2)) or 101.8
	offset = { 105, 0, -58 }; // real distance needed is (sqrt (56*56*2) + sqrt(16*16*2)) or 101.8
	AngleVectors(self.e.s.angles, f, r);

	startpoint = M_ProjectFlashSource(self, offset, f, r);

	if (self.monsterinfo.chosen_reinforcements.empty())
		return;

	auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[0]];

	if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32, false))
	{
		@ent = CreateFlyMonster(spawnpoint, self.e.s.angles, reinforcement.mins, reinforcement.maxs, reinforcement.classname);

		if (ent is null)
			return;

		gi_sound(self.e, soundchan_t::BODY, carrier::sounds::spawn, 1, ATTN_NONE, 0);

		ent.nextthink = level.time;
		ent.think(ent);

		ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::SPAWNED_COMMANDER | ai_flags_t::DO_NOT_COUNT | ai_flags_t::IGNORE_SHOTS);
		@ent.monsterinfo.commander = self;
		ent.monsterinfo.slots_from_commander = reinforcement.strength;
		self.monsterinfo.monster_used += reinforcement.strength;

		if ((self.enemy.e.inuse) && (self.enemy.health > 0))
		{
			@ent.enemy = self.enemy;
			FoundTarget(ent);

			if (ent.classname == "monster_kamikaze")
			{
				ent.monsterinfo.lefty = false;
				ent.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
				M_SetAnimation(ent, flyer_move_kamikaze);
				ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::CHARGING);
				@ent.owner = self;
			}
			else if (ent.classname == "monster_flyer")
			{
				if (brandom())
				{
					ent.monsterinfo.lefty = false;
					ent.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
					M_SetAnimation(ent, flyer_move_attack3);
				}
				else
				{
					ent.monsterinfo.lefty = true;
					ent.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
					M_SetAnimation(ent, flyer_move_attack3);
				}
			}
		}
	}
}

void carrier_prep_spawn(ASEntity &self)
{
	CarrierCoopCheck(self);
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
	self.timestamp = level.time;
	self.yaw_speed = 10;
}

void carrier_spawn_check(ASEntity &self)
{
	CarrierCoopCheck(self);
	CarrierSpawn(self);

	if (level.time > (self.timestamp + time_sec(2.0))) // 0.5 seconds per flyer.  this gets three
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		self.yaw_speed = orig_yaw_speed;
	}
	else
		self.monsterinfo.nextframe = carrier::frames::spawn08;
}

void carrier_ready_spawn(ASEntity &self)
{
	float  current_yaw;
	vec3_t offset, f, r, startpoint, spawnpoint;

	CarrierCoopCheck(self);

	current_yaw = anglemod(self.e.s.angles.yaw);

	if (abs(current_yaw - self.ideal_yaw) > 0.1f)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HOLD_FRAME);
		self.timestamp += FRAME_TIME_S;
		return;
	}

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

	int num_summoned;
	self.monsterinfo.chosen_reinforcements = M_PickReinforcements(self, num_summoned, 1);

	if (num_summoned == 0)
		return;

	auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[0]];

	offset = { 105, 0, -58 };
	AngleVectors(self.e.s.angles, f, r);
	startpoint = M_ProjectFlashSource(self, offset, f, r);
	if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32, false))
	{
		float radius = (reinforcement.maxs - reinforcement.mins).length() * 0.5f;

		SpawnGrow_Spawn(spawnpoint + (reinforcement.mins + reinforcement.maxs), radius, radius * 2.f);
	}
}

void carrier_start_spawn(ASEntity &self)
{
	int	   mytime;
	float  enemy_yaw;
	vec3_t temp;

	CarrierCoopCheck(self);
	if (orig_yaw_speed == 0)
		orig_yaw_speed = self.yaw_speed;

	if (self.enemy is null)
		return;

	mytime = ((level.time - self.timestamp) / 0.5).secondsi();

	temp = self.enemy.e.s.origin - self.e.s.origin;
	enemy_yaw = vectoyaw(temp);

	// note that the offsets are based on a forward of 105 from the end angle
	if (mytime == 0)
		self.ideal_yaw = anglemod(enemy_yaw - 30);
	else if (mytime == 1)
		self.ideal_yaw = anglemod(enemy_yaw);
	else if (mytime == 2)
		self.ideal_yaw = anglemod(enemy_yaw + 30);
}

const array<mframe_t> carrier_frames_stand = {
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
const mmove_t carrier_move_stand = mmove_t(carrier::frames::search01, carrier::frames::search13, carrier_frames_stand, null);

const array<mframe_t> carrier_frames_walk = {
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
const mmove_t carrier_move_walk = mmove_t(carrier::frames::search01, carrier::frames::search13, carrier_frames_walk, null);

const array<mframe_t> carrier_frames_run = {
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck),
	mframe_t(ai_run, 6, CarrierCoopCheck)
};
const mmove_t carrier_move_run = mmove_t(carrier::frames::search01, carrier::frames::search13, carrier_frames_run, null);

void CarrierSpool(ASEntity &self)
{
	CarrierCoopCheck(self);
	gi_sound(self.e, soundchan_t::BODY, carrier::sounds::cg_up, 1, 0.5f, 0);

	self.monsterinfo.weapon_sound = carrier::sounds::cg_loop;
}

const array<mframe_t> carrier_frames_attack_pre_mg = {
	mframe_t(ai_charge, 4, CarrierSpool),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, carrier_attack_mg)
};
const mmove_t carrier_move_attack_pre_mg = mmove_t(carrier::frames::firea01, carrier::frames::firea08, carrier_frames_attack_pre_mg, null);

// Loop this
const array<mframe_t> carrier_frames_attack_mg = {
	mframe_t(ai_charge, -2, CarrierMachineGun),
	mframe_t(ai_charge, -2, CarrierMachineGun),
	mframe_t(ai_charge, -2, carrier_reattack_mg)
};
const mmove_t carrier_move_attack_mg = mmove_t(carrier::frames::firea09, carrier::frames::firea11, carrier_frames_attack_mg, null);

const array<mframe_t> carrier_frames_attack_post_mg = {
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck)
};
const mmove_t carrier_move_attack_post_mg = mmove_t(carrier::frames::firea12, carrier::frames::firea15, carrier_frames_attack_post_mg, carrier_run);

const array<mframe_t> carrier_frames_attack_pre_gren = {
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, carrier_attack_gren)
};
const mmove_t carrier_move_attack_pre_gren = mmove_t(carrier::frames::fireb01, carrier::frames::fireb06, carrier_frames_attack_pre_gren, null);

const array<mframe_t> carrier_frames_attack_gren = {
	mframe_t(ai_charge, -15, CarrierGrenade),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, carrier_reattack_gren)
};
const mmove_t carrier_move_attack_gren = mmove_t(carrier::frames::fireb07, carrier::frames::fireb10, carrier_frames_attack_gren, null);

const array<mframe_t> carrier_frames_attack_post_gren = {
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck),
	mframe_t(ai_charge, 4, CarrierCoopCheck)
};
const mmove_t carrier_move_attack_post_gren = mmove_t(carrier::frames::fireb11, carrier::frames::fireb16, carrier_frames_attack_post_gren, carrier_run);

const array<mframe_t> carrier_frames_attack_rocket = {
	mframe_t(ai_charge, 15, CarrierRocket)
};
const mmove_t carrier_move_attack_rocket = mmove_t(carrier::frames::fireb01, carrier::frames::fireb01, carrier_frames_attack_rocket, carrier_run);

void CarrierRail(ASEntity &self)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right;

	CarrierCoopCheck(self);
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::CARRIER_RAILGUN], forward, right);

	// calc direction to where we targeted
	dir = self.pos1 - start;
	dir.normalize();

	monster_fire_railgun(self, start, dir, 50, 100, monster_muzzle_t::CARRIER_RAILGUN);
	self.monsterinfo.attack_finished = level.time + RAIL_FIRE_TIME;
}

void CarrierSaveLoc(ASEntity &self)
{
	CarrierCoopCheck(self);
	self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	self.pos1[2] += self.enemy.viewheight;
};

const array<mframe_t> carrier_frames_attack_rail = {
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, 2, CarrierSaveLoc),
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, -20, CarrierRail),
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, 2, CarrierCoopCheck),
	mframe_t(ai_charge, 2, CarrierCoopCheck)
};
const mmove_t carrier_move_attack_rail = mmove_t(carrier::frames::search01, carrier::frames::search09, carrier_frames_attack_rail, carrier_run);

const array<mframe_t> carrier_frames_spawn = {
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2, carrier_prep_spawn),	// 7 - end of wind down
	mframe_t(ai_charge, -2, carrier_start_spawn), // 8 - start of spawn
	mframe_t(ai_charge, -2, carrier_ready_spawn),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -10, carrier_spawn_check), // 12 - actual spawn
	mframe_t(ai_charge, -2),	 // 13 - begin of wind down
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2),
	mframe_t(ai_charge, -2) // 18 - end of wind down
};
const mmove_t carrier_move_spawn = mmove_t(carrier::frames::spawn01, carrier::frames::spawn18, carrier_frames_spawn, carrier_run);

const array<mframe_t> carrier_frames_pain_heavy = {
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
const mmove_t carrier_move_pain_heavy = mmove_t(carrier::frames::death01, carrier::frames::death10, carrier_frames_pain_heavy, carrier_run);

const array<mframe_t> carrier_frames_pain_light = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t carrier_move_pain_light = mmove_t(carrier::frames::spawn01, carrier::frames::spawn04, carrier_frames_pain_light, carrier_run);

const array<mframe_t> carrier_frames_death = {
	mframe_t(ai_move, 0, BossExplode),
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
const mmove_t carrier_move_death = mmove_t(carrier::frames::death01, carrier::frames::death16, carrier_frames_death, carrier_dead);

void carrier_stand(ASEntity &self)
{
	M_SetAnimation(self, carrier_move_stand);
}

void carrier_run(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, carrier_move_stand);
	else
		M_SetAnimation(self, carrier_move_run);
}

void carrier_walk(ASEntity &self)
{
	M_SetAnimation(self, carrier_move_walk);
}

void CarrierMachineGunHold(ASEntity &self)
{
	CarrierMachineGun(self);
}

void carrier_attack(ASEntity &self)
{
	vec3_t vec;
	float  range, luck;
	bool   enemy_inback, enemy_infront, enemy_below;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

	if ((self.enemy is null) || (!self.enemy.e.inuse))
		return;

	enemy_inback = inback(self, self.enemy);
	enemy_infront = infront(self, self.enemy);
	enemy_below = below(self, self.enemy);

	if (self.bad_area !is null)
	{
		if ((enemy_inback) || (enemy_below))
			M_SetAnimation(self, carrier_move_attack_rocket);
		else if ((frandom() < 0.1f) || (level.time < self.monsterinfo.attack_finished))
			M_SetAnimation(self, carrier_move_attack_pre_mg);
		else
		{
			gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, carrier_move_attack_rail);
		}
		return;
	}

	if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
	{
		M_SetAnimation(self, carrier_move_spawn);
		return;
	}

	if (!enemy_inback && !enemy_infront && !enemy_below) // to side and not under
	{
		if ((frandom() < 0.1f) || (level.time < self.monsterinfo.attack_finished))
			M_SetAnimation(self, carrier_move_attack_pre_mg);
		else
		{
			gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
			M_SetAnimation(self, carrier_move_attack_rail);
		}
		return;
	}

	if (enemy_infront)
	{
		vec = self.enemy.e.s.origin - self.e.s.origin;
		range = vec.length();
		if (range <= 125)
		{
			if ((frandom() < 0.8f) || (level.time < self.monsterinfo.attack_finished))
				M_SetAnimation(self, carrier_move_attack_pre_mg);
			else
			{
				gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
				M_SetAnimation(self, carrier_move_attack_rail);
			}
		}
		else if (range < 600)
		{
			luck = frandom();
			if (M_SlotsLeft(self) > 2)
			{
				if (luck <= 0.20f)
					M_SetAnimation(self, carrier_move_attack_pre_mg);
				else if (luck <= 0.40f)
					M_SetAnimation(self, carrier_move_attack_pre_gren);
				else if ((luck <= 0.7f) && !(level.time < self.monsterinfo.attack_finished))
				{
					gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
					M_SetAnimation(self, carrier_move_attack_rail);
				}
				else
					M_SetAnimation(self, carrier_move_spawn);
			}
			else
			{
				if (luck <= 0.30f)
					M_SetAnimation(self, carrier_move_attack_pre_mg);
				else if (luck <= 0.65f)
					M_SetAnimation(self, carrier_move_attack_pre_gren);
				else if (level.time >= self.monsterinfo.attack_finished)
				{
					gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
					M_SetAnimation(self, carrier_move_attack_rail);
				}
				else
					M_SetAnimation(self, carrier_move_attack_pre_mg);
			}
		}
		else // won't use grenades at this range
		{
			luck = frandom();
			if (M_SlotsLeft(self) > 2)
			{
				if (luck < 0.3f)
					M_SetAnimation(self, carrier_move_attack_pre_mg);
				else if ((luck < 0.65f) && !(level.time < self.monsterinfo.attack_finished))
				{
					gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
					self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
					self.pos1[2] += self.enemy.viewheight;
					M_SetAnimation(self, carrier_move_attack_rail);
				}
				else
					M_SetAnimation(self, carrier_move_spawn);
			}
			else
			{
				if ((luck < 0.45f) || (level.time < self.monsterinfo.attack_finished))
					M_SetAnimation(self, carrier_move_attack_pre_mg);
				else
				{
					gi_sound(self.e, soundchan_t::WEAPON, carrier::sounds::rail, 1, ATTN_NORM, 0);
					M_SetAnimation(self, carrier_move_attack_rail);
				}
			}
		}
	}
	else if ((enemy_below) || (enemy_inback))
	{
		M_SetAnimation(self, carrier_move_attack_rocket);
	}
}

void carrier_attack_mg(ASEntity &self)
{
	CarrierCoopCheck(self);
	M_SetAnimation(self, carrier_move_attack_mg);
	self.monsterinfo.melee_debounce_time = level.time + random_time(time_sec(1.2), time_sec(2));
}

void carrier_reattack_mg(ASEntity &self)
{
	CarrierMachineGun(self);

	CarrierCoopCheck(self);
	if (visible(self, self.enemy) && infront(self, self.enemy))
	{
		if (frandom() < 0.6f)
		{
			self.monsterinfo.melee_debounce_time += random_time(time_ms(250), time_ms(500));
			M_SetAnimation(self, carrier_move_attack_mg);
			return;
		}
		else if (self.monsterinfo.melee_debounce_time > level.time)
		{
			M_SetAnimation(self, carrier_move_attack_mg);
			return;
		}
	}

	M_SetAnimation(self, carrier_move_attack_post_mg);
	self.monsterinfo.weapon_sound = 0;
	gi_sound(self.e, soundchan_t::BODY, carrier::sounds::cg_down, 1, 0.5f, 0);
}

void carrier_attack_gren(ASEntity &self)
{
	CarrierCoopCheck(self);
	self.timestamp = level.time;
	M_SetAnimation(self, carrier_move_attack_gren);
}

void carrier_reattack_gren(ASEntity &self)
{
	CarrierCoopCheck(self);
	if (infront(self, self.enemy))
		if (self.timestamp + time_sec(1.3) > level.time) // four grenades
		{
			M_SetAnimation(self, carrier_move_attack_gren);
			return;
		}
	M_SetAnimation(self, carrier_move_attack_post_gren);
}

void carrier_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	bool changed = false;

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(5);

	if (damage < 10)
		gi_sound(self.e, soundchan_t::VOICE, carrier::sounds::pain3, 1, ATTN_NONE, 0);
	else if (damage < 30)
		gi_sound(self.e, soundchan_t::VOICE, carrier::sounds::pain1, 1, ATTN_NONE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, carrier::sounds::pain2, 1, ATTN_NONE, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	self.monsterinfo.weapon_sound = 0;

	if (damage >= 10)
	{
		if (damage < 30)
		{
			if (mod.id == mod_id_t::CHAINFIST || frandom() < 0.5f)
			{
				changed = true;
				M_SetAnimation(self, carrier_move_pain_light);
			}
		}
		else
		{
			M_SetAnimation(self, carrier_move_pain_heavy);
			changed = true;
		}
	}

	// if we changed frames, clean up our little messes
	if (changed)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		self.yaw_speed = orig_yaw_speed;
	}
}

void carrier_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void carrier_dead(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.sound = 0;
	self.e.s.skinnum /= 2;

	self.gravityVector.z = -1.0f;

	ThrowGibs(self, 500, {
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t(3, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
		gib_def_t("models/monsters/carrier/gibs/base.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/carrier/gibs/chest.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/carrier/gibs/gl.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/carrier/gibs/lcg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/carrier/gibs/lwing.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/carrier/gibs/rcg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t("models/monsters/carrier/gibs/rwing.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
		gib_def_t(2, "models/monsters/carrier/gibs/spawner.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/carrier/gibs/thigh.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/carrier/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC | gib_type_t::HEAD))
	});
}

void carrier_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_sound(self.e, soundchan_t::VOICE, carrier::sounds::death, 1, ATTN_NONE, 0);
	self.deadflag = true;
	self.takedamage = false;
	self.count = 0;
	M_SetAnimation(self, carrier_move_death);
	self.velocity = vec3_origin;
	self.gravityVector.z *= 0.01f;
	self.monsterinfo.weapon_sound = 0;
}

bool Carrier_CheckAttack(ASEntity &self)
{
	bool enemy_infront = infront(self, self.enemy);
	bool enemy_inback = inback(self, self.enemy);
	bool enemy_below = below(self, self.enemy);

	// PMM - shoot out the back if appropriate
	if ((enemy_inback) || (!enemy_infront && enemy_below))
	{
		// this is using wait because the attack is supposed to be independent
		if (level.time >= self.monsterinfo.fire_wait)
		{
			self.monsterinfo.fire_wait = level.time + CARRIER_ROCKET_TIME;
			self.monsterinfo.attack(self);
			if (frandom() < 0.6f)
				self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
			else
				self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
			return true;
		}
	}

	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.8f, 0.8f, 0.5f, 0.f);
}

void CarrierPrecache()
{
	gi_soundindex("flyer/flysght1.wav");
	gi_soundindex("flyer/flysrch1.wav");
	gi_soundindex("flyer/flypain1.wav");
	gi_soundindex("flyer/flypain2.wav");
	gi_soundindex("flyer/flyatck2.wav");
	gi_soundindex("flyer/flyatck1.wav");
	gi_soundindex("flyer/flydeth1.wav");
	gi_soundindex("flyer/flyatck3.wav");
	gi_soundindex("flyer/flyidle1.wav");
	gi_soundindex("weapons/rockfly.wav");
	gi_soundindex("infantry/infatck1.wav");
	gi_soundindex("gunner/gunatck3.wav");
	gi_soundindex("weapons/grenlb1b.wav");
	gi_soundindex("tank/rocket.wav");

	gi_modelindex("models/monsters/flyer/tris.md2");
	gi_modelindex("models/objects/rocket/tris.md2");
	gi_modelindex("models/objects/debris2/tris.md2");
	gi_modelindex("models/objects/grenade/tris.md2");
	gi_modelindex("models/items/spawngro3/tris.md2");
	gi_modelindex("models/objects/gibs/sm_metal/tris.md2");
	gi_modelindex("models/objects/gibs/gear/tris.md2");
}

/*QUAKED monster_carrier (1 .5 0) (-56 -56 -44) (56 56 44) Ambush Trigger_Spawn Sight
 */
void SP_monster_carrier(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	carrier::sounds::pain1.precache();
	carrier::sounds::pain2.precache();
	carrier::sounds::pain3.precache();
	carrier::sounds::death.precache();
	carrier::sounds::rail.precache();
	carrier::sounds::sight.precache();
	carrier::sounds::spawn.precache();

	carrier::sounds::cg_down.precache();
	carrier::sounds::cg_loop.precache();
	carrier::sounds::cg_up.precache();

	self.monsterinfo.engine_sound = gi_soundindex("bosshovr/bhvengn1.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/carrier/tris.md2");
	
	gi_modelindex("models/monsters/carrier/gibs/base.md2");
	gi_modelindex("models/monsters/carrier/gibs/chest.md2");
	gi_modelindex("models/monsters/carrier/gibs/gl.md2");
	gi_modelindex("models/monsters/carrier/gibs/head.md2");
	gi_modelindex("models/monsters/carrier/gibs/lcg.md2");
	gi_modelindex("models/monsters/carrier/gibs/lwing.md2");
	gi_modelindex("models/monsters/carrier/gibs/rcg.md2");
	gi_modelindex("models/monsters/carrier/gibs/rwing.md2");
	gi_modelindex("models/monsters/carrier/gibs/spawner.md2");
	gi_modelindex("models/monsters/carrier/gibs/thigh.md2");

	self.e.mins = { -56, -56, -44 };
	self.e.maxs = { 56, 56, 44 };

	// 2000 - 4000 health
	self.health = int(max(2000, 2000 + 1000 * (skill.integer - 1)) * st.health_multiplier);
	// add health in coop (500 * skill)
	if (coop.integer != 0)
		self.health += 500 * skill.integer;

	self.gib_health = -200;
	self.mass = 1000;

	self.yaw_speed = 15;
	orig_yaw_speed = self.yaw_speed;

	self.flags = ent_flags_t(self.flags | ent_flags_t::IMMUNE_LASER);
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	@self.pain = carrier_pain;
	@self.die = carrier_die;

	@self.monsterinfo.melee = null;
	@self.monsterinfo.stand = carrier_stand;
	@self.monsterinfo.walk = carrier_walk;
	@self.monsterinfo.run = carrier_run;
	@self.monsterinfo.attack = carrier_attack;
	@self.monsterinfo.sight = carrier_sight;
	@self.monsterinfo.checkattack = Carrier_CheckAttack;
	@self.monsterinfo.setskin = carrier_setskin;
	gi_linkentity(self.e);

	M_SetAnimation(self, carrier_move_stand);
	self.monsterinfo.scale = carrier::SCALE;

	CarrierPrecache();

	flymonster_start(self);

	self.monsterinfo.attack_finished = time_ms(0);

	string reinforcements = carrier::default_reinforcements;

	if (!st.was_key_specified("monster_slots"))
		self.monsterinfo.monster_slots = carrier::default_monster_slots_base;
	if (st.was_key_specified("reinforcements"))
		reinforcements = st.reinforcements;

	if (self.monsterinfo.monster_slots != 0 && !reinforcements.empty())
	{
		if (skill.integer != 0)
			self.monsterinfo.monster_slots += int(floor(self.monsterinfo.monster_slots * (skill.value / 2.f)));

		M_SetupReinforcements(reinforcements, self.monsterinfo.reinforcements);
	}

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	self.monsterinfo.fly_acceleration = 5.f;
	self.monsterinfo.fly_speed = 50.f;
	self.monsterinfo.fly_above = true;
	self.monsterinfo.fly_min_distance = 1000.f;
	self.monsterinfo.fly_max_distance = 1000.f;
}
