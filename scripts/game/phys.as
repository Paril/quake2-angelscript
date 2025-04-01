/*
=============
SV_RunThink

Runs thinking code for this frame if necessary
=============
*/
bool SV_RunThink(ASEntity &ent)
{
	gtime_t thinktime = ent.nextthink;
	if (thinktime <= time_zero)
		return true;
	if (thinktime > level.time)
		return true;

	ent.nextthink = time_zero;
	if (ent.think is null)
		gi_Com_Error("nullptr ent->think");
	ent.think(ent);

	return false;
}

/*
==================
G_Impact

Two entities have touched, so run their touch functions
==================
*/
void G_Impact(ASEntity &e1, const trace_t &in trace)
{
	ASEntity @e2 = @entities[trace.ent.s.number];

	if (e1.touch !is null && (e1.e.solid != solid_t::NOT || (e1.flags & ent_flags_t::ALWAYS_TOUCH) != 0))
		e1.touch(e1, e2, trace, false);

    if (e2.touch !is null && (e2.e.solid != solid_t::NOT || (e2.flags & ent_flags_t::ALWAYS_TOUCH) != 0))
        e2.touch(e2, e1, trace, true);
}

namespace internal
{
    ASEntity @flymove_trace_passent;
    contents_t flymove_trace_mask;
}

trace_t SV_FlyMove_Trace(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end)
{
    return gi_trace(start, mins, maxs, end, internal::flymove_trace_passent.e, internal::flymove_trace_mask);
}

/*
============
SV_FlyMove

The basic solid body movement clip that slides along multiple planes
============
*/
void SV_FlyMove(ASEntity &ent, float time, contents_t mask)
{
	@ent.groundentity = null;

    @internal::flymove_trace_passent = ent;
    internal::flymove_trace_mask = mask;
    pmove_t pm;
    // AS_TODO
	PM_StepSlideMove_Generic(ent.e.s.origin, ent.velocity, time, ent.e.mins, ent.e.maxs, pm/*touch*/, false, SV_FlyMove_Trace, ent.e.s.origin, ent.velocity);

	for (uint i = 0; i < pm.touch_length(); i++)
	{
		trace_t trace = pm.touch_get(i);

		if (trace.plane.normal.z > 0.7f)
		{
			@ent.groundentity = entities[trace.ent.s.number];
			ent.groundentity_linkcount = trace.ent.linkcount;
		}

		//
		// run the impact function
		//
		G_Impact(ent, trace);

		// impact func requested velocity kill
		if ((ent.flags & ent_flags_t::KILL_VELOCITY) != 0)
		{
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::KILL_VELOCITY);
			ent.velocity = vec3_origin;
		}
	}
}

/*
============
SV_TestEntityPosition

============
*/
ASEntity @SV_TestEntityPosition(ASEntity &ent)
{
	trace_t	   trace;

	trace = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.e.s.origin, ent.e, G_GetClipMask(ent));

	if (trace.startsolid)
		return world;

	return null;
}

/*
================
SV_CheckVelocity
================
*/
void SV_CheckVelocity(ASEntity &ent)
{
	//
	// bound velocity
	//
	float speed = ent.velocity.length();

	if (speed > sv_maxvelocity.value)
		ent.velocity = (ent.velocity / speed) * sv_maxvelocity.value;
}

/*
============
SV_AddGravity

============
*/
void SV_AddGravity(ASEntity &ent)
{
	if (ent.no_gravity_time > level.time)
		return;

	ent.velocity += ent.gravityVector * (ent.gravity * level.gravity * gi_frame_time_s);
}

/*
===============================================================================

PUSHMOVE

===============================================================================
*/

/*
============
SV_PushEntity

Does not change the entities velocity at all
============
*/
trace_t SV_PushEntity(ASEntity &ent, const vec3_t &in push)
{
	vec3_t start = ent.e.s.origin;
	vec3_t end = start + push;

	trace_t trace = gi_trace(start, ent.e.mins, ent.e.maxs, end, ent.e, G_GetClipMask(ent));
	
	ent.e.s.origin = trace.endpos + (trace.plane.normal * .5f);
	gi_linkentity(ent.e);

	if (trace.fraction != 1.0f || trace.startsolid)
	{
		G_Impact(ent, trace);

		// if the pushed entity went away and the pusher is still there
		if (!trace.ent.inuse && ent.e.inuse)
		{
			// move the pusher back and try again
			ent.e.s.origin = start;
			gi_linkentity(ent.e);
			return SV_PushEntity(ent, push);
		}
	}

	// ================
	// PGM
	// FIXME - is this needed?
	ent.gravity = 1.0;
	// PGM
	// ================

	if (ent.e.inuse)
		G_TouchTriggers(ent);

	return trace;
}

class pushed_t
{
	ASEntity @ent;
	vec3_t	 origin;
	vec3_t	 angles;
	bool	 rotated;
	float	 yaw;

    pushed_t() { }

    pushed_t(ASEntity @ent, bool rotated = false)
    {
        @this.ent = ent;
        this.origin = ent.e.s.origin;
        this.angles = ent.e.s.angles;
		this.rotated = rotated;
		this.yaw = 0;

        if (rotated)
        {
            this.rotated = true;
            this.yaw = ent.client !is null ? float(ent.e.client.ps.pmove.delta_angles.yaw) : ent.e.s.angles.yaw;
        }
    }
};

array<pushed_t> pushed;

ASEntity @obstacle;

/*
============
SV_Push

Objects need to be moved back on a failed push,
otherwise riders would continue to slide.
============
*/
array<edict_t @> sv_push_intersect;

BoxEdictsResult_t SV_Push_BoxFilter(edict_t @check_handle, any @const)
{
    ASEntity @check = entities[check_handle.s.number];

    if (check.movetype == movetype_t::PUSH || check.movetype == movetype_t::STOP || check.movetype == movetype_t::NONE ||
        check.movetype == movetype_t::NOCLIP)
        return BoxEdictsResult_t::Skip;

	return BoxEdictsResult_t::Keep;
}

bool SV_Push(ASEntity &pusher, const vec3_t &in move, const vec3_t &in amove)
{
	ASEntity  @check, block = null;
	vec3_t	  mins, maxs;
	vec3_t	  org, org2, move2, forward, right, up;

	// find the bounding box
	mins = pusher.e.absmin;
	maxs = pusher.e.absmax;

	// we need this for pushing things later
	org = -amove;
	AngleVectors(org, forward, right, up);

	// save the pusher's original position
    pushed.push_back(pushed_t(pusher));

	// move the pusher to it's final position
	pusher.e.s.origin += move;
	pusher.e.s.angles += amove;
	gi_linkentity(pusher.e);

	// no clip mask, so it won't move anything
	if (G_GetClipMask(pusher) == contents_t::NONE)
		return true;

    AddPointToBounds(pusher.e.absmin, mins, maxs);
    AddPointToBounds(pusher.e.absmax, mins, maxs);

	// see if any solid entities are inside the final position
	gi_BoxEdicts(mins, maxs, sv_push_intersect, max_edicts, solidity_area_t::SOLID, SV_Push_BoxFilter, null, false);
	gi_BoxEdicts(mins, maxs, sv_push_intersect, max_edicts, solidity_area_t::TRIGGERS, SV_Push_BoxFilter, null, true);

	foreach (edict_t @check_e : sv_push_intersect)
	{
        @check = entities[check_e.s.number];

		// if the entity is standing on the pusher, it will definitely be moved
		if (check.groundentity !is pusher)
		{
			// see if the ent's bbox is inside the pusher's final position
			if (SV_TestEntityPosition(check) is null)
				continue;
		}

		if ((pusher.movetype == movetype_t::PUSH) || (check.groundentity is pusher))
		{
			// move this entity
            pushed.push_back(pushed_t(check, amove.yaw != 0));

			vec3_t old_position = check.e.s.origin;

			// try moving the contacted entity
			check.e.s.origin += move;
			if (check.client !is null)
			{
				// Paril: disabled because in vanilla delta_angles are never
				// lerped. delta_angles can probably be lerped as long as event
				// isn't EV_PLAYER_TELEPORT or a new RDF flag is set
				// check->client->ps.pmove.delta_angles.yaw += amove.yaw;
			}
			else
				check.e.s.angles.yaw += amove.yaw;

			// figure movement due to the pusher's amove
			org = check.e.s.origin - pusher.e.s.origin;
			org2.x = org.dot(forward);
			org2.y = -(org.dot(right));
			org2.z = org.dot(up);
			move2 = org2 - org;
			check.e.s.origin += move2;

			// may have pushed them off an edge
			if (check.groundentity !is pusher)
				@check.groundentity = null;

			@block = SV_TestEntityPosition(check);

			// [Paril-KEX] this is a bit of a hack; allow dead player skulls
			// to be a blocker because otherwise elevators/doors get stuck
			if (block !is null && check.client !is null && !check.takedamage)
			{
				check.e.s.origin = old_position;
				@block = null;
			}

			if (block is null)
			{ // pushed ok
				gi_linkentity(check.e);
				// impact?
				continue;
			}

			// if it is ok to leave in the old position, do it.
			// this is only relevent for riding entities, not pushed
			check.e.s.origin = old_position;
			@block = SV_TestEntityPosition(check);
			if (block is null)
			{
                pushed.pop_back();
				continue;
			}
		}

		// save off the obstacle so we can call the block function
		@obstacle = check;

		// move back any entities we already moved
		// go backwards, so if the same entity was pushed
		// twice, it goes back to the original position
		for (int64 pi = pushed.length() - 1; pi >= 0; pi--)
		{
            pushed_t @p = pushed[pi];
			p.ent.e.s.origin = p.origin;
			p.ent.e.s.angles = p.angles;
			if (p.rotated)
			{
				//if (p->ent->client)
				//	p->ent->client->ps.pmove.delta_angles.yaw = p->yaw;
				//else
					p.ent.e.s.angles.yaw = p.yaw;
			}
			gi_linkentity(p.ent.e);
		}
		return false;
	}

	// FIXME: is there a better way to handle this?
	//  see if anything we moved has touched a trigger
	for (int64 pi = pushed.length() - 1; pi >= 0; pi--)
		G_TouchTriggers(pushed[pi].ent);

	return true;
}

/*
================
SV_Physics_Pusher

Bmodel objects don't interact with each other, but
push all box objects
================
*/
void SV_Physics_Pusher(ASEntity &ent)
{
	vec3_t	 move, amove;
	ASEntity @part;

	// if not a team captain, so movement will be handled elsewhere
	if ((ent.flags & ent_flags_t::TEAMSLAVE) != 0)
		return;

	// make sure all team slaves can move before commiting
	// any moves or calling any think functions
	// if the move is blocked, all moved objects will be backed out
    while (true)
    {
        pushed.resize(0);

        for (@part = ent; part !is null; @part = part.teamchain)
        {
            if (bool(part.velocity) || bool(part.avelocity))
            { // object is moving
                move = part.velocity * gi_frame_time_s;
                amove = part.avelocity * gi_frame_time_s;

                if (!SV_Push(part, move, amove))
                    break; // move was blocked
            }
        }

        if (part !is null)
        {
            // if the pusher has a "blocked" function, call it
            // otherwise, just stay in place until the obstacle is gone
            if (part.moveinfo.blocked !is null)
                part.moveinfo.blocked(part, obstacle);

            if (!obstacle.e.inuse)
                continue;
        }
        else
        {
            // the move succeeded, so call all think functions
            for (@part = ent; part !is null; @part = part.teamchain)
            {
                // prevent entities that are on trains that have gone away from thinking!
                if (part.e.inuse)
                    SV_RunThink(part);
            }
        }

        break;
    }
}

//==================================================================

/*
=============
SV_Physics_None

Non moving objects can only think
=============
*/
void SV_Physics_None(ASEntity &ent)
{
	// regular thinking
	SV_RunThink(ent);
}

/*
=============
SV_Physics_Noclip

A moving object that doesn't obey physics
=============
*/
void SV_Physics_Noclip(ASEntity &ent)
{
	// regular thinking
	if (!SV_RunThink(ent) || !ent.e.inuse)
		return;

	ent.e.s.angles += (ent.avelocity * gi_frame_time_s);
	ent.e.s.origin += (ent.velocity * gi_frame_time_s);

	gi_linkentity(ent.e);
}

/*
==============================================================================

TOSS / BOUNCE

==============================================================================
*/

/*
=============
projectile_infront

returns 1 if the entity is in front (in sight) of self
=============
*/
bool projectile_infront(ASEntity &self, ASEntity &other)
{
	vec3_t vec;
	float  dot;
	vec3_t forward;

	AngleVectors(self.e.s.angles, forward);
	vec = other.e.s.origin - self.e.s.origin;
	vec.normalize();
	dot = vec.dot(forward);
	return dot > 0.35f;
}

// [Paril-KEX] active checking for projectiles to dodge
void SV_CheckProjectileDodge(ASEntity &ent)
{
    // find a monster
    trace_t tr = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.e.s.origin + ent.velocity, ent.e, ent.e.clipmask);

    if (tr.fraction == 1.0f)
        return;
    else if ((tr.ent.svflags & svflags_t::MONSTER) == 0)
        return;

    ASEntity @hit = entities[tr.ent.s.number];

    if (hit.deadflag)
        return;
	// we recently made a valid dodge, don't try again for a bit
	else if (hit.monsterinfo.dodge_time > level.time)
		return;
    // no dodge
    else if (hit.monsterinfo.dodge is null)
        return;
    else if (!projectile_infront(hit, ent))
        return;

	vec3_t v = tr.endpos - ent.e.s.origin;
	gtime_t eta = time_sec(v.length() / ent.velocity.length());

	hit.monsterinfo.dodge(hit, ent.owner, eta, tr, (ent.movetype == movetype_t::BOUNCE || ent.movetype == movetype_t::TOSS), false);
}

/*
=============
SV_Physics_Toss

Toss, bounce, and fly movement.  When onground, do nothing.
=============
*/
void SV_Physics_Toss(ASEntity &ent)
{
	trace_t	 trace;
	vec3_t	 move;
	float	 backoff;
	ASEntity @slave;
	bool	 wasinwater;
	bool	 isinwater;
	vec3_t	 old_origin;

	// regular thinking
	SV_RunThink(ent);

	if (!ent.e.inuse)
		return;

	// if not a team captain, so movement will be handled elsewhere
	if ((ent.flags & ent_flags_t::TEAMSLAVE) != 0)
		return;

	if (ent.velocity.z > 0)
		@ent.groundentity = null;

	// check for the groundentity going away
	if (ent.groundentity !is null)
		if (!ent.groundentity.e.inuse)
			@ent.groundentity = null;

	// if onground, return without moving
	if (ent.groundentity !is null && ent.gravity > 0.0f) // PGM - gravity hack
	{
		if ((ent.e.svflags & svflags_t::MONSTER) != 0)
		{
			M_CatagorizePosition(ent, ent.e.s.origin, ent.waterlevel, ent.watertype);
			M_WorldEffects(ent);
		}

		return;
	}

	old_origin = ent.e.s.origin;

	SV_CheckVelocity(ent);

	// add gravity
	if (ent.movetype != movetype_t::FLY &&
		ent.movetype != movetype_t::FLYMISSILE
		// RAFAEL
		// move type for rippergun projectile
		&& ent.movetype != movetype_t::WALLBOUNCE
		// RAFAEL
	)
		SV_AddGravity(ent);

	// move angles
	ent.e.s.angles = ent.e.s.angles + (ent.avelocity * gi_frame_time_s);

	// move origin
	int num_tries = 5;
	float time_left = gi_frame_time_s;

	while (time_left > 0)
	{
		if (num_tries == 0)
			break;

		num_tries--;
		move = ent.velocity * time_left;
		trace = SV_PushEntity(ent, move);

		if (!ent.e.inuse)
			return;

		if (trace.fraction == 1.0f)
			break;
		// [Paril-KEX] don't build up velocity if we're stuck.
		// just assume that the object we hit is our ground.
		else if (trace.allsolid)
		{
			@ent.groundentity = @entities[trace.ent.s.number];
			ent.groundentity_linkcount = trace.ent.linkcount;
			ent.velocity = vec3_origin;
			ent.avelocity = vec3_origin;
			break;
		}

		time_left -= time_left * trace.fraction;

		if (ent.movetype == movetype_t::TOSS)
			ent.velocity = SlideClipVelocity(ent.velocity, trace.plane.normal, 0.5f);
		else
		{
			// RAFAEL
			if (ent.movetype == movetype_t::WALLBOUNCE)
				backoff = 2.0f;
			// RAFAEL
			else
				backoff = 1.6f;

			ent.velocity = ClipVelocity(ent.velocity, trace.plane.normal, backoff);
		}

		// RAFAEL
		if (ent.movetype == movetype_t::WALLBOUNCE)
			ent.e.s.angles = vectoangles(ent.velocity);
		// RAFAEL
		// stop if on ground
		else
		{
			if (trace.plane.normal.z > 0.7f)
			{
				if ((ent.movetype == movetype_t::TOSS && ent.velocity.length() < 60.0f) ||
					(ent.movetype != movetype_t::TOSS && ent.velocity.scaled(trace.plane.normal).length() < 60.0f))
				{
					if ((ent.flags & ent_flags_t::NO_STANDING) == 0 || trace.ent.solid == solid_t::BSP)
					{
						@ent.groundentity = @entities[trace.ent.s.number];
						ent.groundentity_linkcount = trace.ent.linkcount;
					}
					ent.velocity = vec3_origin;
					ent.avelocity = vec3_origin;
					break;
				}

				// friction for tossing stuff (gibs, etc)
				if (ent.movetype == movetype_t::TOSS)
				{
					ent.velocity *= 0.75f;
					ent.avelocity *= 0.75f;
				}
			}
		}

		// only toss "slides" multiple times
		if (ent.movetype != movetype_t::TOSS)
			break;
	}

	// check for water transition
	wasinwater = (ent.watertype & contents_t::MASK_WATER) != 0;
	ent.watertype = gi_pointcontents(ent.e.s.origin);
	isinwater = (ent.watertype & contents_t::MASK_WATER) != 0;

	if (isinwater)
		ent.waterlevel = water_level_t::FEET;
	else
		ent.waterlevel = water_level_t::NONE;

	if ((ent.e.svflags & svflags_t::MONSTER) != 0)
	{
		M_CatagorizePosition(ent, ent.e.s.origin, ent.waterlevel, ent.watertype);
		M_WorldEffects(ent);
	}
	else
	{
		if (!wasinwater && isinwater)
			gi_positioned_sound(old_origin, world.e, soundchan_t::AUTO, gi_soundindex("misc/h2ohit1.wav"), 1, 1, 0);
		else if (wasinwater && !isinwater)
			gi_positioned_sound(ent.e.s.origin, world.e, soundchan_t::AUTO, gi_soundindex("misc/h2ohit1.wav"), 1, 1, 0);
	}

	// prevent softlocks from keys falling into slime/lava
	if (isinwater && (ent.watertype & (contents_t::SLIME | contents_t::LAVA)) != 0 && (ent.item !is null) &&
		(ent.item.flags & item_flags_t::KEY) != 0 && (ent.spawnflags & spawnflags::item::DROPPED) != 0)
		ent.velocity = { crandom_open() * 300, crandom_open() * 300, 300.f + (crandom_open() * 300.f) };

	// move teamslaves
	for (@slave = ent.teamchain; slave !is null; @slave = slave.teamchain)
	{
		slave.e.s.origin = ent.e.s.origin;
		gi_linkentity(slave.e);
	}

    // for projectiles that are dodgable, see if
    // we're gonna hit a monster
    if ((ent.e.svflags & svflags_t::PROJECTILE) != 0 && (ent.flags & ent_flags_t::DODGE) != 0)
        SV_CheckProjectileDodge(ent);
}


/*
===============================================================================

STEPPING MOVEMENT

===============================================================================
*/

const float sv_friction = 6;
const float sv_waterfriction = 1;

/*
=============
SV_Physics_Step

Monsters freefall when they don't have a ground entity, otherwise
all movement is done with discrete steps.

This is also used for objects that have become still on the ground, but
will fall if the floor is pulled out from under them.
=============
*/
void SV_AddRotationalFriction(ASEntity &ent)
{
	int	  n;
	float adjustment;

	ent.e.s.angles += (ent.avelocity * gi_frame_time_s);
	adjustment = gi_frame_time_s * sv_stopspeed.value * sv_friction; // PGM now a cvar

	for (n = 0; n < 3; n++)
	{
		if (ent.avelocity[n] > 0)
		{
			ent.avelocity[n] -= adjustment;
			if (ent.avelocity[n] < 0)
				ent.avelocity[n] = 0;
		}
		else
		{
			ent.avelocity[n] += adjustment;
			if (ent.avelocity[n] > 0)
				ent.avelocity[n] = 0;
		}
	}
}

void SV_Physics_Step(ASEntity &ent)
{
	bool	   wasonground;
	bool	   hitsound = false;
	float	   speed, newspeed, control;
	float	   friction;
	ASEntity   @groundentity;
	contents_t mask = G_GetClipMask(ent);

	// [Paril-KEX]
	if (ent.no_gravity_time > level.time)
		@ent.groundentity = null;
	// airborne monsters should always check for ground
	else if (ent.groundentity is null)
		M_CheckGround(ent, mask);

	@groundentity = ent.groundentity;

	SV_CheckVelocity(ent);

	if (groundentity !is null)
		wasonground = true;
	else
		wasonground = false;

	if (ent.avelocity)
		SV_AddRotationalFriction(ent);

	// add gravity except:
	//   flying monsters
	//   swimming monsters who are in the water
	if (!wasonground)
		if ((ent.flags & ent_flags_t::FLY) == 0)
			if (!((ent.flags & ent_flags_t::SWIM) != 0 && (ent.waterlevel > water_level_t::WAIST)))
			{
				if (ent.velocity.z < level.gravity * -0.1f)
					hitsound = true;
				if (ent.waterlevel != water_level_t::UNDER)
					SV_AddGravity(ent);
			}

	// friction for flying monsters that have been given vertical velocity
	if ((ent.flags & ent_flags_t::FLY) != 0 && (ent.velocity.z != 0) && (ent.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) == 0)
	{
		speed = abs(ent.velocity.z);
		control = speed < sv_stopspeed.value ? sv_stopspeed.value : speed;
		friction = sv_friction / 3;
		newspeed = speed - (gi_frame_time_s * control * friction);
		if (newspeed < 0)
			newspeed = 0;
		newspeed /= speed;
		ent.velocity.z *= newspeed;
	}

	// friction for flying monsters that have been given vertical velocity
	if ((ent.flags & ent_flags_t::SWIM) != 0 && (ent.velocity.z != 0) && (ent.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) == 0)
	{
		speed = abs(ent.velocity.z);
		control = speed < sv_stopspeed.value ? sv_stopspeed.value : speed;
		newspeed = speed - (gi_frame_time_s * control * sv_waterfriction * float(ent.waterlevel));
		if (newspeed < 0)
			newspeed = 0;
		newspeed /= speed;
		ent.velocity.z *= newspeed;
	}

	if (ent.velocity || ent.no_gravity_time > level.time)
	{
		// apply friction
		if ((wasonground || (ent.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) != 0) && (ent.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) == 0)
		{
			speed = sqrt(ent.velocity.x * ent.velocity.x + ent.velocity.y * ent.velocity.y);
			if (speed != 0)
			{
				friction = sv_friction;

				// Paril: lower friction for dead monsters
				if (ent.deadflag)
					friction *= 0.5f;

				control = speed < sv_stopspeed.value ? sv_stopspeed.value : speed;
				newspeed = speed - gi_frame_time_s * control * friction;

				if (newspeed < 0)
					newspeed = 0;
				newspeed /= speed;

				ent.velocity.x *= newspeed;
				ent.velocity.y *= newspeed;
			}
		}

		vec3_t old_origin = ent.e.s.origin;

		SV_FlyMove(ent, gi_frame_time_s, mask);

		G_TouchProjectiles(ent, old_origin);

		M_CheckGround(ent, mask);

		gi_linkentity(ent.e);

		// ========
		// PGM - reset this every time they move.
		//       G_touchtriggers will set it back if appropriate
		ent.gravity = 1.0;
		// ========

		// [Paril-KEX] this is something N64 does to avoid doors opening
		// at the start of a level, which triggers some monsters to spawn.
		if (!level.is_n64 || level.time > FRAME_TIME_S)
			G_TouchTriggers(ent);

		if (!ent.e.inuse)
			return;

		if (ent.groundentity !is null)
			if (!wasonground)
				if (hitsound)
					ent.e.s.event = entity_event_t::FOOTSTEP;
	}

	if (!ent.e.inuse) // PGM g_touchtrigger free problem
		return;
	
	if ((ent.e.svflags & svflags_t::MONSTER) != 0)
	{
		M_CatagorizePosition(ent, ent.e.s.origin, ent.waterlevel, ent.watertype);
		M_WorldEffects(ent);

		// [Paril-KEX] last minute hack to fix Stalker upside down gravity
		if (wasonground != (ent.groundentity !is null))
		{
			if (ent.monsterinfo.physics_change !is null)
				ent.monsterinfo.physics_change(ent);
		}
	}

	// regular thinking
	SV_RunThink(ent);
}
