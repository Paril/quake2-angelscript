const gtime_t SELECTED_ITEM_TIME = time_sec(3);

void SelectNextItem(ASEntity &ent, item_flags_t itflags, bool menu = true)
{
	item_id_t i, index;
	const gitem_t @it;

	// ZOID
	if (menu && ent.client.menu !is null)
	{
		PMenu_Next(ent);
		return;
	}
	else if (menu && ent.client.chase_target !is null)
	{
		ChaseNext(ent);
		return;
	}
	// ZOID

	// scan  for the next valid one
	for (i = item_id_t(item_id_t::NULL + 1); i <= item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		index = item_id_t((ent.client.pers.selected_item + i) % item_id_t::TOTAL);
		if (ent.client.pers.inventory[index] == 0)
			continue;
		@it = GetItemByIndex(index);
		if (it.use is null)
			continue;
		if ((it.flags & itflags) == 0)
			continue;

		ent.client.pers.selected_item = index;
		ent.client.pers.selected_item_time = level.time + SELECTED_ITEM_TIME;
		ent.e.client.ps.stats[player_stat_t::SELECTED_ITEM_NAME] = configstring_id_t::ITEMS + index;
		return;
	}

	ent.client.pers.selected_item = item_id_t::NULL;
}

void SelectPrevItem(ASEntity &ent, item_flags_t itflags)
{
	item_id_t  i, index;
	const gitem_t @it;

	// ZOID
	if (ent.client.menu !is null)
	{
		PMenu_Prev(ent);
		return;
	}
	else if (ent.client.chase_target !is null)
	{
		ChasePrev(ent);
		return;
	}
	// ZOID

	// scan  for the next valid one
	for (i = item_id_t(item_id_t::NULL + 1); i <= item_id_t::TOTAL; i = item_id_t(i + 1))
	{
        index = item_id_t((ent.client.pers.selected_item + item_id_t::TOTAL - i) % item_id_t::TOTAL);
		if (ent.client.pers.inventory[index] == 0)
			continue;
		@it = GetItemByIndex(index);
		if (it.use is null)
			continue;
		if ((it.flags & itflags) == 0)
			continue;

		ent.client.pers.selected_item = index;
		ent.client.pers.selected_item_time = level.time + SELECTED_ITEM_TIME;
		ent.e.client.ps.stats[player_stat_t::SELECTED_ITEM_NAME] = configstring_id_t::ITEMS + index;
		return;
	}

	ent.client.pers.selected_item = item_id_t::NULL;
}

void ValidateSelectedItem(ASEntity &ent)
{
    if (ent.client.pers.inventory[ent.client.pers.selected_item] != 0)
		return; // valid

	SelectNextItem(ent, item_flags_t::ANY, false);
}

//=================================================================================

bool G_CheatCheck(ASEntity &ent)
{
	if (max_clients > 1 && sv_cheats.integer == 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_need_cheats");
		return false;
	}

	return true;
}

void SpawnAndGiveItem(ASEntity &ent, item_id_t id)
{
	const gitem_t @it = GetItemByIndex(id);

	if (it is null)
		return;

	ASEntity @it_ent = G_Spawn();
	it_ent.classname = it.classname;
	SpawnItem(it_ent, it, empty_st);

	if (it_ent.e.inuse)
	{
		Touch_Item(it_ent, ent, null_trace, true);
		if (it_ent.e.inuse)
			G_FreeEdict(it_ent);
	}
}

/*
==================
Cmd_Give_f

Give items to a client
==================
*/
void Cmd_Give_f(ASEntity &ent)
{
	string name;
	const gitem_t	@it;
	item_id_t index;
	int		  i;
	bool	  give_all;
	ASEntity  @it_ent;

	if (!G_CheatCheck(ent))
		return;

	name = gi_args();

	if (Q_strcasecmp(name, "all") == 0)
		give_all = true;
	else
		give_all = false;

	if (give_all || Q_strcasecmp(gi_argv(1), "health") == 0)
	{
		if (gi_argc() == 3)
			ent.health = parseInt(gi_argv(2));
		else
			ent.health = ent.max_health;
		if (!give_all)
			return;
	}

	if (give_all || Q_strcasecmp(name, "weapons") == 0)
	{
		for (i = 0; i < item_id_t::TOTAL; i++)
		{
			@it = itemlist[i];
			if (it.pickup is null)
				continue;
			if ((it.flags & item_flags_t::WEAPON) == 0)
				continue;
			ent.client.pers.inventory[i] += 1;
		}
		if (!give_all)
			return;
	}

	if (give_all || Q_strcasecmp(name, "ammo") == 0)
	{
		if (give_all)
			SpawnAndGiveItem(ent, item_id_t::ITEM_PACK);

		for (i = 0; i < item_id_t::TOTAL; i++)
		{
			@it = itemlist[i];
			if (it.pickup is null)
				continue;
			if ((it.flags & item_flags_t::AMMO) == 0)
				continue;
			Add_Ammo(ent, it, 1000);
		}
		if (!give_all)
			return;
	}

	if (give_all || Q_strcasecmp(name, "armor") == 0)
	{
		ent.client.pers.inventory[item_id_t::ARMOR_JACKET] = 0;
		ent.client.pers.inventory[item_id_t::ARMOR_COMBAT] = 0;
		ent.client.pers.inventory[item_id_t::ARMOR_BODY] = GetItemByIndex(item_id_t::ARMOR_BODY).armor_info.max_count;

		if (!give_all)
			return;
	}

	if (give_all)
	{
		SpawnAndGiveItem(ent, item_id_t::ITEM_POWER_SHIELD);

		if (!give_all)
			return;
	}

	if (give_all)
	{
		for (i = 0; i < item_id_t::TOTAL; i++)
		{
			@it = itemlist[i];
			if (it.pickup is null)
				continue;
			// ROGUE
			if ((it.flags & (item_flags_t::ARMOR | item_flags_t::WEAPON | item_flags_t::AMMO | item_flags_t::NOT_GIVEABLE | item_flags_t::TECH)) != 0)
				continue;
			else if (it.pickup is CTFPickup_Flag)
				continue;
			else if ((it.flags & item_flags_t::HEALTH) != 0 && it.use is null)
				continue;
			// ROGUE
			ent.client.pers.inventory[i] = (it.flags & item_flags_t::KEY) != 0 ? 8 : 1;
		}

		G_CheckPowerArmor(ent);
		ent.client.pers.power_cubes = 0xFF;
		return;
	}

	@it = FindItem(name);
	if (it is null)
	{
		name = gi_argv(1);
		@it = FindItem(name);
	}
	if (it is null)
		@it = FindItemByClassname(name);

	if (it is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_unknown_item");
		return;
	}

	// ROGUE
	if ((it.flags & item_flags_t::NOT_GIVEABLE) != 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_not_giveable");
		return;
	}
	// ROGUE

	index = it.id;

	if (it.pickup is null)
	{
		ent.client.pers.inventory[index] = 1;
		return;
	}

	if ((it.flags & item_flags_t::AMMO) != 0)
	{
		if (gi_argc() == 3)
			ent.client.pers.inventory[index] = parseInt(gi_argv(2));
		else
			ent.client.pers.inventory[index] += it.quantity;
	}
	else
	{
		@it_ent = G_Spawn();
		it_ent.classname = it.classname;
		SpawnItem(it_ent, it, empty_st);
		// PMM - since some items don't actually spawn when you say to ..
		if (!it_ent.e.inuse)
			return;
		// pmm
		Touch_Item(it_ent, ent, null_trace, true);
		if (it_ent.e.inuse)
			G_FreeEdict(it_ent);
	}
}

void Cmd_SetPOI_f(ASEntity &self)
{
	if (!G_CheatCheck(self))
		return;

	level.current_poi = self.e.s.origin;
	level.valid_poi = true;
}

void Cmd_CheckPOI_f(ASEntity &self)
{
	if (!G_CheatCheck(self))
		return;

	if (!level.valid_poi)
		return;
	
	uint8 visible_pvs = gi_inPVS(self.e.s.origin, level.current_poi, false) ? 1 : 0;
	uint8 visible_pvs_portals = gi_inPVS(self.e.s.origin, level.current_poi, true) ? 1 : 0;
	uint8 visible_phs = gi_inPHS(self.e.s.origin, level.current_poi, false) ? 1 : 0;
	uint8 visible_phs_portals = gi_inPHS(self.e.s.origin, level.current_poi, true) ? 1 : 0;

	gi_Com_Print("pvs {} + portals {}, phs {} + portals {}\n", visible_pvs, visible_pvs_portals, visible_phs, visible_phs_portals);
}

// [Paril-KEX]
void Cmd_Target_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

	ent.target = gi_argv(1);
	G_UseTargets(ent, ent);
	ent.target = "";
}

/*
==================
Cmd_God_f

Sets client to godmode

argv(0) god
==================
*/
void Cmd_God_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

    string msg;

	ent.flags = ent_flags_t(ent.flags ^ ent_flags_t::GODMODE);
	if ((ent.flags & ent_flags_t::GODMODE) == 0)
		msg = "godmode OFF\n";
	else
		msg = "godmode ON\n";

	gi_LocClient_Print(ent.e, print_type_t::HIGH, msg);
}

/*
==================
Cmd_Immortal_f

Sets client to immortal - take damage but never go below 1 hp

argv(0) immortal
==================
*/
void Cmd_Immortal_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

    string msg;

	ent.flags = ent_flags_t(ent.flags ^ ent_flags_t::IMMORTAL);
	if ((ent.flags & ent_flags_t::IMMORTAL) == 0)
		msg = "immortal OFF\n";
	else
		msg = "immortal ON\n";

	gi_LocClient_Print(ent.e, print_type_t::HIGH, msg);
}

/*
=================
Cmd_Spawn_f

Spawn class name

argv(0) spawn
argv(1) <classname>
argv(2+n) "key"...
argv(3+n) "value"...
=================
*/
void Cmd_Spawn_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

	solid_t backup = solid_t(ent.e.solid);
	ent.e.solid = solid_t::NOT;
	gi_linkentity(ent.e);

	ASEntity @other = G_Spawn();
	other.classname = gi_argv(1);

    vec3_t forward;
    AngleVectors(ent.e.s.angles, forward);

	other.e.s.origin = ent.e.s.origin + (forward * 24.0f);
	other.e.s.angles[1] = ent.e.s.angles[1];

	spawn_temp_t st;

	if (gi_argc() > 3)
	{
		for (int i = 2; i < gi_argc(); i += 2)
        {
            tokenizer_t parser(gi_argv(i + 1));
            parser.next();
			ED_ParseField(gi_argv(i), parser, other, st);
        }
	}

	ED_CallSpawn(other, st);

	if (other.e.inuse)
	{
		vec3_t end;
		AngleVectors(ent.client.v_angle, forward);
		end = ent.e.s.origin;
		end[2] += ent.viewheight;
		end += (forward * 8192);

		trace_t tr = gi_traceline(ent.e.s.origin + vec3_t(0.0f, 0.0f, float(ent.viewheight)), end, other.e, contents_t(contents_t::MASK_SHOT | contents_t::MONSTERCLIP));
		other.e.s.origin = tr.endpos;

		for (int i = 0; i < 3; i++)
		{
			if (tr.plane.normal[i] > 0)
				other.e.s.origin[i] -= other.e.mins[i] * tr.plane.normal[i];
			else
				other.e.s.origin[i] += other.e.maxs[i] * -tr.plane.normal[i];
		}

		while (gi_trace(other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, other.e,
			contents_t(contents_t::MASK_SHOT | contents_t::MONSTERCLIP))
			.startsolid)
		{
			float dx = other.e.mins.x - other.e.maxs.x;
			float dy = other.e.mins.y - other.e.maxs.y;
			other.e.s.origin += forward * -sqrt(dx * dx + dy * dy);

			if ((other.e.s.origin - ent.e.s.origin).dot(forward) < 0)
			{
				gi_Client_Print(ent.e, print_type_t::HIGH, "Couldn't find a suitable spawn location\n");
				G_FreeEdict(other);
				break;
			}
		}

		if (other.e.inuse)
			gi_linkentity(other.e);

		if ((other.e.svflags & svflags_t::MONSTER) != 0 && !(other.think is null))
			other.think(other);
	}

	ent.e.solid = backup;
	gi_linkentity(ent.e);
}

/*
=================
Cmd_Spawn_f

Telepo'

argv(0) teleport
argv(1) x
argv(2) y
argv(3) z
=================
*/
void Cmd_Teleport_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

	if (gi_argc() < 4)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Not enough args; teleport x y z [pitch yaw roll]\n");
		return;
	}

	ent.e.s.origin.x = parseFloat(gi_argv(1));
	ent.e.s.origin.y = parseFloat(gi_argv(2));
	ent.e.s.origin.z = parseFloat(gi_argv(3));

	if (gi_argc() >= 4)
	{
		float pitch = parseFloat(gi_argv(4));
		float yaw = parseFloat(gi_argv(5));
		float roll = parseFloat(gi_argv(6));
		vec3_t ang = { pitch, yaw, roll };

		ent.e.client.ps.pmove.delta_angles = ( ang - ent.client.resp.cmd_angles );
		ent.e.client.ps.viewangles = vec3_origin;
		ent.client.v_angle = vec3_origin;
	}

	gi_linkentity(ent.e);
}

/*
==================
Cmd_Notarget_f

Sets client to notarget

argv(0) notarget
==================
*/
void Cmd_Notarget_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

    string msg;

	ent.flags = ent_flags_t(ent.flags ^ ent_flags_t::NOTARGET);
	if ((ent.flags & ent_flags_t::NOTARGET) == 0)
		msg = "notarget OFF\n";
	else
		msg = "notarget ON\n";

	gi_LocClient_Print(ent.e, print_type_t::HIGH, msg);
}

/*
==================
Cmd_Novisible_f

Sets client to "super notarget"

argv(0) notarget
==================
*/
void Cmd_Novisible_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

    string msg;

	ent.flags = ent_flags_t(ent.flags ^ ent_flags_t::NOVISIBLE);
	if ((ent.flags & ent_flags_t::NOVISIBLE) == 0)
		msg = "novisible OFF\n";
	else
		msg = "novisible ON\n";

	gi_LocClient_Print(ent.e, print_type_t::HIGH, msg);
}

void Cmd_AlertAll_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

	for (uint i = 0; i < num_edicts; i++)
	{
		ASEntity @t = entities[i];

		if (!t.e.inuse || t.health <= 0 || (t.e.svflags & svflags_t::MONSTER) == 0)
			continue;

		@t.enemy = ent;
		FoundTarget(t);
	}
}

/*
==================
Cmd_Noclip_f

argv(0) noclip
==================
*/
void Cmd_Noclip_f(ASEntity &ent)
{
	if (!G_CheatCheck(ent))
		return;

    string msg;

	if (ent.movetype == movetype_t::NOCLIP)
	{
		ent.movetype = movetype_t::WALK;
		msg = "noclip OFF\n";
	}
	else
	{
		ent.movetype = movetype_t::NOCLIP;
		msg = "noclip ON\n";
	}

	gi_LocClient_Print(ent.e, print_type_t::HIGH, msg);
}

/*
==================
Cmd_Use_f

Use an inventory item
==================
*/
void Cmd_Use_f(ASEntity &ent, const string &in cmd)
{
	item_id_t index;
	const gitem_t @it;

	if (ent.health <= 0 || ent.deadflag)
		return;

	string s = gi_args();

	if (Q_strcasecmp(cmd, "use_index") == 0 || Q_strcasecmp(cmd, "use_index_only") == 0)
	{
		@it = GetItemByIndex(item_id_t(parseInt(s)));
	}
	else
	{
		@it = FindItem(s);
	}

	if (it is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_unknown_item_name", s);
		return;
	}
	if (it.use is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_item_not_usable");
		return;
	}
	index = it.id;

	// Paril: Use_Weapon handles weapon availability
	if ((it.flags & item_flags_t::WEAPON) == 0 && ent.client.pers.inventory[index] == 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_out_of_item", it.pickup_name);
		return;
	}

	// allow weapon chains for use
	ent.client.no_weapon_chains = Q_strcasecmp(cmd, "use") != 0 && Q_strcasecmp(cmd, "use_index") != 0;

	it.use(ent, it);

	ValidateSelectedItem(ent);
}

/*
==================
Cmd_Drop_f

Drop an inventory item
==================
*/
void Cmd_Drop_f(ASEntity &ent)
{
	item_id_t     index;
	const gitem_t @it = null;
	string        s;

	if (ent.health <= 0 || ent.deadflag)
		return;

	s = gi_args();

	// ZOID--special case for tech powerups
	if (Q_strcasecmp(s, "tech") == 0)
	{
		@it = CTFWhat_Tech(ent);

		if (it !is null)
		{
			it.drop(ent, it);
			ValidateSelectedItem(ent);
		}

		return;
	}
	// ZOID

	string cmd = gi_argv(0);

	if (Q_strcasecmp(cmd, "drop_index") == 0)
	{
		@it = GetItemByIndex(item_id_t(parseInt(s)));
	}
	else
	{
		@it = FindItem(s);
	}

	if (it is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "Unknown item : {}\n", s);
		return;
	}
	if (it.drop is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_item_not_droppable");
		return;
	}
	index = it.id;
	if (ent.client.pers.inventory[index] == 0)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_out_of_item", it.pickup_name);
		return;
	}

	it.drop(ent, it);

	ValidateSelectedItem(ent);
}

/*
=================
Cmd_Inven_f
=================
*/
void Cmd_Inven_f(ASEntity &ent)
{
	int		   i;

	ent.client.showscores = false;
	ent.client.showhelp = false;

	server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);

	// ZOID
	if (ent.client.menu !is null)
	{
		PMenu_Close(ent);
		ent.client.update_chase = true;
		return;
	}
	// ZOID

	if (ent.client.showinventory)
	{
		ent.client.showinventory = false;
		return;
	}

	// ZOID
	if (G_TeamplayEnabled() && ent.client.resp.ctf_team == ctfteam_t::NOTEAM)
	{
		CTFOpenJoinMenu(ent);
		return;
	}
	// ZOID

	ent.client.showinventory = true;

	gi_WriteByte(svc_t::inventory);
	for (i = 0; i < item_id_t::TOTAL; i++)
		gi_WriteShort(ent.client.pers.inventory[i]);
	for (; i < MAX_ITEMS; i++)
		gi_WriteShort(0);
	gi_unicast(ent.e, true);
}

/*
=================
Cmd_InvUse_f
=================
*/
void Cmd_InvUse_f(ASEntity &ent)
{
	const gitem_t @it;

	// ZOID
	if (ent.client.menu !is null)
	{
		PMenu_Select(ent);
		return;
	}
	// ZOID

	if (ent.health <= 0 || ent.deadflag)
		return;

	ValidateSelectedItem(ent);

	if (ent.client.pers.selected_item == item_id_t::NULL)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_no_item_to_use");
		return;
	}

	@it = itemlist[ent.client.pers.selected_item];
	if (it.use is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_item_not_usable");
		return;
	}

	// don't allow weapon chains for invuse
	ent.client.no_weapon_chains = true;
	it.use(ent, it);

	ValidateSelectedItem(ent);
}

/*
=================
Cmd_WeapPrev_f
=================
*/
void Cmd_WeapPrev_f(ASEntity &ent)
{
	item_id_t       i, index;
	const gitem_t	@it;
	item_id_t       selected_weapon;

	if (ent.health <= 0 || ent.deadflag)
		return;
	if (ent.client.pers.weapon is null)
		return;

	// don't allow weapon chains for weapprev
	ent.client.no_weapon_chains = true;

	selected_weapon = ent.client.pers.weapon.id;

	// scan  for the next valid one
	for (i = item_id_t(item_id_t::NULL + 1); i <= item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		// PMM - prevent scrolling through ALL weapons
		index = item_id_t((selected_weapon + item_id_t::TOTAL - i) % item_id_t::TOTAL);
		if (ent.client.pers.inventory[index] == 0)
			continue;
		@it = itemlist[index];
		if (it.use is null)
			continue;
		if ((it.flags & item_flags_t::WEAPON) == 0)
			continue;
		it.use(ent, it);
		// ROGUE
		if (ent.client.newweapon is it)
			return; // successful
					// ROGUE
	}
}

/*
=================
Cmd_WeapNext_f
=================
*/
void Cmd_WeapNext_f(ASEntity &ent)
{
	item_id_t       i, index;
	const gitem_t	@it;
	item_id_t       selected_weapon;

	if (ent.health <= 0 || ent.deadflag)
		return;
	if (ent.client.pers.weapon is null)
		return;

	// don't allow weapon chains for weapnext
	ent.client.no_weapon_chains = true;

	selected_weapon = ent.client.pers.weapon.id;

	// scan  for the next valid one
	for (i = item_id_t(item_id_t::NULL + 1); i <= item_id_t::TOTAL; i = item_id_t(i + 1))
	{
		// PMM - prevent scrolling through ALL weapons
		index = item_id_t((selected_weapon + i) % item_id_t::TOTAL);
		if (ent.client.pers.inventory[index] == 0)
			continue;
		@it = itemlist[index];
		if (it.use is null)
			continue;
		if ((it.flags & item_flags_t::WEAPON) == 0)
			continue;
		it.use(ent, it);
		// PMM - prevent scrolling through ALL weapons

		// ROGUE
		if (ent.client.newweapon is it)
			return;
		// ROGUE
	}
}

/*
=================
Cmd_WeapLast_f
=================
*/
void Cmd_WeapLast_f(ASEntity &ent)
{
	int		        index;
	const gitem_t	@it;

	if (ent.health <= 0 || ent.deadflag)
		return;
	if (ent.client.pers.weapon is null || ent.client.pers.lastweapon is null)
		return;

	// don't allow weapon chains for weaplast
	ent.client.no_weapon_chains = true;

	index = ent.client.pers.lastweapon.id;
	if (ent.client.pers.inventory[index] == 0)
		return;
	@it = itemlist[index];
	if (it.use is null)
		return;
	if ((it.flags & item_flags_t::WEAPON) == 0)
		return;
	it.use(ent, it);
}

/*
=================
Cmd_InvDrop_f
=================
*/
void Cmd_InvDrop_f(ASEntity &ent)
{
	const gitem_t @it;

	if (ent.health <= 0 || ent.deadflag)
		return;

	ValidateSelectedItem(ent);

	if (ent.client.pers.selected_item == item_id_t::NULL)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_no_item_to_drop");
		return;
	}

	@it = itemlist[ent.client.pers.selected_item];
	if (it.drop is null)
	{
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_item_not_droppable");
		return;
	}
	it.drop(ent, it);

	ValidateSelectedItem(ent);
}

/*
=================
Cmd_Kill_f
=================
*/
void Cmd_Kill_f(ASEntity &ent)
{
	// ZOID
	if (ent.client.resp.spectator)
		return;
	// ZOID

	if ((level.time - ent.client.respawn_time) < time_sec(5))
		return;

	ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);
	ent.health = 0;

	// ROGUE
	//  make sure no trackers are still hurting us.
	if (ent.client.tracker_pain_time)
		RemoveAttackingPainDaemons(ent);

	if (ent.client.owned_sphere !is null)
	{
		G_FreeEdict(ent.client.owned_sphere);
		@ent.client.owned_sphere = null;
	}
	// ROGUE

	// [Paril-KEX] don't allow kill to take points away in TDM
	player_die(ent, ent, ent, 100000, vec3_origin, mod_t(mod_id_t::SUICIDE, teamplay.integer != 0));
}

/*
=================
Cmd_Kill_AI_f
=================
*/
void Cmd_Kill_AI_f( ASEntity &ent ) {
	if ( sv_cheats.integer == 0 ) {
		gi_LocClient_Print( ent.e, print_type_t::HIGH, "Kill_AI: Cheats Must Be Enabled!\n" );
		return;
	}

	// except the one we're looking at...
	ASEntity @looked_at = null;

	vec3_t start = ent.e.s.origin + vec3_t(0.f, 0.f, float(ent.viewheight));
	vec3_t end = start + ent.client.v_forward * 1024.f;

	@looked_at = entities[gi_traceline(start, end, ent.e, contents_t::MASK_SHOT).ent.s.number];

	const uint numEdicts = num_edicts;
	for ( uint edictIdx = 1; edictIdx < numEdicts; ++edictIdx ) 
	{
		ASEntity @edict = entities[ edictIdx ];
		if ( !edict.e.inuse || edict is looked_at ) {
			continue;
		}

		if ( ( edict.e.svflags & svflags_t::MONSTER ) == 0 ) 
		{
			continue;
		}

		G_FreeEdict( edict );
	}

	gi_LocClient_Print( ent.e, print_type_t::HIGH, "Kill_AI: All AI Are Dead...\n" );
}

/*
=================
Cmd_Where_f
=================
*/
void Cmd_Where_f( ASEntity & ent ) {
	if ( ent is null || ent.client is null ) {
		return;
	}

	vec3_t origin = ent.e.s.origin;

	string location = format( "{:.1f} {:.1f} {:.1f} {:.1f} {:.1f} {:.1f}\n", origin[ 0 ], origin[ 1 ], origin[ 2 ], ent.e.client.ps.viewangles[0], ent.e.client.ps.viewangles[1], ent.e.client.ps.viewangles[2] );
	gi_LocClient_Print( ent.e, print_type_t::HIGH, "Location: {}\n", location );
	gi_SendToClipBoard( location );
}

/*
=================
Cmd_Clear_AI_Enemy_f
=================
*/
void Cmd_Clear_AI_Enemy_f( ASEntity & ent ) {
	if ( sv_cheats.integer == 0 ) {
		gi_LocClient_Print( ent.e, print_type_t::HIGH, "Cmd_Clear_AI_Enemy: Cheats Must Be Enabled!\n" );
		return;
	}

	const uint numEdicts = num_edicts;
	for ( uint edictIdx = 1; edictIdx < numEdicts; ++edictIdx ) {
		ASEntity @edict = entities[ edictIdx ];
		if ( !edict.e.inuse ) {
			continue;
		}

		if ( ( edict.e.svflags & svflags_t::MONSTER ) == 0 ) {
			continue;
		}

		edict.monsterinfo.aiflags = ai_flags_t(edict.monsterinfo.aiflags | ai_flags_t::FORGET_ENEMY);
	}

	gi_LocClient_Print( ent.e, print_type_t::HIGH, "Cmd_Clear_AI_Enemy: Clear All AI Enemies...\n" );
}

/*
=================
Cmd_PutAway_f
=================
*/
void Cmd_PutAway_f(ASEntity &ent)
{
	ent.client.showscores = false;
	ent.client.showhelp = false;
	ent.client.showinventory = false;

	server_flags = server_flags_t(server_flags & ~server_flags_t::SLOW_TIME);

	// ZOID
	if (ent.client.menu !is null)
		PMenu_Close(ent);
	ent.client.update_chase = true;
	// ZOID
}

bool PlayerLessThan(const int &in a, const int &in b)
{
	int anum = players[a].e.client.ps.stats[player_stat_t::FRAGS];
	int bnum = players[b].e.client.ps.stats[player_stat_t::FRAGS];

    return anum < bnum;
}

const uint MAX_IDEAL_PACKET_SIZE = 1024;

/*
=================
Cmd_Players_f
=================
*/
void Cmd_Players_f(ASEntity &ent)
{
	uint   i;
	string small, large;
	array<int> index;

	for (i = 0; i < max_clients; i++)
		if (players[i].client.pers.connected)
			index.push_back(i);

	// sort by frags
	index.sort(PlayerLessThan);

	// print information
	if (!index.empty())
	{
		for (i = 0; i < index.length(); i++)
		{
			small = format("{:3} {}\n", players[index[i]].e.client.ps.stats[player_stat_t::FRAGS],
						players[index[i]].client.pers.netname);

			if (small.length() + large.length() > MAX_IDEAL_PACKET_SIZE - 50)
			{ // can't print all of them in one packet
				large += "...\n";
				break;
			}

			large += small;
		}
	
		// remove the last newline
		large.erase(large.length() - 1, 1);
	}

	gi_LocClient_Print(ent.e, print_type_t(print_type_t::HIGH | print_type_t::NO_NOTIFY), "$g_players", large, formatUInt(index.length()));
}

bool CheckFlood(ASEntity &ent)
{
	int		   i;

	if (flood_msgs.integer != 0)
	{
		ASClient @cl = ent.client;

		if (level.time < cl.flood_locktill)
		{
			gi_LocClient_Print(ent.e, print_type_t::HIGH, "$g_flood_cant_talk",
				formatInt((cl.flood_locktill - level.time).secondsi()));
			return true;
		}
		i = cl.flood_whenhead - flood_msgs.integer + 1;
		if (i < 0)
			i = cl.flood_when.length() + i;
		if (i >= int(cl.flood_when.length()))
			i = 0;
		if (cl.flood_when[i] && level.time - cl.flood_when[i] < time_sec(flood_persecond.value))
		{
			cl.flood_locktill = level.time + time_sec(flood_waitdelay.value);
			gi_LocClient_Print(ent.e, print_type_t::CHAT, "$g_flood_cant_talk",
				formatInt(flood_waitdelay.integer));
			return true;
		}
		cl.flood_whenhead = (cl.flood_whenhead + 1) % cl.flood_when.length();
		cl.flood_when[cl.flood_whenhead] = level.time;
	}
	return false;
}

/*
=================
Cmd_Wave_f
=================
*/
void Cmd_Wave_f(ASEntity &ent)
{
	int i;

	i = parseInt(gi_argv(1));

	// no dead or noclip waving
	if (ent.deadflag || ent.movetype == movetype_t::NOCLIP)
		return;

	// can't wave when ducked
	bool do_animate = ent.client.anim_priority <= anim_priority_t::WAVE && (ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) == 0;

	if (do_animate)
		ent.client.anim_priority = anim_priority_t::WAVE;

	string other_notify_msg, other_notify_none_msg;

	vec3_t start, dir;
	P_ProjectSource(ent, ent.client.v_angle, { 0, 0, 0 }, start, dir);

	// see who we're aiming at
	ASEntity @aiming_at = null;
	float best_dist = -9999;

    foreach (ASEntity @player : active_players)
    {
		if (player is ent)
			continue;
		vec3_t cdir = player.e.s.origin - start;
		float dist = cdir.normalize();

		float dot = ent.client.v_forward.dot(cdir);

		if (dot < 0.97f)
			continue;
		else if (dist < best_dist)
			continue;

		best_dist = dist;
		@aiming_at = player;
	}

	switch (i)
	{
	case gesture_type_t::FLIP_OFF:
		other_notify_msg = "$g_flipoff_other";
		other_notify_none_msg = "$g_flipoff_none";
		if (do_animate)
		{
			ent.e.s.frame = player::frames::flip01 - 1;
			ent.client.anim_end = player::frames::flip12;
		}
		break;
	case gesture_type_t::SALUTE:
		other_notify_msg = "$g_salute_other";
		other_notify_none_msg = "$g_salute_none";
		if (do_animate)
		{
			ent.e.s.frame = player::frames::salute01 - 1;
			ent.client.anim_end = player::frames::salute11;
		}
		break;
	case gesture_type_t::TAUNT:
		other_notify_msg = "$g_taunt_other";
		other_notify_none_msg = "$g_taunt_none";
		if (do_animate)
		{
			ent.e.s.frame = player::frames::taunt01 - 1;
			ent.client.anim_end = player::frames::taunt17;
		}
		break;
	case gesture_type_t::WAVE:
		other_notify_msg = "$g_wave_other";
		other_notify_none_msg = "$g_wave_none";
		if (do_animate)
		{
			ent.e.s.frame = player::frames::wave01 - 1;
			ent.client.anim_end = player::frames::wave11;
		}
		break;
	case gesture_type_t::POINT:
	default:
		other_notify_msg = "$g_point_other";
		other_notify_none_msg = "$g_point_none";
		if (do_animate)
		{
			ent.e.s.frame = player::frames::point01 - 1;
			ent.client.anim_end = player::frames::point12;
		}
		break;
	}

	bool has_a_target = false;

	if (i == gesture_type_t::POINT)
	{
        foreach (ASEntity @player : active_players)
        {
            if (player is ent)
                continue;
			if (!OnSameTeam(ent, player))
				continue;

			has_a_target = true;
			break;
		}
	}

	if (i == gesture_type_t::POINT && has_a_target)
	{
		// don't do this stuff if we're flooding
		if (CheckFlood(ent))
			return;

		trace_t tr = gi_traceline(start, start + (ent.client.v_forward * 2048), ent.e, contents_t(contents_t::MASK_SHOT & ~contents_t::WINDOW));
		other_notify_msg = "$g_point_other_ping";

		uint32 key = GetUnicastKey();

		if (tr.fraction != 1.0f)
		{
			// send to all teammates
            foreach (ASEntity @player : active_players)
            {
                if (player is ent)
                    continue;
                if (!OnSameTeam(ent, player))
                    continue;

				gi_WriteByte(svc_t::poi);
				gi_WriteShort(pois_t::POI_PING + (ent.e.s.number - 1));
				gi_WriteShort(5000);
				gi_WritePosition(tr.endpos);
				gi_WriteShort(level.pic_ping);
				gi_WriteByte(208);
				gi_WriteByte(pois_t::POI_FLAG_NONE);
                // AS_TODO: shouldn't `key` be used here.. oops
				gi_unicast(player.e, false);

				gi_local_sound(player.e, soundchan_t::AUTO, gi_soundindex("misc/help_marker.wav"), 1.0f, ATTN_NONE, 0.0f, key);
				gi_LocClient_Print(player.e, print_type_t::HIGH, other_notify_msg, ent.client.pers.netname);
			}
		}
	}
	else
	{
		if (CheckFlood(ent))
			return;

		ASEntity @targ = null;
		while ((@targ = findradius(targ, ent.e.s.origin, 1024)) !is null)
		{
			if (ent is targ) continue;
			if (targ.client is null) continue;
			if (!gi_inPVS(ent.e.s.origin, targ.e.s.origin, false)) continue;

			if (aiming_at !is null && !other_notify_msg.empty())
				gi_LocClient_Print(targ.e, print_type_t::TTS, other_notify_msg, ent.client.pers.netname, aiming_at.client.pers.netname);
			else if (!other_notify_none_msg.empty())
				gi_LocClient_Print(targ.e, print_type_t::TTS, other_notify_none_msg, ent.client.pers.netname);
		}

		if (aiming_at !is null && !other_notify_msg.empty())
			gi_LocClient_Print(ent.e, print_type_t::TTS, other_notify_msg, ent.client.pers.netname, aiming_at.client.pers.netname);
		else if (!other_notify_none_msg.empty())
			gi_LocClient_Print(ent.e, print_type_t::TTS, other_notify_none_msg, ent.client.pers.netname);
	}

	ent.client.anim_time = time_zero;
}

//#ifndef KEX_Q2_GAME
/*
==================
Cmd_Say_f

NB: only used for non-Playfab stuff
==================
*/
/*
void Cmd_Say_f(edict_t *ent, bool arg0)
{
	edict_t *other;
	const char	 *p_in;
	static std::string text;

	if (gi.argc() < 2 && !arg0)
		return;
	else if (CheckFlood(ent))
		return;

	text.clear();
	fmt::format_to(std::back_inserter(text), FMT_STRING("{}: "), ent.client.pers.netname);

	if (arg0)
	{
		text += gi.argv(0);
		text += " ";
		text += gi.args();
	}
	else
	{
		p_in = gi.args();
		size_t in_len = strlen(p_in);

		if (p_in[0] == '\"' && p_in[in_len - 1] == '\"')
			text += std::string_view(p_in + 1, in_len - 2);
		else
			text += p_in;
	}

	// don't let text be too long for malicious reasons
	if (text.length() > 150)
		text.resize(150);

	if (text.back() != '\n')
		text.push_back('\n');

	if (sv_dedicated.integer)
		gi.Client_Print(nullptr, PRINT_CHAT, text.c_str());

	for (uint32_t j = 1; j <= game.maxclients; j++)
	{
		other = &g_edicts[j];
		if (!other.inuse)
			continue;
		if (!other.client)
			continue;
		gi.Client_Print(other, PRINT_CHAT, text.c_str());
	}
}
#endif
*/

void Cmd_PlayerList_f(ASEntity &ent)
{
	uint i;
	string str, text;
	ASEntity @e2;

	// connect time, ping, score, name
	for (i = 0; i < max_clients; i++)
	{
        @e2 = players[i];

		if (!e2.e.inuse)
			continue;

		str = format("{:02}:{:02} {:4} {:3} {}{}\n", (level.time - e2.client.resp.entertime).milliseconds / 60000,
					((level.time - e2.client.resp.entertime).milliseconds % 60000) / 1000, e2.e.client.ping,
					e2.client.resp.score, e2.client.pers.netname, e2.client.resp.spectator ? " (spectator)" : "");

		if (text.length() + str.length() > MAX_IDEAL_PACKET_SIZE - 50)
		{
			text += "...\n";
			break;
		}

		text += str;
	}

	if (!text.empty())
		gi_Client_Print(ent.e, print_type_t::HIGH, text);
}

void Cmd_Switchteam_f(ASEntity &ent)
{
	if (!G_TeamplayEnabled())
		return;

	// [Paril-KEX] in force-join, just do a regular team join.
	if (g_teamplay_force_join.integer != 0)
	{
		// check if we should even switch teams
		ASEntity @player;
		uint team1count = 0, team2count = 0;
		ctfteam_t best_team;

		for (uint i = 1; i <= max_clients; i++)
		{
			@player = entities[i];

			// NB: we are counting ourselves in this one, unlike
			// the other assign team func
			if (!player.e.inuse)
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
			best_team = ctfteam_t::TEAM1;
		else
			best_team = ctfteam_t::TEAM2;

		if (ent.client.resp.ctf_team != best_team)
		{
			////
			ent.e.svflags = svflags_t::NONE;
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::GODMODE);
			ent.client.resp.ctf_team = best_team;
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
					ent.client.pers.netname, CTFTeamName(best_team));
				return;
			}

			ent.health = 0;
			player_die(ent, ent, ent, 100000, vec3_origin, mod_t(mod_id_t::SUICIDE, true));

			// don't even bother waiting for death frames
			ent.deadflag = true;
			respawn(ent);

			ent.client.resp.score = 0;

			gi_LocBroadcast_Print(print_type_t::HIGH, "$g_changed_team",
				ent.client.pers.netname, CTFTeamName(best_team));
		}

		return;
	}

	if (ent.client.resp.ctf_team != ctfteam_t::NOTEAM)
		CTFObserver(ent);

	if (ent.client.menu is null)
		CTFOpenJoinMenu(ent);
}

/*
static void Cmd_ListMonsters_f(edict_t *ent)
{
	if (!G_CheatCheck(ent))
		return;
	else if (!g_debug_monster_kills.integer)
		return;

	for (size_t i = 0; i < level.total_monsters; i++)
	{
		edict_t *e = level.monsters_registered[i];

		if (!e || !e.inuse)
			continue;
		else if (!(e.svflags & SVF_MONSTER) || (e.monsterinfo.aiflags & AI_DO_NOT_COUNT))
			continue;
		else if (e.deadflag)
			continue;

		gi.Com_PrintFmt("{}\n", *e);
	}
}
*/

/*
=================
ClientCommand
=================
*/
void ClientCommand(edict_t @ent_handle)
{
	if (ent_handle.client is null)
		return; // not fully in game yet

    ASEntity @ent = entities[ent_handle.s.number];
	string cmd = gi_argv(0);

	if (Q_strcasecmp(cmd, "players") == 0)
	{
		Cmd_Players_f(ent);
		return;
	}
	// [Paril-KEX] these have to go through the lobby system
/*#ifndef KEX_Q2_GAME
	if (Q_strcasecmp(cmd, "say") == 0)
	{
		Cmd_Say_f(ent, false);
		return;
	}
	if (Q_strcasecmp(cmd, "say_team") == 0 || Q_strcasecmp(cmd, "steam") == 0)
	{
		if (G_TeamplayEnabled())
			CTFSay_Team(ent, gi.args());
		else
			Cmd_Say_f(ent, false);
		return;
	}
#endif*/
	if (Q_strcasecmp(cmd, "score") == 0)
	{
		Cmd_Score_f(ent);
		return;
	}
	if (Q_strcasecmp(cmd, "help") == 0)
	{
		Cmd_Help_f(ent);
		return;
	}
	if (Q_strcasecmp(cmd, "listmonsters") == 0)
	{
        // AS_TODO
		//Cmd_ListMonsters_f(ent);
		return;
	}

	if (level.intermissiontime)
		return;
	
	if ( Q_strcasecmp( cmd, "target" ) == 0 )
		Cmd_Target_f( ent );
	else if ( Q_strcasecmp( cmd, "use" ) == 0 || Q_strcasecmp( cmd, "use_only" ) == 0 ||
		Q_strcasecmp( cmd, "use_index" ) == 0 || Q_strcasecmp( cmd, "use_index_only" ) == 0 )
		Cmd_Use_f( ent, cmd );
	else if ( Q_strcasecmp( cmd, "drop" ) == 0 ||
		Q_strcasecmp( cmd, "drop_index" ) == 0 )
		Cmd_Drop_f( ent );
	else if ( Q_strcasecmp( cmd, "give" ) == 0 )
		Cmd_Give_f( ent );
	else if ( Q_strcasecmp( cmd, "god" ) == 0 )
		Cmd_God_f( ent );
	else if (Q_strcasecmp(cmd, "immortal") == 0)
		Cmd_Immortal_f(ent);
	else if ( Q_strcasecmp( cmd, "setpoi" ) == 0 )
		Cmd_SetPOI_f( ent );
	else if ( Q_strcasecmp( cmd, "checkpoi" ) == 0 )
		Cmd_CheckPOI_f( ent );
	// Paril: cheats to help with dev
	else if ( Q_strcasecmp( cmd, "spawn" ) == 0 )
		Cmd_Spawn_f( ent );
	else if ( Q_strcasecmp( cmd, "teleport" ) == 0 )
		Cmd_Teleport_f( ent );
	else if ( Q_strcasecmp( cmd, "notarget" ) == 0 )
		Cmd_Notarget_f( ent );
	else if ( Q_strcasecmp( cmd, "novisible" ) == 0 )
		Cmd_Novisible_f( ent );
	else if ( Q_strcasecmp( cmd, "alertall" ) == 0 )
		Cmd_AlertAll_f( ent );
	else if ( Q_strcasecmp( cmd, "noclip" ) == 0 )
		Cmd_Noclip_f( ent );
	else if ( Q_strcasecmp( cmd, "inven" ) == 0 )
		Cmd_Inven_f( ent );
	else if ( Q_strcasecmp( cmd, "invnext" ) == 0 )
		SelectNextItem( ent, item_flags_t::ANY );
	else if ( Q_strcasecmp( cmd, "invprev" ) == 0 )
		SelectPrevItem( ent, item_flags_t::ANY );
	else if ( Q_strcasecmp( cmd, "invnextw" ) == 0 )
		SelectNextItem( ent, item_flags_t::WEAPON );
	else if ( Q_strcasecmp( cmd, "invprevw" ) == 0 )
		SelectPrevItem( ent, item_flags_t::WEAPON );
	else if ( Q_strcasecmp( cmd, "invnextp" ) == 0 )
		SelectNextItem( ent, item_flags_t::POWERUP );
	else if ( Q_strcasecmp( cmd, "invprevp" ) == 0 )
		SelectPrevItem( ent, item_flags_t::POWERUP );
	else if ( Q_strcasecmp( cmd, "invuse" ) == 0 )
		Cmd_InvUse_f( ent );
	else if ( Q_strcasecmp( cmd, "invdrop" ) == 0 )
		Cmd_InvDrop_f( ent );
	else if ( Q_strcasecmp( cmd, "weapprev" ) == 0 )
		Cmd_WeapPrev_f( ent );
	else if ( Q_strcasecmp( cmd, "weapnext" ) == 0 )
		Cmd_WeapNext_f( ent );
	else if ( Q_strcasecmp( cmd, "weaplast" ) == 0 || Q_strcasecmp( cmd, "lastweap" ) == 0 )
		Cmd_WeapLast_f( ent );
	else if ( Q_strcasecmp( cmd, "kill" ) == 0 )
		Cmd_Kill_f( ent );
	else if ( Q_strcasecmp( cmd, "kill_ai" ) == 0 )
		Cmd_Kill_AI_f( ent );
	else if ( Q_strcasecmp( cmd, "where" ) == 0 )
		Cmd_Where_f( ent );
	else if ( Q_strcasecmp( cmd, "clear_ai_enemy" ) == 0 )
		Cmd_Clear_AI_Enemy_f( ent );
	else if (Q_strcasecmp(cmd, "putaway") == 0)
		Cmd_PutAway_f(ent);
	else if (Q_strcasecmp(cmd, "wave") == 0)
		Cmd_Wave_f(ent);
	else if (Q_strcasecmp(cmd, "playerlist") == 0)
		Cmd_PlayerList_f(ent);
	// ZOID
	else if (Q_strcasecmp(cmd, "team") == 0)
		CTFTeam_f(ent);
	else if (Q_strcasecmp(cmd, "id") == 0)
		CTFID_f(ent);
	else if (Q_strcasecmp(cmd, "yes") == 0)
		CTFVoteYes(ent);
	else if (Q_strcasecmp(cmd, "no") == 0)
		CTFVoteNo(ent);
	else if (Q_strcasecmp(cmd, "ready") == 0)
		CTFReady(ent);
	else if (Q_strcasecmp(cmd, "notready") == 0)
		CTFNotReady(ent);
	else if (Q_strcasecmp(cmd, "ghost") == 0)
		CTFGhost(ent);
	else if (Q_strcasecmp(cmd, "admin") == 0)
		CTFAdmin(ent);
	else if (Q_strcasecmp(cmd, "stats") == 0)
		CTFStats(ent);
	else if (Q_strcasecmp(cmd, "warp") == 0)
		CTFWarp(ent);
	else if (Q_strcasecmp(cmd, "boot") == 0)
		CTFBoot(ent);
	else if (Q_strcasecmp(cmd, "playerlist") == 0)
		CTFPlayerList(ent);
	else if (Q_strcasecmp(cmd, "observer") == 0)
		CTFObserver(ent);
	// ZOID
	else if (Q_strcasecmp(cmd, "switchteam") == 0)
		Cmd_Switchteam_f(ent);
/*#ifndef KEX_Q2_GAME
	else // anything that doesn't match a command will be a chat
		Cmd_Say_f(ent, true);
#else*/
	// anything that doesn't match a command will inform them
	else
		gi_LocClient_Print(ent.e, print_type_t::HIGH, "invalid game command \"{}\"\n", cmd);
//#endif
}
