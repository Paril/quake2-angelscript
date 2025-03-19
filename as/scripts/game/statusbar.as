// easy statusbar wrapper
class statusbar_t
{
	string sb;
	
	statusbar_t &yb(int32 offset) { sb += format("yb {} ", offset); return this; }
	statusbar_t &yt(int32 offset) { sb += format("yt {} ", offset); return this; }
	statusbar_t &yv(int32 offset) { sb += format("yv {} ", offset); return this; }
	statusbar_t &xl(int32 offset) { sb += format("xl {} ", offset); return this; }
	statusbar_t &xr(int32 offset) { sb += format("xr {} ", offset); return this; }
	statusbar_t &xv(int32 offset) { sb += format("xv {} ", offset); return this; }

	statusbar_t &ifstat(player_stat_t stat) { sb += format("if {} ", int(stat)); return this; }
	statusbar_t &endifstat() { sb += "endif "; return this; }

	statusbar_t &pic(player_stat_t stat) { sb += format("pic {} ", int(stat)); return this; }
	statusbar_t &picn(const ::string &in icon) { sb += format("picn {} ", icon); return this; }

	statusbar_t &anum() { sb += "anum "; return this; }
	statusbar_t &rnum() { sb += "rnum "; return this; }
	statusbar_t &hnum() { sb += "hnum "; return this; }
	statusbar_t &num(int32 width, player_stat_t stat) { sb += format("num {} {} ", width, int(stat)); return this; }
	
	statusbar_t &loc_stat_string(player_stat_t stat) { sb += format("loc_stat_string {} ", int(stat)); return this; }
	statusbar_t &loc_stat_rstring(player_stat_t stat) { sb += format("loc_stat_rstring {} ", int(stat)); return this; }
	statusbar_t &stat_string(player_stat_t stat) { sb += format("stat_string {} ", int(stat)); return this; }
	statusbar_t &loc_stat_cstring2(player_stat_t stat) { sb += format("loc_stat_cstring2 {} ", int(stat)); return this; }
	statusbar_t &string2(const ::string &in str)
	{
		if (str[0] != '"' && (str.findFirstOf(" \n") != -1))
			sb += format("string2 \"{}\" ", str);
		else
			sb += format("string2 {} ", str);
		return this;
	}
	statusbar_t &string(const ::string &in str)
	{
		if (str[0] != '"' && (str.findFirstOf(" \n") != -1))
			sb += format("string \"{}\" ", str);
		else
			sb += format("string {} ", str);
		return this;
	}
	statusbar_t &loc_rstring(const ::string &in str)
	{
		if (str[0] != '"' && (str.findFirstOf(" \n") != -1))
			sb += format("loc_rstring 0 \"{}\" ", str);
		else
			sb += format("loc_rstring 0 {} ", str);
		return this;
	}

	statusbar_t &lives_num(player_stat_t stat) { sb += format("lives_num {} ", int(stat)); return this; }
	statusbar_t &stat_pname(player_stat_t stat) { sb += format("stat_pname {} ", int(stat)); return this; }

	statusbar_t &health_bars() { sb += "health_bars "; return this; }
	statusbar_t &story() { sb += "story "; return this; }
};

// create & set the statusbar string for the current gamemode
void G_InitStatusbar()
{
	statusbar_t sb;

	// ---- shared stuff that every gamemode uses ----
	sb.yb(-24);

	// health
	sb.xv(0).hnum().xv(50).pic(player_stat_t::HEALTH_ICON);

	// ammo
	sb.ifstat(player_stat_t::AMMO_ICON).xv(100).anum().xv(150).pic(player_stat_t::AMMO_ICON).endifstat();

	// armor
	sb.ifstat(player_stat_t::ARMOR_ICON).xv(200).rnum().xv(250).pic(player_stat_t::ARMOR_ICON).endifstat();

	// selected item
	sb.ifstat(player_stat_t::SELECTED_ICON).xv(296).pic(player_stat_t::SELECTED_ICON).endifstat();

	sb.yb(-50);

	// picked up item
	sb.ifstat(player_stat_t::PICKUP_ICON).xv(0).pic(player_stat_t::PICKUP_ICON).xv(26).yb(-42).loc_stat_string(player_stat_t::PICKUP_STRING).yb(-50).endifstat();

	// selected item name
	sb.ifstat(player_stat_t::SELECTED_ITEM_NAME).yb(-34).xv(319).loc_stat_rstring(player_stat_t::SELECTED_ITEM_NAME).yb(-58).endifstat();

	// timer
	sb.ifstat(player_stat_t::TIMER_ICON).xv(262).num(2, player_stat_t::TIMER).xv(296).pic(player_stat_t::TIMER_ICON).endifstat();
	
	sb.yb(-50);

	// help / weapon icon
	sb.ifstat(player_stat_t::HELPICON).xv(150).pic(player_stat_t::HELPICON).endifstat();

	// ---- gamemode-specific stuff ----
	if (deathmatch.integer == 0)
	{
		// SP/coop
		// key display
		// move up if the timer is active
		// FIXME: ugly af
		sb.ifstat(player_stat_t::TIMER_ICON).yb(-76).endifstat();
		sb.ifstat(player_stat_t::SELECTED_ITEM_NAME)
			.yb(-58)
			.ifstat(player_stat_t::TIMER_ICON)
				.yb(-84)
			.endifstat()
		.endifstat();
		sb.ifstat(player_stat_t::KEY_A).xv(296).pic(player_stat_t::KEY_A).endifstat();
		sb.ifstat(player_stat_t::KEY_B).xv(272).pic(player_stat_t::KEY_B).endifstat();
		sb.ifstat(player_stat_t::KEY_C).xv(248).pic(player_stat_t::KEY_C).endifstat();

		if (coop.integer != 0)
		{
			// top of screen coop respawn display
			sb.ifstat(player_stat_t::COOP_RESPAWN).xv(0).yt(0).loc_stat_cstring2(player_stat_t::COOP_RESPAWN).endifstat();

			// coop lives
			sb.ifstat(player_stat_t::LIVES).xr(-16).yt(2).lives_num(player_stat_t::LIVES).xr(0).yt(28).loc_rstring("$g_lives").endifstat();
		}

		sb.ifstat(player_stat_t::HEALTH_BARS).yt(24).health_bars().endifstat();
	}
	else if (G_TeamplayEnabled())
	{
		CTFPrecache();

		// ctf/tdm
		// red team
		sb.yb(-110).ifstat(player_stat_t::CTF_TEAM1_PIC).xr(-26).pic(player_stat_t::CTF_TEAM1_PIC).endifstat().xr(-78).num(3, player_stat_t::CTF_TEAM1_CAPS);
		// joined overlay
		sb.ifstat(player_stat_t::CTF_JOINED_TEAM1_PIC).yb(-112).xr(-28).pic(player_stat_t::CTF_JOINED_TEAM1_PIC).endifstat();

		// blue team
		sb.yb(-83).ifstat(player_stat_t::CTF_TEAM2_PIC).xr(-26).pic(player_stat_t::CTF_TEAM2_PIC).endifstat().xr(-78).num(3, player_stat_t::CTF_TEAM2_CAPS);
		// joined overlay
		sb.ifstat(player_stat_t::CTF_JOINED_TEAM2_PIC).yb(-85).xr(-28).pic(player_stat_t::CTF_JOINED_TEAM2_PIC).endifstat();

		if (ctf.integer != 0)
		{
			// have flag graph
			sb.ifstat(player_stat_t::CTF_FLAG_PIC).yt(26).xr(-24).pic(player_stat_t::CTF_FLAG_PIC).endifstat();
		}

		// id view state
		sb.ifstat(player_stat_t::CTF_ID_VIEW).xv(112).yb(-58).stat_pname(player_stat_t::CTF_ID_VIEW).endifstat();

		// id view color
		sb.ifstat(player_stat_t::CTF_ID_VIEW_COLOR).xv(96).yb(-58).pic(player_stat_t::CTF_ID_VIEW_COLOR).endifstat();

		if (ctf.integer != 0)
		{
			// match
			sb.ifstat(player_stat_t::CTF_MATCH).xl(0).yb(-78).stat_string(player_stat_t::CTF_MATCH).endifstat();
		}

		// team info
		sb.ifstat(player_stat_t::CTF_TEAMINFO).xl(0).yb(-88).stat_string(player_stat_t::CTF_TEAMINFO).endifstat();
	}
	else
	{ 
		// dm
		// frags
		sb.xr(-50).yt(2).num(3, player_stat_t::FRAGS);

		// spectator
		sb.ifstat(player_stat_t::SPECTATOR).xv(0).yb(-58).string2("SPECTATOR MODE").endifstat();

		// chase cam
		sb.ifstat(player_stat_t::CHASE).xv(0).yb(-68).string("CHASING").xv(64).stat_string(player_stat_t::CHASE).endifstat();
	}

	// ---- more shared stuff ----
	if (deathmatch.integer != 0)
	{
		// tech
		sb.ifstat(player_stat_t::CTF_TECH).yb(-137).xr(-26).pic(player_stat_t::CTF_TECH).endifstat();
	}
	else
	{
		sb.story();
	}

    sb.yb(-16);
    sb.xl(16);
    sb.string("AS SV");

	gi_configstring(configstring_id_t::STATUSBAR, sb.sb);
}
