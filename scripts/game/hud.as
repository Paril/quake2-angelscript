void set_compressed_integer(uint bits_per_value, gclient_t &cl, uint8 id, uint16 count, uint byte_offset)
{
	uint16 bit_offset = bits_per_value * id;
	uint16 byte = bit_offset / 8;
	uint16 bit_shift = bit_offset % 8;
	uint16 mask = ((1 << bits_per_value) - 1) << bit_shift;
    cl.ps.stats.set_stat_uint16(byte_offset + byte, (cl.ps.stats.get_stat_uint16(byte_offset + byte) & ~mask) | ((count << bit_shift) & mask));
}

void G_SetAmmoStat(gclient_t &cl, uint8 ammo_id, uint16 count)
{
	set_compressed_integer(NUM_BITS_FOR_AMMO, cl, ammo_id, count, player_stat_t::AMMO_INFO_START * 2);
}

void G_SetPowerupStat(gclient_t &cl, uint8 powerup_id, uint16 count)
{
	set_compressed_integer(NUM_BITS_PER_POWERUP, cl, powerup_id, count, player_stat_t::POWERUP_INFO_START * 2);
}

void MoveClientToIntermission(ASEntity &ent)
{
	// [Paril-KEX]
	if (ent.e.client.ps.pmove.pm_type != pmtype_t::FREEZE)
		ent.e.s.event = entity_event_t::OTHER_TELEPORT;
	if (deathmatch.integer != 0)
		ent.client.showscores = true;
	ent.e.s.origin = level.intermission_origin;
	ent.e.client.ps.pmove.origin = level.intermission_origin;
	ent.e.client.ps.viewangles = level.intermission_angle;
	ent.e.client.ps.pmove.pm_type = pmtype_t::FREEZE;
	ent.e.client.ps.gunindex = 0;
	ent.e.client.ps.gunskin = 0;
	ent.e.client.ps.damage_blend[3] = ent.e.client.ps.screen_blend[3] = 0;
	ent.e.client.ps.rdflags = refdef_flags_t::NONE;

	// clean up powerup info
	ent.client.quad_time = time_zero;
	ent.client.invincible_time = time_zero;
	ent.client.breather_time = time_zero;
	ent.client.enviro_time = time_zero;
	ent.client.invisible_time = time_zero;
	ent.client.grenade_blew_up = false;
	ent.client.grenade_time = time_zero;
	
	ent.client.showhelp = false;
	ent.client.showscores = false;

    server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);

	// RAFAEL
	ent.client.quadfire_time = time_zero;
	// RAFAEL
	// ROGUE
	ent.client.ir_time = time_zero;
	ent.client.nuke_time = time_zero;
	ent.client.double_time = time_zero;
	ent.client.tracker_pain_time = time_zero;
	// ROGUE

	ent.viewheight = 0;
	ent.e.s.modelindex = 0;
	ent.e.s.modelindex2 = 0;
	ent.e.s.modelindex3 = 0;
	ent.e.s.modelindex = 0;
	ent.e.s.effects = effects_t::NONE;
	ent.e.s.sound = 0;
	ent.e.solid = solid_t::NOT;
	ent.movetype = movetype_t::NOCLIP;

	gi_linkentity(ent.e);

	// add the layout

	if (deathmatch.integer != 0)
	{
		DeathmatchScoreboard(ent);
		ent.client.showscores = true;
	}
}

// [Paril-KEX] update the level entry for end-of-unit screen
void G_UpdateLevelEntry()
{
	if (level.entry is null)
		return;
	
	level.entry.found_secrets = level.found_secrets;
	level.entry.total_secrets = level.total_secrets;
	level.entry.killed_monsters = level.killed_monsters;
	level.entry.total_monsters = level.total_monsters;
}

string G_EndOfUnitEntry(const int &in y, const level_entry_t &in entry)
{
    string layout = format("yv {} ", y);

	// we didn't visit this level, so print it as an unknown entry
	if (entry.pretty_name.empty())
	{
		layout += "table_row 1 ??? ";
		return layout;
	}

	layout += format("table_row 4 \"{}\" ", entry.pretty_name) + 
		format("{}/{} ", entry.killed_monsters, entry.total_monsters) + 
		format("{}/{} ", entry.found_secrets, entry.total_secrets);

	int minutes = entry.time.milliseconds / 60000;
	int seconds = (entry.time.milliseconds / 1000) % 60;
	int milliseconds = entry.time.milliseconds % 1000;

	layout += format("{:02}:{:02}:{:03} ", minutes, seconds, milliseconds);

    return layout;
}

void G_EndOfUnitMessage()
{
	// [Paril-KEX] update game level entry
	G_UpdateLevelEntry();

	string layout;

	// sort entries
	game.level_entries.sort(function(a, b) {
		int a_order = a.visit_order != 0 ? a.visit_order : (!a.pretty_name.empty() ? (MAX_LEVELS_PER_UNIT + 1) : (MAX_LEVELS_PER_UNIT + 2));
		int b_order = b.visit_order != 0 ? b.visit_order : (!b.pretty_name.empty() ? (MAX_LEVELS_PER_UNIT + 1) : (MAX_LEVELS_PER_UNIT + 2));

		return a_order < b_order;
	});

	layout += "start_table 4 $m_eou_level $m_eou_kills $m_eou_secrets $m_eou_time ";

	int y = 16;
	level_entry_t totals;
	int num_rows = 0;

	foreach (const level_entry_t @entry : game.level_entries)
	{
		if (entry.map_name.empty())
			break;

		layout += G_EndOfUnitEntry(y, entry);

		y += 8;
		
		totals.found_secrets += entry.found_secrets;
		totals.killed_monsters += entry.killed_monsters;
		totals.time += entry.time;
		totals.total_monsters += entry.total_monsters;
		totals.total_secrets += entry.total_secrets;

		if (entry.visit_order != 0)
			num_rows++;
	}

	y += 8;

	// make this a space so it prints totals
	if (num_rows > 1)
	{
		layout += "table_row 0 "; // empty row to separate totals
		totals.pretty_name = " ";
		layout += G_EndOfUnitEntry(y, totals);
	}

	layout += "xv 160 yt 0 draw_table ";

	layout += format("ifgef {} yb -48 xv 0 loc_cstring2 0 \"$m_eou_press_button\" endif ", (level.intermission_server_frame + time_sec(5).frames()));

	gi_WriteByte(svc_t::layout);
	gi_WriteString(layout);
	gi_multicast(vec3_origin, multicast_t::ALL, true);

    foreach (ASEntity @player : active_players)
		player.client.showeou = true;
}

void BeginIntermission(ASEntity &targ)
{
	ASEntity @ent, client;

	if (level.intermissiontime)
		return; // already activated

	// ZOID
	if (ctf.integer != 0)
		CTFCalcScores();
	// ZOID

	game.autosaved = false;

	level.intermissiontime = level.time;

	// respawn any dead clients
	for (uint i = 0; i < max_clients; i++)
	{
		@client = players[i];
		if (!client.e.inuse)
			continue;
		if (client.health <= 0)
		{
			// give us our max health back since it will reset
			// to pers.health; in instanced items we'd lose the items
			// we touched so we always want to respawn with our max.
			if (P_UseCoopInstancedItems())
				client.client.pers.health = client.client.pers.max_health = client.max_health;

			respawn(client);
		}
	}

	level.intermission_server_frame = gi_ServerFrame();
	level.changemap = targ.map;
	level.intermission_clear = (targ.spawnflags & spawnflags::changelevel::CLEAR_INVENTORY) != 0;
	level.intermission_eou = false;
	level.intermission_fade = (targ.spawnflags & spawnflags::changelevel::FADE_OUT) != 0;

	// destroy all player trails
	PlayerTrail_Destroy(null);

	// [Paril-KEX] update game level entry
	G_UpdateLevelEntry();

	if (level.changemap.findFirstOf("*") != -1)
	{
		if (coop.integer != 0)
		{
			for (uint i = 0; i < max_clients; i++)
			{
				@client = players[i];
				if (!client.e.inuse)
					continue;
				// strip players of all keys between units
				for (uint n = 0; n < item_id_t::TOTAL; n++)
					if ((itemlist[n].flags & item_flags_t::KEY) != 0)
						client.client.pers.inventory[n] = 0;
			}
		}

		if (!level.achievement.empty())
		{
			gi_WriteByte(svc_t::achievement);
			gi_WriteString(level.achievement);
			gi_multicast(vec3_origin, multicast_t::ALL, true);
		}

		level.intermission_eou = true;

		// "no end of unit" maps handle intermission differently
		if ((targ.spawnflags & spawnflags::changelevel::NO_END_OF_UNIT) == 0)
			G_EndOfUnitMessage();
		else if ((targ.spawnflags & spawnflags::changelevel::IMMEDIATE_LEAVE) != 0 && deathmatch.integer == 0)
		{
			level.exitintermission = true; // go immediately to the next level
			return;
		}
	}
	else
	{
		if (deathmatch.integer == 0)
		{
			level.exitintermission = true; // go immediately to the next level
			return;
		}
	}

	level.exitintermission = false;

	if (!level.level_intermission_set)
	{
		// find an intermission spot
		@ent = find_by_str<ASEntity>(null, "classname", "info_player_intermission");
		if (ent is null)
		{ // the map creator forgot to put in an intermission point...
			@ent = find_by_str<ASEntity>(null, "classname", "info_player_start");
			if (ent is null)
				@ent = find_by_str<ASEntity>(null, "classname", "info_player_deathmatch");
		}
		else
		{ // choose one of four spots
			int i = irandom(4);
			while ((i--) != 0)
			{
				@ent = find_by_str<ASEntity>(ent, "classname", "info_player_intermission");
				if (ent is null) // wrap around the list
					@ent = find_by_str<ASEntity>(ent, "classname", "info_player_intermission");
			}
		}

		level.intermission_origin = ent.e.s.origin;
		level.intermission_angle = ent.e.s.angles;
	}

	// move all clients to the intermission point
	for (uint i = 0; i < max_clients; i++)
	{
		@client = players[i];
		if (!client.e.inuse)
			continue;
		MoveClientToIntermission(client);
	}
}

const uint MAX_SCOREBOARD_SIZE = 1024;

/*
==================
DeathmatchScoreboardMessage

==================
*/
void DeathmatchScoreboardMessage(ASEntity &ent, ASEntity @killer)
{
	string entry, str;
	uint		j;
	int			score;
	int			x, y;
	ASClient @cl;
	ASEntity @cl_ent;
	string tag;

	// ZOID
	if (G_TeamplayEnabled())
	{
		CTFScoreboardMessage(ent, killer);
		return;
	}
	// ZOID
	array<int> sorted(max_clients), sortedscores(max_clients);

	//  sort the clients by score
	uint32 total = 0;
	for (uint32 i = 0; i < max_clients; i++)
	{
		@cl_ent = players[i];
		if (!cl_ent.e.inuse || cl_ent.client.resp.spectator)
			continue;
		score = cl_ent.client.resp.score;
		for (j = 0; j < total; j++)
		{
			if (score > sortedscores[j])
				break;
		}
		for (uint32 k = total; k > j; k--)
		{
			sorted[k] = sorted[k - 1];
			sortedscores[k] = sortedscores[k - 1];
		}
		sorted[j] = i;
		sortedscores[j] = score;
		total++;
	}

	// add the clients in sorted order
	if (total > 16)
		total = 16;

	for (uint32 i = 0; i < total; i++)
	{
		@cl_ent = players[sorted[i]];
		@cl = cl_ent.client;

		x = (i >= 8) ? 130 : -72;
		y = 0 + 32 * (i % 8);

		// add a dogtag
		// [Paril-KEX] use dynamic dogtags
		tag = "";

		if (!tag.empty())
		{
			entry = format("xv {} yv {} picn {} ", x + 32, y, tag);

			if (str.length() + entry.length() > MAX_SCOREBOARD_SIZE)
				break;

			str += entry;
		}
		else
		{
			entry = format("xv {} yv {} dogtag {} ", x + 32, y, sorted[i]);

			if (str.length() + entry.length() > MAX_SCOREBOARD_SIZE)
				break;

			str += entry;
		}

		entry = format("client {} {} {} {} {} {} ",
					x, y, sorted[i], cl.resp.score, cl_ent.e.client.ping, (level.time - cl.resp.entertime).minutesi());

		if (str.length() + entry.length() > MAX_SCOREBOARD_SIZE)
			break;

		str += entry;
	}

	// [Paril-KEX] time & frags
	if (fraglimit.integer != 0)
	{
		str += format("xv -20 yv -10 loc_string2 1 $g_score_frags \"{}\" ", fraglimit.integer);
	}
	if (timelimit.value != 0 && !level.intermissiontime)
	{
		str += format("xv 340 yv -10 time_limit {} ", gi_ServerFrame() + ((time_min(timelimit.value) - level.time)).milliseconds / gi_frame_time_ms);
	}

	if (level.intermissiontime)
		str += format("ifgef {} yb -48 xv 0 loc_cstring2 0 \"$m_eou_press_button\" endif ", (level.intermission_server_frame + time_sec(5).frames()));

	gi_WriteByte(svc_t::layout);
	gi_WriteString(str);
}

/*
==================
DeathmatchScoreboard

Draw instead of help message.
Note that it isn't that hard to overflow the 1400 byte message limit!
==================
*/
void DeathmatchScoreboard(ASEntity &ent)
{
	DeathmatchScoreboardMessage(ent, ent.enemy);
	gi_unicast(ent.e, true);
	ent.client.menutime = level.time + time_sec(3);
}

/*
==================
Cmd_Score_f

Display the scoreboard
==================
*/
void Cmd_Score_f(ASEntity &ent)
{
	if (level.intermissiontime)
		return;

	ent.client.showinventory = false;
	ent.client.showhelp = false;

	server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);

	// ZOID
	if (ent.client.menu !is null)
		PMenu_Close(ent);
	// ZOID

	if (deathmatch.integer == 0 && coop.integer == 0)
		return;

	if (ent.client.showscores)
	{
		ent.client.showscores = false;
		ent.client.update_chase = true;
		return;
	}

	ent.client.showscores = true;
	DeathmatchScoreboard(ent);
}

/*
==================
HelpComputer

Draw help computer.
==================
*/
void HelpComputer(ASEntity &ent)
{
	string sk;

	if (skill.integer == 0)
		sk = "$m_easy";
	else if (skill.integer == 1)
		sk = "$m_medium";
	else if (skill.integer == 2)
		sk = "$m_hard";
	else
		sk = "$m_nightmare";

	// send the layout

	string helpString = format(
		"xv 32 yv 8 picn help "		   // background
		"xv 0 yv 25 cstring2 \"{}\" ",  // level name
		level.level_name);

	if (level.is_n64)
	{
		helpString += format("xv 0 yv 54 loc_cstring 1 \"{{}}\" \"{}\" ",  // help 1
			game.helpmessage1);
	}
	else 
	{
		string first_message = game.helpmessage1;
		string first_title = level.primary_objective_title;

		string second_message = game.helpmessage2;
		string second_title = level.secondary_objective_title;

		if (level.is_psx)
		{
            // AS_TODO check optimize
            first_message = game.helpmessage2;
            first_title = level.secondary_objective_title;

            second_message = game.helpmessage1;
            second_title = level.primary_objective_title;

			//std::swap(first_message, second_message);
			//std::swap(first_title, second_title);
		}

		int y = 54;
		if (!first_message.empty())
		{
			helpString += format("xv 0 yv {} loc_cstring2 0 \"{}\" "  // title
				"xv 0 yv {} loc_cstring 0 \"{}\" ",
				y,
				first_title,
				y + 11,
				first_message);

			y += 58;
		}

		if (!second_message.empty())
		{
			helpString += format("xv 0 yv {} loc_cstring2 0 \"{}\" "  // title
				"xv 0 yv {} loc_cstring 0 \"{}\" ",
				y,
				second_title,
				y + 11,
				second_message);
		}

	}

	helpString += format("xv 55 yv 164 loc_string2 0 \"{}\" "
		"xv 265 yv 164 loc_rstring2 1 \"{{}}: {}/{}\" \"$g_pc_goals\" "
		"xv 55 yv 172 loc_string2 1 \"{{}}: {}/{}\" \"$g_pc_kills\" "
		"xv 265 yv 172 loc_rstring2 1 \"{{}}: {}/{}\" \"$g_pc_secrets\" ",
		sk,
		level.found_goals, level.total_goals,
		level.killed_monsters, level.total_monsters,
		level.found_secrets, level.total_secrets);

	gi_WriteByte(svc_t::layout);
	gi_WriteString(helpString);
	gi_unicast(ent.e, true);
}

/*
==================
Cmd_Help_f

Display the current help message
==================
*/
void Cmd_Help_f(ASEntity &ent)
{
	// this is for backwards compatability
	if (deathmatch.integer != 0)
	{
		Cmd_Score_f(ent);
		return;
	}

	if (level.intermissiontime)
		return;

	ent.client.showinventory = false;
	ent.client.showscores = false;

	if (ent.client.showhelp &&
			(ent.client.pers.game_help1changed == game.help1changed ||
			ent.client.pers.game_help2changed == game.help2changed))
	{
		ent.client.showhelp = false;
		server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);
		return;
	}

	ent.client.showhelp = true;
	ent.client.pers.helpchanged = 0;
	server_flags = server_flags_t(server_flags | server_flags_t::SLOW_TIME);
	HelpComputer(ent);
}

// [Paril-KEX] for stats we want to always be set in coop
// even if we're spectating
void G_SetCoopStats(ASEntity &ent)
{
	if (coop.integer != 0 && g_coop_enable_lives.integer != 0)
		ent.e.client.ps.stats[player_stat_t::LIVES] = ent.client.pers.lives + 1;
	else
		ent.e.client.ps.stats[player_stat_t::LIVES] = 0;

	// stat for text on what we're doing for respawn
	if (ent.client.coop_respawn_state != coop_respawn_t::NONE)
		ent.e.client.ps.stats[player_stat_t::COOP_RESPAWN] = game_configstring_id_t::COOP_RESPAWN_STRING + (ent.client.coop_respawn_state - coop_respawn_t::IN_COMBAT);
	else
		ent.e.client.ps.stats[player_stat_t::COOP_RESPAWN] = 0;
}

funcdef gtime_t powerup_time_f(const ASClient &);
funcdef int powerup_count_f(const ASClient &);

class powerup_info_t
{
	item_id_t item = item_id_t::NULL;
    powerup_time_f @time_ptr = null;
    powerup_count_f @count_ptr = null;

    powerup_info_t() { }
    
    powerup_info_t(item_id_t item, powerup_time_f @time_ptr, powerup_count_f @count_ptr)
    {
        this.item = item;
        @this.time_ptr = time_ptr;
        @this.count_ptr = count_ptr;
    }
}

const array<powerup_info_t> powerup_table = {
	powerup_info_t(item_id_t::ITEM_QUAD, function(c) { return c.quad_time; }, null),
	powerup_info_t(item_id_t::ITEM_QUADFIRE, function(c) { return c.quadfire_time; }, null),
	powerup_info_t(item_id_t::ITEM_DOUBLE, function(c) { return c.double_time; }, null),
	powerup_info_t(item_id_t::ITEM_INVULNERABILITY, function(c) { return c.invincible_time; }, null),
	powerup_info_t(item_id_t::ITEM_INVISIBILITY, function(c) { return c.invisible_time; }, null),
	powerup_info_t(item_id_t::ITEM_ENVIROSUIT, function(c) { return c.enviro_time; }, null),
	powerup_info_t(item_id_t::ITEM_REBREATHER, function(c) { return c.breather_time; }, null),
	powerup_info_t(item_id_t::ITEM_IR_GOGGLES, function(c) { return c.ir_time; }, null),
	powerup_info_t(item_id_t::ITEM_SILENCER, null, function(c) { return c.silencer_shots; })
};

/*
===============
G_SetStats
===============
*/
void G_SetStats(ASEntity &ent)
{
	const gitem_t	@item;
	item_id_t index;
	int		  cells = 0;
	item_id_t power_armor_type;
	uint invIndex;

    gclient_t @cl = ent.e.client;

	//
	// health
	//
	if ((ent.e.s.renderfx & renderfx_t::USE_DISGUISE) != 0)
		cl.ps.stats[player_stat_t::HEALTH_ICON] = level.disguise_icon;
	else
		cl.ps.stats[player_stat_t::HEALTH_ICON] = level.pic_health;
	cl.ps.stats[player_stat_t::HEALTH] = ent.health;

	//
	// weapons
	//
	uint32 weaponbits = 0;

	for (invIndex = item_id_t::WEAPON_GRAPPLE; invIndex <= item_id_t::WEAPON_DISRUPTOR; invIndex++)
	{
		if (ent.client.pers.inventory[invIndex] != 0)
		{
			weaponbits |= 1 << GetItemByIndex(item_id_t(invIndex)).weapon_wheel_index;
		}
	}

	cl.ps.stats[player_stat_t::WEAPONS_OWNED_1] = (weaponbits & 0xFFFF);
	cl.ps.stats[player_stat_t::WEAPONS_OWNED_2] = (weaponbits >> 16);

	cl.ps.stats[player_stat_t::ACTIVE_WHEEL_WEAPON] = (ent.client.newweapon !is null ? ent.client.newweapon.weapon_wheel_index :
		ent.client.pers.weapon !is null ? ent.client.pers.weapon.weapon_wheel_index :
		-1);
	cl.ps.stats[player_stat_t::ACTIVE_WEAPON] = ent.client.pers.weapon !is null ? ent.client.pers.weapon.weapon_wheel_index : -1;

	//
	// ammo
	//
	cl.ps.stats[player_stat_t::AMMO_ICON] = 0;
	cl.ps.stats[player_stat_t::AMMO] = 0;

	if (ent.client.pers.weapon !is null && ent.client.pers.weapon.ammo != item_id_t::NULL)
	{
		@item = GetItemByIndex(ent.client.pers.weapon.ammo);

		if (!G_CheckInfiniteAmmo(item))
		{
			cl.ps.stats[player_stat_t::AMMO_ICON] = gi_imageindex(item.icon);
			cl.ps.stats[player_stat_t::AMMO] = ent.client.pers.inventory[ent.client.pers.weapon.ammo];
		}
	}
	
    cl.ps.stats.fill(player_stat_t::AMMO_INFO_START * 2, 0, 2 * NUM_AMMO_STATS);
	for (uint ammoIndex = ammo_t::BULLETS; ammoIndex < ammo_t::MAX; ++ammoIndex)
	{
		const gitem_t @ammo = GetItemByAmmo(ammo_t(ammoIndex));
		uint16 val = G_CheckInfiniteAmmo(ammo) ? AMMO_VALUE_INFINITE : clamp(ent.client.pers.inventory[ammo.id], 0, AMMO_VALUE_INFINITE - 1);
		G_SetAmmoStat(cl, ammo.ammo_wheel_index, val);
	}

	//
	// armor
	//
	power_armor_type = PowerArmorType(ent);
	if (power_armor_type != item_id_t::NULL)
		cells = ent.client.pers.inventory[item_id_t::AMMO_CELLS];

	index = ArmorIndex(ent);

	if (power_armor_type != item_id_t::NULL && (index == item_id_t::NULL || (level.time.milliseconds % 3000) < 1500))
	{ // flash between power armor and other armor icon
		cl.ps.stats[player_stat_t::ARMOR_ICON] = power_armor_type == item_id_t::ITEM_POWER_SHIELD ? gi_imageindex("i_powershield") : gi_imageindex("i_powerscreen");
		cl.ps.stats[player_stat_t::ARMOR] = cells;
	}
	else if (index != item_id_t::NULL)
	{
		@item = GetItemByIndex(index);
		cl.ps.stats[player_stat_t::ARMOR_ICON] = gi_imageindex(item.icon);
		cl.ps.stats[player_stat_t::ARMOR] = ent.client.pers.inventory[index];
	}
	else
	{
		cl.ps.stats[player_stat_t::ARMOR_ICON] = 0;
		cl.ps.stats[player_stat_t::ARMOR] = 0;
	}

	//
	// pickup message
	//
	if (level.time > ent.client.pickup_msg_time)
	{
		cl.ps.stats[player_stat_t::PICKUP_ICON] = 0;
		cl.ps.stats[player_stat_t::PICKUP_STRING] = 0;
	}

	// owned powerups
    cl.ps.stats.fill(player_stat_t::POWERUP_INFO_START * 2, 0, 2 * NUM_POWERUP_STATS);

	for (powerup_t powerupIndex = powerup_t::SCREEN; powerupIndex < powerup_t::MAX; powerupIndex = powerup_t(powerupIndex + 1))
	{
		const gitem_t @powerup = GetItemByPowerup(powerupIndex);

        // temp
        if (powerup is null)
            continue;

		uint16 val;

		switch (powerup.id)
		{
		case item_id_t::ITEM_POWER_SCREEN:
		case item_id_t::ITEM_POWER_SHIELD:
			if (ent.client.pers.inventory[powerup.id] == 0)
				val = 0;
			else if ((ent.flags & ent_flags_t::POWER_ARMOR) != 0)
				val = 2;
			else
				val = 1;
			break;
		case item_id_t::ITEM_FLASHLIGHT:
			if (ent.client.pers.inventory[powerup.id] == 0)
				val = 0;
			else if ((ent.flags & ent_flags_t::FLASHLIGHT) != 0)
				val = 2;
			else
				val = 1;
			break;
		default:
			val = clamp(ent.client.pers.inventory[powerup.id], 0, 3);
			break;
		}

		G_SetPowerupStat(cl, powerup.powerup_wheel_index, val);
	}

	cl.ps.stats[player_stat_t::TIMER_ICON] = 0;
	cl.ps.stats[player_stat_t::TIMER] = 0;

	//
	// timers
	//
	// PGM
	if (ent.client.owned_sphere !is null)
	{
		if (uint(ent.client.owned_sphere.spawnflags) == uint(spawnflags::sphere::DEFENDER)) // defender
			cl.ps.stats[player_stat_t::TIMER_ICON] = gi_imageindex("p_defender");
		else if (uint(ent.client.owned_sphere.spawnflags) == uint(spawnflags::sphere::HUNTER)) // hunter
			cl.ps.stats[player_stat_t::TIMER_ICON] = gi_imageindex("p_hunter");
		else if (uint(ent.client.owned_sphere.spawnflags) == uint(spawnflags::sphere::VENGEANCE)) // vengeance
			cl.ps.stats[player_stat_t::TIMER_ICON] = gi_imageindex("p_vengeance");
		else // error case
			cl.ps.stats[player_stat_t::TIMER_ICON] = gi_imageindex("i_fixme");

		cl.ps.stats[player_stat_t::TIMER] = int(ceil(ent.client.owned_sphere.wait - level.time.secondsf()));
	}
	else
	{
		const powerup_info_t @best_powerup = null;

		foreach (const powerup_info_t @powerup : powerup_table)
		{
			if (powerup.time_ptr !is null && powerup.time_ptr(ent.client) <= level.time)
				continue;
			else if (powerup.count_ptr !is null && powerup.count_ptr(ent.client) == 0)
				continue;

			if (best_powerup is null)
			{
				@best_powerup = powerup;
				continue;
			}
			
			if (powerup.time_ptr !is null && powerup.time_ptr(ent.client) < best_powerup.time_ptr(ent.client))
			{
				@best_powerup = powerup;
				continue;
			}
			else if (powerup.count_ptr !is null && best_powerup.time_ptr is null)
			{
				@best_powerup = powerup;
				continue;
			}
		}

		if (best_powerup !is null)
		{
			int16 value;

			if (best_powerup.count_ptr !is null)
				value = best_powerup.count_ptr(ent.client);
			else
				value = int16(ceil((best_powerup.time_ptr(ent.client) - level.time).secondsf()));

			cl.ps.stats[player_stat_t::TIMER_ICON] = gi_imageindex(GetItemByIndex(best_powerup.item).icon);
			cl.ps.stats[player_stat_t::TIMER] = value;
		}
	}
	// PGM

	//
	// selected item
	//
	cl.ps.stats[player_stat_t::SELECTED_ITEM] = ent.client.pers.selected_item;

	if (ent.client.pers.selected_item == item_id_t::NULL)
		cl.ps.stats[player_stat_t::SELECTED_ICON] = 0;
	else
	{
		cl.ps.stats[player_stat_t::SELECTED_ICON] = gi_imageindex(itemlist[ent.client.pers.selected_item].icon);

		if (ent.client.pers.selected_item_time < level.time)
			cl.ps.stats[player_stat_t::SELECTED_ITEM_NAME] = 0;
	}

	//
	// layouts
	//
	cl.ps.stats[player_stat_t::LAYOUTS] = 0;

	if (deathmatch.integer != 0)
	{
		if (ent.client.pers.health <= 0 || level.intermissiontime || ent.client.showscores)
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::LAYOUT;
		if (ent.client.showinventory && ent.client.pers.health > 0)
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::INVENTORY;
	}
	else
	{
		if (ent.client.showscores || ent.client.showhelp || ent.client.showeou)
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::LAYOUT;
		if (ent.client.showinventory && ent.client.pers.health > 0)
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::INVENTORY;

		if (ent.client.showhelp)
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::HELP;
	}

	if (level.intermissiontime || ent.client.awaiting_respawn)
	{
		if (ent.client.awaiting_respawn || (level.intermission_eou || level.is_n64 || (deathmatch.integer != 0 && level.intermissiontime)))
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::HIDE_HUD;

		// N64 always merges into one screen on level ends
		if (level.intermission_eou || level.is_n64 || (deathmatch.integer != 0 && level.intermissiontime))
			cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::INTERMISSION;
	}
	
	if (level.story_active)
		cl.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::HIDE_CROSSHAIR;
	else
		cl.ps.stats[player_stat_t::LAYOUTS] &= ~layout_flags_t::HIDE_CROSSHAIR;

	// [Paril-KEX] key display
	if (deathmatch.integer == 0)
	{
		int32 key_offset = 0;
		player_stat_t stat = player_stat_t::KEY_A;
		
		cl.ps.stats[player_stat_t::KEY_A] = 
		cl.ps.stats[player_stat_t::KEY_B] = 
		cl.ps.stats[player_stat_t::KEY_C] = 0;

		// there's probably a way to do this in one pass but
		// I'm lazy
        // AS_TODO this is gonna be bad
		array<item_id_t> keys_held;

		foreach (const gitem_t @key_item : itemlist)
		{
			if ((key_item.flags & item_flags_t::KEY) == 0)
				continue;
			else if (ent.client.pers.inventory[key_item.id] == 0)
				continue;

			keys_held.push_back(key_item.id);
		}

		if (keys_held.length() > 3)
			key_offset = int32(level.time.secondsf() / 5);

		for (uint i = 0; i < min(keys_held.length(), 3); i++, stat = player_stat_t(stat + 1))
			cl.ps.stats[stat] = gi_imageindex(GetItemByIndex(keys_held[(i + key_offset) % keys_held.length()]).icon);
	}

	//
	// frags
	//
	cl.ps.stats[player_stat_t::FRAGS] = ent.client.resp.score;

	//
	// help icon / current weapon if not shown
	//
	if (ent.client.pers.helpchanged >= 1 && ent.client.pers.helpchanged <= 2 && (level.time.milliseconds % 1000) < 500) // haleyjd: time-limited
		cl.ps.stats[player_stat_t::HELPICON] = gi_imageindex("i_help");
	else if ((ent.client.pers.hand == handedness_t::CENTER) && ent.client.pers.weapon !is null)
		cl.ps.stats[player_stat_t::HELPICON] = gi_imageindex(ent.client.pers.weapon.icon);
	else
		cl.ps.stats[player_stat_t::HELPICON] = 0;

	cl.ps.stats[player_stat_t::SPECTATOR] = 0;

	// set & run the health bar stuff
    uint16 health_bars = 0;

	for (int i = 0; i < MAX_HEALTH_BARS; i++)
	{
		uint8 health_byte = 0;
        ASEntity @e = level.health_bar_entities[i];

		if (e is null)
            continue;
		else if (e.timestamp)
		{
			if (e.timestamp < level.time)
			{
				@level.health_bar_entities[i] = null;
				continue;
			}

			health_byte = 0b10000000;
		}
		else
		{
			// enemy dead
			if (e.enemy is null || !e.enemy.e.inuse || e.enemy.health <= 0)
			{
				// hack for Makron
				if ((e.enemy.monsterinfo.aiflags & ai_flags_t::DOUBLE_TROUBLE) != 0)
					health_byte = 0b10000000;
				else if (e.delay != 0)
				{
					e.timestamp = level.time + time_sec(e.delay);
					health_byte = 0b10000000;
				}
				else
                {
					@level.health_bar_entities[i] = null;
                    continue;
                }
			}
			else if ((e.spawnflags & spawnflag::healthbar::PVS_ONLY) != 0 && !gi_inPVS(ent.e.origin, e.enemy.e.origin, true))
				continue;
            else
            {
                float health_remaining = float(e.enemy.health) / e.enemy.max_health;
                health_byte = (uint8(health_remaining * 0b01111111) | 0b10000000);
            }
		}

        health_bars |= health_byte << (i * 8);
	}

    cl.ps.stats[player_stat_t::HEALTH_BARS] = int16(health_bars);

	// ZOID
	SetCTFStats(ent);
	// ZOID
}

/*
===============
G_CheckChaseStats
===============
*/
void G_CheckChaseStats(ASEntity &ent)
{
	for (uint32 i = 1; i <= max_clients; i++)
	{
		ASEntity @cl = entities[i];
		if (!cl.e.inuse || cl.client.chase_target !is ent)
			continue;
		cl.e.client.ps.stats = ent.e.client.ps.stats;
		G_SetSpectatorStats(cl);
	}
}

/*
===============
G_SetSpectatorStats
===============
*/
void G_SetSpectatorStats(ASEntity &ent)
{
	if (ent.client.chase_target is null)
		G_SetStats(ent);

	ent.e.client.ps.stats[player_stat_t::SPECTATOR] = 1;

	// layouts are independant in spectator
	ent.e.client.ps.stats[player_stat_t::LAYOUTS] = 0;
	if (ent.client.pers.health <= 0 || level.intermissiontime || ent.client.showscores)
		ent.e.client.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::LAYOUT;
	if (ent.client.showinventory && ent.client.pers.health > 0)
		ent.e.client.ps.stats[player_stat_t::LAYOUTS] |= layout_flags_t::INVENTORY;

	if (ent.client.chase_target !is null && ent.client.chase_target.e.inuse)
		ent.e.client.ps.stats[player_stat_t::CHASE] = configstring_id_t::PLAYERSKINS +
								   ent.e.s.number - 1;
	else
		ent.e.client.ps.stats[player_stat_t::CHASE] = 0;
}
