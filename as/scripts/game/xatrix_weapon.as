
// RAFAEL
/*
	RipperGun
*/

void weapon_ionripper_fire(ASEntity &ent)
{
	vec3_t tempang;
	int	   damage;

	if (deathmatch.integer != 0)
		// tone down for deathmatch
		damage = 30;
	else
		damage = 50;

	if (is_quad)
		damage *= damage_multiplier;

	tempang = ent.client.v_angle;
	tempang.yaw += crandom();

	vec3_t start, dir;
	P_ProjectSource(ent, tempang, { 16, 7, -8 }, start, dir);

	P_AddWeaponKick(ent, ent.client.v_forward * -3, { -3.f, 0.f, 0.f });

	fire_ionripper(ent, start, dir, damage, 500, effects_t::IONRIPPER);

	// send muzzle flash
	gi_WriteByte(svc_t::muzzleflash);
	gi_WriteEntity(ent.e);
	gi_WriteByte(player_muzzle_t::IONRIPPER | is_silenced);
	gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

	PlayerNoise(ent, start, player_noise_t::WEAPON);

	G_RemoveAmmo(ent);
}

const array<int> ripper_pause_frames = { 36 };
const array<int> ripper_fire_frames = { 6 };

void Weapon_Ionripper(ASEntity &ent)
{
	Weapon_Generic(ent, 5, 7, 36, 39, ripper_pause_frames, ripper_fire_frames, weapon_ionripper_fire);
}

//
//	Phalanx
//

void weapon_phalanx_fire(ASEntity &ent)
{
	vec3_t v;
	int	   damage;
	float  damage_radius;
	int	   radius_damage;

	damage = irandom(70, 80);
	radius_damage = 120;
	damage_radius = 120;

	if (is_quad)
	{
		damage *= damage_multiplier;
		radius_damage *= damage_multiplier;
	}

	vec3_t dir;

	if (ent.e.client.ps.gunframe == 8)
	{
		v.x = ent.client.v_angle.x;
		v.y = ent.client.v_angle.y - 1.5f;
		v.z = ent.client.v_angle.z;

		vec3_t start;
		P_ProjectSource(ent, v, { 0, 8, -8 }, start, dir);

		radius_damage = 30;
		damage_radius = 120;

		fire_plasma(ent, start, dir, damage, 725, damage_radius, radius_damage);

		// send muzzle flash
		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(player_muzzle_t::PHALANX2 | is_silenced);
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);
		
		G_RemoveAmmo(ent);
	}
	else
	{
		v.x = ent.client.v_angle.x;
		v.y = ent.client.v_angle.y + 1.5f;
		v.z = ent.client.v_angle.z;

		vec3_t start;
		P_ProjectSource(ent, v, { 0, 8, -8 }, start, dir);

		fire_plasma(ent, start, dir, damage, 725, damage_radius, radius_damage);

		// send muzzle flash
		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(player_muzzle_t::PHALANX | is_silenced);
		gi_multicast(ent.e.s.origin, multicast_t::PVS, false);

		PlayerNoise(ent, start, player_noise_t::WEAPON);
	}

	P_AddWeaponKick(ent, ent.client.v_forward * -2, { -2.f, 0.f, 0.f });
}

const array<int> phalanx_pause_frames = { 29, 42, 55 };
const array<int> phalanx_fire_frames = { 7, 8 };

void Weapon_Phalanx(ASEntity &ent)
{
	Weapon_Generic(ent, 5, 20, 58, 63, phalanx_pause_frames, phalanx_fire_frames, weapon_phalanx_fire);
}

/*
======================================================================

TRAP

======================================================================
*/

const gtime_t TRAP_TIMER = time_sec(5);
const float TRAP_MINSPEED = 300.0f;
const float TRAP_MAXSPEED = 700.0f;

void weapon_trap_fire(ASEntity &ent, bool held)
{
	int	  speed;

	vec3_t start, dir;
	// Paril: kill sideways angle on grenades
	// limit upwards angle so you don't throw behind you
	P_ProjectSource(ent, { max(-62.5f, ent.client.v_angle.x), ent.client.v_angle.y, ent.client.v_angle.z }, { 8, 0, -8 }, start, dir);

	gtime_t timer = ent.client.grenade_time - level.time;
	speed = int(ent.health <= 0 ? TRAP_MINSPEED : min(TRAP_MINSPEED + (TRAP_TIMER - timer).secondsf() * ((TRAP_MAXSPEED - TRAP_MINSPEED) / TRAP_TIMER.secondsf()), TRAP_MAXSPEED));

	ent.client.grenade_time = time_zero;

	fire_trap(ent, start, dir, speed);

	G_RemoveAmmo(ent, 1);
}

const array<int> trap_pause_frames = { 29, 34, 39, 48 };

void Weapon_Trap(ASEntity &ent)
{
	Throw_Generic(ent, 15, 48, 5, "weapons/trapcock.wav", 11, 12, trap_pause_frames, false, "weapons/traploop.wav", weapon_trap_fire, false);
}