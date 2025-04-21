// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

ARACHNID

==============================================================================
*/

namespace arachnid
{
    enum frames
    {
        rails1,
        rails2,
        rails3,
        rails4,
        rails5,
        rails6,
        rails7,
        rails8,
        rails9,
        rails10,
        rails11,
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
        melee_atk1,
        melee_atk2,
        melee_atk3,
        melee_atk4,
        melee_atk5,
        melee_atk6,
        melee_atk7,
        melee_atk8,
        melee_atk9,
        melee_atk10,
        melee_atk11,
        melee_atk12,
        pain11,
        pain12,
        pain13,
        pain14,
        pain15,
        idle1,
        idle2,
        idle3,
        idle4,
        idle5,
        idle6,
        idle7,
        idle8,
        idle9,
        idle10,
        idle11,
        idle12,
        idle13,
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
        turn1,
        turn2,
        turn3,
        melee_out1,
        melee_out2,
        melee_out3,
        pain21,
        pain22,
        pain23,
        pain24,
        pain25,
        pain26,
        melee_pain1,
        melee_pain2,
        melee_pain3,
        melee_pain4,
        melee_pain5,
        melee_pain6,
        melee_pain7,
        melee_pain8,
        melee_pain9,
        melee_pain10,
        melee_pain11,
        melee_pain12,
        melee_pain13,
        melee_pain14,
        melee_pain15,
        melee_pain16,
        melee_in1,
        melee_in2,
        melee_in3,
        melee_in4,
        melee_in5,
        melee_in6,
        melee_in7,
        melee_in8,
        melee_in9,
        melee_in10,
        melee_in11,
        melee_in12,
        melee_in13,
        melee_in14,
        melee_in15,
        melee_in16,
        rails_up1,
        rails_up2,
        rails_up3,
        rails_up4,
        rails_up5,
        rails_up6,
        rails_up7,
        rails_up8,
        rails_up9,
        rails_up10,
        rails_up11,
        rails_up12,
        rails_up13,
        rails_up14,
        rails_up15,
        rails_up16
    };

    const float SCALE = 1.000000f;
}

namespace arachnid::sounds
{
    cached_soundindex step("insane/insane11.wav");
    cached_soundindex charge("gladiator/railgun.wav");
    cached_soundindex melee("gladiator/melee3.wav");
    cached_soundindex melee_hit("gladiator/melee2.wav");
    cached_soundindex pain("arachnid/pain.wav");
    cached_soundindex death("arachnid/death.wav");
    cached_soundindex sight("arachnid/sight.wav");
    cached_soundindex spawn("medic_commander/monsterspawn1.wav");
    cached_soundindex pissed("arachnid/angry.wav");
}

namespace arachnid
{
    const string default_reinforcements = "monster_stalker 1";
    const int default_monster_slots_base = 2;
	const array<vec3_t> reinforcement_position = { { -24.f, 124.f, 0 }, { -24.f, -124.f, 0 } };
}

void arachnid_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, arachnid::sounds::sight, 1, ATTN_NORM, 0);
}

//
// stand
//

const array<mframe_t> arachnid_frames_stand = {
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
const mmove_t arachnid_move_stand = mmove_t(arachnid::frames::idle1, arachnid::frames::idle13, arachnid_frames_stand, null);

void arachnid_stand(ASEntity &self)
{
	M_SetAnimation(self, arachnid_move_stand);
}

//
// walk
//

void arachnid_footstep(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, arachnid::sounds::step, 0.5f, ATTN_IDLE, 0.0f);
}

const array<mframe_t> arachnid_frames_walk = {
	mframe_t(ai_walk, 2, arachnid_footstep),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 16),
	mframe_t(ai_walk, 5),
	mframe_t(ai_walk, 8, arachnid_footstep),
	mframe_t(ai_walk, 8),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 5)
};
const mmove_t arachnid_move_walk = mmove_t(arachnid::frames::walk1, arachnid::frames::walk10, arachnid_frames_walk, null);

void arachnid_walk(ASEntity &self)
{
	M_SetAnimation(self, arachnid_move_walk);
}

//
// run
//

const array<mframe_t> arachnid_frames_run = {
	mframe_t(ai_run, 2, arachnid_footstep),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 16),
	mframe_t(ai_run, 5),
	mframe_t(ai_run, 8, arachnid_footstep),
	mframe_t(ai_run, 8),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 9),
	mframe_t(ai_run, 5)
};
const mmove_t arachnid_move_run = mmove_t(arachnid::frames::walk1, arachnid::frames::walk10, arachnid_frames_run, null);

void arachnid_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		M_SetAnimation(self, arachnid_move_stand);
		return;
	}

	M_SetAnimation(self, arachnid_move_run);
}

//
// pain
//

const array<mframe_t> arachnid_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t arachnid_move_pain1 = mmove_t(arachnid::frames::pain11, arachnid::frames::pain15, arachnid_frames_pain1, arachnid_run);

const array<mframe_t> arachnid_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t arachnid_move_pain2 = mmove_t(arachnid::frames::pain21, arachnid::frames::pain26, arachnid_frames_pain2, arachnid_run);

void arachnid_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);
	gi_sound(self.e, soundchan_t::VOICE, arachnid::sounds::pain, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	float r = frandom();

	if (r < 0.5f)
		M_SetAnimation(self, arachnid_move_pain1);
	else
		M_SetAnimation(self, arachnid_move_pain2);
}

void arachnid_charge_rail(ASEntity &self, monster_muzzle_t mz)
{
	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	gi_sound(self.e, soundchan_t::WEAPON, arachnid::sounds::charge, 1.f, ATTN_NORM, 0.f);

	vec3_t forward, right, start;
	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[mz], forward, right);

	PredictAim(self, self.enemy, start, 0, false, 0.0f, aimpoint: self.pos1);
}

void arachnid_charge_rail_left(ASEntity &self)
{
	arachnid_charge_rail(self, monster_muzzle_t::ARACHNID_RAIL1);
}

void arachnid_charge_rail_right(ASEntity &self)
{
	arachnid_charge_rail(self, monster_muzzle_t::ARACHNID_RAIL2);
}

void arachnid_charge_rail_up_left(ASEntity &self)
{
	arachnid_charge_rail(self, monster_muzzle_t::ARACHNID_RAIL_UP1);
}

void arachnid_charge_rail_up_right(ASEntity &self)
{
	arachnid_charge_rail(self, monster_muzzle_t::ARACHNID_RAIL_UP2);
}

void arachnid_rail_real(ASEntity &self, monster_muzzle_t id)
{
	vec3_t start;
	vec3_t dir;
	vec3_t forward, right, up;

	AngleVectors(self.e.s.angles, forward, right, up);
	start = M_ProjectFlashSource(self, monster_flash_offset[id], forward, right);
	int dmg = 50;

	if (self.e.s.frame >= arachnid::frames::melee_in1 && self.e.s.frame <= arachnid::frames::melee_in16)
	{
		// scan our current direction for players
		array<ASEntity @> players_scanned;

        foreach (ASEntity @player : active_players)
        {
			if (!visible(self, player, false))
				continue;

			if (infront_cone(self, player, 0.5f))
				players_scanned.push_back(player);
		}

		if (!players_scanned.empty())
		{
			ASEntity @chosen = players_scanned[irandom(players_scanned.length())];

			PredictAim(self, chosen, start, 0, false, 0.0f, aimpoint: self.pos1);

			dir = (chosen.e.s.origin - self.e.s.origin).normalized();

			self.ideal_yaw = vectoyaw(dir);
			self.e.s.angles.yaw = self.ideal_yaw;

			dir = (self.pos1 - start).normalized();

			for (int i = 0; i < 3; i++)
				dir[i] += crandom() * 0.018f;
			dir = dir.normalized();
		}
		else
		{
			dir = forward;
		}
	}
	else
	{
		// calc direction to where we targeted
		dir = (self.pos1 - start).normalized();
		dmg = 50;
	}

	bool hit = monster_fire_railgun(self, start, dir, dmg, int(dmg * 2.0f), id);

	if (dmg == 50)
	{
		if (hit)
			self.count = 0;
		else
			self.count++;
	}
}

void arachnid_rail(ASEntity &self)
{
	monster_muzzle_t id;

	switch (self.e.s.frame)
	{
		case arachnid::frames::rails4:
			id = monster_muzzle_t::ARACHNID_RAIL1;
			break;
		case arachnid::frames::rails8:
			id = monster_muzzle_t::ARACHNID_RAIL2;
			break;
		case arachnid::frames::rails_up7:
			id = monster_muzzle_t::ARACHNID_RAIL_UP1;
			break;
		case arachnid::frames::rails_up11:
			id = monster_muzzle_t::ARACHNID_RAIL_UP2;
			break;
		default:
			id = monster_muzzle_t::ARACHNID_RAIL1;
			break;
	}

	arachnid_rail_real(self, id);
}

const array<mframe_t> arachnid_frames_attack1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_charge_rail_left),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_rail),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_charge_rail_right),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_rail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t arachnid_attack1 = mmove_t(arachnid::frames::rails1, arachnid::frames::rails11, arachnid_frames_attack1, arachnid_run);

const array<mframe_t> arachnid_frames_attack_up1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_charge_rail_up_left),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_rail),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_charge_rail_up_right),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_rail),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
};
const mmove_t arachnid_attack_up1 = mmove_t(arachnid::frames::rails_up1, arachnid::frames::rails_up16, arachnid_frames_attack_up1, arachnid_run);

void arachnid_melee_charge(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, arachnid::sounds::melee, 1.f, ATTN_NORM, 0.f);
}

void arachnid_melee_hit(ASEntity &self)
{
	if (!fire_hit(self, { MELEE_DISTANCE, 0, 0 }, 15, 50))
	{
		self.monsterinfo.melee_debounce_time = level.time + time_ms(1000);
		self.count++;
	}
	else if (self.e.s.frame == arachnid::frames::melee_atk11 &&
		     self.monsterinfo.melee_debounce_time < level.time)
		self.monsterinfo.nextframe = arachnid::frames::melee_atk2;
}

const array<mframe_t> arachnid_frames_melee_out = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t arachnid_melee_out = mmove_t(arachnid::frames::melee_out1, arachnid::frames::melee_out3, arachnid_frames_melee_out, arachnid_run);

void arachnid_to_out_melee(ASEntity &self)
{
	M_SetAnimation(self, arachnid_melee_out);
}

const array<mframe_t> arachnid_frames_melee = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_melee_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_melee_hit),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_melee_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_melee_hit),
	mframe_t(ai_charge)
};
const mmove_t arachnid_melee = mmove_t(arachnid::frames::melee_atk1, arachnid::frames::melee_atk12, arachnid_frames_melee, arachnid_to_out_melee);

void arachnid_to_melee(ASEntity &self)
{
	M_SetAnimation(self, arachnid_melee);
}

const array<mframe_t> arachnid_frames_melee_in = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t arachnid_melee_in = mmove_t(arachnid::frames::melee_in1, arachnid::frames::melee_in3, arachnid_frames_melee_in, arachnid_to_melee);

void arachnid_stop_rails(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
	arachnid_run(self);
}

void arachnid_rail_left(ASEntity &self)
{
	arachnid_rail_real(self, monster_muzzle_t::ARACHNID_RAIL1);
}

void arachnid_rail_right(ASEntity &self)
{
	arachnid_rail_real(self, monster_muzzle_t::ARACHNID_RAIL2);
}

void arachnid_rail_rapid(ASEntity &self)
{
	bool left_shot = self.e.s.frame == arachnid::frames::melee_in9; //((self.e.s.frame - arachnid::frames::melee_in5) / 2) % 2;

	arachnid_rail_real(self, left_shot ? monster_muzzle_t::ARACHNID_RAIL1 : monster_muzzle_t::ARACHNID_RAIL2);
}

const array<mframe_t> arachnid_frames_attack3 = {
	mframe_t(ai_charge),
	mframe_t(ai_move, 0, arachnid_rail_rapid),
	mframe_t(ai_move),
	mframe_t(ai_move/*, 0, arachnid_rail_rapid*/),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, arachnid_rail_rapid),
	mframe_t(ai_move),
	mframe_t(ai_move/*, 0, arachnid_rail_rapid*/),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, arachnid_rail_rapid),
	mframe_t(ai_move),
	mframe_t(ai_move/*, 0, arachnid_rail_rapid*/),
	mframe_t(ai_charge)
};
const mmove_t arachnid_attack3 = mmove_t(arachnid::frames::melee_in4, arachnid::frames::melee_in16, arachnid_frames_attack3, arachnid_to_out_melee);

void arachnid_rapid_fire(ASEntity &self)
{
	self.count = 0;
	M_SetAnimation(self, arachnid_attack3);
}

void arachnid_spawn(ASEntity &self)
{
	if (skill.integer != 3)
		return;

	vec3_t f, r, offset, startpoint, spawnpoint;
	int	   count;

	AngleVectors(self.e.s.angles, f, r);

	int num_summoned;
	self.monsterinfo.chosen_reinforcements = M_PickReinforcements(self, num_summoned, 2);

	for (count = 0; count < num_summoned; count++)
	{
		offset = arachnid::reinforcement_position[count];

		if (self.e.s.scale != 0)
			offset *= self.e.s.scale;

		startpoint = M_ProjectFlashSource(self, offset, f, r);
		// a little off the ground
		startpoint[2] += 10 * (self.e.s.scale != 0 ? self.e.s.scale : 1.0f);

		auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[count]];

		if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32))
		{
			if (CheckGroundSpawnPoint(spawnpoint, reinforcement.mins, reinforcement.maxs, 256, -1))
			{
				ASEntity @ent = CreateGroundMonster(spawnpoint, self.e.s.angles, reinforcement.mins, reinforcement.maxs, reinforcement.classname, 256);

				if (ent is null)
					return;

				ent.nextthink = level.time;
				ent.think(ent);

				ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::SPAWNED_COMMANDER | ai_flags_t::DO_NOT_COUNT | ai_flags_t::IGNORE_SHOTS);
				@ent.monsterinfo.commander = self;
				ent.monsterinfo.slots_from_commander = reinforcement.strength;
				self.monsterinfo.monster_used += reinforcement.strength;

				gi_sound(ent.e, soundchan_t::BODY, arachnid::sounds::spawn, 1, ATTN_NONE, 0);

				if ((self.enemy.e.inuse) && (self.enemy.health > 0))
				{
					@ent.enemy = self.enemy;
					FoundTarget(ent);
				}

				float radius = (reinforcement.maxs - reinforcement.mins).length() * 0.5f;
				SpawnGrow_Spawn(spawnpoint + (reinforcement.mins + reinforcement.maxs), radius, radius * 2.f);
			}
		}
	}
}

const array<mframe_t> arachnid_frames_taunt = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, arachnid_spawn),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t arachnid_taunt = mmove_t(arachnid::frames::melee_pain1, arachnid::frames::melee_pain16, arachnid_frames_taunt, arachnid_rapid_fire);

void arachnid_attack(ASEntity &self)
{
	if (self.enemy is null || !self.enemy.e.inuse)
		return;

	if (self.monsterinfo.melee_debounce_time < level.time && range_to(self, self.enemy) < MELEE_DISTANCE)
		M_SetAnimation(self, arachnid_melee_in);
	// annoyed rapid fire attack
	else if (self.enemy.client !is null &&
		self.last_move_time <= level.time &&
		self.count >= 4 &&
		frandom() < (max(self.count / 2.0f, 4.0f) + 1.0f) * 0.2f &&
		(M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL1]) || M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL2])))
	{
		M_SetAnimation(self, arachnid_taunt);
		gi_sound(self.e, soundchan_t::VOICE, arachnid::sounds::pissed, 1.f, 0.25f, 0.f);
		self.count = 0;
		self.pain_debounce_time = level.time + time_sec(4.5);
		self.last_move_time = level.time + time_sec(10);
	}
	else if ((self.enemy.e.s.origin[2] - self.e.s.origin[2]) > 150.f &&
		(M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL_UP1]) || M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL_UP2])))
		M_SetAnimation(self, arachnid_attack_up1);
	else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL1]) || M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::ARACHNID_RAIL2]))
		M_SetAnimation(self, arachnid_attack1);
}

//
// death
//

void arachnid_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.nextthink = time_zero;
	gi_linkentity(self.e);
}

const array<mframe_t> arachnid_frames_death1 = {
	mframe_t(ai_move, 0),
	mframe_t(ai_move, -1.23f),
	mframe_t(ai_move, -1.23f),
	mframe_t(ai_move, -1.23f),
	mframe_t(ai_move, -1.23f),
	mframe_t(ai_move, -1.64f),
	mframe_t(ai_move, -1.64f),
	mframe_t(ai_move, -2.45f),
	mframe_t(ai_move, -8.63f),
	mframe_t(ai_move, -4.0f),
	mframe_t(ai_move, -4.5f),
	mframe_t(ai_move, -6.8f),
	mframe_t(ai_move, -8.0f),
	mframe_t(ai_move, -5.4f),
	mframe_t(ai_move, -3.4f),
	mframe_t(ai_move, -1.9f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t arachnid_move_death = mmove_t(arachnid::frames::death1, arachnid::frames::death20, arachnid_frames_death1, arachnid_dead);

void arachnid_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
/*#ifdef PSX_ASSETS
		ThrowGibs(self, damage, {
			{ "models/monsters/arachnid/gibs/chest.md2" },
			{ "models/monsters/arachnid/gibs/stomach.md2" },
			(gib_def_t { 3, "models/monsters/arachnid/gibs/leg.md2", GIB_UPRIGHT }).frame(0),
			(gib_def_t { 3, "models/monsters/arachnid/gibs/leg.md2", GIB_UPRIGHT }).frame(1),
			(gib_def_t { "models/monsters/arachnid/gibs/l_rail.md2", GIB_UPRIGHT }).frame(brandom() ? 1 : 0),
			(gib_def_t { "models/monsters/arachnid/gibs/r_rail.md2", GIB_UPRIGHT }).frame(brandom() ? 1 : 0),
			{ 2, "models/objects/gibs/bone/tris.md2" },
			{ 3, "models/objects/gibs/sm_meat/tris.md2" },
			{ 2, "models/objects/gibs/gear/tris.md2", GIB_METALLIC },
			{ "models/monsters/arachnid/gibs/head.md2", GIB_HEAD }
		});
#else*/
		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
		});
//#endif
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, arachnid::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	M_SetAnimation(self, arachnid_move_death);
}

void arachnid_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

//
// monster_arachnid
//
// 

/*QUAKED monster_arachnid (1 .5 0) (-40 -40 -20) (40 40 48) Ambush Trigger_Spawn Sight
 */
void SP_monster_arachnid(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	arachnid::sounds::step.precache();
	arachnid::sounds::charge.precache();
	arachnid::sounds::melee.precache();
	arachnid::sounds::melee_hit.precache();
	arachnid::sounds::pain.precache();
	arachnid::sounds::death.precache();
	arachnid::sounds::sight.precache();
	arachnid::sounds::pissed.precache();
	
/*#ifdef PSX_ASSETS
	gi_modelindex("models/monsters/arachnid/gibs/head.md2");
	gi_modelindex("models/monsters/arachnid/gibs/chest.md2");
	gi_modelindex("models/monsters/arachnid/gibs/stomach.md2");
	gi_modelindex("models/monsters/arachnid/gibs/leg.md2");
	gi_modelindex("models/monsters/arachnid/gibs/l_rail.md2");
	gi_modelindex("models/monsters/arachnid/gibs/r_rail.md2");
#endif*/

	if (skill.value >= 3)
	{
		arachnid::sounds::spawn.precache();

		string reinforcements = arachnid::default_reinforcements;

		if (!st.was_key_specified("monster_slots"))
			self.monsterinfo.monster_slots = arachnid::default_monster_slots_base;
		if (st.was_key_specified("reinforcements"))
			reinforcements = st.reinforcements;

		if (self.monsterinfo.monster_slots != 0 && !reinforcements.empty())
			M_SetupReinforcements(reinforcements, self.monsterinfo.reinforcements);
	}

	self.e.s.modelindex = gi_modelindex("models/monsters/arachnid/tris.md2");
	self.e.mins = { -40, -40, -20 };
	self.e.maxs = { 40, 40, 48 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(1000 * st.health_multiplier);
	self.gib_health = -200;

	self.monsterinfo.scale = arachnid::SCALE;

	self.mass = 450;

	@self.pain = arachnid_pain;
	@self.die = arachnid_die;
	@self.monsterinfo.stand = arachnid_stand;
	@self.monsterinfo.walk = arachnid_walk;
	@self.monsterinfo.run = arachnid_run;
	@self.monsterinfo.attack = arachnid_attack;
	@self.monsterinfo.sight = arachnid_sight;
	@self.monsterinfo.setskin = arachnid_setskin;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	gi_linkentity(self.e);

	M_SetAnimation(self, arachnid_move_stand);

	walkmonster_start(self);
}
