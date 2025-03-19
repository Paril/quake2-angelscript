/*QUAKED info_teleport_destination (.5 .5 .5) (-16 -16 -24) (16 16 32)
Destination marker for a teleporter.
*/
void SP_info_teleport_destination(ASEntity &self)
{
}

namespace spawnflags::teleport
{
	// unused; broken?
	// constexpr uint32_t SPAWNFLAG_TELEPORT_PLAYER_ONLY	= 1;
	// unused
	// constexpr uint32_t SPAWNFLAG_TELEPORT_SILENT		= 2;
	// unused
	// constexpr uint32_t SPAWNFLAG_TELEPORT_CTF_ONLY		= 4;
	const spawnflags_t START_ON = spawnflag_dec(8);
}

/*QUAKED trigger_teleport (.5 .5 .5) ? player_only silent ctf_only start_on
Any object touching this will be transported to the corresponding
info_teleport_destination entity. You must set the "target" field,
and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport
entities when it has been fired.

player_only: only players are teleported
silent: <not used right now>
ctf_only: <not used right now>
start_on: when trigger has targetname, start active, deactivate when used.
*/
void trigger_teleport_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @dest;

	if (/*(self->spawnflags & SPAWNFLAG_TELEPORT_PLAYER_ONLY) &&*/ (other.client is null))
		return;

	if (self.delay != 0)
		return;

	@dest = G_PickTarget(self.target);
	if (dest is null)
	{
		gi_Com_Print("Teleport Destination not found!\n");
		return;
	}

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::TELEPORT_EFFECT);
	gi_WritePosition(other.e.s.origin);
	gi_multicast(other.e.s.origin, multicast_t::PVS, false);

	other.e.s.origin = dest.e.s.origin;
	other.e.s.old_origin = dest.e.s.origin;
	other.e.s.origin[2] += 10;

	// clear the velocity and hold them in place briefly
	other.velocity = vec3_origin;

	if (other.client !is null)
	{
		other.e.client.ps.pmove.pm_time = 160; // hold time
		other.e.client.ps.pmove.pm_flags = pmflags_t(other.e.client.ps.pmove.pm_flags | pmflags_t::TIME_TELEPORT);

		// draw the teleport splash at source and on the player
		other.e.s.event = entity_event_t::PLAYER_TELEPORT;

		// set angles
		other.e.client.ps.pmove.delta_angles = dest.e.s.angles - other.client.resp.cmd_angles;

		other.e.client.ps.viewangles = vec3_origin;
		other.client.v_angle = vec3_origin;
	}

	other.e.s.angles = vec3_origin;

	gi_linkentity(other.e);

	// kill anything at the destination
	KillBox(other, other.client !is null);

	// [Paril-KEX] move sphere, if we own it
	if (other.client !is null && other.client.owned_sphere !is null)
	{
		ASEntity @sphere = other.client.owned_sphere;
		sphere.e.s.origin = other.e.s.origin;
		sphere.e.s.origin[2] = other.e.absmax[2];
		sphere.e.s.angles.yaw = other.e.s.angles.yaw;
		gi_linkentity(sphere.e);
	}
}

void trigger_teleport_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.delay != 0)
		self.delay = 0;
	else
		self.delay = 1;
}

void SP_trigger_teleport(ASEntity &self)
{
	if (self.wait == 0)
		self.wait = 0.2f;

	self.delay = 0;

	if (!self.targetname.empty())
	{
		@self.use = trigger_teleport_use;
		if (!self.spawnflags.has(spawnflags::teleport::START_ON))
			self.delay = 1;
	}

	@self.touch = trigger_teleport_touch;

	self.e.solid = solid_t::TRIGGER;
	self.movetype = movetype_t::NONE;

	if (self.e.s.angles)
		G_SetMovedir(self, self.movedir);

	gi_setmodel(self.e, self.model);
	gi_linkentity(self.e);
}


// ***************************
// TRIGGER_DISGUISE
// ***************************

/*QUAKED trigger_disguise (.5 .5 .5) ? TOGGLE START_ON REMOVE
Anything passing through this trigger when it is active will
be marked as disguised.

TOGGLE - field is turned off and on when used. (Paril N.B.: always the case)
START_ON - field is active when spawned.
REMOVE - field removes the disguise
*/

namespace spawnflags::disguise
{
    // unused
    // const spawnflags_t TOGGLE = spawnflag_dec(1);
    const spawnflags_t START_ON = spawnflag_dec(2);
    const spawnflags_t REMOVE = spawnflag_dec(4);
}

void trigger_disguise_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client !is null)
	{
		if (self.spawnflags.has(spawnflags::disguise::REMOVE))
			other.flags = ent_flags_t(other.flags & ~ent_flags_t::DISGUISED);
		else
			other.flags = ent_flags_t(other.flags | ent_flags_t::DISGUISED);
	}
}

void trigger_disguise_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;

	gi_linkentity(self.e);
}

void SP_trigger_disguise(ASEntity &self)
{
    // FIXME probably needs to be cached_imageindex
	if (level.disguise_icon == 0)
		level.disguise_icon = gi_imageindex("i_disguise");

	if (self.spawnflags.has(spawnflags::disguise::START_ON))
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;

	@self.touch = trigger_disguise_touch;
	@self.use = trigger_disguise_use;
	self.movetype = movetype_t::NONE;
	self.e.svflags = svflags_t::NOCLIENT;

	gi_setmodel(self.e, self.model);
	gi_linkentity(self.e);
}
