/*QUAKED rotating_light (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF ALARM
"health"	if set, the light may be killed.
*/

// RAFAEL
// note to self
// the lights will take damage from explosions
// this could leave a player in total darkness very bad

namespace spawnflags::rotating_light
{
    const spawnflags_t START_OFF = spawnflag_dec(1);
    const spawnflags_t ALARM = spawnflag_dec(2);
}

void rotating_light_alarm(ASEntity &self)
{
	if (self.spawnflags.has(spawnflags::rotating_light::START_OFF))
	{
		@self.think = null;
		self.nextthink = time_zero;
	}
	else
	{
		gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), self.moveinfo.sound_start, 1, ATTN_STATIC, 0);
		self.nextthink = level.time + time_sec(1);
	}
}

void rotating_light_killed(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WELDING_SPARKS);
	gi_WriteByte(30);
	gi_WritePosition(self.e.s.origin);
	gi_WriteDir(vec3_origin);
	gi_WriteByte(irandom(0xe0, 0xe8));
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::SPINNINGLIGHTS);
	@self.use = null;

	@self.think = G_FreeEdict;
	self.nextthink = level.time + FRAME_TIME_S;
}

void rotating_light_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.spawnflags.has(spawnflags::rotating_light::START_OFF))
	{
		self.spawnflags &= ~spawnflags::rotating_light::START_OFF;
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::SPINNINGLIGHTS);

		if (self.spawnflags.has(spawnflags::rotating_light::ALARM))
		{
			@self.think = rotating_light_alarm;
			self.nextthink = level.time + FRAME_TIME_S;
		}
	}
	else
	{
		self.spawnflags |= spawnflags::rotating_light::START_OFF;
		self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::SPINNINGLIGHTS);
	}
}

void SP_rotating_light(ASEntity &self)
{
	self.movetype = movetype_t::STOP;
	self.e.solid = solid_t::BBOX;

	self.e.s.modelindex = gi_modelindex("models/objects/light/tris.md2");

	self.e.s.frame = 0;

	@self.use = rotating_light_use;

	if (self.spawnflags.has(spawnflags::rotating_light::START_OFF))
		self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::SPINNINGLIGHTS);
	else
	{
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::SPINNINGLIGHTS);
	}

	if (self.speed == 0)
		self.speed = 32;
	// this is a real cheap way
	// to set the radius of the light
	// self->s.frame = self->speed;

	if (self.health == 0)
	{
		self.health = 10;
		self.max_health = self.health;
		@self.die = rotating_light_killed;
		self.takedamage = true;
	}
	else
	{
		self.max_health = self.health;
		@self.die = rotating_light_killed;
		self.takedamage = true;
	}

	if (self.spawnflags.has(spawnflags::rotating_light::ALARM))
	{
		self.moveinfo.sound_start = gi_soundindex("misc/alarm.wav");
	}

	gi_linkentity(self.e);
}

/*QUAKED func_object_repair (1 .5 0) (-8 -8 -8) (8 8 8)
object to be repaired.
The default delay is 1 second
"delay" the delay in seconds for spark to occur
*/

void object_repair_fx(ASEntity &ent)
{
	ent.nextthink = level.time + time_sec(ent.delay);

	if (ent.health <= 100)
		ent.health++;
	else
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::WELDING_SPARKS);
		gi_WriteByte(10);
		gi_WritePosition(ent.e.s.origin);
		gi_WriteDir(vec3_origin);
		gi_WriteByte(irandom(0xe0, 0xe8));
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
	}
}

void object_repair_dead(ASEntity &ent)
{
	G_UseTargets(ent, ent);
	ent.nextthink = level.time + time_hz(10);
	@ent.think = object_repair_fx;
}

void object_repair_sparks(ASEntity &ent)
{
	if (ent.health <= 0)
	{
		ent.nextthink = level.time + time_hz(10);
		@ent.think = object_repair_dead;
		return;
	}

	ent.nextthink = level.time + time_sec(ent.delay);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WELDING_SPARKS);
	gi_WriteByte(10);
	gi_WritePosition(ent.e.s.origin);
	gi_WriteDir(vec3_origin);
	gi_WriteByte(irandom(0xe0, 0xe8));
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
}

void SP_func_object_repair(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.classname = "object_repair";
	ent.e.mins = { -8, -8, 8 };
	ent.e.maxs = { 8, 8, 8 };
	@ent.think = object_repair_sparks;
	ent.nextthink = level.time + time_sec(1);
	ent.health = 100;
	if (ent.delay == 0)
		ent.delay = 1.0;
}
