void weapon_prox_fire(ASEntity &ent)
{
	vec3_t start, dir;

	// Paril: kill sideways angle on grenades
	// limit upwards angle so you don't fire behind you
	P_ProjectSource(ent, { max(-62.5f, ent.client.v_angle.x), ent.client.v_angle.y, ent.client.v_angle.z }, { 8, 0, -8 }, start, dir);

	P_AddWeaponKick(ent, ent.client.v_forward * -2, { -1.f, 0.f, 0.f });

	fire_prox(ent, start, dir, damage_multiplier, 600);

	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::PROX | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
	
	G_RemoveAmmo(ent);
}

const array<int> proxlauncher_pause_frames = { 34, 51, 59 };
const array<int> proxlauncher_fire_frames = { 6 };

void Weapon_ProxLauncher(ASEntity &ent)
{
	Weapon_Generic(ent, 5, 16, 59, 64, proxlauncher_pause_frames, proxlauncher_fire_frames, weapon_prox_fire);
}

void weapon_tesla_fire(ASEntity &ent, bool held)
{
	vec3_t start, dir;
	// Paril: kill sideways angle on grenades
	// limit upwards angle so you don't throw behind you
	P_ProjectSource(ent, { max(-62.5f, ent.client.v_angle.x), ent.client.v_angle.y, ent.client.v_angle.z }, { 0, 0, -22 }, start, dir);

	gtime_t timer = ent.client.grenade_time - level.time;
	int	    speed = int(ent.health <= 0 ? GRENADE_MINSPEED : min(GRENADE_MINSPEED + (GRENADE_TIMER - timer).secondsf() * ((GRENADE_MAXSPEED - GRENADE_MINSPEED) / GRENADE_TIMER.secondsf()), GRENADE_MAXSPEED));

	ent.client.grenade_time = time_zero;

	fire_tesla(ent, start, dir, damage_multiplier, speed);

	G_RemoveAmmo(ent, 1);
}

const array<int> tesla_pause_frames = { 21 };

void Weapon_Tesla(ASEntity &ent)
{
	Throw_Generic(ent, 8, 32, -1, "", 1, 2, tesla_pause_frames, false, "", weapon_tesla_fire, false);
}

//======================================================================
// ROGUE MODS BELOW
//======================================================================

//
// CHAINFIST
//
const int CHAINFIST_REACH = 24;

void weapon_chainfist_fire(ASEntity &ent)
{
	if ((ent.client.buttons & button_t::ATTACK) == 0)
	{
		if (ent.e.client.ps.gunframe == 13 ||
			ent.e.client.ps.gunframe == 23 ||
			ent.e.client.ps.gunframe >= 32)
		{
			ent.e.client.ps.gunframe = 33;
			return;
		}
	}

	int damage = 7;

	if (deathmatch.integer != 0)
		damage = 15;

	if (is_quad)
		damage *= damage_multiplier;

	// set start point
	vec3_t start, dir;

	P_ProjectSource(ent, ent.client.v_angle, { 0, 0, -4 }, start, dir);

	if (fire_player_melee(ent, start, dir, CHAINFIST_REACH, damage, 100, mod_id_t::CHAINFIST))
	{
		if (ent.client.empty_click_sound < level.time)
		{
			ent.client.empty_click_sound = level.time + time_ms(500);
			gi_sound(ent.e, soundchan_t::WEAPON, gi_soundindex("weapons/sawslice.wav"), 1.f, ATTN_NORM, 0.f);
		}
	}

	PlayerNoise(ent, start, player_noise_t::WEAPON);

	ent.e.client.ps.gunframe++;
	
	if ((ent.client.buttons & button_t::ATTACK) != 0)
	{
		if (ent.e.client.ps.gunframe == 12)
			ent.e.client.ps.gunframe = 14;
		else if (ent.e.client.ps.gunframe == 22)
			ent.e.client.ps.gunframe = 24;
		else if (ent.e.client.ps.gunframe >= 32)
			ent.e.client.ps.gunframe = 7;
	}

	// start the animation
	if (ent.client.anim_priority != anim_priority_t::ATTACK || frandom() < 0.25f)
	{
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
}

// this spits out some smoke from the motor. it's a two-stroke, you know.
void chainfist_smoke(ASEntity &ent)
{
	vec3_t tempVec, dir;
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(8, 8, -4), tempVec, dir);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::CHAINFIST_SMOKE);
	gi_WritePosition(tempVec);
	gi_unicast(ent.e, false);
}

const array<int> chainfist_pause_frames = { 0 };

void Weapon_ChainFist(ASEntity &ent)
{
	Weapon_Repeating(ent, 4, 32, 57, 60, chainfist_pause_frames, weapon_chainfist_fire);
	
	// smoke on idle sequence
	if (ent.e.client.ps.gunframe == 42 && irandom(8) != 0)
	{
		if ((ent.client.pers.hand != handedness_t::CENTER) && frandom() < 0.4f)
			chainfist_smoke(ent);
	}
	else if (ent.e.client.ps.gunframe == 51 && irandom(8) != 0)
	{
		if ((ent.client.pers.hand != handedness_t::CENTER) && frandom() < 0.4f)
			chainfist_smoke(ent);
	}

	// set the appropriate weapon sound.
	if (ent.client.weaponstate == weaponstate_t::FIRING)
		ent.client.weapon_sound = gi_soundindex("weapons/sawhit.wav");
	else if (ent.client.weaponstate == weaponstate_t::DROPPING)
		ent.client.weapon_sound = 0;
	else if (ent.client.pers.weapon.id == item_id_t::WEAPON_CHAINFIST)
		ent.client.weapon_sound = gi_soundindex("weapons/sawidle.wav");
}

//
// Disintegrator
//

void weapon_tracker_fire(ASEntity &self)
{
	vec3_t	 end;
	ASEntity @enemy;
	trace_t	 tr;
	int		 damage;
	vec3_t	 mins, maxs;

	// PMM - felt a little high at 25
	if (deathmatch.integer != 0)
		damage = 45;
	else
		damage = 135;

	if (is_quad)
		damage *= damage_multiplier; // pgm

	mins = { -16, -16, -16 };
	maxs = { 16, 16, 16 };

	vec3_t start, dir;
	P_ProjectSource(self, self.client.v_angle, { 24, 8, -8 }, start, dir);

	end = start + (dir * 8192);
	@enemy = null;
	// PMM - doing two traces .. one point and one box.
	contents_t mask = contents_t::MASK_PROJECTILE;

	// [Paril-KEX]
	if (!G_ShouldPlayersCollide(true))
		mask = contents_t(mask & ~contents_t::PLAYER);

    // AS_TODO
	//G_LagCompensate(self, start, dir);
	tr = gi_traceline(start, end, self.e, mask);
    // AS_TODO
	//G_UnLagCompensate();
	if (tr.ent is world.e)
		tr = gi_trace(start, mins, maxs, end, self.e, mask);

    if (tr.ent !is world.e)
    {
        ASEntity @hit = entities[tr.ent.s.number];

        if ((tr.ent.svflags & svflags_t::MONSTER) != 0 || tr.ent.client !is null || (hit.flags & ent_flags_t::DAMAGEABLE) != 0)
        {
            if (hit.health > 0)
                @enemy = hit;
        }
    }

	P_AddWeaponKick(self, self.client.v_forward * -2, { -1.f, 0.f, 0.f });

	fire_tracker(self, start, dir, damage, 1000, enemy);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(self.e);
	gi_WriteByte(player_muzzle_t::TRACKER | is_silenced);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(self, start, player_noise_t::WEAPON);

	G_RemoveAmmo(self);
}

const array<int> disruptor_pause_frames = { 14, 19, 23 };
const array<int> disruptor_fire_frames = { 5 };

void Weapon_Disintegrator(ASEntity &ent)
{
	Weapon_Generic(ent, 4, 9, 29, 34, disruptor_pause_frames, disruptor_fire_frames, weapon_tracker_fire);
}

/*
======================================================================

ETF RIFLE

======================================================================
*/
void weapon_etf_rifle_fire(ASEntity &ent)
{
	int	   damage;
	int	   kick = 3;
	int	   i;
	vec3_t offset;

	if (deathmatch.integer != 0)
		damage = 10;
	else
		damage = 10;

	if ((ent.client.buttons & button_t::ATTACK) == 0)
	{
		ent.e.client.ps.gunframe = 8;
		return;
	}

	if (ent.e.client.ps.gunframe == 6)
		ent.e.client.ps.gunframe = 7;
	else
		ent.e.client.ps.gunframe = 6;

	// PGM - adjusted to use the quantity entry in the weapon structure.
	if (ent.client.pers.inventory[ent.client.pers.weapon.ammo] < ent.client.pers.weapon.quantity)
	{
		ent.e.client.ps.gunframe = 8;
		NoAmmoWeaponChange(ent, true);
		return;
	}

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	vec3_t kick_origin = vec3_origin, kick_angles = vec3_origin;
	for (i = 0; i < 3; i++)
	{
		kick_origin[i] = crandom() * 0.85f;
		kick_angles[i] = crandom() * 0.85f;
	}
	P_AddWeaponKick(ent, kick_origin, kick_angles);

	// get start / end positions
	if (ent.e.client.ps.gunframe == 6)
		offset = { 15, 8, -8 };
	else
		offset = { 15, 6, -8 };

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle + kick_angles, offset, start, dir);
	fire_flechette(ent, start, dir, damage, 1150, kick);
	Weapon_PowerupSound(ent);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte((ent.e.client.ps.gunframe == 6 ? player_muzzle_t::ETF_RIFLE : player_muzzle_t::ETF_RIFLE_2) | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);

	G_RemoveAmmo(ent);

	ent.client.anim_priority = anim_priority_t::ATTACK;
	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
	{
		ent.e.s.frame = player::frames::crattak1 - int (frandom() + 0.25f);
		ent.client.anim_end = player::frames::crattak9;
	}
	else
	{
		ent.e.s.frame = player::frames::attack1 - int (frandom() + 0.25f);
		ent.client.anim_end = player::frames::attack8;
	}
	ent.client.anim_time = time_zero;
}

const array<int> etf_rifle_pause_frames = { 18, 28 };

void Weapon_ETF_Rifle(ASEntity &ent)
{
	Weapon_Repeating(ent, 4, 7, 37, 41, etf_rifle_pause_frames, weapon_etf_rifle_fire);
}

const int32 HEATBEAM_DM_DMG = 15;
const int32 HEATBEAM_SP_DMG = 15;

void Heatbeam_Fire(ASEntity &ent)
{
	bool firing = (ent.client.buttons & button_t::ATTACK) != 0;
	bool has_ammo = ent.client.pers.inventory[ent.client.pers.weapon.ammo] >= ent.client.pers.weapon.quantity;

	if (!firing || !has_ammo)
	{
		ent.e.client.ps.gunframe = 13;
		ent.client.weapon_sound = 0;
		ent.e.client.ps.gunskin = 0;

		if (firing && !has_ammo)
			NoAmmoWeaponChange(ent, true);
		return;
	}

	// start on frame 8
	if (ent.e.client.ps.gunframe > 12)
		ent.e.client.ps.gunframe = 8;
	else
		ent.e.client.ps.gunframe++;

	if (ent.e.client.ps.gunframe == 12)
		ent.e.client.ps.gunframe = 8;

	// play weapon sound for firing
	ent.client.weapon_sound = gi_soundindex("weapons/bfg__l1a.wav");
	ent.e.client.ps.gunskin = 1;

	int damage;
	int kick;

	// for comparison, the hyperblaster is 15/20
	// jim requested more damage, so try 15/15 --- PGM 07/23/98
	if (deathmatch.integer != 0)
		damage = HEATBEAM_DM_DMG;
	else
		damage = HEATBEAM_SP_DMG;

	if (deathmatch.integer != 0) // really knock 'em around in deathmatch
		kick = 75;
	else
		kick = 30;

	if (is_quad)
	{
		damage *= damage_multiplier;
		kick *= damage_multiplier;
	}

	ent.client.kick.time = time_zero;

	// This offset is the "view" offset for the beam start (used by trace)
	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, { 7, 2, -3 }, start, dir);

	// This offset is the entity offset
    // AS_TODO
	//G_LagCompensate(ent, start, dir);
	fire_heatbeam(ent, start, dir, { 2, 7, -3 }, damage, kick, false);
    // AS_TODO
	//G_UnLagCompensate();
	Weapon_PowerupSound(ent);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::HEATBEAM | is_silenced);
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

const array<int> heatbeam_pause_frames = { 35 };

void Weapon_Heatbeam(ASEntity &ent)
{
	Weapon_Repeating(ent, 8, 12, 42, 47, heatbeam_pause_frames, Heatbeam_Fire);
}