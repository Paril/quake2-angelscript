enum weaponstate_t
{
	READY,
	ACTIVATING,
	DROPPING,
	FIRING
};

bool G_WeaponShouldStay()
{
	if (deathmatch.integer != 0)
		return g_dm_weapons_stay.integer != 0;
	else if (coop.integer != 0)
		return !P_UseCoopInstancedItems();

	return false;
}

// [Kex]
bool G_CheckInfiniteAmmo(const gitem_t &item)
{
	if ((item.flags & item_flags_t::NO_INFINITE_AMMO) != 0)
		return false;

	return g_infinite_ammo.integer != 0 || (deathmatch.integer != 0 && g_instagib.integer != 0);
}

bool is_quad;
int damage_multiplier;

//========
// ROGUE
int P_DamageModifier(ASEntity &ent)
{
	is_quad = false;
	damage_multiplier = 1;

	if (ent.client.quad_time > level.time)
	{
		damage_multiplier *= 4;
		is_quad = true;

		// if we're quad and DF_NO_STACK_DOUBLE is on, return now.
		if (g_dm_no_stack_double.integer != 0)
			return damage_multiplier;
	}

	if (ent.client.double_time > level.time)
	{
		damage_multiplier *= 2;
		is_quad = true;
	}

	return damage_multiplier;
}
// ROGUE
//========

// [Paril-KEX] kicks in vanilla take place over 2 10hz server
// frames; this is to mimic that visual behavior on any tickrate.
float P_CurrentKickFactor(ASEntity &ent)
{
	if (ent.client.kick.time < level.time)
		return 0.0f;

	float f = (ent.client.kick.time - level.time).secondsf() / ent.client.kick.total.secondsf();
	return f;
}

// [Paril-KEX]
vec3_t P_CurrentKickAngles(ASEntity &ent)
{
	return ent.client.kick.angles * P_CurrentKickFactor(ent);
}

vec3_t P_CurrentKickOrigin(ASEntity &ent)
{
	return ent.client.kick.origin * P_CurrentKickFactor(ent);
}

void P_AddWeaponKick(ASEntity &ent, const vec3_t &in origin, const vec3_t &in angles)
{
	ent.client.kick.origin = origin;
	ent.client.kick.angles = angles;
	ent.client.kick.total = time_ms(200);
	ent.client.kick.time = level.time + ent.client.kick.total;
}

void P_ProjectSource(ASEntity &ent, const vec3_t &in angles, vec3_t distance,
                     vec3_t &out result_start, vec3_t &out result_dir, bool adjust_for_pierce = false)
{
	if (ent.client.pers.hand == handedness_t::LEFT)
		distance.y *= -1;
	else if (ent.client.pers.hand == handedness_t::CENTER)
		distance.y = 0;

	vec3_t forward, right, up;
	vec3_t eye_position = (ent.e.s.origin + vec3_t(0, 0, float(ent.viewheight)));

	AngleVectors(angles, forward, right, up);

	result_start = G_ProjectSource2(eye_position, distance, forward, right, up);

	vec3_t	   end = eye_position + forward * 8192;
	contents_t mask = contents_t(contents_t::MASK_PROJECTILE & ~contents_t::DEADMONSTER);

	// [Paril-KEX]
	if (!G_ShouldPlayersCollide(true))
		mask = contents_t(mask & ~contents_t::PLAYER);

	trace_t tr = gi_traceline(eye_position, end, ent.e, mask);

	// if the point was damageable, use raw forward
	// so railgun pierces properly
	if ((tr.startsolid || adjust_for_pierce) && entities[tr.ent.s.number].takedamage)
	{
		result_dir = forward;
		return;
	}

	end = tr.endpos;
	result_dir = (end - result_start).normalized();

/*
	// correction for blocked shots.
	// disabled because it looks weird.
	trace_t eye_tr = gi.traceline(result_start, result_start + (result_dir * tr.fraction * 8192.f), ent, mask);

	if ((eye_tr.endpos - tr.endpos).length() > 32.f)
	{
		result_start = eye_position;
		result_dir = (end - result_start).normalized();
		return;
	}
*/
}

// noise types for PlayerNoise
enum player_noise_t
{
	SELF,
	WEAPON,
	IMPACT
};

// [Paril-KEX] seconds until we are fully invisible after
// making a racket
const gtime_t INVISIBILITY_TIME = time_sec(2);

/*
===============
PlayerNoise

Each player can have two noise objects associated with it:
a personal noise (jumping, pain, weapon firing), and a weapon
target noise (bullet wall impacts)

Monsters that don't directly see the player can move
to a noise in hopes of seeing the player from there.
===============
*/
void PlayerNoise(ASEntity &who, const vec3_t &in where, player_noise_t type)
{
	ASEntity @noise;

	if (type == player_noise_t::WEAPON)
	{
		if (who.client.silencer_shots != 0)
			who.client.invisibility_fade_time = level.time + (INVISIBILITY_TIME / 5);
		else
			who.client.invisibility_fade_time = level.time + INVISIBILITY_TIME;

		if (who.client.silencer_shots != 0)
		{
			who.client.silencer_shots--;
			return;
		}
	}

	if (deathmatch.integer != 0)
		return;

	if ((who.flags & ent_flags_t::NOTARGET) != 0)
		return;

	if (type == player_noise_t::SELF &&
		(who.client.landmark_free_fall || who.client.landmark_noise_time >= level.time))
		return;

	// ROGUE
	if ((who.flags & ent_flags_t::DISGUISED) != 0)
	{
		if (type == player_noise_t::WEAPON)
		{
			@level.disguise_violator = who;
			level.disguise_violation_time = level.time + time_ms(500);
		}
		else
			return;
	}
	// ROGUE

	if (who.client.mynoise is null)
	{
		@noise = G_Spawn();
		noise.classname = "player_noise";
		noise.e.mins = { -8, -8, -8 };
		noise.e.maxs = { 8, 8, 8 };
		@noise.owner = who;
		noise.e.svflags = svflags_t::NOCLIENT;
		@who.client.mynoise = noise;

		@noise = G_Spawn();
		noise.classname = "player_noise";
		noise.e.mins = { -8, -8, -8 };
		noise.e.maxs = { 8, 8, 8 };
		@noise.owner = who;
		noise.e.svflags = svflags_t::NOCLIENT;
		@who.client.mynoise2 = noise;
	}

	if (type == player_noise_t::SELF || type == player_noise_t::WEAPON)
	{
		@noise = who.client.mynoise;
		@who.client.sound_entity = noise;
		who.client.sound_entity_time = level.time;
	}
	else // type == PNOISE_IMPACT
	{
		@noise = who.client.mynoise2;
		@who.client.sound2_entity = noise;
		who.client.sound2_entity_time = level.time;
	}

	noise.e.s.origin = where;
	noise.e.absmin = where - noise.e.maxs;
	noise.e.absmax = where + noise.e.maxs;
	noise.teleport_time = level.time;
	gi_linkentity(noise.e);
}

bool Pickup_Weapon(ASEntity &ent, ASEntity &other)
{
	item_id_t index;
	const gitem_t	@ammo;

	index = ent.item.id;

	bool is_new = other.client.pers.inventory[index] == 0;

	if (G_WeaponShouldStay() && !is_new)
		if ((ent.spawnflags & (spawnflags::item::DROPPED | spawnflags::item::DROPPED_PLAYER)) == 0)
			return false; // leave the weapon for others to pickup

	other.client.pers.inventory[index]++;

	if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
	{
		// give them some ammo with it
		// PGM -- IF APPROPRIATE!
		if (ent.item.ammo != item_id_t::NULL) // PGM
		{
			@ammo = GetItemByIndex(ent.item.ammo);
			// RAFAEL: Don't get infinite ammo with trap
			if (G_CheckInfiniteAmmo(ammo))
				Add_Ammo(other, ammo, 1000);
			else
			{
				// in PSX, we get double ammo with pickups
				int given_quantity = ammo.quantity;

				if (level.is_psx && deathmatch.integer != 0)
					given_quantity *= 2;

				Add_Ammo(other, ammo, given_quantity);
			}
		}

		if ((ent.spawnflags & spawnflags::item::DROPPED_PLAYER) == 0)
		{
			if (deathmatch.integer != 0)
			{
				if (g_dm_weapons_stay.integer != 0)
					ent.flags = ent_flags_t(ent.flags | ent_flags_t::RESPAWN);

				SetRespawn(ent, time_sec(g_weapon_respawn_time.integer), g_dm_weapons_stay.integer == 0);
			}
			if (coop.integer != 0)
				ent.flags = ent_flags_t(ent.flags | ent_flags_t::RESPAWN);
		}
	}

	G_CheckAutoSwitch(other, ent.item, is_new);

	return true;
}

bool is_quadfire;
int is_silenced;

void Weapon_RunThink(ASEntity &ent)
{
	// call active weapon think routine
	if (ent.client.pers.weapon.weaponthink is null)
		return;

	P_DamageModifier(ent);
	// RAFAEL
	is_quadfire = (ent.client.quadfire_time > level.time);
	// RAFAEL
	if (ent.client.silencer_shots != 0)
		is_silenced = player_muzzle_t::SILENCED;
	else
		is_silenced = player_muzzle_t::NONE;
	ent.client.pers.weapon.weaponthink(ent);
}

array<item_id_t> no_ammo_order = {
    item_id_t::WEAPON_DISRUPTOR,
    item_id_t::WEAPON_RAILGUN,
    item_id_t::WEAPON_PLASMABEAM,
    item_id_t::WEAPON_IONRIPPER,
    item_id_t::WEAPON_HYPERBLASTER,
    item_id_t::WEAPON_ETF_RIFLE,
    /*
    item_id_t::WEAPON_CHAINGUN,
    item_id_t::WEAPON_MACHINEGUN,
    */
    item_id_t::WEAPON_SSHOTGUN,
    item_id_t::WEAPON_SHOTGUN,
    item_id_t::WEAPON_PHALANX,
    item_id_t::WEAPON_RLAUNCHER,
    item_id_t::WEAPON_GLAUNCHER,
    item_id_t::WEAPON_PROXLAUNCHER,
    item_id_t::WEAPON_CHAINFIST,
    item_id_t::WEAPON_BLASTER
};

/*
===============
ChangeWeapon

The old weapon has been dropped all the way, so make the new one
current
===============
*/
void ChangeWeapon(ASEntity &ent)
{
	// [Paril-KEX]
	if (ent.health > 0 && g_instant_weapon_switch.integer == 0 && ((ent.client.latched_buttons | ent.client.buttons) & button_t::HOLSTER) != 0)
		return;

	if (ent.client.grenade_time)
	{
		// force a weapon think to drop the held grenade
		ent.client.weapon_sound = 0;
		Weapon_RunThink(ent);
		ent.client.grenade_time = time_zero;
	}

	if (ent.client.pers.weapon !is null)
	{
		@ent.client.pers.lastweapon = @ent.client.pers.weapon;

		if (ent.client.newweapon !is null && ent.client.newweapon !is ent.client.pers.weapon)
			gi_sound(ent.e, soundchan_t::WEAPON, gi_soundindex("weapons/change.wav"), 1, ATTN_NORM, 0);
	}

	@ent.client.pers.weapon = @ent.client.newweapon;
	@ent.client.newweapon = null;
	ent.client.machinegun_shots = 0;

	// set visible model
	if (ent.e.s.modelindex == MODELINDEX_PLAYER)
		P_AssignClientSkinnum(ent);

	if (ent.client.pers.weapon is null)
	{ // dead
		ent.e.client.ps.gunindex = 0;
		ent.e.client.ps.gunskin = 0;
		return;
	}

	ent.client.weaponstate = weaponstate_t::ACTIVATING;
	ent.e.client.ps.gunframe = 0;
	ent.e.client.ps.gunindex = gi_modelindex(ent.client.pers.weapon.view_model);
	ent.e.client.ps.gunskin = 0;
	ent.client.weapon_sound = 0;

	ent.client.anim_priority = anim_priority_t::PAIN;
	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
	{
		ent.e.s.frame = player::frames::crpain1;
		ent.client.anim_end = player::frames::crpain4;
	}
	else
	{
		ent.e.s.frame = player::frames::pain301;
		ent.client.anim_end = player::frames::pain304;
	}
	ent.client.anim_time = time_zero;

	// for instantweap, run think immediately
	// to set up correct start frame
	if (g_instant_weapon_switch.integer != 0)
		Weapon_RunThink(ent);
}

/*
=================
NoAmmoWeaponChange
=================
*/
void NoAmmoWeaponChange(ASEntity &ent, bool sound)
{
	if (sound)
	{
		if (level.time >= ent.client.empty_click_sound)
		{
			gi_sound(ent.e, soundchan_t::WEAPON, gi_soundindex("weapons/noammo.wav"), 1, ATTN_NORM, 0);
			ent.client.empty_click_sound = level.time + time_sec(1);
		}
	}

	foreach (item_id_t id : no_ammo_order)
	{
		const gitem_t @item = GetItemByIndex(id);

		if (item is null)
			gi_Com_Error("Invalid no ammo weapon switch weapon {}\n", int32(id));

		if (ent.client.pers.inventory[item.id] == 0)
			continue;

		if (item.ammo != item_id_t::NULL && ent.client.pers.inventory[item.ammo] < item.quantity)
			continue;

		@ent.client.newweapon = @item;
		return;
	}
}

void G_RemoveAmmo(ASEntity &ent, int32 quantity)
{
	if (G_CheckInfiniteAmmo(ent.client.pers.weapon))
		return;

	bool pre_warning = ent.client.pers.inventory[ent.client.pers.weapon.ammo] <=
		ent.client.pers.weapon.quantity_warn;

	ent.client.pers.inventory[ent.client.pers.weapon.ammo] -= quantity;

	bool post_warning = ent.client.pers.inventory[ent.client.pers.weapon.ammo] <=
		ent.client.pers.weapon.quantity_warn;

	if (!pre_warning && post_warning)
		gi_local_sound(ent.e, soundchan_t::AUTO, gi_soundindex("weapons/lowammo.wav"), 1, ATTN_NORM, 0);

	if (ent.client.pers.weapon.ammo == item_id_t::AMMO_CELLS)
		G_CheckPowerArmor(ent);
}

void G_RemoveAmmo(ASEntity &ent)
{
	G_RemoveAmmo(ent, ent.client.pers.weapon.quantity);
}

// [Paril-KEX] get time per animation frame
gtime_t Weapon_AnimationTime(ASEntity &ent)
{
	if (g_quick_weapon_switch.integer != 0 && (gi_tick_rate >= 20) &&
		(ent.client.weaponstate == weaponstate_t::ACTIVATING || ent.client.weaponstate == weaponstate_t::DROPPING))
		ent.e.client.ps.gunrate = 20;
	else
		ent.e.client.ps.gunrate = 10;

	if (ent.e.client.ps.gunframe != 0 && ((ent.client.pers.weapon.flags & item_flags_t::NO_HASTE) == 0 || ent.client.weaponstate != weaponstate_t::FIRING))
	{
		if (is_quadfire)
			ent.e.client.ps.gunrate *= 2;
		if (CTFApplyHaste(ent))
			ent.e.client.ps.gunrate *= 2;
	}

	// network optimization...
	if (ent.e.client.ps.gunrate == 10)
	{
		ent.e.client.ps.gunrate = 0;
		return time_ms(100);
	}

	return time_ms(int((1.0f / ent.e.client.ps.gunrate) * 1000));
}

/*
=================
Think_Weapon

Called by ClientBeginServerFrame and ClientThink
=================
*/
void Think_Weapon(ASEntity &ent)
{
	if (ent.client.resp.spectator)
		return;

	// if just died, put the weapon away
	if (ent.health < 1)
	{
		@ent.client.newweapon = null;
		ChangeWeapon(ent);
	}

	if (ent.client.pers.weapon is null)
	{
		if (ent.client.newweapon !is null)
			ChangeWeapon(ent);
		return;
	}

	// call active weapon think routine
	Weapon_RunThink(ent);

	// check remainder from haste; on 100ms/50ms server frames we may have
	// 'run next frame in' times that we can't possibly catch up to,
	// so we have to run them now.
	if (time_ms(33) < FRAME_TIME_MS)
	{
		gtime_t relative_time = Weapon_AnimationTime(ent);

		if (relative_time < FRAME_TIME_MS)
		{
			// check how many we can't run before the next server tick
			gtime_t next_frame = level.time + FRAME_TIME_S;
			int64 remaining_ms = (next_frame - ent.client.weapon_think_time).milliseconds;

			while (remaining_ms > 0)
			{
				ent.client.weapon_think_time -= relative_time;
				ent.client.weapon_fire_finished -= relative_time;
				Weapon_RunThink(ent);
				remaining_ms -= relative_time.milliseconds;
			}
		}
	}
}

enum weap_switch_t
{
	ALREADY_USING,
	NO_WEAPON,
	NO_AMMO,
	NOT_ENOUGH_AMMO,
	VALID
};

weap_switch_t Weapon_AttemptSwitch(ASEntity &ent, const gitem_t &item, bool silent)
{
	if (ent.client.pers.weapon is item)
		return weap_switch_t::ALREADY_USING;
	else if (ent.client.pers.inventory[item.id] == 0)
		return weap_switch_t::NO_WEAPON;

	if (item.ammo != item_id_t::NULL && g_select_empty.integer == 0 && (item.flags & item_flags_t::AMMO) == 0)
	{
		const gitem_t @ammo_item = GetItemByIndex(item.ammo);

		if (ent.client.pers.inventory[item.ammo] == 0)
		{
			if (!silent)
				gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_no_ammo", ammo_item.pickup_name, item.pickup_name_definite);
			return weap_switch_t::NO_AMMO;
		}
		else if (ent.client.pers.inventory[item.ammo] < item.quantity)
		{
			if (!silent)
				gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_not_enough_ammo", ammo_item.pickup_name, item.pickup_name_definite);
			return weap_switch_t::NOT_ENOUGH_AMMO;
		}
	}

	return weap_switch_t::VALID;
}

bool Weapon_IsPartOfChain(const gitem_t &item, const gitem_t @other)
{
	return other !is null && other.chain != item_id_t::NULL && item.chain != item_id_t::NULL && other.chain == item.chain;
}

/*
================
Use_Weapon

Make the weapon ready if there is ammo
================
*/
void Use_Weapon(ASEntity &ent, const gitem_t &item)
{
	const gitem_t		@wanted, root;
	weap_switch_t result = weap_switch_t::NO_WEAPON;

	// if we're switching to a weapon in this chain already,
	// start from the weapon after this one in the chain
	if (!ent.client.no_weapon_chains && Weapon_IsPartOfChain(item, ent.client.newweapon))
	{
		@root = ent.client.newweapon;
		@wanted = root.chain_next;
	}
	// if we're already holding a weapon in this chain,
	// start from the weapon after that one
	else if (!ent.client.no_weapon_chains && Weapon_IsPartOfChain(item, ent.client.pers.weapon))
	{
		@root = ent.client.pers.weapon;
		@wanted = root.chain_next;
	}
	// start from beginning of chain (if any)
	else
		@wanted = @root = item;

	while (true)
	{
		// try the weapon currently in the chain
		if ((result = Weapon_AttemptSwitch(ent, wanted, false)) == weap_switch_t::VALID)
			break;

		// no chains
		if (wanted.chain_next is null || ent.client.no_weapon_chains)
			break;

		@wanted = wanted.chain_next;

		// we wrapped back to the root item
		if (wanted is root)
			break;
	}

	if (result == weap_switch_t::VALID)
		@ent.client.newweapon = wanted; // change to this weapon when down
	else if ((result = Weapon_AttemptSwitch(ent, wanted, true)) == weap_switch_t::NO_WEAPON &&
            !(wanted is ent.client.pers.weapon) && !(wanted is ent.client.newweapon))
	    gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_out_of_item", wanted.pickup_name);
}

/*
================
Drop_Weapon
================
*/
void Drop_Weapon(ASEntity &ent, const gitem_t &item)
{
	// [Paril-KEX]
	if (deathmatch.integer != 0 && g_dm_weapons_stay.integer != 0)
		return;

	item_id_t index = item.id;
	// see if we're already using it
	if (((item is ent.client.pers.weapon) || (item is ent.client.newweapon)) && (ent.client.pers.inventory[index] == 1))
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_cant_drop_weapon");
		return;
	}

	ASEntity  @drop = Drop_Item(ent, item);
	drop.spawnflags |= spawnflags::item::DROPPED_PLAYER;
	drop.e.svflags = svflags_t(drop.e.svflags & ~svflags_t::INSTANCED);
	ent.client.pers.inventory[index]--;
}

void Weapon_PowerupSound(ASEntity &ent)
{
	if (!CTFApplyStrengthSound(ent))
	{
		if (ent.client.quad_time > level.time && ent.client.double_time > level.time)
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("ctf/tech2x.wav"), 1, ATTN_NORM, 0);
		else if (ent.client.quad_time > level.time)
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage3.wav"), 1, ATTN_NORM, 0);
		else if (ent.client.double_time > level.time)
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("misc/ddamage3.wav"), 1, ATTN_NORM, 0);
		else if (ent.client.quadfire_time > level.time
			&& ent.client.ctf_techsndtime < level.time)
		{
			ent.client.ctf_techsndtime = level.time + time_sec(1);
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("ctf/tech3.wav"), 1, ATTN_NORM, 0);
		}
	}

	CTFApplyHasteSound(ent);
}

bool Weapon_CanAnimate(ASEntity &ent)
{
	// VWep animations screw up corpses
	return !ent.deadflag && ent.e.s.modelindex == MODELINDEX_PLAYER;
}

// [Paril-KEX] called when finished to set time until
// we're allowed to switch to fire again
void Weapon_SetFinished(ASEntity &ent)
{
	ent.client.weapon_fire_finished = level.time + Weapon_AnimationTime(ent);
}

bool Weapon_HandleDropping(ASEntity &ent, int FRAME_DEACTIVATE_LAST)
{
	if (ent.client.weaponstate != weaponstate_t::DROPPING)
    	return false;

    if (ent.client.weapon_think_time <= level.time)
    {
        if (ent.e.client.ps.gunframe == FRAME_DEACTIVATE_LAST)
        {
            ChangeWeapon(ent);
            return true;
        }
        else if ((FRAME_DEACTIVATE_LAST - ent.e.client.ps.gunframe) == 4)
        {
            ent.client.anim_priority = anim_priority_t(anim_priority_t::ATTACK | anim_priority_t::REVERSED);
            if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
            {
                ent.e.s.frame = player::frames::crpain4 + 1;
                ent.client.anim_end = player::frames::crpain1;
            }
            else
            {
                ent.e.s.frame = player::frames::pain304 + 1;
                ent.client.anim_end = player::frames::pain301;
            }
            ent.client.anim_time = time_zero;
        }

        ent.e.client.ps.gunframe++;
        ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
    }

    return true;
}

bool Weapon_HandleActivating(ASEntity &ent, int FRAME_ACTIVATE_LAST, int FRAME_IDLE_FIRST)
{
	if (ent.client.weaponstate == weaponstate_t::ACTIVATING)
	{
		if (ent.client.weapon_think_time <= level.time || g_instant_weapon_switch.integer != 0)
		{
			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);

			if (ent.e.client.ps.gunframe == FRAME_ACTIVATE_LAST || g_instant_weapon_switch.integer != 0)
			{
				ent.client.weaponstate = weaponstate_t::READY;
				ent.e.client.ps.gunframe = FRAME_IDLE_FIRST;
				ent.client.weapon_fire_buffered = false;
				if (g_instant_weapon_switch.integer == 0)
					Weapon_SetFinished(ent);
				else
					ent.client.weapon_fire_finished = time_zero;
				return true;
			}

			ent.e.client.ps.gunframe++;
			return true;
		}
	}

	return false;
}

bool Weapon_HandleNewWeapon(ASEntity &ent, int FRAME_DEACTIVATE_FIRST, int FRAME_DEACTIVATE_LAST)
{
	bool is_holstering = false;

	if (g_instant_weapon_switch.integer == 0)
		is_holstering = ((ent.client.latched_buttons | ent.client.buttons) & button_t::HOLSTER) != 0;

	if ((ent.client.newweapon !is null || is_holstering) && (ent.client.weaponstate != weaponstate_t::FIRING))
	{
		if (g_instant_weapon_switch.integer != 0 || ent.client.weapon_think_time <= level.time)
		{
			if (ent.client.newweapon is null)
				@ent.client.newweapon = @ent.client.pers.weapon;

			ent.client.weaponstate = weaponstate_t::DROPPING;

			if (g_instant_weapon_switch.integer != 0)
			{
				ChangeWeapon(ent);
				return true;
			}

			ent.e.client.ps.gunframe = FRAME_DEACTIVATE_FIRST;

			if ((FRAME_DEACTIVATE_LAST - FRAME_DEACTIVATE_FIRST) < 4)
			{
				ent.client.anim_priority = anim_priority_t(anim_priority_t::ATTACK | anim_priority_t::REVERSED);
				if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
				{
					ent.e.s.frame = player::frames::crpain4 + 1;
					ent.client.anim_end = player::frames::crpain1;
				}
				else
				{
					ent.e.s.frame = player::frames::pain304 + 1;
					ent.client.anim_end = player::frames::pain301;
				}
				ent.client.anim_time = time_zero;
			}

			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
		}
		return true;
	}

	return false;
}

enum weapon_ready_state_t
{
	NONE,
	CHANGING,
	FIRING
};

// time after firing that we can't respawn on a player for
const gtime_t COOP_DAMAGE_FIRING_TIME = time_ms(2500);

weapon_ready_state_t Weapon_HandleReady(ASEntity &ent, int FRAME_FIRE_FIRST, int FRAME_IDLE_FIRST, int FRAME_IDLE_LAST, const array<int> &in pause_frames)
{
	if (ent.client.weaponstate == weaponstate_t::READY)
	{
		bool request_firing = ent.client.weapon_fire_buffered || ((ent.client.latched_buttons | ent.client.buttons) & button_t::ATTACK) != 0;

		if (request_firing && ent.client.weapon_fire_finished <= level.time)
		{
			ent.client.latched_buttons = button_t(ent.client.latched_buttons & ~button_t::ATTACK);
			ent.client.weapon_think_time = level.time;

			if ((ent.client.pers.weapon.ammo == item_id_t::NULL) ||
				(ent.client.pers.inventory[ent.client.pers.weapon.ammo] >= ent.client.pers.weapon.quantity))
			{
				ent.client.weaponstate = weaponstate_t::FIRING;
				ent.client.last_firing_time = level.time + COOP_DAMAGE_FIRING_TIME;
				return weapon_ready_state_t::FIRING;
			}
			else
			{
				NoAmmoWeaponChange(ent, true);
				return weapon_ready_state_t::CHANGING;
			}
		}
		else if (ent.client.weapon_think_time <= level.time)
		{
			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);

			if (ent.e.client.ps.gunframe == FRAME_IDLE_LAST)
			{
				ent.e.client.ps.gunframe = FRAME_IDLE_FIRST;
				return weapon_ready_state_t::CHANGING;
			}

			if (pause_frames !is null)
				for (uint n = 0; n < pause_frames.length(); n++)
					if (ent.e.client.ps.gunframe == pause_frames[n])
						if (irandom(16) != 0)
							return weapon_ready_state_t::CHANGING;

			ent.e.client.ps.gunframe++;
			return weapon_ready_state_t::CHANGING;
		}
	}

	return weapon_ready_state_t::NONE;
}

void Weapon_HandleFiring_Pre(ASEntity &ent)
{
	Weapon_SetFinished(ent);

	if (ent.client.weapon_fire_buffered)
	{
		ent.client.buttons = button_t(ent.client.buttons | button_t::ATTACK);
		ent.client.weapon_fire_buffered = false;
	}
}

void Weapon_HandleFiring_Post(ASEntity &ent, int32 FRAME_IDLE_FIRST)
{
	if (ent.e.client.ps.gunframe == FRAME_IDLE_FIRST)
	{
		ent.client.weaponstate = weaponstate_t::READY;
		ent.client.weapon_fire_buffered = false;
	}

	ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
}

funcdef void weapon_fire_func_f(ASEntity &);

void Weapon_Generic(ASEntity &ent, int FRAME_ACTIVATE_LAST, int FRAME_FIRE_LAST, int FRAME_IDLE_LAST, int FRAME_DEACTIVATE_LAST,
                    const array<int> &in pause_frames, const array<int> &in fire_frames, weapon_fire_func_f @fire)
{
	int FRAME_FIRE_FIRST = (FRAME_ACTIVATE_LAST + 1);
	int FRAME_IDLE_FIRST = (FRAME_FIRE_LAST + 1);
	int FRAME_DEACTIVATE_FIRST = (FRAME_IDLE_LAST + 1);

	if (!Weapon_CanAnimate(ent))
		return;

	if (Weapon_HandleDropping(ent, FRAME_DEACTIVATE_LAST))
		return;
	else if (Weapon_HandleActivating(ent, FRAME_ACTIVATE_LAST, FRAME_IDLE_FIRST))
		return;
	else if (Weapon_HandleNewWeapon(ent, FRAME_DEACTIVATE_FIRST, FRAME_DEACTIVATE_LAST))
		return;

    weapon_ready_state_t state = Weapon_HandleReady(ent, FRAME_FIRE_FIRST, FRAME_IDLE_FIRST, FRAME_IDLE_LAST, pause_frames);

	if (state != weapon_ready_state_t::NONE)
	{
		if (state == weapon_ready_state_t::FIRING)
		{
			ent.e.client.ps.gunframe = FRAME_FIRE_FIRST;
			ent.client.weapon_fire_buffered = false;

			if (ent.client.weapon_thunk)
				ent.client.weapon_think_time += FRAME_TIME_S;

			ent.client.weapon_think_time += Weapon_AnimationTime(ent);
			Weapon_SetFinished(ent);

			for (uint n = 0; n < fire_frames.length(); n++)
			{
				if (ent.e.client.ps.gunframe == fire_frames[n])
				{
 					Weapon_PowerupSound(ent);
					fire(ent);
					break;
				}
			}

			// start the animation
			ent.client.anim_priority = anim_priority_t::ATTACK;
			if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
			{
				ent.e.s.frame = player::frames::crattak1 - 1;
				ent.client.anim_end = player::frames::crattak9;
			}
			else
			{
				ent.e.s.frame = player::frames::attack1 - 1;
				ent.client.anim_end = player::frames::attack8;
			}
			ent.client.anim_time = time_zero;
		}

		return;
	}

	if (ent.client.weaponstate == weaponstate_t::FIRING && ent.client.weapon_think_time <= level.time)
	{
		ent.client.last_firing_time = level.time + COOP_DAMAGE_FIRING_TIME;
		ent.e.client.ps.gunframe++;
        Weapon_HandleFiring_Pre(ent);
        for (uint n = 0; n < fire_frames.length(); n++)
        {
            if (ent.e.client.ps.gunframe == fire_frames[n])
            {
                Weapon_PowerupSound(ent);
                fire(ent);
                break;
            }
        }
        Weapon_HandleFiring_Post(ent, FRAME_IDLE_FIRST);
	}
}

void Weapon_Repeating(ASEntity &ent, int FRAME_ACTIVATE_LAST, int FRAME_FIRE_LAST, int FRAME_IDLE_LAST,
                      int FRAME_DEACTIVATE_LAST, const array<int> &in pause_frames, weapon_fire_func_f @fire)
{
	const int FRAME_FIRE_FIRST = (FRAME_ACTIVATE_LAST + 1);
	const int FRAME_IDLE_FIRST = (FRAME_FIRE_LAST + 1);
	const int FRAME_DEACTIVATE_FIRST = (FRAME_IDLE_LAST + 1);

	if (!Weapon_CanAnimate(ent))
		return;

	if (Weapon_HandleDropping(ent, FRAME_DEACTIVATE_LAST))
		return;
	else if (Weapon_HandleActivating(ent, FRAME_ACTIVATE_LAST, FRAME_IDLE_FIRST))
		return;
	else if (Weapon_HandleNewWeapon(ent, FRAME_DEACTIVATE_FIRST, FRAME_DEACTIVATE_LAST))
		return;
	else if (Weapon_HandleReady(ent, FRAME_FIRE_FIRST, FRAME_IDLE_FIRST, FRAME_IDLE_LAST, pause_frames) == weapon_ready_state_t::CHANGING)
		return;

	if (ent.client.weaponstate == weaponstate_t::FIRING && ent.client.weapon_think_time <= level.time)
	{
		ent.client.last_firing_time = level.time + COOP_DAMAGE_FIRING_TIME;
        Weapon_HandleFiring_Pre(ent);
        fire(ent);
        Weapon_HandleFiring_Post(ent, FRAME_IDLE_FIRST);

		if (ent.client.weapon_thunk)
			ent.client.weapon_think_time += FRAME_TIME_S;
	}
}

/*
======================================================================

GRENADE

======================================================================
*/

const gtime_t GRENADE_TIMER = time_sec(3);
const float GRENADE_MINSPEED = 400.0f;
const float GRENADE_MAXSPEED = 800.0f;

void weapon_grenade_fire(ASEntity &ent, bool held)
{
	int	  damage = 125;
	int	  speed;
	float radius;

	radius = float(damage + 40);
	if (is_quad)
		damage *= damage_multiplier;

	vec3_t start, dir;
	// Paril: kill sideways angle on grenades
	// limit upwards angle so you don't throw behind you
	P_ProjectSource(ent, { max(-62.5f, ent.client.v_angle.x), ent.client.v_angle.y, ent.client.v_angle.z }, { 2, 0, -14 }, start, dir);

	gtime_t timer = ent.client.grenade_time - level.time;
	speed = int(ent.health <= 0 ? GRENADE_MINSPEED : min(GRENADE_MINSPEED + (GRENADE_TIMER - timer).secondsf() * ((GRENADE_MAXSPEED - GRENADE_MINSPEED) / GRENADE_TIMER.secondsf()), GRENADE_MAXSPEED));

	ent.client.grenade_time = time_zero;

	fire_grenade2(ent, start, dir, damage, speed, timer, radius, held);

	G_RemoveAmmo(ent, 1);
}

funcdef void throw_fire_f(ASEntity &, bool);

void Throw_Generic(ASEntity &ent, int FRAME_FIRE_LAST, int FRAME_IDLE_LAST, int FRAME_PRIME_SOUND,
					string prime_sound,
					int FRAME_THROW_HOLD, int FRAME_THROW_FIRE, const array<int> &in pause_frames, bool EXPLODE,
					string primed_sound,
					throw_fire_f @fire, bool extra_idle_frame)
{
	// when we die, just toss what we had in our hands.
	if (ent.health <= 0)
	{
		fire(ent, true);
		return;
	}

	uint n;
	int FRAME_IDLE_FIRST = (FRAME_FIRE_LAST + 1);

	if (ent.client.newweapon !is null && (ent.client.weaponstate == weaponstate_t::READY))
	{
		if (ent.client.weapon_think_time <= level.time)
		{
			ChangeWeapon(ent);
			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
		}
		return;
	}

	if (ent.client.weaponstate == weaponstate_t::ACTIVATING)
	{
		if (ent.client.weapon_think_time <= level.time)
		{
			ent.client.weaponstate = weaponstate_t::READY;
			if (!extra_idle_frame)
				ent.e.client.ps.gunframe = FRAME_IDLE_FIRST;
			else
				ent.e.client.ps.gunframe = FRAME_IDLE_LAST + 1;
			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
			Weapon_SetFinished(ent);
		}
		return;
	}

	if (ent.client.weaponstate == weaponstate_t::READY)
	{
		bool request_firing = ent.client.weapon_fire_buffered || ((ent.client.latched_buttons | ent.client.buttons) & button_t::ATTACK) != 0;

		if (request_firing && ent.client.weapon_fire_finished <= level.time)
		{
			ent.client.latched_buttons = button_t(ent.client.latched_buttons & ~button_t::ATTACK);

			if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] != 0)
			{
				ent.e.client.ps.gunframe = 1;
				ent.client.weaponstate = weaponstate_t::FIRING;
				ent.client.grenade_time = time_zero;
				ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
			}
			else
				NoAmmoWeaponChange(ent, true);
			return;
		}
		else if (ent.client.weapon_think_time <= level.time)
		{
			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);

			if (ent.e.client.ps.gunframe >= FRAME_IDLE_LAST)
			{
				ent.e.client.ps.gunframe = FRAME_IDLE_FIRST;
				return;
			}

            for (n = 0; n < pause_frames.length(); n++)
            {
                if (ent.e.client.ps.gunframe == pause_frames[n])
                {
                    if (irandom(16) != 0)
                        return;
                }
            }

			ent.e.client.ps.gunframe++;
		}
		return;
	}

	if (ent.client.weaponstate == weaponstate_t::FIRING)
	{
		ent.client.last_firing_time = level.time + COOP_DAMAGE_FIRING_TIME;

		if (ent.client.weapon_think_time <= level.time)
		{
			if (!prime_sound.empty() && ent.e.client.ps.gunframe == FRAME_PRIME_SOUND)
				gi_sound(ent.e, soundchan_t::WEAPON, gi_soundindex(prime_sound), 1, ATTN_NORM, 0);

			// [Paril-KEX] dualfire/time accel
			gtime_t grenade_wait_time = time_sec(1);

			if (CTFApplyHaste(ent))
				grenade_wait_time *= 0.5f;
			if (is_quadfire)
				grenade_wait_time *= 0.5f;

			if (ent.e.client.ps.gunframe == FRAME_THROW_HOLD)
			{
				if (!ent.client.grenade_time && !ent.client.grenade_finished_time)
					ent.client.grenade_time = level.time + GRENADE_TIMER + time_ms(200);

				if (!primed_sound.empty() && !ent.client.grenade_blew_up)
					ent.client.weapon_sound = gi_soundindex(primed_sound);

				// they waited too long, detonate it in their hand
				if (EXPLODE && !ent.client.grenade_blew_up && level.time >= ent.client.grenade_time)
				{
					Weapon_PowerupSound(ent);
					ent.client.weapon_sound = 0;
					fire(ent, true);
					ent.client.grenade_blew_up = true;

					ent.client.grenade_finished_time = level.time + grenade_wait_time;
				}

				if ((ent.client.buttons & button_t::ATTACK) != 0)
				{
					ent.client.weapon_think_time = level.time + time_ms(1);
					return;
				}

				if (ent.client.grenade_blew_up)
				{
					if (level.time >= ent.client.grenade_finished_time)
					{
						ent.e.client.ps.gunframe = FRAME_FIRE_LAST;
						ent.client.grenade_blew_up = false;
						ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);
					}
					else
					{
						return;
					}
				}
				else
				{
					ent.e.client.ps.gunframe++;

					Weapon_PowerupSound(ent);
					ent.client.weapon_sound = 0;
					fire(ent, false);

					if (!EXPLODE || !ent.client.grenade_blew_up)
						ent.client.grenade_finished_time = level.time + grenade_wait_time;

					if (!ent.deadflag && ent.e.s.modelindex == MODELINDEX_PLAYER && ent.health > 0) // VWep animations screw up corpses
					{
						if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
						{
							ent.client.anim_priority = anim_priority_t::ATTACK;
							ent.e.s.frame = player::frames::crattak1 - 1;
							ent.client.anim_end = player::frames::crattak3;
						}
						else
						{
							ent.client.anim_priority = anim_priority_t(anim_priority_t::ATTACK | anim_priority_t::REVERSED);
							ent.e.s.frame = player::frames::wave08;
							ent.client.anim_end = player::frames::wave01;
						}
						ent.client.anim_time = time_zero;
					}
				}
			}

			ent.client.weapon_think_time = level.time + Weapon_AnimationTime(ent);

			if ((ent.e.client.ps.gunframe == FRAME_FIRE_LAST) && (level.time < ent.client.grenade_finished_time))
				return;

			ent.e.client.ps.gunframe++;

			if (ent.e.client.ps.gunframe == FRAME_IDLE_FIRST)
			{
				ent.client.grenade_finished_time = time_zero;
				ent.client.weaponstate = weaponstate_t::READY;
				ent.client.weapon_fire_buffered = false;
				Weapon_SetFinished(ent);
				
				if (extra_idle_frame)
					ent.e.client.ps.gunframe = FRAME_IDLE_LAST + 1;

				// Paril: if we ran out of the throwable, switch
				// so we don't appear to be holding one that we
				// can't throw
				if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] == 0)
				{
					NoAmmoWeaponChange(ent, false);
					ChangeWeapon(ent);
				}
			}
		}
	}
}

const array<int> grenade_pause_frames = { 29, 34, 39, 48 };

void Weapon_Grenade(ASEntity &ent)
{
	Throw_Generic(ent, 15, 48, 5, "weapons/hgrena1b.wav", 11, 12, grenade_pause_frames, true, "weapons/hgrenc1b.wav", weapon_grenade_fire, true);

	// [Paril-KEX] skip the duped frame
	if (ent.e.client.ps.gunframe == 1)
		ent.e.client.ps.gunframe = 2;
}

/*
======================================================================

GRENADE LAUNCHER

======================================================================
*/

void weapon_grenadelauncher_fire(ASEntity &ent)
{
	int	  damage = 120;
	float radius;

	radius = float(damage + 40);
	if (is_quad)
		damage *= damage_multiplier;

	vec3_t start, dir;
	// Paril: kill sideways angle on grenades
	// limit upwards angle so you don't fire it behind you
	P_ProjectSource(ent, { max(-62.5f, ent.client.v_angle[0]), ent.client.v_angle[1], ent.client.v_angle[2] }, { 8, 0, -8 }, start, dir);

	P_AddWeaponKick(ent, ent.client.v_forward * -2, { -1.f, 0.f, 0.f });

	fire_grenade(ent, start, dir, damage, 600, time_sec(2.5), radius, (crandom() * 10.0f), (200 + crandom() * 10.0f), false);

	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::GRENADE | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> glauncher_pause_frames = { 34, 51, 59 };
const array<int> glauncher_fire_frames = { 6 };

void Weapon_GrenadeLauncher(ASEntity &ent)
{
	Weapon_Generic(ent, 5, 16, 59, 64, glauncher_pause_frames, glauncher_fire_frames, weapon_grenadelauncher_fire);
}

/*
======================================================================

ROCKET

======================================================================
*/

void Weapon_RocketLauncher_Fire(ASEntity &ent)
{
	int	  damage;
	float damage_radius;
	int	  radius_damage;

	damage = irandom(100, 120);
	radius_damage = 120;
	damage_radius = 120;
	if (is_quad)
	{
		damage *= damage_multiplier;
		radius_damage *= damage_multiplier;
	}

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, { 8, 8, -8 }, start, dir);
	fire_rocket(ent, start, dir, damage, 650, damage_radius, radius_damage);

	P_AddWeaponKick(ent, ent.client.v_forward * -2, { -1.f, 0.f, 0.f });

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::ROCKET | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> rlauncher_pause_frames = { 25, 33, 42, 50 };
const array<int> rlauncher_fire_frames = { 5 };

void Weapon_RocketLauncher(ASEntity &ent)
{
	Weapon_Generic(ent, 4, 12, 50, 54, rlauncher_pause_frames, rlauncher_fire_frames, Weapon_RocketLauncher_Fire);
}

/*
======================================================================

BLASTER / HYPERBLASTER

======================================================================
*/

void Blaster_Fire(ASEntity &ent, const vec3_t &in g_offset, int damage, bool hyper, effects_t effect)
{
	if (is_quad)
		damage *= damage_multiplier;

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(24, 8, -8) + g_offset, start, dir);

	if (hyper)
		P_AddWeaponKick(ent, ent.client.v_forward * -2, { crandom() * 0.7f, crandom() * 0.7f, crandom() * 0.7f });
	else
		P_AddWeaponKick(ent, ent.client.v_forward * -2, { -1.0f, 0.0f, 0.0f });

	// let the regular blaster projectiles travel a bit faster because it is a completely useless gun
	int speed = hyper ? 1000 : 1500;

	fire_blaster(ent, start, dir, damage, speed, effect, hyper ? mod_id_t::HYPERBLASTER : mod_id_t::BLASTER);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	if (hyper)
		gi_WriteByte(int(player_muzzle_t::HYPERBLASTER) | is_silenced);
	else
		gi_WriteByte(int(player_muzzle_t::BLASTER) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
}

void Weapon_Blaster_Fire(ASEntity &ent)
{
	// give the blaster 15 across the board instead of just in dm
	int damage = 15;
	Blaster_Fire(ent, vec3_origin, damage, false, effects_t::BLASTER);
}

const array<int> blaster_pause_frames = { 19, 32 };
const array<int> blaster_fire_frames = { 5 };

void Weapon_Blaster(ASEntity &ent)
{
	Weapon_Generic(ent, 4, 8, 52, 55, blaster_pause_frames, blaster_fire_frames, Weapon_Blaster_Fire);
}



void Weapon_HyperBlaster_Fire(ASEntity &ent)
{
	float	  rotation;
	vec3_t	  offset;
	int		  damage;

	// start on frame 6
	if (ent.e.client.ps.gunframe > 20)
		ent.e.client.ps.gunframe = 6;
	else
		ent.e.client.ps.gunframe++;

	// if we reached end of loop, have ammo & holding attack, reset loop
	// otherwise play wind down
	if (ent.e.client.ps.gunframe == 12)
	{
		if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] != 0 && (ent.client.buttons & button_t::ATTACK) != 0)
			ent.e.client.ps.gunframe = 6;
		else
			gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("weapons/hyprbd1a.wav"), 1, ATTN_NORM, 0);
	}

	// play weapon sound for firing loop
	if (ent.e.client.ps.gunframe >= 6 && ent.e.client.ps.gunframe <= 11)
		ent.client.weapon_sound = gi_soundindex("weapons/hyprbl1a.wav");
	else
		ent.client.weapon_sound = 0;

	// fire frames
	bool request_firing = ent.client.weapon_fire_buffered || (ent.client.buttons & button_t::ATTACK) != 0;

	if (request_firing)
	{
		if (ent.e.client.ps.gunframe >= 6 && ent.e.client.ps.gunframe <= 11)
		{
			ent.client.weapon_fire_buffered = false;

			if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] == 0)
			{
				NoAmmoWeaponChange(ent, true);
				return;
			}

			rotation = (ent.e.client.ps.gunframe - 5) * 2 * PIf / 6;
			offset[0] = -4 * sin(rotation);
			offset[2] = 0;
			offset[1] = 4 * cos(rotation);

			if (deathmatch.integer != 0)
				damage = 15;
			else
				damage = 20;
			Blaster_Fire(ent, offset, damage, true, ((ent.e.client.ps.gunframe - 6) % 4) == 0 ? effects_t::HYPERBLASTER : effects_t::NONE);
			Weapon_PowerupSound(ent);

			G_RemoveAmmo(ent);

			ent.client.anim_priority = anim_priority_t::ATTACK;
			if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
			{
				ent.e.s.frame = player::frames::crattak1 - int(frandom() + 0.25f);
				ent.client.anim_end = player::frames::crattak9;
			}
			else
			{
				ent.e.s.frame = player::frames::attack1 - int(frandom() + 0.25f);
				ent.client.anim_end = player::frames::attack8;
			}
			ent.client.anim_time = time_zero;
		}
	}
}

const array<int> hyperblaster_pause_frames;

void Weapon_HyperBlaster(ASEntity &ent)
{
	Weapon_Repeating(ent, 5, 20, 49, 53, hyperblaster_pause_frames, Weapon_HyperBlaster_Fire);
}

/*
======================================================================

MACHINEGUN / CHAINGUN

======================================================================
*/

const int32 DEFAULT_BULLET_HSPREAD = 300;
const int32 DEFAULT_BULLET_VSPREAD = 500;

void Machinegun_Fire(ASEntity &ent)
{
	int i;
	int damage = 8;
	int kick = 2;

	if ((ent.client.buttons & button_t::ATTACK) == 0)
	{
		ent.client.machinegun_shots = 0;
		ent.e.client.ps.gunframe = 6;
		return;
	}

	if (ent.e.client.ps.gunframe == 4)
		ent.e.client.ps.gunframe = 5;
	else
		ent.e.client.ps.gunframe = 4;

	if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] < 1)
	{
		ent.e.client.ps.gunframe = 6;
		NoAmmoWeaponChange(ent, true);
		return;
	}

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	vec3_t kick_origin, kick_angles;
	for (i = 0; i < 3; i++)
	{
		kick_origin[i] = crandom() * 0.35f;
		kick_angles[i] = crandom() * 0.7f;
	}
	//kick_angles[0] = ent->client->machinegun_shots * -1.5f;
	P_AddWeaponKick(ent, kick_origin, kick_angles);

	// raise the gun as it is firing
	// [Paril-KEX] disabled as this is a bit hard to do with high
	// tickrate, but it also just sucks in general.
	/*if (!deathmatch->integer)
	{
		ent->client->machinegun_shots++;
		if (ent->client->machinegun_shots > 9)
			ent->client->machinegun_shots = 9;
	}*/

	// get start / end positions
	vec3_t start, dir;
	// Paril: kill sideways angle on hitscan
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(0, 0, -8), start, dir, true);
	G_LagCompensate(ent, start, dir);
	fire_bullet(ent, start, dir, damage, kick, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, mod_id_t::MACHINEGUN);
	G_UnLagCompensate();
	Weapon_PowerupSound(ent);

	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(int(player_muzzle_t::MACHINEGUN) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);

	ent.client.anim_priority = anim_priority_t::ATTACK;
	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
	{
		ent.e.s.frame = player::frames::crattak1 - int(frandom() + 0.25f);
		ent.client.anim_end = player::frames::crattak9;
	}
	else
	{
		ent.e.s.frame = player::frames::attack1 - int(frandom() + 0.25f);
		ent.client.anim_end = player::frames::attack8;
	}
	ent.client.anim_time = time_zero;
}

const array<int> machinegun_pause_frames = { 23, 45 };

void Weapon_Machinegun(ASEntity &ent)
{
	Weapon_Repeating(ent, 3, 5, 45, 49, machinegun_pause_frames, Machinegun_Fire);
}

void Chaingun_Fire(ASEntity &ent)
{
	int	  i;
	int	  shots;
	float r, u;
	int	  damage;
	int	  kick = 2;

	if (deathmatch.integer != 0)
		damage = 6;
	else
		damage = 8;

	if (ent.e.client.ps.gunframe > 31)
	{
		ent.e.client.ps.gunframe = 5;
		gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("weapons/chngnu1a.wav"), 1, ATTN_IDLE, 0);
	}
	else if ((ent.e.client.ps.gunframe == 14) && (ent.client.buttons & button_t::ATTACK) == 0)
	{
		ent.e.client.ps.gunframe = 32;
		ent.client.weapon_sound = 0;
		return;
	}
	else if ((ent.e.client.ps.gunframe == 21) && (ent.client.buttons & button_t::ATTACK) != 0 && ent.client.pers.inventory[ent.client.pers.weapon.ammo] != 0)
	{
		ent.e.client.ps.gunframe = 15;
	}
	else
	{
		ent.e.client.ps.gunframe++;
	}

	if (ent.e.client.ps.gunframe == 22)
	{
		ent.client.weapon_sound = 0;
		gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("weapons/chngnd1a.wav"), 1, ATTN_IDLE, 0);
	}

	if (ent.e.client.ps.gunframe < 5 || ent.e.client.ps.gunframe > 21)
		return;

	ent.client.weapon_sound = gi_soundindex("weapons/chngnl1a.wav");

	ent.client.anim_priority = anim_priority_t::ATTACK;
	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
	{
		ent.e.s.frame = player::frames::crattak1 - (ent.e.client.ps.gunframe & 1);
		ent.client.anim_end = player::frames::crattak9;
	}
	else
	{
		ent.e.s.frame = player::frames::attack1 - (ent.e.client.ps.gunframe & 1);
		ent.client.anim_end = player::frames::attack8;
	}
	ent.client.anim_time = time_zero;

	if (ent.e.client.ps.gunframe <= 9)
		shots = 1;
	else if (ent.e.client.ps.gunframe <= 14)
	{
		if ((ent.client.buttons & button_t::ATTACK) != 0)
			shots = 2;
		else
			shots = 1;
	}
	else
		shots = 3;

	if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] < shots)
		shots = ent.client.pers.inventory[ent.client.pers.weapon.ammo];

	if (shots == 0)
	{
		NoAmmoWeaponChange(ent, true);
		return;
	}

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	vec3_t kick_origin, kick_angles;
	for (i = 0; i < 3; i++)
	{
		kick_origin[i] = crandom() * 0.35f;
		kick_angles[i] = crandom() * (0.5f + (shots * 0.15f));
	}
	P_AddWeaponKick(ent, kick_origin, kick_angles);

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(0, 0, -8), start, dir, true);

	G_LagCompensate(ent, start, dir);
	for (i = 0; i < shots; i++)
	{
		// get start / end positions
		// Paril: kill sideways angle on hitscan
		r = crandom() * 4;
		u = crandom() * 4;
		P_ProjectSource(ent, ent.client.v_angle, vec3_t(0, r, u + -8), start, dir, true);

		fire_bullet(ent, start, dir, damage, kick, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, mod_id_t::CHAINGUN);
	}
	G_UnLagCompensate();

	Weapon_PowerupSound(ent);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(int(player_muzzle_t::CHAINGUN1 + shots - 1) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent, shots);
}

const array<int> chaingun_pause_frames = { 38, 43, 51, 61 };

void Weapon_Chaingun(ASEntity &ent)
{
	Weapon_Repeating(ent, 4, 31, 61, 64, chaingun_pause_frames, Chaingun_Fire);
}


/*
======================================================================

SHOTGUN / SUPERSHOTGUN

======================================================================
*/

const int32 DEFAULT_SHOTGUN_HSPREAD = 1000;
const int32 DEFAULT_SHOTGUN_VSPREAD = 500;
const int32 DEFAULT_DEATHMATCH_SHOTGUN_COUNT = 12;
const int32 DEFAULT_SHOTGUN_COUNT = 12;
const int32 DEFAULT_SSHOTGUN_COUNT = 20;

void weapon_shotgun_fire(ASEntity &ent)
{
	int damage = 4;
	int kick = 8;

	vec3_t start, dir;
	// Paril: kill sideways angle on hitscan
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(0, 0, -8), start, dir, true);

	P_AddWeaponKick(ent, ent.client.v_forward * -2, vec3_t(-2.0f, 0.0f, 0.0f));

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	G_LagCompensate(ent, start, dir);
	if (deathmatch.integer != 0)
		fire_shotgun(ent, start, dir, damage, kick, 500, 500, DEFAULT_DEATHMATCH_SHOTGUN_COUNT, mod_id_t::SHOTGUN);
	else
		fire_shotgun(ent, start, dir, damage, kick, 500, 500, DEFAULT_SHOTGUN_COUNT, mod_id_t::SHOTGUN);
	G_UnLagCompensate();

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(int(player_muzzle_t::SHOTGUN) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> shotgun_pause_frames = { 22, 28, 34 };
const array<int> shotgun_fire_frames = { 8 };

void Weapon_Shotgun(ASEntity &ent)
{
	Weapon_Generic(ent, 7, 18, 36, 39, shotgun_pause_frames, shotgun_fire_frames, weapon_shotgun_fire);
}

void weapon_supershotgun_fire(ASEntity &ent)
{
	int damage = 6;
	int kick = 12;

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}
	
	vec3_t start, dir;
	// Paril: kill sideways angle on hitscan
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(0, 0, -8), start, dir);
	G_LagCompensate(ent, start, dir);
	vec3_t v;
	v.pitch = ent.client.v_angle.pitch;
	v.yaw = ent.client.v_angle.yaw - 5;
	v.roll = ent.client.v_angle.roll;
	// Paril: kill sideways angle on hitscan
	P_ProjectSource(ent, v, { 0, 0, -8 }, start, dir, true);
	fire_shotgun(ent, start, dir, damage, kick, DEFAULT_SHOTGUN_HSPREAD, DEFAULT_SHOTGUN_VSPREAD, DEFAULT_SSHOTGUN_COUNT / 2, mod_id_t::SSHOTGUN);
	v.yaw = ent.client.v_angle.yaw + 5;
	P_ProjectSource(ent, v, { 0, 0, -8 }, start, dir, true);
	fire_shotgun(ent, start, dir, damage, kick, DEFAULT_SHOTGUN_HSPREAD, DEFAULT_SHOTGUN_VSPREAD, DEFAULT_SSHOTGUN_COUNT / 2, mod_id_t::SSHOTGUN);
	G_UnLagCompensate();

	P_AddWeaponKick(ent, ent.client.v_forward * -2, vec3_t(-2.0f, 0.0f, 0.0f));

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(int(player_muzzle_t::SSHOTGUN) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> super_shotgun_pause_frames = { 29, 42, 57 };
const array<int> super_shotgun_fire_frames = { 7 };

void Weapon_SuperShotgun(ASEntity &ent)
{
	Weapon_Generic(ent, 6, 17, 57, 61, super_shotgun_pause_frames, super_shotgun_fire_frames, weapon_supershotgun_fire);
}

/*
======================================================================

RAILGUN

======================================================================
*/

void weapon_railgun_fire(ASEntity &ent)
{
	int damage, kick;
	
	// normal damage too extreme for DM
	if (deathmatch.integer != 0)
	{
		damage = 100;
		kick = 200;
	}
	else
	{
		damage = 125;
		kick = 225;
	}

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, { 0, 7, -8 }, start, dir, true);
	G_LagCompensate(ent, start, dir);
	fire_rail(ent, start, dir, damage, kick);
	G_UnLagCompensate();

	P_AddWeaponKick(ent, ent.client.v_forward * -3, { -3.f, 0.f, 0.f });

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::RAILGUN | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> railgun_pause_frames = { 56 };
const array<int> railgun_fire_frames = { 4 };

void Weapon_Railgun(ASEntity &ent)
{
	Weapon_Generic(ent, 3, 18, 56, 61, railgun_pause_frames, railgun_fire_frames, weapon_railgun_fire);
}

/*
======================================================================

BFG10K

======================================================================
*/

void weapon_bfg_fire(ASEntity &ent)
{
	int	  damage;
	float damage_radius = 1000;

	if (deathmatch.integer != 0)
		damage = 200;
	else
		damage = 500;

	if (ent.e.client.ps.gunframe == 9)
	{
		// send muzzle flash
		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(player_muzzle_t::BFG | is_silenced);
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

		PlayerNoise(ent, ent.e.s.origin, player_noise_t::WEAPON);
		return;
	}

	// cells can go down during windup (from power armor hits), so
	// check again and abort firing if we don't have enough now
	if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] < 50)
		return;

	if (is_quad)
		damage *= damage_multiplier;

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(8, 8, -8), start, dir);
	fire_bfg(ent, start, dir, damage, 400, damage_radius);

	P_AddWeaponKick(ent, ent.client.v_forward * -2, vec3_t(-20.f, 0, crandom() * 8));
	ent.client.kick.total = DAMAGE_TIME;
	ent.client.kick.time = level.time + ent.client.kick.total;

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::BFG2 | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> bfg_pause_frames = { 39, 45, 50, 55 };
const array<int> bfg_fire_frames = { 9, 17 };

void Weapon_BFG(ASEntity &ent)
{
	Weapon_Generic(ent, 8, 32, 54, 58, bfg_pause_frames, bfg_fire_frames, weapon_bfg_fire);
}

// Lag compensation code
// [Paril-KEX] push all players' origins back to match their lag compensation
void G_LagCompensate(ASEntity &from_player, const vec3_t &in start, const vec3_t &in dir)
{
	uint32 current_frame = gi_ServerFrame();

	// if you need this to fight monsters, you need help
	if (deathmatch.integer == 0)
		return;
	else if (g_lag_compensation.integer == 0)
		return;
	// don't need this
	else if (from_player.client.cmd.server_frame >= current_frame ||
		(from_player.e.svflags & svflags_t::BOT) != 0)
		return;

	int32 frame_delta = (current_frame - from_player.client.cmd.server_frame) + 1;

	foreach (auto @player : active_players)
	{
		// we aren't gonna hit ourselves
		if (player is from_player)
			continue;

		// not enough data, spare them
		if (player.client.num_lag_origins < frame_delta)
			continue;

		// if they're way outside of cone of vision, they won't be captured in this
		if ((player.e.origin - start).normalized().dot(dir) < 0.75f)
			continue;

		int32 lag_id = (player.client.next_lag_origin - 1) - (frame_delta - 1);

		if (lag_id < 0)
			lag_id = game.max_lag_origins + lag_id;

		if (lag_id < 0 || lag_id >= player.client.num_lag_origins)
		{
			gi_Com_Print("lag compensation error\n");
			G_UnLagCompensate();
			return;
		}

		vec3_t lag_origin = game.lag_origins[((player.e.number - 1) * game.max_lag_origins) + lag_id];

		// no way they'd be hit if they aren't in the PVS
		if (!gi_inPVS(lag_origin, start, false))
			continue;

		// only back up once
		if (!player.client.is_lag_compensated)
		{
			player.client.is_lag_compensated = true;
			player.client.lag_restore_origin = player.e.origin;
		}
			
		player.e.origin = lag_origin;

		gi_linkentity(player.e);
	}
}

// [Paril-KEX] pop everybody's lag compensation values
void G_UnLagCompensate()
{
	foreach (auto @player : active_players)
	{
		if (player.client.is_lag_compensated)
		{
			player.client.is_lag_compensated = false;
			player.e.origin = player.client.lag_restore_origin;
			gi_linkentity(player.e);
		}
	}
}

// [Paril-KEX] save the current lag compensation value
void G_SaveLagCompensation(ASEntity &ent)
{
	game.lag_origins[((ent.e.number - 1) * game.max_lag_origins) + ent.client.next_lag_origin] = ent.e.origin;
	ent.client.next_lag_origin = (ent.client.next_lag_origin + 1) % game.max_lag_origins;

	if (ent.client.num_lag_origins < game.max_lag_origins)
		ent.client.num_lag_origins++;
}
