
/*
========================
fire_flechette
========================
*/
void flechette_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other is self.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.client !is null)
		PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
	{
		T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal,
				 self.dmg, int(self.dmg_radius), damageflags_t::NO_REG_ARMOR, mod_id_t::ETF_RIFLE);
	}
	else
	{
		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::FLECHETTE);
		gi_WritePosition(self.e.s.origin);
		gi_WriteDir(tr.plane.normal);
		gi_multicast(self.e.s.origin, multicast_t::PHS, false);
	}

	G_FreeEdict(self);
}

void fire_flechette(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, int kick)
{
	ASEntity @flechette;

	@flechette = G_Spawn();
	flechette.e.s.origin = start;
	flechette.e.s.old_origin = start;
	flechette.e.s.angles = vectoangles(dir);
	flechette.velocity = dir * speed;
	flechette.e.svflags = svflags_t(flechette.e.svflags | svflags_t::PROJECTILE);
	flechette.movetype = movetype_t::FLYMISSILE;
	flechette.e.clipmask = contents_t::MASK_PROJECTILE;
	flechette.flags = ent_flags_t(flechette.flags | ent_flags_t::DODGE);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		flechette.e.clipmask = contents_t(flechette.e.clipmask & ~contents_t::PLAYER);

	flechette.e.solid = solid_t::BBOX;
	flechette.e.s.renderfx = renderfx_t::FULLBRIGHT;
	flechette.e.s.modelindex = gi_modelindex("models/proj/flechette/tris.md2");

	@flechette.owner = self;
	@flechette.touch = flechette_touch;
	flechette.nextthink = level.time + time_sec(8000.0f / speed);
	@flechette.think = G_FreeEdict;
	flechette.dmg = damage;
	flechette.dmg_radius = float(kick);

	gi_linkentity(flechette.e);

	trace_t tr = gi_traceline(self.e.s.origin, flechette.e.s.origin, flechette.e, flechette.e.clipmask);
	if (tr.fraction < 1.0f)
	{
		flechette.e.s.origin = tr.endpos + (tr.plane.normal * 1.0f);
		flechette.touch(flechette, entities[tr.ent.s.number], tr, false);
	}
}

// **************************
// PROX
// **************************

const gtime_t PROX_TIME_TO_LIVE = time_sec(45); // 45, 30, 15, 10
const gtime_t PROX_TIME_DELAY = time_ms(500);
const float	  PROX_BOUND_SIZE = 96;
const float	  PROX_DAMAGE_RADIUS = 192;
const int32   PROX_HEALTH = 20;
const int32   PROX_DAMAGE = 60;
const float   PROX_DAMAGE_OPEN_MULTIPLIER = 1.5f; // expands 60 to 90 when it opens

//===============
void Prox_ExplodeReal(ASEntity &ent, ASEntity @other, const vec3_t &in normal)
{
	vec3_t	 origin;
	ASEntity @owner;

	// free the trigger field

	// PMM - changed teammaster to "mover" .. owner of the field is the prox
	if (ent.teamchain !is null && ent.teamchain.owner is ent)
		G_FreeEdict(ent.teamchain);

	@owner = ent;
	if (ent.teammaster !is null)
	{
		@owner = ent.teammaster;
		PlayerNoise(owner, ent.e.s.origin, player_noise_t::IMPACT);
	}

	if (other !is null)
	{
		vec3_t dir = other.e.s.origin - ent.e.s.origin;
		T_Damage(other, ent, owner, dir, ent.e.s.origin, normal, ent.dmg, ent.dmg, damageflags_t::NONE, mod_id_t::PROX);
	}

	// play quad sound if appopriate
	if (ent.dmg > PROX_DAMAGE * PROX_DAMAGE_OPEN_MULTIPLIER)
		gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage3.wav"), 1, ATTN_NORM, 0);

	ent.takedamage = false;
	T_RadiusDamage(ent, owner, float(ent.dmg), other, PROX_DAMAGE_RADIUS, damageflags_t::NONE, mod_id_t::PROX);

	origin = ent.e.s.origin + normal;
	gi_WriteByte(svc_t::temp_entity);
	if (ent.groundentity !is null)
		gi_WriteByte(temp_event_t::GRENADE_EXPLOSION);
	else
		gi_WriteByte(temp_event_t::ROCKET_EXPLOSION);
	gi_WritePosition(origin);
	gi_multicast(ent.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(ent);
}

void Prox_Explode(ASEntity &ent)
{
	Prox_ExplodeReal(ent, null, (ent.velocity * -0.02f));
}

//===============
//===============
void prox_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// if set off by another prox, delay a little (chained explosions)
	if (inflictor.classname != "prox_mine")
	{
		self.takedamage = false;
		Prox_Explode(self);
	}
	else
	{
		self.takedamage = false;
		@self.think = Prox_Explode;
		self.nextthink = level.time + FRAME_TIME_S;
	}
}

//===============
//===============
void Prox_Field_Touch(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity @prox;

	if ((other.e.svflags & svflags_t::MONSTER) == 0 && other.client is null)
		return;

	// trigger the prox mine if it's still there, and still mine.
	@prox = ent.owner;

	// teammate avoidance
	if (CheckTeamDamage(prox.teammaster, other))
		return;

	if (deathmatch.integer == 0 && other.client !is null)
		return;

	if (other is prox) // don't set self off
		return;

	if (prox.think is Prox_Explode) // we're set to blow!
		return;

	if (prox.teamchain is ent)
	{
		gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/proxwarn.wav"), 1, ATTN_NORM, 0);
		@prox.think = Prox_Explode;
		prox.nextthink = level.time + PROX_TIME_DELAY;
		return;
	}

	ent.e.solid = solid_t::NOT;
	G_FreeEdict(ent);
}

//===============
//===============
void prox_seek(ASEntity &ent)
{
	if (level.time > time_sec(ent.wait))
	{
		Prox_Explode(ent);
	}
	else
	{
		ent.e.s.frame++;
		if (ent.e.s.frame > 13)
			ent.e.s.frame = 9;
		@ent.think = prox_seek;
		ent.nextthink = level.time + time_hz(10);
	}
}

//===============
//===============
void prox_open(ASEntity &ent)
{
	ASEntity @search;

	@search = null;

	if (ent.e.s.frame == 9) // end of opening animation
	{
		// set the owner to nullptr so the owner can walk through it.  needs to be done here so the owner
		// doesn't get stuck on it while it's opening if fired at point blank wall
		ent.e.s.sound = 0;

		if (deathmatch.integer != 0)
			@ent.owner = null;

		if (ent.teamchain !is null)
			@ent.teamchain.touch = Prox_Field_Touch;
		while ((@search = findradius(search, ent.e.s.origin, PROX_DAMAGE_RADIUS + 10)) !is null)
		{
			if (search.classname.empty()) // tag token and other weird shit
				continue;
			
			// teammate avoidance
			if (CheckTeamDamage(search, ent.teammaster))
				continue;

			// if it's a monster or player with health > 0
			// or it's a player start point
			// and we can see it
			// blow up
			if (
				search !is ent &&
				(
					(((search.e.svflags & svflags_t::MONSTER) != 0 || (deathmatch.integer != 0 && (search.client !is null ||
                        (search.classname == "prox_mine")))) && (search.health > 0)) ||
					(deathmatch.integer != 0 &&
					 ((search.classname.findFirst("info_player_") == 0)) ||
					  (search.classname == "misc_teleporter_dest") ||
					  (search.classname.findFirst("item_flag_") == 0))) &&
				(visible(search, ent)))
			{
				gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/proxwarn.wav"), 1, ATTN_NORM, 0);
				Prox_Explode(ent);
				return;
			}
		}

		if (g_dm_strong_mines.integer != 0)
			ent.wait = (level.time + PROX_TIME_TO_LIVE).secondsf();
		else
		{
			switch (int(ent.dmg / (PROX_DAMAGE * PROX_DAMAGE_OPEN_MULTIPLIER)))
			{
			case 1:
				ent.wait = (level.time + PROX_TIME_TO_LIVE).secondsf();
				break;
			case 2:
				ent.wait = (level.time + time_sec(30)).secondsf();
				break;
			case 4:
				ent.wait = (level.time + time_sec(15)).secondsf();
				break;
			case 8:
				ent.wait = (level.time + time_sec(10)).secondsf();
				break;
			default:
				ent.wait = (level.time + PROX_TIME_TO_LIVE).secondsf();
				break;
			}
		}

		@ent.think = prox_seek;
		ent.nextthink = level.time + time_ms(200);
	}
	else
	{
		if (ent.e.s.frame == 0)
		{
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/proxopen.wav"), 1, ATTN_NORM, 0);
			ent.dmg = int(ent.dmg * PROX_DAMAGE_OPEN_MULTIPLIER);
		}
		ent.e.s.frame++;
		@ent.think = prox_open;
		ent.nextthink = level.time + time_hz(10);
	}
}

const float PROX_STOP_EPSILON = 0.1f;

//===============
//===============
void prox_land(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	ASEntity   @field;
	vec3_t	   dir;
	vec3_t	   forward, right, up;
	movetype_t movetype = movetype_t::NONE;
	bool       stick_ok = false;
	vec3_t	   land_point;

	// must turn off owner so owner can shoot it and set it off
	// moved to prox_open so owner can get away from it if fired at pointblank range into
	// wall
	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(ent);
		return;
	}

	if (tr.plane.normal)
	{
		land_point = ent.e.s.origin + (tr.plane.normal * -10.0f);
		if ((gi_pointcontents(land_point) & (contents_t::SLIME | contents_t::LAVA)) != 0)
		{
			Prox_Explode(ent);
			return;
		}
	}

	if (!tr.plane.normal || (other.e.svflags & svflags_t::MONSTER) != 0 || other.client !is null || (other.flags & ent_flags_t::DAMAGEABLE) != 0)
	{
		if (other !is ent.teammaster)
			Prox_ExplodeReal(ent, other, tr.plane.normal);

		return;
	}
	else if (other !is world)
	{
		// Here we need to check to see if we can stop on this entity.
		// Note that plane can be nullptr

		// PMM - code stolen from g_phys (ClipVelocity)
		vec3_t vout;
		float  backoff, change;
		int	   i;

		if ((other.movetype == movetype_t::PUSH) && (tr.plane.normal[2] > 0.7f))
			stick_ok = true;
		else
			stick_ok = false;

		backoff = ent.velocity.dot(tr.plane.normal) * 1.5f;
		for (i = 0; i < 3; i++)
		{
			change = tr.plane.normal[i] * backoff;
			vout[i] = ent.velocity[i] - change;
			if (vout[i] > -PROX_STOP_EPSILON && vout[i] < PROX_STOP_EPSILON)
				vout[i] = 0;
		}

		if (vout[2] > 60)
			return;

		movetype = movetype_t::BOUNCE;

		// if we're here, we're going to stop on an entity
		if (stick_ok)
		{ // it's a happy entity
			ent.velocity = vec3_origin;
			ent.avelocity = vec3_origin;
		}
		else // no-stick.  teflon time
		{
			if (tr.plane.normal[2] > 0.7f)
			{
				Prox_Explode(ent);
				return;
			}
			return;
		}
	}
	else if (other.e.s.modelindex != MODELINDEX_WORLD)
		return;

	dir = vectoangles(tr.plane.normal);
	AngleVectors(dir, forward, right, up);

	if ((gi_pointcontents(ent.e.s.origin) & (contents_t::LAVA | contents_t::SLIME)) != 0)
	{
		Prox_Explode(ent);
		return;
	}

	ent.e.svflags = svflags_t(ent.e.svflags & ~svflags_t::PROJECTILE);

	@field = G_Spawn();

	field.e.s.origin = ent.e.s.origin;
	field.e.mins = { -PROX_BOUND_SIZE, -PROX_BOUND_SIZE, -PROX_BOUND_SIZE };
	field.e.maxs = { PROX_BOUND_SIZE, PROX_BOUND_SIZE, PROX_BOUND_SIZE };
	field.movetype = movetype_t::NONE;
	field.e.solid = solid_t::TRIGGER;
	@field.owner = ent;
	field.classname = "prox_field";
	@field.teammaster = ent;
	gi_linkentity(field.e);

	ent.velocity = vec3_origin;
	ent.avelocity = vec3_origin;
	// rotate to vertical
	dir.pitch = dir.pitch + 90;
	ent.e.s.angles = dir;
	ent.takedamage = true;
	ent.movetype = movetype; // either bounce or none, depending on whether we stuck to something
	@ent.die = prox_die;
	@ent.teamchain = field;
	ent.health = PROX_HEALTH;
	ent.nextthink = level.time;
	@ent.think = prox_open;
	@ent.touch = null;
	ent.e.solid = solid_t::BBOX;

	gi_linkentity(ent.e);
}

void Prox_Think(ASEntity &self)
{
	if (self.timestamp <= level.time)
	{
		Prox_Explode(self);
		return;
	}

	self.e.s.angles = vectoangles(self.velocity.normalized());
	self.e.s.angles.pitch -= 90;
	self.nextthink = level.time;
}

//===============
//===============
void fire_prox(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int prox_damage_multiplier, int speed)
{
	ASEntity @prox;
	vec3_t	 dir;
	vec3_t	 forward, right, up;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@prox = G_Spawn();
	prox.e.s.origin = start;
	prox.velocity = aimdir * speed;

	float gravityAdjustment = level.gravity / 800.f;

	prox.velocity += up * (200 + crandom() * 10.0f) * gravityAdjustment;
	prox.velocity += right * (crandom() * 10.0f);

	prox.e.s.angles = dir;
	prox.e.s.angles.pitch -= 90;
	prox.movetype = movetype_t::BOUNCE;
	prox.e.solid = solid_t::BBOX;
	prox.e.svflags = svflags_t(prox.e.svflags | svflags_t::PROJECTILE);
	prox.e.s.effects = effects_t(prox.e.s.effects | effects_t::GRENADE);
	prox.flags = ent_flags_t(prox.flags | ( ent_flags_t::DODGE | ent_flags_t::TRAP ));
	prox.e.clipmask = contents_t(contents_t::MASK_PROJECTILE | contents_t::LAVA | contents_t::SLIME);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		prox.e.clipmask = contents_t(prox.e.clipmask & ~contents_t::PLAYER);

	prox.e.s.renderfx = renderfx_t(prox.e.s.renderfx | renderfx_t::IR_VISIBLE);
	// FIXME - this needs to be bigger.  Has other effects, though.  Maybe have to change origin to compensate
	//  so it sinks in correctly.  Also in lavacheck, might have to up the distance
	prox.e.mins = { -6, -6, -6 };
	prox.e.maxs = { 6, 6, 6 };
	prox.e.s.modelindex = gi_modelindex("models/weapons/g_prox/tris.md2");
	@prox.owner = self;
	@prox.teammaster = self;
	@prox.touch = prox_land;
	@prox.think = Prox_Think;
	prox.nextthink = level.time;
	prox.dmg = PROX_DAMAGE * prox_damage_multiplier;
	prox.classname = "prox_mine";
	prox.flags = ent_flags_t(prox.flags | ent_flags_t::DAMAGEABLE);
	prox.flags = ent_flags_t(prox.flags | ent_flags_t::MECHANICAL);

	switch (prox_damage_multiplier)
	{
	case 1:
		prox.timestamp = level.time + PROX_TIME_TO_LIVE;
		break;
	case 2:
		prox.timestamp = level.time + time_sec(30);
		break;
	case 4:
		prox.timestamp = level.time + time_sec(15);
		break;
	case 8:
		prox.timestamp = level.time + time_sec(10);
		break;
	default:
		prox.timestamp = level.time + PROX_TIME_TO_LIVE;
		break;
	}

	gi_linkentity(prox.e);
}

// *************************
// MELEE WEAPONS
// *************************

class player_melee_data_t
{
	ASEntity @self;
	vec3_t start;
	vec3_t aim;
	int reach;

    player_melee_data_t() { }
    player_melee_data_t(ASEntity @self, const vec3_t &in start, const vec3_t &in aim, int reach)
    {
        @this.self = self;
        this.start = start;
        this.aim = aim;
        this.reach = reach;
    }
};

BoxEdictsResult_t fire_player_melee_BoxFilter(edict_t @check_handle, any @const data_v)
{
    ASEntity @check = entities[check_handle.s.number];
    player_melee_data_t @data;
    data_v.retrieve(@data);

	if (!check.e.inuse || !check.takedamage || check is data.self)
		return BoxEdictsResult_t::Skip;

	// check distance
	vec3_t closest_point_to_check = closest_point_to_box(data.start, check.e.s.origin + check.e.mins, check.e.s.origin + check.e.maxs);
	vec3_t closest_point_to_self = closest_point_to_box(closest_point_to_check, data.self.e.s.origin + data.self.e.mins, data.self.e.s.origin + data.self.e.maxs);

	vec3_t dir = (closest_point_to_check - closest_point_to_self);
	float len = dir.normalize();

	if (len > data.reach)
		return BoxEdictsResult_t::Skip;

	// check angle if we aren't intersecting
	vec3_t shrink = { 2, 2, 2 };
	if (!boxes_intersect(check.e.absmin + shrink, check.e.absmax - shrink, data.self.e.absmin + shrink, data.self.e.absmax - shrink))
	{
		dir = (((check.e.absmin + check.e.absmax) / 2) - data.start).normalized();

		if (dir.dot(data.aim) < 0.70f)
			return BoxEdictsResult_t::Skip;
	}

	return BoxEdictsResult_t::Keep;
}

bool fire_player_melee(ASEntity &self, const vec3_t &in start, const vec3_t &in aim, int reach, int damage, int kick, mod_t mod)
{
	const uint MAX_HIT = 4;

	vec3_t reach_vec = { float(reach - 1), float(reach - 1), float(reach - 1) };
	array<edict_t @> targets;

	player_melee_data_t data(
		self,
		start,
		aim,
		reach
    );

	// find all the things we could maybe hit
	uint num = gi_BoxEdicts(self.e.absmin - reach_vec, self.e.absmax + reach_vec, targets, MAX_HIT, solidity_area_t::SOLID, fire_player_melee_BoxFilter, any(@data), false);

	if (num == 0)
		return false;

	bool was_hit = false;

	for (uint i = 0; i < num; i++)
	{
		edict_t @hit_handle = targets[i];
        ASEntity @hit = entities[hit_handle.s.number];

		if (!hit.e.inuse || !hit.takedamage)
			continue;
		else if (!CanDamage(self, hit))
			continue;

		// do the damage
		vec3_t closest_point_to_check = closest_point_to_box(start, hit.e.s.origin + hit.e.mins, hit.e.s.origin + hit.e.maxs);

		if ((hit.e.svflags & svflags_t::MONSTER) != 0)
			hit.pain_debounce_time -= random_time(time_ms(5), time_ms(75));

		if (mod.id == mod_id_t::CHAINFIST)
			T_Damage(hit, self, self, aim, closest_point_to_check, -aim, damage, kick / 2,
					 damageflags_t(damageflags_t::DESTROY_ARMOR | damageflags_t::NO_KNOCKBACK), mod);
		else
			T_Damage(hit, self, self, aim, closest_point_to_check, -aim, damage, kick / 2, damageflags_t::NO_KNOCKBACK, mod);

		was_hit = true;
	}

	return was_hit;
}

// *************************
// NUKE
// *************************

const gtime_t NUKE_DELAY = time_sec(4);
const gtime_t NUKE_TIME_TO_LIVE = time_sec(6);
const float	  NUKE_RADIUS = 512;
const int32 NUKE_DAMAGE = 400;
const gtime_t NUKE_QUAKE_TIME = time_sec(3);
const float	  NUKE_QUAKE_STRENGTH = 100;

void Nuke_Quake(ASEntity &self)
{
	uint i;
	ASEntity @e;

	if (self.last_move_time < level.time)
	{
		gi_positioned_sound(self.e.origin, self.e, soundchan_t::AUTO, self.noise_index, 0.75, ATTN_NONE, 0);
		self.last_move_time = level.time + time_ms(500);
	}

	for (i = 1; i < num_edicts; i++)
	{
        @e = entities[i];

		if (!e.e.inuse)
			continue;
		if (e.client is null)
			continue;
		if (e.groundentity is null)
			continue;

		@e.groundentity = null;
		e.velocity[0] += crandom() * 150;
		e.velocity[1] += crandom() * 150;
		e.velocity[2] = self.speed * (100.0f / e.mass);
	}

	if (level.time < self.timestamp)
		self.nextthink = level.time + FRAME_TIME_S;
	else
		G_FreeEdict(self);
}

void Nuke_Explode(ASEntity &ent)
{
	if (ent.teammaster.client !is null)
		PlayerNoise(ent.teammaster, ent.e.origin, player_noise_t::IMPACT);

	T_RadiusNukeDamage(ent, ent.teammaster, float(ent.dmg), ent, ent.dmg_radius, mod_id_t::NUKE);

	if (ent.dmg > NUKE_DAMAGE)
		gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage3.wav"), 1, ATTN_NORM, 0);

	gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), gi_soundindex("weapons/grenlx1a.wav"), 1, ATTN_NONE, 0);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1_BIG);
	gi_WritePosition(ent.e.origin);
	gi_multicast(ent.e.origin, multicast_t::PHS, false);

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::NUKEBLAST);
	gi_WritePosition(ent.e.origin);
	gi_multicast(ent.e.origin, multicast_t::ALL, false);

	// become a quake
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.noise_index = gi_soundindex("world/rumble.wav");
	@ent.think = Nuke_Quake;
	ent.speed = NUKE_QUAKE_STRENGTH;
	ent.timestamp = level.time + NUKE_QUAKE_TIME;
	ent.nextthink = level.time + FRAME_TIME_S;
	ent.last_move_time = time_zero;
}

void nuke_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.takedamage = false;
	if (attacker.classname == "nuke")
	{
		G_FreeEdict(self);
		return;
	}
	Nuke_Explode(self);
}

void Nuke_Think(ASEntity &ent)
{
	float			attenuation, default_atten = 1.8f;
	int				nuke_damage_multiplier;
	player_muzzle_t muzzleflash;

	nuke_damage_multiplier = ent.dmg / NUKE_DAMAGE;
	switch (nuke_damage_multiplier)
	{
	case 1:
		attenuation = default_atten / 1.4f;
		muzzleflash = player_muzzle_t::NUKE1;
		break;
	case 2:
		attenuation = default_atten / 2.0f;
		muzzleflash = player_muzzle_t::NUKE2;
		break;
	case 4:
		attenuation = default_atten / 3.0f;
		muzzleflash = player_muzzle_t::NUKE4;
		break;
	case 8:
		attenuation = default_atten / 5.0f;
		muzzleflash = player_muzzle_t::NUKE8;
		break;
	default:
		attenuation = default_atten;
		muzzleflash = player_muzzle_t::NUKE1;
		break;
	}

	if (ent.wait < level.time.secondsf())
		Nuke_Explode(ent);
	else if (level.time >= (time_sec(ent.wait) - NUKE_TIME_TO_LIVE))
	{
		ent.e.frame++;

		if (ent.e.frame > 11)
			ent.e.frame = 6;

		if ((gi_pointcontents(ent.e.origin) & contents_t(contents_t::SLIME | contents_t::LAVA)) != 0)
		{
			Nuke_Explode(ent);
			return;
		}

		@ent.think = Nuke_Think;
		ent.nextthink = level.time + time_hz(10);
		ent.health = 1;
		@ent.owner = null;

		gi_WriteByte(svc_t::muzzleflash);
		gi_WriteEntity(ent.e);
		gi_WriteByte(muzzleflash);
		gi_multicast(ent.e.origin, multicast_t::PHS, false);

		if (ent.timestamp <= level.time)
		{
			if ((time_sec(ent.wait) - level.time) <= (NUKE_TIME_TO_LIVE / 2.0f))
			{
				gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), gi_soundindex("weapons/nukewarn2.wav"), 1, attenuation, 0);
				ent.timestamp = level.time + time_ms(300);
			}
			else
			{
				gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), gi_soundindex("weapons/nukewarn2.wav"), 1, attenuation, 0);
				ent.timestamp = level.time + time_ms(500);
			}
		}
	}
	else
	{
		if (ent.timestamp <= level.time)
		{
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), gi_soundindex("weapons/nukewarn2.wav"), 1, attenuation, 0);
			ent.timestamp = level.time + time_sec(1);
		}
		ent.nextthink = level.time + FRAME_TIME_S;
	}
}

void nuke_bounce(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (tr.surface !is null && tr.surface.id != 0)
	{
		if (frandom() > 0.5f)
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("weapons/hgrenb1a.wav"), 1, ATTN_NORM, 0);
		else
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("weapons/hgrenb2a.wav"), 1, ATTN_NORM, 0);
	}
}

void fire_nuke(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int speed)
{
	ASEntity @nuke;
	vec3_t	 dir;
	vec3_t	 forward, right, up;
	int		 damage_modifier = P_DamageModifier(self);

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@nuke = G_Spawn();
	nuke.e.origin = start;
	nuke.velocity = aimdir * speed;
	nuke.velocity += up * (200 + crandom() * 10.0f);
	nuke.velocity += right * (crandom() * 10.0f);
	nuke.movetype = movetype_t::BOUNCE;
	nuke.e.clipmask = contents_t::MASK_PROJECTILE;
	nuke.e.solid = solid_t::BBOX;
	nuke.e.effects = effects_t(nuke.e.effects | effects_t::GRENADE);
	nuke.e.renderfx = renderfx_t(nuke.e.renderfx | renderfx_t::IR_VISIBLE);
	nuke.e.mins = { -8, -8, 0 };
	nuke.e.maxs = { 8, 8, 16 };
	nuke.e.modelindex = gi_modelindex("models/weapons/g_nuke/tris.md2");
	@nuke.owner = self;
	@nuke.teammaster = self;
	nuke.nextthink = level.time + FRAME_TIME_S;
	nuke.wait = (level.time + NUKE_DELAY + NUKE_TIME_TO_LIVE).secondsf();
	@nuke.think = Nuke_Think;
	@nuke.touch = nuke_bounce;

	nuke.health = 10000;
	nuke.takedamage = true;
	nuke.flags = ent_flags_t(nuke.flags | ent_flags_t::DAMAGEABLE);
	nuke.dmg = NUKE_DAMAGE * damage_modifier;
	if (damage_modifier == 1)
		nuke.dmg_radius = NUKE_RADIUS;
	else
		nuke.dmg_radius = NUKE_RADIUS + NUKE_RADIUS * (0.25f * damage_modifier);
	// this yields 1.0, 1.5, 2.0, 3.0 times radius

	nuke.classname = "nuke";
	@nuke.die = nuke_die;

	gi_linkentity(nuke.e);
}

// *************************
// TESLA
// *************************

const gtime_t TESLA_TIME_TO_LIVE = time_sec(30);
const float	  TESLA_DAMAGE_RADIUS = 128;
const int32   TESLA_DAMAGE = 3;
const int32   TESLA_KNOCKBACK = 8;

const gtime_t TESLA_ACTIVATE_TIME = time_sec(3);

const int32   TESLA_EXPLOSION_DAMAGE_MULT = 50; // this is the amount the damage is multiplied by for underwater explosions
const float	  TESLA_EXPLOSION_RADIUS = 200;

void tesla_remove(ASEntity &self)
{
	ASEntity @cur, next;

	self.takedamage = false;
	if (self.teamchain !is null)
	{
		@cur = self.teamchain;
		while (cur !is null)
		{
			@next = cur.teamchain;
			G_FreeEdict(cur);
			@cur = next;
		}
	}
	else if (self.air_finished)
		gi_Com_Print("tesla_mine without a field!\n");

	@self.owner = self.teammaster; // Going away, set the owner correctly.
	// PGM - grenade explode does damage to self->enemy
	@self.enemy = null;

	// play quad sound if quadded and an underwater explosion
	if ((self.dmg_radius != 0) && (self.dmg > (TESLA_DAMAGE * TESLA_EXPLOSION_DAMAGE_MULT)))
		gi_sound(self.e, soundchan_t::ITEM, gi_soundindex("items/damage3.wav"), 1, ATTN_NORM, 0);

	Grenade_Explode(self);
}

void tesla_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	tesla_remove(self);
}

void tesla_blow(ASEntity &self)
{
	self.dmg *= TESLA_EXPLOSION_DAMAGE_MULT;
	self.dmg_radius = TESLA_EXPLOSION_RADIUS;
	tesla_remove(self);
}

void tesla_zap(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
}

BoxEdictsResult_t tesla_think_active_BoxFilter(edict_t @check_handle, any @const data_v)
{
    ASEntity @check = entities[check_handle.s.number];
    ASEntity @self;
    data_v.retrieve(@self);

	if (!check.e.inuse)
		return BoxEdictsResult_t::Skip;
	if (check is self)
		return BoxEdictsResult_t::Skip;
	if (check.health < 1)
		return BoxEdictsResult_t::Skip;
	// don't hit teammates
	if (check.client !is null)
	{
		if (deathmatch.integer == 0)
			return BoxEdictsResult_t::Skip;
		else if (CheckTeamDamage(check, self.teammaster))
			return BoxEdictsResult_t::Skip;
	}
	if ((check.e.svflags & svflags_t::MONSTER) == 0 && (check.flags & ent_flags_t::DAMAGEABLE) == 0 && check.client is null)
		return BoxEdictsResult_t::Skip;

	// don't hit other teslas in SP/coop
	if (deathmatch.integer == 0 && !check.classname.empty() && (check.flags & ent_flags_t::TRAP) != 0)
		return BoxEdictsResult_t::Skip;

	return BoxEdictsResult_t::Keep;
}

void tesla_think_active(ASEntity &self)
{
	ASEntity @hit;
	vec3_t	 dir, start;
	trace_t	 tr;

	if (level.time > self.air_finished)
	{
		tesla_remove(self);
		return;
	}

	start = self.e.s.origin;
	start.z += 16;

	// find all the things we could maybe hit
	array<edict_t @> touch;
	uint num = gi_BoxEdicts(self.teamchain.e.absmin, self.teamchain.e.absmax, touch, MAX_EDICTS, solidity_area_t::SOLID, tesla_think_active_BoxFilter, any(@self), false);

	for (uint i = 0; i < num; i++)
	{
		// if the tesla died while zapping things, stop zapping.
		if (!(self.e.inuse))
			break;

		@hit = entities[touch[i].s.number];
		if (!hit.e.inuse)
			continue;
		if (hit is self)
			continue;
		if (hit.health < 1)
			continue;
		// don't hit teammates
		if (hit.client !is null)
		{
			if (deathmatch.integer == 0)
				continue;
			else if (CheckTeamDamage(hit, self.teamchain.owner))
				continue;
		}
		if ((hit.e.svflags & svflags_t::MONSTER) == 0 && (hit.flags & ent_flags_t::DAMAGEABLE) == 0 && hit.client is null)
			continue;

		tr = gi_traceline(start, hit.e.s.origin, self.e, contents_t::MASK_PROJECTILE);

		if (tr.fraction == 1 || tr.ent is hit.e)
		{
			dir = hit.e.s.origin - start;

			// PMM - play quad sound if it's above the "normal" damage
			if (self.dmg > TESLA_DAMAGE)
				gi_sound(self.e, soundchan_t::ITEM, gi_soundindex("items/damage3.wav"), 1, ATTN_NORM, 0);

			// PGM - don't do knockback to walking monsters
			if ((hit.e.svflags & svflags_t::MONSTER) != 0 && (hit.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
				T_Damage(hit, self, self.teammaster, dir, tr.endpos, tr.plane.normal,
						 self.dmg, 0, damageflags_t::NONE, mod_id_t::TESLA);
			else
				T_Damage(hit, self, self.teammaster, dir, tr.endpos, tr.plane.normal,
						 self.dmg, TESLA_KNOCKBACK, damageflags_t::NONE, mod_id_t::TESLA);

			gi_WriteByte(svc_t::temp_entity);
			gi_WriteByte(temp_event_t::LIGHTNING);
			gi_WriteEntity(self.e);	// source entity
			gi_WriteEntity(hit.e); // destination entity
			gi_WritePosition(start);
			gi_WritePosition(tr.endpos);
			gi_multicast(start, multicast_t::PVS, false);
		}
	}

	if (self.e.inuse)
	{
		@self.think = tesla_think_active;
		self.nextthink = level.time + time_hz(10);
	}
}

void tesla_activate(ASEntity &self)
{
	ASEntity @trigger;
	ASEntity @search;

	if ((gi_pointcontents(self.e.s.origin) & (contents_t::SLIME | contents_t::LAVA | contents_t::WATER)) != 0)
	{
		tesla_blow(self);
		return;
	}

	// only check for spawn points in deathmatch
	if (deathmatch.integer != 0)
	{
		@search = null;
		while ((@search = findradius(search, self.e.s.origin, 1.5f * TESLA_DAMAGE_RADIUS)) !is null)
		{
			// [Paril-KEX] don't allow traps to be placed near flags or teleporters
			// if it's a monster or player with health > 0
			// or it's a player start point
			// and we can see it
			// blow up
			if (!search.classname.empty() && ((deathmatch.integer != 0 &&
					((search.classname.findFirst("info_player_") == 0) ||
					(search.classname == "misc_teleporter_dest") ||
					(search.classname.findFirst("item_flag_") == 0)))) &&
				(visible(search, self)))
			{
				BecomeExplosion1(self);
				return;
			}
		}
	}

	@trigger = G_Spawn();
	trigger.e.s.origin = self.e.s.origin;
	trigger.e.mins = { -TESLA_DAMAGE_RADIUS, -TESLA_DAMAGE_RADIUS, self.e.mins[2] };
	trigger.e.maxs = { TESLA_DAMAGE_RADIUS, TESLA_DAMAGE_RADIUS, TESLA_DAMAGE_RADIUS };
	trigger.movetype = movetype_t::NONE;
	trigger.e.solid = solid_t::TRIGGER;
	@trigger.owner = self;
	@trigger.touch = tesla_zap;
	trigger.classname = "tesla trigger";
	// doesn't need to be marked as a teamslave since the move code for bounce looks for teamchains
	gi_linkentity(trigger.e);

	self.e.s.angles = vec3_origin;
	// clear the owner if in deathmatch
	if (deathmatch.integer != 0)
		@self.owner = null;
	@self.teamchain = trigger;
	@self.think = tesla_think_active;
	self.nextthink = level.time + FRAME_TIME_S;
	self.air_finished = level.time + TESLA_TIME_TO_LIVE;
}

void tesla_think(ASEntity &ent)
{
	if ((gi_pointcontents(ent.e.s.origin) & (contents_t::SLIME | contents_t::LAVA)) != 0)
	{
		tesla_remove(ent);
		return;
	}

	ent.e.s.angles = vec3_origin;

	if (ent.e.s.frame == 0)
		gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/teslaopen.wav"), 1, ATTN_NORM, 0);

	ent.e.s.frame++;
	if (ent.e.s.frame > 14)
	{
		ent.e.s.frame = 14;
		@ent.think = tesla_activate;
		ent.nextthink = level.time + time_hz(10);
	}
	else
	{
		if (ent.e.s.frame > 9)
		{
			if (ent.e.s.frame == 10)
			{
				if (ent.owner !is null && ent.owner.client !is null)
				{
					PlayerNoise(ent.owner, ent.e.s.origin, player_noise_t::WEAPON); // PGM
				}
				ent.e.s.skinnum = 1;
			}
			else if (ent.e.s.frame == 12)
				ent.e.s.skinnum = 2;
			else if (ent.e.s.frame == 14)
				ent.e.s.skinnum = 3;
		}
		@ent.think = tesla_think;
		ent.nextthink = level.time + time_hz(10);
	}
}

void tesla_lava(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if ((tr.contents & (contents_t::SLIME | contents_t::LAVA)) != 0)
	{
		tesla_blow(ent);
		return;
	}

	if (ent.velocity)
	{
		if (frandom() > 0.5f)
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/hgrenb1a.wav"), 1, ATTN_NORM, 0);
		else
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("weapons/hgrenb2a.wav"), 1, ATTN_NORM, 0);
	}
}

void fire_tesla(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int tesla_damage_multiplier, int speed)
{
	ASEntity @tesla;
	vec3_t	 dir;
	vec3_t	 forward, right, up;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	@tesla = G_Spawn();
	tesla.e.s.origin = start;
	tesla.velocity = aimdir * speed;

	float gravityAdjustment = level.gravity / 800.f;

	tesla.velocity += up * (200 + crandom() * 10.0f) * gravityAdjustment;
	tesla.velocity += right * (crandom() * 10.0f);

	tesla.e.s.angles = vec3_origin;
	tesla.movetype = movetype_t::BOUNCE;
	tesla.e.solid = solid_t::BBOX;
	tesla.e.s.effects = effects_t(tesla.e.s.effects | effects_t::GRENADE);
	tesla.e.s.renderfx = renderfx_t(tesla.e.s.renderfx | renderfx_t::IR_VISIBLE);
	tesla.e.mins = { -12, -12, 0 };
	tesla.e.maxs = { 12, 12, 20 };
	tesla.e.s.modelindex = gi_modelindex("models/weapons/g_tesla/tris.md2");

	@tesla.owner = self; // PGM - we don't want it owned by self YET.
	@tesla.teammaster = self;

	tesla.wait = (level.time + TESLA_TIME_TO_LIVE).secondsf();
	@tesla.think = tesla_think;
	tesla.nextthink = level.time + TESLA_ACTIVATE_TIME;

	// blow up on contact with lava & slime code
	@tesla.touch = tesla_lava;

	if (deathmatch.integer != 0)
		// PMM - lowered from 50 - 7/29/1998
		tesla.health = 20;
	else
		tesla.health = 50; // FIXME - change depending on skill?

	tesla.takedamage = true;
	@tesla.die = tesla_die;
	tesla.dmg = TESLA_DAMAGE * tesla_damage_multiplier;
	tesla.classname = "tesla_mine";
	tesla.flags = ent_flags_t(tesla.flags | ( ent_flags_t::DAMAGEABLE | ent_flags_t::TRAP ));
	tesla.e.clipmask = contents_t((contents_t::MASK_PROJECTILE | contents_t::SLIME | contents_t::LAVA) & ~contents_t::DEADMONSTER);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		tesla.e.clipmask = contents_t(tesla.e.clipmask & ~contents_t::PLAYER);

	tesla.flags = ent_flags_t(tesla.flags | ent_flags_t::MECHANICAL);

	gi_linkentity(tesla.e);
}

// *************************
//  HEATBEAM
// *************************

void fire_beams(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, const vec3_t &in offset, int damage, int kick, temp_event_t te_beam, temp_event_t te_impact, mod_t mod)
{
	trace_t	   tr;
	vec3_t	   dir;
	vec3_t	   forward, right, up;
	vec3_t	   end;
	vec3_t	   water_start, endpoint;
	bool	   water = false, underwater = false;
	contents_t content_mask = contents_t(contents_t::MASK_PROJECTILE | contents_t::MASK_WATER);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		content_mask = contents_t(content_mask & ~contents_t::PLAYER);

	vec3_t	   beam_endpt;

	dir = vectoangles(aimdir);
	AngleVectors(dir, forward, right, up);

	end = start + (forward * 8192);

	if ((gi_pointcontents(start) & contents_t::MASK_WATER) != 0)
	{
		underwater = true;
		water_start = start;
		content_mask = contents_t(content_mask & ~contents_t::MASK_WATER);
	}

	tr = gi_traceline(start, end, self.e, content_mask);

	// see if we hit water
	if ((tr.contents & contents_t::MASK_WATER) != 0)
	{
		water = true;
		water_start = tr.endpos;

		if (start != tr.endpos)
		{
			gi_WriteByte(svc_t::temp_entity);
			gi_WriteByte(temp_event_t::HEATBEAM_SPARKS);
			gi_WritePosition(water_start);
			gi_WriteDir(tr.plane.normal);
			gi_multicast(tr.endpos, multicast_t::PVS, false);
		}
		// re-trace ignoring water this time
		tr = gi_traceline(water_start, end, self.e, contents_t(content_mask & ~contents_t::MASK_WATER));
	}
	endpoint = tr.endpos;

	// halve the damage if target underwater
	if (water)
	{
		damage = damage / 2;
	}

	// send gun puff / flash
	if (!((tr.surface !is null) && (tr.surface.flags & surfflags_t::SKY) != 0))
	{
		if (tr.fraction < 1.0f)
		{
            ASEntity @hit = entities[tr.ent.s.number];

			if (hit.takedamage)
			{
				T_Damage(hit, self, self, aimdir, tr.endpos, tr.plane.normal, damage, kick, damageflags_t::ENERGY, mod);
			}
			else
			{
				if ((!water) && !(tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0))
				{
					// This is the truncated steam entry - uses 1+1+2 extra bytes of data
					gi_WriteByte(svc_t::temp_entity);
					gi_WriteByte(temp_event_t::HEATBEAM_STEAM);
					gi_WritePosition(tr.endpos);
					gi_WriteDir(tr.plane.normal);
					gi_multicast(tr.endpos, multicast_t::PVS, false);

					if (self.client !is null)
						PlayerNoise(self, tr.endpos, player_noise_t::IMPACT);
				}
			}
		}
	}

	// if went through water, determine where the end and make a bubble trail
	if ((water) || (underwater))
	{
		vec3_t pos;

		dir = tr.endpos - water_start;
		dir.normalize();
		pos = tr.endpos + (dir * -2);
		if ((gi_pointcontents(pos) & contents_t::MASK_WATER) != 0)
			tr.endpos = pos;
		else
			tr = gi_traceline(pos, water_start, tr.ent, contents_t::MASK_WATER);

		pos = water_start + tr.endpos;
		pos *= 0.5f;

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::BUBBLETRAIL2);
		gi_WritePosition(water_start);
		gi_WritePosition(tr.endpos);
		gi_multicast(pos, multicast_t::PVS, false);
	}

	if ((!underwater) && (!water))
	{
		beam_endpt = tr.endpos;
	}
	else
	{
		beam_endpt = endpoint;
	}

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(te_beam);
	gi_WriteEntity(self.e);
	gi_WritePosition(start);
	gi_WritePosition(beam_endpt);
	gi_multicast(self.e.s.origin, multicast_t::ALL, false);
}

/*
=================
fire_heat

Fires a single heat beam.  Zap.
=================
*/
void fire_heatbeam(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, const vec3_t &in offset, int damage, int kick, bool monster)
{
	if (monster)
		fire_beams(self, start, aimdir, offset, damage, kick, temp_event_t::MONSTER_HEATBEAM, temp_event_t::HEATBEAM_SPARKS, mod_id_t::HEATBEAM);
	else
		fire_beams(self, start, aimdir, offset, damage, kick, temp_event_t::HEATBEAM, temp_event_t::HEATBEAM_SPARKS, mod_id_t::HEATBEAM);
}

// *************************
//	BLASTER 2
// *************************

/*
=================
fire_blaster2

Fires a single green blaster bolt.  Used by monsters, generally.
=================
*/
void blaster2_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	mod_t mod;
	bool  damagestat;

	if (other is self.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.owner !is null && self.owner.client !is null)
		PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
	{
		// the only time players will be firing blaster2 bolts will be from the
		// defender sphere.
		if (self.owner !is null && self.owner.client !is null)
			mod = mod_id_t::DEFENDER_SPHERE;
		else
			mod = mod_id_t::BLASTER2;

		if (self.owner !is null)
		{
			damagestat = self.owner.takedamage;
			self.owner.takedamage = false;
			if (self.dmg >= 5)
				T_RadiusDamage(self, self.owner, float(self.dmg * 2), other, self.dmg_radius, damageflags_t::ENERGY, mod_id_t::UNKNOWN);
			T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::ENERGY, mod);
			self.owner.takedamage = damagestat;
		}
		else
		{
			if (self.dmg >= 5)
				T_RadiusDamage(self, self.owner, float(self.dmg * 2), other, self.dmg_radius, damageflags_t::ENERGY, mod_id_t::UNKNOWN);
			T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal, self.dmg, 1, damageflags_t::ENERGY, mod);
		}
	}
	else
	{
		// PMM - yeowch this will get expensive
		if (self.dmg >= 5)
			T_RadiusDamage(self, self.owner, float(self.dmg * 2), self.owner, self.dmg_radius, damageflags_t::ENERGY, mod_id_t::UNKNOWN);

		gi_WriteByte(svc_t::temp_entity);
		gi_WriteByte(temp_event_t::BLASTER2);
		gi_WritePosition(self.e.s.origin);
		gi_WriteDir(tr.plane.normal);
		gi_multicast(self.e.s.origin, multicast_t::PHS, false);
	}

	G_FreeEdict(self);
}

void fire_blaster2(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, effects_t effect, bool hyper)
{
	ASEntity @bolt;
	trace_t	 tr;

	@bolt = G_Spawn();
	bolt.e.s.origin = start;
	bolt.e.s.old_origin = start;
	bolt.e.s.angles = vectoangles(dir);
	bolt.velocity = dir * speed;
	bolt.e.svflags = svflags_t(bolt.e.svflags | svflags_t::PROJECTILE);
	bolt.movetype = movetype_t::FLYMISSILE;
	bolt.e.clipmask = contents_t::MASK_PROJECTILE;
	bolt.flags = ent_flags_t(bolt.flags | ent_flags_t::DODGE);

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		bolt.e.clipmask = contents_t(bolt.e.clipmask & ~contents_t::PLAYER);

	bolt.e.solid = solid_t::BBOX;
	bolt.e.s.effects = effects_t(bolt.e.s.effects | effect);
	if (effect != 0)
		bolt.e.s.effects = effects_t(bolt.e.s.effects | effects_t::TRACKER);
	bolt.dmg_radius = 128;
	bolt.e.s.modelindex = gi_modelindex("models/objects/laser/tris.md2");
	bolt.e.s.skinnum = 2;
	bolt.e.s.scale = 2.5f;
	@bolt.touch = blaster2_touch;

	@bolt.owner = self;
	bolt.nextthink = level.time + time_sec(2);
	@bolt.think = G_FreeEdict;
	bolt.dmg = damage;
	bolt.classname = "bolt";
	gi_linkentity(bolt.e);

	tr = gi_traceline(self.e.s.origin, bolt.e.s.origin, bolt.e, bolt.e.clipmask);
	if (tr.fraction < 1.0f)
	{
		bolt.e.s.origin = tr.endpos + (tr.plane.normal * 1.f);
		bolt.touch(bolt, entities[tr.ent.s.number], tr, false);
	}
}

// *************************
// tracker
// *************************

const damageflags_t TRACKER_DAMAGE_FLAGS = damageflags_t(damageflags_t::NO_POWER_ARMOR | damageflags_t::ENERGY | damageflags_t::NO_KNOCKBACK);
const damageflags_t TRACKER_IMPACT_FLAGS = damageflags_t(damageflags_t::NO_POWER_ARMOR | damageflags_t::ENERGY);

const gtime_t TRACKER_DAMAGE_TIME = time_ms(500);

void tracker_pain_daemon_think(ASEntity &self)
{
	const vec3_t pain_normal = { 0, 0, 1 };
	int	  hurt;

	if (!self.e.inuse)
		return;

	if ((level.time - self.timestamp) > TRACKER_DAMAGE_TIME)
	{
		if (self.enemy.client is null)
			self.enemy.e.s.effects = effects_t(self.enemy.e.s.effects & ~effects_t::TRACKERTRAIL);
		G_FreeEdict(self);
	}
	else
	{
		if (self.enemy.health > 0)
		{
			vec3_t center = (self.enemy.e.absmax + self.enemy.e.absmin) * 0.5f;

			T_Damage(self.enemy, self, self.owner, vec3_origin, center, pain_normal,
					 self.dmg, 0, TRACKER_DAMAGE_FLAGS, mod_id_t::TRACKER);

			// if we kill the player, we'll be removed.
			if (self.e.inuse)
			{
				// if we killed a monster, gib them.
				if (self.enemy.health < 1)
				{
					if (self.enemy.gib_health != 0)
						hurt = -self.enemy.gib_health;
					else
						hurt = 500;

					T_Damage(self.enemy, self, self.owner, vec3_origin, center,
							 pain_normal, hurt, 0, TRACKER_DAMAGE_FLAGS, mod_id_t::TRACKER);
				}

				self.nextthink = level.time + time_hz(10);

				if (self.enemy.client !is null)
					self.enemy.client.tracker_pain_time = self.nextthink;
				else
					self.enemy.e.s.effects = effects_t(self.enemy.e.s.effects | effects_t::TRACKERTRAIL);
			}
		}
		else
		{
			if (self.enemy.client is null)
			    self.enemy.e.s.effects = effects_t(self.enemy.e.s.effects & ~effects_t::TRACKERTRAIL);
			G_FreeEdict(self);
		}
	}
}

void tracker_pain_daemon_spawn(ASEntity &owner, ASEntity @enemy, int damage)
{
	ASEntity @daemon;

	if (enemy is null)
		return;

	@daemon = G_Spawn();
	daemon.classname = "pain daemon";
	@daemon.think = tracker_pain_daemon_think;
	daemon.nextthink = level.time;
	daemon.timestamp = level.time;
	@daemon.owner = owner;
	@daemon.enemy = enemy;
	daemon.dmg = damage;
}

void tracker_explode(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::TRACKER_EXPLOSION);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	G_FreeEdict(self);
}

void tracker_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	float damagetime;

	if (other is self.owner)
		return;

	if (tr.surface !is null && (tr.surface.flags & surfflags_t::SKY) != 0)
	{
		G_FreeEdict(self);
		return;
	}

	if (self.client !is null)
		PlayerNoise(self.owner, self.e.s.origin, player_noise_t::IMPACT);

	if (other.takedamage)
	{
		if ((other.e.svflags & svflags_t::MONSTER) != 0 || other.client !is null)
		{
			if (other.health > 0) // knockback only for living creatures
			{
				// PMM - kickback was times 4 .. reduced to 3
				// now this does no damage, just knockback
				T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal,
						 /* self->dmg */ 0, (self.dmg * 3), TRACKER_IMPACT_FLAGS, mod_id_t::TRACKER);

				if ((other.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
					other.velocity[2] += 140;

				damagetime = float(self.dmg) * 0.1f;
				damagetime = damagetime / TRACKER_DAMAGE_TIME.secondsf();

				tracker_pain_daemon_spawn(self.owner, other, int(damagetime));
			}
			else // lots of damage (almost autogib) for dead bodies
			{
				T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal,
						 self.dmg * 4, (self.dmg * 3), TRACKER_IMPACT_FLAGS, mod_id_t::TRACKER);
			}
		}
		else // full damage in one shot for inanimate objects
		{
			T_Damage(other, self, self.owner, self.velocity, self.e.s.origin, tr.plane.normal,
					 self.dmg, (self.dmg * 3), TRACKER_IMPACT_FLAGS, mod_id_t::TRACKER);
		}
	}

	tracker_explode(self);
	return;
}

void tracker_fly(ASEntity &self)
{
	vec3_t dest;
	vec3_t dir;
	vec3_t center;

	if ((self.enemy is null) || (!self.enemy.e.inuse) || (self.enemy.health < 1))
	{
		tracker_explode(self);
		return;
	}

	// PMM - try to hunt for center of enemy, if possible and not client
	if (self.enemy.client !is null)
	{
		dest = self.enemy.e.s.origin;
		dest[2] += self.enemy.viewheight;
	}
	// paranoia
	else if (!self.enemy.e.absmin || !self.enemy.e.absmax)
	{
		dest = self.enemy.e.s.origin;
	}
	else
	{
		center = (self.enemy.e.absmin + self.enemy.e.absmax) * 0.5f;
		dest = center;
	}

	dir = dest - self.e.s.origin;
	dir.normalize();
	self.e.s.angles = vectoangles(dir);
	self.velocity = dir * self.speed;
	self.monsterinfo.saved_goal = dest;

	self.nextthink = level.time + time_hz(10);
}

void fire_tracker(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, ASEntity @enemy)
{
	ASEntity @bolt;
	trace_t	 tr;

	@bolt = G_Spawn();
	bolt.e.s.origin = start;
	bolt.e.s.old_origin = start;
	bolt.e.s.angles = vectoangles(dir);
	bolt.velocity = dir * speed;
	bolt.e.svflags = svflags_t(bolt.e.svflags | svflags_t::PROJECTILE);
	bolt.movetype = movetype_t::FLYMISSILE;
	bolt.e.clipmask = contents_t::MASK_PROJECTILE;

	// [Paril-KEX]
	if (self.client !is null && !G_ShouldPlayersCollide(true))
		bolt.e.clipmask = contents_t(bolt.e.clipmask & ~contents_t::PLAYER);

	bolt.e.solid = solid_t::BBOX;
	bolt.speed = float(speed);
	bolt.e.s.effects = effects_t::TRACKER;
	bolt.e.s.sound = gi_soundindex("weapons/disrupt.wav");
	bolt.e.s.modelindex = gi_modelindex("models/proj/disintegrator/tris.md2");
	@bolt.touch = tracker_touch;
	@bolt.enemy = enemy;
	@bolt.owner = self;
	bolt.dmg = damage;
	bolt.classname = "tracker";
	gi_linkentity(bolt.e);

	if (enemy !is null)
	{
		bolt.nextthink = level.time + time_hz(10);
		@bolt.think = tracker_fly;
	}
	else
	{
		bolt.nextthink = level.time + time_sec(10);
		@bolt.think = G_FreeEdict;
	}

	tr = gi_traceline(self.e.s.origin, bolt.e.s.origin, bolt.e, bolt.e.clipmask);
	if (tr.fraction < 1.0f)
	{
		bolt.e.s.origin = tr.endpos + (tr.plane.normal * 1.f);
		bolt.touch(bolt, entities[tr.ent.s.number], tr, false);
	}
}