
// this is used for communications out of sv_movestep to say what entity
// is blocking us
ASEntity @new_bad; // pmm

/*
=============
M_CheckBottom

Returns false if any part of the bottom of the entity is off an edge that
is not a staircase.

=============
*/
bool M_CheckBottom_Fast_Generic(const vec3_t &in absmins, const vec3_t &in absmaxs, bool ceiling)
{
	// PGM
	//  FIXME - this will only handle 0,0,1 and 0,0,-1 gravity vectors
	vec3_t start;

	if (ceiling)
		start.z = absmaxs.z + 1;
    else
    	start.z = absmins.z - 1;
	// PGM

	for (int x = 0; x <= 1; x++)
		for (int y = 0; y <= 1; y++)
		{
			start.x = x != 0 ? absmaxs.x : absmins.x;
			start.y = y != 0 ? absmaxs.y : absmins.y;
			if (gi_pointcontents(start) != contents_t::SOLID)
				return false;
		}

	return true; // we got out easy
}

bool M_CheckBottom_Slow_Generic(const vec3_t &in origin, const vec3_t &in mins, const vec3_t &in maxs, ASEntity @ignore, contents_t mask, bool ceiling, bool allow_any_step_height)
{
	vec3_t start;

	//
	// check it for real...
	//
	vec3_t step_quadrant_size = (maxs - mins) * 0.5f;
	step_quadrant_size.z = 0;

	vec3_t half_step_quadrant = step_quadrant_size * 0.5f;
	vec3_t half_step_quadrant_mins = -half_step_quadrant;

	vec3_t stop;

	start.x = stop.x = origin.x;
	start.y = stop.y = origin.y;

	// PGM
	if (!ceiling)
	{
		start.z = origin.z + mins.z;
		stop.z = start.z - STEPSIZE * 2;
	}
	else
	{
		start.z = origin.z + maxs.z;
		stop.z = start.z + STEPSIZE * 2;
	}
	// PGM

	vec3_t mins_no_z = mins;
	vec3_t maxs_no_z = maxs;
	mins_no_z.z = maxs_no_z.z = 0;

    edict_t @ignore_e = ignore !is null ? ignore.e : null;
	trace_t trace = gi_trace(start, mins_no_z, maxs_no_z, stop, ignore_e, mask);

	if (trace.fraction == 1.0f)
		return false;

	// [Paril-KEX]
	if (allow_any_step_height)
		return true;

	start.x = stop.x = origin.x + ((mins.x + maxs.x) * 0.5f);
	start.y = stop.y = origin.y + ((mins.y + maxs.y) * 0.5f);

	float mid = trace.endpos.z;

	// the corners must be within 16 of the midpoint
	for (int32 x = 0; x <= 1; x++)
		for (int32 y = 0; y <= 1; y++)
		{
			vec3_t quadrant_start = start;

			if (x != 0)
				quadrant_start.x += half_step_quadrant.x;
			else
				quadrant_start.x -= half_step_quadrant.x;

			if (y != 0)
				quadrant_start.y += half_step_quadrant.y;
			else
				quadrant_start.y -= half_step_quadrant.y;

			vec3_t quadrant_end = quadrant_start;
			quadrant_end.z = stop.z;

			trace = gi_trace(quadrant_start, half_step_quadrant_mins, half_step_quadrant, quadrant_end, ignore_e, mask);

			// PGM
			//  FIXME - this will only handle 0,0,1 and 0,0,-1 gravity vectors
			if (ceiling)
			{
				if (trace.fraction == 1.0f || trace.endpos.z - mid > (STEPSIZE))
					return false;
			}
			else
			{
				if (trace.fraction == 1.0f || mid - trace.endpos.z > (STEPSIZE))
					return false;
			}
			// PGM
		}

	return true;
}

bool M_CheckBottom(ASEntity &ent)
{
	// if all of the points under the corners are solid world, don't bother
	// with the tougher checks

	if (M_CheckBottom_Fast_Generic(ent.e.s.origin + ent.e.mins, ent.e.s.origin + ent.e.maxs, ent.gravityVector.z > 0))
		return true; // we got out easy

	contents_t mask = (ent.e.svflags & svflags_t::MONSTER) != 0 ? contents_t::MASK_MONSTERSOLID : contents_t(contents_t::MASK_SOLID | contents_t::MONSTER | contents_t::PLAYER);
	return M_CheckBottom_Slow_Generic(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent, mask, ent.gravityVector.z > 0, ent.spawnflags.has(spawnflags::monsters::SUPER_STEP));
}

//============
// ROGUE
bool IsBadAhead(ASEntity &self, ASEntity &bad, const vec3_t &in move)
{
	vec3_t dir;
	vec3_t forward;
	float  dp_bad, dp_move;
	vec3_t move_copy;

	move_copy = move;

	dir = bad.e.s.origin - self.e.s.origin;
	dir.normalize();
	AngleVectors(self.e.s.angles, forward);
	dp_bad = forward.dot(dir);

	move_copy.normalize();
	AngleVectors(self.e.s.angles, forward);
	dp_move = forward.dot(move_copy);

	if ((dp_bad < 0) && (dp_move < 0))
		return true;
	if ((dp_bad > 0) && (dp_move > 0))
		return true;

	return false;
}

vec3_t G_IdealHoverPosition(ASEntity &ent)
{
	if ((ent.enemy is null && (ent.monsterinfo.aiflags & ai_flags_t::MEDIC) == 0) ||
            (ent.monsterinfo.aiflags & (ai_flags_t::COMBAT_POINT | ai_flags_t::SOUND_TARGET | ai_flags_t::PATHING)) != 0)
		return vec3_origin; // go right for the center

	// pick random direction
    float theta = frandom(2 * PIf);
    float phi;
	
	// buzzards pick half sphere
	if (ent.monsterinfo.fly_above)
		phi = acos(0.7f + frandom(0.3f));
	else if (ent.monsterinfo.fly_buzzard || (ent.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
		phi = acos(frandom());
	// non-buzzards pick a level around the center
	else
		phi = acos(frandom() * 0.7f);

    vec3_t d = {
		sin(phi) * cos(theta),
		sin(phi) * sin(theta),
		cos(phi)
	};

	return d * frandom(ent.monsterinfo.fly_min_distance, ent.monsterinfo.fly_max_distance);
}

bool SV_flystep_testvisposition(const vec3_t &in start, const vec3_t &in end, const vec3_t &in starta, const vec3_t &in startb, ASEntity &ent)
{
	trace_t tr = gi_traceline(start, end, ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP));
			
	if (tr.fraction == 1.0f)
	{
		tr = gi_trace(starta, ent.e.mins, ent.e.maxs, startb, ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP));

		if (tr.fraction == 1.0f)
			return true;
	}

	return false;
}

bool SV_alternate_flystep(ASEntity &ent, const vec3_t &in move, bool relink, ASEntity @current_bad)
{
	// swimming monsters just follow their velocity in the air
	if ((ent.flags & ent_flags_t::SWIM) != 0 && ent.waterlevel < water_level_t::UNDER)
		return true;

	if (ent.monsterinfo.fly_position_time <= level.time ||
		(ent.enemy !is null && ent.monsterinfo.fly_pinned && !visible(ent, ent.enemy)))
	{
		ent.monsterinfo.fly_pinned = false;
		ent.monsterinfo.fly_position_time = level.time + random_time(time_sec(3), time_sec(10));
		ent.monsterinfo.fly_ideal_position = G_IdealHoverPosition(ent);
	}

	vec3_t towards_origin, towards_velocity = vec3_origin;

	float current_speed = 0;
	vec3_t dir = ent.velocity ? ent.velocity.normalized(current_speed) : vec3_origin;
	
	if ((ent.monsterinfo.aiflags & ai_flags_t::PATHING) != 0)
		towards_origin = (ent.monsterinfo.nav_path.returnCode == PathReturnCode::TraversalPending) ?
			ent.monsterinfo.nav_path.secondMovePoint : ent.monsterinfo.nav_path.firstMovePoint;
	else if (ent.enemy !is null && (ent.monsterinfo.aiflags & (ai_flags_t::COMBAT_POINT | ai_flags_t::SOUND_TARGET | ai_flags_t::LOST_SIGHT)) == 0)
	{
		towards_origin = ent.enemy.e.s.origin;
		towards_velocity = ent.enemy.velocity;
	}
	else if (ent.goalentity !is null)
		towards_origin = ent.goalentity.e.s.origin;
	else // what we're going towards probably died or something
	{
		// change speed
		if (current_speed != 0)
		{
			if (current_speed > 0)
				current_speed = max(0.f, current_speed - ent.monsterinfo.fly_acceleration);
			else if (current_speed < 0)
				current_speed = min(0.f, current_speed + ent.monsterinfo.fly_acceleration);

			ent.velocity = dir * current_speed;
		}

		return true;
	}

	vec3_t wanted_pos;
		
	if (ent.monsterinfo.fly_pinned)
		wanted_pos = ent.monsterinfo.fly_ideal_position;
	else if ((ent.monsterinfo.aiflags & (ai_flags_t::PATHING | ai_flags_t::COMBAT_POINT | ai_flags_t::SOUND_TARGET | ai_flags_t::LOST_SIGHT)) != 0)
		wanted_pos = towards_origin;
	else
		wanted_pos = (towards_origin + (towards_velocity * 0.25f)) + ent.monsterinfo.fly_ideal_position;

	//gi.Draw_Point(wanted_pos, 8.0f, rgba_red, gi.frame_time_s, true);

	// find a place we can fit in from here
	trace_t tr = gi_trace(towards_origin, { -8.f, -8.f, -8.f }, { 8.f, 8.f, 8.f }, wanted_pos, ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP));

	if (!tr.allsolid)
		wanted_pos = tr.endpos;

	float dist_to_wanted;
	vec3_t dest_diff = (wanted_pos - ent.e.s.origin);

	if (dest_diff.z > ent.e.mins.z && dest_diff.z < ent.e.maxs.z)
		dest_diff.z = 0;

	vec3_t wanted_dir = dest_diff.normalized(dist_to_wanted);

	if ((ent.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
		ent.ideal_yaw = vectoyaw((towards_origin - ent.e.s.origin).normalized());
		
	// check if we're blocked from moving this way from where we are
	tr = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.e.s.origin + (wanted_dir * ent.monsterinfo.fly_acceleration), ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP));

	vec3_t aim_fwd, aim_rgt, aim_up;
	vec3_t yaw_angles = { 0, ent.e.s.angles.y, 0 };

	AngleVectors(yaw_angles, aim_fwd, aim_rgt, aim_up);

	// it's a fairly close block, so we may want to shift more dramatically
	if (tr.fraction < 0.25f)
	{
		bool bottom_visible = SV_flystep_testvisposition(ent.e.s.origin + vec3_t(0, 0, ent.e.mins.z), wanted_pos,
			ent.e.s.origin, ent.e.s.origin + vec3_t(0, 0, ent.e.mins.z - ent.monsterinfo.fly_acceleration), ent);
		bool top_visible = SV_flystep_testvisposition(ent.e.s.origin + vec3_t(0, 0, ent.e.maxs.z), wanted_pos,
			ent.e.s.origin, ent.e.s.origin + vec3_t(0, 0, ent.e.maxs.z + ent.monsterinfo.fly_acceleration), ent);

		// top & bottom are same, so we need to try right/left
		if (bottom_visible == top_visible)
		{
			bool left_visible = gi_traceline(ent.e.s.origin + aim_fwd.scaled(ent.e.maxs) - aim_rgt.scaled(ent.e.maxs), wanted_pos, ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP)).fraction == 1.0f;
			bool right_visible = gi_traceline(ent.e.s.origin + aim_fwd.scaled(ent.e.maxs) + aim_rgt.scaled(ent.e.maxs), wanted_pos, ent.e, contents_t(contents_t::MASK_SOLID | contents_t::MONSTERCLIP)).fraction == 1.0f;

			if (left_visible != right_visible)
			{
				if (right_visible)
					wanted_dir += aim_rgt;
				else
					wanted_dir -= aim_rgt;
			}
			else
				// we're probably stuck, push us directly away
				wanted_dir = tr.plane.normal;
		}
		else
		{
			if (top_visible)
				wanted_dir += aim_up;
			else
				wanted_dir -= aim_up;
		}

		wanted_dir.normalize();
	}

	// the closer we are to zero, the more we can change dir.
	// if we're pushed past our max speed we shouldn't
	// turn at all.
	bool following_paths = (ent.monsterinfo.aiflags & (ai_flags_t::PATHING | ai_flags_t::COMBAT_POINT | ai_flags_t::LOST_SIGHT)) != 0;
	float turn_factor;
			
	if (((ent.monsterinfo.fly_thrusters && !ent.monsterinfo.fly_pinned) || following_paths) && dir.dot(wanted_dir) > 0.0f)
		turn_factor = 0.45f;
	else
		turn_factor = min(1.f, 0.84f + (0.08f * (current_speed / ent.monsterinfo.fly_speed)));

	vec3_t final_dir = dir ? dir : wanted_dir;

	// swimming monsters don't exit water voluntarily, and
	// flying monsters don't enter water voluntarily (but will
	// try to leave it)
	bool bad_movement_direction = false;

    // Paril: commented as this caused issues
	//if ((ent.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) == 0)
	{
		if ((ent.flags & ent_flags_t::SWIM) != 0)
			bad_movement_direction = (gi_pointcontents(ent.e.s.origin + (wanted_dir * current_speed)) & contents_t::WATER) == 0;
		else if ((ent.flags & ent_flags_t::FLY) != 0 && ent.waterlevel < water_level_t::UNDER)
			bad_movement_direction = (gi_pointcontents(ent.e.s.origin + (wanted_dir * current_speed)) & contents_t::WATER) != 0;
	}

	if (bad_movement_direction)
	{
		if (ent.monsterinfo.fly_recovery_time < level.time)
		{
			ent.monsterinfo.fly_recovery_dir = vec3_t(crandom(), crandom(), crandom()).normalized();
			ent.monsterinfo.fly_recovery_time = level.time + time_sec(1);
		}

		wanted_dir = ent.monsterinfo.fly_recovery_dir;
	}

	if (dir && turn_factor > 0)
		final_dir = slerp(dir, wanted_dir, 1.0f - turn_factor).normalized();

	// the closer we are to the wanted position, we want to slow
	// down so we don't fly past it.
	float speed_factor;
	
	//gi.Draw_Ray(ent->s.origin, aim_fwd, 16.0f, 8.0f, rgba_green, gi.frame_time_s, true);
	//gi.Draw_Ray(ent->s.origin, final_dir, 16.0f, 8.0f, rgba_blue, gi.frame_time_s, true);
	if (ent.enemy is null || (ent.monsterinfo.fly_thrusters && !ent.monsterinfo.fly_pinned) || following_paths)
	{
		// Paril: only do this correction if we are following paths. we want to move backwards
		// away from players.
		if (following_paths && dir && wanted_dir.dot(dir) < -0.25)
			speed_factor = 0.f;
		else
			speed_factor = 1.f;
	}
	else
		speed_factor = min(1.f, dist_to_wanted / ent.monsterinfo.fly_speed);

	if (bad_movement_direction)
		speed_factor = -speed_factor;

	float accel = ent.monsterinfo.fly_acceleration;

	// if we're flying away from our destination, apply reverse thrusters
	if (final_dir.dot(wanted_dir) < 0.25f)
		accel *= 2.0f;

	float wanted_speed = ent.monsterinfo.fly_speed * speed_factor;

	if ((ent.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		wanted_speed = 0;

	// change speed
	if (current_speed > wanted_speed)
		current_speed = max(wanted_speed, current_speed - accel);
	else if (current_speed < wanted_speed)
		current_speed = min(wanted_speed, current_speed + accel);

	// commit
	ent.velocity = final_dir * current_speed;

	// for buzzards, set their pitch
	if (ent.enemy !is null && (ent.monsterinfo.fly_buzzard || (ent.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0))
	{
		vec3_t d = (ent.e.s.origin - towards_origin).normalized();
		d = vectoangles(d);
		ent.e.s.angles.pitch = LerpAngle(ent.e.s.angles.pitch, -d.pitch, gi_frame_time_s * 4.0f);
	}
	else
		ent.e.s.angles.pitch = 0;

	return true;
}

// flying monsters don't step up
bool SV_flystep(ASEntity &ent, const vec3_t &in move, bool relink, ASEntity @current_bad)
{
	if ((ent.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0)
	{
		if (SV_alternate_flystep(ent, move, relink, current_bad))
			return true;
	}

	// try the move
	vec3_t oldorg = ent.e.s.origin;
	vec3_t neworg = ent.e.s.origin + move;

	// fixme: move to monsterinfo
	// we want the carrier to stay a certain distance off the ground, to help prevent him
	// from shooting his fliers, who spawn in below him
	float minheight;

	if (ent.classname == "monster_carrier")
		minheight = 104;
	else
		minheight = 40;

	// try one move with vertical motion, then one without
	for (int i = 0; i < 2; i++)
	{
		vec3_t new_move = move;

		if (i == 0 && ent.enemy !is null)
		{
			if (ent.goalentity is null)
				@ent.goalentity = ent.enemy;

			vec3_t goal_position = ((ent.monsterinfo.aiflags & ai_flags_t::PATHING) != 0) ? ent.monsterinfo.nav_path.firstMovePoint : ent.goalentity.e.s.origin;

			float dz = ent.e.s.origin.z - goal_position.z;
			float dist = move.length();

			if (ent.goalentity.client !is null)
			{
				if (dz > minheight)
				{
					//	pmm
					new_move *= 0.5f;
					new_move.z -= dist;
				}
				if (!((ent.flags & ent_flags_t::SWIM) != 0 && (ent.waterlevel < water_level_t::WAIST)))
					if (dz < (minheight - 10))
					{
						new_move *= 0.5f;
						new_move.z += dist;
					}
			}
			else
			{
				// RAFAEL
				if (ent.classname == "monster_fixbot")
				{
					if (ent.e.s.frame >= 105 && ent.e.s.frame <= 120)
					{
						if (dz > 12)
							new_move.z--;
						else if (dz < -12)
							new_move.z++;
					}
					else if (ent.e.s.frame >= 31 && ent.e.s.frame <= 88)
					{
						if (dz > 12)
							new_move.z -= 12;
						else if (dz < -12)
							new_move.z += 12;
					}
					else
					{
						if (dz > 12)
							new_move.z -= 8;
						else if (dz < -12)
							new_move.z += 8;
					}
				}
				else
				{
					// RAFAEL
					if (dz > 0)
					{
						new_move *= 0.5f;
						new_move.z -= min(dist, dz);
					}
					else if (dz < 0)
					{
						new_move *= 0.5f;
						new_move.z += -max(-dist, dz);
					}
					// RAFAEL
				}
				// RAFAEL
			}
		}

		neworg = ent.e.s.origin + new_move;

		trace_t trace = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, neworg, ent.e, contents_t::MASK_MONSTERSOLID);

		// fly monsters don't enter water voluntarily
		if ((ent.flags & ent_flags_t::FLY) != 0)
		{
			if (ent.waterlevel == water_level_t::NONE)
			{
				vec3_t test = { trace.endpos.x, trace.endpos.y, trace.endpos.z + ent.e.mins.z + 1 };
				contents_t contents = gi_pointcontents(test);
				if ((contents & contents_t::MASK_WATER) != 0)
					return false;
			}
		}

		// swim monsters don't exit water voluntarily
		if ((ent.flags & ent_flags_t::SWIM) != 0)
		{
			if (ent.waterlevel < water_level_t::WAIST)
			{
				vec3_t test = { trace.endpos.x, trace.endpos.y, trace.endpos.z + ent.e.mins.z + 1 };
				contents_t contents = gi_pointcontents(test);
				if ((contents & contents_t::MASK_WATER) == 0)
					return false;
			}
		}

		// ROGUE
		if ((trace.fraction == 1) && (!trace.allsolid) && (!trace.startsolid))
		// ROGUE
		{
			ent.e.s.origin = trace.endpos;
			//=====
			// PGM
			if (current_bad is null && CheckForBadArea(ent) !is null)
				ent.e.s.origin = oldorg;
			else
			{
				if (relink)
				{
					gi_linkentity(ent.e);
					G_TouchTriggers(ent);
				}

				return true;
			}
			// PGM
			//=====
		}

		G_Impact(ent, trace);

		if (ent.enemy is null)
			break;
	}

	return false;
}

/*
=============
SV_movestep

Called by monster program code.
The move will be adjusted for slopes and stairs, but if the move isn't
possible, no move is done, false is returned, and
pr_global_struct->trace_normal is set to the normal of the blocking wall
=============
*/
// FIXME since we need to test end position contents here, can we avoid doing
// it again later in catagorize position?
bool SV_movestep(ASEntity &ent, vec3_t move, bool relink)
{
	//======
	// PGM
	ASEntity @current_bad = null;

	// PMM - who cares about bad areas if you're dead?
	if (ent.health > 0)
	{
		@current_bad = CheckForBadArea(ent);
		if (current_bad !is null)
		{
			@ent.bad_area = current_bad;

			if (ent.enemy !is null && ent.enemy.classname == "tesla_mine")
			{
				// if the tesla is in front of us, back up...
				if (IsBadAhead(ent, current_bad, move))
					move *= -1;
			}
		}
		else if (ent.bad_area !is null)
		{
			// if we're no longer in a bad area, get back to business.
			@ent.bad_area = null;
			if (ent.oldenemy !is null) // && ent->bad_area->owner == ent->enemy)
			{
				@ent.enemy = ent.oldenemy;
				@ent.goalentity = ent.oldenemy;
				FoundTarget(ent);
			}
		}
	}
	// PGM
	//======

	// flying monsters don't step up
	if ((ent.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) != 0)
		return SV_flystep(ent, move, relink, current_bad);

	// try the move
	vec3_t oldorg = ent.e.s.origin;

	float stepsize;

	// push down from a step height above the wished position
	if (ent.spawnflags.has(spawnflags::monsters::SUPER_STEP) && ent.health > 0)
		stepsize = 64.0f;
	else if ((ent.monsterinfo.aiflags & ai_flags_t::NOSTEP) == 0)
		stepsize = STEPSIZE;
	else
		stepsize = 1;

	stepsize += 0.75f;

	contents_t mask = (ent.e.svflags & svflags_t::MONSTER) != 0 ? contents_t::MASK_MONSTERSOLID : contents_t(contents_t::MASK_SOLID | contents_t::MONSTER | contents_t::PLAYER);

	vec3_t start_up = oldorg + ent.gravityVector * (-1 * stepsize);

	start_up = gi_trace(oldorg, ent.e.mins, ent.e.maxs, start_up, ent.e, mask).endpos;

	vec3_t end_up = start_up + move;

	trace_t up_trace = gi_trace(start_up, ent.e.mins, ent.e.maxs, end_up, ent.e, mask);

	if (up_trace.startsolid)
	{
		start_up += ent.gravityVector * (-1 * stepsize);
		up_trace = gi_trace(start_up, ent.e.mins, ent.e.maxs, end_up, ent.e, mask);
	}
	
	vec3_t start_fwd = oldorg;
	vec3_t end_fwd = start_fwd + move;

	trace_t fwd_trace = gi_trace(start_fwd, ent.e.mins, ent.e.maxs, end_fwd, ent.e, mask);

	if (fwd_trace.startsolid)
	{
		start_up += ent.gravityVector * (-1 * stepsize);
		fwd_trace = gi_trace(start_fwd, ent.e.mins, ent.e.maxs, end_fwd, ent.e, mask);
	}

	// pick the one that went farther
	trace_t /*@*/chosen_forward = (up_trace.fraction > fwd_trace.fraction) ? up_trace : fwd_trace;

	if (chosen_forward.startsolid || chosen_forward.allsolid)
		return false;

	int32 steps = 1;
	bool stepped = false;

	if (up_trace.fraction > fwd_trace.fraction)
		steps = 2;
	
	// step us down
	vec3_t end = chosen_forward.endpos + (ent.gravityVector * (steps * stepsize));
	trace_t trace = gi_trace(chosen_forward.endpos, ent.e.mins, ent.e.maxs, end, ent.e, mask);

	if (abs(ent.e.s.origin.z - trace.endpos.z) > 8.0f)
		stepped = true;

	// Paril: improved the water handling here.
	// monsters are okay with stepping into water
	// up to their waist.
	if (ent.waterlevel <= water_level_t::WAIST)
	{
		water_level_t end_waterlevel;
		contents_t	  end_watertype;
		M_CatagorizePosition(ent, trace.endpos, end_waterlevel, end_watertype);

		// don't go into deep liquids or
		// slime/lava voluntarily
		if ((end_watertype & (contents_t::SLIME | contents_t::LAVA)) != 0 ||
			end_waterlevel > water_level_t::WAIST)
			return false;
	}

	if (trace.fraction == 1)
	{
		// if monster had the ground pulled out, go ahead and fall
		if ((ent.flags & ent_flags_t::PARTIALGROUND) != 0)
		{
			ent.e.s.origin += move;
			if (relink)
			{
				gi_linkentity(ent.e);
				G_TouchTriggers(ent);
			}
			@ent.groundentity = null;
			return true;
		}
		// [Paril-KEX] allow dead monsters to "fall" off of edges in their death animation
		else if (!ent.spawnflags.has(spawnflags::monsters::SUPER_STEP) && ent.health > 0)
			return false; // walked off an edge
	}
	
	// [Paril-KEX] if we didn't move at all (or barely moved), don't count it
	if ((trace.endpos - oldorg).length() < move.length() * 0.05f)
	{
		ent.monsterinfo.bad_move_time = level.time + time_ms(1000);

		if (ent.monsterinfo.bump_time < level.time && chosen_forward.fraction < 1.0f)
		{
			// adjust ideal_yaw to move against the object we hit and try again
            vec3_t forward;
            AngleVectors({0.0f, ent.ideal_yaw, 0.0f}, forward);

			vec3_t dir = SlideClipVelocity(forward, chosen_forward.plane.normal, 1.0f);
			float new_yaw = vectoyaw(dir);

			if (dir.lengthSquared() > 0.1f && ent.ideal_yaw != new_yaw)
			{
				ent.ideal_yaw = new_yaw;
				ent.monsterinfo.random_change_time = level.time + time_ms(100);
				ent.monsterinfo.bump_time = level.time + time_ms(200);
				return true;
			}
		}

		return false;
	}

	// check point traces down for dangling corners
	ent.e.s.origin = trace.endpos;

	// PGM
	//  PMM - don't bother with bad areas if we're dead
	if (ent.health > 0)
	{
		// use AI_BLOCKED to tell the calling layer that we're now mad at a tesla
		@new_bad = CheckForBadArea(ent);
		if (current_bad is null && new_bad !is null)
		{
			if (new_bad.owner !is null)
			{
				if (new_bad.owner.classname == "tesla_mine")
				{
					if ((ent.enemy is null) || (!ent.enemy.e.inuse))
					{
						TargetTesla(ent, new_bad.owner);
						ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::BLOCKED);
					}
					else if (ent.enemy.classname == "tesla_mine")
					{
					}
					else if ((ent.enemy !is null) && (ent.enemy.client !is null))
					{
						if (!visible(ent, ent.enemy))
						{
							TargetTesla(ent, new_bad.owner);
							ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::BLOCKED);
						}
					}
					else
					{
						TargetTesla(ent, new_bad.owner);
						ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::BLOCKED);
					}
				}
			}

			ent.e.s.origin = oldorg;
			return false;
		}
	}
	// PGM

	if (!M_CheckBottom(ent))
	{
		if ((ent.flags & ent_flags_t::PARTIALGROUND) != 0)
		{ // entity had floor mostly pulled out from underneath it
			// and is trying to correct
			if (relink)
			{
				gi_linkentity(ent.e);
				G_TouchTriggers(ent);
			}
			return true;
		}

		// walked off an edge that wasn't a stairway
		ent.e.s.origin = oldorg;
		return false;
	}

	if (ent.spawnflags.has(spawnflags::monsters::SUPER_STEP) && ent.health > 0)
	{
		if (ent.groundentity is null || ent.groundentity.e.solid == solid_t::BSP)
		{
			if (trace.ent.solid != solid_t::BSP)
			{
				// walked off an edge
				ent.e.s.origin = oldorg;
				M_CheckGround(ent, G_GetClipMask(ent));
				return false;
			}
		}
	}

	// [Paril-KEX]
	M_CheckGround(ent, G_GetClipMask(ent));

	if (ent.groundentity is null)
	{
		// walked off an edge
		ent.e.s.origin = oldorg;
		M_CheckGround(ent, G_GetClipMask(ent));
		return false;
	}

	if ((ent.flags & ent_flags_t::PARTIALGROUND) != 0)
	{
		ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::PARTIALGROUND);
	}
	@ent.groundentity = entities[trace.ent.s.number];
	ent.groundentity_linkcount = trace.ent.linkcount;

	// the move is ok
	if (relink)
	{
		gi_linkentity(ent.e);

		// [Paril-KEX] this is something N64 does to avoid doors opening
		// at the start of a level, which triggers some monsters to spawn.
		if (!level.is_n64 || level.time > FRAME_TIME_S)
			G_TouchTriggers(ent);
	}

	if (stepped)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::STAIR_STEP);

	if (trace.fraction < 1.0f)
		G_Impact(ent, trace);

	return true;
}

// check if a movement would succeed
bool ai_check_move(ASEntity &self, float dist)
{
	if ( ai_movement_disabled.integer != 0 ) {
		return false;
	}

	float yaw = self.e.s.angles.yaw * PIf * 2 / 360;
	vec3_t move = {
		cos(yaw) * dist,
		sin(yaw) * dist,
		0
	};

	vec3_t old_origin = self.e.s.origin;

	if (!SV_movestep(self, move, false))
		return false;

	self.e.s.origin = old_origin;
	gi_linkentity(self.e);
	return true;
}

//============================================================================

/*
===============
M_ChangeYaw

===============
*/
void M_ChangeYaw(ASEntity &ent)
{
	float ideal;
	float current;
	float move;
	float speed;

	current = anglemod(ent.e.s.angles.yaw);
	ideal = ent.ideal_yaw;

	if (current == ideal)
		return;

	move = ideal - current;
	// [Paril-KEX] high tick rate
	speed = ent.yaw_speed / (gi_tick_rate / 10);

	if (ideal > current)
	{
		if (move >= 180)
			move = move - 360;
	}
	else
	{
		if (move <= -180)
			move = move + 360;
	}
	if (move > 0)
	{
		if (move > speed)
			move = speed;
	}
	else
	{
		if (move < -speed)
			move = -speed;
	}

	ent.e.s.angles.yaw = anglemod(current + move);
}

/*
======================
SV_StepDirection

Turns to the movement direction, and walks the current distance if
facing it.

======================
*/
bool SV_StepDirection(ASEntity &ent, float yaw, float dist, bool allow_no_turns)
{
	vec3_t move, oldorigin;

	if (!ent.e.inuse)
		return true; // PGM g_touchtrigger free problem

	float old_ideal_yaw = ent.ideal_yaw;
	float old_current_yaw = ent.e.s.angles.yaw;

	ent.ideal_yaw = yaw;
	M_ChangeYaw(ent);

	yaw = yaw * PIf * 2 / 360;
	move.x = cos(yaw) * dist;
	move.y = sin(yaw) * dist;
	move.z = 0;

	oldorigin = ent.e.s.origin;
	if (SV_movestep(ent, move, false))
	{
		ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
		if (!ent.e.inuse)
			return true; // PGM g_touchtrigger free problem

		if (Q_strncasecmp(ent.classname, "monster_widow", 13) != 0)
		{
			if (!FacingIdeal(ent))
			{
				// not turned far enough, so don't take the step
				// but still turn
				ent.e.s.origin = oldorigin;
				M_CheckGround(ent, G_GetClipMask(ent));
				return allow_no_turns; // [Paril-KEX]
			}
		}
		gi_linkentity(ent.e);
		G_TouchTriggers(ent);
		G_TouchProjectiles(ent, oldorigin);
		return true;
	}
	gi_linkentity(ent.e);
	G_TouchTriggers(ent);
	ent.ideal_yaw = old_ideal_yaw;
	ent.e.s.angles.yaw = old_current_yaw;
	return false;
}

/*
======================
SV_FixCheckBottom

======================
*/
void SV_FixCheckBottom(ASEntity &ent)
{
	ent.flags = ent_flags_t(ent.flags | ent_flags_t::PARTIALGROUND);
}

/*
================
SV_NewChaseDir

================
*/
const float DI_NODIR = -1;

bool SV_NewChaseDir(ASEntity &actor, const vec3_t &in pos, float dist)
{
	float deltax, deltay;
	vec3_t d;
	float tdir, olddir, turnaround;

	olddir = anglemod(trunc(actor.ideal_yaw / 45) * 45);
	turnaround = anglemod(olddir - 180);

	deltax = pos.x - actor.e.s.origin.x;
	deltay = pos.y - actor.e.s.origin.y;
	if (deltax > 10)
		d.y = 0;
	else if (deltax < -10)
		d.y = 180;
	else
		d.y = DI_NODIR;
	if (deltay < -10)
		d.z = 270;
	else if (deltay > 10)
		d.z = 90;
	else
		d.z = DI_NODIR;
	
	// try direct route
	if (d.y != DI_NODIR && d.z != DI_NODIR)
	{
		if (d.y == 0)
			tdir = d.z == 90 ? 45.0f : 315.0f;
		else
			tdir = d.z == 90 ? 135.0f : 215.0f;

		if (tdir != turnaround && SV_StepDirection(actor, tdir, dist, false))
			return true;
	}

	// try other directions
	if (brandom() || abs(deltay) > abs(deltax))
	{
		tdir = d.y;
		d.y = d.z;
		d.z = tdir;
	}

	if (d.y != DI_NODIR && d.y != turnaround && SV_StepDirection(actor, d.y, dist, false))
		return true;

	if (d.z != DI_NODIR && d.z != turnaround && SV_StepDirection(actor, d.z, dist, false))
		return true;

	// ROGUE
	if (actor.monsterinfo.blocked !is null)
	{
		if ((actor.e.inuse) && (actor.health > 0) && (actor.monsterinfo.aiflags & ai_flags_t::TARGET_ANGER) == 0)
		{
			// if block "succeeds", the actor will not move or turn.
			if (actor.monsterinfo.blocked(actor, dist))
			{
				actor.monsterinfo.move_block_counter = -2;
				return true;
			}
			
			// we couldn't step; instead of running endlessly in our current
			// spot, try switching to node navigation temporarily to get to
			// where we need to go.
			if ((actor.monsterinfo.aiflags & (ai_flags_t::LOST_SIGHT | ai_flags_t::COMBAT_POINT |
                ai_flags_t::TARGET_ANGER | ai_flags_t::PATHING | ai_flags_t::TEMP_MELEE_COMBAT | ai_flags_t::NO_PATH_FINDING)) == 0)
			{
				if (++actor.monsterinfo.move_block_counter > 2)
				{
					actor.monsterinfo.aiflags = ai_flags_t(actor.monsterinfo.aiflags | ai_flags_t::TEMP_MELEE_COMBAT);
					actor.monsterinfo.move_block_change_time = level.time + time_sec(3);
					actor.monsterinfo.move_block_counter = 0;
				}
			}
		}
	}
	// ROGUE

	// there is no direct path to the player, so pick another direction

	if (olddir != DI_NODIR && SV_StepDirection(actor, olddir, dist, false))
		return true;

	if (brandom()) // randomly determine direction of search
	{
		for (tdir = 0; tdir <= 315; tdir += 45)
			if (tdir != turnaround && SV_StepDirection(actor, tdir, dist, false))
				return true;
	}
	else
	{
		for (tdir = 315; tdir >= 0; tdir -= 45)
			if (tdir != turnaround && SV_StepDirection(actor, tdir, dist, false))
				return true;
	}

	if (turnaround != DI_NODIR && SV_StepDirection(actor, turnaround, dist, false))
		return true;

	actor.ideal_yaw = frandom(0, 360); // can't move; pick a random yaw...

	// if a bridge was pulled out from underneath a monster, it may not have
	// a valid standing position at all

	if (!M_CheckBottom(actor))
		SV_FixCheckBottom(actor);

	return false;
}

/*
======================
SV_CloseEnough

======================
*/
bool SV_CloseEnough(ASEntity &ent, ASEntity &goal, float dist)
{
	int i;

	for (i = 0; i < 3; i++)
	{
		if (goal.e.absmin[i] > ent.e.absmax[i] + dist)
			return false;
		if (goal.e.absmax[i] < ent.e.absmin[i] - dist)
			return false;
	}
	return true;
}

bool M_NavPathToGoal(ASEntity &self, float dist, const vec3_t &in goal)
{
	// mark us as *trying* now (nav_pos is valid)
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::PATHING);

	vec3_t path_to = (self.monsterinfo.nav_path.returnCode == PathReturnCode::TraversalPending) ?
		self.monsterinfo.nav_path.secondMovePoint : self.monsterinfo.nav_path.firstMovePoint;

	vec3_t ground_origin = self.e.s.origin + vec3_t(0.0f, 0.0f, self.e.mins.z) - vec3_t(0.0f, 0.0f, PLAYER_MINS.z);
	vec3_t mon_mins = ground_origin + PLAYER_MINS;
	vec3_t mon_maxs = ground_origin + PLAYER_MAXS;

	if (self.monsterinfo.nav_path_cache_time <= level.time ||
		(self.monsterinfo.nav_path.returnCode != PathReturnCode::TraversalPending &&
		boxes_intersect(mon_mins, mon_maxs, path_to, path_to)))
	{
		PathRequest request;
		if (self.enemy !is null)
			request.goal = self.enemy.e.s.origin;
		else
			request.goal = self.goalentity.e.s.origin;
		request.moveDist = dist;
		if (g_debug_monster_paths.integer == 1)
			request.debugging.drawTime = gi_frame_time_s;
		request.start = self.e.s.origin;
		request.pathFlags = PathFlags::Walk;
		
		request.nodeSearch.minHeight = -(self.e.mins.z * 2);
		request.nodeSearch.maxHeight = (self.e.maxs.z * 2);

		// FIXME remove hardcoding
		if (self.classname == "monster_guardian")
		{
			request.nodeSearch.radius = 2048.0f;
		}

		if (self.monsterinfo.can_jump || (self.flags & ent_flags_t::FLY) != 0)
		{
			if (self.monsterinfo.jump_height != 0)
			{
				request.pathFlags = PathFlags(request.pathFlags | PathFlags::BarrierJump);
				request.traversals.jumpHeight = self.monsterinfo.jump_height;
			}
			if (self.monsterinfo.drop_height != 0)
			{
				request.pathFlags = PathFlags(request.pathFlags | PathFlags::WalkOffLedge);
				request.traversals.dropHeight = self.monsterinfo.drop_height;
			}
		}

		if ((self.flags & ent_flags_t::FLY) != 0)
		{
			request.nodeSearch.maxHeight = request.nodeSearch.minHeight = 8192.0f;
			request.pathFlags = PathFlags(request.pathFlags | PathFlags::LongJump);
		}

		if (!gi_GetPathToGoal(request, self.monsterinfo.nav_path))
		{
			// fatal error, don't bother ever trying nodes
			if (self.monsterinfo.nav_path.returnCode == PathReturnCode::NoNavAvailable)
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::NO_PATH_FINDING);
			return false;
		}

		self.monsterinfo.nav_path_cache_time = level.time + time_sec(2);
	}

	float yaw;
	float old_yaw = self.e.s.angles.yaw;
	float old_ideal_yaw = self.ideal_yaw;
	
	if (self.monsterinfo.random_change_time >= level.time &&
	    (self.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) == 0)
		yaw = self.ideal_yaw;
	else
		yaw = vectoyaw((path_to - self.e.s.origin).normalized());

	if ( !SV_StepDirection( self, yaw, dist, true ) ) {

		if (!self.e.inuse)
			return false;

		if (self.monsterinfo.blocked !is null && (self.monsterinfo.aiflags & ai_flags_t::TARGET_ANGER) == 0)
		{
			if ((self.e.inuse) && (self.health > 0))
			{
				// if we're blocked, the blocked function will be deferred to for yaw
				self.e.s.angles.yaw = old_yaw;
				self.ideal_yaw = old_ideal_yaw;
				if (self.monsterinfo.blocked(self, dist))
					return true;
			}
		}

		// try the first point
		if (self.monsterinfo.random_change_time >= level.time)
			yaw = self.ideal_yaw;
		else
			yaw = vectoyaw((self.monsterinfo.nav_path.firstMovePoint - self.e.s.origin).normalized());
		
		if ( !SV_StepDirection( self, yaw, dist, true ) ) {

			// we got blocked, but all is not lost yet; do a similar bump around-ish behavior
			// to try to regain our composure
			if ((self.monsterinfo.aiflags & ai_flags_t::BLOCKED) != 0)
			{
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
				return true;
			}

			if (self.monsterinfo.random_change_time < level.time && self.e.inuse)
			{
				self.monsterinfo.random_change_time = level.time + time_ms(1500);
				if (SV_NewChaseDir(self, path_to, dist))
					return true;
			}

			self.monsterinfo.path_blocked_counter += FRAME_TIME_S * 3;
		}

		if (self.monsterinfo.path_blocked_counter > time_sec(1.5))
			return false;
	}

	return true;
}

/*
=============
M_MoveToPath

Advanced movement code that use the bots pathfinder if allowed and conditions are right.
Feel free to add any other conditions needed.
=============
*/
bool M_MoveToPath(ASEntity &self, float dist)
{
	if ((self.flags & ent_flags_t::STATIONARY) != 0)
		return false;
	else if ((self.monsterinfo.aiflags & ai_flags_t::NO_PATH_FINDING) != 0)
		return false;
	else if (self.monsterinfo.path_wait_time > level.time)
		return false;
	else if (self.enemy is null)
		return false;
	else if (self.enemy.client !is null && self.enemy.client.invisible_time > level.time && self.enemy.client.invisibility_fade_time <= level.time)
		return false;
	else if (self.monsterinfo.attack_state >= ai_attack_state_t::MISSILE)
		return true;

	combat_style_t style = self.monsterinfo.combat_style;

	if ((self.monsterinfo.aiflags & ai_flags_t::TEMP_MELEE_COMBAT) != 0)
		style = combat_style_t::MELEE;
	
	if ( visible(self, self.enemy, false) ) {
		if ( (self.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) != 0 || style == combat_style_t::RANGED ) {
			// do the normal "shoot, walk, shoot" behavior...
			return false;
		} else if ( style == combat_style_t::MELEE ) {
			// path pretty close to the enemy, then let normal Quake movement take over.
			if ( range_to(self, self.enemy) > 240.0f ||
					abs(self.e.s.origin.z - self.enemy.e.s.origin.z) > max(self.e.maxs.z, -self.e.mins.z) ) {
				if ( M_NavPathToGoal( self, dist, self.enemy.e.s.origin ) ) {
					return true;
				}
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TEMP_MELEE_COMBAT);
			} else {
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TEMP_MELEE_COMBAT);
				return false;
			}
		} else if ( style == combat_style_t::MIXED ) {
			// most mixed combat AI have fairly short range attacks, so try to path within mid range.
			if ( range_to(self, self.enemy) > RANGE_NEAR ||
					abs(self.e.s.origin.z - self.enemy.e.s.origin.z) > max(self.e.maxs.z, -self.e.mins.z) * 2.0f ) {
				if ( M_NavPathToGoal( self, dist, self.enemy.e.s.origin ) ) {
					return true;
				}
			} else {
				return false;
			}
		}
	} else {
		// we can't see our enemy, let's see if we can path to them
		if ( M_NavPathToGoal( self, dist, self.enemy.e.s.origin ) ) {
			return true;
		}
	}

	if (!self.e.inuse)
		return false;

	if (self.monsterinfo.nav_path.returnCode > PathReturnCode::StartPathErrors)
	{
		self.monsterinfo.path_wait_time = level.time + time_sec(10);
		return false;
	}

	self.monsterinfo.path_blocked_counter += FRAME_TIME_S * 3;

	if (self.monsterinfo.path_blocked_counter > time_sec(5))
	{
		self.monsterinfo.path_blocked_counter = time_zero;
		self.monsterinfo.path_wait_time = level.time + time_sec(5);

		return false;
	}

	return true;
}

/*
======================
M_MoveToGoal
======================
*/
void M_MoveToGoal(ASEntity &ent, float dist)
{
	if ( ai_movement_disabled.integer != 0 ) {
		if ( !FacingIdeal( ent ) ) {
			M_ChangeYaw( ent );
		} // mal: don't move, but still face toward target
		return;
	}

	ASEntity @goal;

	@goal = ent.goalentity;

	if (ent.groundentity is null && (ent.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
		return;
	// ???
	else if (goal is null)
		return;

	// [Paril-KEX] try paths if we can't see the enemy
	if ((ent.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) == 0 && ent.monsterinfo.attack_state < ai_attack_state_t::MISSILE)
	{
        if (M_MoveToPath(ent, dist))
		{
			ent.monsterinfo.path_blocked_counter = max(time_zero, ent.monsterinfo.path_blocked_counter - FRAME_TIME_S);
			return;
		}
	}

	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::PATHING);

	// [Paril-KEX] dumb hack; in some n64 maps, the corners are way too high and
	// I'm too lazy to fix them individually in maps, so here's a game fix..
	if ((goal.flags & ent_flags_t::PARTIALGROUND) == 0 && (ent.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0 &&
		(goal.classname == "path_corner" || goal.classname == "point_combat"))
	{
		vec3_t p = goal.e.s.origin;
		p.z = ent.e.s.origin.z;

		if (boxes_intersect(ent.e.absmin, ent.e.absmax, p, p))
		{
			// mark this so we don't do it again later
			goal.flags = ent_flags_t(goal.flags | ent_flags_t::PARTIALGROUND);

			if (!boxes_intersect(ent.e.absmin, ent.e.absmax, goal.e.s.origin, goal.e.s.origin))
			{
				// move it if we would have touched it if the corner was lower
				goal.e.s.origin.z = p.z;
				gi_linkentity(goal.e);
			}
		}
	}

	// [Paril-KEX] if we have a straight shot to our target, just move
	// straight instead of trying to stick to invisible guide lines
	if ((ent.monsterinfo.bad_move_time <= level.time || (ent.monsterinfo.aiflags & ai_flags_t::CHARGING) != 0) && goal !is null)
	{
		if (!FacingIdeal(ent))
		{
			M_ChangeYaw(ent);
			return;
		}

		trace_t tr = gi_traceline(ent.e.s.origin, goal.e.s.origin, ent.e, contents_t::MASK_MONSTERSOLID);

		if (tr.fraction == 1.0f || tr.ent is goal.e)
		{
			if (SV_StepDirection(ent, vectoyaw((goal.e.s.origin - ent.e.s.origin).normalized()), dist, false))
				return;
		}

		// we didn't make a step, so don't try this for a while
		// *unless* we're going to a path corner
		if (goal.classname != "path_corner" && goal.classname != "point_combat")
		{
			ent.monsterinfo.bad_move_time = level.time + time_sec(5);
			ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::CHARGING);
		}
	}

	// bump around...
	if ((ent.monsterinfo.random_change_time <= level.time // random change time is up
		&& irandom(4) == 1 // random bump around
		&& (ent.monsterinfo.aiflags & ai_flags_t::CHARGING) == 0 // PMM - charging monsters (AI_CHARGING) don't deflect unless they have to
		&& !((ent.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0 && ent.enemy !is null && (ent.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) == 0)) // alternate fly monsters don't do this either unless they have to
		|| !SV_StepDirection(ent, ent.ideal_yaw, dist, ent.monsterinfo.bad_move_time > level.time))
	{
		if ((ent.monsterinfo.aiflags & ai_flags_t::BLOCKED) != 0)
		{
			ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
			return;
		}
		ent.monsterinfo.random_change_time = level.time + random_time(time_ms(500), time_ms(1000));
		SV_NewChaseDir(ent, goal.e.s.origin, dist);
		ent.monsterinfo.move_block_counter = 0;
	}
	else
		ent.monsterinfo.bad_move_time -= time_ms(250);
}

/*
===============
M_walkmove
===============
*/
bool M_walkmove(ASEntity &ent, float yaw, float dist)
{
	if ( ai_movement_disabled.integer != 0 ) {
		return false;
	}

	vec3_t move;
	// PMM
	bool retval;

	if (ent.groundentity is null && (ent.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
		return false;

	yaw = yaw * PIf * 2 / 360;

	move.x = cos(yaw) * dist;
	move.y = sin(yaw) * dist;
	move.z = 0;

	// PMM
	retval = SV_movestep(ent, move, true);
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags & ~ai_flags_t::BLOCKED);
	return retval;
}
