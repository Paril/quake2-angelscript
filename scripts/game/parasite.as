// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

parasite

==============================================================================
*/

namespace parasite
{
    enum frames
    {
        break01,
        break02,
        break03,
        break04,
        break05,
        break06,
        break07,
        break08,
        break09,
        break10,
        break11,
        break12,
        break13,
        break14,
        break15,
        break16,
        break17,
        break18,
        break19,
        break20,
        break21,
        break22,
        break23,
        break24,
        break25,
        break26,
        break27,
        break28,
        break29,
        break30,
        break31,
        break32,
        death101,
        death102,
        death103,
        death104,
        death105,
        death106,
        death107,
        drain01,
        drain02,
        drain03,
        drain04,
        drain05,
        drain06,
        drain07,
        drain08,
        drain09,
        drain10,
        drain11,
        drain12,
        drain13,
        drain14,
        drain15,
        drain16,
        drain17,
        drain18,
        pain101,
        pain102,
        pain103,
        pain104,
        pain105,
        pain106,
        pain107,
        pain108,
        pain109,
        pain110,
        pain111,
        run01,
        run02,
        run03,
        run04,
        run05,
        run06,
        run07,
        run08,
        run09,
        run10,
        run11,
        run12,
        run13,
        run14,
        run15,
        stand01,
        stand02,
        stand03,
        stand04,
        stand05,
        stand06,
        stand07,
        stand08,
        stand09,
        stand10,
        stand11,
        stand12,
        stand13,
        stand14,
        stand15,
        stand16,
        stand17,
        stand18,
        stand19,
        stand20,
        stand21,
        stand22,
        stand23,
        stand24,
        stand25,
        stand26,
        stand27,
        stand28,
        stand29,
        stand30,
        stand31,
        stand32,
        stand33,
        stand34,
        stand35,
        // ROGUE
        jump01,
        jump02,
        jump03,
        jump04,
        jump05,
        jump06,
        jump07,
        jump08
        // ROGUE
    };

    const float SCALE = 1.000000f;
}

const float g_athena_parasite_miss_chance = 0.1f;
const float g_athena_parasite_proboscis_speed = 1250;
const float g_athena_parasite_proboscis_retract_modifier = 2.0f;

namespace parasite::sounds
{
    cached_soundindex pain1("parasite/parpain1.wav");
    cached_soundindex pain2("parasite/parpain2.wav");
    cached_soundindex die("parasite/pardeth1.wav");
    cached_soundindex launch("parasite/paratck1.wav");
    cached_soundindex impact("parasite/paratck2.wav");
    cached_soundindex suck("parasite/paratck3.wav");
    cached_soundindex reelin("parasite/paratck4.wav");
    cached_soundindex sight("parasite/parsght1.wav");
    cached_soundindex tap("parasite/paridle1.wav");
    cached_soundindex scratch("parasite/paridle2.wav");
    cached_soundindex search("parasite/parsrch1.wav");
}

void parasite_launch(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::launch, 1, ATTN_NORM, 0);
}

void parasite_reel_in(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::reelin, 1, ATTN_NORM, 0);
}

void parasite_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::sight, 1, ATTN_NORM, 0);
}

void parasite_tap(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::tap, 0.75f, 2.75f, 0);
}

void parasite_scratch(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::scratch, 0.75f, 2.75f, 0);
}

/*
void parasite_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::search, 1, ATTN_IDLE, 0);
}
*/

const array<mframe_t> parasite_frames_start_fidget = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t parasite_move_start_fidget = mmove_t(parasite::frames::stand18, parasite::frames::stand21, parasite_frames_start_fidget, parasite_do_fidget);

const array<mframe_t> parasite_frames_fidget = {
	mframe_t(ai_stand, 0, parasite_scratch),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_scratch),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t parasite_move_fidget = mmove_t(parasite::frames::stand22, parasite::frames::stand27, parasite_frames_fidget, parasite_refidget);

const array<mframe_t> parasite_frames_end_fidget = {
	mframe_t(ai_stand, 0, parasite_scratch),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t parasite_move_end_fidget = mmove_t(parasite::frames::stand28, parasite::frames::stand35, parasite_frames_end_fidget, parasite_stand);

void parasite_end_fidget(ASEntity &self)
{
	M_SetAnimation(self, parasite_move_end_fidget);
}

void parasite_do_fidget(ASEntity &self)
{
	M_SetAnimation(self, parasite_move_fidget);
}

void parasite_refidget(ASEntity &self)
{
	if (frandom() <= 0.8f)
		M_SetAnimation(self, parasite_move_fidget);
	else
		M_SetAnimation(self, parasite_move_end_fidget);
}

void parasite_idle(ASEntity &self)
{
	if (self.enemy !is null)
		return;

	M_SetAnimation(self, parasite_move_start_fidget);
}

const array<mframe_t> parasite_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, parasite_tap)
};
const mmove_t parasite_move_stand = mmove_t(parasite::frames::stand01, parasite::frames::stand17, parasite_frames_stand, parasite_stand);

void parasite_stand(ASEntity &self)
{
	M_SetAnimation(self, parasite_move_stand);
}

const array<mframe_t> parasite_frames_run = {
	mframe_t(ai_run, 30),
	mframe_t(ai_run, 30),
	mframe_t(ai_run, 22, monster_footstep),
	mframe_t(ai_run, 19, monster_footstep),
	mframe_t(ai_run, 24),
	mframe_t(ai_run, 28, monster_footstep),
	mframe_t(ai_run, 25, monster_footstep)
};
const mmove_t parasite_move_run = mmove_t(parasite::frames::run03, parasite::frames::run09, parasite_frames_run, null);

const array<mframe_t> parasite_frames_start_run = {
	mframe_t(ai_run),
	mframe_t(ai_run, 30)
};
const mmove_t parasite_move_start_run = mmove_t(parasite::frames::run01, parasite::frames::run02, parasite_frames_start_run, parasite_run);

/*
const array<mframe_t> parasite_frames_stop_run = {
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 20),
	mframe_t(ai_run, 12),
	mframe_t(ai_run, 10),
	mframe_t(ai_run),
	mframe_t(ai_run)
};
const mmove_t parasite_move_stop_run = mmove_t(parasite::frames::run10, parasite::frames::run15, parasite_frames_stop_run, null);
*/

void parasite_start_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, parasite_move_stand);
	else
		M_SetAnimation(self, parasite_move_start_run);
}

void parasite_run(ASEntity &self)
{
	if (self.proboscus !is null && self.proboscus.style != 2)
		proboscis_retract(self.proboscus);

	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, parasite_move_stand);
	else
		M_SetAnimation(self, parasite_move_run);
}

const array<mframe_t> parasite_frames_walk = {
	mframe_t(ai_walk, 30),
	mframe_t(ai_walk, 30),
	mframe_t(ai_walk, 22, monster_footstep),
	mframe_t(ai_walk, 19, monster_footstep),
	mframe_t(ai_walk, 24),
	mframe_t(ai_walk, 28, monster_footstep),
	mframe_t(ai_walk, 25, monster_footstep)
};
const mmove_t parasite_move_walk = mmove_t(parasite::frames::run03, parasite::frames::run09, parasite_frames_walk, parasite_walk);

const array<mframe_t> parasite_frames_start_walk = {
	mframe_t(ai_walk, 0),
	mframe_t(ai_walk, 30, parasite_walk)
};
const mmove_t parasite_move_start_walk = mmove_t(parasite::frames::run01, parasite::frames::run02, parasite_frames_start_walk, null);

/*
const array<mframe_t> parasite_frames_stop_walk = {
	mframe_t(ai_walk, 20),
	mframe_t(ai_walk, 20),
	mframe_t(ai_walk, 12),
	mframe_t(ai_walk, 10),
	mframe_t(ai_walk),
	mframe_t(ai_walk)
};
const mmove_t parasite_move_stop_walk = mmove_t(parasite::frames::run10, parasite::frames::run15, parasite_frames_stop_walk, null);
*/

void parasite_start_walk(ASEntity &self)
{
	M_SetAnimation(self, parasite_move_start_walk);
}

void parasite_walk(ASEntity &self)
{
	M_SetAnimation(self, parasite_move_walk);
}

// hard reset on proboscis; like we never existed
void proboscis_reset(ASEntity &self)
{
	@self.owner.proboscus = null;
	G_FreeEdict(self.proboscus);
	G_FreeEdict(self);
}

void proboscis_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (mod.id == mod_id_t::CRUSH)
		proboscis_reset(self);
}

void parasite_break_wait(ASEntity &self)
{
	// prob exploded?
	if (self.proboscus !is null && self.proboscus.style != 3)
		self.monsterinfo.nextframe = parasite::frames::break19;
	else if (brandom())
	{
		// don't get hurt
		parasite_reel_in(self);
		self.monsterinfo.nextframe = parasite::frames::break31;
	}
}

void proboscis_retract(ASEntity &self)
{
	// start retract animation
	if (self.owner.monsterinfo.active_move is parasite_move_fire_proboscis)
		self.owner.monsterinfo.nextframe = parasite::frames::drain12;

	// mark as retracting
	self.movetype = movetype_t::NONE;
	self.e.solid = solid_t::NOT;
	// come back real hard
	if (self.style != 2)
		self.speed *= g_athena_parasite_proboscis_retract_modifier;
	self.style = 2;
	gi_linkentity(self.e);
}

void parasite_break_retract(ASEntity &self)
{
	if (self.proboscus !is null)
		proboscis_retract(self.proboscus);
}

void parasite_break_sound(ASEntity &self)
{
	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::pain2, 1, ATTN_NORM, 0);

	self.pain_debounce_time = level.time + time_sec(3);
}

void parasite_charge_proboscis(ASEntity &self, float dist)
{
	if (self.e.s.frame >= parasite::frames::break01 && self.e.s.frame <= parasite::frames::break32)
		ai_move(self, dist);
	else
		ai_charge(self, dist);

	if (self.proboscus !is null)
		proboscis_segment_draw(self.proboscus.proboscus);
}

void parasite_break_noise(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::search, 1, ATTN_NORM, 0);
}

const array<mframe_t> parasite_frames_break = {
	mframe_t(parasite_charge_proboscis),
	mframe_t(parasite_charge_proboscis, -3, parasite_break_noise),
	mframe_t(parasite_charge_proboscis, 1),
	mframe_t(parasite_charge_proboscis, 2),
	mframe_t(parasite_charge_proboscis, -3),
	mframe_t(parasite_charge_proboscis, 1),
	mframe_t(parasite_charge_proboscis, 1),
	mframe_t(parasite_charge_proboscis, 3),
	mframe_t(parasite_charge_proboscis, 0, parasite_break_noise),
	mframe_t(parasite_charge_proboscis, -18),
	mframe_t(parasite_charge_proboscis, 3),
	mframe_t(parasite_charge_proboscis, 9),
	mframe_t(parasite_charge_proboscis, 6),
	mframe_t(parasite_charge_proboscis),
	mframe_t(parasite_charge_proboscis, -18),
	mframe_t(parasite_charge_proboscis),
	mframe_t(parasite_charge_proboscis, 8, parasite_break_retract),
	mframe_t(parasite_charge_proboscis, 9),
	mframe_t(parasite_charge_proboscis, 0, parasite_break_wait),
	mframe_t(parasite_charge_proboscis, -18, parasite_break_sound),
	mframe_t(parasite_charge_proboscis),
	mframe_t(parasite_charge_proboscis), // airborne
	mframe_t(parasite_charge_proboscis), // airborne
	mframe_t(parasite_charge_proboscis), // slides
	mframe_t(parasite_charge_proboscis), // slides
	mframe_t(parasite_charge_proboscis), // slides
	mframe_t(parasite_charge_proboscis), // slides
	mframe_t(parasite_charge_proboscis, 4),
	mframe_t(parasite_charge_proboscis, 11),
	mframe_t(parasite_charge_proboscis, -2),
	mframe_t(parasite_charge_proboscis, -5),
	mframe_t(parasite_charge_proboscis, 1)
};
const mmove_t parasite_move_break = mmove_t(parasite::frames::break01, parasite::frames::break32, parasite_frames_break, parasite_start_run);

void proboscis_touch(ASEntity &self, ASEntity &other, const trace_t &in tr, bool other_touching_self)
{
	// owner isn't trying to probe any more, don't touch anything
	if (self.owner.monsterinfo.active_move !is parasite_move_fire_proboscis)
		return;

	vec3_t p;

	// hit what we want to succ
	if ((other.e.svflags & svflags_t::PLAYER) != 0 || other is self.owner.enemy)
	{
		if (tr.startsolid)
			p = tr.endpos;
		else
			p = tr.endpos - ((self.e.s.origin - tr.endpos).normalized() * 12);

		self.owner.monsterinfo.nextframe = parasite::frames::drain06;
		self.movetype = movetype_t::NONE;
		self.e.solid = solid_t::NOT;
		self.style = 1;
		// stick to this guy
		self.move_origin = p - other.e.s.origin;
		@self.enemy = other;
		self.e.s.alpha = 0.35f;
		gi_sound(self.e, soundchan_t::WEAPON, parasite::sounds::suck, 1, ATTN_NORM, 0);
	}
	else
	{
		p = tr.endpos + tr.plane.normal;
		// hit monster, don't suck but do small damage
		// and retract immediately
		if ((other.e.svflags & (svflags_t::MONSTER | svflags_t::DEADMONSTER)) != 0)
			proboscis_retract(self);
		else
		{
			// hit wall; stick to it and do break animation
			@self.owner.monsterinfo.active_move = parasite_move_break;
			self.movetype = movetype_t::NONE;
			self.e.solid = solid_t::NOT;
			self.style = 1;
			self.owner.e.s.angles.yaw = self.e.s.angles.yaw;
		}
	}

	if (other.takedamage)
		T_Damage(other, self, self.owner, tr.plane.normal, tr.endpos, tr.plane.normal, 5, 0, damageflags_t::NONE, mod_id_t::UNKNOWN);

	gi_positioned_sound(tr.endpos, self.owner.e, soundchan_t::AUTO, parasite::sounds::impact, 1, ATTN_NORM, 0);

	self.e.s.origin = p;
	self.nextthink = level.time + FRAME_TIME_S; // start doing stuff on next frame
	gi_linkentity(self.e);
}

// from break01
const array<vec3_t> parasite_break_offsets = {
	{ 7.0f, 0, 7.0f },
	{ 6.3f, 14.5f, 4.0f },
	{ 8.5f, 0, 5.6f },
	{ 5.0f, -15.25f, 4.0f },
	{ 9.5f, -1.8f, 5.9f },
	{ 6.2f, 14.f, 4.0f },
	{ 12.25f, 7.5f, 1.4f },
	{ 13.8f, 0, -2.4f },
	{ 13.8f, 0, -4.0f },
	{ 0.1f, 0, -0.7f },
	{ 5.0f, 0, 3.7f },
	{ 11.f, 0, 4.f },
	{ 13.5f, 0, -4.0f },
	{ 13.5f, 0, -4.0f },
	{ 0.2f, 0, -0.7f },
	{ 3.9f, 0, 3.6f },
	{ 8.5f, 0, 5.0f },
	{ 14.0f, 0, -4.f },
	{ 14.0f, 0, -4.f },
	{ 0.1f, 0, -0.5f }
};

// from drain01
const array<vec3_t> parasite_drain_offsets = {
	{ -1.7f, 0, 1.2f },
	{ -2.2f, 0, -0.6f },
	{ 7.7f, 0, 7.2f },
	{ 7.2f, 0, 5.7f },
	{ 6.2f, 0, 7.8f },
	{ 4.7f, 0, 6.7f },
	{ 5.0f, 0, 9.0f },
	{ 5.0f, 0, 7.0f },
	{ 5.0f, 0, 10.5f },
	{ 4.5f, 0, 9.7f },
	{ 1.5f, 0, 12.0f },
	{ 2.9f, 0, 11.0f },
	{ 2.1f, 0, 7.6f },
};

vec3_t parasite_get_proboscis_start(ASEntity &self)
{
	vec3_t f, r, start;
	AngleVectors(self.e.s.angles, f, r);
	vec3_t offset;
	if (self.e.s.frame >= parasite::frames::break01 && self.e.s.frame < int(parasite::frames::break01 + parasite_break_offsets.length()))
		offset = parasite_break_offsets[self.e.s.frame - parasite::frames::break01];
	else if (self.e.s.frame >= parasite::frames::drain01 && self.e.s.frame < int(parasite::frames::drain01 + parasite_drain_offsets.length()))
		offset = parasite_drain_offsets[self.e.s.frame - parasite::frames::drain01];
	else
		offset = { 8, 0, 6 };
	start = M_ProjectFlashSource(self, offset, f, r);
	return start;
}

void proboscis_think(ASEntity &self)
{
	self.nextthink = level.time + FRAME_TIME_S; // start doing stuff on next frame

	// retracting; keep pulling until we hit the parasite
	if (self.style == 2)
	{
		vec3_t start = parasite_get_proboscis_start(self.owner);
		vec3_t dir = (self.e.s.origin - start);
		float dist = dir.normalize();

		if (dist <= (self.speed * 2) * gi_frame_time_s)
		{
			// reached target; free self on next frame, let parasite know
			self.style = 3;
			@self.think = proboscis_reset;
			self.e.s.origin = start;
			gi_linkentity(self.e);
			return;
		}

		// pull us in
		self.e.s.origin -= dir * (self.speed * gi_frame_time_s);
		gi_linkentity(self.e);
	}
	// stuck on target; do damage, suck health
	// and check if target goes away
	else if (self.style == 1)
	{
		if (self.enemy is null)
		{
			// stuck in wall
		}
		else if (!self.enemy.e.inuse || self.enemy.health <= 0 || !self.enemy.takedamage)
		{
			// target gone, retract early
			proboscis_retract(self);
		}
		else
		{
			// update our position
			self.e.s.origin = self.enemy.e.s.origin + self.move_origin;

			vec3_t start = parasite_get_proboscis_start(self.owner);

			self.e.s.angles = vectoangles((self.e.s.origin - start).normalized());

			// see if we got cut by the world
			trace_t tr = gi_traceline(start, self.e.s.origin, null, contents_t::MASK_SOLID);

			if (tr.fraction != 1.0f)
			{
				// blocked, so retract
				proboscis_retract(self);
				self.e.s.origin = self.e.s.old_origin;
			}
			else
			{
				// succ & drain
				if (self.timestamp <= level.time)
				{
					T_Damage(self.enemy, self, self.owner, tr.plane.normal, tr.endpos, tr.plane.normal, 2, 0, damageflags_t::NONE, mod_id_t::UNKNOWN);
					self.owner.health = min(self.owner.max_health, self.owner.health + 2);
					self.owner.monsterinfo.setskin(self.owner);
					self.timestamp = level.time + time_hz(10);
				}
			}

			gi_linkentity(self.e);
		}
	}
	// flying
	else if (self.style == 0)
	{
		// owner gone away?
		if (self.owner.enemy is null || !self.owner.enemy.e.inuse || self.owner.enemy.health <= 0)
		{
			proboscis_retract(self);
			return;
		}

		// if we're well behind our target and missed by 2x velocity,
		// be smart enough to pull in automatically
		vec3_t to_target = (self.e.s.origin - self.owner.enemy.e.s.origin);
		float dist_to_target = to_target.normalize();

		if (dist_to_target > (self.speed * 2) / 15.f)
		{
			vec3_t from_owner = (self.e.s.origin - self.owner.e.s.origin).normalized();
			float dot = to_target.dot(from_owner);

			if (dot > 0.f)
			{
				proboscis_retract(self);
				return;
			}
		}
	}
}

void proboscis_segment_draw(ASEntity &self)
{
	vec3_t start = parasite_get_proboscis_start(self.owner.owner);

	self.e.s.origin = start;
	self.e.s.old_origin = self.owner.e.s.origin - ((self.owner.e.s.origin - start).normalized() * 8.f);
	gi_linkentity(self.e);
}

void fire_proboscis(ASEntity &self, const vec3_t &in start, const vec3_t &in dir, float speed)
{
	ASEntity @tip = G_Spawn();
	tip.e.s.angles = vectoangles(dir);
	tip.e.s.modelindex = gi_modelindex("models/monsters/parasite/tip/tris.md2");
	tip.movetype = movetype_t::FLYMISSILE;
	@tip.owner = self;
	@self.proboscus = tip;
	tip.e.clipmask = contents_t(contents_t::MASK_PROJECTILE & ~contents_t::DEADMONSTER);
	tip.e.s.origin = tip.e.s.old_origin = start;
	tip.speed = speed;
	tip.velocity = dir * speed;
	tip.e.solid = solid_t::BBOX;
	tip.takedamage = true;
	tip.flags = ent_flags_t(tip.flags | ent_flags_t::NO_DAMAGE_EFFECTS | ent_flags_t::NO_KNOCKBACK);
	@tip.die = proboscis_die;
	@tip.touch = proboscis_touch;
	@tip.think = proboscis_think;
	tip.nextthink = level.time + FRAME_TIME_S; // start doing stuff on next frame
	tip.e.svflags = svflags_t(tip.e.svflags | svflags_t::PROJECTILE);

	ASEntity @segment = G_Spawn();
	segment.e.s.modelindex = gi_modelindex("models/monsters/parasite/segment/tris.md2");
	segment.e.s.renderfx = renderfx_t::BEAM;
	@segment.postthink = proboscis_segment_draw;

	@tip.proboscus = segment;
	@segment.owner = tip;

	trace_t tr = gi_traceline(tip.e.s.origin, tip.e.s.origin + (tip.velocity * gi_frame_time_s), self.e, tip.e.clipmask);
	if (tr.startsolid)
	{
		tr.plane.normal = -dir;
		tr.endpos = start;
		tip.touch(tip, entities[tr.ent.s.number], tr, false);
	}
	else if (tr.fraction < 1.0f)
		tip.touch(tip, entities[tr.ent.s.number], tr, false);

	segment.e.s.origin = start;
	segment.e.s.old_origin = tip.e.s.origin + ((tip.e.s.origin - start).normalized() * 8.f);

	gi_linkentity(tip.e);
	gi_linkentity(segment.e);
}

void parasite_fire_proboscis(ASEntity &self)
{
	if (self.proboscus !is null && self.proboscus.style != 2)
		proboscis_reset(self.proboscus);

	vec3_t start = parasite_get_proboscis_start(self);

	vec3_t dir;
	PredictAim(self, self.enemy, start, g_athena_parasite_proboscis_speed, false, crandom() * g_athena_parasite_miss_chance, dir);

	fire_proboscis(self, start, dir, g_athena_parasite_proboscis_speed);
}

void parasite_proboscis_wait(ASEntity &self)
{
	// loop frames while we wait
	if (self.e.s.frame == parasite::frames::drain04)
		self.monsterinfo.nextframe = parasite::frames::drain05;
	else
		self.monsterinfo.nextframe = parasite::frames::drain04;
}

void parasite_proboscis_pull_wait(ASEntity &self)
{
	// prob exploded?
	if (self.proboscus is null || self.proboscus.style == 3)
	{
		self.monsterinfo.nextframe = parasite::frames::drain14;
		return;
	}

	// being pulled in, so wait until we get destroyed
	if (self.e.s.frame == parasite::frames::drain12)
		self.monsterinfo.nextframe = parasite::frames::drain13;
	else
		self.monsterinfo.nextframe = parasite::frames::drain12;

	if (self.proboscus.style != 2)
		proboscis_retract(self.proboscus);
}

const array<mframe_t> parasite_frames_fire_proboscis = {
	mframe_t(parasite_charge_proboscis, 0, parasite_launch),
	mframe_t(parasite_charge_proboscis),
	mframe_t(parasite_charge_proboscis, 15, parasite_fire_proboscis), // Target hits
	mframe_t(parasite_charge_proboscis, 0, parasite_proboscis_wait),  // drain
	mframe_t(parasite_charge_proboscis, 0, parasite_proboscis_wait),  // drain
	mframe_t(parasite_charge_proboscis, 0),  // drain
	mframe_t(parasite_charge_proboscis, 0),  // drain
	mframe_t(parasite_charge_proboscis, -2), // drain
	mframe_t(parasite_charge_proboscis, -2), // drain
	mframe_t(parasite_charge_proboscis, -3), // drain
	mframe_t(parasite_charge_proboscis, -2), // drain
	mframe_t(parasite_charge_proboscis, 0, parasite_proboscis_pull_wait),  // drain
	mframe_t(parasite_charge_proboscis, -1, parasite_proboscis_pull_wait), // drain
	mframe_t(parasite_charge_proboscis, 0, parasite_reel_in),		  // let go
	mframe_t(parasite_charge_proboscis, -2),
	mframe_t(parasite_charge_proboscis, -2),
	mframe_t(parasite_charge_proboscis, -3),
	mframe_t(parasite_charge_proboscis)
};
const mmove_t parasite_move_fire_proboscis = mmove_t(parasite::frames::drain01, parasite::frames::drain18, parasite_frames_fire_proboscis, parasite_start_run);

void parasite_attack(ASEntity &self)
{
	if (!M_CheckClearShot(self, parasite_drain_offsets[0]))
		return;

	if (self.proboscus !is null && self.proboscus.style != 2)
		proboscis_retract(self.proboscus);

	M_SetAnimation(self, parasite_move_fire_proboscis);
}

//================
// ROGUE
void parasite_jump_down(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void parasite_jump_up(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 200);
	self.velocity += (up * 450);
}

void parasite_jump_wait_land(ASEntity &self)
{
	if (self.groundentity is null)
	{
		self.monsterinfo.nextframe = self.e.s.frame;

		if (monster_jump_finished(self))
			self.monsterinfo.nextframe = self.e.s.frame + 1;
	}
	else
		self.monsterinfo.nextframe = self.e.s.frame + 1;
}

const array<mframe_t> parasite_frames_jump_up = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -8, parasite_jump_up),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, parasite_jump_wait_land),
	mframe_t(ai_move)
};
const mmove_t parasite_move_jump_up = mmove_t(parasite::frames::jump01, parasite::frames::jump08, parasite_frames_jump_up, parasite_run);

const array<mframe_t> parasite_frames_jump_down = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, parasite_jump_down),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, parasite_jump_wait_land),
	mframe_t(ai_move)
};
const mmove_t parasite_move_jump_down = mmove_t(parasite::frames::jump01, parasite::frames::jump08, parasite_frames_jump_down, parasite_run);

void parasite_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, parasite_move_jump_up);
	else
		M_SetAnimation(self, parasite_move_jump_down);
}

/*
===
Blocked
===
*/
bool parasite_blocked(ASEntity &self, float dist)
{
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			parasite_jump(self, result);
		return true;
	}

	if (blocked_checkplat(self, dist))
		return true;

	return false;
}
// ROGUE
//================

/*
===
Death Stuff Starts
===
*/

void parasite_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	monster_dead(self);
}

void parasite_shrink(ASEntity &self)
{
	self.e.maxs.z = 0;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> parasite_frames_death = {
	mframe_t(ai_move, 0, null, parasite::frames::stand01),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, parasite_shrink),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t parasite_move_death = mmove_t(parasite::frames::death101, parasite::frames::death107, parasite_frames_death, parasite_dead);

void parasite_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	if (self.proboscus !is null && self.proboscus.style != 2)
		proboscis_reset(self.proboscus);

	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(1, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(3, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t("models/monsters/parasite/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t(2, "models/monsters/parasite/gibs/bleg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t(2, "models/monsters/parasite/gibs/fleg.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/parasite/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});

		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::die, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;
	M_SetAnimation(self, parasite_move_death);
}

/*
===
End Death Stuff
===
*/

const array<mframe_t> parasite_frames_pain1 = {
	mframe_t(ai_move, 0, null, parasite::frames::stand01),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, function(self) { self.monsterinfo.nextframe = parasite::frames::pain105; }),
	mframe_t(ai_move, 0, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 6, monster_footstep),
	mframe_t(ai_move, 16),
	mframe_t(ai_move, -6, monster_footstep),
	mframe_t(ai_move, -7),
	mframe_t(ai_move)
};
const mmove_t parasite_move_pain1 = mmove_t(parasite::frames::pain101, parasite::frames::pain111, parasite_frames_pain1, parasite_start_run);

void parasite_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	if (self.proboscus !is null && self.proboscus.style != 2)
		proboscis_retract(self.proboscus);

	self.pain_debounce_time = level.time + time_sec(3);

	if (frandom() < 0.5f)
		gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::pain1, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, parasite::sounds::pain2, 1, ATTN_NORM, 0);
	
	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	M_SetAnimation(self, parasite_move_pain1);
}

void parasite_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum = 1;
	else
		self.e.s.skinnum = 0;
}

namespace spawnflags::parasite
{
    const uint32 NOJUMPING = 8;
}

/*QUAKED monster_parasite (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight NoJumping
 */
void SP_monster_parasite(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	parasite::sounds::pain1.precache();
	parasite::sounds::pain2.precache();
	parasite::sounds::die.precache();
	parasite::sounds::launch.precache();
	parasite::sounds::impact.precache();
	parasite::sounds::suck.precache();
	parasite::sounds::reelin.precache();
	parasite::sounds::sight.precache();
	parasite::sounds::tap.precache();
	parasite::sounds::scratch.precache();
	parasite::sounds::search.precache();

	gi_modelindex("models/monsters/parasite/tip/tris.md2");
	gi_modelindex("models/monsters/parasite/segment/tris.md2");

	self.e.s.modelindex = gi_modelindex("models/monsters/parasite/tris.md2");
	
	gi_modelindex("models/monsters/parasite/gibs/head.md2");
	gi_modelindex("models/monsters/parasite/gibs/chest.md2");
	gi_modelindex("models/monsters/parasite/gibs/bleg.md2");
	gi_modelindex("models/monsters/parasite/gibs/fleg.md2");

	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 24 };
	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;

	self.health = int(175 * st.health_multiplier);
	self.gib_health = -50;
	self.mass = 250;

	@self.pain = parasite_pain;
	@self.die = parasite_die;

	@self.monsterinfo.stand = parasite_stand;
	@self.monsterinfo.walk = parasite_start_walk;
	@self.monsterinfo.run = parasite_start_run;
	@self.monsterinfo.attack = parasite_attack;
	@self.monsterinfo.sight = parasite_sight;
	@self.monsterinfo.idle = parasite_idle;
	@self.monsterinfo.blocked = parasite_blocked; // PGM
	@self.monsterinfo.setskin = parasite_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, parasite_move_stand);
	self.monsterinfo.scale = parasite::SCALE;
	self.yaw_speed = 30;
	self.monsterinfo.can_jump = (self.spawnflags & spawnflags::parasite::NOJUMPING) == 0;
	self.monsterinfo.drop_height = 256;
	self.monsterinfo.jump_height = 68;

	walkmonster_start(self);
}
