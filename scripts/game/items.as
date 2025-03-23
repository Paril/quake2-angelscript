// item spawnflags
namespace spawnflags::item
{
    const spawnflags_t TRIGGER_SPAWN = spawnflag_bit(0);
    const spawnflags_t NO_TOUCH = spawnflag_bit(1);
    const spawnflags_t TOSS_SPAWN = spawnflag_bit(2);
    const spawnflags_t NO_DROP = spawnflag_bit(3);
    const spawnflags_t MAX = spawnflag_bit(4);
// 8 bits reserved for editor flags & power cube bits
// (see SPAWNFLAG_NOT_EASY)
    const spawnflags_t DROPPED = spawnflag_bit(16);
    const spawnflags_t DROPPED_PLAYER = spawnflag_bit(17);
    const spawnflags_t TARGETS_USED = spawnflag_bit(18);
}

// gitem_t.flags
enum item_flags_t : uint32
{
	NONE		= 0,
	WEAPON		= 1 << 0, // use makes active weapon
	AMMO		= 1 << 1,
	ARMOR		= 1 << 2,
	STAY_COOP	= 1 << 3,
	KEY			= 1 << 4,
	POWERUP		= 1 << 5,
	// ROGUE
	NOT_GIVEABLE= 1 << 6, // item can not be given
	// ROGUE
	HEALTH		= 1 << 7,
	// ZOID
	TECH		= 1 << 8,
	NO_HASTE	= 1 << 9,
	// ZOID

	NO_INFINITE_AMMO = 1 << 10, // [Paril-KEX] don't allow infinite ammo to affect
	POWERUP_WHEEL    = 1 << 11, // [Paril-KEX] item should be in powerup wheel
	POWERUP_ONOFF    = 1 << 12, // [Paril-KEX] for wheel; can't store more than one, show on/off state

	NOT_RANDOM  = 1 << 13, // [Paril-KEX] item never shows up in randomizations

	ANY			= 0xFFFFFFFF
};

// health edict_t.style
enum health_style_t
{
	IGNORE_MAX = 1,
	TIMED      = 2
};

// item IDs; must match itemlist order
enum item_id_t : uint8
{
	NULL, // must always be zero

	ARMOR_BODY,
	ARMOR_COMBAT,
	ARMOR_JACKET,
	ARMOR_SHARD,
	ITEM_POWER_SCREEN,
	ITEM_POWER_SHIELD,
	WEAPON_GRAPPLE,
	WEAPON_BLASTER,
	WEAPON_CHAINFIST,
	WEAPON_SHOTGUN,
	WEAPON_SSHOTGUN,
	WEAPON_MACHINEGUN,
	WEAPON_ETF_RIFLE,
	WEAPON_CHAINGUN,
	AMMO_GRENADES,
	AMMO_TRAP,
	AMMO_TESLA,
	WEAPON_GLAUNCHER,
	WEAPON_PROXLAUNCHER,
	WEAPON_RLAUNCHER,
	WEAPON_HYPERBLASTER,
	WEAPON_IONRIPPER,
	WEAPON_PLASMABEAM,
	WEAPON_RAILGUN,
	WEAPON_PHALANX,
	WEAPON_BFG,
	WEAPON_DISRUPTOR,

	AMMO_SHELLS,
	AMMO_BULLETS,
	AMMO_CELLS,
	AMMO_ROCKETS,
	AMMO_SLUGS,
	AMMO_MAGSLUG,
	AMMO_FLECHETTES,
	AMMO_PROX,
	AMMO_NUKE,
	AMMO_ROUNDS,

	ITEM_QUAD,
	ITEM_QUADFIRE,
	ITEM_INVULNERABILITY,
	ITEM_INVISIBILITY,
	ITEM_SILENCER,
	ITEM_REBREATHER,
	ITEM_ENVIROSUIT,
	ITEM_ANCIENT_HEAD,
	ITEM_LEGACY_HEAD,
	ITEM_ADRENALINE,
	ITEM_BANDOLIER,
	ITEM_PACK,
	ITEM_IR_GOGGLES,
	ITEM_DOUBLE,

	ITEM_SPHERE_VENGEANCE,
	ITEM_SPHERE_HUNTER,
	ITEM_SPHERE_DEFENDER,
	ITEM_DOPPELGANGER,

	KEY_DATA_CD,
	KEY_POWER_CUBE,
	KEY_EXPLOSIVE_CHARGES,
	KEY_YELLOW,
	KEY_POWER_CORE,
	KEY_PYRAMID,
	KEY_DATA_SPINNER,
	KEY_PASS,
	KEY_BLUE_KEY,
	KEY_RED_KEY,
	KEY_GREEN_KEY,
	KEY_COMMANDER_HEAD,
	KEY_AIRSTRIKE,
	KEY_NUKE_CONTAINER,
	KEY_NUKE,

	HEALTH_SMALL,
	HEALTH_MEDIUM,
	HEALTH_LARGE,
	HEALTH_MEGA,
	
	FLAG1,
	FLAG2,

	TECH_RESISTANCE,
	TECH_STRENGTH,
	TECH_HASTE,
	TECH_REGENERATION,
	ITEM_FLASHLIGHT,
	ITEM_COMPASS,

	TOTAL
};

class gitem_armor_t
{
	int32 base_count;
	int32 max_count;
	float normal_protection;
	float energy_protection;

	gitem_armor_t(int32 base_count, int32 max_count, float normal, float energy)
	{
		this.base_count = base_count;
		this.max_count = max_count;
		this.normal_protection = normal;
		this.energy_protection = energy;
	}
};

const gitem_armor_t jacketarmor_info(25, 50, .30f, .00f);
const gitem_armor_t combatarmor_info(50, 100, .60f, .30f);
const gitem_armor_t bodyarmor_info(100, 200, .80f, .60f);

funcdef bool gitem_pickup_f(ASEntity &ent, ASEntity &other);
funcdef void gitem_use_f(ASEntity &ent, const gitem_t &item);
funcdef void gitem_drop_f(ASEntity &ent, const gitem_t &item);
funcdef void gitem_weaponthink_f(ASEntity &ent);

class gitem_t
{
	item_id_t           id;		   // matches item list index
	string              classname; // spawning name
	gitem_pickup_f      @pickup;
    gitem_use_f         @use;
    gitem_drop_f        @drop;
    gitem_weaponthink_f @weaponthink;
	string              pickup_sound;
	string              world_model;
	effects_t           world_model_flags;
	string              view_model;

	// client side info
	string icon;
	string use_name; // for use command, english only
	string pickup_name; // for printing on pickup
	string pickup_name_definite; // definite article version for languages that need it

	int			 quantity = 0;	  // for ammo how much, for weapons how much is used per shot
	item_id_t	 ammo = item_id_t::NULL;  // for weapons
	item_id_t	 chain = item_id_t::NULL; // weapon chain root
	item_flags_t flags = item_flags_t::NONE; // IT_* flags

	string vwep_model; // vwep model string (for weapons)

	const gitem_armor_t  @armor_info;
	int					 tag = 0;

	string precaches; // string of all models, sounds, and images this item will use

	int32 sort_id = 0; // used by some items to control their sorting
	int32 quantity_warn = 5; // when to warn on low ammo

	// set in InitItems, don't set by hand
	// circular list of chained weapons
	gitem_t @chain_next = null;
	// set in SP_worldspawn, don't set by hand
	// model index for vwep
	int32   vwep_index = 0;
	// set in SetItemNames, don't set by hand
	// offset into CS_WHEEL_AMMO/CS_WHEEL_WEAPONS/CS_WHEEL_POWERUPS
	int32   ammo_wheel_index = -1;
	int32   weapon_wheel_index = -1;
	int32   powerup_wheel_index = -1;

    gitem_t() { }

    gitem_t(item_id_t id, string classname = "", gitem_pickup_f @pickup = null, gitem_use_f @use = null, gitem_drop_f @drop = null, gitem_weaponthink_f @weaponthink = null,
            const string &in pickup_sound = "", const string &in world_model = "", effects_t world_model_flags = effects_t::NONE, const string &in view_model = "",
            const string &in icon = "", const string &in use_name = "", const string &in pickup_name = "", const string &in pickup_name_definite = "",
            int quantity = 0, item_id_t ammo = item_id_t::NULL, item_id_t chain = item_id_t::NULL, item_flags_t flags = item_flags_t::NONE,
            const string &in vwep_model = "", const gitem_armor_t @armor_info = null, int tag = 0, const string &in precaches = "", int sort_id = 0, int quantity_warn = 5)
    {
        this.id = id;
        this.classname = classname;
        @this.pickup = @pickup;
        @this.use = @use;
        @this.drop = @drop;
        @this.weaponthink = @weaponthink;
        this.pickup_sound = pickup_sound;
        this.world_model = world_model;
        this.world_model_flags = world_model_flags;
        this.view_model = view_model;
        this.icon = icon;
        this.use_name = use_name;
        this.pickup_name = pickup_name;
        this.pickup_name_definite = pickup_name_definite;
        this.quantity = quantity;
        this.ammo = ammo;
        this.chain = chain;
        this.flags = flags;
        this.vwep_model = vwep_model;
        @this.armor_info = @armor_info;
        this.tag = tag;
        this.precaches = precaches;
        this.sort_id = sort_id;
        this.quantity_warn = quantity_warn;
    }
};
//======================================================================

void DoRespawn(ASEntity &self)
{
    ASEntity @ent = self;

	if (!ent.team.empty())
	{
		ASEntity @master;
		int		 count;
		int		 choice;

		@master = ent.teammaster;

		// ZOID
		// in ctf, when we are weapons stay, only the master of a team of weapons
		// is spawned
		if (ctf.integer != 0 && g_dm_weapons_stay.integer != 0 && master.item !is null && (master.item.flags & item_flags_t::WEAPON) != 0)
			@ent = master;
		else
		{
			// ZOID
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
			ent.e.solid = solid_t::NOT;
			gi_linkentity(ent.e);

            count = 0;
            @ent = master;
			while (ent !is null)
            {
                @ent = ent.chain;
                count++;
            }

			choice = irandom(count);

            count = 0;
            @ent = master;
			while (count < choice)
            {
                @ent = ent.chain;
                count++;
            }
		}
	}

	ent.e.svflags = svflags_t(ent.e.svflags & ~(svflags_t::NOCLIENT | svflags_t::RESPAWNING));
	ent.e.solid = solid_t::TRIGGER;
	gi_linkentity(ent.e);

	// send an effect
	ent.e.s.event = entity_event_t::ITEM_RESPAWN;

	// ROGUE
    // AS_TODO
    /*
	if (g_dm_random_items.integer != 0)
	{
		item_id_t new_item = DoRandomRespawn(ent);

		// if we've changed entities, then do some sleight of hand.
		// otherwise, the old entity will respawn
		if (new_item)
		{
			ent.item = GetItemByIndex(new_item);

			ent.classname = ent.item.classname;
			ent.s.effects = ent.item.world_model_flags;
			gi.setmodel(ent, ent.item.world_model);
		}
	}
    */
	// ROGUE
}

void SetRespawn(ASEntity &ent, gtime_t delay, bool hide_self = true)
{
	// already respawning
	if (ent.think is DoRespawn && ent.nextthink >= level.time)
		return;

	ent.flags = ent_flags_t(ent.flags | ent_flags_t::RESPAWN);

	if (hide_self)
	{
		ent.e.svflags = svflags_t(ent.e.svflags | (svflags_t::NOCLIENT | svflags_t::RESPAWNING));
		ent.e.solid = solid_t::NOT;
		gi_linkentity(ent.e);
	}

	ent.nextthink = level.time + delay;
	@ent.think = DoRespawn;
}

bool G_AddAmmoAndCap(ASEntity &other, item_id_t item, int max, int quantity)
{
	if (other.client.pers.inventory[item] >= max)
		return false;

	other.client.pers.inventory[item] += quantity;
	if (other.client.pers.inventory[item] > max)
		other.client.pers.inventory[item] = max;

	G_CheckPowerArmor(other);

	return true;
}

bool G_AddAmmoAndCapQuantity(ASEntity &other, ammo_t ammo)
{
	const gitem_t @item = GetItemByAmmo(ammo);
	return G_AddAmmoAndCap(other, item.id, other.client.pers.max_ammo[ammo], item.quantity);
}

void G_AdjustAmmoCap(ASEntity &other, ammo_t ammo, int16 new_max)
{
	other.client.pers.max_ammo[ammo] = max(other.client.pers.max_ammo[ammo], new_max);
}

bool Pickup_Bandolier(ASEntity &ent, ASEntity &other)
{
	G_AdjustAmmoCap(other, ammo_t::BULLETS, 250);
	G_AdjustAmmoCap(other, ammo_t::SHELLS, 150);
	G_AdjustAmmoCap(other, ammo_t::CELLS, 250);
	G_AdjustAmmoCap(other, ammo_t::SLUGS, 75);
	G_AdjustAmmoCap(other, ammo_t::MAGSLUG, 75);
	G_AdjustAmmoCap(other, ammo_t::FLECHETTES, 250);
	G_AdjustAmmoCap(other, ammo_t::DISRUPTOR, 21);

	G_AddAmmoAndCapQuantity(other, ammo_t::BULLETS);
	G_AddAmmoAndCapQuantity(other, ammo_t::SHELLS);

	if (!ent.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
		SetRespawn(ent, time_sec(ent.item.quantity));

	return true;
}

bool Pickup_Pack(ASEntity &ent, ASEntity &other)
{
	G_AdjustAmmoCap(other, ammo_t::BULLETS, 300);
	G_AdjustAmmoCap(other, ammo_t::SHELLS, 200);
	G_AdjustAmmoCap(other, ammo_t::ROCKETS, 100);
	G_AdjustAmmoCap(other, ammo_t::GRENADES, 100);
	G_AdjustAmmoCap(other, ammo_t::CELLS, 300);
	G_AdjustAmmoCap(other, ammo_t::SLUGS, 100);
	G_AdjustAmmoCap(other, ammo_t::MAGSLUG, 100);
	G_AdjustAmmoCap(other, ammo_t::FLECHETTES, 300);
	G_AdjustAmmoCap(other, ammo_t::DISRUPTOR, 30);

	G_AddAmmoAndCapQuantity(other, ammo_t::BULLETS);
	G_AddAmmoAndCapQuantity(other, ammo_t::SHELLS);
	G_AddAmmoAndCapQuantity(other, ammo_t::CELLS);
	G_AddAmmoAndCapQuantity(other, ammo_t::GRENADES);
	G_AddAmmoAndCapQuantity(other, ammo_t::ROCKETS);
	G_AddAmmoAndCapQuantity(other, ammo_t::SLUGS);

	// RAFAEL
	G_AddAmmoAndCapQuantity(other, ammo_t::MAGSLUG);
	// RAFAEL

	// ROGUE
	G_AddAmmoAndCapQuantity(other, ammo_t::FLECHETTES);
	G_AddAmmoAndCapQuantity(other, ammo_t::DISRUPTOR);
	// ROGUE

	if (!ent.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
		SetRespawn(ent, time_sec(ent.item.quantity));

	return true;
}

//======================================================================
gtime_t quad_fire_drop_timeout_hack = time_zero;
gtime_t quad_drop_timeout_hack = time_zero;

void Use_Quad(ASEntity &ent, const gitem_t &item)
{
	gtime_t timeout;

	ent.client.pers.inventory[item.id]--;

	if (quad_drop_timeout_hack)
	{
		timeout = quad_drop_timeout_hack;
		quad_drop_timeout_hack = time_zero;
	}
	else
	{
		timeout = time_sec(30);
	}

	ent.client.quad_time = max(level.time, ent.client.quad_time) + timeout;

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage.wav"), 1, ATTN_NORM, 0);
}
// =====================================================================

// RAFAEL
void Use_QuadFire(ASEntity &ent, const gitem_t &item)
{
	gtime_t timeout;

	ent.client.pers.inventory[item.id]--;

	if (quad_fire_drop_timeout_hack)
	{
		timeout = quad_fire_drop_timeout_hack;
		quad_fire_drop_timeout_hack = time_zero;
	}
	else
	{
		timeout = time_sec(30);
	}

	ent.client.quadfire_time = max(level.time, ent.client.quadfire_time) + timeout;

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/quadfire1.wav"), 1, ATTN_NORM, 0);
}
// RAFAEL

//======================================================================

void Use_Breather(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.breather_time = max(level.time, ent.client.breather_time) + time_sec(30);

	//	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage.wav"), 1, ATTN_NORM, 0);
}

//======================================================================

void Use_Envirosuit(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.enviro_time = max(level.time, ent.client.enviro_time) + time_sec(30);

	//	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage.wav"), 1, ATTN_NORM, 0);
}

//======================================================================

void Use_Invulnerability(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.invincible_time = max(level.time, ent.client.invincible_time) + time_sec(30);

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/protect.wav"), 1, ATTN_NORM, 0);
}

void Use_Invisibility(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;

	ent.client.invisible_time = max(level.time, ent.client.invisible_time) + time_sec(30);

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/protect.wav"), 1, ATTN_NORM, 0);
}

//======================================================================

void Use_Silencer(ASEntity &ent, const gitem_t &item)
{
	ent.client.pers.inventory[item.id]--;
	ent.client.silencer_shots += 30;

	//	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage.wav"), 1, ATTN_NORM, 0);
}

//======================================================================

bool Pickup_Key(ASEntity &ent, ASEntity &other)
{
	if (coop.integer != 0)
	{
		if (ent.item.id == item_id_t::KEY_POWER_CUBE || ent.item.id == item_id_t::KEY_EXPLOSIVE_CHARGES)
		{
			if ((other.client.pers.power_cubes & (uint(ent.spawnflags & spawnflags::EDITOR_MASK) >> 8)) != 0)
				return false;
			other.client.pers.inventory[ent.item.id]++;
			other.client.pers.power_cubes |= (uint(ent.spawnflags & spawnflags::EDITOR_MASK) >> 8);
		}
		else
		{
			if (other.client.pers.inventory[ent.item.id] != 0)
				return false;
			other.client.pers.inventory[ent.item.id] = 1;
		}
		return true;
	}
	other.client.pers.inventory[ent.item.id]++;
	return true;
}

bool Add_Ammo(ASEntity &ent, const gitem_t &item, int count)
{
	if (ent.client is null || ammo_t(item.tag) < ammo_t::BULLETS || ammo_t(item.tag) >= ammo_t::MAX)
		return false;

	return G_AddAmmoAndCap(ent, item.id, ent.client.pers.max_ammo[item.tag], count);
}

// we just got weapon `item`, check if we should switch to it
void G_CheckAutoSwitch(ASEntity &ent, const gitem_t &item, bool is_new)
{
	// already using or switching to
	if (ent.client.pers.weapon is item ||
		ent.client.newweapon is item)
		return;
	// need ammo
	else if (item.ammo != item_id_t::NULL)
	{
		int32 required_ammo = (item.flags & item_flags_t::AMMO) != 0 ? 1 : item.quantity;
		
		if (ent.client.pers.inventory[item.ammo] < required_ammo)
			return;
	}

	// check autoswitch setting
	if (ent.client.pers.autoswitch == auto_switch_t::NEVER)
		return;
	else if ((item.flags & item_flags_t::AMMO) != 0 && ent.client.pers.autoswitch == auto_switch_t::ALWAYS_NO_AMMO)
		return;
	else if (ent.client.pers.autoswitch == auto_switch_t::SMART)
	{
		bool using_blaster = ent.client.pers.weapon !is null && ent.client.pers.weapon.id == item_id_t::WEAPON_BLASTER;

		// smartness algorithm: in DM, we will always switch if we have the blaster out
		// otherwise leave our active weapon alone
		if (deathmatch.integer != 0 && !using_blaster)
			return;
		// in SP, only switch if it's a new weapon, or we have the blaster out
		else if (deathmatch.integer == 0 && !using_blaster && !is_new)
			return;
	}

	// switch!
	@ent.client.newweapon = @item;
}

bool Pickup_Ammo(ASEntity &ent, ASEntity &other)
{
	int	 oldcount;
	int	 count;
	bool weapon;

	weapon = (ent.item.flags & item_flags_t::WEAPON) != 0;
	if (weapon && G_CheckInfiniteAmmo(ent.item))
		count = 1000;
	else if (ent.count != 0)
		count = ent.count;
	else
		count = ent.item.quantity;

	oldcount = other.client.pers.inventory[ent.item.id];

	if (!Add_Ammo(other, ent.item, count))
		return false;

	if (weapon)
		G_CheckAutoSwitch(other, ent.item, oldcount == 0);

	if (!ent.spawnflags.has(spawnflags::item::DROPPED | spawnflags::item::DROPPED_PLAYER) && deathmatch.integer != 0)
		SetRespawn(ent, time_sec(30));
	return true;
}

//======================================================================

bool IsInstantItemsEnabled()
{
	if (deathmatch.integer != 0 && g_dm_instant_items.integer != 0)
	{
		return true;
	}

	if (deathmatch.integer == 0 && level.instantitems)
	{
		return true;
	}

	return false;
}

bool Pickup_Powerup(ASEntity &ent, ASEntity &other)
{
	int quantity;

	quantity = other.client.pers.inventory[ent.item.id];
	if ((skill.integer == 0 && quantity >= 3) ||
		(skill.integer == 1 && quantity >= 2) ||
		(skill.integer >= 2 && quantity >= 1))
		return false;

	if (coop.integer != 0 && !P_UseCoopInstancedItems() && (ent.item.flags & item_flags_t::STAY_COOP) != 0 && (quantity > 0))
		return false;

	other.client.pers.inventory[ent.item.id]++;

	bool is_dropped_from_death = ent.spawnflags.has(spawnflags::item::DROPPED_PLAYER) && !ent.spawnflags.has(spawnflags::item::DROPPED);

	if (IsInstantItemsEnabled() ||
		((ent.item.use is Use_Quad) && is_dropped_from_death) ||
		((ent.item.use is Use_QuadFire) && is_dropped_from_death))
	{
		if ((ent.item.use is Use_Quad) && is_dropped_from_death)
			quad_drop_timeout_hack = (ent.nextthink - level.time);
		else if ((ent.item.use is Use_QuadFire) && is_dropped_from_death)
			quad_fire_drop_timeout_hack = (ent.nextthink - level.time);

		if (ent.item.use !is null)
			ent.item.use(other, ent.item);
	}

	if (deathmatch.integer != 0)
	{
		if (!ent.spawnflags.has(spawnflags::item::DROPPED) && !is_dropped_from_death)
			SetRespawn(ent, time_sec(ent.item.quantity));
	}

	return true;
}

bool Pickup_General(ASEntity &ent, ASEntity &other)
{
	if (other.client.pers.inventory[ent.item.id] != 0)
		return false;

	other.client.pers.inventory[ent.item.id]++;

	if (deathmatch.integer != 0)
	{
		if (!ent.spawnflags.has(spawnflags::item::DROPPED))
			SetRespawn(ent, time_sec(ent.item.quantity));
	}

	return true;
}

void Drop_General(ASEntity &ent, const gitem_t &item)
{
	ASEntity @dropped = Drop_Item(ent, item);
	dropped.spawnflags |= spawnflags::item::DROPPED_PLAYER;
	dropped.e.svflags = svflags_t(dropped.e.svflags & ~svflags_t::INSTANCED);
	ent.client.pers.inventory[item.id]--;
}

//======================================================================

void Use_Adrenaline(ASEntity &ent, const gitem_t &item)
{
	if (deathmatch.integer == 0)
		ent.max_health += 1;

	if (ent.health < ent.max_health)
		ent.health = ent.max_health;

	gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/n_health.wav"), 1, ATTN_NORM, 0);

	ent.client.pers.inventory[item.id]--;
}

bool Pickup_LegacyHead(ASEntity &ent, ASEntity &other)
{
	other.max_health += 5;
	other.health += 5;

	if (!ent.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
		SetRespawn(ent, time_sec(ent.item.quantity));

	return true;
}

void Drop_Ammo(ASEntity &ent, const gitem_t &item)
{
	// [Paril-KEX]
	if (G_CheckInfiniteAmmo(item))
		return;

	item_id_t index = item.id;
	ASEntity @dropped = Drop_Item(ent, item);
	dropped.spawnflags |= spawnflags::item::DROPPED_PLAYER;
	dropped.e.svflags = svflags_t(dropped.e.svflags & ~svflags_t::INSTANCED);

	if (ent.client.pers.inventory[index] >= item.quantity)
		dropped.count = item.quantity;
	else
		dropped.count = ent.client.pers.inventory[index];

	if (ent.client.pers.weapon !is null && ent.client.pers.weapon is item && (item.flags & item_flags_t::AMMO) != 0 &&
		ent.client.pers.inventory[index] - dropped.count <= 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_cant_drop_weapon");
		G_FreeEdict(dropped);
		return;
	}

	ent.client.pers.inventory[index] -= dropped.count;
	G_CheckPowerArmor(ent);
}


//======================================================================

void MegaHealth_Think(ASEntity &self)
{
	if (self.owner.health > self.owner.max_health
		//ZOID
		&& !CTFHasRegeneration(self.owner)
		//ZOID
		)
	{
		self.nextthink = level.time + time_sec(1);
		self.owner.health -= 1;
		return;
	}

	if (!self.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
		SetRespawn(self, time_sec(20));
	else
		G_FreeEdict(self);
}

bool Pickup_Health(ASEntity &ent, ASEntity &other)
{
	health_style_t health_flags = health_style_t(ent.style != 0 ? ent.style : int(ent.item.tag));

	if ((health_flags & health_style_t::IGNORE_MAX) == 0)
		if (other.health >= other.max_health)
			return false;

	int count = ent.count != 0 ? ent.count : ent.item.quantity;

	// ZOID
	if (deathmatch.integer != 0 && other.health >= 250 && count > 25)
		return false;
	// ZOID

	other.health += count;

	//ZOID
	if (ctf.integer != 0 && other.health > 250 && count > 25)
		other.health = 250;
	//ZOID

	if ((health_flags & health_style_t::IGNORE_MAX) == 0)
	{
		if (other.health > other.max_health)
			other.health = other.max_health;
	}

	if ((ent.item.tag & health_style_t::TIMED) != 0
		//ZOID
		&& !CTFHasRegeneration(other)
		//ZOID
		)
	{
		if (deathmatch.integer == 0)
		{
			// mega health doesn't need to be special in SP
			// since it never respawns.
			other.client.pers.megahealth_time = time_sec(5);
		}
		else
		{
			@ent.think = MegaHealth_Think;
			ent.nextthink = level.time + time_sec(5);
			@ent.owner = other;
			ent.flags = ent_flags_t(ent.flags | ent_flags_t::RESPAWN);
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
			ent.e.solid = solid_t::NOT;
		}
	}
	else
	{
		if (!ent.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
			SetRespawn(ent, time_sec(30));
	}

	return true;
}

//======================================================================

item_id_t ArmorIndex(ASEntity &ent)
{
	if ((ent.e.svflags & svflags_t::MONSTER) != 0)
		return ent.monsterinfo.armor_type;

	if (ent.client !is null)
	{
		if (ent.client.pers.inventory[item_id_t::ARMOR_JACKET] > 0)
			return item_id_t::ARMOR_JACKET;
		else if (ent.client.pers.inventory[item_id_t::ARMOR_COMBAT] > 0)
			return item_id_t::ARMOR_COMBAT;
		else if (ent.client.pers.inventory[item_id_t::ARMOR_BODY] > 0)
			return item_id_t::ARMOR_BODY;
	}

	return item_id_t::NULL;
}

bool Pickup_Armor(ASEntity &ent, ASEntity &other)
{
	item_id_t			 old_armor_index;
	const gitem_armor_t @oldinfo;
	const gitem_armor_t @newinfo;
	int					 newcount;
	float				 salvage;
	int					 salvagecount;

	// get info on new armor
	@newinfo = ent.item.armor_info;

	old_armor_index = ArmorIndex(other);

	// [Paril-KEX] for g_start_items
	int32 base_count = ent.count != 0 ? ent.count : newinfo !is null ? newinfo.base_count : 0;

	// handle armor shards specially
	if (ent.item.id == item_id_t::ARMOR_SHARD)
	{
		if (old_armor_index == item_id_t::NULL)
			other.client.pers.inventory[item_id_t::ARMOR_JACKET] = 2;
		else
			other.client.pers.inventory[old_armor_index] += 2;
	}
	// if player has no armor, just use it
	else if (old_armor_index == item_id_t::NULL)
	{
		other.client.pers.inventory[ent.item.id] = base_count;
	}

	// use the better armor
	else
	{
		// get info on old armor
		if (old_armor_index == item_id_t::ARMOR_JACKET)
			@oldinfo = jacketarmor_info;
		else if (old_armor_index == item_id_t::ARMOR_COMBAT)
			@oldinfo = combatarmor_info;
		else
			@oldinfo = bodyarmor_info;

		if (newinfo.normal_protection > oldinfo.normal_protection)
		{
			// calc new armor values
			salvage = oldinfo.normal_protection / newinfo.normal_protection;
			salvagecount = int(salvage * other.client.pers.inventory[old_armor_index]);
			newcount = base_count + salvagecount;
			if (newcount > newinfo.max_count)
				newcount = newinfo.max_count;

			// zero count of old armor so it goes away
			other.client.pers.inventory[old_armor_index] = 0;

			// change armor to new item with computed value
			other.client.pers.inventory[ent.item.id] = newcount;
		}
		else
		{
			// calc new armor values
			salvage = newinfo.normal_protection / oldinfo.normal_protection;
			salvagecount = int(salvage * base_count);
			newcount = other.client.pers.inventory[old_armor_index] + salvagecount;
			if (newcount > oldinfo.max_count)
				newcount = oldinfo.max_count;

			// if we're already maxed out then we don't need the new armor
			if (other.client.pers.inventory[old_armor_index] >= newcount)
				return false;

			// update current armor value
			other.client.pers.inventory[old_armor_index] = newcount;
		}
	}

	if (!ent.spawnflags.has(spawnflags::item::DROPPED) && deathmatch.integer != 0)
		SetRespawn(ent, time_sec(20));

	return true;
}


//======================================================================

item_id_t PowerArmorType(ASEntity &ent)
{
	if (ent.client is null)
		return item_id_t::NULL;

	if ((ent.flags & ent_flags_t::POWER_ARMOR) == 0)
		return item_id_t::NULL;

	if (ent.client.pers.inventory[item_id_t::ITEM_POWER_SHIELD] > 0)
		return item_id_t::ITEM_POWER_SHIELD;

	if (ent.client.pers.inventory[item_id_t::ITEM_POWER_SCREEN] > 0)
		return item_id_t::ITEM_POWER_SCREEN;

	return item_id_t::NULL;
}

void Use_PowerArmor(ASEntity &ent, const gitem_t &item)
{
	if ((ent.flags & ent_flags_t::POWER_ARMOR) != 0)
	{
		ent.flags = ent_flags_t(ent.flags & ~(ent_flags_t::POWER_ARMOR | ent_flags_t::WANTS_POWER_ARMOR));
		gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/power2.wav"), 1, ATTN_NORM, 0);
	}
	else
	{
		if (ent.client.pers.inventory[item_id_t::AMMO_CELLS] == 0)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_no_cells_power_armor");
			return;
		}

		ent.flags = ent_flags_t(ent.flags | ent_flags_t::POWER_ARMOR);

		if (ent.client.pers.autoshield != AUTO_SHIELD_MANUAL &&
			ent.client.pers.inventory[item_id_t::AMMO_CELLS] > ent.client.pers.autoshield)
			ent.flags = ent_flags_t(ent.flags | ent_flags_t::WANTS_POWER_ARMOR);

		gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/power1.wav"), 1, ATTN_NORM, 0);
	}
}

void G_CheckPowerArmor(ASEntity &ent)
{
	bool has_enough_cells;

	if (ent.client.pers.inventory[item_id_t::AMMO_CELLS] == 0)
		has_enough_cells = false;
	else if (ent.client.pers.autoshield >= AUTO_SHIELD_AUTO)
		has_enough_cells = (ent.flags & ent_flags_t::WANTS_POWER_ARMOR) != 0 &&
                           ent.client.pers.inventory[item_id_t::AMMO_CELLS] > ent.client.pers.autoshield;
	else
		has_enough_cells = true;

	if ((ent.flags & ent_flags_t::POWER_ARMOR) != 0)
	{
		if (!has_enough_cells)
		{
			// ran out of cells for power armor
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::POWER_ARMOR);
			gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/power2.wav"), 1, ATTN_NORM, 0);
		}
	}
	else
	{
		// special case for power armor, for auto-shields
		if (ent.client.pers.autoshield != AUTO_SHIELD_MANUAL &&
			has_enough_cells && (ent.client.pers.inventory[item_id_t::ITEM_POWER_SCREEN] != 0 ||
				ent.client.pers.inventory[item_id_t::ITEM_POWER_SHIELD] != 0))
		{
			ent.flags = ent_flags_t(ent.flags | ent_flags_t::POWER_ARMOR);
			gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/power1.wav"), 1, ATTN_NORM, 0);
		}
	}
}

bool Pickup_PowerArmor(ASEntity &ent, ASEntity &other)
{
	int quantity;

	quantity = other.client.pers.inventory[ent.item.id];

	other.client.pers.inventory[ent.item.id]++;

	if (deathmatch.integer != 0)
	{
		if (!ent.spawnflags.has(spawnflags::item::DROPPED))
			SetRespawn(ent, time_sec(ent.item.quantity));
		// auto-use for DM only if we didn't already have one
		if (quantity == 0)
			G_CheckPowerArmor(other);
	}
	else
		G_CheckPowerArmor(other);

	return true;
}

void Drop_PowerArmor(ASEntity &ent, const gitem_t &item)
{
	if ((ent.flags & ent_flags_t::POWER_ARMOR) != 0 && (ent.client.pers.inventory[item.id] == 1))
		Use_PowerArmor(ent, item);
	Drop_General(ent, item);
}

/*
===============
Touch_Item
===============
*/
void Touch_Item(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	bool taken;

	if (other.client is null)
		return;
	if (other.health < 1)
		return; // dead people can't pickup
	if (ent.item.pickup is null)
		return; // not a grabbable item?

	// already got this instanced item
	if (coop.integer != 0 && P_UseCoopInstancedItems())
	{
        // AS_TODO
		//if (ent.item_picked_up_by[other.s.number - 1])
		//	return;
	}

	// ZOID
	if (CTFMatchSetup())
		return; // can't pick stuff up right now
	// ZOID

	taken = ent.item.pickup(ent, other);

	ValidateSelectedItem(other);

	if (taken)
	{
		// flash the screen
		other.client.bonus_alpha = 0.25;

		// show icon and name on status bar
		other.e.client.ps.stats[player_stat_t::PICKUP_ICON] = gi_imageindex(ent.item.icon);
		other.e.client.ps.stats[player_stat_t::PICKUP_STRING] = configstring_id_t::ITEMS + ent.item.id;
		other.client.pickup_msg_time = level.time + time_sec(3);

		// change selected item if we still have it
		if (ent.item.use !is null && other.client.pers.inventory[ent.item.id] != 0)
		{
			other.e.client.ps.stats[player_stat_t::SELECTED_ITEM] = other.client.pers.selected_item = ent.item.id;
			other.e.client.ps.stats[player_stat_t::SELECTED_ITEM_NAME] = 0; // don't set name on pickup item since it's already there
		}

		if (ent.noise_index  != 0)
			gi_sound(other.e, soundchan_t::ITEM, ent.noise_index, 1, ATTN_NORM, 0);
		else if (!ent.item.pickup_sound.empty())
			gi_sound(other.e, soundchan_t::ITEM, gi_soundindex(ent.item.pickup_sound), 1, ATTN_NORM, 0);
		
        // AS_TODO
		/*int32 player_number = other.e.s.number - 1;

		if (coop.integer != 0 && P_UseCoopInstancedItems() && !ent.item_picked_up_by[player_number])
		{
			ent.item_picked_up_by[player_number] = true;

			// [Paril-KEX] this is to fix a coop quirk where items
			// that send a message on pick up will only print on the
			// player that picked them up, and never anybody else; 
			// when instanced items are enabled we don't need to limit
			// ourselves to this, but it does mean that relays that trigger
			// messages won't work, so we'll have to fix those
			if (ent.message)
				G_PrintActivationMessage(ent, other, false);
		}*/
	}

	if (!ent.spawnflags.has(spawnflags::item::TARGETS_USED))
	{
		// [Paril-KEX] see above msg; this also disables the message in DM
		// since there's no need to print pickup messages in DM (this wasn't
		// even a documented feature, relays were traditionally used for this)
        bool backup_message = deathmatch.integer == 0 || (coop.integer != 0 && P_UseCoopInstancedItems());
		string message_backup;

		if (backup_message)
        {
			message_backup = ent.message;
            ent.message = "";
        }

		G_UseTargets(ent, other);
		
		if (backup_message)
            ent.message = message_backup;

		ent.spawnflags |= spawnflags::item::TARGETS_USED;
	}

	if (taken)
	{
		bool should_remove = false;

		if (coop.integer != 0)
		{
			// in coop with instanced items, *only* dropped 
			// player items will ever get deleted permanently.
			if (P_UseCoopInstancedItems())
				should_remove = ent.spawnflags.has(spawnflags::item::DROPPED_PLAYER);
			// in coop without instanced items, IF_STAY_COOP items remain
			// if not dropped
			else
				should_remove = ent.spawnflags.has(spawnflags::item::DROPPED | spawnflags::item::DROPPED_PLAYER) || (ent.item.flags & item_flags_t::STAY_COOP) == 0;
		}
		else
			should_remove = deathmatch.integer == 0 || ent.spawnflags.has(spawnflags::item::DROPPED | spawnflags::item::DROPPED_PLAYER);

		if (should_remove)
		{
			if ((ent.flags & ent_flags_t::RESPAWN) != 0)
				ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::RESPAWN);
			else
				G_FreeEdict(ent);
		}
	}
}

//======================================================================

void drop_temp_touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other is ent.owner)
		return;

	Touch_Item(ent, other, tr, other_touching_self);
}

void drop_make_touchable(ASEntity &ent)
{
	@ent.touch = Touch_Item;
	if (deathmatch.integer != 0)
	{
		ent.nextthink = level.time + time_sec(29);
		@ent.think = G_FreeEdict;
	}
}

ASEntity @Drop_Item(ASEntity &ent, const gitem_t &item)
{
	ASEntity @dropped;
	vec3_t	 forward, right;
	vec3_t	 offset;

	@dropped = G_Spawn();

	@dropped.item = item;
	dropped.spawnflags = spawnflags::item::DROPPED;
	dropped.classname = item.classname;
	dropped.e.s.effects = item.world_model_flags;
	gi_setmodel(dropped.e, dropped.item.world_model);
	dropped.e.s.renderfx = renderfx_t(renderfx_t::GLOW | renderfx_t::NO_LOD | renderfx_t::IR_VISIBLE); // PGM
	dropped.e.mins = { -15, -15, -15 };
	dropped.e.maxs = { 15, 15, 15 };
	dropped.e.solid = solid_t::TRIGGER;
	dropped.movetype = movetype_t::TOSS;
	@dropped.touch = drop_temp_touch;
	@dropped.owner = ent;

	if (ent.client !is null)
	{
		trace_t trace;

		AngleVectors(ent.client.v_angle, forward, right);
		offset = { 24, 0, -16 };
		dropped.e.s.origin = G_ProjectSource(ent.e.s.origin, offset, forward, right);
		trace = gi_trace(ent.e.s.origin, dropped.e.mins, dropped.e.maxs, dropped.e.s.origin, ent.e, contents_t::SOLID);
		dropped.e.s.origin = trace.endpos;
	}
	else
	{
		AngleVectors(ent.e.s.angles, forward, right);
		dropped.e.s.origin = (ent.e.absmin + ent.e.absmax) / 2;
	}

	G_FixStuckObject(dropped, dropped.e.s.origin);

	dropped.velocity = forward * 100;
	dropped.velocity.z = 300;

	@dropped.think = drop_make_touchable;
	dropped.nextthink = level.time + time_sec(1);

	if (coop.integer != 0 && P_UseCoopInstancedItems())
		dropped.e.svflags = svflags_t(dropped.e.svflags | svflags_t::INSTANCED);

	gi_linkentity(dropped.e);

	return dropped;
}

void Use_Item(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::NOCLIENT);
	@ent.use = null;

	if (ent.spawnflags.has(spawnflags::item::NO_TOUCH))
	{
		ent.e.solid = solid_t::BBOX;
		@ent.touch = null;
	}
	else
	{
		ent.e.solid = solid_t::TRIGGER;
		@ent.touch = Touch_Item;
	}

	gi_linkentity(ent.e);
}

//======================================================================

/*
================
droptofloor
================
*/
void droptofloor(ASEntity &ent)
{
	trace_t tr;
	vec3_t	dest;

	// [Paril-KEX] scale foodcube based on how much we ingested
	if (ent.classname == "item_foodcube")
	{
		ent.e.mins = vec3_t(-8, -8, -8) * ent.e.s.scale;
		ent.e.maxs = vec3_t(8, 8, 8) * ent.e.s.scale;
	}
	else
	{
		ent.e.mins = { -15, -15, -15 };
		ent.e.maxs = { 15, 15, 15 };
	}

	if (!ent.model.empty())
		gi_setmodel(ent.e, ent.model);
	else
		gi_setmodel(ent.e, ent.item.world_model);
	ent.e.solid = solid_t::TRIGGER;
	@ent.touch = Touch_Item;

	if (!ent.spawnflags.has(spawnflags::item::NO_DROP))
	{
		ent.movetype = movetype_t::TOSS;
		dest = ent.e.s.origin + vec3_t(0, 0, -128);

		tr = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, dest, ent.e, contents_t::MASK_SOLID);
		if (tr.startsolid)
		{
			if (G_FixStuckObject(ent, ent.e.s.origin) == stuck_result_t::NO_GOOD_POSITION)
			{
				// RAFAEL
				if (ent.classname == "item_foodcube")
					ent.velocity.z = 0;
				else
				{
					// RAFAEL
					gi_Com_Print("{}: droptofloor: startsolid\n", ent);
					ent.Free();
					return;
					// RAFAEL
				}
				// RAFAEL
			}
		}
		else
			ent.e.s.origin = tr.endpos;
	}

	if (!ent.team.empty())
	{
		ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::TEAMSLAVE);
		@ent.chain = ent.teamchain;
		@ent.teamchain = null;

		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.e.solid = solid_t::NOT;

		if (ent is ent.teammaster)
		{
			ent.nextthink = level.time + time_hz(10);
			@ent.think = DoRespawn;
		}
	}

	if (ent.spawnflags.has(spawnflags::item::NO_TOUCH))
	{
		ent.e.solid = solid_t::BBOX;
		@ent.touch = null;
		ent.e.s.effects = effects_t(ent.e.s.effects & ~(effects_t::ROTATE | effects_t::BOB));
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx & ~renderfx_t::GLOW);
	}

	if (ent.spawnflags.has(spawnflags::item::TRIGGER_SPAWN))
	{
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.e.solid = solid_t::NOT;
		@ent.use = Use_Item;
	}

	ent.watertype = gi_pointcontents(ent.e.s.origin);
	gi_linkentity(ent.e);
}

/*
===============
PrecacheItem

Precaches all data needed for a given item.
This will be called for each item spawned in a level,
and for each item in each client's inventory.
===============
*/
void PrecacheItem(const gitem_t &it)
{
	const gitem_t	@ammo;

	if (!it.pickup_sound.empty())
		gi_soundindex(it.pickup_sound);
	if (!it.world_model.empty())
		gi_modelindex(it.world_model);
	if (!it.view_model.empty())
		gi_modelindex(it.view_model);
	if (!it.icon.empty())
		gi_imageindex(it.icon);

	// parse everything for its ammo
	if (it.ammo != item_id_t::NULL)
	{
		@ammo = GetItemByIndex(it.ammo);
		if (!(ammo is it))
			PrecacheItem(ammo);
	}

	// parse the space seperated precache string for other items
	if (it.precaches.empty())
		return;

    array<string> entries = it.precaches.split(" ");

	for (uint i = 0; i < entries.length(); i++)
	{
        if (entries[i].empty())
            continue;

		// determine type based on extension
		if (entries[i].findFirst(".md2") != -1)
			gi_modelindex(entries[i]);
		else if (entries[i].findFirst(".sp2") != -1)
			gi_modelindex(entries[i]);
		else if (entries[i].findFirst(".wav") != -1)
			gi_soundindex(entries[i]);
		else if (entries[i].findFirst(".pcx") != -1)
			gi_imageindex(entries[i]);
	}
}

/*
============
SpawnItem

Sets the clipping size and plants the object on the floor.

Items can't be immediately dropped to floor, because they might
be on an entity that hasn't spawned yet.
============
*/
void SpawnItem(ASEntity &ent, const gitem_t @item, const spawn_temp_t &in st)
{
	// [Sam-KEX]
	// Paril: allow all keys to be trigger_spawn'd (N64 uses this
	// a few different times)
	if ((item.flags & item_flags_t::KEY) != 0)
	{
		if (ent.spawnflags.has(spawnflags::item::TRIGGER_SPAWN))
		{
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
			ent.e.solid = solid_t::NOT;
			@ent.use = Use_Item;
		}
		if (ent.spawnflags.has(spawnflags::item::NO_TOUCH))
		{
			ent.e.solid = solid_t::BBOX;
			@ent.touch = null;
			ent.e.s.effects = effects_t(ent.e.s.effects & ~(effects_t::ROTATE | effects_t::BOB));
			ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx & ~renderfx_t::GLOW);
		}
	}
	else if (uint(ent.spawnflags) >= uint(spawnflags::item::MAX)) // PGM
	{
		ent.spawnflags = spawnflags::NONE;
		gi_Com_Print("{} has invalid spawnflags set\n", ent);
	}

	// some items will be prevented in deathmatch
	if (deathmatch.integer != 0)
	{
		// [Kex] In instagib, spawn no pickups!
		if (g_instagib.value != 0)
		{
			if (item.pickup is Pickup_Armor || item.pickup is Pickup_PowerArmor ||
				item.pickup is Pickup_Powerup || item.pickup is Pickup_Sphere || item.pickup is Pickup_Doppleganger ||
				(item.flags & item_flags_t::HEALTH) != 0 || (item.flags & item_flags_t::AMMO) != 0 || item.pickup is Pickup_Weapon ||
                item.pickup is Pickup_Pack || item.id == item_id_t::ITEM_BANDOLIER || item.id == item_id_t::ITEM_PACK ||
				item.id == item_id_t::AMMO_NUKE)
			{
				G_FreeEdict(ent);
				return;
			}
		}

		if (g_no_armor.integer != 0)
		{
            if (item.pickup is Pickup_Armor || item.pickup is Pickup_PowerArmor)
			{
				G_FreeEdict(ent);
				return;
			}
		}
		if (g_no_items.integer != 0)
		{
			if (item.pickup is Pickup_Powerup)
			{
				G_FreeEdict(ent);
				return;
			}

			//=====
			// ROGUE
			if (item.pickup is Pickup_Sphere)
			{
				G_FreeEdict(ent);
				return;
			}
			if (item.pickup is Pickup_Doppleganger)
			{
				G_FreeEdict(ent);
				return;
			}
			// ROGUE
			//=====
		}
		if (g_no_health.integer != 0)
		{
			if ((item.flags & item_flags_t::HEALTH) != 0)
			{
				G_FreeEdict(ent);
				return;
			}
		}
		if (G_CheckInfiniteAmmo(item))
		{
			if (item.flags == item_flags_t::AMMO)
			{
				G_FreeEdict(ent);
				return;
			}

			// [Paril-KEX] some item swappage 
			// BFG too strong in Infinite Ammo mode
			if (item.id == item_id_t::WEAPON_BFG)
				@item = GetItemByIndex(item_id_t::WEAPON_DISRUPTOR);
		}

		//==========
		// ROGUE
		if (g_no_mines.integer != 0)
		{
			if (item.id == item_id_t::WEAPON_PROXLAUNCHER || item.id == item_id_t::AMMO_PROX ||
                item.id == item_id_t::AMMO_TESLA || item.id == item_id_t::AMMO_TRAP)
			{
				G_FreeEdict(ent);
				return;
			}
		}
		if (g_no_nukes.integer != 0)
		{
			if (item.id == item_id_t::AMMO_NUKE)
			{
				G_FreeEdict(ent);
				return;
			}
		}
		if (g_no_spheres.integer != 0)
		{
			if (item.pickup is Pickup_Sphere)
			{
				G_FreeEdict(ent);
				return;
			}
		}
		// ROGUE
		//==========
	}

	//==========
	// ROGUE
	// DM only items
	if (deathmatch.integer == 0)
	{
		if (item.pickup is Pickup_Doppleganger || item.pickup is Pickup_Nuke)
		{
			gi_Com_Print("{} spawned in non-DM; freeing...\n", ent);
			G_FreeEdict(ent);
			return;
		}
		if ((item.use is Use_Vengeance) || (item.use is Use_Hunter))
		{
			gi_Com_Print("{} spawned in non-DM; freeing...\n", ent);
			G_FreeEdict(ent);
			return;
		}
	}
	// ROGUE
	//==========

	// [Paril-KEX] power armor breaks infinite ammo
	if (G_CheckInfiniteAmmo(item))
	{
		if (item.id == item_id_t::ITEM_POWER_SHIELD || item.id == item_id_t::ITEM_POWER_SCREEN)
			@item = GetItemByIndex(item_id_t::ARMOR_BODY);
	}

	// ZOID
	// Don't spawn the flags unless enabled
	if (ctf.integer == 0 && (item.id == item_id_t::FLAG1 || item.id == item_id_t::FLAG2))
	{
		G_FreeEdict(ent);
		return;
	}
	// ZOID

	// set final classname now
	ent.classname = item.classname;

	PrecacheItem(item);

	if (coop.integer != 0 && (item.id == item_id_t::KEY_POWER_CUBE || item.id == item_id_t::KEY_EXPLOSIVE_CHARGES))
	{
		ent.spawnflags |= spawnflag_dec(1 << (8 + level.power_cubes));
		level.power_cubes++;
	}

	// mark all items as instanced
	if (coop.integer != 0)
	{
		if (P_UseCoopInstancedItems())
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::INSTANCED);
	}

	@ent.item = item;
	ent.nextthink = level.time + time_hz(20); // items start after other solids
	@ent.think = droptofloor;
	if (!(level.is_spawning && st.was_key_specified("effects")) && ent.e.s.effects == effects_t::NONE)
		ent.e.s.effects = item.world_model_flags;
	if (!(level.is_spawning && st.was_key_specified("renderfx")) && ent.e.s.renderfx == renderfx_t::NONE)
		ent.e.s.renderfx = renderfx_t::GLOW;
	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::NO_LOD);
	if (!ent.model.empty())
		gi_modelindex(ent.model);

	if (ent.spawnflags.has(spawnflags::item::TRIGGER_SPAWN))
		SetTriggeredSpawn(ent);

	// ZOID
	// flags are server animated and have special handling
	if (item.id == item_id_t::FLAG1 || item.id == item_id_t::FLAG2)
	{
		@ent.think = CTFFlagSetup;
	}
	// ZOID
}

void P_ToggleFlashlight(ASEntity &ent, bool state)
{
	if (((ent.flags & ent_flags_t::FLASHLIGHT) != 0) == state)
		return;

	ent.flags = ent_flags_t(ent.flags ^ ent_flags_t::FLASHLIGHT);

	gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex((ent.flags & ent_flags_t::FLASHLIGHT) != 0 ? "items/flashlight_on.wav" : "items/flashlight_off.wav"), 1.f, ATTN_STATIC, 0);
}

void Use_Flashlight(ASEntity &ent, const gitem_t &inv)
{
	P_ToggleFlashlight(ent, (ent.flags & ent_flags_t::FLASHLIGHT) == 0);
}

void Compass_Update(ASEntity &ent, bool first)
{
    // AS_TODO: move this elsewhere
    if (level.poi_points.empty())
        level.poi_points.resize(max_clients);

	array<vec3_t> @points = level.poi_points[ent.e.s.number - 1];

	// deleted for some reason
	if (points.empty())
		return;

	if (!ent.client.help_draw_points)
		return;
	if (ent.client.help_draw_time >= level.time)
		return;

	// don't draw too many points
	float distance = (points[ent.client.help_draw_index] - ent.e.s.origin).length();
	if (distance > 4096 ||
		!gi_inPHS(ent.e.s.origin, points[ent.client.help_draw_index], false))
	{
		ent.client.help_draw_points = false;
		return;
	}

	gi_WriteByte(svc_t::help_path);
	gi_WriteByte(first ? 1 : 0);
	gi_WritePosition(points[ent.client.help_draw_index]);
	
	if (ent.client.help_draw_index == ent.client.help_draw_count - 1)
		gi_WriteDir((ent.client.help_poi_location - points[ent.client.help_draw_index]).normalized());
	else
		gi_WriteDir((points[ent.client.help_draw_index + 1] - points[ent.client.help_draw_index]).normalized());
	gi_unicast(ent.e, false);

	P_SendLevelPOI(ent);

	gi_local_sound(ent.e, points[ent.client.help_draw_index], world.e, soundchan_t::AUTO, gi_soundindex("misc/help_marker.wav"), 1.0f, ATTN_NORM, 0.0f, GetUnicastKey());

	// done
	if (ent.client.help_draw_index == ent.client.help_draw_count - 1)
	{
		ent.client.help_draw_points = false;
		return;
	}

	ent.client.help_draw_index++;
	ent.client.help_draw_time = level.time + time_ms(200);
}

void Use_Compass(ASEntity &ent, const gitem_t &inv)
{
	if (!level.valid_poi)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$no_valid_poi");
		return;
	}

	if (level.current_dynamic_poi !is null)
		level.current_dynamic_poi.use(level.current_dynamic_poi, ent, ent);
	
	ent.client.help_poi_location = level.current_poi;
	ent.client.help_poi_image = level.current_poi_image;

    // AS_TODO: move this elsewhere
    if (level.poi_points.empty())
        level.poi_points.resize(max_clients);

	array<vec3_t> points;

	PathRequest request;
	request.start = ent.e.s.origin;
	request.goal = level.current_poi;
	request.moveDist = 64.f;
	request.pathFlags = PathFlags::All;
	request.nodeSearch.ignoreNodeFlags = true;
	request.nodeSearch.minHeight = 128.0f;
	request.nodeSearch.maxHeight = 128.0f;
	request.nodeSearch.radius = 1024.0f;
	request.maxPathPoints = 128;

	PathInfo info;

	if (gi_GetPathToGoal(request, info))
	{
        points.resize(info.numPathPoints + 1);

        points[0] = vec3_origin;
        for (uint i = 1; i < info.numPathPoints; i++)
            points[i] = info.getPathPoint(i); // TODO: code-wise copy?

		// TODO: optimize points?
		ent.client.help_draw_points = true;
		ent.client.help_draw_count = min(info.numPathPoints, 128);
		ent.client.help_draw_index = 1;

		// remove points too close to the player so they don't have to backtrack
		for (uint i = 1; i < 1 + ent.client.help_draw_count; i++)
		{
			float distance = (points[i] - ent.e.s.origin).length();
			if (distance > 192)
			{
				break;
			}

			ent.client.help_draw_index = i;
		}

		// create an extra point in front of us if we're facing away from the first real point
		float d = ((points[ent.client.help_draw_index]) - ent.e.s.origin).normalized().dot(ent.client.v_forward);

		if (d < 0.3f)
		{
			vec3_t p = ent.e.s.origin + (ent.client.v_forward * 64.f);

			trace_t tr = gi_traceline(ent.e.s.origin + vec3_t(0.0f, 0.0f, float(ent.viewheight)), p, null, contents_t::MASK_SOLID);

			ent.client.help_draw_index--;
			ent.client.help_draw_count++;

			if (tr.fraction < 1.0f)
				tr.endpos += tr.plane.normal * 8.f;

			points[ent.client.help_draw_index] = tr.endpos;
		}

        level.poi_points[ent.e.s.number - 1] = points;

		ent.client.help_draw_time = time_zero;
		Compass_Update(ent, true);
	}
	else
	{
		P_SendLevelPOI(ent);
		gi_local_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/help_marker.wav"), 1.0f, ATTN_NORM, 0, GetUnicastKey());
	}
}

array<gitem_t@> itemlist = {
    gitem_t(),


	//
	// ARMOR
	//
	

/*QUAKED item_armor_body (.3 .3 1) (-16 -16 -16) (16 16 16)
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/items/armor/body/tris.md2"
*/
	gitem_t(
		id: item_id_t::ARMOR_BODY,
		classname: "item_armor_body", 
		pickup: Pickup_Armor,
		pickup_sound: "misc/ar3_pkup.wav",
		world_model: "models/items/armor/body/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_bodyarmor",
		use_name: "Body Armor",
		pickup_name: "$item_body_armor",
		pickup_name_definite: "$item_body_armor_def",
		flags: item_flags_t::ARMOR,
		armor_info: bodyarmor_info
	),

/*QUAKED item_armor_combat (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ARMOR_COMBAT,
		classname: "item_armor_combat", 
		pickup: Pickup_Armor,
		pickup_sound: "misc/ar1_pkup.wav",
		world_model: "models/items/armor/combat/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_combatarmor",
		use_name:  "Combat Armor",
		pickup_name:  "$item_combat_armor",
		pickup_name_definite: "$item_combat_armor_def",
		flags: item_flags_t::ARMOR,
		armor_info: combatarmor_info
	),

/*QUAKED item_armor_jacket (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ARMOR_JACKET,
		classname: "item_armor_jacket", 
		pickup: Pickup_Armor,
		pickup_sound: "misc/ar1_pkup.wav",
		world_model: "models/items/armor/jacket/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_jacketarmor",
		use_name:  "Jacket Armor",
		pickup_name:  "$item_jacket_armor",
		pickup_name_definite: "$item_jacket_armor_def",
		flags: item_flags_t::ARMOR,
		armor_info: jacketarmor_info
	),

/*QUAKED item_armor_shard (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ARMOR_SHARD,
		classname: "item_armor_shard", 
		pickup: Pickup_Armor,
		pickup_sound: "misc/ar2_pkup.wav",
		world_model: "models/items/armor/shard/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_armor_shard",
		use_name:  "Armor Shard",
		pickup_name:  "$item_armor_shard",
		pickup_name_definite: "$item_armor_shard_def",
		flags: item_flags_t::ARMOR
	),

/*QUAKED item_power_screen (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_POWER_SCREEN,
		classname: "item_power_screen", 
		pickup: Pickup_PowerArmor,
		use: Use_PowerArmor,
		drop: Drop_PowerArmor,
		pickup_sound: "misc/ar3_pkup.wav",
		world_model: "models/items/armor/screen/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_powerscreen",
		use_name:  "Power Screen",
		pickup_name:  "$item_power_screen",
		pickup_name_definite: "$item_power_screen_def",
		quantity: 60,
		ammo: item_id_t::AMMO_CELLS,
		flags: item_flags_t(item_flags_t::ARMOR | item_flags_t::POWERUP_WHEEL | item_flags_t::POWERUP_ONOFF),
		tag: powerup_t::SCREEN,
		precaches: "misc/power2.wav misc/power1.wav"
	),

/*QUAKED item_power_shield (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_POWER_SHIELD,
		classname: "item_power_shield",
		pickup: Pickup_PowerArmor,
		use: Use_PowerArmor,
		drop: Drop_PowerArmor,
		pickup_sound: "misc/ar3_pkup.wav",
		world_model: "models/items/armor/shield/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_powershield",
		use_name:  "Power Shield",
		pickup_name:  "$item_power_shield",
		pickup_name_definite: "$item_power_shield_def",
		quantity: 60,
		ammo: item_id_t::AMMO_CELLS,
		flags: item_flags_t(item_flags_t::ARMOR | item_flags_t::POWERUP_WHEEL | item_flags_t::POWERUP_ONOFF),
		tag: powerup_t::SHIELD,
		precaches: "misc/power2.wav misc/power1.wav"
	),

	//
	// WEAPONS 
	//

/* weapon_grapple (.3 .3 1) (-16 -16 -16) (16 16 16)
always owned, never in the world
*/
	gitem_t(
		id: item_id_t::WEAPON_GRAPPLE,
		classname: "weapon_grapple", 
		use: Use_Weapon,
		weaponthink: CTFWeapon_Grapple,
		view_model: "models/weapons/grapple/tris.md2",
		icon: "w_grapple",
		use_name:  "Grapple",
		pickup_name:  "$item_grapple",
		pickup_name_definite: "$item_grapple_def",
		chain: item_id_t::WEAPON_BLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::NO_HASTE | item_flags_t::POWERUP_WHEEL | item_flags_t::NOT_RANDOM),
		vwep_model: "#w_grapple.md2",
		precaches: "weapons/grapple/grfire.wav weapons/grapple/grpull.wav weapons/grapple/grhang.wav weapons/grapple/grreset.wav weapons/grapple/grhit.wav weapons/grapple/grfly.wav"
    ),

/* weapon_blaster (.3 .3 1) (-16 -16 -16) (16 16 16)
always owned, never in the world
*/
	gitem_t(
		id: item_id_t::WEAPON_BLASTER,
		classname: "weapon_blaster", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		weaponthink: Weapon_Blaster,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_blast/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_blast/tris.md2",
		icon: "w_blaster",
		use_name:  "Blaster",
		pickup_name:  "$item_blaster",
		pickup_name_definite: "$item_blaster_def",
		chain: item_id_t::WEAPON_BLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP | item_flags_t::NOT_RANDOM),
		vwep_model: "#w_blaster.md2",
		precaches: "weapons/blastf1a.wav misc/lasfly.wav"
    ),

	/*QUAKED weapon_chainfist (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
	*/
	gitem_t(
		id: item_id_t::WEAPON_CHAINFIST,
		classname: "weapon_chainfist",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_ChainFist,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_chainf/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_chainf/tris.md2",
		icon: "w_chainfist",
		use_name:  "Chainfist",
		pickup_name:  "$item_chainfist",
		pickup_name_definite: "$item_chainfist_def",
		chain: item_id_t::WEAPON_BLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_chainfist.md2",
		precaches: "weapons/sawidle.wav weapons/sawhit.wav weapons/sawslice.wav"
	),

/*QUAKED weapon_shotgun (.3 .3 1) (-16 -16 -16) (16 16 16)
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/weapons/g_shotg/tris.md2"
*/
	gitem_t(
		id: item_id_t::WEAPON_SHOTGUN,
		classname: "weapon_shotgun", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Shotgun,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_shotg/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_shotg/tris.md2",
		icon: "w_shotgun",
		use_name:  "Shotgun",
		pickup_name:  "$item_shotgun",
		pickup_name_definite: "$item_shotgun_def",
		quantity: 1,
		ammo: item_id_t::AMMO_SHELLS,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_shotgun.md2",
		precaches: "weapons/shotgf1b.wav weapons/shotgr1b.wav"
    ),

/*QUAKED weapon_supershotgun (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_SSHOTGUN,
		classname: "weapon_supershotgun", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_SuperShotgun,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_shotg2/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_shotg2/tris.md2",
		icon: "w_sshotgun",
		use_name:  "Super Shotgun",
		pickup_name:  "$item_super_shotgun",
		pickup_name_definite: "$item_super_shotgun_def",
		quantity: 2,
		ammo: item_id_t::AMMO_SHELLS,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_sshotgun.md2",
		precaches: "weapons/sshotf1b.wav",
		quantity_warn: 10
    ),

/*QUAKED weapon_machinegun (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_MACHINEGUN,
		classname: "weapon_machinegun", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Machinegun,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_machn/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_machn/tris.md2",
		icon: "w_machinegun",
		use_name:  "Machinegun",
		pickup_name:  "$item_machinegun",
		pickup_name_definite: "$item_machinegun_def",
		quantity: 1,
		ammo: item_id_t::AMMO_BULLETS,
		chain: item_id_t::WEAPON_MACHINEGUN,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_machinegun.md2",
		precaches: "weapons/machgf1b.wav weapons/machgf2b.wav weapons/machgf3b.wav weapons/machgf4b.wav weapons/machgf5b.wav",
		quantity_warn: 30
    ),

	// ROGUE
/*QUAKED weapon_etf_rifle (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::WEAPON_ETF_RIFLE,
		classname: "weapon_etf_rifle",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_ETF_Rifle,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_etf_rifle/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_etf_rifle/tris.md2",
		icon: "w_etf_rifle",
		use_name:  "ETF Rifle",
		pickup_name:  "$item_etf_rifle",
		pickup_name_definite: "$item_etf_rifle_def",
		quantity: 1,
		ammo: item_id_t::AMMO_FLECHETTES,
		chain: item_id_t::WEAPON_MACHINEGUN,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_etfrifle.md2",
		precaches: "weapons/nail1.wav models/proj/flechette/tris.md2",
		quantity_warn: 30
	),
	// ROGUE

/*QUAKED weapon_chaingun (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_CHAINGUN,
		classname: "weapon_chaingun", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Chaingun,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_chain/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_chain/tris.md2",
		icon: "w_chaingun",
		use_name:  "Chaingun",
		pickup_name:  "$item_chaingun",
		pickup_name_definite: "$item_chaingun_def",
		quantity: 1,
		ammo: item_id_t::AMMO_BULLETS,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_chaingun.md2",
		precaches: "weapons/chngnu1a.wav weapons/chngnl1a.wav weapons/machgf3b.wav weapons/chngnd1a.wav",
		quantity_warn: 60
    ),

/*QUAKED ammo_grenades (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_GRENADES,
		classname: "ammo_grenades",
		pickup: Pickup_Ammo,
		use: Use_Weapon,
		drop: Drop_Ammo,
		weaponthink: Weapon_Grenade,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/grenades/medium/tris.md2",
		world_model_flags: effects_t::NONE,
		view_model: "models/weapons/v_handgr/tris.md2",
		icon: "a_grenades",
		use_name:  "Grenades",
		pickup_name:  "$item_grenades",
		pickup_name_definite: "$item_grenades_def",
		quantity: 5,
		ammo: item_id_t::AMMO_GRENADES,
		chain: item_id_t::AMMO_GRENADES,
		flags: item_flags_t(item_flags_t::AMMO | item_flags_t::WEAPON),
		vwep_model: "#a_grenades.md2",
		tag: ammo_t::GRENADES,
		precaches: "weapons/hgrent1a.wav weapons/hgrena1b.wav weapons/hgrenc1b.wav weapons/hgrenb1a.wav weapons/hgrenb2a.wav models/objects/grenade3/tris.md2",
		quantity_warn: 2
    ),

// RAFAEL
/*QUAKED ammo_trap (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_TRAP,
		classname: "ammo_trap",
		pickup: Pickup_Ammo,
		use: Use_Weapon,
		drop: Drop_Ammo,
		weaponthink: Weapon_Trap,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/weapons/g_trap/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_trap/tris.md2",
		icon: "a_trap",
		use_name:  "Trap",
		pickup_name:  "$item_trap",
		pickup_name_definite: "$item_trap_def",
		quantity: 1,
		ammo: item_id_t::AMMO_TRAP,
		chain: item_id_t::AMMO_GRENADES,
		flags: item_flags_t(item_flags_t::AMMO | item_flags_t::WEAPON | item_flags_t::NO_INFINITE_AMMO),
		vwep_model: "#a_trap.md2",
		tag: ammo_t::TRAP,
		precaches: "misc/fhit3.wav weapons/trapcock.wav weapons/traploop.wav weapons/trapsuck.wav weapons/trapdown.wav items/s_health.wav items/n_health.wav items/l_health.wav items/m_health.wav models/weapons/z_trap/tris.md2",
		quantity_warn: 1
	),
// RAFAEL

/*QUAKED ammo_tesla (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::AMMO_TESLA,
		classname: "ammo_tesla",
		pickup: Pickup_Ammo,
		use: Use_Weapon,
		drop: Drop_Ammo,
		weaponthink: Weapon_Tesla,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/ammo/am_tesl/tris.md2",
		world_model_flags: effects_t::NONE,
		view_model: "models/weapons/v_tesla/tris.md2",
		icon: "a_tesla",
		use_name:  "Tesla",
		pickup_name:  "$item_tesla",
		pickup_name_definite: "$item_tesla_def",
		quantity: 3,
		ammo: item_id_t::AMMO_TRAP,
		chain: item_id_t::AMMO_GRENADES,
		flags: item_flags_t(item_flags_t::AMMO | item_flags_t::WEAPON | item_flags_t::NO_INFINITE_AMMO),
		vwep_model: "#a_tesla.md2",
		tag: ammo_t::TESLA,
		precaches: "weapons/teslaopen.wav weapons/hgrenb1a.wav weapons/hgrenb2a.wav models/weapons/g_tesla/tris.md2",
		quantity_warn: 1
    ),

/*QUAKED weapon_grenadelauncher (.3 .3 1) (-16 -16 -16) (16 16 16)
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/weapons/g_launch/tris.md2"
*/
	gitem_t(
		id: item_id_t::WEAPON_GLAUNCHER,
		classname: "weapon_grenadelauncher",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_GrenadeLauncher,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_launch/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_launch/tris.md2",
		icon: "w_glauncher",
		use_name:  "Grenade Launcher",
		pickup_name:  "$item_grenade_launcher",
		pickup_name_definite: "$item_grenade_launcher_def",
		quantity: 1,
		ammo: item_id_t::AMMO_GRENADES,
		chain: item_id_t::WEAPON_GLAUNCHER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_glauncher.md2",
		precaches: "models/objects/grenade4/tris.md2 weapons/grenlf1a.wav weapons/grenlr1b.wav weapons/grenlb1b.wav"
	),

	// ROGUE
/*QUAKED weapon_proxlauncher (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::WEAPON_PROXLAUNCHER,
		classname: "weapon_proxlauncher",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_ProxLauncher,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_plaunch/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_plaunch/tris.md2",
		icon: "w_proxlaunch",
		use_name:  "Prox Launcher",
		pickup_name:  "$item_prox_launcher",
		pickup_name_definite: "$item_prox_launcher_def",
		quantity: 1,
		ammo: item_id_t::AMMO_PROX,
		chain: item_id_t::WEAPON_GLAUNCHER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_plauncher.md2",
		precaches: "weapons/grenlf1a.wav weapons/grenlr1b.wav weapons/grenlb1b.wav weapons/proxwarn.wav weapons/proxopen.wav"
	),
	// ROGUE

/*QUAKED weapon_rocketlauncher (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_RLAUNCHER,
		classname: "weapon_rocketlauncher",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_RocketLauncher,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_rocket/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_rocket/tris.md2",
		icon: "w_rlauncher",
		use_name:  "Rocket Launcher",
		pickup_name:  "$item_rocket_launcher",
		pickup_name_definite: "$item_rocket_launcher_def",
		quantity: 1,
		ammo: item_id_t::AMMO_ROCKETS,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_rlauncher.md2",
		precaches: "models/objects/rocket/tris.md2 weapons/rockfly.wav weapons/rocklf1a.wav weapons/rocklr1b.wav models/objects/debris2/tris.md2"
	),

/*QUAKED weapon_hyperblaster (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_HYPERBLASTER,
		classname: "weapon_hyperblaster", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_HyperBlaster,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_hyperb/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_hyperb/tris.md2",
		icon: "w_hyperblaster",
		use_name:  "HyperBlaster",
		pickup_name:  "$item_hyperblaster",
		pickup_name_definite: "$item_hyperblaster_def",
		quantity: 1,
		ammo: item_id_t::AMMO_CELLS,
		chain: item_id_t::WEAPON_HYPERBLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_hyperblaster.md2",
		precaches: "weapons/hyprbu1a.wav weapons/hyprbl1a.wav weapons/hyprbf1a.wav weapons/hyprbd1a.wav misc/lasfly.wav",
		quantity_warn: 30
    ),

// RAFAEL
/*QUAKED weapon_boomer (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_IONRIPPER,
		classname: "weapon_boomer",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Ionripper,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_boom/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_boomer/tris.md2",
		icon: "w_ripper",
		use_name:  "Ionripper",
		pickup_name:  "$item_ionripper",
		pickup_name_definite: "$item_ionripper_def",
		quantity: 2,
		ammo: item_id_t::AMMO_CELLS,
		chain: item_id_t::WEAPON_HYPERBLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_ripper.md2",
		precaches: "weapons/rippfire.wav models/objects/boomrang/tris.md2 misc/lasfly.wav",
		quantity_warn: 30
	),
// RAFAEL

// ROGUE
	/*QUAKED weapon_plasmabeam (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
	*/ 
	gitem_t(
		id: item_id_t::WEAPON_PLASMABEAM,
		classname: "weapon_plasmabeam",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Heatbeam,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_beamer/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_beamer/tris.md2",
		icon: "w_heatbeam",
		use_name:  "Plasma Beam",
		pickup_name:  "$item_plasma_beam",
		pickup_name_definite: "$item_plasma_beam_def",
		quantity: 2,
		ammo: item_id_t::AMMO_CELLS,
		chain: item_id_t::WEAPON_HYPERBLASTER,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_plasma.md2",
		precaches: "weapons/bfg__l1a.wav",
		quantity_warn: 50
    ),
//rogue

/*QUAKED weapon_railgun (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_RAILGUN,
		classname: "weapon_railgun", 
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Railgun,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_rail/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_rail/tris.md2",
		icon: "w_railgun",
		use_name:  "Railgun",
		pickup_name:  "$item_railgun",
		pickup_name_definite: "$item_railgun_def",
		quantity: 1,
		ammo: item_id_t::AMMO_SLUGS,
		chain: item_id_t::WEAPON_RAILGUN,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_railgun.md2",
		precaches: "weapons/rg_hum.wav"
	),

// RAFAEL 14-APR-98
/*QUAKED weapon_phalanx (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_PHALANX,
		classname: "weapon_phalanx",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Phalanx,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_shotx/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_shotx/tris.md2",
		icon: "w_phallanx",
		use_name:  "Phalanx",
		pickup_name:  "$item_phalanx",
		pickup_name_definite: "$item_phalanx_def",
		quantity: 1,
		ammo: item_id_t::AMMO_MAGSLUG,
		chain: item_id_t::WEAPON_RAILGUN,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_phalanx.md2",
		precaches: "weapons/plasshot.wav sprites/s_photon.sp2 weapons/rockfly.wav"
    ),
// RAFAEL

/*QUAKED weapon_bfg (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::WEAPON_BFG,
		classname: "weapon_bfg",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_BFG,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_bfg/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_bfg/tris.md2",
		icon: "w_bfg",
		use_name:  "BFG10K",
		pickup_name:  "$item_bfg10k",
		pickup_name_definite: "$item_bfg10k_def",
		quantity: 50,
		ammo: item_id_t::AMMO_CELLS,
		chain: item_id_t::WEAPON_BFG,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_bfg.md2",
		precaches: "sprites/s_bfg1.sp2 sprites/s_bfg2.sp2 sprites/s_bfg3.sp2 weapons/bfg__f1y.wav weapons/bfg__l1a.wav weapons/bfg__x1b.wav weapons/bfg_hum.wav",
		quantity_warn: 50
	),

	// =========================
	// ROGUE WEAPONS
	/*QUAKED weapon_disintegrator (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
	*/
	gitem_t(
		id: item_id_t::WEAPON_DISRUPTOR,
		classname: "weapon_disintegrator",
		pickup: Pickup_Weapon,
		use: Use_Weapon,
		drop: Drop_Weapon,
		weaponthink: Weapon_Disintegrator,
		pickup_sound: "misc/w_pkup.wav",
		world_model: "models/weapons/g_dist/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		view_model: "models/weapons/v_dist/tris.md2",
		icon: "w_disintegrator",
		use_name:  "Disruptor",
		pickup_name:  "$item_disruptor",
		pickup_name_definite: "$item_disruptor_def",
		quantity: 1,
		ammo: item_id_t::AMMO_ROUNDS,
		chain: item_id_t::WEAPON_BFG,
		flags: item_flags_t(item_flags_t::WEAPON | item_flags_t::STAY_COOP),
		vwep_model: "#w_disrupt.md2",
		precaches: "models/proj/disintegrator/tris.md2 weapons/disrupt.wav weapons/disint2.wav weapons/disrupthit.wav"
    ),

	// ROGUE WEAPONS
	// =========================

	//
	// AMMO ITEMS
	//

/*QUAKED ammo_shells (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_SHELLS,
		classname: "ammo_shells",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/shells/medium/tris.md2",
		icon: "a_shells",
		use_name:  "Shells",
		pickup_name:  "$item_shells",
		pickup_name_definite: "$item_shells_def",
		quantity: 10,
		flags: item_flags_t::AMMO,
		tag: ammo_t::SHELLS
    ),

/*QUAKED ammo_bullets (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_BULLETS,
		classname: "ammo_bullets",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/bullets/medium/tris.md2",
		icon: "a_bullets",
		use_name:  "Bullets",
		pickup_name:  "$item_bullets",
		pickup_name_definite: "$item_bullets_def",
		quantity: 50,
		flags: item_flags_t::AMMO,
		tag: ammo_t::BULLETS
    ),

/*QUAKED ammo_cells (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_CELLS,
		classname: "ammo_cells",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/cells/medium/tris.md2",
		icon: "a_cells",
		use_name:  "Cells",
		pickup_name:  "$item_cells",
		pickup_name_definite: "$item_cells_def",
		quantity: 50,
		flags: item_flags_t::AMMO,
		tag: ammo_t::CELLS
    ),

/*QUAKED ammo_rockets (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/ammo/rockets/medium/tris.md2"
*/
	gitem_t(
		id: item_id_t::AMMO_ROCKETS,
		classname: "ammo_rockets",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/rockets/medium/tris.md2",
		icon: "a_rockets",
		use_name:  "Rockets",
		pickup_name:  "$item_rockets",
		pickup_name_definite: "$item_rockets_def",
		quantity: 5,
		flags: item_flags_t::AMMO,
		tag: ammo_t::ROCKETS
    ),

/*QUAKED ammo_slugs (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_SLUGS,
		classname: "ammo_slugs",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/items/ammo/slugs/medium/tris.md2",
		icon: "a_slugs",
		use_name:  "Slugs",
		pickup_name:  "$item_slugs",
		pickup_name_definite: "$item_slugs_def",
		quantity: 10,
		flags: item_flags_t::AMMO,
		tag: ammo_t::SLUGS
    ),

// RAFAEL
/*QUAKED ammo_magslug (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::AMMO_MAGSLUG,
		classname: "ammo_magslug",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/objects/ammo/tris.md2",
		view_model: "",
		icon: "a_mslugs",
		use_name:  "Mag Slug",
		pickup_name:  "$item_mag_slug",
		pickup_name_definite: "$item_mag_slug_def",
		quantity: 10,
		flags: item_flags_t::AMMO,
		tag: ammo_t::MAGSLUG
	),
// RAFAEL

// =======================================
// ROGUE AMMO

/*QUAKED ammo_flechettes (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::AMMO_FLECHETTES,
		classname: "ammo_flechettes",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/ammo/am_flechette/tris.md2",
		icon: "a_flechettes",
		use_name:  "Flechettes",
		pickup_name:  "$item_flechettes",
		pickup_name_definite: "$item_flechettes_def",
		quantity: 50,
		flags: item_flags_t::AMMO,
		tag: ammo_t::FLECHETTES
	),

/*QUAKED ammo_prox (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::AMMO_PROX,
		classname: "ammo_prox",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/ammo/am_prox/tris.md2",
		icon: "a_prox",
		use_name:  "Prox",
		pickup_name:  "$item_prox",
		pickup_name_definite: "$item_prox_def",
		quantity: 5,
		flags: item_flags_t::AMMO,
		tag: ammo_t::PROX,
		precaches: "models/weapons/g_prox/tris.md2 weapons/proxwarn.wav"
    ),

/*QUAKED ammo_nuke (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::AMMO_NUKE,
		classname: "ammo_nuke",
		pickup: Pickup_Nuke,
		use: Use_Nuke,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/weapons/g_nuke/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_nuke",
		use_name: "A-M Bomb",
		pickup_name: "$item_am_bomb",
		pickup_name_definite: "$item_am_bomb_def",
		quantity: 300,
		ammo: item_id_t::AMMO_NUKE,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::AM_BOMB,
		precaches: "weapons/nukewarn2.wav world/rumble.wav"
    ),

/*QUAKED ammo_disruptor (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::AMMO_ROUNDS,
		classname: "ammo_disruptor",
		pickup: Pickup_Ammo,
		drop: Drop_Ammo,
		pickup_sound: "misc/am_pkup.wav",
		world_model: "models/ammo/am_disr/tris.md2",
		icon: "a_disruptor",
		use_name:  "Rounds",
		pickup_name:  "$item_rounds",
		pickup_name_definite: "$item_rounds_def",
		quantity: 3,
		flags: item_flags_t::AMMO,
		tag: ammo_t::DISRUPTOR
    ),
// ROGUE AMMO
// =======================================


	//
	// POWERUP ITEMS
	//
/*QUAKED item_quad (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_QUAD,
		classname: "item_quad", 
		pickup: Pickup_Powerup,
		use: Use_Quad,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/quaddama/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_quad",
		use_name:  "Quad Damage",
		pickup_name:  "$item_quad_damage",
		pickup_name_definite: "$item_quad_damage_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::QUAD,
		precaches: "items/damage.wav items/damage2.wav items/damage3.wav ctf/tech2x.wav"
	),

// RAFAEL
/*QUAKED item_quadfire (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_QUADFIRE,
		classname: "item_quadfire", 
		pickup: Pickup_Powerup,
		use: Use_QuadFire,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/quadfire/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_quadfire",
		use_name:  "DualFire Damage",
		pickup_name:  "$item_dualfire_damage",
		pickup_name_definite: "$item_dualfire_damage_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::QUADFIRE,
		precaches: "items/quadfire1.wav items/quadfire2.wav items/quadfire3.wav"
	),
// RAFAEL

/*QUAKED item_invulnerability (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_INVULNERABILITY,
		classname: "item_invulnerability",
		pickup: Pickup_Powerup,
		use: Use_Invulnerability,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/invulner/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_invulnerability",
		use_name:  "Invulnerability",
		pickup_name:  "$item_invulnerability",
		pickup_name_definite: "$item_invulnerability_def",
		quantity: 300,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::INVULNERABILITY,
		precaches: "items/protect.wav items/protect2.wav items/protect4.wav"
	),

/*QUAKED item_invisibility (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_INVISIBILITY,
		classname: "item_invisibility",
		pickup: Pickup_Powerup,
		use: Use_Invisibility,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/cloaker/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_cloaker",
		use_name:  "Invisibility",
		pickup_name:  "$item_invisibility",
		pickup_name_definite: "$item_invisibility_def",
		quantity: 300,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::INVISIBILITY
	),

/*QUAKED item_silencer (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/silencer/tris.md2"
*/
	gitem_t(
		id: item_id_t::ITEM_SILENCER,
		classname: "item_silencer",
		pickup: Pickup_Powerup,
		use: Use_Silencer,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/silencer/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_silencer",
		use_name:  "Silencer",
		pickup_name:  "$item_silencer",
		pickup_name_definite: "$item_silencer_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::SILENCER
	),

/*QUAKED item_breather (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_REBREATHER,
		classname: "item_breather",
		pickup: Pickup_Powerup,
		use: Use_Breather,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/breather/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_rebreather",
		use_name:  "Rebreather",
		pickup_name:  "$item_rebreather",
		pickup_name_definite: "$item_rebreather_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::STAY_COOP | item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::REBREATHER,
		precaches: "items/airout.wav"
	),

/*QUAKED item_enviro (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_ENVIROSUIT,
		classname: "item_enviro",
		pickup: Pickup_Powerup,
		use: Use_Envirosuit,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/enviro/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_envirosuit",
		use_name:  "Environment Suit",
		pickup_name:  "$item_environment_suit",
		pickup_name_definite: "$item_environment_suit_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::STAY_COOP | item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::ENVIROSUIT,
		precaches: "items/airout.wav"
	),

/*QUAKED item_ancient_head (.3 .3 1) (-16 -16 -16) (16 16 16)
Special item that gives +2 to maximum health
model="models/items/c_head/tris.md2"
*/
	gitem_t(
		id: item_id_t::ITEM_ANCIENT_HEAD,
		classname: "item_ancient_head",
		pickup: Pickup_LegacyHead,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/c_head/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_fixme",
		use_name:  "Ancient Head",
		pickup_name:  "$item_ancient_head",
		pickup_name_definite: "$item_ancient_head_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::HEALTH | item_flags_t::NOT_RANDOM)
	),

	/*QUAKED item_legacy_head (.3 .3 1) (-16 -16 -16) (16 16 16)
	Special item that gives +5 to maximum health
	model="models/items/legacyhead/tris.md2"
	*/
	gitem_t(
		id: item_id_t::ITEM_LEGACY_HEAD,
		classname: "item_legacy_head",
		pickup: Pickup_LegacyHead,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/legacyhead/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_fixme",
		use_name:  "Legacy Head",
		pickup_name:  "$item_legacy_head",
		pickup_name_definite: "$item_legacy_head_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::HEALTH | item_flags_t::NOT_RANDOM)
	),

/*QUAKED item_adrenaline (.3 .3 1) (-16 -16 -16) (16 16 16)
gives +1 to maximum health
*/
	gitem_t(
		id: item_id_t::ITEM_ADRENALINE,
		classname: "item_adrenaline",
		pickup: Pickup_Powerup,
		use: Use_Adrenaline,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/adrenal/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_adrenaline",
		use_name:  "Adrenaline",
		pickup_name:  "$item_adrenaline",
		pickup_name_definite: "$item_adrenaline_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::HEALTH | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::ADRENALINE,
		precaches: "items/n_health.wav"
	),

/*QUAKED item_bandolier (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_BANDOLIER,
		classname: "item_bandolier",
		pickup: Pickup_Bandolier,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/band/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_bandolier",
		use_name:  "Bandolier",
		pickup_name:  "$item_bandolier",
		pickup_name_definite: "$item_bandolier_def",
		quantity: 60,
		flags: item_flags_t::POWERUP
	),

/*QUAKED item_pack (.3 .3 1) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::ITEM_PACK,
		classname: "item_pack",
		pickup: Pickup_Pack,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/pack/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_pack",
		use_name:  "Ammo Pack",
		pickup_name:  "$item_ammo_pack",
		pickup_name_definite: "$item_ammo_pack_def",
		quantity: 180,
		flags: item_flags_t::POWERUP
	),


// ======================================
// PGM

/*QUAKED item_ir_goggles (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
gives +1 to maximum health
*/
	gitem_t(
		id: item_id_t::ITEM_IR_GOGGLES,
		classname: "item_ir_goggles",
		pickup: Pickup_Powerup,
		use: Use_IR,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/goggles/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_ir",
		use_name:  "IR Goggles",
		pickup_name:  "$item_ir_goggles",
		pickup_name_definite: "$item_ir_goggles_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::IR_GOGGLES,
		precaches: "misc/ir_start.wav"
	),

/*QUAKED item_double (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::ITEM_DOUBLE,
		classname: "item_double", 
		pickup: Pickup_Powerup,
		use: Use_Double,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/ddamage/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_double",
		use_name:  "Double Damage",
		pickup_name:  "$item_double_damage",
		pickup_name_definite: "$item_double_damage_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::DOUBLE,
		precaches: "misc/ddamage1.wav misc/ddamage2.wav misc/ddamage3.wav ctf/tech2x.wav"
	),

/*QUAKED item_sphere_vengeance (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::ITEM_SPHERE_VENGEANCE,
		classname: "item_sphere_vengeance", 
		pickup: Pickup_Sphere,
		use: Use_Vengeance,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/vengnce/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_vengeance",
		use_name:  "vengeance sphere",
		pickup_name:  "$item_vengeance_sphere",
		pickup_name_definite: "$item_vengeance_sphere_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::SPHERE_VENGEANCE,
		precaches: "spheres/v_idle.wav"
    ),

/*QUAKED item_sphere_hunter (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::ITEM_SPHERE_HUNTER,
		classname: "item_sphere_hunter", 
		pickup: Pickup_Sphere,
		use: Use_Hunter,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/hunter/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_hunter",
		use_name:  "hunter sphere",
		pickup_name:  "$item_hunter_sphere",
		pickup_name_definite: "$item_hunter_sphere_def",
		quantity: 120,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::SPHERE_HUNTER,
		precaches: "spheres/h_idle.wav spheres/h_active.wav spheres/h_lurk.wav"
    ),

/*QUAKED item_sphere_defender (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::ITEM_SPHERE_DEFENDER,
		classname: "item_sphere_defender", 
		pickup: Pickup_Sphere,
		use: Use_Defender,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/defender/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_defender",
		use_name:  "defender sphere",
		pickup_name:  "$item_defender_sphere",
		pickup_name_definite: "$item_defender_sphere_def",
		quantity: 60,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::SPHERE_DEFENDER,
		precaches: "models/objects/laser/tris.md2 models/items/shell/tris.md2 spheres/d_idle.wav"
    ),

/*QUAKED item_doppleganger (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::ITEM_DOPPELGANGER,
		classname: "item_doppleganger",
		pickup: Pickup_Doppleganger,
		use: Use_Doppleganger,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/dopple/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_doppleganger",
		use_name:  "Doppelganger",
		pickup_name:  "$item_doppleganger",
		pickup_name_definite: "$item_doppleganger_def",
		quantity: 90,
		flags: item_flags_t(item_flags_t::POWERUP | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::DOPPELGANGER,
		precaches: "models/objects/dopplebase/tris.md2 models/items/spawngro3/tris.md2 medic_commander/monsterspawn1.wav models/items/hunter/tris.md2 models/items/vengnce/tris.md2"
    ),

	//
	// KEYS
	//
/*QUAKED key_data_cd (0 .5 .8) (-16 -16 -16) (16 16 16)
key for computer centers
*/
	gitem_t(
		id: item_id_t::KEY_DATA_CD,
		classname: "key_data_cd",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/data_cd/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_datacd",
		use_name:  "Data CD",
		pickup_name:  "$item_data_cd",
		pickup_name_definite: "$item_data_cd_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_power_cube (0 .5 .8) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN NO_TOUCH
warehouse circuits
*/
	gitem_t(
		id: item_id_t::KEY_POWER_CUBE,
		classname: "key_power_cube",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/power/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_powercube",
		use_name:  "Power Cube",
		pickup_name:  "$item_power_cube",
		pickup_name_definite: "$item_power_cube_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_explosive_charges (0 .5 .8) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN NO_TOUCH
warehouse circuits
*/
	gitem_t(
		id: item_id_t::KEY_EXPLOSIVE_CHARGES,
		classname: "key_explosive_charges",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/n64/charge/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "n64/i_charges",
		use_name:  "Explosive Charges",
		pickup_name:  "$item_explosive_charges",
		pickup_name_definite: "$item_explosive_charges_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
	),

/*QUAKED key_yellow_key (0 .5 .8) (-16 -16 -16) (16 16 16)
normal door key - yellow
[Sam-KEX] New key type for Q2 N64
*/
	gitem_t(
		id: item_id_t::KEY_YELLOW,
		classname: "key_yellow_key",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/n64/yellow_key/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "n64/i_yellow_key",
		use_name:  "Yellow Key",
		pickup_name:  "$item_yellow_key",
		pickup_name_definite: "$item_yellow_key_def",
		flags: item_flags_t(item_flags_t::STAY_COOP | item_flags_t::KEY)
    ),

/*QUAKED key_power_core (0 .5 .8) (-16 -16 -16) (16 16 16)
key for N64
*/
	gitem_t(
		id: item_id_t::KEY_POWER_CORE,
		classname: "key_power_core",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/n64/power_core/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_pyramid",
		use_name:  "Power Core",
		pickup_name:  "$item_power_core",
		pickup_name_definite: "$item_power_core_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_pyramid (0 .5 .8) (-16 -16 -16) (16 16 16)
key for the entrance of jail3
*/
	gitem_t(
		id: item_id_t::KEY_PYRAMID,
		classname: "key_pyramid",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/pyramid/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_pyramid",
		use_name:  "Pyramid Key",
		pickup_name:  "$item_pyramid_key",
		pickup_name_definite: "$item_pyramid_key_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
	),

/*QUAKED key_data_spinner (0 .5 .8) (-16 -16 -16) (16 16 16)
key for the city computer
model="models/items/keys/spinner/tris.md2"
*/
	gitem_t(
		id: item_id_t::KEY_DATA_SPINNER,
		classname: "key_data_spinner",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/spinner/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_dataspin",
		use_name:  "Data Spinner",
		pickup_name:  "$item_data_spinner",
		pickup_name_definite: "$item_data_spinner_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
	),

/*QUAKED key_pass (0 .5 .8) (-16 -16 -16) (16 16 16)
security pass for the security level
model="models/items/keys/pass/tris.md2"
*/
	gitem_t(
		id: item_id_t::KEY_PASS,
		classname: "key_pass",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/pass/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_security",
		use_name:  "Security Pass",
		pickup_name:  "$item_security_pass",
		pickup_name_definite: "$item_security_pass_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
	),

/*QUAKED key_blue_key (0 .5 .8) (-16 -16 -16) (16 16 16)
normal door key - blue
*/
	gitem_t(
		id: item_id_t::KEY_BLUE_KEY,
		classname: "key_blue_key",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/key/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_bluekey",
		use_name:  "Blue Key",
		pickup_name:  "$item_blue_key",
		pickup_name_definite: "$item_blue_key_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_red_key (0 .5 .8) (-16 -16 -16) (16 16 16)
normal door key - red
*/
	gitem_t(
		id: item_id_t::KEY_RED_KEY,
		classname: "key_red_key",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/red_key/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_redkey",
		use_name:  "Red Key",
		pickup_name:  "$item_red_key",
		pickup_name_definite: "$item_red_key_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

// RAFAEL
/*QUAKED key_green_key (0 .5 .8) (-16 -16 -16) (16 16 16)
normal door key - blue
*/
	gitem_t(
		id: item_id_t::KEY_GREEN_KEY,
		classname: "key_green_key",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/green_key/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "k_green",
		use_name:  "Green Key",
		pickup_name:  "$item_green_key",
		pickup_name_definite: "$item_green_key_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
	),
// RAFAEL

/*QUAKED key_commander_head (0 .5 .8) (-16 -16 -16) (16 16 16)
tank commander's head
*/
	gitem_t(
		id: item_id_t::KEY_COMMANDER_HEAD,
		classname: "key_commander_head",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/monsters/commandr/head/tris.md2",
		world_model_flags: effects_t::GIB,
		icon: "k_comhead",
		use_name:  "Commander's Head",
		pickup_name:  "$item_commanders_head",
		pickup_name_definite: "$item_commanders_head_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_airstrike_target (0 .5 .8) (-16 -16 -16) (16 16 16)
*/
	gitem_t(
		id: item_id_t::KEY_AIRSTRIKE,
		classname: "key_airstrike_target",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/keys/target/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_airstrike",
		use_name:  "Airstrike Marker",
		pickup_name:  "$item_airstrike_marker",
		pickup_name_definite: "$item_airstrike_marker_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),
	
// ======================================
// PGM

/*QUAKED key_nuke_container (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::KEY_NUKE_CONTAINER,
		classname: "key_nuke_container",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/weapons/g_nuke/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_contain",
		use_name:  "Antimatter Pod",
		pickup_name:  "$item_antimatter_pod",
		pickup_name_definite: "$item_antimatter_pod_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

/*QUAKED key_nuke (.3 .3 1) (-16 -16 -16) (16 16 16) TRIGGER_SPAWN
*/
	gitem_t(
		id: item_id_t::KEY_NUKE,
		classname: "key_nuke",
		pickup: Pickup_Key,
		drop: Drop_General,
		pickup_sound: "items/pkup.wav",
		world_model: "models/weapons/g_nuke/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "i_nuke",
		use_name:  "Antimatter Bomb",
		pickup_name:  "$item_antimatter_bomb",
		pickup_name_definite: "$item_antimatter_bomb_def",
		flags: item_flags_t(item_flags_t::STAY_COOP|item_flags_t::KEY)
    ),

// PGM
//

// PGM
// ======================================

/*QUAKED item_health_small (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/healing/stimpack/tris.md2"
*/
	// Paril: split the healths up so they are always valid classnames
	gitem_t(
		id: item_id_t::HEALTH_SMALL,
		classname: "item_health_small",
		pickup: Pickup_Health,
		pickup_sound: "items/s_health.wav",
		world_model: "models/items/healing/stimpack/tris.md2",
		icon: "i_health",
		use_name:  "Health",
		pickup_name:  "$item_stimpack",
		pickup_name_definite: "$item_stimpack_def",
		quantity: 2,
		flags: item_flags_t::HEALTH,
		tag: int(health_style_t::IGNORE_MAX)
	),

/*QUAKED item_health (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/healing/medium/tris.md2"
*/
	gitem_t(
		id: item_id_t::HEALTH_MEDIUM,
		classname: "item_health",
		pickup: Pickup_Health,
		pickup_sound: "items/n_health.wav",
		world_model: "models/items/healing/medium/tris.md2",
		icon: "i_health",
		use_name:  "Health",
		pickup_name:  "$item_small_medkit",
		pickup_name_definite: "$item_small_medkit_def",
		quantity: 10,
		flags: item_flags_t::HEALTH
	),

/*QUAKED item_health_large (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/healing/large/tris.md2"
*/
	gitem_t(
		id: item_id_t::HEALTH_LARGE,
		classname: "item_health_large",
		pickup: Pickup_Health,
		pickup_sound: "items/l_health.wav",
		world_model: "models/items/healing/large/tris.md2",
		icon: "i_health",
		use_name:  "Health",
		pickup_name:  "$item_large_medkit",
		pickup_name_definite: "$item_large_medkit",
		quantity: 25,
		flags: item_flags_t::HEALTH
	),

/*QUAKED item_health_mega (.3 .3 1) (-16 -16 -16) (16 16 16)
model="models/items/mega_h/tris.md2"
*/
	gitem_t(
		id: item_id_t::HEALTH_MEGA,
		classname: "item_health_mega",
		pickup: Pickup_Health,
		pickup_sound: "items/m_health.wav",
		world_model: "models/items/mega_h/tris.md2",
		icon: "p_megahealth",
		use_name:  "Health",
		pickup_name:  "$item_mega_health",
		pickup_name_definite: "$item_mega_health_def",
		quantity: 100,
		flags: item_flags_t::HEALTH,
		tag: int(health_style_t::IGNORE_MAX | health_style_t::TIMED)
	),

//ZOID
/*QUAKED item_flag_team1 (1 0.2 0) (-16 -16 -24) (16 16 32)
*/
	gitem_t(
		id: item_id_t::FLAG1,
		classname: "item_flag_team1",
		pickup: CTFPickup_Flag,
		drop: CTFDrop_Flag, //Should this be null if we don't want players to drop it manually?
		pickup_sound: "ctf/flagtk.wav",
		world_model: "players/male/flag1.md2",
		world_model_flags: effects_t::FLAG1,
		icon: "i_ctf1",
		use_name: "Red Flag",
		pickup_name: "$item_red_flag",
		pickup_name_definite: "$item_red_flag_def",
		precaches: "ctf/flagcap.wav"
    ),

/*QUAKED item_flag_team2 (1 0.2 0) (-16 -16 -24) (16 16 32)
*/
	gitem_t(
		id: item_id_t::FLAG2,
		classname: "item_flag_team2",
		pickup: CTFPickup_Flag,
		drop: CTFDrop_Flag,
		pickup_sound: "ctf/flagtk.wav",
		world_model: "players/male/flag2.md2",
		world_model_flags: effects_t::FLAG2,
		icon: "i_ctf2",
		use_name: "Blue Flag",
		pickup_name: "$item_blue_flag",
		pickup_name_definite: "$item_blue_flag_def",
		precaches: "ctf/flagcap.wav"
    ),

/* Resistance Tech */
	gitem_t(
		id: item_id_t::TECH_RESISTANCE,
		classname: "item_tech1",
		pickup: CTFPickup_Tech,
		drop: CTFDrop_Tech,
		pickup_sound: "items/pkup.wav",
		world_model: "models/ctf/resistance/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "tech1",
		use_name: "Disruptor Shield",
		pickup_name: "$item_disruptor_shield",
		pickup_name_definite: "$item_disruptor_shield_def",
		flags: item_flags_t(item_flags_t::TECH | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::TECH1,
		precaches: "ctf/tech1.wav"
    ),

/* Strength Tech */
	gitem_t(
		id: item_id_t::TECH_STRENGTH,
		classname: "item_tech2",
		pickup: CTFPickup_Tech,
		drop: CTFDrop_Tech,
		pickup_sound: "items/pkup.wav",
		world_model: "models/ctf/strength/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "tech2",
		use_name: "Power Amplifier",
		pickup_name: "$item_power_amplifier",
		pickup_name_definite: "$item_power_amplifier_def",
		flags: item_flags_t(item_flags_t::TECH | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::TECH2,
		precaches: "ctf/tech2.wav ctf/tech2x.wav"
	),

/* Haste Tech */
	gitem_t(
		id: item_id_t::TECH_HASTE,
		classname: "item_tech3",
		pickup: CTFPickup_Tech,
		drop: CTFDrop_Tech,
		pickup_sound: "items/pkup.wav",
		world_model: "models/ctf/haste/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "tech3",
		use_name: "Time Accel",
		pickup_name: "$item_time_accel",
		pickup_name_definite: "$item_time_accel_def",
		flags: item_flags_t(item_flags_t::TECH | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::TECH3,
		precaches: "ctf/tech3.wav"
    ),

/* Regeneration Tech */
	gitem_t(
		id: item_id_t::TECH_REGENERATION,
		classname: "item_tech4",
		pickup: CTFPickup_Tech,
		drop: CTFDrop_Tech,
		pickup_sound: "items/pkup.wav",
		world_model: "models/ctf/regeneration/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "tech4",
		use_name: "AutoDoc",
		pickup_name: "$item_autodoc",
		pickup_name_definite: "$item_autodoc_def",
		flags: item_flags_t(item_flags_t::TECH | item_flags_t::POWERUP_WHEEL),
		tag: powerup_t::TECH4,
		precaches: "ctf/tech4.wav"
    ),

	gitem_t(
		id: item_id_t::ITEM_FLASHLIGHT,
		classname: "item_flashlight", 
		pickup: Pickup_General,
		use: Use_Flashlight,
		pickup_sound: "items/pkup.wav",
		world_model: "models/items/flashlight/tris.md2",
		world_model_flags: effects_t(effects_t::ROTATE | effects_t::BOB),
		icon: "p_torch",
		use_name:  "Flashlight",
		pickup_name:  "$item_flashlight",
		pickup_name_definite: "$item_flashlight_def",
		flags: item_flags_t(item_flags_t::STAY_COOP | item_flags_t::POWERUP_WHEEL | item_flags_t::POWERUP_ONOFF | item_flags_t::NOT_RANDOM),
		tag: powerup_t::FLASHLIGHT,
		precaches: "items/flashlight_on.wav items/flashlight_off.wav",
		sort_id: -1
    ),

	gitem_t(
		id: item_id_t::ITEM_COMPASS,
		classname: "item_compass", 
		use: Use_Compass,
		world_model_flags: effects_t::NONE,
		icon: "p_compass",
		use_name:  "Compass",
		pickup_name:  "$item_compass",
		pickup_name_definite: "$item_compass_def",
		flags: item_flags_t(item_flags_t::STAY_COOP | item_flags_t::POWERUP_WHEEL | item_flags_t::POWERUP_ONOFF),
		tag: powerup_t::COMPASS,
		precaches: "misc/help_marker.wav",
		sort_id: -2
    )
};

const gitem_t @GetItemByIndex(item_id_t index)
{
    return @itemlist[index];
}

array<gitem_t@> ammolist = array<gitem_t@>(uint(ammo_t::MAX));

const gitem_t @GetItemByAmmo(ammo_t ammo)
{
	return @ammolist[ammo];
}

array<gitem_t@> poweruplist = array<gitem_t@>(uint(powerup_t::MAX));

const gitem_t @GetItemByPowerup(powerup_t powerup)
{
	return @poweruplist[powerup];
}

/*
===============
FindItemByClassname

===============
*/
const gitem_t @FindItemByClassname(const string &in classname)
{
	foreach (const gitem_t @it : itemlist)
	{
		if (it.classname.empty())
			continue;
		if (Q_strcasecmp(it.classname, classname) == 0)
			return it;
	}

	return null;
}

/*
===============
FindItem

===============
*/
const gitem_t @FindItem(const string &in pickup_name)
{
	foreach (const gitem_t @it : itemlist)
	{
		if (it.use_name.empty())
			continue;
		if (Q_strcasecmp(it.use_name, pickup_name) == 0)
			return it;
	}

	return null;
}

// [Paril-KEX] whether instanced items should be used or not
bool P_UseCoopInstancedItems()
{
	// squad respawn forces instanced items on, since we don't
	// want players to need to backtrack just to get their stuff.
	return g_coop_instanced_items.integer != 0 || g_coop_squad_respawn.integer != 0;
}

/*
============
Sets up the item list.
============
*/
void InitItems()
{
	// validate item integrity
	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
		if (itemlist[i].id != i)
			gi_Com_Error("Item {} has wrong enum ID {} (should be {})", itemlist[i].pickup_name, int(itemlist[i].id), int(i));

	// set up weapon chains
	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		if (itemlist[i].chain == item_id_t::NULL)
			continue;

		gitem_t @item = @itemlist[i];

		// already initialized
		if (item.chain_next !is null)
			continue;

		gitem_t @chain_item = @itemlist[uint(item.chain)];

		if (chain_item is null)
			gi_Com_Error("Invalid item chain {} for {}", int(item.chain), item.pickup_name);

		// set up initial chain
		if (chain_item.chain_next is null)
			@chain_item.chain_next = @chain_item;

		// if we're not the first in chain, add us now
		if (!(chain_item is item))
		{
			gitem_t @c;

			// end of chain is one whose chain_next points to chain_item
			for (@c = @chain_item; !(c.chain_next is chain_item); @c = @c.chain_next)
				continue;

			// splice us in
			@item.chain_next = @chain_item;
			@c.chain_next = @item;
		}
	}

	// set up ammo
	foreach (gitem_t @it : itemlist)
	{
		if ((it.flags & item_flags_t::AMMO) != 0 && ammo_t(it.tag) >= ammo_t::BULLETS && ammo_t(it.tag) < ammo_t::MAX)
			@ammolist[uint(it.tag)] = @it;
		else if ((it.flags & item_flags_t::POWERUP_WHEEL) != 0 && (it.flags & item_flags_t::WEAPON) == 0 &&
                 powerup_t(it.tag) >= powerup_t::SCREEN && powerup_t(it.tag) < powerup_t::MAX)
			@poweruplist[uint(it.tag)] = @it;
	}

	// in coop or DM with Weapons' Stay, remove drop ptr
    if (coop.integer != 0)
    {
        foreach (gitem_t @it : itemlist)
            if (!P_UseCoopInstancedItems() && (it.flags & item_flags_t::STAY_COOP) != 0)
                @it.drop = null;
    }
}

// [Paril-KEX]
bool G_CanDropItem(const gitem_t &item)
{
	if (item.drop is null)
		return false;
	else if ((item.flags & item_flags_t::WEAPON) != 0 && (item.flags & item_flags_t::AMMO) == 0 && deathmatch.integer != 0 && g_dm_weapons_stay.integer != 0)
		return false;

	return true;
}

/*
===============
SetItemNames

Called by worldspawn
===============
*/
void SetItemNames()
{
	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
		gi_configstring(configstring_id_t(configstring_id_t::ITEMS + i), itemlist[i].pickup_name);

	// [Paril-KEX] set ammo wheel indices first
	int32 cs_index = 0;

	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		if ((itemlist[i].flags & item_flags_t::AMMO) == 0)
			continue;

		if (cs_index >= MAX_WHEEL_ITEMS)
			gi_Com_Error("out of wheel indices");

		gi_configstring(configstring_id_t(configstring_id_t::WHEEL_AMMO + cs_index), format("{}|{}", int32(i), gi_imageindex(itemlist[i].icon)));
		itemlist[i].ammo_wheel_index = cs_index;
		cs_index++;
	}

	// set weapon wheel indices
	cs_index = 0;

	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		if ((itemlist[i].flags & item_flags_t::WEAPON) == 0)
			continue;

		if (cs_index >= MAX_WHEEL_ITEMS)
			gi_Com_Error("out of wheel indices");

		int32 min_ammo = (itemlist[i].flags & item_flags_t::AMMO) != 0 ? 1 : itemlist[i].quantity;

		gi_configstring(configstring_id_t(configstring_id_t::WHEEL_WEAPONS + cs_index), format("{}|{}|{}|{}|{}|{}|{}|{}",
			int32(i),
			gi_imageindex(itemlist[i].icon),
			itemlist[i].ammo != item_id_t::NULL ? GetItemByIndex(itemlist[i].ammo).ammo_wheel_index : -1,
			min_ammo,
			(itemlist[i].flags & item_flags_t::POWERUP_WHEEL) != 0 ? 1 : 0,
			itemlist[i].sort_id,
			itemlist[i].quantity_warn,
			G_CanDropItem(itemlist[i]) ? 1 : 0
		));
		itemlist[i].weapon_wheel_index = cs_index;
		cs_index++;
	}

	// set powerup wheel indices
	cs_index = 0;

	for (item_id_t i = item_id_t::NULL; i < item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		if ((itemlist[i].flags & item_flags_t::POWERUP_WHEEL) == 0 || (itemlist[i].flags & item_flags_t::WEAPON) != 0)
			continue;

		if (cs_index >= MAX_WHEEL_ITEMS)
			gi_Com_Error("out of wheel indices");

		gi_configstring(configstring_id_t(configstring_id_t::WHEEL_POWERUPS + cs_index), format("{}|{}|{}|{}|{}|{}",
			int32(i),
			gi_imageindex(itemlist[i].icon),
			(itemlist[i].flags & item_flags_t::POWERUP_ONOFF) != 0 ? 1 : 0,
			itemlist[i].sort_id,
			G_CanDropItem(itemlist[i]) ? 1 : 0,
			itemlist[i].ammo != item_id_t::NULL ? GetItemByIndex(itemlist[i].ammo).ammo_wheel_index : -1
		));
		itemlist[i].powerup_wheel_index = cs_index;
		cs_index++;
	}
}
