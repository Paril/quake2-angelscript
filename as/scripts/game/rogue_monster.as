
// ROGUE
void monster_fire_blaster2(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, monster_muzzle_t flashtype, effects_t effect)
{
	fire_blaster2(self, start, dir, damage, speed, effect, false);
	monster_muzzleflash(self, start, flashtype);
}

void monster_fire_tracker(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed, ASEntity @enemy, monster_muzzle_t flashtype)
{
	fire_tracker(self, start, dir, damage, speed, enemy);
	monster_muzzleflash(self, start, flashtype);
}

void monster_fire_heatbeam(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, const vec3_t &in offset, int damage, int kick, monster_muzzle_t flashtype)
{
	fire_heatbeam(self, start, dir, offset, damage, kick, true);
	monster_muzzleflash(self, start, flashtype);
}
// ROGUE

void stationarymonster_triggered_spawn(ASEntity &self)
{
	self.e.solid = solid_t::BBOX;
	self.movetype = movetype_t::NONE;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	self.air_finished = level.time + time_sec(12);
	gi_linkentity(self.e);

	KillBox(self, false);

	// FIXME - why doesn't this happen with real monsters?
	self.spawnflags &= ~spawnflags::monsters::TRIGGER_SPAWN;

	stationarymonster_start_go(self);

	if (self.enemy !is null && !(self.spawnflags.has(spawnflags::monsters::AMBUSH)) && (self.enemy.flags & ent_flags_t::NOTARGET) == 0)
	{
		if ((self.enemy.flags & ent_flags_t::DISGUISED) == 0) // PGM
			FoundTarget(self);
		else // PMM - just in case, make sure to clear the enemy so FindTarget doesn't get confused
			@self.enemy = null;
	}
	else
	{
		@self.enemy = null;
	}
}

void stationarymonster_triggered_spawn_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	// we have a one frame delay here so we don't telefrag the guy who activated us
	@self.think = stationarymonster_triggered_spawn;
	self.nextthink = level.time + FRAME_TIME_S;
	if (activator !is null && activator.client !is null)
		@self.enemy = activator;
	@self.use = monster_use;
}

void stationarymonster_triggered_start(ASEntity &self)
{
	self.e.solid = solid_t::NOT;
	self.movetype = movetype_t::NONE;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.nextthink = time_zero;
	@self.use = stationarymonster_triggered_spawn_use;
}

void stationarymonster_start_go(ASEntity &self)
{
	if (self.yaw_speed == 0)
		self.yaw_speed = 20;

	monster_start_go(self);

	if (self.spawnflags.has(spawnflags::monsters::TRIGGER_SPAWN))
		stationarymonster_triggered_start(self);
}

void stationarymonster_start(ASEntity &self, const spawn_temp_t @st)
{
	self.flags = ent_flags_t(self.flags | ent_flags_t::STATIONARY);
	@self.think = stationarymonster_start_go;
	monster_start(self, st);

	// fix viewheight
	self.viewheight = 0;
}

void monster_done_dodge(ASEntity &self)
{
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::DODGING);
	if (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING)
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
}