
/*QUAKED target_mal_laser (1 0 0) (-4 -4 -4) (4 4 4) START_ON RED GREEN BLUE YELLOW ORANGE FAT
Mal's laser
*/
void target_mal_laser_on(ASEntity &self)
{
	if (self.activator is null)
		@self.activator = self;
	self.spawnflags |= spawnflags::laser::ZAP | spawnflags::laser::ON;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	self.flags = ent_flags_t(self.flags | ent_flags_t::TRAP);
	// target_laser_think (self);
	self.nextthink = level.time + time_sec(self.wait + self.delay);
}

void target_mal_laser_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;
	if (self.spawnflags.has(spawnflags::laser::ON))
		target_laser_off(self);
	else
		target_mal_laser_on(self);
}

void mal_laser_think2(ASEntity &self)
{
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.think = mal_laser_think;
	self.nextthink = level.time + time_sec(self.wait);
	self.spawnflags |= spawnflags::laser::ZAP;
}

void mal_laser_think(ASEntity &self)
{
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	target_laser_think(self);
	@self.think = mal_laser_think2;
	self.nextthink = level.time + time_ms(100);
}

void SP_target_mal_laser(ASEntity &self)
{
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::NOT;
	self.e.s.renderfx = renderfx_t(self.e.s.renderfx | renderfx_t::BEAM);
	self.e.s.modelindex = MODELINDEX_WORLD; // must be non-zero
	self.flags = ent_flags_t(self.flags | ent_flags_t::TRAP_LASER_FIELD);

	// set the beam diameter
	if (self.spawnflags.has(spawnflags::laser::FAT))
		self.e.s.frame = 16;
	else
		self.e.s.frame = 4;

	// set the color
	if (self.spawnflags.has(spawnflags::laser::RED))
		self.e.s.skinnum = int(0xf2f2f0f0);
	else if (self.spawnflags.has(spawnflags::laser::GREEN))
		self.e.s.skinnum = int(0xd0d1d2d3);
	else if (self.spawnflags.has(spawnflags::laser::BLUE))
		self.e.s.skinnum = int(0xf3f3f1f1);
	else if (self.spawnflags.has(spawnflags::laser::YELLOW))
		self.e.s.skinnum = int(0xdcdddedf);
	else if (self.spawnflags.has(spawnflags::laser::ORANGE))
		self.e.s.skinnum = int(0xe0e1e2e3);

	G_SetMovedir(self, self.movedir);

	if (self.delay == 0)
		self.delay = 0.1f;

	if (self.wait == 0)
		self.wait = 0.1f;

	if (self.dmg == 0)
		self.dmg = 5;

	self.e.mins = { -8, -8, -8 };
	self.e.maxs = { 8, 8, 8 };

	self.nextthink = level.time + time_sec(self.delay);
	@self.think = mal_laser_think;

	@self.use = target_mal_laser_use;

	gi_linkentity(self.e);

	if (self.spawnflags.has(spawnflags::laser::ON))
		target_mal_laser_on(self);
	else
		target_laser_off(self);
}
// END	15-APR-98
