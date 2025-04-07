namespace medic
{
    enum frames
    {
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
        wait1,
        wait2,
        wait3,
        wait4,
        wait5,
        wait6,
        wait7,
        wait8,
        wait9,
        wait10,
        wait11,
        wait12,
        wait13,
        wait14,
        wait15,
        wait16,
        wait17,
        wait18,
        wait19,
        wait20,
        wait21,
        wait22,
        wait23,
        wait24,
        wait25,
        wait26,
        wait27,
        wait28,
        wait29,
        wait30,
        wait31,
        wait32,
        wait33,
        wait34,
        wait35,
        wait36,
        wait37,
        wait38,
        wait39,
        wait40,
        wait41,
        wait42,
        wait43,
        wait44,
        wait45,
        wait46,
        wait47,
        wait48,
        wait49,
        wait50,
        wait51,
        wait52,
        wait53,
        wait54,
        wait55,
        wait56,
        wait57,
        wait58,
        wait59,
        wait60,
        wait61,
        wait62,
        wait63,
        wait64,
        wait65,
        wait66,
        wait67,
        wait68,
        wait69,
        wait70,
        wait71,
        wait72,
        wait73,
        wait74,
        wait75,
        wait76,
        wait77,
        wait78,
        wait79,
        wait80,
        wait81,
        wait82,
        wait83,
        wait84,
        wait85,
        wait86,
        wait87,
        wait88,
        wait89,
        wait90,
        run1,
        run2,
        run3,
        run4,
        run5,
        run6,
        paina1,
        paina2,
        paina3,
        paina4,
        paina5,
        paina6,
        paina7,
        paina8,
        painb1,
        painb2,
        painb3,
        painb4,
        painb5,
        painb6,
        painb7,
        painb8,
        painb9,
        painb10,
        painb11,
        painb12,
        painb13,
        painb14,
        painb15,
        duck1,
        duck2,
        duck3,
        duck4,
        duck5,
        duck6,
        duck7,
        duck8,
        duck9,
        duck10,
        duck11,
        duck12,
        duck13,
        duck14,
        duck15,
        duck16,
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
        death23,
        death24,
        death25,
        death26,
        death27,
        death28,
        death29,
        death30,
        attack1,
        attack2,
        attack3,
        attack4,
        attack5,
        attack6,
        attack7,
        attack8,
        attack9,
        attack10,
        attack11,
        attack12,
        attack13,
        attack14,
        attack15,
        attack16,
        attack17,
        attack18,
        attack19,
        attack20,
        attack21,
        attack22,
        attack23,
        attack24,
        attack25,
        attack26,
        attack27,
        attack28,
        attack29,
        attack30,
        attack31,
        attack32,
        attack33,
        attack34,
        attack35,
        attack36,
        attack37,
        attack38,
        attack39,
        attack40,
        attack41,
        attack42,
        attack43,
        attack44,
        attack45,
        attack46,
        attack47,
        attack48,
        attack49,
        attack50,
        attack51,
        attack52,
        attack53,
        attack54,
        attack55,
        attack56,
        attack57,
        attack58,
        attack59,
        attack60
    };

    const float SCALE = 1.000000f;
}

const float MEDIC_MIN_DISTANCE = 32;
const float MEDIC_MAX_HEAL_DISTANCE = 400;
const gtime_t MEDIC_TRY_TIME = time_sec(10);

// FIXME -
//
// owner moved to monsterinfo.healer instead
//
// For some reason, the healed monsters are rarely ending up in the floor
//
// 5/15/1998 I think I fixed these, keep an eye on them

namespace medic::sounds
{
    cached_soundindex idle1("medic/idle.wav");
    cached_soundindex pain1("medic/medpain1.wav");
    cached_soundindex pain2("medic/medpain2.wav");
    cached_soundindex die("medic/meddeth1.wav");
    cached_soundindex sight("medic/medsght1.wav");
    cached_soundindex search("medic/medsrch1.wav");
    cached_soundindex hook_launch("medic/medatck2.wav");
    cached_soundindex hook_hit("medic/medatck3.wav");
    cached_soundindex hook_heal("medic/medatck4.wav");
    cached_soundindex hook_retract("medic/medatck5.wav");

    // PMM - commander sounds
    cached_soundindex commander_idle1("medic_commander/medidle.wav");
    cached_soundindex commander_pain1("medic_commander/medpain1.wav");
    cached_soundindex commander_pain2("medic_commander/medpain2.wav");
    cached_soundindex commander_die("medic_commander/meddeth.wav");
    cached_soundindex commander_sight("medic_commander/medsght.wav");
    cached_soundindex commander_search("medic_commander/medsrch.wav");
    cached_soundindex commander_hook_launch("medic_commander/medatck2c.wav");
    cached_soundindex commander_hook_hit("medic_commander/medatck3a.wav");
    cached_soundindex commander_hook_heal("medic_commander/medatck4a.wav");
    cached_soundindex commander_hook_retract("medic_commander/medatck5a.wav");
    cached_soundindex commander_spawn("medic_commander/monsterspawn1.wav");
}

namespace medic
{
    const string default_reinforcements = "monster_soldier_light 1;monster_soldier 2;monster_soldier_ss 2;monster_infantry 3;monster_gunner 4;monster_medic 5;monster_gladiator 6";
    const int32 default_monster_slots_base = 3;

    const array<vec3_t> reinforcement_position = {
        vec3_t(80, 0, 0),
        vec3_t(40, 60, 0),
        vec3_t(40, -60, 0),
        vec3_t(0, 80, 0),
        vec3_t(0, -80, 0)
    };
}

const int MAX_REINFORCEMENTS = 5; // max number of spawns we can do at once.

// AS_TODO move to reinforcements.as?
const float inverse_log_slots = pow(2, MAX_REINFORCEMENTS);

// filter out the reinforcement indices we can pick given the space we have left
void M_PickValidReinforcements(ASEntity &self, int32 space, array<uint8> &output)
{
	output.resize(0);

	for (uint8 i = 0; i < self.monsterinfo.reinforcements.length(); i++)
		if (self.monsterinfo.reinforcements[i].strength <= space)
			output.push_back(i);
}

// pick an array of reinforcements to use; note that this does not modify `self`
array<uint8> M_PickReinforcements(ASEntity &self, int32 &out num_chosen, int32 max_slots = 0)
{
	array<uint8> available;
	array<uint8> chosen;

	// decide how many things we want to spawn;
	// this is on a logarithmic scale
	// so we don't spawn too much too often.
	int32 num_slots = max(1, int32(log2(frandom(inverse_log_slots))));

	// we only have this many slots left to use
	int32 remaining = self.monsterinfo.monster_slots - self.monsterinfo.monster_used;
	
	for (num_chosen = 0; num_chosen < num_slots; num_chosen++)
	{
		// ran out of slots!
		if ((max_slots != 0 && num_chosen == max_slots) || remaining == 0)
			break;

		// get everything we could choose
		M_PickValidReinforcements(self, remaining, available);

		// can't pick any
		if (available.empty())
			break;

		// select monster, TODO fairly
		chosen.push_back(available[irandom(available.length())]);

		remaining -= self.monsterinfo.reinforcements[chosen[num_chosen]].strength;
	}

	return chosen;
}

void M_SetupReinforcements(const string &in reinforcements, array<reinforcement_t> &out list)
{
	// count up the semicolons
	if (reinforcements.empty())
		return;

	// parse
    tokenizer_t tokenizer(reinforcements);
    tokenizer.separators = "; ";

	while (tokenizer.next())
	{
		if (!tokenizer.has_token)
        {
            gi_Com_Print("reinforcements string too long or ends early\n");
			break;
        }

        reinforcement_t r;

		r.classname = tokenizer.as_string();

        tokenizer.next();

		r.strength = tokenizer.as_int32();

        if (r.strength < 0)
        {
            gi_Com_Print("reinforcements string has bad strength; invalid\n");
			break;
        }

		ASEntity @newEnt = G_Spawn();

		newEnt.classname = r.classname;

		newEnt.monsterinfo.aiflags = ai_flags_t(newEnt.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

		ED_CallSpawn(newEnt);

		r.mins = newEnt.e.mins;
		r.maxs = newEnt.e.maxs;

		G_FreeEdict(newEnt);

		list.push_back(r);
	}
}

int32 M_SlotsLeft(ASEntity &self)
{
	return self.monsterinfo.monster_slots - self.monsterinfo.monster_used;
}

void fixHealerEnemy(ASEntity &self)
{
	if (self.oldenemy !is null && self.oldenemy.e.inuse && self.oldenemy.health > 0)
	{
		@self.enemy = self.oldenemy;
		HuntTarget(self, false);
	}
	else
	{
		@self.enemy = @self.goalentity = null;
		@self.oldenemy = null;
		if (!FindTarget(self))
		{
			// no valid enemy, so stop acting
			self.monsterinfo.pausetime = HOLD_FOREVER;
			return;
		}
	}
}

void cleanupHeal(ASEntity &self)
{
	// clean up target, if we have one and it's legit
	if (self.enemy !is null && self.enemy.e.inuse && self.enemy.client is null && (self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
		cleanupHealTarget(self.enemy);

	fixHealerEnemy(self);
}

void abortHeal(ASEntity &self, bool gib, bool mark)
{
	int			 hurt;
	const vec3_t pain_normal = { 0, 0, 1 };

	if (self.enemy !is null && self.enemy.e.inuse && self.enemy.client is null && (self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		cleanupHealTarget(self.enemy);

		// gib em!
		if (mark)
		{
			// if the first badMedic slot is filled by a medic, skip it and use the second one
			if ((self.enemy.monsterinfo.badMedic1 !is null) && (self.enemy.monsterinfo.badMedic1.e.inuse) && (self.enemy.monsterinfo.badMedic1.classname.findFirst("monster_medic") == 0))
			{
				@self.enemy.monsterinfo.badMedic2 = self;
			}
			else
			{
				@self.enemy.monsterinfo.badMedic1 = self;
			}
		}

		if (gib)
		{
			// [Paril-KEX] health added in case of weird edge case
			// with fixbot "healing" the corpses
			if (self.enemy.gib_health != 0)
				hurt = -self.enemy.gib_health + max(0, self.enemy.health);
			else
				hurt = 500;

			T_Damage(self.enemy, self, self, vec3_origin, self.enemy.e.s.origin,
					 pain_normal, hurt, 0, damageflags_t::NONE, mod_id_t::UNKNOWN);
		}

		cleanupHeal(self);
	}

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
	self.monsterinfo.medicTries = 0;
}

bool finishHeal(ASEntity &self)
{
	ASEntity @healee = self.enemy;

	healee.spawnflags = spawnflags::NONE;
	healee.monsterinfo.aiflags = ai_flags_t(healee.monsterinfo.aiflags & ai_flags_t::RESPAWN_MASK);
	healee.target = "";
	healee.targetname = "";
	healee.combattarget = "";
	healee.deathtarget = "";
	healee.healthtarget = "";
	healee.itemtarget = "";
	@healee.monsterinfo.healer = self;

	vec3_t maxs = healee.e.maxs;
	maxs[2] += 48; // compensate for change when they die

	trace_t tr = gi_trace(healee.e.s.origin, healee.e.mins, maxs, healee.e.s.origin, healee.e, contents_t::MASK_MONSTERSOLID);

	if (tr.startsolid || tr.allsolid)
	{
		abortHeal(self, true, false);
		return false;
	}
	else if (tr.ent !is world.e)
	{
		abortHeal(self, true, false);
		return false;
	}

	healee.monsterinfo.aiflags = ai_flags_t(healee.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS | ai_flags_t::DO_NOT_COUNT);

	// backup & restore health stuff, because of multipliers
	int32 old_max_health = healee.max_health;
	item_id_t old_power_armor_type = healee.monsterinfo.initial_power_armor_type;
	int32 old_power_armor_power = healee.monsterinfo.max_power_armor_power;
	int32 old_base_health = healee.monsterinfo.base_health;
	int32 old_health_scaling = healee.monsterinfo.health_scaling;
	array<reinforcement_t> @reinforcements = healee.monsterinfo.reinforcements;
	int32 slots_from_commander = healee.monsterinfo.slots_from_commander;
	int32 monster_slots = healee.monsterinfo.monster_slots;
	int32 monster_used = healee.monsterinfo.monster_used;
	int32 old_gib_health = healee.gib_health;

	spawn_temp_t st;
	st.keys_specified.add("reinforcements");
	st.reinforcements = "";

	ED_CallSpawn(healee, st);

	healee.monsterinfo.slots_from_commander = slots_from_commander;
	healee.monsterinfo.reinforcements = reinforcements;
	healee.monsterinfo.monster_slots = monster_slots;
	healee.monsterinfo.monster_used = monster_used;

	healee.gib_health = old_gib_health / 2;
	healee.health = healee.max_health = old_max_health;
	healee.monsterinfo.power_armor_power = healee.monsterinfo.max_power_armor_power = old_power_armor_power;
	healee.monsterinfo.power_armor_type = healee.monsterinfo.initial_power_armor_type = old_power_armor_type;
	healee.monsterinfo.base_health = old_base_health;
	healee.monsterinfo.health_scaling = old_health_scaling;

	if (healee.monsterinfo.setskin !is null)
		healee.monsterinfo.setskin(healee);

	if (healee.think !is null)
	{
		healee.nextthink = level.time;
		healee.think(healee);
	}
	healee.monsterinfo.aiflags = ai_flags_t(healee.monsterinfo.aiflags & ~ai_flags_t::RESURRECTING);
	healee.monsterinfo.aiflags = ai_flags_t(healee.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS | ai_flags_t::DO_NOT_COUNT);
	// turn off flies
	healee.e.s.effects = effects_t(healee.e.s.effects & ~effects_t::FLIES);
	@healee.monsterinfo.healer = null;

	// switch our enemy
	fixHealerEnemy(self);

	// switch revivee's enemy
	@healee.oldenemy = null;
	@healee.enemy = self.enemy;

	if (healee.enemy !is null)
		FoundTarget(healee);
	else
	{
		@healee.enemy = null;
		if (!FindTarget(healee))
		{
			// no valid enemy, so stop acting
			healee.monsterinfo.pausetime = HOLD_FOREVER;
			healee.monsterinfo.stand(healee);
		}
	}

	cleanupHeal(self);
	return true;
}

bool canReach(ASEntity &self, ASEntity &other)
{
	vec3_t	spot1;
	vec3_t	spot2;
	trace_t trace;

	spot1 = self.e.s.origin;
	spot1[2] += self.viewheight;
	spot2 = other.e.s.origin;
	spot2[2] += other.viewheight;
	trace = gi_traceline(spot1, spot2, self.e, contents_t(contents_t::MASK_PROJECTILE | contents_t::MASK_WATER));
	return trace.fraction == 1.0f || trace.ent is other.e;
}

ASEntity @healFindMonster(ASEntity &self, float radius)
{
	ASEntity @ent = null;
	ASEntity @best = null;

	while ((@ent = findradius(ent, self.e.s.origin, radius)) !is null)
	{
		if (ent is self)
			continue;
		if ((ent.e.svflags & svflags_t::MONSTER) == 0)
			continue;
		if ((ent.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
			continue;
		// check to make sure we haven't bailed on this guy already
		if ((ent.monsterinfo.badMedic1 is self) || (ent.monsterinfo.badMedic2 is self))
			continue;
		if (ent.monsterinfo.healer !is null)
			// FIXME - this is correcting a bug that is somewhere else
			// if the healer is a monster, and it's in medic mode .. continue .. otherwise
			//   we will override the healer, if it passes all the other tests
			if ((ent.monsterinfo.healer.e.inuse) && (ent.monsterinfo.healer.health > 0) &&
				(ent.monsterinfo.healer.e.svflags & svflags_t::MONSTER) != 0 && (ent.monsterinfo.healer.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
				continue;
		if (ent.health > 0)
			continue;
		if ((ent.nextthink) && (ent.think !is monster_dead_think))
			continue;
		if (!visible(self, ent))
			continue;
		if (ent.classname.findFirst("player") == 0) // stop it from trying to heal player_noise entities
			continue;
		// FIXME - there's got to be a better way ..
		// make sure we don't spawn people right on top of us
		if (realrange(self, ent) <= MEDIC_MIN_DISTANCE)
			continue;
		if (best is null)
		{
			@best = ent;
			continue;
		}
		if (ent.max_health <= best.max_health)
			continue;
		@best = ent;
	}

	return best;
}

ASEntity @medic_FindDeadMonster(ASEntity &self)
{
	float	 radius;

	if (self.monsterinfo.react_to_damage_time > level.time)
		return null;

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		radius = MEDIC_MAX_HEAL_DISTANCE;
	else
		radius = 1024;

	ASEntity @best = healFindMonster(self, radius);

	if (best !is null)
		self.timestamp = level.time + MEDIC_TRY_TIME;

	return best;
}

void medic_idle(ASEntity &self)
{
	ASEntity @ent;

	// PMM - commander sounds
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::idle1, 1, ATTN_IDLE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_idle1, 1, ATTN_IDLE, 0);

	if (self.oldenemy is null)
	{
		@ent = medic_FindDeadMonster(self);
		if (ent !is null)
		{
			@self.oldenemy = self.enemy;
			@self.enemy = ent;
			@self.enemy.monsterinfo.healer = self;
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MEDIC);
			FoundTarget(self);
		}
	}
}

void medic_search(ASEntity &self)
{
	ASEntity @ent;

	// PMM - commander sounds
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::search, 1, ATTN_IDLE, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_search, 1, ATTN_IDLE, 0);

	if (self.oldenemy is null)
	{
		@ent = medic_FindDeadMonster(self);
		if (ent !is null)
		{
			@self.oldenemy = self.enemy;
			@self.enemy = ent;
			@self.enemy.monsterinfo.healer = self;
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MEDIC);
			FoundTarget(self);
		}
	}
}

void medic_sight(ASEntity &self, ASEntity &other)
{
	// PMM - commander sounds
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::sight, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_sight, 1, ATTN_NORM, 0);
}

const array<mframe_t> medic_frames_stand = {
	mframe_t(ai_stand, 0, medic_idle),
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
};
const mmove_t medic_move_stand = mmove_t(medic::frames::wait1, medic::frames::wait90, medic_frames_stand, null);

void medic_stand(ASEntity &self)
{
	M_SetAnimation(self, medic_move_stand);
}

const array<mframe_t> medic_frames_walk = {
	mframe_t(ai_walk, 6.2f),
	mframe_t(ai_walk, 18.1f, monster_footstep),
	mframe_t(ai_walk, 1),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk, 9),
	mframe_t(ai_walk, 11),
	mframe_t(ai_walk, 11.6f, monster_footstep),
	mframe_t(ai_walk, 2),
	mframe_t(ai_walk, 9.9f),
	mframe_t(ai_walk, 14),
	mframe_t(ai_walk, 9.3f)
};
const mmove_t medic_move_walk = mmove_t(medic::frames::walk1, medic::frames::walk12, medic_frames_walk, null);

void medic_walk(ASEntity &self)
{
	M_SetAnimation(self, medic_move_walk);
}

const array<mframe_t> medic_frames_run = {
	mframe_t(ai_run, 18),
	mframe_t(ai_run, 22.5f, monster_footstep),
	mframe_t(ai_run, 25.4f, monster_done_dodge),
	mframe_t(ai_run, 23.4f, monster_footstep),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 35.6f)
};
const mmove_t medic_move_run = mmove_t(medic::frames::run1, medic::frames::run6, medic_frames_run, null);

void medic_run(ASEntity &self)
{
	monster_done_dodge(self);

	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) == 0)
	{
		ASEntity @ent;

		@ent = medic_FindDeadMonster(self);
		if (ent !is null)
		{
			@self.oldenemy = self.enemy;
			@self.enemy = ent;
			@self.enemy.monsterinfo.healer = self;
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MEDIC);
			FoundTarget(self);
			return;
		}
	}

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, medic_move_stand);
	else
		M_SetAnimation(self, medic_move_run);
}

const array<mframe_t> medic_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t medic_move_pain1 = mmove_t(medic::frames::paina2, medic::frames::paina6, medic_frames_pain1, medic_run);

const array<mframe_t> medic_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t medic_move_pain2 = mmove_t(medic::frames::painb2, medic::frames::painb13, medic_frames_pain2, medic_run);

void medic_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	monster_done_dodge(self);

	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	float r = frandom();

	if (self.mass > 400)
	{
		if (damage < 35)
		{
			gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_pain1, 1, ATTN_NORM, 0);

			if (mod.id != mod_id_t::CHAINFIST)
				return;
		}

		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_pain2, 1, ATTN_NORM, 0);
	}
	else if (r < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::pain2, 1, ATTN_NORM, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	// if we're healing someone, we ignore pain
	if (mod.id != mod_id_t::CHAINFIST && (self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
		return;

	if (self.mass > 400)
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);

		if (r < (min((float(damage * 0.005f)), 0.5f))) // no more than 50% chance of big pain
			M_SetAnimation(self, medic_move_pain2);
		else
			M_SetAnimation(self, medic_move_pain1);
	}
	else if (r < 0.5f)
		M_SetAnimation(self, medic_move_pain1);
	else
		M_SetAnimation(self, medic_move_pain2);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);

	abortHeal(self, false, false);
}

void medic_setskin(ASEntity &self)
{
	if ((self.health < (self.max_health / 2)))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

void medic_fire_blaster(ASEntity &self)
{
	vec3_t	  start;
	vec3_t	  forward, right;
	vec3_t	  end;
	vec3_t	  dir;
	effects_t effect;
	int		  damage = 2;
	monster_muzzle_t mz;

	// paranoia checking
	if (!(self.enemy !is null && self.enemy.e.inuse))
		return;

	if ((self.e.s.frame == medic::frames::attack9) || (self.e.s.frame == medic::frames::attack12))
	{
		effect = effects_t::BLASTER;
		damage = 6;
		mz = (self.mass > 400) ? monster_muzzle_t::MEDIC_BLASTER_2 : monster_muzzle_t::MEDIC_BLASTER_1;
	}
	else
	{
		effect = ((self.e.s.frame % 4) != 0) ? effects_t::NONE : effects_t::HYPERBLASTER;
		mz = monster_muzzle_t(((self.mass > 400) ? monster_muzzle_t::MEDIC_HYPERBLASTER2_1 : monster_muzzle_t::MEDIC_HYPERBLASTER1_1) + (self.e.s.frame - medic::frames::attack19));
	}

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[mz], forward, right);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	if (self.enemy.classname == "tesla_mine")
		damage = 3;

	// medic commander shoots blaster2
	if (self.mass > 400)
		monster_fire_blaster2(self, start, dir, damage, 1000, mz, effect);
	else
		monster_fire_blaster(self, start, dir, damage, 1000, mz, effect);
}

void medic_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void medic_shrink(ASEntity &self)
{
	self.e.maxs[2] = -2;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> medic_frames_death = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, -18.f, monster_footstep),
	mframe_t(ai_move, -10.f, medic_shrink),
	mframe_t(ai_move, -6.f),
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
	mframe_t(ai_move)
};
const mmove_t medic_move_death = mmove_t(medic::frames::death2, medic::frames::death30, medic_frames_death, medic_dead);

void medic_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// if we had a pending patient, he was already freed up in Killed

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t("models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
			gib_def_t("models/monsters/medic/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t(2, "models/monsters/medic/gibs/leg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/medic/gibs/hook.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/medic/gibs/gun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/medic/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});

		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	//	PMM
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::die, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, medic::sounds::commander_die, 1, ATTN_NORM, 0);
	//
	self.deadflag = true;
	self.takedamage = true;

	M_SetAnimation(self, medic_move_death);
}

const array<mframe_t> medic_frames_duck = {
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1, monster_duck_down),
	mframe_t(ai_move, -1, monster_duck_hold),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1), // PMM - duck up used to be here
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1),
	mframe_t(ai_move, -1, monster_duck_up)
};
const mmove_t medic_move_duck = mmove_t(medic::frames::duck2, medic::frames::duck14, medic_frames_duck, medic_run);

// PMM -- moved dodge code to after attack code so I can reference attack frames

const array<mframe_t> medic_frames_attackHyperBlaster = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	// [Paril-KEX] end on 36 as intended
	mframe_t(ai_charge, 2.f), // 33
	mframe_t(ai_charge, 3.f, monster_footstep),
};
const mmove_t medic_move_attackHyperBlaster = mmove_t(medic::frames::attack15, medic::frames::attack34, medic_frames_attackHyperBlaster, medic_run);

void medic_quick_attack(ASEntity &self)
{
	if (frandom() < 0.5f)
	{
		M_SetAnimation(self, medic_move_attackHyperBlaster, false);
		self.monsterinfo.nextframe = medic::frames::attack16;
	}
}

void medic_continue(ASEntity &self)
{
	if (visible(self, self.enemy))
		if (frandom() <= 0.95f)
			M_SetAnimation(self, medic_move_attackHyperBlaster, false);
}

const array<mframe_t> medic_frames_attackBlaster = {
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 2),
	mframe_t(ai_charge, 0, medic_quick_attack),
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, medic_fire_blaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, medic_continue) // Change to medic_continue... Else, go to frame 32
};
const mmove_t medic_move_attackBlaster = mmove_t(medic::frames::attack3, medic::frames::attack14, medic_frames_attackBlaster, medic_run);

void medic_hook_launch(ASEntity &self)
{
	// PMM - commander sounds
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::hook_launch, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::commander_hook_launch, 1, ATTN_NORM, 0);
}

const array<vec3_t> medic_cable_offsets = {
	{ 45.0f, -9.2f, 15.5f },
	{ 48.4f, -9.7f, 15.2f },
	{ 47.8f, -9.8f, 15.8f },
	{ 47.3f, -9.3f, 14.3f },
	{ 45.4f, -10.1f, 13.1f },
	{ 41.9f, -12.7f, 12.0f },
	{ 37.8f, -15.8f, 11.2f },
	{ 34.3f, -18.4f, 10.7f },
	{ 32.7f, -19.7f, 10.4f },
	{ 32.7f, -19.7f, 10.4f }
};

void medic_cable_attack(ASEntity &self)
{
	vec3_t	start, end, f, r;
	trace_t tr;
	vec3_t	dir;
	float	distance;

	if ((self.enemy is null) || (!self.enemy.e.inuse) || (self.enemy.e.s.effects & effects_t::GIB) != 0)
	{
		abortHeal(self, false, false);
		return;
	}

	// we switched back to a player; let the animation finish
	if (self.enemy.client !is null)
		return;

	// see if our enemy has changed to a client, or our target has more than 0 health,
	// abort it .. we got switched to someone else due to damage
	if (self.enemy.health > 0)
	{
		abortHeal(self, false, false);
		return;
	}

	AngleVectors(self.e.s.angles, f, r);
	start = M_ProjectFlashSource(self, medic_cable_offsets[self.e.s.frame - medic::frames::attack42], f, r);

	// check for max distance
	// not needed, done in checkattack
	// check for min distance
	dir = start - self.enemy.e.s.origin;
	distance = dir.length();
	if (distance < MEDIC_MIN_DISTANCE)
	{
		abortHeal(self, true, false);
		self.monsterinfo.nextframe = medic::frames::attack52;
		return;
	}

	tr = gi_traceline(start, self.enemy.e.s.origin, self.e, MASK_SOLID);
	if (tr.fraction != 1.0f && tr.ent !is self.enemy.e)
	{
		if (tr.ent is world.e)
		{
			// give up on second try
			if (self.monsterinfo.medicTries > 1)
			{
				abortHeal(self, false, true);
				self.monsterinfo.nextframe = medic::frames::attack52;
				return;
			}
			self.monsterinfo.medicTries++;
			cleanupHeal(self);
			self.monsterinfo.nextframe = medic::frames::attack52;
			return;
		}
		abortHeal(self, false, false);
		self.monsterinfo.nextframe = medic::frames::attack52;
		return;
	}

	if (self.e.s.frame == medic::frames::attack43)
	{
		// PMM - commander sounds
		if (self.mass == 400)
			gi_sound(self.enemy.e, soundchan_t::AUTO, medic::sounds::hook_hit, 1, ATTN_NORM, 0);
		else
			gi_sound(self.enemy.e, soundchan_t::AUTO, medic::sounds::commander_hook_hit, 1, ATTN_NORM, 0);

		self.enemy.monsterinfo.aiflags = ai_flags_t(self.enemy.monsterinfo.aiflags | ai_flags_t::RESURRECTING);
		self.enemy.takedamage = false;
		M_SetEffects(self.enemy);
	}
	else if (self.e.s.frame == medic::frames::attack50)
	{
		if (!finishHeal(self))
			self.monsterinfo.nextframe = medic::frames::attack52;

		return;
	}
	else
	{
		if (self.e.s.frame == medic::frames::attack44)
		{
			// PMM - medic commander sounds
			if (self.mass == 400)
				gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::hook_heal, 1, ATTN_NORM, 0);
			else
				gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::commander_hook_heal, 1, ATTN_NORM, 0);
		}
	}

	// adjust start for beam origin being in middle of a segment
	start += (f * 8);

	// adjust end z for end spot since the monster is currently dead
	end = self.enemy.e.s.origin;
	end[2] = (self.enemy.e.absmin[2] + self.enemy.e.absmax[2]) / 2;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::MEDIC_CABLE_ATTACK);
	gi_WriteEntity(self.e);
	gi_WritePosition(start);
	gi_WritePosition(end);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);
}

void medic_hook_retract(ASEntity &self)
{
	if (self.mass == 400)
		gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::hook_retract, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::hook_retract, 1, ATTN_NORM, 0);

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
	fixHealerEnemy(self);
}

const array<mframe_t> medic_frames_attackCable = {
	// ROGUE - negated 36-40 so he scoots back from his target a little
	// ROGUE - switched 33-36 to ai_charge
	// ROGUE - changed frame 52 to 60 to compensate for changes in 36-40
	// [Paril-KEX] started on 36 as they intended
	mframe_t(ai_charge, -4.7f), // 37
	mframe_t(ai_charge, -5.f),
	mframe_t(ai_charge, -6.f),
	mframe_t(ai_charge, -4.f), // 40
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_move, 0, medic_hook_launch),	// 42
	mframe_t(ai_move, 0, medic_cable_attack), // 43
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack),
	mframe_t(ai_move, 0, medic_cable_attack), // 51
	mframe_t(ai_move, 0, medic_hook_retract), // 52
	mframe_t(ai_move, -1.5f),
	mframe_t(ai_move, -1.2f, monster_footstep),
	mframe_t(ai_move, -3.f)
};
const mmove_t medic_move_attackCable = mmove_t(medic::frames::attack37, medic::frames::attack55, medic_frames_attackCable, medic_run);

void medic_start_spawn(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, medic::sounds::commander_spawn, 1, ATTN_NORM, 0);
	self.monsterinfo.nextframe = medic::frames::attack48;
}

void medic_determine_spawn(ASEntity &self)
{
	vec3_t f, r, offset, startpoint, spawnpoint;
	int	   count;
	int	   num_success = 0;

	AngleVectors(self.e.s.angles, f, r);

	int num_summoned;
	self.monsterinfo.chosen_reinforcements = M_PickReinforcements(self, num_summoned);

	for (count = 0; count < num_summoned; count++)
	{
		offset = medic::reinforcement_position[count];

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
				num_success++;
				// we found a spot, we're done here
				count = num_summoned;
			}
		}
	}

	// see if we have any success by spinning around
	if (num_success == 0)
	{
		for (count = 0; count < num_summoned; count++)
		{
			offset = medic::reinforcement_position[count];

			if (self.e.s.scale != 0)
				offset *= self.e.s.scale;

			// check behind
			offset[0] *= -1.0f;
			offset[1] *= -1.0f;
			startpoint = M_ProjectFlashSource(self, offset, f, r);
			// a little off the ground
			startpoint[2] += 10;

			auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[count]];

			if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32))
			{
				if (CheckGroundSpawnPoint(spawnpoint, reinforcement.mins, reinforcement.maxs, 256, -1))
				{
					num_success++;
					// we found a spot, we're done here
					count = num_summoned;
				}
			}
		}

		if (num_success != 0)
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MANUAL_STEERING);
			self.ideal_yaw = anglemod(self.e.s.angles.yaw) + 180;
			if (self.ideal_yaw > 360.0f)
				self.ideal_yaw -= 360.0f;
		}
	}

	if (num_success == 0)
		self.monsterinfo.nextframe = medic::frames::attack53;
}

void medic_spawngrows(ASEntity &self)
{
	vec3_t f, r, offset, startpoint, spawnpoint;
	int	   count;
	int	   num_summoned; // should be 1, 3, or 5
	int	   num_success = 0;
	float  current_yaw;

	// if we've been directed to turn around
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
	{
		current_yaw = anglemod(self.e.s.angles.yaw);
		if (abs(current_yaw - self.ideal_yaw) > 0.1f)
		{
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HOLD_FRAME);
			return;
		}

		// done turning around
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);
	}

	AngleVectors(self.e.s.angles, f, r);

	num_summoned = self.monsterinfo.chosen_reinforcements.length();

	for (count = 0; count < num_summoned; count++)
	{
		offset = medic::reinforcement_position[count];

		startpoint = M_ProjectFlashSource(self, offset, f, r);

		// a little off the ground
		startpoint[2] += 10 * (self.e.s.scale != 0 ? self.e.s.scale : 1.0f);

		auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[count]];

		if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32))
		{
			if (CheckGroundSpawnPoint(spawnpoint, reinforcement.mins, reinforcement.maxs, 256, -1))
			{
				num_success++;
				float radius = (reinforcement.maxs - reinforcement.mins).length() * 0.5f;
				SpawnGrow_Spawn(spawnpoint + (reinforcement.mins + reinforcement.maxs), radius, radius * 2.f);
			}
		}
	}

	if (num_success == 0)
		self.monsterinfo.nextframe = medic::frames::attack53;
}

void medic_finish_spawn(ASEntity &self)
{
	ASEntity @ent;
	vec3_t	 f, r, offset, startpoint, spawnpoint;
	int		 count;
	int		 num_summoned; // should be 1, 3, or 5
	ASEntity @designated_enemy;

	AngleVectors(self.e.s.angles, f, r);

	num_summoned = self.monsterinfo.chosen_reinforcements.length();

	for (count = 0; count < num_summoned; count++)
	{
		auto @reinforcement = self.monsterinfo.reinforcements[self.monsterinfo.chosen_reinforcements[count]];
		offset = medic::reinforcement_position[count];

		startpoint = M_ProjectFlashSource(self, offset, f, r);

		// a little off the ground
		startpoint[2] += 10 * (self.e.s.scale != 0 ? self.e.s.scale : 1.0f);

		@ent = null;
		if (FindSpawnPoint(startpoint, reinforcement.mins, reinforcement.maxs, spawnpoint, 32))
		{
			if (CheckSpawnPoint(spawnpoint, reinforcement.mins, reinforcement.maxs))
				@ent = CreateGroundMonster(spawnpoint, self.e.s.angles, reinforcement.mins, reinforcement.maxs, reinforcement.classname, 256);
		}

		if (ent is null)
			continue;

		if (ent.think !is null)
		{
			ent.nextthink = level.time;
			ent.think(ent);
		}

		ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS | ai_flags_t::DO_NOT_COUNT | ai_flags_t::SPAWNED_COMMANDER | ai_flags_t::SPAWNED_NEEDS_GIB);
		@ent.monsterinfo.commander = self;
		ent.monsterinfo.slots_from_commander = reinforcement.strength;
		self.monsterinfo.monster_used += reinforcement.strength;

		if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			@designated_enemy = self.oldenemy;
		else
			@designated_enemy = self.enemy;

		if (coop.integer != 0)
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

		if ((designated_enemy !is null) && (designated_enemy.e.inuse) && (designated_enemy.health > 0))
		{
			@ent.enemy = designated_enemy;
			FoundTarget(ent);
		}
		else
		{
			@ent.enemy = null;
			ent.monsterinfo.stand(ent);
		}
	}
}

const array<mframe_t> medic_frames_callReinforcements = {
	// ROGUE - 33-36 now ai_charge
	mframe_t(ai_charge, 2), // 33
	mframe_t(ai_charge, 3),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 4.4f), // 36
	mframe_t(ai_charge, 4.7f),
	mframe_t(ai_charge, 5),
	mframe_t(ai_charge, 6),
	mframe_t(ai_charge, 4), // 40
	mframe_t(ai_charge, 0, monster_footstep),
	mframe_t(ai_move, 0, medic_start_spawn), // 42
	mframe_t(ai_move),					   // 43 -- 43 through 47 are skipped
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, medic_determine_spawn), // 48
	mframe_t(ai_charge, 0, medic_spawngrows),	   // 49
	mframe_t(ai_move),						   // 50
	mframe_t(ai_move),						   // 51
	mframe_t(ai_move, -15, medic_finish_spawn),  // 52
	mframe_t(ai_move, -1.5f),
	mframe_t(ai_move, -1.2f),
	mframe_t(ai_move, -3, monster_footstep)
};
const mmove_t medic_move_callReinforcements = mmove_t(medic::frames::attack33, medic::frames::attack55, medic_frames_callReinforcements, medic_run);

void medic_attack(ASEntity &self)
{
	monster_done_dodge(self);

	float enemy_range = range_to(self, self.enemy);

	// signal from checkattack to spawn
	if ((self.monsterinfo.aiflags & ai_flags_t::BLOCKED) != 0)
	{
		M_SetAnimation(self, medic_move_callReinforcements);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
	}

	float r = frandom();
	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		if ((self.mass > 400) && (r > 0.8f) && M_SlotsLeft(self) != 0)
			M_SetAnimation(self, medic_move_callReinforcements);
		else
			M_SetAnimation(self, medic_move_attackCable);
	}
	else
	{
		if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
		{
			M_SetAnimation(self, medic_move_callReinforcements);
			return;
		}
		if ((self.mass > 400) && (r > 0.2f) && (enemy_range > RANGE_MELEE) && M_SlotsLeft(self) != 0)
			M_SetAnimation(self, medic_move_callReinforcements);
		else
			M_SetAnimation(self, medic_move_attackBlaster);
	}
}

bool medic_checkattack(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		// if our target went away
		if ((self.enemy is null) || (!self.enemy.e.inuse))
		{
			abortHeal(self, false, false);
			self.monsterinfo.nextframe = medic::frames::attack52;
			return false;
		}

		// if we ran out of time, give up
		if (self.timestamp < level.time)
		{
			abortHeal(self, false, true);
			self.monsterinfo.nextframe = medic::frames::attack52;
			self.timestamp = time_zero;
			return false;
		}

		if (realrange(self, self.enemy) < MEDIC_MAX_HEAL_DISTANCE + 10)
		{
			medic_attack(self);
			return true;
		}
		else
		{
			self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
			return false;
		}
	}

	if (self.enemy.client !is null && !visible(self, self.enemy) && M_SlotsLeft(self) != 0)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::BLIND;
		return true;
	}

	// give a LARGE bias to spawning things when we have room
	// use ai_flags_t::BLOCKED as a signal to attack to spawn
	if (self.monsterinfo.monster_slots != 0 && (frandom() < 0.8f) && (M_SlotsLeft(self) > self.monsterinfo.monster_slots * 0.8f) && (realrange(self, self.enemy) > 150))
	{
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		return true;
	}

	// ROGUE
	// since his idle animation looks kinda bad in combat, always attack
	// when he's on a combat point
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
	{
		self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
		return true;
	}

	return M_CheckAttack(self);
}

void MedicCommanderCache()
{
	gi_modelindex("models/items/spawngro3/tris.md2");
}

bool medic_duck(ASEntity &self, gtime_t eta)
{
	//	don't dodge if you're healing
	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
		return false;

	if ((self.monsterinfo.active_move is medic_move_attackHyperBlaster) ||
		(self.monsterinfo.active_move is medic_move_attackCable) ||
		(self.monsterinfo.active_move is medic_move_attackBlaster) ||
		(self.monsterinfo.active_move is medic_move_callReinforcements))
	{
		// he ignores skill
		self.monsterinfo.unduck(self);
		return false;
	}

	M_SetAnimation(self, medic_move_duck);

	return true;
}

bool medic_sidestep(ASEntity &self)
{
	if ((self.monsterinfo.active_move is medic_move_attackHyperBlaster) ||
		(self.monsterinfo.active_move is medic_move_attackCable) ||
		(self.monsterinfo.active_move is medic_move_attackBlaster) ||
		(self.monsterinfo.active_move is medic_move_callReinforcements))
	{
		// if we're shooting, don't dodge
		return false;
	}

	if (self.monsterinfo.active_move !is medic_move_run)
		M_SetAnimation(self, medic_move_run);

	return true;
}

//===========
// PGM
bool medic_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// PGM
//===========

/*QUAKED monster_medic (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
model="models/monsters/medic/tris.md2"
*/
void SP_monster_medic(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/medic/tris.md2");

	gi_modelindex("models/monsters/medic/gibs/chest.md2");
	gi_modelindex("models/monsters/medic/gibs/gun.md2");
	gi_modelindex("models/monsters/medic/gibs/head.md2");
	gi_modelindex("models/monsters/medic/gibs/hook.md2");
	gi_modelindex("models/monsters/medic/gibs/leg.md2");

	self.e.mins = { -24, -24, -24 };
	self.e.maxs = { 24, 24, 32 };

	// PMM
	if (self.classname == "monster_medic_commander")
	{
		self.health = int(600 * st.health_multiplier);
		self.gib_health = -130;
		self.mass = 600;
		self.yaw_speed = 40; // default is 20
		MedicCommanderCache();
	}
	else
	{
		// PMM
		self.health = int(300 * st.health_multiplier);
		self.gib_health = -130;
		self.mass = 400;
	}

	@self.pain = medic_pain;
	@self.die = medic_die;

	@self.monsterinfo.stand = medic_stand;
	@self.monsterinfo.walk = medic_walk;
	@self.monsterinfo.run = medic_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = medic_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = medic_sidestep;
	@self.monsterinfo.blocked = medic_blocked;
	// pmm
	@self.monsterinfo.attack = medic_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = medic_sight;
	@self.monsterinfo.idle = medic_idle;
	@self.monsterinfo.search = medic_search;
	@self.monsterinfo.checkattack = medic_checkattack;
	@self.monsterinfo.setskin = medic_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, medic_move_stand);
	self.monsterinfo.scale = medic::SCALE;

	walkmonster_start(self);

	// PMM
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::IGNORE_SHOTS);

	if (self.mass > 400)
	{
		self.e.s.skinnum = 2;

		// commander sounds
		medic::sounds::commander_idle1.precache();
		medic::sounds::commander_pain1.precache();
		medic::sounds::commander_pain2.precache();
		medic::sounds::commander_die.precache();
		medic::sounds::commander_sight.precache();
		medic::sounds::commander_search.precache();
		medic::sounds::commander_hook_launch.precache();
		medic::sounds::commander_hook_hit.precache();
		medic::sounds::commander_hook_heal.precache();
		medic::sounds::commander_hook_retract.precache();
		medic::sounds::commander_spawn.precache();
		gi_soundindex("tank/tnkatck3.wav");

		string reinforcements;

		if (!st.was_key_specified("monster_slots"))
			self.monsterinfo.monster_slots = medic::default_monster_slots_base;
		if (st.was_key_specified("reinforcements"))
			reinforcements = st.reinforcements;
        else
            reinforcements = medic::default_reinforcements;

		if (self.monsterinfo.monster_slots != 0 && !reinforcements.empty())
		{
			if (skill.integer != 0)
				self.monsterinfo.monster_slots += int(floor(self.monsterinfo.monster_slots * (skill.value / 2.f)));

			M_SetupReinforcements(reinforcements, self.monsterinfo.reinforcements);
		}
	}
	else
	{
		medic::sounds::idle1.precache();
		medic::sounds::pain1.precache();
		medic::sounds::pain2.precache();
		medic::sounds::die.precache();
		medic::sounds::sight.precache();
		medic::sounds::search.precache();
		medic::sounds::hook_launch.precache();
		medic::sounds::hook_hit.precache();
		medic::sounds::hook_heal.precache();
		medic::sounds::hook_retract.precache();
		gi_soundindex("medic/medatck1.wav");

		self.e.s.skinnum = 0;
	}
	// pmm
}

/*QUAKED monster_medic_commander (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
void SP_monster_medic_commander(ASEntity &self)
{
    SP_monster_medic(self);
}