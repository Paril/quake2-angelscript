namespace spawnflags::plat2
{
//====
// PGM
    const uint32 TOGGLE = 2;
    const uint32 TOP = 4;
    const uint32 START_ACTIVE = 8;
    const uint32 BOX_LIFT = 32;
// PGM
//====
}

void plat2_spawn_danger_area(ASEntity &ent)
{
	vec3_t mins, maxs;

	mins = ent.e.mins;
	maxs = ent.e.maxs;
	maxs[2] = ent.e.mins[2] + 64;

	SpawnBadArea(mins, maxs, time_zero, ent);
}

void plat2_kill_danger_area(ASEntity &ent)
{
	ASEntity @t;

	@t = null;
	while ((@t = find_by_str<ASEntity>(t, "classname", "bad_area")) !is null)
	{
		if (t.owner is ent)
			G_FreeEdict(t);
	}
}

void plat2_hit_top(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_end  != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_end, 1, ATTN_STATIC, 0);
	}
	ent.e.s.sound = 0;
	ent.moveinfo.state = move_state_t::TOP;

	if ((ent.plat2flags & plat2flags_t::CALLED) != 0)
	{
		ent.plat2flags = plat2flags_t::WAITING;
		if ((ent.spawnflags & spawnflags::plat2::TOGGLE) == 0)
		{
			@ent.think = plat2_go_down;
			ent.nextthink = level.time + time_sec(ent.wait * 2.5f);
		}
		if (deathmatch.integer != 0)
			ent.last_move_time = level.time - time_sec(ent.wait * 0.5f);
		else
			ent.last_move_time = level.time - time_sec(ent.wait);
	}
	else if ((ent.spawnflags & spawnflags::plat2::TOP) == 0 && (ent.spawnflags & spawnflags::plat2::TOGGLE) == 0)
	{
		ent.plat2flags = plat2flags_t::NONE;
		@ent.think = plat2_go_down;
		ent.nextthink = level.time + time_sec(ent.wait);
		ent.last_move_time = level.time;
	}
	else
	{
		ent.plat2flags = plat2flags_t::NONE;
		ent.last_move_time = level.time;
	}

	G_UseTargets(ent, ent);
}

void plat2_hit_bottom(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_end != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_end, 1, ATTN_STATIC, 0);
	}
	ent.e.s.sound = 0;
	ent.moveinfo.state = move_state_t::BOTTOM;

	if ((ent.plat2flags & plat2flags_t::CALLED) != 0)
	{
		ent.plat2flags = plat2flags_t::WAITING;
		if ((ent.spawnflags & spawnflags::plat2::TOGGLE) == 0)
		{
			@ent.think = plat2_go_up;
			ent.nextthink = level.time + time_sec(ent.wait * 2.5f);
		}
		if (deathmatch.integer != 0)
			ent.last_move_time = level.time - time_sec(ent.wait * 0.5f);
		else
			ent.last_move_time = level.time - time_sec(ent.wait);
	}
	else if ((ent.spawnflags & spawnflags::plat2::TOP) != 0 && (ent.spawnflags & spawnflags::plat2::TOGGLE) == 0)
	{
		ent.plat2flags = plat2flags_t::NONE;
		@ent.think = plat2_go_up;
		ent.nextthink = level.time + time_sec(ent.wait);
		ent.last_move_time = level.time;
	}
	else
	{
		ent.plat2flags = plat2flags_t::NONE;
		ent.last_move_time = level.time;
	}

	plat2_kill_danger_area(ent);
	G_UseTargets(ent, ent);
}

void plat2_go_down(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_start != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	ent.e.s.sound = ent.moveinfo.sound_middle;

	ent.moveinfo.state = move_state_t::DOWN;
	ent.plat2flags = plat2flags_t(ent.plat2flags | plat2flags_t::MOVING);

	Move_Calc(ent, ent.moveinfo.end_origin, plat2_hit_bottom);
}

void plat2_go_up(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_start != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	ent.e.s.sound = ent.moveinfo.sound_middle;

	ent.moveinfo.state = move_state_t::UP;
	ent.plat2flags = plat2flags_t(ent.plat2flags | plat2flags_t::MOVING);

	plat2_spawn_danger_area(ent);

	Move_Calc(ent, ent.moveinfo.start_origin, plat2_hit_top);
}

void plat2_operate(ASEntity @ent, ASEntity &other)
{
	int		 otherState;
	gtime_t	 pauseTime;
	float	 platCenter;
	ASEntity @trigger;

	@trigger = ent;
	@ent = ent.enemy; // now point at the plat, not the trigger

	if ((ent.plat2flags & plat2flags_t::MOVING) != 0)
		return;

	if ((ent.last_move_time + time_sec(ent.wait)) > level.time)
		return;

	platCenter = (trigger.e.absmin[2] + trigger.e.absmax[2]) / 2;

	if (ent.moveinfo.state == move_state_t::TOP)
	{
		otherState = move_state_t::TOP;
		if ((ent.spawnflags & spawnflags::plat2::BOX_LIFT) != 0)
		{
			if (platCenter > other.e.s.origin[2])
				otherState = move_state_t::BOTTOM;
		}
		else
		{
			if (trigger.e.absmax[2] > other.e.s.origin[2])
				otherState = move_state_t::BOTTOM;
		}
	}
	else
	{
		otherState = move_state_t::BOTTOM;
		if (other.e.s.origin[2] > platCenter)
			otherState = move_state_t::TOP;
	}

	ent.plat2flags = plat2flags_t::MOVING;

	if (deathmatch.integer != 0)
		pauseTime = time_ms(300);
	else
		pauseTime = time_ms(500);

	if (ent.moveinfo.state != otherState)
	{
		ent.plat2flags = plat2flags_t(ent.plat2flags | plat2flags_t::CALLED);
		pauseTime = time_ms(100);
	}

	ent.last_move_time = level.time;

	if (ent.moveinfo.state == move_state_t::BOTTOM)
	{
		@ent.think = plat2_go_up;
		ent.nextthink = level.time + pauseTime;
	}
	else
	{
		@ent.think = plat2_go_down;
		ent.nextthink = level.time + pauseTime;
	}
}

void Touch_Plat_Center2(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	// this requires monsters to actively trigger plats, not just step on them.

	// FIXME - commented out for E3
	// if (!other.client)
	//	return;

	if (other.health <= 0)
		return;

	// PMM - don't let non-monsters activate plat2s
	if (((other.e.svflags & svflags_t::MONSTER) == 0) && (other.client is null))
		return;

	plat2_operate(ent, other);
}

void plat2_blocked(ASEntity &self, ASEntity &other)
{
	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::CRUSH);
		// if it's still there, nuke it
		if (other.e.inuse && other.e.solid != solid_t::NOT)
			BecomeExplosion1(other);
		return;
	}

	// gib dead things
	if (other.health < 1)
	{
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100, 1, damageflags_t::NONE, mod_id_t::CRUSH);
	}

	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);

	// [Paril-KEX] killed, so don't change direction
	if (!other.e.inuse || other.e.solid == solid_t::NOT)
		return;

	if (self.moveinfo.state == move_state_t::UP)
		plat2_go_down(self);
	else if (self.moveinfo.state == move_state_t::DOWN)
		plat2_go_up(self);
}

void Use_Plat2(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ASEntity @trigger;

	if (ent.moveinfo.state > move_state_t::BOTTOM)
		return;
	// [Paril-KEX] disabled this; causes confusing situations
	//if ((ent.last_move_time + 2_sec) > level.time)
	//	return;

	uint i;
	for (i = 1 + max_clients + BODY_QUEUE_SIZE; i < num_edicts; i++)
	{
        @trigger = entities[i];
		if (!trigger.e.inuse)
			continue;
		if (trigger.touch is Touch_Plat_Center2)
		{
			if (trigger.enemy is ent)
			{
				//				Touch_Plat_Center2 (trigger, activator, nullptr, nullptr);
				plat2_operate(trigger, activator);
				return;
			}
		}
	}
}

void plat2_activate(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ASEntity @trigger;

	//	if(ent.targetname)
	//		ent.targetname[0] = 0;

	@ent.use = Use_Plat2;

	@trigger = plat_spawn_inside_trigger(ent); // the "start moving" trigger

	trigger.e.maxs[0] += 10;
	trigger.e.maxs[1] += 10;
	trigger.e.mins[0] -= 10;
	trigger.e.mins[1] -= 10;

	gi_linkentity(trigger.e);

	@trigger.touch = Touch_Plat_Center2; // Override trigger touch function

	plat2_go_down(ent);
}

/*QUAKED func_plat2 (0 .5 .8) ? PLAT_LOW_TRIGGER TOGGLE TOP START_ACTIVE UNUSED BOX_LIFT
speed	default 150

PLAT_LOW_TRIGGER - creates a short trigger field at the bottom
TOGGLE - plat will not return to default position.
TOP - plat's default position will the the top.
START_ACTIVE - plat will trigger it's targets each time it hits top
UNUSED
BOX_LIFT - this indicates that the lift is a box, rather than just a platform

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

"speed"	overrides default 200.
"accel" overrides default 500
"lip"	no default

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determoveinfoned by the model's height.

*/
void SP_func_plat2(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	ASEntity @trigger;

	ent.e.s.angles = vec3_origin;
	ent.e.solid = solid_t::BSP;
	ent.movetype = movetype_t::PUSH;

	gi_setmodel(ent.e, ent.model);

	@ent.moveinfo.blocked = plat2_blocked;

	if (ent.speed == 0)
		ent.speed = 20;
	else
		ent.speed *= 0.1f;

	if (ent.accel == 0)
		ent.accel = 5;
	else
		ent.accel *= 0.1f;

	if (ent.decel == 0)
		ent.decel = 5;
	else
		ent.decel *= 0.1f;

	if (deathmatch.integer != 0)
	{
		ent.speed *= 2;
		ent.accel *= 2;
		ent.decel *= 2;
	}

	// PMM Added to kill things it's being blocked by
	if (ent.dmg == 0)
		ent.dmg = 2;

	// pos1 is the top position, pos2 is the bottom
	ent.pos1 = ent.e.s.origin;
	ent.pos2 = ent.e.s.origin;

	if (st.height  != 0)
		ent.pos2[2] -= (st.height - st.lip);
	else
		ent.pos2[2] -= (ent.e.maxs[2] - ent.e.mins[2]) - st.lip;

	ent.moveinfo.state = move_state_t::TOP;

	if (!ent.targetname.empty() && (ent.spawnflags & spawnflags::plat2::START_ACTIVE) == 0)
	{
		@ent.use = plat2_activate;
	}
	else
	{
		@ent.use = Use_Plat2;

		@trigger = plat_spawn_inside_trigger(ent); // the "start moving" trigger

		// PGM - debugging??
		trigger.e.maxs[0] += 10;
		trigger.e.maxs[1] += 10;
		trigger.e.mins[0] -= 10;
		trigger.e.mins[1] -= 10;

		gi_linkentity(trigger.e);

		@trigger.touch = Touch_Plat_Center2; // Override trigger touch function

		if ((ent.spawnflags & spawnflags::plat2::TOP) == 0)
		{
			ent.e.s.origin = ent.pos2;
			ent.moveinfo.state = move_state_t::BOTTOM;
		}
	}

	gi_linkentity(ent.e);

	ent.moveinfo.speed = ent.speed;
	ent.moveinfo.accel = ent.accel;
	ent.moveinfo.decel = ent.decel;
	ent.moveinfo.wait = ent.wait;
	ent.moveinfo.start_origin = ent.pos1;
	ent.moveinfo.start_angles = ent.e.s.angles;
	ent.moveinfo.end_origin = ent.pos2;
	ent.moveinfo.end_angles = ent.e.s.angles;

	if (ent.wait == 0)
		ent.wait = 2.0f;

	G_SetMoveinfoSounds(ent, "plats/pt1_strt.wav", "plats/pt1_mid.wav", "plats/pt1_end.wav");
}
