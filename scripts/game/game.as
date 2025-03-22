
const uint32 SFL_CROSS_TRIGGER_MASK = (uint(0xffffffff) & ~uint(spawnflags::EDITOR_MASK));

class level_entry_t
{
	// bsp name
	string map_name;
	// map name
	string pretty_name;
	// these are set when we leave the level
	int total_secrets = 0;
	int found_secrets = 0;
	int total_monsters = 0;
	int killed_monsters = 0;
	// total time spent in the level, for end screen
	gtime_t time = time_zero;
	// the order we visited levels in
	int visit_order = 0;
};

class game_locals_t
{
	string  helpmessage1;
	string  helpmessage2;
	int32   help1changed, help2changed;

	// can't store spawnpoint in level, because
	// it would get overwritten by the savegame restore
	string spawnpoint; // needed for coop respawns

	// cross level triggers
	uint32 cross_level_flags, cross_unit_flags;

    bool autosaved = false;

	// [Paril-KEX]
	int32 airacceleration_modified, gravity_modified;
	array<level_entry_t> level_entries;
    uint max_lag_origins;
    array<vec3_t> lag_origins;
};

game_locals_t game;

// a special class that links together to create
// a linked list of indices; this should be used
// for objects that need to be cached between
// load games, because index positions can change.
// these must be global.
class cached_soundindex
{
    string                  name;
    int                     index = 0;
    cached_soundindex       @next = null;

    cached_soundindex(const string &in name)
    {
        this.name = name;

        if (cached_soundindex_head !is null)
            @cached_soundindex_head.next = @cached_soundindex_head;

        @cached_soundindex_head = @this;
    }

    void precache()
    {
        this.index = gi_soundindex(this.name);
    }

    void clear()
    {
        this.index = 0;
    }

    void reset()
    {
        if (this.index != 0)
            this.index = gi_soundindex(name);
    }

    int opImplConv()
    {
        if (this.index == 0)
            this.precache();

        return index;
    }
}

cached_soundindex @cached_soundindex_head = null;

void cached_soundindex_reset_all()
{
    for (auto @asset = cached_soundindex_head; asset !is null; @asset = asset.next)
        asset.reset();
}

void cached_soundindex_clear_all()
{
    for (auto @asset = cached_soundindex_head; asset !is null; @asset = asset.next)
        asset.clear();
}

class cached_modelindex
{
    string                  name;
    int                     index = 0;
    cached_modelindex       @next = null;

    cached_modelindex(const string &in name)
    {
        this.name = name;

        if (cached_modelindex_head !is null)
            @cached_modelindex_head.next = @cached_modelindex_head;

        @cached_modelindex_head = @this;
    }

    void precache()
    {
        this.index = gi_modelindex(name);
    }

    void clear()
    {
        this.index = 0;
    }

    void reset()
    {
        if (this.index != 0)
            this.index = gi_modelindex(name);
    }

    int opImplConv()
    {
        if (this.index == 0)
            this.precache();

        return index;
    }
}

cached_modelindex @cached_modelindex_head = null;

void cached_modelindex_reset_all()
{
    for (auto @asset = cached_modelindex_head; asset !is null; @asset = asset.next)
        asset.reset();
}

void cached_modelindex_clear_all()
{
    for (auto @asset = cached_modelindex_head; asset !is null; @asset = asset.next)
        asset.clear();
}

class cached_imageindex
{
    string                  name;
    int                     index = 0;
    cached_imageindex       @next = null;

    cached_imageindex(const string &in name)
    {
        this.name = name;

        if (cached_imageindex_head !is null)
            @cached_imageindex_head.next = @cached_imageindex_head;

        @cached_imageindex_head = @this;
    }

    void precache()
    {
        this.index = gi_imageindex(name);
    }

    void clear()
    {
        this.index = 0;
    }

    void reset()
    {
        if (this.index != 0)
            this.index = gi_imageindex(name);
    }

    int opImplConv()
    {
        if (this.index == 0)
            this.precache();

        return index;
    }
}

cached_imageindex @cached_imageindex_head = null;

void cached_imageindex_reset_all()
{
    for (auto @asset = cached_imageindex_head; asset !is null; @asset = asset.next)
        asset.reset();
}

void cached_imageindex_clear_all()
{
    for (auto @asset = cached_imageindex_head; asset !is null; @asset = asset.next)
        asset.clear();
}

// Paril: used in N64. causes them to be mad at the player
// regardless of circumstance.
const uint HACKFLAG_ATTACK_PLAYER = 1;
// used in N64, appears to change their behavior for the end scene.
const uint HACKFLAG_END_CUTSCENE = 4;
