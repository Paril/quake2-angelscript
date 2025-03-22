// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
	fixbot.c
*/

namespace fixbot
{
    enum frames
    {
        charging_01,
        charging_02,
        charging_03,
        charging_04,
        charging_05,
        charging_06,
        charging_07,
        charging_08,
        charging_09,
        charging_10,
        charging_11,
        charging_12,
        charging_13,
        charging_14,
        charging_15,
        charging_16,
        charging_17,
        charging_18,
        charging_19,
        charging_20,
        charging_21,
        charging_22,
        charging_23,
        charging_24,
        charging_25,
        charging_26,
        charging_27,
        charging_28,
        charging_29,
        charging_30,
        charging_31,
        landing_01,
        landing_02,
        landing_03,
        landing_04,
        landing_05,
        landing_06,
        landing_07,
        landing_08,
        landing_09,
        landing_10,
        landing_11,
        landing_12,
        landing_13,
        landing_14,
        landing_15,
        landing_16,
        landing_17,
        landing_18,
        landing_19,
        landing_20,
        landing_21,
        landing_22,
        landing_23,
        landing_24,
        landing_25,
        landing_26,
        landing_27,
        landing_28,
        landing_29,
        landing_30,
        landing_31,
        landing_32,
        landing_33,
        landing_34,
        landing_35,
        landing_36,
        landing_37,
        landing_38,
        landing_39,
        landing_40,
        landing_41,
        landing_42,
        landing_43,
        landing_44,
        landing_45,
        landing_46,
        landing_47,
        landing_48,
        landing_49,
        landing_50,
        landing_51,
        landing_52,
        landing_53,
        landing_54,
        landing_55,
        landing_56,
        landing_57,
        landing_58,
        pushback_01,
        pushback_02,
        pushback_03,
        pushback_04,
        pushback_05,
        pushback_06,
        pushback_07,
        pushback_08,
        pushback_09,
        pushback_10,
        pushback_11,
        pushback_12,
        pushback_13,
        pushback_14,
        pushback_15,
        pushback_16,
        takeoff_01,
        takeoff_02,
        takeoff_03,
        takeoff_04,
        takeoff_05,
        takeoff_06,
        takeoff_07,
        takeoff_08,
        takeoff_09,
        takeoff_10,
        takeoff_11,
        takeoff_12,
        takeoff_13,
        takeoff_14,
        takeoff_15,
        takeoff_16,
        ambient_01,
        ambient_02,
        ambient_03,
        ambient_04,
        ambient_05,
        ambient_06,
        ambient_07,
        ambient_08,
        ambient_09,
        ambient_10,
        ambient_11,
        ambient_12,
        ambient_13,
        ambient_14,
        ambient_15,
        ambient_16,
        ambient_17,
        ambient_18,
        ambient_19,
        paina_01,
        paina_02,
        paina_03,
        paina_04,
        paina_05,
        paina_06,
        painb_01,
        painb_02,
        painb_03,
        painb_04,
        painb_05,
        painb_06,
        painb_07,
        painb_08,
        pickup_01,
        pickup_02,
        pickup_03,
        pickup_04,
        pickup_05,
        pickup_06,
        pickup_07,
        pickup_08,
        pickup_09,
        pickup_10,
        pickup_11,
        pickup_12,
        pickup_13,
        pickup_14,
        pickup_15,
        pickup_16,
        pickup_17,
        pickup_18,
        pickup_19,
        pickup_20,
        pickup_21,
        pickup_22,
        pickup_23,
        pickup_24,
        pickup_25,
        pickup_26,
        pickup_27,
        freeze_01,
        shoot_01,
        shoot_02,
        shoot_03,
        shoot_04,
        shoot_05,
        shoot_06,
        weldstart_01,
        weldstart_02,
        weldstart_03,
        weldstart_04,
        weldstart_05,
        weldstart_06,
        weldstart_07,
        weldstart_08,
        weldstart_09,
        weldstart_10,
        weldmiddle_01,
        weldmiddle_02,
        weldmiddle_03,
        weldmiddle_04,
        weldmiddle_05,
        weldmiddle_06,
        weldmiddle_07,
        weldend_01,
        weldend_02,
        weldend_03,
        weldend_04,
        weldend_05,
        weldend_06,
        weldend_07
    };

    const float SCALE = 1.000000f;
}

namespace fixbot::sounds
{
    cached_soundindex pain1("flyer/flypain1.wav");
    cached_soundindex die("flyer/flydeth1.wav");

    cached_soundindex weld1("misc/welder1.wav");
    cached_soundindex weld2("misc/welder2.wav");
    cached_soundindex weld3("misc/welder3.wav");
}

// [Paril-KEX] clean up bot goals if we get interrupted
void bot_goal_check(ASEntity &self)
{
	if (self.owner is null || !self.owner.e.inuse || self.owner.goalentity !is self)
	{
		G_FreeEdict(self);
		return;
	}

	self.nextthink = level.time + time_ms(1);
}

ASEntity @fixbot_FindDeadMonster(ASEntity &self)
{
	return healFindMonster(self, 1024);
}

void fixbot_set_fly_parameters(ASEntity &self, bool heal, bool weld, bool roam)
{
	self.monsterinfo.fly_position_time = time_sec(0);
	self.monsterinfo.fly_acceleration = 5.f;
	self.monsterinfo.fly_speed = 110.f;
	self.monsterinfo.fly_buzzard = false;

	if (heal)
	{
		self.monsterinfo.fly_min_distance = 100.f;
		self.monsterinfo.fly_max_distance = 100.f;
		self.monsterinfo.fly_thrusters = true;
	}
	else if (weld || roam)
	{
		self.monsterinfo.fly_min_distance = 16.f;
		self.monsterinfo.fly_max_distance = 16.f;
	}
	else
	{
		// timid bot
		self.monsterinfo.fly_min_distance = 300.f;
		self.monsterinfo.fly_max_distance = 500.f;
	}
}

bool fixbot_search(ASEntity &self)
{
	ASEntity @ent;

	if (self.enemy is null)
	{
		@ent = fixbot_FindDeadMonster(self);
		if (ent !is null)
		{
			@self.oldenemy = self.enemy;
			@self.enemy = ent;
			@self.enemy.monsterinfo.healer = self;
			self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::MEDIC);
			FoundTarget(self);
			fixbot_set_fly_parameters(self, true, false, false);
			return true;
		}
	}
	return false;
}

void landing_goal(ASEntity &self)
{
	trace_t	 tr;
	vec3_t	 forward, right, up;
	vec3_t	 end;
	ASEntity @ent;

	@ent = G_Spawn();
	ent.classname = "bot_goal";
	ent.e.solid = solid_t::BBOX;
	@ent.owner = self;
	@ent.think = bot_goal_check;
	gi_linkentity(ent.e);

	ent.e.mins = { -32, -32, -24 };
	ent.e.maxs = { 32, 32, 24 };

	AngleVectors(self.e.s.angles, forward, right, up);
	end = self.e.s.origin + (forward * 32);
	end = self.e.s.origin + (up * -8096);

	tr = gi_trace(self.e.s.origin, ent.e.mins, ent.e.maxs, end, self.e, contents_t::MASK_MONSTERSOLID);

	ent.e.s.origin = tr.endpos;

	@self.goalentity = @self.enemy = ent;
	M_SetAnimation(self, fixbot_move_landing);
}

void takeoff_goal(ASEntity &self)
{
	trace_t	 tr;
	vec3_t	 forward, right, up;
	vec3_t	 end;
	ASEntity @ent;

	@ent = G_Spawn();
	ent.classname = "bot_goal";
	ent.e.solid = solid_t::BBOX;
	@ent.owner = self;
	@ent.think = bot_goal_check;
	gi_linkentity(ent.e);

	ent.e.mins = { -32, -32, -24 };
	ent.e.maxs = { 32, 32, 24 };

	AngleVectors(self.e.s.angles, forward, right, up);
	end = self.e.s.origin + (forward * 32);
	end = self.e.s.origin + (up * 128);

	tr = gi_trace(self.e.s.origin, ent.e.mins, ent.e.maxs, end, self.e, contents_t::MASK_MONSTERSOLID);

	ent.e.s.origin = tr.endpos;

	@self.goalentity = @self.enemy = ent;
	M_SetAnimation(self, fixbot_move_takeoff);
}

namespace spawnflags::fixbot
{
    const spawnflags_t FIXIT = spawnflag_dec(4);
    const spawnflags_t TAKEOFF = spawnflag_dec(8);
    const spawnflags_t LANDING = spawnflag_dec(16);
    const spawnflags_t WORKING = spawnflag_dec(32);
    const spawnflags_t FLAGS = spawnflags::fixbot::FIXIT | spawnflags::fixbot::TAKEOFF | spawnflags::fixbot::LANDING | spawnflags::fixbot::WORKING;
}

void change_to_roam(ASEntity &self)
{

	if (fixbot_search(self))
		return;

	fixbot_set_fly_parameters(self, false, false, true);
	M_SetAnimation(self, fixbot_move_roamgoal);

	if (self.spawnflags.has(spawnflags::fixbot::LANDING))
	{
		landing_goal(self);
		M_SetAnimation(self, fixbot_move_landing);
		self.spawnflags &= ~spawnflags::fixbot::FLAGS;
		self.spawnflags |= spawnflags::fixbot::WORKING;
	}
	if (self.spawnflags.has(spawnflags::fixbot::TAKEOFF))
	{
		takeoff_goal(self);
		M_SetAnimation(self, fixbot_move_takeoff);
		self.spawnflags &= ~spawnflags::fixbot::FLAGS;
		self.spawnflags |= spawnflags::fixbot::WORKING;
	}
	if (self.spawnflags.has(spawnflags::fixbot::FIXIT))
	{
		M_SetAnimation(self, fixbot_move_roamgoal);
		self.spawnflags &= ~spawnflags::fixbot::FLAGS;
		self.spawnflags |= spawnflags::fixbot::WORKING;
	}
	if (uint(self.spawnflags) == 0)
	{
		M_SetAnimation(self, fixbot_move_stand2);
	}
}

void roam_goal(ASEntity &self)
{

	trace_t	 tr;
	vec3_t	 forward, right, up;
	vec3_t	 end;
	ASEntity @ent;
	vec3_t	 dang;
	float	 len, oldlen;
	int		 i;
	vec3_t	 vec;
	vec3_t	 whichvec = vec3_origin;

	@ent = G_Spawn();
	ent.classname = "bot_goal";
	ent.e.solid = solid_t::BBOX;
	@ent.owner = self;
	@ent.think = bot_goal_check;
	ent.nextthink = level.time + time_ms(1);
	gi_linkentity(ent.e);

	oldlen = 0;

	for (i = 0; i < 12; i++)
	{

		dang = self.e.s.angles;

		if (i < 6)
			dang.yaw += 30 * i;
		else
			dang.yaw -= 30 * (i - 6);

		AngleVectors(dang, forward, right, up);
		end = self.e.s.origin + (forward * 8192);

		tr = gi_traceline(self.e.s.origin, end, self.e, contents_t::MASK_PROJECTILE);

		vec = self.e.s.origin - tr.endpos;
		len = vec.normalize();

		if (len > oldlen)
		{
			oldlen = len;
			whichvec = tr.endpos;
		}
	}

	ent.e.s.origin = whichvec;
	@self.goalentity = @self.enemy = ent;

	M_SetAnimation(self, fixbot_move_turn);
}

void use_scanner(ASEntity &self)
{
	ASEntity @ent = null;

	float  radius = 1024;
	vec3_t vec;

	float len;

	while ((@ent = findradius(ent, self.e.s.origin, radius)) !is null)
	{
		if (ent.health >= 100)
		{
			if (ent.classname == "object_repair")
			{
				if (visible(self, ent))
				{
					// remove the old one
					if (self.goalentity.classname == "bot_goal")
					{
						self.goalentity.nextthink = level.time + time_ms(100);
						@self.goalentity.think = G_FreeEdict;
					}

					@self.goalentity = @self.enemy = ent;

					vec = self.e.s.origin - self.goalentity.e.s.origin;
					len = vec.normalize();

					fixbot_set_fly_parameters(self, false, true, false);

					if (len < 86.0f)
					{
						M_SetAnimation(self, fixbot_move_weld_start);
						return;
					}
					return;
				}
			}
		}
	}

	if (self.goalentity is null)
	{
		M_SetAnimation(self, fixbot_move_stand);
		return;
	}

	vec = self.e.s.origin - self.goalentity.e.s.origin;
	len = vec.length();

	if (len < 86.0f)
	{
		if (self.goalentity.classname == "object_repair")
		{
			M_SetAnimation(self, fixbot_move_weld_start);
		}
		else
		{
			self.goalentity.nextthink = level.time + time_ms(100);
			@self.goalentity.think = G_FreeEdict;
			@self.goalentity = @self.enemy = null;
			M_SetAnimation(self, fixbot_move_stand);
		}
		return;
	}
}

/*
	when the bot has found a landing pad
	it will proceed to its goalentity
	just above the landing pad and
	decend translated along the z the current
	frames are at 10fps
*/
void blastoff(ASEntity &self, const vec3_t &in start, const vec3_t &in aimdir, int damage, int kick, int te_impact, int hspread, int vspread)
{
	trace_t	   tr;
	vec3_t	   dir;
	vec3_t	   forward, right, up;
	vec3_t	   end;
	float	   r;
	float	   u;
	vec3_t	   water_start;
	bool	   water = false;
	contents_t content_mask = contents_t(contents_t::MASK_PROJECTILE | contents_t::MASK_WATER);

	hspread += (self.e.s.frame - fixbot::frames::takeoff_01);
	vspread += (self.e.s.frame - fixbot::frames::takeoff_01);

	tr = gi_traceline(self.e.s.origin, start, self.e, contents_t::MASK_PROJECTILE);
	if (!(tr.fraction < 1.0f))
	{
		dir = vectoangles(aimdir);
		AngleVectors(dir, forward, right, up);

		r = crandom() * hspread;
		u = crandom() * vspread;
		end = start + (forward * 8192);
		end += (right * r);
		end += (up * u);

		if ((gi_pointcontents(start) & contents_t::MASK_WATER) != 0)
		{
			water = true;
			water_start = start;
			content_mask = contents_t(content_mask & ~contents_t::MASK_WATER);
		}

		tr = gi_traceline(start, end, self.e, content_mask);

		// see if we hit water
		if ((tr.contents & contents_t::MASK_WATER) != 0)
		{
			int color;

			water = true;
			water_start = tr.endpos;

			if (start != tr.endpos)
			{
				if ((tr.contents & contents_t::WATER) != 0)
				{
					if (tr.surface.name == "*brwater")
						color = splash_color_t::BROWN_WATER;
					else
						color = splash_color_t::BLUE_WATER;
				}
				else if ((tr.contents & contents_t::SLIME) != 0)
					color = splash_color_t::SLIME;
				else if ((tr.contents & contents_t::LAVA) != 0)
					color = splash_color_t::LAVA;
				else
					color = splash_color_t::UNKNOWN;

				if (color != splash_color_t::UNKNOWN)
				{
					gi_WriteByte(svc_t::temp_entity);
					gi_WriteByte(temp_event_t::SPLASH);
					gi_WriteByte(8);
					gi_WritePosition(tr.endpos);
					gi_WriteDir(tr.plane.normal);
					gi_WriteByte(color);
					gi_multicast(tr.endpos, multicast_t::PVS, false);
				}

				// change bullet's course when it enters water
				dir = end - start;
				dir = vectoangles(dir);
				AngleVectors(dir, forward, right, up);
				r = crandom() * hspread * 2;
				u = crandom() * vspread * 2;
				end = water_start + (forward * 8192);
				end += (right * r);
				end += (up * u);
			}

			// re-trace ignoring water this time
			tr = gi_traceline(water_start, end, self.e, contents_t::MASK_PROJECTILE);
		}
	}

	// send gun puff / flash
	if (!((tr.surface !is null) && (tr.surface.flags & surfflags_t::SKY) != 0))
	{
		if (tr.fraction < 1.0f)
		{
            ASEntity @hit = entities[tr.ent.s.number];

			if (hit.takedamage)
			{
				T_Damage(hit, self, self, aimdir, tr.endpos, tr.plane.normal, damage, kick, damageflags_t::BULLET, mod_id_t::BLASTOFF);
			}
			else
			{
				if ((tr.surface.flags & surfflags_t::SKY) == 0)
				{
					gi_WriteByte(svc_t::temp_entity);
					gi_WriteByte(te_impact);
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
	if (water)
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
		gi_WriteByte(temp_event_t::BUBBLETRAIL);
		gi_WritePosition(water_start);
		gi_WritePosition(tr.endpos);
		gi_multicast(pos, multicast_t::PVS, false);
	}
}

void fly_vertical(ASEntity &self)
{
	int	   i;
	vec3_t v;
	vec3_t forward;
	vec3_t start;
	vec3_t tempvec;

	v = self.goalentity.e.s.origin - self.e.s.origin;
	self.ideal_yaw = vectoyaw(v);
	M_ChangeYaw(self);

	if (self.e.s.frame == fixbot::frames::landing_58 || self.e.s.frame == fixbot::frames::takeoff_16)
	{
		self.goalentity.nextthink = level.time + time_ms(100);
		@self.goalentity.think = G_FreeEdict;
		M_SetAnimation(self, fixbot_move_stand);
		@self.goalentity = @self.enemy = null;
	}

	// kick up some particles
	tempvec = self.e.s.angles;
	tempvec.pitch += 90;

	AngleVectors(tempvec, forward);
	start = self.e.s.origin;

	for (i = 0; i < 10; i++)
		blastoff(self, start, forward, 2, 1, temp_event_t::SHOTGUN, DEFAULT_SHOTGUN_HSPREAD, DEFAULT_SHOTGUN_VSPREAD);

	// needs sound
}

void fly_vertical2(ASEntity &self)
{
	vec3_t v;
	float  len;

	v = self.goalentity.e.s.origin - self.e.s.origin;
	len = v.length();
	self.ideal_yaw = vectoyaw(v);
	M_ChangeYaw(self);

	if (len < 32)
	{
		self.goalentity.nextthink = level.time + time_ms(100);
		@self.goalentity.think = G_FreeEdict;
		M_SetAnimation(self, fixbot_move_stand);
		@self.goalentity = @self.enemy = null;
	}

	// needs sound
}

const array<mframe_t> fixbot_frames_landing = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),

	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),

	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),

	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),

	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),

	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2),
	mframe_t(ai_move, 0, fly_vertical2)
};
const mmove_t fixbot_move_landing = mmove_t(fixbot::frames::landing_01, fixbot::frames::landing_58, fixbot_frames_landing, null);

/*
	generic ambient stand
*/
const array<mframe_t> fixbot_frames_stand = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, change_to_roam)

};
const mmove_t fixbot_move_stand = mmove_t(fixbot::frames::ambient_01, fixbot::frames::ambient_19, fixbot_frames_stand, null);

const array<mframe_t> fixbot_frames_stand2 = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, change_to_roam)
};
const mmove_t fixbot_move_stand2 = mmove_t(fixbot::frames::ambient_01, fixbot::frames::ambient_19, fixbot_frames_stand2, null);

/*
	will need the pickup offset for the front pincers
	object will need to stop forward of the object
	and take the object with it ( this may require a variant of liftoff and landing )
*/
/*
const array<mframe_t> fixbot_frames_pickup = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)

};
const mmove_t fixbot_move_pickup = mmove_t(fixbot::frames::pickup_01, fixbot::frames::pickup_27, fixbot_frames_pickup, null);
*/

/*
	generic frame to move bot
*/
const array<mframe_t> fixbot_frames_roamgoal = {
	mframe_t(ai_move, 0, roam_goal)
};
const mmove_t fixbot_move_roamgoal = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_roamgoal, null);

void ai_facing(ASEntity &self, float dist)
{
	if (self.goalentity is null)
	{
		fixbot_stand(self);
		return;
	}

	vec3_t v;

	if (infront(self, self.goalentity))
		M_SetAnimation(self, fixbot_move_forward);
	else
	{
		v = self.goalentity.e.s.origin - self.e.s.origin;
		self.ideal_yaw = vectoyaw(v);
		M_ChangeYaw(self);
	}
};

const array<mframe_t> fixbot_frames_turn = {
	mframe_t(ai_facing)
};
const mmove_t fixbot_move_turn = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_turn, null);

void go_roam(ASEntity &self)
{
	M_SetAnimation(self, fixbot_move_stand);
}

/*
	takeoff
*/
const array<mframe_t> fixbot_frames_takeoff = {
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),

	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical),
	mframe_t(ai_move, 0.01f, fly_vertical)
};
const mmove_t fixbot_move_takeoff = mmove_t(fixbot::frames::takeoff_01, fixbot::frames::takeoff_16, fixbot_frames_takeoff, null);

/* findout what this is */
const array<mframe_t> fixbot_frames_paina = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t fixbot_move_paina = mmove_t(fixbot::frames::paina_01, fixbot::frames::paina_06, fixbot_frames_paina, fixbot_run);

/* findout what this is */
const array<mframe_t> fixbot_frames_painb = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t fixbot_move_painb = mmove_t(fixbot::frames::painb_01, fixbot::frames::painb_08, fixbot_frames_painb, fixbot_run);

/*
	backup from pain
	call a generic painsound
	some spark effects
*/
const array<mframe_t> fixbot_frames_pain3 = {
	mframe_t(ai_move, -1)
};
const mmove_t fixbot_move_pain3 = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_pain3, fixbot_run);

/*
	bot has compleated landing
	and is now on the grownd
	( may need second land if the bot is releasing jib into jib vat )
*/
/*
const array<mframe_t> fixbot_frames_land = {
	mframe_t(ai_move)
};
const mmove_t fixbot_move_land = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_land, null);
*/

void ai_movetogoal(ASEntity &self, float dist)
{
	M_MoveToGoal(self, dist);
}
/*

*/
const array<mframe_t> fixbot_frames_forward = {
	mframe_t(ai_movetogoal, 5, use_scanner)
};
const mmove_t fixbot_move_forward = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_forward, null);

/*

*/
const array<mframe_t> fixbot_frames_walk = {
	mframe_t(ai_walk, 5)
};
const mmove_t fixbot_move_walk = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_walk, null);

/*

*/
const array<mframe_t> fixbot_frames_run = {
	mframe_t(ai_run, 10)
};
const mmove_t fixbot_move_run = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_run, null);

/*
	raf
	note to self
	they could have a timer that will cause
	the bot to explode on countdown
*/
/*
const array<mframe_t> fixbot_frames_death1 = {
	mframe_t(ai_move)
};
const mmove_t fixbot_move_death1 = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_death1, fixbot_dead);

//
const array<mframe_t> fixbot_frames_backward = {
	mframe_t(ai_move)
};
const mmove_t fixbot_move_backward = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_backward, null);
*/

//
const array<mframe_t> fixbot_frames_start_attack = {
	mframe_t(ai_charge)
};
const mmove_t fixbot_move_start_attack = mmove_t(fixbot::frames::freeze_01, fixbot::frames::freeze_01, fixbot_frames_start_attack, fixbot_attack);

/*
	TBD:
	need to get laser attack anim
	attack with the laser blast
*/
/*
const array<mframe_t> fixbot_frames_attack1 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -10, fixbot_fire_blaster)
};
const mmove_t fixbot_move_attack1 = mmove_t(fixbot::frames::shoot_01, fixbot::frames::shoot_06, fixbot_frames_attack1, null);
*/

void fixbot_laser_update(ASEntity &laser)
{
	ASEntity @self = laser.owner;

	vec3_t start, dir;
	AngleVectors(self.e.s.angles, dir);
	start = self.e.s.origin + (dir * 16);

	if (self.enemy !is null && self.health > 0)
	{
		vec3_t point;
		point = (self.enemy.e.absmin + self.enemy.e.absmax) * 0.5f;
		if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
			point.x += sin(level.time.secondsf()) * 8;
		dir = point - self.e.s.origin;
		dir.normalize();
	}

	laser.e.s.origin = start;
	laser.movedir = dir;
	gi_linkentity(laser.e);
	dabeam_update(laser, true);
}

void fixbot_fire_laser(ASEntity &self)
{
	// critter dun got blown up while bein' fixed
	if (self.enemy is null || !self.enemy.e.inuse || self.enemy.health <= self.enemy.gib_health)
	{
		M_SetAnimation(self, fixbot_move_stand);
		self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
		return;
	}

	// fire the beam until they're within res range
	bool firedLaser = false;

	if (self.enemy.health < (self.enemy.mass / 10))
	{
		firedLaser = true;
		monster_fire_dabeam(self, -1, false, fixbot_laser_update);
	}

	if (self.enemy.health >= (self.enemy.mass / 10))
	{
		// we have enough health now; if we didn't fire
		// a laser, just make a fake one
		if (!firedLaser)
			monster_fire_dabeam(self, 0, false, fixbot_laser_update);
		else
			self.monsterinfo.fly_position_time = time_zero;
		
		// change our fly parameter slightly so we back away
		self.monsterinfo.fly_min_distance = self.monsterinfo.fly_max_distance = 200.f;

		// don't revive if we are too close
		if ((self.e.s.origin - self.enemy.e.s.origin).length() > 86.f)
		{
			finishHeal(self);
			M_SetAnimation(self, fixbot_move_stand);
		}
	}
	else
		self.enemy.monsterinfo.aiflags = ai_flags_t(self.enemy.monsterinfo.aiflags | ai_flags_t::RESURRECTING);
}

const array<mframe_t> fixbot_frames_laserattack = {
	mframe_t(ai_charge, 0, fixbot_fire_laser),
	mframe_t(ai_charge, 0, fixbot_fire_laser),
	mframe_t(ai_charge, 0, fixbot_fire_laser),
	mframe_t(ai_charge, 0, fixbot_fire_laser),
	mframe_t(ai_charge, 0, fixbot_fire_laser),
	mframe_t(ai_charge, 0, fixbot_fire_laser)
};
const mmove_t fixbot_move_laserattack = mmove_t(fixbot::frames::shoot_01, fixbot::frames::shoot_06, fixbot_frames_laserattack, null);

/*
	need to get forward translation data
	for the charge attack
*/
const array<mframe_t> fixbot_frames_attack2 = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),
	mframe_t(ai_charge, -10),

	mframe_t(ai_charge, 0, fixbot_fire_blaster),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge)
};
const mmove_t fixbot_move_attack2 = mmove_t(fixbot::frames::charging_01, fixbot::frames::charging_31, fixbot_frames_attack2, fixbot_run);

void weldstate(ASEntity &self)
{
	if (self.e.s.frame == fixbot::frames::weldstart_10)
		M_SetAnimation(self, fixbot_move_weld);
	else if (self.goalentity !is null && self.e.s.frame == fixbot::frames::weldmiddle_07)
	{
		if (self.goalentity.health <= 0)
		{
			@self.enemy.owner = null;
			M_SetAnimation(self, fixbot_move_weld_end);
		}
		else
		{
			if (!(self.spawnflags.has(spawnflags::monsters::SCENIC)))
				self.goalentity.health -= 10;
		}
	}
	else
	{
		@self.goalentity = @self.enemy = null;
		M_SetAnimation(self, fixbot_move_stand);
	}
}

void ai_move2(ASEntity &self, float dist)
{
	if (self.goalentity is null)
	{
		fixbot_stand(self);
		return;
	}

	vec3_t v;

	M_walkmove(self, self.e.s.angles.yaw, dist);

	v = self.goalentity.e.s.origin - self.e.s.origin;
	self.ideal_yaw = vectoyaw(v);
	M_ChangeYaw(self);
};

const array<mframe_t> fixbot_frames_weld_start = {
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0),
	mframe_t(ai_move2, 0, weldstate)
};
const mmove_t fixbot_move_weld_start = mmove_t(fixbot::frames::weldstart_01, fixbot::frames::weldstart_10, fixbot_frames_weld_start, null);

const array<mframe_t> fixbot_frames_weld = {
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, fixbot_fire_welder),
	mframe_t(ai_move2, 0, weldstate)
};
const mmove_t fixbot_move_weld = mmove_t(fixbot::frames::weldmiddle_01, fixbot::frames::weldmiddle_07, fixbot_frames_weld, null);

const array<mframe_t> fixbot_frames_weld_end = {
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2),
	mframe_t(ai_move2, -2, weldstate)
};
const mmove_t fixbot_move_weld_end = mmove_t(fixbot::frames::weldend_01, fixbot::frames::weldend_07, fixbot_frames_weld_end, null);

void fixbot_fire_welder(ASEntity &self)
{
	vec3_t start;
	vec3_t forward, right;
	vec3_t end;
	vec3_t dir;
	vec3_t vec;
	float  r;

	if (self.enemy is null)
		return;

	if (self.spawnflags.has(spawnflags::monsters::SCENIC))
	{
		if (self.timestamp >= level.time)
			return;

		self.timestamp = level.time + random_time(time_ms(450), time_ms(1500));
	}

	vec[0] = 24.0;
	vec[1] = -0.8f;
	vec[2] = -10.0;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, vec, forward, right);

	end = self.enemy.e.s.origin;

	dir = end - start;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::WELDING_SPARKS);
	gi_WriteByte(10);
	gi_WritePosition(start);
	gi_WriteDir(vec3_origin);
	gi_WriteByte(irandom(0xe0, 0xe8));
	gi_multicast(self.e.s.origin, multicast_t::PVS, false);

	if (frandom() > 0.8f)
	{
		r = frandom();

		if (r < 0.33f)
			gi_sound(self.e, soundchan_t::VOICE, fixbot::sounds::weld1, 1, ATTN_IDLE, 0);
		else if (r < 0.66f)
			gi_sound(self.e, soundchan_t::VOICE, fixbot::sounds::weld2, 1, ATTN_IDLE, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, fixbot::sounds::weld3, 1, ATTN_IDLE, 0);
	}
}

void fixbot_fire_blaster(ASEntity &self)
{
	vec3_t start;
	vec3_t forward, right;
	vec3_t end;
	vec3_t dir;

	if (!visible(self, self.enemy))
	{
		M_SetAnimation(self, fixbot_move_run);
	}

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::HOVER_BLASTER_1], forward, right);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	monster_fire_blaster(self, start, dir, 15, 1000, monster_muzzle_t::HOVER_BLASTER_1, effects_t::BLASTER);
}

void fixbot_stand(ASEntity &self)
{
	M_SetAnimation(self, fixbot_move_stand);
}

void fixbot_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, fixbot_move_stand);
	else
		M_SetAnimation(self, fixbot_move_run);
}

void fixbot_walk(ASEntity &self)
{
	vec3_t vec;
	float  len;

	if (self.goalentity !is null && self.goalentity.classname == "object_repair")
	{
		vec = self.e.s.origin - self.goalentity.e.s.origin;
		len = vec.length();
		if (len < 32)
		{
			M_SetAnimation(self, fixbot_move_weld_start);
			return;
		}
	}
	M_SetAnimation(self, fixbot_move_walk);
}

void fixbot_start_attack(ASEntity &self)
{
	M_SetAnimation(self, fixbot_move_start_attack);
}

void fixbot_attack(ASEntity &self)
{
	vec3_t vec;
	float  len;

	if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
	{
		if (!visible(self, self.enemy))
			return;
		vec = self.e.s.origin - self.enemy.e.s.origin;
		len = vec.length();
		if (len > 128)
			return;
		else
			M_SetAnimation(self, fixbot_move_laserattack);
	}
	else
	{
		fixbot_set_fly_parameters(self, false, false, false);
		M_SetAnimation(self, fixbot_move_attack2);
	}
}

void fixbot_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	fixbot_set_fly_parameters(self, false, false, false);
	self.pain_debounce_time = level.time + time_sec(3);
	gi_sound(self.e, soundchan_t::VOICE, fixbot::sounds::pain1, 1, ATTN_NORM, 0);

	if (damage <= 10)
		M_SetAnimation(self, fixbot_move_pain3);
	else if (damage <= 25)
		M_SetAnimation(self, fixbot_move_painb);
	else
		M_SetAnimation(self, fixbot_move_paina);

	abortHeal(self, false, false);
}

void fixbot_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	self.movetype = movetype_t::TOSS;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	self.nextthink = time_zero;
	gi_linkentity(self.e);
}

void fixbot_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	gi_sound(self.e, soundchan_t::VOICE, fixbot::sounds::die, 1, ATTN_NORM, 0);
	BecomeExplosion1(self);

	// shards
}

/*QUAKED monster_fixbot (1 .5 0) (-32 -32 -24) (32 32 24) Ambush Trigger_Spawn Fixit Takeoff Landing
 */
void SP_monster_fixbot(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	fixbot::sounds::pain1.precache();
	fixbot::sounds::die.precache();

	fixbot::sounds::weld1.precache();
	fixbot::sounds::weld2.precache();
	fixbot::sounds::weld3.precache();

	self.e.s.modelindex = gi_modelindex("models/monsters/fixbot/tris.md2");

	self.e.mins = { -32, -32, -24 };
	self.e.maxs = { 32, 32, 24 };

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(150 * st.health_multiplier);
	self.mass = 150;

	@self.pain = fixbot_pain;
	@self.die = fixbot_die;

	@self.monsterinfo.stand = fixbot_stand;
	@self.monsterinfo.walk = fixbot_walk;
	@self.monsterinfo.run = fixbot_run;
	@self.monsterinfo.attack = fixbot_attack;

	gi_linkentity(self.e);

	M_SetAnimation(self, fixbot_move_stand);
	self.monsterinfo.scale = fixbot::SCALE;
	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	fixbot_set_fly_parameters(self, false, false, false);

	flymonster_start(self);
}
