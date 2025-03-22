// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

/*
==============================================================================

PLAYER TRAIL

==============================================================================

This is a two-way list containing the a list of points of where
the player has been recently. It is used by monsters for pursuit.

This is improved from vanilla; now, the list itself is stored in
client data so it can be stored for multiple clients.

chain = next
enemy = prev

The head node will always have a null "chain", the tail node
will always have a null "enemy".
*/

const uint TRAIL_LENGTH = 8;

// places a new entity at the head of the player trail.
// the tail entity may be moved to the front if the length
// is at the end.
ASEntity @PlayerTrail_Spawn(ASEntity &owner)
{
	uint len = 0;

	for (ASEntity @tail = owner.client.trail_tail; tail !is null; @tail = tail.chain)
		len++;

	ASEntity @trail;

	// move the tail to the head
	if (len == TRAIL_LENGTH)
	{
		// unlink the old tail
		@trail = owner.client.trail_tail;
		@owner.client.trail_tail = trail.chain;
		@owner.client.trail_tail.enemy = null;
		@trail.chain = @trail.enemy = null;
	}
	else
	{
		// spawn a new head
		@trail = G_Spawn();
		trail.classname = "player_trail";
	}

	// link as new head
	if (owner.client.trail_head !is null)
		@owner.client.trail_head.chain = trail;
	@trail.enemy = owner.client.trail_head;
	@owner.client.trail_head = trail;

	// if there's no tail, we become the tail too
	if (owner.client.trail_tail is null)
		@owner.client.trail_tail = trail;

	return trail;
}

// destroys all player trail entities in the map.
// we don't want these to stay around across level loads.
void PlayerTrail_Destroy(ASEntity @player)
{
    // in DM we don't have to worry about any of this
    if (deathmatch.integer == 0)
        return;

    // slow path when leaving levels
    if (player is null)
    {
        for (uint i = max_clients + 1; i < num_edicts; i++)
        {
            ASEntity @e = entities[i];

            if (e.classname == "player_trail" ||
                e.classname == "player_noise")
                G_FreeEdict(e);
        }

        for (uint i = 0; i < max_clients; i++)
		    @players[i].client.trail_head = @players[i].client.trail_tail = null;
    }
    else
    {
        // clear trail
        for (ASEntity @marker = player.client.trail_head; marker !is null; )
        {
            ASEntity @next = marker.enemy;
            G_FreeEdict(marker);
            @marker = next;
        }
        
        @player.client.trail_head = @player.client.trail_tail = null;

        // clear noises
        if (player.client.mynoise !is null)
        {
            G_FreeEdict(player.client.mynoise);
            @player.client.mynoise = null;
        }
        if (player.client.mynoise2 !is null)
        {
            G_FreeEdict(player.client.mynoise2);
            @player.client.mynoise2 = null;
        }
    }
}

// check to see if we can add a new player trail spot
// for this player.
void PlayerTrail_Add(ASEntity &player)
{
	// if we can still see the head, we don't want a new one.
	if (player.client.trail_head !is null && visible(player, player.client.trail_head))
		return;
	// don't spawn trails in intermission, if we're dead, if we're noclipping or not on ground yet
	else if (level.intermissiontime || player.health <= 0 || player.movetype == movetype_t::NOCLIP ||
		player.groundentity is null)
		return;

	ASEntity @trail = PlayerTrail_Spawn(player);
	trail.e.s.origin = player.e.s.old_origin;
	trail.timestamp = level.time;
	@trail.owner = player;
}

// pick a trail node that matches the player
// we're hunting that is visible to us.
ASEntity @PlayerTrail_Pick(ASEntity &self, bool next)
{
	// not player or doesn't have a trail yet
	if (self.enemy.client is null || self.enemy.client.trail_head is null)
		return null;

	// find which marker head that was dropped while we
	// were searching for this enemy
	ASEntity @marker;

	for (@marker = self.enemy.client.trail_head; marker !is null; @marker = marker.enemy)
	{
		if (marker.timestamp <= self.monsterinfo.trail_time)
			continue;

		break;
	}

	if (next)
	{
		// find the marker we're closest to
		float closest_dist = float_limits::infinity;
		ASEntity @closest = null;

		for (ASEntity @m2 = marker; m2 !is null; @m2 = m2.enemy)
		{
			float len = (m2.e.s.origin - self.e.s.origin).lengthSquared();

			if (len < closest_dist)
			{
				closest_dist = len;
				@closest = m2;
			}
		}

		// should never happen
		if (closest is null)
			return null;

		// use the next one from the closest one
		@marker = closest.chain;
	}
	else
	{
		// from that marker, find the first one we can see
		for (; marker !is null && !visible(self, marker); @marker = marker.enemy)
			continue;
	}

	return marker;
}
