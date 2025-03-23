
// note: removed features:
// - gamerule cvar (unfinished Rogue game modes)
// - hint paths
// - match details (unused/unfinished feature for consoles)

gtime_t FRAME_TIME_MS, FRAME_TIME_S;

// [Paril-KEX] fetch the clipmask for this entity; certain modifiers
// affect the clipping behavior of objects.
contents_t G_GetClipMask(ASEntity &ent)
{
	contents_t mask = ent.e.clipmask;

	// default masks
	if (mask == contents_t::NONE)
	{
		if ((ent.e.svflags & svflags_t::MONSTER) != 0)
			mask = contents_t::MASK_MONSTERSOLID;
		else if ((ent.e.svflags & svflags_t::PROJECTILE) != 0)
			mask = contents_t::MASK_PROJECTILE;
		else
			mask = contents_t(contents_t::MASK_SHOT & ~contents_t::DEADMONSTER);
	}
	
	// non-solid objects (items, etc) shouldn't try to clip
	// against players/monsters
	if (ent.e.solid == solid_t::NOT || ent.e.solid == solid_t::TRIGGER)
		mask = contents_t(mask & ~(contents_t::MONSTER | contents_t::PLAYER));

	// monsters/players that are also dead shouldn't clip
	// against players/monsters
	if ((ent.e.svflags & (svflags_t::MONSTER | svflags_t::PLAYER) != 0) && (ent.e.svflags & svflags_t::DEADMONSTER) != 0)
		mask = contents_t(mask & ~(contents_t::MONSTER | contents_t::PLAYER));

	// remove special mask value
	mask = contents_t(mask & ~contents_t::AREAPORTAL);

	return mask;
}

// [Paril-KEX]
void G_RunBmodelAnimation(ASEntity &ent)
{
	auto @anim = ent.bmodel_anim;

	if (anim.currently_alternate != anim.alternate)
	{
		anim.currently_alternate = anim.alternate;
		anim.next_tick = time_zero;
	}

	if (level.time < anim.next_tick)
		return;

	const auto speed = anim.alternate ? anim.alt_speed : anim.speed;

	anim.next_tick = level.time + time_ms(speed);

	const auto style = anim.alternate ? anim.alt_style : anim.style;
	
	const auto start = anim.alternate ? anim.alt_start : anim.start;
	const auto end = anim.alternate ? anim.alt_end : anim.end;

	switch (style)
	{
	case bmodel_animstyle_t::FORWARDS:
		if (end >= start)
			ent.e.s.frame++;
		else
			ent.e.s.frame--;
		break;
	case bmodel_animstyle_t::BACKWARDS:
		if (end >= start)
			ent.e.s.frame--;
		else
			ent.e.s.frame++;
		break;
	case bmodel_animstyle_t::RANDOM:
		ent.e.s.frame = irandom(start, end + 1);
		break;
	}

	const auto nowrap = anim.alternate ? anim.alt_nowrap : anim.nowrap;

	if (nowrap)
	{
		if (end >= start)
			ent.e.s.frame = clamp(ent.e.s.frame, start, end);
		else
			ent.e.s.frame = clamp(ent.e.s.frame, end, start);
	}
	else
	{
		if (ent.e.s.frame < start)
			ent.e.s.frame = end;
		else if (ent.e.s.frame > end)
			ent.e.s.frame = start;
	}
}

void test_func()
{
    ai_flags_t t = ai_flags_t::NONE;
    t = ai_flags_t(t & ~ai_flags_t::PATHING);
}

/*
================
G_RunEntity

================
*/
void G_RunEntity(ASEntity &ent)
{
	// PGM
	trace_t trace;
	vec3_t	previous_origin;
	bool	has_previous_origin = false;

	if (ent.movetype == movetype_t::STEP)
	{
		previous_origin = ent.e.s.origin;
		has_previous_origin = true;
	}
	// PGM

	if (ent.prethink !is null)
		ent.prethink(ent);

	// bmodel animation stuff runs first, so custom entities
	// can override them
	if (ent.bmodel_anim.enabled)
		G_RunBmodelAnimation(ent);

	switch (ent.movetype)
	{
	case movetype_t::PUSH:
	case movetype_t::STOP:
		SV_Physics_Pusher(ent);
		break;
	case movetype_t::NONE:
		SV_Physics_None(ent);
		break;
	case movetype_t::NOCLIP:
		SV_Physics_Noclip(ent);
		break;
	case movetype_t::STEP:
		SV_Physics_Step(ent);
		break;
	case movetype_t::TOSS:
	case movetype_t::BOUNCE:
	case movetype_t::FLY:
	case movetype_t::FLYMISSILE:
	// RAFAEL
	case movetype_t::WALLBOUNCE:
		// RAFAEL
		SV_Physics_Toss(ent);
		break;
	default:
		gi_Com_Error("G_RunEntity: bad movetype {}", int(ent.movetype));
	}

	// PGM
	if (has_previous_origin && ent.movetype == movetype_t::STEP)
	{
		// if we moved, check and fix origin if needed
		if (ent.e.s.origin != previous_origin)
		{
			trace = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, previous_origin, ent.e, G_GetClipMask(ent));
			if (trace.allsolid || trace.startsolid)
				ent.e.s.origin = previous_origin;
		}
	}
	// PGM

	if (ent.e.inuse && ent.postthink !is null)
		ent.postthink(ent);
}


/*
=================
CreateTargetChangeLevel

Returns the created target changelevel
=================
*/
ASEntity @CreateTargetChangeLevel(const string &in map)
{
	ASEntity @ent;

	@ent = G_Spawn();
	ent.classname = "target_changelevel";
	level.nextmap = map;
	ent.map = level.nextmap;
	return ent;
}

/*
=================
EndDMLevel

The timelimit or fraglimit has been exceeded
=================
*/
void EndDMLevel()
{
	ASEntity @ent;

	// stay on same level flag
	if (g_dm_same_level.integer != 0)
	{
		BeginIntermission(CreateTargetChangeLevel(level.mapname));
		return;
	}

	if (!level.forcemap.empty())
	{
		BeginIntermission(CreateTargetChangeLevel(level.forcemap));
		return;
	}

	string str = g_map_list.stringval;

	// see if it's in the map list
	if (!str.empty())
	{
        array<string> maps = str.split(" ");
		string first_map;

        if (!maps.empty())
            first_map = maps[0];

		for (uint i = 0; i < maps.length(); i++)
        {
            string map = maps[i];

			if (Q_strcasecmp(map, level.mapname) == 0)
			{
				if (i == maps.length() - 1)
				{
					// end of list, go to first one
					if (first_map.empty()) // there isn't a first one, same level
					{
						BeginIntermission(CreateTargetChangeLevel(level.mapname));
						return;
					}
					else
					{
						// [Paril-KEX] re-shuffle if necessary
						if (g_map_list_shuffle.integer != 0)
						{
							if (maps.length() <= 1)
							{
								// meh
								BeginIntermission(CreateTargetChangeLevel(level.mapname));
								return;
							}

                            maps.shuffle();

							// if the current map is the map at the front, push it to the end
							if (maps[0] == level.mapname)
                            {
                                // TODO: array.swap?
                                string temp = maps[0];
                                maps[0] = maps[maps.length() - 1];
                                maps[maps.length() - 1] = temp;
                            }

							gi_cvar_forceset("g_map_list", join(maps, " "));

							BeginIntermission(CreateTargetChangeLevel(maps[0]));
							return;
						}

						BeginIntermission(CreateTargetChangeLevel(first_map));
						return;
					}
				}
				else
				{
				    // it's in the list, go to the next one
					BeginIntermission(CreateTargetChangeLevel(maps[i + 1]));
					return;
				}
			}
		}
	}

	if (!level.nextmap.empty()) // go to a specific map
	{
		BeginIntermission(CreateTargetChangeLevel(level.nextmap));
		return;
	}

	// search for a changelevel
	ent = find_by_str<ASEntity>(null, "classname", "target_changelevel");

	if (ent is null)
	{ // the map designer didn't include a changelevel,
		// so create a fake ent that goes back to the same level
		BeginIntermission(CreateTargetChangeLevel(level.mapname));
		return;
	}

	BeginIntermission(ent);
}

int password_modified, spectator_password_modified;

/*
=================
CheckNeedPass
=================
*/
void CheckNeedPass()
{
	int need;

	// if password or spectator_password has changed, update needpass
	// as needed
	if (Cvar_WasModified(password, password_modified) || Cvar_WasModified(spectator_password, spectator_password_modified))
	{
		need = 0;

		if (!password.stringval.empty() && Q_strcasecmp(password.stringval, "none") != 0)
			need |= 1;
		if (!spectator_password.stringval.empty() && Q_strcasecmp(spectator_password.stringval, "none")  != 0)
			need |= 2;

		gi_cvar_set("needpass", format("{}", need));
	}
}

/*
=================
CheckDMRules
=================
*/
void CheckDMRules()
{
	ASEntity @cl;

	if (level.intermissiontime)
		return;

	if (deathmatch.integer == 0)
		return;

	// ZOID
	if (ctf.integer != 0 && CTFCheckRules())
	{
		EndDMLevel();
		return;
	}
	if (CTFInMatch())
		return; // no checking in match mode
				// ZOID

	if (timelimit.value != 0)
	{
		if (level.time >= time_min(timelimit.value))
		{
			gi_LocBroadcast_Print(print_type_t::HIGH, "$g_timelimit_hit");
			EndDMLevel();
			return;
		}
	}

	if (fraglimit.integer != 0)
	{
		// [Paril-KEX]
		if (teamplay.integer != 0)
		{
			CheckEndTDMLevel();
			return;
		}

		for (uint i = 0; i < max_clients; i++)
		{
			@cl = players[i];
			if (!cl.e.inuse)
				continue;

			if (cl.client.resp.score >= fraglimit.integer)
			{
				gi_LocBroadcast_Print(print_type_t::HIGH, "$g_fraglimit_hit");
				EndDMLevel();
				return;
			}
		}
	}
}

/*
=============
ExitLevel
=============
*/
void ExitLevel()
{
	// [Paril-KEX] N64 fade
	if (level.intermission_fade)
	{
		level.intermission_fade_time = level.time + time_sec(1.3);
		level.intermission_fading = true;
		return;
	}

	ClientEndServerFrames();

	level.exitintermission = false;
	level.intermissiontime = time_zero;

	// [Paril-KEX] support for intermission completely wiping players
	// back to default stuff
	if (level.intermission_clear)
	{
		level.intermission_clear = false;

		for (uint i = 0; i < max_clients; i++)
		{
			// [Kex] Maintain user info to keep the player skin. 
            string userinfo = players[i].client.pers.userinfo;

            players[i].client.pers = client_persistant_t();
            players[i].client.resp.coop_respawn = client_persistant_t();
			players[i].health = 0; // this should trip the power armor, etc to reset as well

            players[i].client.pers.userinfo = players[i].client.resp.coop_respawn.userinfo = userinfo;
		}
	}

	// [Paril-KEX] end of unit, so clear level trackers
	if (level.intermission_eou)
	{
		game.level_entries.resize(0);

		// give all players their lives back
		if (g_coop_enable_lives.integer != 0)
            foreach (ASEntity @player : active_players)
				player.client.pers.lives = g_coop_num_lives.integer + 1;
	}

	if (CTFNextMap())
		return;

	if (level.changemap.empty())
	{
		gi_Com_Error("Got null changemap when trying to exit level. Was a trigger_changelevel configured correctly?");
		return;
	}

	// for N64 mainly, but if we're directly changing to "victorXXX.pcx" then
	// end game
	uint start_offset = (level.changemap[0] == '*' ? 1 : 0);

    if (level.changemap.length() > (6 + start_offset) &&
		Q_strncasecmp(level.changemap.substr(), "victor", 6) == 0 &&
		Q_strncasecmp(level.changemap.substr(level.changemap.length() - 4), ".pcx", 4) == 0)
		gi_AddCommandString(format("endgame \"{}\"\n", level.changemap.substr(start_offset)));
	else
		gi_AddCommandString(format("gamemap \"{}\"\n", level.changemap));

	level.changemap = "";
}

void G_CheckCvars()
{
	if (Cvar_WasModified(sv_airaccelerate, game.airacceleration_modified))
	{
		// [Paril-KEX] air accel handled by game DLL now, and allow
		// it to be changed in sp/coop
		gi_configstring(configstring_id_t::AIRACCEL, format("{}", sv_airaccelerate.integer));
		pm_config.airaccel = sv_airaccelerate.integer;
	}

	if (Cvar_WasModified(sv_gravity, game.gravity_modified))
		level.gravity = sv_gravity.value;
}

bool G_AnyDeadPlayersWithoutLives()
{
    foreach (ASEntity @player : active_players)
		if (player.health <= 0 && player.client.pers.lives == 0)
			return true;

	return false;
}

/*
================
Advances the world by 0.1 seconds
================
*/
void G_RunFrame(bool main_loop)
{
	G_CheckCvars();

    // AS_TODO
	//Bot_UpdateDebug();

	level.time += FRAME_TIME_MS;

	if (level.intermission_fading)
	{
        // AS_TODO this should probably be done in ClientEndServerFrame
		if (level.intermission_fade_time > level.time)
		{
			float alpha = clamp(1.0f - (level.intermission_fade_time - level.time - time_ms(300)).secondsf(), 0.0f, 1.0f);

            foreach (ASEntity @player : active_players)
			    player.e.client.ps.screen_blend = { 0, 0, 0, alpha };
		}
		else
		{
			level.intermission_fade = level.intermission_fading = false;
			ExitLevel();
		}

		return;
	}

	// exit intermissions

	if (level.exitintermission)
	{
		ExitLevel();
		return;
	}

	// reload the map start save if restart time is set (all players are dead)
	if (level.coop_level_restart_time > time_zero && level.time > level.coop_level_restart_time)
	{
		ClientEndServerFrames();
		gi_AddCommandString("restart_level\n");
	}

	// clear client coop respawn states; this is done
	// early since it may be set multiple times for different
	// players
	if (coop.integer != 0 && (g_coop_enable_lives.integer != 0 || g_coop_squad_respawn.integer != 0))
    {
        foreach (ASEntity @player : active_players)
        {
			if (player.client.respawn_time >= level.time)
				player.client.coop_respawn_state = coop_respawn_t::WAITING;
			else if (g_coop_enable_lives.integer != 0 && player.health <= 0 && player.client.pers.lives == 0)
				player.client.coop_respawn_state = coop_respawn_t::NO_LIVES;
			else if (g_coop_enable_lives.integer != 0 && G_AnyDeadPlayersWithoutLives())
				player.client.coop_respawn_state = coop_respawn_t::NO_LIVES;
			else
				player.client.coop_respawn_state = coop_respawn_t::NONE;
		}
	}

    bool update_bots = level.num_bots != 0;

    // run edicts
    for (uint i = 0; i < num_edicts; i++)
    {
        ASEntity @ent = @entities[i];

        if (!ent.e.inuse)
        {
			// defer removing client info so that disconnected, etc works
			if (i > 0 && i <= max_clients)
			{
				if (ent.timestamp && level.time < ent.timestamp)
				{
					int32 playernum = ent.e.s.number - 1;
					gi_configstring(uint(configstring_id_t::PLAYERSKINS) + playernum, "");
					ent.timestamp = time_zero;
				}
			}
            continue;
        }

        @level.current_entity = @ent;

        // Paril: RF_BEAM entities update their old_origin by hand.
        if ((ent.e.s.renderfx & renderfx_t::BEAM) == 0)
            ent.e.s.old_origin = ent.e.s.origin;

        // if the ground entity moved, make sure we are still on it
        if (ent.groundentity !is null && (ent.groundentity.e.linkcount != ent.groundentity_linkcount))
        {
            contents_t mask = G_GetClipMask(ent);

            if ((ent.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) == 0 && (ent.e.svflags & svflags_t::MONSTER) != 0)
            {
                @ent.groundentity = null;
                M_CheckGround(ent, mask);
            }
            else
            {
                // if it's still 1 point below us, we're good
                trace_t tr = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.e.s.origin + ent.gravityVector, ent.e, mask);

                if (tr.startsolid || tr.allsolid || !(tr.ent is ent.groundentity.e))
                    @ent.groundentity = null;
                else
                    ent.groundentity_linkcount = ent.groundentity.e.linkcount;
            }
        }

        if (update_bots)
            Entity_UpdateState( ent );

        if (i > 0 && i <= max_clients)
        {
            ClientBeginServerFrame(ent);
            continue;
        }

        G_RunEntity(ent);
    }

	// see if it is time to end a deathmatch
	CheckDMRules();

	// see if needpass needs updated
	CheckNeedPass();

	if (coop.integer != 0 && (g_coop_enable_lives.integer != 0 || g_coop_squad_respawn.integer != 0))
	{
		// rarely, we can see a flash of text if all players respawned
		// on some other player, so if everybody is now alive we'll reset
		// back to empty
		bool reset_coop_respawn = true;

        foreach (ASEntity @player : active_players)
        {
			if (player.health > 0)
			{
				reset_coop_respawn = false;
				break;
			}
		}

		if (reset_coop_respawn)
            foreach (ASEntity @player : active_players)
    		    player.client.coop_respawn_state = coop_respawn_t::NONE;
	}

	// build the playerstate_t structures for all players
	ClientEndServerFrames();

	// [Paril-KEX] if not in intermission and player 1 is loaded in
	// the game as an entity, increase timer on current entry
	if (level.entry !is null && !level.intermissiontime && players[0].e.inuse && players[0].client.pers.connected)
		level.entry.time += FRAME_TIME_S;

	// [Paril-KEX] run monster pains now
    for (uint i = max_clients + 1 + BODY_QUEUE_SIZE; i < num_edicts; i++)
    {
        ASEntity @ent = @entities[i];

		if (!ent.e.inuse || (ent.e.svflags & svflags_t::MONSTER) == 0)
			continue;

		M_ProcessPain(ent);
	}
}

bool G_AnyPlayerSpawned()
{
    foreach (ASEntity @player : active_players)
		if (player.client.pers.spawned)
			return true;

	return false;
}

const gtime_t MATCH_REPORT_TIME = time_sec(45);

void RunFrame(bool main_loop)
{
	if (main_loop && !G_AnyPlayerSpawned())
		return;
	
	for (int i = 0; i < g_frames_per_frame.integer; i++)
		G_RunFrame(main_loop);
}

cvar_t @developer;
cvar_t @deathmatch;
cvar_t @coop;
cvar_t @skill;
cvar_t @fraglimit;
cvar_t @timelimit;
// ZOID
cvar_t @capturelimit;
cvar_t @g_quick_weapon_switch;
cvar_t @g_instant_weapon_switch;
// ZOID
cvar_t @password;
cvar_t @spectator_password;
cvar_t @needpass;
cvar_t @maxspectators;
cvar_t @g_select_empty;
cvar_t @sv_dedicated;

cvar_t @filterban;

cvar_t @sv_maxvelocity;
cvar_t @sv_gravity;

cvar_t @g_skipViewModifiers;

cvar_t @sv_rollspeed;
cvar_t @sv_rollangle;
cvar_t @gun_x;
cvar_t @gun_y;
cvar_t @gun_z;

cvar_t @run_pitch;
cvar_t @run_roll;
cvar_t @bob_up;
cvar_t @bob_pitch;
cvar_t @bob_roll;

cvar_t @sv_cheats;

cvar_t @g_debug_monster_paths;
cvar_t @g_debug_monster_kills;
cvar_t @g_debug_poi;

cvar_t @bot_debug_follow_actor;
cvar_t @bot_debug_move_to_point;

cvar_t @flood_msgs;
cvar_t @flood_persecond;
cvar_t @flood_waitdelay;

cvar_t @sv_stopspeed; // PGM	 (this was a define in g_phys.c)

cvar_t @g_strict_saves;

// ROGUE cvars
cvar_t @huntercam;
cvar_t @g_dm_strong_mines;
cvar_t @g_dm_random_items;
// ROGUE

// [Kex]
cvar_t @g_instagib;
cvar_t @g_coop_player_collision;
cvar_t @g_coop_squad_respawn;
cvar_t @g_coop_enable_lives;
cvar_t @g_coop_num_lives;
cvar_t @g_coop_instanced_items;
cvar_t @g_allow_grapple;
cvar_t @g_grapple_fly_speed;
cvar_t @g_grapple_pull_speed;
cvar_t @g_grapple_damage;
cvar_t @g_coop_health_scaling;
cvar_t @g_weapon_respawn_time;

// dm"flags"
cvar_t @g_no_health;
cvar_t @g_no_items;
cvar_t @g_dm_weapons_stay;
cvar_t @g_dm_no_fall_damage;
cvar_t @g_dm_instant_items;
cvar_t @g_dm_same_level;
cvar_t @g_friendly_fire;
cvar_t @g_dm_force_respawn;
cvar_t @g_dm_force_respawn_time;
cvar_t @g_dm_spawn_farthest;
cvar_t @g_no_armor;
cvar_t @g_dm_allow_exit;
cvar_t @g_infinite_ammo;
cvar_t @g_dm_no_quad_drop;
cvar_t @g_dm_no_quadfire_drop;
cvar_t @g_no_mines;
cvar_t @g_dm_no_stack_double;
cvar_t @g_no_nukes;
cvar_t @g_no_spheres;
cvar_t @g_teamplay_armor_protect;
cvar_t @g_allow_techs;
cvar_t @g_start_items;
cvar_t @g_map_list;
cvar_t @g_map_list_shuffle;
cvar_t @g_lag_compensation;

cvar_t @sv_airaccelerate;
cvar_t @g_damage_scale;
cvar_t @g_disable_player_collision;
cvar_t @ai_damage_scale;
cvar_t @ai_model_scale;
cvar_t @ai_allow_dm_spawn;
cvar_t @ai_movement_disabled;

cvar_t @g_frames_per_frame;

/*
============
This will be called when the game module is first loaded, which
only happens when a new game is started or a save game
is loaded.
============
*/
void PreInitGame()
{
	@developer = gi_cvar("developer", "0", cvar_flags_t::NOFLAGS);
	@deathmatch = gi_cvar("deathmatch", "0", cvar_flags_t::LATCH);
	@coop = gi_cvar("coop", "0", cvar_flags_t::LATCH);
	@teamplay = gi_cvar("teamplay", "0", cvar_flags_t::LATCH);

	// ZOID
	CTFInit();

	// This gamemode only supports deathmatch
    if (ctf.integer != 0)
	{
		if (deathmatch.integer == 0)
		{
			gi_Com_Print("Forcing deathmatch.\n");
			gi_cvar_set("deathmatch", "1");
		}
		// force coop off
		if (coop.integer != 0)
			gi_cvar_set("coop", "0");
		// force tdm off
		if (teamplay.integer != 0)
			gi_cvar_set("teamplay", "0");
	}
	if (teamplay.integer != 0)
	{
		if (deathmatch.integer == 0)
		{
			gi_Com_Print("Forcing deathmatch.\n");
			gi_cvar_set("deathmatch", "1");
		}
		// force coop off
		if (coop.integer != 0)
			gi_cvar_set("coop", "0");
	}
	// ZOID
}

/*
============
Called after PreInitGame when the game has set up cvars.
============
*/
void InitGame()
{
	gi_Com_Print("==== InitGame ====\n");

	@gun_x = gi_cvar("gun_x", "0", cvar_flags_t::NOFLAGS);
	@gun_y = gi_cvar("gun_y", "0", cvar_flags_t::NOFLAGS);
	@gun_z = gi_cvar("gun_z", "0", cvar_flags_t::NOFLAGS);

	// FIXME: sv_ prefix is wrong for these
	@sv_rollspeed = gi_cvar("sv_rollspeed", "200", cvar_flags_t::NOFLAGS);
	@sv_rollangle = gi_cvar("sv_rollangle", "2", cvar_flags_t::NOFLAGS);
	@sv_maxvelocity = gi_cvar("sv_maxvelocity", "2000", cvar_flags_t::NOFLAGS);
	@sv_gravity = gi_cvar("sv_gravity", "800", cvar_flags_t::NOFLAGS);

	@g_skipViewModifiers = gi_cvar("g_skipViewModifiers", "0", cvar_flags_t::NOSET);

	@sv_stopspeed = gi_cvar("sv_stopspeed", "100", cvar_flags_t::NOFLAGS); // PGM - was #define in g_phys.c

	// ROGUE
	@huntercam = gi_cvar("huntercam", "1", cvar_flags_t(cvar_flags_t::SERVERINFO | cvar_flags_t::LATCH));
	@g_dm_strong_mines = gi_cvar("g_dm_strong_mines", "0", cvar_flags_t::NOFLAGS);
	@g_dm_random_items = gi_cvar("g_dm_random_items", "0", cvar_flags_t::NOFLAGS);
	// ROGUE

	// [Kex] Instagib
	@g_instagib = gi_cvar("g_instagib", "0", cvar_flags_t::NOFLAGS);

	// [Paril-KEX]
	@g_coop_player_collision = gi_cvar("g_coop_player_collision", "0", cvar_flags_t::LATCH);
	@g_coop_squad_respawn = gi_cvar("g_coop_squad_respawn", "1", cvar_flags_t::LATCH);
	@g_coop_enable_lives = gi_cvar("g_coop_enable_lives", "0", cvar_flags_t::LATCH);
	@g_coop_num_lives = gi_cvar("g_coop_num_lives", "2", cvar_flags_t::LATCH);
	@g_coop_instanced_items = gi_cvar("g_coop_instanced_items", "1", cvar_flags_t::LATCH);
	@g_allow_grapple = gi_cvar("g_allow_grapple", "auto", cvar_flags_t::NOFLAGS);
	@g_grapple_fly_speed = gi_cvar("g_grapple_fly_speed", format("{}", CTF_DEFAULT_GRAPPLE_SPEED), cvar_flags_t::NOFLAGS);
	@g_grapple_pull_speed = gi_cvar("g_grapple_pull_speed", format("{}", CTF_DEFAULT_GRAPPLE_PULL_SPEED), cvar_flags_t::NOFLAGS);
	@g_grapple_damage = gi_cvar("g_grapple_damage", "10", cvar_flags_t::NOFLAGS);

	@g_debug_monster_paths = gi_cvar("g_debug_monster_paths", "0", cvar_flags_t::NOFLAGS);
	@g_debug_monster_kills = gi_cvar("g_debug_monster_kills", "0", cvar_flags_t::LATCH);
	@g_debug_poi = gi_cvar("g_debug_poi", "0", cvar_flags_t::NOFLAGS);

	@bot_debug_follow_actor = gi_cvar("bot_debug_follow_actor", "0", cvar_flags_t::NOFLAGS);
	@bot_debug_move_to_point = gi_cvar("bot_debug_move_to_point", "0", cvar_flags_t::NOFLAGS);

	// noset vars
	@sv_dedicated = gi_cvar("dedicated", "0", cvar_flags_t::NOSET);

	// latched vars
	@sv_cheats = gi_cvar("cheats", "0", cvar_flags_t(cvar_flags_t::SERVERINFO | cvar_flags_t::LATCH));
	//cvar_t("gamename", GAMEVERSION, cvar_flags_t(cvar_flags_t::SERVERINFO | cvar_flags_t::LATCH));

	@maxspectators = gi_cvar("maxspectators", "4", cvar_flags_t::SERVERINFO);
	@skill = gi_cvar("skill", "1", cvar_flags_t::LATCH);

	// change anytime vars
	@fraglimit = gi_cvar("fraglimit", "0", cvar_flags_t::SERVERINFO);
	@timelimit = gi_cvar("timelimit", "0", cvar_flags_t::SERVERINFO);
	// ZOID
	@capturelimit = gi_cvar("capturelimit", "0", cvar_flags_t::SERVERINFO);
	@g_quick_weapon_switch = gi_cvar("g_quick_weapon_switch", "1", cvar_flags_t::LATCH);
	@g_instant_weapon_switch = gi_cvar("g_instant_weapon_switch", "0", cvar_flags_t::LATCH);
	// ZOID
	@password = gi_cvar("password", "", cvar_flags_t::USERINFO);
	@spectator_password = gi_cvar("spectator_password", "", cvar_flags_t::USERINFO);
	@needpass = gi_cvar("needpass", "0", cvar_flags_t::SERVERINFO);
	@filterban = gi_cvar("filterban", "1", cvar_flags_t::NOFLAGS);

	@g_select_empty = gi_cvar("g_select_empty", "0", cvar_flags_t::ARCHIVE);

	@run_pitch = gi_cvar("run_pitch", "0.002", cvar_flags_t::NOFLAGS);
	@run_roll = gi_cvar("run_roll", "0.005", cvar_flags_t::NOFLAGS);
	@bob_up = gi_cvar("bob_up", "0.005", cvar_flags_t::NOFLAGS);
	@bob_pitch = gi_cvar("bob_pitch", "0.002", cvar_flags_t::NOFLAGS);
	@bob_roll = gi_cvar("bob_roll", "0.002", cvar_flags_t::NOFLAGS);

	// flood control
	@flood_msgs = gi_cvar("flood_msgs", "4", cvar_flags_t::NOFLAGS);
	@flood_persecond = gi_cvar("flood_persecond", "4", cvar_flags_t::NOFLAGS);
	@flood_waitdelay = gi_cvar("flood_waitdelay", "10", cvar_flags_t::NOFLAGS);

	@g_strict_saves = gi_cvar("g_strict_saves", "1", cvar_flags_t::NOFLAGS);

	@sv_airaccelerate = gi_cvar("sv_airaccelerate", "0", cvar_flags_t::NOFLAGS);

	@g_damage_scale = gi_cvar("g_damage_scale", "1", cvar_flags_t::NOFLAGS);
	@g_disable_player_collision = gi_cvar("g_disable_player_collision", "0", cvar_flags_t::NOFLAGS);
	@ai_damage_scale = gi_cvar("ai_damage_scale", "1", cvar_flags_t::NOFLAGS);
	@ai_model_scale = gi_cvar("ai_model_scale", "0", cvar_flags_t::NOFLAGS);
	@ai_allow_dm_spawn = gi_cvar("ai_allow_dm_spawn", "0", cvar_flags_t::NOFLAGS);
	@ai_movement_disabled = gi_cvar("ai_movement_disabled", "0", cvar_flags_t::NOFLAGS);

	@g_frames_per_frame = gi_cvar("g_frames_per_frame", "1", cvar_flags_t::NOFLAGS);

	@g_coop_health_scaling = gi_cvar("g_coop_health_scaling", "0", cvar_flags_t::LATCH);
	@g_weapon_respawn_time = gi_cvar("g_weapon_respawn_time", "30", cvar_flags_t::NOFLAGS);

	// dm "flags"
	@g_no_health = gi_cvar("g_no_health", "0", cvar_flags_t::NOFLAGS);
	@g_no_items = gi_cvar("g_no_items", "0", cvar_flags_t::NOFLAGS);
	@g_dm_weapons_stay = gi_cvar("g_dm_weapons_stay", "0", cvar_flags_t::NOFLAGS);
	@g_dm_no_fall_damage = gi_cvar("g_dm_no_fall_damage", "0", cvar_flags_t::NOFLAGS);
	@g_dm_instant_items = gi_cvar("g_dm_instant_items", "1", cvar_flags_t::NOFLAGS);
	@g_dm_same_level = gi_cvar("g_dm_same_level", "0", cvar_flags_t::NOFLAGS);
	@g_friendly_fire = gi_cvar("g_friendly_fire", "0", cvar_flags_t::NOFLAGS);
	@g_dm_force_respawn = gi_cvar("g_dm_force_respawn", "0", cvar_flags_t::NOFLAGS);
	@g_dm_force_respawn_time = gi_cvar("g_dm_force_respawn_time", "0", cvar_flags_t::NOFLAGS);
	@g_dm_spawn_farthest = gi_cvar("g_dm_spawn_farthest", "1", cvar_flags_t::NOFLAGS);
	@g_no_armor = gi_cvar("g_no_armor", "0", cvar_flags_t::NOFLAGS);
	@g_dm_allow_exit = gi_cvar("g_dm_allow_exit", "0", cvar_flags_t::NOFLAGS);
	@g_infinite_ammo = gi_cvar("g_infinite_ammo", "0", cvar_flags_t::LATCH);
	@g_dm_no_quad_drop = gi_cvar("g_dm_no_quad_drop", "0", cvar_flags_t::NOFLAGS);
	@g_dm_no_quadfire_drop = gi_cvar("g_dm_no_quadfire_drop", "0", cvar_flags_t::NOFLAGS);
	@g_no_mines = gi_cvar("g_no_mines", "0", cvar_flags_t::NOFLAGS);
	@g_dm_no_stack_double = gi_cvar("g_dm_no_stack_double", "0", cvar_flags_t::NOFLAGS);
	@g_no_nukes = gi_cvar("g_no_nukes", "0", cvar_flags_t::NOFLAGS);
	@g_no_spheres = gi_cvar("g_no_spheres", "0", cvar_flags_t::NOFLAGS);
	@g_teamplay_force_join = gi_cvar("g_teamplay_force_join", "0", cvar_flags_t::NOFLAGS);
	@g_teamplay_armor_protect = gi_cvar("g_teamplay_armor_protect", "0", cvar_flags_t::NOFLAGS);
	@g_allow_techs = gi_cvar("g_allow_techs", "auto", cvar_flags_t::NOFLAGS);

	@g_start_items = gi_cvar("g_start_items", "", cvar_flags_t::LATCH);
	@g_map_list = gi_cvar("g_map_list", "", cvar_flags_t::NOFLAGS);
	@g_map_list_shuffle = gi_cvar("g_map_list_shuffle", "0", cvar_flags_t::NOFLAGS);
	@g_lag_compensation = gi_cvar("g_lag_compensation", "1", cvar_flags_t::NOFLAGS);

	// items
	InitItems();

    // initialize entities & clients
    SetupEntityArrays(false);
	
	// how far back we should support lag origins for
	game.max_lag_origins = uint(20 * (0.1f / gi_frame_time_s));
	game.lag_origins = array<vec3_t>(game.max_lag_origins);

    FRAME_TIME_MS = FRAME_TIME_S = time_ms(gi_frame_time_ms);

    DAMAGE_TIME_SLACK = time_ms(100) - FRAME_TIME_MS;
    DAMAGE_TIME = time_ms(500) + DAMAGE_TIME_SLACK;
    FALL_TIME = time_ms(300) + DAMAGE_TIME_SLACK;
}

void ShutdownGame()
{
	gi_Com_Print("==== ShutdownGame ====\n");

    @pm = null;
}

/*
=================
ClientEndServerFrames
=================
*/
void ClientEndServerFrames()
{
	// calc the player views now that all pushing
	// and damage has been added
	for (uint i = 0; i < max_clients; i++)
	{
		if (players[i].e.inuse)
    		ClientEndServerFrame(players[i]);
	}
}

/*
================
G_PrepFrame

This has to be done before the world logic, because
player processing happens outside RunFrame
================
*/
void PrepFrame()
{
	for (uint32 i = 0; i < num_edicts; i++)
    {
        if (i < max_clients)
    		players[i].e.client.ps.stats[player_stat_t::HIT_MARKER] = 0;

		entities[i].e.s.event = entity_event_t::NONE;
    }

    server_flags = server_flags_t(server_flags & ~server_flags_t::INTERMISSION);

	if ( level.intermissiontime ) {
		server_flags = server_flags_t(server_flags | server_flags_t::INTERMISSION);
	}
}
