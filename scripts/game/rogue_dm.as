const item_flags_t IF_TYPE_MASK = item_flags_t(item_flags_t::WEAPON | item_flags_t::AMMO | item_flags_t::POWERUP | item_flags_t::ARMOR | item_flags_t::KEY);

item_flags_t GetSubstituteItemFlags(item_id_t id)
{
	const gitem_t @item = GetItemByIndex(id);

	// we want to stay within the item class
	item_flags_t flags = item_flags_t(item.flags & IF_TYPE_MASK);

	if ((flags & (item_flags_t::WEAPON | item_flags_t::AMMO)) == (item_flags_t::WEAPON | item_flags_t::AMMO))
		flags = item_flags_t::AMMO;
	// Adrenaline and Mega Health count as powerup
	else if (id == item_id_t::ITEM_ADRENALINE || id == item_id_t::HEALTH_MEGA)
		flags = item_flags_t::POWERUP;

	return flags;
}

item_id_t FindSubstituteItem(ASEntity &ent)
{
	// never replace flags
	if (ent.item.id == item_id_t::FLAG1 || ent.item.id == item_id_t::FLAG2)
		return item_id_t::NULL;

	// stimpack/shard randomizes
	if (ent.item.id == item_id_t::HEALTH_SMALL ||
		ent.item.id == item_id_t::ARMOR_SHARD)
		return brandom() ? item_id_t::HEALTH_SMALL : item_id_t::ARMOR_SHARD;

	// health is special case
	if (ent.item.id == item_id_t::HEALTH_MEDIUM ||
		ent.item.id == item_id_t::HEALTH_LARGE)
	{
		float rnd = frandom();

		if (rnd < 0.6f)
			return item_id_t::HEALTH_MEDIUM;
		else
			return item_id_t::HEALTH_LARGE;
	}
	// armor is also special case
	else if (ent.item.id == item_id_t::ARMOR_JACKET ||
			 ent.item.id == item_id_t::ARMOR_COMBAT ||
			 ent.item.id == item_id_t::ARMOR_BODY ||
			 ent.item.id == item_id_t::ITEM_POWER_SCREEN ||
			 ent.item.id == item_id_t::ITEM_POWER_SHIELD)
	{
		float rnd = frandom();

		if (rnd < 0.4f)
			return item_id_t::ARMOR_JACKET;
		else if (rnd < 0.6f)
			return item_id_t::ARMOR_COMBAT;
		else if (rnd < 0.8f)
			return item_id_t::ARMOR_BODY;
		else if (rnd < 0.9f)
			return item_id_t::ITEM_POWER_SCREEN;
		else
			return item_id_t::ITEM_POWER_SHIELD;
	}

	item_flags_t myflags = GetSubstituteItemFlags(ent.item.id);

	array<item_id_t> possible_items;

	// gather matching items
	for (item_id_t i = item_id_t(item_id_t::NULL + 1); i < item_id_t::TOTAL; i = item_id_t(int(i) + 1))
	{
		const gitem_t @it = GetItemByIndex(i);
		item_flags_t itflags = it.flags;

		if (itflags == 0 || (itflags & (item_flags_t::NOT_GIVEABLE | item_flags_t::TECH | item_flags_t::NOT_RANDOM)) != 0 || it.pickup is null || it.world_model.empty())
			continue;

		// don't respawn spheres if they're dmflag disabled.
		if (g_no_spheres.integer != 0)
		{
			if (i == item_id_t::ITEM_SPHERE_VENGEANCE ||
				i == item_id_t::ITEM_SPHERE_HUNTER ||
				i == item_id_t::ITEM_SPHERE_DEFENDER)
			{
				continue;
			}
		}

		if (g_no_nukes.integer != 0 && i == item_id_t::AMMO_NUKE)
			continue;

		if (g_no_mines.integer != 0 &&
			(i == item_id_t::AMMO_PROX || i == item_id_t::AMMO_TESLA || i == item_id_t::AMMO_TRAP || i == item_id_t::WEAPON_PROXLAUNCHER))
			continue;

		itflags = GetSubstituteItemFlags(i);

		if ((itflags & IF_TYPE_MASK) == (myflags & IF_TYPE_MASK))
			possible_items.push_back(i);
	}

	if (possible_items.empty())
		return item_id_t::NULL;

	return possible_items[irandom(possible_items.size())];
}

//=================
//=================
item_id_t DoRandomRespawn(ASEntity &ent)
{
	if (ent.item is null)
		return item_id_t::NULL; // why

	return FindSubstituteItem(ent);
}

//=================
//=================
void PrecacheForRandomRespawn()
{
	for (item_id_t i = item_id_t(item_id_t::NULL + 1); i < item_id_t::TOTAL; i++)
	{
        const gitem_t @it = GetItemByIndex(i);
		item_flags_t itflags = it.flags;

		if (itflags == 0 || (itflags & (item_flags_t::NOT_GIVEABLE | item_flags_t::TECH | item_flags_t::NOT_RANDOM)) != 0 || it.pickup is null || it.world_model.empty())
			continue;

		PrecacheItem(it);
	}
}

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