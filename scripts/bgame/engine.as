const rgba_t rgba_red = { 255, 0, 0, 255 };
const rgba_t rgba_blue = { 0, 0, 255, 255 };
const rgba_t rgba_green = { 0, 255, 0, 255 };
const rgba_t rgba_yellow = { 255, 255, 0, 255 };
const rgba_t rgba_white = { 255, 255, 255, 255 };
const rgba_t rgba_black = { 0, 0, 0, 255 };
const rgba_t rgba_cyan = { 0, 255, 255, 255 };
const rgba_t rgba_magenta = { 255, 0, 255, 255 };
const rgba_t rgba_orange = { 116, 61, 50, 255 };

const int MAX_NETNAME = 32;

const float STEPSIZE = 18.0f;

// game.h -- game dll information visible to server
// PARIL_NEW_API - value likely not used by any other Q2-esque engine in the wild
const int GAME_API_VERSION = 2023;
const int CGAME_API_VERSION = 2022;

const int MAX_STRING_CHARS = 1024; // max length of a string passed to Cmd_TokenizeString
const int MAX_STRING_TOKENS = 80;  // max tokens resulting from Cmd_TokenizeString
const int MAX_TOKEN_CHARS = 512;   // max length of an individual token

const int MAX_QPATH = 64;   // max length of a quake game pathname
const int MAX_OSPATH = 128; // max length of a filesystem pathname

//
// per-level limits
//
const int MAX_CLIENTS = 256; // absolute limit
const int MAX_EDICTS = 8192; // upper limit, due to svc_sound encoding as 15 bits
const int MAX_LIGHTSTYLES = 256;
const int MAX_MODELS = 8192; // these are sent over the net as shorts
const int MAX_SOUNDS = 2048; // so they cannot be blindly increased
const int MAX_IMAGES = 512;
const int MAX_ITEMS = 256;
const int MAX_GENERAL = (MAX_CLIENTS * 2); // general config strings

// [Sam-KEX]
const int MAX_SHADOW_LIGHTS = 256;

const int MAX_LOCALIZATION_ARGS = 8;

// convenience type to check for cvar
// modifications
class cvar_modify_t
{
    int     modified_count;
    cvar_t  @cvar;

    cvar_modify_t(cvar_t @in_cvar, bool initially_modified = false)
    {
        @this.cvar = in_cvar;
        this.modified_count = initially_modified ? 0 : this.cvar.modified_count;
    }

    bool get_modified() property
    {
        if (this.cvar.modified_count != modified_count)
        {
            modified_count = this.cvar.modified_count;
            return true;
        }

        return false;
    }
}

// [Paril-KEX]
const int MAX_MATERIAL_NAME = 16;

// sound attenuation values
const float ATTN_LOOP_NONE = -1; // full volume the entire level, for loop only
const float ATTN_NONE = 0; // full volume the entire level, for sounds only
const float ATTN_NORM = 1;
const float ATTN_IDLE = 2;
const float ATTN_STATIC = 3; // diminish very rapidly with distance

// total stat count
const uint MAX_STATS = 64;

// bound by number of things we can fit in two stats
const uint MAX_WHEEL_ITEMS = 32;

enum game_style_t
{
    PVE,
    FFA,
    TDM
};

// [Sam-KEX] New define for max config string length
const int CS_MAX_STRING_LENGTH = 96;
const int CS_MAX_STRING_LENGTH_OLD = 64;

// certain configstrings are allowed to be larger
// than CS_MAX_STRING_LENGTH; this gets the absolute size
// for the given configstring at the specified id
// since vanilla didn't do a very good job of size checking
uint CS_SIZE(configstring_id_t v)
{
	if (v >= configstring_id_t::STATUSBAR && v < configstring_id_t::AIRACCEL)
		return CS_MAX_STRING_LENGTH * (int(configstring_id_t::AIRACCEL) - int(v));
	else if (v >= configstring_id_t::GENERAL && v < configstring_id_t::WHEEL_WEAPONS)
		return CS_MAX_STRING_LENGTH * (int(configstring_id_t::MAX_CONFIGSTRINGS) - int(v));
	
	return CS_MAX_STRING_LENGTH;
}

const int MAX_MODELS_OLD = 256, MAX_SOUNDS_OLD = 256, MAX_IMAGES_OLD = 256;

void CS_REMAP(configstring_old_id_t id, int &out start, int &out length)
{
    // direct mapping
    if (id < configstring_old_id_t::STATUSBAR_OLD)
    {
		start = int(id) * CS_MAX_STRING_LENGTH;
		length = CS_MAX_STRING_LENGTH;
	}
    // statusbar needs a bit of special handling, since we have a different
    // max configstring length and these are just segments of a longer string
    else if (id < configstring_old_id_t::AIRACCEL_OLD)
    {
        start = (int(configstring_id_t::STATUSBAR) * CS_MAX_STRING_LENGTH) + ((id - int(configstring_old_id_t::STATUSBAR_OLD)) * CS_MAX_STRING_LENGTH_OLD);
        length = (int(configstring_id_t::AIRACCEL) - int(configstring_id_t::STATUSBAR)) * CS_MAX_STRING_LENGTH;
    }
    // offset
    else if (id < configstring_old_id_t::MODELS_OLD)
    {
        start = (id + (int(configstring_id_t::AIRACCEL) - int(configstring_old_id_t::AIRACCEL_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::SOUNDS_OLD)
    {
        start = (id + (int(configstring_id_t::MODELS) - int(configstring_old_id_t::MODELS_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::IMAGES_OLD)
    {
        start = (id + (int(configstring_id_t::SOUNDS) - int(configstring_old_id_t::SOUNDS_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::LIGHTS_OLD)
    {
        start = (id + (int(configstring_id_t::IMAGES) - int(configstring_old_id_t::IMAGES_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::ITEMS_OLD)
    {
        start = (id + (int(configstring_id_t::LIGHTS) - int(configstring_old_id_t::LIGHTS_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::PLAYERSKINS_OLD)
    {
        start = (id + (int(configstring_id_t::ITEMS) - int(configstring_old_id_t::ITEMS_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else if (id < configstring_old_id_t::GENERAL_OLD)
    {
        start = (id + (int(configstring_id_t::PLAYERSKINS) - int(configstring_old_id_t::PLAYERSKINS_OLD))) * CS_MAX_STRING_LENGTH;
        length = CS_MAX_STRING_LENGTH;
    }
    else
    {
        // general also needs some special handling because it's both
        // offset *and* allowed to overflow
        start = (id + (int(configstring_id_t::GENERAL) - int(configstring_old_id_t::GENERAL_OLD))) * CS_MAX_STRING_LENGTH_OLD;
        length = (int(configstring_id_t::MAX_CONFIGSTRINGS) - int(configstring_id_t::GENERAL)) * CS_MAX_STRING_LENGTH;
    }
}

//===============================================================

const int32 MODELINDEX_WORLD = 1;    // special index for world
const int32 MODELINDEX_PLAYER = MAX_MODELS_OLD - 1; // special index for player models

const int Max_Armor_Types = 3;

const int32 PROTOCOL_VERSION_3XX   = 34;
const int32 PROTOCOL_VERSION_DEMOS = 2022;
const int32 PROTOCOL_VERSION       = 2023;

// convenience function to check if the given cvar ptr has been
// modified from its previous modified value, and automatically
// assigns modified to cvar's current value
bool Cvar_WasModified(const cvar_t @cvar, int &modified)
{
    if (cvar.modified_count != modified)
    {
        modified = cvar.modified_count;
        return true;
    }

    return false;
}