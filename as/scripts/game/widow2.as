// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

black widow, part 2

==============================================================================
*/

// timestamp used to prevent rapid fire of melee attack

namespace widow2
{
    enum frames
    {
        blackwidow3,
        walk01,
        walk02,
        walk03,
        walk04,
        walk05,
        walk06,
        walk07,
        walk08,
        walk09,
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
        firea01,
        firea02,
        firea03,
        firea04,
        firea05,
        firea06,
        firea07,
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
        tongs01,
        tongs02,
        tongs03,
        tongs04,
        tongs05,
        tongs06,
        tongs07,
        tongs08,
        pain01,
        pain02,
        pain03,
        pain04,
        pain05,
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
        dthsrh01,
        dthsrh02,
        dthsrh03,
        dthsrh04,
        dthsrh05,
        dthsrh06,
        dthsrh07,
        dthsrh08,
        dthsrh09,
        dthsrh10,
        dthsrh11,
        dthsrh12,
        dthsrh13,
        dthsrh14,
        dthsrh15,
        dthsrh16,
        dthsrh17,
        dthsrh18,
        dthsrh19,
        dthsrh20,
        dthsrh21,
        dthsrh22
    };

    const float SCALE = 2.000000f;
}

namespace widow2::sounds
{
    cached_soundindex pain1("widow/bw2pain1.wav");
    cached_soundindex pain2("widow/bw2pain2.wav");
    cached_soundindex pain3("widow/bw2pain3.wav");
    cached_soundindex death("widow/death.wav");
    cached_soundindex search1("bosshovr/bhvunqv1.wav");
    cached_soundindex tentacles_retract("brain/brnatck3.wav");
}

namespace widow2
{
    // sqrt(64*64*2) + sqrt(28*28*2) => 130.1
    const array<vec3_t> spawnpoints = {
        { 30, 135, 0 },
        { 30, -135, 0 }
    };

    const array<float> sweep_angles = {
        -40.0, -32.0, -24.0, -16.0, -8.0, 0.0, 8.0, 16.0, 24.0, 32.0, 40.0
    };

    // these offsets used by the tongue
    const array<vec3_t> offsets = {
        { 17.48f, 0.10f, 68.92f },
        { 17.47f, 0.29f, 68.91f },
        { 17.45f, 0.53f, 68.87f },
        { 17.42f, 0.78f, 68.81f },
        { 17.39f, 1.02f, 68.75f },
        { 17.37f, 1.20f, 68.70f },
        { 17.36f, 1.24f, 68.71f },
        { 17.37f, 1.21f, 68.72f },
    };
}

void widow2_search(ASEntity &self)
{
	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, widow2::sounds::search1, 1, ATTN_NONE, 0);
}

void Widow2Beam(ASEntity &self)
{
	vec3_t					 forward, right, target;
	vec3_t					 start, targ_angles, vec;
	monster_muzzle_t flashnum;

	if ((self.enemy is null) || (!self.enemy.e.inuse))
		return;

	AngleVectors(self.e.s.angles, forward, right);

	if ((self.e.s.frame >= widow2::frames::fireb05) && (self.e.s.frame <= widow2::frames::fireb09))
	{
		// regular beam attack
		Widow2SaveBeamTarget(self);
		flashnum = monster_muzzle_t(monster_muzzle_t::WIDOW2_BEAMER_1 + self.e.s.frame - widow2::frames::fireb05);
		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flashnum], forward, right);
		target = self.pos2;
		target[2] += self.enemy.viewheight - 10;
		forward = target - start;
		forward.normalize();
		monster_fire_heatbeam(self, start, forward, vec3_origin, 10, 50, flashnum);
	}
	else if ((self.e.s.frame >= widow2::frames::spawn04) && (self.e.s.frame <= widow2::frames::spawn14))
	{
		// sweep
		flashnum = monster_muzzle_t(monster_muzzle_t::WIDOW2_BEAM_SWEEP_1 + self.e.s.frame - widow2::frames::spawn04);
		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[flashnum], forward, right);
		target = self.enemy.e.s.origin - start;
		targ_angles = vectoangles(target);

		vec = self.e.s.angles;

		vec.pitch += targ_angles.pitch;
		vec.yaw -= widow2::sweep_angles[flashnum - monster_muzzle_t::WIDOW2_BEAM_SWEEP_1];

		AngleVectors(vec, forward);
		monster_fire_heatbeam(self, start, forward, vec3_origin, 10, 50, flashnum);
	}
	else
	{
		Widow2SaveBeamTarget(self);
		start = G_ProjectSource(self.e.s.origin, monster_flash_offset[monster_muzzle_t::WIDOW2_BEAMER_1], forward, right);

		target = self.pos2;
		target[2] += self.enemy.viewheight - 10;

		forward = target - start;
		forward.normalize();

		monster_fire_heatbeam(self, start, forward, vec3_origin, 10, 50, monster_muzzle_t::WIDOW2_BEAM_SWEEP_1);
	}
}

void Widow2Spawn(ASEntity &self)
{
	vec3_t	 f, r, u, offset, startpoint, spawnpoint;
	ASEntity @ent, designated_enemy;
	int		 i;

	AngleVectors(self.e.s.angles, f, r, u);

	for (i = 0; i < 2; i++)
	{
		offset = widow2::spawnpoints[i];

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

void widow2_spawn_check(ASEntity &self)
{
	Widow2Beam(self);
	Widow2Spawn(self);
}

void widow2_ready_spawn(ASEntity &self)
{
	vec3_t f, r, u, offset, startpoint, spawnpoint;
	int	   i;

	Widow2Beam(self);
	AngleVectors(self.e.s.angles, f, r, u);

	for (i = 0; i < 2; i++)
	{
		offset = widow2::spawnpoints[i];
		startpoint = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		if (FindSpawnPoint(startpoint, widow::stalker_mins, widow::stalker_maxs, spawnpoint, 64))
		{
			float radius = (widow::stalker_maxs - widow::stalker_mins).length() * 0.5f;

			SpawnGrow_Spawn(spawnpoint + (widow::stalker_mins + widow::stalker_maxs), radius, radius * 2.f);
		}
	}
}

void widow2_step(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("widow/bwstep1.wav"), 1, ATTN_NORM, 0);
}

const array<mframe_t> widow2_frames_stand = {
	mframe_t(ai_stand)
};
const mmove_t widow2_move_stand = mmove_t(widow2::frames::blackwidow3, widow2::frames::blackwidow3, widow2_frames_stand, null);

const array<mframe_t> widow2_frames_walk = {
	mframe_t(ai_walk, 9.01f, widow2_step),
	mframe_t(ai_walk, 7.55f),
	mframe_t(ai_walk, 7.01f),
	mframe_t(ai_walk, 6.66f),
	mframe_t(ai_walk, 6.20f),
	mframe_t(ai_walk, 5.78f, widow2_step),
	mframe_t(ai_walk, 7.25f),
	mframe_t(ai_walk, 8.37f),
	mframe_t(ai_walk, 10.41f)
};
const mmove_t widow2_move_walk = mmove_t(widow2::frames::walk01, widow2::frames::walk09, widow2_frames_walk, null);

const array<mframe_t> widow2_frames_run = {
	mframe_t(ai_run, 9.01f, widow2_step),
	mframe_t(ai_run, 7.55f),
	mframe_t(ai_run, 7.01f),
	mframe_t(ai_run, 6.66f),
	mframe_t(ai_run, 6.20f),
	mframe_t(ai_run, 5.78f, widow2_step),
	mframe_t(ai_run, 7.25f),
	mframe_t(ai_run, 8.37f),
	mframe_t(ai_run, 10.41f)
};
const mmove_t widow2_move_run = mmove_t(widow2::frames::walk01, widow2::frames::walk09, widow2_frames_run, null);

const array<mframe_t> widow2_frames_attack_pre_beam = {
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 4, widow2_step),
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 4, widow2_attack_beam)
};
const mmove_t widow2_move_attack_pre_beam = mmove_t(widow2::frames::fireb01, widow2::frames::fireb04, widow2_frames_attack_pre_beam, null);

// Loop this
const array<mframe_t> widow2_frames_attack_beam = {
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, widow2_reattack_beam)
};
const mmove_t widow2_move_attack_beam = mmove_t(widow2::frames::fireb05, widow2::frames::fireb09, widow2_frames_attack_beam, null);

const array<mframe_t> widow2_frames_attack_post_beam = {
	mframe_t(ai_charge, 4),
	mframe_t(ai_charge, 4)
};
const mmove_t widow2_move_attack_post_beam = mmove_t(widow2::frames::fireb06, widow2::frames::fireb07, widow2_frames_attack_post_beam, widow2_run);

void WidowDisrupt(ASEntity &self)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right, aimpoint;
	float  len;

	AngleVectors(self.e.s.angles, forward, right);
	start = G_ProjectSource(self.e.s.origin, monster_flash_offset[monster_muzzle_t::WIDOW_DISRUPTOR], forward, right);

	dir = self.pos1 - self.enemy.e.s.origin;
	len = dir.length();

	if (len < 30)
	{
		// calc direction to where we targeted
		dir = self.pos1 - start;
		dir.normalize();

		monster_fire_tracker(self, start, dir, 20, 500, self.enemy, monster_muzzle_t::WIDOW_DISRUPTOR);
	}
	else
	{
		PredictAim(self, self.enemy, start, 1200, true, 0, dir, aimpoint);
		monster_fire_tracker(self, start, dir, 20, 1200, null, monster_muzzle_t::WIDOW_DISRUPTOR);
	}

	widow2_step(self);
}

void Widow2SaveDisruptLoc(ASEntity &self)
{
	if (self.enemy !is null && self.enemy.e.inuse)
	{
		self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
		self.pos1[2] += self.enemy.viewheight;
	}
	else
		self.pos1 = vec3_origin;
}

void widow2_disrupt_reattack(ASEntity &self)
{
	float luck = frandom();

	if (luck < (0.25f + (skill.integer * 0.15f)))
		self.monsterinfo.nextframe = widow2::frames::firea01;
}

const array<mframe_t> widow2_frames_attack_disrupt = {
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, Widow2SaveDisruptLoc),
	mframe_t(ai_charge, -20, WidowDisrupt),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 2, widow2_disrupt_reattack)
};
const mmove_t widow2_move_attack_disrupt = mmove_t(widow2::frames::firea01, widow2::frames::firea07, widow2_frames_attack_disrupt, widow2_run);

void Widow2SaveBeamTarget(ASEntity &self)
{
	if (self.enemy !is null && self.enemy.e.inuse)
	{
		self.pos2 = self.pos1;
		self.pos1 = self.enemy.e.s.origin; // save for aiming the shot
	}
	else
	{
		self.pos1 = vec3_origin;
		self.pos2 = vec3_origin;
	}
}

void Widow2BeamTargetRemove(ASEntity &self)
{
	self.pos1 = vec3_origin;
	self.pos2 = vec3_origin;
}

void Widow2StartSweep(ASEntity &self)
{
	Widow2SaveBeamTarget(self);
}

const array<mframe_t> widow2_frames_spawn = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, function(self) { widow_start_spawn(self); widow2_step(self); }),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam), // 5
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, widow2_ready_spawn), // 10
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, Widow2Beam),
	mframe_t(ai_charge, 0, widow2_spawn_check),
	mframe_t(ai_charge), // 15
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, widow2_reattack_beam)
};
const mmove_t widow2_move_spawn = mmove_t(widow2::frames::spawn01, widow2::frames::spawn18, widow2_frames_spawn, null);

bool widow2_tongue_attack_ok(const vec3_t &in start, const vec3_t &in end, float range)
{
	vec3_t dir, angles;

	// check for max distance
	dir = start - end;
	if (dir.length() > range)
		return false;

	// check for min/max pitch
	angles = vectoangles(dir);
	if (angles[0] < -180)
		angles[0] += 360;
	if (abs(angles[0]) > 30)
		return false;

	return true;
}

void Widow2Tongue(ASEntity &self)
{
	vec3_t	f, r, u;
	vec3_t	start, end, dir;
	trace_t tr;

	AngleVectors(self.e.s.angles, f, r, u);
	start = G_ProjectSource2(self.e.s.origin, widow2::offsets[self.e.s.frame - widow2::frames::tongs01], f, r, u);
	end = self.enemy.e.s.origin;
	if (!widow2_tongue_attack_ok(start, end, 256))
	{
		end[2] = self.enemy.e.s.origin[2] + self.enemy.e.maxs[2] - 8;
		if (!widow2_tongue_attack_ok(start, end, 256))
		{
			end[2] = self.enemy.e.s.origin[2] + self.enemy.e.mins[2] + 8;
			if (!widow2_tongue_attack_ok(start, end, 256))
				return;
		}
	}
	end = self.enemy.e.s.origin;

	tr = gi_traceline(start, end, self.e, contents_t::MASK_PROJECTILE);
	if (tr.ent !is self.enemy.e)
		return;

	gi_sound(self.e, soundchan_t::WEAPON, widow2::sounds::tentacles_retract, 1, ATTN_NORM, 0);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::PARASITE_ATTACK);
	gi_WriteEntity(self.e);
	gi_WritePosition(start);
	gi_WritePosition(end);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	dir = start - end;
	T_Damage(self.enemy, self, self, dir, self.enemy.e.s.origin, vec3_origin, 2, 0, damageflags_t::NO_KNOCKBACK, mod_id_t::UNKNOWN);
}

void Widow2TonguePull(ASEntity &self)
{
	vec3_t vec;
	vec3_t f, r, u;
	vec3_t start, end;

	if ((self.enemy is null) || (!self.enemy.e.inuse))
	{
		self.monsterinfo.run(self);
		return;
	}

	AngleVectors(self.e.s.angles, f, r, u);
	start = G_ProjectSource2(self.e.s.origin, widow2::offsets[self.e.s.frame - widow2::frames::tongs01], f, r, u);
	end = self.enemy.e.s.origin;

	if (!widow2_tongue_attack_ok(start, end, 256))
		return;

	if (self.enemy.groundentity !is null)
	{
		self.enemy.e.s.origin[2] += 1;
		@self.enemy.groundentity = null;
        gi_linkentity(self.enemy.e);
	}

	vec = self.e.s.origin - self.enemy.e.s.origin;

	if (self.enemy.client !is null)
	{
		vec.normalize();
		self.enemy.velocity += (vec * 1000);
	}
	else
	{
		self.enemy.ideal_yaw = vectoyaw(vec);
		M_ChangeYaw(self.enemy);
		self.enemy.velocity = f * 1000;
	}
}

void Widow2Crunch(ASEntity &self)
{
	vec3_t aim;

	if ((self.enemy is null) || (!self.enemy.e.inuse))
	{
		self.monsterinfo.run(self);
		return;
	}

	Widow2TonguePull(self);

	// 70 + 32
	aim = { 150, 0, 4 };
	if (self.e.s.frame != widow2::frames::tongs07)
		fire_hit(self, aim, irandom(20, 26), 0);
	else if (self.enemy.groundentity !is null)
		fire_hit(self, aim, irandom(20, 26), 500);
	else // not as much kick if they're in the air .. makes it harder to land on her head
		fire_hit(self, aim, irandom(20, 26), 250);
}

void Widow2Toss(ASEntity &self)
{
	self.timestamp = level.time + time_sec(3);
}

const array<mframe_t> widow2_frames_tongs = {
	mframe_t(ai_charge, 0, Widow2Tongue),
	mframe_t(ai_charge, 0, Widow2Tongue),
	mframe_t(ai_charge, 0, Widow2Tongue),
	mframe_t(ai_charge, 0, Widow2TonguePull),
	mframe_t(ai_charge, 0, Widow2TonguePull), // 5
	mframe_t(ai_charge, 0, Widow2TonguePull),
	mframe_t(ai_charge, 0, Widow2Crunch),
	mframe_t(ai_charge, 0, Widow2Toss)
};
const mmove_t widow2_move_tongs = mmove_t(widow2::frames::tongs01, widow2::frames::tongs08, widow2_frames_tongs, widow2_run);

const array<mframe_t> widow2_frames_pain = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t widow2_move_pain = mmove_t(widow2::frames::pain01, widow2::frames::pain05, widow2_frames_pain, widow2_run);

const array<mframe_t> widow2_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion1), // 3 boom
	mframe_t(ai_move),
	mframe_t(ai_move), // 5

	mframe_t(ai_move, 0, WidowExplosion2), // 6 boom
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 10

	mframe_t(ai_move),
	mframe_t(ai_move), // 12
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move), // 15

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion3), // 18
	mframe_t(ai_move),					 // 19
	mframe_t(ai_move),					 // 20

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion4), // 25

	mframe_t(ai_move), // 26
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion5),
	mframe_t(ai_move, 0, WidowExplosionLeg), // 30

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion6),
	mframe_t(ai_move), // 35

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplosion7),
	mframe_t(ai_move),
	mframe_t(ai_move), // 40

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, WidowExplode) // 44
};
const mmove_t widow2_move_death = mmove_t(widow2::frames::death01, widow2::frames::death44, widow2_frames_death, null);

const array<mframe_t> widow2_frames_dead = {
	mframe_t(ai_move, 0, widow2_start_searching),
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
	mframe_t(ai_move, 0, widow2_keep_searching)
};
const mmove_t widow2_move_dead = mmove_t(widow2::frames::dthsrh01, widow2::frames::dthsrh15, widow2_frames_dead, null);

const array<mframe_t> widow2_frames_really_dead = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move, 0, widow2_finaldeath)
};
const mmove_t widow2_move_really_dead = mmove_t(widow2::frames::dthsrh16, widow2::frames::dthsrh22, widow2_frames_really_dead, null);

void widow2_start_searching(ASEntity &self)
{
	self.count = 0;
}

void widow2_keep_searching(ASEntity &self)
{
	if (self.count <= 2)
	{
		M_SetAnimation(self, widow2_move_dead);
		self.e.s.frame = widow2::frames::dthsrh01;
		self.count++;
		return;
	}

	M_SetAnimation(self, widow2_move_really_dead);
}

void widow2_finaldeath(ASEntity &self)
{
	self.e.mins = { -70, -70, 0 };
	self.e.maxs = { 70, 70, 80 };
	self.movetype = movetype_t::TOSS;
	self.takedamage = true;
	self.nextthink = time_zero;
	gi_linkentity(self.e);
}

void widow2_stand(ASEntity &self)
{
	M_SetAnimation(self, widow2_move_stand);
}

void widow2_run(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, widow2_move_stand);
	else
		M_SetAnimation(self, widow2_move_run);
}

void widow2_walk(ASEntity &self)
{
	M_SetAnimation(self, widow2_move_walk);
}

void widow2_melee(ASEntity &self)
{
	if (self.timestamp >= level.time)
		widow2_attack(self);
	else
		M_SetAnimation(self, widow2_move_tongs);
}

void widow2_attack(ASEntity &self)
{
	float luck;
	bool  blocked = false;

	if ((self.monsterinfo.aiflags & ai_flags_t::BLOCKED) != 0)
	{
		blocked = true;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
	}

	if (self.enemy is null)
		return;

	float real_enemy_range = realrange(self, self.enemy);

	// melee attack
	if (self.timestamp < level.time)
	{
		if (real_enemy_range < 300)
		{
			vec3_t f, r, u;
			AngleVectors(self.e.s.angles, f, r, u);
			vec3_t spot1 = G_ProjectSource2(self.e.s.origin, widow2::offsets[0], f, r, u);
			vec3_t spot2 = self.enemy.e.s.origin;
			if (widow2_tongue_attack_ok(spot1, spot2, 256))
			{
				// melee attack ok

				// be nice in easy mode
				if (skill.integer != 0 || irandom(4) != 0)
				{
					M_SetAnimation(self, widow2_move_tongs);
					return;
				}
			}
		}
	}

	if (self.bad_area !is null)
	{
		if ((frandom() < 0.75f) || (level.time < self.monsterinfo.attack_finished))
			M_SetAnimation(self, widow2_move_attack_pre_beam);
		else
		{
			M_SetAnimation(self, widow2_move_attack_disrupt);
		}
		return;
	}

	WidowCalcSlots(self);

	// if we can't see the target, spawn stuff
	if ((self.monsterinfo.attack_state == ai_attack_state_t::BLIND) && (M_SlotsLeft(self) >= 2))
	{
		M_SetAnimation(self, widow2_move_spawn);
		return;
	}

	// accept bias towards spawning
	if (blocked && (M_SlotsLeft(self) >= 2))
	{
		M_SetAnimation(self, widow2_move_spawn);
		return;
	}

	if (real_enemy_range < 600)
	{
		luck = frandom();
		if (M_SlotsLeft(self) >= 2)
		{
			if (luck <= 0.40f)
				M_SetAnimation(self, widow2_move_attack_pre_beam);
			else if ((luck <= 0.7f) && !(level.time < self.monsterinfo.attack_finished))
			{
				M_SetAnimation(self, widow2_move_attack_disrupt);
			}
			else
				M_SetAnimation(self, widow2_move_spawn);
		}
		else
		{
			if ((luck <= 0.50f) || (level.time < self.monsterinfo.attack_finished))
				M_SetAnimation(self, widow2_move_attack_pre_beam);
			else
			{
				M_SetAnimation(self, widow2_move_attack_disrupt);
			}
		}
	}
	else
	{
		luck = frandom();
		if (M_SlotsLeft(self) >= 2)
		{
			if (luck < 0.3f)
				M_SetAnimation(self, widow2_move_attack_pre_beam);
			else if ((luck < 0.65f) || (level.time < self.monsterinfo.attack_finished))
				M_SetAnimation(self, widow2_move_spawn);
			else
			{
				M_SetAnimation(self, widow2_move_attack_disrupt);
			}
		}
		else
		{
			if ((luck < 0.45f) || (level.time < self.monsterinfo.attack_finished))
				M_SetAnimation(self, widow2_move_attack_pre_beam);
			else
			{
				M_SetAnimation(self, widow2_move_attack_disrupt);
			}
		}
	}
}

void widow2_attack_beam(ASEntity &self)
{
	M_SetAnimation(self, widow2_move_attack_beam);
	widow2_step(self);
}

void widow2_reattack_beam(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	if (infront(self, self.enemy))
		if (frandom() <= 0.5f)
			if ((frandom() < 0.7f) || (M_SlotsLeft(self) < 2))
				M_SetAnimation(self, widow2_move_attack_beam);
			else
				M_SetAnimation(self, widow2_move_spawn);
		else
			M_SetAnimation(self, widow2_move_attack_post_beam);
	else
		M_SetAnimation(self, widow2_move_attack_post_beam);
}

void widow2_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(5);

	if (damage < 15)
		gi_sound(self.e, soundchan_t::VOICE, widow2::sounds::pain1, 1, ATTN_NONE, 0);
	else if (damage < 75)
		gi_sound(self.e, soundchan_t::VOICE, widow2::sounds::pain2, 1, ATTN_NONE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, widow2::sounds::pain3, 1, ATTN_NONE, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	if (damage >= 15)
	{
		if (damage < 75)
		{
			if ((skill.integer < 3) && (frandom() < (0.6f - (0.2f * skill.integer))))
			{
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
				M_SetAnimation(self, widow2_move_pain);
			}
		}
		else
		{
			if ((skill.integer < 3) && (frandom() < (0.75f - (0.1f * skill.integer))))
			{
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
				M_SetAnimation(self, widow2_move_pain);
			}
		}
	}
}

void widow2_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

void widow2_dead(ASEntity &self)
{
}

void KillChildren(ASEntity &self)
{
	ASEntity @ent = null;

	while (true)
	{
		@ent = find_by_str<ASEntity>(ent, "classname", "monster_stalker");
		if (ent is null)
			return;

		// FIXME - may need to stagger
		if ((ent.e.inuse) && (ent.health > 0))
			T_Damage(ent, self, self, vec3_origin, self.enemy.e.s.origin, vec3_origin, (ent.health + 1), 0, damageflags_t::NO_KNOCKBACK, mod_id_t::UNKNOWN);
	}
}

void widow2_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	int n;
	int clipped;

	// check for gib
	if (self.deadflag && M_CheckGib(self, mod))
	{
		clipped = min(damage, 100);

		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
		for (n = 0; n < 2; n++)
			ThrowWidowGibLoc(self, "models/objects/gibs/bone/tris.md2", clipped, gib_type_t::NONE, vec3_origin, false, false);
		for (n = 0; n < 3; n++)
			ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", clipped, gib_type_t::NONE, vec3_origin, false, false);
		for (n = 0; n < 3; n++)
		{
			ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib1/tris.md2", clipped, gib_type_t::METALLIC, vec3_origin,
							   0, false, false);
			ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib2/tris.md2", clipped, gib_type_t::METALLIC, vec3_origin,
							   gi_soundindex("misc/fhit3.wav"), false, false);
		}
		for (n = 0; n < 2; n++)
		{
			ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib3/tris.md2", clipped, gib_type_t::METALLIC, vec3_origin,
							   0, false, false);
			ThrowWidowGibSized(self, "models/monsters/blackwidow/gib3/tris.md2", clipped, gib_type_t::METALLIC, vec3_origin,
							   0, false, false);
		}
		ThrowGibs(self, damage, {
			gib_def_t("models/objects/gibs/chest/tris.md2"),
			gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
		});

		return;
	}

	if (self.deadflag)
		return;

	gi_sound(self.e, soundchan_t::VOICE, widow2::sounds::death, 1, ATTN_NONE, 0);
	self.deadflag = true;
	self.takedamage = false;
	self.count = 0;
	KillChildren(self);
	self.monsterinfo.quad_time = time_zero;
	self.monsterinfo.double_time = time_zero;
	self.monsterinfo.invincible_time = time_zero;
	M_SetAnimation(self, widow2_move_death);
}

bool Widow2_CheckAttack(ASEntity &self)
{
	if (self.enemy is null)
		return false;

	WidowPowerups(self);

	if ((frandom() < 0.8f) && (M_SlotsLeft(self) >= 2) && (realrange(self, self.enemy) > 150))
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		return true;
	}

	return M_CheckAttack_Base(self, 0.4f, 0.8f, 0.8f, 0.5f, 0.f, 0.f);
}

void Widow2Precache()
{
	// cache in all of the stalker stuff, widow stuff, spawngro stuff, gibs
	gi_soundindex("parasite/parpain1.wav");
	gi_soundindex("parasite/parpain2.wav");
	gi_soundindex("parasite/pardeth1.wav");
	gi_soundindex("parasite/paratck1.wav");
	gi_soundindex("parasite/parsght1.wav");
	gi_soundindex("infantry/melee2.wav");
	gi_soundindex("misc/fhit3.wav");

	gi_soundindex("tank/tnkatck3.wav");
	gi_soundindex("weapons/disrupt.wav");
	gi_soundindex("weapons/disint2.wav");

	gi_modelindex("models/monsters/stalker/tris.md2");
	gi_modelindex("models/items/spawngro3/tris.md2");
	gi_modelindex("models/objects/gibs/sm_metal/tris.md2");
	gi_modelindex("models/objects/laser/tris.md2");
	gi_modelindex("models/proj/disintegrator/tris.md2");

	gi_modelindex("models/monsters/blackwidow/gib1/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib2/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib3/tris.md2");
	gi_modelindex("models/monsters/blackwidow/gib4/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib1/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib2/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib3/tris.md2");
	gi_modelindex("models/monsters/blackwidow2/gib4/tris.md2");
}

/*QUAKED monster_widow2 (1 .5 0) (-70 -70 0) (70 70 144) Ambush Trigger_Spawn Sight
 */
void SP_monster_widow2(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	widow2::sounds::pain1.precache();
	widow2::sounds::pain2.precache();
	widow2::sounds::pain3.precache();
	widow2::sounds::death.precache();
	widow2::sounds::search1.precache();
	widow2::sounds::tentacles_retract.precache();

	//	self.e.s.sound = gi_soundindex ("bosshovr/bhvengn1.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/blackwidow2/tris.md2");
	self.e.mins = { -70, -70, 0 };
	self.e.maxs = { 70, 70, 144 };

	self.health = int((2000 + 800 + 1000 * skill.integer) * st.health_multiplier);
	if (coop.integer != 0)
		self.health += 500 * skill.integer;
	//	self.health = 1;
	self.gib_health = -900;
	self.mass = 2500;

	/*	if (skill.integer == 2)
		{
			self.monsterinfo.power_armor_type = IT_ITEM_POWER_SHIELD;
			self.monsterinfo.power_armor_power = 500;
		}
		else */
	if (skill.integer == 3)
	{
		if (!st.was_key_specified("power_armor_type"))
			self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;
		if (!st.was_key_specified("power_armor_power"))
			self.monsterinfo.power_armor_power = 750;
	}

	self.yaw_speed = 30;

	self.flags = ent_flags_t(self.flags | ent_flags_t::IMMUNE_LASER);
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	@self.pain = widow2_pain;
	@self.die = widow2_die;

	@self.monsterinfo.melee = widow2_melee;
	@self.monsterinfo.stand = widow2_stand;
	@self.monsterinfo.walk = widow2_walk;
	@self.monsterinfo.run = widow2_run;
	@self.monsterinfo.attack = widow2_attack;
	@self.monsterinfo.search = widow2_search;
	@self.monsterinfo.checkattack = Widow2_CheckAttack;
	@self.monsterinfo.setskin = widow2_setskin;
	gi_linkentity(self.e);

	M_SetAnimation(self, widow2_move_stand);
	self.monsterinfo.scale = widow2::SCALE;

	Widow2Precache();
	WidowCalcSlots(self);
	walkmonster_start(self);
}
