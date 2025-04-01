// [Paril-KEX] convenience functions that returns true
// if the powerup should be 'active' (false to disable,
// will flash at 500ms intervals after 3 sec)
bool G_PowerUpExpiringRelative(const gtime_t &in left)
{
	return left.milliseconds > 3000 || (left.milliseconds % 1000) < 500;
}

bool G_PowerUpExpiring(const gtime_t &in time)
{
	return G_PowerUpExpiringRelative(time - level.time);
}

/*
=================
findradius

Returns entities that have origins within a spherical area

findradius (origin, radius)
=================
*/
ASEntity @findradius(ASEntity @from, const vec3_t &in org, float rad)
{
	vec3_t eorg;
    uint num = 0;

	if (from !is null)
        num = from.e.s.number + 1;

	for (; num < num_edicts; num++)
	{
        @from = @entities[num];
		if (!from.e.inuse)
			continue;
		if (from.e.solid == solid_t::NOT)
			continue;
		eorg = org - (from.e.s.origin + (from.e.mins + from.e.maxs) * 0.5f);
		if (eorg.length() > rad)
			continue;
		return from;
	}

	return null;
}

/*
=============
G_PickTarget

Searches all active entities for the next one that holds
the matching string at fieldofs in the structure.

Searches beginning at the edict after from, or the beginning if nullptr
nullptr will be returned if the end of the list is reached.

=============
*/
ASEntity @G_PickTarget(const string &in targetname)
{
	if (targetname.empty())
	{
		gi_Com_Print("G_PickTarget called with nullptr targetname\n");
		return null;
	}

	array<ASEntity @> choices;
    ASEntity @ent = null;

	while (true)
	{
		@ent = find_by_str<ASEntity>(ent, "targetname", targetname);
		if (ent is null)
			break;
		choices.push_back(ent);
	}

	if (choices.empty())
	{
		gi_Com_Print("G_PickTarget: target {} not found\n", targetname);
		return null;
	}

	return choices[irandom(choices.length())];
}

void Think_Delay(ASEntity &ent)
{
	G_UseTargets(ent, ent.activator);
	G_FreeEdict(ent);
}

void G_PrintActivationMessage(ASEntity &ent, ASEntity @activator, bool coop_global)
{
	//
	// print the message
	//
	if (!ent.message.empty() && activator !is null && (activator.e.svflags & svflags_t::MONSTER) == 0)
	{
		if (coop_global && coop.integer != 0)
			gi_LocBroadcast_Print(print_type_t::CENTER, "{}", ent.message);
		else
			gi_LocCenter_Print(activator.e, "{}", ent.message);

		// [Paril-KEX] allow non-noisy centerprints
		if (ent.noise_index >= 0)
		{
			if (ent.noise_index != 0)
				gi_sound(activator.e, soundchan_t::AUTO, ent.noise_index, 1, ATTN_NORM, 0);
			else
				gi_sound(activator.e, soundchan_t::AUTO, gi_soundindex("misc/talk1.wav"), 1, ATTN_NORM, 0);
		}
	}
}

/*
==============================
G_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void G_UseTargets(ASEntity &ent, ASEntity @activator)
{
	ASEntity @t;

	//
	// check for a delay
	//
	if (ent.delay != 0)
	{
		// create a temp object to fire at a later time
		@t = G_Spawn();
		t.classname = "DelayedUse";
		t.nextthink = level.time + time_sec(ent.delay);
		@t.think = Think_Delay;
		@t.activator = activator;
		if (activator is null)
			gi_Com_Print("Think_Delay with no activator\n");
		t.message = ent.message;
		t.target = ent.target;
		t.killtarget = ent.killtarget;
		return;
	}

	//
	// print the message
	//
	G_PrintActivationMessage(ent, activator, true);

	//
	// kill killtargets
	//
	if (!ent.killtarget.empty())
	{
		@t = null;
		while ((@t = find_by_str<ASEntity>(t, "targetname", ent.killtarget)) !is null)
		{
			if (t.teammaster !is null)
			{
				// PMM - if this entity is part of a chain, cleanly remove it
				if ((t.flags & ent_flags_t::TEAMSLAVE) != 0)
				{
					for (ASEntity @master = t.teammaster; master !is null; @master = master.teamchain)
					{
						if (master.teamchain is t)
						{
							@master.teamchain = t.teamchain;
							break;
						}
					}
				}
				// [Paril-KEX] remove teammaster too
				else if ((t.flags & ent_flags_t::TEAMMASTER) != 0)
				{
					t.teammaster.flags = ent_flags_t(t.teammaster.flags & ~ent_flags_t::TEAMMASTER);

					ASEntity @new_master = t.teammaster.teamchain;

					if (new_master !is null)
					{
						new_master.flags = ent_flags_t(new_master.flags | ent_flags_t::TEAMMASTER);
						new_master.flags = ent_flags_t(new_master.flags & ~ent_flags_t::TEAMSLAVE);

						for (ASEntity @m = new_master; m !is null; @m = m.teamchain)
							@m.teammaster = new_master;
					}
				}
			}

			// [Paril-KEX] if we killtarget a monster, clean up properly
			if ((t.e.svflags & svflags_t::MONSTER) != 0)
			{
				if (!t.deadflag && (t.monsterinfo.aiflags & ai_flags_t::DO_NOT_COUNT) == 0 && (t.spawnflags & spawnflags::monsters::DEAD) == 0)
					G_MonsterKilled(t);
			}

			// PMM
			G_FreeEdict(t);

			if (!ent.e.inuse)
			{
				gi_Com_Print("entity was removed while using killtargets\n");
				return;
			}
		}
	}

	//
	// fire targets
	//
	if (!ent.target.empty())
	{
		@t = null;
		while ((@t = find_by_str<ASEntity>(t, "targetname", ent.target)) !is null)
		{
			// doors fire area portals in a specific way
			if (Q_strcasecmp(t.classname, "func_areaportal") == 0 &&
				(Q_strcasecmp(ent.classname, "func_door") == 0 || Q_strcasecmp(ent.classname, "func_door_rotating") == 0
				|| Q_strcasecmp(ent.classname, "func_door_secret") == 0 || Q_strcasecmp(ent.classname, "func_water") == 0))
				continue;

			if (t is ent)
			{
				gi_Com_Print("WARNING: Entity used itself.\n");
			}
			else
			{
				if (t.use !is null)
					t.use(t, ent, activator);
			}
			if (!ent.e.inuse)
			{
				gi_Com_Print("entity was removed while using targets\n");
				return;
			}
		}
	}
}

const vec3_t VEC_UP = { 0, -1, 0 };
const vec3_t MOVEDIR_UP = { 0, 0, 1 };
const vec3_t VEC_DOWN = { 0, -2, 0 };
const vec3_t MOVEDIR_DOWN = { 0, 0, -1 };

void G_SetMovedir(ASEntity &ent, vec3_t &out movedir)
{
	if (ent.e.s.angles == VEC_UP)
	{
		movedir = MOVEDIR_UP;
	}
	else if (ent.e.s.angles == VEC_DOWN)
	{
		movedir = MOVEDIR_DOWN;
	}
	else
	{
		AngleVectors(ent.e.s.angles, movedir);
	}

	ent.e.s.angles = vec3_origin;
}

const trace_t null_trace;

BoxEdictsResult_t G_TouchTriggers_BoxFilter(edict_t @ent, any @const)
{
	ASEntity @hit = entities[ent.s.number];

	if (hit.touch is null)
		return BoxEdictsResult_t::Skip;

	return BoxEdictsResult_t::Keep;
}

/*
============
G_TouchTriggers

============
*/
array<edict_t @> touchtrig_touch;

void G_TouchTriggers(ASEntity &ent)
{
	// dead things don't activate triggers!
	if ((ent.client !is null || (ent.e.svflags & svflags_t::MONSTER) != 0) && (ent.health <= 0))
		return;

	uint i;
	ASEntity @hit;

	gi_BoxEdicts(ent.e.absmin, ent.e.absmax, touchtrig_touch, max_edicts, solidity_area_t::TRIGGERS, G_TouchTriggers_BoxFilter, null, false);

	// be careful, it is possible to have an entity in this
	// list removed before we get to it (killtriggered)
	for (i = 0; i < touchtrig_touch.length(); i++)
	{
		@hit = entities[touchtrig_touch[i].s.number];
		if (!hit.e.inuse)
			continue;
		if (hit.touch is null)
			continue;
		hit.touch(hit, ent, null_trace, true);
	}
}

class skipped_projectile_t
{
    ASEntity @projectile;
    int spawn_count;

    skipped_projectile_t() { }

    skipped_projectile_t(ASEntity @p)
    {
        @this.projectile = p;
        this.spawn_count = p.spawn_count;
    }
}

// [Paril-KEX] scan for projectiles between our movement positions
// to see if we need to collide against them
array<skipped_projectile_t> touchproj_skipped;

void G_TouchProjectiles(ASEntity &ent, const vec3_t &in previous_origin)
{
	// a bit ugly, but we'll store projectiles we are ignoring here.
	while (true)
	{
		trace_t tr = gi_trace(previous_origin, ent.e.mins, ent.e.maxs, ent.e.s.origin, ent.e, contents_t(ent.e.clipmask | contents_t::PROJECTILE));

		if (tr.fraction == 1.0f)
			break;
		else if ((tr.ent.svflags & svflags_t::PROJECTILE) == 0)
			break;

		// always skip this projectile since certain conditions may cause the projectile
		// to not disappear immediately
		tr.ent.svflags = svflags_t(tr.ent.svflags & ~svflags_t::PROJECTILE);
		touchproj_skipped.push_back(skipped_projectile_t(entities[tr.ent.s.number]));

		// if we're both players and it's coop, allow the projectile to "pass" through
		if (ent.client !is null && tr.ent.owner !is null && tr.ent.owner.client !is null && !G_ShouldPlayersCollide(true))
			continue;

		G_Impact(ent, tr);
	}

	foreach (const skipped_projectile_t @skip : touchproj_skipped)
		if (skip.projectile.e.inuse && skip.projectile.spawn_count == skip.spawn_count)
			skip.projectile.e.svflags = svflags_t(skip.projectile.e.svflags | svflags_t::PROJECTILE);

    touchproj_skipped.resize(0);
}

/*
==============================================================================

Kill box

==============================================================================
*/

/*
=================
KillBox

Kills all entities that would touch the proposed new positioning
of ent.
=================
*/

BoxEdictsResult_t KillBox_BoxFilter(edict_t @ent, any @const)
{
    ASEntity @hit = entities[ent.s.number];

	if (hit.e.solid == solid_t::NOT || !hit.takedamage || hit.e.solid == solid_t::TRIGGER)
		return BoxEdictsResult_t::Skip;

	return BoxEdictsResult_t::Keep;
}

bool KillBox(ASEntity &ent, bool from_spawning, mod_id_t mod = mod_id_t::TELEFRAG, bool bsp_clipping = true, bool allow_safety = false)
{
	// don't telefrag as spectator...
	if (ent.movetype == movetype_t::NOCLIP)
		return true;

	contents_t mask = contents_t(contents_t::MONSTER | contents_t::PLAYER);

	// [Paril-KEX] don't gib other players in coop if we're not colliding
	if (from_spawning && ent.client !is null && coop.integer != 0 && !G_ShouldPlayersCollide(false))
		mask = contents_t(mask & ~contents_t::PLAYER);

	uint i;
	array<edict_t @> touch;
	ASEntity @hit;

	gi_BoxEdicts(ent.e.absmin, ent.e.absmax, touch, max_edicts, solidity_area_t::SOLID, KillBox_BoxFilter, null, false);

	for (i = 0; i < touch.length(); i++)
	{
		@hit = entities[touch[i].s.number];

		if (hit is ent)
			continue;
		else if (!hit.e.inuse || !hit.takedamage || hit.e.solid == solid_t::NOT || hit.e.solid == solid_t::TRIGGER || hit.e.solid == solid_t::BSP)
			continue;
		else if (hit.client !is null && (mask & contents_t::PLAYER) == 0)
			continue;

		if ((ent.e.solid == solid_t::BSP || (ent.e.svflags & svflags_t::HULL) != 0) && bsp_clipping)
		{
			trace_t clip = gi_clip(ent.e, hit.e.s.origin, hit.e.mins, hit.e.maxs, hit.e.s.origin, G_GetClipMask(hit));

			if (clip.fraction == 1.0f)
				continue;
		}

		// [Paril-KEX] don't allow telefragging of friends in coop.
		// the player that is about to be telefragged will have collision
		// disabled until another time.
		if (ent.client !is null && hit.client !is null && coop.integer != 0)
		{
			hit.e.clipmask = contents_t(hit.e.clipmask & ~contents_t::PLAYER);
			ent.e.clipmask = contents_t(ent.e.clipmask & ~contents_t::PLAYER);
			continue;
		}

		if (allow_safety && G_FixStuckObject(hit, hit.e.s.origin) != stuck_result_t::NO_GOOD_POSITION)
			continue;

		T_Damage(hit, ent, ent, vec3_origin, ent.e.s.origin, vec3_origin, 100000, 0, damageflags_t::NO_PROTECTION, mod);
	}

	return true; // all clear
}
