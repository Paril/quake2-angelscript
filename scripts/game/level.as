class level_locals_t
{
	bool is_spawning = false; // whether we're still doing SpawnEntities
	gtime_t time;

	string level_name; // the descriptive name (Outer Base, etc)
	string mapname;	// the server name (base1, etc)
	string nextmap;	// go here when fraglimit is hit
	string forcemap;	// go here

	// intermission state
	gtime_t		intermissiontime; // time the intermission was started
	string      changemap;
	string      achievement;
	bool		exitintermission = false;
	bool		intermission_eou = false;
	bool		intermission_clear = false; // [Paril-KEX] clear inventory on switch
	bool		level_intermission_set = false; // [Paril-KEX] for target_camera switches; don't find intermission point
	bool		intermission_fade = false, intermission_fading = false; // [Paril-KEX] fade on exit instead of immediately leaving
	gtime_t		intermission_fade_time;
	vec3_t		intermission_origin;
	vec3_t		intermission_angle;
	bool		respawn_intermission = false; // only set once for respawning players

	int32 pic_health;
	int32 pic_ping;

	int32 total_secrets = 0;
	int32 found_secrets = 0;

	int32 total_goals = 0;
	int32 found_goals = 0;

	int32 total_monsters = 0;
	array<ASEntity@> monsters_registered; // only for debug
	int32 killed_monsters = 0;

	ASEntity @current_entity; // entity running from G_RunFrame
	int32	 body_que;		 // dead bodies

	int32 power_cubes = 0; // ugly necessity for coop

	// ROGUE
	ASEntity @disguise_violator;
	gtime_t	 disguise_violation_time;
	int32    disguise_icon; // [Paril-KEX]
	// ROGUE
	
	uint shadow_light_count = 0; // [Sam-KEX]
	bool is_n64 = false, is_psx = false;
	gtime_t coop_level_restart_time; // restart the level after this time
	bool instantitems = false; // instantitems 1 set in worldspawn

	// N64 goal stuff
	string goals; // empty if no goals in world
	int32 goal_num = 0; // current relative goal number, increased with each target_goal

	// offset for the first vwep model, for
	// skinnum encoding
	int32 vwep_offset = 0;

	// coop health scaling factor;
	// this percentage of health is added
	// to the monster's health per player.
	float coop_health_scaling = 1;
	// this isn't saved in the save file, but stores
	// the amount of players currently active in the
	// level, compared against monsters' individual 
	// scale #
	int32 coop_scale_players = 0;

	// [Paril-KEX] current level entry
	level_entry_t @entry = null;

	// [Paril-KEX] current poi
	bool valid_poi = false;
	vec3_t current_poi;
	int32 current_poi_image;
	int32 current_poi_stage;
	ASEntity @current_dynamic_poi;
	array<array<vec3_t>> poi_points; // temporary storage for POIs in coop

	// start items
	string start_items;
	// disable grappling hook
	bool no_grapple = false;

	// saved gravity
	float gravity = 1;
	// level is a hub map, and shouldn't be included in EOU stuff
	bool hub_map = false;
	// active health bar entities
	array<ASEntity@> health_bar_entities(MAX_HEALTH_BARS);
	int32 intermission_server_frame = 0;
	bool deadly_kill_box = false;
	bool story_active = false;
	gtime_t next_auto_save;

	string primary_objective_string;
	string secondary_objective_string;

	string primary_objective_title;
	string secondary_objective_title;

    // used to track whether we need to update
    // entities for bots or not
    int num_bots = 0;

    // AS_TODO
    // this is AS-specific, because creating/freeing entities
    // is a bit slower than native was. in the future we can
    // fix this by changing how MoveToGoal works to accept
    // non-entity goals.
    ASEntity @monster_fakegoal;
}

level_locals_t level;