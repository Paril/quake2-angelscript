
//==========================================================

/*QUAKED target_steam (1 0 0) (-8 -8 -8) (8 8 8)
Creates a steam effect (particles w/ velocity in a line).

  speed = velocity of particles (default 50)
  count = number of particles (default 32)
  sounds = color of particles (default 8 for steam)
	 the color range is from this color to this color + 6
  wait = seconds to run before stopping (overrides default
	 value derived from func_timer)

  best way to use this is to tie it to a func_timer that "pokes"
  it every second (or however long you set the wait time, above)

  note that the width of the base is proportional to the speed
  good colors to use:
  6-9 - varying whites (darker to brighter)
  224 - sparks
  176 - blue water
  80  - brown water
  208 - slime
  232 - blood
*/

// FIXME - this needs to be a global
namespace internal
{
    int16 nextid_steamid;
}

void use_target_steam(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	vec3_t	   point;

	internal::nextid_steamid = (internal::nextid_steamid % 20000) + 1;

	// automagically set wait from func_timer unless they set it already, or
	// default to 1000 if not called by a func_timer (eek!)
	if (self.wait == 0)
	{
		if (other !is null)
			self.wait = other.wait * 1000;
		else
			self.wait = 1000;
	}

	if (self.enemy !is null)
	{
		point = (self.enemy.e.absmin + self.enemy.e.absmax) * 0.5f;
		self.movedir = point - self.e.s.origin;
		self.movedir.normalize();
	}

	point = self.e.s.origin + (self.movedir * (self.style * 0.5f));
	if (self.wait > 100)
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::STEAM);
		gi_WriteShort(internal::nextid_steamid);
		gi_WriteByte(self.count);
		gi_WritePosition(self.e.s.origin);
		gi_WriteDir(self.movedir);
		gi_WriteByte(self.sounds & 0xff);
		gi_WriteShort(self.style);
		gi_WriteLong(int(self.wait));
		gi_multicast(self.e.s.origin, multicast_t::PVS, false);
	}
	else
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::STEAM);
		gi_WriteShort(-1);
		gi_WriteByte(self.count);
		gi_WritePosition(self.e.s.origin);
		gi_WriteDir(self.movedir);
		gi_WriteByte(self.sounds & 0xff);
		gi_WriteShort(self.style);
		gi_multicast(self.e.s.origin, multicast_t::PVS, false);
	}
}

void target_steam_start(ASEntity &self)
{
	ASEntity @ent;

	@self.use = use_target_steam;

	if (!self.target.empty())
	{
		@ent = find_by_str<ASEntity>(null, "targetname", self.target);
		if (ent is null)
			gi_Com_Print("{}: target {} not found\n", self, self.target);
		@self.enemy = ent;
	}
	else
	{
		G_SetMovedir(self, self.movedir);
	}

	if (self.count == 0)
		self.count = 32;
	if (self.style == 0)
		self.style = 75;
	if (self.sounds == 0)
		self.sounds = 8;
	if (self.wait != 0)
		self.wait *= 1000; // we want it in milliseconds, not seconds

	// paranoia is good
	self.sounds &= 0xff;
	self.count &= 0xff;

	self.e.svflags = svflags_t::NOCLIENT;

	gi_linkentity(self.e);
}

void SP_target_steam(ASEntity &self)
{
	self.style = int(self.speed);

	if (!self.target.empty())
	{
		@self.think = target_steam_start;
		self.nextthink = level.time + time_sec(1);
	}
	else
		target_steam_start(self);
}

//==========================================================
// target_anger
//==========================================================

void target_anger_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @target, t;

	@t = null;
	@target = find_by_str<ASEntity>(t, "targetname", self.killtarget);

	if (target !is null && !self.target.empty())
	{
		// Make whatever a "good guy" so the monster will try to kill it!
		if ((target.e.svflags & svflags_t::MONSTER) == 0)
		{
			target.monsterinfo.aiflags = ai_flags_t(target.monsterinfo.aiflags | ai_flags_t::GOOD_GUY | ai_flags_t::DO_NOT_COUNT);
			target.e.svflags = svflags_t(target.e.svflags | svflags_t::MONSTER);
			target.health = 300;
		}

		@t = null;
		while ((@t = find_by_str<ASEntity>(t, "targetname", self.target)) !is null)
		{
			if (t is self)
			{
				gi_Com_Print("WARNING: entity used itself.\n");
			}
			else
			{
				if (t.use !is null)
				{
					if (t.health <= 0)
						return;

					@t.enemy = target;
					t.monsterinfo.aiflags = ai_flags_t(t.monsterinfo.aiflags | ai_flags_t::TARGET_ANGER);
					FoundTarget(t);
				}
			}
			if (!self.e.inuse)
			{
				gi_Com_Print("entity was removed while using targets\n");
				return;
			}
		}
	}
}

/*QUAKED target_anger (1 0 0) (-8 -8 -8) (8 8 8)
This trigger will cause an entity to be angry at another entity when a player touches it. Target the
entity you want to anger, and killtarget the entity you want it to be angry at.

target - entity to piss off
killtarget - entity to be pissed off at
*/
void SP_target_anger(ASEntity &self)
{
	if (self.target.empty())
	{
		gi_Com_Print("target_anger without target!\n");
		G_FreeEdict(self);
		return;
	}
	if (self.killtarget.empty())
	{
		gi_Com_Print("target_anger without killtarget!\n");
		G_FreeEdict(self);
		return;
	}

	@self.use = target_anger_use;
	self.e.svflags = svflags_t::NOCLIENT;
}

// ***********************************
// target_killplayers
// ***********************************

void target_killplayers_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	level.deadly_kill_box = true;

	ASEntity @ent, player;

	// kill any visible monsters
	for (uint i = max_clients + 1 + BODY_QUEUE_SIZE; i < num_edicts; i++)
	{
        @ent = entities[i];

		if (!ent.e.inuse)
			continue;
		if (ent.health < 1)
			continue;
		if (!ent.takedamage)
			continue;

		for (uint p = 0; p < max_clients; p++)
		{
			@player = players[p];
			if (!player.e.inuse)
				continue;

			if (gi_inPVS(player.e.s.origin, ent.e.s.origin, false))
			{
				T_Damage(ent, self, self, vec3_origin, ent.e.s.origin, vec3_origin,
					ent.health, 0, damageflags_t::NO_PROTECTION, mod_id_t::TELEFRAG);
				break;
			}
		}
	}

	// kill the players
	for (uint i = 0; i < max_clients; i++)
	{
		@player = players[i];
		if (!player.e.inuse)
			continue;

		// nail it
		T_Damage(player, self, self, vec3_origin, self.e.s.origin, vec3_origin, 100000, 0, damageflags_t::NO_PROTECTION, mod_id_t::TELEFRAG);
	}

	level.deadly_kill_box = false;
}

/*QUAKED target_killplayers (1 0 0) (-8 -8 -8) (8 8 8)
When triggered, this will kill all the players on the map.
*/
void SP_target_killplayers(ASEntity &self)
{
	@self.use = target_killplayers_use;
	self.e.svflags = svflags_t::NOCLIENT;
}

/*QUAKED target_blacklight (1 0 1) (-16 -16 -24) (16 16 24)
Pulsing black light with sphere in the center
*/
void blacklight_think(ASEntity &self)
{
	self.e.s.angles[0] += frandom(10);
	self.e.s.angles[1] += frandom(10);
	self.e.s.angles[2] += frandom(10);
	self.nextthink = level.time + FRAME_TIME_MS;
}

void SP_target_blacklight(ASEntity &ent)
{
	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	ent.e.mins = vec3_origin;
	ent.e.maxs = vec3_origin;

	ent.e.s.effects = effects_t(ent.e.s.effects | (effects_t::TRACKERTRAIL | effects_t::TRACKER));
	@ent.think = blacklight_think;
	ent.e.s.modelindex = gi_modelindex("models/items/spawngro3/tris.md2");
	ent.e.s.scale = 6.f;
	ent.e.s.skinnum = 0;
	ent.nextthink = level.time + FRAME_TIME_MS;
	gi_linkentity(ent.e);
}

/*QUAKED target_orb (1 0 1) (-16 -16 -24) (16 16 24)
Translucent pulsing orb with speckles
*/
void SP_target_orb(ASEntity &ent)
{
	if (deathmatch.integer != 0)
	{ // auto-remove for deathmatch
		G_FreeEdict(ent);
		return;
	}

	ent.e.mins = vec3_origin;
	ent.e.maxs = vec3_origin;

	//	ent.s.effects |= EF_TRACKERTRAIL;
	@ent.think = blacklight_think;
	ent.nextthink = level.time + time_hz(10);
	ent.e.s.skinnum = 1;
	ent.e.s.modelindex = gi_modelindex("models/items/spawngro3/tris.md2");
	ent.e.s.frame = 2;
	ent.e.s.scale = 8.f;
	ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::SPHERETRANS);
	gi_linkentity(ent.e);
}
