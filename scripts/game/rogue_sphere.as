// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
// g_sphere.c
// pmack
// april 1998

// defender - actively finds and shoots at enemies
// hunter - waits until < 25% health and vore ball tracks person who hurt you
// vengeance - kills person who killed you.

namespace spawnflags::sphere
{
    const uint DEFENDER_VALUE = 0x0001;
    const uint HUNTER_VALUE = 0x0002;
    const uint VENGEANCE_VALUE = 0x0004;

    const spawnflags_t DEFENDER = spawnflag_dec(DEFENDER_VALUE);
    const spawnflags_t HUNTER = spawnflag_dec(HUNTER_VALUE);
    const spawnflags_t VENGEANCE = spawnflag_dec(VENGEANCE_VALUE);
    const spawnflags_t DOPPLEGANGER = spawnflag_dec(0x10000);

    const spawnflags_t MASK_TYPE = DEFENDER | HUNTER | VENGEANCE;
    const spawnflags_t MASK_FLAGS = DOPPLEGANGER;
}

const gtime_t DEFENDER_LIFESPAN = time_sec(30);
const gtime_t HUNTER_LIFESPAN = time_sec(30);
const gtime_t VENGEANCE_LIFESPAN = time_sec(30);
const gtime_t MINIMUM_FLY_TIME = time_sec(15);

// *************************
// General Sphere Code
// *************************

// =================
// =================
void sphere_think_explode(ASEntity &self)
{
	if (self.owner !is null && self.owner.client !is null && !self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		@self.owner.client.owned_sphere = null;
	}
	BecomeExplosion1(self);
}

// =================
// sphere_explode
// =================
void sphere_explode (ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	sphere_think_explode(self);
}

// =================
// sphere_if_idle_die - if the sphere is not currently attacking, blow up.
// =================
void sphere_if_idle_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.enemy is null)
		sphere_think_explode(self);
}

// *************************
// Sphere Movement
// *************************

// =================
// =================
void sphere_fly(ASEntity &self)
{
	vec3_t dest;
	vec3_t dir;

	if (level.time >= time_sec(self.wait))
	{
		sphere_think_explode(self);
		return;
	}

	dest = self.owner.e.origin;
	dest[2] = self.owner.e.absmax[2] + 4;

    // this looks weird, but it's basically a cheap check for
    // a check every second
	if (level.time.secondsf() == level.time.secondsi())
	{
		if (!visible(self, self.owner))
		{
			self.e.origin = dest;
			gi_linkentity(self.e);
			return;
		}
	}

	dir = dest - self.e.origin;
	self.velocity = dir * 5;
}

// =================
// =================
void sphere_chase(ASEntity &self, bool stupidChase)
{
	vec3_t dest;
	vec3_t dir;
	float  dist;

	if (level.time >= time_sec(self.wait) || (self.enemy !is null && self.enemy.health < 1))
	{
		sphere_think_explode(self);
		return;
	}

	dest = self.enemy.e.origin;
	if (self.enemy.client !is null)
		dest[2] += self.enemy.viewheight;

	if (visible(self, self.enemy) || stupidChase)
	{
		// if moving, hunter sphere uses active sound
		if (!stupidChase)
			self.e.sound = gi_soundindex("spheres/h_active.wav");

		dir = dest - self.e.origin;
		dir.normalize();
		self.e.angles = vectoangles(dir);
		self.velocity = dir * 500;
		self.monsterinfo.saved_goal = dest;
	}
	else if (!self.monsterinfo.saved_goal)
	{
		dir = self.enemy.e.origin - self.e.origin;
		dist = dir.normalize();
		self.e.angles = vectoangles(dir);

		// if lurking, hunter sphere uses lurking sound
		self.e.sound = gi_soundindex("spheres/h_lurk.wav");
		self.velocity = vec3_origin;
	}
	else
	{
		dir = self.monsterinfo.saved_goal - self.e.origin;
		dist = dir.normalize();

		if (dist > 1)
		{
			self.e.angles = vectoangles(dir);

			if (dist > 500)
				self.velocity = dir * 500;
			else if (dist < 20)
				self.velocity = dir * (dist / gi_frame_time_s);
			else
				self.velocity = dir * dist;

			// if moving, hunter sphere uses active sound
			if (!stupidChase)
				self.e.sound = gi_soundindex("spheres/h_active.wav");
		}
		else
		{
			dir = self.enemy.e.origin - self.e.origin;
			dist = dir.normalize();
			self.e.angles = vectoangles(dir);

			// if not moving, hunter sphere uses lurk sound
			if (!stupidChase)
				self.e.sound = gi_soundindex("spheres/h_lurk.wav");

			self.velocity = vec3_origin;
		}
	}
}

// *************************
// Attack related stuff
// *************************

// =================
// =================
void sphere_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, const mod_t &in mod)
{
	if (self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		if (other is self.teammaster)
			return;

		self.takedamage = false;
		@self.owner = self.teammaster;
		@self.teammaster = null;
	}
	else
	{
		if (other is self.owner)
			return;
		// PMM - don't blow up on bodies
		if (other.classname == "bodyque")
			return;
	}

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.owner !is null)
	{
		if (other.takedamage)
		{
			T_Damage(other, self, self.owner, self.velocity, self.e.origin, tr.plane.normal,
					 10000, 1, damageflags_t::DESTROY_ARMOR, mod);
		}
		else
		{
			T_RadiusDamage(self, self.owner, 512, self.owner, 256, damageflags_t::NONE, mod);
		}
	}

	sphere_think_explode(self);
}

// =================
// =================
void vengeance_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
		sphere_touch(self, other, tr, mod_id_t::DOPPLE_VENGEANCE);
	else
		sphere_touch(self, other, tr, mod_id_t::VENGEANCE_SPHERE);
}

// =================
// =================
void hunter_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @owner;

	// don't blow up if you hit the world.... sheesh.
	if (other is world)
		return;

	if (self.owner !is null)
	{
		// if owner is flying with us, make sure they stop too.
		@owner = self.owner;
		if ((owner.flags & ent_flags_t::SAM_RAIMI) != 0)
		{
			owner.velocity = vec3_origin;
			owner.movetype = movetype_t::NONE;
			gi_linkentity(owner.e);
		}
	}

	if (self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
		sphere_touch(self, other, tr, mod_id_t::DOPPLE_HUNTER);
	else
		sphere_touch(self, other, tr, mod_id_t::HUNTER_SPHERE);
}

// =================
// =================
void defender_shoot(ASEntity &self, ASEntity &enemy)
{
	vec3_t dir;
	vec3_t start;

	if (!(enemy.e.inuse) || enemy.health <= 0)
		return;

	if (enemy is self.owner)
		return;

	dir = enemy.e.origin - self.e.origin;
	dir.normalize();

	if (self.monsterinfo.attack_finished > level.time)
		return;

	if (!visible(self, self.enemy))
		return;

	start = self.e.origin;
	start[2] += 2;
	fire_blaster2(self.owner, start, dir, 10, 1000, effects_t::BLASTER, false);

	self.monsterinfo.attack_finished = level.time + time_ms(400);
}

// *************************
// Activation Related Stuff
// *************************

// =================
// =================
void body_gib(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
	ThrowGibs(self, 50, {
		gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t("models/objects/gibs/skull/tris.md2")
	});
}

// =================
// =================
void hunter_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	ASEntity @owner;
	float	 dist;
	vec3_t	 dir;

	if (self.enemy !is null)
		return;

	@owner = self.owner;

	if (!self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		if (owner !is null && (owner.health > 0))
			return;

		// PMM
		if (other is owner)
			return;
		// pmm
	}
	else
	{
		// if fired by a doppleganger, set it to 10 second timeout
		self.wait = (level.time + MINIMUM_FLY_TIME).secondsf();
	}

	if ((time_sec(self.wait) - level.time) < MINIMUM_FLY_TIME)
		self.wait = (level.time + MINIMUM_FLY_TIME).secondsf();
	self.e.effects = effects_t(self.e.effects | effects_t::BLASTER | effects_t::TRACKER);
	@self.touch = hunter_touch;
	@self.enemy = other;

	// if we're not owned by a player, no sam raimi
	// if we're spawned by a doppleganger, no sam raimi
	if (self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER) || !(owner !is null && owner.client !is null))
		return;

	// sam raimi cam is disabled if FORCE_RESPAWN is set.
	// sam raimi cam is also disabled if huntercam->value is 0.
	if (g_dm_force_respawn.integer == 0 && huntercam.integer != 0)
	{
		dir = other.e.origin - self.e.origin;
		dist = dir.length();

		if (owner !is null && (dist >= 192))
		{
			// detach owner from body and send him flying
			owner.movetype = movetype_t::FLYMISSILE;

			// gib like we just died, even though we didn't, really.
			body_gib(owner);

			// move the sphere to the owner's current viewpoint.
			// we know it's a valid spot (or will be momentarily)
			self.e.origin = owner.e.origin;
			self.e.origin.z += owner.viewheight;

			// move the player's origin to the sphere's new origin
			owner.e.origin = self.e.origin;
			owner.e.angles = self.e.angles;
			owner.client.v_angle = self.e.angles;
			owner.e.mins = { -5, -5, -5 };
			owner.e.maxs = { 5, 5, 5 };
			owner.e.client.ps.fov = 140;
			owner.e.modelindex = 0;
			owner.e.modelindex2 = 0;
			owner.viewheight = 8;
			owner.e.solid = solid_t::NOT;
			owner.flags = ent_flags_t(owner.flags | ent_flags_t::SAM_RAIMI);
			gi_linkentity(owner.e);

			self.e.solid = solid_t::BBOX;
			gi_linkentity(self.e);
		}
	}
}

// =================
// =================
void defender_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	// PMM
	if (other is self.owner)
		return;

	// pmm
	@self.enemy = other;
}

// =================
// =================
void vengeance_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (self.enemy !is null)
		return;

	if (!self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		if (self.owner !is null && self.owner.health >= 25)
			return;

		// PMM
		if (other is self.owner)
			return;
		// pmm
	}
	else
	{
		self.wait = (level.time + MINIMUM_FLY_TIME).secondsf();
	}

	if ((time_sec(self.wait) - level.time) < MINIMUM_FLY_TIME)
		self.wait = (level.time + MINIMUM_FLY_TIME).secondsf();
	self.e.effects = effects_t(self.e.effects | effects_t::ROCKET);
	@self.touch = vengeance_touch;
	@self.enemy = other;
}

// *************************
// Think Functions
// *************************

// ===================
// ===================
void defender_think(ASEntity &self)
{
	if (self.owner is null)
	{
		G_FreeEdict(self);
		return;
	}

	// if we've exited the level, just remove ourselves.
	if (level.intermissiontime)
	{
		sphere_think_explode(self);
		return;
	}

	if (self.owner.health <= 0)
	{
		sphere_think_explode(self);
		return;
	}

	self.e.frame++;
	if (self.e.frame > 19)
		self.e.frame = 0;

	if (self.enemy !is null)
	{
		if (self.enemy.health > 0)
			defender_shoot(self, self.enemy);
		else
			@self.enemy = null;
	}

	sphere_fly(self);

	if (self.e.inuse)
		self.nextthink = level.time + time_hz(10);
}

// =================
// =================
void hunter_think(ASEntity &self)
{
	// if we've exited the level, just remove ourselves.
	if (level.intermissiontime)
	{
		sphere_think_explode(self);
		return;
	}

	ASEntity @owner = self.owner;

	if (owner is null && !self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		G_FreeEdict(self);
		return;
	}

	if (owner !is null)
		self.ideal_yaw = owner.e.angles.yaw;
	else if (self.enemy !is null) // fired by doppleganger
	{
		vec3_t dir = self.enemy.e.origin - self.e.origin;
		self.ideal_yaw = vectoyaw(dir);
	}

	M_ChangeYaw(self);

	if (self.enemy !is null)
	{
		sphere_chase(self, false);

		// deal with sam raimi cam
		if (owner !is null && (owner.flags & ent_flags_t::SAM_RAIMI) != 0)
		{
			if (self.e.inuse)
			{
				LookAtKiller(owner, self, self.enemy);
				// owner is flying with us, move him too
				owner.movetype = movetype_t::FLYMISSILE;
				owner.viewheight = int(self.e.origin.z - owner.e.origin.z);
				owner.e.origin = self.e.origin;
				owner.velocity = self.velocity;
				owner.e.mins = vec3_origin;
				owner.e.maxs = vec3_origin;
				gi_linkentity(owner.e);
			}
			else // sphere timed out
			{
				owner.velocity = vec3_origin;
				owner.movetype = movetype_t::NONE;
				gi_linkentity(owner.e);
			}
		}
	}
	else
		sphere_fly(self);

	if (self.e.inuse)
		self.nextthink = level.time + time_hz(10);
}

// =================
// =================
void vengeance_think(ASEntity &self)
{
	// if we've exited the level, just remove ourselves.
	if (level.intermissiontime)
	{
		sphere_think_explode(self);
		return;
	}

	if (self.owner is null && !self.spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
	{
		G_FreeEdict(self);
		return;
	}

	if (self.enemy !is null)
		sphere_chase(self, true);
	else
		sphere_fly(self);

	if (self.e.inuse)
		self.nextthink = level.time + time_hz(10);
}

// *************************
// Spawning / Creation
// *************************

// monsterinfo_t
// =================
// =================
ASEntity @Sphere_Spawn(ASEntity &owner, const spawnflags_t &in spawnflags)
{
	ASEntity @sphere;

	@sphere = G_Spawn();
	sphere.e.origin = owner.e.origin;
	sphere.e.origin[2] = owner.e.absmax[2];
	sphere.e.angles.yaw = owner.e.angles.yaw;
	sphere.e.solid = solid_t::BBOX;
	sphere.e.clipmask = contents_t::MASK_PROJECTILE;
	sphere.e.renderfx = renderfx_t(renderfx_t::FULLBRIGHT | renderfx_t::IR_VISIBLE);
	sphere.movetype = movetype_t::FLYMISSILE;

	if (spawnflags.has(spawnflags::sphere::DOPPLEGANGER))
		@sphere.teammaster = owner.teammaster;
	else
		@sphere.owner = owner;

	sphere.classname = "sphere";
	sphere.yaw_speed = 40;
	sphere.monsterinfo.attack_finished = time_zero;
	sphere.spawnflags = spawnflags; // need this for the HUD to recognize sphere
	// PMM
	sphere.takedamage = false;

	switch (uint(spawnflags & spawnflags::sphere::MASK_TYPE))
	{
	case spawnflags::sphere::DEFENDER_VALUE:
		sphere.e.modelindex = gi_modelindex("models/items/defender/tris.md2");
		sphere.e.modelindex2 = gi_modelindex("models/items/shell/tris.md2");
		sphere.e.sound = gi_soundindex("spheres/d_idle.wav");
		@sphere.pain = defender_pain;
		sphere.wait = (level.time + DEFENDER_LIFESPAN).secondsf();
		@sphere.die = sphere_explode;
		@sphere.think = defender_think;
		break;
	case spawnflags::sphere::HUNTER_VALUE:
		sphere.e.modelindex = gi_modelindex("models/items/hunter/tris.md2");
		sphere.e.sound = gi_soundindex("spheres/h_idle.wav");
		sphere.wait = (level.time + HUNTER_LIFESPAN).secondsf();
		@sphere.pain = hunter_pain;
		@sphere.die = sphere_if_idle_die;
		@sphere.think = hunter_think;
		break;
	case spawnflags::sphere::VENGEANCE_VALUE:
		sphere.e.modelindex = gi_modelindex("models/items/vengnce/tris.md2");
		sphere.e.sound = gi_soundindex("spheres/v_idle.wav");
		sphere.wait = (level.time + VENGEANCE_LIFESPAN).secondsf();
		@sphere.pain = vengeance_pain;
		@sphere.die = sphere_if_idle_die;
		@sphere.think = vengeance_think;
		sphere.avelocity = { 30, 30, 0 };
		break;
	default:
		gi_Com_Print("Tried to create an invalid sphere\n");
		G_FreeEdict(sphere);
		return null;
	}

	sphere.nextthink = level.time + time_hz(10);

	gi_linkentity(sphere.e);

	return sphere;
}

// =================
// Own_Sphere - attach the sphere to the client so we can
//		directly access it later
// =================
void Own_Sphere(ASEntity &self, ASEntity @sphere)
{
	if (sphere is null)
		return;

	// ownership only for players
	if (self.client !is null)
	{
		// if they don't have one
		if (self.client.owned_sphere is null)
		{
			@self.client.owned_sphere = sphere;
		}
		// they already have one, take care of the old one
		else
		{
			if (self.client.owned_sphere.e.inuse)
			{
				G_FreeEdict(self.client.owned_sphere);
				@self.client.owned_sphere = sphere;
			}
			else
			{
				@self.client.owned_sphere = sphere;
			}
		}
	}
}

// =================
// =================
void Defender_Launch(ASEntity &self)
{
	ASEntity @sphere;

	@sphere = Sphere_Spawn(self, spawnflags::sphere::DEFENDER);
	Own_Sphere(self, sphere);
}

// =================
// =================
void Hunter_Launch(ASEntity &self)
{
	ASEntity @sphere;

	@sphere = Sphere_Spawn(self, spawnflags::sphere::HUNTER);
	Own_Sphere(self, sphere);
}

// =================
// =================
void Vengeance_Launch(ASEntity &self)
{
	ASEntity @sphere;

	@sphere = Sphere_Spawn(self, spawnflags::sphere::VENGEANCE);
	Own_Sphere(self, sphere);
}
