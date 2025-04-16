const uint SAVE_FORMAT_VERSION = 2;

// add wrappers
void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const string &in value)
{
    if (!value.empty())
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const uint64 &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const int64 &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const effects_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const solid_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const ai_flags_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const renderfx_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const handedness_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const item_id_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const pmtype_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const weaponstate_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const water_level_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const anim_priority_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const move_state_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const ai_attack_state_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const combat_style_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const svflags_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const contents_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const movetype_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const plat2flags_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const bmodel_animstyle_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const mod_id_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const pmflags_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const ent_flags_t &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const double &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const float &in value)
{
    if (value != 0)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const float &in value, const float &in defaultValue)
{
    if (value != defaultValue)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const bool &in value)
{
    if (value)
        obj.obj_add(key, doc.val(value));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const gtime_t &in value)
{
    if (value)
        obj.obj_add(key, doc.val(value.milliseconds));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const vec3_t &in v)
{
    if (v)
    {
        json_mutval vector = doc.val_arr();
        vector.arr_append(doc.val(v[0]));
        vector.arr_append(doc.val(v[1]));
        vector.arr_append(doc.val(v[2]));
        obj.obj_add(key, vector);
    }
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const vec4_t &in v)
{
    if (v)
    {
        json_mutval vector = doc.val_arr();
        vector.arr_append(doc.val(v[0]));
        vector.arr_append(doc.val(v[1]));
        vector.arr_append(doc.val(v[2]));
        vector.arr_append(doc.val(v[3]));
        obj.obj_add(key, vector);
    }
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const vec3_t &in v, const vec3_t &in defaultValue)
{
    if (v != defaultValue)
    {
        json_mutval vector = doc.val_arr();
        vector.arr_append(doc.val(v[0]));
        vector.arr_append(doc.val(v[1]));
        vector.arr_append(doc.val(v[2]));
        obj.obj_add(key, vector);
    }
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const gitem_t @value)
{
    if (value !is null)
        obj.obj_add(key, doc.val(value.classname));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const edict_t @value)
{
    if (value !is null)
        obj.obj_add(key, doc.val(value.s.number));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const ASEntity @value)
{
    if (value !is null)
        obj.obj_add(key, doc.val(value.e.s.number));
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, json_mutval v)
{
    if (v.is_ctn && v.length != 0)
        obj.obj_add(key, v);
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const fog_t &in v)
{
    json_mutval fv = doc.val_obj();
    json_add_optional(doc, fv, "density", v.density);
    json_add_optional(doc, fv, "rgb", v.rgb);
    json_add_optional(doc, fv, "skyfactor", v.skyfactor);
    json_add_optional(doc, obj, key, fv);
}

void json_add_optional(json_mutdoc &doc, json_mutval obj, const string &in key, const height_fog_t &in v)
{
    json_mutval fv = doc.val_obj();
    json_add_optional(doc, fv, "density", v.density);
    json_add_optional(doc, fv, "end", v.end);
    json_add_optional(doc, fv, "falloff", v.falloff);
    json_add_optional(doc, fv, "start", v.start);
    json_add_optional(doc, obj, key, fv);
}

// get wrappers
void json_get_optional(json_doc &doc, json_val obj, float &out value, const float &in defaultValue)
{
    if (!obj.valid)
        value = defaultValue;
    else
        obj.get(value);
}

void json_get_optional(json_doc &doc, json_val obj, gtime_t &out value)
{
    int64 i64;
    obj.get(i64);
    value = time_ms(i64);
}

void json_get_optional(json_doc &doc, json_val obj, vec3_t &out v)
{
    if (obj.is_arr && obj.length == 3)
    {
        json_arr_iter iter(obj);
        iter.next.get(v.x);
        iter.next.get(v.y);
        iter.next.get(v.z);
    }
    else
        v = vec3_origin;
}

const vec4_t vec4_origin = { 0, 0, 0, 0 };

void json_get_optional(json_doc &doc, json_val obj, vec4_t &out v)
{
    if (obj.is_arr && obj.length == 4)
    {
        json_arr_iter iter(obj);
        iter.next.get(v.x);
        iter.next.get(v.y);
        iter.next.get(v.z);
        iter.next.get(v.w);
    }
    else
        v = vec4_origin;
}

void json_get_optional(json_doc &doc, json_val obj, vec3_t &out v, const vec3_t &in defaultValue)
{
    if (obj.is_arr && obj.length == 3)
    {
        json_arr_iter iter(obj);
        iter.next.get(v.x);
        iter.next.get(v.y);
        iter.next.get(v.z);
    }
    else
        v = defaultValue;
}

void json_get_optional(json_doc &doc, json_val obj, const gitem_t @&out value)
{
    if (!obj.is_str)
        @value = null;
    else
        @value = FindItemByClassname(obj.str);
}

void json_get_optional(json_doc &doc, json_val obj, edict_t @&out value)
{
    if (obj.is_num)
    {
        @value = G_EdictForNum(obj.get_uint32());

        // "reserve" an ASEntity slot
        if (entities[value.s.number] is null)
            @entities[value.s.number] = ASEntity(value);
    }
    else
        @value = null;
}

void json_get_optional(json_doc &doc, json_val obj, ASEntity @&out value)
{
    edict_t @e;
    json_get_optional(doc, obj, e);

    if (@e !is null)
        @value = entities[e.s.number];
    else
        @value = null;
}

void json_get_optional(json_doc &doc, json_val obj, fog_t &out value)
{
    obj["density"].get(value.density);
    json_get_optional(doc, obj["rgb"], value.rgb);
    obj["skyfactor"].get(value.skyfactor);
}

void json_get_optional(json_doc &doc, json_val obj, height_fog_t &out value)
{
    obj["density"].get(value.density);
    json_get_optional(doc, obj["end"], value.end);
    obj["falloff"].get(value.falloff);
    json_get_optional(doc, obj["start"], value.start);
}

json_mutval WriteGameLocals(json_mutdoc &doc)
{
    json_mutval obj = doc.val_obj();

    json_add_optional(doc, obj, "helpmessage1", game.helpmessage1);
    json_add_optional(doc, obj, "helpmessage2", game.helpmessage2);
    json_add_optional(doc, obj, "help1changed", game.help1changed);
    json_add_optional(doc, obj, "help2changed", game.help2changed);

    json_add_optional(doc, obj, "spawnpoint", game.spawnpoint);

    json_add_optional(doc, obj, "cross_level_flags", game.cross_level_flags);
    json_add_optional(doc, obj, "cross_unit_flags", game.cross_unit_flags);

    json_add_optional(doc, obj, "autosaved", game.autosaved);

    return obj;
}

void ReadGameLocals(json_doc &doc, json_val obj)
{
    if (!obj.is_obj)
        return;

    obj["helpmessage1"].get(game.helpmessage1);
    obj["helpmessage2"].get(game.helpmessage2);
    obj["help1changed"].get(game.help1changed);
    obj["help2changed"].get(game.help2changed);

    obj["spawnpoint"].get(game.spawnpoint);

    obj["cross_level_flags"].get(game.cross_level_flags);
    obj["cross_unit_flags"].get(game.cross_unit_flags);

    obj["autosaved"].get(game.autosaved);
}

json_mutval WriteClientPersistent(json_mutdoc &doc, client_persistant_t &p)
{
    json_mutval obj = doc.val_obj();

    json_add_optional(doc, obj, "userinfo", p.userinfo);
    json_add_optional(doc, obj, "social_id", p.social_id);
    json_add_optional(doc, obj, "netname", p.netname);
    json_add_optional(doc, obj, "hand", p.hand);
    json_add_optional(doc, obj, "health", p.health);
    json_add_optional(doc, obj, "max_health", p.max_health);
    json_add_optional(doc, obj, "savedFlags", p.savedFlags);
    json_add_optional(doc, obj, "selected_item", p.selected_item);
    {
        json_mutval arr = doc.val_arr();
        for (int i = 0; i < item_id_t::TOTAL; i++)
            arr.arr_append(doc.val(p.inventory[i]));
        json_add_optional(doc, obj, "inventory", arr);
    }
    {
        json_mutval arr = doc.val_arr();
        for (int i = 0; i < ammo_t::MAX; i++)
            arr.arr_append(doc.val(p.max_ammo[i]));
        json_add_optional(doc, obj, "max_ammo", arr);
    }
    json_add_optional(doc, obj, "weapon", p.weapon);
    json_add_optional(doc, obj, "lastweapon", p.lastweapon);
    json_add_optional(doc, obj, "power_cubes", p.power_cubes);
    json_add_optional(doc, obj, "score", p.score);
    json_add_optional(doc, obj, "game_help1changed", p.game_help1changed);
    json_add_optional(doc, obj, "game_help2changed", p.game_help2changed);
    json_add_optional(doc, obj, "helpchanged", p.helpchanged);
    json_add_optional(doc, obj, "help_time", p.help_time);
    json_add_optional(doc, obj, "spectator", p.spectator);
    json_add_optional(doc, obj, "bob_skip", p.bob_skip);
    json_add_optional(doc, obj, "wanted_fog", p.wanted_fog);
    json_add_optional(doc, obj, "wanted_heightfog", p.wanted_heightfog);
    json_add_optional(doc, obj, "megahealth_time", p.megahealth_time);
    json_add_optional(doc, obj, "lives", p.lives);
    json_add_optional(doc, obj, "n64_crouch_warn_times", p.n64_crouch_warn_times);
    json_add_optional(doc, obj, "n64_crouch_warning", p.n64_crouch_warning);

    return obj;
}

void ReadClientPersistent(json_doc &doc, json_val obj, client_persistant_t &p)
{
    if (!obj.is_obj)
        return;

    obj["userinfo"].get(p.userinfo);
    obj["social_id"].get(p.social_id);
    obj["netname"].get(p.netname);
    obj["hand"].get_enum(p.hand);
    obj["health"].get(p.health);
    obj["max_health"].get(p.max_health);
    obj["savedFlags"].get_enum(p.savedFlags);
    obj["selected_item"].get_enum(p.selected_item);
    {
        json_val arr = obj["inventory"];

        if (arr.is_arr)
        {
            json_arr_iter iter(arr);
            int i = 0;

            while (iter.has_next)
            {
                json_val v = iter.next;
                p.inventory[i] = v.get_int32();
                i++;
            }
        }
    }
    {
        json_val arr = obj["max_ammo"];

        if (arr.is_arr)
        {
            json_arr_iter iter(arr);
            int i = 0;

            while (iter.has_next)
            {
                json_val v = iter.next;
                p.max_ammo[i] = v.get_int16();
                i++;
            }
        }
    }
    json_get_optional(doc, obj["weapon"], p.weapon);
    json_get_optional(doc, obj["lastweapon"], p.lastweapon);
    obj["power_cubes"].get(p.power_cubes);
    obj["score"].get(p.score);
    obj["game_help1changed"].get(p.game_help1changed);
    obj["game_help2changed"].get(p.game_help2changed);
    obj["helpchanged"].get(p.helpchanged);
    json_get_optional(doc, obj["help_time"], p.help_time);
    obj["spectator"].get(p.spectator);
    obj["bob_skip"].get(p.bob_skip);
    json_get_optional(doc, obj["wanted_fog"], p.wanted_fog);
    json_get_optional(doc, obj["wanted_heightfog"], p.wanted_heightfog);
    json_get_optional(doc, obj["megahealth_time"], p.megahealth_time);
    obj["lives"].get(p.lives);
    obj["n64_crouch_warn_times"].get(p.n64_crouch_warn_times);
    json_get_optional(doc, obj["n64_crouch_warning"], p.n64_crouch_warning);
}

json_mutval WriteClient(json_mutdoc &doc, ASEntity &ent)
{
    json_mutval obj = doc.val_obj();

    ASClient @cl = ent.client;
    gclient_t @gcl = ent.e.client;

    // ps.pmove
    json_add_optional(doc, obj, "ps.pmove.pm_type", gcl.ps.pmove.pm_type);
    json_add_optional(doc, obj, "ps.pmove.origin", gcl.ps.pmove.origin);
    json_add_optional(doc, obj, "ps.pmove.velocity", gcl.ps.pmove.velocity);
    json_add_optional(doc, obj, "ps.pmove.pm_flags", gcl.ps.pmove.pm_flags);
    json_add_optional(doc, obj, "ps.pmove.pm_time", gcl.ps.pmove.pm_time);
    json_add_optional(doc, obj, "ps.pmove.gravity", gcl.ps.pmove.gravity);
    json_add_optional(doc, obj, "ps.pmove.delta_angles", gcl.ps.pmove.delta_angles);
    json_add_optional(doc, obj, "ps.pmove.viewheight", gcl.ps.pmove.viewheight);

    // ps
    json_add_optional(doc, obj, "ps.viewangles", gcl.ps.viewangles);
    json_add_optional(doc, obj, "ps.viewoffset", gcl.ps.viewoffset);
    json_add_optional(doc, obj, "ps.gunangles", gcl.ps.gunangles);
    json_add_optional(doc, obj, "ps.gunoffset", gcl.ps.gunoffset);
    json_add_optional(doc, obj, "ps.gunindex", gcl.ps.gunindex);
    json_add_optional(doc, obj, "ps.gunframe", gcl.ps.gunframe);
    json_add_optional(doc, obj, "ps.gunskin", gcl.ps.gunskin);
    {
        json_mutval arr = doc.val_arr();
        for (int i = 0; i < 64; i++)
            arr.arr_append(doc.val(gcl.ps.stats[i]));
        json_add_optional(doc, obj, "ps.stats", arr);
    }

    // pers
    json_add_optional(doc, obj, "pers", WriteClientPersistent(doc, cl.pers));

    // resp.coop_respawn
    json_add_optional(doc, obj, "resp.coop_respawn", WriteClientPersistent(doc, cl.resp.coop_respawn));

    // resp
    json_add_optional(doc, obj, "resp.entertime", cl.resp.entertime);
    json_add_optional(doc, obj, "resp.score", cl.resp.score);
    json_add_optional(doc, obj, "resp.cmd_angles", cl.resp.cmd_angles);
    json_add_optional(doc, obj, "resp.spectator", cl.resp.spectator);

    // ASClient
    json_add_optional(doc, obj, "newweapon", cl.newweapon);
    json_add_optional(doc, obj, "killer_yaw", cl.killer_yaw);
    json_add_optional(doc, obj, "weaponstate", cl.weaponstate);
    json_add_optional(doc, obj, "kick.angles", cl.kick.angles);
    json_add_optional(doc, obj, "kick.origin", cl.kick.origin);
    json_add_optional(doc, obj, "kick.total", cl.kick.total);
    json_add_optional(doc, obj, "kick.time", cl.kick.time);
    json_add_optional(doc, obj, "quake_time", cl.quake_time);
    json_add_optional(doc, obj, "v_dmg_roll", cl.v_dmg_roll);
    json_add_optional(doc, obj, "v_dmg_pitch", cl.v_dmg_pitch);
    json_add_optional(doc, obj, "v_dmg_time", cl.v_dmg_time);
    json_add_optional(doc, obj, "fall_time", cl.fall_time);
    json_add_optional(doc, obj, "fall_value", cl.fall_value);
    json_add_optional(doc, obj, "damage_blend", cl.damage_blend);
    json_add_optional(doc, obj, "v_angle", cl.v_angle);
    json_add_optional(doc, obj, "bobtime", cl.bobtime);
    json_add_optional(doc, obj, "oldviewangles", cl.oldviewangles);
    json_add_optional(doc, obj, "oldvelocity", cl.oldvelocity);
    json_add_optional(doc, obj, "oldgroundentity", cl.oldgroundentity);
    json_add_optional(doc, obj, "next_drown_time", cl.next_drown_time);
    json_add_optional(doc, obj, "old_waterlevel", cl.old_waterlevel);
    json_add_optional(doc, obj, "breather_sound", cl.breather_sound);
    json_add_optional(doc, obj, "machinegun_shots", cl.machinegun_shots);
    json_add_optional(doc, obj, "anim_end", cl.anim_end);
    json_add_optional(doc, obj, "anim_priority", cl.anim_priority);
    json_add_optional(doc, obj, "anim_duck", cl.anim_duck);
    json_add_optional(doc, obj, "anim_run", cl.anim_run);
    json_add_optional(doc, obj, "quad_time", cl.quad_time);
    json_add_optional(doc, obj, "invincible_time", cl.invincible_time);
    json_add_optional(doc, obj, "breather_time", cl.breather_time);
    json_add_optional(doc, obj, "enviro_time", cl.enviro_time);
    json_add_optional(doc, obj, "invisible_time", cl.invisible_time);
    json_add_optional(doc, obj, "grenade_blew_up", cl.grenade_blew_up);
    json_add_optional(doc, obj, "grenade_time", cl.grenade_time);
    json_add_optional(doc, obj, "grenade_finished_time", cl.grenade_finished_time);
    json_add_optional(doc, obj, "quadfire_time", cl.quadfire_time);
    json_add_optional(doc, obj, "silencer_shots", cl.silencer_shots);
    json_add_optional(doc, obj, "weapon_sound", cl.weapon_sound);
    json_add_optional(doc, obj, "pickup_msg_time", cl.pickup_msg_time);
    json_add_optional(doc, obj, "respawn_time", cl.respawn_time);
    json_add_optional(doc, obj, "double_time", cl.double_time);
    json_add_optional(doc, obj, "ir_time", cl.ir_time);
    json_add_optional(doc, obj, "nuke_time", cl.nuke_time);
    json_add_optional(doc, obj, "tracker_pain_time", cl.tracker_pain_time);
    json_add_optional(doc, obj, "empty_click_sound", cl.empty_click_sound);
    json_add_optional(doc, obj, "trail_head", cl.trail_head);
    json_add_optional(doc, obj, "trail_tail", cl.trail_tail);
    json_add_optional(doc, obj, "landmark_name", cl.landmark_name);
    json_add_optional(doc, obj, "landmark_rel_pos", cl.landmark_rel_pos);
    json_add_optional(doc, obj, "landmark_free_fall", cl.landmark_free_fall);
    json_add_optional(doc, obj, "landmark_noise_time", cl.landmark_noise_time);
    json_add_optional(doc, obj, "invisibility_fade_time", cl.invisibility_fade_time);
    json_add_optional(doc, obj, "last_ladder_pos", cl.last_ladder_pos);
    json_add_optional(doc, obj, "last_ladder_sound", cl.last_ladder_sound);
    json_add_optional(doc, obj, "sight_entity", cl.sight_entity);
    json_add_optional(doc, obj, "sight_entity_time", cl.sight_entity_time);
    json_add_optional(doc, obj, "sound_entity", cl.sound_entity);
    json_add_optional(doc, obj, "sound_entity_time", cl.sound_entity_time);
    json_add_optional(doc, obj, "sound2_entity", cl.sound2_entity);
    json_add_optional(doc, obj, "sound2_entity_time", cl.sound2_entity_time);
    json_add_optional(doc, obj, "last_firing_time", cl.last_firing_time);
    json_add_optional(doc, obj, "mynoise", cl.mynoise);
    json_add_optional(doc, obj, "mynoise2", cl.mynoise2);

    return obj;
}

void ReadClient(json_doc &doc, json_val obj, ASEntity &ent)
{
    json_val v;

    ASClient @cl = ent.client;
    gclient_t @gcl = ent.e.client;

    // ps.pmove
    obj["ps.pmove.pm_type"].get_enum(gcl.ps.pmove.pm_type);
    json_get_optional(doc, obj["ps.pmove.origin"], gcl.ps.pmove.origin);
    json_get_optional(doc, obj["ps.pmove.velocity"], gcl.ps.pmove.velocity);
    obj["ps.pmove.pm_flags"].get_enum(gcl.ps.pmove.pm_flags);
    obj["ps.pmove.pm_time"].get(gcl.ps.pmove.pm_time);
    obj["ps.pmove.gravity"].get(gcl.ps.pmove.gravity);
    json_get_optional(doc, obj["ps.pmove.delta_angles"], gcl.ps.pmove.delta_angles);
    obj["ps.pmove.viewheight"].get(gcl.ps.pmove.viewheight);

    // ps
    json_get_optional(doc, obj["ps.viewangles"], gcl.ps.viewangles);
    json_get_optional(doc, obj["ps.viewoffset"], gcl.ps.viewoffset);
    json_get_optional(doc, obj["ps.gunangles"], gcl.ps.gunangles);
    json_get_optional(doc, obj["ps.gunoffset"], gcl.ps.gunoffset);
    obj["ps.gunindex"].get(gcl.ps.gunindex);
    obj["ps.gunframe"].get(gcl.ps.gunframe);
    obj["ps.gunskin"].get(gcl.ps.gunskin);
    {
        v = obj["ps.stats"];

        if (v.is_arr)
        {
            json_arr_iter iter(v);
            int i = 0;

            while (iter.has_next)
            {
                v = iter.next;
                gcl.ps.stats[i] = v.get_int16();
                i++;
            }
        }
    }

    // pers
    ReadClientPersistent(doc, obj["pers"], cl.pers);

    // resp.coop_respawn
    ReadClientPersistent(doc, obj["resp.coop_respawn"], cl.resp.coop_respawn);

    // resp
    json_get_optional(doc, obj["resp.entertime"], cl.resp.entertime);
    obj["resp.score"].get(cl.resp.score);
    json_get_optional(doc, obj["resp.cmd_angles"], cl.resp.cmd_angles);
    obj["resp.spectator"].get(cl.resp.spectator);

    // ASClient
    json_get_optional(doc, obj["newweapon"], cl.newweapon);
    obj["killer_yaw"].get(cl.killer_yaw);
    obj["weaponstate"].get_enum(cl.weaponstate);
    json_get_optional(doc, obj["kick.angles"], cl.kick.angles);
    json_get_optional(doc, obj["kick.origin"], cl.kick.origin);
    json_get_optional(doc, obj["kick.total"], cl.kick.total);
    json_get_optional(doc, obj["kick.time"], cl.kick.time);
    json_get_optional(doc, obj["quake_time"], cl.quake_time);
    obj["v_dmg_roll"].get(cl.v_dmg_roll);
    obj["v_dmg_pitch"].get(cl.v_dmg_pitch);
    json_get_optional(doc, obj["v_dmg_time"], cl.v_dmg_time);
    json_get_optional(doc, obj["fall_time"], cl.fall_time);
    obj["fall_value"].get(cl.fall_value);
    json_get_optional(doc, obj["damage_blend"], cl.damage_blend);
    json_get_optional(doc, obj["v_angle"], cl.v_angle);
    obj["bobtime"].get(cl.bobtime);
    json_get_optional(doc, obj["oldviewangles"], cl.oldviewangles);
    json_get_optional(doc, obj["oldvelocity"], cl.oldvelocity);
    json_get_optional(doc, obj["oldgroundentity"], cl.oldgroundentity);
    json_get_optional(doc, obj["next_drown_time"], cl.next_drown_time);
    obj["old_waterlevel"].get_enum(cl.old_waterlevel);
    obj["breather_sound"].get(cl.breather_sound);
    obj["machinegun_shots"].get(cl.machinegun_shots);
    obj["anim_end"].get(cl.anim_end);
    obj["anim_priority"].get_enum(cl.anim_priority);
    obj["anim_duck"].get(cl.anim_duck);
    obj["anim_run"].get(cl.anim_run);
    json_get_optional(doc, obj["quad_time"], cl.quad_time);
    json_get_optional(doc, obj["invincible_time"], cl.invincible_time);
    json_get_optional(doc, obj["breather_time"], cl.breather_time);
    json_get_optional(doc, obj["enviro_time"], cl.enviro_time);
    json_get_optional(doc, obj["invisible_time"], cl.invisible_time);
    obj["grenade_blew_up"].get(cl.grenade_blew_up);
    json_get_optional(doc, obj["grenade_time"], cl.grenade_time);
    json_get_optional(doc, obj["grenade_finished_time"], cl.grenade_finished_time);
    json_get_optional(doc, obj["quadfire_time"], cl.quadfire_time);
    obj["silencer_shots"].get(cl.silencer_shots);
    obj["weapon_sound"].get(cl.weapon_sound);
    json_get_optional(doc, obj["pickup_msg_time"], cl.pickup_msg_time);
    json_get_optional(doc, obj["respawn_time"], cl.respawn_time);
    json_get_optional(doc, obj["double_time"], cl.double_time);
    json_get_optional(doc, obj["ir_time"], cl.ir_time);
    json_get_optional(doc, obj["nuke_time"], cl.nuke_time);
    json_get_optional(doc, obj["tracker_pain_time"], cl.tracker_pain_time);
    json_get_optional(doc, obj["empty_click_sound"], cl.empty_click_sound);
    json_get_optional(doc, obj["trail_head"], cl.trail_head);
    json_get_optional(doc, obj["trail_tail"], cl.trail_tail);
    obj["landmark_name"].get(cl.landmark_name);
    json_get_optional(doc, obj["landmark_rel_pos"], cl.landmark_rel_pos);
    obj["landmark_free_fall"].get(cl.landmark_free_fall);
    json_get_optional(doc, obj["landmark_noise_time"], cl.landmark_noise_time);
    json_get_optional(doc, obj["invisibility_fade_time"], cl.invisibility_fade_time);
    json_get_optional(doc, obj["last_ladder_pos"], cl.last_ladder_pos);
    json_get_optional(doc, obj["last_ladder_sound"], cl.last_ladder_sound);
    json_get_optional(doc, obj["sight_entity"], cl.sight_entity);
    json_get_optional(doc, obj["sight_entity_time"], cl.sight_entity_time);
    json_get_optional(doc, obj["sound_entity"], cl.sound_entity);
    json_get_optional(doc, obj["sound_entity_time"], cl.sound_entity_time);
    json_get_optional(doc, obj["sound2_entity"], cl.sound2_entity);
    json_get_optional(doc, obj["sound2_entity_time"], cl.sound2_entity_time);
    json_get_optional(doc, obj["last_firing_time"], cl.last_firing_time);
    json_get_optional(doc, obj["mynoise"], cl.mynoise);
    json_get_optional(doc, obj["mynoise2"], cl.mynoise2);
}

void WriteGame(bool autosave, json_mutdoc &doc)
{
	if (!autosave)
		SaveClientData();
    
    json_mutval root = doc.val_obj();

    root.obj_add("as_save_version", doc.val(SAVE_FORMAT_VERSION));

	// write game
	game.autosaved = autosave;
    json_mutval locals = WriteGameLocals(doc);
    if (locals.valid && locals.length != 0)
        root.obj_add("game", locals);
	game.autosaved = false;

    json_mutval clients = doc.val_arr();
    root.obj_add("clients", clients);

	// write clients
	for (uint i = 0; i < max_clients; i++)
        clients.arr_append(WriteClient(doc, players[i]));

    doc.root = root;
}

void ReadGame(json_doc &doc)
{
	// pull version
	uint save_version;
    json_val root = doc.root;

    // AS_TODO ReadGame on native side should
    // validate max_edicts & max_clients

    // if we have no version tag it's bad/not Q2AS
    json_val v = root["as_save_version"];
    //if (!v.is_num)
    //    gi_Com_Error("incompatible save version");

	game = game_locals_t();

    // unlink all old entities
    entities = array<ASEntity@>(max_edicts);
    players = array<ASEntity@>(max_clients);

    internal::allow_value_assign++;

    for (uint i = 0; i < max_edicts; i++)
        G_EdictForNum(i).reset();

    @world = ASEntity(G_EdictForNum(0));
    @entities[0] = @world;

    for (uint i = 0; i < max_clients; i++)
    {
        ASEntity p(G_EdictForNum(i + 1));
        @p.client = ASClient(G_ClientForNum(i));
        @entities[i + 1] = @p;
        @players[i] = p;
    }

	// read game
    ReadGameLocals(doc, root["game"]);

	// read clients
    json_arr_iter iter(root["clients"]);
    int i = 0;

    while (iter.has_next)
	{
        json_val cl = iter.next;
        ReadClient(doc, cl, players[i]);
        // unused atm
        //upgrade_client(players[i], uint(v.num), save_version);
        i++;
	}

    internal::allow_value_assign--;
}

json_mutval WriteLevelLocals(json_mutdoc &doc)
{
    json_mutval obj = doc.val_obj();

    json_add_optional(doc, obj, "time", level.time);

    json_add_optional(doc, obj, "level_name", level.level_name);
    json_add_optional(doc, obj, "mapname", level.mapname);
    json_add_optional(doc, obj, "nextmap", level.nextmap);

    json_add_optional(doc, obj, "intermissiontime", level.intermissiontime);
    json_add_optional(doc, obj, "changemap", level.changemap);
    json_add_optional(doc, obj, "achievement", level.achievement);
    json_add_optional(doc, obj, "exitintermission", level.exitintermission);
    json_add_optional(doc, obj, "intermission_clear", level.intermission_clear);
    json_add_optional(doc, obj, "intermission_origin", level.intermission_origin);
    json_add_optional(doc, obj, "intermission_angle", level.intermission_angle);

    json_add_optional(doc, obj, "total_secrets", level.total_secrets);
    json_add_optional(doc, obj, "found_secrets", level.found_secrets);

    json_add_optional(doc, obj, "total_goals", level.total_goals);
    json_add_optional(doc, obj, "found_goals", level.found_goals);

    json_add_optional(doc, obj, "total_monsters", level.total_monsters);
    // AS_TODO monsters_registered
    json_add_optional(doc, obj, "killed_monsters", level.killed_monsters);

    json_add_optional(doc, obj, "body_que", level.body_que);

    json_add_optional(doc, obj, "power_cubes", level.power_cubes);

    json_add_optional(doc, obj, "disguise_violator", level.disguise_violator);
    json_add_optional(doc, obj, "disguise_violation_time", level.disguise_violation_time);

    json_add_optional(doc, obj, "coop_level_restart_time", level.coop_level_restart_time);

    json_add_optional(doc, obj, "goals", level.goals);
    json_add_optional(doc, obj, "goal_num", level.goal_num);
    json_add_optional(doc, obj, "vwep_offset", level.vwep_offset);

    json_add_optional(doc, obj, "valid_poi", level.valid_poi);
    json_add_optional(doc, obj, "current_poi", level.current_poi);
    json_add_optional(doc, obj, "current_poi_stage", level.current_poi_stage);
    json_add_optional(doc, obj, "current_poi_image", level.current_poi_image);
    json_add_optional(doc, obj, "current_dynamic_poi", level.current_dynamic_poi);

    json_add_optional(doc, obj, "start_items", level.start_items);
    json_add_optional(doc, obj, "no_grapple", level.no_grapple);
    json_add_optional(doc, obj, "gravity", level.gravity);
    json_add_optional(doc, obj, "health_bar_entities[0]", level.health_bar_entities[0]);
    json_add_optional(doc, obj, "health_bar_entities[1]", level.health_bar_entities[1]);
    json_add_optional(doc, obj, "intermission_server_frame", level.intermission_server_frame);
    json_add_optional(doc, obj, "story_active", level.story_active);
    json_add_optional(doc, obj, "next_auto_save", level.next_auto_save);
    json_add_optional(doc, obj, "primary_objective_string", level.primary_objective_string);
    json_add_optional(doc, obj, "secondary_objective_string", level.secondary_objective_string);
    json_add_optional(doc, obj, "primary_objective_title", level.primary_objective_title);
    json_add_optional(doc, obj, "secondary_objective_title", level.secondary_objective_title);
    json_add_optional(doc, obj, "monster_fakegoal", level.monster_fakegoal);

    return obj;
}

void ReadLevelLocals(json_doc &doc, json_val obj)
{
    if (!obj.is_obj)
        return;

    json_get_optional(doc, obj["time"], level.time);

    obj["level_name"].get(level.level_name);
    obj["mapname"].get(level.mapname);
    obj["nextmap"].get(level.nextmap);

    json_get_optional(doc, obj["intermissiontime"], level.intermissiontime);
    obj["changemap"].get(level.changemap);
    obj["achievement"].get(level.achievement);
    obj["exitintermission"].get(level.exitintermission);
    obj["intermission_clear"].get(level.intermission_clear);
    json_get_optional(doc, obj["intermission_origin"], level.intermission_origin);
    json_get_optional(doc, obj["intermission_angle"], level.intermission_angle);

    obj["total_secrets"].get(level.total_secrets);
    obj["found_secrets"].get(level.found_secrets);

    obj["total_goals"].get(level.total_goals);
    obj["found_goals"].get(level.found_goals);

    obj["total_monsters"].get(level.total_monsters);
    // AS_TODO monsters_registered
    obj["killed_monsters"].get(level.killed_monsters);

    obj["body_que"].get(level.body_que);

    obj["power_cubes"].get(level.power_cubes);

    json_get_optional(doc, obj["disguise_violator"], level.disguise_violator);
    json_get_optional(doc, obj["disguise_violation_time"], level.disguise_violation_time);

    json_get_optional(doc, obj["coop_level_restart_time"], level.coop_level_restart_time);

    obj["goals"].get(level.goals);
    obj["goal_num"].get(level.goal_num);
    obj["vwep_offset"].get(level.vwep_offset);

    obj["valid_poi"].get(level.valid_poi);
    json_get_optional(doc, obj["current_poi"], level.current_poi);
    obj["current_poi_stage"].get(level.current_poi_stage);
    obj["current_poi_image"].get(level.current_poi_image);
    json_get_optional(doc, obj["current_dynamic_poi"], level.current_dynamic_poi);

    obj["start_items"].get(level.start_items);
    obj["no_grapple"].get(level.no_grapple);
    obj["gravity"].get(level.gravity);
    json_get_optional(doc, obj["health_bar_entities[0]"], level.health_bar_entities[0]);
    json_get_optional(doc, obj["health_bar_entities[1]"], level.health_bar_entities[1]);
    obj["intermission_server_frame"].get(level.intermission_server_frame);
    obj["story_active"].get(level.story_active);
    json_get_optional(doc, obj["next_auto_save"], level.next_auto_save);
    obj["primary_objective_string"].get(level.primary_objective_string);
    obj["secondary_objective_string"].get(level.secondary_objective_string);
    obj["primary_objective_title"].get(level.primary_objective_title);
    obj["secondary_objective_title"].get(level.secondary_objective_title);
    json_get_optional(doc, obj["monster_fakegoal"], level.monster_fakegoal);
}

json_mutval WriteEntityMoveInfo(json_mutdoc &doc, const moveinfo_t &info)
{
    json_mutval obj = doc.val_obj();

    json_add_optional(doc, obj, "start_origin", info.start_origin);
    json_add_optional(doc, obj, "start_angles", info.start_angles);
    json_add_optional(doc, obj, "end_origin", info.end_origin);
    json_add_optional(doc, obj, "end_angles", info.end_angles);
    json_add_optional(doc, obj, "end_angles_reversed", info.end_angles_reversed);

    json_add_optional(doc, obj, "sound_start", info.sound_start);
    json_add_optional(doc, obj, "sound_middle", info.sound_middle);
    json_add_optional(doc, obj, "sound_end", info.sound_end);

    json_add_optional(doc, obj, "accel", info.accel);
    json_add_optional(doc, obj, "speed", info.speed);
    json_add_optional(doc, obj, "decel", info.decel);
    json_add_optional(doc, obj, "distance", info.distance);

    json_add_optional(doc, obj, "wait", info.wait);

    json_add_optional(doc, obj, "state", info.state);
    json_add_optional(doc, obj, "reversing", info.reversing);
    json_add_optional(doc, obj, "dir", info.dir);
    json_add_optional(doc, obj, "dest", info.dest);
    json_add_optional(doc, obj, "current_speed", info.current_speed);
    json_add_optional(doc, obj, "move_speed", info.move_speed);
    json_add_optional(doc, obj, "next_speed", info.next_speed);
    json_add_optional(doc, obj, "remaining_distance", info.remaining_distance);
    json_add_optional(doc, obj, "decel_distance", info.decel_distance);
    json_add_optional(doc, obj, "endfunc", reflect_name_of_global<endfunc_f>(info.endfunc));
    json_add_optional(doc, obj, "blocked", reflect_name_of_global<blocked_f>(info.blocked));

    json_add_optional(doc, obj, "curve_ref", info.curve_ref);
    if (!info.curve_positions.empty())
    {
        json_mutval arr = doc.val_arr();

        for (uint i = 0; i < info.curve_positions.size(); i++)
            arr.arr_append(doc.val(info.curve_positions[i]));

        json_add_optional(doc, obj, "curve_positions", arr);
    }
    json_add_optional(doc, obj, "curve_frame", info.curve_frame);
    json_add_optional(doc, obj, "subframe", info.subframe);
    json_add_optional(doc, obj, "num_subframes", info.num_subframes);
    json_add_optional(doc, obj, "num_frames_done", info.num_frames_done);

    return obj;
}

void ReadEntityMoveInfo(json_doc &doc, json_val obj, moveinfo_t &info)
{
    if (!obj.is_obj)
        return;

    json_get_optional(doc, obj["start_origin"], info.start_origin);
    json_get_optional(doc, obj["start_angles"], info.start_angles);
    json_get_optional(doc, obj["end_origin"], info.end_origin);
    json_get_optional(doc, obj["end_angles"], info.end_angles);
    json_get_optional(doc, obj["end_angles_reversed"], info.end_angles_reversed);

    obj["sound_start"].get(info.sound_start);
    obj["sound_middle"].get(info.sound_middle);
    obj["sound_end"].get(info.sound_end);

    obj["accel"].get(info.accel);
    obj["speed"].get(info.speed);
    obj["decel"].get(info.decel);
    obj["distance"].get(info.distance);

    obj["wait"].get(info.wait);

    obj["state"].get_enum(info.state);
    obj["reversing"].get(info.reversing);
    json_get_optional(doc, obj["dir"], info.dir);
    json_get_optional(doc, obj["dest"], info.dest);
    obj["current_speed"].get(info.current_speed);
    obj["move_speed"].get(info.move_speed);
    obj["next_speed"].get(info.next_speed);
    obj["remaining_distance"].get(info.remaining_distance);
    obj["decel_distance"].get(info.decel_distance);
    reflect_global_from_name<endfunc_f>(obj["endfunc"].str, info.endfunc);
    reflect_global_from_name<blocked_f>(obj["blocked"].str, info.blocked);

    json_get_optional(doc, obj["curve_ref"], info.curve_ref);
    json_val arr = obj["curve_positions"];
    if (arr.is_arr)
    {
        info.curve_positions.resize(arr.length);
        json_arr_iter iter(arr);
        uint i = 0;

        while (iter.has_next)
        {
            info.curve_positions[i] = iter.next.get_float();
            i++;
        }
    }
    obj["curve_frame"].get(info.curve_frame);
    obj["subframe"].get(info.subframe);
    obj["num_subframes"].get(info.num_subframes);
    obj["num_frames_done"].get(info.num_frames_done);
}

json_mutval WriteEntityMonsterInfo(json_mutdoc &doc, const monsterinfo_t &info)
{
    json_mutval obj = doc.val_obj();

    json_add_optional(doc, obj, "active_move", reflect_name_of_global<mmove_t>(info.active_move));
    json_add_optional(doc, obj, "next_move", reflect_name_of_global<mmove_t>(info.next_move));
    json_add_optional(doc, obj, "aiflags", info.aiflags);
    json_add_optional(doc, obj, "nextframe", info.nextframe);
    json_add_optional(doc, obj, "scale", info.scale);

    json_add_optional(doc, obj, "stand", reflect_name_of_global<monsterinfo_stand_f>(info.stand));
    json_add_optional(doc, obj, "idle", reflect_name_of_global<monsterinfo_idle_f>(info.idle));
    json_add_optional(doc, obj, "search", reflect_name_of_global<monsterinfo_search_f>(info.search));
    json_add_optional(doc, obj, "walk", reflect_name_of_global<monsterinfo_walk_f>(info.walk));
    json_add_optional(doc, obj, "run", reflect_name_of_global<monsterinfo_run_f>(info.run));
    json_add_optional(doc, obj, "dodge", reflect_name_of_global<monsterinfo_dodge_f>(info.dodge));
    json_add_optional(doc, obj, "attack", reflect_name_of_global<monsterinfo_attack_f>(info.attack));
    json_add_optional(doc, obj, "melee", reflect_name_of_global<monsterinfo_melee_f>(info.melee));
    json_add_optional(doc, obj, "sight", reflect_name_of_global<monsterinfo_sight_f>(info.sight));
    json_add_optional(doc, obj, "checkattack", reflect_name_of_global<monsterinfo_checkattack_f>(info.checkattack));
    json_add_optional(doc, obj, "setskin", reflect_name_of_global<monsterinfo_setskin_f>(info.setskin));

    json_add_optional(doc, obj, "pausetime", info.pausetime);
    json_add_optional(doc, obj, "attack_finished", info.attack_finished);
    json_add_optional(doc, obj, "fire_wait", info.fire_wait);

    json_add_optional(doc, obj, "saved_goal", info.saved_goal);
    json_add_optional(doc, obj, "search_time", info.search_time);
    json_add_optional(doc, obj, "trail_time", info.trail_time);
    json_add_optional(doc, obj, "last_sighting", info.last_sighting);
    json_add_optional(doc, obj, "attack_state", info.attack_state);
    json_add_optional(doc, obj, "lefty", info.lefty);
    json_add_optional(doc, obj, "idle_time", info.idle_time);

    json_add_optional(doc, obj, "power_armor_type", info.power_armor_type);
    json_add_optional(doc, obj, "power_armor_power", info.power_armor_power);
    json_add_optional(doc, obj, "initial_power_armor_type", info.initial_power_armor_type);
    json_add_optional(doc, obj, "max_power_armor_power", info.max_power_armor_power);
    json_add_optional(doc, obj, "weapon_sound", info.weapon_sound);
    json_add_optional(doc, obj, "engine_sound", info.engine_sound);
    
    json_add_optional(doc, obj, "blocked", reflect_name_of_global<monsterinfo_blocked_f>(info.blocked));
    json_add_optional(doc, obj, "medicTries", info.medicTries);
    json_add_optional(doc, obj, "badMedic1", info.badMedic1);
    json_add_optional(doc, obj, "badMedic2", info.badMedic2);
    json_add_optional(doc, obj, "healer", info.healer);
    json_add_optional(doc, obj, "duck", reflect_name_of_global<monsterinfo_duck_f>(info.duck));
    json_add_optional(doc, obj, "unduck", reflect_name_of_global<monsterinfo_unduck_f>(info.unduck));
    json_add_optional(doc, obj, "sidestep", reflect_name_of_global<monsterinfo_sidestep_f>(info.sidestep));
    json_add_optional(doc, obj, "base_height", info.base_height);
    json_add_optional(doc, obj, "next_duck_time", info.next_duck_time);
    json_add_optional(doc, obj, "duck_wait_time", info.duck_wait_time);
    json_add_optional(doc, obj, "last_player_enemy", info.last_player_enemy);
    json_add_optional(doc, obj, "blindfire", info.blindfire);
    json_add_optional(doc, obj, "can_jump", info.can_jump);
    json_add_optional(doc, obj, "had_visibility", info.had_visibility);
    json_add_optional(doc, obj, "drop_height", info.drop_height);
    json_add_optional(doc, obj, "jump_height", info.jump_height);
    json_add_optional(doc, obj, "blind_fire_delay", info.blind_fire_delay);
    json_add_optional(doc, obj, "blind_fire_target", info.blind_fire_target);
    json_add_optional(doc, obj, "slots_from_commander", info.slots_from_commander);
    json_add_optional(doc, obj, "monster_slots", info.monster_slots);
    json_add_optional(doc, obj, "monster_used", info.monster_used);
    json_add_optional(doc, obj, "commander", info.commander);
    json_add_optional(doc, obj, "quad_time", info.quad_time);
    json_add_optional(doc, obj, "invincible_time", info.invincible_time);
    json_add_optional(doc, obj, "double_time", info.double_time);

    json_add_optional(doc, obj, "surprise_time", info.surprise_time);
    json_add_optional(doc, obj, "armor_type", info.armor_type);
    json_add_optional(doc, obj, "armor_power", info.armor_power);
    json_add_optional(doc, obj, "close_sight_tripped", info.close_sight_tripped);
    json_add_optional(doc, obj, "melee_debounce_time", info.melee_debounce_time);
    json_add_optional(doc, obj, "strafe_check_time", info.strafe_check_time);
    json_add_optional(doc, obj, "base_health", info.base_health);
    json_add_optional(doc, obj, "health_scaling", info.health_scaling);
    json_add_optional(doc, obj, "next_move_time", info.next_move_time);
    json_add_optional(doc, obj, "bad_move_time", info.bad_move_time);
    json_add_optional(doc, obj, "bump_time", info.bump_time);
    json_add_optional(doc, obj, "random_change_time", info.random_change_time);
    json_add_optional(doc, obj, "path_blocked_counter", info.path_blocked_counter);
    json_add_optional(doc, obj, "path_wait_time", info.path_wait_time);
    json_add_optional(doc, obj, "combat_style", info.combat_style);
    
    json_add_optional(doc, obj, "fly_max_distance", info.fly_max_distance);
    json_add_optional(doc, obj, "fly_min_distance", info.fly_min_distance);
    json_add_optional(doc, obj, "fly_acceleration", info.fly_acceleration);
    json_add_optional(doc, obj, "fly_speed", info.fly_speed);
    json_add_optional(doc, obj, "fly_ideal_position", info.fly_ideal_position);
    json_add_optional(doc, obj, "fly_position_time", info.fly_position_time);
    json_add_optional(doc, obj, "fly_buzzard", info.fly_buzzard);
    json_add_optional(doc, obj, "fly_above", info.fly_above);
    json_add_optional(doc, obj, "fly_pinned", info.fly_pinned);
    json_add_optional(doc, obj, "fly_thrusters", info.fly_thrusters);
    json_add_optional(doc, obj, "fly_recovery_time", info.fly_recovery_time);
    json_add_optional(doc, obj, "fly_recovery_dir", info.fly_recovery_dir);
    
    json_add_optional(doc, obj, "checkattack_time", info.checkattack_time);
    json_add_optional(doc, obj, "start_frame", info.start_frame);
    json_add_optional(doc, obj, "dodge_time", info.dodge_time);
    json_add_optional(doc, obj, "move_block_counter", info.move_block_counter);
    json_add_optional(doc, obj, "move_block_change_time", info.move_block_change_time);
    json_add_optional(doc, obj, "react_to_damage_time", info.react_to_damage_time);
    json_add_optional(doc, obj, "jump_time", info.jump_time);

    if (!info.reinforcements.empty())
    {
        json_mutval arr = doc.val_arr();
        
        foreach (const reinforcement_t @v : info.reinforcements)
        {
            json_mutval val = doc.val_obj();
            val.obj_put("classname", doc.val(v.classname));
            json_add_optional(doc, val, "mins", v.mins);
            json_add_optional(doc, val, "maxs", v.maxs);
            val.obj_put("strength", doc.val(v.strength));
            arr.arr_append(val);
        }

        obj.obj_add("reinforcements", arr);
    }
    if (!info.chosen_reinforcements.empty())
    {
        json_mutval arr = doc.val_arr();
        
        foreach (uint8 v : info.chosen_reinforcements)
            arr.arr_append(doc.val(v));

        obj.obj_add("chosen_reinforcements", arr);
    }

    return obj;
}

void ReadEntityMonsterInfo(json_doc &doc, json_val obj, monsterinfo_t &info)
{
    if (!obj.is_obj)
        return;

    reflect_global_from_name<const mmove_t>(obj["active_move"].str, info.active_move);
    reflect_global_from_name<const mmove_t>(obj["next_move"].str, info.next_move);
    obj["aiflags"].get_enum(info.aiflags);
    obj["nextframe"].get(info.nextframe);
    obj["scale"].get(info.scale);

    reflect_global_from_name<monsterinfo_stand_f>(obj["stand"].str, info.stand);
    reflect_global_from_name<monsterinfo_idle_f>(obj["idle"].str, info.idle);
    reflect_global_from_name<monsterinfo_search_f>(obj["search"].str, info.search);
    reflect_global_from_name<monsterinfo_walk_f>(obj["walk"].str, info.walk);
    reflect_global_from_name<monsterinfo_run_f>(obj["run"].str, info.run);
    reflect_global_from_name<monsterinfo_dodge_f>(obj["dodge"].str, info.dodge);
    reflect_global_from_name<monsterinfo_attack_f>(obj["attack"].str, info.attack);
    reflect_global_from_name<monsterinfo_melee_f>(obj["melee"].str, info.melee);
    reflect_global_from_name<monsterinfo_sight_f>(obj["sight"].str, info.sight);
    reflect_global_from_name<monsterinfo_checkattack_f>(obj["checkattack"].str, info.checkattack);
    reflect_global_from_name<monsterinfo_setskin_f>(obj["setskin"].str, info.setskin);

    json_get_optional(doc, obj["pausetime"], info.pausetime);
    json_get_optional(doc, obj["attack_finished"], info.attack_finished);
    json_get_optional(doc, obj["fire_wait"], info.fire_wait);

    json_get_optional(doc, obj["saved_goal"], info.saved_goal);
    json_get_optional(doc, obj["search_time"], info.search_time);
    json_get_optional(doc, obj["trail_time"], info.trail_time);
    json_get_optional(doc, obj["last_sighting"], info.last_sighting);
    obj["attack_state"].get_enum(info.attack_state);
    obj["lefty"].get(info.lefty);
    json_get_optional(doc, obj["idle_time"], info.idle_time);

    obj["power_armor_type"].get_enum(info.power_armor_type);
    obj["power_armor_power"].get(info.power_armor_power);
    obj["initial_power_armor_type"].get_enum(info.initial_power_armor_type);
    obj["max_power_armor_power"].get(info.max_power_armor_power);
    obj["weapon_sound"].get(info.weapon_sound);
    obj["engine_sound"].get(info.engine_sound);
    
    reflect_global_from_name<monsterinfo_blocked_f>(obj["blocked"].str, info.blocked);
    obj["medicTries"].get(info.medicTries);
    json_get_optional(doc, obj["badMedic1"], info.badMedic1);
    json_get_optional(doc, obj["badMedic2"], info.badMedic2);
    json_get_optional(doc, obj["healer"], info.healer);
    reflect_global_from_name<monsterinfo_duck_f>(obj["duck"].str, info.duck);
    reflect_global_from_name<monsterinfo_unduck_f>(obj["unduck"].str, info.unduck);
    reflect_global_from_name<monsterinfo_sidestep_f>(obj["sidestep"].str, info.sidestep);
    obj["base_height"].get(info.base_height);
    json_get_optional(doc, obj["next_duck_time"], info.next_duck_time);
    json_get_optional(doc, obj["duck_wait_time"], info.duck_wait_time);
    json_get_optional(doc, obj["last_player_enemy"], info.last_player_enemy);
    obj["blindfire"].get(info.blindfire);
    obj["can_jump"].get(info.can_jump);
    obj["had_visibility"].get(info.had_visibility);
    obj["drop_height"].get(info.drop_height);
    obj["jump_height"].get(info.jump_height);
    json_get_optional(doc, obj["blind_fire_delay"], info.blind_fire_delay);
    json_get_optional(doc, obj["blind_fire_target"], info.blind_fire_target);
    obj["slots_from_commander"].get(info.slots_from_commander);
    obj["monster_slots"].get(info.monster_slots);
    obj["monster_used"].get(info.monster_used);
    json_get_optional(doc, obj["commander"], info.commander);
    json_get_optional(doc, obj["quad_time"], info.quad_time);
    json_get_optional(doc, obj["invincible_time"], info.invincible_time);
    json_get_optional(doc, obj["double_time"], info.double_time);

    json_get_optional(doc, obj["surprise_time"], info.surprise_time);
    obj["armor_type"].get_enum(info.armor_type);
    obj["armor_power"].get(info.armor_power);
    obj["close_sight_tripped"].get(info.close_sight_tripped);
    json_get_optional(doc, obj["melee_debounce_time"], info.melee_debounce_time);
    json_get_optional(doc, obj["strafe_check_time"], info.strafe_check_time);
    obj["base_health"].get(info.base_health);
    obj["health_scaling"].get(info.health_scaling);
    json_get_optional(doc, obj["next_move_time"], info.next_move_time);
    json_get_optional(doc, obj["bad_move_time"], info.bad_move_time);
    json_get_optional(doc, obj["bump_time"], info.bump_time);
    json_get_optional(doc, obj["random_change_time"], info.random_change_time);
    json_get_optional(doc, obj["path_blocked_counter"], info.path_blocked_counter);
    json_get_optional(doc, obj["path_wait_time"], info.path_wait_time);
    obj["combat_style"].get_enum(info.combat_style);
    
    obj["fly_max_distance"].get(info.fly_max_distance);
    obj["fly_min_distance"].get(info.fly_min_distance);
    obj["fly_acceleration"].get(info.fly_acceleration);
    obj["fly_speed"].get(info.fly_speed);
    json_get_optional(doc, obj["fly_ideal_position"], info.fly_ideal_position);
    json_get_optional(doc, obj["fly_position_time"], info.fly_position_time);
    obj["fly_buzzard"].get(info.fly_buzzard);
    obj["fly_above"].get(info.fly_above);
    obj["fly_pinned"].get(info.fly_pinned);
    obj["fly_thrusters"].get(info.fly_thrusters);
    json_get_optional(doc, obj["fly_recovery_time"], info.fly_recovery_time);
    json_get_optional(doc, obj["fly_recovery_dir"], info.fly_recovery_dir);
    
    json_get_optional(doc, obj["checkattack_time"], info.checkattack_time);
    obj["start_frame"].get(info.start_frame);
    json_get_optional(doc, obj["dodge_time"], info.dodge_time);
    obj["move_block_counter"].get(info.move_block_counter);
    json_get_optional(doc, obj["move_block_change_time"], info.move_block_change_time);
    json_get_optional(doc, obj["react_to_damage_time"], info.react_to_damage_time);
    json_get_optional(doc, obj["jump_time"], info.jump_time);

    {
        json_val arr = obj["reinforcements"];
        if (arr.is_arr && arr.length != 0)
        {
            info.reinforcements.resize(arr.length);
            json_arr_iter iter(arr);
            int i = 0;

            while (iter.has_next)
            {
                json_val robj = iter.next;
                reinforcement_t @v = info.reinforcements[i];
                robj["classname"].get(v.classname);
                robj["mins"][0].get(v.mins.x);
                robj["mins"][1].get(v.mins.y);
                robj["mins"][2].get(v.mins.z);
                robj["maxs"][0].get(v.mins.x);
                robj["maxs"][1].get(v.maxs.y);
                robj["maxs"][2].get(v.maxs.z);
                robj["strength"].get(v.strength);
                i++;
            }
        }
    }
    {
        json_val arr = obj["chosen_reinforcements"];
        if (arr.is_arr && arr.length != 0)
        {
            info.chosen_reinforcements.resize(arr.length);
            json_arr_iter iter(arr);
            int i = 0;

            while (iter.has_next)
            {
                arr = iter.next;
                info.chosen_reinforcements[i] = arr.get_uint8();
                i++;
            }
        }
    }
}

json_mutval WriteEntity(json_mutdoc &doc, ASEntity &ent)
{
    json_mutval obj = doc.val_obj();

    edict_t @e = ent.e;

    json_add_optional(doc, obj, "s.origin", e.s.origin);
    json_add_optional(doc, obj, "s.angles", e.s.angles);
    json_add_optional(doc, obj, "s.old_origin", e.s.old_origin);
    json_add_optional(doc, obj, "s.modelindex", e.s.modelindex);
    json_add_optional(doc, obj, "s.modelindex2", e.s.modelindex2);
    json_add_optional(doc, obj, "s.modelindex3", e.s.modelindex3);
    json_add_optional(doc, obj, "s.modelindex4", e.s.modelindex4);
    json_add_optional(doc, obj, "s.frame", e.s.frame);
    json_add_optional(doc, obj, "s.skinnum", e.s.skinnum);
    json_add_optional(doc, obj, "s.effects", e.s.effects);
    json_add_optional(doc, obj, "s.renderfx", e.s.renderfx);
    json_add_optional(doc, obj, "s.sound", e.s.sound);
    json_add_optional(doc, obj, "s.alpha", e.s.alpha);
    json_add_optional(doc, obj, "s.scale", e.s.scale);
    json_add_optional(doc, obj, "s.loop_volume", e.s.loop_volume);
    json_add_optional(doc, obj, "s.loop_attenuation", e.s.loop_attenuation);

    json_add_optional(doc, obj, "svflags", e.svflags);
    json_add_optional(doc, obj, "mins", e.mins);
    json_add_optional(doc, obj, "maxs", e.maxs);
    json_add_optional(doc, obj, "solid", e.solid);
    json_add_optional(doc, obj, "clipmask", e.clipmask);
    json_add_optional(doc, obj, "owner", e.owner);

    json_add_optional(doc, obj, "spawn_count", ent.spawn_count);
    json_add_optional(doc, obj, "movetype", ent.movetype);
    json_add_optional(doc, obj, "flags", ent.flags);

    json_add_optional(doc, obj, "model", ent.model);
    json_add_optional(doc, obj, "freetime", ent.freetime);
    json_add_optional(doc, obj, "message", ent.message);
    json_add_optional(doc, obj, "classname", ent.classname);
    json_add_optional(doc, obj, "spawnflags", ent.spawnflags);

    json_add_optional(doc, obj, "timestamp", ent.timestamp);

    json_add_optional(doc, obj, "angle", ent.angle);
    json_add_optional(doc, obj, "target", ent.target);
    json_add_optional(doc, obj, "targetname", ent.targetname);
    json_add_optional(doc, obj, "killtarget", ent.killtarget);
    json_add_optional(doc, obj, "team", ent.team);
    json_add_optional(doc, obj, "pathtarget", ent.pathtarget);
    json_add_optional(doc, obj, "deathtarget", ent.deathtarget);
    json_add_optional(doc, obj, "healthtarget", ent.healthtarget);
    json_add_optional(doc, obj, "itemtarget", ent.itemtarget);
    json_add_optional(doc, obj, "combattarget", ent.combattarget);
    json_add_optional(doc, obj, "target_ent", ent.target_ent);

    json_add_optional(doc, obj, "speed", ent.speed);
    json_add_optional(doc, obj, "accel", ent.accel);
    json_add_optional(doc, obj, "decel", ent.decel);
    json_add_optional(doc, obj, "movedir", ent.movedir);
    json_add_optional(doc, obj, "pos1", ent.pos1);
    json_add_optional(doc, obj, "pos2", ent.pos2);
    json_add_optional(doc, obj, "pos3", ent.pos3);

    json_add_optional(doc, obj, "velocity", ent.velocity);
    json_add_optional(doc, obj, "avelocity", ent.avelocity);
    json_add_optional(doc, obj, "mass", ent.mass);
    json_add_optional(doc, obj, "air_finished", ent.air_finished);
    json_add_optional(doc, obj, "gravity", ent.gravity, 1.0f);

    json_add_optional(doc, obj, "goalentity", ent.goalentity);
    json_add_optional(doc, obj, "movetarget", ent.movetarget);
    json_add_optional(doc, obj, "yaw_speed", ent.yaw_speed);
    json_add_optional(doc, obj, "ideal_yaw", ent.ideal_yaw);

    json_add_optional(doc, obj, "nextthink", ent.nextthink);
    json_add_optional(doc, obj, "prethink", reflect_name_of_global<prethink_f>(ent.prethink));
    json_add_optional(doc, obj, "postthink", reflect_name_of_global<postthink_f>(ent.postthink));
    json_add_optional(doc, obj, "think", reflect_name_of_global<think_f>(ent.think));
    json_add_optional(doc, obj, "touch", reflect_name_of_global<touch_f>(ent.touch));
    json_add_optional(doc, obj, "use", reflect_name_of_global<use_f>(ent.use));
    json_add_optional(doc, obj, "pain", reflect_name_of_global<pain_f>(ent.pain));
    json_add_optional(doc, obj, "die", reflect_name_of_global<die_f>(ent.die));

    json_add_optional(doc, obj, "touch_debounce_time", ent.touch_debounce_time);
    json_add_optional(doc, obj, "pain_debounce_time", ent.pain_debounce_time);
    json_add_optional(doc, obj, "damage_debounce_time", ent.damage_debounce_time);
    json_add_optional(doc, obj, "fly_sound_debounce_time", ent.fly_sound_debounce_time);
    json_add_optional(doc, obj, "last_move_time", ent.last_move_time);

    json_add_optional(doc, obj, "health", ent.health);
    json_add_optional(doc, obj, "max_health", ent.max_health);
    json_add_optional(doc, obj, "gib_health", ent.gib_health);
    json_add_optional(doc, obj, "deadflag", ent.deadflag);
    json_add_optional(doc, obj, "show_hostile", ent.show_hostile);

    json_add_optional(doc, obj, "powerarmor_time", ent.powerarmor_time);

    json_add_optional(doc, obj, "map", ent.map);

    json_add_optional(doc, obj, "viewheight", ent.viewheight);
    json_add_optional(doc, obj, "takedamage", ent.takedamage);
    json_add_optional(doc, obj, "dmg", ent.dmg);
    json_add_optional(doc, obj, "radius_dmg", ent.radius_dmg);
    json_add_optional(doc, obj, "dmg_radius", ent.dmg_radius);
    json_add_optional(doc, obj, "sounds", ent.sounds);
    json_add_optional(doc, obj, "count", ent.count);

    json_add_optional(doc, obj, "chain", ent.chain);
    json_add_optional(doc, obj, "enemy", ent.enemy);
    json_add_optional(doc, obj, "oldenemy", ent.oldenemy);
    json_add_optional(doc, obj, "activator", ent.activator);
    json_add_optional(doc, obj, "groundentity", ent.groundentity);
    json_add_optional(doc, obj, "groundentity_linkcount", ent.groundentity_linkcount);
    json_add_optional(doc, obj, "teamchain", ent.teamchain);
    json_add_optional(doc, obj, "teammaster", ent.teammaster);

    json_add_optional(doc, obj, "noise_index", ent.noise_index);
    json_add_optional(doc, obj, "noise_index2", ent.noise_index2);
    json_add_optional(doc, obj, "volume", ent.volume);
    json_add_optional(doc, obj, "attenuation", ent.attenuation);

    json_add_optional(doc, obj, "wait", ent.wait);
    json_add_optional(doc, obj, "delay", ent.delay);
    json_add_optional(doc, obj, "random", ent.random);

    json_add_optional(doc, obj, "teleport_time", ent.teleport_time);

    json_add_optional(doc, obj, "watertype", ent.watertype);
    json_add_optional(doc, obj, "waterlevel", ent.waterlevel);

    json_add_optional(doc, obj, "move_origin", ent.move_origin);
    json_add_optional(doc, obj, "move_angles", ent.move_angles);

    json_add_optional(doc, obj, "style", ent.style);
    json_add_optional(doc, obj, "style_on", ent.style_on);
    json_add_optional(doc, obj, "style_off", ent.style_off);

    json_add_optional(doc, obj, "item", ent.item);
    json_add_optional(doc, obj, "crosslevel_flags", ent.crosslevel_flags);
    json_add_optional(doc, obj, "no_gravity_time", ent.no_gravity_time);

    json_add_optional(doc, obj, "moveinfo", WriteEntityMoveInfo(doc, ent.moveinfo));
    json_add_optional(doc, obj, "monsterinfo", WriteEntityMonsterInfo(doc, ent.monsterinfo));

    json_add_optional(doc, obj, "plat2flags", ent.plat2flags);
    json_add_optional(doc, obj, "offset", ent.offset);
    json_add_optional(doc, obj, "gravityVector", ent.gravityVector, { 0, 0, -1});
    json_add_optional(doc, obj, "bad_area", ent.bad_area);

    json_add_optional(doc, obj, "clock_message", ent.clock_message);
    json_add_optional(doc, obj, "dead_time", ent.dead_time);
    json_add_optional(doc, obj, "beam", ent.beam);
    json_add_optional(doc, obj, "beam2", ent.beam2);
    json_add_optional(doc, obj, "proboscus", ent.proboscus);
    json_add_optional(doc, obj, "hackflags", ent.hackflags);

    json_add_optional(doc, obj, "fog", ent.fog);
    json_add_optional(doc, obj, "fog_off", ent.fog_off);
    json_add_optional(doc, obj, "heightfog", ent.heightfog);
    json_add_optional(doc, obj, "heightfog_off", ent.heightfog_off);
    if (ent.item_picked_up_by.size != 0)
        json_add_optional(doc, obj, "item_picked_up_by", ent.item_picked_up_by.to_string());

    json_add_optional(doc, obj, "slime_debounce_time", ent.slime_debounce_time);

    json_add_optional(doc, obj, "bmodel_anim.start", ent.bmodel_anim.start);
    json_add_optional(doc, obj, "bmodel_anim.end", ent.bmodel_anim.end);
    json_add_optional(doc, obj, "bmodel_anim.style", ent.bmodel_anim.style);
    json_add_optional(doc, obj, "bmodel_anim.speed", ent.bmodel_anim.speed);
    json_add_optional(doc, obj, "bmodel_anim.nowrap", ent.bmodel_anim.nowrap);

    json_add_optional(doc, obj, "bmodel_anim.alt_start", ent.bmodel_anim.alt_start);
    json_add_optional(doc, obj, "bmodel_anim.alt_end", ent.bmodel_anim.alt_end);
    json_add_optional(doc, obj, "bmodel_anim.alt_style", ent.bmodel_anim.alt_style);
    json_add_optional(doc, obj, "bmodel_anim.alt_speed", ent.bmodel_anim.alt_speed);
    json_add_optional(doc, obj, "bmodel_anim.alt_nowrap", ent.bmodel_anim.alt_nowrap);

    json_add_optional(doc, obj, "bmodel_anim.enabled", ent.bmodel_anim.enabled);
    json_add_optional(doc, obj, "bmodel_anim.alternate", ent.bmodel_anim.alternate);
    json_add_optional(doc, obj, "bmodel_anim.currently_alternate", ent.bmodel_anim.currently_alternate);
    json_add_optional(doc, obj, "bmodel_anim.next_tick", ent.bmodel_anim.next_tick);

    json_add_optional(doc, obj, "lastMOD.id", ent.lastMOD.id);
    json_add_optional(doc, obj, "lastMOD.friendly_fire", ent.lastMOD.friendly_fire);

    json_add_optional(doc, obj, "vision_cone", ent.vision_cone);

    return obj;
}

void ReadEntity(json_doc &doc, json_val obj, ASEntity &ent)
{
    edict_t @e = ent.e;

    json_get_optional(doc, obj["s.origin"], e.s.origin);
    json_get_optional(doc, obj["s.angles"], e.s.angles);
    json_get_optional(doc, obj["s.old_origin"], e.s.old_origin);
    obj["s.modelindex"].get(e.s.modelindex);
    obj["s.modelindex2"].get(e.s.modelindex2);
    obj["s.modelindex3"].get(e.s.modelindex3);
    obj["s.modelindex4"].get(e.s.modelindex4);
    obj["s.frame"].get(e.s.frame);
    obj["s.skinnum"].get(e.s.skinnum);
    obj["s.effects"].get_enum(e.s.effects);
    obj["s.renderfx"].get_enum(e.s.renderfx);
    obj["s.sound"].get(e.s.sound);
    obj["s.alpha"].get(e.s.alpha);
    obj["s.scale"].get(e.s.scale);
    obj["s.loop_volume"].get(e.s.loop_volume);
    obj["s.loop_attenuation"].get(e.s.loop_attenuation);

    obj["svflags"].get_enum(e.svflags);
    json_get_optional(doc, obj["mins"], e.mins);
    json_get_optional(doc, obj["maxs"], e.maxs);
    obj["solid"].get_enum(e.solid);
    obj["clipmask"].get_enum(e.clipmask);
    json_get_optional(doc, obj["owner"], e.owner);

    obj["spawn_count"].get(ent.spawn_count);
    obj["movetype"].get_enum(ent.movetype);
    obj["flags"].get_enum(ent.flags);

    obj["model"].get(ent.model);
    json_get_optional(doc, obj["freetime"], ent.freetime);
    obj["message"].get(ent.message);
    obj["classname"].get(ent.classname);
    obj["spawnflags"].get(ent.spawnflags);

    json_get_optional(doc, obj["timestamp"], ent.timestamp);

    obj["angle"].get(ent.angle);
    obj["target"].get(ent.target);
    obj["targetname"].get(ent.targetname);
    obj["killtarget"].get(ent.killtarget);
    obj["team"].get(ent.team);
    obj["pathtarget"].get(ent.pathtarget);
    obj["deathtarget"].get(ent.deathtarget);
    obj["healthtarget"].get(ent.healthtarget);
    obj["itemtarget"].get(ent.itemtarget);
    obj["combattarget"].get(ent.combattarget);
    json_get_optional(doc, obj["target_ent"], ent.target_ent);

    obj["speed"].get(ent.speed);
    obj["accel"].get(ent.accel);
    obj["decel"].get(ent.decel);
    json_get_optional(doc, obj["movedir"], ent.movedir);
    json_get_optional(doc, obj["pos1"], ent.pos1);
    json_get_optional(doc, obj["pos2"], ent.pos2);
    json_get_optional(doc, obj["pos3"], ent.pos3);

    json_get_optional(doc, obj["velocity"], ent.velocity);
    json_get_optional(doc, obj["avelocity"], ent.avelocity);
    obj["mass"].get(ent.mass);
    json_get_optional(doc, obj["air_finished"], ent.air_finished);
    json_get_optional(doc, obj["gravity"], ent.gravity, 1.0f);

    json_get_optional(doc, obj["goalentity"], ent.goalentity);
    json_get_optional(doc, obj["movetarget"], ent.movetarget);
    obj["yaw_speed"].get(ent.yaw_speed);
    obj["ideal_yaw"].get(ent.ideal_yaw);

    json_get_optional(doc, obj["nextthink"], ent.nextthink);
    reflect_global_from_name<prethink_f>(obj["prethink"].str, ent.prethink);
    reflect_global_from_name<postthink_f>(obj["postthink"].str, ent.postthink);
    reflect_global_from_name<think_f>(obj["think"].str, ent.think);
    reflect_global_from_name<touch_f>(obj["touch"].str, ent.touch);
    reflect_global_from_name<use_f>(obj["use"].str, ent.use);
    reflect_global_from_name<pain_f>(obj["pain"].str, ent.pain);
    reflect_global_from_name<die_f>(obj["die"].str, ent.die);

    json_get_optional(doc, obj["touch_debounce_time"], ent.touch_debounce_time);
    json_get_optional(doc, obj["pain_debounce_time"], ent.pain_debounce_time);
    json_get_optional(doc, obj["damage_debounce_time"], ent.damage_debounce_time);
    json_get_optional(doc, obj["fly_sound_debounce_time"], ent.fly_sound_debounce_time);
    json_get_optional(doc, obj["last_move_time"], ent.last_move_time);

    obj["health"].get(ent.health);
    obj["max_health"].get(ent.max_health);
    obj["gib_health"].get(ent.gib_health);
    obj["deadflag"].get(ent.deadflag);
    json_get_optional(doc, obj["show_hostile"], ent.show_hostile);

    json_get_optional(doc, obj["powerarmor_time"], ent.powerarmor_time);

    obj["map"].get(ent.map);

    obj["viewheight"].get(ent.viewheight);
    obj["takedamage"].get(ent.takedamage);
    obj["dmg"].get(ent.dmg);
    obj["radius_dmg"].get(ent.radius_dmg);
    obj["dmg_radius"].get(ent.dmg_radius);
    obj["sounds"].get(ent.sounds);
    obj["count"].get(ent.count);

    json_get_optional(doc, obj["chain"], ent.chain);
    json_get_optional(doc, obj["enemy"], ent.enemy);
    json_get_optional(doc, obj["oldenemy"], ent.oldenemy);
    json_get_optional(doc, obj["activator"], ent.activator);
    json_get_optional(doc, obj["groundentity"], ent.groundentity);
    obj["groundentity_linkcount"].get(ent.groundentity_linkcount);
    json_get_optional(doc, obj["teamchain"], ent.teamchain);
    json_get_optional(doc, obj["teammaster"], ent.teammaster);

    obj["noise_index"].get(ent.noise_index);
    obj["noise_index2"].get(ent.noise_index2);
    obj["volume"].get(ent.volume);
    obj["attenuation"].get(ent.attenuation);

    obj["wait"].get(ent.wait);
    obj["delay"].get(ent.delay);
    obj["random"].get(ent.random);

    json_get_optional(doc, obj["teleport_time"], ent.teleport_time);

    obj["watertype"].get_enum(ent.watertype);
    obj["waterlevel"].get_enum(ent.waterlevel);

    json_get_optional(doc, obj["move_origin"], ent.move_origin);
    json_get_optional(doc, obj["move_angles"], ent.move_angles);

    obj["style"].get(ent.style);
    obj["style_on"].get(ent.style_on);
    obj["style_off"].get(ent.style_off);

    json_get_optional(doc, obj["item"], ent.item);
    obj["crosslevel_flags"].get(ent.crosslevel_flags);
    json_get_optional(doc, obj["no_gravity_time"], ent.no_gravity_time);

    ReadEntityMoveInfo(doc, obj["moveinfo"], ent.moveinfo);
    ReadEntityMonsterInfo(doc, obj["monsterinfo"], ent.monsterinfo);

    obj["plat2flags"].get_enum(ent.plat2flags);
    json_get_optional(doc, obj["offset"], ent.offset);
    json_get_optional(doc, obj["gravityVector"], ent.gravityVector, { 0, 0, -1});
    json_get_optional(doc, obj["bad_area"], ent.bad_area);

    obj["clock_message"].get(ent.clock_message);
    json_get_optional(doc, obj["dead_time"], ent.dead_time);
    json_get_optional(doc, obj["beam"], ent.beam);
    json_get_optional(doc, obj["beam2"], ent.beam2);
    json_get_optional(doc, obj["proboscus"], ent.proboscus);
    obj["hackflags"].get(ent.hackflags);

    json_get_optional(doc, obj["fog"], ent.fog);
    json_get_optional(doc, obj["fog_off"], ent.fog_off);
    json_get_optional(doc, obj["heightfog"], ent.heightfog);
    json_get_optional(doc, obj["heightfog_off"], ent.heightfog_off);

    {
        string s;
        obj["item_picked_up_by"].get(s);

        if (!s.empty())
            ent.item_picked_up_by = dynamic_bitset(s);
    }

    json_get_optional(doc, obj["slime_debounce_time"], ent.slime_debounce_time);

    obj["bmodel_anim.start"].get(ent.bmodel_anim.start);
    obj["bmodel_anim.end"].get(ent.bmodel_anim.end);
    obj["bmodel_anim.style"].get_enum(ent.bmodel_anim.style);
    obj["bmodel_anim.speed"].get(ent.bmodel_anim.speed);
    obj["bmodel_anim.nowrap"].get(ent.bmodel_anim.nowrap);

    obj["bmodel_anim.alt_start"].get(ent.bmodel_anim.alt_start);
    obj["bmodel_anim.alt_end"].get(ent.bmodel_anim.alt_end);
    obj["bmodel_anim.alt_style"].get_enum(ent.bmodel_anim.alt_style);
    obj["bmodel_anim.alt_speed"].get(ent.bmodel_anim.alt_speed);
    obj["bmodel_anim.alt_nowrap"].get(ent.bmodel_anim.alt_nowrap);

    obj["bmodel_anim.enabled"].get(ent.bmodel_anim.enabled);
    obj["bmodel_anim.alternate"].get(ent.bmodel_anim.alternate);
    obj["bmodel_anim.currently_alternate"].get(ent.bmodel_anim.currently_alternate);
    json_get_optional(doc, obj["bmodel_anim.next_tick"], ent.bmodel_anim.next_tick);

    obj["lastMOD.id"].get_enum(ent.lastMOD.id);
    obj["lastMOD.friendly_fire"].get(ent.lastMOD.friendly_fire);

    obj["vision_cone"].get(ent.vision_cone);
}

void WriteLevel(bool transition, json_mutdoc &doc)
{
	// update current level entry now, just so we can
	// use gamemap to test EOU
	G_UpdateLevelEntry();

    json_mutval root = doc.val_obj();

    root.obj_add("as_save_version", doc.val(SAVE_FORMAT_VERSION));

	// write level
    json_mutval locals = WriteLevelLocals(doc);

    if (locals.valid && locals.length != 0)
        root.obj_add("level", locals);

    json_mutval ents = doc.val_obj();
    root.obj_add("entities", ents);

	// write entities
	for (uint i = 0; i < num_edicts; i++)
	{
        ASEntity @e = entities[i];

		if (!e.e.inuse)
			continue;
        // clear all the client inuse flags before saving so that
        // when the level is re-entered, the clients will spawn
        // at spawn points instead of occupying body shells
		else if (transition && i >= 1 && i <= max_clients)
			continue;

        json_mutval ent = WriteEntity(doc, e);

        if (ent.valid && ent.length != 0)
            ents.obj_add(format("{}", i), ent);
	}

    doc.root = root;
}

void upgrade_edict(json_doc &doc, json_val obj, ASEntity &ent, uint save_version)
{
	// 1 -> 2
	if (save_version <= 1)
	{
		// func_plat2 gained "wait" key.
		// used to be hardcoded to 2.0f
		if (ent.classname == "func_plat2")
		{
			ent.wait = 2.0f;
		}
	}
}

void upgrade_level(json_doc &doc, json_val root, uint save_version)
{
}

// new entry point for ReadLevel.
// takes in pointer to JSON data. does
// not store or modify it.
void ReadLevel(json_doc &doc)
{
    num_edicts = max_clients + 1;

    internal::allow_value_assign++;
	SetupEntityArrays(true);

    json_val root = doc.root;

    // if we have no version tag it's bad/not Q2AS
    json_val v = root.obj_get("as_save_version");
    //if (!v.is_num)
    //    gi_Com_Error("incompatible save version");

    uint save_version = uint(v.num);

	// read level
    ReadLevelLocals(doc, root["level"]);
	upgrade_level(doc, root, save_version);

    v = root.obj_get("entities");
    json_obj_iter iter(v);

	// read entities
    while (iter.has_next)
	{
        json_val key = iter.next;
        json_val val = iter.get_val(key);

        uint number = parseInt(key.str);

		if (number >= num_edicts)
			num_edicts = number + 1;

        edict_t @ent = G_EdictForNum(number);
        ASEntity @asent;

        if (entities[number] is null)
        {
            @asent = ASEntity(ent);
            @entities[number] = asent;
        }
        else
        {
            @asent = entities[number];

            // entity was already spawned, but it will
            // have stale data from when it first loaded.
            // reset the entire ASEntity (only client needs
            // to be backed up).
            ASClient @cl = asent.client;
            asent = ASEntity(ent);
            @asent.client = cl;
        }

        asent.Init();
        ReadEntity(doc, val, asent);
		upgrade_edict(doc, val, asent, save_version);
		gi_linkentity(ent);
	}

	// mark all clients as unconnected
	for (uint i = 0; i < max_clients; i++)
	{
		ASEntity @ent = players[i];
		ent.client.pers.connected = false;
		ent.client.pers.spawned = false;
	}

	// do any load time things at this point
	for (uint i = max_clients + 1 + BODY_QUEUE_SIZE; i < num_edicts; i++)
	{
		ASEntity @ent = entities[i];

        // any entities that aren't set were freed.
        if (ent is null)
            @ent = @entities[i] = ASEntity(G_EdictForNum(i));

		if (!ent.e.inuse)
        {
            // freed entity, add to free list
            ent.MarkAsFreed();
			continue;
        }

		// fire any cross-level/unit triggers
		if (ent.classname == "target_crosslevel_target" || ent.classname == "target_crossunit_target")
			ent.nextthink = level.time + time_sec(ent.delay);
	}
    internal::allow_value_assign--;

	G_PrecacheInventoryItems();

	// clear cached indices
	cached_soundindex_reset_all();
	cached_modelindex_reset_all();
	cached_imageindex_reset_all();

	G_LoadShadowLights();
}

// [Paril-KEX]
bool CanSave()
{
    if (max_clients == 1 && players[0].health <= 0)
    {
        gi_LocClient_Print(players[0].e, print_type_t::CENTER, "$g_no_save_dead");
        return false;
    }
	// don't allow saving during cameras/intermissions as this
	// causes the game to act weird when these are loaded
	else if (level.intermissiontime)
	{
		return false;
	}

	return true;
}