uint64 cgame_init_time = 0;

void CG_Init()
{
	CG_InitScreen();

	cgame_init_time = cgi_CL_ClientRealTime();

	pm_config.airaccel = parseInt(cgi_get_configstring(configstring_id_t::AIRACCEL));
	pm_config.physics_flags = physics_flags_t(parseInt(cgi_get_configstring(game_configstring_id_t::PHYSICS_FLAGS)));
}

void CG_Shutdown()
{
}

int32 CG_GetActiveWeaponWheelWeapon(const player_state_t &in ps)
{
	return ps.stats[player_stat_t::ACTIVE_WHEEL_WEAPON];
}

uint32 CG_GetOwnedWeaponWheelWeapons(const player_state_t &in ps)
{
	return uint32(uint16(ps.stats[player_stat_t::WEAPONS_OWNED_1]) | uint32(uint16(ps.stats[player_stat_t::WEAPONS_OWNED_2]) << 16));
}

int16 CG_GetWeaponWheelAmmoCount(const player_state_t &in ps, int32 ammo_id)
{
	uint16 ammo = G_GetAmmoStat(ps.stats, ammo_id);

	if (ammo == AMMO_VALUE_INFINITE)
		return -1;

	return ammo;
}

int16 CG_GetPowerupWheelCount(const player_state_t &in ps, int32 powerup_id)
{
	return G_GetPowerupStat(ps.stats, powerup_id);
}

int16 CG_GetHitMarkerDamage(const player_state_t &in ps)
{
	return ps.stats[player_stat_t::HIT_MARKER];
}

void CG_ParseConfigString(int32 i, const string &in s)
{
	if (i == game_configstring_id_t::PHYSICS_FLAGS)
		pm_config.physics_flags = physics_flags_t(parseInt(s));
	else if (i == configstring_id_t::AIRACCEL)
		pm_config.airaccel = parseInt(s);
}

void CG_GetMonsterFlashOffset(monster_muzzle_t id, vec3_t &out offset)
{
	if (id >= int(monster_flash_offset.length()))
		cgi_Com_Error("Bad muzzle flash offset");

	offset = monster_flash_offset[id];
}