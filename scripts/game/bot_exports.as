// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

/*
================
Bot_SetWeapon
================
*/
void Bot_SetWeapon( edict_t @ bot_handle, int weaponIndex, bool instantSwitch ) {
	if ( weaponIndex <= item_id_t::NULL || weaponIndex > item_id_t::TOTAL ) {
		return;
	}

	if ( ( bot_handle.svflags & svflags_t::BOT ) == 0 ) {
		return;
	}

	ASEntity @ bot = entities[bot_handle.s.number];
    ASClient @ client = bot.client;
	if ( client is null || client.pers.inventory[ weaponIndex ] == 0 ) {
		return;
	}

	const item_id_t weaponItemID = item_id_t( weaponIndex );

	const gitem_t @ currentGun = client.pers.weapon;
	if ( currentGun !is null ) {
		if ( currentGun.id == weaponItemID ) {
			return;
		} // already have the gun in hand.
	}

	const gitem_t @ pendingGun = client.newweapon;
	if ( pendingGun !is null ) {
		if ( pendingGun.id == weaponItemID ) {
			return;
		} // already in the process of switching to that gun, just be patient!
	}

	const gitem_t @ item = itemlist[ weaponIndex ];
	if ( ( item.flags & item_flags_t::WEAPON ) == 0 ) {
		return;
	}

	if ( item.use is null ) {
		return;
	}

	bot.client.no_weapon_chains = true;
	item.use( bot, item );

	if ( instantSwitch ) {
		// FIXME: ugly, maybe store in client later
        // AS_TODO
		//const int temp_instant_weapon = g_instant_weapon_switch.integer;
		//g_instant_weapon_switch->integer = 1;
		ChangeWeapon( bot );
		//g_instant_weapon_switch->integer = temp_instant_weapon;
	}
}

/*
================
Bot_TriggerEdict
================
*/
void Bot_TriggerEdict( edict_t @ bot_handle, edict_t @ edict_handle ) {
	if ( !bot_handle.inuse || !edict_handle.inuse ) {
		return;
	}

	if ( ( bot_handle.svflags & svflags_t::BOT ) == 0 ) {
		return;
	}

    ASEntity @bot = entities[bot_handle.s.number];
    ASEntity @edict = entities[edict_handle.s.number];

	if ( edict.use !is null ) {
		edict.use( edict, bot, bot );
	}

	if ( edict.touch !is null ) {
		edict.touch( edict, bot, null_trace, true );
	}
}

/*
================
Bot_UseItem
================
*/
void Bot_UseItem( edict_t @ bot_handle, int itemID ) {
	if ( !bot_handle.inuse ) {
		return;
	}

	if ( ( bot_handle.svflags & svflags_t::BOT ) == 0 ) {
		return;
	}

	const item_id_t desiredItemID = item_id_t( itemID );

    ASEntity @bot = entities[bot_handle.s.number];

	bot.client.pers.selected_item = desiredItemID;

	ValidateSelectedItem( bot );

	if ( bot.client.pers.selected_item == item_id_t::NULL  ) {
		return;
	}

	if ( bot.client.pers.selected_item != desiredItemID ) {
		return;
	} // the itemID changed on us - don't use it!

	const gitem_t @ item = itemlist[ bot.client.pers.selected_item ];
	bot.client.pers.selected_item = item_id_t::NULL;

	if ( item.use is null ) {
		return;
	}

	bot.client.no_weapon_chains = true;
	item.use( bot, item );
}

/*
================
Bot_GetItemID
================
*/
int Bot_GetItemID( const string &in classname ) {
	if ( classname.empty() ) {
		return Item_Invalid;
	}

	if ( Q_strcasecmp( classname, "none" ) == 0 ) {
		return Item_Null;
	}

	for ( int i = 0; i < item_id_t::TOTAL; ++i ) {
		const gitem_t @ item = itemlist[i];
		if ( Q_strcasecmp( item.classname, classname ) == 0 ) {
			return item.id;
		}
	}

	return Item_Invalid;
}

/*
================
Edict_ForceLookAtPoint
================
*/
void Edict_ForceLookAtPoint( edict_t @ edict_handle, const vec3_t &in point ) {
	vec3_t viewOrigin = edict_handle.s.origin;
    ASEntity @edict = entities[edict_handle.s.number];
	if ( edict.client !is null ) {
		viewOrigin += edict.e.client.ps.viewoffset;
	}

	const vec3_t ideal = ( point - viewOrigin ).normalized();
	
	vec3_t viewAngles = vectoangles( ideal );
	if ( viewAngles.x < -180.0f ) {
		viewAngles.x = anglemod( viewAngles.x + 360.0f );
	}
	
	if ( edict.client !is null ) {
		edict.e.client.ps.pmove.delta_angles = ( viewAngles - edict.client.resp.cmd_angles );
		edict.e.client.ps.viewangles = vec3_origin;
		edict.client.v_angle = vec3_origin;
		edict.e.s.angles = vec3_origin;
	}
}

/*
================
Bot_PickedUpItem

Check if the given bot has picked up the given item or not.
================
*/
bool Bot_PickedUpItem( edict_t @ bot, edict_t @ item ) {
	if ((item.svflags & svflags_t::INSTANCED) != 0)
		return cast<ASEntity>(item.as_obj).item_picked_up_by[bot.number - 1];

	return false;
}