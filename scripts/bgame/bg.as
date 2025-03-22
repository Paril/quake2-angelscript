// ammo IDs
enum ammo_t : uint8
{
	BULLETS,
	SHELLS,
	ROCKETS,
	GRENADES,
	CELLS,
	SLUGS,
	// RAFAEL
	MAGSLUG,
	TRAP,
	// RAFAEL
	// ROGUE
	FLECHETTES,
	TESLA,
	DISRUPTOR,
	PROX,
	// ROGUE
    MAX
};

// powerup IDs
enum powerup_t : uint8
{
	SCREEN,
	SHIELD,

	AM_BOMB,

	QUAD,
	QUADFIRE,
	INVULNERABILITY,
	INVISIBILITY,
	SILENCER,
	REBREATHER,
	ENVIROSUIT,
	ADRENALINE,
	IR_GOGGLES,
	DOUBLE,
	SPHERE_VENGEANCE,
	SPHERE_HUNTER,
	SPHERE_DEFENDER,
	DOPPELGANGER,

	FLASHLIGHT,
	COMPASS,
	TECH1,
	TECH2,
	TECH3,
	TECH4,
	MAX
};

// physics modifiers
enum physics_flags_t
{
	PC = 0,

	N64_MOVEMENT	= 1 << 0,
	PSX_MOVEMENT	= 1 << 1,

	PSX_SCALE		= 1 << 2,

	DEATHMATCH		= 1 << 3
};

// the total number of levels we'll track for the
// end of unit screen.
const int MAX_LEVELS_PER_UNIT = 16;

// can't crouch in single player N64
bool PM_CrouchingDisabled(physics_flags_t flags)
{
	return (flags & physics_flags_t::N64_MOVEMENT) != 0 && (flags & physics_flags_t::DEATHMATCH) == 0;
}

// state for coop respawning; used to select which
// message to print for the player this is set on.
enum coop_respawn_t
{
	NONE, // no message
	IN_COMBAT, // player is in combat
	BAD_AREA, // player not in a good spot
	BLOCKED, // spawning was blocked by something
	WAITING, // for players that are waiting to respawn
	NO_LIVES, // out of lives, so need to wait until level switch
	TOTAL
};

// reserved general CS ranges
enum game_configstring_id_t
{
	CTF_MATCH = configstring_id_t::GENERAL,
	CTF_TEAMINFO,
	CTF_PLAYER_NAME,
	CTF_PLAYER_NAME_END = CTF_PLAYER_NAME + MAX_CLIENTS,

	// nb: offset by 1 since NONE is zero
	COOP_RESPAWN_STRING,
	COOP_RESPAWN_STRING_END = COOP_RESPAWN_STRING + (int(coop_respawn_t::TOTAL) - 1),

	// [Paril-KEX] see enum physics_flags_t
	PHYSICS_FLAGS,
	HEALTH_BAR_NAME, // active health bar name

	STORY,

	LAST
};

//
// p_move.c
//
class pm_config_t
{
	int32			airaccel = 0;
	physics_flags_t	physics_flags = physics_flags_t::PC;
};

pm_config_t pm_config;

const float PSX_PHYSICS_SCALAR = 0.875f;

// ammo stats compressed in 9 bits per entry
// since the range is 0-300
const uint BITS_PER_AMMO = 9;

uint num_of_type_for_bits(uint byte_size, uint num_bits)
{
	return (num_bits + (byte_size * 8) - 1) / ((byte_size * 8) + 1);
}

uint16 get_compressed_integer(uint bits_per_value, stat_array_t &in stats, uint8 id, uint byte_offset)
{
	uint16 bit_offset = bits_per_value * id;
	uint16 byte = bit_offset / 8;
	uint16 bit_shift = bit_offset % 8;
	uint16 mask = ((1 << bits_per_value) - 1) << bit_shift;
    // AS_TODO
	//uint16 *base = (uint16_t *) ((uint8_t *) start + byte);
	//return (*base & mask) >> bit_shift;
    return (stats.get_stat_uint16(byte_offset + byte) & mask) >> bit_shift;
}

const uint NUM_BITS_FOR_AMMO = 9;
const uint NUM_AMMO_STATS = num_of_type_for_bits(2, NUM_BITS_FOR_AMMO * ammo_t::MAX);

// if this value is set on an STAT_AMMO_INFO_xxx, don't render ammo
const uint16 AMMO_VALUE_INFINITE = (1 << NUM_BITS_FOR_AMMO) - 1;

uint16 G_GetAmmoStat(stat_array_t &in stats, uint8 ammo_id)
{
	return get_compressed_integer(NUM_BITS_FOR_AMMO, stats, ammo_id, player_stat_t::AMMO_INFO_START * 2);
}

// powerup stats compressed in 2 bits per entry;
// 3 is the max you'll ever hold, and for some
// (flashlight) it's to indicate on/off state
const uint NUM_BITS_PER_POWERUP = 2;
const uint NUM_POWERUP_STATS = num_of_type_for_bits(2, NUM_BITS_PER_POWERUP * powerup_t::MAX);

uint16 G_GetPowerupStat(stat_array_t &in stats, uint8 powerup_id)
{
	return get_compressed_integer(NUM_BITS_PER_POWERUP, stats, powerup_id, player_stat_t::POWERUP_INFO_START * 2);
}

// player_state->stats[] indexes
namespace player_stat_t
{
    const int HEALTH_ICON = 0;
    const int HEALTH = 1;
    const int AMMO_ICON = 2;
    const int AMMO = 3;
    const int ARMOR_ICON = 4;
    const int ARMOR = 5;
    const int SELECTED_ICON = 6;
    const int PICKUP_ICON = 7;
    const int PICKUP_STRING = 8;
    const int TIMER_ICON = 9;
    const int TIMER = 10;
    const int HELPICON = 11;
    const int SELECTED_ITEM = 12;
    const int LAYOUTS = 13;
    const int FRAGS = 14;
    const int FLASHES = 15; // cleared each frame, 1 = health, 2 = armor
    const int CHASE = 16;
    const int SPECTATOR = 17;

	const int CTF_TEAM1_PIC = 18;
	const int CTF_TEAM1_CAPS = 19;
	const int CTF_TEAM2_PIC = 20;
	const int CTF_TEAM2_CAPS = 21;
	const int CTF_FLAG_PIC = 22;
	const int CTF_JOINED_TEAM1_PIC = 23;
	const int CTF_JOINED_TEAM2_PIC = 24;
	const int CTF_TEAM1_HEADER = 25;
	const int CTF_TEAM2_HEADER = 26;
	const int CTF_TECH = 27;
	const int CTF_ID_VIEW = 28;
	const int CTF_MATCH = 29;
	const int CTF_ID_VIEW_COLOR = 30;
	const int CTF_TEAMINFO = 31;

    // [Kex] More stats for weapon wheel
    const int WEAPONS_OWNED_1 = 32;
    const int WEAPONS_OWNED_2 = 33;
    const int AMMO_INFO_START = 34;

// AS_TODO: this is kinda dumb but these can't be enum'd properly
// because AS enums can't contain constants calculated
// via functions.

    const int AMMO_INFO_END = AMMO_INFO_START + NUM_AMMO_STATS - 1;
	const int POWERUP_INFO_START = AMMO_INFO_END + 1;
	const int POWERUP_INFO_END = POWERUP_INFO_START + NUM_POWERUP_STATS - 1;

    // [Paril-KEX] Key display
    const int KEY_A = POWERUP_INFO_END + 1;
    const int KEY_B = KEY_A + 1;
    const int KEY_C = KEY_B + 1;

    // [Paril-KEX] currently active wheel weapon (or one we're switching to)
    const int ACTIVE_WHEEL_WEAPON = KEY_C + 1;
	// [Paril-KEX] top of screen coop respawn state
	const int COOP_RESPAWN = ACTIVE_WHEEL_WEAPON + 1;
	// [Paril-KEX] respawns remaining
	const int LIVES = COOP_RESPAWN + 1;
	// [Paril-KEX] hit marker; # of damage we successfully landed
	const int HIT_MARKER = LIVES + 1;
	// [Paril-KEX]
	const int SELECTED_ITEM_NAME = HIT_MARKER + 1;
	// [Paril-KEX]
	const int HEALTH_BARS = SELECTED_ITEM_NAME + 1; // two health bar values; 7 bits for value, 1 bit for active
	// [Paril-KEX]
	const int ACTIVE_WEAPON = HEALTH_BARS + 1;

	// don't use; just for verification
    const int LAST = ACTIVE_WEAPON + 1;
};

typedef uint16 player_stat_t;

const gtime_t time_zero = time_ms(0);