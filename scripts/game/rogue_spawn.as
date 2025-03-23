//
// ROGUE
//

//
// Monster spawning code
//
// Used by the carrier, the medic_commander, and the black widow
//
// The sequence to create a flying monster is:
//
//  FindSpawnPoint - tries to find suitable spot to spawn the monster in
//  CreateFlyMonster  - this verifies the point as good and creates the monster

// To create a ground walking monster:
//
//  FindSpawnPoint - same thing
//  CreateGroundMonster - this checks the volume and makes sure the floor under the volume is suitable
//

// FIXME - for the black widow, if we want the stalkers coming in on the roof, we'll have to tweak some things

//
// CreateMonster
//
ASEntity @CreateMonster(const vec3_t &in origin, const vec3_t &in angles, const string &in classname)
{
	ASEntity @newEnt = G_Spawn();

	newEnt.e.s.origin = origin;
	newEnt.e.s.angles = angles;
	newEnt.classname = classname;
	newEnt.monsterinfo.aiflags = ai_flags_t(newEnt.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

	newEnt.gravityVector = { 0, 0, -1 };
	ED_CallSpawn(newEnt);
	newEnt.e.s.renderfx = renderfx_t(newEnt.e.s.renderfx | renderfx_t::IR_VISIBLE);

	return newEnt;
}

ASEntity @CreateFlyMonster(const vec3_t &in origin, const vec3_t &in angles, const vec3_t &in mins, const vec3_t &in maxs, const string &in classname)
{
	if (!CheckSpawnPoint(origin, mins, maxs))
		return null;

	return (CreateMonster(origin, angles, classname));
}

// This is just a wrapper for CreateMonster that looks down height # of CMUs and sees if there
// are bad things down there or not

ASEntity @CreateGroundMonster(const vec3_t &in origin, const vec3_t &in angles, const vec3_t &in entMins, const vec3_t &in entMaxs, const string &in classname, float height)
{
	ASEntity @newEnt;

	// check the ground to make sure it's there, it's relatively flat, and it's not toxic
	if (!CheckGroundSpawnPoint(origin, entMins, entMaxs, height, -1.f))
		return null;

	@newEnt = CreateMonster(origin, angles, classname);
	if (newEnt is null)
		return null;

	return newEnt;
}

// FindSpawnPoint
// PMM - this is used by the medic commander (possibly by the carrier) to find a good spawn point
// if the startpoint is bad, try above the startpoint for a bit

bool FindSpawnPoint(const vec3_t &in startpoint, const vec3_t &in mins, const vec3_t &in maxs, vec3_t &out spawnpoint, float maxMoveUp, bool drop = true)
{
	spawnpoint = startpoint;

	// drop first
	if (!drop || !M_droptofloor_generic(spawnpoint, mins, maxs, false, null, contents_t::MASK_MONSTERSOLID, false, spawnpoint))
	{
		spawnpoint = startpoint;

		// fix stuck if we couldn't drop initially
		if (G_FixStuckObject_Generic(spawnpoint, mins, maxs, function(start, mins, maxs, end) {
				return gi_trace(start, mins, maxs, end, null, contents_t::MASK_MONSTERSOLID);
			}, spawnpoint) == stuck_result_t::NO_GOOD_POSITION)
			return false;

		// fixed, so drop again
		if (drop && !M_droptofloor_generic(spawnpoint, mins, maxs, false, null, contents_t::MASK_MONSTERSOLID, false, spawnpoint))
			return false; // ???
	}

	return true;
}

// FIXME - all of this needs to be tweaked to handle the new gravity rules
// if we ever want to spawn stuff on the roof

//
// CheckSpawnPoint
//
// PMM - checks volume to make sure we can spawn a monster there (is it solid?)
//
// This is all fliers should need

bool CheckSpawnPoint(const vec3_t &in origin, const vec3_t &in mins, const vec3_t &in maxs)
{
	trace_t tr;

	if (!mins || !maxs)
		return false;

	tr = gi_trace(origin, mins, maxs, origin, null, contents_t::MASK_MONSTERSOLID);
	if (tr.startsolid || tr.allsolid)
		return false;

	if (tr.ent !is world.e)
		return false;

	return true;
}

//
// CheckGroundSpawnPoint
//
// PMM - used for walking monsters
//  checks:
//		1)	is there a ground within the specified height of the origin?
//		2)	is the ground non-water?
//		3)	is the ground flat enough to walk on?
//

bool CheckGroundSpawnPoint(const vec3_t &in origin, const vec3_t &in entMins, const vec3_t &in entMaxs, float height, float gravity)
{
	if (!CheckSpawnPoint(origin, entMins, entMaxs))
		return false;

	if (M_CheckBottom_Fast_Generic(origin + entMins, origin + entMaxs, false))
		return true;

	if (M_CheckBottom_Slow_Generic(origin, entMins, entMaxs, null, contents_t::MASK_MONSTERSOLID, false, false))
		return true;

	return false;
}

// ****************************
// SPAWNGROW stuff
// ****************************

const gtime_t SPAWNGROW_LIFESPAN = time_ms(1000);

void spawngrow_think(ASEntity &self)
{
	if (level.time >= self.timestamp)
	{
		G_FreeEdict(self.target_ent);
		G_FreeEdict(self);
		return;
	}

	self.e.s.angles += self.avelocity * gi_frame_time_s;

	float t = 1.f - ((level.time - self.teleport_time).secondsf() / self.wait);

	self.e.s.scale = clamp(lerp(self.decel, self.accel, t) / 16.f, 0.001f, 16.f);
	self.e.s.alpha = t * t;

	self.nextthink += FRAME_TIME_MS;
}

vec3_t SpawnGro_laser_pos(ASEntity &ent)
{
	// pick random direction
	float theta = frandom(2 * PIf);
	float phi = acos(crandom());

	vec3_t d(
		sin(phi) * cos(theta),
		sin(phi) * sin(theta),
		cos(phi)
    );

	return ent.e.s.origin + (d * ent.owner.e.s.scale * 9.f);
}

void SpawnGro_laser_think(ASEntity &self)
{
	self.e.s.old_origin = SpawnGro_laser_pos(self);
	gi_linkentity(self.e);
	self.nextthink = level.time + time_ms(1);
}

void SpawnGrow_Spawn(const vec3_t &in startpos, float start_size, float end_size)
{
	ASEntity @ent;

	@ent = G_Spawn();
	ent.e.s.origin = startpos;

	ent.e.s.angles[0] = float(irandom(360));
	ent.e.s.angles[1] = float(irandom(360));
	ent.e.s.angles[2] = float(irandom(360));

	ent.avelocity[0] = frandom(280.f, 360.f) * 2.f;
	ent.avelocity[1] = frandom(280.f, 360.f) * 2.f;
	ent.avelocity[2] = frandom(280.f, 360.f) * 2.f;

	ent.e.solid = solid_t::NOT;
	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::IR_VISIBLE);
	ent.movetype = movetype_t::NONE;
	ent.classname = "spawngro";

	ent.e.s.modelindex = gi_modelindex("models/items/spawngro3/tris.md2");
	ent.e.s.skinnum = 1;

	ent.accel = start_size;
	ent.decel = end_size;
	@ent.think = spawngrow_think;

	ent.e.s.scale = clamp(start_size / 16.f, 0.001f, 8.f);

	ent.teleport_time = level.time;
	ent.wait = SPAWNGROW_LIFESPAN.secondsf();
	ent.timestamp = level.time + SPAWNGROW_LIFESPAN;

	ent.nextthink = level.time + FRAME_TIME_MS;

	gi_linkentity(ent.e);

	// [Paril-KEX]
	ASEntity @beam = @ent.target_ent = G_Spawn();
	beam.e.s.modelindex = MODELINDEX_WORLD;
	beam.e.s.renderfx = renderfx_t(renderfx_t::BEAM_LIGHTNING | renderfx_t::NO_ORIGIN_LERP);
	beam.e.s.frame = 1;
	beam.e.s.skinnum = 0x30303030;
	beam.classname = "spawngro_beam";
	beam.angle = end_size;
	@beam.owner = ent;
	beam.e.s.origin = ent.e.s.origin;
	@beam.think = SpawnGro_laser_think;
	beam.nextthink = level.time + time_ms(1);
	beam.e.s.old_origin = SpawnGro_laser_pos(beam);
	gi_linkentity(beam.e);
}