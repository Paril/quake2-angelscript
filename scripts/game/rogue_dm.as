void doppleganger_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	ASEntity @sphere;
	float	 dist;
	vec3_t	 dir;

	if ((self.enemy !is null) && (self.enemy !is self.teammaster))
	{
		dir = self.enemy.e.origin - self.e.origin;
		dist = dir.length();

		if (dist > 80.f)
		{
			if (dist > 768)
			{
				@sphere = Sphere_Spawn(self, spawnflags::sphere::HUNTER | spawnflags::sphere::DOPPLEGANGER);
				sphere.pain(sphere, attacker, 0, 0, mod);
			}
			else
			{
				@sphere = Sphere_Spawn(self, spawnflags::sphere::VENGEANCE | spawnflags::sphere::DOPPLEGANGER);
				sphere.pain(sphere, attacker, 0, 0, mod);
			}
		}
	}

	self.takedamage = false;

	// [Paril-KEX]
	T_RadiusDamage(self, self.teammaster, 160.f, self, 140.f, damageflags_t::NONE, mod_id_t::DOPPLE_EXPLODE);

	if (self.teamchain !is null)
		BecomeExplosion1(self.teamchain);
	BecomeExplosion1(self);
}

void doppleganger_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	@self.enemy = other;
}

void doppleganger_timeout(ASEntity &self)
{
	doppleganger_die(self, self, self, 9999, self.e.origin, mod_id_t::UNKNOWN);
}

void body_think(ASEntity &self)
{
	float r;

	if (abs(self.ideal_yaw - anglemod(self.e.angles.yaw)) < 2)
	{
		if (self.timestamp < level.time)
		{
			r = frandom();
			if (r < 0.10f)
			{
				self.ideal_yaw = frandom(350.0f);
				self.timestamp = level.time + time_sec(1);
			}
		}
	}
	else
		M_ChangeYaw(self);

	if (self.teleport_time <= level.time)
	{
		self.e.frame++;
		if (self.e.frame > player::frames::stand40)
			self.e.frame = player::frames::stand01;

		self.teleport_time = level.time + time_hz(10);
	}

	self.nextthink = level.time + FRAME_TIME_MS;
}

void fire_doppleganger(ASEntity &ent, const vec3_t &in start, const vec3_t &in aimdir)
{
	ASEntity @base;
	ASEntity @body;
	vec3_t	 dir;
	vec3_t	 forward, right, up;
	int		 number;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@base = G_Spawn();
	base.e.origin = start;
	base.e.angles = dir;
	base.movetype = movetype_t::TOSS;
	base.e.solid = solid_t::BBOX;
	base.e.renderfx = renderfx_t(base.e.renderfx | renderfx_t::IR_VISIBLE);
	base.e.angles.pitch = 0;
	base.e.mins = { -16, -16, -24 };
	base.e.maxs = { 16, 16, 32 };
	base.e.modelindex = gi_modelindex ("models/objects/dopplebase/tris.md2");
	base.e.alpha = 0.1f;
	@base.teammaster = ent;
	base.flags = ent_flags_t(base.flags | ( ent_flags_t::DAMAGEABLE | ent_flags_t::TRAP ));
	base.takedamage = true;
	base.health = 30;
	@base.pain = doppleganger_pain;
	@base.die = doppleganger_die;

	base.nextthink = level.time + time_sec(30);
	@base.think = doppleganger_timeout;

	base.classname = "doppleganger";

	gi_linkentity(base.e);

	@body = G_Spawn();
	body.e.s = ent.e.s;
	body.e.sound = 0;
	body.e.event = entity_event_t::NONE;
	body.yaw_speed = 30;
	body.ideal_yaw = 0;
	body.e.origin = start;
	body.e.origin.z += 8;
	body.teleport_time = level.time + time_hz(10);
	@body.think = body_think;
	body.nextthink = level.time + FRAME_TIME_MS;
	gi_linkentity(body.e);

	@base.teamchain = body;
	@body.teammaster = base;

	// [Paril-KEX]
	@body.owner = ent;
	gi_sound(body.e, soundchan_t::AUTO, gi_soundindex("medic_commander/monsterspawn1.wav"), 1.f, ATTN_NORM, 0.f);
}