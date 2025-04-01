class shadow_light_temp_t
{
	shadow_light_data_t data;
	string lightstyletarget;
};

class spawn_temp_t
{
	// world vars
	string      sky;
	float       skyrotate;
	vec3_t      skyaxis;
	int32       skyautorotate = 1;
	string      nextmap;

	float		lip;
	float		distance;
	float		height;
	string      noise;
	float		pausetime;
	string      item;
	string      gravity;

	float minyaw;
	float maxyaw;
	float minpitch;
	float maxpitch;

	shadow_light_temp_t sl; // [Sam-KEX]
	string music; // [Edward-KEX]
	int instantitems;
	float radius; // [Paril-KEX]
	bool hub_map; // [Paril-KEX]
	string achievement; // [Paril-KEX]

	// [Paril-KEX]
	string goals;

	// [Paril-KEX]
	string image;

	int fade_start_dist = 96;
	int fade_end_dist = 384;
	string start_items;
	int no_grapple = 0;
	float health_multiplier = 1.0f;
	int physics_flags_sp = 0, physics_flags_dm = 0;

	string reinforcements; // [Paril-KEX]
	string noise_start, noise_middle, noise_end; // [Paril-KEX]
	int32 loop_count; // [Paril-KEX]

	string_hashset keys_specified;

	string primary_objective_string;
	string secondary_objective_string;

	string primary_objective_title;
	string secondary_objective_title;

	bool was_key_specified(const string &in key) const
	{
        return keys_specified.contains(key);
	}
}

cached_modelindex sm_meat_index("models/objects/gibs/sm_meat/tris.md2");

const spawn_temp_t @current_st;
// don't use directly
const spawn_temp_t empty_st;

const spawn_temp_t @ED_GetSpawnTemp()
{
	if (current_st is null)
	{
		gi_Com_Print("WARNING: empty spawntemp accessed; this is probably a code bug.\n");
		return empty_st;
	}

	return current_st;
}

	//spawn_t("target_actor", SP_target_actor),
    
	//spawn_t("misc_actor", SP_misc_actor),
    
	// ZOID
	//spawn_t("trigger_ctf_teleport", SP_trigger_ctf_teleport),
	//spawn_t("info_ctf_teleport_destination", SP_info_ctf_teleport_destination),
	//spawn_t("misc_ctf_banner", SP_misc_ctf_banner),
	//spawn_t("misc_ctf_small_banner", SP_misc_ctf_small_banner),
	// ZOID

funcdef void spawnfunc_f(ASEntity &);

/*
===============
ED_CallSpawn

Finds the spawn function for the entity and calls it
===============
*/
void ED_CallSpawn(ASEntity &ent, const spawn_temp_t @spawntemp)
{
	uint		 i;

	if (ent.classname.empty())
	{
		gi_Com_Print("ED_CallSpawn: nullptr classname\n");
		ent.Free();
		return;
	}

	@current_st = spawntemp;

	// PGM - do this before calling the spawn function so it can be overridden.
	ent.gravityVector = { 0.0f, 0.0f, -1.0f };
	// PGM

	ent.e.sv.init = false;

	// FIXME - PMM classnames hack
	if (ent.classname == "weapon_nailgun")
		ent.classname = GetItemByIndex(item_id_t::WEAPON_ETF_RIFLE).classname;
	else if (ent.classname == "ammo_nails")
		ent.classname = GetItemByIndex(item_id_t::AMMO_FLECHETTES).classname;
	else if (ent.classname == "weapon_heatbeam")
		ent.classname = GetItemByIndex(item_id_t::WEAPON_PLASMABEAM).classname;
	// pmm

	// check item spawn functions
	foreach (gitem_t @item : itemlist)
	{
		if (item.classname.empty())
			continue;
		if (item.classname == ent.classname)
		{
			// found it
			// before spawning, pick random item replacement
            // AS_TODO
            /*
			if (g_dm_random_items.integer != 0)
			{
				ent->item = item;
				item_id_t new_item = DoRandomRespawn(ent);

				if (new_item)
				{
					item = GetItemByIndex(new_item);
					ent->classname = item->classname;
				}
			}
            */

			SpawnItem(ent, item, spawntemp);

			if ((pm_config.physics_flags & physics_flags_t::PSX_SCALE) != 0)
				ent.e.s.origin[2] += 15.0f - (15.0f * PSX_PHYSICS_SCALAR);

			@current_st = null;
			return;
		}
	}

	// check normal spawn functions
    string spawnfuncname = "SP_" + ent.classname;
    spawnfunc_f @spawnfunc = null;

    if (reflect_global_from_name<spawnfunc_f>(spawnfuncname, spawnfunc, true))
    {
        spawnfunc(ent);
        @current_st = null;
        return;
    }

	gi_Com_Print("{} doesn't have a spawn function\n", ent);
	ent.Free();
	@current_st = null;
}

// Quick redirect to use empty spawntemp
void ED_CallSpawn(ASEntity &ent)
{
	ED_CallSpawn(ent, empty_st);
}

bool ED_LoadColor(tokenizer_t &tokenizer, int32 &out v)
{
    tokenizer.push_state();

    // check if we have multiple tokens.
    // we will always have one token, but
    // we might not have multiple.
    if (!tokenizer.next())
    {
        tokenizer.pop_state();
        return false;
    }
    
    bool has_rgba = tokenizer.next();

    tokenizer.reset();

    tokenizer.next();

	// space means rgba as values
	if (has_rgba)
	{
		vec4_t raw_values = { 0, 0, 0, 1.0f };
		bool is_float = true;
        uint parse_offset = 0;

		for (int i = 0; i < 4; i++)
		{
            float tv = tokenizer.as_float();

            if (tv > 1.0f)
                is_float = false;

            raw_values[i] = tv;

            if (!tokenizer.next())
                break;
		}

		if (is_float)
			for (int i = 0; i < 4; i++)
				raw_values[i] *= 255.0f;

		v = (int32(raw_values[3])) | (int32(raw_values[2]) << 8) | (int32(raw_values[1]) << 16) | (int32(raw_values[0]) << 24);
        tokenizer.pop_state();
        return true;
	}

	// integral
	v = tokenizer.as_int32();
    tokenizer.pop_state();
    return true;
}

bool ED_LoadFloat(tokenizer_t &tokenizer, float &out v)
{
    v = tokenizer.as_float();
    return true;
}

bool ED_LoadString(tokenizer_t &tokenizer, string &out v)
{
    v = tokenizer.as_string();
    return true;
}

bool ED_LoadVector(tokenizer_t &tokenizer, vec3_t &out v)
{
    tokenizer.push_state();
    uint parse_offset = 0;

    for (int i = 0; i < 3; i++)
    {
        if (!tokenizer.next())
            return false;

        v[i] = tokenizer.as_float();
    }

    tokenizer.pop_state();
    return true;
}

bool ED_LoadInt(tokenizer_t &tokenizer, int32 &out v)
{
    v = tokenizer.as_int32();
    return true;
}

bool ED_LoadUInt(tokenizer_t &tokenizer, uint32 &out v)
{
    v = tokenizer.as_uint32();
    return true;
}

bool ED_LoadUInt(tokenizer_t &tokenizer, int64 &out v)
{
    v = tokenizer.as_int64();
    return true;
}

bool ED_LoadUInt(tokenizer_t &tokenizer, uint64 &out v)
{
    v = tokenizer.as_uint64();
    return true;
}

bool ED_LoadRenderFX(tokenizer_t &tokenizer, renderfx_t &out v)
{
    uint32 val;

    if (!ED_LoadUInt(tokenizer, val))
        return false;

    v = renderfx_t(val);
    return true;
}

bool ED_LoadEffects(tokenizer_t &tokenizer, effects_t &out v)
{
    uint64 val;

    if (!ED_LoadUInt(tokenizer, val))
        return false;

    v = effects_t(val);
    return true;
}

bool ED_LoadBmodelAnimStyle(tokenizer_t &tokenizer, bmodel_animstyle_t &out v)
{
    int32 val;

    if (!ED_LoadInt(tokenizer, val))
        return false;

    val = clamp(val, int(bmodel_animstyle_t::FORWARDS), int(bmodel_animstyle_t::RANDOM));
    v = bmodel_animstyle_t(val);

    return true;
}

bool ED_LoadBool(tokenizer_t &tokenizer, bool &out v)
{
    v = tokenizer.as_int32() != 0;
    return true;
}

bool ED_LoadPowerArmorPower(tokenizer_t &tokenizer, item_id_t &out v)
{
    int32 type;

    if (!ED_LoadInt(tokenizer, type))
        return false;

    if (type == 0)
        v = item_id_t::NULL;
    else if (type == 1)
        v = item_id_t::ITEM_POWER_SCREEN;
    else
        v = item_id_t::ITEM_POWER_SHIELD;

    return true;
}

bool ED_LoadAngle(tokenizer_t &tokenizer, vec3_t &out v)
{
    v = vec3_origin;
    return ED_LoadFloat(tokenizer, v.yaw);
}

funcdef bool parse_st_f(tokenizer_t &, spawn_temp_t &);

// AS_TODO: typed dictionary?
// reflection?
const dictionary st_fields = {
    { "lip", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.lip); }) },
    { "distance", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.distance); }) },
    { "height", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.height); }) },
    { "noise", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.noise); }) },
    { "pausetime", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.pausetime); }) },
    { "item", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.item); }) },
    { "gravity", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.gravity); }) },
    { "sky", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.sky); }) },
    { "skyrotate", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.skyrotate); }) },
    { "skyaxis", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadVector(tokenizer, st.skyaxis); }) },
    { "skyautorotate", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.skyautorotate); }) },
    { "minyaw", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.minyaw); }) },
    { "maxyaw", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.maxyaw); }) },
    { "minpitch", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.minpitch); }) },
    { "maxpitch", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.maxpitch); }) },
    { "nextmap", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.nextmap); }) },
    { "music", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.music); }) },
    { "instantitems", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.instantitems); }) },
    { "radius", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.radius); }) },
    { "hub_map", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadBool(tokenizer, st.hub_map); }) },
    { "achievement", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.achievement); }) },
    { "shadowlightradius", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.sl.data.radius); }) },
    { "shadowlightresolution", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.sl.data.resolution); }) },
    { "shadowlightintensity", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.sl.data.intensity); }) },
    { "shadowlightstartfadedistance", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.sl.data.fade_start); }) },
    { "shadowlightendfadedistance", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.sl.data.fade_end); }) },
    { "shadowlightstyle", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.sl.data.lightstyle); }) },
    { "shadowlightconeangle", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.sl.data.coneangle); }) },
    { "shadowlightstyletarget", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.sl.lightstyletarget); }) },
    { "goals", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.goals); }) },
    { "image", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.image); }) },
    { "fade_start_dist", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.fade_start_dist); }) },
    { "fade_end_dist", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.fade_end_dist); }) },
    { "start_items", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.start_items); }) },
    { "no_grapple", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.no_grapple); }) },
    { "health_multiplier", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadFloat(tokenizer, st.health_multiplier); }) },
    { "physics_flags_sp", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.physics_flags_sp); }) },
    { "physics_flags_dm", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.physics_flags_dm); }) },
    { "reinforcements", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.reinforcements); }) },
    { "noise_start", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.noise_start); }) },
    { "noise_middle", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.noise_middle); }) },
    { "noise_end", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.noise_end); }) },
    { "loop_count", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadInt(tokenizer, st.loop_count); }) },
    { "primary_objective_string", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.primary_objective_string); }) },
    { "secondary_objective_string", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.secondary_objective_string); }) },
    { "primary_objective_title", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.primary_objective_title); }) },
    { "secondary_objective_title", cast<parse_st_f>(function(tokenizer, st) { return ED_LoadString(tokenizer, st.secondary_objective_title); }) }
};

funcdef bool parse_ent_f(tokenizer_t &, ASEntity &);

// AS_TODO: typed dictionary?
// reflection?
const dictionary ent_fields = {
    { "classname", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.classname); }) },
    { "model", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.model); }) },
    { "spawnflags", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.spawnflags); }) },
    { "speed", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.speed); }) },
    { "accel", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.accel); }) },
    { "decel", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.decel); }) },
    { "target", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.target); }) },
    { "targetname", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.targetname); }) },
    { "pathtarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.pathtarget); }) },
    { "deathtarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.deathtarget); }) },
    { "healthtarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.healthtarget); }) },
    { "itemtarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.itemtarget); }) },
    { "killtarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.killtarget); }) },
    { "combattarget", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.combattarget); }) },
    { "message", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.message); }) },
    { "team", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.team); }) },
    { "wait", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.wait); }) },
    { "delay", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.delay); }) },
    { "random", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.random); }) },
    { "move_origin", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.move_origin); }) },
    { "move_angles", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.move_angles); }) },
    { "style", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.style); }) },
    { "style_on", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.style_on); }) },
    { "style_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.style_off); }) },
    { "crosslevel_flags", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadUInt(tokenizer, ent.crosslevel_flags); }) },
    { "count", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.count); }) },
    { "health", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.health); }) },
    { "sounds", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.sounds); }) },
    { "light", cast<parse_ent_f>(function(tokenizer, ent) { return true; }) },
    { "dmg", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.dmg); }) },
    { "mass", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.mass); }) },
    { "volume", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.volume); }) },
    { "attenuation", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.attenuation); }) },
    { "map", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.map); }) },
    { "origin", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.e.s.origin); }) },
    { "angles", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.e.s.angles); }) },
    { "angle", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadAngle(tokenizer, ent.e.s.angles); }) },
    { "rgba", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadColor(tokenizer, ent.e.s.skinnum); }) },
    { "hackflags", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.hackflags); }) },
    { "alpha", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.e.s.alpha); }) },
    { "scale", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.e.s.scale); }) },
    { "mangle", cast<parse_ent_f>(function(tokenizer, ent) { return true; }) },
    { "dead_frame", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.monsterinfo.start_frame); }) },
    { "frame", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.e.s.frame); }) },
    { "effects", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadEffects(tokenizer, ent.e.s.effects); }) },
    { "renderfx", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadRenderFX(tokenizer, ent.e.s.renderfx); }) },
    { "fog_color", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.fog.rgb); }) },
    { "fog_color_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.fog_off.rgb); }) },
    { "fog_density", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.fog.density); }) },
    { "fog_density_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.fog_off.density); }) },
    { "fog_sky_factor", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.fog.skyfactor); }) },
    { "fog_sky_factor_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.fog_off.skyfactor); }) },
    { "heightfog_falloff", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog.falloff); }) },
    { "heightfog_density", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog.density); }) },
    { "heightfog_start_color", cast<parse_ent_f>(function(tokenizer, ent) { 
        vec3_t sc;
        bool result = ED_LoadVector(tokenizer, sc);
        ent.heightfog.start.x = sc.x;
        ent.heightfog.start.y = sc.y;
        ent.heightfog.start.z = sc.z;
        return result;
    }) },
    { "heightfog_start_dist", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog.start.w); }) },
    { "heightfog_end_color", cast<parse_ent_f>(function(tokenizer, ent) {
        vec3_t sc;
        bool result = ED_LoadVector(tokenizer, sc);
        ent.heightfog.end.x = sc.x;
        ent.heightfog.end.y = sc.y;
        ent.heightfog.end.z = sc.z;
        return result;
    }) },
    { "heightfog_end_dist", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog.end.w); }) },
    { "heightfog_falloff_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog_off.falloff); }) },
    { "heightfog_density_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog_off.density); }) },
    { "heightfog_start_color_off", cast<parse_ent_f>(function(tokenizer, ent) {
        vec3_t sc;
        bool result = ED_LoadVector(tokenizer, sc);
        ent.heightfog_off.start.x = sc.x;
        ent.heightfog_off.start.y = sc.y;
        ent.heightfog_off.start.z = sc.z;
        return result;
    }) },
    { "heightfog_start_dist_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog_off.start.w); }) },
    { "heightfog_end_color_off", cast<parse_ent_f>(function(tokenizer, ent) {
        vec3_t sc;
        bool result = ED_LoadVector(tokenizer, sc);
        ent.heightfog_off.end.x = sc.x;
        ent.heightfog_off.end.y = sc.y;
        ent.heightfog_off.end.z = sc.z;
        return result;
    }) },
    { "heightfog_end_dist_off", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.heightfog_off.end.w); }) },
    { "eye_position", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.move_origin); }) },
    { "vision_cone", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadFloat(tokenizer, ent.vision_cone); }) },
    { "message2", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadString(tokenizer, ent.map); }) },
    { "mins", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.e.mins); }) },
    { "maxs", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadVector(tokenizer, ent.e.maxs); }) },
    { "bmodel_anim_start", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.start); }) },
    { "bmodel_anim_end", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.end); }) },
    { "bmodel_anim_style", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadBmodelAnimStyle(tokenizer, ent.bmodel_anim.style); }) },
    { "bmodel_anim_speed", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.speed); }) },
    { "bmodel_anim_nowrap", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadBool(tokenizer, ent.bmodel_anim.nowrap); }) },
    { "bmodel_anim_alt_start", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.alt_start); }) },
    { "bmodel_anim_alt_end", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.alt_end); }) },
    { "bmodel_anim_alt_style", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadBmodelAnimStyle(tokenizer, ent.bmodel_anim.alt_style); }) },
    { "bmodel_anim_alt_speed", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.bmodel_anim.alt_speed); }) },
    { "bmodel_anim_alt_nowrap", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadBool(tokenizer, ent.bmodel_anim.alt_nowrap); }) },
    { "power_armor_power", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.monsterinfo.power_armor_power); }) },
    { "power_armor_type", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadPowerArmorPower(tokenizer, ent.monsterinfo.power_armor_type); }) },
    { "monster_slots", cast<parse_ent_f>(function(tokenizer, ent) { return ED_LoadInt(tokenizer, ent.monsterinfo.monster_slots); }) }
};

// AS_TODO: use hashmap with some sort of dynamic compilation.
// maybe can do something better when reflection is in.
bool ED_ParseField(const string &in key, tokenizer_t &tokenizer, ASEntity &ent, spawn_temp_t &st)
{
    // check st first
    {
        parse_st_f @f;

        if (st_fields.get(key.aslower(), @f))
            return f(tokenizer, st);
    }

    // try edict
    {
        parse_ent_f @f;

        if (ent_fields.get(key.aslower(), @f))
            return f(tokenizer, ent);
    }

	return false;
}

void ED_ParseEdict(tokenizer_t &tokenizer, ASEntity &ent, spawn_temp_t &st)
{
	string  keyname;
    string  com_token;

	bool init = false;
	
	// go through all the dictionary pairs
	while (tokenizer.next())
	{
		// parse key
		if (tokenizer.token_equals("}"))
			break;
		if (!tokenizer.has_token)
			gi_Com_Error("ED_ParseEntity: EOF without closing brace");

        keyname = tokenizer.as_string();

        tokenizer.next();
    
		// parse value
		if (!tokenizer.has_token)
			gi_Com_Error("ED_ParseEntity: EOF without closing brace");

		if (tokenizer.token_equals("}"))
			gi_Com_Error("ED_ParseEntity: closing brace without data");

		init = true;

		// keynames with a leading underscore are used for utility comments,
		// and are immediately discarded by quake
		if (keyname[0] == '_')
		{
			// [Sam-KEX] Hack for setting RGBA for shadow-casting lights
			if (keyname == "_color")
				ED_LoadColor(tokenizer, ent.e.s.skinnum);

			continue;
		}

		if (!ED_ParseField(keyname, tokenizer, ent, st))
        {
            gi_Com_Print("WARNING: can't parse key {} (value is {})\n", keyname, tokenizer.as_string());
        }
        else
        {
            st.keys_specified.add(keyname);
        }
	}

	if (!init)
        ent = ASEntity(ent.e);
    else
    {
        if (st.was_key_specified("bmodel_anim_start") || st.was_key_specified("bmodel_anim_end"))
            ent.bmodel_anim.enabled = true;
    }
}

namespace spawnflags
{
    // these spawnflags affect every entity. note that items are a bit special
    // because these 8 bits are instead used for power cube bits.
    const uint32  NONE = 0,
                        NOT_EASY = 0x00000100,
                        NOT_MEDIUM = 0x00000200,
                        NOT_HARD = 0x00000400,
                        NOT_DEATHMATCH = 0x00000800,
                        NOT_COOP = 0x00001000,
                        RESERVED1 = 0x00002000,
                        COOP_ONLY = 0x00004000,
                        RESERVED2 = 0x00008000;

    const uint32 EDITOR_MASK = (NOT_EASY | NOT_MEDIUM | NOT_HARD | NOT_DEATHMATCH |
                                NOT_COOP | RESERVED1 | COOP_ONLY | RESERVED2);
}

/*
================
G_FindTeams

Chain together all entities with a matching team field.

All but the first will have the FL_TEAMSLAVE flag set.
All but the last will have the teamchain field set to the next one
================
*/

// adjusts teams so that trains that move their children
// are in the front of the team
void G_FixTeams()
{
	ASEntity @e, e2, chain;
	uint32 i, j;
	uint32 c;

	c = 0;
	for (i = max_clients + 1; i < num_edicts; i++)
	{
        @e = entities[i];

		if (!e.e.inuse)
			continue;
		if (e.team.empty())
			continue;
		if (e.classname == "func_train" && (e.spawnflags & spawnflags::train::MOVE_TEAMCHAIN) != 0)
		{
			if ((e.flags & ent_flags_t::TEAMSLAVE) != 0)
			{
				@chain = e;
				@e.teammaster = e;
				@e.teamchain = null;
				e.flags = ent_flags_t(e.flags & ~ent_flags_t::TEAMSLAVE);
				e.flags = ent_flags_t(e.flags | ent_flags_t::TEAMMASTER);
				c++;
				for (j = max_clients + 1; j < num_edicts; j++)
				{
                    @e2 = entities[j];

					if (e2 is e)
						continue;
					if (!e2.e.inuse)
						continue;
					if (e2.team.empty())
						continue;
					if (e.team == e2.team)
					{
						@chain.teamchain = e2;
						@e2.teammaster = e;
						@e2.teamchain = null;
						@chain = e2;
						e2.flags = ent_flags_t(e2.flags | ent_flags_t::TEAMSLAVE);
						e2.flags = ent_flags_t(e2.flags & ~ent_flags_t::TEAMMASTER);
						e2.movetype = movetype_t::PUSH;
						e2.speed = e.speed;
					}
				}
			}
		}
	}

	gi_Com_Print("{} teams repaired\n", c);
}

void G_FindTeams()
{
	ASEntity @e, e2, chain;
	uint32 i, j;
	uint32 c, c2;

	c = 0;
	c2 = 0;
	for (i = max_clients + 1; i < num_edicts; i++)
	{
        @e = entities[i];

		if (!e.e.inuse)
			continue;
		if (e.team.empty())
			continue;
		if ((e.flags & ent_flags_t::TEAMSLAVE) != 0)
			continue;
		@chain = e;
		@e.teammaster = e;
		e.flags = ent_flags_t(e.flags | ent_flags_t::TEAMMASTER);
		c++;
		c2++;
		for (j = i + 1; j < num_edicts; j++)
		{
            @e2 = entities[j];

			if (!e2.e.inuse)
				continue;
			if (e2.team.empty())
				continue;
            if ((e2.flags & ent_flags_t::TEAMSLAVE) != 0)
                continue;
			if (e.team == e2.team)
			{
				c2++;
				@chain.teamchain = e2;
				@e2.teammaster = e;
				@chain = e2;
				e2.flags = ent_flags_t(e2.flags | ent_flags_t::TEAMSLAVE);
			}
		}
	}

	// ROGUE
	G_FixTeams();
	// ROGUE

	gi_Com_Print("{} teams with {} entities\n", c, c2);
}

// inhibit entities from game based on cvars & spawnflags
bool G_InhibitEntity(ASEntity &ent)
{
	// dm-only
	if (deathmatch.integer != 0)
		return (ent.spawnflags & spawnflags::NOT_DEATHMATCH) != 0;

	// coop flags
	if (coop.integer != 0 && (ent.spawnflags & spawnflags::NOT_COOP) != 0)
		return true;
	else if (coop.integer == 0 && (ent.spawnflags & spawnflags::COOP_ONLY) != 0)
		return true;

	// skill
	return ((skill.integer == 0) && (ent.spawnflags & spawnflags::NOT_EASY) != 0) ||
		   ((skill.integer == 1) && (ent.spawnflags & spawnflags::NOT_MEDIUM) != 0) ||
		   ((skill.integer >= 2) && (ent.spawnflags & spawnflags::NOT_HARD) != 0);
}

// [Paril-KEX]
void G_PrecacheInventoryItems()
{
	if (deathmatch.integer != 0)
		return;

	for (uint i = 0; i < max_clients; i++)
	{
		ASClient @cl = players[i].client;

		for (item_id_t id = item_id_t::NULL; id != item_id_t::TOTAL; id = item_id_t(id + 1))
			if (cl.pers.inventory[id] != 0)
				PrecacheItem(GetItemByIndex(id));
	}
}

// [Paril-KEX]
void G_PrecacheStartItems(const string &in items)
{
	if (items.empty())
		return;

    tokenizer_t tokenizer(items);
    tokenizer.separators = ";";

	while (tokenizer.next())
	{
		if (!tokenizer.has_token)
        {
            gi_Com_Print("start_items string too long or ends early\n");
			break;
        }

        tokenizer.push_state();
        tokenizer.separators = " ";

        if (!tokenizer.next())
            gi_Com_Error("Invalid start_items string");

		const gitem_t @item = FindItemByClassname(tokenizer.as_string());

		if (item is null || item.pickup is null)
			gi_Com_Error("Invalid g_start_item entry: {}\n", tokenizer.as_string());

		int count = 1;

		if (tokenizer.next())
			count = tokenizer.as_int32();

		if (count != 0)
            PrecacheItem(item);

        tokenizer.pop_state();
        tokenizer.separators = ";";
	}
}

void SpawnEntities(string &in mapname, string &in entstring, string &in spawnpoint)
{
	// clear cached indices
	cached_soundindex_clear_all();
	cached_modelindex_clear_all();
	cached_imageindex_clear_all();

	ASEntity @ent;
	int		 inhibit;

	int skill_level = clamp(skill.integer, 0, 3);
	if (skill.integer != skill_level)
		gi_cvar_forceset("skill", format("{}", skill_level));

	SaveClientData();

    level = level_locals_t();

	level.is_spawning = true;

    // get rid of everything from the previous level
    // except the special reserved entities.
    // we have to back up the client data, but all
    // the edict_t stuff gets wiped.
    internal::allow_value_assign = true;
	for (uint i = 0; i < num_edicts; i++)
    {
        if (i < max_clients + 1 + BODY_QUEUE_SIZE)
        {
            edict_t @e = G_EdictForNum(i);
            e.reset();
            ASClient @cl = entities[i].client;
            @entities[i] = ASEntity(e);
            @entities[i].client = cl;

            if (i >= 1 && i <= max_clients)
                @players[i - 1] = @entities[i];
        }
        else
            entities[i].Free();
    }
    internal::allow_value_assign = false;

	// all other flags are not important atm
    server_flags = server_flags_t(server_flags & server_flags_t::LOADING);

	level.mapname = mapname;
	// Paril: fixes a bug where autosaves will start you at
	// the wrong spawnpoint if they happen to be non-empty
	// (mine2 -> mine3)
	if (!game.autosaved)
		game.spawnpoint = spawnpoint;

	level.is_n64 = Q_strncasecmp(level.mapname, "q64/", 4) == 0;
	level.is_psx = Q_strncasecmp(level.mapname, "psx/", 4) == 0;

	level.coop_scale_players = 0;
	level.coop_health_scaling = clamp(g_coop_health_scaling.value, 0.0f, 1.0f);

	// set client fields on player ents
	for (uint32 i = 0; i < max_clients; i++)
	{
		// "disconnect" all players since the level is switching
		players[i].client.pers.connected = false;
		players[i].client.pers.spawned = false;
	}

	@ent = null;
	inhibit = 0;

	// reserve some spots for dead player bodies for coop / deathmatch
	InitBodyQue();

    tokenizer_t tokenizer(entstring);

	// parse ents
	while (tokenizer.next())
	{
		// parse the opening brace
		if (!tokenizer.has_token)
			break;
		if (!tokenizer.token_equals("{"))
			gi_Com_Error("ED_LoadFromFile: found \"{}\" when expecting {{", tokenizer.as_string());
        
		if (ent is null)
			@ent = @world;
		else
			@ent = G_Spawn();

		spawn_temp_t st = spawn_temp_t();

		ED_ParseEdict(tokenizer, ent, st);

		// remove things (except the world) from different skill levels or deathmatch
		if (@ent != @world)
		{
			if (G_InhibitEntity(ent))
			{
				ent.Free();
				inhibit++;
				continue;
			}

			ent.spawnflags &= ~spawnflags::EDITOR_MASK;
		}

		ED_CallSpawn(ent, st);

		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::IR_VISIBLE); // PGM
	}

	gi_Com_Print("{} entities inhibited\n", inhibit);

	// precache start_items
	G_PrecacheStartItems(g_start_items.stringval);
	G_PrecacheStartItems(level.start_items);

	// precache player inventory items
	G_PrecacheInventoryItems();

	G_FindTeams();

	// ZOID
	CTFSpawn();
	// ZOID

	// ROGUE
	if (deathmatch.integer != 0)
	{
        // AS_TODO
		//if (g_dm_random_items.integer != 0)
		//	PrecacheForRandomRespawn();
	}
	// ROGUE

	setup_shadow_lights();

    // AS_TODO
	/*if (gi.cvar("g_print_spawned_entities", "0", CVAR_NOFLAGS)->integer)
	{
		std::map<std::string, int> entities;
		int total_monster_health = 0;

		for (size_t i = 0; i < globals.num_edicts; i++)
		{
			edict_t *e = &globals.edicts[i];

			if (!e->inuse)
				continue;
			else if (!e->item && !e->monsterinfo.stand)
				continue;

			const char *cn = e->classname ? e->classname : "noclass";

			if (auto f = entities.find(cn); f != entities.end())
			{
				f->second++;
			}
			else
			{
				entities.insert({ cn, 1 });
			}

			if (e->monsterinfo.stand)
			{
				total_monster_health += e->health;
			}

			if (e->item && strcmp(e->classname, e->item->classname))
			{
				cn = e->item->classname ? e->item->classname : "noclass";

				if (auto f = entities.find(cn); f != entities.end())
				{
					f->second++;
				}
				else
				{
					entities.insert({ cn, 1 });
				}
			}
		}

		gi.Com_PrintFmt("total monster health: {}\n", total_monster_health);
		
		for (auto &e : entities)
		{
			gi.Com_PrintFmt("{}: {}\n", e.first, e.second);
		}
	}*/

	level.is_spawning = false;
}

cached_soundindex snd_fry("player/fry.wav");

void SP_worldspawn(ASEntity &ent)
{
    ent.movetype = movetype_t::PUSH;
    ent.e.solid = solid_t::BSP;
    ent.Init();
    ent.e.s.modelindex = MODELINDEX_WORLD;
    ent.gravity = 1.0f;

	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (st.hub_map)
	{
		level.hub_map = true;

		// clear helps
		game.help1changed = game.help2changed = 0;

		for (uint i = 0; i < max_clients; i++)
		{
			players[i].client.pers.game_help1changed = players[i].client.pers.game_help2changed = 0;
			players[i].client.resp.coop_respawn.game_help1changed = players[i].client.resp.coop_respawn.game_help2changed = 0;
		}
	}

	if (!st.achievement.empty())
		level.achievement = st.achievement;

	//---------------

	// set configstrings for items
	SetItemNames();

	if (!st.nextmap.empty())
		level.nextmap = st.nextmap;

	// make some data visible to the server

	if (!ent.message.empty())
	{
		gi_configstring(uint(configstring_id_t::NAME), ent.message);
		level.level_name = ent.message;
	}
	else
		level.level_name = level.mapname;

	if (!st.sky.empty())
		gi_configstring(uint(configstring_id_t::SKY), st.sky);
	else
		gi_configstring(uint(configstring_id_t::SKY), "unit1_");

	gi_configstring(uint(configstring_id_t::SKYROTATE), format("{} {}", st.skyrotate, st.skyautorotate));

	gi_configstring(uint(configstring_id_t::SKYAXIS), format("{}", st.skyaxis));

	if (!st.music.empty())
	{
		gi_configstring(uint(configstring_id_t::CDTRACK), st.music);
	}
	else
	{
		gi_configstring(uint(configstring_id_t::CDTRACK), format("{}", ent.sounds));
	}

	if (level.is_n64)
		gi_configstring(uint(configstring_id_t::CD_LOOP_COUNT), "0");
	else if (st.was_key_specified("loop_count"))
		gi_configstring(uint(configstring_id_t::CD_LOOP_COUNT), format("{}", st.loop_count));
	else
		gi_configstring(uint(configstring_id_t::CD_LOOP_COUNT), "");

	if (st.instantitems > 0 || level.is_n64)
	{
		level.instantitems = true;
	}

	// [Paril-KEX]
	if (deathmatch.integer == 0)
		gi_configstring(uint(configstring_id_t::GAME_STYLE), format("{}", int(game_style_t::PVE)));
	else if (teamplay.integer != 0 || ctf.integer != 0)
		gi_configstring(uint(configstring_id_t::GAME_STYLE), format("{}", int(game_style_t::TDM)));
	else
		gi_configstring(uint(configstring_id_t::GAME_STYLE), format("{}", int(game_style_t::FFA)));

	// [Paril-KEX]
	if (!st.goals.empty())
	{
		level.goals = st.goals;
		game.help1changed++;
	}

	if (!st.start_items.empty())
		level.start_items = st.start_items;

	if (st.no_grapple != 0)
		level.no_grapple = true;

	gi_configstring(uint(configstring_id_t::MAXCLIENTS), format("{}", max_clients));

	int override_physics = gi_cvar("g_override_physics_flags", "-1", cvar_flags_t::NOFLAGS).integer;

	if (override_physics == -1)
	{
		if (deathmatch.integer != 0 && st.was_key_specified("physics_flags_dm"))
			override_physics = st.physics_flags_dm;
		else if (deathmatch.integer == 0 && st.was_key_specified("physics_flags_sp"))
			override_physics = st.physics_flags_sp;
	}

	if (override_physics >= 0)
		pm_config.physics_flags = physics_flags_t(override_physics);
	else
	{
		if (level.is_n64)
			pm_config.physics_flags = physics_flags_t(pm_config.physics_flags | physics_flags_t::N64_MOVEMENT);

		if (level.is_psx)
			pm_config.physics_flags = physics_flags_t(pm_config.physics_flags | physics_flags_t::PSX_MOVEMENT | physics_flags_t::PSX_SCALE);

		if (deathmatch.integer != 0)
			pm_config.physics_flags = physics_flags_t(pm_config.physics_flags | physics_flags_t::DEATHMATCH);
	}

	gi_configstring(uint(game_configstring_id_t::PHYSICS_FLAGS), format("{}", int(pm_config.physics_flags)));
	
	level.primary_objective_string = "$g_primary_mission_objective";
	level.secondary_objective_string = "$g_secondary_mission_objective";

	if (!st.primary_objective_string.empty())
		level.primary_objective_string = st.primary_objective_string;
	if (!st.secondary_objective_string.empty())
		level.secondary_objective_string = st.secondary_objective_string;
	
	level.primary_objective_title = "$g_pc_primary_objective";
	level.secondary_objective_title = "$g_pc_secondary_objective";

	if (!st.primary_objective_title.empty())
		level.primary_objective_title = st.primary_objective_title;
	if (!st.secondary_objective_title.empty())
		level.secondary_objective_title = st.secondary_objective_title;

	// statusbar prog
	G_InitStatusbar();

	// [Paril-KEX] air accel handled by game DLL now, and allow
	// it to be changed in sp/coop
	gi_configstring(uint(configstring_id_t::AIRACCEL), format("{}", sv_airaccelerate.integer));
	pm_config.airaccel = sv_airaccelerate.integer;

	game.airacceleration_modified = sv_airaccelerate.modified_count;

	//---------------

	// help icon for statusbar
	gi_imageindex("i_help");
	level.pic_health = gi_imageindex("i_health");
	gi_imageindex("help");
	gi_imageindex("field_3");

	if (st.gravity.empty())
	{
		level.gravity = 800.0f;
		gi_cvar_set("sv_gravity", "800");
	}
	else
	{
		level.gravity = parseFloat(st.gravity);
		gi_cvar_set("sv_gravity", st.gravity);
	}

	snd_fry.precache(); // standing in lava / slime
	
	PrecacheItem(GetItemByIndex(item_id_t::ITEM_COMPASS));
	PrecacheItem(GetItemByIndex(item_id_t::WEAPON_BLASTER));

	if (g_dm_random_items.integer != 0)
		for (item_id_t i = item_id_t(item_id_t::NULL + 1); i < item_id_t::TOTAL; i = item_id_t(i + 1))
			PrecacheItem(GetItemByIndex(i));

	gi_soundindex("player/lava1.wav");
	gi_soundindex("player/lava2.wav");

	gi_soundindex("misc/pc_up.wav");
	gi_soundindex("misc/talk1.wav");

	// gibs
	gi_soundindex("misc/udeath.wav");

	gi_soundindex("items/respawn1.wav");
	gi_soundindex("misc/mon_power2.wav");

	// sexed sounds
	gi_soundindex("*death1.wav");
	gi_soundindex("*death2.wav");
	gi_soundindex("*death3.wav");
	gi_soundindex("*death4.wav");
	gi_soundindex("*fall1.wav");
	gi_soundindex("*fall2.wav");
	gi_soundindex("*gurp1.wav"); // drowning damage
	gi_soundindex("*gurp2.wav");
	gi_soundindex("*jump1.wav"); // player jump
	gi_soundindex("*pain25_1.wav");
	gi_soundindex("*pain25_2.wav");
	gi_soundindex("*pain50_1.wav");
	gi_soundindex("*pain50_2.wav");
	gi_soundindex("*pain75_1.wav");
	gi_soundindex("*pain75_2.wav");
	gi_soundindex("*pain100_1.wav");
	gi_soundindex("*pain100_2.wav");
	gi_soundindex("*drown1.wav"); // [Paril-KEX]

	// sexed models
	foreach (gitem_t @item : itemlist)
		item.vwep_index = 0;

	foreach (gitem_t @item : itemlist)
	{
		if (item.vwep_model.empty())
			continue;

		foreach (gitem_t @check : itemlist)
		{
			if (!check.vwep_model.empty() && Q_strcasecmp(item.vwep_model, check.vwep_model) == 0 && check.vwep_index != 0)
			{
				item.vwep_index = check.vwep_index;
				break;
			}
		}

		if (item.vwep_index != 0)
			continue;

		item.vwep_index = gi_modelindex(item.vwep_model);

		if (level.vwep_offset == 0)
			level.vwep_offset = item.vwep_index;
	}

	//-------------------

	gi_soundindex("player/gasp1.wav"); // gasping for air
	gi_soundindex("player/gasp2.wav"); // head breaking surface, not gasping

	gi_soundindex("player/watr_in.wav");  // feet hitting water
	gi_soundindex("player/watr_out.wav"); // feet leaving water

	gi_soundindex("player/watr_un.wav"); // head going underwater

	gi_soundindex("player/u_breath1.wav");
	gi_soundindex("player/u_breath2.wav");

	gi_soundindex("player/wade1.wav");
	gi_soundindex("player/wade2.wav");
	gi_soundindex("player/wade3.wav");

    // AS_TODO
/*#ifdef PSX_ASSETS
	gi_soundindex("player/breathout1.wav");
	gi_soundindex("player/breathout2.wav");
	gi_soundindex("player/breathout3.wav");
#endif*/

	gi_soundindex("items/pkup.wav");   // bonus item pickup
	gi_soundindex("world/land.wav");   // landing thud
	gi_soundindex("misc/h2ohit1.wav"); // landing splash

	gi_soundindex("items/damage.wav");
	gi_soundindex("items/protect.wav");
	gi_soundindex("items/protect4.wav");
	gi_soundindex("weapons/noammo.wav");
	gi_soundindex("weapons/lowammo.wav");
	gi_soundindex("weapons/change.wav");

	gi_soundindex("infantry/inflies1.wav");

	sm_meat_index.precache();
	gi_modelindex("models/objects/gibs/arm/tris.md2");
	gi_modelindex("models/objects/gibs/bone/tris.md2");
	gi_modelindex("models/objects/gibs/bone2/tris.md2");
	gi_modelindex("models/objects/gibs/chest/tris.md2");
	gi_modelindex("models/objects/gibs/skull/tris.md2");
	gi_modelindex("models/objects/gibs/head2/tris.md2");
	gi_modelindex("models/objects/gibs/sm_metal/tris.md2");

	level.pic_ping = gi_imageindex("loc_ping");

	//
	// Setup light animation tables. 'a' is total darkness, 'z' is doublebright.
	//

	// 0 normal
	gi_configstring(uint(configstring_id_t::LIGHTS) + 0, "m");

	// 1 FLICKER (first variety)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	gi_configstring(uint(configstring_id_t::LIGHTS) + 2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	gi_configstring(uint(configstring_id_t::LIGHTS) + 4, "mamamamamama");

	// 5 GENTLE PULSE 1
	gi_configstring(uint(configstring_id_t::LIGHTS) + 5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)`map
	gi_configstring(uint(configstring_id_t::LIGHTS) + 7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	gi_configstring(uint(configstring_id_t::LIGHTS) + 10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	gi_configstring(uint(configstring_id_t::LIGHTS) + 11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// [Paril-KEX] 12 N64's 2 (fast strobe)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 12, "zzazazzzzazzazazaaazazzza");

	// [Paril-KEX] 13 N64's 3 (half of strong pulse)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 13, "abcdefghijklmnopqrstuvwxyz");

	// [Paril-KEX] 14 N64's 4 (fast strobe)
	gi_configstring(uint(configstring_id_t::LIGHTS) + 14, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	gi_configstring(uint(configstring_id_t::LIGHTS) + 63, "a");

	// coop respawn strings
	if (coop.integer != 0)
	{
		gi_configstring(configstring_id_t(game_configstring_id_t::COOP_RESPAWN_STRING + 0), "$g_coop_respawn_in_combat");
		gi_configstring(configstring_id_t(game_configstring_id_t::COOP_RESPAWN_STRING + 1), "$g_coop_respawn_bad_area");
		gi_configstring(configstring_id_t(game_configstring_id_t::COOP_RESPAWN_STRING + 2), "$g_coop_respawn_blocked");
		gi_configstring(configstring_id_t(game_configstring_id_t::COOP_RESPAWN_STRING + 3), "$g_coop_respawn_waiting");
		gi_configstring(configstring_id_t(game_configstring_id_t::COOP_RESPAWN_STRING + 4), "$g_coop_respawn_no_lives");
	}
}
