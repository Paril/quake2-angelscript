
// RAFAEL
void monster_fire_blueblaster(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, monster_muzzle_t flashtype, effects_t effect)
{
	fire_blueblaster(self, start, dir, damage, speed, effect);
	monster_muzzleflash(self, start, flashtype);
}

// RAFAEL
void monster_fire_ionripper(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, monster_muzzle_t flashtype, effects_t effect)
{
	fire_ionripper(self, start, dir, damage, speed, effect);
	monster_muzzleflash(self, start, flashtype);
}

// RAFAEL
void monster_fire_heat(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, monster_muzzle_t flashtype, float turn_fraction)
{
	fire_heat(self, start, dir, damage, speed, float(damage), damage, turn_fraction);
	monster_muzzleflash(self, start, flashtype);
}

// RAFAEL
class dabeam_pierce_t : pierce_args_t
{
	ASEntity @self;
	bool damage;

	dabeam_pierce_t(ASEntity &self, bool damage)
	{
        super();
        @this.self = self;
        this.damage = damage;
	}

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
	bool hit(contents_t &mask, vec3_t &end) override
	{
        ASEntity @hit = entities[tr.ent.s.number];

		if (damage)
		{
			// hurt it if we can
			if (self.dmg > 0 && (hit.takedamage) && (hit.flags & ent_flags_t::IMMUNE_LASER) == 0 && (hit !is self.owner))
				T_Damage(hit, self, self.owner, self.movedir, tr.endpos, vec3_origin, self.dmg, skill.integer, damageflags_t::ENERGY, mod_id_t::TARGET_LASER);

			if (self.dmg < 0) // healer ray
			{
				// when player is at 100 health
				// just undo health fix
				// keeping fx
				if (hit.health < hit.max_health)
					hit.health = min(hit.max_health, hit.health - self.dmg);
			}
		}

		// if we hit something that's not a monster or player or is immune to lasers, we're done
		if ((tr.ent.svflags & svflags_t::MONSTER) == 0 && (tr.ent.client is null))
		{
			if (damage)
			{
				gi_WriteByte(svc_t::temp_entity);
				gi_WriteByte(temp_event_t::LASER_SPARKS);
				gi_WriteByte(10);
				gi_WritePosition(tr.endpos);
				gi_WriteDir(tr.plane.normal);
				gi_WriteByte(self.e.s.skinnum);
				gi_multicast(tr.endpos, multicast_t::PVS, false);
			}

			return false;
		}

		if (!mark(hit))
			return false;

		return true;
	}
};

void dabeam_update(ASEntity &self, bool damage)
{
	vec3_t start = self.e.s.origin;
	vec3_t end = start + (self.movedir * 2048);

	dabeam_pierce_t args(
		self,
		damage
    );

	pierce_trace(start, end, self, args, contents_t(contents_t::SOLID | contents_t::MONSTER | contents_t::PLAYER | contents_t::DEADMONSTER));

	self.e.s.old_origin = args.tr.endpos + (args.tr.plane.normal * 1.0f);
	gi_linkentity(self.e);
}

namespace spawnflags::dabeam
{
    const uint32 SECONDARY = 1;
    const uint32 SPAWNED = 2;
}

void beam_think(ASEntity &self)
{
	if ((self.spawnflags & spawnflags::dabeam::SECONDARY) != 0)
		@self.owner.beam2 = null;
	else
		@self.owner.beam = null;
	G_FreeEdict(self);
}

// RAFAEL
void monster_fire_dabeam(ASEntity &self, int damage, bool secondary, think_f @update_func)
{
	ASEntity @beam_ptr = secondary ? self.beam2 : self.beam;

	if (beam_ptr is null)
	{
		@beam_ptr = G_Spawn();

		beam_ptr.movetype = movetype_t::NONE;
		beam_ptr.e.solid = solid_t::NOT;
		beam_ptr.e.s.renderfx = renderfx_t(beam_ptr.e.s.renderfx | renderfx_t::BEAM);
		beam_ptr.e.s.modelindex = MODELINDEX_WORLD;
		@beam_ptr.owner = self;
		beam_ptr.dmg = damage;
		beam_ptr.e.s.frame = 2;
		beam_ptr.spawnflags = secondary ? spawnflags::dabeam::SECONDARY : spawnflags::NONE;

		if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			beam_ptr.e.s.skinnum = int(0xf3f3f1f1);
		else
			beam_ptr.e.s.skinnum = int(0xf2f2f0f0);

		@beam_ptr.think = beam_think;
		beam_ptr.e.s.sound = gi_soundindex("misc/lasfly.wav");
		@beam_ptr.postthink = update_func;

        @(secondary ? self.beam2 : self.beam) = beam_ptr;
	}

	beam_ptr.nextthink = level.time + time_ms(200);
	beam_ptr.spawnflags &= ~spawnflags::dabeam::SPAWNED;
	update_func(beam_ptr);
	dabeam_update(beam_ptr, true);
	beam_ptr.spawnflags |= spawnflags::dabeam::SPAWNED;
}