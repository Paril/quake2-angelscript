
/*
=========================================================

  PLATS

  movement options:

  linear
  smooth start, hard stop
  smooth start, smooth stop

  start
  end
  acceleration
  speed
  deceleration
  begin sound
  end sound
  target fired when reaching end
  wait at end

  object characteristics that use move segments
  ---------------------------------------------
  movetype_push, or movetype_stop
  action when touched
  action when blocked
  action when used
	disabled?
  auto trigger spawning


=========================================================
*/

// support routine for setting moveinfo sounds
int32 G_GetMoveinfoSoundIndex(ASEntity &self, const string &in default_value, const string &in wanted_value)
{
	if (wanted_value.empty())
	{
		if (!default_value.empty())
			return gi_soundindex(default_value);

		return 0;
	}
	else if (wanted_value == "0" || wanted_value == " ")
		return 0;

	return gi_soundindex(wanted_value);
}

void G_SetMoveinfoSounds(ASEntity &self, const string &in default_start, const string &in default_mid, const string &in default_end)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	self.moveinfo.sound_start = G_GetMoveinfoSoundIndex(self, default_start, st.noise_start);
	self.moveinfo.sound_middle = G_GetMoveinfoSoundIndex(self, default_mid, st.noise_middle);
	self.moveinfo.sound_end = G_GetMoveinfoSoundIndex(self, default_end, st.noise_end);
}

//
// Support routines for movement (changes in origin using velocity)
//

void Move_Done(ASEntity &ent)
{
	ent.velocity = vec3_origin;
	ent.moveinfo.endfunc(ent);
}

void Move_Final(ASEntity &ent)
{
    ent.moveinfo.curve_positions.resize(0);

	if (ent.moveinfo.remaining_distance == 0)
	{
		Move_Done(ent);
		return;
	}

	// [Paril-KEX] use exact remaining distance
	ent.velocity = (ent.moveinfo.dest - ent.e.s.origin) * (1.0f / gi_frame_time_s);

	@ent.think = Move_Done;
	ent.nextthink = level.time + FRAME_TIME_S;
}

void Move_Begin(ASEntity &ent)
{
	float frames;

	if ((ent.moveinfo.speed * gi_frame_time_s) >= ent.moveinfo.remaining_distance)
	{
		Move_Final(ent);
		return;
	}
	ent.velocity = ent.moveinfo.dir * ent.moveinfo.speed;
	frames = floor((ent.moveinfo.remaining_distance / ent.moveinfo.speed) / gi_frame_time_s);
	ent.moveinfo.remaining_distance -= frames * ent.moveinfo.speed * gi_frame_time_s;
	ent.nextthink = level.time + (FRAME_TIME_S * frames);
	@ent.think = Move_Final;
}

float AccelerationDistance(float target, float rate)
{
	return (target * ((target / rate) + 1) / 2);
}

void Move_Regular(ASEntity &ent, const vec3_t &in dest, move_endfunc_f @endfunc)
{
	if (level.current_entity is ((ent.flags & ent_flags_t::TEAMSLAVE) != 0 ? ent.teammaster : ent))
	{
		Move_Begin(ent);
	}
	else
	{
		ent.nextthink = level.time + FRAME_TIME_S;
		@ent.think = Move_Begin;
	}
}

void Move_Calc(ASEntity &ent, const vec3_t &in dest, move_endfunc_f @endfunc)
{
	ent.velocity = vec3_origin;
	ent.moveinfo.dest = dest;
	ent.moveinfo.dir = dest - ent.e.s.origin;
	ent.moveinfo.remaining_distance = ent.moveinfo.dir.normalize();
	@ent.moveinfo.endfunc = endfunc;

	if (ent.moveinfo.speed == ent.moveinfo.accel && ent.moveinfo.speed == ent.moveinfo.decel)
	{
		Move_Regular(ent, dest, endfunc);
	}
	else
	{
		// accelerative
		ent.moveinfo.current_speed = 0;

		if (gi_tick_rate == 10)
			@ent.think = Think_AccelMove;
		else
		{
			// [Paril-KEX] rewritten to work better at higher tickrates
			ent.moveinfo.curve_frame = 0;
			ent.moveinfo.num_subframes = uint((0.1f / gi_frame_time_s) - 1);

			float total_dist = ent.moveinfo.remaining_distance;

			array<float> distances;

			if (ent.moveinfo.num_subframes != 0)
			{
				distances.push_back(0);
				ent.moveinfo.curve_frame = 1;
			}
			else
				ent.moveinfo.curve_frame = 0;

			// simulate 10hz movement
			while (ent.moveinfo.remaining_distance > 0)
			{
				if (!Think_AccelMove_MoveInfo(ent.moveinfo))
					break;

				ent.moveinfo.remaining_distance -= ent.moveinfo.current_speed;
				distances.push_back(total_dist - ent.moveinfo.remaining_distance);
			}

			if (ent.moveinfo.num_subframes != 0)
				distances.push_back(total_dist);

			ent.moveinfo.subframe = 0;
			ent.moveinfo.curve_ref = ent.e.s.origin;
			ent.moveinfo.curve_positions = distances;

			ent.moveinfo.num_frames_done = 0;

			@ent.think = Think_AccelMove_New;
		}

		ent.nextthink = level.time + FRAME_TIME_S;
	}
}

void Think_AccelMove_New(ASEntity &ent)
{
	float t = 0.0f;
	float target_dist;

	if (ent.moveinfo.num_subframes != 0)
	{
		if (ent.moveinfo.subframe == ent.moveinfo.num_subframes + 1)
		{
			ent.moveinfo.subframe = 0;
			ent.moveinfo.curve_frame++;

			if (ent.moveinfo.curve_frame == ent.moveinfo.curve_positions.length())
			{
				Move_Final(ent);
				return;
			}
		}

		t = (ent.moveinfo.subframe + 1) / (float(ent.moveinfo.num_subframes + 1));

		target_dist = lerp(ent.moveinfo.curve_positions[ent.moveinfo.curve_frame - 1], ent.moveinfo.curve_positions[ent.moveinfo.curve_frame], t);
		ent.moveinfo.subframe++;
	}
	else
	{
		if (ent.moveinfo.curve_frame == ent.moveinfo.curve_positions.length())
		{
			Move_Final(ent);
			return;
		}

		target_dist = ent.moveinfo.curve_positions[ent.moveinfo.curve_frame++];
	}

	ent.moveinfo.num_frames_done++;
	vec3_t target_pos = ent.moveinfo.curve_ref + (ent.moveinfo.dir * target_dist);
	ent.velocity = (target_pos - ent.e.s.origin) * (1.0f / gi_frame_time_s);
	ent.nextthink = level.time + FRAME_TIME_S;
}

//
// Support routines for angular movement (changes in angle using avelocity)
//

void AngleMove_Done(ASEntity &ent)
{
	ent.avelocity = vec3_origin;
	ent.moveinfo.endfunc(ent);
}

void AngleMove_Final(ASEntity &ent)
{
	vec3_t move;

	if (ent.moveinfo.state == move_state_t::UP)
	{
		if (ent.moveinfo.reversing)
			move = ent.moveinfo.end_angles_reversed - ent.e.s.angles;
		else
			move = ent.moveinfo.end_angles - ent.e.s.angles;
	}
	else
		move = ent.moveinfo.start_angles - ent.e.s.angles;

	if (!move)
	{
		AngleMove_Done(ent);
		return;
	}

	ent.avelocity = move * (1.0f / gi_frame_time_s);

	@ent.think = AngleMove_Done;
	ent.nextthink = level.time + FRAME_TIME_S;
}

void AngleMove_Begin(ASEntity &ent)
{
	vec3_t destdelta;
	float  len;
	float  traveltime;
	float  frames;

	// PGM		accelerate as needed
	if (ent.moveinfo.speed < ent.speed)
	{
		ent.moveinfo.speed += ent.accel;
		if (ent.moveinfo.speed > ent.speed)
			ent.moveinfo.speed = ent.speed;
	}
	// PGM

	// set destdelta to the vector needed to move
	if (ent.moveinfo.state == move_state_t::UP)
	{
		if (ent.moveinfo.reversing)
			destdelta = ent.moveinfo.end_angles_reversed - ent.e.s.angles;
		else
			destdelta = ent.moveinfo.end_angles - ent.e.s.angles;
	}
	else
		destdelta = ent.moveinfo.start_angles - ent.e.s.angles;

	// calculate length of vector
	len = destdelta.length();

	// divide by speed to get time to reach dest
	traveltime = len / ent.moveinfo.speed;

	if (traveltime < gi_frame_time_s)
	{
		AngleMove_Final(ent);
		return;
	}

	frames = floor(traveltime / gi_frame_time_s);

	// scale the destdelta vector by the time spent traveling to get velocity
	ent.avelocity = destdelta * (1.0f / traveltime);

	// PGM
	//  if we're done accelerating, act as a normal rotation
	if (ent.moveinfo.speed >= ent.speed)
	{
		// set nextthink to trigger a think when dest is reached
		ent.nextthink = level.time + (FRAME_TIME_S * frames);
		@ent.think = AngleMove_Final;
	}
	else
	{
		ent.nextthink = level.time + FRAME_TIME_S;
		@ent.think = AngleMove_Begin;
	}
	// PGM
}

void AngleMove_Calc(ASEntity &ent, move_endfunc_f @endfunc)
{
	ent.avelocity = vec3_origin;
	@ent.moveinfo.endfunc = endfunc;

	// PGM
	//  if we're supposed to accelerate, this will tell anglemove_begin to do so
	if (ent.accel != ent.speed)
		ent.moveinfo.speed = 0;
	// PGM

	if (level.current_entity is ((ent.flags & ent_flags_t::TEAMSLAVE) != 0 ? ent.teammaster : ent))
	{
		AngleMove_Begin(ent);
	}
	else
	{
		ent.nextthink = level.time + FRAME_TIME_S;
		@ent.think = AngleMove_Begin;
	}
}

/*
==============
Think_AccelMove

The team has completed a frame of movement, so
change the speed for the next frame
==============
*/
void plat_CalcAcceleratedMove(moveinfo_t &moveinfo)
{
	float accel_dist;
	float decel_dist;

	if (moveinfo.remaining_distance < moveinfo.accel)
	{
		moveinfo.move_speed = moveinfo.speed;
		moveinfo.current_speed = moveinfo.remaining_distance;
		return;
	}

	accel_dist = AccelerationDistance(moveinfo.speed, moveinfo.accel);
	decel_dist = AccelerationDistance(moveinfo.speed, moveinfo.decel);

	if ((moveinfo.remaining_distance - accel_dist - decel_dist) < 0)
	{
		float f;

		f = (moveinfo.accel + moveinfo.decel) / (moveinfo.accel * moveinfo.decel);
		moveinfo.move_speed = moveinfo.current_speed =
			(-2 + sqrt(4 - 4 * f * (-2 * moveinfo.remaining_distance))) / (2 * f);
		decel_dist = AccelerationDistance(moveinfo.move_speed, moveinfo.decel);
	}
	else
		moveinfo.move_speed = moveinfo.speed;

	moveinfo.decel_distance = decel_dist;
}

void plat_Accelerate(moveinfo_t &moveinfo)
{
	// are we decelerating?
	if (moveinfo.remaining_distance <= moveinfo.decel_distance)
	{
		if (moveinfo.remaining_distance < moveinfo.decel_distance)
		{
			if (moveinfo.next_speed != 0)
			{
				moveinfo.current_speed = moveinfo.next_speed;
				moveinfo.next_speed = 0;
				return;
			}
			if (moveinfo.current_speed > moveinfo.decel)
			{
				moveinfo.current_speed -= moveinfo.decel;

				// [Paril-KEX] fix platforms in xdm6, etc
				if (abs(moveinfo.current_speed) < 0.01f)
					moveinfo.current_speed = moveinfo.remaining_distance + 1;
			}
		}
		return;
	}
	
	// are we at full speed and need to start decelerating during this move?
	if (moveinfo.current_speed == moveinfo.move_speed)
		if ((moveinfo.remaining_distance - moveinfo.current_speed) < moveinfo.decel_distance)
		{
			float p1_distance;
			float p2_distance;
			float distance;

			p1_distance = moveinfo.remaining_distance - moveinfo.decel_distance;
			p2_distance = moveinfo.move_speed * (1.0f - (p1_distance / moveinfo.move_speed));
			distance = p1_distance + p2_distance;
			moveinfo.current_speed = moveinfo.move_speed;
			moveinfo.next_speed = moveinfo.move_speed - moveinfo.decel * (p2_distance / distance);
			return;
		}

	// are we accelerating?
	if (moveinfo.current_speed < moveinfo.speed)
	{
		float old_speed;
		float p1_distance;
		float p1_speed;
		float p2_distance;
		float distance;

		old_speed = moveinfo.current_speed;

		// figure simple acceleration up to move_speed
		moveinfo.current_speed += moveinfo.accel;
		if (moveinfo.current_speed > moveinfo.speed)
			moveinfo.current_speed = moveinfo.speed;

		// are we accelerating throughout this entire move?
		if ((moveinfo.remaining_distance - moveinfo.current_speed) >= moveinfo.decel_distance)
			return;

		// during this move we will accelerate from current_speed to move_speed
		// and cross over the decel_distance; figure the average speed for the
		// entire move
		p1_distance = moveinfo.remaining_distance - moveinfo.decel_distance;
		p1_speed = (old_speed + moveinfo.move_speed) / 2.0f;
		p2_distance = moveinfo.move_speed * (1.0f - (p1_distance / p1_speed));
		distance = p1_distance + p2_distance;
		moveinfo.current_speed =
			(p1_speed * (p1_distance / distance)) + (moveinfo.move_speed * (p2_distance / distance));
		moveinfo.next_speed = moveinfo.move_speed - moveinfo.decel * (p2_distance / distance);
		return;
	}

	// we are at constant velocity (move_speed)
	return;
}

bool Think_AccelMove_MoveInfo (moveinfo_t &moveinfo)
{
	if (moveinfo.current_speed == 0)		// starting or blocked
		plat_CalcAcceleratedMove(moveinfo);

	plat_Accelerate(moveinfo);

	// will the entire move complete on next frame?
	return moveinfo.remaining_distance > moveinfo.current_speed;
}

// Paril: old acceleration code; this is here only to support old save games.
void Think_AccelMove(ASEntity &ent)
{
	// [Paril-KEX] calculate distance dynamically
	if (ent.moveinfo.state == move_state_t::UP)
		ent.moveinfo.remaining_distance = (ent.moveinfo.start_origin - ent.e.s.origin).length();
	else
		ent.moveinfo.remaining_distance = (ent.moveinfo.end_origin - ent.e.s.origin).length();

	// will the entire move complete on next frame?
	if (!Think_AccelMove_MoveInfo(ent.moveinfo))
	{
		Move_Final(ent);
		return;
	}

	if (ent.moveinfo.remaining_distance <= ent.moveinfo.current_speed)
	{
		Move_Final(ent);
		return;
	}

	ent.velocity = ent.moveinfo.dir * (ent.moveinfo.current_speed * 10);
	ent.nextthink = level.time + time_hz(10);
	@ent.think = Think_AccelMove;
}

void plat_hit_top(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_end != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_end, 1, ATTN_STATIC, 0);
	}
	ent.e.s.sound = 0;
	ent.moveinfo.state = move_state_t::TOP;

	@ent.think = plat_go_down;
	ent.nextthink = level.time + time_sec(3);
}

void plat_hit_bottom(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_end != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_end, 1, ATTN_STATIC, 0);
	}
	ent.e.s.sound = 0;
	ent.moveinfo.state = move_state_t::BOTTOM;

	// ROGUE
	plat2_kill_danger_area(ent);
	// ROGUE
}

void plat_go_down(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_start != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	ent.e.s.sound = ent.moveinfo.sound_middle;

	ent.moveinfo.state = move_state_t::DOWN;
	Move_Calc(ent, ent.moveinfo.end_origin, plat_hit_bottom);
}

void plat_go_up(ASEntity &ent)
{
	if ((ent.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (ent.moveinfo.sound_start != 0)
			gi_sound(ent.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), ent.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	ent.e.s.sound = ent.moveinfo.sound_middle;

	ent.moveinfo.state = move_state_t::UP;
	Move_Calc(ent, ent.moveinfo.start_origin, plat_hit_top);

	// ROGUE
	plat2_spawn_danger_area(ent);
	// ROGUE
}

void plat_blocked(ASEntity &self, ASEntity &other)
{
	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::CRUSH);
		// if it's still there, nuke it
		if (other.e.inuse && other.e.solid != solid_t::NOT) // PGM
			BecomeExplosion1(other);
		return;
	}

	// PGM
	//  gib dead things
	if (other.health < 1)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100, 1, damageflags_t::NONE, mod_id_t::CRUSH);
	// PGM

	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);

	// [Paril-KEX] killed the thing, so don't switch directions
	if (!other.e.inuse || other.e.solid == solid_t::NOT)
		return;

	if (self.moveinfo.state == move_state_t::UP)
		plat_go_down(self);
	else if (self.moveinfo.state == move_state_t::DOWN)
		plat_go_up(self);
}

namespace spawnflags::plat
{
    const spawnflags_t LOW_TRIGGER = spawnflag_dec(1);
    const spawnflags_t NO_MONSTER = spawnflag_dec(2);
}

void Use_Plat(ASEntity &ent, ASEntity &other, ASEntity @activator)
{
	//======
	// ROGUE
	// if a monster is using us, then allow the activity when stopped.
	if ((other.e.svflags & svflags_t::MONSTER) != 0 && !ent.spawnflags.has(spawnflags::plat::NO_MONSTER))
	{
		if (ent.moveinfo.state == move_state_t::TOP)
			plat_go_down(ent);
		else if (ent.moveinfo.state == move_state_t::BOTTOM)
			plat_go_up(ent);

		return;
	}
	// ROGUE
	//======

	if (ent.think !is null)
		return; // already down
	plat_go_down(ent);
}

void Touch_Plat_Center(ASEntity &ent, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client is null)
		return;

	if (other.health <= 0)
		return;

	ASEntity @plat = ent.enemy; // now point at the plat, not the trigger
	if (plat.moveinfo.state == move_state_t::BOTTOM)
		plat_go_up(plat);
	else if (plat.moveinfo.state == move_state_t::TOP)
		plat.nextthink = level.time + time_sec(1); // the player is still on the plat, so delay going down
}

// PGM - plat2's change the trigger field
ASEntity @plat_spawn_inside_trigger(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	ASEntity @trigger;
	vec3_t	 tmin, tmax;

	//
	// middle trigger
	//
	@trigger = G_Spawn();
	@trigger.touch = Touch_Plat_Center;
	trigger.movetype = movetype_t::NONE;
	trigger.e.solid = solid_t::TRIGGER;
	@trigger.enemy = ent;

	tmin.x = ent.e.mins.x + 25;
	tmin.y = ent.e.mins.y + 25;
	tmin.z = ent.e.mins.z;

	tmax.x = ent.e.maxs.x - 25;
	tmax.y = ent.e.maxs.y - 25;
	tmax.z = ent.e.maxs.z + 8;

	tmin.z = tmax.z - (ent.pos1.z - ent.pos2.z + st.lip);

	if (ent.spawnflags.has(spawnflags::plat::LOW_TRIGGER))
		tmax.z = tmin.z + 8;

	if (tmax.x - tmin.x <= 0)
	{
		tmin.x = (ent.e.mins.x + ent.e.maxs.x) * 0.5f;
		tmax.x = tmin.x + 1;
	}
	if (tmax.y - tmin.y <= 0)
	{
		tmin.y = (ent.e.mins.y + ent.e.maxs.y) * 0.5f;
		tmax.y = tmin.y + 1;
	}

	trigger.e.mins = tmin;
	trigger.e.maxs = tmax;

	gi_linkentity(trigger.e);

	return trigger; // PGM 11/17/97
}

/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is triggered, when it will lower and become a normal plat.

"speed"	overrides default 200.
"accel" overrides default 500
"lip"	overrides default 8 pixel lip

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.

Set "sounds" to one of the following:
1) base fast
2) chain slow
*/
void SP_func_plat(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	ent.e.s.angles = vec3_origin;
	ent.e.solid = solid_t::BSP;
	ent.movetype = movetype_t::PUSH;

	gi_setmodel(ent.e, ent.model);

	@ent.moveinfo.blocked = plat_blocked;

	if (ent.speed == 0)
		ent.speed = 20;
	else
		ent.speed *= 0.1f;

	if (ent.accel == 0)
		ent.accel = 5;
	else
		ent.accel *= 0.1f;

	if (ent.decel == 0)
		ent.decel = 5;
	else
		ent.decel *= 0.1f;

	if (ent.dmg == 0)
		ent.dmg = 2;

	float lip = st.lip;

	if (!st.was_key_specified("lip"))
		lip = 8;

	// pos1 is the top position, pos2 is the bottom
	ent.pos1 = ent.e.s.origin;
	ent.pos2 = ent.e.s.origin; 
	if (st.height != 0)
		ent.pos2[2] -= st.height;
	else
		ent.pos2[2] -= (ent.e.maxs[2] - ent.e.mins[2]) - lip;

	@ent.use = Use_Plat;

	plat_spawn_inside_trigger(ent); // the "start moving" trigger

	if (!ent.targetname.empty())
	{
		ent.moveinfo.state = move_state_t::UP;
	}
	else
	{
		ent.e.s.origin = ent.pos2;
		gi_linkentity(ent.e);
		ent.moveinfo.state = move_state_t::BOTTOM;
	}

	ent.moveinfo.speed = ent.speed;
	ent.moveinfo.accel = ent.accel;
	ent.moveinfo.decel = ent.decel;
	ent.moveinfo.wait = ent.wait;
	ent.moveinfo.start_origin = ent.pos1;
	ent.moveinfo.start_angles = ent.e.s.angles;
	ent.moveinfo.end_origin = ent.pos2;
	ent.moveinfo.end_angles = ent.e.s.angles;

	G_SetMoveinfoSounds(ent, "plats/pt1_strt.wav", "plats/pt1_mid.wav", "plats/pt1_end.wav");
}

//====================================================================

// Paril: Rogue added a spawnflag in func_rotating that
// is a reserved editor flag.
namespace spawnflags::rotating
{
    const spawnflags_t START_ON = spawnflag_dec(1);
    const spawnflags_t REVERSE = spawnflag_dec(2);
    const spawnflags_t X_AXIS = spawnflag_dec(4);
    const spawnflags_t Y_AXIS = spawnflag_dec(8);
    const spawnflags_t TOUCH_PAIN = spawnflag_dec(16);
    const spawnflags_t STOP = spawnflag_dec(32);
    const spawnflags_t ANIMATED = spawnflag_dec(64);
    const spawnflags_t ANIMATED_FAST = spawnflag_dec(128);
    const spawnflags_t ACCEL = spawnflag_dec(0x00010000);
}

/*QUAKED func_rotating (0 .5 .8) ? START_ON REVERSE X_AXIS Y_AXIS TOUCH_PAIN STOP ANIMATED ANIMATED_FAST NOT_EASY NOT_MEDIUM NOT_HARD NOT_DM NOT_COOP RESERVED1 COOP_ONLY RESERVED2 ACCEL
You need to have an origin brush as part of this entity.
The center of that brush will be the point around which it is rotated. It will rotate around the Z axis by default.
You can check either the X_AXIS or Y_AXIS box to change that.

func_rotating will use it's targets when it stops and starts.

"speed" determines how fast it moves; default value is 100.
"dmg"	damage to inflict when blocked (2 default)
"accel" if specified, is how much the rotation speed will increase per .1sec.

REVERSE will cause the it to rotate in the opposite direction.
STOP mean it will stop moving instead of pushing entities
ACCEL means it will accelerate to it's final speed and decelerate when shutting down.
*/

//============
// PGM
void rotating_accel(ASEntity &self)
{
	float current_speed;

	current_speed = self.avelocity.length();
	if (current_speed >= (self.speed - self.accel)) // done
	{
		self.avelocity = self.movedir * self.speed;
		G_UseTargets(self, self);
	}
	else
	{
		current_speed += self.accel;
		self.avelocity = self.movedir * current_speed;
		@self.think = rotating_accel;
		self.nextthink = level.time + FRAME_TIME_S;
	}
}

void rotating_decel(ASEntity &self)
{
	float current_speed;

	current_speed = self.avelocity.length();
	if (current_speed <= self.decel) // done
	{
		self.avelocity = vec3_origin;
		G_UseTargets(self, self);
		@self.touch = null;
	}
	else
	{
		current_speed -= self.decel;
		self.avelocity = self.movedir * current_speed;
		@self.think = rotating_decel;
		self.nextthink = level.time + FRAME_TIME_S;
	}
}
// PGM
//============

void rotating_blocked(ASEntity &self, ASEntity &other)
{
	if (self.dmg == 0)
		return;
	if (level.time < self.touch_debounce_time)
		return;
	self.touch_debounce_time = level.time + time_hz(10);
	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
}

void rotating_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (self.avelocity)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
}

void rotating_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.avelocity)
	{
		self.e.s.sound = 0;
		// PGM
		if (self.spawnflags.has(spawnflags::rotating::ACCEL)) // Decelerate
			rotating_decel(self);
		else
		{
			self.avelocity = vec3_origin;
			G_UseTargets(self, self);
			@self.touch = null;
		}
		// PGM
	}
	else
	{
		self.e.s.sound = self.moveinfo.sound_middle;
		// PGM
		if (self.spawnflags.has(spawnflags::rotating::ACCEL)) // accelerate
			rotating_accel(self);
		else
		{
			self.avelocity = self.movedir * self.speed;
			G_UseTargets(self, self);
		}
		if (self.spawnflags.has(spawnflags::rotating::TOUCH_PAIN))
			@self.touch = rotating_touch;
		// PGM
	}
}

void SP_func_rotating(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	ent.e.solid = solid_t::BSP;
	if (ent.spawnflags.has(spawnflags::rotating::STOP))
		ent.movetype = movetype_t::STOP;
	else
		ent.movetype = movetype_t::PUSH;

	if (!st.noise.empty())
	{
		ent.moveinfo.sound_middle = gi_soundindex(st.noise);

		// [Paril-KEX] for rhangar1 doors
		if (!st.was_key_specified("attenuation"))
			ent.attenuation = ATTN_STATIC;
		else
		{
			if (ent.attenuation == -1)
			{
				ent.e.s.loop_attenuation = ATTN_LOOP_NONE;
				ent.attenuation = ATTN_NONE;
			}
			else
			{
				ent.e.s.loop_attenuation = ent.attenuation;
			}
		}
	}

	// set the axis of rotation
	ent.movedir = vec3_origin;
	if (ent.spawnflags.has(spawnflags::rotating::X_AXIS))
		ent.movedir.z = 1.0;
	else if (ent.spawnflags.has(spawnflags::rotating::Y_AXIS))
		ent.movedir.x = 1.0;
	else // Z_AXIS
		ent.movedir.y = 1.0;

	// check for reverse rotation
	if (ent.spawnflags.has(spawnflags::rotating::REVERSE))
		ent.movedir = -ent.movedir;

	if (ent.speed == 0)
		ent.speed = 100;
	if (!st.was_key_specified("dmg"))
		ent.dmg = 2;

	@ent.use = rotating_use;
	if (ent.dmg != 0)
		@ent.moveinfo.blocked = rotating_blocked;

	if (ent.spawnflags.has(spawnflags::rotating::START_ON))
		ent.use(ent, world, null);

	if (ent.spawnflags.has(spawnflags::rotating::ANIMATED))
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM_ALL);
	if (ent.spawnflags.has(spawnflags::rotating::ANIMATED_FAST))
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM_ALLFAST);

	// PGM
	if (ent.spawnflags.has(spawnflags::rotating::ACCEL)) // Accelerate / Decelerate
	{
		if (ent.accel == 0)
			ent.accel = 1;
		else if (ent.accel > ent.speed)
			ent.accel = ent.speed;

		if (ent.decel == 0)
			ent.decel = 1;
		else if (ent.decel > ent.speed)
			ent.decel = ent.speed;
	}
	// PGM

	gi_setmodel(ent.e, ent.model);
	gi_linkentity(ent.e);
}

void func_spinning_think(ASEntity &ent)
{
	if (ent.timestamp <= level.time)
	{
		ent.timestamp = level.time + random_time(time_sec(1), time_sec(6));
		ent.movedir = { ent.decel + frandom(ent.speed - ent.decel), ent.decel + frandom(ent.speed - ent.decel), ent.decel + frandom(ent.speed - ent.decel) };

		for (int32 i = 0; i < 3; i++)
		{
			if (brandom())
				ent.movedir[i] = -ent.movedir[i];
		}
	}

	for (int32 i = 0; i < 3; i++)
	{
		if (ent.avelocity[i] == ent.movedir[i])
			continue;

		if (ent.avelocity[i] < ent.movedir[i])
			ent.avelocity[i] = min(ent.movedir[i], ent.avelocity[i] + ent.accel);
		else
			ent.avelocity[i] = max(ent.movedir[i], ent.avelocity[i] - ent.accel);
	}

	ent.nextthink = level.time + FRAME_TIME_MS;
}

// [Paril-KEX]
void SP_func_spinning(ASEntity &ent)
{
	ent.e.solid = solid_t::BSP;

	if (ent.speed == 0)
		ent.speed = 100;
	if (ent.dmg == 0)
		ent.dmg = 2;

	ent.movetype = movetype_t::PUSH;

	ent.timestamp = time_zero;
	ent.nextthink = level.time + FRAME_TIME_MS;
	@ent.think = func_spinning_think;

	gi_setmodel(ent.e, ent.model);
	gi_linkentity(ent.e);
}


/*
======================================================================

BUTTONS

======================================================================
*/

/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
1) silent
2) steam metal
3) wooden clunk
4) metallic click
5) in-out
*/

void button_done(ASEntity &self)
{
	self.moveinfo.state = move_state_t::BOTTOM;
	if (!self.bmodel_anim.enabled)
	{
		if (level.is_n64)
			self.e.s.frame = 0;
		else
			self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::ANIM23);
		self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM01);
	}
	else
		self.bmodel_anim.alternate = false;
}

void button_return(ASEntity &self)
{
	self.moveinfo.state = move_state_t::DOWN;

	Move_Calc(self, self.moveinfo.start_origin, button_done);

	if (self.health != 0)
		self.takedamage = true;
}

void button_wait(ASEntity &self)
{
	self.moveinfo.state = move_state_t::TOP;
	
	if (!self.bmodel_anim.enabled)
	{
		self.e.s.effects = effects_t(self.e.s.effects & ~effects_t::ANIM01);
		if (level.is_n64)
			self.e.s.frame = 2;
		else
			self.e.s.effects = effects_t(self.e.s.effects | effects_t::ANIM23);
	}
	else
		self.bmodel_anim.alternate = true;

	G_UseTargets(self, self.activator);

	if (self.moveinfo.wait >= 0)
	{
		self.nextthink = level.time + time_sec(self.moveinfo.wait);
		@self.think = button_return;
	}
}

void button_fire(ASEntity &self)
{
	if (self.moveinfo.state == move_state_t::UP || self.moveinfo.state == move_state_t::TOP)
		return;

	self.moveinfo.state = move_state_t::UP;
	if (self.moveinfo.sound_start != 0 && (self.flags & ent_flags_t::TEAMSLAVE) == 0)
		gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), self.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	Move_Calc(self, self.moveinfo.end_origin, button_wait);
}

void button_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;
	button_fire(self);
}

void button_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client is null)
		return;

	if (other.health <= 0)
		return;

	@self.activator = other;
	button_fire(self);
}

void button_killed(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	@self.activator = attacker;
	self.health = self.max_health;
	self.takedamage = false;
	button_fire(self);
}

void SP_func_button(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	vec3_t abs_movedir;
	float  dist;

	G_SetMovedir(ent, ent.movedir);
	ent.movetype = movetype_t::STOP;
	ent.e.solid = solid_t::BSP;
	gi_setmodel(ent.e, ent.model);

	if (ent.sounds != 1)
		G_SetMoveinfoSounds(ent, "switches/butn2.wav", "", "");
	else
		G_SetMoveinfoSounds(ent, "", "", "");

	if (ent.speed == 0)
		ent.speed = 40;
	if (ent.accel == 0)
		ent.accel = ent.speed;
	if (ent.decel == 0)
		ent.decel = ent.speed;

	if (ent.wait == 0)
		ent.wait = 3;

	float lip = st.lip;

	if (lip == 0)
		lip = 4;

	ent.pos1 = ent.e.s.origin;
	abs_movedir.x = abs(ent.movedir.x);
	abs_movedir.y = abs(ent.movedir.y);
	abs_movedir.z = abs(ent.movedir.z);
	dist = abs_movedir.x * ent.e.size.x + abs_movedir.y * ent.e.size.y + abs_movedir.z * ent.e.size.z - lip;
	ent.pos2 = ent.pos1 + (ent.movedir * dist);

	@ent.use = button_use;

	if (!ent.bmodel_anim.enabled)
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM01);

	if (ent.health != 0)
	{
		ent.max_health = ent.health;
		@ent.die = button_killed;
		ent.takedamage = true;
	}
	else if (ent.targetname.empty())
		@ent.touch = button_touch;

	ent.moveinfo.state = move_state_t::BOTTOM;

	ent.moveinfo.speed = ent.speed;
	ent.moveinfo.accel = ent.accel;
	ent.moveinfo.decel = ent.decel;
	ent.moveinfo.wait = ent.wait;
	ent.moveinfo.start_origin = ent.pos1;
	ent.moveinfo.start_angles = ent.e.s.angles;
	ent.moveinfo.end_origin = ent.pos2;
	ent.moveinfo.end_angles = ent.e.s.angles;

	gi_linkentity(ent.e);
}

namespace spawnflags::door
{
    const spawnflags_t START_OPEN = spawnflag_dec(1);
    const spawnflags_t REVERSE = spawnflag_dec(2);
    const spawnflags_t CRUSHER = spawnflag_dec(4);
    const spawnflags_t NOMONSTER = spawnflag_dec(8);
    const spawnflags_t ANIMATED = spawnflag_dec(16);
    const spawnflags_t TOGGLE = spawnflag_dec(32);
    const spawnflags_t ANIMATED_FAST = spawnflag_dec(64);
}


/*
======================================================================

DOORS

  spawn a trigger surrounding the entire team unless it is
  already targeted by another

======================================================================
*/

/*QUAKED func_door (0 .5 .8) ? START_OPEN x CRUSHER NOMONSTER ANIMATED TOGGLE ANIMATED_FAST
TOGGLE		wait in both the start and end states for a trigger event.
START_OPEN	the door to moves to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not useful for touch or takedamage doors).
NOMONSTER	monsters will not trigger this door

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
1)	silent
2)	light
3)	medium
4)	heavy
*/

void door_use_areaportals(ASEntity &self, bool open)
{
	ASEntity @t = null;

	if (self.target.empty())
		return;

	while ((@t = find_by_str<ASEntity>(t, "targetname", self.target)) !is null)
	{
		if (Q_strcasecmp(t.classname, "func_areaportal") == 0)
		{
			gi_SetAreaPortalState(t.style, open);
		}
	}
}

void door_play_sound(ASEntity &self, int32 sound)
{
	if (self.teammaster is null)
	{
		gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), sound, 1, self.attenuation, 0);
		return;
	}

	vec3_t p = vec3_origin;
	int32 c = 0;

	for (ASEntity @t = self.teammaster; t !is null; @t = t.teamchain)
	{
		p += (t.e.absmin + t.e.absmax) * 0.5f;
		c++;
	}

	if (c == 1)
	{
		gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), sound, 1, self.attenuation, 0);
		return;
	}

	p /= c;

	if ((gi_pointcontents(p) & contents_t::SOLID) != 0)
	{
		gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), sound, 1, self.attenuation, 0);
		return;
	}

	gi_positioned_sound(p, self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), sound, 1, self.attenuation, 0);
}

void door_hit_top(ASEntity &self)
{
	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_end != 0)
			door_play_sound(self, self.moveinfo.sound_end);
	}
	self.e.s.sound = 0;
	self.moveinfo.state = move_state_t::TOP;
	if (self.spawnflags.has(spawnflags::door::TOGGLE))
		return;
	if (self.moveinfo.wait >= 0)
	{
		@self.think = door_go_down;
		self.nextthink = level.time + time_sec(self.moveinfo.wait);
	}

	if (self.spawnflags.has(spawnflags::door::START_OPEN))
		door_use_areaportals(self, false);
}

void door_hit_bottom(ASEntity &self)
{
	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_end != 0)
			door_play_sound(self, self.moveinfo.sound_end);
	}
	self.e.s.sound = 0;
	self.moveinfo.state = move_state_t::BOTTOM;

	if (!self.spawnflags.has(spawnflags::door::START_OPEN))
		door_use_areaportals(self, false);
}

void door_go_down(ASEntity &self)
{
	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_start != 0)
			door_play_sound(self, self.moveinfo.sound_start);
	}

	self.e.s.sound = self.moveinfo.sound_middle;

	if (self.max_health != 0)
	{
		self.takedamage = true;
		self.health = self.max_health;
	}

	self.moveinfo.state = move_state_t::DOWN;
	if (self.classname == "func_door" ||
		self.classname == "func_water" ||
		self.classname == "func_door_secret")
		Move_Calc(self, self.moveinfo.start_origin, door_hit_bottom);
	else if (self.classname == "func_door_rotating")
		AngleMove_Calc(self, door_hit_bottom);

	if (self.spawnflags.has(spawnflags::door::START_OPEN))
		door_use_areaportals(self, true);
}

void door_go_up(ASEntity &self, ASEntity @activator)
{
	if (self.moveinfo.state == move_state_t::UP)
		return; // already going up

	if (self.moveinfo.state == move_state_t::TOP)
	{ // reset top wait time
		if (self.moveinfo.wait >= 0)
			self.nextthink = level.time + time_sec(self.moveinfo.wait);
		return;
	}

	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_start != 0)
			door_play_sound(self, self.moveinfo.sound_start);
	}

	self.e.s.sound = self.moveinfo.sound_middle;

	self.moveinfo.state = move_state_t::UP;
	if (self.classname == "func_door" ||
		self.classname == "func_water" ||
		self.classname == "func_door_secret")
		Move_Calc(self, self.moveinfo.end_origin, door_hit_top);
	else if (self.classname == "func_door_rotating")
		AngleMove_Calc(self, door_hit_top);

	G_UseTargets(self, activator);

	if (!self.spawnflags.has(spawnflags::door::START_OPEN))
		door_use_areaportals(self, true);
}

//======
// PGM
void smart_water_go_up(ASEntity &self)
{
	float	 distance;
	ASEntity @lowestPlayer;
	ASEntity @ent;
	float	 lowestPlayerPt;

	if (self.moveinfo.state == move_state_t::TOP)
	{ // reset top wait time
		if (self.moveinfo.wait >= 0)
			self.nextthink = level.time + time_sec(self.moveinfo.wait);
		return;
	}

	if (self.health != 0)
	{
		if (self.e.absmax[2] >= self.health)
		{
			self.velocity = vec3_origin;
			self.nextthink = time_zero;
			self.moveinfo.state = move_state_t::TOP;
			return;
		}
	}

	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_start != 0)
			gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), self.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	self.e.s.sound = self.moveinfo.sound_middle;

	// find the lowest player point.
	lowestPlayerPt = 999999;
	@lowestPlayer = null;
	for (uint32 i = 0; i < max_clients; i++)
	{
		@ent = players[i];

		// don't count dead or unused player slots
		if ((ent.e.inuse) && (ent.health > 0))
		{
			if (ent.e.absmin[2] < lowestPlayerPt)
			{
				lowestPlayerPt = ent.e.absmin[2];
				@lowestPlayer = ent;
			}
		}
	}

	if (lowestPlayer is null)
	{
		return;
	}

	distance = lowestPlayerPt - self.e.absmax[2];

	// for the calculations, make sure we intend to go up at least a little.
	if (distance < self.accel)
	{
		distance = 100;
		self.moveinfo.speed = 5;
	}
	else
		self.moveinfo.speed = distance / self.accel;

	if (self.moveinfo.speed < 5)
		self.moveinfo.speed = 5;
	else if (self.moveinfo.speed > self.speed)
		self.moveinfo.speed = self.speed;

	// FIXME - should this allow any movement other than straight up?
	self.moveinfo.dir = { 0, 0, 1 };
	self.velocity = self.moveinfo.dir * self.moveinfo.speed;
	self.moveinfo.remaining_distance = distance;

	if (self.moveinfo.state != move_state_t::UP)
	{
		G_UseTargets(self, lowestPlayer);
		door_use_areaportals(self, true);
		self.moveinfo.state = move_state_t::UP;
	}

	@self.think = smart_water_go_up;
	self.nextthink = level.time + FRAME_TIME_S;
}

// PGM
//======

void door_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @ent;
	vec3_t	 center; // PGM

	if ((self.flags & ent_flags_t::TEAMSLAVE) != 0)
		return;

	if (activator !is null && self.classname == "func_door_rotating" && self.spawnflags.has(spawnflags::door_rotating::SAFE_OPEN) &&
		(self.moveinfo.state == move_state_t::BOTTOM || self.moveinfo.state == move_state_t::DOWN))
	{
		if (self.moveinfo.dir)
		{
			vec3_t forward = (activator.e.s.origin - self.e.s.origin).normalized();
			self.moveinfo.reversing = forward.dot(self.moveinfo.dir) > 0;
		}
	}

	if (self.spawnflags.has(spawnflags::door::TOGGLE))
	{
		if (self.moveinfo.state == move_state_t::UP || self.moveinfo.state == move_state_t::TOP)
		{
			// trigger all paired doors
			for (@ent = self; ent !is null; @ent = ent.teamchain)
			{
				ent.message = "";
				@ent.touch = null;
				door_go_down(ent);
			}
			return;
		}
	}

	// PGM
	//  smart water is different
	center = self.e.mins + self.e.maxs;
	center *= 0.5f;
	if ((self.classname == "func_water") && (gi_pointcontents(center) & contents_t::MASK_WATER) != 0 && self.spawnflags.has(spawnflags::water::SMART))
	{
		self.message = "";
		@self.touch = null;
		@self.enemy = activator;
		smart_water_go_up(self);
		return;
	}
	// PGM

	// trigger all paired doors
	for (@ent = self; ent !is null; @ent = ent.teamchain)
	{
		ent.message = "";
		@ent.touch = null;
		door_go_up(ent, activator);
	}
}

void Touch_DoorTrigger(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.health <= 0)
		return;

	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
		return;

	if ((other.e.svflags & svflags_t::MONSTER) != 0)
	{
		if (self.owner.spawnflags.has(spawnflags::door::NOMONSTER))
			return;
		// [Paril-KEX] this is for PSX; the scale is so small that monsters walking
		// around to path_corners often initiate doors unintentionally.
		else if (other.spawnflags.has(spawnflags::monsters::NO_IDLE_DOORS) && other.enemy is null)
			return;
	}

	if (level.time < self.touch_debounce_time)
		return;
	self.touch_debounce_time = level.time + time_sec(1);

	door_use(self.owner, other, other);
}

void Think_CalcMoveSpeed(ASEntity &self)
{
	ASEntity @ent;
	float	 min;
	float	 time;
	float	 newspeed;
	float	 ratio;
	float	 dist;

	if ((self.flags & ent_flags_t::TEAMSLAVE) != 0)
		return; // only the team master does this

	// find the smallest distance any member of the team will be moving
	min = abs(self.moveinfo.distance);
	for (@ent = self.teamchain; ent !is null; @ent = ent.teamchain)
	{
		dist = abs(ent.moveinfo.distance);
		if (dist < min)
			min = dist;
	}

	time = min / self.moveinfo.speed;

	// adjust speeds so they will all complete at the same time
	for (@ent = self; ent !is null; @ent = ent.teamchain)
	{
		newspeed = abs(ent.moveinfo.distance) / time;
		ratio = newspeed / ent.moveinfo.speed;
		if (ent.moveinfo.accel == ent.moveinfo.speed)
			ent.moveinfo.accel = newspeed;
		else
			ent.moveinfo.accel *= ratio;
		if (ent.moveinfo.decel == ent.moveinfo.speed)
			ent.moveinfo.decel = newspeed;
		else
			ent.moveinfo.decel *= ratio;
		ent.moveinfo.speed = newspeed;
	}
}

void Think_SpawnDoorTrigger(ASEntity &ent)
{
	ASEntity @other;
	vec3_t	 mins, maxs;

	if ((ent.flags & ent_flags_t::TEAMSLAVE) != 0)
		return; // only the team leader spawns a trigger

	mins = ent.e.absmin;
	maxs = ent.e.absmax;

	for (@other = ent.teamchain; other !is null; @other = other.teamchain)
	{
		AddPointToBounds(other.e.absmin, mins, maxs);
		AddPointToBounds(other.e.absmax, mins, maxs);
	}

	// expand
	mins.x -= 60;
	mins.y -= 60;
	maxs.x += 60;
	maxs.y += 60;

	@other = G_Spawn();
	other.e.mins = mins;
	other.e.maxs = maxs;
	@other.owner = ent;
	other.e.solid = solid_t::TRIGGER;
	other.movetype = movetype_t::NONE;
	@other.touch = Touch_DoorTrigger;
	gi_linkentity(other.e);

	Think_CalcMoveSpeed(ent);
}

void door_blocked(ASEntity &self, ASEntity &other)
{
	ASEntity @ent;

	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::CRUSH);
		// if it's still there, nuke it
		if (other.e.inuse)
			BecomeExplosion1(other);
		return;
	}
	
	if (self.dmg != 0 && !(level.time < self.touch_debounce_time))
	{
		self.touch_debounce_time = level.time + time_hz(10);
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
	}

	// [Paril-KEX] don't allow wait -1 doors to return
	if (self.spawnflags.has(spawnflags::door::CRUSHER) || self.wait == -1)
		return;

	// if a door has a negative wait, it would never come back if blocked,
	// so let it just squash the object to death real fast
	if (self.moveinfo.wait >= 0)
	{
		if (self.moveinfo.state == move_state_t::DOWN)
		{
			for (@ent = self.teammaster; ent !is null; @ent = ent.teamchain)
				door_go_up(ent, ent.activator);
		}
		else
		{
			for (@ent = self.teammaster; ent !is null; @ent = ent.teamchain)
				door_go_down(ent);
		}
	}
}

void door_killed(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	ASEntity @ent;

	for (@ent = self.teammaster; ent !is null; @ent = ent.teamchain)
	{
		ent.health = ent.max_health;
		ent.takedamage = false;
	}
	door_use(self.teammaster, attacker, attacker);
}

void door_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	if (other.client is null)
		return;

	if (level.time < self.touch_debounce_time)
		return;
	self.touch_debounce_time = level.time + time_sec(5);

	gi_LocCenter_Print(other.e, "{}", self.message);
	gi_sound(other.e, soundchan_t::AUTO, gi_soundindex("misc/talk1.wav"), 1, ATTN_NORM, 0);
}

void Think_DoorActivateAreaPortal(ASEntity &ent)
{
	door_use_areaportals(ent, true);

	if (ent.health != 0 || !ent.targetname.empty())
		Think_CalcMoveSpeed(ent);
	else
		Think_SpawnDoorTrigger(ent);
}

void SP_func_door(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	vec3_t abs_movedir;

	if (ent.sounds != 1)
		G_SetMoveinfoSounds(ent, "doors/dr1_strt.wav", "doors/dr1_mid.wav", "doors/dr1_end.wav");
	else
		G_SetMoveinfoSounds(ent, "", "", "");

	// [Paril-KEX] for rhangar1 doors
	if (!st.was_key_specified("attenuation"))
		ent.attenuation = ATTN_STATIC;
	else
	{
		if (ent.attenuation == -1)
		{
			ent.e.s.loop_attenuation = ATTN_LOOP_NONE;
			ent.attenuation = ATTN_NONE;
		}
		else
		{
			ent.e.s.loop_attenuation = ent.attenuation;
		}
	}

	G_SetMovedir(ent, ent.movedir);
	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::BSP;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::DOOR);
	gi_setmodel(ent.e, ent.model);

	@ent.moveinfo.blocked = door_blocked;
	@ent.use = door_use;

	if (ent.speed == 0)
		ent.speed = 100;
	if (deathmatch.integer != 0)
		ent.speed *= 2;
	
	if (ent.accel == 0)
		ent.accel = ent.speed;
	if (ent.decel == 0)
		ent.decel = ent.speed;

	if (ent.wait == 0)
		ent.wait = 3;
	float lip = st.lip;
	if (lip == 0)
		lip = 8;
	if (ent.dmg == 0)
		ent.dmg = 2;

	// calculate second position
	ent.pos1 = ent.e.s.origin;
	abs_movedir.x = abs(ent.movedir.x);
	abs_movedir.y = abs(ent.movedir.y);
	abs_movedir.z = abs(ent.movedir.z);
	ent.moveinfo.distance =
		abs_movedir.x * ent.e.size.x + abs_movedir.y * ent.e.size.y + abs_movedir.z * ent.e.size.z - lip;
	ent.pos2 = ent.pos1 + (ent.movedir * ent.moveinfo.distance);

	// if it starts open, switch the positions
	if (ent.spawnflags.has(spawnflags::door::START_OPEN))
	{
		ent.e.s.origin = ent.pos2;
		ent.pos2 = ent.pos1;
		ent.pos1 = ent.e.s.origin;
	}

	ent.moveinfo.state = move_state_t::BOTTOM;

	if (ent.health != 0)
	{
		ent.takedamage = true;
		@ent.die = door_killed;
		ent.max_health = ent.health;
	}
	else if (!ent.targetname.empty())
	{
		if (!ent.message.empty())
		{
			gi_soundindex("misc/talk.wav");
			@ent.touch = door_touch;
		}
		ent.flags = ent_flags_t(ent.flags | ent_flags_t::LOCKED);
	}

	ent.moveinfo.speed = ent.speed;
	ent.moveinfo.accel = ent.accel;
	ent.moveinfo.decel = ent.decel;
	ent.moveinfo.wait = ent.wait;
	ent.moveinfo.start_origin = ent.pos1;
	ent.moveinfo.start_angles = ent.e.s.angles;
	ent.moveinfo.end_origin = ent.pos2;
	ent.moveinfo.end_angles = ent.e.s.angles;

	if (ent.spawnflags.has(spawnflags::door::ANIMATED))
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM_ALL);
	if (ent.spawnflags.has(spawnflags::door::ANIMATED_FAST))
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM_ALLFAST);

	// to simplify logic elsewhere, make non-teamed doors into a team of one
	if (ent.team.empty())
		@ent.teammaster = ent;

	gi_linkentity(ent.e);

	ent.nextthink = level.time + FRAME_TIME_S;
	
	if (ent.spawnflags.has(spawnflags::door::START_OPEN))
		@ent.think = Think_DoorActivateAreaPortal;
	else if (ent.health != 0 || !ent.targetname.empty())
		@ent.think = Think_CalcMoveSpeed;
	else
		@ent.think = Think_SpawnDoorTrigger;
}

// PGM
void Door_Activate(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.use = null;

	if (self.health != 0)
	{
		self.takedamage = true;
		@self.die = door_killed;
		self.max_health = self.health;
	}

	if (self.health != 0)
		@self.think = Think_CalcMoveSpeed;
	else
		@self.think = Think_SpawnDoorTrigger;
	self.nextthink = level.time + FRAME_TIME_S;
}
// PGM

/*QUAKED func_door_rotating (0 .5 .8) ? START_OPEN REVERSE CRUSHER NOMONSTER ANIMATED TOGGLE X_AXIS Y_AXIS NOT_EASY NOT_MEDIUM NOT_HARD NOT_DM NOT_COOP RESERVED1 COOP_ONLY RESERVED2 INACTIVE SAFE_OPEN
TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN	the door to moves to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not useful for touch or takedamage doors).
NOMONSTER	monsters will not trigger this door

You need to have an origin brush as part of this entity.  The center of that brush will be
the point around which it is rotated. It will rotate around the Z axis by default.  You can
check either the X_AXIS or Y_AXIS box to change that.

"distance" is how many degrees the door will be rotated.
"speed" determines how fast the door moves; default value is 100.
"accel" if specified,is how much the rotation speed will increase each .1 sec. (default: no accel)

REVERSE will cause the door to rotate in the opposite direction.
INACTIVE will cause the door to be inactive until triggered.
SAFE_OPEN will cause the door to open in reverse if you are on the `angles` side of the door.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
1)	silent
2)	light
3)	medium
4)	heavy
*/

namespace spawnflags::door_rotating
{
    const spawnflags_t X_AXIS = spawnflag_dec(64);
    const spawnflags_t Y_AXIS = spawnflag_dec(128);
    const spawnflags_t INACTIVE = spawnflag_dec(0x10000); // Paril: moved to non-reserved
    const spawnflags_t SAFE_OPEN = spawnflag_dec(0x20000);
    const spawnflags_t NO_COLLISION = spawnflag_dec(0x40000);
}

void SP_func_door_rotating(ASEntity &ent)
{
	if (ent.spawnflags.has(spawnflags::door_rotating::SAFE_OPEN))
		G_SetMovedir(ent, ent.moveinfo.dir);

	ent.e.s.angles = vec3_origin;

	// set the axis of rotation
	ent.movedir = vec3_origin;
	if (ent.spawnflags.has(spawnflags::door_rotating::X_AXIS))
		ent.movedir.z = 1.0;
	else if (ent.spawnflags.has(spawnflags::door_rotating::Y_AXIS))
		ent.movedir.x = 1.0;
	else // Z_AXIS
		ent.movedir.y = 1.0;

	// check for reverse rotation
	if (ent.spawnflags.has(spawnflags::door::REVERSE))
		ent.movedir = -ent.movedir;

	const spawn_temp_t @st = ED_GetSpawnTemp();
	int distance = int(st.distance);

	if (distance == 0)
	{
		gi_Com_Print("{}: no distance set\n", ent);
		distance = 90;
	}

	ent.pos1 = ent.e.s.angles;
	ent.pos2 = ent.e.s.angles + (ent.movedir * distance);
	ent.pos3 = ent.e.s.angles + (ent.movedir * -distance);
	ent.moveinfo.distance = float(distance);

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::BSP;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::DOOR);
	gi_setmodel(ent.e, ent.model);

	@ent.moveinfo.blocked = door_blocked;
	@ent.use = door_use;

	if (ent.speed == 0)
		ent.speed = 100;
	if (ent.accel == 0)
		ent.accel = ent.speed;
	if (ent.decel == 0)
		ent.decel = ent.speed;

	if (ent.wait == 0)
		ent.wait = 3;
	if (ent.dmg == 0)
		ent.dmg = 2;

	if (ent.sounds != 1)
		G_SetMoveinfoSounds(ent, "doors/dr1_strt.wav", "doors/dr1_mid.wav", "doors/dr1_end.wav");
	else
		G_SetMoveinfoSounds(ent, "", "", "");

	// [Paril-KEX] for rhangar1 doors
	if (!st.was_key_specified("attenuation"))
		ent.attenuation = ATTN_STATIC;
	else
	{
		if (ent.attenuation == -1)
		{
			ent.e.s.loop_attenuation = ATTN_LOOP_NONE;
			ent.attenuation = ATTN_NONE;
		}
		else
		{
			ent.e.s.loop_attenuation = ent.attenuation;
		}
	}

	// if it starts open, switch the positions
	if (ent.spawnflags.has(spawnflags::door::START_OPEN))
	{
		if (ent.spawnflags.has(spawnflags::door_rotating::SAFE_OPEN))
		{
			ent.spawnflags &= ~spawnflags::door_rotating::SAFE_OPEN;
			gi_Com_Print("{}: SAFE_OPEN is not compatible with START_OPEN\n", ent);
		}

		ent.e.s.angles = ent.pos2;
		ent.pos2 = ent.pos1;
		ent.pos1 = ent.e.s.angles;
		ent.movedir = -ent.movedir;
	}

	if (ent.spawnflags.has(spawnflags::door_rotating::NO_COLLISION))
		ent.e.clipmask = contents_t::AREAPORTAL; // just because zero is automatic

	if (ent.health != 0)
	{
		ent.takedamage = true;
		@ent.die = door_killed;
		ent.max_health = ent.health;
	}

	if (!ent.targetname.empty() && !ent.message.empty())
	{
		gi_soundindex("misc/talk.wav");
		@ent.touch = door_touch;
	}

	ent.moveinfo.state = move_state_t::BOTTOM;
	ent.moveinfo.speed = ent.speed;
	ent.moveinfo.accel = ent.accel;
	ent.moveinfo.decel = ent.decel;
	ent.moveinfo.wait = ent.wait;
	ent.moveinfo.start_origin = ent.e.s.origin;
	ent.moveinfo.start_angles = ent.pos1;
	ent.moveinfo.end_origin = ent.e.s.origin;
	ent.moveinfo.end_angles = ent.pos2;
	ent.moveinfo.end_angles_reversed = ent.pos3;

	if (ent.spawnflags.has(spawnflags::door::ANIMATED))
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::ANIM_ALL);

	// to simplify logic elsewhere, make non-teamed doors into a team of one
	if (ent.team.empty())
		@ent.teammaster = ent;

	gi_linkentity(ent.e);

	ent.nextthink = level.time + FRAME_TIME_S;
	if (ent.health != 0 || !ent.targetname.empty())
		@ent.think = Think_CalcMoveSpeed;
	else
		@ent.think = Think_SpawnDoorTrigger;

	// PGM
	if (ent.spawnflags.has(spawnflags::door_rotating::INACTIVE))
	{
		ent.takedamage = false;
		@ent.die = null;
		@ent.think = null;
		ent.nextthink = time_zero;
		@ent.use = Door_Activate;
	}
	// PGM
}

void smart_water_blocked(ASEntity &self, ASEntity &other)
{
	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::LAVA);
		// if it's still there, nuke it
		if (other.e.inuse && other.e.solid != solid_t::NOT) // PGM
			BecomeExplosion1(other);
		return;
	}

	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100, 1, damageflags_t::NONE, mod_id_t::LAVA);
}


/*QUAKED func_water (0 .5 .8) ? START_OPEN SMART
func_water is a moveable water brush.  It must be targeted to operate.  Use a non-water texture at your own risk.

START_OPEN causes the water to move to its destination when spawned and operate in reverse.

SMART causes the water to adjust its speed depending on distance to player.
(speed = distance/accel, min 5, max self.speed)
"accel"		for smart water, the divisor to determine water speed. default 20 (smaller = faster)

"health"	maximum height of this water brush
"angle"		determines the opening direction (up or down only)
"speed"		movement speed (25 default)
"wait"		wait before returning (-1 default, -1 = TOGGLE)
"lip"		lip remaining at end of move (0 default)
"sounds"	(yes, these need to be changed)
0)	no sound
1)	water
2)	lava
*/

namespace spawnflags::water
{
    const spawnflags_t SMART = spawnflag_dec(2);
}

void SP_func_water(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	vec3_t abs_movedir;

	G_SetMovedir(self, self.movedir);
	self.movetype = movetype_t::PUSH;
	self.e.solid = solid_t::BSP;
	gi_setmodel(self.e, self.model);

	switch (self.sounds)
	{
	case 1: // water
	case 2: // lava
		G_SetMoveinfoSounds(self, "world/mov_watr.wav", "", "world/stp_watr.wav");
		break;

	default:
		G_SetMoveinfoSounds(self, "", "", "");
		break;
	}

	self.attenuation = ATTN_STATIC;

	// calculate second position
	self.pos1 = self.e.s.origin;
	abs_movedir.x = abs(self.movedir.x);
	abs_movedir.y = abs(self.movedir.y);
	abs_movedir.z = abs(self.movedir.z);
	self.moveinfo.distance =
		abs_movedir.x * self.e.size.x + abs_movedir.y * self.e.size.y + abs_movedir.z * self.e.size.z - st.lip;
	self.pos2 = self.pos1 + (self.movedir * self.moveinfo.distance);

	// if it starts open, switch the positions
	if (self.spawnflags.has(spawnflags::door::START_OPEN))
	{
		self.e.s.origin = self.pos2;
		self.pos2 = self.pos1;
		self.pos1 = self.e.s.origin;
	}

	self.moveinfo.start_origin = self.pos1;
	self.moveinfo.start_angles = self.e.s.angles;
	self.moveinfo.end_origin = self.pos2;
	self.moveinfo.end_angles = self.e.s.angles;

	self.moveinfo.state = move_state_t::BOTTOM;

	if (self.speed == 0)
		self.speed = 25;
	self.moveinfo.accel = self.moveinfo.decel = self.moveinfo.speed = self.speed;

	// ROGUE
	if (self.spawnflags.has(spawnflags::water::SMART)) // smart water
	{
		// this is actually the divisor of the lowest player's distance to determine speed.
		// self.speed then becomes the cap of the speed.
		if (self.accel == 0)
			self.accel = 20;
		@self.moveinfo.blocked = smart_water_blocked;
	}
	// ROGUE

	if (self.wait == 0)
		self.wait = -1;
	self.moveinfo.wait = self.wait;

	@self.use = door_use;

	if (self.wait == -1)
		self.spawnflags |= spawnflags::door::TOGGLE;

	gi_linkentity(self.e);
}

namespace spawnflags::train
{
    const spawnflags_t START_ON = spawnflag_dec(1);
    const spawnflags_t TOGGLE = spawnflag_dec(2);
    const spawnflags_t BLOCK_STOPS = spawnflag_dec(4);
    const spawnflags_t MOVE_TEAMCHAIN = spawnflag_dec(8);
    const spawnflags_t FIX_OFFSET = spawnflag_dec(16);
    const spawnflags_t USE_ORIGIN = spawnflag_dec(32);
}

/*QUAKED func_train (0 .5 .8) ? START_ON TOGGLE BLOCK_STOPS MOVE_TEAMCHAIN FIX_OFFSET USE_ORIGIN
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
noise	looping sound to play when the train is in motion

To have other entities move with the train, set all the piece's team value to the same thing. They will move in unison.
*/
void train_blocked(ASEntity &self, ASEntity &other)
{
	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::CRUSH);
		// if it's still there, nuke it
		if (other.e.inuse && other.e.solid != solid_t::NOT)
			BecomeExplosion1(other);
		return;
	}

	if (level.time < self.touch_debounce_time)
		return;

	if (self.dmg == 0)
		return;
	self.touch_debounce_time = level.time + time_ms(500);
	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
}

void train_wait(ASEntity &self)
{
	if (!self.target_ent.pathtarget.empty())
	{
		string savetarget;
		ASEntity @ent;

		@ent = self.target_ent;
		savetarget = ent.target;
		ent.target = ent.pathtarget;
		G_UseTargets(ent, self.activator);
		ent.target = savetarget;

		// make sure we didn't get killed by a killtarget
		if (!self.e.inuse)
			return;
	}

	if (self.moveinfo.wait != 0)
	{
		if (self.moveinfo.wait > 0)
		{
			self.nextthink = level.time + time_sec(self.moveinfo.wait);
			@self.think = train_next;
		}
		else if (self.spawnflags.has(spawnflags::train::TOGGLE)) // && wait < 0
		{
			// PMM - clear target_ent, let train_next get called when we get used
			//			train_next (self);
			@self.target_ent = null;
			// pmm
			self.spawnflags &= ~spawnflags::train::START_ON;
			self.velocity = vec3_origin;
			self.nextthink = time_zero;
		}

		if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
		{
			if (self.moveinfo.sound_end != 0)
				gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), self.moveinfo.sound_end, 1, ATTN_STATIC, 0);
		}
		self.e.s.sound = 0;
	}
	else
	{
		train_next(self);
	}
}

// PGM
void train_piece_wait(ASEntity &self)
{
}
// PGM

void train_next(ASEntity &self)
{
	ASEntity @ent;
	vec3_t	 dest;
	bool	 first;

	first = true;

    while (true)
    {
        if (self.target.empty())
        {
            self.e.s.sound = 0;
            return;
        }

        @ent = G_PickTarget(self.target);
        if (ent is null)
        {
            gi_Com_Print("{}: train_next: bad target {}\n", self, self.target);
            return;
        }

        self.target = ent.target;

        // check for a teleport path_corner
        if (ent.spawnflags.has(spawnflags::path_corner::TELEPORT))
        {
            if (!first)
            {
                gi_Com_Print("{}: connected teleport path_corners\n", ent);
                return;
            }
            first = false;

            if (self.spawnflags.has(spawnflags::train::USE_ORIGIN))
                self.e.s.origin = ent.e.s.origin;
            else
            {
                self.e.s.origin = ent.e.s.origin - self.e.mins;

                if (self.spawnflags.has(spawnflags::train::FIX_OFFSET))
                    self.e.s.origin -= vec3_t(1.0f, 1.0f, 1.0f);
            }

            self.e.s.old_origin = self.e.s.origin;
            self.e.s.event = entity_event_t::OTHER_TELEPORT;
            gi_linkentity(self.e);
            continue;
        }

        break;
    }

	// PGM
	if (ent.speed != 0)
	{
		self.speed = ent.speed;
		self.moveinfo.speed = ent.speed;
		if (ent.accel != 0)
			self.moveinfo.accel = ent.accel;
		else
			self.moveinfo.accel = ent.speed;
		if (ent.decel != 0)
			self.moveinfo.decel = ent.decel;
		else
			self.moveinfo.decel = ent.speed;
		self.moveinfo.current_speed = 0;
	}
	// PGM

	self.moveinfo.wait = ent.wait;
	@self.target_ent = ent;

	if ((self.flags & ent_flags_t::TEAMSLAVE) == 0)
	{
		if (self.moveinfo.sound_start != 0)
            gi_sound(self.e, soundchan_t(soundchan_t::NO_PHS_ADD | soundchan_t::VOICE), self.moveinfo.sound_start, 1, ATTN_STATIC, 0);
	}

	self.e.s.sound = self.moveinfo.sound_middle;
	
	if (self.spawnflags.has(spawnflags::train::USE_ORIGIN))
		dest = ent.e.s.origin;
	else
	{
		dest = ent.e.s.origin - self.e.mins;

		if (self.spawnflags.has(spawnflags::train::FIX_OFFSET))
			dest -= vec3_t(1.0f, 1.0f, 1.0f);
	}

	self.moveinfo.state = move_state_t::TOP;
	self.moveinfo.start_origin = self.e.s.origin;
	self.moveinfo.end_origin = dest;
	Move_Calc(self, dest, train_wait);
	self.spawnflags |= spawnflags::train::START_ON;

	// PGM
	if (self.spawnflags.has(spawnflags::train::MOVE_TEAMCHAIN))
	{
		ASEntity @e;
		vec3_t	 dir, dst;

		dir = dest - self.e.s.origin;
		for (@e = self.teamchain; e !is null; @e = e.teamchain)
		{
			dst = dir + e.e.s.origin;
			e.moveinfo.start_origin = e.e.s.origin;
			e.moveinfo.end_origin = dst;

			e.moveinfo.state = move_state_t::TOP;
			e.speed = self.speed;
			e.moveinfo.speed = self.moveinfo.speed;
			e.moveinfo.accel = self.moveinfo.accel;
			e.moveinfo.decel = self.moveinfo.decel;
			e.movetype = movetype_t::PUSH;
			Move_Calc(e, dst, train_piece_wait);
		}
	}
	// PGM
}

void train_resume(ASEntity &self)
{
	ASEntity @ent;
	vec3_t	 dest;

	@ent = self.target_ent;
	
	if (self.spawnflags.has(spawnflags::train::USE_ORIGIN))
		dest = ent.e.s.origin;
	else
	{
		dest = ent.e.s.origin - self.e.mins;

		if (self.spawnflags.has(spawnflags::train::FIX_OFFSET))
			dest -= vec3_t(1.0f, 1.0f, 1.0f);
	}

	// PGM (Paril)
	if (ent.speed != 0)
	{
		self.speed = ent.speed;
		self.moveinfo.speed = ent.speed;
		if (ent.accel != 0)
			self.moveinfo.accel = ent.accel;
		else
			self.moveinfo.accel = ent.speed;
		if (ent.decel != 0)
			self.moveinfo.decel = ent.decel;
		else
			self.moveinfo.decel = ent.speed;
		self.moveinfo.current_speed = 0;
	}
	// PGM

	self.e.s.sound = self.moveinfo.sound_middle;

	self.moveinfo.state = move_state_t::TOP;
	self.moveinfo.start_origin = self.e.s.origin;
	self.moveinfo.end_origin = dest;
	Move_Calc(self, dest, train_wait);
	self.spawnflags |= spawnflags::train::START_ON;
}

void func_train_find(ASEntity &self)
{
	ASEntity @ent;

	if (self.target.empty())
	{
		gi_Com_Print("{}: train_find: no target\n", self);
		return;
	}
	@ent = G_PickTarget(self.target);
	if (ent is null)
	{
		gi_Com_Print("{}: train_find: target {} not found\n", self, self.target);
		return;
	}
	self.target = ent.target;

	if (self.spawnflags.has(spawnflags::train::USE_ORIGIN))
		self.e.s.origin = ent.e.s.origin;
	else
	{
		self.e.s.origin = ent.e.s.origin - self.e.mins;

		if (self.spawnflags.has(spawnflags::train::FIX_OFFSET))
			self.e.s.origin -= vec3_t(1.0f, 1.0f, 1.0f);
	}

	gi_linkentity(self.e);

	// if not triggered, start immediately
	if (self.targetname.empty())
		self.spawnflags |= spawnflags::train::START_ON;

	if (self.spawnflags.has(spawnflags::train::START_ON))
	{
		self.nextthink = level.time + FRAME_TIME_S;
		@self.think = train_next;
		@self.activator = self;
	}
}

void train_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;

	if (self.spawnflags.has(spawnflags::train::START_ON))
	{
		if (!self.spawnflags.has(spawnflags::train::TOGGLE))
			return;
		self.spawnflags &= ~spawnflags::train::START_ON;
		self.velocity = vec3_origin;
		self.nextthink = time_zero;
	}
	else
	{
		if (self.target_ent !is null)
			train_resume(self);
		else
			train_next(self);
	}
}

void SP_func_train(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	self.movetype = movetype_t::PUSH;

	self.e.s.angles = vec3_origin;
	@self.moveinfo.blocked = train_blocked;
	if (self.spawnflags.has(spawnflags::train::BLOCK_STOPS))
		self.dmg = 0;
	else
	{
		if (self.dmg == 0)
			self.dmg = 100;
	}
	self.e.solid = solid_t::BSP;
	gi_setmodel(self.e, self.model);

	if (!st.noise.empty())
	{
		self.moveinfo.sound_middle = gi_soundindex(st.noise);

		// [Paril-KEX] for rhangar1 doors
		if (!st.was_key_specified("attenuation"))
			self.attenuation = ATTN_STATIC;
		else
		{
			if (self.attenuation == -1)
			{
				self.e.s.loop_attenuation = ATTN_LOOP_NONE;
				self.attenuation = ATTN_NONE;
			}
			else
			{
				self.e.s.loop_attenuation = self.attenuation;
			}
		}
	}

	if (self.speed == 0)
		self.speed = 100;

	self.moveinfo.speed = self.speed;
	self.moveinfo.accel = self.moveinfo.decel = self.moveinfo.speed;

	@self.use = train_use;

	gi_linkentity(self.e);

	if (!self.target.empty())
	{
		// start trains on the second frame, to make sure their targets have had
		// a chance to spawn
		self.nextthink = level.time + FRAME_TIME_S;
		@self.think = func_train_find;
	}
	else
	{
		gi_Com_Print("{}: no target\n", self);
	}
}

/*QUAKED trigger_elevator (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
 */
void trigger_elevator_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	ASEntity @target;

	if (self.movetarget.nextthink)
		return;

	if (other.pathtarget.empty())
	{
		gi_Com_Print("{}: elevator used with no pathtarget\n", self);
		return;
	}

	@target = G_PickTarget(other.pathtarget);
	if (target is null)
	{
		gi_Com_Print("{}: elevator used with bad pathtarget: {}\n", self, other.pathtarget);
		return;
	}

	@self.movetarget.target_ent = target;
	train_resume(self.movetarget);
}

void trigger_elevator_init(ASEntity &self)
{
	if (self.target.empty())
	{
		gi_Com_Print("{}: has no target\n", self);
		return;
	}
	@self.movetarget = G_PickTarget(self.target);
	if (self.movetarget is null)
	{
		gi_Com_Print("{}: unable to find target {}\n", self, self.target);
		return;
	}
	if (self.movetarget.classname != "func_train")
	{
		gi_Com_Print("{}: target {} is not a train\n", self, self.target);
		return;
	}

	@self.use = trigger_elevator_use;
	self.e.svflags = svflags_t::NOCLIENT;
}

void SP_trigger_elevator(ASEntity &self)
{
	@self.think = trigger_elevator_init;
	self.nextthink = level.time + FRAME_TIME_S;
}

/*QUAKED func_timer (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) START_ON
"wait"			base time between triggering all targets, default is 1
"random"		wait variance, default is 0

so, the basic time between firing is a random time between
(wait - random) and (wait + random)

"delay"			delay before first firing when turned on, default is 0

"pausetime"		additional delay used only the very first time
				and only if spawned with START_ON

These can used but not touched.
*/

namespace spawnflags::timer
{
    const spawnflags_t START_ON = spawnflag_dec(1);
}

void func_timer_think(ASEntity &self)
{
	G_UseTargets(self, self.activator);
	self.nextthink = level.time + time_sec(self.wait + crandom() * self.random);
}

void func_timer_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	@self.activator = activator;

	// if on, turn it off
	if (self.nextthink)
	{
		self.nextthink = time_zero;
		return;
	}

	// turn it on
	if (self.delay != 0)
		self.nextthink = level.time + time_sec(self.delay);
	else
		func_timer_think(self);
}

void SP_func_timer(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	if (self.wait == 0)
		self.wait = 1.0;

	@self.use = func_timer_use;
	@self.think = func_timer_think;

	if (self.random >= self.wait)
	{
		self.random = self.wait - gi_frame_time_s;
		gi_Com_Print("{}: random >= wait\n", self);
	}

	if (self.spawnflags.has(spawnflags::timer::START_ON))
	{
		self.nextthink = level.time + time_sec(1) + time_sec(st.pausetime + self.delay + self.wait + crandom() * self.random);
		@self.activator = self;
	}

	self.e.svflags = svflags_t::NOCLIENT;
}

/*QUAKED func_conveyor (0 .5 .8) ? START_ON TOGGLE
Conveyors are stationary brushes that move what's on them.
The brush should be have a surface with at least one current content enabled.
speed	default 100
*/

namespace spawnflags::conveyor
{
    const spawnflags_t START_ON = spawnflag_dec(1);
    const spawnflags_t TOGGLE = spawnflag_dec(2);
}

void func_conveyor_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.spawnflags.has(spawnflags::conveyor::START_ON))
	{
		self.speed = 0;
		self.spawnflags &= ~spawnflags::conveyor::START_ON;
	}
	else
	{
		self.speed = float(self.count);
		self.spawnflags |= spawnflags::conveyor::START_ON;
	}

	if (!self.spawnflags.has(spawnflags::conveyor::TOGGLE))
		self.count = 0;
}

void SP_func_conveyor(ASEntity &self)
{
	if (self.speed == 0)
		self.speed = 100;

	if (!self.spawnflags.has(spawnflags::conveyor::START_ON))
	{
		self.count = int(self.speed);
		self.speed = 0;
	}

	@self.use = func_conveyor_use;

	gi_setmodel(self.e, self.model);
	self.e.solid = solid_t::BSP;
	gi_linkentity(self.e);
}

/*QUAKED func_door_secret (0 .5 .8) ? always_shoot 1st_left 1st_down
A secret door.  Slide back and then to the side.

open_once		doors never closes
1st_left		1st move is left of arrow
1st_down		1st move is down from arrow
always_shoot	door is shootebale even if targeted

"angle"		determines the direction
"dmg"		damage to inflic when blocked (default 2)
"wait"		how long to hold in the open position (default 5, -1 means hold)
*/

namespace spawnflags::door_secret
{
    const spawnflags_t ALWAYS_SHOOT = spawnflag_dec(1);
    const spawnflags_t FIRST_LEFT = spawnflag_dec(2);
    const spawnflags_t FIRST_DOWN = spawnflag_dec(4);
}

void door_secret_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	// make sure we're not already moving
	if (self.e.s.origin)
		return;

	Move_Calc(self, self.pos1, door_secret_move1);
	door_use_areaportals(self, true);
}

void door_secret_move1(ASEntity &self)
{
	self.nextthink = level.time + time_sec(1);
	@self.think = door_secret_move2;
}

void door_secret_move2(ASEntity &self)
{
	Move_Calc(self, self.pos2, door_secret_move3);
}

void door_secret_move3(ASEntity &self)
{
	if (self.wait == -1)
		return;
	self.nextthink = level.time + time_sec(self.wait);
	@self.think = door_secret_move4;
}

void door_secret_move4(ASEntity &self)
{
	Move_Calc(self, self.pos1, door_secret_move5);
}

void door_secret_move5(ASEntity &self)
{
	self.nextthink = level.time + time_sec(1);
	@self.think = door_secret_move6;
}

void door_secret_move6(ASEntity &self)
{
	Move_Calc(self, vec3_origin, door_secret_done);
}

void door_secret_done(ASEntity &self)
{
	if (self.targetname.empty() || self.spawnflags.has(spawnflags::door_secret::ALWAYS_SHOOT))
	{
		self.health = 0;
		self.takedamage = true;
	}
	door_use_areaportals(self, false);
}

void door_secret_blocked(ASEntity &self, ASEntity &other)
{
	if ((other.e.svflags & svflags_t::MONSTER) == 0 && (other.client is null))
	{
		// give it a chance to go away on it's own terms (like gibs)
		T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, 100000, 1, damageflags_t::NONE, mod_id_t::CRUSH);
		// if it's still there, nuke it
		if (other.e.inuse && other.e.solid != solid_t::NOT)
			BecomeExplosion1(other);
		return;
	}

	if (level.time < self.touch_debounce_time)
		return;
	self.touch_debounce_time = level.time + time_ms(500);

	T_Damage(other, self, self, vec3_origin, other.e.s.origin, vec3_origin, self.dmg, 1, damageflags_t::NONE, mod_id_t::CRUSH);
}

void door_secret_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.takedamage = false;
	door_secret_use(self, attacker, attacker);
}

void SP_func_door_secret(ASEntity &ent)
{
	vec3_t forward, right, up;
	float  side;
	float  width;
	float  length;

	G_SetMoveinfoSounds(ent, "doors/dr1_strt.wav", "doors/dr1_mid.wav", "doors/dr1_end.wav");

	ent.attenuation = ATTN_STATIC;

	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::BSP;
	ent.e.svflags = svflags_t(ent.e.svflags | svflags_t::DOOR);
	gi_setmodel(ent.e, ent.model);

	@ent.moveinfo.blocked = door_secret_blocked;
	@ent.use = door_secret_use;

	if (ent.targetname.empty() || ent.spawnflags.has(spawnflags::door_secret::ALWAYS_SHOOT))
	{
		ent.health = 0;
		ent.takedamage = true;
		@ent.die = door_secret_die;
	}

	if (ent.dmg == 0)
		ent.dmg = 2;

	if (ent.wait == 0)
		ent.wait = 5;

	if (ent.speed == 0)
		ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = 50;
	else
		ent.moveinfo.accel = ent.moveinfo.decel = ent.moveinfo.speed = ent.speed * 0.1f;

	// calculate positions
	AngleVectors(ent.e.s.angles, forward, right, up);
	ent.e.s.angles = vec3_origin;
	side = 1.0f - (ent.spawnflags.has(spawnflags::door_secret::FIRST_LEFT) ? 2 : 0);
	if (ent.spawnflags.has(spawnflags::door_secret::FIRST_DOWN))
		width = abs(up.dot(ent.e.size));
	else
		width = abs(right.dot(ent.e.size));
	length = abs(forward.dot(ent.e.size));
	if (ent.spawnflags.has(spawnflags::door_secret::FIRST_DOWN))
		ent.pos1 = ent.e.s.origin + (up * (-1 * width));
	else
		ent.pos1 = ent.e.s.origin + (right * (side * width));
	ent.pos2 = ent.pos1 + (forward * length);

	if (ent.health != 0)
	{
		ent.takedamage = true;
		@ent.die = door_killed;
		ent.max_health = ent.health;
	}
	else if (!ent.targetname.empty() && !ent.message.empty())
	{
		gi_soundindex("misc/talk.wav");
		@ent.touch = door_touch;
	}

	gi_linkentity(ent.e);
}

/*QUAKED func_killbox (1 0 0) ?
Kills everything inside when fired, irrespective of protection.
*/
namespace spawnflags::killbox
{
    const spawnflags_t DEADLY_COOP = spawnflag_dec(2);
    const spawnflags_t EXACT_COLLISION = spawnflag_dec(4);
}

void use_killbox(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if (self.spawnflags.has(spawnflags::killbox::DEADLY_COOP))
		level.deadly_kill_box = true;

	self.e.solid = solid_t::TRIGGER;
	gi_linkentity(self.e);

	KillBox(self, false, mod_id_t::TELEFRAG, self.spawnflags.has(spawnflags::killbox::EXACT_COLLISION));

	self.e.solid = solid_t::NOT;
	gi_linkentity(self.e);

	level.deadly_kill_box = false;
}

void SP_func_killbox(ASEntity &ent)
{
	gi_setmodel(ent.e, ent.model);
	@ent.use = use_killbox;
	ent.e.svflags = svflags_t::NOCLIENT;
}

/*QUAKED func_eye (0 1 0) ?
Camera-like eye that can track entities.
"pathtarget" point to an info_notnull (which gets freed after spawn) to automatically set
the eye_position
"target"/"killtarget"/"delay"/"message" target keys to fire when we first spot a player
"eye_position" manually set the eye position; note that this is in "forward right up" format, relative to
the origin of the brush and using the entity's angles
"radius" default 512, detection radius for entities
"speed" default 45, how fast, in degrees per second, we should move on each axis to reach the target
"vision_cone" default 0.5 for half cone; how wide the cone of vision should be (relative to their initial angles)
"wait" default 0, the amount of time to wait before returning to neutral angles
*/
namespace spawnflags::func_eye
{
    const spawnflags_t FIRED_TARGETS = spawnflag_bit(17); // internal use only
}

void func_eye_think(ASEntity &self)
{
	// find enemy to track
	float closest_dist = 0;
	ASEntity @closest_player = null;

    foreach (ASEntity @player : active_players)
    {
		vec3_t dir = player.e.s.origin - self.e.s.origin;
		float dist = dir.normalize();

		if (dir.dot(self.movedir) < self.yaw_speed)
			continue;

		if (dist >= self.dmg_radius)
			continue;

		if (closest_player is null || dist < closest_dist)
		{
			@closest_player = player;
			closest_dist = dist;
		}
	}

	@self.enemy = closest_player;

	// tracking player
	vec3_t wanted_angles;

	vec3_t fwd, rgt, up;
	AngleVectors(self.e.s.angles, fwd, rgt, up);

	vec3_t eye_pos = self.e.s.origin;
	eye_pos += fwd * self.move_origin.x;
	eye_pos += rgt * self.move_origin.y;
	eye_pos += up  * self.move_origin.z;
	
	if (self.enemy !is null)
	{
		if (!self.spawnflags.has(spawnflags::func_eye::FIRED_TARGETS))
		{
			G_UseTargets(self, self.enemy);
			self.spawnflags |= spawnflags::func_eye::FIRED_TARGETS;
		}

		vec3_t dir = (self.enemy.e.s.origin - eye_pos).normalized();
		wanted_angles = vectoangles(dir);

		self.e.s.frame = 2;
		self.timestamp = level.time + time_sec(self.wait);
	}
	else
	{
		if (self.timestamp <= level.time)
		{
			// return to neutral
			wanted_angles = self.move_angles;
			self.e.s.frame = 0;
		}
		else
			wanted_angles = self.e.s.angles;
	}
	
	for (int i = 0; i < 2; i++)
	{
		float current = anglemod(self.e.s.angles[i]);
		float ideal = wanted_angles[i];

		if (current == ideal)
			continue;

		float move = ideal - current;

		if (ideal > current)
		{
			if (move >= 180)
				move = move - 360;
		}
		else
		{
			if (move <= -180)
				move = move + 360;
		}
		if (move > 0)
		{
			if (move > self.speed)
				move = self.speed;
		}
		else
		{
			if (move < -self.speed)
				move = -self.speed;
		}

		self.e.s.angles[i] = anglemod(current + move);
	}

	self.nextthink = level.time + FRAME_TIME_S;
}

void func_eye_setup(ASEntity &self)
{
	ASEntity @eye_pos = G_PickTarget(self.pathtarget);

	if (eye_pos is null)
		gi_Com_Print("{}: bad target\n", self);
	else
		self.move_origin = eye_pos.e.s.origin - self.e.s.origin;

	self.movedir = self.move_origin.normalized();

	@self.think = func_eye_think;
	self.nextthink = level.time + time_hz(10);
}

void SP_func_eye(ASEntity &ent)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();
	ent.movetype = movetype_t::PUSH;
	ent.e.solid = solid_t::BSP;
	gi_setmodel(ent.e, ent.model);

	if (st.radius == 0)
		ent.dmg_radius = 512;
	else
		ent.dmg_radius = st.radius;

	if (ent.speed == 0)
		ent.speed = 45;

	// set vision cone
	if (st.was_key_specified("vision_cone"))
		ent.yaw_speed = ent.vision_cone;

	if (ent.yaw_speed == 0)
		ent.yaw_speed = 0.5f;

	ent.speed *= gi_frame_time_s;
	ent.move_angles = ent.e.s.angles;

	ent.wait = 1.0f;

	if (!ent.pathtarget.empty())
	{
		@ent.think = func_eye_setup;
		ent.nextthink = level.time + time_hz(10);
	}
	else
	{
		@ent.think = func_eye_think;
		ent.nextthink = level.time + time_hz(10);

		vec3_t right, up;
		AngleVectors(ent.move_angles, ent.movedir, right, up);

		vec3_t move_origin = ent.move_origin;
		ent.move_origin = ent.movedir * move_origin.x;
		ent.move_origin += right * move_origin.y;
		ent.move_origin += up * move_origin.z;
	}

	gi_linkentity(ent.e);
}
