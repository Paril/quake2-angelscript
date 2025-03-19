/*
ROGUE
clean up heal targets for medic
*/
void cleanupHealTarget(ASEntity &ent)
{
	@ent.monsterinfo.healer = null;
	ent.takedamage = true;
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::RESURRECTING);
	M_SetEffects(ent);
}

/*
============
T_RadiusNukeDamage

Like T_RadiusDamage, but ignores walls (skips CanDamage check, among others)
// up to KILLZONE radius, do 10,000 points
// after that, do damage linearly out to KILLZONE2 radius
============
*/

void T_RadiusNukeDamage(ASEntity &inflictor, ASEntity &attacker, float damage, ASEntity @ignore, float radius, mod_t mod)
{
	float	 points;
	ASEntity @ent = null;
	vec3_t	 v;
	vec3_t	 dir;
	float	 len;
	float	 killzone, killzone2;
	trace_t	 tr;
	float	 dist;

	killzone = radius;
	killzone2 = radius * 2.0f;

	while ((@ent = findradius(ent, inflictor.e.origin, killzone2)) !is null)
	{
		// ignore nobody
		if (ent is ignore)
			continue;
		if (!ent.takedamage)
			continue;
		if (!ent.e.inuse)
			continue;
		if (!(ent.client !is null || (ent.e.svflags & svflags_t::MONSTER) != 0 || (ent.flags & ent_flags_t::DAMAGEABLE) != 0))
			continue;

		v = ent.e.mins + ent.e.maxs;
		v = ent.e.origin + (v * 0.5f);
		v = inflictor.e.origin - v;
		len = v.length();
		if (len <= killzone)
		{
			if (ent.client !is null)
				ent.flags = ent_flags_t(ent.flags | ent_flags_t::NOGIB);
			points = 10000;
		}
		else if (len <= killzone2)
			points = (damage / killzone) * (killzone2 - len);
		else
			points = 0;

		if (points > 0)
		{
			if (ent.client !is null)
				ent.client.nuke_time = level.time + time_sec(2);
			dir = ent.e.origin - inflictor.e.origin;
			T_Damage(ent, inflictor, attacker, dir, inflictor.e.origin, vec3_origin, int(points), int(points), damageflags_t::RADIUS, mod);
		}
	}
    uint i = 1;
	// cycle through players
	while (i < num_edicts)
	{
	    @ent = entities[i]; // skip the worldspawn
		if ((ent.client !is null) && (ent.client.nuke_time != level.time + time_sec(2)) && (ent.e.inuse))
		{
			tr = gi_traceline(inflictor.e.origin, ent.e.origin, inflictor.e, contents_t::MASK_SOLID);
			if (tr.fraction == 1.0f)
				ent.client.nuke_time = level.time + time_sec(2);
			else
			{
				dist = realrange(ent, inflictor);
				if (dist < 2048)
					ent.client.nuke_time = max(ent.client.nuke_time, level.time + time_sec(1.5));
				else
					ent.client.nuke_time = max(ent.client.nuke_time, level.time + time_sec(1));
			}
		}

        i++;
	}
}