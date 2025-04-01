const string CTF_VERSION_STRING = "1.52";

const string CTF_TEAM1_SKIN = "ctf_r";
const string CTF_TEAM2_SKIN = "ctf_b";

const int32 CTF_CAPTURE_BONUS = 15;	  // what you get for capture
const int32 CTF_TEAM_BONUS = 10;		  // what your team gets for capture
const int32 CTF_RECOVERY_BONUS = 1;	  // what you get for recovery
const int32 CTF_FLAG_BONUS = 0;		  // what you get for picking up enemy flag
const int32 CTF_FRAG_CARRIER_BONUS = 2; // what you get for fragging enemy flag carrier
const gtime_t CTF_FLAG_RETURN_TIME = time_sec(40);  // seconds until auto return

const int32 CTF_CARRIER_DANGER_PROTECT_BONUS = 2; // bonus for fraggin someone who has recently hurt your flag carrier
const int32 CTF_CARRIER_PROTECT_BONUS = 1;		// bonus for fraggin someone while either you or your target are near your flag carrier
const int32 CTF_FLAG_DEFENSE_BONUS = 1;			// bonus for fraggin someone while either you or your target are near your flag
const int32 CTF_RETURN_FLAG_ASSIST_BONUS = 1;		// awarded for returning a flag that causes a capture to happen almost immediately
const int32 CTF_FRAG_CARRIER_ASSIST_BONUS = 2;	// award for fragging a flag carrier if a capture happens almost immediately

const float CTF_TARGET_PROTECT_RADIUS = 400;   // the radius around an object being defended where a target will be worth extra frags
const float CTF_ATTACKER_PROTECT_RADIUS = 400; // the radius around an object being defended where an attacker will get extra frags when making kills

const gtime_t CTF_CARRIER_DANGER_PROTECT_TIMEOUT = time_sec(8);
const gtime_t CTF_FRAG_CARRIER_ASSIST_TIMEOUT = time_sec(10);
const gtime_t CTF_RETURN_FLAG_ASSIST_TIMEOUT = time_sec(10);

const gtime_t CTF_AUTO_FLAG_RETURN_TIMEOUT = time_sec(30); // number of seconds before dropped flag auto-returns

const gtime_t CTF_TECH_TIMEOUT = time_sec(60); // seconds before techs spawn again

const int32 CTF_DEFAULT_GRAPPLE_SPEED = 650;		// speed of grapple in flight
const float	CTF_DEFAULT_GRAPPLE_PULL_SPEED = 650; // speed player is pulled at

enum match_t
{
	NONE,
	SETUP,
	PREGAME,
	GAME,
	POST
};

enum elect_t
{
	NONE,
	MATCH,
	ADMIN,
	MAP
};

class ctfgame_t
{
	int		    team1, team2;
	int		    total1, total2; // these are only set when going into intermission except in teamplay
	gtime_t     last_flag_capture;
	ctfteam_t	last_capture_team;

	match_t match;	   // match state
	gtime_t matchtime; // time for match start/end (depends on state)
	int		lasttime;  // last time update, explicitly truncated to seconds
	bool	countdown; // has audio countdown started?

	elect_t	  election;	 // election type
	ASEntity  @etarget;	 // for admin election, who's being elected
	string    elevel;     // for map election, target level
	int		  evotes;	 // votes so far
	int		  needvotes;	 // votes needed
	gtime_t	  electtime;	 // remaining time until election times out
	string    emsg;  	 // election name
	ctfteam_t warnactive; // true if stat string 30 is active

    array<ghost_t> ghosts;
};

ctfgame_t ctfgame;

cvar_t @ctf;
cvar_t @g_teamplay_force_join;
cvar_t @teamplay;

// [Paril-KEX]
bool G_TeamplayEnabled()
{
    return ctf.integer != 0 || teamplay.integer != 0;
}

// [Paril-KEX]
void G_AdjustTeamScore(ctfteam_t team, int32 offset)
{
	if (team == ctfteam_t::TEAM1)
		ctfgame.total1 += offset;
	else if (team == ctfteam_t::TEAM2)
		ctfgame.total2 += offset;
}

cvar_t @competition;
cvar_t @matchlock;
cvar_t @electpercentage;
cvar_t @matchtime;
cvar_t @matchsetuptime;
cvar_t @matchstarttime;
cvar_t @admin_password;
cvar_t @allow_admin;
cvar_t @warp_list;
cvar_t @warn_unbalanced;

// Index for various CTF pics, this saves us from calling gi.imageindex
// all the time and saves a few CPU cycles since we don't have to do
// a bunch of string compares all the time.
// These are set in CTFPrecache() called from worldspawn
int imageindex_i_ctf1;
int imageindex_i_ctf2;
int imageindex_i_ctf1d;
int imageindex_i_ctf2d;
int imageindex_i_ctf1t;
int imageindex_i_ctf2t;
int imageindex_i_ctfj;
int imageindex_sbfctf1;
int imageindex_sbfctf2;
int imageindex_ctfsb1;
int imageindex_ctfsb2;
int modelindex_flag1, modelindex_flag2; // [Paril-KEX]

const array<item_id_t> tech_ids = { item_id_t::TECH_RESISTANCE, item_id_t::TECH_STRENGTH, item_id_t::TECH_HASTE, item_id_t::TECH_REGENERATION };

/*------------------------------------------------------------------------*/

// AS_TODO a proper bounds type might be a better idea
array<vec3_t> loc_buildboxpoints(const vec3_t &in org, const vec3_t &in mins, const vec3_t &in maxs)
{
    vec3_t p0 = org + mins;
    vec3_t p4 = org + maxs;

    return {
        p0,
        vec3_t(p0[0] - mins[0], p0[1], p0[2]),
        vec3_t(p0[0], p0[1] - mins[1], p0[2]),
        vec3_t(p0[0] - mins[0], p0[1] - mins[1], p0[2]),
        p4,
        vec3_t(p4[0] - maxs[0], p4[1], p4[2]),
        vec3_t(p4[0], p4[1] - maxs[1], p4[2]),
        vec3_t(p4[0] - maxs[0], p4[1] - maxs[1], p4[2])
    };
}

bool loc_CanSee(ASEntity @targ, ASEntity @inflictor)
{
	trace_t trace;
	int		i;
	vec3_t	viewpoint;

	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == movetype_t::PUSH)
		return false; // bmodels not supported

	viewpoint = inflictor.e.origin;
	viewpoint[2] += inflictor.viewheight;

    array<vec3_t> targpoints = loc_buildboxpoints(targ.e.origin, targ.e.mins, targ.e.maxs);

	for (i = 0; i < 8; i++)
	{
		trace = gi_traceline(viewpoint, targpoints[i], inflictor.e, contents_t::MASK_SOLID);
		if (trace.fraction == 1.0f)
			return true;
	}

	return false;
}

/*--------------------------------------------------------------------------*/

void CTFSpawn()
{
    ctfgame = ctfgame_t();
	CTFSetupTechSpawn();

	if (competition.integer > 1)
	{
		ctfgame.match = match_t::SETUP;
		ctfgame.matchtime = level.time + time_min(matchsetuptime.value);
	}
}

void CTFInit()
{
	@ctf = gi_cvar("ctf", "0", cvar_flags_t(cvar_flags_t::SERVERINFO | cvar_flags_t::LATCH));
	@competition = gi_cvar("competition", "0", cvar_flags_t::SERVERINFO);
	@matchlock = gi_cvar("matchlock", "1", cvar_flags_t::SERVERINFO);
	@electpercentage = gi_cvar("electpercentage", "66", cvar_flags_t::NOFLAGS);
	@matchtime = gi_cvar("matchtime", "20", cvar_flags_t::SERVERINFO);
	@matchsetuptime = gi_cvar("matchsetuptime", "10", cvar_flags_t::NOFLAGS);
	@matchstarttime = gi_cvar("matchstarttime", "20", cvar_flags_t::NOFLAGS);
	@admin_password = gi_cvar("admin_password", "", cvar_flags_t::NOFLAGS);
	@allow_admin = gi_cvar("allow_admin", "1", cvar_flags_t::NOFLAGS);
	@warp_list = gi_cvar("warp_list", "q2ctf1 q2ctf2 q2ctf3 q2ctf4 q2ctf5", cvar_flags_t::NOFLAGS);
	@warn_unbalanced = gi_cvar("warn_unbalanced", "0", cvar_flags_t::NOFLAGS);
}

/*
 * Precache CTF items
 */

void CTFPrecache()
{
	imageindex_i_ctf1 = gi_imageindex("i_ctf1");
	imageindex_i_ctf2 = gi_imageindex("i_ctf2");
	imageindex_i_ctf1d = gi_imageindex("i_ctf1d");
	imageindex_i_ctf2d = gi_imageindex("i_ctf2d");
	imageindex_i_ctf1t = gi_imageindex("i_ctf1t");
	imageindex_i_ctf2t = gi_imageindex("i_ctf2t");
	imageindex_i_ctfj = gi_imageindex("i_ctfj");
	imageindex_sbfctf1 = gi_imageindex("sbfctf1");
	imageindex_sbfctf2 = gi_imageindex("sbfctf2");
	imageindex_ctfsb1 = gi_imageindex("tag4");
	imageindex_ctfsb2 = gi_imageindex("tag5");
	modelindex_flag1 = gi_modelindex("players/male/flag1.md2");
	modelindex_flag2 = gi_modelindex("players/male/flag2.md2");

	PrecacheItem(GetItemByIndex(item_id_t::WEAPON_GRAPPLE));

    ctfgame.ghosts.resize(max_clients);
}

/*--------------------------------------------------------------------------*/

string CTFTeamName(ctfteam_t team)
{
	switch (team)
	{
	case ctfteam_t::NOTEAM:
		return "SPECTATOR";
	case ctfteam_t::TEAM1:
		return "RED";
	case ctfteam_t::TEAM2:
		return "BLUE";
	}
	return "UNKNOWN"; // Hanzo pointed out this was spelled wrong as "UKNOWN"
}

string CTFOtherTeamName(int team)
{
	switch (team)
	{
	case ctfteam_t::TEAM1:
		return "BLUE";
	case ctfteam_t::TEAM2:
		return "RED";
	}
	return "UNKNOWN"; // Hanzo pointed out this was spelled wrong as "UKNOWN"
}

ctfteam_t CTFOtherTeam(ctfteam_t team)
{
	switch (team)
	{
	case ctfteam_t::TEAM1:
		return ctfteam_t::TEAM2;
	case ctfteam_t::TEAM2:
		return ctfteam_t::TEAM1;
	}
	return ctfteam_t::INVALID; // invalid value
}

void CTFAssignSkin(ASEntity &ent, const string &in s)
{
	int	  playernum = ent.e.number - 1;
    string t;

    {
        int i = s.findFirstOf("/");

        if (i != -1)
            t = s.substr(0, i + 1);
        else
            t = "male/";
    }

	switch (ent.client.resp.ctf_team)
	{
	case ctfteam_t::TEAM1:
		t = format("{}\\{}{}\\default", ent.client.pers.netname, t, CTF_TEAM1_SKIN);
		break;
	case ctfteam_t::TEAM2:
		t = format("{}\\{}{}\\default", ent.client.pers.netname, t, CTF_TEAM2_SKIN);
		break;
	default:
		t = format("{}\\{}\\default", ent.client.pers.netname, s);
		break;
	}

	gi_configstring(configstring_id_t::PLAYERSKINS + playernum, t);
}

void CTFAssignTeam(ASEntity &who)
{
	ASEntity @player;
	uint32 team1count = 0, team2count = 0;

	who.client.resp.ctf_state = 0;

	if (g_teamplay_force_join.integer == 0 && (who.e.svflags & svflags_t::BOT) == 0)
	{
		who.client.resp.ctf_team = ctfteam_t::NOTEAM;
		return;
	}

	for (uint32 i = 1; i <= max_clients; i++)
	{
		@player = entities[i];

		if (!player.e.inuse || player is who)
			continue;

		switch (player.client.resp.ctf_team)
		{
		case ctfteam_t::TEAM1:
			team1count++;
			break;
		case ctfteam_t::TEAM2:
			team2count++;
			break;
		default:
			break;
		}
	}
	if (team1count < team2count)
		who.client.resp.ctf_team = ctfteam_t::TEAM1;
	else if (team2count < team1count)
		who.client.resp.ctf_team = ctfteam_t::TEAM2;
	else if (brandom())
		who.client.resp.ctf_team = ctfteam_t::TEAM1;
	else
		who.client.resp.ctf_team = ctfteam_t::TEAM2;
}

/*
================
SelectCTFSpawnPoint

go to a ctf point, but NOT the two points closest
to other players
================
*/
ASEntity @SelectCTFSpawnPoint(ASEntity &ent, bool force_spawn)
{
	if (ent.client.resp.ctf_state != 0)
	{
		select_spawn_result_t result = SelectDeathmatchSpawnPoint(g_dm_spawn_farthest.integer != 0, force_spawn, false);

		if (result.any_valid)
			return result.spot;
	}

	string cname;

	switch (ent.client.resp.ctf_team)
	{
	case ctfteam_t::TEAM1:
		cname = "info_player_team1";
		break;
	case ctfteam_t::TEAM2:
		cname = "info_player_team2";
		break;
	default:
	{
		select_spawn_result_t result = SelectDeathmatchSpawnPoint(g_dm_spawn_farthest.integer != 0, force_spawn, true);

		if (result.any_valid)
			return result.spot;

		gi_Com_Error("can't find suitable spectator spawn point");
		return null;
	}
	}

	array<ASEntity @> spawn_points;
	ASEntity @spot = null;

	while ((@spot = find_by_str<ASEntity>(spot, "classname", cname)) !is null)
		spawn_points.push_back(spot);

	if (spawn_points.empty())
	{
		select_spawn_result_t result = SelectDeathmatchSpawnPoint(g_dm_spawn_farthest.integer != 0, force_spawn, true);

		if (!result.any_valid)
			gi_Com_Error("can't find suitable CTF spawn point");

		return result.spot;
	}

    spawn_points.shuffle();

	foreach (ASEntity @point : spawn_points)
		if (SpawnPointClear(point))
			return point;
	
	if (force_spawn)
		return spawn_points[irandom(spawn_points.length())];

	return null;
}

/*------------------------------------------------------------------------*/
/*
CTFFragBonuses

Calculate the bonuses for flag defense, flag carrier defense, etc.
Note that bonuses are not cumaltive.  You get one, they are in importance
order.
*/
void CTFFragBonuses(ASEntity &targ, ASEntity &inflictor, ASEntity &attacker)
{
	ASEntity    @ent;
	item_id_t	flag_item, enemy_flag_item;
	ctfteam_t	otherteam;
	ASEntity    @flag, carrier = null;
	string      c;
	vec3_t		v1, v2;

	if (targ.client !is null && attacker.client !is null)
	{
		if (attacker.client.resp.ghost !is null)
			if (attacker !is targ)
				attacker.client.resp.ghost.kills++;
		if (targ.client.resp.ghost !is null)
			targ.client.resp.ghost.deaths++;
	}

	// no bonus for fragging yourself
	if (targ.client is null || attacker.client is null || targ is attacker)
		return;

	otherteam = CTFOtherTeam(targ.client.resp.ctf_team);
	if (otherteam < 0)
		return; // whoever died isn't on a team

	// same team, if the flag at base, check to he has the enemy flag
	if (targ.client.resp.ctf_team == ctfteam_t::TEAM1)
	{
		flag_item = item_id_t::FLAG1;
		enemy_flag_item = item_id_t::FLAG2;
	}
	else
	{
		flag_item = item_id_t::FLAG2;
		enemy_flag_item = item_id_t::FLAG1;
	}

	// did the attacker frag the flag carrier?
	if (targ.client.pers.inventory[enemy_flag_item] != 0)
	{
		attacker.client.resp.ctf_lastfraggedcarrier = level.time;
		attacker.client.resp.score += CTF_FRAG_CARRIER_BONUS;
		gi_LocClient_Print(attacker.e, print_type_t::MEDIUM, "$g_bonus_enemy_carrier",
				   formatInt(CTF_FRAG_CARRIER_BONUS));

		// the target had the flag, clear the hurt carrier
		// field on the other team
		for (uint i = 1; i <= max_clients; i++)
		{
			@ent = entities[i];
			if (ent.e.inuse && ent.client.resp.ctf_team == otherteam)
				ent.client.resp.ctf_lasthurtcarrier = time_zero;
		}
		return;
	}

	if (targ.client.resp.ctf_lasthurtcarrier &&
		level.time - targ.client.resp.ctf_lasthurtcarrier < CTF_CARRIER_DANGER_PROTECT_TIMEOUT &&
		attacker.client.pers.inventory[flag_item] == 0)
	{
		// attacker is on the same team as the flag carrier and
		// fragged a guy who hurt our flag carrier
		attacker.client.resp.score += CTF_CARRIER_DANGER_PROTECT_BONUS;
		gi_LocBroadcast_Print(print_type_t::MEDIUM, "$g_bonus_flag_defense",
				   attacker.client.pers.netname,
				   CTFTeamName(attacker.client.resp.ctf_team));
		if (attacker.client.resp.ghost !is null)
			attacker.client.resp.ghost.carrierdef++;
		return;
	}

	// flag and flag carrier area defense bonuses

	// we have to find the flag and carrier entities

	// find the flag
	switch (attacker.client.resp.ctf_team)
	{
	case ctfteam_t::TEAM1:
		c = "item_flag_team1";
		break;
	case ctfteam_t::TEAM2:
		c = "item_flag_team2";
		break;
	default:
		return;
	}

	@flag = null;
	while ((@flag = find_by_str<ASEntity>(flag, "classname", c)) !is null)
	{
		if ((flag.spawnflags & spawnflags::item::DROPPED) == 0)
			break;
	}

	if (flag is null)
		return; // can't find attacker's flag

	// find attacker's team's flag carrier
	for (uint32 i = 1; i <= max_clients; i++)
	{
		@carrier = entities[i];
		if (carrier.e.inuse &&
			carrier.client.pers.inventory[flag_item] != 0)
			break;
		@carrier = null;
	}

	// ok we have the attackers flag and a pointer to the carrier

	// check to see if we are defending the base's flag
	v1 = targ.e.origin - flag.e.origin;
	v2 = attacker.e.origin - flag.e.origin;

	if ((v1.length() < CTF_TARGET_PROTECT_RADIUS ||
		 v2.length() < CTF_TARGET_PROTECT_RADIUS ||
		 loc_CanSee(flag, targ) || loc_CanSee(flag, attacker)) &&
		attacker.client.resp.ctf_team != targ.client.resp.ctf_team)
	{
		// we defended the base flag
		attacker.client.resp.score += CTF_FLAG_DEFENSE_BONUS;
		if (flag.e.solid == solid_t::NOT)
			gi_LocBroadcast_Print(print_type_t::MEDIUM, "$g_bonus_defend_base",
					   attacker.client.pers.netname,
					   CTFTeamName(attacker.client.resp.ctf_team));
		else
			gi_LocBroadcast_Print(print_type_t::MEDIUM, "$g_bonus_defend_flag",
					   attacker.client.pers.netname,
					   CTFTeamName(attacker.client.resp.ctf_team));
		if (attacker.client.resp.ghost !is null)
			attacker.client.resp.ghost.basedef++;
		return;
	}

	if (carrier !is null && carrier !is attacker)
	{
		v1 = targ.e.origin - carrier.e.origin;
		v2 = attacker.e.origin - carrier.e.origin;

		if (v1.length() < CTF_ATTACKER_PROTECT_RADIUS ||
			v2.length() < CTF_ATTACKER_PROTECT_RADIUS ||
			loc_CanSee(carrier, targ) || loc_CanSee(carrier, attacker))
		{
			attacker.client.resp.score += CTF_CARRIER_PROTECT_BONUS;
			gi_LocBroadcast_Print(print_type_t::MEDIUM, "$g_bonus_defend_carrier",
					   attacker.client.pers.netname,
					   CTFTeamName(attacker.client.resp.ctf_team));
			if (attacker.client.resp.ghost !is null)
				attacker.client.resp.ghost.carrierdef++;
			return;
		}
	}
}

void CTFCheckHurtCarrier(ASEntity &targ, ASEntity &attacker)
{
	item_id_t flag_item;

	if (targ.client is null || attacker.client is null)
		return;

	if (targ.client.resp.ctf_team == ctfteam_t::TEAM1)
		flag_item = item_id_t::FLAG2;
	else
		flag_item = item_id_t::FLAG1;

	if (targ.client.pers.inventory[flag_item] != 0 &&
		targ.client.resp.ctf_team != attacker.client.resp.ctf_team)
		attacker.client.resp.ctf_lasthurtcarrier = level.time;
}

/*------------------------------------------------------------------------*/

void CTFResetFlag(ctfteam_t ctf_team)
{
	string c;
	ASEntity @ent;

	switch (ctf_team)
	{
	case ctfteam_t::TEAM1:
		c = "item_flag_team1";
		break;
	case ctfteam_t::TEAM2:
		c = "item_flag_team2";
		break;
	default:
		return;
	}

	@ent = null;
	while ((@ent = find_by_str<ASEntity>(ent, "classname", c)) !is null)
	{
		if ((ent.spawnflags & spawnflags::item::DROPPED) != 0)
			G_FreeEdict(ent);
		else
		{
			ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::NOCLIENT);
			ent.e.solid = solid_t::TRIGGER;
			gi_linkentity(ent.e);
			ent.e.event = entity_event_t::ITEM_RESPAWN;
		}
	}
}

void CTFResetFlags()
{
	CTFResetFlag(ctfteam_t::TEAM1);
	CTFResetFlag(ctfteam_t::TEAM2);
}

bool CTFPickup_Flag(ASEntity &ent, ASEntity &other)
{
	ctfteam_t ctf_team;
	ASEntity  @player;
	item_id_t flag_item, enemy_flag_item;

	// figure out what team this flag is
	if (ent.item.id == item_id_t::FLAG1)
		ctf_team = ctfteam_t::TEAM1;
	else if (ent.item.id == item_id_t::FLAG2)
		ctf_team = ctfteam_t::TEAM2;
	else
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Don't know what team the flag is on.\n");
		return false;
	}

	// same team, if the flag at base, check to he has the enemy flag
	if (ctf_team == ctfteam_t::TEAM1)
	{
		flag_item = item_id_t::FLAG1;
		enemy_flag_item = item_id_t::FLAG2;
	}
	else
	{
		flag_item = item_id_t::FLAG2;
		enemy_flag_item = item_id_t::FLAG1;
	}

	if (ctf_team == other.client.resp.ctf_team)
	{
		if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
		{
			// the flag is at home base.  if the player has the enemy
			// flag, he's just won!

			if (other.client.pers.inventory[enemy_flag_item] != 0)
			{
				gi_LocBroadcast_Print(print_type_t::HIGH, "$g_flag_captured",
						   other.client.pers.netname, CTFOtherTeamName(ctf_team));
				other.client.pers.inventory[enemy_flag_item] = 0;

				ctfgame.last_flag_capture = level.time;
				ctfgame.last_capture_team = ctf_team;
				if (ctf_team == ctfteam_t::TEAM1)
					ctfgame.team1++;
				else
					ctfgame.team2++;

				gi_sound(ent.e, soundchan_t(soundchan_t::RELIABLE | soundchan_t::NO_PHS_ADD | soundchan_t::AUX), gi_soundindex("ctf/flagcap.wav"), 1, ATTN_NONE, 0);

				// other gets another 10 frag bonus
				other.client.resp.score += CTF_CAPTURE_BONUS;
				if (other.client.resp.ghost !is null)
					other.client.resp.ghost.caps++;

				// Ok, let's do the player loop, hand out the bonuses
				for (uint32 i = 1; i <= max_clients; i++)
				{
					@player = entities[i];
					if (!player.e.inuse)
						continue;

					if (player.client.resp.ctf_team != other.client.resp.ctf_team)
						player.client.resp.ctf_lasthurtcarrier = time_sec(-5);
					else if (player.client.resp.ctf_team == other.client.resp.ctf_team)
					{
						if (player !is other)
							player.client.resp.score += CTF_TEAM_BONUS;
						// award extra points for capture assists
						if (player.client.resp.ctf_lastreturnedflag && player.client.resp.ctf_lastreturnedflag + CTF_RETURN_FLAG_ASSIST_TIMEOUT > level.time)
						{
							gi_LocBroadcast_Print(print_type_t::HIGH, "$g_bonus_assist_return", player.client.pers.netname);
							player.client.resp.score += CTF_RETURN_FLAG_ASSIST_BONUS;
						}
						if (player.client.resp.ctf_lastfraggedcarrier && player.client.resp.ctf_lastfraggedcarrier + CTF_FRAG_CARRIER_ASSIST_TIMEOUT > level.time)
						{
							gi_LocBroadcast_Print(print_type_t::HIGH, "$g_bonus_assist_frag_carrier", player.client.pers.netname);
							player.client.resp.score += CTF_FRAG_CARRIER_ASSIST_BONUS;
						}
					}
				}

				CTFResetFlags();
				return false;
			}
			return false; // its at home base already
		}
		// hey, its not home.  return it by teleporting it back
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_returned_flag",
				   other.client.pers.netname, CTFTeamName(ctf_team));
		other.client.resp.score += CTF_RECOVERY_BONUS;
		other.client.resp.ctf_lastreturnedflag = level.time;
		gi_sound(ent.e, soundchan_t(soundchan_t::RELIABLE | soundchan_t::NO_PHS_ADD | soundchan_t::AUX), gi_soundindex("ctf/flagret.wav"), 1, ATTN_NONE, 0);
		// CTFResetFlag will remove this entity!  We must return false
		CTFResetFlag(ctf_team);
		return false;
	}

	// hey, its not our flag, pick it up
	gi_LocBroadcast_Print(print_type_t::HIGH, "$g_got_flag",
			   other.client.pers.netname, CTFTeamName(ctf_team));
	other.client.resp.score += CTF_FLAG_BONUS;

	other.client.pers.inventory[flag_item] = 1;
	other.client.resp.ctf_flagsince = level.time;

	// pick up the flag
	// if it's not a dropped flag, we just make is disappear
	// if it's dropped, it will be removed by the pickup caller
	if ((ent.spawnflags & spawnflags::item::DROPPED) == 0)
	{
		ent.flags = ent_flags_t(ent.flags | ent_flags_t::RESPAWN);
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.e.solid = solid_t::NOT;
	}
	return true;
}

void CTFDropFlagTouch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	// owner (who dropped us) can't touch for two secs
	if (other is ent.owner &&
		ent.nextthink - level.time > CTF_AUTO_FLAG_RETURN_TIMEOUT - time_sec(2))
		return;

	Touch_Item(ent, other, tr, other_touching_self);
}

void CTFDropFlagThink(ASEntity &ent)
{
	// auto return the flag
	// reset flag will remove ourselves
	if (ent.item.id == item_id_t::FLAG1)
	{
		CTFResetFlag(ctfteam_t::TEAM1);
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_flag_returned",
				   CTFTeamName(ctfteam_t::TEAM1));
	}
	else if (ent.item.id == item_id_t::FLAG2)
	{
		CTFResetFlag(ctfteam_t::TEAM2);
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_flag_returned",
				   CTFTeamName(ctfteam_t::TEAM2));
	}

	gi_sound(ent.e, soundchan_t(soundchan_t::RELIABLE | soundchan_t::NO_PHS_ADD | soundchan_t::AUX), gi_soundindex("ctf/flagret.wav"), 1, ATTN_NONE, 0);
}

// Called from PlayerDie, to drop the flag from a dying player
void CTFDeadDropFlag(ASEntity &self)
{
	ASEntity @dropped = null;

	if (self.client.pers.inventory[item_id_t::FLAG1] != 0)
	{
		@dropped = Drop_Item(self, GetItemByIndex(item_id_t::FLAG1));
		self.client.pers.inventory[item_id_t::FLAG1] = 0;
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_lost_flag",
				   self.client.pers.netname, CTFTeamName(ctfteam_t::TEAM1));
	}
	else if (self.client.pers.inventory[item_id_t::FLAG2] != 0)
	{
		@dropped = Drop_Item(self, GetItemByIndex(item_id_t::FLAG2));
		self.client.pers.inventory[item_id_t::FLAG2] = 0;
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_lost_flag",
				   self.client.pers.netname, CTFTeamName(ctfteam_t::TEAM2));
	}

	if (dropped !is null)
	{
		@dropped.think = CTFDropFlagThink;
		dropped.nextthink = level.time + CTF_AUTO_FLAG_RETURN_TIMEOUT;
		@dropped.touch = CTFDropFlagTouch;
	}
}

void CTFDrop_Flag(ASEntity &ent, const gitem_t &item)
{
	if (brandom())
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_lusers_drop_flags");
	else
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_winners_drop_flags");
}

void CTFFlagThink(ASEntity &ent)
{
	if (ent.e.solid != solid_t::NOT)
		ent.e.frame = 173 + (((ent.e.frame - 173) + 1) % 16);
	ent.nextthink = level.time + time_hz(10);
}

void CTFFlagSetup(ASEntity &ent)
{
	trace_t tr;
	vec3_t	dest;

	ent.e.mins = { -15, -15, -15 };
	ent.e.maxs = { 15, 15, 15 };

	if (!ent.model.empty())
		gi_setmodel(ent.e, ent.model);
	else
		gi_setmodel(ent.e, ent.item.world_model);
	ent.e.solid = solid_t::TRIGGER;
	ent.movetype = movetype_t::TOSS;
	@ent.touch = Touch_Item;
	ent.e.frame = 173;

	dest = ent.e.origin + vec3_t(0, 0, -128);

	tr = gi_trace(ent.e.origin, ent.e.mins, ent.e.maxs, dest, ent.e, contents_t::MASK_SOLID);
	if (tr.startsolid)
	{
		gi_Com_Print("CTFFlagSetup: {} startsolid at {}\n", ent, ent.e.origin);
		G_FreeEdict(ent);
		return;
	}

	ent.e.origin = tr.endpos;

	gi_linkentity(ent.e);

	ent.nextthink = level.time + time_hz(10);
	@ent.think = CTFFlagThink;
}

void CTFEffects(ASEntity &player)
{
	player.e.effects = effects_t(player.e.effects & ~(effects_t::FLAG1 | effects_t::FLAG2));
	if (player.health > 0)
	{
		if (player.client.pers.inventory[item_id_t::FLAG1] != 0)
		{
			player.e.effects = effects_t(player.e.effects | effects_t::FLAG1);
		}
		if (player.client.pers.inventory[item_id_t::FLAG2] != 0)
		{
			player.e.effects = effects_t(player.e.effects | effects_t::FLAG2);
		}
	}

	if (player.client.pers.inventory[item_id_t::FLAG1] != 0)
		player.e.modelindex3 = modelindex_flag1;
	else if (player.client.pers.inventory[item_id_t::FLAG2] != 0)
		player.e.modelindex3 = modelindex_flag2;
	else
		player.e.modelindex3 = 0;
}

// called when we enter the intermission
void CTFCalcScores()
{
	ctfgame.total1 = ctfgame.total2 = 0;
	for (uint32 i = 0; i < max_clients; i++)
	{
        ASEntity @cl = players[i];
		if (!cl.e.inuse)
			continue;
		if (cl.client.resp.ctf_team == ctfteam_t::TEAM1)
			ctfgame.total1 += cl.client.resp.score;
		else if (cl.client.resp.ctf_team == ctfteam_t::TEAM2)
			ctfgame.total2 += cl.client.resp.score;
	}
}

void CheckEndTDMLevel()
{
	if (ctfgame.total1 >= fraglimit.integer || ctfgame.total2 >= fraglimit.integer)
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_fraglimit_hit");
		EndDMLevel();
	}
}

void CTFID_f(ASEntity &ent)
{
	if (ent.client.resp.id_state)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Disabling player identication display.\n");
		ent.client.resp.id_state = false;
	}
	else
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Activating player identication display.\n");
		ent.client.resp.id_state = true;
	}
}

void CTFSetIDView(ASEntity &ent)
{
	vec3_t	 forward, dir;
	trace_t	 tr;
	ASEntity @who, best;
	float	 bd = 0, d;

	// only check every few frames
	if (level.time - ent.client.resp.lastidtime < time_ms(250))
		return;
	ent.client.resp.lastidtime = level.time;

	ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW] = 0;
	ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = 0;

	AngleVectors(ent.client.v_angle, forward);
	forward *= 1024;
	forward = ent.e.origin + forward;
	tr = gi_traceline(ent.e.origin, forward, ent.e, contents_t::MASK_SOLID);
	if (tr.fraction < 1 && tr.ent !is null && tr.ent.client !is null)
	{
        ASEntity @hit = entities[tr.ent.number];
		ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW] = tr.ent.number;
		if (hit.client.resp.ctf_team == ctfteam_t::TEAM1)
			ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = imageindex_sbfctf1;
		else if (hit.client.resp.ctf_team == ctfteam_t::TEAM2)
			ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = imageindex_sbfctf2;
		return;
	}

	AngleVectors(ent.client.v_angle, forward);
	@best = null;
	for (uint32 i = 1; i <= max_clients; i++)
	{
		@who = entities[i];
		if (!who.e.inuse || who.e.solid == solid_t::NOT)
			continue;
		dir = who.e.origin - ent.e.origin;
		dir.normalize();
		d = forward.dot(dir);

		// we have teammate indicators that are better for this
		if (ent.client.resp.ctf_team == who.client.resp.ctf_team)
			continue;

		if (d > bd && loc_CanSee(ent, who))
		{
			bd = d;
			@best = who;
		}
	}
	if (bd > 0.90f)
	{
		ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW] = best.e.number;
		if (best.client.resp.ctf_team == ctfteam_t::TEAM1)
			ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = imageindex_sbfctf1;
		else if (best.client.resp.ctf_team == ctfteam_t::TEAM2)
			ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = imageindex_sbfctf2;
	}
}


void SetCTFStats(ASEntity &ent)
{
	uint32   i;
	int		 p1, p2;
	ASEntity @e;

	if (ctfgame.match > match_t::NONE)
		ent.e.client.ps.stats[player_stat_t::CTF_MATCH] = game_configstring_id_t::CTF_MATCH;
	else
		ent.e.client.ps.stats[player_stat_t::CTF_MATCH] = 0;

	if (ctfgame.warnactive != ctfteam_t::NOTEAM)
		ent.e.client.ps.stats[player_stat_t::CTF_TEAMINFO] = game_configstring_id_t::CTF_TEAMINFO;
	else
		ent.e.client.ps.stats[player_stat_t::CTF_TEAMINFO] = 0;

	// ghosting
	if (ent.client.resp.ghost !is null)
	{
		ent.client.resp.ghost.score = ent.client.resp.score;
		ent.client.resp.ghost.netname = ent.client.pers.netname;
		ent.client.resp.ghost.number = ent.e.number;
	}

	// logo headers for the frag display
	ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_HEADER] = imageindex_ctfsb1;
	ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_HEADER] = imageindex_ctfsb2;

	bool blink = (level.time.milliseconds % 1000) < 500;

	// if during intermission, we must blink the team header of the winning team
	if (level.intermissiontime && blink)
	{
		// blink half second
		// note that ctfgame.total[12] is set when we go to intermission
		if (ctfgame.team1 > ctfgame.team2)
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_HEADER] = 0;
		else if (ctfgame.team2 > ctfgame.team1)
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_HEADER] = 0;
		else if (ctfgame.total1 > ctfgame.total2) // frag tie breaker
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_HEADER] = 0;
		else if (ctfgame.total2 > ctfgame.total1)
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_HEADER] = 0;
		else
		{ // tie game!
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_HEADER] = 0;
			ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_HEADER] = 0;
		}
	}

	// tech icon
	i = 0;
	ent.e.client.ps.stats[player_stat_t::CTF_TECH] = 0;

	foreach (item_id_t tech : @tech_ids)
	{
		if (ent.client.pers.inventory[tech] != 0)
		{
			ent.e.client.ps.stats[player_stat_t::CTF_TECH] = gi_imageindex(GetItemByIndex(tech).icon);
			break;
		}
	}

	if (ctf.integer != 0)
	{
		// figure out what icon to display for team logos
		// three states:
		//   flag at base
		//   flag taken
		//   flag dropped
		p1 = imageindex_i_ctf1;
		@e = find_by_str<ASEntity>(null, "classname", "item_flag_team1");
		if (e !is null)
		{
			if (e.e.solid == solid_t::NOT)
			{
				// not at base
				// check if on player
				p1 = imageindex_i_ctf1d; // default to dropped
				for (i = 1; i <= max_clients; i++)
					if (entities[i].e.inuse &&
						entities[i].client.pers.inventory[item_id_t::FLAG1] != 0)
					{
						// enemy has it
						p1 = imageindex_i_ctf1t;
						break;
					}

				// [Paril-KEX] make sure there is a dropped version on the map somewhere
				if (p1 == imageindex_i_ctf1d)
				{
					@e = find_by_str<ASEntity>(e, "classname", "item_flag_team1");

					if (e is null)
					{
						CTFResetFlag(ctfteam_t::TEAM1);
						gi_LocBroadcast_Print(print_type_t::HIGH, "$g_flag_returned",
							CTFTeamName(ctfteam_t::TEAM1));
						gi_sound(ent.e, soundchan_t(soundchan_t::RELIABLE | soundchan_t::NO_PHS_ADD | soundchan_t::AUX), gi_soundindex("ctf/flagret.wav"), 1, ATTN_NONE, 0);
					}
				}
			}
			else if ((e.spawnflags & spawnflags::item::DROPPED) != 0)
				p1 = imageindex_i_ctf1d; // must be dropped
		}
		p2 = imageindex_i_ctf2;
		@e = find_by_str<ASEntity>(null, "classname", "item_flag_team2");
		if (e !is null)
		{
			if (e.e.solid == solid_t::NOT)
			{
				// not at base
				// check if on player
				p2 = imageindex_i_ctf2d; // default to dropped
				for (i = 1; i <= max_clients; i++)
					if (entities[i].e.inuse &&
						entities[i].client.pers.inventory[item_id_t::FLAG2] != 0)
					{
						// enemy has it
						p2 = imageindex_i_ctf2t;
						break;
					}

				// [Paril-KEX] make sure there is a dropped version on the map somewhere
				if (p2 == imageindex_i_ctf2d)
				{
					@e = find_by_str<ASEntity>(e, "classname", "item_flag_team2");

					if (e is null)
					{
						CTFResetFlag(ctfteam_t::TEAM2);
						gi_LocBroadcast_Print(print_type_t::HIGH, "$g_flag_returned",
							CTFTeamName(ctfteam_t::TEAM2));
						gi_sound(ent.e, soundchan_t(soundchan_t::RELIABLE | soundchan_t::NO_PHS_ADD | soundchan_t::AUX), gi_soundindex("ctf/flagret.wav"), 1, ATTN_NONE, 0);
					}
				}
			}
			else if ((e.spawnflags & spawnflags::item::DROPPED) != 0)
				p2 = imageindex_i_ctf2d; // must be dropped
		}

		ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_PIC] = p1;
		ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_PIC] = p2;

		if (ctfgame.last_flag_capture && level.time - ctfgame.last_flag_capture < time_sec(5))
		{
			if (ctfgame.last_capture_team == ctfteam_t::TEAM1)
			{
				if (blink)
					ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_PIC] = p1;
				else
					ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_PIC] = 0;
			}
			else if (blink)
				ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_PIC] = p2;
			else
				ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_PIC] = 0;
		}

		ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_CAPS] = ctfgame.team1;
		ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_CAPS] = ctfgame.team2;

		ent.e.client.ps.stats[player_stat_t::CTF_FLAG_PIC] = 0;
		if (ent.client.resp.ctf_team == ctfteam_t::TEAM1 &&
			ent.client.pers.inventory[item_id_t::FLAG2] != 0 &&
			blink)
			ent.e.client.ps.stats[player_stat_t::CTF_FLAG_PIC] = imageindex_i_ctf2;

		else if (ent.client.resp.ctf_team == ctfteam_t::TEAM2 &&
				 ent.client.pers.inventory[item_id_t::FLAG1] != 0 &&
				 blink)
			ent.e.client.ps.stats[player_stat_t::CTF_FLAG_PIC] = imageindex_i_ctf1;
	}
	else
	{
		ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_PIC] = imageindex_i_ctf1;
		ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_PIC] = imageindex_i_ctf2;

		ent.e.client.ps.stats[player_stat_t::CTF_TEAM1_CAPS] = ctfgame.total1;
		ent.e.client.ps.stats[player_stat_t::CTF_TEAM2_CAPS] = ctfgame.total2;
	}

	ent.e.client.ps.stats[player_stat_t::CTF_JOINED_TEAM1_PIC] = 0;
	ent.e.client.ps.stats[player_stat_t::CTF_JOINED_TEAM2_PIC] = 0;
	if (ent.client.resp.ctf_team == ctfteam_t::TEAM1)
		ent.e.client.ps.stats[player_stat_t::CTF_JOINED_TEAM1_PIC] = imageindex_i_ctfj;
	else if (ent.client.resp.ctf_team == ctfteam_t::TEAM2)
		ent.e.client.ps.stats[player_stat_t::CTF_JOINED_TEAM2_PIC] = imageindex_i_ctfj;

	if (ent.client.resp.id_state)
		CTFSetIDView(ent);
	else
	{
		ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW] = 0;
		ent.e.client.ps.stats[player_stat_t::CTF_ID_VIEW_COLOR] = 0;
	}
}

/*------------------------------------------------------------------------*/

/*QUAKED info_player_team1 (1 0 0) (-16 -16 -24) (16 16 32)
potential team1 spawning position for ctf games
*/
void SP_info_player_team1(ASEntity &self)
{
}

/*QUAKED info_player_team2 (0 0 1) (-16 -16 -24) (16 16 32)
potential team2 spawning position for ctf games
*/
void SP_info_player_team2(ASEntity &self)
{
}

/*--------------------------------------------------------------------------*/

/*------------------------------------------------------------------------*/
/* GRAPPLE																  */
/*------------------------------------------------------------------------*/

// ent is player
void CTFPlayerResetGrapple(ASEntity &ent)
{
	if (ent.client !is null && ent.client.ctf_grapple !is null)
		CTFResetGrapple(ent.client.ctf_grapple);
}

// self is grapple, not player
void CTFResetGrapple(ASEntity &self)
{
	if (self.owner.client.ctf_grapple is null)
		return;
	
	gi_sound(self.e.owner, soundchan_t::WEAPON, gi_soundindex("weapons/grapple/grreset.wav"), self.owner.client.silencer_shots != 0 ? 0.2f : 1.0f, ATTN_NORM, 0);

	ASClient @cl = self.owner.client;
	@cl.ctf_grapple = null;
	cl.ctf_grapplereleasetime = level.time + time_sec(1);
	cl.ctf_grapplestate = ctfgrapplestate_t::FLY; // we're firing, not on hook
	self.owner.flags = ent_flags_t(self.owner.flags & ~ent_flags_t::NO_KNOCKBACK);
	G_FreeEdict(self);
}

void CTFGrappleTouch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	float volume = 1.0;

	if (other is self.owner)
		return;

	if (self.owner.client.ctf_grapplestate != ctfgrapplestate_t::FLY)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		CTFResetGrapple(self);
		return;
	}

	self.velocity = vec3_origin;

	PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
	{
		if (self.dmg != 0)
			T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::NONE, mod_id_t::GRAPPLE);
		CTFResetGrapple(self);
		return;
	}

	self.owner.client.ctf_grapplestate = ctfgrapplestate_t::PULL; // we're on hook
	@self.enemy = other;

	self.e.solid = solid_t::NOT;

	if (self.owner.client.silencer_shots != 0)
		volume = 0.2f;

	gi_sound(self.e, soundchan_t::WEAPON, gi_soundindex("weapons/grapple/grhit.wav"), volume, ATTN_NORM, 0);
	self.e.s.sound = gi_soundindex("weapons/grapple/grpull.wav");

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::SPARKS);
	gi_WritePosition(self.e.s.origin);
	gi_WriteDir(tr.plane.normal);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);
}

// draw beam between grapple and self
void CTFGrappleDrawCable(ASEntity &self)
{
	if (self.owner.client.ctf_grapplestate == ctfgrapplestate_t::HANG)
		return;

	vec3_t start, dir;
	P_ProjectSource(self.owner, self.owner.client.v_angle, { 7, 2, -9 }, start, dir);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::GRAPPLE_CABLE_2);
	gi_WriteEntity(self.owner.e);
	gi_WritePosition(start);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);
}

// pull the player toward the grapple
void CTFGrapplePull(ASEntity &self)
{
	vec3_t hookdir, v;
	float  vlen;

	if (self.owner.client.pers.weapon !is null && self.owner.client.pers.weapon.id == item_id_t::WEAPON_GRAPPLE &&
		!(self.owner.client.newweapon !is null || ((self.owner.client.latched_buttons | self.owner.client.buttons) & button_t::HOLSTER) != 0) &&
		self.owner.client.weaponstate != weaponstate_t::FIRING &&
		self.owner.client.weaponstate != weaponstate_t::ACTIVATING)
	{
		if (self.owner.client.newweapon is null)
			@self.owner.client.newweapon = self.owner.client.pers.weapon;

		CTFResetGrapple(self);
		return;
	}

	if (self.enemy !is null)
	{
		if (self.enemy.e.solid == solid_t::NOT)
		{
			CTFResetGrapple(self);
			return;
		}
		if (self.enemy.e.solid == solid_t::BBOX)
		{
			v = self.enemy.e.size * 0.5f;
			v += self.enemy.e.s.origin;
			self.e.s.origin = v + self.enemy.e.mins;
			gi_linkentity(self.e);
		}
		else
			self.velocity = self.enemy.velocity;

		if (self.enemy.deadflag)
		{ // he died
			CTFResetGrapple(self);
			return;
		}
	}

	CTFGrappleDrawCable(self);

	if (self.owner.client.ctf_grapplestate > ctfgrapplestate_t::FLY)
	{
		// pull player toward grapple
		vec3_t forward, up;

		AngleVectors(self.owner.client.v_angle, forward, up: up);
		v = self.owner.e.s.origin;
		v[2] += self.owner.viewheight;
		hookdir = self.e.s.origin - v;

		vlen = hookdir.length();

		if (self.owner.client.ctf_grapplestate == ctfgrapplestate_t::PULL &&
			vlen < 64)
		{
			self.owner.client.ctf_grapplestate = ctfgrapplestate_t::HANG;
			self.e.s.sound = gi_soundindex("weapons/grapple/grhang.wav");
		}

		hookdir.normalize();
		hookdir = hookdir * g_grapple_pull_speed.value;
		self.owner.velocity = hookdir;
		self.owner.flags = ent_flags_t(self.owner.flags | ent_flags_t::NO_KNOCKBACK);
		SV_AddGravity(self.owner);
	}
}

void grapple_die(ASEntity &self, ASEntity &other, ASEntity &inflictor, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (mod.id == mod_id_t::CRUSH)
		CTFResetGrapple(self);
}

bool CTFFireGrapple(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, effects_t effect)
{
	ASEntity @grapple;
	trace_t	 tr;
	vec3_t	 normalized = dir.normalized();

	@grapple = G_Spawn();
	grapple.e.s.origin = start;
	grapple.e.s.old_origin = start;
	grapple.e.s.angles = vectoangles(normalized);
	grapple.velocity = normalized * speed;
	grapple.movetype = movetype_t::FLYMISSILE;
	grapple.e.clipmask = contents_t::MASK_PROJECTILE;
	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		grapple.e.clipmask = contents_t(grapple.e.clipmask & ~contents_t::PLAYER);
	grapple.e.solid = solid_t::BBOX;
	grapple.e.s.effects = effects_t(grapple.e.s.effects | effect);
	grapple.e.s.modelindex = gi_modelindex("models/weapons/grapple/hook/tris.md2");
	@grapple.owner = self;
	@grapple.touch = CTFGrappleTouch;
	grapple.dmg = damage;
	grapple.flags = ent_flags_t(grapple.flags | ent_flags_t::NO_KNOCKBACK | ent_flags_t::NO_DAMAGE_EFFECTS);
	grapple.takedamage = true;
	@grapple.die = grapple_die;
	@self.client.ctf_grapple = grapple;
	self.client.ctf_grapplestate = ctfgrapplestate_t::FLY; // we're firing, not on hook
	gi_linkentity(grapple.e);

	tr = gi_traceline(self.e.s.origin, grapple.e.s.origin, grapple.e, grapple.e.clipmask);
	if (tr.fraction < 1.0f)
	{
		grapple.e.s.origin = tr.endpos + (tr.plane.normal * 1.0f);
		grapple.touch(grapple, entities[tr.ent.s.number], tr, false);
		return false;
	}

	grapple.e.s.sound = gi_soundindex("weapons/grapple/grfly.wav");

	return true;
}

void CTFGrappleFire(ASEntity &ent, const vec3_t &in g_offset, int damage, effects_t effect)
{
	float volume = 1.0;

	if (ent.client.ctf_grapplestate > ctfgrapplestate_t::FLY)
		return; // it's already out

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, vec3_t(24, 8, -8 + 2) + g_offset, start, dir);

	if (ent.client.silencer_shots != 0)
		volume = 0.2f;

	if (CTFFireGrapple(ent, start, dir, damage, g_grapple_fly_speed.integer, effect))
		gi_sound(ent.e, soundchan_t::WEAPON, gi_soundindex("weapons/grapple/grfire.wav"), volume, ATTN_NORM, 0);

	PlayerNoise(ent, start, player_noise_t::WEAPON);
}

void CTFWeapon_Grapple_Fire(ASEntity &ent)
{
	CTFGrappleFire(ent, vec3_origin, g_grapple_damage.integer, effects_t::NONE);
}

const array<int> grapple_pause_frames = { 10, 18, 27 };
const array<int> grapple_fire_frames = { 6 };

void CTFWeapon_Grapple(ASEntity &ent)
{
	int			  prevstate;

	// if the the attack button is still down, stay in the firing frame
	if ((ent.client.buttons & (button_t::ATTACK | button_t::HOLSTER)) != 0 &&
		ent.client.weaponstate == weaponstate_t::FIRING &&
		ent.client.ctf_grapple !is null)
		ent.e.client.ps.gunframe = 6;

	if ((ent.client.buttons & (button_t::ATTACK | button_t::HOLSTER)) == 0 &&
		ent.client.ctf_grapple !is null)
	{
		CTFResetGrapple(ent.client.ctf_grapple);
		if (ent.client.weaponstate == weaponstate_t::FIRING)
			ent.client.weaponstate = weaponstate_t::READY;
	}

	if ((ent.client.newweapon !is null || ((ent.client.latched_buttons | ent.client.buttons) & button_t::HOLSTER) != 0) &&
		ent.client.ctf_grapplestate > ctfgrapplestate_t::FLY &&
		ent.client.weaponstate == weaponstate_t::FIRING)
	{
		// he wants to change weapons while grappled
		if (ent.client.newweapon is null)
			@ent.client.newweapon = ent.client.pers.weapon;
		ent.client.weaponstate = weaponstate_t::DROPPING;
		ent.e.client.ps.gunframe = 32;
	}

	prevstate = ent.client.weaponstate;
	Weapon_Generic(ent, 5, 10, 31, 36, grapple_pause_frames, grapple_fire_frames,
				   CTFWeapon_Grapple_Fire);

	// if the the attack button is still down, stay in the firing frame
	if ((ent.client.buttons & (button_t::ATTACK | button_t::HOLSTER)) != 0 &&
		ent.client.weaponstate == weaponstate_t::FIRING &&
		ent.client.ctf_grapple !is null)
		ent.e.client.ps.gunframe = 6;

	// if we just switched back to grapple, immediately go to fire frame
	if (prevstate == weaponstate_t::ACTIVATING &&
		ent.client.weaponstate == weaponstate_t::READY &&
		ent.client.ctf_grapplestate > ctfgrapplestate_t::FLY)
	{
		if ((ent.client.buttons & (button_t::ATTACK | button_t::HOLSTER)) == 0)
			ent.e.client.ps.gunframe = 6;
		else
			ent.e.client.ps.gunframe = 5;
		ent.client.weaponstate = weaponstate_t::FIRING;
	}
}

void CTFDirtyTeamMenu()
{
    foreach (ASEntity @player : active_players)
    {
		if (player.client.menu !is null)
		{
			player.client.menudirty = true;
			player.client.menutime = level.time;
		}
    }
}

void CTFTeam_f(ASEntity &ent)
{
	if (!G_TeamplayEnabled())
		return;

	ctfteam_t	  desired_team;
	string t = gi_args();

	if (t.empty())
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_you_are_on_team",
				   CTFTeamName(ent.client.resp.ctf_team));
		return;
	}

	if (ctfgame.match > match_t::SETUP)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_cant_change_teams");
		return;
	}

	// [Paril-KEX] with force-join, don't allow us to switch
	// using this command.
	if (g_teamplay_force_join.integer != 0)
	{
		if ((ent.e.svflags & svflags_t::BOT) == 0)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_cant_change_teams");
			return;
		}
	}

	if (Q_strcasecmp(t, "red") == 0)
		desired_team = ctfteam_t::TEAM1;
	else if (Q_strcasecmp(t, "blue") == 0)
		desired_team = ctfteam_t::TEAM2;
	else
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_unknown_team", t);
		return;
	}

	if (ent.client.resp.ctf_team == desired_team)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_already_on_team",
				   CTFTeamName(ent.client.resp.ctf_team));
		return;
	}

	////
	ent.e.svflags = svflags_t::NONE;
	ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);
	ent.client.resp.ctf_team = desired_team;
	ent.client.resp.ctf_state = 0;
	string value;
	gi_Info_ValueForKey(ent.client.pers.userinfo, "skin", value);
	CTFAssignSkin(ent, value);

	// if anybody has a menu open, update it immediately
	CTFDirtyTeamMenu();

	if (ent.e.solid == solid_t::NOT)
	{
		// spectator
		PutClientInServer(ent);

		G_PostRespawn(ent);

		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_joined_team",
				   ent.client.pers.netname, CTFTeamName(desired_team));
		return;
	}

	ent.health = 0;
	player_die(ent, ent, ent, 100000, vec3_origin, mod_t(mod_id_t::SUICIDE, true));

	// don't even bother waiting for death frames
	ent.deadflag = true;
	respawn(ent);

	ent.client.resp.score = 0;

	gi_LocBroadcast_Print(print_type_t::HIGH, "$g_changed_team",
			   ent.client.pers.netname, CTFTeamName(desired_team));
}

const uint MAX_CTF_STAT_LENGTH = 1024;

class ctf_team_data_t
{
    array<int>  sorted(max_clients);
    array<int>  sortedscores(max_clients);
    uint        total;
    int         totalscore;
    uint        last;
}

/*
==================
CTFScoreboardMessage
==================
*/
void CTFScoreboardMessage(ASEntity &ent, ASEntity @killer)
{
	uint       i, j, k, n;
	int		   score;
	ASClient   @cl;
	ASEntity   @cl_ent;
	int		   team;

    ctf_team_data_t[] teams(2);

	// sort the clients by team and score
	for (i = 0; i < max_clients; i++)
	{
		@cl_ent = players[i];
		if (!cl_ent.e.inuse)
			continue;
        @cl = cl_ent.client;
		if (cl.resp.ctf_team == ctfteam_t::TEAM1)
			team = 0;
		else if (cl.resp.ctf_team == ctfteam_t::TEAM2)
			team = 1;
		else
			continue; // unknown team?

		score = cl.resp.score;
        ctf_team_data_t @data = teams[team];

		for (j = 0; j < data.total; j++)
		{
			if (score > data.sortedscores[j])
				break;
		}
		for (k = data.total; k > j; k--)
		{
			data.sorted[k] = data.sorted[k - 1];
			data.sortedscores[k] = data.sortedscores[k - 1];
		}
		data.sorted[j] = i;
		data.sortedscores[j] = score;
		data.totalscore += score;
		data.total++;
	}

	// print level name and exit rules
	// add the clients in sorted order
	string str;

	// [Paril-KEX] time & frags
	if (teamplay.integer != 0)
	{
		if (fraglimit.integer != 0)
		{
			str += format("xv -20 yv -10 loc_string2 1 $g_score_frags \"{}\" ", fraglimit.integer);
		}
	}
	else
	{
		if (capturelimit.integer != 0)
		{
			str += format("xv -20 yv -10 loc_string2 1 $g_score_captures \"{}\" ", capturelimit.integer);
		}
	}
	if (timelimit.value != 0)
	{
		str += format("xv 340 yv -10 time_limit {} ", gi_ServerFrame() + ((time_min(timelimit.value) - level.time)).milliseconds / gi_frame_time_ms);
	}

	// team one
	if (teamplay.integer != 0)
	{
		str += format(
			"if 25 xv -32 yv 8 pic 25 endif "
			"xv -123 yv 28 cstring \"{}\" "
			"xv 41 yv 12 num 3 19 "
			"if 26 xv 208 yv 8 pic 26 endif "
			"xv 117 yv 28 cstring \"{}\" "
			"xv 280 yv 12 num 3 21 ",
			teams[0].total,
			teams[1].total);
	}
	else
	{
		str += format(
			"if 25 xv -32 yv 8 pic 25 endif "
			"xv 0 yv 28 string \"{:4}/{:<3}\" "
			"xv 58 yv 12 num 2 19 "
			"if 26 xv 208 yv 8 pic 26 endif "
			"xv 240 yv 28 string \"{:4}/{:<3}\" "
			"xv 296 yv 12 num 2 21 ",
			teams[0].totalscore, teams[1].total,
			teams[1].totalscore, teams[1].total);
	}

	for (i = 0; i < 16; i++)
	{
		if (i >= teams[0].total && i >= teams[1].total)
			break; // we're done

		// left side
		if (i < teams[0].total)
		{
			@cl_ent = players[teams[0].sorted[i]];
			@cl = cl_ent.client;

			string entry = format("ctf -40 {} {} {} {} {} ",
						42 + i * 8,
						teams[0].sorted[i],
						cl.resp.score,
						cl.c.ping > 999 ? 999 : cl.c.ping,
						cl.pers.inventory[item_id_t::FLAG2] != 0 ? "sbfctf2" : "\"\"");

			if (str.length() + entry.length() < MAX_CTF_STAT_LENGTH)
			{
				str += entry;
				teams[0].last = i;
			}
		}

		// right side
		if (i < teams[1].total)
		{
			@cl_ent = players[teams[1].sorted[i]];
			@cl = cl_ent.client;

			string entry = format("ctf 200 {} {} {} {} {} ",
						42 + i * 8,
						teams[1].sorted[i],
						cl.resp.score,
						cl.c.ping > 999 ? 999 : cl.c.ping,
						cl.pers.inventory[item_id_t::FLAG1] != 0 ? "sbfctf1" : "\"\"");
			
			if (str.length() + entry.length() < MAX_CTF_STAT_LENGTH)
			{
				str += entry;
				teams[1].last = i;
			}
		}
	}

	// put in spectators if we have enough room
	if (teams[0].last > teams[1].last)
		j = teams[0].last;
	else
		j = teams[1].last;
	j = (j + 2) * 8 + 42;

	k = n = 0;
	if (str.length() < MAX_CTF_STAT_LENGTH - 50)
	{
		for (i = 0; i < max_clients; i++)
		{
			@cl_ent = players[i];
			@cl = cl_ent.client;
			if (!cl_ent.e.inuse ||
				cl_ent.e.solid != solid_t::NOT ||
				cl.resp.ctf_team != ctfteam_t::NOTEAM)
				continue;

			if (k == 0)
			{
				k = 1;
				str += format("xv 0 yv {} loc_string2 0 \"$g_pc_spectators\" ", j);
				j += 8;
			}

			string entry = format("ctf {} {} {} {} {} \"\" ",
						(n & 1) != 0 ? 200 : -40, // x
						j,				   // y
						i,				   // playernum
						cl.resp.score,
						cl.c.ping > 999 ? 999 : cl.c.ping);

			if (str.length() + entry.length() < MAX_CTF_STAT_LENGTH)
				str += entry;

			if ((n & 1) != 0)
				j += 8;
			n++;
		}
	}

	if (teams[0].total - teams[0].last > 1) // couldn't fit everyone
		str += format("xv -32 yv {} loc_string 1 $g_ctf_and_more {} ",
					42 + (teams[0].last + 1) * 8, teams[0].total - teams[0].last - 1);
	if (teams[1].total - teams[1].last > 1) // couldn't fit everyone
		str += format("xv 208 yv {} loc_string 1 $g_ctf_and_more {} ",
					42 + (teams[1].last + 1) * 8, teams[1].total - teams[1].last - 1);

	if (level.intermissiontime)
		str += format("ifgef {} yb -48 xv 0 loc_cstring2 0 \"$m_eou_press_button\" endif ", (level.intermission_server_frame + time_sec(5).frames()));

	gi_WriteByte(svc_t::layout);
	gi_WriteString(str);
}

/*------------------------------------------------------------------------*/
/* TECH																	  */
/*------------------------------------------------------------------------*/

void CTFHasTech(ASEntity &who)
{
	if (level.time - who.client.ctf_lasttechmsg > time_sec(2))
	{
		gi_LocCenter_Print(who.e, "$g_already_have_tech");
		who.client.ctf_lasttechmsg = level.time;
	}
}

const gitem_t @CTFWhat_Tech(ASEntity &ent)
{
	foreach (item_id_t id : tech_ids)
		if (ent.client.pers.inventory[id] != 0)
			return GetItemByIndex(id);
	return null;
}

bool CTFPickup_Tech(ASEntity &ent, ASEntity &other)
{
	foreach (item_id_t id : tech_ids)
    {
		if (other.client.pers.inventory[id] != 0)
		{
			CTFHasTech(other);
			return false; // has this one
		}
	}

	// client only gets one tech
	other.client.pers.inventory[ent.item.id]++;
	other.client.ctf_regentime = level.time;
	return true;
}

ASEntity @FindTechSpawn()
{
	return SelectDeathmatchSpawnPoint(false, true, true).spot;
}

void TechThink(ASEntity &tech)
{
	ASEntity @spot;

	if ((@spot = FindTechSpawn()) !is null)
	{
		SpawnTech(tech.item, spot);
		G_FreeEdict(tech);
	}
	else
	{
		tech.nextthink = level.time + CTF_TECH_TIMEOUT;
		@tech.think = TechThink;
	}
}

void CTFDrop_Tech(ASEntity &ent, const gitem_t &item)
{
	ASEntity @tech = Drop_Item(ent, item);
	tech.nextthink = level.time + CTF_TECH_TIMEOUT;
	@tech.think = TechThink;
	ent.client.pers.inventory[item.id] = 0;
}

void CTFDeadDropTech(ASEntity @ent)
{
	ASEntity @dropped;

	foreach (item_id_t id : tech_ids)
    {
		if (ent.client.pers.inventory[id] != 0)
		{
			@dropped = Drop_Item(ent, GetItemByIndex(id));
			// hack the velocity to make it bounce random
			dropped.velocity[0] = crandom_open() * 300;
			dropped.velocity[1] = crandom_open() * 300;
			dropped.nextthink = level.time + CTF_TECH_TIMEOUT;
			@dropped.think = TechThink;
			@dropped.owner = null;
			ent.client.pers.inventory[id] = 0;
		}
	}
}

void SpawnTech(const gitem_t @item, ASEntity &spot)
{
	ASEntity @ent;
	vec3_t	 forward, right;
	vec3_t	 angles;

	@ent = G_Spawn();

	ent.classname = item.classname;
	@ent.item = item;
	ent.spawnflags = spawnflags::item::DROPPED;
	ent.e.effects = item.world_model_flags;
	ent.e.renderfx = renderfx_t(renderfx_t::GLOW | renderfx_t::NO_LOD);
	ent.e.mins = { -15, -15, -15 };
	ent.e.maxs = { 15, 15, 15 };
	gi_setmodel(ent.e, ent.item.world_model);
	ent.e.solid = solid_t::TRIGGER;
	ent.movetype = movetype_t::TOSS;
	@ent.touch = Touch_Item;
	@ent.owner = ent;

	angles[0] = 0;
	angles[1] = irandom(360);
	angles[2] = 0;

	AngleVectors(angles, forward, right);
	ent.e.origin = spot.e.origin;
	ent.e.origin[2] += 16;
	ent.velocity = forward * 100;
	ent.velocity[2] = 300;

	ent.nextthink = level.time + CTF_TECH_TIMEOUT;
	@ent.think = TechThink;

	gi_linkentity(ent.e);
}

void SpawnTechs(ASEntity &ent)
{
	ASEntity @spot;

	foreach (item_id_t id : tech_ids)
		if ((@spot = FindTechSpawn()) !is null)
			SpawnTech(GetItemByIndex(id), spot);

    // kind of a hack...
	if (ent !is world)
		G_FreeEdict(ent);
}

// frees the passed edict!
void CTFRespawnTech(ASEntity &ent)
{
	ASEntity @spot;

	if ((@spot = FindTechSpawn()) !is null)
		SpawnTech(ent.item, spot);

	G_FreeEdict(ent);
}

void CTFSetupTechSpawn()
{
	ASEntity @ent;
	bool techs_allowed;

	// [Paril-KEX]
	if (g_allow_techs.stringval == "auto")
		techs_allowed = ctf.integer != 0;
	else
		techs_allowed = g_allow_techs.integer != 0;

	if (!techs_allowed)
		return;

	@ent = G_Spawn();
	ent.nextthink = level.time + time_sec(2);
	@ent.think = SpawnTechs;
}

void CTFResetTech()
{
	ASEntity @ent;
	uint i;

	for (i = 1; i < num_edicts; i++)
	{
        @ent = entities[i];

		if (ent.e.inuse)
			if (ent.item !is null && (ent.item.flags & item_flags_t::TECH) != 0)
				G_FreeEdict(ent);
	}

	SpawnTechs(world);
}

int CTFApplyResistance(ASEntity &ent, int dmg)
{
	float volume = 1.0;

	if (ent.client !is null && ent.client.silencer_shots != 0)
		volume = 0.2f;

	if (dmg != 0 && ent.client !is null && ent.client.pers.inventory[item_id_t::TECH_RESISTANCE] != 0)
	{
		// make noise
		gi_sound(ent.e, soundchan_t::AUX, gi_soundindex("ctf/tech1.wav"), volume, ATTN_NORM, 0);
		return dmg / 2;
	}
	return dmg;
}

int CTFApplyStrength(ASEntity &ent, int dmg)
{
	if (dmg != 0 && ent.client !is null && ent.client.pers.inventory[item_id_t::TECH_STRENGTH] != 0)
	{
		return dmg * 2;
	}
	return dmg;
}

bool CTFApplyStrengthSound(ASEntity &ent)
{
	float volume = 1.0;

	if (ent.client !is null && ent.client.silencer_shots != 0)
		volume = 0.2f;

	if (ent.client !is null &&
		ent.client.pers.inventory[item_id_t::TECH_STRENGTH] != 0)
	{
		if (ent.client.ctf_techsndtime < level.time)
		{
			ent.client.ctf_techsndtime = level.time + time_sec(1);
			if (ent.client.quad_time > level.time)
				gi_sound(ent.e, soundchan_t::AUX, gi_soundindex("ctf/tech2x.wav"), volume, ATTN_NORM, 0);
			else
				gi_sound(ent.e, soundchan_t::AUX, gi_soundindex("ctf/tech2.wav"), volume, ATTN_NORM, 0);
		}
		return true;
	}
	return false;
}

bool CTFApplyHaste(ASEntity &ent)
{
	if (ent.client !is null &&
		ent.client.pers.inventory[item_id_t::TECH_HASTE] != 0)
		return true;
	return false;
}

void CTFApplyHasteSound(ASEntity &ent)
{
	float volume = 1.0;

	if (ent.client !is null && ent.client.silencer_shots != 0)
		volume = 0.2f;

	if (ent.client !is null &&
		ent.client.pers.inventory[item_id_t::TECH_HASTE] != 0 &&
		ent.client.ctf_techsndtime < level.time)
	{
		ent.client.ctf_techsndtime = level.time + time_sec(1);
		gi_sound(ent.e, soundchan_t::AUX, gi_soundindex("ctf/tech3.wav"), volume, ATTN_NORM, 0);
	}
}

void CTFApplyRegeneration(ASEntity &ent)
{
	bool	   noise = false;
	ASClient   @client;
	int		   index;
	float	   volume = 1.0;

	@client = ent.client;
	if (client is null)
		return;

	if (client.silencer_shots != 0)
		volume = 0.2f;

	if (client.pers.inventory[item_id_t::TECH_REGENERATION] != 0)
	{
		if (client.ctf_regentime < level.time)
		{
			client.ctf_regentime = level.time;
			if (ent.health < 150)
			{
				ent.health += 5;
				if (ent.health > 150)
					ent.health = 150;
				client.ctf_regentime += time_ms(500);
				noise = true;
			}
			index = ArmorIndex(ent);
			if (index != item_id_t::NULL && client.pers.inventory[index] < 150)
			{
				client.pers.inventory[index] += 5;
				if (client.pers.inventory[index] > 150)
					client.pers.inventory[index] = 150;
				client.ctf_regentime += time_ms(500);
				noise = true;
			}
		}
		if (noise && ent.client.ctf_techsndtime < level.time)
		{
			ent.client.ctf_techsndtime = level.time + time_sec(1);
			gi_sound(ent.e, soundchan_t::AUX, gi_soundindex("ctf/tech4.wav"), volume, ATTN_NORM, 0);
		}
	}
}

bool CTFHasRegeneration(ASEntity &ent)
{
	if (ent.client !is null &&
		ent.client.pers.inventory[item_id_t::TECH_REGENERATION] != 0)
		return true;
	return false;
}

/*-----------------------------------------------------------------------*/
/*QUAKED misc_ctf_banner (1 .5 0) (-4 -64 0) (4 64 248) TEAM2
The origin is the bottom of the banner.
The banner is 248 tall.
*/
void misc_ctf_banner_think(ASEntity &ent)
{
	ent.e.frame = (ent.e.frame + 1) % 16;
	ent.nextthink = level.time + time_hz(10);
}

namespace spawnflags::ctf_banner
{
    const uint32 BLUE = 1;
}

void SP_misc_ctf_banner(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.modelindex = gi_modelindex("models/ctf/banner/tris.md2");
	if ((ent.spawnflags & spawnflags::ctf_banner::BLUE) != 0) // team2
		ent.e.skinnum = 1;

	ent.e.frame = irandom(16);
	gi_linkentity(ent.e);

	@ent.think = misc_ctf_banner_think;
	ent.nextthink = level.time + time_hz(10);
}

/*QUAKED misc_ctf_small_banner (1 .5 0) (-4 -32 0) (4 32 124) TEAM2
The origin is the bottom of the banner.
The banner is 124 tall.
*/
void SP_misc_ctf_small_banner(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.modelindex = gi_modelindex("models/ctf/banner/small.md2");
	if ((ent.spawnflags & spawnflags::ctf_banner::BLUE) != 0) // team2
		ent.e.skinnum = 1;

	ent.e.frame = irandom(16);
	gi_linkentity(ent.e);

	@ent.think = misc_ctf_banner_think;
	ent.nextthink = level.time + time_hz(10);
}

/*-----------------------------------------------------------------------*/

void SetGameName(pmenu_t &p)
{
	if (ctf.integer != 0)
		p.text = "$g_pc_3wctf";
	else
		p.text = "$g_pc_teamplay";
}

void SetLevelName(pmenu_t &p)
{
	string levelname = "*";
	if (!world.message.empty())
		levelname += world.message;
	else
		levelname += level.mapname;
	p.text = levelname;
}

/*-----------------------------------------------------------------------*/

/* ELECTIONS */

bool CTFBeginElection(ASEntity &ent, elect_t type, const string &in msg)
{
	int		 count;
	ASEntity @e;

	if (electpercentage.value == 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Elections are disabled, only an admin can process this action.\n");
		return false;
	}

	if (ctfgame.election != elect_t::NONE)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Election already in progress.\n");
		return false;
	}

	// clear votes
	count = 0;
	for (uint i = 1; i <= max_clients; i++)
	{
		@e = entities[i];
		e.client.resp.voted = false;
		if (e.e.inuse)
			count++;
	}

	if (count < 2)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Not enough players for election.\n");
		return false;
	}

	@ctfgame.etarget = ent;
	ctfgame.election = type;
	ctfgame.evotes = 0;
	ctfgame.needvotes = int((count * electpercentage.value) / 100);
	ctfgame.electtime = level.time + time_sec(20); // twenty seconds for election
	ctfgame.emsg = msg;

	// tell everyone
	gi_Broadcast_Print(print_type_t::CHAT, ctfgame.emsg);
	gi_LocBroadcast_Print(print_type_t::HIGH, "Type YES or NO to vote on this request.\n");
	gi_LocBroadcast_Print(print_type_t::HIGH, "Votes: {}  Needed: {}  Time left: {}s\n", ctfgame.evotes, ctfgame.needvotes,
			   (ctfgame.electtime - level.time).secondsi());

	return true;
}

void CTFResetAllPlayers()
{
	uint i;
	ASEntity @ent;

	for (i = 1; i <= max_clients; i++)
	{
		@ent = entities[i];
		if (!ent.e.inuse)
			continue;

		if (ent.client.menu !is null)
			PMenu_Close(ent);

		CTFPlayerResetGrapple(ent);
		CTFDeadDropFlag(ent);
		CTFDeadDropTech(ent);

		ent.client.resp.ctf_team = ctfteam_t::NOTEAM;
		ent.client.resp.ready = false;

		ent.e.svflags = svflags_t::NONE;
		ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);
		PutClientInServer(ent);
	}

	// reset the level
	CTFResetTech();
	CTFResetFlags();

	for (i = 1; i <= num_edicts; i++)
	{
		@ent = entities[i];
		if (ent.e.inuse && ent.client is null)
		{
			if (ent.e.solid == solid_t::NOT && ent.think is DoRespawn &&
				ent.nextthink >= level.time)
			{
				ent.nextthink = time_zero;
				DoRespawn(ent);
			}
		}
	}
	if (ctfgame.match == match_t::SETUP)
		ctfgame.matchtime = level.time + time_min(matchsetuptime.value);
}

void CTFAssignGhost(ASEntity &ent)
{
	uint ghost, i;

	for (ghost = 0; ghost < max_clients; ghost++)
		if (ctfgame.ghosts[ghost].code == 0)
			break;
	if (ghost == max_clients)
		return;
	ctfgame.ghosts[ghost].team = ent.client.resp.ctf_team;
	ctfgame.ghosts[ghost].score = 0;
	for (;;)
	{
		ctfgame.ghosts[ghost].code = irandom(10000, 100000);
		for (i = 0; i < max_clients; i++)
			if (i != ghost && ctfgame.ghosts[i].code == ctfgame.ghosts[ghost].code)
				break;
		if (i == max_clients)
			break;
	}
	@ctfgame.ghosts[ghost].ent = ent;
	ctfgame.ghosts[ghost].netname = ent.client.pers.netname;
	@ent.client.resp.ghost = ctfgame.ghosts[ghost];
	gi_LocClient_Print(ent.e, print_type_t::CHAT, "Your ghost code is **** {} ****\n", ctfgame.ghosts[ghost].code);
	gi_LocClient_Print(ent.e, print_type_t::HIGH, "If you lose connection, you can rejoin with your score intact by typing \"ghost {}\".\n",
			   ctfgame.ghosts[ghost].code);
}

// start a match
void CTFStartMatch()
{
	ASEntity @ent;

	ctfgame.match = match_t::GAME;
	ctfgame.matchtime = level.time + time_min(matchtime.value);
	ctfgame.countdown = false;

	ctfgame.team1 = ctfgame.team2 = 0;

	ctfgame.ghosts.resize(0);
    ctfgame.ghosts.resize(max_clients);

	for (uint i = 1; i <= max_clients; i++)
	{
		@ent = entities[i];

		if (!ent.e.inuse)
			continue;

		ent.client.resp.score = 0;
		ent.client.resp.ctf_state = 0;
		@ent.client.resp.ghost = null;

		gi_LocCenter_Print(ent.e, "******************\n\nMATCH HAS STARTED!\n\n******************");

		if (ent.client.resp.ctf_team != ctfteam_t::NOTEAM)
		{
			// make up a ghost code
			CTFAssignGhost(ent);
			CTFPlayerResetGrapple(ent);
			ent.e.svflags = svflags_t::NOCLIENT;
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);

			ent.client.respawn_time = level.time + random_time(time_sec(1), time_sec(4));
			ent.e.client.ps.pmove.pm_type = pmtype_t::DEAD;
			ent.client.anim_priority = anim_priority_t::DEATH;
			ent.e.frame = player::frames::death308 - 1;
			ent.client.anim_end = player::frames::death308;
			ent.deadflag = true;
			ent.movetype = movetype_t::NOCLIP;
			ent.e.client.ps.gunindex = 0;
			ent.e.client.ps.gunskin = 0;
			gi_linkentity(ent.e);
		}
	}
}

void CTFEndMatch()
{
	ctfgame.match = match_t::POST;
	gi_LocBroadcast_Print(print_type_t::CHAT, "MATCH COMPLETED!\n");

	CTFCalcScores();

	gi_LocBroadcast_Print(print_type_t::HIGH, "RED TEAM:  {} captures, {} points\n",
			   ctfgame.team1, ctfgame.total1);
	gi_LocBroadcast_Print(print_type_t::HIGH, "BLUE TEAM:  {} captures, {} points\n",
			   ctfgame.team2, ctfgame.total2);

	if (ctfgame.team1 > ctfgame.team2)
		gi_LocBroadcast_Print(print_type_t::CHAT, "$g_ctf_red_wins_caps",
				   ctfgame.team1 - ctfgame.team2);
	else if (ctfgame.team2 > ctfgame.team1)
		gi_LocBroadcast_Print(print_type_t::CHAT, "$g_ctf_blue_wins_caps",
				   ctfgame.team2 - ctfgame.team1);
	else if (ctfgame.total1 > ctfgame.total2) // frag tie breaker
		gi_LocBroadcast_Print(print_type_t::CHAT, "$g_ctf_red_wins_points",
				   ctfgame.total1 - ctfgame.total2);
	else if (ctfgame.total2 > ctfgame.total1)
		gi_LocBroadcast_Print(print_type_t::CHAT, "$g_ctf_blue_wins_points",
				   ctfgame.total2 - ctfgame.total1);
	else
		gi_LocBroadcast_Print(print_type_t::CHAT, "$g_ctf_tie_game");

	EndDMLevel();
}

bool CTFNextMap()
{
	if (ctfgame.match == match_t::POST)
	{
		ctfgame.match = match_t::SETUP;
		CTFResetAllPlayers();
		return true;
	}
	return false;
}


void CTFWinElection()
{
	switch (ctfgame.election)
	{
	case elect_t::MATCH:
		// reset into match mode
		if (competition.integer < 3)
			gi_cvar_set("competition", "2");
		ctfgame.match = match_t::SETUP;
		CTFResetAllPlayers();
		break;

	case elect_t::ADMIN:
		ctfgame.etarget.client.resp.admin = true;
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} has become an admin.\n", ctfgame.etarget.client.pers.netname);
		gi_LocClient_Print(ctfgame.etarget.e, print_type_t::HIGH, "Type 'admin' to access the adminstration menu.\n");
		break;

	case elect_t::MAP:
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} is warping to level {}.\n",
				   ctfgame.etarget.client.pers.netname, ctfgame.elevel);
		level.forcemap = ctfgame.elevel;
		EndDMLevel();
		break;

	default:
		break;
	}
	ctfgame.election = elect_t::NONE;
}

void CTFVoteYes(ASEntity &ent)
{
	if (ctfgame.election == elect_t::NONE)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "No election is in progress.\n");
		return;
	}
	if (ent.client.resp.voted)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You already voted.\n");
		return;
	}
	if (ctfgame.etarget is ent)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You can't vote for yourself.\n");
		return;
	}

	ent.client.resp.voted = true;

	ctfgame.evotes++;
	if (ctfgame.evotes == ctfgame.needvotes)
	{
		// the election has been won
		CTFWinElection();
		return;
	}
	gi_LocBroadcast_Print(print_type_t::HIGH, "{}\n", ctfgame.emsg);
	gi_LocBroadcast_Print(print_type_t::CHAT, "Votes: {}  Needed: {}  Time left: {}s\n", ctfgame.evotes, ctfgame.needvotes,
			   (ctfgame.electtime - level.time).secondsi());
}

void CTFVoteNo(ASEntity &ent)
{
	if (ctfgame.election == elect_t::NONE)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "No election is in progress.\n");
		return;
	}
	if (ent.client.resp.voted)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You already voted.\n");
		return;
	}
	if (ctfgame.etarget is ent)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You can't vote for yourself.\n");
		return;
	}

	ent.client.resp.voted = true;

	gi_LocBroadcast_Print(print_type_t::HIGH, "{}\n", ctfgame.emsg);
	gi_LocBroadcast_Print(print_type_t::CHAT, "Votes: {}  Needed: {}  Time left: {}s\n", ctfgame.evotes, ctfgame.needvotes,
			   (ctfgame.electtime - level.time).secondsi());
}

void CTFReady(ASEntity &ent)
{
	uint i, j;
	ASEntity @e;
	uint t1, t2;

	if (ent.client.resp.ctf_team == ctfteam_t::NOTEAM)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Pick a team first (hit <TAB> for menu)\n");
		return;
	}

	if (ctfgame.match != match_t::SETUP)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "A match is not being setup.\n");
		return;
	}

	if (ent.client.resp.ready)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You have already commited.\n");
		return;
	}

	ent.client.resp.ready = true;
	gi_LocBroadcast_Print(print_type_t::HIGH, "{} is ready.\n", ent.client.pers.netname);

	t1 = t2 = 0;
    j = 0; i = 1;
	for (; i <= max_clients; i++)
	{
		@e = entities[i];
		if (!e.e.inuse)
			continue;
		if (e.client.resp.ctf_team != ctfteam_t::NOTEAM && !e.client.resp.ready)
			j++;
		if (e.client.resp.ctf_team == ctfteam_t::TEAM1)
			t1++;
		else if (e.client.resp.ctf_team == ctfteam_t::TEAM2)
			t2++;
	}
	if (j == 0 && t1 != 0 && t2 != 0)
	{
		// everyone has commited
		gi_LocBroadcast_Print(print_type_t::CHAT, "All players have committed.  Match starting\n");
		ctfgame.match = match_t::PREGAME;
		ctfgame.matchtime = level.time + time_sec(matchstarttime.value);
		ctfgame.countdown = false;
		gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("misc/talk1.wav"), 1, ATTN_NONE, 0);
	}
}

void CTFNotReady(ASEntity &ent)
{
	if (ent.client.resp.ctf_team == ctfteam_t::NOTEAM)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Pick a team first (hit <TAB> for menu)\n");
		return;
	}

	if (ctfgame.match != match_t::SETUP && ctfgame.match != match_t::PREGAME)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "A match is not being setup.\n");
		return;
	}

	if (!ent.client.resp.ready)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You haven't commited.\n");
		return;
	}

	ent.client.resp.ready = false;
	gi_LocBroadcast_Print(print_type_t::HIGH, "{} is no longer ready.\n", ent.client.pers.netname);

	if (ctfgame.match == match_t::PREGAME)
	{
		gi_LocBroadcast_Print(print_type_t::CHAT, "Match halted.\n");
		ctfgame.match = match_t::SETUP;
		ctfgame.matchtime = level.time + time_min(matchsetuptime.value);
	}
}

void CTFGhost(ASEntity &ent)
{
	uint i;
	int n;

	if (gi_argc() < 2)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Usage:  ghost <code>\n");
		return;
	}

	if (ent.client.resp.ctf_team != ctfteam_t::NOTEAM)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You are already in the game.\n");
		return;
	}
	if (ctfgame.match != match_t::GAME)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "No match is in progress.\n");
		return;
	}

	n = parseInt(gi_argv(1));

	for (i = 0; i < max_clients; i++)
	{
		if (ctfgame.ghosts[i].code != 0 && ctfgame.ghosts[i].code == n)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "Ghost code accepted, your position has been reinstated.\n");
			@ctfgame.ghosts[i].ent.client.resp.ghost = null;
			ent.client.resp.ctf_team = ctfgame.ghosts[i].team;
			@ent.client.resp.ghost = ctfgame.ghosts[i];
			ent.client.resp.score = ctfgame.ghosts[i].score;
			ent.client.resp.ctf_state = 0;
			@ctfgame.ghosts[i].ent = ent;
			ent.e.svflags = svflags_t::NONE;
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);
			PutClientInServer(ent);
			gi_LocBroadcast_Print(print_type_t::HIGH, "{} has been reinstated to {} team.\n",
					   ent.client.pers.netname, CTFTeamName(ent.client.resp.ctf_team));
			return;
		}
	}
	gi_LocClient_Print(ent.e, print_type_t::HIGH, "Invalid ghost code.\n");
}

bool CTFMatchSetup()
{
	if (ctfgame.match == match_t::SETUP || ctfgame.match == match_t::PREGAME)
		return true;
	return false;
}

bool CTFMatchOn()
{
	if (ctfgame.match == match_t::GAME)
		return true;
	return false;
}

/*-----------------------------------------------------------------------*/

const int jmenu_level = 1;
const int jmenu_match = 2;
const int jmenu_red = 4;
const int jmenu_blue = 7;
const int jmenu_chase = 10;
const int jmenu_reqmatch = 12;

const array<pmenu_t> joinmenu = {
	pmenu_t("*$g_pc_3wctf", pmenu_align_t::CENTER),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("$g_pc_join_red_team", pmenu_align_t::LEFT, CTFJoinTeam1),
	pmenu_t("", pmenu_align_t::LEFT),
	pmenu_t("", pmenu_align_t::LEFT),
	pmenu_t("$g_pc_join_blue_team", pmenu_align_t::LEFT, CTFJoinTeam2),
	pmenu_t("", pmenu_align_t::LEFT),
	pmenu_t("", pmenu_align_t::LEFT),
	pmenu_t("$g_pc_chase_camera", pmenu_align_t::LEFT, CTFChaseCam),
	pmenu_t("", pmenu_align_t::LEFT),
	pmenu_t("", pmenu_align_t::LEFT),
};

const array<pmenu_t> nochasemenu = {
	pmenu_t("$g_pc_3wctf", pmenu_align_t::CENTER),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("$g_pc_no_chase", pmenu_align_t::LEFT),
	pmenu_t("", pmenu_align_t::CENTER),
	pmenu_t("$g_pc_return", pmenu_align_t::LEFT, CTFReturnToMain)
};

void CTFJoinTeam(ASEntity &ent, ctfteam_t desired_team)
{
	PMenu_Close(ent);

	ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::NOCLIENT);
	ent.client.resp.ctf_team = desired_team;
	ent.client.resp.ctf_state = 0;
	string value;
	gi_Info_ValueForKey(ent.client.pers.userinfo, "skin", value);
	CTFAssignSkin(ent, value);

	// assign a ghost if we are in match mode
	if (ctfgame.match == match_t::GAME)
	{
		if (ent.client.resp.ghost !is null)
			ent.client.resp.ghost.code = 0;
		@ent.client.resp.ghost = null;
		CTFAssignGhost(ent);
	}

	PutClientInServer(ent);

	G_PostRespawn(ent);

	gi_LocBroadcast_Print(print_type_t::HIGH, "$g_joined_team",
			   ent.client.pers.netname, CTFTeamName(desired_team));

	if (ctfgame.match == match_t::SETUP)
	{
		gi_LocCenter_Print(ent.e, "Type \"ready\" in console to ready up.\n");
	}

	// if anybody has a menu open, update it immediately
	CTFDirtyTeamMenu();
}

void CTFJoinTeam1(ASEntity &ent, pmenuhnd_t &)
{
	CTFJoinTeam(ent, ctfteam_t::TEAM1);
}

void CTFJoinTeam2(ASEntity &ent, pmenuhnd_t &)
{
	CTFJoinTeam(ent, ctfteam_t::TEAM2);
}

void CTFNoChaseCamUpdate(ASEntity &ent)
{
	array<pmenu_t> @entries = ent.client.menu.entries;

	SetGameName(entries[0]);
	SetLevelName(entries[jmenu_level]);
}

void CTFChaseCam(ASEntity &ent, pmenuhnd_t &)
{
	ASEntity @e;

	CTFJoinTeam(ent, ctfteam_t::NOTEAM);

	if (ent.client.chase_target !is null)
	{
		@ent.client.chase_target = null;
		ent.e.client.ps.pmove.pm_flags = pmflags_t(ent.e.client.ps.pmove.pm_flags & ~(pmflags_t::NO_POSITIONAL_PREDICTION | pmflags_t::NO_ANGULAR_PREDICTION));
		PMenu_Close(ent);
		return;
	}

	for (uint i = 1; i <= max_clients; i++)
	{
		@e = entities[i];
		if (e.e.inuse && e.e.solid != solid_t::NOT)
		{
			@ent.client.chase_target = e;
			PMenu_Close(ent);
			ent.client.update_chase = true;
			return;
		}
	}

	PMenu_Close(ent);
	PMenu_Open(ent, nochasemenu, -1, null, CTFNoChaseCamUpdate);
}

void CTFReturnToMain(ASEntity &ent, pmenuhnd_t &)
{
	PMenu_Close(ent);
	CTFOpenJoinMenu(ent);
}

void CTFRequestMatch(ASEntity &ent, pmenuhnd_t &)
{
	PMenu_Close(ent);

	CTFBeginElection(ent, elect_t::MATCH, format("{} has requested to switch to competition mode.\n",
				ent.client.pers.netname));
}

void CTFUpdateJoinMenu(ASEntity &ent)
{
	array<pmenu_t> @entries = ent.client.menu.entries;

	SetGameName(entries[0]);

	if (ctfgame.match >= match_t::PREGAME && matchlock.integer != 0)
	{
		entries[jmenu_red].text = "MATCH IS LOCKED";
		@entries[jmenu_red].SelectFunc = null;
		entries[jmenu_blue].text = "  (entry is not permitted)";
		@entries[jmenu_blue].SelectFunc = null;
	}
	else
	{
		if (ctfgame.match >= match_t::PREGAME)
		{
			entries[jmenu_red].text = "Join Red MATCH Team";
			entries[jmenu_blue].text = "Join Blue MATCH Team";
		}
		else
		{
			entries[jmenu_red].text = "$g_pc_join_red_team";
			entries[jmenu_blue].text = "$g_pc_join_blue_team";
		}
		@entries[jmenu_red].SelectFunc = CTFJoinTeam1;
		@entries[jmenu_blue].SelectFunc = CTFJoinTeam2;
	}

	// KEX_FIXME: what's this for?
	if (!g_teamplay_force_join.stringval.empty())
	{
		if (Q_strcasecmp(g_teamplay_force_join.stringval, "red") == 0)
		{
			entries[jmenu_blue].text.resize(0);
			@entries[jmenu_blue].SelectFunc = null;
		}
		else if (Q_strcasecmp(g_teamplay_force_join.stringval, "blue") == 0)
		{
			entries[jmenu_red].text.resize(0);
			@entries[jmenu_red].SelectFunc = null;
		}
	}

	if (ent.client.chase_target !is null)
		entries[jmenu_chase].text = "$g_pc_leave_chase_camera";
	else
		entries[jmenu_chase].text = "$g_pc_chase_camera";

	SetLevelName(entries[jmenu_level]);

	uint num1 = 0, num2 = 0;
	for (uint i = 0; i < max_clients; i++)
	{
        ASEntity @e = players[i];
		if (!e.e.inuse)
			continue;
		if (e.client.resp.ctf_team == ctfteam_t::TEAM1)
			num1++;
		else if (e.client.resp.ctf_team == ctfteam_t::TEAM2)
			num2++;
	}

	switch (ctfgame.match)
	{
	case match_t::NONE:
		entries[jmenu_match].text.resize(0);
		break;

	case match_t::SETUP:
		entries[jmenu_match].text = "*MATCH SETUP IN PROGRESS";
		break;

	case match_t::PREGAME:
		entries[jmenu_match].text = "*MATCH STARTING";
		break;

	case match_t::GAME:
		entries[jmenu_match].text = "*MATCH IN PROGRESS";
		break;

	default:
		break;
	}

	if (!entries[jmenu_red].text.empty())
	{
		entries[jmenu_red + 1].text = "$g_pc_playercount";
		entries[jmenu_red + 1].text_arg1 = format("{}", num1);
	}
	else
	{
		entries[jmenu_red + 1].text.resize(0);
		entries[jmenu_red + 1].text_arg1.resize(0);
	}
	if (!entries[jmenu_blue].text.empty())
	{
		entries[jmenu_blue + 1].text = "$g_pc_playercount";
		entries[jmenu_blue + 1].text_arg1 = format("{}", num2);
	}
	else
	{
		entries[jmenu_blue + 1].text.resize(0);
		entries[jmenu_blue + 1].text_arg1.resize(0);
	}

	entries[jmenu_reqmatch].text.resize(0);
	@entries[jmenu_reqmatch].SelectFunc = null;
	if (competition.integer != 0 && ctfgame.match < match_t::SETUP)
	{
		entries[jmenu_reqmatch].text = "Request Match";
		@entries[jmenu_reqmatch].SelectFunc = CTFRequestMatch;
	}
}

void CTFOpenJoinMenu(ASEntity &ent)
{
	uint num1 = 0, num2 = 0;
	for (uint i = 0; i < max_clients; i++)
	{
        ASEntity @e = players[i];
		if (!e.e.inuse)
			continue;
		if (e.client.resp.ctf_team == ctfteam_t::TEAM1)
			num1++;
		else if (e.client.resp.ctf_team == ctfteam_t::TEAM2)
			num2++;
	}

	int team;

	if (num1 > num2)
		team = ctfteam_t::TEAM1;
	else if (num2 > num1)
		team = ctfteam_t::TEAM2;
	team = brandom() ? ctfteam_t::TEAM1 : ctfteam_t::TEAM2;

	PMenu_Open(ent, joinmenu, team, null, CTFUpdateJoinMenu);
}

bool CTFStartClient(ASEntity &ent)
{
	if (!G_TeamplayEnabled())
		return false;

	if (ent.client.resp.ctf_team != ctfteam_t::NOTEAM)
		return false;

	if (((ent.e.svflags & svflags_t::BOT) == 0 && g_teamplay_force_join.integer == 0) || ctfgame.match >= match_t::SETUP)
	{
		// start as 'observer'
		ent.movetype = movetype_t::NOCLIP;
		ent.e.solid = solid_t::NOT;
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
		ent.client.resp.ctf_team = ctfteam_t::NOTEAM;
		ent.client.resp.spectator = true;
		ent.e.client.ps.gunindex = 0;
		ent.e.client.ps.gunskin = 0;
		gi_linkentity(ent.e);

		CTFOpenJoinMenu(ent);
		return true;
	}
	return false;
}

void CTFObserver(ASEntity &ent)
{
	if (!G_TeamplayEnabled() || g_teamplay_force_join.integer != 0)
		return;

	// start as 'observer'
	if (ent.movetype == movetype_t::NOCLIP)
		CTFPlayerResetGrapple(ent);

	CTFDeadDropFlag(ent);
	CTFDeadDropTech(ent);

	ent.deadflag = false;
	ent.movetype = movetype_t::NOCLIP;
	ent.e.solid = solid_t::NOT;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.client.resp.ctf_team = ctfteam_t::NOTEAM;
	ent.e.client.ps.gunindex = 0;
	ent.e.client.ps.gunskin = 0;
	ent.client.resp.score = 0;
	PutClientInServer(ent);
}

bool CTFInMatch()
{
	if (ctfgame.match > match_t::NONE)
		return true;
	return false;
}

bool CTFCheckRules()
{
	int		 t;
	uint     i, j;
	string 	 text;
	ASEntity @ent;

	if (ctfgame.election != elect_t::NONE && ctfgame.electtime <= level.time)
	{
		gi_LocBroadcast_Print(print_type_t::CHAT, "Election timed out and has been cancelled.\n");
		ctfgame.election = elect_t::NONE;
	}

	if (ctfgame.match != match_t::NONE)
	{
		t = (ctfgame.matchtime - level.time).secondsi();

		// no team warnings in match mode
		ctfgame.warnactive = ctfteam_t::NOTEAM;

		if (t <= 0)
		{ // time ended on something
			switch (ctfgame.match)
			{
			case match_t::SETUP:
				// go back to normal mode
				if (competition.integer < 3)
				{
					ctfgame.match = match_t::NONE;
					gi_cvar_set("competition", "1");
					CTFResetAllPlayers();
				}
				else
				{
					// reset the time
					ctfgame.matchtime = level.time + time_min(matchsetuptime.value);
				}
				return false;

			case match_t::PREGAME:
				// match started!
				CTFStartMatch();
				gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("misc/tele_up.wav"), 1, ATTN_NONE, 0);
				return false;

			case match_t::GAME:
				// match ended!
				CTFEndMatch();
				gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("misc/bigtele.wav"), 1, ATTN_NONE, 0);
				return false;

			default:
				break;
			}
		}

		if (t == ctfgame.lasttime)
			return false;

		ctfgame.lasttime = t;

		switch (ctfgame.match)
		{
		case match_t::SETUP:
            j = 0; i = 1;
			for (; i <= max_clients; i++)
			{
				@ent = entities[i];
				if (!ent.e.inuse)
					continue;
				if (ent.client.resp.ctf_team != ctfteam_t::NOTEAM &&
					!ent.client.resp.ready)
					j++;
			}

			if (competition.integer < 3)
				text = format("{:02}:{:02} SETUP: {} not ready", t / 60, t % 60, j);
			else
				text = format("SETUP: {} not ready", j);

			gi_configstring(game_configstring_id_t::CTF_MATCH, text);
			break;

		case match_t::PREGAME:
			text = format("{:02}:{:02} UNTIL START", t / 60, t % 60);
			gi_configstring(game_configstring_id_t::CTF_MATCH, text);

			if (t <= 10 && !ctfgame.countdown)
			{
				ctfgame.countdown = true;
				gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("world/10_0.wav"), 1, ATTN_NONE, 0);
			}
			break;

		case match_t::GAME:
			text = format("{:02}:{:02} MATCH", t / 60, t % 60);
			gi_configstring(game_configstring_id_t::CTF_MATCH, text);
			if (t <= 10 && !ctfgame.countdown)
			{
				ctfgame.countdown = true;
				gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("world/10_0.wav"), 1, ATTN_NONE, 0);
			}
			break;

		default:
			break;
		}
		return false;
	}
	else
	{
		int team1 = 0, team2 = 0;

		if (level.time == time_sec(ctfgame.lasttime))
			return false;
		ctfgame.lasttime = level.time.secondsi();
		// this is only done in non-match (public) mode

		if (warn_unbalanced.integer != 0)
		{
			// count up the team totals
			for (i = 1; i <= max_clients; i++)
			{
				@ent = entities[i];
				if (!ent.e.inuse)
					continue;
				if (ent.client.resp.ctf_team == ctfteam_t::TEAM1)
					team1++;
				else if (ent.client.resp.ctf_team == ctfteam_t::TEAM2)
					team2++;
			}

			if (team1 - team2 >= 2 && team2 >= 2)
			{
				if (ctfgame.warnactive != ctfteam_t::TEAM1)
				{
					ctfgame.warnactive = ctfteam_t::TEAM1;
					gi_configstring(game_configstring_id_t::CTF_TEAMINFO, "WARNING: Red has too many players");
				}
			}
			else if (team2 - team1 >= 2 && team1 >= 2)
			{
				if (ctfgame.warnactive != ctfteam_t::TEAM2)
				{
					ctfgame.warnactive = ctfteam_t::TEAM2;
					gi_configstring(game_configstring_id_t::CTF_TEAMINFO, "WARNING: Blue has too many players");
				}
			}
			else
				ctfgame.warnactive = ctfteam_t::NOTEAM;
		}
		else
			ctfgame.warnactive = ctfteam_t::NOTEAM;
	}

	if (capturelimit.integer != 0 &&
		(ctfgame.team1 >= capturelimit.integer ||
		 ctfgame.team2 >= capturelimit.integer))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "$g_capturelimit_hit");
		return true;
	}
	return false;
}

/*--------------------------------------------------------------------------
 * just here to help old map conversions
 *--------------------------------------------------------------------------*/

void old_teleporter_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @dest;
	vec3_t	 forward;

	if (other.client is null)
		return;
	@dest = G_PickTarget(self.target);
	if (dest is null)
	{
		gi_Com_Print("Couldn't find destination\n");
		return;
	}

	// ZOID
	CTFPlayerResetGrapple(other);
	// ZOID

	// unlink to make sure it can't possibly interfere with KillBox
	gi_unlinkentity(other.e);

	other.e.origin = dest.e.origin;
	other.e.old_origin = dest.e.origin;
	//	other->s.origin[2] += 10;

	// clear the velocity and hold them in place briefly
	other.velocity = vec3_origin;
	other.e.client.ps.pmove.pm_time = 160; // hold time
	other.e.client.ps.pmove.pm_flags = pmflags_t(other.e.client.ps.pmove.pm_flags | pmflags_t::TIME_TELEPORT);

	// draw the teleport splash at source and on the player
	self.enemy.e.event = entity_event_t::PLAYER_TELEPORT;
	other.e.event = entity_event_t::PLAYER_TELEPORT;

	// set angles
	other.e.client.ps.pmove.delta_angles = dest.e.angles - other.client.resp.cmd_angles;

	other.e.angles.pitch = 0;
	other.e.angles.yaw = dest.e.angles.yaw;
	other.e.angles.roll = 0;
	other.e.client.ps.viewangles = dest.e.angles;
	other.client.v_angle = dest.e.angles;

	// give a little forward velocity
	AngleVectors(other.client.v_angle, forward);
	other.velocity = forward * 200;

	gi_linkentity(other.e);

	// kill anything at the destination
	if (!KillBox(other, true))
	{
	}

	// [Paril-KEX] move sphere, if we own it
	if (other.client.owned_sphere !is null)
	{
		ASEntity @sphere = other.client.owned_sphere;
		sphere.e.origin = other.e.origin;
		sphere.e.origin.z = other.e.absmax.z;
		sphere.e.angles.yaw = other.e.angles.yaw;
		gi_linkentity(sphere.e);
	}
}

/*QUAKED trigger_ctf_teleport (0.5 0.5 0.5) ?
Players touching this will be teleported
*/
void SP_trigger_ctf_teleport(ASEntity &ent)
{
	ASEntity @s;
	int		 i;

	if (ent.target.empty())
	{
		gi_Com_Print("teleporter without a target.\n");
		G_FreeEdict(ent);
		return;
	}

	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.e.solid = solid_t::TRIGGER;
	@ent.touch = old_teleporter_touch;
	gi_setmodel(ent.e, ent.model);
	gi_linkentity(ent.e);

	// noise maker and splash effect dude
	@s = G_Spawn();
	@ent.enemy = s;
	for (i = 0; i < 3; i++)
		s.e.origin[i] = ent.e.mins[i] + (ent.e.maxs[i] - ent.e.mins[i]) / 2;
	s.e.sound = gi_soundindex("world/hum1.wav");
	gi_linkentity(s.e);
}

/*QUAKED info_ctf_teleport_destination (0.5 0.5 0.5) (-16 -16 -24) (16 16 32)
Point trigger_teleports at these.
*/
void SP_info_ctf_teleport_destination(ASEntity &ent)
{
	ent.e.origin.z += 16;
}

/*----------------------------------------------------------------------------------*/
/* ADMIN */

class admin_settings_t
{
	float matchlen;
	float matchsetuplen;
	float matchstartlen;
	bool weaponsstay;
	bool instantitems;
	bool quaddrop;
	bool instantweap;
	bool matchlock;
};


void CTFAdmin_SettingsApply(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	if (settings.matchlen != matchtime.value)
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} changed the match length to {} minutes.\n",
				   ent.client.pers.netname, settings.matchlen);
		if (ctfgame.match == match_t::GAME)
		{
			// in the middle of a match, change it on the fly
			ctfgame.matchtime = (ctfgame.matchtime - time_min(matchtime.value)) + time_min(settings.matchlen);
		}
		gi_cvar_set("matchtime", format("{}", settings.matchlen));
	}

	if (settings.matchsetuplen != matchsetuptime.value)
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} changed the match setup time to {} minutes.\n",
				   ent.client.pers.netname, settings.matchsetuplen);
		if (ctfgame.match == match_t::SETUP)
		{
			// in the middle of a match, change it on the fly
			ctfgame.matchtime = (ctfgame.matchtime - time_min(matchsetuptime.value)) + time_min(settings.matchsetuplen);
		}
		gi_cvar_set("matchsetuptime", format("{}", settings.matchsetuplen));
	}

	if (settings.matchstartlen != matchstarttime.value)
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} changed the match start time to {} seconds.\n",
				   ent.client.pers.netname, settings.matchstartlen);
		if (ctfgame.match == match_t::PREGAME)
		{
			// in the middle of a match, change it on the fly
			ctfgame.matchtime = (ctfgame.matchtime - time_sec(matchstarttime.value)) + time_sec(settings.matchstartlen);
		}
		gi_cvar_set("matchstarttime", format("{}", settings.matchstartlen));
	}

	if (settings.weaponsstay != (g_dm_weapons_stay.integer != 0))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} turned {} weapons stay.\n",
				   ent.client.pers.netname, settings.weaponsstay ? "on" : "off");
		gi_cvar_set("g_dm_weapons_stay", settings.weaponsstay ? "1" : "0");
	}

	if (settings.instantitems != (g_dm_instant_items.integer != 0))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} turned {} instant items.\n",
				   ent.client.pers.netname, settings.instantitems ? "on" : "off");
		gi_cvar_set("g_dm_instant_items", settings.instantitems ? "1" : "0");
	}

	if (settings.quaddrop != (g_dm_no_quad_drop.integer == 0))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} turned {} quad drop.\n",
				   ent.client.pers.netname, settings.quaddrop ? "on" : "off");
		gi_cvar_set("g_dm_no_quad_drop", !settings.quaddrop ? "1" : "0");
	}

	if (settings.instantweap != (g_instant_weapon_switch.integer != 0))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} turned {} instant weapons.\n",
				   ent.client.pers.netname, settings.instantweap ? "on" : "off");
		gi_cvar_set("g_instant_weapon_switch", settings.instantweap ? "1" : "0");
	}

	if (settings.matchlock != (matchlock.integer != 0))
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} turned {} match lock.\n",
				   ent.client.pers.netname, settings.matchlock ? "on" : "off");
		gi_cvar_set("matchlock", settings.matchlock ? "1" : "0");
	}

	PMenu_Close(ent);
	CTFOpenAdminMenu(ent);
}

void CTFAdmin_SettingsCancel(ASEntity &ent, pmenuhnd_t &p)
{
	PMenu_Close(ent);
	CTFOpenAdminMenu(ent);
}

void CTFAdmin_ChangeMatchLen(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.matchlen = fmod(settings.matchlen, 60) + 5;
	if (settings.matchlen < 5)
		settings.matchlen = 5;

	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeMatchSetupLen(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.matchsetuplen = fmod(settings.matchsetuplen, 60) + 5;
	if (settings.matchsetuplen < 5)
		settings.matchsetuplen = 5;

	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeMatchStartLen(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.matchstartlen = fmod(settings.matchstartlen, 600) + 10;
	if (settings.matchstartlen < 20)
		settings.matchstartlen = 20;

	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeWeapStay(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.weaponsstay = !settings.weaponsstay;
	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeInstantItems(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.instantitems = !settings.instantitems;
	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeQuadDrop(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.quaddrop = !settings.quaddrop;
	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeInstantWeap(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.instantweap = !settings.instantweap;
	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_ChangeMatchLock(ASEntity &ent, pmenuhnd_t &p)
{
	admin_settings_t @settings;
    p.arg.retrieve(@settings);

	settings.matchlock = !settings.matchlock;
	CTFAdmin_UpdateSettings(ent, p);
}

void CTFAdmin_UpdateSettings(ASEntity &ent, pmenuhnd_t &setmenu)
{
	int				  i = 2;
	admin_settings_t @settings;
    setmenu.arg.retrieve(@settings);

	PMenu_UpdateEntry(setmenu.entries[i], format("Match Len:       {:2} mins", settings.matchlen), pmenu_align_t::LEFT, CTFAdmin_ChangeMatchLen);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Match Setup Len: {:2} mins", settings.matchsetuplen), pmenu_align_t::LEFT, CTFAdmin_ChangeMatchSetupLen);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Match Start Len: {:2} secs", settings.matchstartlen), pmenu_align_t::LEFT, CTFAdmin_ChangeMatchStartLen);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Weapons Stay:    {}", settings.weaponsstay ? "Yes" : "No"), pmenu_align_t::LEFT, CTFAdmin_ChangeWeapStay);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Instant Items:   {}", settings.instantitems ? "Yes" : "No"), pmenu_align_t::LEFT, CTFAdmin_ChangeInstantItems);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Quad Drop:       {}", settings.quaddrop ? "Yes" : "No"), pmenu_align_t::LEFT, CTFAdmin_ChangeQuadDrop);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Instant Weapons: {}", settings.instantweap ? "Yes" : "No"), pmenu_align_t::LEFT, CTFAdmin_ChangeInstantWeap);
	i++;

	PMenu_UpdateEntry(setmenu.entries[i], format("Match Lock:      {}", settings.matchlock ? "Yes" : "No"), pmenu_align_t::LEFT, CTFAdmin_ChangeMatchLock);
	i++;

	PMenu_Update(ent);
}

const array<pmenu_t> def_setmenu = {
	pmenu_t("*Settings Menu", pmenu_align_t::CENTER, null),
	pmenu_t("", pmenu_align_t::CENTER, null),
	pmenu_t("", pmenu_align_t::LEFT, null), // int matchlen;
	pmenu_t("", pmenu_align_t::LEFT, null), // int matchsetuplen;
	pmenu_t("", pmenu_align_t::LEFT, null), // int matchstartlen;
	pmenu_t("", pmenu_align_t::LEFT, null), // bool weaponsstay;
	pmenu_t("", pmenu_align_t::LEFT, null), // bool instantitems;
	pmenu_t("", pmenu_align_t::LEFT, null), // bool quaddrop;
	pmenu_t("", pmenu_align_t::LEFT, null), // bool instantweap;
	pmenu_t("", pmenu_align_t::LEFT, null), // bool matchlock;
	pmenu_t("", pmenu_align_t::LEFT, null),
	pmenu_t("Apply", pmenu_align_t::LEFT, CTFAdmin_SettingsApply),
	pmenu_t("Cancel", pmenu_align_t::LEFT, CTFAdmin_SettingsCancel)
};

void CTFAdmin_Settings(ASEntity &ent, pmenuhnd_t &p)
{
	pmenuhnd_t	   @menu;

	PMenu_Close(ent);

	admin_settings_t settings;

	settings.matchlen = matchtime.value;
	settings.matchsetuplen = matchsetuptime.value;
	settings.matchstartlen = matchstarttime.value;
	settings.weaponsstay = g_dm_weapons_stay.integer != 0;
	settings.instantitems = g_dm_instant_items.integer != 0;
	settings.quaddrop = g_dm_no_quad_drop.integer == 0;
	settings.instantweap = g_instant_weapon_switch.integer != 0;
	settings.matchlock = matchlock.integer != 0;

    any arg;
    arg.store(@settings);

	@menu = PMenu_Open(ent, def_setmenu, -1, arg, null);
	CTFAdmin_UpdateSettings(ent, menu);
}

void CTFAdmin_MatchSet(ASEntity &ent, pmenuhnd_t &p)
{
	PMenu_Close(ent);

	if (ctfgame.match == match_t::SETUP)
	{
		gi_LocBroadcast_Print(print_type_t::CHAT, "Match has been forced to start.\n");
		ctfgame.match = match_t::PREGAME;
		ctfgame.matchtime = level.time + time_sec(matchstarttime.value);
		gi_positioned_sound(world.e.origin, world.e, soundchan_t::AUTO | soundchan_t::RELIABLE, gi_soundindex("misc/talk1.wav"), 1, ATTN_NONE, 0);
		ctfgame.countdown = false;
	}
	else if (ctfgame.match == match_t::GAME)
	{
		gi_LocBroadcast_Print(print_type_t::CHAT, "Match has been forced to terminate.\n");
		ctfgame.match = match_t::SETUP;
		ctfgame.matchtime = level.time + time_min(matchsetuptime.value);
		CTFResetAllPlayers();
	}
}

void CTFAdmin_MatchMode(ASEntity &ent, pmenuhnd_t &p)
{
	PMenu_Close(ent);

	if (ctfgame.match != match_t::SETUP)
	{
		if (competition.integer < 3)
			gi_cvar_set("competition", "2");
		ctfgame.match = match_t::SETUP;
		CTFResetAllPlayers();
	}
}

void CTFAdmin_Reset(ASEntity &ent, pmenuhnd_t &p)
{
	PMenu_Close(ent);

	// go back to normal mode
	gi_LocBroadcast_Print(print_type_t::CHAT, "Match mode has been terminated, reseting to normal game.\n");
	ctfgame.match = match_t::NONE;
	gi_cvar_set("competition", "1");
	CTFResetAllPlayers();
}

void CTFAdmin_Cancel(ASEntity &ent, pmenuhnd_t &p)
{
	PMenu_Close(ent);
}

const array<pmenu_t> adminmenu_base = {
	pmenu_t("*Administration Menu", pmenu_align_t::CENTER, null),
	pmenu_t("", pmenu_align_t::CENTER, null), // blank
	pmenu_t("Settings", pmenu_align_t::LEFT, CTFAdmin_Settings),
	pmenu_t("", pmenu_align_t::LEFT, null),
	pmenu_t("", pmenu_align_t::LEFT, null),
	pmenu_t("Cancel", pmenu_align_t::LEFT, CTFAdmin_Cancel),
	pmenu_t("", pmenu_align_t::CENTER, null),
};

void CTFOpenAdminMenu(ASEntity &ent)
{
    array<pmenu_t> adminmenu = adminmenu_base;

	adminmenu[3].text.resize(0);
	@adminmenu[3].SelectFunc = null;
	adminmenu[4].text.resize(0);
	@adminmenu[4].SelectFunc = null;
	if (ctfgame.match == match_t::SETUP)
	{
		adminmenu[3].text = "Force start match";
		@adminmenu[3].SelectFunc = CTFAdmin_MatchSet;
		adminmenu[4].text = "Reset to pickup mode";
		@adminmenu[4].SelectFunc = CTFAdmin_Reset;
	}
	else if (ctfgame.match == match_t::GAME || ctfgame.match == match_t::PREGAME)
	{
		adminmenu[3].text = "Cancel match";
		@adminmenu[3].SelectFunc = CTFAdmin_MatchSet;
	}
	else if (ctfgame.match == match_t::NONE && competition.integer  != 0)
	{
		adminmenu[3].text = "Switch to match mode";
		@adminmenu[3].SelectFunc = CTFAdmin_MatchMode;
	}

	//	if (ent->client->menu)
	//		PMenu_Close(ent->client->menu);

	PMenu_Open(ent, adminmenu, -1, null, null);
}

void CTFAdmin(ASEntity &ent)
{
	if (allow_admin.integer == 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Administration is disabled\n");
		return;
	}

	if (gi_argc() > 1 && !admin_password.stringval.empty() &&
		!ent.client.resp.admin && admin_password.stringval == gi_argv(1))
	{
		ent.client.resp.admin = true;
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} has become an admin.\n", ent.client.pers.netname);
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Type 'admin' to access the adminstration menu.\n");
	}

	if (!ent.client.resp.admin)
	{
		CTFBeginElection(ent, elect_t::ADMIN, format("{} has requested admin rights.\n",
					ent.client.pers.netname));
		return;
	}

	if (ent.client.menu !is null)
		PMenu_Close(ent);

	CTFOpenAdminMenu(ent);
}

/*----------------------------------------------------------------*/

void CTFStats(ASEntity &ent)
{
	if (!G_TeamplayEnabled())
		return;

	ghost_t @g;
	string text;
	ASEntity @e2;

	text.resize(0);

	if (ctfgame.match == match_t::SETUP)
	{
		for (uint i = 1; i <= max_clients; i++)
		{
			@e2 = entities[i];
			if (!e2.e.inuse)
				continue;
			if (!e2.client.resp.ready && e2.client.resp.ctf_team != ctfteam_t::NOTEAM)
			{
				string str = format("{} is not ready.\n", e2.client.pers.netname);

				if (text.length() + str.length() < MAX_CTF_STAT_LENGTH - 50)
					text += str;
			}
		}
	}

	uint i;
	for (i = 0; i < max_clients; i++)
    {
        @g = ctfgame.ghosts[i];
		if (g.ent !is null)
			break;
    }

	if (i == max_clients)
	{
		if (text.empty())
			text = "No statistics available.\n";

		gi_Client_Print(ent.e, print_type_t::HIGH, text);
		return;
	}

	text += "  #|Name            |Score|Kills|Death|BasDf|CarDf|Effcy|\n";

	for (i = 0; i < max_clients; i++)
	{
        @g = ctfgame.ghosts[i];

		if (g.netname.empty())
			continue;

		int e;

		if (g.deaths + g.kills == 0)
			e = 50;
		else
			e = g.kills * 100 / (g.kills + g.deaths);
		string str = format("{:3}|{:<16.16}|{:5}|{:5}|{:5}|{:5}|{:5}|{:4}%|\n",
			g.number,
			g.netname,
			g.score,
			g.kills,
			g.deaths,
			g.basedef,
			g.carrierdef,
			e);

		if (text.length() + str.length() > MAX_CTF_STAT_LENGTH - 50)
		{
			text += "And more...\n";
			break;
		}

		text += str;
	}

	gi_Client_Print(ent.e, print_type_t::HIGH, text);
}

void CTFPlayerList(ASEntity &ent)
{
	string text;
	ASEntity @e2;

	// number, name, connect time, ping, score, admin
	text.resize(0);

	for (uint i = 1; i <= max_clients; i++)
	{
		@e2 = entities[i];
		if (!e2.e.inuse)
			continue;

		string str = format("{:3} {:<16.16} {:02}:{:02} {:4} {:3}{}{}\n",
					i,
					e2.client.pers.netname,
					(level.time - e2.client.resp.entertime).milliseconds / 60000,
					((level.time - e2.client.resp.entertime).milliseconds % 60000) / 1000,
					e2.e.client.ping,
					e2.client.resp.score,
					(ctfgame.match == match_t::SETUP || ctfgame.match == match_t::PREGAME) ? (e2.client.resp.ready ? " (ready)" : " (notready)") : "",
					e2.client.resp.admin ? " (admin)" : "");

		if (text.length() + str.length() > MAX_CTF_STAT_LENGTH - 50)
		{
			text += "And more...\n";
			break;
		}

		text += str;
	}

	gi_Client_Print(ent.e, print_type_t::HIGH, text);
}

void CTFWarp(ASEntity &ent)
{
	if (gi_argc() < 2)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Where do you want to warp to?\n");
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Available levels are: {}\n", warp_list.stringval);
		return;
	}

    string map = gi_argv(1);
    tokenizer_t parser(warp_list.stringval);

	while (parser.next())
		if (parser.token_iequals(map))
			break;

	if (!parser.has_token)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Unknown CTF level.\n");
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Available levels are: {}\n", warp_list.stringval);
		return;
	}

	if (ent.client.resp.admin)
	{
		gi_LocBroadcast_Print(print_type_t::HIGH, "{} is warping to level {}.\n",
				   ent.client.pers.netname, map);
		level.forcemap = map;
		EndDMLevel();
		return;
	}

	if (CTFBeginElection(ent, elect_t::MAP, format("{} has requested warping to level {}.\n",
			ent.client.pers.netname, map)))
		ctfgame.elevel = map;
}

void CTFBoot(ASEntity &ent)
{
	ASEntity @targ;

	if (!ent.client.resp.admin)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "You are not an admin.\n");
		return;
	}

	if (gi_argc() < 2)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Who do you want to kick?\n");
		return;
	}

    string n = gi_argv(1);

	if (n[0] < '0' && n[0] > '9')
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Specify the player number to kick.\n");
		return;
	}

	uint i = parseUInt(n);
	if (i < 1 || i > max_clients)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Invalid player number.\n");
		return;
	}

	@targ = entities[i];
	if (!targ.e.inuse)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "That player number is not connected.\n");
		return;
	}

	gi_AddCommandString(format("kick {}\n", i - 1));
}

void CTFSetPowerUpEffect(ASEntity &ent, effects_t def)
{
	if (ent.client.resp.ctf_team == ctfteam_t::TEAM1 && def == effects_t::QUAD)
		ent.e.effects = effects_t(ent.e.effects | effects_t::PENT); // red
	else if (ent.client.resp.ctf_team == ctfteam_t::TEAM2 && def == effects_t::PENT)
		ent.e.effects = effects_t(ent.e.effects | effects_t::QUAD); // blue
	else
		ent.e.effects = effects_t(ent.e.effects | def);
}
