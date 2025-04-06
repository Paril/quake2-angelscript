const int    Team_None = 0;
const int    Item_UnknownRespawnTime = int32_limits::max;
const int    Item_Invalid = -1;
const int    Item_Null = 0;

namespace sv_ent_flags_t {
    const uint64 NONE               = 0; // no flags
    const uint64 ONGROUND           = 1 << 0;
    const uint64 HAS_DMG_BOOST      = 1 << 1;
    const uint64 HAS_PROTECTION     = 1 << 2;
    const uint64 HAS_INVISIBILITY   = 1 << 3;
    const uint64 IS_JUMPING         = 1 << 4;
    const uint64 IS_CROUCHING       = 1 << 5;
    const uint64 IS_ITEM            = 1 << 6;
    const uint64 IS_OBJECTIVE       = 1 << 7;
    const uint64 HAS_TELEPORTED     = 1 << 8;
    const uint64 TAKES_DAMAGE       = 1 << 9;
    const uint64 IS_HIDDEN          = 1 << 10;
    const uint64 IS_NOCLIP          = 1 << 11;
    const uint64 IN_WATER           = 1 << 12;
    const uint64 NO_TARGET          = 1 << 13;
    const uint64 GOD_MODE           = 1 << 14;
    const uint64 IS_FLIPPING_OFF    = 1 << 15;
    const uint64 IS_SALUTING        = 1 << 16;
    const uint64 IS_TAUNTING        = 1 << 17;
    const uint64 IS_WAVING          = 1 << 18;
    const uint64 IS_POINTING        = 1 << 19;
    const uint64 ON_LADDER          = 1 << 20;
    const uint64 MOVESTATE_TOP      = 1 << 21;
    const uint64 MOVESTATE_BOTTOM   = 1 << 22;
    const uint64 MOVESTATE_MOVING   = 1 << 23;
    const uint64 IS_LOCKED_DOOR     = 1 << 24;
    const uint64 CAN_GESTURE        = 1 << 25;
    const uint64 WAS_TELEFRAGGED    = 1 << 26;
    const uint64 TRAP_DANGER        = 1 << 27;
    const uint64 ACTIVE             = 1 << 28;
    const uint64 IS_SPECTATOR       = 1 << 29;
    const uint64 IN_TEAM            = 1 << 30;
};
typedef uint64 sv_ent_flags_t;

const int Team_Coop_Monster = 0;

/*
================
Player_UpdateState
================
*/
void Player_UpdateState( ASEntity & player ) {
	const client_persistant_t @persistant = player.client.pers;

	player.e.sv.ent_flags = sv_ent_flags_t::NONE;
	if ( player.groundentity !is null || ( player.flags & ent_flags_t::PARTIALGROUND ) != 0 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::ONGROUND;
	} else {
		if ( (player.e.client.ps.pmove.pm_flags & pmflags_t::JUMP_HELD) != 0 ) {
			player.e.sv.ent_flags |= sv_ent_flags_t::IS_JUMPING;
		}
	}

	if ( (player.e.client.ps.pmove.pm_flags & pmflags_t::ON_LADDER) != 0) {
		player.e.sv.ent_flags |= sv_ent_flags_t::ON_LADDER;
	}

	if ( ( player.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED ) != 0 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_CROUCHING;
	}

	if ( player.client.quad_time > level.time ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_DMG_BOOST;
	} else if ( player.client.quadfire_time > level.time ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_DMG_BOOST;
	} else if ( player.client.double_time > level.time ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_DMG_BOOST;
	}

	if ( player.client.invincible_time > level.time ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_PROTECTION;
	}

	if ( player.client.invisible_time > level.time ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_INVISIBILITY;
	}

	if ( ( player.e.client.ps.pmove.pm_flags & pmflags_t::TIME_TELEPORT ) != 0 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::HAS_TELEPORTED;
	}

	if ( player.takedamage ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::TAKES_DAMAGE;
	}

	if ( player.e.solid == solid_t::NOT ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_HIDDEN;
	}

	if ( ( player.flags & ent_flags_t::INWATER ) != 0 ) {
		if ( player.waterlevel >= water_level_t::WAIST ) {
			player.e.sv.ent_flags |= sv_ent_flags_t::IN_WATER;
		}
	}

	if ( ( player.flags & ent_flags_t::NOTARGET ) != 0 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::NO_TARGET;
	}

	if ( ( player.flags & ent_flags_t::GODMODE ) != 0 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::GOD_MODE;
	}

	if ( player.movetype == movetype_t::NOCLIP ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_NOCLIP;
	}

	if ( player.client.anim_end == player::frames::flip12 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_FLIPPING_OFF;
	}

	if ( player.client.anim_end == player::frames::salute11 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_SALUTING;
	}

	if ( player.client.anim_end == player::frames::taunt17 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_TAUNTING;
	}

	if ( player.client.anim_end == player::frames::wave11 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_WAVING;
	}

	if ( player.client.anim_end == player::frames::point12 ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_POINTING;
	}

	if ( ( player.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED ) == 0 && player.client.anim_priority <= anim_priority_t::WAVE ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::CAN_GESTURE;
	}

	if ( player.lastMOD.id == mod_id_t::TELEFRAG || player.lastMOD.id == mod_id_t::TELEFRAG_SPAWN ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::WAS_TELEFRAGGED;
	}

	if ( player.client.resp.spectator ) {
		player.e.sv.ent_flags |= sv_ent_flags_t::IS_SPECTATOR;
	}

    // AS_TODO double-check the math
	player.e.sv.team = ((player.e.s.skinnum >> 24) & 0x8);

	player.e.sv.buttons = player.client.buttons;

	const item_id_t armorType = ArmorIndex( player );
	player.e.sv.armor_type = armorType;
	player.e.sv.armor_value = persistant.inventory[ armorType ];

	player.e.sv.health = ( player.deadflag != true ) ? player.health : -1;
	player.e.sv.weapon = ( persistant.weapon !is null ) ? persistant.weapon.id : item_id_t::NULL;

	player.e.sv.last_attackertime = int32( player.client.last_attacker_time.milliseconds );
	player.e.sv.respawntime = int32( player.client.respawn_time.milliseconds );
	player.e.sv.waterlevel = player.waterlevel;
	player.e.sv.viewheight = player.viewheight;

	player.e.sv.viewangles = player.client.v_angle;
	player.e.sv.viewforward = player.client.v_forward;
	player.e.sv.velocity = player.velocity;

	@player.e.sv.ground_entity = player.groundentity !is null ? player.groundentity.e : null;
	@player.e.sv.enemy = player.enemy !is null ? player.enemy.e : null;

	//static_assert( sizeof( persistant.inventory ) <= sizeof( player.e.sv.inventory ) );
    player.e.sv.inventory = persistant.inventory;

	if ( !player.e.sv.init ) {
		player.e.sv.init = true;
		player.e.sv.classname = player.classname;
		player.e.sv.targetname = player.targetname;
		player.e.sv.lobby_usernum = player.e.s.number - 1;
		player.e.sv.starting_health = player.health;
		player.e.sv.max_health = player.max_health;

		// NOTE: entries are assumed to be ranked with the first armor assumed
		// NOTE: to be the "best", and last the "worst". You don't need to add
		// NOTE: entries for things like armor shards, only actual armors.
		// NOTE: Check "Max_Armor_Types" to raise/lower the armor count.
		player.e.sv.armor_info[ 0 ].item_id = item_id_t::ARMOR_BODY;
		player.e.sv.armor_info[ 0 ].max_count = bodyarmor_info.max_count;
		player.e.sv.armor_info[ 1 ].item_id = item_id_t::ARMOR_COMBAT;
		player.e.sv.armor_info[ 1 ].max_count = combatarmor_info.max_count;
		player.e.sv.armor_info[ 2 ].item_id = item_id_t::ARMOR_JACKET;
		player.e.sv.armor_info[ 2 ].max_count = jacketarmor_info.max_count;

		gi_Info_ValueForKey( player.client.pers.userinfo, "name", player.e.sv.netname );

		gi_Bot_RegisterEdict( player.e );
	}
}

/*
================
Monster_UpdateState
================
*/
void Monster_UpdateState( ASEntity & monster ) {
	monster.e.sv.ent_flags = sv_ent_flags_t::NONE;
	if ( monster.groundentity !is null ) {
		monster.e.sv.ent_flags |= sv_ent_flags_t::ONGROUND;
	}

	if ( monster.takedamage ) {
		monster.e.sv.ent_flags |= sv_ent_flags_t::TAKES_DAMAGE;
	}

	if ( monster.e.solid == solid_t::NOT || monster.movetype == movetype_t::NONE ) {
		monster.e.sv.ent_flags |= sv_ent_flags_t::IS_HIDDEN;
	}

	if ( ( monster.flags & ent_flags_t::INWATER ) != 0 ) {
		monster.e.sv.ent_flags |= sv_ent_flags_t::IN_WATER;
	}

	if ( coop.integer != 0 ) {
		monster.e.sv.team = Team_Coop_Monster;
	} else {
		monster.e.sv.team = Team_None; // TODO: CTF/TDM/etc...
	}

	monster.e.sv.health = ( monster.deadflag != true ) ? monster.health : -1;
	monster.e.sv.waterlevel = monster.waterlevel;
	@monster.e.sv.enemy = monster.enemy !is null ? monster.enemy.e : null;
	@monster.e.sv.ground_entity = monster.groundentity !is null ? monster.groundentity.e : null;

	int viewHeight = monster.viewheight;
	if ( ( monster.monsterinfo.aiflags & ai_flags_t::DUCKED ) != 0 ) {
		viewHeight = int( monster.e.maxs[ 2 ] - 4.0f );
	}
	monster.e.sv.viewheight = viewHeight;

	monster.e.sv.viewangles = monster.e.s.angles;

	AngleVectors( monster.e.s.angles, monster.e.sv.viewforward );

	monster.e.sv.velocity = monster.velocity;

	if ( !monster.e.sv.init ) {
		monster.e.sv.init = true;
		monster.e.sv.classname = monster.classname;
		monster.e.sv.targetname = monster.targetname;
		monster.e.sv.starting_health = monster.health;
		monster.e.sv.max_health = monster.max_health;

		gi_Bot_RegisterEdict( monster.e );
	}
}

/*
================
Item_UpdateState
================
*/
void Item_UpdateState( ASEntity & item ) {
	item.e.sv.ent_flags = sv_ent_flags_t::IS_ITEM;
	item.e.sv.respawntime = 0;

	if ( !item.team.empty() ) {
		item.e.sv.ent_flags |= sv_ent_flags_t::IN_TEAM;
	} // some DM maps have items chained together in teams...

	if ( item.e.solid == solid_t::NOT ) {
		item.e.sv.ent_flags |= sv_ent_flags_t::IS_HIDDEN;

		if ( item.nextthink.milliseconds > 0 ) {
			if ( ( item.e.svflags & svflags_t::RESPAWNING ) != 0 ) {
				const gtime_t pendingRespawnTime = ( item.nextthink - level.time );
				item.e.sv.respawntime = int32( pendingRespawnTime.milliseconds );
			} else {
				// item will respawn at some unknown time in the future...
				item.e.sv.respawntime = Item_UnknownRespawnTime;
			}
		}
	}

	const item_id_t itemID = item.item.id;

	if ( itemID == item_id_t::FLAG1 || itemID == item_id_t::FLAG2 ) {
		item.e.sv.ent_flags |= sv_ent_flags_t::IS_OBJECTIVE;
		// TODO: figure out if the objective is dropped/carried/home...
	}

	// always need to update these for items, since random item spawning
	// could change them at any time...
	item.e.sv.classname = item.classname;
	item.e.sv.item_id = item.item.id;

	if ( !item.e.sv.init ) {
		item.e.sv.init = true;
		item.e.sv.targetname = item.targetname;

		gi_Bot_RegisterEdict( item.e );
	}
}

/*
================
Trap_UpdateState
================
*/
void Trap_UpdateState( ASEntity & danger ) {
	danger.e.sv.ent_flags = sv_ent_flags_t::TRAP_DANGER;
	danger.e.sv.velocity = danger.velocity;

	if ( danger.owner !is null && danger.owner.client !is null ) {
		// AS_TODO check math
		danger.e.sv.team = ((danger.owner.e.s.skinnum >> 24) & 0x8);
	}

	if ( danger.groundentity !is null ) {
		danger.e.sv.ent_flags |= sv_ent_flags_t::ONGROUND;
	}

	if ( ( danger.flags & ent_flags_t::TRAP_LASER_FIELD ) == 0 ) {
		danger.e.sv.ent_flags |= sv_ent_flags_t::ACTIVE; // non-lasers are always active
	} else {
		danger.e.sv.start_origin = danger.e.s.origin;
		danger.e.sv.end_origin = danger.e.s.old_origin;
		if ( ( danger.e.svflags & svflags_t::NOCLIENT ) == 0 ) {
			if ( ( danger.e.s.renderfx & renderfx_t::BEAM ) != 0 ) {
				danger.e.sv.ent_flags |= sv_ent_flags_t::ACTIVE; // lasers are active!!
			}
		}
	}

	if ( !danger.e.sv.init ) {
		danger.e.sv.init = true;
		danger.e.sv.classname = danger.classname;

		gi_Bot_RegisterEdict( danger.e );
	}
}

/*
================
Edict_UpdateState
================
*/
void Edict_UpdateState( ASEntity & edict ) {
	edict.e.sv.ent_flags = sv_ent_flags_t::NONE;
	edict.e.sv.health = edict.health;

	if ( edict.takedamage ) {
		edict.e.sv.ent_flags |= sv_ent_flags_t::TAKES_DAMAGE;
	}

	// plats, movers, and doors use this to determine move state.
	const bool isDoor = ( ( edict.e.svflags & svflags_t::DOOR ) != 0 );
	const bool isReversedDoor = ( isDoor && ( edict.spawnflags & spawnflags::door::REVERSE ) != 0 );

	// doors have their top/bottom states reversed from plats
	// ( unless "reverse" spawnflag is set! )
	if ( isDoor && !isReversedDoor ) {
		if ( edict.moveinfo.state == move_state_t::TOP ) {
			edict.e.sv.ent_flags |= sv_ent_flags_t::MOVESTATE_BOTTOM;
		} else if ( edict.moveinfo.state == move_state_t::BOTTOM ) {
			edict.e.sv.ent_flags |= sv_ent_flags_t::MOVESTATE_TOP;
		}
	} else {
		if ( edict.moveinfo.state == move_state_t::TOP ) {
			edict.e.sv.ent_flags |= sv_ent_flags_t::MOVESTATE_TOP;
		} else if ( edict.moveinfo.state == move_state_t::BOTTOM ) {
			edict.e.sv.ent_flags |= sv_ent_flags_t::MOVESTATE_BOTTOM;
		}
	}

	if ( edict.moveinfo.state == move_state_t::UP || edict.moveinfo.state == move_state_t::DOWN ) {
		edict.e.sv.ent_flags |= sv_ent_flags_t::MOVESTATE_MOVING;
 	} 

	edict.e.sv.start_origin = edict.moveinfo.start_origin;
	edict.e.sv.end_origin = edict.moveinfo.end_origin;

	if ( (edict.e.svflags & svflags_t::DOOR) != 0 ) {
		if ( (edict.flags & ent_flags_t::LOCKED) != 0 ) {
			edict.e.sv.ent_flags |= sv_ent_flags_t::IS_LOCKED_DOOR;
		}
	}

	if ( !edict.e.sv.init ) {
		edict.e.sv.init = true;
		edict.e.sv.classname = edict.classname;
		edict.e.sv.targetname = edict.targetname;
		edict.e.sv.spawnflags = uint(edict.spawnflags);
	}
}

/*
================
Entity_UpdateState
================
*/
void Entity_UpdateState( ASEntity & edict ) {
	if ( (edict.e.svflags & svflags_t::MONSTER ) != 0) {
		Monster_UpdateState( edict );
	} else if ( (edict.flags & ent_flags_t::TRAP) != 0 || (edict.flags & ent_flags_t::TRAP_LASER_FIELD) != 0 ) {
		Trap_UpdateState( edict );
	} else if ( edict.item !is null ) {
		Item_UpdateState( edict );
	} else if ( edict.client !is null ) {
		Player_UpdateState( edict );
	} else {
		Edict_UpdateState( edict );
	}
}

void info_nav_lock_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @n = null;

	while ( ( @n = find_by_str<ASEntity>( n, "targetname", self.target ) ) !is null ) {
		if ( ( n.e.svflags & svflags_t::DOOR ) == 0 ) {
			gi_Com_Print( "{} tried targeting {}, a non-SVF_DOOR\n", self, n );
			continue;
		}

		n.flags = ent_flags_t(n.flags ^ ent_flags_t::LOCKED);
	}
}

/*QUAKED info_nav_lock (1.0 1.0 0.0) (-16 -16 0) (16 16 32)
toggle locked state on linked entity
*/
void SP_info_nav_lock( ASEntity &self ) {
	if ( self.targetname.empty() ) {
		gi_Com_Print( "{} missing targetname\n", self );
		G_FreeEdict( self );
		return;
	}

	if ( self.target.empty() ) {
		gi_Com_Print( "{} missing target\n", self );
		G_FreeEdict( self );
		return;
	}

	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.use = info_nav_lock_use;
}