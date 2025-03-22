// RAFAEL
void SP_item_foodcube(ASEntity &self)
{
	if (deathmatch.integer != 0 && g_no_health.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}

	self.model = "models/objects/trapfx/tris.md2";
	SpawnItem(self, GetItemByIndex(item_id_t::HEALTH_SMALL), empty_st);
	self.spawnflags |= spawnflags::item::DROPPED;
	self.style = health_style_t::IGNORE_MAX;
	self.classname = "item_foodcube";
	self.e.s.effects = effects_t(self.e.s.effects | effects_t::GIB);

	// Paril: set pickup noise for foodcube based on amount
	if (self.count < 10)
		self.noise_index = gi_soundindex("items/s_health.wav");
	else if (self.count < 25)
		self.noise_index = gi_soundindex("items/n_health.wav");
	else if (self.count < 50)
		self.noise_index = gi_soundindex("items/l_health.wav");
	else
		self.noise_index = gi_soundindex("items/m_health.wav");
}

// RAFAEL
void fire_blueblaster(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, effects_t effect)
{
	ASEntity @bolt;
	trace_t	 tr;

	@bolt = G_Spawn();
	bolt.e.s.origin = start;
	bolt.e.s.old_origin = start;
	bolt.e.s.angles = vectoangles(dir);
	bolt.velocity = dir * speed;
	bolt.e.svflags = svflags_t(bolt.e.svflags | svflags_t::PROJECTILE);
	bolt.movetype = movetype_t::FLYMISSILE;
	bolt.flags = ent_flags_t(bolt.flags | ent_flags_t::DODGE);
	bolt.e.clipmask = contents_t::MASK_PROJECTILE;
	bolt.e.solid = solid_t::BBOX;
	bolt.e.s.effects = effects_t(bolt.e.s.effects | effect);
	bolt.e.s.modelindex = gi_modelindex("models/objects/laser/tris.md2");
	bolt.e.s.skinnum = 1;
	bolt.e.s.sound = gi_soundindex("misc/lasfly.wav");
	@bolt.owner = self;
	@bolt.touch = blaster_touch;
	bolt.nextthink = level.time + time_sec(2);
	@bolt.think = G_FreeEdict;
	bolt.dmg = damage;
	bolt.classname = "bolt";
	bolt.style = mod_id_t::BLUEBLASTER;
	gi_linkentity(bolt.e);

	tr = gi_traceline(self.e.s.origin, bolt.e.s.origin, bolt.e, bolt.e.clipmask);

	if (tr.fraction < 1.0f)
	{
		bolt.e.s.origin = tr.endpos + (tr.plane.normal * 1.f);
		bolt.touch(bolt, entities[tr.ent.s.number], tr, false);
	}
}

// RAFAEL

// RAFAEL

/*
fire_ionripper
*/

void ionripper_sparks(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WELDING_SPARKS);
	gi_WriteByte(0);
	gi_WritePosition(self.e.s.origin);
	gi_WriteDir(vec3_origin);
	gi_WriteByte(irandom(0xe4, 0xe8));
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	G_FreeEdict(self);
}

// RAFAEL
void ionripper_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other is self.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.owner.client !is null)
		PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
	{
		T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::ENERGY, mod_id_t::RIPPER);
	}
	else
	{
		return;
	}

	G_FreeEdict(self);
}

// RAFAEL
void fire_ionripper(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, effects_t effect)
{
	ASEntity @ion;
	trace_t	 tr;

	@ion = G_Spawn();
	ion.e.s.origin = start;
	ion.e.s.old_origin = start;
	ion.e.s.angles = vectoangles(dir);
	ion.velocity = dir * speed;
	ion.movetype = movetype_t::WALLBOUNCE;
	ion.e.clipmask = contents_t::MASK_PROJECTILE;

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		ion.e.clipmask = contents_t(ion.e.clipmask & ~contents_t::PLAYER);

	ion.e.solid = solid_t::BBOX;
	ion.e.s.effects = effects_t(ion.e.s.effects | effect);
	ion.e.svflags = svflags_t(ion.e.svflags | svflags_t::PROJECTILE);
	ion.flags = ent_flags_t(ion.flags | ent_flags_t::DODGE);
	ion.e.s.renderfx = renderfx_t(ion.e.s.renderfx | renderfx_t::FULLBRIGHT);
	ion.e.s.modelindex = gi_modelindex("models/objects/boomrang/tris.md2");
	ion.e.s.sound = gi_soundindex("misc/lasfly.wav");
	@ion.owner = self;
	@ion.touch = ionripper_touch;
	ion.nextthink = level.time + time_sec(3);
	@ion.think = ionripper_sparks;
	ion.dmg = damage;
	ion.dmg_radius = 100;
	gi_linkentity(ion.e);

	tr = gi_traceline(self.e.s.origin, ion.e.s.origin, ion.e, ion.e.clipmask);
	if (tr.fraction < 1.0f)
	{
		ion.e.s.origin = tr.endpos + (tr.plane.normal * 1.f);
		ion.touch(ion, entities[tr.ent.s.number], tr, false);
	}
}

// RAFAEL
/*
fire_heat
*/

void heat_think(ASEntity &self)
{
	ASEntity @acquire = null;
	float	 oldlen = 0;
	float	 olddot = 1;

	vec3_t fwd;
    AngleVectors(self.e.s.angles, fwd);

	// try to stay on current target if possible
	if (self.enemy !is null)
	{
		@acquire = self.enemy;

		if (acquire.health <= 0 ||
			!visible(self, acquire))
		{
			@self.enemy = @acquire = null;
		}
	}

	if (acquire is null)
	{
		ASEntity @target = null;

		// acquire new target
		while ((@target = findradius(target, self.e.s.origin, 1024)) !is null)
		{
			if (self.owner is target)
				continue;
			if (target.client is null)
				continue;
			if (target.health <= 0)
				continue;
			if (!visible(self, target))
				continue;

			vec3_t vec = self.e.s.origin - target.e.s.origin;
			float len = vec.length();

			float dot = vec.normalized().dot(fwd);

			// targets that require us to turn less are preferred
			if (dot >= olddot)
				continue;

			if (acquire is null || dot < olddot || len < oldlen)
			{
				@acquire = target;
				oldlen = len;
				olddot = dot;
			}
		}
	}

	if (acquire !is null)
	{
		vec3_t vec = (acquire.e.s.origin - self.e.s.origin).normalized();
		float t = self.accel;

		float d = self.movedir.dot(vec);

		if (d < 0.45f && d > -0.45f)
			vec = -vec;

		self.movedir = slerp(self.movedir, vec, t).normalized();
		self.e.s.angles = vectoangles(self.movedir);

		if (self.enemy !is acquire)
		{
			gi_sound(self.e, soundchan_t::WEAPON, gi_soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
			@self.enemy = acquire;
		}
	}
	else
		@self.enemy = null;

	self.velocity = self.movedir * self.speed;
	self.nextthink = level.time + FRAME_TIME_MS;
}

// RAFAEL
void fire_heat(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, float damage_radius, int radius_damage, float turn_fraction)
{
	ASEntity @heat;

	@heat = G_Spawn();
	heat.e.s.origin = start;
	heat.movedir = dir;
	heat.e.s.angles = vectoangles(dir);
	heat.velocity = dir * speed;
	heat.flags = ent_flags_t(heat.flags | ent_flags_t::DODGE);
	heat.movetype = movetype_t::FLYMISSILE;
	heat.e.svflags = svflags_t(heat.e.svflags | svflags_t::PROJECTILE);
	heat.e.clipmask = contents_t::MASK_PROJECTILE;
	heat.e.solid = solid_t::BBOX;
	heat.e.s.effects = effects_t(heat.e.s.effects | effects_t::ROCKET);
	heat.e.s.modelindex = gi_modelindex("models/objects/rocket/tris.md2");
	@heat.owner = self;
	@heat.touch = rocket_touch;
	heat.speed = speed;
	heat.accel = turn_fraction;

	heat.nextthink = level.time + FRAME_TIME_MS;
	@heat.think = heat_think;

	heat.dmg = damage;
	heat.radius_dmg = radius_damage;
	heat.dmg_radius = damage_radius;
	heat.e.s.sound = gi_soundindex("weapons/rockfly.wav");

	if (visible(heat, self.enemy))
	{
		@heat.enemy = self.enemy;
		gi_sound(heat.e, soundchan_t::WEAPON, gi_soundindex("weapons/railgr1a.wav"), 1.f, 0.25f, 0);
	}

	gi_linkentity(heat.e);
}

// RAFAEL

/*
fire_plasma
*/

void plasma_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	vec3_t origin;

	if (other is ent.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(ent);
		return;
	}

	if (ent.owner.client !is null)
		PlayerNoise(ent.owner, ent.e.s.origin, player_noise_t::IMPACT);

	// calculate position for the explosion entity
	origin = ent.e.s.origin + tr.plane.normal;

	if (other.takedamage)
	{
		T_Damage(other, ent, ent.owner, ent.velocity, ent.e.s.origin, tr.plane.normal, ent.dmg, ent.dmg, damageflags_t::ENERGY, mod_id_t::PHALANX);
	}

	T_RadiusDamage(ent, ent.owner, float(ent.radius_dmg), other, ent.dmg_radius, damageflags_t::ENERGY, mod_id_t::PHALANX);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::PLASMA_EXPLOSION);
	gi_WritePosition(origin);
	gi_multicast(ent.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(ent);
}
// RAFAEL

// RAFAEL
void fire_plasma(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, float damage_radius, int radius_damage)
{
	ASEntity @plasma;

	@plasma = G_Spawn();
	plasma.e.s.origin = start;
	plasma.movedir = dir;
	plasma.e.s.angles = vectoangles(dir);
	plasma.velocity = dir * speed;
	plasma.movetype = movetype_t::FLYMISSILE;
	plasma.e.clipmask = contents_t::MASK_PROJECTILE;

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		plasma.e.clipmask = contents_t(plasma.e.clipmask & ~contents_t::PLAYER);

	plasma.e.solid = solid_t::BBOX;
	plasma.e.svflags = svflags_t(plasma.e.svflags | svflags_t::PROJECTILE);
	plasma.flags = ent_flags_t(plasma.flags | ent_flags_t::DODGE);
	@plasma.owner = self;
	@plasma.touch = plasma_touch;
	plasma.nextthink = level.time + time_sec(8000.f / speed);
	@plasma.think = G_FreeEdict;
	plasma.dmg = damage;
	plasma.radius_dmg = radius_damage;
	plasma.dmg_radius = damage_radius;
	plasma.e.s.sound = gi_soundindex("weapons/rockfly.wav");

	plasma.e.s.modelindex = gi_modelindex("sprites/s_photon.sp2");
	plasma.e.s.effects = effects_t(plasma.e.s.effects | effects_t::PLASMA | effects_t::ANIM_ALLFAST);

	gi_linkentity(plasma.e);
}

void Trap_Gib_Think(ASEntity &ent)
{
	if (ent.owner.e.s.frame != 5)
	{
		G_FreeEdict(ent);
		return;
	}

	vec3_t forward, right, up;
	vec3_t vec;

	AngleVectors(ent.owner.e.s.angles, forward, right, up);

	// rotate us around the center
	float degrees = (150.0f * gi_frame_time_s) + ent.owner.delay;
	vec3_t diff = ent.owner.e.s.origin - ent.e.s.origin;
	vec = RotatePointAroundVector(up, diff, degrees);
	ent.e.s.angles[1] += degrees;
	vec3_t new_origin = ent.owner.e.s.origin - vec;

	trace_t tr = gi_traceline(ent.e.s.origin, new_origin, ent.e, contents_t::MASK_SOLID);
	ent.e.s.origin = tr.endpos;
	
	// pull us towards the trap's center
	diff.normalize();
	ent.e.s.origin += diff * (15.0f * gi_frame_time_s);

	ent.watertype = gi_pointcontents(ent.e.s.origin);
	if ((ent.watertype & contents_t::MASK_WATER) != 0)
		ent.waterlevel = water_level_t::FEET;

	ent.nextthink = level.time + FRAME_TIME_S;
	gi_linkentity(ent.e);
}

void trap_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	BecomeExplosion1(self);
}

// RAFAEL
void Trap_Think(ASEntity &ent)
{
	ASEntity @target = null;
	ASEntity @best = null;
	vec3_t	 vec;
	float	 len;
	float	 oldlen = 8000;

	if (ent.timestamp < level.time)
	{
		BecomeExplosion1(ent);
		// note to self
		// cause explosion damage???
		return;
	}

	ent.nextthink = level.time + time_hz(10);

	if (ent.groundentity is null)
		return;

	// ok lets do the blood effect
	if (ent.e.s.frame > 4)
	{
		if (ent.e.s.frame == 5)
		{
			bool spawn = ent.wait == 64;

			ent.wait -= 2;

			if (spawn)
				gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/trapdown.wav"), 1, ATTN_IDLE, 0);

			ent.delay += 2.0f;

			if (ent.wait < 19)
				ent.e.s.frame++;

			return;
		}
		ent.e.s.frame++;
		if (ent.e.s.frame == 8)
		{
			ent.nextthink = level.time + time_sec(1);
			@ent.think = G_FreeEdict;
			ent.e.s.effects = effects_t(ent.e.s.effects & ~effects_t::TRAP);

			@best = G_Spawn();
			best.count = ent.mass;
			best.e.s.scale = 1.0f + ((ent.accel - 100.0f) / 300.0f) * 1.0f;
			SP_item_foodcube(best);
			best.e.s.origin = ent.e.s.origin;
			best.e.s.origin[2] += 24 * best.e.s.scale;
			best.e.s.angles.yaw = frandom() * 360;
			best.velocity[2] = 400;
			best.think(best);
			best.nextthink = time_zero;
			best.e.s.old_origin = best.e.s.origin;
			gi_linkentity(best.e);

			gi_sound(best.e, soundchan_t::AUTO, gi_soundindex("misc/fhit3.wav"), 1.0f, ATTN_NORM, 0.0f);

			return;
		}
		return;
	}

	ent.e.s.effects = effects_t(ent.e.s.effects & ~effects_t::TRAP);
	if (ent.e.s.frame >= 4)
	{
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::TRAP);
		// clear the owner if in deathmatch
		if (deathmatch.integer != 0)
			@ent.owner = null;
	}

	if (ent.e.s.frame < 4)
	{
		ent.e.s.frame++;
		return;
	}

	while ((@target = findradius(target, ent.e.s.origin, 256)) !is null)
	{
		if (target is ent)
			continue;
		
		// [Paril-KEX] don't allow traps to be placed near flags or teleporters
		// if it's a monster or player with health > 0
		// or it's a player start point
		// and we can see it
		// blow up
		if (!target.classname.empty() && ((deathmatch.integer != 0 &&
				((target.classname.findFirst("info_player_") == 0) ||
				(target.classname == "misc_teleporter_dest") ||
				(target.classname.findFirst("item_flag_") == 0)))) &&
			(visible(target, ent)))
		{
			BecomeExplosion1(ent);
			return;
		}

		if ((target.e.svflags & svflags_t::MONSTER) == 0 && target.client is null)
			continue;
		if (target !is ent.teammaster && CheckTeamDamage(target, ent.teammaster))
			continue;
		// [Paril-KEX]
		if (deathmatch.integer == 0 && target.client !is null)
			continue;
		if (target.health <= 0)
			continue;
		if (!visible(ent, target))
			continue;
		vec = ent.e.s.origin - target.e.s.origin;
		len = vec.length();
		if (best is null)
		{
			@best = target;
			oldlen = len;
			continue;
		}
		if (len < oldlen)
		{
			oldlen = len;
			@best = target;
		}
	}

	// pull the enemy in
	if (best !is null)
	{
		if (best.groundentity !is null)
		{
			best.e.s.origin[2] += 1;
			@best.groundentity = null;
		}
		vec = ent.e.s.origin - best.e.s.origin;
		len = vec.normalize();

		float max_speed = best.client !is null ? 290.0f : 150.0f;

		best.velocity += (vec * clamp(max_speed - len, 64.0f, max_speed));

		ent.e.s.sound = gi_soundindex("weapons/trapsuck.wav");

		if (len < 48)
		{
			if (best.mass < 400)
			{
				ent.takedamage = false;
				ent.e.solid = solid_t::NOT;
				@ent.die = null;

				T_Damage(best, ent, ent.teammaster, vec3_origin, best.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::TRAP);

				if ((best.e.svflags & svflags_t::MONSTER) != 0)
					M_ProcessPain(best);

				@ent.enemy = best;
				ent.wait = 64;
				ent.e.s.old_origin = ent.e.s.origin;
				ent.timestamp = level.time + time_sec(30);
				ent.accel = best.mass;
				if (deathmatch.integer != 0)
					ent.mass = best.mass / 4;
				else
					ent.mass = best.mass / 10;
				// ok spawn the food cube
				ent.e.s.frame = 5;

				// link up any gibs that this monster may have spawned
				for (uint32 i = 0; i < num_edicts; i++)
				{
					ASEntity @e = entities[i];

					if (!e.e.inuse)
						continue;
					else if (e.classname != "gib")
						continue;
					else if ((e.e.s.origin - ent.e.s.origin).length() > 128.0f)
						continue;

					e.movetype = movetype_t::NONE;
					e.nextthink = level.time + FRAME_TIME_S;
					@e.think = Trap_Gib_Think;
					@e.owner = ent;
					Trap_Gib_Think(e);
				}
			}
			else
			{
				BecomeExplosion1(ent);
				// note to self
				// cause explosion damage???
				return;
			}
		}
	}
}

// RAFAEL
void fire_trap(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int speed)
{
	ASEntity @trap;
	vec3_t	 dir;
	vec3_t	 forward, right, up;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@trap = G_Spawn();
	trap.e.s.origin = start;
	trap.velocity = aimdir * speed;

	float gravityAdjustment = level.gravity / 800.0f;

	trap.velocity += up * (200 + crandom() * 10.0f) * gravityAdjustment;
	trap.velocity += right * (crandom() * 10.0f);

	trap.avelocity = { 0, 300, 0 };
	trap.movetype = movetype_t::BOUNCE;

	trap.e.solid = solid_t::BBOX;
	trap.takedamage = true;
	trap.e.mins = { -4, -4, 0 };
	trap.e.maxs = { 4, 4, 8 };
	@trap.die = trap_die;
	trap.health = 20;
	trap.e.s.modelindex = gi_modelindex("models/weapons/z_trap/tris.md2");
	@trap.owner = self;
	@trap.teammaster = self;
	trap.nextthink = level.time + time_sec(1);
	@trap.think = Trap_Think;
	trap.classname = "food_cube_trap";
	// RAFAEL 16-APR-98
	trap.e.s.sound = gi_soundindex("weapons/traploop.wav");
	// END 16-APR-98

	trap.flags = ent_flags_t(trap.flags | ( ent_flags_t::DAMAGEABLE | ent_flags_t::MECHANICAL | ent_flags_t::TRAP ));
	trap.e.clipmask = contents_t(contents_t::MASK_PROJECTILE & ~contents_t::DEADMONSTER);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		trap.e.clipmask = contents_t(trap.e.clipmask & ~contents_t::PLAYER);

	gi_linkentity(trap.e);

	trap.timestamp = level.time + time_sec(30);
}
