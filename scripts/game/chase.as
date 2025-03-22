// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

void UpdateChaseCam(ASEntity &ent)
{
    vec3_t	 o, ownerv, goal;
    ASEntity @targ;
    vec3_t	 forward, right;
    trace_t	 trace;
    vec3_t	 oldgoal;
    vec3_t	 angles;

    // is our chase target gone?
    if (!ent.client.chase_target.e.inuse || ent.client.chase_target.client.resp.spectator)
    {
        ASEntity @old = ent.client.chase_target;
        ChaseNext(ent);
        if (ent.client.chase_target is old)
        {
            @ent.client.chase_target = null;
            ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~(pmflags_t::NO_POSITIONAL_PREDICTION | pmflags_t::NO_ANGULAR_PREDICTION));
            return;
        }
    }

    @targ = ent.client.chase_target;

    ownerv = targ.e.origin;
    oldgoal = ent.e.origin;

    ownerv.z += targ.viewheight;

    angles = targ.client.v_angle;
    if (angles.pitch > 56)
        angles.pitch = 56;
    AngleVectors(angles, forward, right);
    forward.normalize();
    o = ownerv + (forward * -30);

    if (o.z < targ.e.origin.z + 20)
        o.z = targ.e.origin.z + 20;

    // jump animation lifts
    if (targ.groundentity is null)
        o.z += 16;

    trace = gi_traceline(ownerv, o, targ.e, contents_t::MASK_SOLID);

    goal = trace.endpos;

    goal += (forward * 2);

    // pad for floors and ceilings
    o = goal;
    o.z += 6;
    trace = gi_traceline(goal, o, targ.e, contents_t::MASK_SOLID);
    if (trace.fraction < 1)
    {
        goal = trace.endpos;
        goal.z -= 6;
    }

    o = goal;
    o.z -= 6;
    trace = gi_traceline(goal, o, targ.e, contents_t::MASK_SOLID);
    if (trace.fraction < 1)
    {
        goal = trace.endpos;
        goal.z += 6;
    }

    if (targ.deadflag)
        ent.e.client.ps.pmove.pm_type = pmtype_t::DEAD;
    else
        ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;

    ent.e.origin = goal;
    ent.e.client.ps.pmove.delta_angles = targ.client.v_angle - ent.client.resp.cmd_angles;

    if (targ.deadflag)
    {
        ent.e.client.ps.viewangles.roll = 40;
        ent.e.client.ps.viewangles.pitch = -15;
        ent.e.client.ps.viewangles.yaw = targ.client.killer_yaw;
    }
    else
    {
        ent.e.client.ps.viewangles = targ.client.v_angle;
        ent.client.v_angle = targ.client.v_angle;
        AngleVectors(ent.client.v_angle, ent.client.v_forward);
    }

    ent.viewheight = 0;
    ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags | pmflags_t::NO_POSITIONAL_PREDICTION | pmflags_t::NO_ANGULAR_PREDICTION);
    gi_linkentity(ent.e);
}

void ChaseNext(ASEntity &ent)
{
    uint     i;
    ASEntity @e;

    if (ent.client.chase_target is null)
        return;

    i = ent.client.chase_target.e.number;
    do
    {
        i++;
        if (i > max_clients)
            i = 1;
        @e = entities[i];
        if (!e.e.inuse)
            continue;
        if (!e.client.resp.spectator)
            break;
    } while (e !is ent.client.chase_target);

    @ent.client.chase_target = e;
    ent.client.update_chase = true;
}

void ChasePrev(ASEntity &ent)
{
    uint     i;
    ASEntity @e;

    if (ent.client.chase_target is null)
        return;

    i = ent.client.chase_target.e.number;
    do
    {
        i--;
        if (i < 1)
            i = max_clients;
        @e = entities[i];
        if (!e.e.inuse)
            continue;
        if (!e.client.resp.spectator)
            break;
    } while (e !is ent.client.chase_target);

    @ent.client.chase_target = e;
    ent.client.update_chase = true;
}

void GetChaseTarget(ASEntity &ent)
{
    uint i;
    ASEntity @other;

    for (i = 1; i <= max_clients; i++)
    {
        @other = entities[i];
        if (other.e.inuse && !other.client.resp.spectator)
        {
            @ent.client.chase_target = other;
            ent.client.update_chase = true;
            UpdateChaseCam(ent);
            return;
        }
    }

    if (ent.client.chase_msg_time <= level.time)
    {
        gi_LocCenter_Print(ent.e, "$g_no_players_chase");
        ent.client.chase_msg_time = level.time + time_sec(5);
    }
}
