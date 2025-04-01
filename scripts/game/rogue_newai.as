enum blocked_jump_result_t
{
	NO_JUMP,
	JUMP_TURN,
	JUMP_JUMP_UP,
	JUMP_JUMP_DOWN
};

// blocked_checkplat
//	dist: how far they are trying to walk.
bool blocked_checkplat(ASEntity &self, float dist)
{
	int		 playerPosition;
	trace_t	 trace;
	vec3_t	 pt1, pt2;
	vec3_t	 forward;
	ASEntity @plat;

	if (self.enemy is null)
		return false;

	// check player's relative altitude
	if (self.enemy.e.absmin[2] >= self.e.absmax[2])
		playerPosition = 1;
	else if (self.enemy.e.absmax[2] <= self.e.absmin[2])
		playerPosition = -1;
	else
		playerPosition = 0;

	// if we're close to the same position, don't bother trying plats.
	if (playerPosition == 0)
		return false;

	@plat = null;

	// see if we're already standing on a plat.
	if (self.groundentity !is null && self.groundentity !is world)
	{
		if (self.groundentity.classname.findFirst("func_plat") == 0)
			@plat = self.groundentity;
	}

	// if we're not, check to see if we'll step onto one with this move
	if (plat is null)
	{
		AngleVectors(self.e.s.angles, forward);
		pt1 = self.e.s.origin + (forward * dist);
		pt2 = pt1;
		pt2[2] -= 384;

		trace = gi_traceline(pt1, pt2, self.e, contents_t::MASK_MONSTERSOLID);
		if (trace.fraction < 1 && !trace.allsolid && !trace.startsolid)
		{
			if (entities[trace.ent.s.number].classname.findFirst("func_plat") == 0)
			{
				@plat = entities[trace.ent.s.number];
			}
		}
	}

	// if we've found a plat, trigger it.
	if (plat !is null && plat.use !is null)
	{
		if (playerPosition == 1)
		{
			if ((self.groundentity is plat && plat.moveinfo.state == move_state_t::BOTTOM) ||
				(self.groundentity !is plat && plat.moveinfo.state == move_state_t::TOP))
			{
				plat.use(plat, self, self);
				return true;
			}
		}
		else if (playerPosition == -1)
		{
			if ((self.groundentity is plat && plat.moveinfo.state == move_state_t::TOP) ||
				(self.groundentity !is plat && plat.moveinfo.state == move_state_t::BOTTOM))
			{
				plat.use(plat, self, self);
				return true;
			}
		}
	}

	return false;
}

//*******************
// JUMPING AIDS
//*******************

void monster_jump_start(ASEntity &self)
{
	monster_done_dodge(self);

	self.monsterinfo.jump_time = level.time + time_sec(3);
}

bool monster_jump_finished(ASEntity &self)
{
	// if we lost our forward velocity, give us more
	vec3_t forward;

	AngleVectors(self.e.s.angles, forward);

	vec3_t forward_velocity = self.velocity.scaled(forward);

	if (forward_velocity.length() < 150.0f)
	{
		float z_velocity = self.velocity.z;
		self.velocity = forward * 150.0f;
		self.velocity.z = z_velocity;
	}

	return self.monsterinfo.jump_time < level.time;
}

// blocked_checkjump
//	dist: how far they are trying to walk.
//  self.monsterinfo.drop_height/self.monsterinfo.jump_height: how far they'll ok a jump for. set to 0 to disable that direction.
blocked_jump_result_t blocked_checkjump(ASEntity &self, float dist) nodiscard
{
	// can't jump even if we physically can
	if (!self.monsterinfo.can_jump)
		return blocked_jump_result_t::NO_JUMP;
	// no enemy to path to
	else if (self.enemy is null)
		return blocked_jump_result_t::NO_JUMP;

	// we just jumped recently, don't try again
	if (self.monsterinfo.jump_time > level.time)
		return blocked_jump_result_t::NO_JUMP;

	// if we're pathing, the nodes will ensure we can reach the destination.
	if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) != 0)
	{
		if (self.monsterinfo.nav_path.returnCode != PathReturnCode::TraversalPending)
			return blocked_jump_result_t::NO_JUMP;

		float yaw = vectoyaw((self.monsterinfo.nav_path.firstMovePoint - self.monsterinfo.nav_path.secondMovePoint).normalized());
		self.ideal_yaw = yaw + 180;
		if (self.ideal_yaw > 360)
			self.ideal_yaw -= 360;

		if (!FacingIdeal(self))
		{
			M_ChangeYaw(self);
			return blocked_jump_result_t::JUMP_TURN;
		}

		monster_jump_start(self);

		if (self.monsterinfo.nav_path.secondMovePoint.z > self.monsterinfo.nav_path.firstMovePoint.z)
			return blocked_jump_result_t::JUMP_JUMP_UP;
		else
			return blocked_jump_result_t::JUMP_JUMP_DOWN;
	}

	int		playerPosition;
	trace_t trace;
	vec3_t	pt1, pt2;
	vec3_t	forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);

	if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) != 0)
	{
		if (self.monsterinfo.nav_path.secondMovePoint[2] > (self.e.absmin[2] + STEPSIZE))
			playerPosition = 1;
		else if (self.monsterinfo.nav_path.secondMovePoint[2] < (self.e.absmin[2] - STEPSIZE))
			playerPosition = -1;
		else
			playerPosition = 0;
	}
	else
	{
		if (self.enemy.e.absmin[2] > (self.e.absmin[2] + STEPSIZE))
			playerPosition = 1;
		else if (self.enemy.e.absmin[2] < (self.e.absmin[2] - STEPSIZE))
			playerPosition = -1;
		else
			playerPosition = 0;
	}

	if (playerPosition == -1 && self.monsterinfo.drop_height != 0)
	{
		// check to make sure we can even get to the spot we're going to "fall" from
		pt1 = self.e.s.origin + (forward * 48);
		trace = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, pt1, self.e, contents_t::MASK_MONSTERSOLID);
		if (trace.fraction < 1)
			return blocked_jump_result_t::NO_JUMP;

		pt2 = pt1;
		pt2[2] = self.e.absmin[2] - self.monsterinfo.drop_height - 1;

		trace = gi_traceline(pt1, pt2, self.e, contents_t(contents_t::MASK_MONSTERSOLID | contents_t::MASK_WATER));
		if (trace.fraction < 1 && !trace.allsolid && !trace.startsolid)
		{
			// check how deep the water is
			if ((trace.contents & contents_t::WATER) != 0)
			{
				trace_t deep = gi_traceline(trace.endpos, pt2, self.e, contents_t::MASK_MONSTERSOLID);

				water_level_t waterlevel;
				contents_t watertype;
				M_CatagorizePosition(self, deep.endpos, waterlevel, watertype);

				if (waterlevel > water_level_t::WAIST)
					return blocked_jump_result_t::NO_JUMP;
			}

			if ((self.e.absmin[2] - trace.endpos[2]) >= 24 && (trace.contents & (contents_t::MASK_SOLID | contents_t::WATER)) != 0)
			{
				if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) != 0)
				{
					if ((self.monsterinfo.nav_path.secondMovePoint[2] - trace.endpos[2]) > 32)
						return blocked_jump_result_t::NO_JUMP;
				}
				else
				{
					if ((self.enemy.e.absmin[2] - trace.endpos[2]) > 32)
						return blocked_jump_result_t::NO_JUMP;

					if (trace.plane.normal[2] < 0.9f)
						return blocked_jump_result_t::NO_JUMP;
				}

				monster_jump_start(self);

				return blocked_jump_result_t::JUMP_JUMP_DOWN;
			}
		}
	}
	else if (playerPosition == 1 && self.monsterinfo.jump_height != 0)
	{
		pt1 = self.e.s.origin + (forward * 48);
		pt2 = pt1;
		pt1[2] = self.e.absmax[2] + self.monsterinfo.jump_height;

		trace = gi_traceline(pt1, pt2, self.e, contents_t(contents_t::MASK_MONSTERSOLID | contents_t::MASK_WATER));
		if (trace.fraction < 1 && !trace.allsolid && !trace.startsolid)
		{
			if ((trace.endpos[2] - self.e.absmin[2]) <= self.monsterinfo.jump_height && (trace.contents & (contents_t::MASK_SOLID | contents_t::WATER)) != 0)
			{
				face_wall(self);

				monster_jump_start(self);

				return blocked_jump_result_t::JUMP_JUMP_UP;
			}
		}
	}

	return blocked_jump_result_t::NO_JUMP;
}

// *****************************
//	MISCELLANEOUS STUFF
// *****************************

// PMM - inback
// use to see if opponent is behind you (not to side)
// if it looks a lot like infront, well, there's a reason

bool inback(ASEntity &self, ASEntity &other)
{
	vec3_t vec;
	float  dot;
	vec3_t forward;

	AngleVectors(self.e.s.angles, forward);
	vec = other.e.s.origin - self.e.s.origin;
	vec.normalize();
	dot = vec.dot(forward);
	return dot < -0.3f;
}

bool below(ASEntity &self, ASEntity &other)
{
	vec3_t vec;
	float  dot;

	vec = other.e.s.origin - self.e.s.origin;
	vec.normalize();
	dot = vec.dot({ 0, 0, -1 });

	if (dot > 0.95f) // 18 degree arc below
		return true;
	return false;
}

float realrange(ASEntity &self, ASEntity &other)
{
	vec3_t dir;

	dir = self.e.s.origin - other.e.s.origin;

	return dir.length();
}

bool face_wall(ASEntity &self)
{
	vec3_t	pt;
	vec3_t	forward;
	vec3_t	ang;
	trace_t tr;

	AngleVectors(self.e.s.angles, forward);
	pt = self.e.s.origin + (forward * 64);
	tr = gi_traceline(self.e.s.origin, pt, self.e, contents_t::MASK_MONSTERSOLID);
	if (tr.fraction < 1 && !tr.allsolid && !tr.startsolid)
	{
		ang = vectoangles(tr.plane.normal);
		self.ideal_yaw = ang.yaw + 180;
		if (self.ideal_yaw > 360)
			self.ideal_yaw -= 360;

		M_ChangeYaw(self);
		return true;
	}

	return false;
}


//
// Monster "Bad" Areas
//

void badarea_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
}

ASEntity @SpawnBadArea(const vec3_t &in mins, const vec3_t &in maxs, gtime_t lifespan, ASEntity @owner)
{
	ASEntity @badarea;
	vec3_t	 origin;

	origin = mins + maxs;
	origin *= 0.5f;

	@badarea = G_Spawn();
	badarea.e.s.origin = origin;

	badarea.e.maxs = maxs - origin;
	badarea.e.mins = mins - origin;
	@badarea.touch = badarea_touch;
	badarea.movetype = movetype_t::NONE;
	badarea.e.solid = solid_t::TRIGGER;
	badarea.classname = "bad_area";
	gi_linkentity(badarea.e);

	if (lifespan)
	{
		@badarea.think = G_FreeEdict;
		badarea.nextthink = level.time + lifespan;
	}
	if (owner !is null)
	{
		@badarea.owner = owner;
	}

	return badarea;
}

BoxEdictsResult_t CheckForBadArea_BoxFilter(edict_t @hit_handle, any @const data_v)
{
    ASEntity @hit = entities[hit_handle.s.number];

	if (hit.touch is badarea_touch)
	{
		data_v.store(@hit);
		return BoxEdictsResult_t::End;
	}

	return BoxEdictsResult_t::Skip;
}

// CheckForBadArea
//		This is a customized version of G_TouchTriggers that will check
//		for bad area triggers and return them if they're touched.
ASEntity @CheckForBadArea(ASEntity &ent)
{
	vec3_t	 mins, maxs;

	mins = ent.e.s.origin + ent.e.mins;
	maxs = ent.e.s.origin + ent.e.maxs;

    any hit_v;

	gi_BoxEdicts(mins, maxs, null, 0, solidity_area_t::TRIGGERS, CheckForBadArea_BoxFilter, @hit_v, false);

    ASEntity @hit = null;

    hit_v.retrieve(@hit);

	return hit;
}

bool MarkTeslaArea(ASEntity &self, ASEntity &tesla)
{
	vec3_t	 mins, maxs;
	ASEntity @e;
	ASEntity @tail;
	ASEntity @area;

	@area = null;

	// make sure this tesla doesn't have a bad area around it already...
	@e = tesla.teamchain;
	@tail = tesla;
	while (e !is null)
	{
		@tail = tail.teamchain;
		if (e.classname == "bad_area")
			return false;

		@e = e.teamchain;
	}

	// see if we can grab the trigger directly
	if (tesla.teamchain !is null && tesla.teamchain.e.inuse)
	{
		ASEntity @trigger;

		@trigger = tesla.teamchain;

		mins = trigger.e.absmin;
		maxs = trigger.e.absmax;

		if (tesla.air_finished)
			@area = SpawnBadArea(mins, maxs, tesla.air_finished, tesla);
		else
			@area = SpawnBadArea(mins, maxs, tesla.nextthink, tesla);
	}
	// otherwise we just guess at how long it'll last.
	else
	{
		mins = vec3_t(-TESLA_DAMAGE_RADIUS, -TESLA_DAMAGE_RADIUS, tesla.e.mins[2]);
		maxs = vec3_t(TESLA_DAMAGE_RADIUS, TESLA_DAMAGE_RADIUS, TESLA_DAMAGE_RADIUS);

		@area = SpawnBadArea(mins, maxs, time_sec(30), tesla);
	}

	// if we spawned a bad area, then link it to the tesla
	if (area !is null)
		@tail.teamchain = area;

	return true;
}

// predictive calculator
// target is who you want to shoot
// start is where the shot comes from
// bolt_speed is how fast the shot is (or 0 for hitscan)
// eye_height is a boolean to say whether or not to adjust to targets eye_height
// offset is how much time to miss by
// aimdir is the resulting aim direction (optional)
// aimpoint is the resulting aimpoint (optional)
void PredictAim(ASEntity &self, ASEntity @target, const vec3_t &in start, float bolt_speed, bool eye_height, float offset, vec3_t &out aimdir, vec3_t &out aimpoint /* = void*/)
{
	vec3_t dir, vec;
	float  dist, time;

    aimdir = aimpoint = vec3_origin;

	if (target is null || !target.e.inuse)
	{
		return;
	}

	dir = target.e.s.origin - start;
	if (eye_height)
		dir[2] += target.viewheight;
	dist = dir.length();

	// [Paril-KEX] if our current attempt is blocked, try the opposite one
	trace_t tr = gi_traceline(start, start + dir, self.e, contents_t::MASK_PROJECTILE);

	if (tr.ent !is target.e)
	{
		eye_height = !eye_height;
		dir = target.e.s.origin - start;
		if (eye_height)
			dir[2] += target.viewheight;
		dist = dir.length();
	}

	if (bolt_speed != 0)
		time = dist / bolt_speed;
	else
		time = 0;

	vec = target.e.s.origin + (target.velocity * (time - offset));

	// went backwards...
	if (dir.normalized().dot((vec - start).normalized()) < 0)
		vec = target.e.s.origin;
	else
	{
		// if the shot is going to impact a nearby wall from our prediction, just fire it straight.	
		if (gi_traceline(start, vec, null, contents_t::MASK_SOLID).fraction < 0.9f)
			vec = target.e.s.origin;
	}

	if (eye_height)
		vec[2] += target.viewheight;

	aimdir = (vec - start).normalized();
	aimpoint = vec;
}

const array<float> calculate_pitch_pitches = { -80.f, -70.f, -60.f, -50.f, -40.f, -30.f, -20.f, -10.f, -5.f };
const float calculate_pitch_sim_time = 0.1f;

// [Paril-KEX] find a pitch that will at some point land on or near the player.
// very approximate. aim will be adjusted to the correct aim vector.
bool M_CalculatePitchToFire(ASEntity &self, const vec3_t &in target, const vec3_t &in start, vec3_t &aim,
                            float speed, float time_remaining, bool mortar, bool destroy_on_touch = false)
{
	float best_pitch = 0.f;
	float best_dist = float_limits::infinity;

	vec3_t pitched_aim = vectoangles(aim);

	foreach (auto pitch : calculate_pitch_pitches)
	{
		if (mortar && pitch >= -30.f)
			break;

		pitched_aim.pitch = pitch;
		vec3_t fwd;
        AngleVectors(pitched_aim, fwd);

		vec3_t velocity = fwd * speed;
		vec3_t origin = start;

		float t = time_remaining;

		while (t > 0.f)
		{
			velocity += vec3_t(0, 0, -1) * level.gravity * calculate_pitch_sim_time;

			vec3_t end = origin + (velocity * calculate_pitch_sim_time);
			trace_t tr = gi_traceline(origin, end, null, contents_t::MASK_SHOT);

			origin = tr.endpos;

			if (tr.fraction < 1.0f)
			{
				if ((tr.surface.flags & surfflags_t::SKY) != 0)
					break;

				origin += tr.plane.normal;
				velocity = ClipVelocity(velocity, tr.plane.normal, 1.6f);

				float dist = (origin - target).lengthSquared();

				if (tr.ent is self.enemy.e || tr.ent.client !is null || (tr.plane.normal.z >= 0.7f && dist < (128.f * 128.f) && dist < best_dist))
				{
					best_pitch = pitch;
					best_dist = dist;
				}

				if (destroy_on_touch || (tr.contents & (contents_t::MONSTER | contents_t::PLAYER | contents_t::DEADMONSTER)) != 0)
					break;
			}

			t -= calculate_pitch_sim_time;
		}
	}

	if (!isinf(best_dist))
	{
		pitched_aim.pitch = best_pitch;
        AngleVectors(pitched_aim, aim);
		return true;
	}

	return false;
}

// [Paril-KEX]
bool M_AdjustBlindfireTarget(ASEntity &self, const vec3_t &in start, const vec3_t &in target, const vec3_t &in right, vec3_t &out out_dir)
{
	trace_t trace = gi_traceline(start, target, self.e, contents_t::MASK_PROJECTILE);

	// blindfire has different fail criteria for the trace
	if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
	{
		out_dir = target - start;
		out_dir.normalize();
		return true;
	}

	// try shifting the target to the left a little (to help counter large offset)
	vec3_t left_target = target + (right * -20);
	trace = gi_traceline(start, left_target, self.e, contents_t::MASK_PROJECTILE);

	if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
	{
		out_dir = left_target - start;
		out_dir.normalize();
		return true;
	}

	// ok, that failed.  try to the right
	vec3_t right_target = target + (right * 20);
	trace = gi_traceline(start, right_target, self.e, contents_t::MASK_PROJECTILE);
	if (!(trace.startsolid || trace.allsolid || (trace.fraction < 0.5f)))
	{
		out_dir = right_target - start;
		out_dir.normalize();
		return true;
	}

    out_dir = vec3_origin;

	return false;
}

// [Paril-KEX] returns true if the skill check passes
bool G_SkillCheck(const array<float> &in skills)
{
	if (skills.length() < uint(skill.integer))
		return true;

	float skill_switch = skills[skill.integer];
	return skill_switch == 1.0f ? true : frandom() < skill_switch;
}

// ROGUE
// this determines how long to wait after a duck to duck again.
// if we finish a duck-up, this gets cut in half.
const gtime_t DUCK_INTERVAL = time_ms(5000);
// ROGUE

//
// New dodge code
//
void M_MonsterDodge(ASEntity &self, ASEntity &attacker, gtime_t eta, const trace_t &in tr, bool gravity, bool not_trace)
{
	float r = frandom();
	float height;
	bool  ducker = false, dodger = false;

	// this needs to be here since this can be called after the monster has "died"
	if (self.health < 1)
		return;

	if ((self.monsterinfo.duck !is null) && (self.monsterinfo.unduck !is null) && !gravity)
		ducker = true;
	if ((self.monsterinfo.sidestep !is null) && (self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0)
		dodger = true;

	if ((!ducker) && (!dodger))
		return;

	if (self.enemy is null)
	{
		@self.enemy = attacker;
		FoundTarget(self);
	}

	// PMM - don't bother if it's going to hit anyway; fix for weird in-your-face etas (I was
	// seeing numbers like 13 and 14)
	if ((eta < FRAME_TIME_MS) || (eta > time_sec(2.5)))
		return;

	// skill level determination..
	if (r > 0.50f)
		return;

	if (ducker && !not_trace)
	{
		height = self.e.absmax[2] - 32 - 1; // the -1 is because the absmax is s.origin + maxs + 1

		if ((!dodger) && ((tr.endpos[2] <= height) || (self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0))
			return;
	}
	else
		height = self.e.absmax[2];

	if (dodger)
	{
		// if we're already dodging, just finish the sequence, i.e. don't do anything else
		if ((self.monsterinfo.aiflags & ai_flags_t::DODGING) != 0)
			return;

		// if we're ducking already, or the shot is at our knees
		if ((!ducker || not_trace || tr.endpos[2] <= height) || (self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		{
			// on Easy & Normal, don't sidestep as often (25% on Easy, 50% on Normal)
			if (!G_SkillCheck({ 0.25f, 0.50f, 1.0f, 1.0f }))
			{
				self.monsterinfo.dodge_time = level.time + random_time(time_sec(0.8), time_sec(1.4));
				return;
			}
			else
			{
				if (!not_trace)
				{
					vec3_t right, diff;

					AngleVectors(self.e.s.angles, right: right);
					diff = tr.endpos - self.e.s.origin;

					if (right.dot(diff) < 0)
						self.monsterinfo.lefty = false;
					else
						self.monsterinfo.lefty = true;
				}
				else
					self.monsterinfo.lefty = brandom();

				// call the monster specific code here
				if (self.monsterinfo.sidestep(self))
				{
					// if we are currently ducked, unduck
					if ((ducker) && (self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
						self.monsterinfo.unduck(self);

					self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DODGING);
					self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;

					self.monsterinfo.dodge_time = level.time + random_time(time_sec(0.4), time_sec(2.0));
				}
				return;
			}
		}
	}

	// [Paril-KEX] we don't need to duck until projectiles are going to hit us very
	// soon.
	if (ducker && !not_trace && eta < time_sec(0.5))
	{
		if (self.monsterinfo.next_duck_time > level.time)
			return;

		monster_done_dodge(self);

		if (self.monsterinfo.duck(self, eta))
		{
			// if duck didn't set us yet, do it now
			if (self.monsterinfo.duck_wait_time < level.time)
				self.monsterinfo.duck_wait_time = level.time + eta;

			monster_duck_down(self);

			// on Easy & Normal mode, duck longer
			if (skill.integer == 0)
				self.monsterinfo.duck_wait_time += random_time(time_ms(500), time_ms(1000));
			else if (skill.integer == 1)
				self.monsterinfo.duck_wait_time += random_time(time_ms(100), time_ms(350));
		}

		self.monsterinfo.dodge_time = level.time + random_time(time_sec(0.2), time_sec(0.7));
	}
}

void monster_duck_down(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::DUCKED);

	self.e.maxs[2] = self.monsterinfo.base_height - 32;
	self.takedamage = true;
	self.monsterinfo.next_duck_time = level.time + DUCK_INTERVAL;
	gi_linkentity(self.e);
}

void monster_duck_hold(ASEntity &self)
{
	if (level.time >= self.monsterinfo.duck_wait_time)
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);
	else
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::HOLD_FRAME);
}

void monster_duck_up(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) == 0)
		return;

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DUCKED);
	self.e.maxs[2] = self.monsterinfo.base_height;
	self.takedamage = true;
	// we finished a duck-up successfully, so cut the time remaining in half
	if (self.monsterinfo.next_duck_time > level.time)
		self.monsterinfo.next_duck_time = level.time + ((self.monsterinfo.next_duck_time - level.time) / 2);
	gi_linkentity(self.e);
}

//=========================
//=========================
bool has_valid_enemy(ASEntity &self)
{
	if (self.enemy is null)
		return false;

	if (!self.enemy.e.inuse)
		return false;

	if (self.enemy.health < 1)
		return false;

	return true;
}

void TargetTesla(ASEntity &self, ASEntity &tesla)
{
	// PMM - medic bails on healing things
	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		if (self.enemy !is null)
			cleanupHealTarget(self.enemy);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
	}

	// store the player enemy in case we lose track of him.
	if (self.enemy !is null && self.enemy.client !is null)
		@self.monsterinfo.last_player_enemy = self.enemy;

	if (self.enemy !is tesla)
	{
		@self.oldenemy = self.enemy;
		@self.enemy = tesla;
		if (self.monsterinfo.attack !is null)
		{
			if (self.health <= 0)
				return;

			self.monsterinfo.attack(self);
		}
		else
			FoundTarget(self);
	}
}

// this returns a randomly selected coop player who is visible to self
// returns nullptr if bad
ASEntity @PickCoopTarget(ASEntity &self)
{
	array<ASEntity @> targets;
	int		          targetID;
	ASEntity          @ent;

	// if we're not in coop, this is a noop
	if (coop.integer == 0)
		return null;

	for (uint32 player = 0; player < max_clients; player++)
	{
		@ent = players[player];
		if (!ent.e.inuse)
			continue;
		if (ent.client is null)
			continue;
		if (visible(self, ent))
			targets.push_back(ent);
	}

	if (targets.length() == 0)
		return null;

	// get a number from 0 to (num_targets-1)
	targetID = irandom(targets.length());

	return targets[targetID];
}

void BossExplode_think(ASEntity &self)
{
	// owner gone or changed
	if (!self.owner.e.inuse || self.owner.e.s.modelindex != self.style || self.count != self.owner.spawn_count)
	{
		G_FreeEdict(self);
		return;
	}

	vec3_t org = self.owner.e.s.origin + self.owner.e.mins;
	
	org.x += frandom() * self.owner.e.size.x;
	org.y += frandom() * self.owner.e.size.y;
	org.z += frandom() * self.owner.e.size.z;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte((self.viewheight % 3) == 0 ? temp_event_t::EXPLOSION1 : temp_event_t::EXPLOSION1_NL);
	gi_WritePosition(org);
	gi_multicast(org, multicast_t::PVS, false);

	self.viewheight++;

	self.nextthink = level.time + random_time(time_ms(50), time_ms(200));
}

void BossExplode(ASEntity &self)
{
	// no blowy on deady
	if ((self.spawnflags & spawnflags::monsters::DEAD) != 0)
		return;

	ASEntity @exploder = G_Spawn();
	@exploder.owner = self;
	exploder.count = self.spawn_count;
	exploder.style = self.e.s.modelindex;
	@exploder.think = BossExplode_think;
	exploder.nextthink = level.time + random_time(time_ms(75), time_ms(250));
	exploder.viewheight = 0;
}