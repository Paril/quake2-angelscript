
//
// monster weapons
//
void monster_muzzleflash(ASEntity &self, const vec3_t &in start, monster_muzzle_t id)
{
	if (id <= 255)
		gi_WriteByte(svc_t::muzzleflash2);
	else
		gi_WriteByte(svc_t::muzzleflash3);

	gi_WriteEntity(self.e);

	if (id <= 255)
		gi_WriteByte(id);
	else
		gi_WriteShort(id);

	gi_multicast(start, multicast_t::PHS, false);
}

void monster_fire_bullet(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int kick, int hspread,
						 int vspread, monster_muzzle_t flashtype)
{
	fire_bullet(self, start, dir, damage, kick, hspread, vspread, mod_id_t::UNKNOWN);
	monster_muzzleflash(self, start, flashtype);
}

void monster_fire_shotgun(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int hspread,
						  int vspread, int count, monster_muzzle_t flashtype)
{
	fire_shotgun(self, start, aimdir, damage, kick, hspread, vspread, count, mod_id_t::UNKNOWN);
	monster_muzzleflash(self, start, flashtype);
}

ASEntity @monster_fire_blaster(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed,
						       monster_muzzle_t flashtype, effects_t effect)
{
	ASEntity @e = fire_blaster(self, start, dir, damage, speed, effect, mod_id_t::BLASTER);
	monster_muzzleflash(self, start, flashtype);
	return e;
}

void monster_fire_flechette(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed,
						    monster_muzzle_t flashtype)
{
	fire_flechette(self, start, dir, damage, speed, damage / 2);
	monster_muzzleflash(self, start, flashtype);
}

void monster_fire_grenade(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int speed,
						  monster_muzzle_t flashtype, float right_adjust, float up_adjust)
{
	fire_grenade(self, start, aimdir, damage, speed, time_sec(2.5), damage + 40.f, right_adjust, up_adjust, true);
	monster_muzzleflash(self, start, flashtype);
}

void monster_fire_rocket(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, int damage, int speed,
						 monster_muzzle_t flashtype)
{
	fire_rocket(self, start, dir, damage, speed, float(damage + 20), damage);
	monster_muzzleflash(self, start, flashtype);
}

bool monster_fire_railgun(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick,
						  monster_muzzle_t flashtype)
{
	if ((gi_pointcontents(start) & contents_t::MASK_SOLID) != 0)
		return false;

	bool hit = fire_rail(self, start, aimdir, damage, kick);

	monster_muzzleflash(self, start, flashtype);

	return hit;
}

void monster_fire_bfg(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int speed, int kick,
					  float damage_radius, monster_muzzle_t flashtype)
{
	fire_bfg(self, start, aimdir, damage, speed, damage_radius);
	monster_muzzleflash(self, start, flashtype);
}

const float MELEE_DISTANCE = 50;

const gtime_t HOLD_FOREVER = time_ms(int64_limits::max);

// [Paril-KEX]
void monster_footstep(ASEntity &self)
{
	if (self.groundentity !is null)
		self.e.s.event = entity_event_t::OTHER_FOOTSTEP;
}

// [Paril-KEX]
vec3_t M_ProjectFlashSource(ASEntity &self, const vec3_t &in offset, const vec3_t &in forward, const vec3_t &in right)
{
	return G_ProjectSource(self.e.s.origin, (self.e.s.scale != 0) ? (offset * self.e.s.scale) : offset, forward, right);
}

// [Paril-KEX] check if shots fired from the given offset
// might be blocked by something
bool M_CheckClearShot(ASEntity &self, const vec3_t &in offset, vec3_t &out start = void)
{
	// no enemy, just do whatever
	if (self.enemy is null)
		return false;

	vec3_t f, r;

	vec3_t real_angles = { self.e.s.angles.x, self.ideal_yaw, 0.0f };

	AngleVectors(real_angles, f, r);
	start = M_ProjectFlashSource(self, offset, f, r);

	vec3_t target;

	bool is_blind = self.monsterinfo.attack_state == ai_attack_state_t::BLIND ||
                    (self.monsterinfo.aiflags & (ai_flags_t::MANUAL_STEERING | ai_flags_t::LOST_SIGHT)) != 0;
	
	if (is_blind)
		target = self.monsterinfo.blind_fire_target;
	else
		target = self.enemy.e.s.origin + vec3_t(0, 0, float(self.enemy.viewheight));

	trace_t tr = gi_traceline(start, target, self.e, contents_t(contents_t::MASK_PROJECTILE & ~contents_t::DEADMONSTER));

	if (tr.ent is self.enemy.e || tr.ent.client !is null || (tr.fraction > 0.8f && !tr.startsolid))
		return true;

	if (!is_blind)
	{
		target = self.enemy.e.s.origin;

		tr = gi_traceline(start, target, self.e, contents_t(contents_t::MASK_PROJECTILE & ~contents_t::DEADMONSTER));

		if (tr.ent is self.enemy.e || tr.ent.client !is null || (tr.fraction > 0.8f && !tr.startsolid))
			return true;
	}

	return false;
}

void M_CheckGround(ASEntity &ent, contents_t mask)
{
	vec3_t	point;
	trace_t trace;

	// [Paril-KEX]
	if (ent.no_gravity_time > level.time)
		return;

	if ((ent.flags & (ent_flags_t::SWIM | ent_flags_t::FLY)) != 0)
		return;

	if ((ent.velocity.z * ent.gravityVector.z) < -100) // PGM
	{
		@ent.groundentity = null;
		return;
	}

	// if the hull point one-quarter unit down is solid the entity is on ground
	point = ent.e.s.origin;
	point.z += (0.25f * ent.gravityVector.z); // PGM

	trace = gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, point, ent.e, mask);

	// check steepness
	// PGM
	if (ent.gravityVector.z < 0) // normal gravity
	{
		if (trace.plane.normal.z < 0.7f && !trace.startsolid)
		{
			@ent.groundentity = null;
			return;
		}
	}
	else // inverted gravity
	{
		if (trace.plane.normal.z > -0.7f && !trace.startsolid)
		{
			@ent.groundentity = null;
			return;
		}
	}
	// PGM

	if (!trace.startsolid && !trace.allsolid)
	{
		ent.e.s.origin = trace.endpos;
		@ent.groundentity = entities[trace.ent.s.number];
		ent.groundentity_linkcount = trace.ent.linkcount;
		ent.velocity.z = 0;
	}
}

void M_CatagorizePosition(ASEntity &self, const vec3_t &in in_point, water_level_t &out waterlevel, contents_t &out watertype)
{
	vec3_t	   point;
	contents_t cont;

	//
	// get waterlevel
	//
	point = in_point;
	if (self.gravityVector.z > 0)
		point.z += self.e.maxs.z - 1;
	else
		point.z += self.e.mins.z + 1;
	cont = gi_pointcontents(point);

	if ((cont & contents_t::MASK_WATER) == 0)
	{
		waterlevel = water_level_t::NONE;
		watertype = contents_t::NONE;
		return;
	}

	watertype = cont;
	waterlevel = water_level_t::FEET;
	point.z += 26;
	cont = gi_pointcontents(point);
	if ((cont & contents_t::MASK_WATER) == 0)
		return;

	waterlevel = water_level_t::WAIST;
	point.z += 22;
	cont = gi_pointcontents(point);
	if ((cont & contents_t::MASK_WATER) != 0)
		waterlevel = water_level_t::UNDER;
}

bool M_ShouldReactToPain(ASEntity &self, const mod_t &in mod)
{
	if ((self.monsterinfo.aiflags & (ai_flags_t::DUCKED | ai_flags_t::COMBAT_POINT))  != 0)
		return false;

	return mod.id == mod_id_t::CHAINFIST || skill.integer < 3;
}

void M_WorldEffects(ASEntity &ent)
{
	int dmg;

	if (ent.health > 0)
	{
		bool take_drown_damage = false;

		if ((ent.flags & ent_flags_t::SWIM) == 0)
		{
			if (ent.waterlevel < water_level_t::UNDER)
				ent.air_finished = level.time + time_sec(12);
			else if (ent.air_finished < level.time)
				take_drown_damage = true;
		}
		else
		{
			if (ent.waterlevel > water_level_t::NONE)
				ent.air_finished = level.time + time_sec(9);
			else if (ent.air_finished < level.time)
				take_drown_damage = true;
		}

		if (take_drown_damage && ent.pain_debounce_time < level.time)
		{
			dmg = 2 + int(2 * floor((level.time - ent.air_finished).secondsf()));
			if (dmg > 15)
				dmg = 15;
			T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, dmg, 0, damageflags_t::NO_ARMOR, mod_id_t::WATER);
			ent.pain_debounce_time = level.time + time_sec(1);
		}
	}

	if (ent.waterlevel == water_level_t::NONE)
	{
		if ((ent.flags & ent_flags_t::INWATER) != 0)
		{
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_out.wav"), 1, ATTN_NORM, 0);
			ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::INWATER);
		}
	}
	else
	{
		if ((ent.watertype & contents_t::LAVA) != 0 && (ent.flags & ent_flags_t::IMMUNE_LAVA) == 0)
		{
			if (ent.damage_debounce_time < level.time)
			{
				ent.damage_debounce_time = level.time + time_ms(100);
				T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, 10 * ent.waterlevel, 0, damageflags_t::NONE, mod_id_t::LAVA);
			}
		}
		if ((ent.watertype & contents_t::SLIME) != 0 && (ent.flags & ent_flags_t::IMMUNE_SLIME) == 0)
		{
			if (ent.damage_debounce_time < level.time)
			{
				ent.damage_debounce_time = level.time + time_ms(100);
				T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, 4 * ent.waterlevel, 0, damageflags_t::NONE, mod_id_t::SLIME);
			}
		}

		if ((ent.flags & ent_flags_t::INWATER) == 0)
		{
			if ((ent.watertype & contents_t::LAVA) != 0)
			{
				if ((ent.e.svflags & svflags_t::MONSTER) != 0 && ent.health > 0)
				{
					if (frandom() <= 0.5f)
						gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/lava1.wav"), 1, ATTN_NORM, 0);
					else
						gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/lava2.wav"), 1, ATTN_NORM, 0);
				}
				else
					gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_in.wav"), 1, ATTN_NORM, 0);
			}
			else if ((ent.watertype & contents_t::SLIME) != 0)
				gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_in.wav"), 1, ATTN_NORM, 0);
			else if ((ent.watertype & contents_t::WATER) != 0)
				gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_in.wav"), 1, ATTN_NORM, 0);

			ent.flags = ent_flags_t(ent.flags | ent_flags_t::INWATER);
			ent.damage_debounce_time = time_zero;
		}
	}
}

bool M_droptofloor_generic(const vec3_t &in origin, const vec3_t &in mins, const vec3_t &in maxs, bool ceiling, ASEntity @ignore, contents_t mask, bool allow_partial, vec3_t &out out_origin)
{
	vec3_t	end;
	trace_t trace;

    out_origin = origin;

	// PGM
	if (gi_trace(origin, mins, maxs, origin, ignore !is null ? ignore.e : null, mask).startsolid)
	{
		if (!ceiling)
			out_origin.z += 1;
		else
			out_origin.z -= 1;
	}

	if (!ceiling)
	{
		end = out_origin;
		end.z -= 256;
	}
	else
	{
		end = out_origin;
		end.z += 256;
	}
	// PGM

	trace = gi_trace(out_origin, mins, maxs, end, ignore !is null ? ignore.e : null, mask);

	if (trace.fraction == 1 || trace.allsolid || (!allow_partial && trace.startsolid))
		return false;

	out_origin = trace.endpos;
	return true;
}

bool M_droptofloor(ASEntity &ent)
{
	contents_t mask = G_GetClipMask(ent);

	if (!ent.spawnflags.has(spawnflags::monsters::NO_DROP))
	{
		if (!M_droptofloor_generic(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.gravityVector.z > 0, ent, mask, true, ent.e.s.origin))
			return false;
	}
	else
	{
		if (gi_trace(ent.e.s.origin, ent.e.mins, ent.e.maxs, ent.e.s.origin, ent.e, mask).startsolid)
			return false;
	}

	gi_linkentity(ent.e);
	M_CheckGround(ent, mask);
	M_CatagorizePosition(ent, ent.e.s.origin, ent.waterlevel, ent.watertype);

	return true;
}

void M_SetEffects(ASEntity &ent)
{
	ent.e.s.effects = effects_t(ent.e.s.effects & ~(effects_t::COLOR_SHELL | effects_t::POWERSCREEN | effects_t::DOUBLE | effects_t::QUAD | effects_t::PENT | effects_t::FLIES));
	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx & ~(renderfx_t::SHELL_RED | renderfx_t::SHELL_GREEN | renderfx_t::SHELL_BLUE | renderfx_t::SHELL_DOUBLE));

	ent.e.s.sound = 0;
	ent.e.s.loop_attenuation = 0;

	// we're gibbed
	if ((ent.e.s.renderfx & renderfx_t::LOW_PRIORITY) != 0)
		return;

	if (ent.monsterinfo.weapon_sound != 0 && ent.health > 0)
	{
		ent.e.s.sound = ent.monsterinfo.weapon_sound;
		ent.e.s.loop_attenuation = ATTN_NORM;
	}
	else if (ent.monsterinfo.engine_sound != 0)
		ent.e.s.sound = ent.monsterinfo.engine_sound;

	if ((ent.monsterinfo.aiflags & ai_flags_t::RESURRECTING) != 0)
	{
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::COLOR_SHELL);
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_RED);
	}

	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::DOT_SHADOW);

	// no power armor/powerup effects if we died
	if (ent.health <= 0)
		return;

	if (ent.powerarmor_time > level.time)
	{
		if (ent.monsterinfo.power_armor_type == item_id_t::ITEM_POWER_SCREEN)
		{
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::POWERSCREEN);
		}
		else if (ent.monsterinfo.power_armor_type == item_id_t::ITEM_POWER_SHIELD)
		{
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::COLOR_SHELL);
			ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_GREEN);
		}
	}

	// PMM - new monster powerups
	if (ent.monsterinfo.quad_time > level.time)
	{
		if (G_PowerUpExpiring(ent.monsterinfo.quad_time))
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::QUAD);
	}

	if (ent.monsterinfo.double_time > level.time)
	{
		if (G_PowerUpExpiring(ent.monsterinfo.double_time))
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::DOUBLE);
	}

	if (ent.monsterinfo.invincible_time > level.time)
	{
		if (G_PowerUpExpiring(ent.monsterinfo.invincible_time))
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::PENT);
	}
}

bool M_AllowSpawn( ASEntity &self ) {
	if ( deathmatch.integer != 0 && ai_allow_dm_spawn.integer == 0 ) {
		return false;
	}
	return true;
}

void M_SetAnimation(ASEntity &self, const mmove_t @move, bool instant = true)
{
	// [Paril-KEX] free the beams if we switch animations.
	if (self.beam !is null)
	{
		self.beam.Free();
		@self.beam = null;
	}

	if (self.beam2 !is null)
	{
		self.beam2.Free();
		@self.beam2 = null;
	}

	// instant switches will cause active_move to change on the next frame
	if (instant)
	{
		@self.monsterinfo.active_move = move;
		@self.monsterinfo.next_move = null;
		return;
	}

	// these wait until the frame is ready to be finished
	@self.monsterinfo.next_move = move;
}

void M_MoveFrame(ASEntity &self)
{
	const mmove_t @move = self.monsterinfo.active_move;

	// [Paril-KEX] high tick rate adjustments;
	// monsters still only step frames and run thinkfunc's at
	// 10hz, but will run aifuncs at full speed with
	// distance spread over 10hz

	self.nextthink = level.time + FRAME_TIME_S;

	// time to run next 10hz move yet?
	bool run_frame = self.monsterinfo.next_move_time <= level.time;

	// we asked nicely to switch frames when the timer ran up
	if (run_frame && self.monsterinfo.next_move !is null && !(self.monsterinfo.active_move is self.monsterinfo.next_move))
	{
		M_SetAnimation(self, self.monsterinfo.next_move, true);
		@move = self.monsterinfo.active_move;
	}

	if (move is null)
		return;

	// no, but maybe we were explicitly forced into another move (pain,
	// death, etc)
	if (!run_frame)
		run_frame = (self.e.s.frame < move.firstframe || self.e.s.frame > move.lastframe);

	if (run_frame)
	{
		// [Paril-KEX] allow next_move and nextframe to work properly after an endfunc
		bool explicit_frame = false;

		if ((self.monsterinfo.nextframe != 0) && (self.monsterinfo.nextframe >= move.firstframe) &&
			(self.monsterinfo.nextframe <= move.lastframe))
		{
			self.e.s.frame = self.monsterinfo.nextframe;
			self.monsterinfo.nextframe = 0;
		}
		else
		{
			if (self.e.s.frame == move.lastframe)
			{
				if (move.endfunc !is null)
				{
					move.endfunc(self);

					if (self.monsterinfo.next_move !is null)
					{
						M_SetAnimation(self, self.monsterinfo.next_move, true);

						if (self.monsterinfo.nextframe != 0)
						{
							self.e.s.frame = self.monsterinfo.nextframe;
							self.monsterinfo.nextframe = 0;
							explicit_frame = true;
						}
					}

					// regrab move, endfunc is very likely to change it
					@move = self.monsterinfo.active_move;

					// check for death
					if ((self.e.svflags & svflags_t::DEADMONSTER) != 0)
						return;
				}
			}

			if (self.e.s.frame < move.firstframe || self.e.s.frame > move.lastframe)
			{
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::HOLD_FRAME);
				self.e.s.frame = move.firstframe;
			}
			else if (!explicit_frame)
			{
				if ((self.monsterinfo.aiflags & ai_flags_t::HOLD_FRAME) == 0)
				{
					self.e.s.frame++;
					if (self.e.s.frame > move.lastframe)
						self.e.s.frame = move.firstframe;
				}
			}
		}

		if ((self.monsterinfo.aiflags & ai_flags_t::HIGH_TICK_RATE) != 0)
			self.monsterinfo.next_move_time = level.time;
		else
			self.monsterinfo.next_move_time = level.time + time_hz(10);

		if ((self.monsterinfo.nextframe != 0) && !((self.monsterinfo.nextframe >= move.firstframe) &&
			(self.monsterinfo.nextframe <= move.lastframe)))
			self.monsterinfo.nextframe = 0;
	}

	// NB: frame thinkfunc can be called on the same frame
	// as the animation changing

	int32 index = self.e.s.frame - move.firstframe;
	if (move.frames[index].aifunc !is null)
	{
		if ((self.monsterinfo.aiflags & ai_flags_t::HOLD_FRAME) == 0)
		{
			float dist = move.frames[index].dist * self.monsterinfo.scale;
			dist /= gi_tick_rate / 10;
			move.frames[index].aifunc(self, dist);
		}
		else
			move.frames[index].aifunc(self, 0);
	}

	if (run_frame && move.frames[index].thinkfunc !is null)
		move.frames[index].thinkfunc(self);

	if (move.frames[index].lerp_frame != -1)
	{
		self.e.s.renderfx = renderfx_t(self.e.s.renderfx | renderfx_t::OLD_FRAME_LERP);
		self.e.s.old_frame = move.frames[index].lerp_frame;
	}
}

void G_MonsterKilled(ASEntity &self)
{
	level.killed_monsters++;

	if (coop.integer != 0 && self.enemy !is null && self.enemy.client !is null)
		self.enemy.client.resp.score++;
/*
	if (g_debug_monster_kills->integer)
	{
		bool found = false;

		for (auto &ent : level.monsters_registered)
		{
			if (ent == self)
			{
				ent = nullptr;
				found = true;
				break;
			}
		}

		if (!found)
		{
#if defined(_DEBUG) && defined(KEX_PLATFORM_WINPC)
			__debugbreak();
#endif
			gi.Center_Print(&g_edicts[1], "found missing monster?");
		}

		if (level.killed_monsters == level.total_monsters)
		{
			gi.Center_Print(&g_edicts[1], "all monsters dead");
		}
	}
*/
}

void M_ProcessPain(ASEntity &e)
{
	if (e.monsterinfo.damage_blood == 0)
		return;

	if (e.health <= 0)
	{
		// ROGUE
		if ((e.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
		{
			if (e.enemy !is null && e.enemy.e.inuse && (e.enemy.e.svflags & svflags_t::MONSTER) != 0) // god, I hope so
			{
				cleanupHealTarget(e.enemy);
			}

			// clean up self
			e.monsterinfo.aiflags = ai_flags_t(e.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
		}
		// ROGUE

		bool dead_commander_check = false;

		if (!e.deadflag)
		{
			@e.enemy = e.monsterinfo.damage_attacker;

			// ROGUE
			// ROGUE - free up slot for spawned monster if it's spawned
			if ((e.monsterinfo.aiflags & ai_flags_t::SPAWNED_COMMANDER) != 0 && (e.monsterinfo.aiflags & ai_flags_t::SPAWNED_NEEDS_GIB) == 0)
				dead_commander_check = true;

			if ((e.monsterinfo.aiflags & ai_flags_t::DO_NOT_COUNT) == 0 && !e.spawnflags.has(spawnflags::monsters::DEAD))
				G_MonsterKilled(e);
		
			@e.touch = null;
			monster_death_use(e);
		}

		e.die(e, e.monsterinfo.damage_inflictor, e.monsterinfo.damage_attacker, e.monsterinfo.damage_blood, e.monsterinfo.damage_from, e.monsterinfo.damage_mod);
		
		// [Paril-KEX] medic commander only gets his slots back after the monster is gibbed, since we can revive them
		if (e.health <= e.gib_health)
		{
			if ((e.monsterinfo.aiflags & ai_flags_t::SPAWNED_COMMANDER) != 0 && (e.monsterinfo.aiflags & ai_flags_t::SPAWNED_NEEDS_GIB) != 0)
				dead_commander_check = true;
		}

		if (dead_commander_check)
		{
			ASEntity @commander = e.monsterinfo.commander;

			if (commander !is null && commander.e.inuse)
				commander.monsterinfo.monster_used = max(0, commander.monsterinfo.monster_used - e.monsterinfo.slots_from_commander);

			@e.monsterinfo.commander = null;
		}

		if (e.e.inuse && e.health > e.gib_health && e.e.s.frame == e.monsterinfo.active_move.lastframe)
		{
			e.e.s.frame -= irandom(1, 3);

			if (e.groundentity !is null && e.movetype == movetype_t::TOSS && (e.flags & ent_flags_t::STATIONARY) == 0)
				e.e.s.angles.y += brandom() ? 4.5f : -4.5f;
		}
	}
	else
		e.pain(e, e.monsterinfo.damage_attacker, float(e.monsterinfo.damage_knockback), e.monsterinfo.damage_blood, e.monsterinfo.damage_mod);

	if (!e.e.inuse)
		return;

	if (e.monsterinfo.setskin !is null)
		e.monsterinfo.setskin(e);

	e.monsterinfo.damage_blood = 0;
	e.monsterinfo.damage_knockback = 0;
	@e.monsterinfo.damage_attacker = @e.monsterinfo.damage_inflictor = null;

	// [Paril-KEX] fire health target
	if (!e.healthtarget.empty())
	{
		string target = e.target;
		e.target = e.healthtarget;
		G_UseTargets(e, e.enemy);
		e.target = target;
	}
}

//
// Monster utility functions
//
void monster_dead_think(ASEntity &self)
{
	// flies
	if ((self.monsterinfo.aiflags & ai_flags_t::STINKY) != 0 && (self.monsterinfo.aiflags & ai_flags_t::STUNK) == 0)
	{
		if (!self.fly_sound_debounce_time)
			self.fly_sound_debounce_time = level.time + random_time(time_sec(5), time_sec(15));
		else if (self.fly_sound_debounce_time < level.time)
		{
			if (self.e.s.sound == 0)
			{
				self.e.s.effects = effects_t(self.e.s.effects | effects_t::FLIES);
				self.e.s.sound = gi_soundindex("infantry/inflies1.wav");
				self.fly_sound_debounce_time = level.time + time_sec(60);
			}
			else
			{
				self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::FLIES);
				self.e.s.sound = 0;
				self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STUNK);
			}
		}
	}

	if (self.monsterinfo.damage_blood == 0)
	{
		if (self.e.s.frame != self.monsterinfo.active_move.lastframe)
			self.e.s.frame++;
	}

	self.nextthink = level.time + time_hz(10);
}

void monster_dead(ASEntity &self)
{
	@self.think = monster_dead_think;
	self.nextthink = level.time + time_hz(10);
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.monsterinfo.damage_blood = 0;
	self.fly_sound_debounce_time = time_zero;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STUNK);
	gi_linkentity(self.e);
}

// basic setskin implementation that works for
// simple monsters
void setskin_basic(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

// gib flags
enum gib_type_t
{
	NONE =      0,  // no flags (organic)
	METALLIC =  1,  // bouncier
	ACID =		2,  // acidic (gekk)
	HEAD =		4,  // head gib; the input entity will transform into this
	DEBRIS =	8,  // explode outwards rather than in velocity, no blood
	SKINNED =	16, // use skinnum
	UPRIGHT =   32, // stay upright on ground
};

class gib_def_t
{
	uint count = 1;
	string gibname;
	float scale = 1.0f;
	gib_type_t type = gib_type_t::NONE;
	int framenum = 0;

    gib_def_t() { }

	gib_def_t(uint count, const string &in gibname)
	{
        this.count = count;
        this.gibname = gibname;
	}

	gib_def_t(uint count, const string &in gibname, gib_type_t type)
	{
        this.count = count;
        this.gibname = gibname;
        this.type = type;
	}

	gib_def_t(uint count, const string &in gibname, float scale)
	{
        this.count = count;
        this.gibname = gibname;
        this.scale = scale;
	}

	gib_def_t(uint count, const string &in gibname, float scale, gib_type_t type)
	{
        this.count = count;
        this.gibname = gibname;
        this.scale = scale;
        this.type = type;
	}

	gib_def_t(const string &in gibname, float scale, gib_type_t type)
	{
        this.gibname = gibname;
        this.scale = scale;
        this.type = type;
	}

	gib_def_t(const string &in gibname, float scale)
	{
        this.gibname = gibname;
        this.scale = scale;
	}

	gib_def_t(const string &in gibname, gib_type_t type)
	{
        this.gibname = gibname;
        this.type = type;
	}

	gib_def_t(const string &in gibname)
	{
        this.gibname = gibname;
	}

	gib_def_t &frame(int f)
	{
		this.framenum = f;
		return this;
	}
};

// convenience function to throw different gib types
// NOTE: always throw the head gib *last* since self's size is used
// to position the gibs!
void ThrowGibs(ASEntity &self, int32 damage, const array<gib_def_t> &in gibs)
{
	foreach (const gib_def_t @gib : gibs)
		for (uint i = 0; i < gib.count; i++)
			ThrowGib(self, gib.gibname, damage, gib.type, gib.scale * (self.e.s.scale != 0 ? self.e.s.scale : 1), gib.framenum);
}

bool M_CheckGib(ASEntity &self, const mod_t &in mod)
{
	if (self.deadflag)
	{
		if (mod.id == mod_id_t::CRUSH)
			return true;
	}

	return self.health <= self.gib_health;
}

void monster_think(ASEntity &self)
{
    /*
	// [Paril-KEX] monster sniff testing; if we can make an unobstructed path to the player, murder ourselves.
	if (g_debug_monster_kills->integer)
	{
		if (g_edicts[1].inuse)
		{
			trace_t enemy_trace = gi.traceline(self->s.origin, g_edicts[1].s.origin, self, MASK_SHOT);

			if (enemy_trace.fraction < 1.0f && enemy_trace.ent == &g_edicts[1])
				T_Damage(self, &g_edicts[1], &g_edicts[1], { 0, 0, -1 }, self->s.origin, { 0, 0, -1 }, 9999, 9999, DAMAGE_NO_PROTECTION, MOD_BFG_BLAST);
			else
			{
				static vec3_t points[64];

				if (self->disintegrator_time <= level.time)
				{
					PathRequest request;
					request.goal = g_edicts[1].s.origin;
					request.moveDist = 4.0f;
					request.nodeSearch.ignoreNodeFlags = true;
					request.nodeSearch.radius = 9999;
					request.pathFlags = PathFlags::All;
					request.start = self->s.origin;
					request.traversals.dropHeight = 9999;
					request.traversals.jumpHeight = 9999;
					request.pathPoints.array = points;
					request.pathPoints.count = q_countof(points);

					PathInfo info;

					if (gi.GetPathToGoal(request, info))
					{
						if (info.returnCode != PathReturnCode::NoStartNode &&
							info.returnCode != PathReturnCode::NoGoalNode &&
							info.returnCode != PathReturnCode::NoPathFound &&
							info.returnCode != PathReturnCode::NoNavAvailable &&
							info.numPathPoints < q_countof(points))
						{
							if (CheckPathVisibility(g_edicts[1].s.origin + vec3_t { 0.f, 0.f, g_edicts[1].mins.z }, points[info.numPathPoints - 1]) &&
								CheckPathVisibility(self->s.origin + vec3_t { 0.f, 0.f, self->mins.z }, points[0]))
							{
								size_t i = 0;

								for (; i < info.numPathPoints - 1; i++)
									if (!CheckPathVisibility(points[i], points[i + 1]))
										break;

								if (i == info.numPathPoints - 1)
									T_Damage(self, &g_edicts[1], &g_edicts[1], { 0, 0, 1 }, self->s.origin, { 0, 0, 1 }, 9999, 9999, DAMAGE_NO_PROTECTION, MOD_BFG_BLAST);
								else
									self->disintegrator_time = level.time + 500_ms;
							}
							else
								self->disintegrator_time = level.time + 500_ms;
						}
						else
						{
							self->disintegrator_time = level.time + 1_sec;
						}
					}
					else
					{
						self->disintegrator_time = level.time + 1_sec;
					}
				}
			}

			if (!self->deadflag && !(self->monsterinfo.aiflags & AI_DO_NOT_COUNT))
				gi.Draw_Bounds(self->absmin, self->absmax, rgba_red, gi.frame_time_s, false);
		}
	}
    */

	self.e.s.renderfx = renderfx_t(self.e.s.renderfx & ~(renderfx_t::STAIR_STEP | renderfx_t::OLD_FRAME_LERP));

	M_ProcessPain(self);

	// pain/die above freed us
	if (!self.e.inuse || !(self.think is monster_think))
		return;

	if ((self.hackflags & HACKFLAG_ATTACK_PLAYER) != 0)
	{
		if (self.enemy is null && players[0].e.inuse)
		{
			@self.enemy = players[0];
			FoundTarget(self);
		}
	}

	M_MoveFrame(self);
	if (self.e.linkcount != self.monsterinfo.linkcount)
	{
		self.monsterinfo.linkcount = self.e.linkcount;
		M_CheckGround(self, G_GetClipMask(self));
	}
	M_CatagorizePosition(self, self.e.s.origin, self.waterlevel, self.watertype);
	M_WorldEffects(self);
	M_SetEffects(self);
}

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void monster_use (ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.enemy !is null)
		return;
	if (self.health <= 0)
		return;
	if (activator is null)
		return;
	if ((activator.flags & ent_flags_t::NOTARGET) != 0)
		return;
	if ((activator.client is null) && (activator.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) == 0)
		return;
	if ((activator.flags & ent_flags_t::DISGUISED) != 0) // PGM
		return;							 // PGM

	// delay reaction so if the monster is teleported, its sound is still heard
	@self.enemy = activator;
	FoundTarget(self);
}

void monster_triggered_spawn(ASEntity &self)
{
	self.e.s.origin[2] += 1;

	self.e.solid = solid_t::BBOX;
	self.movetype = movetype_t::STEP;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	self.air_finished = level.time + time_sec(12);
	gi_linkentity(self.e);

	KillBox(self, false);

	monster_start_go(self);

	// RAFAEL
	if (self.classname == "monster_fixbot")
	{
		if (self.spawnflags.has(spawnflags::fixbot::LANDING | spawnflags::fixbot::TAKEOFF | spawnflags::fixbot::FIXIT))
		{
			@self.enemy = null;
			return;
		}
	}
	// RAFAEL

	if (self.enemy !is null && !(self.spawnflags.has(spawnflags::monsters::AMBUSH)) &&
        (self.enemy.flags & ent_flags_t::NOTARGET) == 0 && (self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) == 0)
	{
		// ROGUE
		if ((self.enemy.flags & ent_flags_t::DISGUISED) == 0)
			// ROGUE
			FoundTarget(self);
		// ROGUE
		else // PMM - just in case, make sure to clear the enemy so FindTarget doesn't get confused
			@self.enemy = null;
		// ROGUE
	}
	else
	{
		@self.enemy = null;
	}
}

void monster_triggered_spawn_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	// we have a one frame delay here so we don't telefrag the guy who activated us
	@self.think = monster_triggered_spawn;
	self.nextthink = level.time + FRAME_TIME_S;
	if (activator !is null && activator.client !is null && (self.hackflags & HACKFLAG_END_CUTSCENE) == 0)
		@self.enemy = activator;
	@self.use = monster_use;

	if (self.spawnflags.has(spawnflags::monsters::SCENIC))
	{
		M_droptofloor(self);

		self.nextthink = time_zero;
		self.think(self);

		if (self.spawnflags.has(spawnflags::monsters::AMBUSH))
			monster_use(self, other, activator);

		for (int i = 0; i < 30; i++)
		{
			self.think(self);
			self.monsterinfo.next_move_time = time_zero;
		}
	}
}

void monster_triggered_think(ASEntity &self)
{
    // AS_TODO
    /*
	if ((self->monsterinfo.aiflags & ai_flags_t::DO_NOT_COUNT) == 0)
		gi.Draw_Bounds(self.e.absmin, self->absmax, rgba_blue, gi.frame_time_s, false);

	self->nextthink = level.time + 1_ms;
    */
}

void monster_triggered_start(ASEntity &self)
{
	self.e.solid = solid_t::NOT;
	self.movetype = movetype_t::NONE;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.nextthink = time_zero;
	@self.use = monster_triggered_spawn_use;

    /*
	if (g_debug_monster_kills->integer)
	{
		self->think = monster_triggered_think;
		self->nextthink = level.time + 1_ms;
	}

    AS_TODO
	if (!self->targetname ||
		(G_FindByString<&edict_t::target>(nullptr, self->targetname) == nullptr &&
		 G_FindByString<&edict_t::pathtarget>(nullptr, self->targetname) == nullptr &&
		 G_FindByString<&edict_t::deathtarget>(nullptr, self->targetname) == nullptr &&
		 G_FindByString<&edict_t::itemtarget>(nullptr, self->targetname) == nullptr &&
		 G_FindByString<&edict_t::healthtarget>(nullptr, self->targetname) == nullptr &&
		 G_FindByString<&edict_t::combattarget>(nullptr, self->targetname) == nullptr))
	{
		gi.Com_PrintFmt("{}: is trigger spawned, but has no targetname or no entity to spawn it\n", *self);
	}
    */
}

/*
================
monster_death_use

When a monster dies, it fires all of its targets with the current
enemy as activator.
================
*/
void monster_death_use(ASEntity &self)
{
	self.flags = ent_flags_t(self.flags & ~(ent_flags_t::FLY | ent_flags_t::SWIM));
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ai_flags_t::DEATH_MASK);

	if (self.item !is null)
	{
		ASEntity @dropped = Drop_Item(self, self.item);

		if (!self.itemtarget.empty())
		{
			dropped.target = self.itemtarget;
			self.itemtarget = "";
		}

		@self.item = null;
	}

	if (!self.deathtarget.empty())
		self.target = self.deathtarget;

	if (!self.target.empty())
		G_UseTargets(self, self.enemy);

	// [Paril-KEX] fire health target
	if (!self.healthtarget.empty())
	{
		string target = self.target;
		self.target = self.healthtarget;
		G_UseTargets(self, self.enemy);
		self.target = target;
	}
}

// [Paril-KEX] adjust the monster's health from how
// many active players we have
void G_Monster_ScaleCoopHealth(ASEntity &self)
{
	// already scaled
	if (self.monsterinfo.health_scaling >= level.coop_scale_players)
		return;

	// this is just to fix monsters that change health after spawning...
	// looking at you, soldiers
	if (self.monsterinfo.base_health == 0)
		self.monsterinfo.base_health = self.max_health;

	int delta = level.coop_scale_players - self.monsterinfo.health_scaling;
	int additional_health = delta * int(self.monsterinfo.base_health * level.coop_health_scaling);

	self.health = max(1, self.health + additional_health);
	self.max_health += additional_health;

	self.monsterinfo.health_scaling = level.coop_scale_players;
}

// AS_TODO
/*
struct monster_filter_t
{
	inline bool operator()(edict_t *self) const
	{
		return self->inuse && (self->flags & FL_COOP_HEALTH_SCALE) && self->health > 0;
	}
};

// check all active monsters' scaling
void G_Monster_CheckCoopHealthScaling()
{
	for (auto monster : entity_iterable_t<monster_filter_t>())
		G_Monster_ScaleCoopHealth(monster);
}
*/

//============================================================================
namespace spawnflags::monsters
{
    const spawnflags_t FUBAR = spawnflag_dec(4);

    const spawnflags_t AMBUSH = spawnflag_dec(1);
    const spawnflags_t TRIGGER_SPAWN = spawnflag_dec(2);
    const spawnflags_t DEAD = spawnflag_bit(16);
    const spawnflags_t SUPER_STEP = spawnflag_bit(17);
    const spawnflags_t NO_DROP = spawnflag_bit(18);
    const spawnflags_t SCENIC = spawnflag_bit(19);
    const spawnflags_t NO_IDLE_DOORS = spawnflag_bit(20);
}

bool monster_start(ASEntity &self, const spawn_temp_t &in st)
{
	if ( !M_AllowSpawn( self ) ) {
		self.Free();
		return false;
	}

	if (self.spawnflags.has(spawnflags::monsters::SCENIC))
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::GOOD_GUY);

	// [Paril-KEX] n64
	if ((self.hackflags & (HACKFLAG_END_CUTSCENE | HACKFLAG_ATTACK_PLAYER)) != 0)
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

	if (self.spawnflags.has(spawnflags::monsters::FUBAR) && (self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) == 0)
	{
		self.spawnflags &= ~spawnflags::monsters::FUBAR;
		self.spawnflags |= spawnflags::monsters::AMBUSH;
	}

	// [Paril-KEX] simplify other checks
	if ((self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::DO_NOT_COUNT);

	// ROGUE
	if ((self.monsterinfo.aiflags & ai_flags_t::DO_NOT_COUNT) == 0 && !self.spawnflags.has(spawnflags::monsters::DEAD))
	{
        // AS_TODO
		//if (g_debug_monster_kills.integer != 0)
		//	level.monsters_registered[level.total_monsters] = self;
		// ROGUE
		level.total_monsters++;
	}

	self.nextthink = level.time + FRAME_TIME_S;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::MONSTER);
	self.takedamage = true;
	self.air_finished = level.time + time_sec(12);
	@self.use = monster_use;
	self.max_health = self.health;
	self.e.clipmask = contents_t::MASK_MONSTERSOLID;
	self.deadflag = false;
	self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::DEADMONSTER);
	self.flags = ent_flags_t(self.flags & ~ent_flags_t::ALIVE_KNOCKBACK_ONLY);
	self.flags = ent_flags_t(self.flags | ent_flags_t::COOP_HEALTH_SCALE);
	self.e.s.old_origin = self.e.s.origin;
	self.monsterinfo.initial_power_armor_type = self.monsterinfo.power_armor_type;
	self.monsterinfo.max_power_armor_power = self.monsterinfo.power_armor_power;

	if (self.monsterinfo.checkattack is null)
		@self.monsterinfo.checkattack = M_CheckAttack;

	if ( ai_model_scale.value > 0 ) {
		self.e.s.scale = ai_model_scale.value;
	}

	if (self.e.s.scale != 0)
	{
		self.monsterinfo.scale *= self.e.s.scale;
		self.e.mins *= self.e.s.scale;
		self.e.maxs *= self.e.s.scale;
		self.mass = int(self.mass * self.e.s.scale);
	}

	if ((pm_config.physics_flags & physics_flags_t::PSX_SCALE) != 0)
		self.e.s.origin.z -= self.e.mins.z - (self.e.mins.z * PSX_PHYSICS_SCALAR);

	// set combat style if unset
	if (self.monsterinfo.combat_style == combat_style_t::UNKNOWN)
	{
		if (self.monsterinfo.attack is null && self.monsterinfo.melee !is null)
			self.monsterinfo.combat_style = combat_style_t::MELEE;
		else
			self.monsterinfo.combat_style = combat_style_t::MIXED;
	}

	if (!st.item.empty())
	{
		@self.item = FindItemByClassname(st.item);

		if (self.item is null)
			gi_Com_Print("{}: bad item: {}\n", self, st.item);
	}

	// randomize what frame they start on
	if (self.monsterinfo.active_move !is null)
		self.e.s.frame =
			irandom(self.monsterinfo.active_move.firstframe, self.monsterinfo.active_move.lastframe + 1);

	// PMM - get this so I don't have to do it in all of the monsters
	self.monsterinfo.base_height = self.e.maxs.z;

	// Paril: monsters' old default viewheight (25)
	// is all messed up for certain monsters. Calculate
	// from maxs to make a bit more sense.
	if (self.viewheight == 0)
		self.viewheight = int(self.e.maxs.z - 8.0f);

	// PMM - clear these
	self.monsterinfo.quad_time = time_zero;
	self.monsterinfo.double_time = time_zero;
	self.monsterinfo.invincible_time = time_zero;

	// set base health & set base scaling to 1 player
	self.monsterinfo.base_health = self.health;
	self.monsterinfo.health_scaling = 1;

	// [Paril-KEX] co-op health scale
	G_Monster_ScaleCoopHealth(self);

	// set vision cone
	if (!st.was_key_specified("vision_cone"))
	{
		self.vision_cone = -2.0f; // special value to use old algorithm
	}

	return true;
}

namespace internal
{
    ASEntity @fixedstuck_self;
    contents_t fixedstuck_mask;
}

trace_t FixStuckObject_Trace(const vec3_t &in start, const vec3_t &in mins, const vec3_t &in maxs, const vec3_t &in end)
{
    return gi_trace(start, mins, maxs, end, internal::fixedstuck_self.e, internal::fixedstuck_mask);
}

stuck_result_t G_FixStuckObject(ASEntity &self, vec3_t check)
{
	@internal::fixedstuck_self = self;
    internal::fixedstuck_mask = G_GetClipMask(self);
	stuck_result_t result = G_FixStuckObject_Generic(check, self.e.mins, self.e.maxs, FixStuckObject_Trace, check);

	if (result == stuck_result_t::NO_GOOD_POSITION)
		return result;

	self.e.s.origin = check;

	if (result == stuck_result_t::FIXED && developer.integer != 0)
		gi_Com_Print("fixed stuck {}\n", self);

	return result;
}

const array<int> monster_adjust_bits = { 0, -1, 1, -2, 2, -4, 4, -8, 8 };

void monster_start_go(ASEntity &self)
{
	// Paril: moved here so this applies to swim/fly monsters too
	if ((self.flags & ent_flags_t::STATIONARY) == 0)
	{
		vec3_t check = self.e.s.origin;

		// [Paril-KEX] different nudge method; see if any of the bbox sides are clear,
		// if so we can see how much headroom we have in that direction and shift us.
		// most of the monsters stuck in solids will only be stuck on one side, which
		// conveniently leaves only one side not in a solid; this won't fix monsters
		// stuck in a corner though.
		bool is_stuck = false;

		if ((self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0 || (self.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) != 0)
			is_stuck = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, self.e.s.origin, self.e, contents_t::MASK_MONSTERSOLID).startsolid;
		else
			is_stuck = !M_droptofloor(self) || !M_walkmove(self, 0, 0);

		if (is_stuck)
		{
			if (G_FixStuckObject(self, check) != stuck_result_t::NO_GOOD_POSITION)
			{
				if ((self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
					is_stuck = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, self.e.s.origin, self.e, contents_t::MASK_MONSTERSOLID).startsolid;
				else if ((self.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
					M_droptofloor(self);
				is_stuck = false;
			}
		}

		// last ditch effort: brute force
		if (is_stuck)
		{
			// Paril: try nudging them out. this fixes monsters stuck
			// in very shallow slopes.
			bool					walked = false;

			for (int32 y = 0; !walked && y < 3; y++)
				for (int32 x = 0; !walked && x < 3; x++)
					for (int32 z = 0; !walked && z < 3; z++)
					{
						self.e.s.origin.x = check.x + monster_adjust_bits[x];
						self.e.s.origin.y = check.y + monster_adjust_bits[y];
						self.e.s.origin.z = check.z + monster_adjust_bits[z];
						
						if ((self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
						{
							is_stuck = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, self.e.s.origin, self.e, contents_t::MASK_MONSTERSOLID).startsolid;

							if (!is_stuck)
								walked = true;
						}
						else if ((self.flags & (ent_flags_t::FLY | ent_flags_t::SWIM)) == 0)
						{
							M_droptofloor(self);
							walked = M_walkmove(self, 0, 0);
						}
					}
		}

		if (is_stuck)
			gi_Com_Print("WARNING: {} stuck in solid\n", self);
	}

	vec3_t v;

	if (self.health <= 0)
		return;

	self.e.s.old_origin = self.e.s.origin;

	// check for target to combat_point and change to combattarget
	if (!self.target.empty())
	{
		bool	 notcombat;
		bool	 fixup;
		ASEntity @target = null;

		notcombat = false;
		fixup = false;
		while ((@target = find_by_str<ASEntity>(target, "targetname", self.target)) !is null)
		{
			if (target.classname == "point_combat")
			{
				self.combattarget = self.target;
				fixup = true;
			}
			else
			{
				notcombat = true;
			}
		}
		if (notcombat && !self.combattarget.empty())
			gi_Com_Print("{}: has target with mixed types\n", self);
		if (fixup)
			self.target = "";
	}

	// validate combattarget
	if (!self.combattarget.empty())
	{
		ASEntity @target = null;
		while ((@target = find_by_str<ASEntity>(target, "targetname", self.combattarget)) !is null)
		{
			if (target.classname != "point_combat")
			{
				gi_Com_Print("{} has a bad combattarget {} ({})\n", self, self.combattarget, target);
			}
		}
	}

	// allow spawning dead
	bool spawn_dead = self.spawnflags.has(spawnflags::monsters::DEAD);

	if (!self.target.empty())
	{
		@self.goalentity = @self.movetarget = G_PickTarget(self.target);
		if (self.movetarget is null)
		{
			gi_Com_Print("{}: can't find target {}\n", self, self.target);
			self.target = "";
			self.monsterinfo.pausetime = HOLD_FOREVER;
			if (!spawn_dead)
				self.monsterinfo.stand(self);
		}
		else if (self.movetarget.classname == "path_corner")
		{
			v = self.goalentity.e.s.origin - self.e.s.origin;
			self.ideal_yaw = self.e.s.angles.yaw = vectoyaw(v);
			if (!spawn_dead)
				self.monsterinfo.walk(self);
			self.target = "";
		}
		else
		{
			@self.goalentity = @self.movetarget = null;
			self.monsterinfo.pausetime = HOLD_FOREVER;
			if (!spawn_dead)
				self.monsterinfo.stand(self);
		}
	}
	else
	{
		self.monsterinfo.pausetime = HOLD_FOREVER;
		if (!spawn_dead)
			self.monsterinfo.stand(self);
	}
	
	if (spawn_dead)
	{
		// to spawn dead, we'll mimick them dying naturally
		self.health = 0;

		vec3_t f = self.e.s.origin;

		if (self.die !is null)
			self.die(self, self, self, 0, vec3_origin, mod_t(mod_id_t::SUICIDE));

		if (!self.e.inuse)
			return;

		if (self.monsterinfo.setskin !is null)
			self.monsterinfo.setskin(self);

		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::SPAWNED_DEAD);

		auto @move = self.monsterinfo.active_move;

		for (int i = move.firstframe; i < move.lastframe; i++)
		{
			self.e.s.frame = i;

			if (move.frames[i - move.firstframe].thinkfunc !is null)
				move.frames[i - move.firstframe].thinkfunc(self);

			if (!self.e.inuse)
				return;
		}

		if (move.endfunc !is null)
			move.endfunc(self);

		if (!self.e.inuse)
			return;

		if (self.monsterinfo.start_frame != 0)
			self.e.s.frame = self.monsterinfo.start_frame;
		else
			self.e.s.frame = move.lastframe;

		self.e.s.origin = f;
		gi_linkentity(self.e);

		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::SPAWNED_DEAD);
	}
	else
	{
		@self.think = monster_think;
		self.nextthink = level.time + FRAME_TIME_S;
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::SPAWNED_ALIVE);
	}
}

void walkmonster_start_go(ASEntity &self)
{
	if (self.yaw_speed == 0)
		self.yaw_speed = 20;

    if (self.spawnflags.has(spawnflags::monsters::TRIGGER_SPAWN))
		monster_triggered_start(self);
	else
		monster_start_go(self);
}

void walkmonster_start(ASEntity &self)
{
	@self.think = walkmonster_start_go;
	monster_start(self, ED_GetSpawnTemp());
}

void flymonster_start_go(ASEntity &self)
{
	if (self.yaw_speed == 0)
		self.yaw_speed = 30;

	if (self.spawnflags.has(spawnflags::monsters::TRIGGER_SPAWN))
		monster_triggered_start(self);
	else
		monster_start_go(self);
}

void flymonster_start(ASEntity &self)
{
	self.flags = ent_flags_t(self.flags | ent_flags_t::FLY);
	@self.think = flymonster_start_go;
	monster_start(self, ED_GetSpawnTemp());
}

void swimmonster_start_go(ASEntity &self)
{
	if (self.yaw_speed == 0)
		self.yaw_speed = 30;

    if (self.spawnflags.has(spawnflags::monsters::TRIGGER_SPAWN))
		monster_triggered_start(self);
	else
		monster_start_go(self);
}

void swimmonster_start(ASEntity &self)
{
	self.flags = ent_flags_t(self.flags | ent_flags_t::SWIM);
	@self.think = swimmonster_start_go;
	monster_start(self, ED_GetSpawnTemp());
}

/*QUAKED trigger_health_relay (1.0 1.0 0.0) (-8 -8 -8) (8 8 8)
Special type of relay that fires when a linked object is reduced
beyond a certain amount of health.

It will only fire once, and free itself afterwards.
*/
void trigger_health_relay_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	float percent_health = clamp(float(other.health) / float(other.max_health), 0.f, 1.f);

	// not ready to trigger yet
	if (percent_health > self.speed)
		return;

	// fire!
	G_UseTargets(self, activator);

	// kill self
	G_FreeEdict(self);
}

void SP_trigger_health_relay(ASEntity &self)
{
	if (self.targetname.empty())
	{
		gi_Com_Print("{} missing targetname\n", self);
		G_FreeEdict(self);
		return;
	}

	if (self.speed < 0 || self.speed > 100)
	{
		gi_Com_Print("{} has bad \"speed\" (health percentage); must be between 0 and 100, inclusive\n", self);
		G_FreeEdict(self);
		return;
	}

	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	@self.use = trigger_health_relay_use;
}
