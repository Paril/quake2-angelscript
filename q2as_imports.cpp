#include "q2as_local.h"
#include "q2as_reg.h"
#include "bg_local.h"

// import-related stuff that doesn't belong anywhere else.
bool Q2AS_RegisterImportTypes(asIScriptEngine *engine)
{
	static uint32_t max_split = MAX_SPLIT_PLAYERS;
	EnsureRegisteredGlobalProperty("const uint MAX_SPLIT_PLAYERS", (void *) &max_split);

#define Q2AS_OBJECT configstring_id_t
#define Q2AS_ENUM_PREFIX CS_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, NAME);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, CDTRACK);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKY);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKYAXIS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKYROTATE);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, STATUSBAR);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, AIRACCEL);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MAXCLIENTS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MAPCHECKSUM);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MODELS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SOUNDS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, IMAGES);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, LIGHTS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SHADOWLIGHTS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, ITEMS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, PLAYERSKINS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, GENERAL);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, WHEEL_WEAPONS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, WHEEL_AMMO);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, WHEEL_POWERUPS);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, CD_LOOP_COUNT);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, GAME_STYLE);
	EnsureRegisteredEnumValueRaw("configstring_id_t", "MAX_CONFIGSTRINGS", MAX_CONFIGSTRINGS);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT configstring_old_id_t
#define Q2AS_ENUM_PREFIX CS_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, NAME_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, CDTRACK_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKY_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKYAXIS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SKYROTATE_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, STATUSBAR_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, AIRACCEL_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MAXCLIENTS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MAPCHECKSUM_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, MODELS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, SOUNDS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, IMAGES_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, LIGHTS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, ITEMS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, PLAYERSKINS_OLD);
	EnsureRegisteredEnumValueGlobalNoPrefix(CS_, GENERAL_OLD);
	EnsureRegisteredEnumValueRaw("configstring_old_id_t", "MAX_CONFIGSTRINGS_OLD", MAX_CONFIGSTRINGS_OLD);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT layout_flags_t
#define Q2AS_ENUM_PREFIX LAYOUT_

	EnsureRegisteredTypedEnum("int16");
	EnsureRegisteredEnumValue(LAYOUTS_, NONE);
	EnsureRegisteredEnumValue(LAYOUTS_, LAYOUT);
	EnsureRegisteredEnumValue(LAYOUTS_, INVENTORY);
	EnsureRegisteredEnumValue(LAYOUTS_, HIDE_HUD);
	EnsureRegisteredEnumValue(LAYOUTS_, INTERMISSION);
	EnsureRegisteredEnumValue(LAYOUTS_, HELP);
	EnsureRegisteredEnumValue(LAYOUTS_, HIDE_CROSSHAIR);
	
#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

#define Q2AS_OBJECT monster_muzzle_t
#define Q2AS_ENUM_PREFIX MZ2_

	EnsureRegisteredEnum();
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, UNUSED_0);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_BLASTER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_BLASTER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_BLASTER_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_11);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_12);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_13);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_14);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_15);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_16);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_17);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_18);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_MACHINEGUN_19);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_ROCKET_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_ROCKET_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TANK_ROCKET_3);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_11);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_12);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_13);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_2);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_MACHINEGUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE_4);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CHICK_ROCKET_1);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, FLYER_BLASTER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, FLYER_BLASTER_2);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_BLASTER_1);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GLADIATOR_RAILGUN_1);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, HOVER_BLASTER_1);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, ACTOR_MACHINEGUN_1);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_MACHINEGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_ROCKET_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_ROCKET_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_ROCKET_3);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_L1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_L2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_L3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_L4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_L5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_ROCKET_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_ROCKET_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_ROCKET_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_ROCKET_4);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, FLOAT_BLASTER_1);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_8);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BFG);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_11);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_12);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_13);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_14);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_15);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_16);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_BLASTER_17);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MAKRON_RAILGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_L6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_MACHINEGUN_R6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, JORG_BFG_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_R1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_R2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_R3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_R4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, BOSS2_MACHINEGUN_R5);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_MACHINEGUN_L1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_MACHINEGUN_R1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_GRENADE);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TURRET_MACHINEGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TURRET_ROCKET);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, TURRET_BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, STALKER_BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, DAEDALUS_BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_BLASTER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_RAILGUN);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_DISRUPTOR);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RAIL);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_PLASMABEAM);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_MACHINEGUN_L2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_MACHINEGUN_R2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RAIL_LEFT);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RAIL_RIGHT);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_SWEEP9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_100);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_90);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_80);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_70);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_60);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_50);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_40);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_30);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_20);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_0);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_10L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_20L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_30L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_40L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_50L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_60L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_BLASTER_70L);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW_RUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_ROCKET_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_ROCKET_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_ROCKET_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, CARRIER_ROCKET_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAMER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAMER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAMER_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAMER_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAMER_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, WIDOW2_BEAM_SWEEP_11);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_8);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUARDIAN_BLASTER);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, ARACHNID_RAIL1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, ARACHNID_RAIL2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, ARACHNID_RAIL_UP1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, ARACHNID_RAIL_UP2);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_14);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_15);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_16);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_17);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_18);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_19);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_20);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_21);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_CHAINGUN_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_CHAINGUN_2);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_MORTAR_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_MORTAR_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_MORTAR_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_FRONT_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_FRONT_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_FRONT_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_CROUCH_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_CROUCH_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNCMDR_GRENADE_CROUCH_3);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_BLASTER_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_SHOTGUN_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_MACHINEGUN_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_RIPPER_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SOLDIER_HYPERGUN_9);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE2_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE2_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE2_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, GUNNER_GRENADE2_4);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, INFANTRY_MACHINEGUN_22);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_GRENADE_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, SUPERTANK_GRENADE_2);
	
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, HOVER_BLASTER_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, DAEDALUS_BLASTER_2);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_11);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER1_12);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_1);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_2);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_3);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_4);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_5);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_6);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_7);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_8);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_9);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_10);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_11);
	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, MEDIC_HYPERBLASTER2_12);

	EnsureRegisteredEnumValueGlobalNoPrefix(MZ2_, LAST);

#undef Q2AS_OBJECT
#undef Q2AS_ENUM_PREFIX

	return true;
}