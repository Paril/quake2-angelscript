namespace spawnflags::trigger
{
// PGM - some of these are mine, some id's. I added the define's.
    const spawnflags_t MONSTER = spawnflag_dec(0x01);
    const spawnflags_t NOT_PLAYER = spawnflag_dec(0x02);
    const spawnflags_t TRIGGERED = spawnflag_dec(0x04);
    const spawnflags_t TOGGLE = spawnflag_dec(0x08);
    const spawnflags_t LATCHED = spawnflag_dec(0x10);
    const spawnflags_t CLIP = spawnflag_dec(0x20);
// PGM
}

void InitTrigger(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (st.was_key_specified("angle") || st.was_key_specified("angles") || bool(self.e.s.angles))
		G_SetMovedir(self, self.movedir);

	self.e.solid = solid_t::TRIGGER;
	self.movetype = movetype_t::NONE;
	// [Paril-KEX] adjusted to allow mins/maxs to be defined
	// by hand instead
	if (!self.model.empty())
		gi_setmodel(self.e, self.model);
	self.e.svflags = svflags_t::NOCLIENT;
}

// the wait time has passed, so set back up for another activation
void multi_wait(ASEntity &ent)
{
	ent.nextthink = time_zero;
}

// the trigger was just activated
// ent->activator should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void multi_trigger(ASEntity &ent)
{
	if (ent.nextthink)
		return; // already been triggered

	G_UseTargets(ent, ent.activator);

	if (ent.wait > 0)
	{
		@ent.think = multi_wait;
		ent.nextthink = level.time + time_sec(ent.wait);
	}
	else
	{ // we can't just remove (self) here, because this is a touch function
		// called while looping through area links...
		@ent.touch = null;
		ent.nextthink = level.time + FRAME_TIME_S;
		@ent.think = G_FreeEdict;
	}
}

void Use_Multi(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	// PGM
	if (ent.spawnflags.has(spawnflags::trigger::TOGGLE))
	{
		if (ent.e.solid == solid_t::TRIGGER)
			ent.e.solid = solid_t::NOT;
		else
			ent.e.solid = solid_t::TRIGGER;
		gi_linkentity(ent.e);
	}
	else
	{
		@ent.activator = activator;
		multi_trigger(ent);
	}
	// PGM
}

void Touch_Multi(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client !is null)
	{
		if (self.spawnflags.has(spawnflags::trigger::NOT_PLAYER))
			return;
	}
	else if ((other.e.svflags & svflags_t::MONSTER) != 0)
	{
		if (!self.spawnflags.has(spawnflags::trigger::MONSTER))
			return;
	}
	else
		return;

	if (self.spawnflags.has(spawnflags::trigger::CLIP))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	if (self.movedir)
	{
		vec3_t forward;

		AngleVectors(other.e.s.angles, forward);
		if (forward.dot(self.movedir) < 0)
			return;
	}

	@self.activator = other;
	multi_trigger(self);
}

/*QUAKED trigger_multiple (.5 .5 .5) ? MONSTER NOT_PLAYER TRIGGERED TOGGLE LATCHED
Variable sized repeatable trigger.  Must be targeted at one or more entities.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)

TOGGLE - using this trigger will activate/deactivate it. trigger will begin inactive.

sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void trigger_enable(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	self.e.solid = solid_t::TRIGGER;
	@self.use = Use_Multi;
	gi_linkentity(self.e);
}

BoxEdictsResult_t latched_trigger_filter(edict_t @ent, any @const data)
{
	ASEntity @other = entities[ent.s.number];
	ASEntity @self;
    data.retrieve(@self);

	if (other.client !is null)
	{
		if (self.spawnflags.has(spawnflags::trigger::NOT_PLAYER))
			return BoxEdictsResult_t::Skip;
	}
	else if ((other.e.svflags & svflags_t::MONSTER) != 0)
	{
		if (!self.spawnflags.has(spawnflags::trigger::MONSTER))
			return BoxEdictsResult_t::Skip;
	}
	else
		return BoxEdictsResult_t::Skip;

	if (self.movedir)
	{
		vec3_t forward;

		AngleVectors(other.e.s.angles, forward);
		if (forward.dot(self.movedir) < 0)
			return BoxEdictsResult_t::Skip;
	}

	@self.activator = other;
	return BoxEdictsResult_t(BoxEdictsResult_t::Keep | BoxEdictsResult_t::End);
}

void latched_trigger_think(ASEntity &self)
{
	self.nextthink = level.time + time_ms(1);

	bool any_inside = gi_BoxEdicts(self.e.absmin, self.e.absmax, null, 0, solidity_area_t::SOLID, latched_trigger_filter, any(@self), false) != 0;

	if ((self.count != 0) != any_inside)
	{
		G_UseTargets(self, self.activator);
		self.count = any_inside ? 1 : 0;
	}
}

void SP_trigger_multiple(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	// [Paril-KEX] PSX
	if (!st.noise.empty())
		ent.noise_index = gi_soundindex(st.noise);
	else if (ent.sounds == 1)
		ent.noise_index = gi_soundindex("misc/secret.wav");
	else if (ent.sounds == 2)
		ent.noise_index = gi_soundindex("misc/talk.wav");
	else if (ent.sounds == 3)
		ent.noise_index = gi_soundindex("misc/trigger1.wav");

	if (ent.wait == 0)
		ent.wait = 0.2f;

	InitTrigger(ent);

	if (ent.spawnflags.has(spawnflags::trigger::LATCHED))
	{
		if (ent.spawnflags.has(spawnflags::trigger::TRIGGERED | spawnflags::trigger::TOGGLE))
			gi_Com_Print("{}: latched and triggered/toggle are not supported\n", ent);

		@ent.think = latched_trigger_think;
		ent.nextthink = level.time + time_ms(1);
		@ent.use = Use_Multi;
		return;
	}
	else if (!ent.model.empty() || bool(ent.e.mins) || bool(ent.e.maxs))
		@ent.touch = Touch_Multi;

	// PGM
	if (ent.spawnflags.has(spawnflags::trigger::TRIGGERED | spawnflags::trigger::TOGGLE))
	// PGM
	{
		ent.e.solid = solid_t::NOT;
		@ent.use = trigger_enable;
	}
	else
	{
		ent.e.solid = solid_t::TRIGGER;
		@ent.use = Use_Multi;
	}

	gi_linkentity(ent.e);

	if (ent.spawnflags.has(spawnflags::trigger::CLIP))
		ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::HULL);
}

/*QUAKED trigger_once (.5 .5 .5) ? x x TRIGGERED
Triggers once, then removes itself.
You must set the key "target" to the name of another object in the level that has a matching "targetname".

If TRIGGERED, this trigger must be triggered before it is live.

sounds
 1)	secret
 2)	beep beep
 3)	large switch
 4)

"message"	string to be displayed when triggered
*/

void SP_trigger_once(ASEntity &ent)
{
	// make old maps work because I messed up on flag assignments here
	// triggered was on bit 1 when it should have been on bit 4
	if (ent.spawnflags.has(spawnflags::trigger::MONSTER))
	{
		ent.spawnflags &= ~spawnflags::trigger::MONSTER;
		ent.spawnflags |= spawnflags::trigger::TRIGGERED;
		gi_Com_Print("{}: fixed TRIGGERED flag\n", ent);
	}

	ent.wait = -1;
	SP_trigger_multiple(ent);
}

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.
*/
namespace spawnflags::trigger_relay
{
    const spawnflags_t NO_SOUND = spawnflag_dec(1);
}

void trigger_relay_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.crosslevel_flags != 0 && !(self.crosslevel_flags == (game.cross_level_flags & SFL_CROSS_TRIGGER_MASK & self.crosslevel_flags)))
		return;

	G_UseTargets(self, activator);
}

void SP_trigger_relay(ASEntity &self)
{
	@self.use = trigger_relay_use;

	if (self.spawnflags.has(spawnflags::trigger_relay::NO_SOUND))
		self.noise_index = -1;
}

/*
==============================================================================

trigger_key

==============================================================================
*/

namespace spawnflags::trigger_key
{
    const spawnflags_t BECOME_RELAY = spawnflag_dec(1);
}

/*QUAKED trigger_key (.5 .5 .5) (-8 -8 -8) (8 8 8)
A relay trigger that only fires it's targets if player has the proper key.
Use "item" to specify the required key, for example "key_data_cd"
*/
void trigger_key_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	item_id_t index;

	if (self.item is null)
		return;
	if (activator is null || activator.client is null)
		return;

	index = self.item.id;
	if (activator.client.pers.inventory[index] == 0)
	{
		if (level.time < self.touch_debounce_time)
			return;
		self.touch_debounce_time = level.time + time_sec(5);
		gi_LocCenter_Print(activator.e, "$g_you_need", self.item.pickup_name_definite);
		gi_sound(activator.e, soundchan_t::AUTO, gi_soundindex("misc/keytry.wav"), 1, ATTN_NORM, 0);
		return;
	}

	gi_sound(activator.e, soundchan_t::AUTO, gi_soundindex("misc/keyuse.wav"), 1, ATTN_NORM, 0);
	if (coop.integer != 0)
	{
		ASEntity @ent;

		if (self.item.id == item_id_t::KEY_POWER_CUBE || self.item.id == item_id_t::KEY_EXPLOSIVE_CHARGES)
		{
			int cube;

			for (cube = 0; cube < 8; cube++)
				if ((activator.client.pers.power_cubes & (1 << cube)) != 0)
					break;
			for (uint32 player = 1; player <= max_clients; player++)
			{
				@ent = entities[player];
				if (!ent.e.inuse)
					continue;
				if (ent.client is null)
					continue;
				if ((ent.client.pers.power_cubes & (1 << cube)) != 0)
				{
					ent.client.pers.inventory[index]--;
					ent.client.pers.power_cubes &= ~(1 << cube);

					// [Paril-KEX] don't allow respawning players to keep
					// used keys
					if (!P_UseCoopInstancedItems())
					{
						ent.client.resp.coop_respawn.inventory[index] = 0;
						ent.client.resp.coop_respawn.power_cubes &= ~(1 << cube);
					}
				}
			}
		}
		else
		{
			for (uint32 player = 1; player <= max_clients; player++)
			{
				@ent = entities[player];
				if (!ent.e.inuse)
					continue;
				if (ent.client is null)
					continue;
				ent.client.pers.inventory[index] = 0;

				// [Paril-KEX] don't allow respawning players to keep
				// used keys
				if (!P_UseCoopInstancedItems())
					ent.client.resp.coop_respawn.inventory[index] = 0;
			}
		}
	}
	else
	{
		activator.client.pers.inventory[index]--;
	}

	G_UseTargets(self, activator);

	if (self.spawnflags.has(spawnflags::trigger_key::BECOME_RELAY))
		@self.use = trigger_relay_use;
	else
		@self.use = null;
}

void SP_trigger_key(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (st.item.empty())
	{
		gi_Com_Print("{}: no key item\n", self);
		return;
	}
	@self.item = FindItemByClassname(st.item);

	if (self.item is null)
	{
		gi_Com_Print("{}: item {} not found\n", self, st.item);
		return;
	}

	if (self.target.empty())
	{
		gi_Com_Print("{}: no target\n", self);
		return;
	}

	gi_soundindex("misc/keytry.wav");
	gi_soundindex("misc/keyuse.wav");

	@self.use = trigger_key_use;
}

/*
==============================================================================

trigger_counter

==============================================================================
*/

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/

namespace spawnflags::counter
{
    const spawnflags_t NOMESSAGE = spawnflag_dec(1);
}

void trigger_counter_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.count == 0)
		return;

	self.count--;

	if (self.count != 0)
	{
		if (!self.spawnflags.has(spawnflags::counter::NOMESSAGE))
		{
			gi_LocCenter_Print(activator.e, "$g_more_to_go", self.count);
			gi_sound(activator.e, soundchan_t::AUTO, gi_soundindex("misc/talk1.wav"), 1, ATTN_NORM, 0);
		}
		return;
	}

	if (!self.spawnflags.has(spawnflags::counter::NOMESSAGE))
	{
		gi_LocCenter_Print(activator.e, "$g_sequence_completed");
		gi_sound(activator.e, soundchan_t::AUTO, gi_soundindex("misc/talk1.wav"), 1, ATTN_NORM, 0);
	}
	@self.activator = activator;
	multi_trigger(self);
}

void SP_trigger_counter(ASEntity &self)
{
	self.wait = -1;
	if (self.count == 0)
		self.count = 2;

	@self.use = trigger_counter_use;
}

/*
==============================================================================

trigger_always

==============================================================================
*/

/*QUAKED trigger_always (.5 .5 .5) (-8 -8 -8) (8 8 8)
This trigger will always fire.  It is activated by the world.
*/
void SP_trigger_always(ASEntity &ent)
{
	// we must have some delay to make sure our use targets are present
	if (ent.delay == 0)
		ent.delay = 0.2f;
	G_UseTargets(ent, ent);
}

/*
==============================================================================

trigger_push

==============================================================================
*/

// PGM
namespace spawnflags::push
{
    const spawnflags_t ONCE = spawnflag_dec(0x01);
    const spawnflags_t PLUS = spawnflag_dec(0x02);
    const spawnflags_t SILENT = spawnflag_dec(0x04);
    const spawnflags_t START_OFF = spawnflag_dec(0x08);
    const spawnflags_t CLIP = spawnflag_dec(0x10);
    const spawnflags_t ADDITIVE = spawnflag_dec(0x20);
}
// PGM

cached_soundindex windsound("misc/windfly.wav");

void trigger_push_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.spawnflags.has(spawnflags::push::CLIP))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	if (other.classname == "grenade" || other.health > 0)
	{
		// [Paril-KEX]
		if (self.spawnflags.has(spawnflags::push::ADDITIVE))
		{
			vec3_t velocity_in_dir = other.velocity.scaled(self.movedir);
			float max_speed = (self.speed * 10);

			if (velocity_in_dir.normalized().dot(self.movedir) < 0 || velocity_in_dir.length() < max_speed)
			{
				float speed_adjust = (max_speed * gi_frame_time_s) * 2;
				other.velocity += self.movedir * speed_adjust;
				other.no_gravity_time = level.time + time_ms(100);
			}
		}
		else
			other.velocity = self.movedir * (self.speed * 10);

		if (other.client !is null)
		{
			// don't take falling damage immediately from this
			other.client.oldvelocity = other.velocity;
			@other.client.oldgroundentity = other.groundentity;
			if (
				!self.spawnflags.has(spawnflags::push::SILENT) &&
				(other.fly_sound_debounce_time < level.time))
			{
				other.fly_sound_debounce_time = level.time + time_sec(1.5);
				gi_sound(other.e, soundchan_t::AUTO, windsound, 1, ATTN_NORM, 0);
			}
		}
	}

	if (self.spawnflags.has(spawnflags::push::ONCE))
		G_FreeEdict(self);
}

//======
// PGM
void trigger_push_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;
	gi_linkentity(self.e);
}
// PGM
//======

// RAFAEL
void trigger_effect(ASEntity &self)
{
	vec3_t origin;
	int	   i;

	origin = (self.e.absmin + self.e.absmax) * 0.5f;

	for (i = 0; i < 10; i++)
	{
		origin[2] += (self.speed * 0.01f) * (i + frandom());
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::TUNNEL_SPARKS);
		gi_WriteByte(1);
		gi_WritePosition(origin);
		gi_WriteDir(vec3_origin);
		gi_WriteByte(irandom(0x74, 0x7C));
		gi_multicast(self.e.s.origin, multicast_t::PVS, false);
	}
}

void trigger_push_inactive(ASEntity &self)
{
	if (self.delay > level.time.secondsf())
	{
		self.nextthink = level.time + time_ms(100);
	}
	else
	{
		@self.touch = trigger_push_touch;
		@self.think = trigger_push_active;
		self.nextthink = level.time + time_ms(100);
		self.delay = (self.nextthink + time_sec(self.wait)).secondsf();
	}
}

void trigger_push_active(ASEntity &self)
{
	if (self.delay > level.time.secondsf())
	{
		self.nextthink = level.time + time_ms(100);
		trigger_effect(self);
	}
	else
	{
		@self.touch = null;
		@self.think = trigger_push_inactive;
		self.nextthink = level.time + time_ms(100);
		self.delay = (self.nextthink + time_sec(self.wait)).secondsf();
	}
}

// RAFAEL

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE PUSH_PLUS PUSH_SILENT START_OFF CLIP
Pushes the player
"speed"	defaults to 1000
"wait"  defaults to 10, must use PUSH_PLUS

If targeted, it will toggle on and off when used.

START_OFF - toggled trigger_push begins in off setting
SILENT - doesn't make wind noise
*/
void SP_trigger_push(ASEntity &self)
{
	InitTrigger(self);
	if (!self.spawnflags.has(spawnflags::push::SILENT))
		windsound.precache();
	@self.touch = trigger_push_touch;

	// RAFAEL
	if (self.spawnflags.has(spawnflags::push::PLUS))
	{
		if (self.wait == 0)
			self.wait = 10;

		@self.think = trigger_push_active;
		self.nextthink = level.time + time_ms(100);
		self.delay = (self.nextthink + time_sec(self.wait)).secondsf();
	}
	// RAFAEL

	if (self.speed == 0)
		self.speed = 1000;

	// PGM
	if (!self.targetname.empty()) // toggleable
	{
		@self.use = trigger_push_use;
		if (self.spawnflags.has(spawnflags::push::START_OFF))
			self.e.solid = solid_t::NOT;
	}
	else if (self.spawnflags.has(spawnflags::push::START_OFF))
	{
		gi_Com_Print("{} is START_OFF but not targeted.\n", self);
		self.e.svflags = svflags_t::NONE;
		@self.touch = null;
		self.e.solid = solid_t::BSP;
		self.movetype = movetype_t::PUSH;
	}
	// PGM

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::push::CLIP))
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::HULL);
}


/*
==============================================================================

trigger_hurt

==============================================================================
*/

/*QUAKED trigger_hurt (.5 .5 .5) ? START_OFF TOGGLE SILENT NO_PROTECTION SLOW NO_PLAYERS NO_MONSTERS PASSIVE
Any entity that touches this will be hurt.

It does dmg points of damage each server frame

SILENT			supresses playing the sound
SLOW			changes the damage rate to once per second
NO_PROTECTION	*nothing* stops the damage

"dmg"			default 5 (whole numbers only)

*/

namespace spawnflags::hurt
{
    const spawnflags_t START_OFF = spawnflag_dec(1);
    const spawnflags_t TOGGLE = spawnflag_dec(2);
    const spawnflags_t SILENT = spawnflag_dec(4);
    const spawnflags_t NO_PROTECTION = spawnflag_dec(8);
    const spawnflags_t SLOW = spawnflag_dec(16);
    const spawnflags_t NO_PLAYERS = spawnflag_dec(32);
    const spawnflags_t NO_MONSTERS = spawnflag_dec(64);
    const spawnflags_t CLIPPED = spawnflag_dec(128);
    const spawnflags_t PASSIVE = spawnflag_bit(16);
}

void hurt_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;
	gi_linkentity(self.e);

	if (!self.spawnflags.has(spawnflags::hurt::TOGGLE))
		@self.use = null;

	if (self.spawnflags.has(spawnflags::hurt::PASSIVE))
	{
		if (self.e.solid == solid_t::TRIGGER)
		{
			if (self.spawnflags.has(spawnflags::hurt::SLOW))
				self.nextthink = level.time + time_sec(1);
			else
				self.nextthink = level.time + time_hz(10);
		}
		else
			self.nextthink = time_zero;
	}
}

class hurt_filter_data_t
{
	ASEntity @self;
	array<ASEntity @> hurt;
};

BoxEdictsResult_t hurt_filter(edict_t @other_handle, any @const ptr)
{
	hurt_filter_data_t @data;
    ptr.retrieve(@data);

    ASEntity @other = entities[other_handle.s.number];
	ASEntity @self = data.self;

	if (!other.takedamage)
		return BoxEdictsResult_t::Skip;
	else if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.flags & ent_flags_t::DAMAGEABLE) == 0 && (other.client is null) && other.classname != "misc_explobox")
		return BoxEdictsResult_t::Skip;
	else if (self.spawnflags.has(spawnflags::hurt::NO_MONSTERS) && (other.e.svflags & svflags_t::MONSTER) != 0)
		return BoxEdictsResult_t::Skip;
	else if (self.spawnflags.has(spawnflags::hurt::NO_PLAYERS) && (other.client !is null))
		return BoxEdictsResult_t::Skip;

	if (self.spawnflags.has(spawnflags::hurt::CLIPPED))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return BoxEdictsResult_t::Skip;
	}

	data.hurt.push_back(other);
	return BoxEdictsResult_t::Skip;
}

void hurt_think(ASEntity &self)
{
	hurt_filter_data_t data;
    @data.self = self;

	gi_BoxEdicts(self.e.absmin, self.e.absmax, null, 0, solidity_area_t::SOLID, hurt_filter, any(@data), false);
	
	damageflags_t dflags;

	if (self.spawnflags.has(spawnflags::hurt::NO_PROTECTION))
		dflags = damageflags_t::NO_PROTECTION;
	else
		dflags = damageflags_t::NONE;

	foreach (ASEntity @other : data.hurt)
	{
		if (!self.spawnflags.has(spawnflags::hurt::SILENT))
		{
			if (self.fly_sound_debounce_time < level.time)
			{
				gi_sound(other.e, soundchan_t::AUTO, self.noise_index, 1, ATTN_NORM, 0);
				self.fly_sound_debounce_time = level.time + time_sec(1);
			}
		}

		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, self.dmg, dflags, mod_id_t::TRIGGER_HURT);
	}

	if (self.spawnflags.has(spawnflags::hurt::SLOW))
		self.nextthink = level.time + time_sec(1);
	else
		self.nextthink = level.time + time_hz(10);
}

void hurt_touch (ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (!other.takedamage)
		return;
	else if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.flags & ent_flags_t::DAMAGEABLE) == 0 && (other.client  is null) && (other.classname != "misc_explobox"))
		return;
	else if (self.spawnflags.has(spawnflags::hurt::NO_MONSTERS) && (other.e.svflags & svflags_t::MONSTER) != 0)
		return;
	else if (self.spawnflags.has(spawnflags::hurt::NO_PLAYERS) && (other.client !is null))
		return;

	if (self.timestamp > level.time)
		return;

	if (self.spawnflags.has(spawnflags::hurt::CLIPPED))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	if (self.spawnflags.has(spawnflags::hurt::SLOW))
		self.timestamp = level.time + time_sec(1);
	else
		self.timestamp = level.time + time_hz(10);

	if (!self.spawnflags.has(spawnflags::hurt::SILENT))
	{
		if (self.fly_sound_debounce_time < level.time)
		{
			gi_sound(other.e, soundchan_t::AUTO, self.noise_index, 1, ATTN_NORM, 0);
			self.fly_sound_debounce_time = level.time + time_sec(1);
		}
	}

	damageflags_t dflags;

	if (self.spawnflags.has(spawnflags::hurt::NO_PROTECTION))
		dflags = damageflags_t::NO_PROTECTION;
	else
		dflags = damageflags_t::NONE;

	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, self.dmg, dflags, mod_id_t::TRIGGER_HURT);
}

void SP_trigger_hurt(ASEntity &self)
{
	InitTrigger(self);

	self.noise_index = gi_soundindex("world/electro.wav");

	if (self.spawnflags.has(spawnflags::hurt::PASSIVE))
	{
		@self.think = hurt_think;

		if (!self.spawnflags.has(spawnflags::hurt::START_OFF))
		{
			if (self.spawnflags.has(spawnflags::hurt::SLOW))
				self.nextthink = level.time + time_sec(1);
			else
				self.nextthink = level.time + time_hz(10);
		}
	}
	else
		@self.touch = hurt_touch;

	if (self.dmg == 0)
		self.dmg = 5;

	if (self.spawnflags.has(spawnflags::hurt::START_OFF))
		self.e.solid = solid_t::NOT;
	else
		self.e.solid = solid_t::TRIGGER;

	if (self.spawnflags.has(spawnflags::hurt::TOGGLE))
		@self.use = hurt_use;

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::hurt::CLIPPED))
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::HULL);
}


/*
==============================================================================

trigger_gravity

==============================================================================
*/

/*QUAKED trigger_gravity (.5 .5 .5) ? TOGGLE START_OFF
Changes the touching entites gravity to the value of "gravity".
1.0 is standard gravity for the level.

TOGGLE - trigger_gravity can be turned on and off
START_OFF - trigger_gravity starts turned off (implies TOGGLE)
*/

namespace spawnflags::gravity
{
    const spawnflags_t TOGGLE = spawnflag_dec(1);
    const spawnflags_t START_OFF = spawnflag_dec(2);
    const spawnflags_t CLIPPED = spawnflag_dec(4);
}

// PGM
void trigger_gravity_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;
	gi_linkentity(self.e);
}
// PGM

void trigger_gravity_touch (ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.spawnflags.has(spawnflags::gravity::CLIPPED))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	other.gravity = self.gravity;
}

void SP_trigger_gravity(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (st.gravity.empty())
	{
		gi_Com_Print("{}: no gravity set\n", self);
		G_FreeEdict(self);
		return;
	}

	InitTrigger(self);

	// PGM
	self.gravity = parseFloat(st.gravity);

	if (self.spawnflags.has(spawnflags::gravity::TOGGLE))
		@self.use = trigger_gravity_use;

	if (self.spawnflags.has(spawnflags::gravity::START_OFF))
	{
		@self.use = trigger_gravity_use;
		self.e.solid = solid_t::NOT;
	}

	@self.touch = trigger_gravity_touch;
	// PGM

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::gravity::CLIPPED))
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::HULL);
}

/*
==============================================================================

trigger_monsterjump

==============================================================================
*/

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards

TOGGLE - trigger_monsterjump can be turned on and off
START_OFF - trigger_monsterjump starts turned off (implies TOGGLE)
*/

namespace spawnflags::monsterjump
{
    const spawnflags_t TOGGLE = spawnflag_dec(1);
    const spawnflags_t START_OFF = spawnflag_dec(2);
    const spawnflags_t CLIPPED = spawnflag_dec(4);
}

void trigger_monsterjump_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.e.solid == solid_t::NOT)
		self.e.solid = solid_t::TRIGGER;
	else
		self.e.solid = solid_t::NOT;
	gi_linkentity(self.e);
}

void trigger_monsterjump_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if ((other.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) != 0)
		return;
	if ((other.e.svflags & svflags_t::DEADMONSTER) != 0)
		return;
	if ((other.e.svflags & svflags_t::MONSTER) == 0)
		return;

	if (self.spawnflags.has(spawnflags::monsterjump::CLIPPED))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	// set XY even if not on ground, so the jump will clear lips
	other.velocity.x = self.movedir.x * self.speed;
	other.velocity.y = self.movedir.y * self.speed;

	if (other.groundentity is null)
		return;

	@other.groundentity = null;
	other.velocity.z = self.movedir.z;
}

void SP_trigger_monsterjump(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (self.speed == 0)
		self.speed = 200;
	float height = st.height;
	if (height == 0)
		height = 200;
	if (self.e.s.angles.yaw == 0)
		self.e.s.angles.yaw = 360;
	InitTrigger(self);
	@self.touch = trigger_monsterjump_touch;
	self.movedir[2] = height;

	if (self.spawnflags.has(spawnflags::monsterjump::TOGGLE))
		@self.use = trigger_monsterjump_use;

	if (self.spawnflags.has(spawnflags::monsterjump::START_OFF))
	{
		@self.use = trigger_monsterjump_use;
		self.e.solid = solid_t::NOT;
	}

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::monsterjump::CLIPPED))
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::HULL);
}

/*
==============================================================================

trigger_flashlight

==============================================================================
*/

/*QUAKED trigger_flashlight (.5 .5 .5) ?
Players moving against this trigger will have their flashlight turned on or off.
"style" default to 0, set to 1 to always turn flashlight on, 2 to always turn off,
        otherwise "angles" are used to control on/off state
*/

namespace spawnflags::flashlight
{
    const spawnflags_t CLIPPED = spawnflag_dec(1);
}

void trigger_flashlight_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client is null)
		return;

	if (self.spawnflags.has(spawnflags::flashlight::CLIPPED))
	{
		trace_t clip = gi_clip(self.e, other.e.s.origin, other.e.mins, other.e.maxs, other.e.s.origin, G_GetClipMask(other));

		if (clip.fraction == 1.0f)
			return;
	}

	if (self.style == 1)
	{
		P_ToggleFlashlight(other, true);
	}
	else if (self.style == 2)
	{
		P_ToggleFlashlight(other, false);
	}
	else if (other.velocity.lengthSquared() > 32.0f)
	{
		vec3_t forward = other.velocity.normalized();
		P_ToggleFlashlight(other, forward.dot(self.movedir) > 0);
	}
}

void SP_trigger_flashlight(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if (self.e.s.angles.yaw == 0)
		self.e.s.angles.yaw = 360;
	InitTrigger(self);
	@self.touch = trigger_flashlight_touch;
	self.movedir[2] = st.height;

	if (self.spawnflags.has(spawnflags::flashlight::CLIPPED))
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::HULL);
	gi_linkentity(self.e);
}

/*
==============================================================================

trigger_fog

==============================================================================
*/

/*QUAKED trigger_fog (.5 .5 .5) ? AFFECT_FOG AFFECT_HEIGHTFOG INSTANTANEOUS FORCE BLEND
Players moving against this trigger will have their fog settings changed.
Fog/heightfog will be adjusted if the spawnflags are set. Instantaneous
ignores any delays. Force causes it to ignore movement dir and always use
the "on" values. Blend causes it to change towards how far you are into the trigger
with respect to angles.
"target" can target an info_notnull to pull the keys below from.
"delay" default to 0.5; time in seconds a change in fog will occur over
"wait" default to 0.0; time in seconds before a re-trigger can be executed

"fog_density"; density value of fog, 0-1
"fog_color"; color value of fog, 3d vector with values between 0-1 (r g b)
"fog_density_off"; transition density value of fog, 0-1
"fog_color_off"; transition color value of fog, 3d vector with values between 0-1 (r g b)
"fog_sky_factor"; sky factor value of fog, 0-1
"fog_sky_factor_off"; transition sky factor value of fog, 0-1

"heightfog_falloff"; falloff value of heightfog, 0-1
"heightfog_density"; density value of heightfog, 0-1
"heightfog_start_color"; the start color for the fog (r g b, 0-1)
"heightfog_start_dist"; the start distance for the fog (units)
"heightfog_end_color"; the start color for the fog (r g b, 0-1)
"heightfog_end_dist"; the end distance for the fog (units)

"heightfog_falloff_off"; transition falloff value of heightfog, 0-1
"heightfog_density_off"; transition density value of heightfog, 0-1
"heightfog_start_color_off"; transition the start color for the fog (r g b, 0-1)
"heightfog_start_dist_off"; transition the start distance for the fog (units)
"heightfog_end_color_off"; transition the start color for the fog (r g b, 0-1)
"heightfog_end_dist_off"; transition the end distance for the fog (units)
*/
namespace spawnflags::fog
{
    const spawnflags_t AFFECT_FOG = spawnflag_dec(1);
    const spawnflags_t AFFECT_HEIGHTFOG = spawnflag_dec(2);
    const spawnflags_t INSTANTANEOUS = spawnflag_dec(4);
    const spawnflags_t FORCE = spawnflag_dec(8);
    const spawnflags_t BLEND = spawnflag_dec(16);
}

void trigger_fog_touch (ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client is null)
		return;

	if (self.timestamp > level.time)
		return;

	self.timestamp = level.time + time_sec(self.wait);

	ASEntity @fog_value_storage = self;

	if (self.movetarget !is null)
		@fog_value_storage = self.movetarget;

	if (self.spawnflags.has(spawnflags::fog::INSTANTANEOUS))
		other.client.pers.fog_transition_time = time_zero;
	else
		other.client.pers.fog_transition_time = time_sec(fog_value_storage.delay);

	if (self.spawnflags.has(spawnflags::fog::BLEND))
	{
		vec3_t center = (self.e.absmin + self.e.absmax) * 0.5f;
		vec3_t half_size = (self.e.size * 0.5f) + (other.e.size * 0.5f);
		vec3_t start = (-self.movedir).scaled(half_size);
		vec3_t end = (self.movedir).scaled(half_size);
		vec3_t player_dist = (other.e.origin - center).scaled(vec3_t(abs(self.movedir.x),abs(self.movedir.y),abs(self.movedir.z)));

		float dist = (player_dist - start).length();
		dist /= (start - end).length();
		dist = clamp(dist, 0.f, 1.f);

		if (self.spawnflags.has(spawnflags::fog::AFFECT_FOG))
		{
            auto @wanted = other.client.pers.wanted_fog;
            auto @off = fog_value_storage.fog_off;
            auto @on = fog_value_storage.fog;
			wanted.density = lerp(off.density, on.density, dist);
			wanted.rgb.x = lerp(off.rgb.x, on.rgb.x, dist);
			wanted.rgb.y = lerp(off.rgb.y, on.rgb.y, dist);
			wanted.rgb.z = lerp(off.rgb.z, on.rgb.z, dist);
			wanted.skyfactor =	lerp(off.skyfactor, on.skyfactor, dist);
		}

		if (self.spawnflags.has(spawnflags::fog::AFFECT_HEIGHTFOG))
		{
            auto @wanted = other.client.pers.wanted_heightfog;
            auto @off = fog_value_storage.heightfog_off;
            auto @on = fog_value_storage.heightfog;
            wanted.start.x = lerp(off.start.x, on.start.x, dist);
            wanted.start.y = lerp(off.start.y, on.start.y, dist);
            wanted.start.z = lerp(off.start.z, on.start.z, dist);
            wanted.start.w = lerp(off.start.w, on.start.w, dist);
            wanted.end.x = lerp(off.end.x, on.end.x, dist);
            wanted.end.y = lerp(off.end.y, on.end.y, dist);
            wanted.end.z = lerp(off.end.z, on.end.z, dist);
            wanted.end.w = lerp(off.end.w, on.end.w, dist);
            wanted.falloff = lerp(off.falloff, on.falloff, dist);
            wanted.density = lerp(off.density, on.density, dist);
		}

		return;
	}

	bool use_on = true;

	if (!self.spawnflags.has(spawnflags::fog::FORCE))
	{
		float len;
		vec3_t forward = other.velocity.normalized(len);

		// not moving enough to trip; this is so we don't trip
		// the wrong direction when on an elevator, etc.
		if (len <= 0.0001f)
			return;

		use_on = forward.dot(self.movedir) > 0;
	}

	if (self.spawnflags.has(spawnflags::fog::AFFECT_FOG))
	{
		if (use_on)
            other.client.pers.wanted_fog = fog_value_storage.fog;
		else
            other.client.pers.wanted_fog = fog_value_storage.fog_off;
	}

	if (self.spawnflags.has(spawnflags::fog::AFFECT_HEIGHTFOG))
	{
		if (use_on)
			other.client.pers.wanted_heightfog = fog_value_storage.heightfog;
		else
			other.client.pers.wanted_heightfog = fog_value_storage.heightfog_off;
	}
}

void SP_trigger_fog(ASEntity &self)
{
	if (self.e.angles.yaw == 0)
		self.e.angles.yaw = 360;

	InitTrigger(self);

	if (!self.spawnflags.has(spawnflags::fog::AFFECT_FOG | spawnflags::fog::AFFECT_HEIGHTFOG))
		gi_Com_Print("WARNING: {} with no fog spawnflags set\n", self);

	if (!self.target.empty())
	{
		@self.movetarget = G_PickTarget(self.target);

		if (self.movetarget !is null)
		{
			if (self.movetarget.delay == 0)
				self.movetarget.delay = 0.5f;
		}
	}

	if (self.delay == 0)
		self.delay = 0.5f;

	@self.touch = trigger_fog_touch;
}

/*QUAKED trigger_coop_relay (.5 .5 .5) ? AUTO_FIRE
Like a trigger_relay, but all players must be touching its
mins/maxs in order to fire, otherwise a message will be printed.

AUTO_FIRE: check every `wait` seconds for containment instead of
requiring to be fired by something else. Frees itself after firing.

"message"; message to print to the one activating the relay if
           not all players are inside the bounds
"message2"; message to print to players not inside the trigger
            if they aren't in the bounds
*/

namespace spawnflags::coop_relay
{
    const spawnflags_t AUTO_FIRE = spawnflag_dec(1);
}

bool trigger_coop_relay_filter(ASEntity &player)
{
	return (player.health <= 0 || player.deadflag || player.movetype == movetype_t::NOCLIP ||
		player.client.resp.spectator || player.e.s.modelindex != MODELINDEX_PLAYER);
}

bool trigger_coop_relay_can_use(ASEntity &self, ASEntity &activator)
{
	// not coop, so act like a standard trigger_relay minus the message
	if (coop.integer == 0)
		return true;

	// coop; scan for all alive players, print appropriate message
	// to those in/out of range
	bool can_use = true;

    foreach (ASEntity @player : active_players)
    {
		// dead or spectator, don't count them
		if (trigger_coop_relay_filter(player))
			continue;

		if (boxes_intersect(player.e.absmin, player.e.absmax, self.e.absmin, self.e.absmax))
			continue;

		if (self.timestamp < level.time)
			gi_LocCenter_Print(player.e, self.map);
		can_use = false;
	}

	return can_use;
}

void trigger_coop_relay_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (!trigger_coop_relay_can_use(self, activator))
	{
		if (self.timestamp < level.time)
			gi_LocCenter_Print(activator.e, self.message);

		self.timestamp = level.time + time_sec(5);
		return;
	}

	string  msg = self.message;
	self.message = "";
	G_UseTargets(self, activator);
	self.message = msg;
}

BoxEdictsResult_t trigger_coop_relay_player_filter(edict_t @ent_handle, any @const)
{
    ASEntity @ent = entities[ent_handle.s.number];

	if (ent.client is null)
		return BoxEdictsResult_t::Skip;
	else if (trigger_coop_relay_filter(ent))
		return BoxEdictsResult_t::Skip;

	return BoxEdictsResult_t::Keep;
}

void trigger_coop_relay_think(ASEntity &self)
{
	array<edict_t @> found_players;
	uint num_active = 0;

    foreach (ASEntity @player : active_players)
		if (!trigger_coop_relay_filter(player))
			num_active++;

	uint n = gi_BoxEdicts(self.e.absmin, self.e.absmax, found_players, num_active, solidity_area_t::SOLID, trigger_coop_relay_player_filter, null, false);

	if (n == num_active)
	{
		string msg = self.message;
		self.message = "";
		G_UseTargets(self, entities[found_players[0].s.number]);
		self.message = msg;

		G_FreeEdict(self);
		return;
	}
	else if (n != 0 && self.timestamp < level.time)
	{
		for (uint i = 0; i < n; i++)
			gi_LocCenter_Print(found_players[i], self.message);

        foreach (ASEntity @player : active_players)
			if (found_players.findByRef(player.e) == -1)
				gi_LocCenter_Print(player.e, self.map);

		self.timestamp = level.time + time_sec(5);
	}

	self.nextthink = level.time + time_sec(self.wait);
}

void SP_trigger_coop_relay(ASEntity &self)
{
	if (!self.targetname.empty() && self.spawnflags.has(spawnflags::coop_relay::AUTO_FIRE))
		gi_Com_Print("{}: targetname and auto-fire are mutually exclusive\n", self);

	InitTrigger(self);
	
	if (self.message.empty())
		self.message = "$g_coop_wait_for_players";

	if (self.map.empty())
		self.map = "$g_coop_players_waiting_for_you";

	if (self.wait == 0)
		self.wait = 1;

	if (self.spawnflags.has(spawnflags::coop_relay::AUTO_FIRE))
	{
		@self.think = trigger_coop_relay_think;
		self.nextthink = level.time + time_sec(self.wait);
	}
	else
		@self.use = trigger_coop_relay_use;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	gi_linkentity(self.e);
}

/*QUAKED trigger_safe_fall (.5 .5 .5) ?
Players that touch this trigger are granted one (1)
free safe fall damage exemption.

They must already be in the air to get this ability.
*/

void trigger_safe_fall_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client !is null && other.groundentity is null)
		other.client.landmark_free_fall = true;
}

void SP_trigger_safe_fall(ASEntity &self)
{
	InitTrigger(self);
	@self.touch = trigger_safe_fall_touch;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.e.solid = solid_t::TRIGGER;
	gi_linkentity(self.e);
}