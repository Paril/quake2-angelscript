/*QUAKED misc_crashviper (1 .5 0) (-176 -120 -24) (176 120 72)
This is a large viper about to crash
*/
void SP_misc_crashviper(ASEntity &ent)
{
	if (ent.target.empty())
	{
		gi_Com_Print("{}: no target\n", ent);
		G_FreeEdict(ent);
		return;
	}

	if (ent.speed == 0)
		ent.speed = 300;

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/ships/bigviper/tris.md2");
	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 32 };

	@ent.think = func_train_find;
	ent.nextthink = level.time + time_hz(10);
	@ent.use = misc_viper_use;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = ent.speed;

	gi_linkentity(ent.e);
}

// RAFAEL
/*QUAKED misc_viper_missile (1 0 0) (-8 -8 -8) (8 8 8)
"dmg"	how much boom should the bomb make? the default value is 250
*/

void misc_viper_missile_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	vec3_t start, dir;
	vec3_t vec;

	@self.enemy = find_by_str<ASEntity>(null, "targetname", self.target);

	vec = self.enemy.e.s.origin;

	start = self.e.s.origin;
	dir = vec - start;
	dir.normalize();

	monster_fire_rocket(self, start, dir, self.dmg, 500, monster_muzzle_t::CHICK_ROCKET_1);

	self.nextthink = level.time + time_hz(10);
	@self.think = G_FreeEdict;
}

void SP_misc_viper_missile(ASEntity &self)
{
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::NOT;
	self.e.mins = { -8, -8, -8 };
	self.e.maxs = { 8, 8, 8 };

	if (self.dmg == 0)
		self.dmg = 250;

	self.e.s.modelindex = gi_modelindex("models/objects/bomb/tris.md2");

	@self.use = misc_viper_missile_use;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);

	gi_linkentity(self.e);
}

// RAFAEL 17-APR-98
/*QUAKED misc_transport (1 0 0) (-8 -8 -8) (8 8 8)
Maxx's transport at end of game
*/
void SP_misc_transport(ASEntity &ent)
{
	if (ent.target.empty())
	{
		gi_Com_Print("{}: no target\n", ent);
		G_FreeEdict(ent);
		return;
	}

	if (ent.speed == 0)
		ent.speed = 300;

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::NOT;
	ent.e.s.modelindex = gi_modelindex("models/objects/ship/tris.md2");

	ent.e.mins = { -16, -16, 0 };
	ent.e.maxs = { 16, 16, 32 };

	@ent.think = func_train_find;
	ent.nextthink = level.time + time_hz(10);
	@ent.use = misc_strogg_ship_use;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::NOCLIENT);
	ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = ent.speed;

	if (!ent.spawnflags.has(spawnflags::train::START_ON))
		ent.spawnflags |= spawnflags::train::START_ON;

	gi_linkentity(ent.e);
}
// END 17-APR-98

/*QUAKED misc_amb4 (1 0 0) (-16 -16 -16) (16 16 16)
Mal's amb4 loop entity
*/
cached_soundindex amb4sound("world/amb4.wav");

void amb4_think(ASEntity &ent)
{
	ent.nextthink = level.time + time_sec(2.7);
	gi_sound(ent.e, soundchan_t::VOICE, amb4sound, 1, ATTN_NONE, 0);
}

void SP_misc_amb4(ASEntity &ent)
{
	@ent.think = amb4_think;
	ent.nextthink = level.time + time_sec(1);
	amb4sound.precache();
	gi_linkentity(ent.e);
}

/*QUAKED misc_nuke (1 0 0) (-16 -16 -16) (16 16 16)
 */
void SP_misc_nuke(ASEntity &ent)
{
	@ent.use = target_killplayers_use;
}