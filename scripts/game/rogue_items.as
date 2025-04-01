// ================
// PMM
bool Pickup_Nuke(ASEntity &ent, ASEntity &other)
{
	int quantity;

	quantity = other.client.pers.inventory[ent.item.id];

	if (quantity >= 1)
		return false;

	if (coop.integer != 0 && !P_UseCoopInstancedItems() && (ent.item.flags & item_flags_t::STAY_COOP) != 0 && (quantity > 0))
		return false;

	other.client.pers.inventory[ent.item.id]++;

	if (deathmatch.integer != 0)
	{
		if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
			SetRespawn(ent, time_sec(ent.item.quantity));
	}

	return true;
}

// ================
// PGM
void Use_IR(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.ir_time = max(level.time, ent.client.ir_time) + time_sec(60);

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("misc/ir_start.wav"), 1, ATTN_NORM, 0);
}

void Use_Double(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.double_time = max(level.time, ent.client.double_time) + time_sec(30);

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("misc/ddamage1.wav"), 1, ATTN_NORM, 0);
}

void Use_Nuke(ASEntity &ent, const gitem_t &item)
{
	vec3_t forward, right, start;
	int	   speed;

	ent.client.pers.inventory[item.id]--;

	AngleVectors(ent.client.v_angle, forward, right);

	start = ent.e.origin;
	speed = 100;
	fire_nuke(ent, start, forward, speed);
}

void Use_Doppleganger(ASEntity &ent, const gitem_t &item)
{
	vec3_t forward, right;
	vec3_t createPt, spawnPt;
	vec3_t ang;

	ang.pitch = 0;
	ang.yaw = ent.client.v_angle.yaw;
	ang.roll = 0;
	AngleVectors(ang, forward, right);

	createPt = ent.e.origin + (forward * 48);

	if (!FindSpawnPoint(createPt, ent.e.mins, ent.e.maxs, spawnPt, 32))
		return;

	if (!CheckGroundSpawnPoint(spawnPt, ent.e.mins, ent.e.maxs, 64, -1))
		return;

	ent.client.pers.inventory[item.id]--;

	SpawnGrow_Spawn(spawnPt, 24.f, 48.f);
	fire_doppleganger(ent, spawnPt, forward);
}

bool Pickup_Doppleganger(ASEntity &ent, ASEntity &other)
{
	int quantity;

	if (deathmatch.integer == 0) // item is DM only
		return false;

	quantity = other.client.pers.inventory[ent.item.id];
	if (quantity >= 1) // FIXME - apply max to dopplegangers
		return false;

	other.client.pers.inventory[ent.item.id]++;

	if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
		SetRespawn(ent, time_sec(ent.item.quantity));

	return true;
}

bool Pickup_Sphere(ASEntity &ent, ASEntity &other)
{
	int quantity;

	if (other.client !is null && other.client.owned_sphere !is null)
	{
		//		gi.LocClient_Print(other, PRINT_HIGH, "$g_only_one_sphere_customer");
		return false;
	}

	quantity = other.client.pers.inventory[ent.item.id];
	if ((skill.integer == 1 && quantity >= 2) || (skill.integer >= 2 && quantity >= 1))
		return false;

	if ((coop.integer != 0) && !P_UseCoopInstancedItems() && (ent.item.flags & item_flags_t::STAY_COOP) != 0 && (quantity > 0))
		return false;

	other.client.pers.inventory[ent.item.id]++;

	if (deathmatch.integer != 0)
	{
		if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
			SetRespawn(ent, time_sec(ent.item.quantity));
		if (g_dm_instant_items.integer != 0)
		{
			// PGM
			if (ent.item.use !is null)
				ent.item.use(other, ent.item);
			else
				gi_Com_Print("Powerup has no use function!\n");
			// PGM
		}
	}

	return true;
}

void Use_Defender(ASEntity &ent, const gitem_t &item)
{
	if (ent.client !is null && ent.client.owned_sphere !is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_only_one_sphere_time");
		return;
	}

	ent.client.pers.inventory[item.id]--;

	Defender_Launch(ent);
}

void Use_Hunter(ASEntity &ent, const gitem_t &item)
{
	if (ent.client !is null && ent.client.owned_sphere !is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_only_one_sphere_time");
		return;
	}

	ent.client.pers.inventory[item.id]--;

	Hunter_Launch(ent);
}

void Use_Vengeance(ASEntity &ent, const gitem_t &item)
{
	if (ent.client !is null && ent.client.owned_sphere !is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_only_one_sphere_time");
		return;
	}

	ent.client.pers.inventory[item.id]--;

	Vengeance_Launch(ent);
}

// PGM
// ================

//=================
// Item_TriggeredSpawn - create the item marked for spawn creation
//=================
void Item_TriggeredSpawn(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	@self.use = null;

	if ((self.spawnflags & spawnflags::item::TOSS_SPAWN) != 0)
	{
		self.movetype = movetype_t::TOSS;
		vec3_t forward, right;

		AngleVectors(self.e.s.angles, forward, right);
		self.e.s.origin = self.e.s.origin;
		self.e.s.origin[2] += 16;
		self.velocity = forward * 100;
		self.velocity[2] = 300;
	}
	
	if ((self.spawnflags & spawnflags::item::NO_DROP) == 0)
	{
		if (self.item.id != item_id_t::KEY_POWER_CUBE && self.item.id != item_id_t::KEY_EXPLOSIVE_CHARGES) // leave them be on key_power_cube..
			self.spawnflags &= spawnflags::item::NO_TOUCH;
	}
	else
		self.spawnflags &= ~spawnflags::item::TRIGGER_SPAWN;

    droptofloor(self);
}

//=================
// SetTriggeredSpawn - set up an item to spawn in later.
//=================
void SetTriggeredSpawn(ASEntity &ent)
{
	// don't do anything on key_power_cubes.
	if (ent.item.id == item_id_t::KEY_POWER_CUBE || ent.item.id == item_id_t::KEY_EXPLOSIVE_CHARGES)
		return;

	@ent.think = null;
	ent.nextthink = time_zero;
	@ent.use = Item_TriggeredSpawn;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.e.solid = solid_t::NOT;
}
