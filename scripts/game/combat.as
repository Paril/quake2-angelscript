enum damageflags_t
{
	NONE = 0,				       // no damage flags
	RADIUS = 0x00000001,		   // damage was indirect
	NO_ARMOR = 0x00000002,	       // armour does not protect from this damage
	ENERGY = 0x00000004,		   // damage is from an energy based weapon
	NO_KNOCKBACK = 0x00000008,     // do not affect velocity, just view angles
	BULLET = 0x00000010,		   // damage is from a bullet (used for ricochets)
	NO_PROTECTION = 0x00000020,    // armor, shields, invulnerability, and godmode have no effect
							       // ROGUE
	DESTROY_ARMOR = 0x00000040,    // damage is done to armor and health.
	NO_REG_ARMOR = 0x00000080,     // damage skips regular armor
	NO_POWER_ARMOR = 0x00000100,   // damage skips power armor
							       // ROGUE
	NO_INDICATOR = 0x00000200      // for clients: no damage indicators
};

// time after damage that we can't respawn on a player for
const gtime_t COOP_DAMAGE_RESPAWN_TIME = time_ms(2000);

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
bool CanDamage(ASEntity &targ, ASEntity &inflictor)
{
    const contents_t damage_mask = contents_t(contents_t::MASK_SOLID | contents_t::PROJECTILECLIP);
	vec3_t	dest;
	trace_t trace;
	
	// bmodels need special checking because their origin is 0,0,0
	vec3_t inflictor_center;
	
	if (inflictor.e.linked)
		inflictor_center = (inflictor.e.absmin + inflictor.e.absmax) * 0.5f;
	else
		inflictor_center = inflictor.e.s.origin;
	
	if (targ.e.solid == solid_t::BSP)
	{
		dest = closest_point_to_box(inflictor_center, targ.e.absmin, targ.e.absmax);

		trace = gi_traceline(inflictor_center, dest, inflictor.e, damage_mask);
		if (trace.fraction == 1.0f)
			return true;
	}

	vec3_t targ_center;
	
	if (targ.e.linked)
		targ_center = (targ.e.absmin + targ.e.absmax) * 0.5f;
	else
		targ_center = targ.e.s.origin;

	trace = gi_traceline(inflictor_center, targ_center, inflictor.e, damage_mask);
	if (trace.fraction == 1.0f)
		return true;

	dest = targ_center;
	dest.x += 15.0f;
	dest.y += 15.0f;
	trace = gi_traceline(inflictor_center, dest, inflictor.e, damage_mask);
	if (trace.fraction == 1.0f)
		return true;

	dest = targ_center;
	dest.x += 15.0f;
	dest.y -= 15.0f;
	trace = gi_traceline(inflictor_center, dest, inflictor.e, damage_mask);
	if (trace.fraction == 1.0f)
		return true;

	dest = targ_center;
	dest.x -= 15.0f;
	dest.y += 15.0f;
	trace = gi_traceline(inflictor_center, dest, inflictor.e, damage_mask);
	if (trace.fraction == 1.0f)
		return true;

	dest = targ_center;
	dest.x -= 15.0f;
	dest.y -= 15.0f;
	trace = gi_traceline(inflictor_center, dest, inflictor.e, damage_mask);
	if (trace.fraction == 1.0f)
		return true;

	return false;
}

/*
============
Killed
============
*/
void Killed(ASEntity &targ, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (targ.health < -999)
		targ.health = -999;

	// [Paril-KEX]
	if ((targ.e.svflags & svflags_t::MONSTER) != 0 && (targ.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		if (targ.enemy !is null && targ.enemy.e.inuse && (targ.enemy.e.svflags & svflags_t::MONSTER) != 0) // god, I hope so
		{
			cleanupHealTarget(targ.enemy);
		}

		// clean up self
		targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
	}

	@targ.enemy = attacker;
	targ.lastMOD = mod;

	// [Paril-KEX] monsters call die in their damage handler
	if ((targ.e.svflags & svflags_t::MONSTER) != 0)
		return;

	if (targ.die !is null)
		targ.die(targ, inflictor, attacker, damage, point, mod);

	if (targ.monsterinfo.setskin !is null)
		targ.monsterinfo.setskin(targ);
}

/*
================
SpawnDamage
================
*/
void SpawnDamage(temp_event_t type, const vec3_t &in origin, const vec3_t &in normal, int damage)
{
	if (damage > 255)
		damage = 255;
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(type);
	//	gi.WriteByte (damage);
	gi_WritePosition(origin);
	gi_WriteDir(normal);
	gi_multicast(origin, multicast_t::PVS, false);
}

/*
============
T_Damage

targ		entity that is being damaged
inflictor	entity that is causing the damage
attacker	entity that caused the inflictor to damage targ
	example: targ=monster, inflictor=rocket, attacker=player

dir			direction of the attack
point		point at which the damage is being inflicted
normal		normal vector from that point
damage		amount of damage being inflicted
knockback	force to be applied against targ as a result of the damage

dflags		these flags are used to control how T_Damage works
	DAMAGE_RADIUS			damage was indirect (from a nearby explosion)
	DAMAGE_NO_ARMOR			armor does not protect from this damage
	DAMAGE_ENERGY			damage is from an energy based weapon
	DAMAGE_NO_KNOCKBACK		do not affect velocity, just view angles
	DAMAGE_BULLET			damage is from a bullet (used for ricochets)
	DAMAGE_NO_PROTECTION	kills godmode, armor, everything
============
*/
int CheckPowerArmor(ASEntity &ent, const vec3_t &in point, const vec3_t &in normal, int damage, damageflags_t dflags)
{
	int		   save;
	item_id_t  power_armor_type;
	int		   damagePerCell;
	temp_event_t		   pa_te_type;
	int		power;
	int		power_used;

	if (ent.health <= 0)
		return 0;

	if (damage == 0)
		return 0;

	if ((dflags & (damageflags_t::NO_ARMOR | damageflags_t::NO_POWER_ARMOR)) != 0) // PGM
		return 0;

	if (ent.client !is null)
	{
		power_armor_type = PowerArmorType(ent);
		power = ent.client.pers.inventory[item_id_t::AMMO_CELLS];
	}
	else if ((ent.e.svflags & svflags_t::MONSTER) != 0)
	{
		power_armor_type = ent.monsterinfo.power_armor_type;
		power = ent.monsterinfo.power_armor_power;
	}
	else
		return 0;

	if (power_armor_type == item_id_t::NULL)
		return 0;
	if (power == 0)
		return 0;

	if (power_armor_type == item_id_t::ITEM_POWER_SCREEN)
	{
		vec3_t vec;
		float  dot;
		vec3_t forward;

		// only works if damage point is in front
		AngleVectors(ent.e.s.angles, forward);
		vec = point - ent.e.s.origin;
		vec.normalize();
		dot = vec.dot(forward);
		if (dot <= 0.3f)
			return 0;

		damagePerCell = 1;
		pa_te_type = temp_event_t::SCREEN_SPARKS;
		damage = damage / 3;
	}
	else
	{
		if (ctf.integer != 0)
			damagePerCell = 1; // power armor is weaker in CTF
		else
			damagePerCell = 2;
		pa_te_type = temp_event_t::SCREEN_SPARKS;
		damage = (2 * damage) / 3;
	}

	// Paril: fix small amounts of damage not
	// being absorbed
	damage = max(1, damage);

	save = power * damagePerCell;

	if (save == 0)
		return 0;

	// [Paril-KEX] energy damage should do more to power armor, not ETF Rifle shots.
	if ((dflags & damageflags_t::ENERGY) != 0)
		save = max(1, save / 2);

	if (save > damage)
		save = damage;

	// [Paril-KEX] energy damage should do more to power armor, not ETF Rifle shots.
	if ((dflags & damageflags_t::ENERGY) != 0)
		power_used = (save / damagePerCell) * 2;
	else
		power_used = save / damagePerCell;

	power_used = max(1, power_used);

	SpawnDamage(pa_te_type, point, normal, save);
	ent.powerarmor_time = level.time + time_ms(200);

	// Paril: adjustment so that power armor
	// always uses damagePerCell even if it does
	// only a single point of damage
	power = max(0, power - max(damagePerCell, power_used));

	if (ent.client !is null)
		ent.client.pers.inventory[item_id_t::AMMO_CELLS] = power;
	else
		ent.monsterinfo.power_armor_power = power;

	// check power armor turn-off states
	if (ent.client !is null)
		G_CheckPowerArmor(ent);
	else if (power == 0)
	{
		gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/mon_power2.wav"), 1.0f, ATTN_NORM, 0.0f);

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::POWER_SPLASH);
		gi_WriteEntity(ent.e);
		gi_WriteByte((power_armor_type == item_id_t::ITEM_POWER_SCREEN) ? 1 : 0);
		gi_multicast(ent.e.s.origin, multicast_t::PHS, false);
	}

	return save;
}

int CheckArmor(ASEntity &ent, const vec3_t &in point, const vec3_t &in normal, int damage, temp_event_t te_sparks,
			   damageflags_t dflags)
{
	ASClient   @client;
	int		   save;
	item_id_t  index;
	const gitem_t	@armor;

	if (damage == 0)
		return 0;

	// ROGUE
	if ((dflags & (damageflags_t::NO_ARMOR | damageflags_t::NO_REG_ARMOR)) != 0)
		// ROGUE
		return 0;

	@client = ent.client;
	index = ArmorIndex(ent);

	if (index == item_id_t::NULL)
		return 0;

	@armor = GetItemByIndex(index);

	if ((dflags & damageflags_t::ENERGY) != 0)
		save = int(ceil(armor.armor_info.energy_protection * damage));
	else
		save = int(ceil(armor.armor_info.normal_protection * damage));

    int power;

	if (client !is null)
		power = client.pers.inventory[index];
	else
		power = ent.monsterinfo.armor_power;

	if (save >= power)
		save = power;

	if (save == 0)
		return 0;

	if (client !is null)
		client.pers.inventory[index] -= save;
	else
    {
		ent.monsterinfo.armor_power -= save;

    	if (ent.monsterinfo.armor_power == 0)
            ent.monsterinfo.armor_type = item_id_t::NULL;
    }

	SpawnDamage(te_sparks, point, normal, save);

	return save;
}

void M_ReactToDamage(ASEntity &targ, ASEntity &attacker, ASEntity &inflictor)
{
	// pmm
	bool new_tesla;

	if ((attacker.client is null) && (attacker.e.svflags & svflags_t::MONSTER) == 0)
		return;

	//=======
	// ROGUE
	// logic for tesla - if you are hit by a tesla, and can't see who you should be mad at (attacker)
	// attack the tesla
	// also, target the tesla if it's a "new" tesla
	if ((inflictor !is null) && (inflictor.classname == "tesla_mine"))
	{
		new_tesla = MarkTeslaArea(targ, inflictor);
		if ((new_tesla || brandom()) && (targ.enemy is null || targ.enemy.classname.empty() || targ.enemy.classname == "tesla_mine"))
			TargetTesla(targ, inflictor);
		return;
	}
	// ROGUE
	//=======

	if (attacker is targ || attacker is targ.enemy)
		return;

	// if we are a good guy monster and our attacker is a player
	// or another good guy, do not get mad at them
	if ((targ.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
	{
		if (attacker.client !is null || (attacker.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
			return;
	}

	// PGM
	//  if we're currently mad at something a target_anger made us mad at, ignore
	//  damage
	if (targ.enemy !is null && (targ.monsterinfo.aiflags & ai_flags_t::TARGET_ANGER) != 0)
	{
		float percentHealth;

		// make sure whatever we were pissed at is still around.
		if (targ.enemy.e.inuse)
		{
			percentHealth = float(targ.health) / float(targ.max_health);
			if (targ.enemy.e.inuse && percentHealth > 0.33f)
				return;
		}

		// remove the target anger flag
		targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::TARGET_ANGER);
	}
	// PGM

	// we recently switched from reacting to damage, don't do it
	if (targ.monsterinfo.react_to_damage_time > level.time)
		return;

	// PMM
	// if we're healing someone, do like above and try to stay with them
	if ((targ.enemy !is null) && (targ.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		float percentHealth;

		percentHealth = float(targ.health) / float(targ.max_health);
		// ignore it some of the time
		if (targ.enemy.e.inuse && percentHealth > 0.25f)
			return;

		// remove the medic flag
		cleanupHealTarget(targ.enemy);
		targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
	}
	// PMM

	// we now know that we are not both good guys
	targ.monsterinfo.react_to_damage_time = level.time + random_time(time_sec(3), time_sec(5));

	// if attacker is a client, get mad at them because he's good and we're not
	if (attacker.client !is null)
	{
		targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::SOUND_TARGET);

		// this can only happen in coop (both new and old enemies are clients)
		// only switch if can't see the current enemy
		if (targ.enemy !is attacker)
		{
			if (targ.enemy !is null && targ.enemy.client !is null)
			{
				if (visible(targ, targ.enemy))
				{
					@targ.oldenemy = attacker;
					return;
				}
				@targ.oldenemy = targ.enemy;
			}

			// [Paril-KEX]
			if ((targ.e.svflags & svflags_t::MONSTER) != 0 && (targ.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			{
				if (targ.enemy !is null && targ.enemy.e.inuse && (targ.enemy.e.svflags & svflags_t::MONSTER) != 0) // god, I hope so
				{
					cleanupHealTarget(targ.enemy);
				}

				// clean up self
				targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
			}

			@targ.enemy = attacker;
			if ((targ.monsterinfo.aiflags & ai_flags_t::DUCKED) == 0)
				FoundTarget(targ);
		}
		return;
	}

	if (attacker.enemy is targ // if they *meant* to shoot us, then shoot back
		// it's the same base (walk/swim/fly) type and both don't ignore shots,
		// get mad at them
		|| (((targ.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == (attacker.flags & (ent_flags_t::FLY | ent_flags_t::SWIM))) &&
		(targ.classname != attacker.classname) && (attacker.monsterinfo.aiflags & ai_flags_t::IGNORE_SHOTS) == 0 &&
		    (targ.monsterinfo.aiflags & ai_flags_t::IGNORE_SHOTS) == 0))
	{
		if (targ.enemy !is attacker)
		{
			// [Paril-KEX]
			if ((targ.e.svflags & svflags_t::MONSTER) != 0 && (targ.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			{
				if (targ.enemy !is null && targ.enemy.e.inuse && (targ.enemy.e.svflags & svflags_t::MONSTER) != 0) // god, I hope so
				{
					cleanupHealTarget(targ.enemy);
				}

				// clean up self
				targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
			}

			if (targ.enemy !is null && targ.enemy.client !is null)
				@targ.oldenemy = targ.enemy;
			@targ.enemy = attacker;
			if ((targ.monsterinfo.aiflags & ai_flags_t::DUCKED) == 0)
				FoundTarget(targ);
		}
	}
	// otherwise get mad at whoever they are mad at (help our buddy) unless it is us!
	else if (attacker.enemy !is null && attacker.enemy !is targ && targ.enemy !is attacker.enemy)
	{
		if (targ.enemy !is attacker.enemy)
		{
			// [Paril-KEX]
			if ((targ.e.svflags & svflags_t::MONSTER) != 0 && (targ.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			{
				if (targ.enemy !is null && targ.enemy.e.inuse && (targ.enemy.e.svflags & svflags_t::MONSTER) != 0) // god, I hope so
				{
					cleanupHealTarget(targ.enemy);
				}

				// clean up self
				targ.monsterinfo.aiflags = ai_flags_t(targ.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
			}

			if (targ.enemy !is null && targ.enemy.client !is null)
				@targ.oldenemy = targ.enemy;
			@targ.enemy = attacker.enemy;
			if ((targ.monsterinfo.aiflags & ai_flags_t::DUCKED) == 0)
				FoundTarget(targ);
		}
	}
}

// check if the two given entities are on the same team
bool OnSameTeam(ASEntity &ent1, ASEntity &ent2)
{
	// monsters are never on our team atm
	if (ent1.client is null || ent2.client is null)
		return false;
	// we're never on our own team
	else if (ent1 is ent2)
		return false;

	// [Paril-KEX] coop 'team' support
	if (coop.integer != 0)
		return ent1.client !is null && ent2.client !is null;
	// ZOID
	else if (G_TeamplayEnabled() && ent1.client !is null && ent2.client !is null)
	{
		if (ent1.client.resp.ctf_team == ent2.client.resp.ctf_team)
			return true;
	}
	// ZOID

	return false;
}

// check if the two entities are on a team and that
// they wouldn't damage each other
bool CheckTeamDamage(ASEntity &targ, ASEntity &attacker)
{
	// always damage teammates if friendly fire is enabled
	if (g_friendly_fire.integer != 0)
		return false;

	return OnSameTeam(targ, attacker);
}

void T_Damage(ASEntity &targ, ASEntity &inflictor, ASEntity &attacker, const vec3_t &in dir, const vec3_t &in point,
			  const vec3_t &in normal, int damage, int knockback, damageflags_t dflags, mod_t mod)
{
	ASClient   @client;
	int		   take;
	int		   save;
	int		   asave;
	int		   psave;
	temp_event_t te_sparks;
	bool	   sphere_notified; // PGM

	if (!targ.takedamage)
		return;

	if (g_instagib.integer != 0 && attacker.client !is null && targ.client !is null)
	{
		// [Kex] always kill no matter what on instagib
		damage = 9999;
	}

	sphere_notified = false; // PGM

	// friendly fire avoidance
	// if enabled you can't hurt teammates (but you can hurt yourself)
	// knockback still occurs
	if ((targ !is attacker) && (dflags & damageflags_t::NO_PROTECTION) == 0)
	{
		// mark as friendly fire
		if (OnSameTeam(targ, attacker))
		{
			mod.friendly_fire = true;

			// if we're not a nuke & friendly fire is disabled, just kill the damage
			if (g_friendly_fire.integer == 0 && (mod.id != mod_id_t::NUKE))
				damage = 0;
		}
	}

	// easy mode takes half damage
	if (skill.integer == 0 && deathmatch.integer == 0 && targ.client !is null && damage != 0)
	{
		damage /= 2;
		if (damage == 0)
			damage = 1;
	}

	if ( ( targ.e.svflags & svflags_t::MONSTER ) != 0 ) {
		damage *= ai_damage_scale.integer;
	} else {
		damage *= g_damage_scale.integer;
	} // mal: just for debugging...

	@client = targ.client;

	// PMM - defender sphere takes half damage
	if (damage != 0 && (client !is null) && (client.owned_sphere !is null) && (uint(client.owned_sphere.spawnflags) == uint(spawnflags::sphere::DEFENDER)))
	{
		damage /= 2;
		if (damage == 0)
			damage = 1;
	}

	if ((dflags & damageflags_t::BULLET) != 0)
		te_sparks = temp_event_t::BULLET_SPARKS;
	else
		te_sparks = temp_event_t::SPARKS;

	// bonus damage for surprising a monster
	if ((dflags & damageflags_t::RADIUS) == 0 && (targ.e.svflags & svflags_t::MONSTER) != 0 && (attacker.client !is null) &&
		(targ.enemy is null || targ.monsterinfo.surprise_time == level.time) && (targ.health > 0))
	{
		damage *= 2;
		targ.monsterinfo.surprise_time = level.time;
	}

	// ZOID
	// strength tech
	damage = CTFApplyStrength(attacker, damage);
	// ZOID

	if ((targ.flags & ent_flags_t::NO_KNOCKBACK) != 0 ||
		((targ.flags & ent_flags_t::ALIVE_KNOCKBACK_ONLY) != 0 && (!targ.deadflag || targ.dead_time != level.time)))
		knockback = 0;

	// figure momentum add
	if ((dflags & damageflags_t::NO_KNOCKBACK) == 0)
	{
		if ((knockback != 0) && (targ.movetype != movetype_t::NONE) && (targ.movetype != movetype_t::BOUNCE) &&
			(targ.movetype != movetype_t::PUSH) && (targ.movetype != movetype_t::STOP))
		{
			vec3_t normalized = dir.normalized();
			vec3_t kvel;
			float  mass;

			if (targ.mass < 50)
				mass = 50;
			else
				mass = float(targ.mass);

			if (targ.client !is null && attacker is targ)
				kvel = normalized * (1600.0f * knockback / mass); // the rocket jump hack...
			else
				kvel = normalized * (500.0f * knockback / mass);

			targ.velocity += kvel;
		}
	}

	take = damage;
	save = 0;

	// check for godmode
	if ((targ.flags & ent_flags_t::GODMODE) != 0 && (dflags & damageflags_t::NO_PROTECTION) == 0)
	{
		take = 0;
		save = damage;
		SpawnDamage(te_sparks, point, normal, save);
	}

	// check for invincibility
	// ROGUE
	if ((dflags & damageflags_t::NO_PROTECTION) == 0 &&
		(((client !is null && client.invincible_time > level.time)) ||
		 ((targ.e.svflags & svflags_t::MONSTER) != 0 && targ.monsterinfo.invincible_time > level.time)))
	// ROGUE
	{
		if (targ.pain_debounce_time < level.time)
		{
			gi_sound(targ.e, soundchan_t::ITEM, gi_soundindex("items/protect4.wav"), 1, ATTN_NORM, 0);
			targ.pain_debounce_time = level.time + time_sec(2);
		}
		take = 0;
		save = damage;
	}

	// ZOID
	// team armor protect
	if (G_TeamplayEnabled() && targ.client !is null && attacker.client !is null &&
		targ.client.resp.ctf_team == attacker.client.resp.ctf_team && targ !is attacker &&
		g_teamplay_armor_protect.integer != 0)
	{
		psave = asave = 0;
	}
	else
	{
		// ZOID
		psave = CheckPowerArmor(targ, point, normal, take, dflags);
		take -= psave;

		asave = CheckArmor(targ, point, normal, take, te_sparks, dflags);
		take -= asave;
	}

	// treat cheat/powerup savings the same as armor
	asave += save;

	// ZOID
	// resistance tech
	take = CTFApplyResistance(targ, take);
	// ZOID

	// ZOID
	CTFCheckHurtCarrier(targ, attacker);
	// ZOID

	// ROGUE - this option will do damage both to the armor and person. originally for DPU rounds
	if ((dflags & damageflags_t::DESTROY_ARMOR) != 0)
	{
		if ((targ.flags & ent_flags_t::GODMODE) == 0 && (dflags & damageflags_t::NO_PROTECTION) == 0 &&
			!(client !is null && client.invincible_time > level.time))
		{
			take = damage;
		}
	}
	// ROGUE

	// [Paril-KEX] player hit markers
	if (targ !is attacker && attacker.client !is null && targ.health > 0 &&
        !((targ.e.svflags & svflags_t::DEADMONSTER) != 0 || (targ.flags & ent_flags_t::NO_DAMAGE_EFFECTS) != 0) && mod.id != mod_id_t::TARGET_LASER)
		attacker.e.client.ps.stats[player_stat_t::HIT_MARKER] += take + psave + asave;

	// do the damage
	if (take != 0)
	{
		if ((targ.flags & ent_flags_t::NO_DAMAGE_EFFECTS) == 0)
		{
			// ROGUE
			if ((targ.flags & ent_flags_t::MECHANICAL)  != 0)
				SpawnDamage(temp_event_t::ELECTRIC_SPARKS, point, normal, take);
			// ROGUE
			else if ((targ.e.svflags & svflags_t::MONSTER) != 0 || (client !is null))
			{
				// XATRIX
				if (targ.classname == "monster_gekk")
					SpawnDamage(temp_event_t::GREENBLOOD, point, normal, take);
				// XATRIX
				// ROGUE
				else if (mod.id == mod_id_t::CHAINFIST)
					SpawnDamage(temp_event_t::MOREBLOOD, point, normal, 255);
				// ROGUE
				else
					SpawnDamage(temp_event_t::BLOOD, point, normal, take);
			}
			else
				SpawnDamage(te_sparks, point, normal, take);
		}

		if (!CTFMatchSetup())
			targ.health = targ.health - take;

		if ((targ.flags & ent_flags_t::IMMORTAL) != 0 && targ.health <= 0)
			targ.health = 1;

		// PGM - spheres need to know who to shoot at
		if (client !is null && client.owned_sphere !is null)
		{
			sphere_notified = true;
			if (client.owned_sphere.pain !is null)
				client.owned_sphere.pain(client.owned_sphere, attacker, 0, 0, mod);
		}
		// PGM

		if (targ.health <= 0)
		{
			if ((targ.e.svflags & svflags_t::MONSTER) != 0 || (client !is null))
			{
				targ.flags = ent_flags_t(targ.flags | ent_flags_t::ALIVE_KNOCKBACK_ONLY);
				targ.dead_time = level.time;
			}
			targ.monsterinfo.damage_blood += take;
			@targ.monsterinfo.damage_attacker = attacker;
			@targ.monsterinfo.damage_inflictor = inflictor;
			targ.monsterinfo.damage_from = point;
			targ.monsterinfo.damage_mod = mod;
			targ.monsterinfo.damage_knockback += knockback;
			Killed(targ, inflictor, attacker, take, point, mod);
			return;
		}
	}

	// PGM - spheres need to know who to shoot at
	if (!sphere_notified)
	{
		if (client !is null && client.owned_sphere !is null)
		{
			sphere_notified = true;
			if (client.owned_sphere.pain !is null)
				client.owned_sphere.pain(client.owned_sphere, attacker, 0, 0, mod);
		}
	}
	// PGM

	if ( targ.client !is null ) {
		targ.client.last_attacker_time = level.time;
	}

	if ((targ.e.svflags & svflags_t::MONSTER) != 0)
	{
		if (damage > 0)
		{
			M_ReactToDamage(targ, attacker, inflictor);

			@targ.monsterinfo.damage_attacker = attacker;
			@targ.monsterinfo.damage_inflictor = inflictor;
			targ.monsterinfo.damage_blood += take;
			targ.monsterinfo.damage_from = point;
			targ.monsterinfo.damage_mod = mod;
			targ.monsterinfo.damage_knockback += knockback;
		}

		if (targ.monsterinfo.setskin !is null)
			targ.monsterinfo.setskin(targ);
	}
	else if (take != 0 && targ.pain !is null)
		targ.pain(targ, attacker, float(knockback), take, mod);

	// add to the damage inflicted on a player this frame
	// the total will be turned into screen blends and view angle kicks
	// at the end of the frame
	if (client !is null)
	{
		client.damage_parmor += psave;
		client.damage_armor += asave;
		client.damage_blood += take;
		client.damage_knockback += knockback;
		client.damage_from = point;
		client.last_damage_time = level.time + COOP_DAMAGE_RESPAWN_TIME;

		if ((dflags & damageflags_t::NO_INDICATOR) == 0 && inflictor !is world && attacker !is world && (take != 0 || psave != 0 || asave != 0))
		{
			damage_indicator_t @indicator = null;
			uint i;

			for (i = 0; i < client.damage_indicators.length(); i++)
			{
				if ((point - client.damage_indicators[i].from).length() < 32.0f)
				{
					@indicator = client.damage_indicators[i];
					break;
				}
			}

			if (indicator is null && i != MAX_DAMAGE_INDICATORS)
			{
                client.damage_indicators.push_back(damage_indicator_t());
				@indicator = client.damage_indicators[i];
				// for projectile direct hits, use the attacker; otherwise
				// use the inflictor (rocket splash should point to the rocket)
				indicator.from = (dflags & damageflags_t::RADIUS) != 0 ? inflictor.e.s.origin : attacker.e.s.origin;
				indicator.health = indicator.armor = indicator.power = 0;
			}

			if (indicator !is null)
			{
				indicator.health += take;
				indicator.power += psave;
				indicator.armor += asave;
			}
		}
	}
}

/*
============
T_RadiusDamage
============
*/
void T_RadiusDamage(ASEntity &inflictor, ASEntity &attacker, float damage, ASEntity @ignore, float radius, damageflags_t dflags, mod_t mod)
{
	float	 points;
	ASEntity @ent = null;
	vec3_t	 v;
	vec3_t	 dir;
	vec3_t   inflictor_center;
	
	if (inflictor.e.linked)
		inflictor_center = (inflictor.e.absmax + inflictor.e.absmin) * 0.5f;
	else
		inflictor_center = inflictor.e.s.origin;

	while ((@ent = findradius(ent, inflictor_center, radius)) !is null)
	{
		if (ent is ignore)
			continue;
		if (!ent.takedamage)
			continue;

		if (ent.e.solid == solid_t::BSP && ent.e.linked)
			v = closest_point_to_box(inflictor_center, ent.e.absmin, ent.e.absmax);
		else
		{
			v = ent.e.mins + ent.e.maxs;
			v = ent.e.s.origin + (v * 0.5f);
		}
		v = inflictor_center - v;
		points = damage - 0.5f * v.length();
		if (ent is attacker)
			points = points * 0.5f;
		if (points > 0)
		{
			if (CanDamage(ent, inflictor))
			{
				dir = (ent.e.s.origin - inflictor_center).normalized();
				// [Paril-KEX] use closest point on bbox to explosion position
				// to spawn damage effect

				T_Damage(ent, inflictor, attacker, dir, closest_point_to_box(inflictor_center, ent.e.absmin, ent.e.absmax), dir, int(points), int(points),
						 damageflags_t(dflags | damageflags_t::RADIUS), mod);
			}
		}
	}
}