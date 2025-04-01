/*
=================
fire_hit

Used for all impact (hit/punch/slash) attacks
=================
*/
bool fire_hit(ASEntity &self, vec3_t aim, int damage, int kick)
{
	trace_t tr;
	vec3_t	forward, right, up;
	vec3_t	v;
	vec3_t	point;
	float	range;
	vec3_t	dir;

	// see if enemy is in range
	range = distance_between_boxes(self.enemy.e.absmin, self.enemy.e.absmax, self.e.absmin, self.e.absmax);
	if (range > aim.x)
		return false;

	if (!(aim.y > self.e.mins.x && aim.y < self.e.maxs.x))
	{
		// this is a side hit so adjust the "right" value out to the edge of their bbox
		if (aim.y < 0)
			aim.y = self.enemy.e.mins.x;
		else
			aim.y = self.enemy.e.maxs.x;
	}

	point = closest_point_to_box(self.e.s.origin, self.enemy.e.absmin, self.enemy.e.absmax);

	// check that we can hit the point on the bbox
	tr = gi_traceline(self.e.s.origin, point, self.e, contents_t::MASK_PROJECTILE);

	if (tr.fraction < 1)
	{
        ASEntity @hit = entities[tr.ent.s.number];
		if (!hit.takedamage)
			return false;
	}

	// check that we can hit the player from the point
	tr = gi_traceline(point, self.enemy.e.s.origin, self.e, contents_t::MASK_PROJECTILE);

    ASEntity @hit = entities[tr.ent.s.number];

	if (tr.fraction < 1)
	{
		if (!hit.takedamage)
			return false;
		// if it will hit any client/monster then hit the one we wanted to hit
		if ((hit.e.svflags & svflags_t::MONSTER) != 0 || tr.ent.client !is null)
			@hit = self.enemy;
	}

	AngleVectors(self.e.s.angles, forward, right, up);
	point = self.e.s.origin + (forward * range);
	point += (right * aim[1]);
	point += (up * aim[2]);
	dir = point - self.enemy.e.s.origin;

	// do the damage
	T_Damage(hit, self, self, dir, point, vec3_origin, damage, kick / 2, damageflags_t::NO_KNOCKBACK, mod_id_t::HIT);

	if ((hit.e.svflags & svflags_t::MONSTER) == 0 && (hit.client is null))
		return false;

	// do our special form of knockback here
	v = (self.enemy.e.absmin + self.enemy.e.absmax) * 0.5f;
	v -= point;
	v.normalize();
	self.enemy.velocity += v * kick;
	if (self.enemy.velocity[2] > 0)
		@self.enemy.groundentity = null;
	return true;
}

// we won't ever pierce more than this many entities for a single trace.
const uint MAX_PIERCE = 16;

// base class for pierce args; this stores
// the stuff we are piercing.
abstract class pierce_args_t 
{
	// stuff we pierced
	array<ASEntity@> pierced;
	array<solid_t> pierce_solidities;
	// the last trace that was done, when piercing stopped
	trace_t tr;
    bool restored = true;

	// mark entity as pierced
	bool mark(ASEntity &ent)
    {
        // ran out of pierces
        if (pierced.length() == MAX_PIERCE)
            return false;

        pierced.push_back(ent);
        pierce_solidities.push_back(solid_t(ent.e.solid));

        ent.e.solid = solid_t::NOT;
        gi_linkentity(ent.e);

        restored = false;

        return true;
    }

	// restore entities' previous solidities
	void restore()
    {
        for (uint i = 0; i < pierced.length(); i++)
        {
            ASEntity @ent = pierced[i];
            ent.e.solid = pierce_solidities[i];
            gi_linkentity(ent.e);
        }

        restored = true;
    }

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
    // AS_TODO: abstract
	/*abstract*/ bool hit(contents_t &mask, vec3_t &end) { return false; }

	~pierce_args_t()
	{
        // this is fatal and indicative of a code error
        if (!restored)
            gi_Com_Error("pierce restore was not called");
		//restore();
	}
};

// helper routine for piercing traces;
// mask = the input mask for finding what to hit
// you can adjust the mask for the re-trace (for water, etc).
// note that you must take care in your pierce callback to mark
// the entities that are being pierced.
void pierce_trace(const vec3_t &in start, const vec3_t &in end, ASEntity @ignore, pierce_args_t &pierce, contents_t mask)
{
	int	   loop_count = MAX_EDICTS;
	vec3_t own_start, own_end;
	own_start = start;
	own_end = end;

	while ((--loop_count) != 0)
	{
		pierce.tr = gi_traceline(start, own_end, ignore is null ? null : ignore.e, mask);

		// didn't hit anything, so we're done
		if (pierce.tr.ent is null || pierce.tr.fraction == 1.0f)
        {
            pierce.restore();
			return;
        }

		// hit callback said we're done
		if (!pierce.hit(mask, own_end))
        {
            pierce.restore();
			return;
        }

		own_start = pierce.tr.endpos;
	}

    pierce.restore();

	gi_Com_Print("runaway pierce_trace\n");
}

class fire_lead_pierce_t : pierce_args_t
{
	ASEntity     @self;
	vec3_t		 start;
	vec3_t		 aimdir;
	int			 damage;
	int			 kick;
	int			 hspread;
	int			 vspread;
	mod_t		 mod;
	int			 te_impact;
	contents_t   mask;
	bool	     water = false;
	vec3_t	     water_start = vec3_origin;
	ASEntity     @chain = null;

	fire_lead_pierce_t(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int hspread, int vspread, const mod_t &in mod, int te_impact, contents_t mask)
	{
        super();
    
		@this.self = self;
		this.start = start;
		this.aimdir = aimdir;
		this.damage = damage;
		this.kick = kick;
		this.hspread = hspread;
		this.vspread = vspread;
		this.mod = mod;
		this.te_impact = te_impact;
		this.mask = mask;
	}

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
	bool hit(contents_t &mask, vec3_t &end) override
	{
		// see if we hit water
		if ((tr.contents & contents_t::MASK_WATER) != 0)
		{
			splash_color_t color;

			water = true;
			water_start = tr.endpos;

			// CHECK: is this compare ever true?
			if (te_impact != -1 && start != tr.endpos)
			{
				if ((tr.contents & contents_t::WATER) != 0)
				{
					// FIXME: this effectively does nothing..
					/*if (strcmp(tr.surface->name, "brwater") == 0)
						color = splash_color_t::BROWN_WATER;
					else*/
						color = splash_color_t::BLUE_WATER;
				}
				else if ((tr.contents & contents_t::SLIME) != 0)
					color = splash_color_t::SLIME;
				else if ((tr.contents & contents_t::LAVA) != 0)
					color = splash_color_t::LAVA;
				else
					color = splash_color_t::UNKNOWN;

				if (color != splash_color_t::UNKNOWN)
				{
					gi_WriteByte(svc_t::temp_entity);
					gi_WriteByte(temp_event_t::SPLASH);
					gi_WriteByte(8);
					gi_WritePosition(tr.endpos);
					gi_WriteDir(tr.plane.normal);
					gi_WriteByte(color);
					gi_multicast(tr.endpos, multicast_t::PVS, false);
				}

				// change bullet's course when it enters water
				vec3_t dir, forward, right, up;
				dir = end - start;
				dir = vectoangles(dir);
				AngleVectors(dir, forward, right, up);
				float r = crandom() * hspread * 2;
				float u = crandom() * vspread * 2;
				end = water_start + (forward * 8192);
				end += (right * r);
				end += (up * u);
			}

			// re-trace ignoring water this time
			mask = contents_t(mask & ~contents_t::MASK_WATER);
			return true;
		}

		// did we hit an hurtable entity?
        ASEntity @hit = entities[tr.ent.s.number];

		if (hit.takedamage)
		{
			T_Damage(hit, self, self, aimdir, tr.endpos, tr.plane.normal, damage, kick, mod.id == mod_id_t::TESLA ? damageflags_t::ENERGY : damageflags_t::BULLET, mod);

			// only deadmonster is pierceable, or actual dead monsters
			// that haven't been made non-solid yet
			if ((tr.ent.svflags & svflags_t::DEADMONSTER) != 0 ||
				(hit.health <= 0 && (tr.ent.svflags & svflags_t::MONSTER) != 0))
			{
				if (!mark(hit))
					return false;

				return true;
			}
		}
		else
		{
			// send gun puff / flash
			// don't mark the sky
			if (te_impact != temp_event_t::LIGHTNING && !(tr.surface !is null && ((tr.surface.flags & surfflags_t::SKY) != 0 || Q_strncasecmp(tr.surface.name, "sky", 3) == 0)))
			{
				gi_WriteByte(svc_t::temp_entity);
				gi_WriteByte(te_impact);
				gi_WritePosition(tr.endpos);
				gi_WriteDir(tr.plane.normal);
				gi_multicast(tr.endpos, multicast_t::PVS, false);

				if (self.client !is null)
					PlayerNoise(self, tr.endpos, player_noise_t::IMPACT);
			}
		}

		// hit a solid, so we're stopping here

		return false;
	}
};

/*
=================
fire_lead

This is an internal support routine used for bullet/pellet based weapons.
=================
*/
void fire_lead(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int te_impact, int hspread, int vspread, mod_t mod)
{
	fire_lead_pierce_t args(
		self,
		start,
		aimdir,
		damage,
		kick,
		hspread,
		vspread,
		mod,
		te_impact,
		contents_t(contents_t::MASK_PROJECTILE | contents_t::MASK_WATER)
    );

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		args.mask = contents_t(args.mask & ~contents_t::PLAYER);

	// special case: we started in water.
	if ((gi_pointcontents(start) & contents_t::MASK_WATER) != 0)
	{
		args.water = true;
		args.water_start = start;
		args.mask = contents_t(args.mask & ~contents_t::MASK_WATER);
	}

	// check initial firing position
	pierce_trace(self.e.s.origin, start, self, args, args.mask);

	// we're clear, so do the second pierce
	if (args.tr.fraction == 1.0f)
	{
		vec3_t end, dir, forward, right, up;
		dir = vectoangles(aimdir);
		AngleVectors(dir, forward, right, up);

		float r = crandom() * hspread;
		float u = crandom() * vspread;
		end = start + (forward * 8192);
		end += (right * r);
		end += (up * u);

		pierce_trace(args.tr.endpos, end, self, args, args.mask);
	}

	// if went through water, determine where the end is and make a bubble trail
	if (args.water && te_impact != temp_event_t::LIGHTNING)
	{
		vec3_t pos, dir;

		dir = args.tr.endpos - args.water_start;
		dir.normalize();
		pos = args.tr.endpos + (dir * -2);
		if ((gi_pointcontents(pos) & contents_t::MASK_WATER) != 0)
			args.tr.endpos = pos;
		else
			args.tr = gi_traceline(pos, args.water_start, args.tr.ent !is world.e ? args.tr.ent : null, contents_t::WATER);

		pos = args.water_start + args.tr.endpos;
		pos *= 0.5f;

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::BUBBLETRAIL);
		gi_WritePosition(args.water_start);
		gi_WritePosition(args.tr.endpos);
		gi_multicast(pos, multicast_t::PVS, false);
	}
}

/*
=================
fire_bullet

Fires a single round.  Used for machinegun and chaingun.  Would be fine for
pistols, rifles, etc....
=================
*/
void fire_bullet(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int hspread, int vspread, mod_t mod)
{
	fire_lead(self, start, aimdir, damage, kick, mod.id == mod_id_t::TESLA ? temp_event_t::LIGHTNING : temp_event_t::GUNSHOT, hspread, vspread, mod);
}

/*
=================
fire_shotgun

Shoots shotgun pellets.  Used by shotgun and super shotgun.
=================
*/
void fire_shotgun(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int hspread, int vspread, int count, mod_t mod)
{
	for (int i = 0; i < count; i++)
		fire_lead(self, start, aimdir, damage, kick, temp_event_t::SHOTGUN, hspread, vspread, mod);
}

/*
=================
fire_blaster

Fires a single blaster bolt.  Used by the blaster and hyper blaster.
=================
*/
void blaster_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
    if (other is self.owner)
        return;

    if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
    {
        self.Free();
        return;
    }

    // PMM - crash prevention
    if (self.owner !is null && self.owner.client !is null)
    	PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

    if (other.takedamage)
    	T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::ENERGY, mod_id_t(self.style));
    else
    {
        gi_WriteByte(svc_t::temp_entity);
        gi_WriteByte( ( self.style != mod_id_t::BLUEBLASTER ) ? temp_event_t::BLASTER : temp_event_t::BLUEHYPERBLASTER );
        gi_WritePosition(self.e.s.origin);
        gi_WriteDir(tr.plane.normal);
        gi_multicast(self.e.s.origin, multicast_t::PHS, false);
    }

    self.Free();
}

ASEntity @fire_blaster(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, uint64 effect, mod_id_t mod)
{
    ASEntity @bolt = G_Spawn();
    bolt.e.svflags = svflags_t::PROJECTILE;
    bolt.e.s.origin = start;
    bolt.e.s.old_origin = start;
    bolt.e.s.angles = vectoangles(dir);
    bolt.velocity = dir * speed;
    bolt.movetype = movetype_t::FLYMISSILE;
    bolt.e.clipmask = contents_t::MASK_PROJECTILE;
    // [Paril-KEX]
    if (self.client !is null && !G_ShouldPlayersCollide(true))
        bolt.e.clipmask = contents_t(bolt.e.clipmask & ~contents_t::PLAYER);
    bolt.flags = ent_flags_t(bolt.flags | ent_flags_t::DODGE);
    bolt.e.solid = solid_t::BBOX;
    bolt.e.s.effects = effects_t(bolt.e.s.effects | effect);
    bolt.e.s.modelindex = gi_modelindex("models/objects/laser/tris.md2");
    bolt.e.s.sound = gi_soundindex("misc/lasfly.wav");
    @bolt.owner = @self;
    @bolt.touch = blaster_touch;
    bolt.nextthink = level.time + time_sec(2);
    @bolt.think = G_FreeEdict;
    bolt.dmg = damage;
    bolt.classname = "bolt";
    bolt.style = mod;
    gi_linkentity(bolt.e);

    trace_t tr = gi_traceline(self.e.s.origin, bolt.e.s.origin, bolt.e, bolt.e.clipmask);
    if (tr.fraction < 1.0f)
    {
        bolt.e.s.origin = tr.endpos + (tr.plane.normal * 1.0f);
        bolt.touch(bolt, entities[tr.ent.s.number], tr, false);
    }

    return bolt;
}

namespace spawnflags::grenade
{
    const uint32 HAND = 1;
    const uint32 HELD = 2;
}

/*
=================
fire_grenade
=================
*/
void Grenade_ExplodeReal(ASEntity &ent, ASEntity @other, const vec3_t &in normal)
{
	vec3_t origin;
	mod_t  mod;

    if (ent.owner !is null && ent.owner.client !is null)
    	PlayerNoise(ent.owner, ent.e.s.origin, player_noise_t::IMPACT);

	// FIXME: if we are onground then raise our Z just a bit since we are a point?
	if (other !is null)
	{
		vec3_t dir = other.e.s.origin - ent.e.s.origin;
		if ((ent.spawnflags & spawnflags::grenade::HAND) != 0)
			mod = mod_id_t::HANDGRENADE;
		else
			mod = mod_id_t::GRENADE;
		T_Damage(other, ent, ent.owner, dir, ent.e.s.origin, normal, ent.dmg, ent.dmg, mod.id == mod_id_t::HANDGRENADE ? damageflags_t::RADIUS : damageflags_t::NONE, mod);
	}

	if ((ent.spawnflags & spawnflags::grenade::HELD) != 0)
		mod = mod_id_t::HELD_GRENADE;
	else if ((ent.spawnflags & spawnflags::grenade::HAND) != 0)
		mod = mod_id_t::HG_SPLASH;
	else
		mod = mod_id_t::G_SPLASH;
	T_RadiusDamage(ent, ent.owner, float(ent.dmg), other, ent.dmg_radius, damageflags_t::NONE, mod);

	origin = ent.e.s.origin + normal;
	gi_WriteByte(svc_t::temp_entity);
	if (ent.waterlevel != water_level_t::NONE)
	{
		if (ent.groundentity !is null)
			gi_WriteByte(temp_event_t::GRENADE_EXPLOSION_WATER);
		else
			gi_WriteByte(temp_event_t::ROCKET_EXPLOSION_WATER);
	}
	else
	{
		if (ent.groundentity !is null)
			gi_WriteByte(temp_event_t::GRENADE_EXPLOSION);
		else
			gi_WriteByte(temp_event_t::ROCKET_EXPLOSION);
	}
	gi_WritePosition(origin);
	gi_multicast(ent.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(ent);
}

void Grenade_Explode(ASEntity &ent)
{
	Grenade_ExplodeReal(ent, null, ent.velocity * -0.02f);
}

void Grenade_Touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other is ent.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(ent);
		return;
	}

	if (!other.takedamage)
	{
		if ((ent.spawnflags & spawnflags::grenade::HAND) != 0)
		{
			if (frandom() > 0.5f)
				gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/hgrenb1a.wav"), 1, ATTN_NORM, 0);
			else
				gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/hgrenb2a.wav"), 1, ATTN_NORM, 0);
		}
		else
		{
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/grenlb1b.wav"), 1, ATTN_NORM, 0);
		}
		return;
	}

	Grenade_ExplodeReal(ent, other, tr.plane.normal);
}

void Grenade4_Think(ASEntity &self)
{
	if (level.time >= self.timestamp)
	{
		Grenade_Explode(self);
		return;
	}
	
	if (self.velocity)
	{
		float p = self.e.s.angles.x;
		float z = self.e.s.angles.z;
		float speed_frac = clamp(self.velocity.lengthSquared() / (self.speed * self.speed), 0.f, 1.f);
		self.e.s.angles = vectoangles(self.velocity);
		self.e.s.angles.x = LerpAngle(p, self.e.s.angles.x, speed_frac);
		self.e.s.angles.z = z + (gi_frame_time_s * 360 * speed_frac);
	}

	self.nextthink = level.time + FRAME_TIME_S;
}

void fire_grenade(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int speed, gtime_t timer,
                  float damage_radius, float right_adjust, float up_adjust, bool monster)
{
	ASEntity @grenade;
	vec3_t	 dir;
	vec3_t	 forward, right, up;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@grenade = G_Spawn();
	grenade.e.s.origin = start;
	grenade.velocity = aimdir * speed;

	if (up_adjust != 0)
	{
		float gravityAdjustment = level.gravity / 800.f;
		grenade.velocity += up * up_adjust * gravityAdjustment;
	}

	if (right_adjust != 0)
		grenade.velocity += right * right_adjust;

	grenade.movetype = movetype_t::BOUNCE;
	grenade.e.clipmask = contents_t::MASK_PROJECTILE;
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		grenade.e.clipmask = contents_t(grenade.e.clipmask & ~contents_t::PLAYER);
	grenade.e.solid = solid_t::BBOX;
	grenade.e.svflags = svflags_t(grenade.e.svflags | svflags_t::PROJECTILE);
	grenade.flags = ent_flags_t(grenade.flags | ( ent_flags_t::DODGE | ent_flags_t::TRAP ));
	grenade.e.s.effects = effects_t(grenade.e.s.effects | effects_t::GRENADE);
	grenade.speed = speed;
	if (monster)
	{
		grenade.avelocity = { crandom() * 360, crandom() * 360, crandom() * 360 };
		grenade.e.s.modelindex = gi_modelindex("models/objects/grenade/tris.md2");
		grenade.nextthink = level.time + timer;
		@grenade.think = Grenade_Explode;
		grenade.e.s.effects = effects_t(grenade.e.s.effects | effects_t::GRENADE_LIGHT);
	}
	else
	{
		grenade.e.s.modelindex = gi_modelindex("models/objects/grenade4/tris.md2");
		grenade.e.s.angles = vectoangles(grenade.velocity);
		grenade.nextthink = level.time + FRAME_TIME_S;
		grenade.timestamp = level.time + timer;
		@grenade.think = Grenade4_Think;
		grenade.e.s.renderfx = renderfx_t(grenade.e.s.renderfx | renderfx_t::MINLIGHT);
	}
	@grenade.owner = self;
	@grenade.touch = Grenade_Touch;
	grenade.dmg = damage;
	grenade.dmg_radius = damage_radius;
	grenade.classname = "grenade";

	gi_linkentity(grenade.e);
}

void fire_grenade2(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int speed, gtime_t timer, float damage_radius, bool held)
{
	ASEntity @grenade;
	vec3_t	 dir;
	vec3_t	 forward, right, up;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@grenade = G_Spawn();
	grenade.e.s.origin = start;
	grenade.velocity = aimdir * speed;

	float gravityAdjustment = level.gravity / 800.0f;

	grenade.velocity += up * (200 + crandom() * 10.0f) * gravityAdjustment;
	grenade.velocity += right * (crandom() * 10.0f);

	grenade.avelocity = { crandom() * 360, crandom() * 360, crandom() * 360 };
	grenade.movetype = movetype_t::BOUNCE;
	grenade.e.clipmask = contents_t::MASK_PROJECTILE;
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		grenade.e.clipmask = contents_t(grenade.e.clipmask & ~contents_t::PLAYER);
	grenade.e.solid = solid_t::BBOX;
	grenade.e.svflags = svflags_t(grenade.e.svflags | svflags_t::PROJECTILE);
	grenade.flags = ent_flags_t(grenade.flags | ( ent_flags_t::DODGE | ent_flags_t::TRAP ));
	grenade.e.s.effects = effects_t(grenade.e.s.effects | effects_t::GRENADE);

	grenade.e.s.modelindex = gi_modelindex("models/objects/grenade3/tris.md2");
	@grenade.owner = self;
	@grenade.touch = Grenade_Touch;
	grenade.nextthink = level.time + timer;
	@grenade.think = Grenade_Explode;
	grenade.dmg = damage;
	grenade.dmg_radius = damage_radius;
	grenade.classname = "hand_grenade";
	grenade.spawnflags = spawnflags::grenade::HAND;
	if (held)
		grenade.spawnflags |= spawnflags::grenade::HELD;
	grenade.e.s.sound = gi_soundindex("weapons/hgrenc1b.wav");

	if (timer <= time_zero)
		Grenade_Explode(grenade);
	else
	{
		gi_sound(self.e, soundchan_t::WEAPON, gi_soundindex("weapons/hgrent1a.wav"), 1, ATTN_NORM, 0);
		gi_linkentity(grenade.e);
	}
}


/*
=================
fire_rocket
=================
*/
void rocket_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
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
		T_Damage(other, ent, ent.owner, ent.velocity, ent.e.s.origin, tr.plane.normal, ent.dmg, ent.dmg, damageflags_t::NONE, mod_id_t::ROCKET);
	}
	else
	{
		// don't throw any debris in net games
		if (deathmatch.integer == 0 && coop.integer == 0)
		{
			if (tr.surface !is null && (tr.surface.flags & (surfflags_t::WARP | surfflags_t::TRANS33 | surfflags_t::TRANS66 | surfflags_t::FLOWING)) == 0)
			{
				ThrowGibs(ent, 2, {
					gib_def_t(irandom(5), "models/objects/debris2/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
				});
			}
		}
	}

	T_RadiusDamage(ent, ent.owner, float(ent.radius_dmg), other, ent.dmg_radius, damageflags_t::NONE, mod_id_t::R_SPLASH);

	gi_WriteByte(svc_t::temp_entity);
	if (ent.waterlevel != water_level_t::NONE)
		gi_WriteByte(temp_event_t::ROCKET_EXPLOSION_WATER);
	else
		gi_WriteByte(temp_event_t::ROCKET_EXPLOSION);
	gi_WritePosition(origin);
	gi_multicast(ent.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(ent);
}

ASEntity @fire_rocket(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, float damage_radius, int radius_damage)
{
	ASEntity @rocket;

	@rocket = G_Spawn();
	rocket.e.s.origin = start;
	rocket.e.s.angles = vectoangles(dir);
	rocket.velocity = dir * speed;
	rocket.movetype = movetype_t::FLYMISSILE;
	rocket.e.svflags = svflags_t(rocket.e.svflags | svflags_t::PROJECTILE);
	rocket.flags = ent_flags_t(rocket.flags | ent_flags_t::DODGE);
	rocket.e.clipmask = contents_t::MASK_PROJECTILE;
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		rocket.e.clipmask = contents_t(rocket.e.clipmask & ~contents_t::PLAYER);
	rocket.e.solid = solid_t::BBOX;
	rocket.e.s.effects = effects_t(rocket.e.s.effects | effects_t::ROCKET);
	rocket.e.s.modelindex = gi_modelindex("models/objects/rocket/tris.md2");
	@rocket.owner = self;
	@rocket.touch = rocket_touch;
	rocket.nextthink = level.time + time_sec(8000.f / speed);
	@rocket.think = G_FreeEdict;
	rocket.dmg = damage;
	rocket.radius_dmg = radius_damage;
	rocket.dmg_radius = damage_radius;
	rocket.e.s.sound = gi_soundindex("weapons/rockfly.wav");
	rocket.classname = "rocket";

	gi_linkentity(rocket.e);

	return rocket;
}

funcdef bool search_callback_t(const vec3_t &in, const vec3_t &in, bool);

bool binary_positional_search_r(const vec3_t &in viewer, const vec3_t &in start, const vec3_t &in end, search_callback_t @cb, int32 split_num)
{
	// check half-way point
	vec3_t mid = (start + end) * 0.5f;

	if (cb(viewer, mid, true))
		return true;

	// no more splits
	if (split_num == 0)
		return false;

	// recursively check both sides
	return binary_positional_search_r(viewer, start, mid, cb, split_num - 1) || binary_positional_search_r(viewer, mid, end, cb, split_num - 1);
}

// [Paril-KEX] simple binary search through a line to see if any points along
// the line (in a binary split) pass the callback
bool binary_positional_search(const vec3_t &in viewer, const vec3_t &in start, const vec3_t &in end, search_callback_t @cb, int32 num_splits)
{
	// check start/end first
	if (cb(viewer, start, true) || cb(viewer, end, true))
		return true;

	// recursive split
	return binary_positional_search_r(viewer, start, end, cb, num_splits);
}

class fire_rail_pierce_t : pierce_args_t
{
	ASEntity @self;
	vec3_t	 aimdir;
	int		 damage;
	int		 kick;
	bool	 water = false;

	fire_rail_pierce_t(ASEntity @self, const vec3_t &in aimdir, int damage, int kick)
	{
		super();
		@this.self = self;
		this.aimdir = aimdir;
		this.damage = damage;
		this.kick = kick;
	}

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
	bool hit(contents_t &mask, vec3_t &end) override
	{
        ASEntity @hit = entities[tr.ent.s.number];

		if ((tr.contents & (contents_t::SLIME | contents_t::LAVA)) != 0)
		{
			mask = contents_t(mask & ~(contents_t::SLIME | contents_t::LAVA));
			water = true;
			return true;
		}
		else
		{
			// try to kill it first
			if ((hit !is self) && (hit.takedamage))
				T_Damage(hit, self, self, aimdir, tr.endpos, tr.plane.normal, damage, kick, damageflags_t::NONE, mod_id_t::RAILGUN);

			// dead, so we don't need to care about checking pierce
			if (!tr.ent.inuse || (tr.ent.solid == solid_t::NOT || tr.ent.solid == solid_t::TRIGGER))
				return true;

			// ZOID--added so rail goes through SOLID_BBOX entities (gibs, etc)
			if ((tr.ent.svflags & svflags_t::MONSTER) != 0 || (tr.ent.client !is null) ||
				// ROGUE
				(hit.flags & ent_flags_t::DAMAGEABLE) != 0 ||
				// ROGUE
				(tr.ent.solid == solid_t::BBOX))
			{
				if (!mark(hit))
					return false;

				return true;
			}
		}

		return false;
	}
};

/*
=================
fire_rail
=================
*/
bool fire_rail(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick)
{
	fire_rail_pierce_t args(
		self,
		aimdir,
		damage,
		kick
    );

	contents_t mask = contents_t(contents_t::MASK_PROJECTILE | contents_t::SLIME | contents_t::LAVA);
	
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		mask = contents_t(mask & ~contents_t::PLAYER);

	vec3_t end = start + (aimdir * 8192);

	pierce_trace(start, end, self, args, mask);

	uint32 unicast_key = GetUnicastKey();

	// send gun puff / flash
	// [Paril-KEX] this often makes double noise, so trying
	// a slightly different approach...
    foreach (ASEntity @player : active_players)
    {
		vec3_t org = player.e.s.origin + player.e.client.ps.viewoffset + vec3_t(0, 0, float(player.e.client.ps.pmove.viewheight));

		if (binary_positional_search(org, start, args.tr.endpos, gi_inPHS, 3))
		{
			gi_WriteByte(svc_t::temp_entity);
			gi_WriteByte((deathmatch.integer != 0 && g_instagib.integer != 0) ? temp_event_t::RAILTRAIL2 : temp_event_t::RAILTRAIL);
			gi_WritePosition(start);
			gi_WritePosition(args.tr.endpos);
			gi_unicast(player.e, false, unicast_key);
		}
	}

	if (self.client !is null)
		PlayerNoise(self, args.tr.endpos, player_noise_t::IMPACT);

	return args.pierced.length() != 0;
}

vec3_t bfg_laser_pos(const vec3_t &in p, float dist)
{
	float theta = frandom(2 * PIf);
	float phi = acos(crandom());

	vec3_t d(
		sin(phi) * cos(theta),
		sin(phi) * sin(theta),
		cos(phi)
    );

	return p + (d * dist);
}

void bfg_laser_update(ASEntity &self)
{
	if (level.time > self.timestamp || !self.owner.e.inuse)
	{
		G_FreeEdict(self);
		return;
	}

	self.e.s.origin = self.owner.e.s.origin;
	self.nextthink = level.time + time_ms(1);
	gi_linkentity(self.e);
}

void bfg_spawn_laser(ASEntity &self)
{
	vec3_t end = bfg_laser_pos(self.e.s.origin, 256);
	trace_t tr = gi_traceline(self.e.s.origin, end, self.e, contents_t(contents_t::MASK_OPAQUE | contents_t::PROJECTILECLIP));

	if (tr.fraction == 1.0f)
		return;

	ASEntity @laser = G_Spawn();
	laser.e.s.frame = 3;
	laser.e.s.renderfx = renderfx_t::BEAM_LIGHTNING;
	laser.movetype = movetype_t::NONE;
	laser.e.solid = solid_t::NOT;
	laser.e.s.modelindex = MODELINDEX_WORLD; // must be non-zero
	laser.e.s.origin = self.e.s.origin;
	laser.e.s.old_origin = tr.endpos;
	laser.e.s.skinnum = int(0xD0D0D0D0);
	@laser.think = bfg_laser_update;
	laser.nextthink = level.time + time_ms(1);
	laser.timestamp = level.time + time_ms(300);
	@laser.owner = self;
	gi_linkentity(laser.e);
}

/*
=================
fire_bfg
=================
*/
void bfg_explode(ASEntity &self)
{
	ASEntity @ent;
	float	 points;
	vec3_t	 v;
	float	 dist;

	bfg_spawn_laser(self);

	if (self.e.s.frame == 0)
	{
		// the BFG effect
		@ent = null;
		while ((@ent = findradius(ent, self.e.s.origin, self.dmg_radius)) !is null)
		{
			if (!ent.takedamage)
				continue;
			if (ent is self.owner)
				continue;
			if (!CanDamage(ent, self))
				continue;
			if (!CanDamage(ent, self.owner))
				continue;
			// ROGUE - make tesla hurt by bfg
			if ((ent.e.svflags & svflags_t::MONSTER) == 0 && (ent.flags & ent_flags_t::DAMAGEABLE) == 0 &&
                (ent.client is null) && (ent.classname != "misc_explobox"))
				continue;
			// ZOID
			// don't target players in CTF
			if (CheckTeamDamage(ent, self.owner))
				continue;
			// ZOID

			v = ent.e.mins + ent.e.maxs;
			v = ent.e.s.origin + (v * 0.5f);
			vec3_t centroid = v;
			v = self.e.s.origin - centroid;
			dist = v.length();
			points = self.radius_dmg * (1.0f - sqrt(dist / self.dmg_radius));

			T_Damage(ent, self, self.owner, self.velocity, centroid, vec3_origin, int(points), 0, damageflags_t::ENERGY, mod_id_t::BFG_EFFECT);

			// Paril: draw BFG lightning laser to enemies
			gi_WriteByte(svc_t::temp_entity);
			gi_WriteByte(temp_event_t::BFG_ZAP);
			gi_WritePosition(self.e.s.origin);
			gi_WritePosition(centroid);
			gi_multicast(self.e.s.origin, multicast_t::PHS, false);
		}
	}

	self.nextthink = level.time + time_hz(10);
	self.e.s.frame++;
	if (self.e.s.frame == 5)
		@self.think = G_FreeEdict;
}

void bfg_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
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

	// core explosion - prevents firing it into the wall/floor
	if (other.takedamage)
		T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, 200, 0, damageflags_t::ENERGY, mod_id_t::BFG_BLAST);
	T_RadiusDamage(self, self.owner, 200, other, 100, damageflags_t::ENERGY, mod_id_t::BFG_BLAST);

	gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("weapons/bfg__x1b.wav"), 1, ATTN_NORM, 0);
	self.e.solid = solid_t::NOT;
	@self.touch = null;
	self.e.s.origin += self.velocity * (-1 * gi_frame_time_s);
	self.velocity = vec3_origin;
	self.e.s.modelindex = gi_modelindex("sprites/s_bfg3.sp2");
	self.e.s.frame = 0;
	self.e.s.sound = 0;
	self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::ANIM_ALLFAST);
	@self.think = bfg_explode;
	self.nextthink = level.time + time_hz(10);
	@self.enemy = other;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::BFG_BIGEXPLOSION);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);
}

class bfg_laser_pierce_t : pierce_args_t
{
	ASEntity @self;
	vec3_t	 dir;
	int		 damage;

	bfg_laser_pierce_t(ASEntity &self, const vec3_t &in dir, int damage)
	{
		super();
		@this.self = self;
		this.dir = dir;
		this.damage = damage;
	}

	// we hit an entity; return false to stop the piercing.
	// you can adjust the mask for the re-trace (for water, etc).
	bool hit(contents_t &mask, vec3_t &end) override
	{
        ASEntity @hit = entities[tr.ent.s.number];

		// hurt it if we can
		if ((hit.takedamage) && (hit.flags & ent_flags_t::IMMUNE_LASER) == 0 && (tr.ent !is self.e.owner))
			T_Damage(hit, self, self.owner, dir, tr.endpos, vec3_origin, damage, 1, damageflags_t::ENERGY, mod_id_t::BFG_LASER);

		// if we hit something that's not a monster or player we're done
		if ((tr.ent.svflags & svflags_t::MONSTER) == 0 && (hit.flags & ent_flags_t::DAMAGEABLE) == 0 && (tr.ent.client is null))
		{
			gi_WriteByte(svc_t::temp_entity);
			gi_WriteByte(temp_event_t::LASER_SPARKS);
			gi_WriteByte(4);
			gi_WritePosition(tr.endpos + tr.plane.normal);
			gi_WriteDir(tr.plane.normal);
			gi_WriteByte(208);
			gi_multicast(tr.endpos + tr.plane.normal, multicast_t::PVS, false);
			return false;
		}

		if (!mark(hit))
			return false;
		
		return true;
	}
};

void bfg_think(ASEntity &self)
{
	ASEntity @ent;
	vec3_t	 point;
	vec3_t	 dir;
	vec3_t	 start;
	vec3_t	 end;
	int		 dmg;
	trace_t	 tr;

	if (deathmatch.integer != 0)
		dmg = 5;
	else
		dmg = 10;

	bfg_spawn_laser(self);

	@ent = null;
	while ((@ent = findradius(ent, self.e.s.origin, 256)) !is null)
	{
		if (ent is self)
			continue;

		if (ent is self.owner)
			continue;

		if (!ent.takedamage)
			continue;

		// ROGUE - make tesla hurt by bfg
		if ((ent.e.svflags & svflags_t::MONSTER) == 0 && (ent.flags & ent_flags_t::DAMAGEABLE) == 0 &&
            (ent.client is null) && (ent.classname != "misc_explobox"))
			continue;
		// ZOID
		// don't target players in CTF
		if (CheckTeamDamage(ent, self.owner))
			continue;
		// ZOID

		point = (ent.e.absmin + ent.e.absmax) * 0.5f;

		dir = point - self.e.s.origin;
		dir.normalize();

		start = self.e.s.origin;
		end = start + (dir * 2048);

		// [Paril-KEX] don't fire a laser if we're blocked by the world
		tr = gi_traceline(start, point, null, contents_t(contents_t::SOLID | contents_t::PROJECTILECLIP));

		if (tr.fraction < 1.0f)
			continue;

		tr = gi_traceline(start, end, null, contents_t(contents_t::SOLID | contents_t::PROJECTILECLIP));

		bfg_laser_pierce_t args(
			self,
			dir,
			dmg
        );
		
		pierce_trace(start, end, self, args, contents_t(contents_t::SOLID | contents_t::MONSTER | contents_t::PLAYER | contents_t::DEADMONSTER | contents_t::PROJECTILECLIP));

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::BFG_LASER);
		gi_WritePosition(self.e.s.origin);
		gi_WritePosition(tr.endpos);
		gi_multicast(self.e.s.origin, multicast_t::PHS, false);
	}

	self.nextthink = level.time + time_hz(10);
}

void fire_bfg(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, float damage_radius)
{
	ASEntity @bfg;

	@bfg = G_Spawn();
	bfg.e.s.origin = start;
	bfg.e.s.angles = vectoangles(dir);
	bfg.velocity = dir * speed;
	bfg.movetype = movetype_t::FLYMISSILE;
	bfg.e.clipmask = contents_t::MASK_PROJECTILE;
	bfg.e.svflags = svflags_t::PROJECTILE;
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		bfg.e.clipmask = contents_t(bfg.e.clipmask & ~contents_t::PLAYER);
	bfg.e.solid = solid_t::BBOX;
	bfg.e.s.effects = effects_t(bfg.e.s.effects | effects_t::BFG | effects_t::ANIM_ALLFAST);
	bfg.e.s.modelindex = gi_modelindex("sprites/s_bfg1.sp2");
	@bfg.owner = self;
	@bfg.touch = bfg_touch;
	bfg.nextthink = level.time + time_sec(8000.f / speed);
	bfg.radius_dmg = damage;
	bfg.dmg_radius = damage_radius;
	bfg.classname = "bfg blast";
	bfg.e.s.sound = gi_soundindex("weapons/bfg__l1a.wav");

	@bfg.think = bfg_think;
	bfg.nextthink = level.time + FRAME_TIME_S;
	@bfg.teammaster = bfg;
	@bfg.teamchain = null;

	gi_linkentity(bfg.e);
}