
/*QUAKED func_group (0 0 0) ?
Used to group brushes together just for editor convenience.
*/

//=====================================================

void Use_Areaportal(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ent.count ^= 1; // toggle state
	gi_SetAreaPortalState(ent.style, ent.count != 0);
}

/*QUAKED func_areaportal (0 0 0) ?

This is a non-visible object that divides the world into
areas that are seperated when this portal is not activated.
Usually enclosed in the middle of a door.
*/
void SP_func_areaportal(ASEntity &ent)
{
	@ent.use = Use_Areaportal;
	ent.count = 0; // always start closed;
}

//=====================================================

/*
=================
Misc functions
=================
*/
vec3_t VelocityForDamage(int damage, vec3_t v)
{
	v.x = 100.0f * crandom();
	v.y = 100.0f * crandom();
	v.z = frandom(200.0f, 300.0f);

	if (damage < 50)
		v = v * 0.7f;
	else
		v = v * 1.2f;

    return v;
}

void ClipGibVelocity(ASEntity &ent)
{
    ent.velocity.x = clamp(ent.velocity.x, -300.f, 300.f);
    ent.velocity.y = clamp(ent.velocity.y, -300.f, 300.f);
    ent.velocity.z = clamp(ent.velocity.z, 200.f, 500.f); // always some upwards
}

/*
=================
gibs
=================
*/
void gib_die (ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (mod.id == mod_id_t::CRUSH)
		G_FreeEdict(self);
}

void gib_touch (ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (tr.plane.normal.z > 0.7f)
	{
		self.e.s.angles.x = clamp(self.e.s.angles.x, -5.0f, 5.0f);
		self.e.s.angles.z = clamp(self.e.s.angles.z, -5.0f, 5.0f);
	}
}

ASEntity @ThrowGib(ASEntity &self, const string &in gibname, int damage, gib_type_t type, float scale = 1, int frame = 0)
{
	ASEntity @gib;
	vec3_t	 vd;
	vec3_t	 origin;
	vec3_t	 size;
	float	 vscale;

	if ((type & gib_type_t::HEAD) != 0)
	{
		@gib = self;
		gib.e.s.event = entity_event_t::OTHER_TELEPORT;
		// remove setskin so that it doesn't set the skin wrongly later
		@self.monsterinfo.setskin = null;
	}
	else
		@gib = G_Spawn();

	size = self.e.size * 0.5f;
	// since absmin is bloated by 1, un-bloat it here
	origin = (self.e.absmin + vec3_t(1, 1, 1)) + size;

	int32 i;

	for (i = 0; i < 3; i++)
	{
		gib.e.s.origin = origin + vec3_t(crandom(), crandom(), crandom()).scaled(size);

		// try 3 times to get a good, non-solid position
		if ((gi_pointcontents(gib.e.s.origin) & contents_t::MASK_SOLID) == 0)
			break;
	}

	if (i == 3)
	{
		// only free us if we're not being turned into the gib, otherwise
		// just spawn inside a wall
		if (gib !is self)
		{
			G_FreeEdict(gib);
			return null;
		}
	}
	
	gib.e.s.modelindex = gi_modelindex(gibname);
	gib.e.s.modelindex2 = 0;
	gib.e.s.scale = scale;
	gib.e.solid = solid_t::NOT;
	gib.e.svflags = svflags_t(gib.e.svflags | svflags_t::DEADMONSTER);
	gib.e.svflags = svflags_t(gib.e.svflags & ~svflags_t::MONSTER);
	gib.e.clipmask = contents_t::MASK_SOLID;
	gib.e.s.effects = effects_t::NONE;
	gib.e.s.renderfx = renderfx_t::LOW_PRIORITY;
	gib.e.s.renderfx = renderfx_t(gib.e.s.renderfx | renderfx_t::NOSHADOW);
	if ((type & gib_type_t::DEBRIS) == 0)
	{
		if ((type & gib_type_t::ACID) != 0)
			gib.e.s.effects = effects_t(gib.e.s.effects | effects_t::GREENGIB);
		else
			gib.e.s.effects = effects_t(gib.e.s.effects | effects_t::GIB);
		gib.e.s.renderfx = renderfx_t(gib.e.s.renderfx | renderfx_t::IR_VISIBLE);
	}
	gib.flags = ent_flags_t(gib.flags | ent_flags_t::NO_KNOCKBACK | ent_flags_t::NO_DAMAGE_EFFECTS);
	gib.takedamage = true;
	@gib.die = gib_die;
	gib.classname = "gib";
	if ((type & gib_type_t::SKINNED) != 0)
		gib.e.s.skinnum = self.e.s.skinnum;
	else
		gib.e.s.skinnum = 0;
	gib.e.s.frame = frame;
	gib.e.mins = gib.e.maxs = vec3_origin;
	gib.e.s.sound = 0;
	gib.monsterinfo.engine_sound = 0;

	if ((type & gib_type_t::METALLIC) == 0)
	{
		gib.movetype = movetype_t::TOSS;
		vscale = (type & gib_type_t::ACID) != 0 ? 3.0 : 0.5;
	}
	else
	{
		gib.movetype = movetype_t::BOUNCE;
		vscale = 1.0;
	}

	if ((type & gib_type_t::DEBRIS) != 0)
	{
		vec3_t v;
		v.x = 100 * crandom();
		v.y = 100 * crandom();
		v.z = 100 + 100 * crandom();
		gib.velocity = self.velocity + (v * damage);
	}
	else
	{
		vd = VelocityForDamage(damage, vd);
		gib.velocity = self.velocity + (vd * vscale);
		ClipGibVelocity(gib);
	}

	if ((type & gib_type_t::UPRIGHT) != 0)
	{
		@gib.touch = gib_touch;
		gib.flags = ent_flags_t(gib.flags | ent_flags_t::ALWAYS_TOUCH);
	}

	gib.avelocity.x = frandom(600);
	gib.avelocity.y = frandom(600);
	gib.avelocity.z = frandom(600);

	gib.e.s.angles.x = frandom(359);
	gib.e.s.angles.y = frandom(359);
	gib.e.s.angles.z = frandom(359);

	@gib.think = G_FreeEdict;

	if (g_instagib.integer != 0)
		gib.nextthink = level.time + random_time(time_sec(1), time_sec(5));
	else
		gib.nextthink = level.time + random_time(time_sec(10), time_sec(20));

	gi_linkentity(gib.e);

	gib.watertype = gi_pointcontents(gib.e.s.origin);

	if ((gib.watertype & contents_t::MASK_WATER) != 0)
		gib.waterlevel = water_level_t::FEET;
	else
		gib.waterlevel = water_level_t::NONE;

	return gib;
}

void ThrowClientHead(ASEntity &self, int damage)
{
	vec3_t		vd;
	string gibname;

	if (brandom())
	{
		gibname = "models/objects/gibs/head2/tris.md2";
		self.e.s.skinnum = 1; // second skin is player
	}
	else
	{
		gibname = "models/objects/gibs/skull/tris.md2";
		self.e.s.skinnum = 0;
	}

	self.e.s.origin.z += 32;
	self.e.s.frame = 0;
	gi_setmodel(self.e, gibname);
	self.e.mins = { -16, -16, 0 };
	self.e.maxs = { 16, 16, 16 };

	self.takedamage = true; // [Paril-KEX] allow takedamage so we get crushed
	self.e.solid = solid_t::TRIGGER; // [Paril-KEX] make 'trigger' so we still move but don't block shots/explode
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.e.s.effects = effects_t::GIB;
	// PGM
	self.e.s.renderfx = renderfx_t(self.e.s.renderfx | renderfx_t::IR_VISIBLE);
	// PGM
	self.e.s.sound = 0;
	self.flags = ent_flags_t(self.flags | ent_flags_t::NO_KNOCKBACK | ent_flags_t::NO_DAMAGE_EFFECTS);

	self.movetype = movetype_t::BOUNCE;
	vd = VelocityForDamage(damage, vd);
	self.velocity += vd;

	if (self.client !is null) // bodies in the queue don't have a client anymore
	{
		self.client.anim_priority = anim_priority_t::DEATH;
		self.client.anim_end = self.e.s.frame;
	}
	else
	{
		@self.think = null;
		self.nextthink = time_zero;
	}

	gi_linkentity(self.e);
}

void BecomeExplosion1(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(self);
}

void BecomeExplosion2(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION2);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(self);
}

namespace spawnflags::path_corner
{
    const uint32 TELEPORT = 1;
}

/*QUAKED path_corner (.5 .3 0) (-8 -8 -8) (8 8 8) TELEPORT
Target: next path corner
Pathtarget: gets used when an entity that has
	this path_corner targeted touches it
*/

void path_corner_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	vec3_t	 v;
	ASEntity @next;

	if (!(other.movetarget is self))
		return;

	if (other.enemy !is null)
		return;

	if (!self.pathtarget.empty())
	{
		string savetarget;
		savetarget = self.target;
		self.target = self.pathtarget;
		G_UseTargets(self, other);
		self.target = savetarget;
	}

	// see m_move; this is just so we don't needlessly check it
	self.flags = ent_flags_t(self.flags | ent_flags_t::PARTIALGROUND);

	if (!self.target.empty())
		@next = G_PickTarget(self.target);
	else
		@next = null;

	// [Paril-KEX] don't teleport to a point_combat, it means HOLD for them.
	if (next !is null && next.classname == "path_corner" && (next.spawnflags & spawnflags::path_corner::TELEPORT) != 0)
	{
		v = next.e.s.origin;
		v.z += next.e.mins.z;
		v.z -= other.e.mins.z;
		other.e.s.origin = v;
		@next = G_PickTarget(next.target);
		other.e.s.event = entity_event_t::OTHER_TELEPORT;
	}

	@other.goalentity = @other.movetarget = next;

	if (self.wait != 0)
	{
		other.monsterinfo.pausetime = level.time + time_sec(self.wait);
		other.monsterinfo.stand(other);
		return;
	}

	if (other.movetarget is null)
	{
		// N64 cutscene behavior
		if ((other.hackflags & HACKFLAG_END_CUTSCENE) != 0)
		{
			G_FreeEdict(other);
			return;
		}

		other.monsterinfo.pausetime = HOLD_FOREVER;
		other.monsterinfo.stand(other);
	}
	else
	{
		v = other.goalentity.e.s.origin - other.e.s.origin;
		other.ideal_yaw = vectoyaw(v);
	}
}

void SP_path_corner(ASEntity &self)
{
	if (self.targetname.empty())
	{
		gi_Com_Print("{} with no targetname\n", self);
		G_FreeEdict(self);
		return;
	}

	self.e.solid = solid_t::TRIGGER;
	@self.touch = path_corner_touch;
	self.e.mins = { -8, -8, -8 };
	self.e.maxs = { 8, 8, 8 };
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	gi_linkentity(self.e);
}

namespace spawnflags::point_combat
{
    const uint32 HOLD = 1;
}

/*QUAKED point_combat (0.5 0.3 0) (-8 -8 -8) (8 8 8) Hold
Makes this the target of a monster and it will head here
when first activated before going after the activator.  If
hold is selected, it will stay here.
*/
void point_combat_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @activator;

	if (!(other.movetarget is self))
		return;

	if (!self.target.empty())
	{
		other.target = self.target;
		@other.goalentity = @other.movetarget = G_PickTarget(other.target);
		if (other.goalentity is null)
		{
			gi_Com_Print("{} target {} does not exist\n", self, self.target);
			@other.movetarget = self;
		}
		// [Paril-KEX] allow them to be re-used
		//self.target = null;
	}
	else if ((self.spawnflags & spawnflags::point_combat::HOLD) != 0 && (other.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) == 0)
	{
		// already standing
		if ((other.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
			return;

		other.monsterinfo.pausetime = HOLD_FOREVER;
		other.monsterinfo.aiflags = ai_flags_t(other.monsterinfo.aiflags | ai_flags_t::STAND_GROUND | ai_flags_t::REACHED_HOLD_COMBAT | ai_flags_t::THIRD_EYE);
		other.monsterinfo.stand(other);
	}

	if (other.movetarget is self)
	{
		// [Paril-KEX] if we're holding, keep movetarget set; we will
		// use this to make sure we haven't moved too far from where
		// we want to "guard".
		if ((self.spawnflags & spawnflags::point_combat::HOLD) == 0)
		{
			other.target = "";
			@other.movetarget = null;
		}

		@other.goalentity = other.enemy;
		other.monsterinfo.aiflags = ai_flags_t(other.monsterinfo.aiflags & ~ai_flags_t::COMBAT_POINT);
	}

	if (!self.pathtarget.empty())
	{
		string savetarget;

		savetarget = self.target;
		self.target = self.pathtarget;
		if (other.enemy !is null && other.enemy.client !is null)
			@activator = other.enemy;
		else if (other.oldenemy !is null && other.oldenemy.client !is null)
			@activator = other.oldenemy;
		else if (other.activator !is null && other.activator.client !is null)
			@activator = other.activator;
		else
			@activator = other;
		G_UseTargets(self, activator);
		self.target = savetarget;
	}
}

void SP_point_combat(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{
		G_FreeEdict(self);
		return;
	}
	self.e.solid = solid_t::TRIGGER;
	@self.touch = point_combat_touch;
	self.e.mins = { -8, -8, -16 };
	self.e.maxs = { 8, 8, 16 };
	self.e.svflags = svflags_t::NOCLIENT;
	gi_linkentity(self.e);
}

/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void SP_info_null(ASEntity &self)
{
	self.Free();
}

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void SP_info_notnull(ASEntity &self)
{
	self.e.absmin = self.e.s.origin;
	self.e.absmax = self.e.s.origin;
}

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF ALLOW_IN_DM
Non-displayed light.
Default light value is 300.
Default style is 0.
If targeted, will toggle between on and off.
Default _cone value is 10 (used to set size of light for spotlights)
*/

namespace spawnflags::light
{
    const uint32 START_OFF = 1;
    const uint32 ALLOW_IN_DM = 2;
}

void light_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if ((self.spawnflags & spawnflags::light::START_OFF) != 0)
	{
		gi_configstring(configstring_id_t(configstring_id_t::LIGHTS + self.style), self.style_on);
		self.spawnflags &= ~spawnflags::light::START_OFF;
	}
	else
	{
		gi_configstring(configstring_id_t(configstring_id_t::LIGHTS + self.style), self.style_off);
		self.spawnflags |= spawnflags::light::START_OFF;
	}
}

// ---------------------------------------------------------------------------------
// [Sam-KEX] For keeping track of shadow light parameters and setting them up on
// the server side.
void setup_shadow_lights()
{
	for(uint i = 0, s = 0; i < num_edicts; ++i)
	{
        ASEntity @self = entities[i];

        if (!self.e.inuse || (self.e.s.renderfx & renderfx_t::CASTSHADOW) == 0)
            continue;
        
        shadow_light_data_t lightdata;
        gi_GetShadowLightData(i, lightdata);
        lightdata.lighttype = shadow_light_type_t::point;
        lightdata.conedirection = vec3_origin;

		if(!self.target.empty())
		{
			ASEntity @target = find_by_str<ASEntity>(null, "targetname", self.target);
			if(target !is null)
			{
				lightdata.conedirection = (target.e.s.origin - self.e.s.origin).normalized();
				lightdata.lighttype = shadow_light_type_t::cone;
			}
		}

		if (!self.itemtarget.empty())
		{
			ASEntity @target = find_by_str<ASEntity>(null, "targetname", self.itemtarget);
			if(target !is null)
				lightdata.lightstyle = target.style;
		}

        gi_SetShadowLightData(self.e.s.number, lightdata);

		gi_configstring(int16(configstring_id_t::SHADOWLIGHTS) + s, "{};{};{:1};{};{:1};{:1};{:1};{};{:1};{:1};{:1};{:1}",
			self.e.s.number,
			int(lightdata.lighttype),
			lightdata.radius,
			lightdata.resolution,
			lightdata.intensity,
			lightdata.fade_start,
			lightdata.fade_end,
			lightdata.lightstyle,
			lightdata.coneangle,
			lightdata.conedirection.x,
			lightdata.conedirection.y,
			lightdata.conedirection.z);
        s++;
	}
}

// fix an oversight in shadow light code that causes
// lights to be ordered wrong on return levels
// if the spawn functions are changed.
// this will work without changing the save/load code.
void G_LoadShadowLights()
{
	for (uint i = 0; i < level.shadow_light_count; i++)
	{
		array<string> tokens = gi_get_configstring(configstring_id_t::SHADOWLIGHTS + i).split(";");

		if (tokens.length() == 12)
		{
            shadow_light_data_t info;
            uint entity_number = parseUInt(tokens[0]);
            gi_GetShadowLightData(entity_number, info);
			info.lighttype = shadow_light_type_t(parseInt(tokens[1]));
			info.radius = parseFloat(tokens[2]);
			info.resolution = parseInt(tokens[3]);
			info.intensity = parseFloat(tokens[4]);
			info.fade_start = parseFloat(tokens[5]);
			info.fade_end = parseFloat(tokens[6]);
			info.lightstyle = parseInt(tokens[7]);
			info.coneangle = parseFloat(tokens[8]);
			info.conedirection[0] = parseFloat(tokens[9]);
			info.conedirection[1] = parseFloat(tokens[10]);
			info.conedirection[2] = parseFloat(tokens[11]);
            gi_SetShadowLightData(entity_number, info);
		}
	}
}
// ---------------------------------------------------------------------------------

void setup_dynamic_light(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	// [Sam-KEX] Shadow stuff
	if (st.sl.data.radius > 0)
	{
		self.e.s.renderfx = renderfx_t::CASTSHADOW;
		self.itemtarget = st.sl.lightstyletarget;

        gi_SetShadowLightData(self.e.s.number, st.sl.data);
		level.shadow_light_count++;

		self.e.mins = self.e.maxs = vec3_origin;

		gi_linkentity(self.e);
	}
}

void dynamic_light_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.svflags = svflags_t(self.e.svflags ^ svflags_t::NOCLIENT);
}

void SP_dynamic_light(ASEntity &self)
{
	setup_dynamic_light(self);

	if (!self.targetname.empty())
	{
		@self.use = dynamic_light_use;
	}
	
	if ((self.spawnflags & spawnflags::light::START_OFF) != 0)
	    self.e.svflags = svflags_t(self.e.svflags ^ svflags_t::NOCLIENT);
}

void SP_light(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	// no targeted lights in deathmatch, because they cause global messages
	if((self.targetname.empty() || (deathmatch.integer != 0 && (self.spawnflags & spawnflags::light::ALLOW_IN_DM) == 0)) && st.sl.data.radius == 0) // [Sam-KEX]
	{
		G_FreeEdict(self);
		return;
	}

	if (self.style >= 32)
	{
		@self.use = light_use;

		if (self.style_on.empty())
			self.style_on = "m";
		else if (self.style_on[0] >= '0' && self.style_on[0] <= '9')
			self.style_on = gi_get_configstring(configstring_id_t(configstring_id_t::LIGHTS + parseInt(self.style_on)));
		if (self.style_off.empty())
			self.style_off = "a";
		else if (self.style_off[0] >= '0' && self.style_off[0] <= '9')
			self.style_off = gi_get_configstring(configstring_id_t(configstring_id_t::LIGHTS + parseInt(self.style_off)));

		if ((self.spawnflags & spawnflags::light::START_OFF) != 0)
			gi_configstring(configstring_id_t(configstring_id_t::LIGHTS) + self.style, self.style_off);
		else
			gi_configstring(configstring_id_t(configstring_id_t::LIGHTS + self.style), self.style_on);
	}

	setup_dynamic_light(self);
}

/*QUAKED func_wall (0 .5 .8) ? TRIGGER_SPAWN TOGGLE START_ON ANIMATED ANIMATED_FAST
This is just a solid wall if not inhibited

TRIGGER_SPAWN	the wall will not be present until triggered
				it will then blink in to existance; it will
				kill anything that was in it's way

TOGGLE			only valid for TRIGGER_SPAWN walls
				this allows the wall to be turned on and off

START_ON		only valid for TRIGGER_SPAWN walls
				the wall will initially be present
*/

namespace spawnflags::wall
{
    const uint32 TRIGGER_SPAWN = 1;
    const uint32 TOGGLE = 2;
    const uint32 START_ON = 4;
    const uint32 ANIMATED = 8;
    const uint32 ANIMATED_FAST = 16;
    const uint32 SAFE_APPEAR = 32;
}

void func_wall_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
	{
		self.e.solid = solid_t::BSP;
		self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
		gi_linkentity(self.e);
		KillBox(self, false, mod_id_t::TELEFRAG, true, (self.spawnflags & spawnflags::wall::SAFE_APPEAR) != 0);
	}
	else
	{
		self.e.solid = solid_t::NOT;
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
		gi_linkentity(self.e);
	}

	if ((self.spawnflags & spawnflags::wall::TOGGLE) == 0)
		@self.use = null;
}

void SP_func_wall(ASEntity &self)
{
	self.movetype = movetype_t::PUSH;
	gi_setmodel(self.e, self.model);

	if ((self.spawnflags & spawnflags::wall::ANIMATED) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALL);
	if ((self.spawnflags & spawnflags::wall::ANIMATED_FAST) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALLFAST);

	// just a wall
	if ((self.spawnflags & (spawnflags::wall::TRIGGER_SPAWN | spawnflags::wall::TOGGLE | spawnflags::wall::START_ON)) == 0)
	{
		self.e.solid = solid_t::BSP;
		gi_linkentity(self.e);
		return;
	}

	// it must be TRIGGER_SPAWN
	if ((self.spawnflags & spawnflags::wall::TRIGGER_SPAWN) == 0)
		self.spawnflags |= spawnflags::wall::TRIGGER_SPAWN;

	// yell if the spawnflags are odd
	if ((self.spawnflags & spawnflags::wall::START_ON) != 0)
	{
		if ((self.spawnflags & spawnflags::wall::TOGGLE) == 0)
		{
			gi_Com_Print("func_wall START_ON without TOGGLE\n");
			self.spawnflags |= spawnflags::wall::TOGGLE;
		}
	}

	@self.use = func_wall_use;
	if ((self.spawnflags & spawnflags::wall::START_ON) != 0)
	{
		self.e.solid = solid_t::BSP;
	}
	else
	{
		self.e.solid = solid_t::NOT;
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	}
	gi_linkentity(self.e);
}


// [Paril-KEX]
/*QUAKED func_animation (0 .5 .8) ? START_ON
Similar to func_wall, but triggering it will toggle animation
state rather than going on/off.

START_ON		will start in alterate animation
*/

namespace spawnflags::animation
{
    const uint32 START_ON = 1;
}

void func_animation_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.bmodel_anim.alternate = !self.bmodel_anim.alternate;
}

void SP_func_animation(ASEntity &self)
{
	if (!self.bmodel_anim.enabled)
	{
		gi_Com_Print("{} has no animation data\n", self);
		G_FreeEdict(self);
		return;
	}

	self.movetype = movetype_t::PUSH;
	gi_setmodel(self.e, self.model);
	self.e.solid = solid_t::BSP;

	@self.use = func_animation_use;
	self.bmodel_anim.alternate = (self.spawnflags & spawnflags::animation::START_ON) != 0;

	if (self.bmodel_anim.alternate)
		self.e.s.frame = self.bmodel_anim.alt_start;
	else
		self.e.s.frame = self.bmodel_anim.start;

	gi_linkentity(self.e);
}


/*QUAKED func_object (0 .5 .8) ? TRIGGER_SPAWN ANIMATED ANIMATED_FAST
This is solid bmodel that will fall if it's support it removed.
*/

namespace spawnflags::object
{
    const uint32 TRIGGER_SPAWN = 1;
    const uint32 ANIMATED = 2;
    const uint32 ANIMATED_FAST = 4;
}

void func_object_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	// only squash thing we fall on top of
	if (other_touching_self)
		return;
	if (tr.plane.normal[2] < 1.0f)
		return;
	if (other.takedamage == false)
		return;
	if (other.damage_debounce_time > level.time)
		return;
	T_Damage(other, self, self, vec3_origin, closest_point_to_box(other.e.s.origin, self.e.absmin, self.e.absmax), tr.plane.normal, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
	other.damage_debounce_time = level.time + time_hz(10);
}

void func_object_release(ASEntity &self)
{
	self.movetype = movetype_t::TOSS;
	@self.touch = func_object_touch;
}

void func_object_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.solid = solid_t::BSP;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	@self.use = null;
	func_object_release(self);
	KillBox(self, false);
}

void SP_func_object(ASEntity &self)
{
	gi_setmodel(self.e, self.model);

	self.e.mins.x += 1;
	self.e.mins.y += 1;
	self.e.mins.z += 1;
	self.e.maxs.x -= 1;
	self.e.maxs.y -= 1;
	self.e.maxs.z -= 1;

	if (self.dmg == 0)
		self.dmg = 100;

	if ((self.spawnflags & spawnflags::object::TRIGGER_SPAWN) == 0)
	{
		self.e.solid = solid_t::BSP;
		self.movetype = movetype_t::PUSH;
		@self.think = func_object_release;
		self.nextthink = level.time + time_hz(20);
	}
	else
	{
		self.e.solid = solid_t::NOT;
		self.movetype = movetype_t::PUSH;
		@self.use = func_object_use;
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	}

	if ((self.spawnflags & spawnflags::object::ANIMATED) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALL);
	if ((self.spawnflags & spawnflags::object::ANIMATED_FAST) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALLFAST);

	self.e.clipmask = contents_t::MASK_MONSTERSOLID;
	self.flags = ent_flags_t(self.flags | ent_flags_t::NO_STANDING);

	gi_linkentity(self.e);
}

/*QUAKED func_explosive (0 .5 .8) ? Trigger_Spawn ANIMATED ANIMATED_FAST INACTIVE ALWAYS_SHOOTABLE
Any brush that you want to explode or break apart.  If you want an
ex0plosion, set dmg and it will do a radius explosion of that amount
at the center of the bursh.

If targeted it will not be shootable.

INACTIVE - specifies that the entity is not explodable until triggered. If you use this you must
target the entity you want to trigger it. This is the only entity approved to activate it.

health defaults to 100.

mass defaults to 75.  This determines how much debris is emitted when
it explodes.  You get one large chunk per 100 of mass (up to 8) and
one small chunk per 25 of mass (up to 16).  So 800 gives the most.
*/

namespace spawnflags::explosive
{
    const uint32 TRIGGER_SPAWN = 1;
    const uint32 ANIMATED = 2;
    const uint32 ANIMATED_FAST = 4;
    const uint32 INACTIVE = 8;
    const uint32 ALWAYS_SHOOTABLE = 16;
}

void func_explosive_explode(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	uint     count;
	int		 mass;
	ASEntity @master;
	bool	 done = false;

	self.takedamage = false;

	if (self.dmg != 0)
		T_RadiusDamage(self, attacker, float(self.dmg), null, float(self.dmg + 40), damageflags_t::NONE, mod_id_t::EXPLOSIVE);

	self.velocity = inflictor.e.s.origin - self.e.s.origin;
	self.velocity.normalize();
	self.velocity *= 150;

	mass = self.mass;
	if (mass == 0)
		mass = 75;

	// big chunks
	if (mass >= 100)
	{
		count = mass / 100;
		if (count > 8)
			count = 8;
		ThrowGibs(self, 1, {
			gib_def_t(count, "models/objects/debris1/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
		});
	}

	// small chunks
	count = mass / 25;
	if (count > 16)
		count = 16;
	ThrowGibs(self, 2, {
		gib_def_t(count, "models/objects/debris2/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
	});

	// PMM - if we're part of a train, clean ourselves out of it
	if ((self.flags & ent_flags_t::TEAMSLAVE) != 0)
	{
		if (self.teammaster !is null)
		{
			@master = self.teammaster;
			if (master !is null && master.e.inuse) // because mappers (other than jim (usually)) are stupid....
			{
				while (!done)
				{
					if (master.teamchain is self)
					{
						@master.teamchain = self.teamchain;
						done = true;
					}
					@master = master.teamchain;
				}
			}
		}
	}

	G_UseTargets(self, attacker);

	self.e.s.origin = (self.e.absmin + self.e.absmax) * 0.5f;
	
	if (self.noise_index != 0)
		gi_positioned_sound(self.e.s.origin, self.e, soundchan_t::AUTO, self.noise_index, 1, ATTN_NORM, 0);

	if (self.dmg != 0)
		BecomeExplosion1(self);
	else
		G_FreeEdict(self);
}

void func_explosive_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	// Paril: pass activator to explode as attacker. this fixes
	// "strike" trying to centerprint to the relay. Should be
	// a safe change.
	func_explosive_explode(self, self, activator, self.health, vec3_origin, mod_id_t::EXPLOSIVE);
}

// PGM
void func_explosive_activate(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	bool approved = false;

	// PMM - looked like target and targetname were flipped here
	if (other !is null && !other.target.empty())
	{
		if (other.target == self.targetname)
			approved = true;
	}
	if (!approved && activator !is null && !activator.target.empty())
	{
		if (activator.target == self.targetname)
			approved = true;
	}

	if (!approved)
		return;

	@self.use = func_explosive_use;
	if (self.health == 0)
		self.health = 100;
	@self.die = func_explosive_explode;
	self.takedamage = true;
}
// PGM

void func_explosive_spawn(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.solid = solid_t::BSP;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	@self.use = null;
	gi_linkentity(self.e);
	KillBox(self, false);
}

void SP_func_explosive(ASEntity &self)
{
	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(self);
		return;
	}

	self.movetype = movetype_t::PUSH;

	gi_modelindex("models/objects/debris1/tris.md2");
	gi_modelindex("models/objects/debris2/tris.md2");

	gi_setmodel(self.e, self.model);

	if ((self.spawnflags & spawnflags::explosive::TRIGGER_SPAWN) != 0)
	{
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
		self.e.solid = solid_t::NOT;
		@self.use = func_explosive_spawn;
	}
	// PGM
	else if ((self.spawnflags & spawnflags::explosive::INACTIVE) != 0)
	{
		self.e.solid = solid_t::BSP;
		if (!self.targetname.empty())
			@self.use = func_explosive_activate;
	}
	// PGM
	else
	{
		self.e.solid = solid_t::BSP;
		if (!self.targetname.empty())
			@self.use = func_explosive_use;
	}

	if ((self.spawnflags & spawnflags::explosive::ANIMATED) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALL);
	if ((self.spawnflags & spawnflags::explosive::ANIMATED_FAST) != 0)
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM_ALLFAST);

	// PGM
	if ((self.spawnflags & spawnflags::explosive::ALWAYS_SHOOTABLE) != 0 || ((self.use !is func_explosive_use) && (self.use !is func_explosive_activate)))
	// PGM
	{
		if (self.health == 0)
			self.health = 100;
		@self.die = func_explosive_explode;
		self.takedamage = true;
	}

	if (self.sounds != 0)
	{
		if (self.sounds == 1)
			self.noise_index = gi_soundindex("world/brkglas.wav");
		else
			gi_Com_Print("{}: invalid \"sounds\" {}\n", self, self.sounds);
	}

	gi_linkentity(self.e);
}

/*QUAKED misc_explobox (0 .5 .8) (-16 -16 0) (16 16 40)
Large exploding box.  You can override its mass (100),
health (80), and dmg (150).
*/

void barrel_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	float  ratio;
	vec3_t v;

	if ((other.groundentity is null) || (other.groundentity is self))
		return;
	else if (!other_touching_self)
		return;

	ratio = float(other.mass) / float(self.mass);
	v = self.e.s.origin - other.e.s.origin;
	M_walkmove(self, vectoyaw(v), 20 * ratio * gi_frame_time_s);
}

void barrel_explode(ASEntity &self)
{
	self.takedamage = false;

	T_RadiusDamage(self, self.activator, float(self.dmg), null, float(self.dmg + 40), damageflags_t::NONE, mod_id_t::BARREL);

	ThrowGibs(self, int(1.5f * self.dmg / 200.f), {
		gib_def_t(2, "models/objects/debris1/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS)),
		gib_def_t(4, "models/objects/debris3/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS)),
		gib_def_t(8, "models/objects/debris2/tris.md2", gib_type_t(gib_type_t::METALLIC | gib_type_t::DEBRIS))
	});

	if (self.groundentity !is null)
		BecomeExplosion2(self);
	else
		BecomeExplosion1(self);
}

void barrel_burn(ASEntity &self)
{
	if (level.time >= self.timestamp)
		@self.think = barrel_explode;

	self.e.s.effects = effects_t(self.e.s.effects | effects_t::BARREL_EXPLODING);
	self.e.s.sound = gi_soundindex("weapons/bfg__l1a.wav");
	self.nextthink = level.time + FRAME_TIME_S;
}

void barrel_delay(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// allow "dead" barrels waiting to explode to still receive knockback
	if (self.think is barrel_burn || self.think is barrel_explode)
		return;
	
	// allow big booms to immediately blow up barrels (rockets, rail, other explosions) because it feels good and powerful
	if (damage >= 90)
	{
		@self.think = barrel_explode;
		@self.activator = attacker;
	}
	else
	{
		self.timestamp = level.time + time_ms(750);
		@self.think = barrel_burn;
		@self.activator = attacker;
	}

}

//=========
// PGM  - change so barrels will think and hence, blow up
void barrel_think(ASEntity &self)
{
	// the think needs to be first since later stuff may override.
	@self.think = barrel_think;
	self.nextthink = level.time + FRAME_TIME_S;

	M_CatagorizePosition(self, self.e.s.origin, self.waterlevel, self.watertype);
	self.flags = ent_flags_t(self.flags | ent_flags_t::IMMUNE_SLIME);
	self.air_finished = level.time + time_sec(100);
	M_WorldEffects(self);
}

void barrel_start(ASEntity &self)
{
	M_droptofloor(self);
	@self.think = barrel_think;
	self.nextthink = level.time + FRAME_TIME_S;
}
// PGM
//=========

namespace spawnflags::explobox
{
    const uint32 NO_MOVE = 1;
}

void SP_misc_explobox(ASEntity &self)
{
	if (deathmatch.integer != 0 )
	{ // auto-remove for deathmatch
		G_FreeEdict(self);
		return;
	}

	gi_modelindex("models/objects/debris1/tris.md2");
	gi_modelindex("models/objects/debris2/tris.md2");
	gi_modelindex("models/objects/debris3/tris.md2");
	gi_soundindex("weapons/bfg__l1a.wav");

	self.e.solid = solid_t::BBOX;
	self.movetype = movetype_t::STEP;

	self.model = "models/objects/barrels/tris.md2";
	self.e.s.modelindex = gi_modelindex(self.model);
	self.e.mins = { -16, -16, 0 };
	self.e.maxs = { 16, 16, 40 };

	if (self.mass == 0)
		self.mass = 50;
	if (self.health == 0)
		self.health = 10;
	if (self.dmg == 0)
		self.dmg = 150;

	@self.die = barrel_delay;
	self.takedamage = true;
	self.flags = ent_flags_t(self.flags | ent_flags_t::TRAP);

	if ((self.spawnflags & spawnflags::explobox::NO_MOVE) == 0)
		@self.touch = barrel_touch;
	else
		self.flags = ent_flags_t(self.flags | ent_flags_t::NO_KNOCKBACK);

	// PGM - change so barrels will think and hence, blow up
	@self.think = barrel_start;
	self.nextthink = level.time + time_hz(20);
	// PGM

	gi_linkentity(self.e);
}

//
// miscellaneous specialty items
//

/*QUAKED misc_blackhole (1 .5 0) (-8 -8 -8) (8 8 8) AUTO_NOISE
model="models/objects/black/tris.md2"
*/

namespace spawnflags::blackhole
{
    const uint32 AUTO_NOISE = 1;
}

void misc_blackhole_use(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	/*
	gi.WriteByte (svc_temp_entity);
	gi.WriteByte (TE_BOSSTPORT);
	gi.WritePosition (ent.s.origin);
	gi.multicast (ent.s.origin, MULTICAST_PVS);
	*/
	G_FreeEdict(ent);
}

void misc_blackhole_think(ASEntity &self)
{
	if (self.timestamp <= level.time)
	{
		if (++self.e.s.frame >= 19)
			self.e.s.frame = 0;

		self.timestamp = level.time + time_hz(10);
	}
	
	if ((self.spawnflags & spawnflags::blackhole::AUTO_NOISE) != 0)
	{
		self.e.s.angles.x += 50.0f * gi_frame_time_s;
		self.e.s.angles.y += 50.0f * gi_frame_time_s;
	}

	self.nextthink = level.time + FRAME_TIME_MS;
}

void SP_misc_blackhole(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.mins = { -64, -64, 0 };
	ent.e.maxs = { 64, 64, 8 };
	ent.e.s.modelindex = gi_modelindex("models/objects/black/tris.md2");
	ent.e.s.renderfx = renderfx_t::TRANSLUCENT;
	@ent.use = misc_blackhole_use;
	@ent.think = misc_blackhole_think;
	ent.nextthink = level.time + time_hz(20);

	if ((ent.spawnflags & spawnflags::blackhole::AUTO_NOISE) != 0)
	{
		ent.e.s.sound = gi_soundindex("world/blackhole.wav");
		ent.e.s.loop_attenuation = ATTN_NORM;
	}

	gi_linkentity(ent.e);
}

/*QUAKED misc_eastertank (1 .5 0) (-32 -32 -16) (32 32 32)
 */

void misc_eastertank_think(ASEntity &self)
{
	if (++self.e.s.frame < 293)
		self.nextthink = level.time + time_hz(10);
	else
	{
		self.e.s.frame = 254;
		self.nextthink = level.time + time_hz(10);
	}
}

void SP_misc_eastertank(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.e.mins = { -32, -32, -16 };
	ent.e.maxs = { 32, 32, 32 };
	ent.e.s.modelindex = gi_modelindex("models/monsters/tank/tris.md2");
	ent.e.s.frame = 254;
	@ent.think = misc_eastertank_think;
	ent.nextthink = level.time + time_hz(20);
	gi_linkentity(ent.e);
}

/*QUAKED misc_easterchick (1 .5 0) (-32 -32 0) (32 32 32)
 */

void misc_easterchick_think(ASEntity &self)
{
	if (++self.e.s.frame < 247)
		self.nextthink = level.time + time_hz(10);
	else
	{
		self.e.s.frame = 208;
		self.nextthink = level.time + time_hz(10);
	}
}

void SP_misc_easterchick(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.e.mins = { -32, -32, 0 };
	ent.e.maxs = { 32, 32, 32 };
	ent.e.s.modelindex = gi_modelindex("models/monsters/bitch/tris.md2");
	ent.e.s.frame = 208;
	@ent.think = misc_easterchick_think;
	ent.nextthink = level.time + time_hz(20);
	gi_linkentity(ent.e);
}

/*QUAKED misc_easterchick2 (1 .5 0) (-32 -32 0) (32 32 32)
 */

void misc_easterchick2_think(ASEntity &self)
{
	if (++self.e.s.frame < 287)
		self.nextthink = level.time + time_hz(10);
	else
	{
		self.e.s.frame = 248;
		self.nextthink = level.time + time_hz(10);
	}
}

void SP_misc_easterchick2(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.e.mins = { -32, -32, 0 };
	ent.e.maxs = { 32, 32, 32 };
	ent.e.s.modelindex = gi_modelindex("models/monsters/bitch/tris.md2");
	ent.e.s.frame = 248;
	@ent.think = misc_easterchick2_think;
	ent.nextthink = level.time + time_hz(20);
	gi_linkentity(ent.e);
}

/*QUAKED monster_commander_body (1 .5 0) (-32 -32 0) (32 32 48)
Not really a monster, this is the Tank Commander's decapitated body.
There should be a item_commander_head that has this as it's target.
*/

void commander_body_think(ASEntity &self)
{
	if (++self.e.s.frame < 24)
		self.nextthink = level.time + time_hz(10);
	else
		self.nextthink = time_zero;

	if (self.e.s.frame == 22)
		gi_sound(self.e, soundchan_t::BODY, gi_soundindex("tank/thud.wav"), 1, ATTN_NORM, 0);
}

void commander_body_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.think = commander_body_think;
	self.nextthink = level.time + time_hz(10);
	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("tank/pain.wav"), 1, ATTN_NORM, 0);
}

void commander_body_drop(ASEntity &self)
{
	self.movetype = movetype_t::TOSS;
	self.e.s.origin[2] += 2;
}

void SP_monster_commander_body(ASEntity &self)
{
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::BBOX;
	self.model = "models/monsters/commandr/tris.md2";
	self.e.s.modelindex = gi_modelindex(self.model);
	self.e.mins = { -32, -32, 0 };
	self.e.maxs = { 32, 32, 48 };
	@self.use = commander_body_use;
	self.takedamage = true;
	self.flags = ent_flags_t::GODMODE;
	gi_linkentity(self.e);

	gi_soundindex("tank/thud.wav");
	gi_soundindex("tank/pain.wav");

	@self.think = commander_body_drop;
	self.nextthink = level.time + time_hz(50);
}

/*QUAKED misc_banner (1 .5 0) (-4 -4 -4) (4 4 4)
The origin is the bottom of the banner.
The banner is 128 tall.
model="models/objects/banner/tris.md2"
*/
void misc_banner_think(ASEntity &ent)
{
	ent.e.s.frame = (ent.e.s.frame + 1) % 16;
	ent.nextthink = level.time + time_hz(10);
}

void SP_misc_banner(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/objects/banner/tris.md2");
	ent.e.s.frame = irandom(16);
	gi_linkentity(ent.e);

	@ent.think = misc_banner_think;
	ent.nextthink = level.time + time_hz(10);
}

/*QUAKED misc_deadsoldier (1 .5 0) (-16 -16 0) (16 16 16) ON_BACK ON_STOMACH BACK_DECAP FETAL_POS SIT_DECAP IMPALED
This is the dead player model. Comes in 6 exciting different poses!
*/

namespace spawnflags::deadsoldier
{
    const uint32 ON_BACK = 1;
    const uint32 ON_STOMACH = 2;
    const uint32 BACK_DECAP = 4;
    const uint32 FETAL_POS = 8;
    const uint32 SIT_DECAP = 16;
    const uint32 IMPALED = 32;
}

void misc_deadsoldier_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.health > -30)
		return;

	gi_sound(self.e, soundchan_t::BODY, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);
	ThrowGibs(self, damage, {
		gib_def_t(4, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t("models/objects/gibs/head2/tris.md2", gib_type_t::HEAD)
	});
}

void SP_misc_deadsoldier(ASEntity &ent)
{
	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.e.s.modelindex = gi_modelindex("models/deadbods/dude/tris.md2");

	// Defaults to frame 0
	if ((ent.spawnflags & spawnflags::deadsoldier::ON_STOMACH) != 0)
		ent.e.s.frame = 1;
	else if ((ent.spawnflags & spawnflags::deadsoldier::BACK_DECAP) != 0)
		ent.e.s.frame = 2;
	else if ((ent.spawnflags & spawnflags::deadsoldier::FETAL_POS) != 0)
		ent.e.s.frame = 3;
	else if ((ent.spawnflags & spawnflags::deadsoldier::SIT_DECAP) != 0)
		ent.e.s.frame = 4;
	else if ((ent.spawnflags & spawnflags::deadsoldier::IMPALED) != 0)
		ent.e.s.frame = 5;
	else if ((ent.spawnflags & spawnflags::deadsoldier::ON_BACK) != 0)
		ent.e.s.frame = 0;
	else
		ent.e.s.frame = 0;

	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 16 };
	ent.deadflag = true;
	ent.takedamage = true;
	// nb: SVF_MONSTER is here so it bleeds
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::MONSTER | svflags_t::DEADMONSTER);
	@ent.die = misc_deadsoldier_die;
	ent.monsterinfo.aiflags = ai_flags_t(ent.monsterinfo.aiflags | ai_flags_t::GOOD_GUY | ai_flags_t::DO_NOT_COUNT);

	gi_linkentity(ent.e);
}

/*QUAKED misc_viper (1 .5 0) (-16 -16 0) (16 16 32)
This is the Viper for the flyby bombing.
It is trigger_spawned, so you must have something use it for it to show up.
There must be a path for it to follow once it is activated.

"speed"		How fast the Viper should fly
*/

void misc_viper_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	@self.use = train_use;
	train_use(self, other, activator);
}

void SP_misc_viper(ASEntity &ent)
{
	if (ent.target.empty())
	{
		gi_Com_Print("{} without a target\n", ent);
		G_FreeEdict(ent);
		return;
	}

	if (ent.speed == 0)
		ent.speed = 300;

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/ships/viper/tris.md2");
	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 32 };

	@ent.think = func_train_find;
	ent.nextthink = level.time + time_hz(10);
	@ent.use = misc_viper_use;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = ent.speed;

	gi_linkentity(ent.e);
}

/*QUAKED misc_bigviper (1 .5 0) (-176 -120 -24) (176 120 72)
This is a large stationary viper as seen in Paul's intro
*/
void SP_misc_bigviper(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.mins = { -176, -120, -24 };
	ent.e.maxs = { 176, 120, 72 };
	ent.e.s.modelindex = gi_modelindex("models/ships/bigviper/tris.md2");
	gi_linkentity(ent.e);
}

/*QUAKED misc_viper_bomb (1 0 0) (-8 -8 -8) (8 8 8)
"dmg"	how much boom should the bomb make?
*/
void misc_viper_bomb_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	G_UseTargets(self, self.activator);

	self.e.s.origin[2] = self.e.absmin[2] + 1;
	T_RadiusDamage(self, self, float(self.dmg), null, float(self.dmg + 40), damageflags_t::NONE, mod_id_t::BOMB);
	BecomeExplosion2(self);
}

void misc_viper_bomb_prethink(ASEntity &self)
{
	@self.groundentity = null;

	float diff = (self.timestamp - level.time).secondsf();
	if (diff < -1.0f)
		diff = -1.0f;

	vec3_t v = self.moveinfo.dir * (1.0f + diff);
	v[2] = diff;

	diff = self.e.s.angles[2];
	self.e.s.angles = vectoangles(v);
	self.e.s.angles[2] = diff + 10;
}

void misc_viper_bomb_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @viper;

	self.e.solid = solid_t::BBOX;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	self.e.s.effects = effects_t(self.e.s.effects | effects_t::ROCKET);
	@self.use = null;
	self.movetype = movetype_t::TOSS;
	@self.prethink = misc_viper_bomb_prethink;
	@self.touch = misc_viper_bomb_touch;
	@self.activator = activator;

	@viper = find_by_str<ASEntity>(null, "classname", "misc_viper");
	self.velocity = viper.moveinfo.dir * viper.moveinfo.speed;

	self.timestamp = level.time;
	self.moveinfo.dir = viper.moveinfo.dir;
}

void SP_misc_viper_bomb(ASEntity &self)
{
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::NOT;
	self.e.mins = { -8, -8, -8 };
	self.e.maxs = { 8, 8, 8 };

	self.e.s.modelindex = gi_modelindex("models/objects/bomb/tris.md2");

	if (self.dmg == 0)
		self.dmg = 1000;

	@self.use = misc_viper_bomb_use;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);

	gi_linkentity(self.e);
}

/*QUAKED misc_strogg_ship (1 .5 0) (-16 -16 0) (16 16 32)
This is a Storgg ship for the flybys.
It is trigger_spawned, so you must have something use it for it to show up.
There must be a path for it to follow once it is activated.

"speed"		How fast it should fly
*/
void misc_strogg_ship_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	@self.use = train_use;
	train_use(self, other, activator);
}

void SP_misc_strogg_ship(ASEntity &ent)
{
	if (ent.target.empty())
	{
        gi_Com_Print("{} without a target\n", ent);
		G_FreeEdict(ent);
		return;
	}

	if (ent.speed == 0)
		ent.speed = 300;

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/ships/strogg1/tris.md2");
	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 32 };

	@ent.think = func_train_find;
	ent.nextthink = level.time + time_hz(10);
	@ent.use = misc_strogg_ship_use;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = ent.speed;

	gi_linkentity(ent.e);
}

/*QUAKED misc_satellite_dish (1 .5 0) (-64 -64 0) (64 64 128)
model="models/objects/satellite/tris.md2"
*/
void misc_satellite_dish_think(ASEntity &self)
{
	self.e.s.frame++;
	if (self.e.s.frame < 38)
		self.nextthink = level.time + time_hz(10);
}

void misc_satellite_dish_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.s.frame = 0;
	@self.think = misc_satellite_dish_think;
	self.nextthink = level.time + time_hz(10);
}

void SP_misc_satellite_dish(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::BBOX;
	ent.e.mins = { -64, -64, 0 };
	ent.e.maxs = { 64, 64, 128 };
	ent.e.s.modelindex = gi_modelindex("models/objects/satellite/tris.md2");
	@ent.use = misc_satellite_dish_use;
	gi_linkentity(ent.e);
}

/*QUAKED light_mine1 (0 1 0) (-2 -2 -12) (2 2 12)
 */
void SP_light_mine1(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.svflags = svflags_t::DEADMONSTER;
	ent.e.s.modelindex = gi_modelindex("models/objects/minelite/light1/tris.md2");
	gi_linkentity(ent.e);
}

/*QUAKED light_mine2 (0 1 0) (-2 -2 -12) (2 2 12)
 */
void SP_light_mine2(ASEntity &ent)
{
	ent.movetype = movetype_t::NONE;
	ent.e.solid = solid_t::NOT;
	ent.e.svflags = svflags_t::DEADMONSTER;
	ent.e.s.modelindex = gi_modelindex("models/objects/minelite/light2/tris.md2");
	gi_linkentity(ent.e);
}

/*QUAKED misc_gib_arm (1 0 0) (-8 -8 -8) (8 8 8)
Intended for use with the target_spawner
*/
void SP_misc_gib_arm(ASEntity &ent)
{
	gi_setmodel(ent.e, "models/objects/gibs/arm/tris.md2");
	ent.e.solid = solid_t::NOT;
	ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::GIB);
	ent.takedamage = true;
	@ent.die = gib_die;
	ent.movetype = movetype_t::TOSS;
	ent.deadflag = true;
	ent.avelocity.x = frandom(200);
	ent.avelocity.y = frandom(200);
	ent.avelocity.z = frandom(200);
	@ent.think = G_FreeEdict;
	ent.nextthink = level.time + time_sec(10);
	gi_linkentity(ent.e);
}

/*QUAKED misc_gib_leg (1 0 0) (-8 -8 -8) (8 8 8)
Intended for use with the target_spawner
*/
void SP_misc_gib_leg(ASEntity &ent)
{
	gi_setmodel(ent.e, "models/objects/gibs/leg/tris.md2");
	ent.e.solid = solid_t::NOT;
	ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::GIB);
	ent.takedamage = true;
	@ent.die = gib_die;
	ent.movetype = movetype_t::TOSS;
	ent.deadflag = true;
	ent.avelocity.x = frandom(200);
	ent.avelocity.y = frandom(200);
	ent.avelocity.z = frandom(200);
	@ent.think = G_FreeEdict;
	ent.nextthink = level.time + time_sec(10);
	gi_linkentity(ent.e);
}

/*QUAKED misc_gib_head (1 0 0) (-8 -8 -8) (8 8 8)
Intended for use with the target_spawner
*/
void SP_misc_gib_head(ASEntity &ent)
{
	gi_setmodel(ent.e, "models/objects/gibs/head/tris.md2");
	ent.e.solid = solid_t::NOT;
	ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::GIB);
	ent.takedamage = true;
	@ent.die = gib_die;
	ent.movetype = movetype_t::TOSS;
	ent.deadflag = true;
	ent.avelocity.x = frandom(200);
	ent.avelocity.y = frandom(200);
	ent.avelocity.z = frandom(200);
	@ent.think = G_FreeEdict;
	ent.nextthink = level.time + time_sec(10);
	gi_linkentity(ent.e);
}

//=====================================================

/*QUAKED target_character (0 0 1) ?
used with target_string (must be on same "team")
"count" is position in the string (starts at 1)
*/

void SP_target_character(ASEntity &self)
{
	self.movetype = movetype_t::PUSH;
	gi_setmodel(self.e, self.model);
	self.e.solid = solid_t::BSP;
	self.e.s.frame = 12;
	gi_linkentity(self.e);
	return;
}

/*QUAKED target_string (0 0 1) (-8 -8 -8) (8 8 8)
 */

void target_string_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @e;
	int		 n;
	uint	 l;
	uint8	 c;

	l = self.message.length();
	for (@e = self.teammaster; e !is null; @e = e.teamchain)
	{
		if (e.count == 0)
			continue;
		n = e.count - 1;
		if (uint(n) > l)
		{
			e.e.s.frame = 12;
			continue;
		}

		c = self.message[n];
		if (c >= '0' && c <= '9')
			e.e.s.frame = c - '0';
		else if (c == '-')
			e.e.s.frame = 10;
		else if (c == ':')
			e.e.s.frame = 11;
		else
			e.e.s.frame = 12;
	}
}

void SP_target_string(ASEntity &self)
{
	@self.use = target_string_use;
}

/*QUAKED func_clock (0 0 1) (-8 -8 -8) (8 8 8) TIMER_UP TIMER_DOWN START_OFF MULTI_USE
target a target_string with this

The default is to be a time of day clock

TIMER_UP and TIMER_DOWN run for "count" seconds and then fire "pathtarget"
If START_OFF, this entity must be used before it starts

"style"		0 "xx"
			1 "xx:xx"
			2 "xx:xx:xx"
*/
namespace spawnflags::timer
{
    const uint32 UP = 1;
    const uint32 DOWN = 2;
    const uint32 START_OFF = 4;
    const uint32 MULTI_USE = 8;
}

void func_clock_reset(ASEntity &self)
{
	@self.activator = null;

	if ((self.spawnflags & spawnflags::timer::UP) != 0)
	{
		self.health = 0;
		self.wait = float(self.count);
	}
	else if ((self.spawnflags & spawnflags::timer::DOWN) != 0)
	{
		self.health = self.count;
		self.wait = 0;
	}
}

void func_clock_format_countdown(ASEntity &self)
{
	if (self.style == 0)
	{
		self.clock_message = format("{:2}", self.health);
		return;
	}

	if (self.style == 1)
	{
		self.clock_message = format("{:2}:{:02}", self.health / 60, self.health % 60);
		return;
	}

	if (self.style == 2)
	{
		self.clock_message = format("{:2}:{:02}:{:02}", self.health / 3600,
					(self.health - (self.health / 3600) * 3600) / 60, self.health % 60);
		return;
	}
}

void func_clock_think(ASEntity &self)
{
	if (self.enemy is null)
	{
		@self.enemy = find_by_str<ASEntity>(null, "targetname", self.target);
		if (self.enemy is null)
			return;
	}

	if ((self.spawnflags & spawnflags::timer::UP) != 0)
	{
		func_clock_format_countdown(self);
		self.health++;
	}
	else if ((self.spawnflags & spawnflags::timer::DOWN) != 0)
	{
		func_clock_format_countdown(self);
		self.health--;
	}
	else
	{
        // AS_TODO: this is only in UTC. does this matter?
        // this feature is super niche
        datetime t;
		self.clock_message = format("{:2}:{:02}:{:02}", t.hour, t.minute, t.second);
	}

	self.enemy.message = self.clock_message;
	self.enemy.use(self.enemy, self, self);

	if (((self.spawnflags & spawnflags::timer::UP) != 0 && (self.health > self.wait)) ||
		((self.spawnflags & spawnflags::timer::DOWN) != 0 && (self.health < self.wait)))
	{
		if (!self.pathtarget.empty())
		{
			string savetarget;

			savetarget = self.target;
			self.target = self.pathtarget;
			G_UseTargets(self, self.activator);
			self.target = savetarget;
		}

		if ((self.spawnflags & spawnflags::timer::MULTI_USE) == 0)
			return;

		func_clock_reset(self);

		if ((self.spawnflags & spawnflags::timer::START_OFF) != 0)
			return;
	}

	self.nextthink = level.time + time_sec(1);
}

void func_clock_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if ((self.spawnflags & spawnflags::timer::MULTI_USE) == 0)
		@self.use = null;
	if (self.activator !is null)
		return;
	@self.activator = activator;
	self.think(self);
}

void SP_func_clock(ASEntity &self)
{
	if (self.target.empty())
	{
        gi_Com_Print("{} without a target\n", self);
		G_FreeEdict(self);
		return;
	}

	if ((self.spawnflags & spawnflags::timer::DOWN) != 0 && self.count == 0)
	{
        gi_Com_Print("{} without a target\n", self);
		G_FreeEdict(self);
		return;
	}

	if ((self.spawnflags & spawnflags::timer::UP) != 0 && (self.count == 0))
		self.count = 60 * 60;

	func_clock_reset(self);

	@self.think = func_clock_think;

	if ((self.spawnflags & spawnflags::timer::START_OFF) != 0)
		@self.use = func_clock_use;
	else
		self.nextthink = level.time + time_sec(1);
}

//=================================================================================

namespace spawnflags::teleporter
{
    const uint32 NO_SOUND = 1;
    const uint32 NO_TELEPORT_EFFECT = 2;
}

void teleporter_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @dest;

	if (other.client is null)
		return;
	@dest = find_by_str<ASEntity>(null, "targetname", self.target);
	if (dest is null)
	{
		gi_Com_Print("Couldn't find destination\n");
		return;
	}

	// ZOID
	CTFPlayerResetGrapple(other);
	// ZOID

	// unlink to make sure it can't possibly interfere with KillBox
	gi_unlinkentity(other.e);

	other.e.s.origin = dest.e.s.origin;
	other.e.s.old_origin = dest.e.s.origin;
	other.e.s.origin[2] += 10;

	// clear the velocity and hold them in place briefly
	other.velocity = vec3_origin;
	other.e.client.ps.pmove.pm_time = 160; // hold time
	other.e.client.ps.pmove.pm_flags = pmflags_t(other.e.client.ps.pmove.pm_flags | pmflags_t::TIME_TELEPORT);

	// draw the teleport splash at source and on the player
	if ((self.spawnflags & spawnflags::teleporter::NO_TELEPORT_EFFECT) == 0)
	{
		self.owner.e.s.event = entity_event_t::PLAYER_TELEPORT;
		other.e.s.event = entity_event_t::PLAYER_TELEPORT;
	}
	else
	{
		self.owner.e.s.event = entity_event_t::OTHER_TELEPORT;
		other.e.s.event = entity_event_t::OTHER_TELEPORT;
	}

	// set angles
	other.e.client.ps.pmove.delta_angles = dest.e.s.angles - other.client.resp.cmd_angles;

	other.e.s.angles = vec3_origin;
	other.e.client.ps.viewangles = vec3_origin;
	other.client.v_angle = vec3_origin;
	AngleVectors(other.client.v_angle, other.client.v_forward);

	gi_linkentity(other.e);

	// kill anything at the destination
	KillBox(other, other.client !is null);

	// [Paril-KEX] move sphere, if we own it
	if (other.client.owned_sphere !is null)
	{
		ASEntity @sphere = other.client.owned_sphere;
		sphere.e.s.origin = other.e.s.origin;
		sphere.e.s.origin[2] = other.e.absmax[2];
		sphere.e.s.angles.yaw = other.e.s.angles.yaw;
		gi_linkentity(sphere.e);
	}
}

/*QUAKED misc_teleporter (1 0 0) (-32 -32 -24) (32 32 -16) NO_SOUND NO_TELEPORT_EFFECT N64_EFFECT
Stepping onto this disc will teleport players to the targeted misc_teleporter_dest object.
*/
namespace spawnflags::teleporter
{
    const uint32 N64_EFFECT = 4;
}

void SP_misc_teleporter(ASEntity &ent)
{
	ASEntity @trig;

	gi_setmodel(ent.e, "models/objects/dmspot/tris.md2");
	ent.e.s.skinnum = 1;
	if (level.is_n64 || (ent.spawnflags & spawnflags::teleporter::N64_EFFECT) != 0)
		ent.e.s.effects = effects_t::TELEPORTER2;
	else
		ent.e.s.effects = effects_t::TELEPORTER;
	if ((ent.spawnflags & spawnflags::teleporter::NO_SOUND) == 0)
		ent.e.s.sound = gi_soundindex("world/amb10.wav");
	ent.e.solid = solid_t::BBOX;

	ent.e.mins = { -32, -32, -24 };
	ent.e.maxs = { 32, 32, -16 };
	gi_linkentity(ent.e);
	
	// N64 has some of these for visual effects
	if (ent.target.empty())
		return;

	@trig = G_Spawn();
	@trig.touch = teleporter_touch;
	trig.e.solid = solid_t::TRIGGER;
	trig.target = ent.target;
	@trig.owner = ent;
	trig.e.s.origin = ent.e.s.origin;
	trig.e.mins = { -8, -8, 8 };
	trig.e.maxs = { 8, 8, 24 };
	gi_linkentity(trig.e);
}

/*QUAKED misc_teleporter_dest (1 0 0) (-32 -32 -24) (32 32 -16)
Point teleporters at these.
*/
void SP_misc_teleporter_dest(ASEntity &ent)
{
	// Paril-KEX N64 doesn't display these
	if (level.is_n64)
		return;

	gi_setmodel(ent.e, "models/objects/dmspot/tris.md2");
	ent.e.s.skinnum = 0;
	ent.e.solid = solid_t::BBOX;
	//	ent.s.effects |= EF_FLIES;
	ent.e.mins = { -32, -32, -24 };
	ent.e.maxs = { 32, 32, -16 };
	gi_linkentity(ent.e);
}

/*QUAKED misc_flare (1.0 1.0 0.0) (-32 -32 -32) (32 32 32) RED GREEN BLUE LOCK_ANGLE
Creates a flare seen in the N64 version.
*/
namespace spawnflags::flare
{
    const uint32 RED			= 1;
    const uint32 GREEN		= 2;
    const uint32 BLUE			= 4;
    const uint32 LOCK_ANGLE	= 8;
}

void misc_flare_use(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	ent.e.svflags = svflags_t(ent.e.svflags ^ svflags_t::NOCLIENT);
	gi_linkentity(ent.e);
}

void SP_misc_flare(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	ent.e.s.modelindex = 1;
	ent.e.s.renderfx = renderfx_t::FLARE;
	ent.e.solid = solid_t::NOT;
    ent.e.s.scale = st.radius;

	if ((ent.spawnflags & spawnflags::flare::RED) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_RED);

	if ((ent.spawnflags & spawnflags::flare::GREEN) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_GREEN);

	if ((ent.spawnflags & spawnflags::flare::BLUE) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_BLUE);

	if ((ent.spawnflags & spawnflags::flare::LOCK_ANGLE) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::FLARE_LOCK_ANGLE);

	if (!st.image.empty())
	{
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::CUSTOMSKIN);
		ent.e.s.frame = gi_imageindex(st.image);
	}

    ent.e.mins = { -32, -32, -32 };
    ent.e.maxs = { 32, 32, 32 };

	ent.e.s.modelindex2 = st.fade_start_dist;
	ent.e.s.modelindex3 = st.fade_end_dist;

	if (!ent.targetname.empty())
		@ent.use = misc_flare_use;

    gi_linkentity(ent.e);
}

void misc_hologram_think(ASEntity &ent)
{
	ent.e.s.angles[1] += 100 * gi_frame_time_s;
	ent.nextthink = level.time + FRAME_TIME_MS;
	ent.e.s.alpha = frandom(0.2f, 0.6f);
}

/*QUAKED misc_hologram (1.0 1.0 0.0) (-16 -16 0) (16 16 32)
Ship hologram seen in the N64 version.
*/
void SP_misc_hologram(ASEntity &ent)
{
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/ships/strogg1/tris.md2");
	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 32 };
	ent.e.s.effects = effects_t::HOLOGRAM;
	@ent.think = misc_hologram_think;
	ent.nextthink = level.time + FRAME_TIME_MS;
	ent.e.s.alpha = frandom(0.2f, 0.6f);
	ent.e.s.scale = 0.75f;
	gi_linkentity(ent.e);
}


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8) NO_EXPLODE
Lava Balls. Shamelessly copied from Quake 1, like N64 guys
probably did too.
*/
namespace spawnflags::lavaball
{
    const uint32 NO_EXPLODE = 1;
}

void fire_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if ((self.spawnflags & spawnflags::lavaball::NO_EXPLODE) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (other.takedamage)
		T_Damage (other, self, self, vec3_origin, self.e.s.origin, vec3_origin, 20, 0, damageflags_t::NONE, mod_id_t::EXPLOSIVE);

	if ((gi_pointcontents(self.e.s.origin) & contents_t::LAVA) != 0)
		G_FreeEdict(self);
	else
		BecomeExplosion1(self);
}

void fire_fly(ASEntity &self)
{
	ASEntity @fireball = G_Spawn();
	fireball.e.s.effects = effects_t::FIREBALL;
	fireball.e.s.renderfx = renderfx_t::MINLIGHT;
	fireball.e.solid = solid_t::BBOX;
	fireball.movetype = movetype_t::TOSS;
	fireball.e.clipmask = contents_t::MASK_SHOT;
	fireball.velocity.x = crandom() * 50;
	fireball.velocity.y = crandom() * 50;
	fireball.avelocity = { crandom() * 360, crandom() * 360, crandom() * 360 };
	fireball.velocity.z = (self.speed * 1.75f) + (frandom() * 200);
	fireball.classname = "fireball";
	gi_setmodel(fireball.e, "models/objects/gibs/sm_meat/tris.md2");
	fireball.e.s.origin = self.e.s.origin;
	fireball.nextthink = level.time + time_sec(5);
	@fireball.think = G_FreeEdict;
	@fireball.touch = fire_touch;
	fireball.spawnflags = self.spawnflags;
	gi_linkentity(fireball.e);
	self.nextthink = level.time + random_time(time_sec(5));
}

void SP_misc_lavaball(ASEntity &self)
{
	self.classname = "fireball";
	self.nextthink = level.time + random_time(time_sec(5));
	@self.think = fire_fly;
	if (self.speed == 0)
		self.speed = 185;
}

namespace spawnflags::landmark
{
    const uint32 KEEP_Z = 1;
}

void SP_info_landmark(ASEntity &self)
{
	self.e.absmin = self.e.s.origin;
	self.e.absmax = self.e.s.origin;
}

namespace spawnflags::world_text
{
    const uint32 START_OFF = 1;
    const uint32 TRIGGER_ONCE = 2;
    const uint32 REMOVE_ON_TRIGGER = 4;
}

void info_world_text_use ( ASEntity & self, ASEntity & other, ASEntity @ activator ) {
	if ( self.activator is null ) {
		@self.activator = activator;
		self.think( self );
	} else {
		self.nextthink = time_zero;
		@self.activator = null;
	}

	if ((self.spawnflags & spawnflags::world_text::TRIGGER_ONCE) != 0) {
		@self.use = null;
	}

	if ( !self.target.empty() ) {
		ASEntity @ target = G_PickTarget( self.target );
		if ( target !is null && target.e.inuse ) {
			if ( target.use !is null ) {
				target.use( target, self, self );
			}
		}
	}

	if ((self.spawnflags & spawnflags::world_text::REMOVE_ON_TRIGGER) != 0) {
		G_FreeEdict( self );
	}
}

void info_world_text_think ( ASEntity & self ) {
	rgba_t color = rgba_white;

	switch ( self.sounds ) {
		case 0:
			color = rgba_white;
			break;

		case 1:
			color = rgba_red;
			break;

		case 2:
			color = rgba_blue;
			break;

		case 3:
			color = rgba_green;
			break;

		case 4:
			color = rgba_yellow;
			break;

		case 5:
			color = rgba_black;
			break;

		case 6:
			color = rgba_cyan;
			break;

		case 7:
			color = rgba_orange;
			break;

		default:
			color = rgba_white;
			gi_Com_Print( "{}: invalid color\n", self);
			break;
	}

	if ( self.e.s.angles.yaw == -3.0f ) {
		gi_Draw_OrientedWorldText( self.e.s.origin, self.message, color, self.e.size[ 2 ], FRAME_TIME_MS.secondsf(), true );
	} else {
		vec3_t textAngle = { 0.0f, 0.0f, 0.0f };
		textAngle.yaw = anglemod( self.e.s.angles.yaw ) + 180;
		if ( textAngle.yaw > 360.0f ) {
			textAngle.yaw -= 360.0f;
		}
		gi_Draw_StaticWorldText( self.e.s.origin, textAngle, self.message, color, self.e.size[2], FRAME_TIME_MS.secondsf(), true );
	}
	self.nextthink = level.time + FRAME_TIME_MS;
}

/*QUAKED info_world_text (1.0 1.0 0.0) (-16 -16 0) (16 16 32)
designer placed in world text for debugging.
*/
void SP_info_world_text( ASEntity & self ) {
	if ( self.message.empty() ) {
		gi_Com_Print( "{}: no message\n", self);
		G_FreeEdict( self );
		return;
	} // not much point without something to print...

	const spawn_temp_t @st = ED_GetSpawnTemp();

	@self.think = info_world_text_think;
	@self.use = info_world_text_use;
	self.e.size[ 2 ] = st.radius != 0 ? st.radius : 0.2f;

	if ( ( self.spawnflags & spawnflags::world_text::START_OFF ) == 0 ) {
		self.nextthink = level.time + FRAME_TIME_MS;
		@self.activator = self;
	}
}

void misc_player_mannequin_use ( ASEntity & self, ASEntity & other, ASEntity @ activator ) {
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::TARGET_ANGER);
	@self.enemy = activator;

	switch ( self.count ) {
		case gesture_type_t::FLIP_OFF:
			self.e.s.frame = player::frames::flip01;
			self.monsterinfo.nextframe = player::frames::flip12;
			break;

		case gesture_type_t::SALUTE:
			self.e.s.frame = player::frames::salute01;
			self.monsterinfo.nextframe = player::frames::salute11;
			break;

		case gesture_type_t::TAUNT:
			self.e.s.frame = player::frames::taunt01;
			self.monsterinfo.nextframe = player::frames::taunt17;
			break;

		case gesture_type_t::WAVE:
			self.e.s.frame = player::frames::wave01;
			self.monsterinfo.nextframe = player::frames::wave11;
			break;

		case gesture_type_t::POINT:
			self.e.s.frame = player::frames::point01;
			self.monsterinfo.nextframe = player::frames::point12;
			break;
	}
}

void misc_player_mannequin_think ( ASEntity & self ) {
	if ( self.teleport_time <= level.time ) {
		self.e.s.frame++;

		if ( ( self.monsterinfo.aiflags & ai_flags_t::TARGET_ANGER ) == 0 ) {
			if ( self.e.s.frame > player::frames::stand40 ) {
				self.e.s.frame = player::frames::stand01;
			}
		} else {
			if ( self.e.s.frame > self.monsterinfo.nextframe ) {
				self.e.s.frame = player::frames::stand01;
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TARGET_ANGER);
				@self.enemy = null;
			}
		}

		self.teleport_time = level.time + time_hz(10);
	}

	if ( self.enemy !is null ) {
		const vec3_t vec = ( self.enemy.e.s.origin - self.e.s.origin );
		self.ideal_yaw = vectoyaw( vec );
		M_ChangeYaw( self );
	}

	self.nextthink = level.time + FRAME_TIME_MS;
}

void SetupMannequinModel( ASEntity & self, const int modelType, const string &in weapon, const string &in skin ) {
	string modelName;
	string defaultSkin;

	switch ( modelType ) {
		case 1: {
			self.e.s.skinnum = ( MAX_CLIENTS - 1 );
			modelName = "female";
			defaultSkin = "venus";
			break;
		}

		case 2: {
			self.e.s.skinnum = ( MAX_CLIENTS - 2 );
			modelName = "male";
			defaultSkin = "rampage";
			break;
		}

		case 3: {
			self.e.s.skinnum = ( MAX_CLIENTS - 3 );
			modelName = "cyborg";
			defaultSkin = "oni911";
			break;
		}

		default: {
			self.e.s.skinnum = ( MAX_CLIENTS - 1 );
			modelName = "female";
			defaultSkin = "venus";
			break;
		}
	}

	if ( !modelName.empty() ) {
		self.model = format( "players/{}/tris.md2", modelName );

		string weaponName;
		if ( !weapon.empty() ) {
			weaponName = format( "players/{}/{}.md2", modelName, weapon );
		} else {
			weaponName = format( "players/{}/{}.md2", modelName, "w_hyperblaster" );
		}
		self.e.s.modelindex2 = gi_modelindex( weaponName );

		string skinName;
		if ( !skin.empty() ) {
			skinName = format( "mannequin\\{}/{}", modelName, skin );
		} else {
			skinName = format( "mannequin\\{}/{}", modelName, defaultSkin );
		}
		gi_configstring( configstring_id_t::PLAYERSKINS + self.e.s.skinnum, skinName );
	}
}

/*QUAKED misc_player_mannequin (1.0 1.0 0.0) (-32 -32 -32) (32 32 32)
	Creates a player mannequin that stands around.

	NOTE: this is currently very limited, and only allows one unique model
	from each of the three player model types.

 "distance"		- Sets the type of gesture mannequin when use when triggered
 "height"		- Sets the type of model to use ( valid numbers: 1 - 3 )
 "goals"		- Name of the weapon to use.
 "image"		- Name of the player skin to use.
 "radius"		- How much to scale the model in-game
*/
void SP_misc_player_mannequin( ASEntity & self ) {
	const spawn_temp_t @st = ED_GetSpawnTemp();

	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::BBOX;
	if (!st.was_key_specified("effects"))
		self.e.s.effects = effects_t::NONE;
	if (!st.was_key_specified("renderfx"))
		self.e.s.renderfx = renderfx_t::MINLIGHT;
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 32 };
	self.yaw_speed = 30;
	self.ideal_yaw = 0;
	self.teleport_time = level.time + time_hz(10);
	self.e.s.modelindex = MODELINDEX_PLAYER;
	self.count = int(st.distance);

	SetupMannequinModel( self, int(st.height), st.goals, st.image );

	self.e.s.scale = 1.0f;
	if ( ai_model_scale.value > 0.0f ) {
		self.e.s.scale = ai_model_scale.value;
	} else if ( st.radius > 0.0f ) {
		self.e.s.scale = st.radius;
	}

	self.e.mins *= self.e.s.scale;
	self.e.maxs *= self.e.s.scale;

	@self.think = misc_player_mannequin_think;
	self.nextthink = level.time + FRAME_TIME_MS;

	if ( !self.targetname.empty() ) {
		@self.use = misc_player_mannequin_use;
	}

	gi_linkentity( self.e );
}

namespace spawnflags::model
{
    const uint32 TOGGLE = 1;
    const uint32 START_ON = 2;
}

void misc_model_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.svflags = svflags_t(self.e.svflags ^ svflags_t::NOCLIENT);
}

/*QUAKED misc_model (1 0 0) (-8 -8 -8) (8 8 8)
*/
void SP_misc_model(ASEntity &ent)
{
	if (!ent.model.empty())
		gi_setmodel(ent.e, ent.model);

	if ((ent.spawnflags & spawnflags::model::TOGGLE) != 0)
	{
		@ent.use = misc_model_use;

		if ((ent.spawnflags & spawnflags::model::START_ON) == 0)
			ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	}

	gi_linkentity(ent.e);
}