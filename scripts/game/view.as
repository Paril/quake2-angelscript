
gtime_t DAMAGE_TIME_SLACK;
gtime_t DAMAGE_TIME;
gtime_t FALL_TIME;


/*
===============
SkipViewModifiers
===============
*/
bool SkipViewModifiers(ASEntity &ent)
{
	if (g_skipViewModifiers.integer != 0 && sv_cheats.integer != 0) {
		return true;
	}
	// don't do bobbing, etc on grapple
	if (ent.client.ctf_grapple !is null && ent.client.ctf_grapplestate > ctfgrapplestate_t::FLY) {
		return true;
	}
	// spectator mode
	if (ent.client.resp.spectator || (G_TeamplayEnabled() && ent.client.resp.ctf_team == ctfteam_t::NOTEAM)) {
		return true;
	}
	return false;
}

class step_parameters_t
{
	float	xyspeed;
	float	bobmove;
	int		bobcycle, bobcycle_run;	  // odd cycles are right foot going forward
	float	bobfracsin; // sinf(bobfrac*M_PI)
};

/*
===============
SV_CalcRoll
===============
*/
float SV_CalcRoll(ASEntity &client, const vec3_t &in angles, const vec3_t &in velocity, const vec3_t &in right)
{
	if ( SkipViewModifiers(client) ) {
		return 0.0f;
	}

	float sign;
	float side;
	float value;

	side = velocity.dot(right);
	sign = side < 0 ? -1.0f : 1.0f;
	side = abs(side);

	value = sv_rollangle.value;

	if (side < sv_rollspeed.value)
		side = side * value / sv_rollspeed.value;
	else
		side = value;

	return side * sign;
}

/*
===============
P_DamageFeedback

Handles color blends and view kicks
===============
*/
int player_pain_noise_i = 0;

const array<string> pain_sounds = {
    "*pain25_1.wav",
    "*pain25_2.wav",
    "*pain50_1.wav",
    "*pain50_2.wav",
    "*pain75_1.wav",
    "*pain75_2.wav",
    "*pain100_1.wav",
    "*pain100_2.wav"
};

const vec3_t armor_color = { 1.0, 1.0, 1.0 };
const vec3_t power_color = { 0.0, 1.0, 0.0 };
const vec3_t bcolor = { 1.0, 0.0, 0.0 };

void P_DamageFeedback(ASEntity &player, const vec3_t &in forward, const vec3_t &in right, const vec3_t &in up)
{
	ASClient		 @client;
	float			 side;
	float			 realcount, count, kick;
	vec3_t			 v;
	int				 l;

	@client = player.client;

	// flash the backgrounds behind the status numbers
	int16 want_flashes = 0;

	if (client.damage_blood != 0)
		want_flashes |= 1;
	if (client.damage_armor != 0 && (player.flags & ent_flags_t::GODMODE) == 0 && (client.invincible_time <= level.time))
		want_flashes |= 2;

	if (want_flashes != 0)
	{
		client.flash_time = level.time + time_ms(100);
		player.e.client.ps.stats[player_stat_t::FLASHES] = want_flashes;
	}
	else if (client.flash_time < level.time)
		player.e.client.ps.stats[player_stat_t::FLASHES] = 0;

	// total points of damage shot at the player this frame
	count = float(client.damage_blood + client.damage_armor + client.damage_parmor);
	if (count == 0)
		return; // didn't take any damage

	// start a pain animation if still in the player model
	if (client.anim_priority < anim_priority_t::PAIN && player.e.s.modelindex == MODELINDEX_PLAYER)
	{
		client.anim_priority = anim_priority_t::PAIN;
		if ((player.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
		{
			player.e.s.frame = player::frames::crpain1 - 1;
			client.anim_end = player::frames::crpain4;
		}
		else
		{
			player_pain_noise_i = (player_pain_noise_i + 1) % 3;
			switch (player_pain_noise_i)
			{
			case 0:
				player.e.s.frame = player::frames::pain101 - 1;
				client.anim_end = player::frames::pain104;
				break;
			case 1:
				player.e.s.frame = player::frames::pain201 - 1;
				client.anim_end = player::frames::pain204;
				break;
			case 2:
				player.e.s.frame = player::frames::pain301 - 1;
				client.anim_end = player::frames::pain304;
				break;
			}
		}

		client.anim_time = time_zero;
	}

	realcount = count;

	// if we took health damage, do a minimum clamp
	if (client.damage_blood != 0)
	{
		if (count < 10)
			count = 10; // always make a visible effect
	}
	else
	{
		if (count > 2)
			count = 2; // don't go too deep
	}

	// play an appropriate pain sound
	if ((level.time > player.pain_debounce_time) && (player.flags & ent_flags_t::GODMODE) == 0 && (client.invincible_time <= level.time))
	{
		player.pain_debounce_time = level.time + time_ms(700);

		if (player.health < 25)
			l = 0;
		else if (player.health < 50)
			l = 2;
		else if (player.health < 75)
			l = 4;
		else
			l = 6;

		if (brandom())
			l |= 1;

		gi_sound(player.e, soundchan_t::VOICE, gi_soundindex(pain_sounds[l]), 1, ATTN_NORM, 0);
		// Paril: pain noises alert monsters
		PlayerNoise(player, player.e.s.origin, player_noise_t::SELF);
	}

	// the total alpha of the blend is always proportional to count
	if (client.damage_blend.a < 0)
		client.damage_blend.a = 0;

	// [Paril-KEX] tweak the values to rely less on this
	// and more on damage indicators
	if (client.damage_blood != 0 || (client.damage_blend.a + count * 0.06f) < 0.15f)
	{
		client.damage_blend.a += count * 0.06f;

		if (client.damage_blend.a < 0.06f)
			client.damage_blend.a = 0.06f;
		if (client.damage_blend.a > 0.4f)
			client.damage_blend.a = 0.4f; // don't go too saturated
	}

	// mix in colors
	v = vec3_origin;

	if (client.damage_parmor != 0)
		v += power_color * (client.damage_parmor / realcount);
	if (client.damage_blood != 0)
		v += bcolor * max(15.0f, (client.damage_blood / realcount));
	if (client.damage_armor != 0)
		v += armor_color * (client.damage_armor / realcount);
	client.damage_blend.xyz() = v.normalized();

	//
	// calculate view angle kicks
	//
	kick = float(abs(client.damage_knockback));
	if (kick != 0 && player.health > 0) // kick of 0 means no view adjust at all
	{
		kick = kick * 100 / player.health;

		if (kick < count * 0.5f)
			kick = count * 0.5f;
		if (kick > 50)
			kick = 50;

		v = client.damage_from - player.e.s.origin;
		v.normalize();

		side = v.dot(right);
		client.v_dmg_roll = kick * side * 0.3f;

		side = -v.dot(forward);
		client.v_dmg_pitch = kick * side * 0.3f;

		client.v_dmg_time = level.time + DAMAGE_TIME;
	}

	// [Paril-KEX] send view indicators
	if (!client.damage_indicators.empty())
	{
		gi_WriteByte(svc_t::damage);
		gi_WriteByte(client.damage_indicators.length());

		for (uint8 i = 0; i < client.damage_indicators.length(); i++)
		{
			auto @indicator = client.damage_indicators[i];

			// encode total damage into 5 bits
			uint8 encoded = clamp((indicator.health + indicator.power + indicator.armor) / 3, 1, 0x1F);

			// encode types in the latter 3 bits
			if (indicator.health != 0)
				encoded |= 0x20;
			if (indicator.armor != 0)
				encoded |= 0x40;
			if (indicator.power != 0)
				encoded |= 0x80;

			gi_WriteByte(encoded);
			gi_WriteDir((player.e.s.origin - indicator.from).normalized());
		}

		gi_unicast(player.e, false);
	}

	//
	// clear totals
	//
	client.damage_blood = 0;
	client.damage_armor = 0;
	client.damage_parmor = 0;
	client.damage_knockback = 0;
	client.damage_indicators.resize(0);
}

/*
===============
SV_CalcViewOffset

Auto pitching on slopes?

  fall from 128: 400 = 160000
  fall from 256: 580 = 336400
  fall from 384: 720 = 518400
  fall from 512: 800 = 640000
  fall from 640: 960 =

  damage = deltavelocity*deltavelocity  * 0.0001

===============
*/
void SV_CalcViewOffset(ASEntity &ent, const vec3_t &in forward, const vec3_t &in right, const step_parameters_t &in step)
{
	float  bob;
	float  ratio;
	float  delta;
	vec3_t v;

	//===================================

	// base angles
	vec3_t angles = ent.e.client.ps.kick_angles;

	// if dead, fix the angle and don't add any kick
	if (ent.deadflag && !ent.client.resp.spectator)
	{
		angles = vec3_origin;

		if ((ent.flags & ent_flags_t::SAM_RAIMI) != 0)
		{
			ent.e.client.ps.viewangles.roll = 0;
			ent.e.client.ps.viewangles.pitch = 0;
		}
		else
		{
			ent.e.client.ps.viewangles.roll = 40;
			ent.e.client.ps.viewangles.pitch = -15;
		}
		ent.e.client.ps.viewangles.yaw = ent.client.killer_yaw;
	}
	else if (!ent.client.pers.bob_skip && !SkipViewModifiers(ent))
	{
		// add angles based on weapon kick
		angles = P_CurrentKickAngles(ent);

		// add angles based on damage kick
		if (ent.client.v_dmg_time > level.time)
		{
			// [Paril-KEX] 100ms of slack is added to account for
			// visual difference in higher tickrates
			gtime_t diff = ent.client.v_dmg_time - level.time;

			// slack time remaining
			if (DAMAGE_TIME_SLACK)
			{
				if (diff > DAMAGE_TIME - DAMAGE_TIME_SLACK)
					ratio = (DAMAGE_TIME - diff).secondsf() / DAMAGE_TIME_SLACK.secondsf();
				else
					ratio = diff.secondsf() / (DAMAGE_TIME - DAMAGE_TIME_SLACK).secondsf();
			}
			else
				ratio = diff.secondsf() / (DAMAGE_TIME - DAMAGE_TIME_SLACK).secondsf();

			angles.pitch += ratio * ent.client.v_dmg_pitch;
			angles.roll += ratio * ent.client.v_dmg_roll;
		}

		// add pitch based on fall kick
		if (ent.client.fall_time > level.time)
		{
			// [Paril-KEX] 100ms of slack is added to account for
			// visual difference in higher tickrates
			gtime_t diff = ent.client.fall_time - level.time;

			// slack time remaining
			if (DAMAGE_TIME_SLACK)
			{
				if (diff > FALL_TIME - DAMAGE_TIME_SLACK)
					ratio = (FALL_TIME - diff).secondsf() / DAMAGE_TIME_SLACK.secondsf();
				else
					ratio = diff.secondsf() / (FALL_TIME - DAMAGE_TIME_SLACK).secondsf();
			}
			else
				ratio = diff.secondsf() / (FALL_TIME - DAMAGE_TIME_SLACK).secondsf();
			angles.pitch += ratio * ent.client.fall_value;
		}

		// add angles based on velocity
		if (!ent.client.pers.bob_skip && !SkipViewModifiers(ent))
		{
			delta = ent.velocity.dot(forward);
			angles.pitch += delta * run_pitch.value;

			delta = ent.velocity.dot(right);
			angles.roll += delta * run_roll.value;

			// add angles based on bob
			delta = step.bobfracsin * bob_pitch.value * step.xyspeed;
			if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0 && ent.groundentity !is null)
				delta *= 6; // crouching
			delta = min(delta, 1.2f);
			angles.pitch += delta;
			delta = step.bobfracsin * bob_roll.value * step.xyspeed;
			if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0 && ent.groundentity !is null)
				delta *= 6; // crouching
			delta = min(delta, 1.2f);
			if ((step.bobcycle & 1) != 0)
				delta = -delta;
			angles.roll += delta;
		}

		// add earthquake angles
		if (ent.client.quake_time > level.time)
		{
			float factor = min(1.0f, (ent.client.quake_time.secondsf() / level.time.secondsf()) * 0.25f);

			angles.x += crandom() * factor;
			angles.z += crandom() * factor;
			angles.y += crandom() * factor;
		}
	}

	// [Paril-KEX] clamp angles
	for (int i = 0; i < 3; i++)
		ent.e.client.ps.kick_angles[i] = clamp(angles[i], -31.0f, 31.0f);

	//===================================

	// base origin

	v = vec3_origin;

	// add fall height

	if (!ent.client.pers.bob_skip && !SkipViewModifiers(ent))
	{
		if (ent.client.fall_time > level.time)
		{
			// [Paril-KEX] 100ms of slack is added to account for
			// visual difference in higher tickrates
			gtime_t diff = ent.client.fall_time - level.time;

			// slack time remaining
			if (DAMAGE_TIME_SLACK)
			{
				if (diff > FALL_TIME - DAMAGE_TIME_SLACK)
					ratio = (FALL_TIME - diff).secondsf() / DAMAGE_TIME_SLACK.secondsf();
				else
					ratio = diff.secondsf() / (FALL_TIME - DAMAGE_TIME_SLACK).secondsf();
			}
			else
				ratio = diff.secondsf() / (FALL_TIME - DAMAGE_TIME_SLACK).secondsf();
			v.z -= ratio * ent.client.fall_value * 0.4f;
		}

	    // add bob height
		bob = step.bobfracsin * step.xyspeed * bob_up.value;
		if (bob > 6)
			bob = 6;
		// gi.DebugGraph (bob *2, 255);
		v.z += bob;
	}

	// add kick offset

	if (!ent.client.pers.bob_skip && !SkipViewModifiers(ent))
		v += P_CurrentKickOrigin(ent);

	// absolutely bound offsets
	// so the view can never be outside the player box

	if (v.x < -14)
		v.x = -14;
	else if (v.x > 14)
		v.x = 14;
	if (v.y < -14)
		v.y = -14;
	else if (v.y > 14)
		v.y = 14;
	if (v.z < -22)
		v.z = -22;
	else if (v.z > 30)
		v.z = 30;

	ent.e.client.ps.viewoffset = v;
}

/*
==============
SV_CalcGunOffset
==============
*/
void SV_CalcGunOffset(ASEntity &ent, const vec3_t &in forward, const vec3_t &in right, const vec3_t &in up, const step_parameters_t &in step)
{
	int	  i;
	// ROGUE

	if (ent.client.pers.weapon !is null && 
	    // ROGUE - heatbeam shouldn't bob so the beam looks right
		!((ent.client.pers.weapon.id == item_id_t::WEAPON_PLASMABEAM || ent.client.pers.weapon.id == item_id_t::WEAPON_GRAPPLE) && ent.client.weaponstate == weaponstate_t::FIRING) &&
		!SkipViewModifiers(ent))
	{
		// ROGUE
		// gun angles from bobbing
		ent.e.client.ps.gunangles.roll = step.xyspeed * step.bobfracsin * 0.005f;
		ent.e.client.ps.gunangles.yaw = step.xyspeed * step.bobfracsin * 0.01f;
		if ((step.bobcycle & 1) != 0)
		{
			ent.e.client.ps.gunangles.roll = -ent.e.client.ps.gunangles.roll;
			ent.e.client.ps.gunangles.yaw = -ent.e.client.ps.gunangles.yaw;
		}

		ent.e.client.ps.gunangles.pitch = step.xyspeed * step.bobfracsin * 0.005f;

		vec3_t viewangles_delta = ent.client.oldviewangles - ent.e.client.ps.viewangles;

		ent.client.slow_view_angles += viewangles_delta;

		// gun angles from delta movement
		for (i = 0; i < 3; i++)
		{
			float d = ent.client.slow_view_angles[i];

			if (d == 0)
				continue;

			if (d > 180)
				d -= 360;
			if (d < -180)
				d += 360;
			if (d > 45)
				d = 45;
			if (d < -45)
				d = -45;

			// [Sam-KEX] Apply only half-delta. Makes the weapons look less detatched from the player.
			if (i == 2)
				ent.e.client.ps.gunangles[i] += (0.1f * d) * 0.5f;
			else
				ent.e.client.ps.gunangles[i] += (0.2f * d) * 0.5f;

			float reduction_factor = viewangles_delta[i] != 0 ? 0.05f : 0.15f;

			if (d > 0)
				d = max(0.0f, d - gi_frame_time_ms * reduction_factor);
			else if (d < 0)
				d = min(0.0f, d + gi_frame_time_ms * reduction_factor);

            ent.client.slow_view_angles[i] = d;
		}

		// [Paril-KEX] cl_rollhack
		ent.e.client.ps.gunangles.roll = -ent.e.client.ps.gunangles.roll;

	}
	// ROGUE
	else
	{
		ent.e.client.ps.gunangles = vec3_origin;
	}
	// ROGUE

	// gun height
	ent.e.client.ps.gunoffset = vec3_origin;

	// gun_x / gun_y / gun_z are development tools
    ent.e.client.ps.gunoffset += forward * (gun_y.value);
    ent.e.client.ps.gunoffset += right * gun_x.value;
    ent.e.client.ps.gunoffset += up * (-gun_z.value);
}

/*
=============
SV_CalcBlend
=============
*/
void SV_CalcBlend(ASEntity &ent)
{
	gtime_t remaining;

	ent.e.client.ps.damage_blend = ent.e.client.ps.screen_blend = { 0, 0, 0, 0 };

	// add for powerups
	if (ent.client.quad_time > level.time)
	{
		remaining = ent.client.quad_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/damage2.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(0, 0, 1, 0.08f));
	}
	// RAFAEL
	else if (ent.client.quadfire_time > level.time)
	{
		remaining = ent.client.quadfire_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/quadfire2.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(1, 0.2f, 0.5f, 0.08f));
	}
	// RAFAEL
	// PMM - double damage
	else if (ent.client.double_time > level.time)
	{
		remaining = ent.client.double_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("misc/ddamage2.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(0.9f, 0.7f, 0, 0.08f));
	}
	// PMM
	else if (ent.client.invincible_time > level.time)
	{
		remaining = ent.client.invincible_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/protect2.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(1, 1, 0, 0.08f));
	}
	else if (ent.client.invisible_time > level.time)
	{
		remaining = ent.client.invisible_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/protect2.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(0.8f, 0.8f, 0.8f, 0.08f));
	}
	else if (ent.client.enviro_time > level.time)
	{
		remaining = ent.client.enviro_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/airout.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(0, 1, 0, 0.08f));
	}
	else if (ent.client.breather_time > level.time)
	{
		remaining = ent.client.breather_time - level.time;
		if (remaining.milliseconds == 3000) // beginning to fade
			gi_sound(ent.e, soundchan_t::ITEM, gi_soundindex("items/airout.wav"), 1, ATTN_NORM, 0);
		if (G_PowerUpExpiringRelative(remaining))
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(0.4f, 1, 0.4f, 0.04f));
	}

	// PGM
	if (ent.client.nuke_time > level.time)
	{
		float brightness = (ent.client.nuke_time - level.time).secondsf() / 2.0f;
		ent.e.client.ps.screen_blend.accum_blend(vec4_t(1, 1, 1, brightness));
	}
	if (ent.client.ir_time > level.time)
	{
		remaining = ent.client.ir_time - level.time;
		if (G_PowerUpExpiringRelative(remaining))
		{
			ent.e.client.ps.rdflags = refdef_flags_t(ent.e.client.ps.rdflags | refdef_flags_t::IRGOGGLES);
			ent.e.client.ps.screen_blend.accum_blend(vec4_t(1, 0, 0, 0.2f));
		}
		else
			ent.e.client.ps.rdflags = refdef_flags_t(ent.e.client.ps.rdflags & ~refdef_flags_t::IRGOGGLES);
	}
	else
	{
		ent.e.client.ps.rdflags = refdef_flags_t(ent.e.client.ps.rdflags & ~refdef_flags_t::IRGOGGLES);
	}
	// PGM

	// add for damage
	if (ent.client.damage_blend.a > 0)
		ent.e.client.ps.damage_blend.accum_blend(ent.client.damage_blend);

	// [Paril-KEX] drowning visual indicator
	if (ent.air_finished < level.time + time_sec(9))
	{
		const float max_drown_alpha = 0.75f;
		vec4_t drown_color = { 0.1f, 0.1f, 0.2f, (ent.air_finished < level.time) ? 1 : (1.0f - ((ent.air_finished - level.time).secondsf() / 9.0f)) };
		ent.e.client.ps.damage_blend.accum_blend(drown_color);
	}

	// drop the damage value
	ent.client.damage_blend.a -= gi_frame_time_s * 0.6f;
	if (ent.client.damage_blend.a < 0)
		ent.client.damage_blend.a = 0;
}

/*
=============
P_WorldEffects
=============
*/
void P_WorldEffects(ASEntity &ent, const step_parameters_t &in step)
{
	bool		  breather;
	bool		  envirosuit;
	water_level_t waterlevel, old_waterlevel;

	if (ent.movetype == movetype_t::NOCLIP)
	{
		ent.air_finished = level.time + time_sec(12); // don't need air
		return;
	}

	ASClient @client = ent.client;

	waterlevel = ent.waterlevel;
	old_waterlevel = client.old_waterlevel;
	client.old_waterlevel = waterlevel;

	breather = client.breather_time > level.time;
	envirosuit = client.enviro_time > level.time;

	//
	// if just entered a water volume, play a sound
	//
	if (old_waterlevel == water_level_t::NONE && waterlevel != water_level_t::NONE)
	{
		PlayerNoise(ent, ent.e.s.origin, player_noise_t::SELF);
		if ((ent.watertype & contents_t::LAVA) != 0)
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/lava_in.wav"), 1, ATTN_NORM, 0);
		else if ((ent.watertype & contents_t::SLIME) != 0)
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_in.wav"), 1, ATTN_NORM, 0);
		else if ((ent.watertype & contents_t::WATER) != 0)
			gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_in.wav"), 1, ATTN_NORM, 0);
		ent.flags = ent_flags_t(ent.flags | ent_flags_t::INWATER);

		// clear damage_debounce, so the pain sound will play immediately
		ent.damage_debounce_time = level.time - time_sec(1);
	}

	//
	// if just completely exited a water volume, play a sound
	//
	if (old_waterlevel != water_level_t::NONE && waterlevel == water_level_t::NONE)
	{
		PlayerNoise(ent, ent.e.s.origin, player_noise_t::SELF);
		gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_out.wav"), 1, ATTN_NORM, 0);
		ent.flags = ent_flags_t(ent.flags & ~ent_flags_t::INWATER);
	}

	//
	// check for head just going under water
	//
	if (old_waterlevel != water_level_t::UNDER && waterlevel == water_level_t::UNDER)
	{
		gi_sound(ent.e, soundchan_t::BODY, gi_soundindex("player/watr_un.wav"), 1, ATTN_NORM, 0);
	}

	//
	// check for head just coming out of water
	//
	if (ent.health > 0 && old_waterlevel == water_level_t::UNDER && waterlevel != water_level_t::UNDER)
	{
		if (ent.air_finished < level.time)
		{ // gasp for air
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("player/gasp1.wav"), 1, ATTN_NORM, 0);
			PlayerNoise(ent, ent.e.s.origin, player_noise_t::SELF);
		}
		else if (ent.air_finished < level.time + time_sec(11))
		{ // just break surface
			gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("player/gasp2.wav"), 1, ATTN_NORM, 0);
		}
	}

	//
	// check for drowning
	//
	if (waterlevel == water_level_t::UNDER)
	{
		// breather or envirosuit give air
		if (breather || envirosuit)
		{
			ent.air_finished = level.time + time_sec(10);

			if (((client.breather_time - level.time).milliseconds % 2500) == 0)
			{
				if (client.breather_sound == 0)
					gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("player/u_breath1.wav"), 1, ATTN_NORM, 0);
				else
					gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("player/u_breath2.wav"), 1, ATTN_NORM, 0);
				client.breather_sound ^= 1;
				PlayerNoise(ent, ent.e.s.origin, player_noise_t::SELF);
				// FIXME: release a bubble?
			}
		}

		// if out of air, start drowning
		if (ent.air_finished < level.time)
		{ // drown!
			if (ent.client.next_drown_time < level.time && ent.health > 0)
			{
				ent.client.next_drown_time = level.time + time_sec(1);

				// take more damage the longer underwater
				ent.dmg += 2;
				if (ent.dmg > 15)
					ent.dmg = 15;

				// play a gurp sound instead of a normal pain sound
				if (ent.health <= ent.dmg)
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("*drown1.wav"), 1, ATTN_NORM, 0); // [Paril-KEX]
				else if (brandom())
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("*gurp1.wav"), 1, ATTN_NORM, 0);
				else
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("*gurp2.wav"), 1, ATTN_NORM, 0);

				ent.pain_debounce_time = level.time;

				T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, ent.dmg, 0, damageflags_t::NO_ARMOR, mod_id_t::WATER);
			}
		}
		// Paril: almost-drowning sounds
		else if (ent.air_finished <= level.time + time_sec(3))
		{
			if (ent.client.next_drown_time < level.time)
			{
//#ifdef PSX_ASSETS
//				gi.sound(ent, CHAN_VOICE, gi.soundindex(G_Fmt("player/breathout{}.wav", 1 + ((int32_t) level.time.seconds() % 3)).data()), 1, ATTN_NORM, 0);
//#else
				gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex(format("player/wade{}.wav", 1 + (level.time.secondsi() % 3))), 1, ATTN_NORM, 0);
//#endif
				ent.client.next_drown_time = level.time + time_sec(1);
			}
		}
	}
	else
	{
		if (waterlevel == water_level_t::WAIST)
		{
			if ((pm_config.physics_flags & physics_flags_t::PSX_MOVEMENT) != 0)
			{
				if (int(client.bobtime + step.bobmove) != step.bobcycle_run)
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex(format("player/wade{}.wav", irandom(1, 4))), 1, ATTN_NORM, 0);
			}
		}

		ent.air_finished = level.time + time_sec(12);
		ent.dmg = 2;
	}

	//
	// check for sizzle damage
	//
	if (waterlevel != water_level_t::NONE && (ent.watertype & (contents_t::LAVA | contents_t::SLIME)) != 0 && ent.slime_debounce_time <= level.time)
	{
		if ((ent.watertype & contents_t::LAVA) != 0)
		{
			if (ent.health > 0 && ent.pain_debounce_time <= level.time && client.invincible_time < level.time)
			{
				if (brandom())
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("player/burn1.wav"), 1, ATTN_NORM, 0);
				else
					gi_sound(ent.e, soundchan_t::VOICE, gi_soundindex("player/burn2.wav"), 1, ATTN_NORM, 0);
				ent.pain_debounce_time = level.time + time_sec(1);
			}

			int dmg = (envirosuit ? 1 : 3) * waterlevel; // take 1/3 damage with envirosuit

			T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, dmg, 0, damageflags_t::NONE, mod_id_t::LAVA);
			ent.slime_debounce_time = level.time + time_hz(10);
		}

		if ((ent.watertype & contents_t::SLIME) != 0)
		{
			if (!envirosuit)
			{ // no damage from slime with envirosuit
				T_Damage(ent, world, world, vec3_origin, ent.e.s.origin, vec3_origin, 1 * waterlevel, 0, damageflags_t::NONE, mod_id_t::SLIME);
				ent.slime_debounce_time = level.time + time_hz(10);
			}
		}
	}
}

/*
===============
G_SetClientEffects
===============
*/
void G_SetClientEffects(ASEntity &ent)
{
	int pa_type;

	ent.e.s.effects = effects_t::NONE;
	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx & renderfx_t::STAIR_STEP);
	ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::IR_VISIBLE);
	ent.e.s.alpha = 1.0;

	if (ent.health <= 0 || level.intermissiontime)
		return;

	if ((ent.flags & ent_flags_t::FLASHLIGHT) != 0)
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::FLASHLIGHT);

	//=========
	// PGM
	if ((ent.flags & ent_flags_t::DISGUISED) != 0)
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::USE_DISGUISE);
	// PGM
	//=========

	if (ent.powerarmor_time > level.time)
	{
		pa_type = PowerArmorType(ent);
		if (pa_type == item_id_t::ITEM_POWER_SCREEN)
		{
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::POWERSCREEN);
		}
		else if (pa_type == item_id_t::ITEM_POWER_SHIELD)
		{
			ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::COLOR_SHELL);
			ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | renderfx_t::SHELL_GREEN);
		}
	}

	// ZOID
	CTFEffects(ent);
	// ZOID

	if (ent.client.quad_time > level.time)
	{
		if (G_PowerUpExpiring(ent.client.quad_time))
			CTFSetPowerUpEffect(ent, effects_t::QUAD);
	}

	// RAFAEL
	if (ent.client.quadfire_time > level.time)
	{
		if (G_PowerUpExpiring(ent.client.quadfire_time))
			CTFSetPowerUpEffect(ent, effects_t::DUALFIRE);
	}
	// RAFAEL
	//=======
	// ROGUE
	if (ent.client.double_time > level.time)
	{
		if (G_PowerUpExpiring(ent.client.double_time))
			CTFSetPowerUpEffect(ent, effects_t::DOUBLE);
	}
	if (ent.client.owned_sphere !is null && (uint(ent.client.owned_sphere.spawnflags) == uint(spawnflags::sphere::DEFENDER)))
	{
		CTFSetPowerUpEffect(ent, effects_t::HALF_DAMAGE);
	}
	if (ent.client.tracker_pain_time > level.time)
	{
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::TRACKERTRAIL);
	}
	if (ent.client.invisible_time > level.time)
	{
		if (ent.client.invisibility_fade_time <= level.time)
			ent.e.s.alpha = 0.1f;
		else
		{
			float x = (ent.client.invisibility_fade_time - level.time).secondsf() / INVISIBILITY_TIME.secondsf();
			ent.e.s.alpha = clamp(x, 0.1f, 1.0f);
		}
	}
	// ROGUE
	//=======

	if (ent.client.invincible_time > level.time)
	{
		if (G_PowerUpExpiring(ent.client.invincible_time))
			CTFSetPowerUpEffect(ent, effects_t::PENT);
	}

	// show cheaters!!!
	if ((ent.flags & ent_flags_t::GODMODE) != 0)
	{
		ent.e.s.effects = effects_t(ent.e.s.effects | effects_t::COLOR_SHELL);
		ent.e.s.renderfx = renderfx_t(ent.e.s.renderfx | (renderfx_t::SHELL_RED | renderfx_t::SHELL_GREEN | renderfx_t::SHELL_BLUE));
	}
}

/*
===============
G_SetClientEvent
===============
*/
void G_SetClientEvent(ASEntity &ent, const step_parameters_t &in step)
{
	if (ent.e.s.event != entity_event_t::NONE)
		return;

	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::ON_LADDER) != 0)
	{
		if (deathmatch.integer == 0 &&
			ent.client.last_ladder_sound < level.time &&
			(ent.client.last_ladder_pos - ent.e.s.origin).length() > 48.0f)
		{
			ent.e.s.event = entity_event_t::LADDER_STEP;
			ent.client.last_ladder_pos = ent.e.s.origin;
			ent.client.last_ladder_sound = level.time + LADDER_SOUND_TIME;
		}
	}
	else if (ent.groundentity !is null && step.xyspeed > 225)
	{
		if (int(ent.client.bobtime + step.bobmove) != step.bobcycle_run)
			ent.e.s.event = entity_event_t::FOOTSTEP;
	}
}

/*
===============
G_SetClientSound
===============
*/
void G_SetClientSound(ASEntity &ent)
{
	// help beep (no more than three times)
	if (ent.client.pers.helpchanged != 0 && ent.client.pers.helpchanged <= 3 && ent.client.pers.help_time < level.time)
	{
		if (ent.client.pers.helpchanged == 1) // [KEX] haleyjd: once only
			gi_sound(ent.e, soundchan_t::AUTO, gi_soundindex("misc/pc_up.wav"), 1, ATTN_STATIC, 0);
		ent.client.pers.helpchanged++;
		ent.client.pers.help_time = level.time + time_sec(5);
	}

	// reset defaults
	ent.e.s.sound = 0;
	ent.e.s.loop_attenuation = 0;
	ent.e.s.loop_volume = 0;

	if (ent.waterlevel != water_level_t::NONE && (ent.watertype & (contents_t::LAVA | contents_t::SLIME)) != 0)
	{
		ent.e.s.sound = snd_fry;
		return;
	}

	if (ent.deadflag || ent.client.resp.spectator)
		return;

	if (ent.client.weapon_sound != 0)
		ent.e.s.sound = ent.client.weapon_sound;
	else if (ent.client.pers.weapon !is null)
	{
		if (ent.client.pers.weapon.id == item_id_t::WEAPON_RAILGUN)
			ent.e.s.sound = gi_soundindex("weapons/rg_hum.wav");
		else if (ent.client.pers.weapon.id == item_id_t::WEAPON_BFG)
			ent.e.s.sound = gi_soundindex("weapons/bfg_hum.wav");
		// RAFAEL
		else if (ent.client.pers.weapon.id == item_id_t::WEAPON_PHALANX)
			ent.e.s.sound = gi_soundindex("weapons/phaloop.wav");
		// RAFAEL
	}

	// [Paril-KEX] if no other sound is playing, play appropriate grapple sounds
	if (ent.e.s.sound == 0 && ent.client.ctf_grapple !is null)
	{
		if (ent.client.ctf_grapplestate == ctfgrapplestate_t::PULL)
			ent.e.s.sound = gi_soundindex("weapons/grapple/grpull.wav");
		else if (ent.client.ctf_grapplestate == ctfgrapplestate_t::FLY)
			ent.e.s.sound = gi_soundindex("weapons/grapple/grfly.wav");
		else if (ent.client.ctf_grapplestate == ctfgrapplestate_t::HANG)
			ent.e.s.sound = gi_soundindex("weapons/grapple/grhang.wav");
	}

	// weapon sounds play at a higher attn
	ent.e.s.loop_attenuation = ATTN_NORM;
}

/*
===============
G_SetClientFrame
===============
*/
void G_SetClientFrame(ASEntity &ent, const step_parameters_t &in step)
{
	ASClient  @client;
	bool	   duck, run;

	if (ent.e.s.modelindex != MODELINDEX_PLAYER)
		return; // not in the player model

	@client = ent.client;

	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0)
		duck = true;
	else
		duck = false;
	if (step.xyspeed != 0)
		run = true;
	else
		run = false;

	// check for stand/duck and stop/go transitions
	if (duck != client.anim_duck && client.anim_priority < anim_priority_t::DEATH)
	{
    }
	else if (run != client.anim_run && client.anim_priority == anim_priority_t::BASIC)
	{
    }
	else if (ent.groundentity is null && client.anim_priority <= anim_priority_t::WAVE)
	{
    }
    else
    {
        if (client.anim_time > level.time)
            return;
        else if ((client.anim_priority & anim_priority_t::REVERSED) != 0 && (ent.e.s.frame > client.anim_end))
        {
            if (client.anim_time <= level.time)
            {
                ent.e.s.frame--;
                client.anim_time = level.time + time_hz(10);
            }
            return;
        }
        else if ((client.anim_priority & anim_priority_t::REVERSED) == 0 && (ent.e.s.frame < client.anim_end))
        {
            // continue an animation
            if (client.anim_time <= level.time)
            {
                ent.e.s.frame++;
                client.anim_time = level.time + time_hz(10);
            }
            return;
        }

        if (client.anim_priority == anim_priority_t::DEATH)
            return; // stay there
        if (client.anim_priority == anim_priority_t::JUMP)
        {
            if (ent.groundentity is null)
                return; // stay there
            client.anim_priority = anim_priority_t::WAVE;

            if (duck)
            {
                ent.e.s.frame = player::frames::jump6;
                client.anim_end = player::frames::jump4;
                client.anim_priority = anim_priority_t(client.anim_priority | anim_priority_t::REVERSED);
            }
            else
            {
                ent.e.s.frame = player::frames::jump3;
                client.anim_end = player::frames::jump6;
            }
            client.anim_time = level.time + time_hz(10);
            return;
        }
    }

	// return to either a running or standing frame
	client.anim_priority = anim_priority_t::BASIC;
	client.anim_duck = duck;
	client.anim_run = run;
	client.anim_time = level.time + time_hz(10);

	if (ent.groundentity is null)
	{
		// ZOID: if on grapple, don't go into jump frame, go into standing
		// frame
		if (client.ctf_grapple !is null)
		{
			if (duck)
			{
				ent.e.s.frame = player::frames::crstnd01;
				client.anim_end = player::frames::crstnd19;
			}
			else
			{
				ent.e.s.frame = player::frames::stand01;
				client.anim_end = player::frames::stand40;
			}
		}
		else
		{
			// ZOID
			client.anim_priority = anim_priority_t::JUMP;

			if (duck)
			{
				if (ent.e.s.frame != player::frames::crwalk2)
					ent.e.s.frame = player::frames::crwalk1;
				client.anim_end = player::frames::crwalk2;
			}
			else
			{
				if (ent.e.s.frame != player::frames::jump2)
					ent.e.s.frame = player::frames::jump1;
				client.anim_end = player::frames::jump2;
			}
		}
	}
	else if (run)
	{ // running
		if (duck)
		{
			ent.e.s.frame = player::frames::crwalk1;
			client.anim_end = player::frames::crwalk6;
		}
		else
		{
			ent.e.s.frame = player::frames::run1;
			client.anim_end = player::frames::run6;
		}
	}
	else
	{ // standing
		if (duck)
		{
			ent.e.s.frame = player::frames::crstnd01;
			client.anim_end = player::frames::crstnd19;
		}
		else
		{
			ent.e.s.frame = player::frames::stand01;
			client.anim_end = player::frames::stand40;
		}
	}
}

// [Paril-KEX]
void P_RunMegaHealth(ASEntity &ent)
{
	if (!ent.client.pers.megahealth_time)
		return;
	else if (ent.health <= ent.max_health)
	{
		ent.client.pers.megahealth_time = time_zero;
		return;
	}

	ent.client.pers.megahealth_time -= FRAME_TIME_S;

	if (ent.client.pers.megahealth_time <= time_zero)
	{
		ent.health--;

		if (ent.health > ent.max_health)
			ent.client.pers.megahealth_time = time_ms(1000);
		else
			ent.client.pers.megahealth_time = time_zero;
	}
}

/*
=================
Called for each player at the end of the server frame
and right after spawning
=================
*/
void ClientEndServerFrame(ASEntity &ent)
{
	// no player exists yet (load game)
	if (!ent.client.pers.spawned)
		return;

	// check fog changes
	P_ForceFogTransition(ent, false);

	// check goals
	G_PlayerNotifyGoal(ent);

	// mega health
	P_RunMegaHealth(ent);

	//
	// If the origin or velocity have changed since ClientThink(),
	// update the pmove values.  This will happen when the client
	// is pushed by a bmodel or kicked by an explosion.
	//
	// If it wasn't updated here, the view position would lag a frame
	// behind the body position when pushed -- "sinking into plats"
	//
	ent.e.client.ps.pmove.origin = ent.e.s.origin;
	ent.e.client.ps.pmove.velocity = ent.velocity;

	//
	// If the end of unit layout is displayed, don't give
	// the player any normal movement attributes
	//
	if (level.intermissiontime || ent.client.awaiting_respawn)
	{
		if (ent.client.awaiting_respawn || (level.intermission_eou || level.is_n64 || (deathmatch.integer != 0 && level.intermissiontime)))
		{
			ent.e.client.ps.screen_blend.w = ent.e.client.ps.damage_blend.w = 0;
			ent.e.client.ps.fov = 90;
			ent.e.client.ps.gunindex = 0;
		}
		G_SetStats(ent);
		G_SetCoopStats(ent);

		// if the scoreboard is up, update it if a client leaves
		if (deathmatch.integer != 0 && ent.client.showscores && ent.client.menutime)
		{
			DeathmatchScoreboardMessage(ent, ent.enemy);
			gi_unicast(ent.e, false);
			ent.client.menutime = time_zero;
		}

		return;
	}

	// ZOID
	// regen tech
	CTFApplyRegeneration(ent);
	// ZOID

	vec3_t forward, right, up;
	AngleVectors(ent.client.v_angle, forward, right, up);

	//
	// set model angles from view angles so other things in
	// the world can tell which direction you are looking
	//
	if (ent.client.v_angle.pitch > 180)
		ent.e.s.angles.pitch = (-360 + ent.client.v_angle.pitch) / 3;
	else
		ent.e.s.angles.pitch = ent.client.v_angle.pitch / 3;
	
	ent.e.s.angles.yaw = ent.client.v_angle.yaw;
	ent.e.s.angles.roll = 0;
	// [Paril-KEX] cl_rollhack
	ent.e.s.angles.roll = -SV_CalcRoll(ent, ent.e.s.angles, ent.velocity, right) * 4;

	//
	// calculate speed and cycle to be used for
	// all cyclic walking effects
	//
	step_parameters_t step;
	step.xyspeed = sqrt(ent.velocity.x * ent.velocity.x + ent.velocity.y * ent.velocity.y);

	if (step.xyspeed < 5)
	{
		ent.client.bobtime = 0; // start at beginning of cycle again
	}
	else if (ent.groundentity !is null)
	{ // so bobbing only cycles when on ground
		if (step.xyspeed > 210)
			step.bobmove = gi_frame_time_ms / 400.0f;
		else if (step.xyspeed > 100)
			step.bobmove = gi_frame_time_ms / 800.0f;
		else
			step.bobmove = gi_frame_time_ms / 1600.0f;
	}

	float bobtime = (ent.client.bobtime += step.bobmove);
	float bobtime_run = bobtime;

	if ((ent.e.client.ps.pmove.pm_flags & pmflags_t::DUCKED) != 0 && ent.groundentity !is null)
		bobtime *= 4;

	step.bobcycle = int(bobtime);
	step.bobcycle_run = int(bobtime_run);
	step.bobfracsin = abs(sin(bobtime * PIf));

	// burn from lava, etc
	P_WorldEffects(ent, step);

	// apply all the damage taken this frame
	P_DamageFeedback(ent, forward, right, up);

	// determine the view offsets
	SV_CalcViewOffset(ent, forward, right, step);

	// determine the gun offsets
	SV_CalcGunOffset(ent, forward, right, up, step);

	// determine the full screen color blend
	// must be after viewoffset, so eye contents can be
	// accurately determined
	SV_CalcBlend(ent);

	// chase cam stuff
    if (ent.client.resp.spectator)
		G_SetSpectatorStats(ent);
	else
		G_SetStats(ent);

	G_CheckChaseStats(ent);

	G_SetCoopStats(ent);

	G_SetClientEvent(ent, step);

	G_SetClientEffects(ent);

	G_SetClientSound(ent);

	G_SetClientFrame(ent, step);

	ent.client.oldvelocity = ent.velocity;
	ent.client.oldviewangles = ent.e.client.ps.viewangles;
	@ent.client.oldgroundentity = @ent.groundentity;

	// ZOID
	if (ent.client.menudirty && ent.client.menutime <= level.time)
	{
		if (ent.client.menu !is null)
		{
			PMenu_Do_Update(ent);
			gi_unicast(ent.e, true);
		}
		ent.client.menutime = level.time;
		ent.client.menudirty = false;
	}
	// ZOID

	// if the scoreboard is up, update it
	if (ent.client.showscores && ent.client.menutime <= level.time)
	{
		// ZOID
		if (ent.client.menu !is null)
		{
			PMenu_Do_Update(ent);
			ent.client.menudirty = false;
		}
		else
			// ZOID
			DeathmatchScoreboardMessage(ent, ent.enemy);
		gi_unicast(ent.e, false);
		ent.client.menutime = level.time + time_sec(3);
	}

	if ( ( ent.e.svflags & svflags_t::BOT ) != 0 ) {
        // AS_TODO
		//Bot_EndFrame( ent );
	}

	P_AssignClientSkinnum(ent);

	if (deathmatch.integer != 0)
		G_SaveLagCompensation(ent);

	Compass_Update(ent, false);

	// [Paril-KEX] in coop, if player collision is enabled and
	// we are currently in no-player-collision mode, check if
	// it's safe.
	if (coop.integer != 0 && G_ShouldPlayersCollide(false) && (ent.e.clipmask & contents_t::PLAYER) == 0 && ent.takedamage)
	{
		bool clipped_player = false;

		foreach (ASEntity @player : active_players)
		{
			if (player is ent)
				continue;

			trace_t clip = gi_clip(player.e, ent.e.origin, ent.e.mins, ent.e.maxs, ent.e.origin, contents_t(contents_t::MONSTER | contents_t::PLAYER));

			if (clip.startsolid || clip.allsolid)
			{
				clipped_player = true;
				break;
			}
		}

		// safe!
		if (!clipped_player)
			ent.e.clipmask = contents_t(ent.e.clipmask | contents_t::PLAYER);
	}
}
