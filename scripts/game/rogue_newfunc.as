// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

namespace spawnflags::secret_door
{
    const uint32 OPEN_ONCE = 1; // stays open
    // unused
    // const uint32_t FIRST_LEFT		= 2;         // 1st move is left of arrow
    const uint32 FIRST_DOWN = 4; // 1st move is down from arrow
    // unused
    // const uint32_t NO_SHOOT		= 8;         // only opened by trigger
    const uint32 YES_SHOOT = 16; // shootable even if targeted
    const uint32 MOVE_RIGHT = 32;
    const uint32 MOVE_FORWARD = 64;
}

void fd_secret_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if ((self.flags & ent_flags_t::TEAMSLAVE) != 0)
		return;

	// trigger all paired doors
	for (ASEntity @ent = self; ent !is null; @ent = ent.teamchain)
		Move_Calc(ent, ent.moveinfo.start_origin, fd_secret_move1);
}

void fd_secret_killed(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.health = self.max_health;
	self.takedamage = false;

	if ((self.flags & ent_flags_t::TEAMSLAVE) != 0 && self.teammaster !is null && self.teammaster.takedamage != false)
		fd_secret_killed(self.teammaster, inflictor, attacker, damage, point, mod);
	else
		fd_secret_use(self, inflictor, attacker);
}

// Wait after first movement...
void fd_secret_move1(ASEntity &self)
{
	self.nextthink = level.time + time_sec(1);
	@self.think = fd_secret_move2;
}

// Start moving sideways w/sound...
void fd_secret_move2(ASEntity &self)
{
	Move_Calc(self, self.moveinfo.end_origin, fd_secret_move3);
}

// Wait here until time to go back...
void fd_secret_move3(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::secret_door::OPEN_ONCE) == 0)
	{
		self.nextthink = level.time + time_sec(self.wait);
		@self.think = fd_secret_move4;
	}
}

// Move backward...
void fd_secret_move4(ASEntity &self)
{
	Move_Calc(self, self.moveinfo.start_origin, fd_secret_move5);
}

// Wait 1 second...
void fd_secret_move5(ASEntity &self)
{
	self.nextthink = level.time + time_sec(1);
	@self.think = fd_secret_move6;
}

void fd_secret_move6(ASEntity &self)
{
	Move_Calc(self, self.move_origin, fd_secret_done);
}

void fd_secret_done(ASEntity &self)
{
	if (self.targetname.empty() || (self.spawnflags & spawnflags::secret_door::YES_SHOOT) != 0)
	{
		self.health = 1;
		self.takedamage = true;
		@self.die = fd_secret_killed;
	}
}

void secret_blocked(ASEntity &self, ASEntity &other)
{
	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 0, damageflags_t::NONE, mod_id_t::CRUSH);
}

/*
================
secret_touch

Prints messages
================
*/
void secret_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.health <= 0)
		return;

	if (other.client is null)
		return;

	if (self.monsterinfo.attack_finished > level.time)
		return;

	self.monsterinfo.attack_finished = level.time + time_sec(2);

	if (!self.message.empty())
		gi_LocCenter_Print(other.e, self.message);
}

/*QUAKED func_door_secret2 (0 .5 .8) ? open_once FIRST_LEFT FIRST_DOWN no_shoot always_shoot slide_right slide_forward
Basic secret door. Slides back, then to the left. Angle determines direction.

FLAGS:
open_once = not implemented yet
FIRST_LEFT = 1st move is left/right of arrow
FIRST_DOWN = 1st move is forwards/backwards
no_shoot = not implemented yet
always_shoot = even if targeted, keep shootable
reverse_left = the sideways move will be to right of arrow
reverse_back = the to/fro move will be forward

VALUES:
wait = # of seconds before coming back (5 default)
dmg  = damage to inflict when blocked (2 default)

*/

void SP_func_door_secret2(ASEntity &ent)
{
	vec3_t forward, right, up;
	float  lrSize, fbSize;

	G_SetMoveinfoSounds(ent, "doors/dr1_strt.wav", "doors/dr1_mid.wav", "doors/dr1_end.wav");

	if (ent.dmg == 0)
		ent.dmg = 2;

	AngleVectors(ent.e.s.angles, forward, right, up);
	ent.move_origin = ent.e.s.origin;
	ent.move_angles = ent.e.s.angles;

	G_SetMovedir(ent, ent.movedir);
	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::BSP;
	gi_setmodel(ent.e, ent.model);

	if (ent.move_angles[1] == 0 || ent.move_angles[1] == 180)
	{
		lrSize = ent.e.size[1];
		fbSize = ent.e.size[0];
	}
	else if (ent.move_angles[1] == 90 || ent.move_angles[1] == 270)
	{
		lrSize = ent.e.size[0];
		fbSize = ent.e.size[1];
	}
	else
	{
		gi_Com_Print("Secret door not at 0,90,180,270!\n");
		G_FreeEdict(ent);
		return;
	}

	if ((ent.spawnflags & spawnflags::secret_door::MOVE_FORWARD) != 0)
		forward *= fbSize;
	else
		forward *= fbSize * -1;

	if ((ent.spawnflags & spawnflags::secret_door::MOVE_RIGHT) != 0)
		right *= lrSize;
	else
		right *= lrSize * -1;

	if ((ent.spawnflags & spawnflags::secret_door::FIRST_DOWN) != 0)
	{
		ent.moveinfo.start_origin = ent.e.s.origin + forward;
		ent.moveinfo.end_origin = ent.moveinfo.start_origin + right;
	}
	else
	{
		ent.moveinfo.start_origin = ent.e.s.origin + right;
		ent.moveinfo.end_origin = ent.moveinfo.start_origin + forward;
	}

	@ent.touch = secret_touch;
	@ent.moveinfo.blocked = secret_blocked;
	@ent.use = fd_secret_use;
	ent.moveinfo.speed = 50;
	ent.moveinfo.accel = 50;
	ent.moveinfo.decel = 50;

	if (ent.targetname.empty() || (ent.spawnflags & spawnflags::secret_door::YES_SHOOT) != 0)
	{
		ent.health = 1;
		ent.max_health = ent.health;
		ent.takedamage = true;
		@ent.die = fd_secret_killed;
	}
	if (ent.wait == 0)
		ent.wait = 5; // 5 seconds before closing

	gi_linkentity(ent.e);
}

// ==================================================

namespace spawnflags::forcewall
{
    const uint32 START_ON = 1;
}

void force_wall_think(ASEntity &self)
{
	if (self.wait == 0)
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::FORCEWALL);
		gi_WritePosition(self.pos1);
		gi_WritePosition(self.pos2);
		gi_WriteByte(self.style);
		gi_multicast(self.offset, multicast_t::PVS, false);
	}

	@self.think = force_wall_think;
	self.nextthink = level.time + time_hz(10);
}

void force_wall_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.wait == 0)
	{
		self.wait = 1;
		@self.think = null;
		self.nextthink = time_zero;
		self.e.solid = solid_t::NOT;
		gi_linkentity(self.e);
	}
	else
	{
		self.wait = 0;
		@self.think = force_wall_think;
		self.nextthink = level.time + time_hz(10);
		self.e.solid = solid_t::BSP;
		gi_linkentity(self.e);
		KillBox(self, false); // Is this appropriate?
	}
}

/*QUAKED func_force_wall (1 0 1) ? start_on
A vertical particle force wall. Turns on and solid when triggered.
If someone is in the force wall when it turns on, they're telefragged.

start_on - forcewall begins activated. triggering will turn it off.
style - color of particles to use.
	208: green, 240: red, 241: blue, 224: orange
*/
void SP_func_force_wall(ASEntity &ent)
{
	gi_setmodel(ent.e, ent.model);

	ent.offset[0] = (ent.e.absmax[0] + ent.e.absmin[0]) / 2;
	ent.offset[1] = (ent.e.absmax[1] + ent.e.absmin[1]) / 2;
	ent.offset[2] = (ent.e.absmax[2] + ent.e.absmin[2]) / 2;

	ent.pos1[2] = ent.e.absmax[2];
	ent.pos2[2] = ent.e.absmax[2];
	if (ent.e.size[0] > ent.e.size[1])
	{
		ent.pos1[0] = ent.e.absmin[0];
		ent.pos2[0] = ent.e.absmax[0];
		ent.pos1[1] = ent.offset[1];
		ent.pos2[1] = ent.offset[1];
	}
	else
	{
		ent.pos1[0] = ent.offset[0];
		ent.pos2[0] = ent.offset[0];
		ent.pos1[1] = ent.e.absmin[1];
		ent.pos2[1] = ent.e.absmax[1];
	}

	if (ent.style == 0)
		ent.style = 208;

	ent.movetype = movetype_t::NONE;
	ent.wait = 1;

	if ((ent.spawnflags & spawnflags::forcewall::START_ON) != 0)
	{
		ent.e.solid = solid_t::BSP;
		@ent.think = force_wall_think;
		ent.nextthink = level.time + time_hz(10);
	}
	else
		ent.e.solid = solid_t::NOT;

	@ent.use = force_wall_use;

	ent.e.svflags = svflags_t::NOCLIENT;

	gi_linkentity(ent.e);
}
