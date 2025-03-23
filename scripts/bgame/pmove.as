// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

// In PSX SP, step-ups aren't allowed
bool PM_AllowStepUp()
{
	if ((pm_config.physics_flags & physics_flags_t::PSX_MOVEMENT) != 0)
		return (pm_config.physics_flags & physics_flags_t::DEATHMATCH) != 0;

	return true;
}

float PM_ApplyPSXScalar(float v, float scalar = PSX_PHYSICS_SCALAR)
{
	if ((pm_config.physics_flags & physics_flags_t::PSX_SCALE) != 0)
		return v * scalar;

	return v;
}

// PSX / N64 can't trick-jump except in DM
bool PM_AllowTrickJump()
{
	return (pm_config.physics_flags & (physics_flags_t::N64_MOVEMENT | physics_flags_t::PSX_MOVEMENT)) == 0 ||
           (pm_config.physics_flags & physics_flags_t::DEATHMATCH) != 0;
}

// PSX / N64 (single player) require landing before a next jump
bool PM_NeedsLandTime()
{
	return (pm_config.physics_flags & (physics_flags_t::N64_MOVEMENT | physics_flags_t::PSX_MOVEMENT)) != 0 &&
           (pm_config.physics_flags & physics_flags_t::DEATHMATCH) == 0;
}

funcdef trace_t stuck_object_trace_fn_t(const vec3_t &in, const vec3_t &in, const vec3_t &in, const vec3_t &in);

enum stuck_result_t
{
	GOOD_POSITION,
	FIXED,
	NO_GOOD_POSITION
};

class good_position_t
{
    vec3_t origin;
    float distance;

    good_position_t() { }

    good_position_t(const vec3_t &in origin, float distance)
    {
        this.origin = origin;
        this.distance = distance;
    }
};

class side_check_t
{
    vec3_t normal, mins, maxs;

    side_check_t()
    {
    }

    side_check_t(const vec3_t &in normal, const vec3_t &in mins, const vec3_t &in maxs)
    {
        this.normal = normal;
        this.mins = mins;
        this.maxs = maxs;
    }
};

const side_check_t[] side_checks = {
    side_check_t({ 0, 0, 1 }, { -1, -1, 0 }, { 1, 1, 0 }),
    side_check_t({ 0, 0, -1 }, { -1, -1, 0 }, { 1, 1, 0 }),
    side_check_t({ 1, 0, 0 }, { 0, -1, -1 }, { 0, 1, 1 }),
    side_check_t({ -1, 0, 0 }, { 0, -1, -1 }, { 0, 1, 1 }),
    side_check_t({ 0, 1, 0 }, { -1, 0, -1 }, { 1, 0, 1 }),
    side_check_t({ 0, -1, 0 }, { -1, 0, -1 }, { 1, 0, 1 })
};

// [Paril-KEX] generic code to detect & fix a stuck object
stuck_result_t G_FixStuckObject_Generic(const vec3_t &in origin, const vec3_t &in own_mins, const vec3_t &in own_maxs, stuck_object_trace_fn_t @trace, vec3_t &out out_origin)
{
	if (!trace(origin, own_mins, own_maxs, origin).startsolid)
    {
        out_origin = origin;
		return stuck_result_t::GOOD_POSITION;
    }

	good_position_t[] good_positions;

	for (uint sn = 0; sn < side_checks.length(); sn++)
	{
		side_check_t side = side_checks[sn];
		vec3_t start = origin;
		vec3_t mins = vec3_origin, maxs = vec3_origin;

		for (int n = 0; n < 3; n++)
		{
			if (side.normal[n] < 0)
				start[n] += own_mins[n];
			else if (side.normal[n] > 0)
				start[n] += own_maxs[n];

			if (side.mins[n] == -1)
				mins[n] = own_mins[n];
			else if (side.mins[n] == 1)
				mins[n] = own_maxs[n];

			if (side.maxs[n] == -1)
				maxs[n] = own_mins[n];
			else if (side.maxs[n] == 1)
				maxs[n] = own_maxs[n];
		}

		trace_t tr = trace(start, mins, maxs, start);

		int needed_epsilon_fix = -1;
		int needed_epsilon_dir;

		if (tr.startsolid)
		{
			for (int e = 0; e < 3; e++)
			{
				if (side.normal[e] != 0)
					continue;

				vec3_t ep_start = start;
				ep_start[e] += 1;

				tr = trace(ep_start, mins, maxs, ep_start);

				if (!tr.startsolid)
				{
					start = ep_start;
					needed_epsilon_fix = e;
					needed_epsilon_dir = 1;
					break;
				}

				ep_start[e] -= 2;
				tr = trace(ep_start, mins, maxs, ep_start);

				if (!tr.startsolid)
				{
					start = ep_start;
					needed_epsilon_fix = e;
					needed_epsilon_dir = -1;
					break;
				}
			}
		}

		// no good
		if (tr.startsolid)
			continue;

		vec3_t opposite_start = origin;
		side_check_t other_side = side_checks[sn ^ 1];

		for (int n = 0; n < 3; n++)
		{
			if (other_side.normal[n] < 0)
				opposite_start[n] += own_mins[n];
			else if (other_side.normal[n] > 0)
				opposite_start[n] += own_maxs[n];
		}

		if (needed_epsilon_fix >= 0)
			opposite_start[needed_epsilon_fix] += needed_epsilon_dir;

		// potentially a good side; start from our center, push back to the opposite side
		// to find how much clearance we have
		tr = trace(start, mins, maxs, opposite_start);

		// ???
		if (tr.startsolid)
			continue;

		// check the delta
		vec3_t end = tr.endpos;
		// push us very slightly away from the wall
		end += side.normal * 0.125f;

		// calculate delta
		const vec3_t delta = end - opposite_start;
		vec3_t new_origin = origin + delta;

		if (needed_epsilon_fix >= 0)
			new_origin[needed_epsilon_fix] += needed_epsilon_dir;

		tr = trace(new_origin, own_mins, own_maxs, new_origin);

		// bad
		if (tr.startsolid)
			continue;

        good_positions.push_back(good_position_t(new_origin, delta.lengthSquared()));
	}

	if (!good_positions.empty())
	{
		good_positions.sort(function(a, b) { return a.distance < b.distance; });

		out_origin = good_positions[0].origin;

		return stuck_result_t::FIXED;
	}

    out_origin = origin;

	return stuck_result_t::NO_GOOD_POSITION;
}

// all of the locals will be zeroed before each
// pmove, just to make damn sure we don't have
// any differences when running on client or server

class pml_t
{
	vec3_t origin = vec3_origin;	 // full float precision
	vec3_t velocity = vec3_origin; // full float precision

	vec3_t forward = vec3_origin, right = vec3_origin, up = vec3_origin;
	float  frametime = 0;

	csurface_t @groundsurface = null;
	contents_t	groundcontents = contents_t::NONE;

	vec3_t previous_origin = vec3_origin;
	vec3_t start_velocity = vec3_origin;

    pml_t() { }
};

pmove_t @pm;
pml_t	 pml;

// movement parameters
const float pm_stopspeed = 100;
const float pm_maxspeed = 300;
const float pm_duckspeed = 100;
const float pm_accelerate = 10;
const float pm_wateraccelerate = 10;
const float pm_friction = 6;
const float pm_waterfriction = 1;
const float pm_waterspeed = 400;
const float pm_laddermod = 0.5f;

/*

  walking up a step should kill some velocity

*/

trace_t PM_Clip(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, contents_t mask)
{
	return pm.clip(start, mins, maxs, end, mask);
}

trace_t PM_Trace(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end, contents_t mask = contents_t::NONE)
{
	if (pm.s.pm_type == pmtype_t::SPECTATOR)
		return PM_Clip(start, mins, maxs, end, contents_t::MASK_SOLID);

	if (mask == contents_t::NONE)
	{
		if (pm.s.pm_type == pmtype_t::DEAD || pm.s.pm_type == pmtype_t::GIB)
			mask = contents_t::MASK_DEADSOLID;
		else if (pm.s.pm_type == pmtype_t::SPECTATOR)
			mask = contents_t::MASK_SOLID;
		else
			mask = contents_t::MASK_PLAYERSOLID;

		if ((pm.s.pm_flags & pmflags_t::IGNORE_PLAYER_COLLISION) != 0)
			mask = contents_t(mask & ~contents_t::PLAYER);
	}

	return pm.trace(start, mins, maxs, end, pm.player, mask);
}

// only here to satisfy pm_trace_t
trace_t PM_Trace_Auto(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end)
{
	return PM_Trace(start, mins, maxs, end);
}

const int MAXTOUCH = 32;

/*
==================
PM_StepSlideMove

Each intersection will try to step over the obstruction instead of
sliding along it.

Returns a new origin, velocity, and contact entity
Does not modify any world state?
==================
*/
const float	 MIN_STEP_NORMAL = 0.7f; // can't step up onto very steep slopes
const int MAX_CLIP_PLANES = 5;

void PM_RecordTrace(pmove_t &pm/*array<trace_t> &touch*/, trace_t &in tr)
{
	if (pm.touch_length() == MAXTOUCH)
		return;

	for (uint i = 0; i < pm.touch_length(); i++)
		if (pm.touch_get(i).ent is tr.ent)
			return;
    
	pm.touch_push_back(tr);
}

funcdef trace_t pm_trace_func_f(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end);

// [Paril-KEX] made generic so you can run this without
// needing a pml/pm
void PM_StepSlideMove_Generic(vec3_t &in in_origin, vec3_t &in in_velocity, float frametime,
                              const vec3_t &in mins, const vec3_t &in maxs, pmove_t &pm,/*array<trace_t> &touch,*/
                              bool has_time, pm_trace_func_f @trace_func, vec3_t &out out_origin,
                              vec3_t &out out_velocity)
{
	int		bumpcount, numbumps;
	vec3_t	dir;
	float	d;
	int		numplanes;
	array<vec3_t>	planes;
	vec3_t	primal_velocity;
	int		i, j;
	trace_t trace;
	vec3_t	end;
	float	time_left;

	numbumps = 4;

	primal_velocity = in_velocity;
	numplanes = 0;

	time_left = frametime;

	for (bumpcount = 0; bumpcount < numbumps; bumpcount++)
	{
		for (i = 0; i < 3; i++)
			end[i] = in_origin[i] + time_left * in_velocity[i];

		trace = trace_func(in_origin, mins, maxs, end);

		if (trace.allsolid)
		{						 // entity is trapped in another solid
			in_velocity[2] = 0; // don't build up falling damage
			
			// save entity for contact
			PM_RecordTrace(/*touch*/pm, trace);

            out_origin = in_origin;
            out_velocity = in_velocity;
			return;
		}

		// [Paril-KEX] experimental attempt to fix stray collisions on curved
		// surfaces; easiest to see on q2dm1 by running/jumping against the sides
		// of the curved map.
		if (trace.surface2 !is null)
		{
			vec3_t clipped_a, clipped_b;
            clipped_a = SlideClipVelocity(in_velocity, trace.plane.normal, 1.01f);
            clipped_b = SlideClipVelocity(in_velocity, trace.plane2.normal, 1.01f);

			bool better = false;

			for (int c = 0; c < 3; c++)
			{
				if (abs(clipped_a[c]) < abs(clipped_b[c]))
				{
					better = true;
					break;
				}
			}

			if (better)
			{
				trace.plane = trace.plane2;
				@trace.surface = @trace.surface2;
			}
		}

		if (trace.fraction > 0)
		{ // actually covered some distance
			in_origin = trace.endpos;
			numplanes = 0;
		}

		if (trace.fraction == 1)
			break; // moved the entire distance

		// save entity for contact
		PM_RecordTrace(/*touch*/pm, trace);

		time_left -= time_left * trace.fraction;

		// slide along this plane
		if (numplanes >= MAX_CLIP_PLANES)
		{ // this shouldn't really happen
			in_velocity = vec3_origin;
			break;
		}

		//
		// if this is the same plane we hit before, nudge origin
		// out along it, which fixes some epsilon issues with
		// non-axial planes (xswamp, q2dm1 sometimes...)
		//
		for (i = 0; i < numplanes; i++)
		{
			if (trace.plane.normal.dot(planes[i]) > 0.99f)
			{
				pml.origin.x += trace.plane.normal.x * 0.01f;
				pml.origin.y += trace.plane.normal.y * 0.01f;
				G_FixStuckObject_Generic(pml.origin, mins, maxs, trace_func, pml.origin);
				break;
			}
		}

		if (i < numplanes)
			continue;

		planes.push_back(trace.plane.normal);
		numplanes++;

		//
		// modify original_velocity so it parallels all of the clip planes
		//
		for (i = 0; i < numplanes; i++)
		{
            in_velocity = SlideClipVelocity(in_velocity, planes[i], 1.01f);
			for (j = 0; j < numplanes; j++)
				if (j != i)
				{
					if (in_velocity.dot(planes[j]) < 0)
						break; // not ok
				}
			if (j == numplanes)
				break;
		}

		if (i != numplanes)
		{ // go along this plane
		}
		else
		{ // go along the crease
			if (numplanes != 2)
			{
				in_velocity = vec3_origin;
				break;
			}
			dir = planes[0].cross(planes[1]);
			d = dir.dot(in_velocity);
			in_velocity = dir * d;
		}

		//
		// if velocity is against the original velocity, stop dead
		// to avoid tiny oscillations in sloping corners
		//
		if (in_velocity.dot(primal_velocity) <= 0)
		{
			in_velocity = vec3_origin;
			break;
		}
	}

	if (has_time)
	{
		in_velocity = primal_velocity;
	}

    out_origin = in_origin;
    out_velocity = in_velocity;
}

void PM_StepSlideMove_()
{
	PM_StepSlideMove_Generic(pml.origin, pml.velocity, pml.frametime, pm.mins, pm.maxs, /*pm.touch*/pm, pm.s.pm_time != 0, PM_Trace_Auto, pml.origin, pml.velocity);
}


/*
==================
PM_StepSlideMove

==================
*/
void PM_StepSlideMove()
{
	vec3_t	start_o, start_v;
	vec3_t	down_o, down_v;
	trace_t trace;
	float	down_dist, up_dist;
	//	vec3_t		delta;
	vec3_t up, down;

	start_o = pml.origin;
	start_v = pml.velocity;

	PM_StepSlideMove_();

	if (!PM_AllowStepUp())
	{
		// no step up
		if ((pm.s.pm_flags & pmflags_t::ON_GROUND) == 0)
			return;
	}

	down_o = pml.origin;
	down_v = pml.velocity;

	up = start_o;
	up[2] += STEPSIZE;

	trace = PM_Trace(start_o, pm.mins, pm.maxs, up);
	if (trace.allsolid)
		return; // can't step up

	float stepSize = trace.endpos[2] - start_o[2];

	// try sliding above
	pml.origin = trace.endpos;
	pml.velocity = start_v;

	PM_StepSlideMove_();

	// push down the final amount
	down = pml.origin;
	down[2] -= stepSize;

	// [Paril-KEX] jitspoe suggestion for stair clip fix; store
	// the old down position, and pick a better spot for downwards
	// trace if the start origin's Z position is lower than the down end pt.
	vec3_t original_down = down;

	if (start_o[2] < down[2])
		down[2] = start_o[2] - 1.0f;

	trace = PM_Trace(pml.origin, pm.mins, pm.maxs, down);
	if (!trace.allsolid)
	{
		// [Paril-KEX] from above, do the proper trace now
		trace_t real_trace = PM_Trace(pml.origin, pm.mins, pm.maxs, original_down);
		pml.origin = real_trace.endpos;

		// only an upwards jump is a stair clip
		if (pml.velocity.z > 0.0f)
		{
			pm.step_clip = true;
		}
	}

	up = pml.origin;

	// decide which one went farther
	down_dist = (down_o.x - start_o.x) * (down_o.x - start_o.x) + (down_o.y - start_o.y) * (down_o.y - start_o.y);
	up_dist = (up.x - start_o.x) * (up.x - start_o.x) + (up.y - start_o.y) * (up.y - start_o.y);

	if (down_dist > up_dist || trace.plane.normal.z < MIN_STEP_NORMAL)
	{
		pml.origin = down_o;
		pml.velocity = down_v;
	}
	// [Paril-KEX] NB: this line being commented is crucial for ramp-jumps to work.
	// thanks to Jitspoe for pointing this one out.
	else// if (pm->s.pm_flags & PMF_ON_GROUND)
		//!! Special case
		// if we were walking along a plane, then we need to copy the Z over
		pml.velocity.z = down_v.z;

	// Paril: step down stairs/slopes
	if ((pm.s.pm_flags & pmflags_t::ON_GROUND) != 0 && (pm.s.pm_flags & pmflags_t::ON_LADDER) == 0 &&
		(pm.waterlevel < water_level_t::WAIST || ((pm.cmd.buttons & button_t::JUMP) == 0 && pml.velocity.z <= 0)))
	{
		down = pml.origin;
		down.z -= STEPSIZE;
		trace = PM_Trace(pml.origin, pm.mins, pm.maxs, down);
		if (trace.fraction < 1.0f)
		{
			pml.origin = trace.endpos;
		}
	}
}

/*
==================
PM_Friction

Handles both ground friction and water friction
==================
*/
void PM_Friction()
{
	float  speed, newspeed, control;
	float  friction;
	float  drop;

	speed = pml.velocity.length();
	if (speed < 1)
	{
		pml.velocity.x = 0;
		pml.velocity.y = 0;
		return;
	}

	drop = 0;

	// apply ground friction
	if ((pm.groundentity !is null && pml.groundsurface !is null &&
        (pml.groundsurface.flags & surfflags_t::SLICK) == 0) || (pm.s.pm_flags & pmflags_t::ON_LADDER) != 0)
	{
		friction = PM_ApplyPSXScalar(pm_friction);
		control = speed < PM_ApplyPSXScalar(pm_stopspeed) ? PM_ApplyPSXScalar(pm_stopspeed) : speed;
		drop += control * friction * pml.frametime;
	}

	// apply water friction
	if (pm.waterlevel != water_level_t::NONE && (pm.s.pm_flags & pmflags_t::ON_LADDER) == 0)
	{
		drop += speed * PM_ApplyPSXScalar(pm_waterfriction) * float(pm.waterlevel) * pml.frametime;
	}

	// scale the velocity
	newspeed = speed - drop;
	if (newspeed < 0)
	{
		newspeed = 0;
	}
	newspeed /= speed;

	pml.velocity *= newspeed;
}

/*
==============
PM_Accelerate

Handles user intended acceleration
==============
*/
void PM_Accelerate(const vec3_t &in wishdir, float wishspeed, float accel)
{
	wishspeed = PM_ApplyPSXScalar(wishspeed);
	accel = PM_ApplyPSXScalar(accel);

	float currentspeed = pml.velocity.dot(wishdir);
	float addspeed = wishspeed - currentspeed;
	if (addspeed <= 0)
		return;
	float accelspeed = accel * pml.frametime * wishspeed;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (int i = 0; i < 3; i++)
		pml.velocity[i] += accelspeed * wishdir[i];
}

void PM_AirAccelerate(const vec3_t &in wishdir, float wishspeed, float accel)
{
	float wishspd = wishspeed;
	if (wishspd > 30)
		wishspd = 30;
	float currentspeed = pml.velocity.dot(wishdir);
	float addspeed = wishspd - currentspeed;
	if (addspeed <= 0)
		return;
	float accelspeed = accel * wishspeed * pml.frametime;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (int i = 0; i < 3; i++)
		pml.velocity[i] += accelspeed * wishdir[i];
}

/*
=============
PM_AddCurrents
=============
*/
void PM_AddCurrents(vec3_t &wishvel)
{
	vec3_t v;
	float  s;

	//
	// account for ladders
	//

	if ((pm.s.pm_flags & pmflags_t::ON_LADDER) != 0)
	{
		if (pm.cmd.buttons & (button_t::JUMP | button_t::CROUCH) != 0)
		{
			// [Paril-KEX]: if we're underwater, use full speed on ladders
			float ladder_speed = pm.waterlevel >= water_level_t::WAIST ? pm_maxspeed : 200;
			
			if ((pm.cmd.buttons & button_t::JUMP) != 0)
				wishvel.z = ladder_speed;
			else if ((pm.cmd.buttons & button_t::CROUCH) != 0)
				wishvel.z = -ladder_speed;
		}
		else if (pm.cmd.forwardmove != 0)
		{
			// [Paril-KEX] clamp the speed a bit so we're not too fast
			float ladder_speed = clamp(pm.cmd.forwardmove, -200.0f, 200.0f);

			if (pm.cmd.forwardmove > 0)
			{
				if (pm.viewangles.pitch < 15)
					wishvel.z = ladder_speed;
				else
					wishvel.z = -ladder_speed;
			}
			// [Paril-KEX] allow using "back" arrow to go down on ladder
			else if (pm.cmd.forwardmove < 0)
			{
				// if we haven't touched ground yet, remove x/y so we don't
				// slide off of the ladder
				if (pm.groundentity is null)
					wishvel.x = wishvel.y = 0;

				wishvel.z = ladder_speed;
			}
		}
		else
			wishvel.z = 0;

		// limit horizontal speed when on a ladder
		// [Paril-KEX] unless we're on the ground
		if (pm.groundentity is null)
		{
			// [Paril-KEX] instead of left/right not doing anything,
			// have them move you perpendicular to the ladder plane
			if (pm.cmd.sidemove != 0)
			{
				// clamp side speed so it's not jarring...
				float ladder_speed = clamp(pm.cmd.sidemove, -150.0f, 150.0f);

				if (pm.waterlevel < water_level_t::WAIST)
					ladder_speed *= pm_laddermod;

				// check for ladder
				vec3_t flatforward, spot;
				flatforward = pml.forward;
				flatforward.z = 0;
				flatforward.normalize();

				spot = pml.origin + (flatforward * 1);
				trace_t trace = PM_Trace(pml.origin, pm.mins, pm.maxs, spot, contents_t::LADDER);

				if (trace.fraction != 1.0f && (trace.contents & contents_t::LADDER) != 0)
				{
					vec3_t right = trace.plane.normal.cross({ 0, 0, 1 });

					wishvel.x = wishvel.y = 0;
					wishvel += (right * -ladder_speed);
				}
			}
			else
			{
				if (wishvel.x < -25)
					wishvel.x = -25;
				else if (wishvel.x > 25)
					wishvel.y = 25;

				if (wishvel.y < -25)
					wishvel.y = -25;
				else if (wishvel.y > 25)
					wishvel.y = 25;
			}
		}
	}

	//
	// add water currents
	//

	if ((pm.watertype & contents_t::MASK_CURRENT) != 0)
	{
		v = vec3_origin;

		if ((pm.watertype & contents_t::CURRENT_0) != 0)
			v[0] += 1;
		if ((pm.watertype & contents_t::CURRENT_90) != 0)
			v[1] += 1;
		if ((pm.watertype & contents_t::CURRENT_180) != 0)
			v[0] -= 1;
		if ((pm.watertype & contents_t::CURRENT_270) != 0)
			v[1] -= 1;
		if ((pm.watertype & contents_t::CURRENT_UP) != 0)
			v[2] += 1;
		if ((pm.watertype & contents_t::CURRENT_DOWN) != 0)
			v[2] -= 1;

		s = pm_waterspeed;
		if ((pm.waterlevel == water_level_t::FEET) && pm.groundentity !is null)
			s /= 2;

		wishvel += (v * s);
	}

	//
	// add conveyor belt velocities
	//

	if (pm.groundentity !is null)
	{
		v = vec3_origin;

		if ((pml.groundcontents & contents_t::CURRENT_0) != 0)
			v[0] += 1;
		if ((pml.groundcontents & contents_t::CURRENT_90) != 0)
			v[1] += 1;
		if ((pml.groundcontents & contents_t::CURRENT_180) != 0)
			v[0] -= 1;
		if ((pml.groundcontents & contents_t::CURRENT_270) != 0)
			v[1] -= 1;
		if ((pml.groundcontents & contents_t::CURRENT_UP) != 0)
			v[2] += 1;
		if ((pml.groundcontents & contents_t::CURRENT_DOWN) != 0)
			v[2] -= 1;

		wishvel += v * 100;
	}
}

/*
===================
PM_WaterMove

===================
*/
void PM_WaterMove()
{
	int	   i;
	vec3_t wishvel;
	float  wishspeed;
	vec3_t wishdir;

	//
	// user intentions
	//
	for (i = 0; i < 3; i++)
		wishvel[i] = pml.forward[i] * pm.cmd.forwardmove + pml.right[i] * pm.cmd.sidemove;

	if (pm.cmd.forwardmove == 0 && pm.cmd.sidemove == 0 &&
		(pm.cmd.buttons & (button_t::JUMP | button_t::CROUCH)) == 0)
	{
		if (pm.groundentity is null)
			wishvel[2] -= 60; // drift towards bottom
	}
	else
	{
		if ((pm.cmd.buttons & button_t::CROUCH) != 0)
			wishvel[2] -= pm_waterspeed * 0.5f;
		else if ((pm.cmd.buttons & button_t::JUMP) != 0)
			wishvel[2] += pm_waterspeed * 0.5f;
	}

	PM_AddCurrents(wishvel);

	wishdir = wishvel;
	wishspeed = wishdir.normalize();

	if (wishspeed > pm_maxspeed)
	{
		wishvel *= pm_maxspeed / wishspeed;
		wishspeed = pm_maxspeed;
	}
	wishspeed *= 0.5f;

	float duckspeed = PM_ApplyPSXScalar(pm_duckspeed, 1.25f);

	if ((pm.s.pm_flags & pmflags_t::DUCKED) != 0 && wishspeed > duckspeed)
	{
		wishvel *= duckspeed / wishspeed;
		wishspeed = duckspeed;
	}

	PM_Accelerate(wishdir, wishspeed, pm_wateraccelerate);

	PM_StepSlideMove();
}

/*
===================
PM_AirMove

===================
*/
void PM_AirMove()
{
	int	   i;
	vec3_t wishvel;
	float  fmove, smove;
	vec3_t wishdir;
	float  wishspeed;
	float  maxspeed;

	fmove = pm.cmd.forwardmove;
	smove = pm.cmd.sidemove;

	for (i = 0; i < 2; i++)
		wishvel[i] = pml.forward[i] * fmove + pml.right[i] * smove;
	wishvel[2] = 0;

	PM_AddCurrents(wishvel);

	wishdir = wishvel;
	wishspeed = wishdir.normalize();

	float duckspeed = PM_ApplyPSXScalar(pm_duckspeed, 1.25f);

	//
	// clamp to server defined max speed
	//
	maxspeed = (pm.s.pm_flags & pmflags_t::DUCKED) != 0 ? duckspeed : pm_maxspeed;

	if (wishspeed > maxspeed)
	{
		wishvel *= maxspeed / wishspeed;
		wishspeed = maxspeed;
	}

	if ((pm.s.pm_flags & pmflags_t::ON_LADDER) != 0)
	{
		PM_Accelerate(wishdir, wishspeed, pm_accelerate);
		if (wishvel[2] == 0)
		{
			if (pml.velocity[2] > 0)
			{
				pml.velocity[2] -= pm.s.gravity * pml.frametime;
				if (pml.velocity[2] < 0)
					pml.velocity[2] = 0;
			}
			else
			{
				pml.velocity[2] += pm.s.gravity * pml.frametime;
				if (pml.velocity[2] > 0)
					pml.velocity[2] = 0;
			}
		}
		PM_StepSlideMove();
	}
	else if (pm.groundentity !is null)
	{						 // walking on ground
		pml.velocity[2] = 0; //!!! this is before the accel
		PM_Accelerate(wishdir, wishspeed, pm_accelerate);

		// PGM	-- fix for negative trigger_gravity fields
		//		pml.velocity[2] = 0;
		if (pm.s.gravity > 0)
			pml.velocity[2] = 0;
		else
			pml.velocity[2] -= pm.s.gravity * pml.frametime;
		// PGM

		if (pml.velocity[0] == 0 && pml.velocity[1] == 0)
			return;
		PM_StepSlideMove();
	}
	else
	{ // not on ground, so little effect on velocity
		if (pm_config.airaccel != 0)
			PM_AirAccelerate(wishdir, wishspeed, pm_config.airaccel);
		else
			PM_Accelerate(wishdir, wishspeed, 1);

		// add gravity
		if (pm.s.pm_type != pmtype_t::GRAPPLE)
			pml.velocity[2] -= pm.s.gravity * pml.frametime;

		PM_StepSlideMove();
	}
}

void PM_GetWaterLevel(const vec3_t &in position, water_level_t &out level, contents_t &out type)
{
	//
	// get waterlevel, accounting for ducking
	//
	level = water_level_t::NONE;
	type = contents_t::NONE;

	int sample2 = int(pm.s.viewheight - pm.mins[2]);
	int sample1 = sample2 / 2;

	vec3_t point = position;

	point[2] += pm.mins[2] + 1;

	contents_t cont = pm.pointcontents(point);

	if ((cont & contents_t::MASK_WATER) != 0)
	{
		type = cont;
		level = water_level_t::FEET;
		point[2] = pml.origin[2] + pm.mins[2] + sample1;
		cont = pm.pointcontents(point);
		if ((cont & contents_t::MASK_WATER) != 0)
		{
			level = water_level_t::WAIST;
			point[2] = pml.origin[2] + pm.mins[2] + sample2;
			cont = pm.pointcontents(point);
			if ((cont & contents_t::WATER) != 0)
				level = water_level_t::UNDER;
		}
	}
}

/*
=============
PM_CatagorizePosition
=============
*/
void PM_CatagorizePosition()
{
	vec3_t	   point;
	trace_t	   trace;

	// if the player hull point one unit down is solid, the player
	// is on ground

	// see if standing on something solid
	point[0] = pml.origin[0];
	point[1] = pml.origin[1];
	point[2] = pml.origin[2] - 0.25f;

	if ((pm.s.pm_flags & pmflags_t::NO_GROUND_SEEK) != 0 || pml.velocity[2] > 180 || pm.s.pm_type == pmtype_t::GRAPPLE) //!!ZOID changed from 100 to 180 (ramp accel)
	{
		pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::ON_GROUND);
		@pm.groundentity = null;
	}
	else
	{
		trace = PM_Trace(pml.origin, pm.mins, pm.maxs, point);
		pm.groundplane = trace.plane;
		@pml.groundsurface = @trace.surface;
		pml.groundcontents = trace.contents;

		// [Paril-KEX] to attempt to fix edge cases where you get stuck
		// wedged between a slope and a wall (which is irrecoverable
		// most of the time), we'll allow the player to "stand" on
		// slopes if they are right up against a wall
		bool slanted_ground = trace.fraction < 1.0f && trace.plane.normal[2] < 0.7f;

		if (slanted_ground)
		{
			trace_t slant = PM_Trace(pml.origin, pm.mins, pm.maxs, pml.origin + trace.plane.normal);

			if (slant.fraction < 1.0f && !slant.startsolid)
				slanted_ground = false;
		}

		if (trace.fraction == 1.0f || (slanted_ground && !trace.startsolid))
		{
			@pm.groundentity = null;
			pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::ON_GROUND);
		}
		else
		{
			@pm.groundentity = @trace.ent;

			// hitting solid ground will end a waterjump
			if ((pm.s.pm_flags & pmflags_t::TIME_WATERJUMP) != 0)
			{
				pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~(pmflags_t::TIME_WATERJUMP | pmflags_t::TIME_LAND | pmflags_t::TIME_TELEPORT | pmflags_t::TIME_TRICK));
				pm.s.pm_time = 0;
			}

			if ((pm.s.pm_flags & pmflags_t::ON_GROUND) == 0)
			{
				// just hit the ground

				// [Paril-KEX]
				if (PM_AllowTrickJump() && pml.velocity[2] >= 100.0f && pm.groundplane.normal[2] >= 0.9f && (pm.s.pm_flags & pmflags_t::DUCKED) == 0)
				{
					pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::TIME_TRICK);
					pm.s.pm_time = 64;
				}

				// [Paril-KEX] calculate impact delta; this also fixes triple jumping
				vec3_t clipped_velocity = SlideClipVelocity(pml.velocity, pm.groundplane.normal, 1.01f);

				pm.impact_delta = PM_ApplyPSXScalar(pml.start_velocity[2] - clipped_velocity[2], 1.0f / PSX_PHYSICS_SCALAR);

				pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::ON_GROUND);

				if (PM_NeedsLandTime() || (pm.s.pm_flags & pmflags_t::DUCKED) != 0)
				{
					pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::TIME_LAND);
					pm.s.pm_time = uint16(PM_ApplyPSXScalar(128, 0.5f));
				}
			}
		}

		PM_RecordTrace(/*pm.touch*/pm, trace);
	}

	//
	// get waterlevel, accounting for ducking
	//
	PM_GetWaterLevel(pml.origin, pm.waterlevel, pm.watertype);
}

/*
=============
PM_CheckJump
=============
*/
void PM_CheckJump()
{
	if ((pm.s.pm_flags & pmflags_t::TIME_LAND) != 0)
	{ // hasn't been long enough since landing to jump again
		return;
	}
	
	if ((pm.cmd.buttons & button_t::JUMP) == 0)
	{ // not holding jump
		pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::JUMP_HELD);
		return;
	}

	// must wait for jump to be released
	if ((pm.s.pm_flags & pmflags_t::JUMP_HELD) != 0)
		return;

	if (pm.s.pm_type == pmtype_t::DEAD)
		return;

	if (pm.waterlevel >= water_level_t::WAIST)
	{ // swimming, not jumping
		@pm.groundentity = null;
		return;
	}

	if (pm.groundentity is null)
		return; // in air, so no effect

	pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::JUMP_HELD);
	pm.jump_sound = true;
	@pm.groundentity = null;
	pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::ON_GROUND);

	float jump_height = PM_ApplyPSXScalar(270.0f, (PSX_PHYSICS_SCALAR * 1.15f));

	pml.velocity[2] += jump_height;
	if (pml.velocity[2] < jump_height)
		pml.velocity[2] = jump_height;
}

/*
=============
PM_CheckSpecialMovement
=============
*/
void PM_CheckSpecialMovement()
{
	vec3_t	spot;
	vec3_t	flatforward;
	trace_t trace;

	if (pm.s.pm_time != 0)
		return;

	pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::ON_LADDER);

	// check for ladder
	flatforward[0] = pml.forward[0];
	flatforward[1] = pml.forward[1];
	flatforward[2] = 0;
	flatforward.normalize();

	spot = pml.origin + (flatforward * 1);
	trace = PM_Trace(pml.origin, pm.mins, pm.maxs, spot, contents_t::LADDER);
	if ((trace.fraction < 1) && (trace.contents & contents_t::LADDER) != 0 && pm.waterlevel < water_level_t::WAIST)
		pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::ON_LADDER);

	if (pm.s.gravity == 0)
		return;

	// check for water jump
	// [Paril-KEX] don't try waterjump if we're moving against where we'll hop
	if ((pm.cmd.buttons & button_t::JUMP) == 0
		&& pm.cmd.forwardmove <= 0)
		return;

	if (pm.waterlevel != water_level_t::WAIST)
		return;
	// [Paril-KEX]
	else if ((pm.watertype & contents_t::NO_WATERJUMP) != 0)
		return;

	// quick check that something is even blocking us forward
	trace = PM_Trace(pml.origin, pm.mins, pm.maxs, pml.origin + (flatforward * 40), contents_t::SOLID);

	// we aren't blocked, or what we're blocked by is something we can walk up
	if (trace.fraction == 1.0f || trace.plane.normal.z >= 0.7f)
		return;

	// [Paril-KEX] improved waterjump
	vec3_t waterjump_vel = flatforward * 50;
	waterjump_vel.z = 350;

	// simulate what would happen if we jumped out here, and
	// if we land on a dry spot we're good!
	// simulate 1 sec worth of movement
	//array<trace_t> touches;
	pmove_t temp;
	vec3_t waterjump_origin = pml.origin;
	float time = 0.1f;
	bool has_time = true;

	for (int i = 0; i < min(50, int(10 * (800.0f / pm.s.gravity))); i++)
	{
		waterjump_vel[2] -= pm.s.gravity * time;

		if (waterjump_vel[2] < 0)
			has_time = false;

		PM_StepSlideMove_Generic(waterjump_origin, waterjump_vel, time, pm.mins, pm.maxs, /*touches*/temp, has_time, PM_Trace_Auto, waterjump_origin, waterjump_vel);
	}

	// snap down to ground
	trace = PM_Trace(waterjump_origin, pm.mins, pm.maxs, waterjump_origin - vec3_t(0, 0, 2.0f), contents_t::SOLID);

	// can't stand here
	if (trace.fraction == 1.0f || trace.plane.normal.z < 0.7f ||
		trace.endpos.z < pml.origin.z)
		return;

	// we're currently standing on ground, and the snapped position
	// is a step
	if (pm.groundentity !is null && abs(pml.origin.z - trace.endpos.z) <= STEPSIZE)
		return;

	water_level_t level;
	contents_t type;

	PM_GetWaterLevel(trace.endpos, level, type);

	// the water jump spot will be under water, so we're
	// probably hitting something weird that isn't important
	if (level >= water_level_t::WAIST)
		return;

	// valid waterjump!
	// jump out of water
	pml.velocity = flatforward * 50;
	pml.velocity[2] = 350;

	pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::TIME_WATERJUMP);
	pm.s.pm_time = 2048;
}

/*
===============
PM_FlyMove
===============
*/
void PM_FlyMove(bool doclip)
{
	float	speed, drop, friction, control, newspeed;
	float	currentspeed, addspeed, accelspeed;
	int		i;
	vec3_t	wishvel;
	float	fmove, smove;
	vec3_t	wishdir;
	float	wishspeed;

	pm.s.viewheight = doclip ? 0 : 22;

	// friction

	speed = pml.velocity.length();
	if (speed < 1)
	{
		pml.velocity = vec3_origin;
	}
	else
	{
		drop = 0;

		friction = pm_friction * 1.5f; // extra friction
		control = speed < pm_stopspeed ? pm_stopspeed : speed;
		drop += control * friction * pml.frametime;

		// scale the velocity
		newspeed = speed - drop;
		if (newspeed < 0)
			newspeed = 0;
		newspeed /= speed;

		pml.velocity *= newspeed;
	}

	// accelerate
	fmove = pm.cmd.forwardmove;
	smove = pm.cmd.sidemove;

	pml.forward.normalize();
	pml.right.normalize();

	for (i = 0; i < 3; i++)
		wishvel[i] = pml.forward[i] * fmove + pml.right[i] * smove;

	if ((pm.cmd.buttons & button_t::JUMP) != 0)
		wishvel[2] += (pm_waterspeed * 0.5f);
	if ((pm.cmd.buttons & button_t::CROUCH) != 0)
		wishvel[2] -= (pm_waterspeed * 0.5f);

	wishdir = wishvel;
	wishspeed = wishdir.normalize();

	//
	// clamp to server defined max speed
	//
	if (wishspeed > pm_maxspeed)
	{
		wishvel *= pm_maxspeed / wishspeed;
		wishspeed = pm_maxspeed;
	}

	// Paril: newer clients do this
	wishspeed *= 2;

	currentspeed = pml.velocity.dot(wishdir);
	addspeed = wishspeed - currentspeed;

	if (addspeed > 0)
	{
		accelspeed = pm_accelerate * pml.frametime * wishspeed;
		if (accelspeed > addspeed)
			accelspeed = addspeed;

		for (i = 0; i < 3; i++)
			pml.velocity[i] += accelspeed * wishdir[i];
	}

	if (doclip)
	{
		PM_StepSlideMove();
	}
	else
	{
		// move
		pml.origin += (pml.velocity * pml.frametime);
	}
}

void PM_SetDimensions()
{
	pm.mins[0] = -16;
	pm.mins[1] = -16;

	pm.maxs[0] = 16;
	pm.maxs[1] = 16;

	if (pm.s.pm_type == pmtype_t::GIB)
	{
		pm.mins[2] = 0;
		pm.maxs[2] = 16;
		pm.s.viewheight = 8;
		return;
	}

	pm.mins[2] = -24;

	if ((pm.s.pm_flags & pmflags_t::DUCKED) != 0 || pm.s.pm_type == pmtype_t::DEAD)
	{
		pm.maxs[2] = 4;
		pm.s.viewheight = -2;
	}
	else
	{
		pm.maxs[2] = 32;
		pm.s.viewheight = 22;
	}
}

bool PM_AboveWater()
{
	const vec3_t below = pml.origin - vec3_t(0, 0, 8);

	bool solid_below = pm.trace(pml.origin, pm.mins, pm.maxs, below, pm.player, MASK_SOLID).fraction < 1.0f;

	if (solid_below)
		return false;

	bool water_below = pm.trace(pml.origin, pm.mins, pm.maxs, below, pm.player, contents_t::MASK_WATER).fraction < 1.0f;

	if (water_below)
		return true;

	return false;
}

/*
==============
PM_CheckDuck

Sets mins, maxs, and pm->viewheight
==============
*/
bool PM_CheckDuck()
{
	if (pm.s.pm_type == pmtype_t::GIB)
		return false;

	trace_t trace;
	bool flags_changed = false;

	if (pm.s.pm_type == pmtype_t::DEAD)
	{
		if ((pm.s.pm_flags & pmflags_t::DUCKED) == 0)
		{
			pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::DUCKED);
			flags_changed = true;
		}
	}
	else if (
		(pm.cmd.buttons & button_t::CROUCH) != 0 &&
		(pm.groundentity !is null || (pm.waterlevel <= water_level_t::FEET && !PM_AboveWater())) &&
		(pm.s.pm_flags & pmflags_t::ON_LADDER) == 0 &&
		!PM_CrouchingDisabled(pm_config.physics_flags))
	{ // duck
		if ((pm.s.pm_flags & pmflags_t::DUCKED) == 0)
		{
			// check that duck won't be blocked
			vec3_t check_maxs = { pm.maxs[0], pm.maxs[1], 4 };
			trace = PM_Trace(pml.origin, pm.mins, check_maxs, pml.origin);
			if (!trace.allsolid)
			{
				pm.s.pm_flags = pmflags_t(pm.s.pm_flags | pmflags_t::DUCKED);
				flags_changed = true;
			}
		}
	}
	else
	{ // stand up if possible
		if ((pm.s.pm_flags & pmflags_t::DUCKED) != 0)
		{
			// try to stand up
			vec3_t check_maxs = { pm.maxs[0], pm.maxs[1], 32 };
			trace = PM_Trace(pml.origin, pm.mins, check_maxs, pml.origin);
			if (!trace.allsolid)
			{
				pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~pmflags_t::DUCKED);
				flags_changed = true;
			}
		}
	}

	if (!flags_changed)
		return false;

	PM_SetDimensions();
	return true;
}

/*
==============
PM_DeadMove
==============
*/
void PM_DeadMove()
{
	float forward;

	if (pm.groundentity is null)
		return;

	// extra friction

	forward = pml.velocity.length();
	forward -= 20;
	if (forward <= 0)
	{
		pml.velocity = vec3_origin;
	}
	else
	{
		pml.velocity.normalize();
		pml.velocity *= forward;
	}
}

bool PM_GoodPosition()
{
	if (pm.s.pm_type == pmtype_t::NOCLIP)
		return true;

	trace_t trace = PM_Trace(pm.s.origin, pm.mins, pm.maxs, pm.s.origin);

	return !trace.allsolid;
}

/*
================
PM_SnapPosition

On exit, the origin will have a value that is pre-quantized to the PMove
precision of the network channel and in a valid position.
================
*/
void PM_SnapPosition()
{
	pm.s.velocity = pml.velocity;
	pm.s.origin = pml.origin;

	if (PM_GoodPosition())
		return;

	if (G_FixStuckObject_Generic(pm.s.origin, pm.mins, pm.maxs, PM_Trace_Auto, pm.s.origin) == stuck_result_t::NO_GOOD_POSITION) {
		pm.s.origin = pml.previous_origin;
		return;
	}
}

const array<int> snap_offsets = { 0, -1, 1 };

/*
================
PM_InitialSnapPosition

================
*/
void PM_InitialSnapPosition()
{
	int					x, y, z;
	vec3_t				base;

	base = pm.s.origin;

	for (z = 0; z < 3; z++)
	{
		pm.s.origin[2] = base[2] + snap_offsets[z];
		for (y = 0; y < 3; y++)
		{
			pm.s.origin[1] = base[1] + snap_offsets[y];
			for (x = 0; x < 3; x++)
			{
				pm.s.origin[0] = base[0] + snap_offsets[x];
				if (PM_GoodPosition())
				{
					pml.origin = pm.s.origin;
					pml.previous_origin = pm.s.origin;
					return;
				}
			}
		}
	}
}

/*
================
PM_ClampAngles

================
*/
void PM_ClampAngles()
{
	if ((pm.s.pm_flags & pmflags_t::TIME_TELEPORT) != 0)
	{
		pm.viewangles.yaw = pm.cmd.angles.yaw + pm.s.delta_angles.yaw;
		pm.viewangles.pitch = 0;
		pm.viewangles.roll = 0;
	}
	else
	{
		// circularly clamp the angles with deltas
		pm.viewangles = pm.cmd.angles + pm.s.delta_angles;

		// don't let the player look up or down more than 90 degrees
		if (pm.viewangles.pitch > 89 && pm.viewangles.pitch < 180)
			pm.viewangles.pitch = 89;
		else if (pm.viewangles.pitch < 271 && pm.viewangles.pitch >= 180)
			pm.viewangles.pitch = 271;
	}
	AngleVectors(pm.viewangles, pml.forward, pml.right, pml.up);
}

// [Paril-KEX]
void PM_ScreenEffects()
{
	// add for contents
	vec3_t vieworg = pml.origin + pm.viewoffset + vec3_t(0, 0, float(pm.s.viewheight));
	contents_t contents = pm.pointcontents(vieworg);

	if ((contents & (contents_t::LAVA | contents_t::SLIME | contents_t::WATER)) != 0)
		pm.rdflags = refdef_flags_t(pm.rdflags | refdef_flags_t::UNDERWATER);
	else
		pm.rdflags = refdef_flags_t(pm.rdflags & ~refdef_flags_t::UNDERWATER);

	if ((contents & (contents_t::SOLID | contents_t::LAVA)) != 0)
		G_AddBlend(1.0f, 0.3f, 0.0f, 0.6f, pm.screen_blend, pm.screen_blend);
	else if ((contents & contents_t::SLIME) != 0)
		G_AddBlend(0.0f, 0.1f, 0.05f, 0.6f, pm.screen_blend, pm.screen_blend);
	else if ((contents & contents_t::WATER) != 0)
		G_AddBlend(0.5f, 0.3f, 0.2f, 0.4f, pm.screen_blend, pm.screen_blend);
}

/*
================
Pmove

Can be called by either the server or the client
================
*/
void Pmove(pmove_t @pmove)
{
	@pm = @pmove;

	// clear results
	pm.touch_clear();//.removeRange(0, pm.touch.length());
	pm.viewangles = vec3_origin;
	pm.s.viewheight = 0;
	@pm.groundentity = null;
	pm.watertype = contents_t::NONE;
	pm.waterlevel = water_level_t::NONE;
	pm.screen_blend.x = pm.screen_blend.y = pm.screen_blend.z = pm.screen_blend.w = 0;
	pm.rdflags = refdef_flags_t::NONE;
	pm.jump_sound = false;
	pm.step_clip = false;
	pm.impact_delta = 0;

	// clear all pmove local vars
	pml = pml_t();

	// convert origin and velocity to float values
	pml.origin = pm.s.origin;
	pml.velocity = pm.s.velocity;

	pml.start_velocity = pml.velocity;

	// save old org in case we get stuck
	pml.previous_origin = pm.s.origin;

	pml.frametime = pm.cmd.msec * 0.001f;

	PM_ClampAngles();

	if (pm.s.pm_type == pmtype_t::SPECTATOR || pm.s.pm_type == pmtype_t::NOCLIP)
	{
		pm.s.pm_flags = pmflags_t::NONE;

		if (pm.s.pm_type == pmtype_t::SPECTATOR)
		{
			pm.mins[0] = -8;
			pm.mins[1] = -8;
			pm.maxs[0] = 8;
			pm.maxs[1] = 8;
			pm.mins[2] = -8;
			pm.maxs[2] = 8;
		}

		PM_FlyMove(pm.s.pm_type == pmtype_t::SPECTATOR);
		PM_SnapPosition();
		return;
	}

	if (pm.s.pm_type >= pmtype_t::DEAD)
	{
		pm.cmd.forwardmove = 0;
		pm.cmd.sidemove = 0;
		pm.cmd.buttons = button_t(pm.cmd.buttons & ~(button_t::JUMP | button_t::CROUCH));
	}

	if (pm.s.pm_type == pmtype_t::FREEZE)
		return; // no movement at all

	// set mins, maxs, and viewheight
	PM_SetDimensions();

	// catagorize for ducking
	PM_CatagorizePosition();

	if (pm.snapinitial)
		PM_InitialSnapPosition();

	// set groundentity, watertype, and waterlevel
	if (PM_CheckDuck())
		PM_CatagorizePosition();

	if (pm.s.pm_type == pmtype_t::DEAD)
		PM_DeadMove();

	PM_CheckSpecialMovement();

	// drop timing counter
	if (pm.s.pm_time != 0)
	{
		if (pm.cmd.msec >= pm.s.pm_time)
		{
			pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~(pmflags_t::TIME_WATERJUMP | pmflags_t::TIME_LAND | pmflags_t::TIME_TELEPORT | pmflags_t::TIME_TRICK));
			pm.s.pm_time = 0;
		}
		else
			pm.s.pm_time -= pm.cmd.msec;
	}

	if ((pm.s.pm_flags & pmflags_t::TIME_TELEPORT) != 0)
	{ // teleport pause stays exactly in place
	}
	else if ((pm.s.pm_flags & pmflags_t::TIME_WATERJUMP) != 0)
	{ // waterjump has no control, but falls
		pml.velocity[2] -= pm.s.gravity * pml.frametime;
		if (pml.velocity[2] < 0)
		{ // cancel as soon as we are falling down again
			pm.s.pm_flags = pmflags_t(pm.s.pm_flags & ~(pmflags_t::TIME_WATERJUMP | pmflags_t::TIME_LAND | pmflags_t::TIME_TELEPORT | pmflags_t::TIME_TRICK));
			pm.s.pm_time = 0;
		}

		PM_StepSlideMove();
	}
	else
	{
		PM_CheckJump();

		PM_Friction();

		if (pm.waterlevel >= water_level_t::WAIST)
			PM_WaterMove();
		else
		{
			vec3_t angles;

			angles = pm.viewangles;
			if (angles.pitch > 180)
				angles.pitch = angles.pitch - 360;
			angles.pitch /= 3;

			AngleVectors(angles, pml.forward, pml.right, pml.up);

			PM_AirMove();
		}
	}

	// set groundentity, watertype, and waterlevel for final spot
	PM_CatagorizePosition();

	// trick jump
	if ((pm.s.pm_flags & pmflags_t::TIME_TRICK) != 0)
		PM_CheckJump();

	// [Paril-KEX]
	PM_ScreenEffects();

	PM_SnapPosition();
}
