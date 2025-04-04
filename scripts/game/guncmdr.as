// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

GUNNER COMMANDER

==============================================================================
*/

namespace spawnflags::guncmdr
{
    const uint32 NOJUMPING = 8;
}

namespace guncmdr::sounds
{
    cached_soundindex pain("guncmdr/gcdrpain2.wav");
    cached_soundindex pain2("guncmdr/gcdrpain1.wav");
    cached_soundindex death("guncmdr/gcdrdeath1.wav");
    cached_soundindex idle("guncmdr/gcdridle1.wav");
    cached_soundindex open("guncmdr/gcdratck1.wav");
    cached_soundindex search("guncmdr/gcdrsrch1.wav");
    cached_soundindex sight("guncmdr/sight1.wav");
}

void guncmdr_idlesound(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::idle, 1, ATTN_IDLE, 0);
}

void guncmdr_sight(ASEntity &self, ASEntity &other)
{
	gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::sight, 1, ATTN_NORM, 0);
}

void guncmdr_search(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::search, 1, ATTN_NORM, 0);
}

const array<mframe_t> guncmdr_frames_fidget = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_idlesound),
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_idlesound),
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
	mframe_t(ai_stand),
	mframe_t(ai_stand),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand)
};
const mmove_t guncmdr_move_fidget = mmove_t(gunner::frames::c_stand201, gunner::frames::c_stand254, guncmdr_frames_fidget, guncmdr_stand);

void guncmdr_fidget(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		return;
	else if (self.enemy !is null)
		return;
	if (frandom() <= 0.05f)
		M_SetAnimation(self, guncmdr_move_fidget);
}

const array<mframe_t> guncmdr_frames_stand = {
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_fidget),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_fidget),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_fidget),

	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand),
	mframe_t(ai_stand, 0, guncmdr_fidget)
};
const mmove_t guncmdr_move_stand = mmove_t(gunner::frames::c_stand101, gunner::frames::c_stand140, guncmdr_frames_stand, null);

void guncmdr_stand(ASEntity &self)
{
	M_SetAnimation(self, guncmdr_move_stand);
}

const array<mframe_t> guncmdr_frames_walk = {
	mframe_t(ai_walk, 1.5f, monster_footstep),
	mframe_t(ai_walk, 2.5f),
	mframe_t(ai_walk, 3.0f),
	mframe_t(ai_walk, 2.5f),
	mframe_t(ai_walk, 2.3f),
	mframe_t(ai_walk, 3.0f),
	mframe_t(ai_walk, 2.8f, monster_footstep),
	mframe_t(ai_walk, 3.6f),
	mframe_t(ai_walk, 2.8f),
	mframe_t(ai_walk, 2.5f),

	mframe_t(ai_walk, 2.3f),
	mframe_t(ai_walk, 4.3f),
	mframe_t(ai_walk, 3.0f, monster_footstep),
	mframe_t(ai_walk, 1.5f),
	mframe_t(ai_walk, 2.5f),
	mframe_t(ai_walk, 3.3f),
	mframe_t(ai_walk, 2.8f),
	mframe_t(ai_walk, 3.0f),
	mframe_t(ai_walk, 2.0f, monster_footstep),
	mframe_t(ai_walk, 2.0f),

	mframe_t(ai_walk, 3.3f),
	mframe_t(ai_walk, 3.6f),
	mframe_t(ai_walk, 3.4f),
	mframe_t(ai_walk, 2.8f),
};
const mmove_t guncmdr_move_walk = mmove_t(gunner::frames::c_walk101, gunner::frames::c_walk124, guncmdr_frames_walk, null);

void guncmdr_walk(ASEntity &self)
{
	M_SetAnimation(self, guncmdr_move_walk);
}

const array<mframe_t> guncmdr_frames_run = {
	mframe_t(ai_run, 15.f, monster_done_dodge),
	mframe_t(ai_run, 16.f, monster_footstep),
	mframe_t(ai_run, 20.f),
	mframe_t(ai_run, 18.f),
	mframe_t(ai_run, 24.f, monster_footstep),
	mframe_t(ai_run, 13.5f)
};

const mmove_t guncmdr_move_run = mmove_t(gunner::frames::c_run101, gunner::frames::c_run106, guncmdr_frames_run, null);

void guncmdr_run(ASEntity &self)
{
	monster_done_dodge(self);
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, guncmdr_move_stand);
	else
		M_SetAnimation(self, guncmdr_move_run);
}

// standing pains

const array<mframe_t> guncmdr_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
};
const mmove_t guncmdr_move_pain1 = mmove_t(gunner::frames::c_pain101, gunner::frames::c_pain104, guncmdr_frames_pain1, guncmdr_run);

const array<mframe_t> guncmdr_frames_pain2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_pain2 = mmove_t(gunner::frames::c_pain201, gunner::frames::c_pain204, guncmdr_frames_pain2, guncmdr_run);

const array<mframe_t> guncmdr_frames_pain3 = {
	mframe_t(ai_move, -3.0f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
};
const mmove_t guncmdr_move_pain3 = mmove_t(gunner::frames::c_pain301, gunner::frames::c_pain304, guncmdr_frames_pain3, guncmdr_run);

const array<mframe_t> guncmdr_frames_pain4 = {
	mframe_t(ai_move, -17.1f),
	mframe_t(ai_move, -3.2f),
	mframe_t(ai_move, 0.9f),
	mframe_t(ai_move, 3.6f),
	mframe_t(ai_move, -2.6f),
	mframe_t(ai_move, 1.0f),
	mframe_t(ai_move, -5.1f),
	mframe_t(ai_move, -6.7f),
	mframe_t(ai_move, -8.8f),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move, -2.1f),
	mframe_t(ai_move, -2.3f),
	mframe_t(ai_move, -2.5f),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_pain4 = mmove_t(gunner::frames::c_pain401, gunner::frames::c_pain415, guncmdr_frames_pain4, guncmdr_run);

const array<mframe_t> guncmdr_frames_death1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 4.0f), // scoot
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
const mmove_t guncmdr_move_death1 = mmove_t(gunner::frames::c_death101, gunner::frames::c_death118, guncmdr_frames_death1, guncmdr_dead);

void guncmdr_pain5_to_death1(ASEntity &self)
{
	if (self.health <= 0)
		M_SetAnimation(self, guncmdr_move_death1, false);
}

const array<mframe_t> guncmdr_frames_death2 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_death2 = mmove_t(gunner::frames::c_death201, gunner::frames::c_death204, guncmdr_frames_death2, guncmdr_dead);

void guncmdr_pain5_to_death2(ASEntity &self)
{
	if (self.health <= 0 && brandom())
		M_SetAnimation(self, guncmdr_move_death2, false);
}

const array<mframe_t> guncmdr_frames_pain5 = {
	mframe_t(ai_move, -29.f),
	mframe_t(ai_move, -5.f),
	mframe_t(ai_move, -5.f),
	mframe_t(ai_move, -3.f),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, guncmdr_pain5_to_death2),
	mframe_t(ai_move, 9.f),
	mframe_t(ai_move, 3.f),
	mframe_t(ai_move, 0, guncmdr_pain5_to_death1),
	mframe_t(ai_move),

	mframe_t(ai_move),
	mframe_t(ai_move, -4.6f),
	mframe_t(ai_move, -4.8f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 9.5f),
	mframe_t(ai_move, 3.4f),
	mframe_t(ai_move),
	mframe_t(ai_move),

	mframe_t(ai_move, -2.4f),
	mframe_t(ai_move, -9.0f),
	mframe_t(ai_move, -5.0f),
	mframe_t(ai_move, -3.6f),
};
const mmove_t guncmdr_move_pain5 = mmove_t(gunner::frames::c_pain501, gunner::frames::c_pain524, guncmdr_frames_pain5, guncmdr_run);

void guncmdr_dead(ASEntity &self)
{
	self.e.mins = vec3_t(-16, -16, -24) * self.e.s.scale;
	self.e.maxs = vec3_t(16, 16, -8) * self.e.s.scale;
	monster_dead(self);
}

void guncmdr_shrink(ASEntity &self)
{
	self.e.maxs[2] = -4 * self.e.s.scale;
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::DEADMONSTER);
	gi_linkentity(self.e);
}

const array<mframe_t> guncmdr_frames_death6 = {
	mframe_t(ai_move, 0, guncmdr_shrink),
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
const mmove_t guncmdr_move_death6 = mmove_t(gunner::frames::c_death601, gunner::frames::c_death614, guncmdr_frames_death6, guncmdr_dead);

void guncmdr_pain6_to_death6(ASEntity &self)
{
	if (self.health <= 0)
		M_SetAnimation(self, guncmdr_move_death6, false);
}

const array<mframe_t> guncmdr_frames_pain6 = {
	mframe_t(ai_move, 16.f),
	mframe_t(ai_move, 16.f),
	mframe_t(ai_move, 12.f),
	mframe_t(ai_move, 5.5f, monster_duck_down),
	mframe_t(ai_move, 3.0f),
	mframe_t(ai_move, -4.7f),
	mframe_t(ai_move, -6.0f, guncmdr_pain6_to_death6),
	mframe_t(ai_move),
	mframe_t(ai_move, 1.8f),
	mframe_t(ai_move, 0.7f),

	mframe_t(ai_move),
	mframe_t(ai_move, -2.1f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	
	mframe_t(ai_move),
	mframe_t(ai_move, -6.1f),
	mframe_t(ai_move, 10.5f),
	mframe_t(ai_move, 4.3f),
	mframe_t(ai_move, 4.7f, monster_duck_up),
	mframe_t(ai_move, 1.4f),
	mframe_t(ai_move),
	mframe_t(ai_move, -3.2f),
	mframe_t(ai_move, 2.3f),
	mframe_t(ai_move, -4.4f),

	mframe_t(ai_move, -4.4f),
	mframe_t(ai_move, -2.4f)
};
const mmove_t guncmdr_move_pain6 = mmove_t(gunner::frames::c_pain601, gunner::frames::c_pain632, guncmdr_frames_pain6, guncmdr_run);

const array<mframe_t> guncmdr_frames_pain7 = {
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
const mmove_t guncmdr_move_pain7 = mmove_t(gunner::frames::c_pain701, gunner::frames::c_pain714, guncmdr_frames_pain7, guncmdr_run);

void guncmdr_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	monster_done_dodge(self);

	if (self.monsterinfo.active_move is guncmdr_move_jump || 
		self.monsterinfo.active_move is guncmdr_move_jump2 ||
		self.monsterinfo.active_move is guncmdr_move_duck_attack)
		return;

	if (level.time < self.pain_debounce_time)
	{
		if (frandom() < 0.3)
			self.monsterinfo.dodge(self, other, FRAME_TIME_S, null_trace, false, true);

		return;
	}

	self.pain_debounce_time = level.time + time_sec(3);

	if (brandom())
		gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::pain, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::pain2, 1, ATTN_NORM, 0);

	if (!M_ShouldReactToPain(self, mod))
	{
		if (frandom() < 0.3)
			self.monsterinfo.dodge(self, other, FRAME_TIME_S, null_trace, false, true);

		return; // no pain anims in nightmare
	}

	vec3_t forward;
	AngleVectors(self.e.s.angles, forward);

	vec3_t dif = (other.e.s.origin - self.e.s.origin);
	dif.z = 0;
	dif.normalize();

	// small pain
	if (damage < 35)
	{
		int r = irandom(0, 4);

		if (r == 0)
			M_SetAnimation(self, guncmdr_move_pain3);
		else if (r == 1)
			M_SetAnimation(self, guncmdr_move_pain2);
		else if (r == 2)
			M_SetAnimation(self, guncmdr_move_pain1);
		else
			M_SetAnimation(self, guncmdr_move_pain7);
	}
	// large pain from behind (aka Paril)
	else if (dif.dot(forward) < -0.40f)
	{
		M_SetAnimation(self, guncmdr_move_pain6);

		self.pain_debounce_time += time_sec(1.5);
	}
	else
	{
		if (brandom())
			M_SetAnimation(self, guncmdr_move_pain4);
		else
			M_SetAnimation(self, guncmdr_move_pain5);

		self.pain_debounce_time += time_sec(1.5);
	}

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MANUAL_STEERING);

	// PMM - clear duck flag
	if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0)
		monster_duck_up(self);
}

void guncmdr_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1;
	else
		self.e.s.skinnum &= ~1;
}

const array<mframe_t> guncmdr_frames_death3 = {
	mframe_t(ai_move, 20.f),
	mframe_t(ai_move, 10.f),
	mframe_t(ai_move, 10.f, function(self) { monster_footstep(self); guncmdr_shrink(self); }),
	mframe_t(ai_move, 0.f, monster_footstep),
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
const mmove_t guncmdr_move_death3 = mmove_t(gunner::frames::c_death301, gunner::frames::c_death321, guncmdr_frames_death3, guncmdr_dead);

const array<mframe_t> guncmdr_frames_death7 = {
	mframe_t(ai_move, 30.f),
	mframe_t(ai_move, 20.f),
	mframe_t(ai_move, 16.f, function(self) { monster_footstep(self); guncmdr_shrink(self); }),
	mframe_t(ai_move, 5.f, monster_footstep),
	mframe_t(ai_move, -6.f),
	mframe_t(ai_move, -7.f, monster_footstep),
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
	mframe_t(ai_move, 0.f, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0.f, monster_footstep),
	mframe_t(ai_move),
	mframe_t(ai_move),
};
const mmove_t guncmdr_move_death7 = mmove_t(gunner::frames::c_death701, gunner::frames::c_death730, guncmdr_frames_death7, guncmdr_dead);

const array<mframe_t> guncmdr_frames_death4 = {
	mframe_t(ai_move, -20.f),
	mframe_t(ai_move, -16.f),
	mframe_t(ai_move, -26.f, function(self) { monster_footstep(self); guncmdr_shrink(self); }),
	mframe_t(ai_move, 0.f, monster_footstep),
	mframe_t(ai_move, -12.f),
	mframe_t(ai_move, 16.f),
	mframe_t(ai_move, 9.2f),
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
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_death4 = mmove_t(gunner::frames::c_death401, gunner::frames::c_death436, guncmdr_frames_death4, guncmdr_dead);

const array<mframe_t> guncmdr_frames_death5 = {
	mframe_t(ai_move, -14.f),
	mframe_t(ai_move, -2.7f),
	mframe_t(ai_move, -2.5f),
	mframe_t(ai_move, -4.6f, monster_footstep),
	mframe_t(ai_move, -4.0f, monster_footstep),
	mframe_t(ai_move, -1.5f),
	mframe_t(ai_move, 2.3f),
	mframe_t(ai_move, 2.5f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 3.5f),
	mframe_t(ai_move, 12.9f, monster_footstep),
	mframe_t(ai_move, 3.8f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	
	mframe_t(ai_move, -2.1f),
	mframe_t(ai_move, -1.3f),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 3.4f),
	mframe_t(ai_move, 5.7f),
	mframe_t(ai_move, 11.2f),
	mframe_t(ai_move, 0, monster_footstep)
};
const mmove_t guncmdr_move_death5 = mmove_t(gunner::frames::c_death501, gunner::frames::c_death528, guncmdr_frames_death5, guncmdr_dead);

void guncmdr_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	// check for gib
	if (M_CheckGib(self, mod))
	{
		gi_sound(self.e, soundchan_t::VOICE, gi_soundindex("misc/udeath.wav"), 1, ATTN_NORM, 0);

		string head_gib = (self.monsterinfo.active_move !is guncmdr_move_death5) ? "models/objects/gibs/sm_meat/tris.md2" : "models/monsters/gunner/gibs/head.md2";

		self.e.s.skinnum /= 2;

		ThrowGibs(self, damage, {
			gib_def_t(2, "models/objects/gibs/bone/tris.md2"),
			gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
			gib_def_t(1, "models/objects/gibs/gear/tris.md2"),
			gib_def_t("models/monsters/gunner/gibs/chest.md2", gib_type_t::SKINNED),
			gib_def_t("models/monsters/gunner/gibs/garm.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gunner/gibs/gun.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::UPRIGHT)),
			gib_def_t("models/monsters/gunner/gibs/foot.md2", gib_type_t::SKINNED),
			gib_def_t(head_gib, gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
		});
		self.deadflag = true;
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::death, 1, ATTN_NORM, 0);
	self.deadflag = true;
	self.takedamage = true;

	// these animations cleanly transitions to death, so just keep going
	if (self.monsterinfo.active_move is guncmdr_move_pain5 &&
		self.e.s.frame < gunner::frames::c_pain508)
		return;
	else if (self.monsterinfo.active_move is guncmdr_move_pain6 &&
		self.e.s.frame < gunner::frames::c_pain607)
		return;

	vec3_t forward;
	AngleVectors(self.e.s.angles, forward);

	vec3_t dif = (inflictor.e.s.origin - self.e.s.origin);
	dif.z = 0;
	dif.normalize();

	// off with da head
	if (abs((self.e.s.origin[2] + self.viewheight) - point[2]) <= 4 &&
		self.velocity.z < 65.f)
	{
		M_SetAnimation(self, guncmdr_move_death5);

		ASEntity @head = ThrowGib(self, "models/monsters/gunner/gibs/head.md2", damage, gib_type_t::NONE, self.e.s.scale);

		if (head !is null)
		{
			head.e.s.angles = self.e.s.angles;
			head.e.s.origin = self.e.s.origin + vec3_t(0, 0, 24.f);
			vec3_t headDir = (self.e.s.origin - inflictor.e.s.origin);
			head.velocity = headDir / headDir.length() * 100.0f;
			head.velocity[2] = 200.0f;
			head.avelocity *= 0.15f;
			gi_linkentity(head.e);
		}
	}
	// damage came from behind; use backwards death
	else if (dif.dot(forward) < -0.40f)
	{
		int r = irandom(0, self.monsterinfo.active_move is guncmdr_move_pain6 ? 2 : 3);

		if (r == 0)
			M_SetAnimation(self, guncmdr_move_death3);
		else if (r == 1)
			M_SetAnimation(self, guncmdr_move_death7);
		else if (r == 2)
			M_SetAnimation(self, guncmdr_move_pain6);
	}
	else
	{
		int r = irandom(0, self.monsterinfo.active_move is guncmdr_move_pain5 ? 1 : 2);

		if (r == 0)
			M_SetAnimation(self, guncmdr_move_death4);
		else
			M_SetAnimation(self, guncmdr_move_pain5);
	}
}

void guncmdr_opengun(ASEntity &self)
{
	gi_sound(self.e, soundchan_t::VOICE, guncmdr::sounds::open, 1, ATTN_IDLE, 0);
}

void GunnerCmdrFire(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right;
	vec3_t					 aim;
	monster_muzzle_t         flash_number;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	if (self.e.s.frame >= gunner::frames::c_attack401 && self.e.s.frame <= gunner::frames::c_attack505)
		flash_number = monster_muzzle_t::GUNCMDR_CHAINGUN_2;
	else
		flash_number = monster_muzzle_t::GUNCMDR_CHAINGUN_1;

	AngleVectors(self.e.s.angles, forward, right);
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);
	PredictAim(self, self.enemy, start, 800, false, frandom() * 0.3f, aim);
	for (int i = 0; i < 3; i++)
		aim[i] += crandom_open() * 0.025f;
	monster_fire_flechette(self, start, aim, 4, 800, flash_number);
}

const array<mframe_t> guncmdr_frames_attack_chain = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guncmdr_opengun),
	mframe_t(ai_charge)
};
const mmove_t guncmdr_move_attack_chain = mmove_t(gunner::frames::c_attack101, gunner::frames::c_attack106, guncmdr_frames_attack_chain, guncmdr_fire_chain);

const array<mframe_t> guncmdr_frames_fire_chain = {
	mframe_t(ai_charge, 0, GunnerCmdrFire),
	mframe_t(ai_charge, 0, GunnerCmdrFire),
	mframe_t(ai_charge, 0, GunnerCmdrFire),
	mframe_t(ai_charge, 0, GunnerCmdrFire),
	mframe_t(ai_charge, 0, GunnerCmdrFire),
	mframe_t(ai_charge, 0, GunnerCmdrFire)
};
const mmove_t guncmdr_move_fire_chain = mmove_t(gunner::frames::c_attack107, gunner::frames::c_attack112, guncmdr_frames_fire_chain, guncmdr_refire_chain);

const array<mframe_t> guncmdr_frames_fire_chain_run = {
	mframe_t(ai_charge, 15.f, GunnerCmdrFire),
	mframe_t(ai_charge, 16.f, GunnerCmdrFire),
	mframe_t(ai_charge, 20.f, GunnerCmdrFire),
	mframe_t(ai_charge, 18.f, GunnerCmdrFire),
	mframe_t(ai_charge, 24.f, GunnerCmdrFire),
	mframe_t(ai_charge, 13.5f, GunnerCmdrFire)
};
const mmove_t guncmdr_move_fire_chain_run = mmove_t(gunner::frames::c_run201, gunner::frames::c_run206, guncmdr_frames_fire_chain_run, guncmdr_refire_chain);

const array<mframe_t> guncmdr_frames_fire_chain_dodge_right = {
	mframe_t(ai_charge, 5.1f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 9.0f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 3.5f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 3.6f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, -1.0f * 2.0f, GunnerCmdrFire)
};
const mmove_t guncmdr_move_fire_chain_dodge_right = mmove_t(gunner::frames::c_attack401, gunner::frames::c_attack405, guncmdr_frames_fire_chain_dodge_right, guncmdr_refire_chain);

const array<mframe_t> guncmdr_frames_fire_chain_dodge_left = {
	mframe_t(ai_charge, 5.1f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 9.0f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 3.5f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, 3.6f * 2.0f, GunnerCmdrFire),
	mframe_t(ai_charge, -1.0f * 2.0f, GunnerCmdrFire)
};
const mmove_t guncmdr_move_fire_chain_dodge_left = mmove_t(gunner::frames::c_attack501, gunner::frames::c_attack505, guncmdr_frames_fire_chain_dodge_left, guncmdr_refire_chain);

const array<mframe_t> guncmdr_frames_endfire_chain = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, guncmdr_opengun),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guncmdr_move_endfire_chain = mmove_t(gunner::frames::c_attack118, gunner::frames::c_attack124, guncmdr_frames_endfire_chain, guncmdr_run);

const int MORTAR_SPEED = 850.f;
const int GRENADE_SPEED = 600.f;

void GunnerCmdrGrenade(ASEntity &self)
{
	vec3_t					 start;
	vec3_t					 forward, right, up;
	vec3_t					 aim;
	monster_muzzle_t         flash_number;
	float					 spread;
	float					 pitch = 0;
	// PMM
	vec3_t target;
	bool   blindfire = false;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	// pmm
	if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) != 0)
		blindfire = true;
	
	if (self.e.s.frame == gunner::frames::c_attack205)
	{
		spread = -0.1f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1;
	}
	else if (self.e.s.frame == gunner::frames::c_attack208)
	{
		spread = 0.f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_2;
	}
	else if (self.e.s.frame == gunner::frames::c_attack211)
	{
		spread = 0.1f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_3;
	}
	else if (self.e.s.frame == gunner::frames::c_attack304)
	{
		spread = -0.1f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_FRONT_1;
	}
	else if (self.e.s.frame == gunner::frames::c_attack307)
	{
		spread = 0.f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_FRONT_2;
	}
	else if (self.e.s.frame == gunner::frames::c_attack310)
	{
		spread = 0.1f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_FRONT_3;
	}
	else if (self.e.s.frame == gunner::frames::c_attack911)
	{
		spread = 0.25f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_1;
	}
	else if (self.e.s.frame == gunner::frames::c_attack912)
	{
		spread = 0.f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_2;
	}
	else if (self.e.s.frame == gunner::frames::c_attack913)
	{
		spread = -0.25f;
		flash_number = monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_3;
	}

	//	pmm
	// if we're shooting blind and we still can't see our enemy
	if ((blindfire) && (!visible(self, self.enemy)))
	{
		// and we have a valid blind_fire_target
		if (!self.monsterinfo.blind_fire_target)
			return;

		target = self.monsterinfo.blind_fire_target;
	}
	else
		target = self.enemy.e.s.origin;
	// pmm

	AngleVectors(self.e.s.angles, forward, right, up); // PGM
	start = M_ProjectFlashSource(self, monster_flash_offset[flash_number], forward, right);

	// PGM
	if (self.enemy !is null && !(flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_3))
	{
		float dist;

		aim = target - self.e.s.origin;
		dist = aim.length();

		// aim up if they're on the same level as me and far away.
		if ((dist > 512) && (aim[2] < 64) && (aim[2] > -64))
		{
			aim[2] += (dist - 512);
		}

		aim.normalize();
		pitch = aim[2];
		if (pitch > 0.4f)
			pitch = 0.4f;
		else if (pitch < -0.5f)
			pitch = -0.5f;

		if ((self.enemy.e.absmin.z - self.e.absmax.z) > 16.f && flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_3)
			pitch += 0.5f;
	}
	// PGM

	if (flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_FRONT_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_FRONT_3)
		pitch -= 0.05f;

	if (!(flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_3))
	{
		aim = forward + (right * spread);
		aim += (up * pitch);
		aim.normalize();
	}
	else
	{
		PredictAim(self, self.enemy, start, 800, false, 0.f, aim);
		aim += right * spread;
		aim.normalize();
	}

	if (flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_CROUCH_3)
	{
		const float inner_spread = 0.125f;

		for (int i = 0; i < 3; i++)
			fire_ionripper(self, start, aim + (right * (-(inner_spread * 2) + (inner_spread * (i + 1)))), 15, 800, effects_t::IONRIPPER);

		monster_muzzleflash(self, start, flash_number);
	}
	else
	{
		// mortar fires farther
		int speed;
		
		if (flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_3)
			speed = MORTAR_SPEED;
		else
			speed = GRENADE_SPEED;

		// try search for best pitch
		if (M_CalculatePitchToFire(self, target, start, aim, speed, 2.5f, (flash_number >= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1 && flash_number <= monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_3)))
			monster_fire_grenade(self, start, aim, 50, speed, flash_number, (crandom_open() * 10.0f), frandom() * 10.f);
		else
			// normal shot
			monster_fire_grenade(self, start, aim, 50, speed, flash_number, (crandom_open() * 10.0f), 200.f + (crandom_open() * 10.0f));
	}
}

const array<mframe_t> guncmdr_frames_attack_mortar = {
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerCmdrGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, GunnerCmdrGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	mframe_t(ai_charge, 0, GunnerCmdrGrenade),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_duck_up),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge)
};
const mmove_t guncmdr_move_attack_mortar = mmove_t(gunner::frames::c_attack201, gunner::frames::c_attack221, guncmdr_frames_attack_mortar, guncmdr_run);

void guncmdr_grenade_mortar_resume(ASEntity &self)
{
	M_SetAnimation(self, guncmdr_move_attack_mortar);
	self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
	self.e.s.frame = self.count;
}

const array<mframe_t> guncmdr_frames_attack_mortar_dodge = {
	mframe_t(ai_charge, 11.f),
	mframe_t(ai_charge, 12.f),
	mframe_t(ai_charge, 16.f),
	mframe_t(ai_charge, 16.f),
	mframe_t(ai_charge, 12.f),
	mframe_t(ai_charge, 11.f)
};
const mmove_t guncmdr_move_attack_mortar_dodge = mmove_t(gunner::frames::c_duckstep01, gunner::frames::c_duckstep06, guncmdr_frames_attack_mortar_dodge, guncmdr_grenade_mortar_resume);

const array<mframe_t> guncmdr_frames_attack_back = {
	//mframe_t(ai_charge),
	mframe_t(ai_charge, -2.f),
	mframe_t(ai_charge, -1.5f),
	mframe_t(ai_charge, -0.5f, GunnerCmdrGrenade),
	mframe_t(ai_charge, -6.0f),
	mframe_t(ai_charge, -4.f),
	mframe_t(ai_charge, -2.5f, GunnerCmdrGrenade),
	mframe_t(ai_charge, -7.0f),
	mframe_t(ai_charge, -3.5f),
	mframe_t(ai_charge, -1.1f, GunnerCmdrGrenade),

	mframe_t(ai_charge, -4.6f),
	mframe_t(ai_charge, 1.9f),
	mframe_t(ai_charge, 1.0f),
	mframe_t(ai_charge, -4.5f),
	mframe_t(ai_charge, 3.2f),
	mframe_t(ai_charge, 4.4f),
	mframe_t(ai_charge, -6.5f),
	mframe_t(ai_charge, -6.1f),
	mframe_t(ai_charge, 3.0f),
	mframe_t(ai_charge, -0.7f),
	mframe_t(ai_charge, -1.0f)
};
const mmove_t guncmdr_move_attack_grenade_back = mmove_t(gunner::frames::c_attack302, gunner::frames::c_attack321, guncmdr_frames_attack_back, guncmdr_run);

void guncmdr_grenade_back_dodge_resume(ASEntity &self)
{
	M_SetAnimation(self, guncmdr_move_attack_grenade_back);
	self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
	self.e.s.frame = self.count;
}

const array<mframe_t> guncmdr_frames_attack_grenade_back_dodge_right = {
	mframe_t(ai_charge, 5.1f * 2.0f),
	mframe_t(ai_charge, 9.0f * 2.0f),
	mframe_t(ai_charge, 3.5f * 2.0f),
	mframe_t(ai_charge, 3.6f * 2.0f),
	mframe_t(ai_charge, -1.0f * 2.0f)
};
const mmove_t guncmdr_move_attack_grenade_back_dodge_right = mmove_t(gunner::frames::c_attack601, gunner::frames::c_attack605, guncmdr_frames_attack_grenade_back_dodge_right, guncmdr_grenade_back_dodge_resume);

const array<mframe_t> guncmdr_frames_attack_grenade_back_dodge_left = {
	mframe_t(ai_charge, 5.1f * 2.0f),
	mframe_t(ai_charge, 9.0f * 2.0f),
	mframe_t(ai_charge, 3.5f * 2.0f),
	mframe_t(ai_charge, 3.6f * 2.0f),
	mframe_t(ai_charge, -1.0f * 2.0f)
};
const mmove_t guncmdr_move_attack_grenade_back_dodge_left = mmove_t(gunner::frames::c_attack701, gunner::frames::c_attack705, guncmdr_frames_attack_grenade_back_dodge_left, guncmdr_grenade_back_dodge_resume);

void guncmdr_kick_finished(ASEntity &self)
{
	self.monsterinfo.melee_debounce_time = level.time + time_sec(3);
	self.monsterinfo.attack(self);
}

void guncmdr_kick(ASEntity &self)
{
	if (fire_hit(self, vec3_t(MELEE_DISTANCE, 0.f, -32.f), 15.f, 400.f))
	{
		if (self.enemy !is null && self.enemy.client !is null && self.enemy.velocity.z < 270.f)
			self.enemy.velocity.z = 270.f;
	}
}

const array<mframe_t> guncmdr_frames_attack_kick = {
	mframe_t(ai_charge, -7.7f),
	mframe_t(ai_charge, -4.9f),
	mframe_t(ai_charge, 12.6f, guncmdr_kick),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -3.0f),
	mframe_t(ai_charge),
	mframe_t(ai_charge, -4.1f),
	mframe_t(ai_charge, 8.6f),
	//mframe_t(ai_charge, -3.5f)
};
const mmove_t guncmdr_move_attack_kick = mmove_t(gunner::frames::c_attack801, gunner::frames::c_attack808, guncmdr_frames_attack_kick, guncmdr_kick_finished);

// don't ever try grenades if we get this close
const float RANGE_GRENADE = 100.f;

// always use mortar at this range
const float RANGE_GRENADE_MORTAR = 525.f;

// at this range, run towards the enemy
const float RANGE_CHAINGUN_RUN = 400.f;

void guncmdr_attack(ASEntity &self)
{
	monster_done_dodge(self);

	float d = range_to(self, self.enemy);

	vec3_t forward, right, aim;
	AngleVectors(self.e.s.angles, forward, right); // PGM

    aim = (self.enemy.e.s.origin - self.e.s.origin).normalized();

	// always use chaingun on tesla
	// kick close enemies
	if (self.bad_area is null && d < RANGE_MELEE && self.monsterinfo.melee_debounce_time < level.time)
		M_SetAnimation(self, guncmdr_move_attack_kick);
	else if (self.bad_area !is null || ((d <= RANGE_GRENADE || brandom()) && M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNCMDR_CHAINGUN_1])))
		M_SetAnimation(self, guncmdr_move_attack_chain);
	else if ((d >= RANGE_GRENADE_MORTAR ||
			abs(self.e.absmin.z - self.enemy.e.absmax.z) > 64.f // enemy is far below or above us, always try mortar
			) && M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1]) &&
			M_CalculatePitchToFire(self, self.enemy.e.s.origin, M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::GUNCMDR_GRENADE_MORTAR_1], forward, right),
				aim, MORTAR_SPEED, 2.5f, true)
		)
	{
		M_SetAnimation(self, guncmdr_move_attack_mortar);
		monster_duck_down(self);
	}
	else if (M_CheckClearShot(self, monster_flash_offset[monster_muzzle_t::GUNCMDR_GRENADE_FRONT_1]) && (self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0 &&
			M_CalculatePitchToFire(self, self.enemy.e.s.origin, M_ProjectFlashSource(self, monster_flash_offset[monster_muzzle_t::GUNCMDR_GRENADE_FRONT_1], forward, right),
				aim, GRENADE_SPEED, 2.5f, false))
		M_SetAnimation(self, guncmdr_move_attack_grenade_back);
	else if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, guncmdr_move_attack_chain);
}

void guncmdr_fire_chain(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0 && self.enemy !is null &&
        range_to(self, self.enemy) > RANGE_CHAINGUN_RUN && ai_check_move(self, 8.0f))
		M_SetAnimation(self, guncmdr_move_fire_chain_run);
	else
		M_SetAnimation(self, guncmdr_move_fire_chain);
}

void guncmdr_refire_chain(ASEntity &self)
{
	monster_done_dodge(self);
	self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;

	if (self.enemy.health > 0)
		if (visible(self, self.enemy))
			if (frandom() <= 0.5f)
			{
				if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0 && self.enemy !is null && range_to(self, self.enemy) > RANGE_CHAINGUN_RUN && ai_check_move(self, 8.0f))
					M_SetAnimation(self, guncmdr_move_fire_chain_run, false);
				else
					M_SetAnimation(self, guncmdr_move_fire_chain, false);
				return;
			}
	M_SetAnimation(self, guncmdr_move_endfire_chain, false);
}

//===========
// PGM
void guncmdr_jump_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 100);
	self.velocity += (up * 300);
}

void guncmdr_jump2_now(ASEntity &self)
{
	vec3_t forward, up;

	AngleVectors(self.e.s.angles, forward, up: up);
	self.velocity += (forward * 150);
	self.velocity += (up * 400);
}

void guncmdr_jump_wait_land(ASEntity &self)
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

const array<mframe_t> guncmdr_frames_jump = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, guncmdr_jump_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, guncmdr_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_jump = mmove_t(gunner::frames::c_jump01, gunner::frames::c_jump10, guncmdr_frames_jump, guncmdr_run);

const array<mframe_t> guncmdr_frames_jump2 = {
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, 0, guncmdr_jump2_now),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 0, guncmdr_jump_wait_land),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move)
};
const mmove_t guncmdr_move_jump2 = mmove_t(gunner::frames::c_jump01, gunner::frames::c_jump10, guncmdr_frames_jump2, guncmdr_run);

void guncmdr_jump(ASEntity &self, blocked_jump_result_t result)
{
	if (self.enemy is null)
		return;

	monster_done_dodge(self);

	if (result == blocked_jump_result_t::JUMP_JUMP_UP)
		M_SetAnimation(self, guncmdr_move_jump2);
	else
		M_SetAnimation(self, guncmdr_move_jump);
}

void GunnerCmdrCounter(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::BERSERK_SLAM);
	vec3_t f, r, start;
	AngleVectors(self.e.s.angles, f, r);
	start = M_ProjectFlashSource(self, { 20.f, 0.f, 14.f }, f, r);
	trace_t tr = gi_traceline(self.e.s.origin, start, self.e, contents_t::MASK_SOLID);
	gi_WritePosition(tr.endpos);
	gi_WriteDir(f);
	gi_multicast(tr.endpos, multicast_t::PHS, false);

	T_SlamRadiusDamage(tr.endpos, self, self, 15, 250.f, self, 200.f, mod_id_t::UNKNOWN);
}

//===========
// PGM
const array<mframe_t> guncmdr_frames_duck_attack = {
	mframe_t(ai_move, 3.6f),
	mframe_t(ai_move, 5.6f, monster_duck_down),
	mframe_t(ai_move, 8.4f),
	mframe_t(ai_move, 2.0f, monster_duck_hold),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),
	mframe_t(ai_charge),

	//mframe_t(ai_charge, 0, GunnerCmdrGrenade),
	//mframe_t(ai_charge, 9.5f, GunnerCmdrGrenade),
	//mframe_t(ai_charge, -1.5f, GunnerCmdrGrenade),
	
	mframe_t(ai_charge, 0),
	mframe_t(ai_charge, 9.5f, GunnerCmdrCounter),
	mframe_t(ai_charge, -1.5f),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 0, monster_duck_up),
	mframe_t(ai_charge),
	mframe_t(ai_charge, 11.f),
	mframe_t(ai_charge, 2.0f),
	mframe_t(ai_charge, 5.6f)
};
const mmove_t guncmdr_move_duck_attack = mmove_t(gunner::frames::c_attack901, gunner::frames::c_attack919, guncmdr_frames_duck_attack, guncmdr_run);

bool guncmdr_duck(ASEntity &self, gtime_t eta)
{
	if ((self.monsterinfo.active_move is guncmdr_move_jump2) ||
		(self.monsterinfo.active_move is guncmdr_move_jump))
	{
		return false;
	}

	if ((self.monsterinfo.active_move is guncmdr_move_fire_chain_dodge_left) ||
		(self.monsterinfo.active_move is guncmdr_move_fire_chain_dodge_right) ||
		(self.monsterinfo.active_move is guncmdr_move_attack_grenade_back_dodge_left) ||
		(self.monsterinfo.active_move is guncmdr_move_attack_grenade_back_dodge_right) ||
		(self.monsterinfo.active_move is guncmdr_move_attack_mortar_dodge))
	{
		// if we're dodging, don't duck
		self.monsterinfo.unduck(self);
		return false;
	}

	M_SetAnimation(self, guncmdr_move_duck_attack);

	return true;
}

bool guncmdr_sidestep(ASEntity &self)
{
	// use special dodge during the main firing anim
	if (self.monsterinfo.active_move is guncmdr_move_fire_chain ||
		self.monsterinfo.active_move is guncmdr_move_fire_chain_run)
	{
		M_SetAnimation(self, !self.monsterinfo.lefty ? guncmdr_move_fire_chain_dodge_right : guncmdr_move_fire_chain_dodge_left, false);
		return true;
	}

	// for backwards mortar, back up where we are in the animation and do a quick dodge
	if (self.monsterinfo.active_move is guncmdr_move_attack_grenade_back)
	{
		self.count = self.e.s.frame;
		M_SetAnimation(self, !self.monsterinfo.lefty ? guncmdr_move_attack_grenade_back_dodge_right : guncmdr_move_attack_grenade_back_dodge_left, false);
		return true;
	}

	// use crouch-move for mortar dodge
	if (self.monsterinfo.active_move is guncmdr_move_attack_mortar)
	{
		self.count = self.e.s.frame;
		M_SetAnimation(self, guncmdr_move_attack_mortar_dodge, false);
		return true;
	}

	// regular sidestep during run
	if (self.monsterinfo.active_move is guncmdr_move_run)
	{
		M_SetAnimation(self, guncmdr_move_run, true);
		return true;
	}

	return false;
}

bool guncmdr_blocked(ASEntity &self, float dist)
{
	if (blocked_checkplat(self, dist))
		return true;
	
    auto result = blocked_checkjump(self, dist);

	if (result != blocked_jump_result_t::NO_JUMP)
	{
		if (result != blocked_jump_result_t::JUMP_TURN)
			guncmdr_jump(self, result);

		return true;
	}

	return false;
}
// PGM
//===========

/*QUAKED monster_guncmdr (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight NoJumping
model="models/monsters/guncmdr/tris.md2"
*/
void SP_monster_guncmdr(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	guncmdr::sounds::pain.precache();
	guncmdr::sounds::pain2.precache();
	guncmdr::sounds::death.precache();
	guncmdr::sounds::idle.precache();
	guncmdr::sounds::open.precache();
	guncmdr::sounds::search.precache();
	guncmdr::sounds::sight.precache();

	gi_soundindex("guncmdr/gcdratck2.wav");
	gi_soundindex("guncmdr/gcdratck3.wav");

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/gunner/tris.md2");
	
	gi_modelindex("models/monsters/gunner/gibs/chest.md2");
	gi_modelindex("models/monsters/gunner/gibs/foot.md2");
	gi_modelindex("models/monsters/gunner/gibs/garm.md2");
	gi_modelindex("models/monsters/gunner/gibs/gun.md2");
	gi_modelindex("models/monsters/gunner/gibs/head.md2");

	self.e.s.scale = 1.25f;
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, 36 };
	self.e.s.skinnum = 2;

	self.health = int(325 * st.health_multiplier);
	self.gib_health = -175;
	self.mass = 255;

	@self.pain = guncmdr_pain;
	@self.die = guncmdr_die;

	@self.monsterinfo.stand = guncmdr_stand;
	@self.monsterinfo.walk = guncmdr_walk;
	@self.monsterinfo.run = guncmdr_run;
	// pmm
	@self.monsterinfo.dodge = M_MonsterDodge;
	@self.monsterinfo.duck = guncmdr_duck;
	@self.monsterinfo.unduck = monster_duck_up;
	@self.monsterinfo.sidestep = guncmdr_sidestep;
	@self.monsterinfo.blocked = guncmdr_blocked; // PGM
	// pmm
	@self.monsterinfo.attack = guncmdr_attack;
	@self.monsterinfo.melee = null;
	@self.monsterinfo.sight = guncmdr_sight;
	@self.monsterinfo.search = guncmdr_search;
	@self.monsterinfo.setskin = guncmdr_setskin;

	gi_linkentity(self.e);

	M_SetAnimation(self, guncmdr_move_stand);
	self.monsterinfo.scale = gunner::SCALE;

	if (!st.was_key_specified("power_armor_power"))
		self.monsterinfo.power_armor_power = 200;
	if (!st.was_key_specified("power_armor_type"))
		self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SHIELD;

	// PMM
	//self.monsterinfo.blindfire = true;
	self.monsterinfo.can_jump = (self.spawnflags & spawnflags::guncmdr::NOJUMPING) == 0;
	self.monsterinfo.drop_height = 192;
	self.monsterinfo.jump_height = 40;

	walkmonster_start(self);
}
