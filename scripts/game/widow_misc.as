
//
// Death sequence stuff
//

vec3_t WidowVelocityForDamage(int damage)
{
    vec3_t v;
	v[0] = damage * crandom();
	v[1] = damage * crandom();
	v[2] = damage * crandom() + 200.0f;
    return v;
}

void widow_gib_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	self.e.solid = solid_t::NOT;
	@self.touch = null;
	self.e.s.angles.pitch = 0;
	self.e.s.angles.roll = 0;
	self.avelocity = vec3_origin;

	if (self.style != 0)
		gi_sound(self.e, soundchan_t::VOICE, self.style, 1, ATTN_NORM, 0);
}

void ThrowWidowGibReal(ASEntity &self, const string &in gibname, int damage, gib_type_t type, const vec3_t &in startpos, bool sized, int hitsound, bool fade, bool use_pos)
{
	ASEntity @gib;
	vec3_t	 vd;
	vec3_t	 origin;
	vec3_t	 size;
	float	 vscale;

	if (gibname.empty())
		return;

	@gib = G_Spawn();

	if (use_pos)
		gib.e.s.origin = startpos;
	else
	{
		origin = (self.e.absmin + self.e.absmax) * 0.5f;
		gib.e.s.origin[0] = origin[0] + crandom() * size[0];
		gib.e.s.origin[1] = origin[1] + crandom() * size[1];
		gib.e.s.origin[2] = origin[2] + crandom() * size[2];
	}

	gib.e.solid = solid_t::NOT;
	gib.e.s.effects = effects_t(gib.e.s.effects | effects_t::GIB);
	gib.flags = ent_flags_t(gib.flags | ent_flags_t::NO_KNOCKBACK);
	gib.takedamage = true;
	@gib.die = gib_die;
	gib.e.s.renderfx = renderfx_t(gib.e.s.renderfx | renderfx_t::IR_VISIBLE);
	gib.e.s.renderfx = renderfx_t(gib.e.s.renderfx & ~renderfx_t::DOT_SHADOW);

	if (fade)
	{
		@gib.think = G_FreeEdict;
		// sized gibs last longer
		if (sized)
			gib.nextthink = level.time + random_time(time_sec(20), time_sec(35));
		else
			gib.nextthink = level.time + random_time(time_sec(5), time_sec(15));
	}
	else
	{
		@gib.think = G_FreeEdict;
		// sized gibs last longer
		if (sized)
			gib.nextthink = level.time + random_time(time_sec(60), time_sec(75));
		else
			gib.nextthink = level.time + random_time(time_sec(25), time_sec(35));
	}

	if ((type & gib_type_t::METALLIC) == 0)
	{
		gib.movetype = movetype_t::TOSS;
		vscale = 0.5;
	}
	else
	{
		gib.movetype = movetype_t::BOUNCE;
		vscale = 1.0;
	}

	vd = WidowVelocityForDamage(damage);
	gib.velocity = self.velocity + (vd * vscale);
	ClipGibVelocity(gib);

	gi_setmodel(gib.e, gibname);

	if (sized)
	{
		gib.style = hitsound;
		gib.e.solid = solid_t::BBOX;
		gib.avelocity[0] = frandom(400);
		gib.avelocity[1] = frandom(400);
		gib.avelocity[2] = frandom(400);
		if (gib.velocity[2] < 0)
			gib.velocity[2] *= -1;
		gib.velocity[0] *= 2;
		gib.velocity[1] *= 2;
		ClipGibVelocity(gib);
		gib.velocity[2] = max(frandom(350.f, 450.f), gib.velocity[2]);
		gib.gravity = 0.25;
		@gib.touch = widow_gib_touch;
		@gib.owner = self;
		if (gib.e.s.modelindex == gi_modelindex("models/monsters/blackwidow2/gib2/tris.md2"))
		{
			gib.e.mins = { -10, -10, 0 };
			gib.e.maxs = { 10, 10, 10 };
		}
		else
		{
			gib.e.mins = { -5, -5, 0 };
			gib.e.maxs = { 5, 5, 5 };
		}
	}
	else
	{
		gib.velocity[0] *= 2;
		gib.velocity[1] *= 2;
		gib.avelocity[0] = frandom(600);
		gib.avelocity[1] = frandom(600);
		gib.avelocity[2] = frandom(600);
	}

	gi_linkentity(gib.e);
}

void ThrowWidowGib(ASEntity &self, const string &in gibname, int damage, gib_type_t type)
{
	ThrowWidowGibReal(self, gibname, damage, type, vec3_origin, false, 0, true, false);
}

void ThrowWidowGibLoc(ASEntity &self, const string &in gibname, int damage, gib_type_t type, const vec3_t &in startpos, bool fade, bool use_pos)
{
	ThrowWidowGibReal(self, gibname, damage, type, startpos, false, 0, fade, use_pos);
}

void ThrowWidowGibSized(ASEntity &self, const string &in gibname, int damage, gib_type_t type, const vec3_t &in startpos, int hitsound, bool fade, bool use_pos)
{
	ThrowWidowGibReal(self, gibname, damage, type, startpos, true, hitsound, fade, use_pos);
}

void ThrowSmallStuff(ASEntity &self, const vec3_t &in point)
{
	int n;

	for (n = 0; n < 2; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, point, false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 300, gib_type_t::METALLIC, point, false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, point, false, true);
}

void ThrowMoreStuff(ASEntity &self, const vec3_t &in point)
{
	int n;

	if (coop.integer != 0)
	{
		ThrowSmallStuff(self, point);
		return;
	}

	for (n = 0; n < 1; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, point, false, true);
	for (n = 0; n < 2; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 300, gib_type_t::METALLIC, point, false, true);
	for (n = 0; n < 3; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, point, false, true);
}

void WidowExplode(ASEntity &self)
{
	vec3_t org;
	int	   n;

	@self.think = WidowExplode;

	org = self.e.s.origin;
	org[2] += irandom(24, 40);
	if (self.count < 8)
		org[2] += irandom(24, 56);
	switch (self.count)
	{
	case 0:
		org[0] -= 24;
		org[1] -= 24;
		break;
	case 1:
		org[0] += 24;
		org[1] += 24;
		ThrowSmallStuff(self, org);
		break;
	case 2:
		org[0] += 24;
		org[1] -= 24;
		break;
	case 3:
		org[0] -= 24;
		org[1] += 24;
		ThrowMoreStuff(self, org);
		break;
	case 4:
		org[0] -= 48;
		org[1] -= 48;
		break;
	case 5:
		org[0] += 48;
		org[1] += 48;
		ThrowArm1(self);
		break;
	case 6:
		org[0] -= 48;
		org[1] += 48;
		ThrowArm2(self);
		break;
	case 7:
		org[0] += 48;
		org[1] -= 48;
		ThrowSmallStuff(self, org);
		break;
	case 8:
		org[0] += 18;
		org[1] += 18;
		org[2] = self.e.s.origin[2] + 48;
		ThrowMoreStuff(self, org);
		break;
	case 9:
		org[0] -= 18;
		org[1] += 18;
		org[2] = self.e.s.origin[2] + 48;
		break;
	case 10:
		org[0] += 18;
		org[1] -= 18;
		org[2] = self.e.s.origin[2] + 48;
		break;
	case 11:
		org[0] -= 18;
		org[1] -= 18;
		org[2] = self.e.s.origin[2] + 48;
		break;
	case 12:
		self.e.s.sound = 0;
		for (n = 0; n < 1; n++)
			ThrowWidowGib(self, "models/objects/gibs/sm_meat/tris.md2", 400, gib_type_t::NONE);
		for (n = 0; n < 2; n++)
			ThrowWidowGib(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC);
		for (n = 0; n < 2; n++)
			ThrowWidowGib(self, "models/objects/gibs/sm_metal/tris.md2", 400, gib_type_t::METALLIC);
		self.deadflag = true;
		@self.think = monster_think;
		self.nextthink = level.time + time_hz(10);
		M_SetAnimation(self, widow2_move_dead);
		return;
	}

	self.count++;
	if (self.count >= 9 && self.count <= 12)
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
		gi_WritePosition(org);
		gi_multicast(self.e.s.origin, multicast_t::ALL, false);
	}
	else
	{
		// else
		gi_WriteByte(svc_t::temp_entity);
		if ((self.count % 2) != 0)
			gi_WriteByte(temp_event_t::EXPLOSION1);
		else
			gi_WriteByte(temp_event_t::EXPLOSION1_NP);
		gi_WritePosition(org);
		gi_multicast(self.e.s.origin, multicast_t::ALL, false);
	}

	self.nextthink = level.time + time_hz(10);
}

void WidowExplosion(ASEntity &self, const vec3_t &in offset)
{
	int	   n;
	vec3_t f, r, u, startpoint;

	AngleVectors(self.e.s.angles, f, r, u);
	startpoint = G_ProjectSource2(self.e.s.origin, offset, f, r, u);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(startpoint);
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);

	for (n = 0; n < 1; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, startpoint, false, true);
	for (n = 0; n < 1; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, startpoint, false, true);
	for (n = 0; n < 2; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 300, gib_type_t::METALLIC, startpoint, false, true);
}

void WidowExplosion1(ASEntity &self)
{
	WidowExplosion(self, { 23.74f, -37.67f, 76.96f });
}

void WidowExplosion2(ASEntity &self)
{
	WidowExplosion(self, { -20.49f, 36.92f, 73.52f });
}

void WidowExplosion3(ASEntity &self)
{
	WidowExplosion(self, { 2.11f, 0.05f, 92.20f });
}

void WidowExplosion4(ASEntity &self)
{
	WidowExplosion(self, { -28.04f, -35.57f, -77.56f });
}

void WidowExplosion5(ASEntity &self)
{
	WidowExplosion(self, { -20.11f, -1.11f, 40.76f });
}

void WidowExplosion6(ASEntity &self)
{
	WidowExplosion(self, { -20.11f, -1.11f, 40.76f });
}

void WidowExplosion7(ASEntity &self)
{
	WidowExplosion(self, { -20.11f, -1.11f, 40.76f });
}

void WidowExplosionLeg(ASEntity &self)
{
	vec3_t f, r, u, startpoint;
	vec3_t offset1 = { -31.89f, -47.86f, 67.02f };
	vec3_t offset2 = { -44.9f, -82.14f, 54.72f };

	AngleVectors(self.e.s.angles, f, r, u);
	startpoint = G_ProjectSource2(self.e.s.origin, offset1, f, r, u);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(startpoint);
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);

	ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib2/tris.md2", 200, gib_type_t::METALLIC, startpoint,
					   gi_soundindex("misc/fhit3.wav"), false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, startpoint, false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, startpoint, false, true);

	startpoint = G_ProjectSource2(self.e.s.origin, offset2, f, r, u);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(startpoint);
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);

	ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib1/tris.md2", 300, gib_type_t::METALLIC, startpoint,
					   gi_soundindex("misc/fhit3.wav"), false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, startpoint, false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, startpoint, false, true);
}

void ThrowArm1(ASEntity &self)
{
	int	   n;
	vec3_t f, r, u, startpoint;
	vec3_t offset1 = { 65.76f, 17.52f, 7.56f };

	AngleVectors(self.e.s.angles, f, r, u);
	startpoint = G_ProjectSource2(self.e.s.origin, offset1, f, r, u);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(startpoint);
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);

	for (n = 0; n < 2; n++)
		ThrowWidowGibLoc(self, "models/objects/gibs/sm_metal/tris.md2", 100, gib_type_t::METALLIC, startpoint, false, true);
}

void ThrowArm2(ASEntity &self)
{
	vec3_t f, r, u, startpoint;
	vec3_t offset1 = { 65.76f, 17.52f, 7.56f };

	AngleVectors(self.e.s.angles, f, r, u);
	startpoint = G_ProjectSource2(self.e.s.origin, offset1, f, r, u);

	ThrowWidowGibSized(self, "models/monsters/blackwidow2/gib4/tris.md2", 200, gib_type_t::METALLIC, startpoint,
					   gi_soundindex("misc/fhit3.wav"), false, true);
	ThrowWidowGibLoc(self, "models/objects/gibs/sm_meat/tris.md2", 300, gib_type_t::NONE, startpoint, false, true);
}



// ****************************
// WidowLeg stuff
// ****************************

const int MAX_LEGSFRAME = 23;
const gtime_t LEG_WAIT_TIME = time_sec(1);

void widowlegs_think(ASEntity &self)
{
	vec3_t offset;
	vec3_t point;
	vec3_t f, r, u;

	if (self.e.s.frame == 17)
	{
		offset = { 11.77f, -7.24f, 23.31f };
		AngleVectors(self.e.s.angles, f, r, u);
		point = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1);
		gi_WritePosition(point);
		gi_multicast(point, multicast_t::ALL, false);
		ThrowSmallStuff(self, point);
	}

	if (self.e.s.frame < MAX_LEGSFRAME)
	{
		self.e.s.frame++;
		self.nextthink = level.time + time_hz(10);
		return;
	}
	else if (self.wait == 0)
	{
		self.wait = (level.time + LEG_WAIT_TIME).secondsf();
	}
	if (level.time > time_sec(self.wait))
	{
		AngleVectors(self.e.s.angles, f, r, u);

		offset = { -65.6f, -8.44f, 28.59f };
		point = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1);
		gi_WritePosition(point);
		gi_multicast(point, multicast_t::ALL, false);
		ThrowSmallStuff(self, point);

		ThrowWidowGibSized(self, "models/monsters/blackwidow/gib1/tris.md2", 80 + int(frandom(20.0f)), gib_type_t::METALLIC, point, 0, true, true);
		ThrowWidowGibSized(self, "models/monsters/blackwidow/gib2/tris.md2", 80 + int(frandom(20.0f)), gib_type_t::METALLIC, point, 0, true, true);

		offset = { -1.04f, -51.18f, 7.04f };
		point = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1);
		gi_WritePosition(point);
		gi_multicast(point, multicast_t::ALL, false);
		ThrowSmallStuff(self, point);

		ThrowWidowGibSized(self, "models/monsters/blackwidow/gib1/tris.md2", 80 + int(frandom(20.0f)), gib_type_t::METALLIC, point, 0, true, true);
		ThrowWidowGibSized(self, "models/monsters/blackwidow/gib2/tris.md2", 80 + int(frandom(20.0f)), gib_type_t::METALLIC, point, 0, true, true);
		ThrowWidowGibSized(self, "models/monsters/blackwidow/gib3/tris.md2", 80 + int(frandom(20.0f)), gib_type_t::METALLIC, point, 0, true, true);

		G_FreeEdict(self);
		return;
	}
	if ((level.time > time_sec(self.wait - 0.5f)) && (self.count == 0))
	{
		self.count = 1;
		AngleVectors(self.e.s.angles, f, r, u);

		offset = { 31, -88.7f, 10.96f };
		point = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1);
		gi_WritePosition(point);
		gi_multicast(point, multicast_t::ALL, false);
		//		ThrowSmallStuff (self, point);

		offset = { -12.67f, -4.39f, 15.68f };
		point = G_ProjectSource2(self.e.s.origin, offset, f, r, u);
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::EXPLOSION1);
		gi_WritePosition(point);
		gi_multicast(point, multicast_t::ALL, false);
		//		ThrowSmallStuff (self, point);

		self.nextthink = level.time + time_hz(10);
		return;
	}
	self.nextthink = level.time + time_hz(10);
}

void Widowlegs_Spawn(const vec3_t &in startpos, const vec3_t &in angles)
{
	ASEntity @ent;

	@ent = G_Spawn();
	ent.e.s.origin = startpos;
	ent.e.s.angles = angles;
	ent.e.solid = solid_t::NOT;
	ent.e.s.renderfx = renderfx_t::IR_VISIBLE;
	ent.movetype = movetype_t::NONE;
	ent.classname = "widowlegs";

	ent.e.s.modelindex = gi_modelindex("models/monsters/legs/tris.md2");
	@ent.think = widowlegs_think;

	ent.nextthink = level.time + time_hz(10);
	gi_linkentity(ent.e);
}

