// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.
/*
==============================================================================

hover

==============================================================================
*/

namespace hover
{
    enum frames
    {
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
        forwrd01,
        forwrd02,
        forwrd03,
        forwrd04,
        forwrd05,
        forwrd06,
        forwrd07,
        forwrd08,
        forwrd09,
        forwrd10,
        forwrd11,
        forwrd12,
        forwrd13,
        forwrd14,
        forwrd15,
        forwrd16,
        forwrd17,
        forwrd18,
        forwrd19,
        forwrd20,
        forwrd21,
        forwrd22,
        forwrd23,
        forwrd24,
        forwrd25,
        forwrd26,
        forwrd27,
        forwrd28,
        forwrd29,
        forwrd30,
        forwrd31,
        forwrd32,
        forwrd33,
        forwrd34,
        forwrd35,
        stop101,
        stop102,
        stop103,
        stop104,
        stop105,
        stop106,
        stop107,
        stop108,
        stop109,
        stop201,
        stop202,
        stop203,
        stop204,
        stop205,
        stop206,
        stop207,
        stop208,
        takeof01,
        takeof02,
        takeof03,
        takeof04,
        takeof05,
        takeof06,
        takeof07,
        takeof08,
        takeof09,
        takeof10,
        takeof11,
        takeof12,
        takeof13,
        takeof14,
        takeof15,
        takeof16,
        takeof17,
        takeof18,
        takeof19,
        takeof20,
        takeof21,
        takeof22,
        takeof23,
        takeof24,
        takeof25,
        takeof26,
        takeof27,
        takeof28,
        takeof29,
        takeof30,
        land01,
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
        pain112,
        pain113,
        pain114,
        pain115,
        pain116,
        pain117,
        pain118,
        pain119,
        pain120,
        pain121,
        pain122,
        pain123,
        pain124,
        pain125,
        pain126,
        pain127,
        pain128,
        pain201,
        pain202,
        pain203,
        pain204,
        pain205,
        pain206,
        pain207,
        pain208,
        pain209,
        pain210,
        pain211,
        pain212,
        pain301,
        pain302,
        pain303,
        pain304,
        pain305,
        pain306,
        pain307,
        pain308,
        pain309,
        death101,
        death102,
        death103,
        death104,
        death105,
        death106,
        death107,
        death108,
        death109,
        death110,
        death111,
        backwd01,
        backwd02,
        backwd03,
        backwd04,
        backwd05,
        backwd06,
        backwd07,
        backwd08,
        backwd09,
        backwd10,
        backwd11,
        backwd12,
        backwd13,
        backwd14,
        backwd15,
        backwd16,
        backwd17,
        backwd18,
        backwd19,
        backwd20,
        backwd21,
        backwd22,
        backwd23,
        backwd24,
        attak101,
        attak102,
        attak103,
        attak104,
        attak105,
        attak106,
        attak107,
        attak108
    };

    const float SCALE = 1.000000f;
}

namespace hover::sounds
{
    cached_soundindex pain1("hover/hovpain1.wav");
    cached_soundindex pain2("hover/hovpain2.wav");
    cached_soundindex death1("hover/hovdeth1.wav");
    cached_soundindex death2("hover/hovdeth2.wav");
    cached_soundindex sight("hover/hovsght1.wav");
    cached_soundindex search1("hover/hovsrch1.wav");
    cached_soundindex search2("hover/hovsrch2.wav");
}

namespace daedalus::sounds
{
    // ROGUE
    // daedalus sounds
    cached_soundindex pain1("daedalus/daedpain1.wav");
    cached_soundindex pain2("daedalus/daedpain2.wav");
    cached_soundindex death1("daedalus/daeddeth1.wav");
    cached_soundindex death2("daedalus/daeddeth2.wav");
    cached_soundindex sight("daedalus/daedsght1.wav");
    cached_soundindex search1("daedalus/daedsrch1.wav");
    cached_soundindex search2("daedalus/daedsrch2.wav");
    // ROGUE
}

void hover_sight(ASEntity &self, ASEntity &other)
{
	// PMM - daedalus sounds
	if (self.mass < 225)
		gi_sound(self.e, soundchan_t::VOICE, hover::sounds::sight, 1, ATTN_NORM, 0);
	else
		gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::sight, 1, ATTN_NORM, 0);
}

void hover_search(ASEntity &self)
{
	// PMM - daedalus sounds
	if (self.mass < 225)
	{
		if (frandom() < 0.5f)
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::search1, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::search2, 1, ATTN_NORM, 0);
	}
	else
	{
		if (frandom() < 0.5f)
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::search1, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::search2, 1, ATTN_NORM, 0);
	}
}

const array<mframe_t> hover_frames_stand = {
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
const mmove_t hover_move_stand = mmove_t(hover::frames::stand01, hover::frames::stand30, hover_frames_stand, null);

const array<mframe_t> hover_frames_pain3 = {
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
const mmove_t hover_move_pain3 = mmove_t(hover::frames::pain301, hover::frames::pain309, hover_frames_pain3, hover_run);

const array<mframe_t> hover_frames_pain2 = {
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
const mmove_t hover_move_pain2 = mmove_t(hover::frames::pain201, hover::frames::pain212, hover_frames_pain2, hover_run);

const array<mframe_t> hover_frames_pain1 = {
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, -8),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -6),
	mframe_t(ai_move, -4),
	mframe_t(ai_move, -3),
	mframe_t(ai_move, 1),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 1),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 2),
	mframe_t(ai_move, 7),
	mframe_t(ai_move, 1),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 2),
	mframe_t(ai_move),
	mframe_t(ai_move),
	mframe_t(ai_move, 5),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 4)
};
const mmove_t hover_move_pain1 = mmove_t(hover::frames::pain101, hover::frames::pain128, hover_frames_pain1, hover_run);

const array<mframe_t> hover_frames_walk = {
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4),
	mframe_t(ai_walk, 4)
};
const mmove_t hover_move_walk = mmove_t(hover::frames::forwrd01, hover::frames::forwrd35, hover_frames_walk, null);

const array<mframe_t> hover_frames_run = {
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10),
	mframe_t(ai_run, 10)
};
const mmove_t hover_move_run = mmove_t(hover::frames::forwrd01, hover::frames::forwrd35, hover_frames_run, null);

void hover_gib(ASEntity &self)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::EXPLOSION1);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	self.e.s.skinnum /= 2;

	ThrowGibs(self, 150, {
		gib_def_t(2, "models/objects/gibs/sm_meat/tris.md2"),
		gib_def_t(2, "models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC),
		gib_def_t("models/monsters/hover/gibs/chest.md2", gib_type_t::SKINNED),
		gib_def_t(2, "models/monsters/hover/gibs/ring.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::METALLIC)),
		gib_def_t(2, "models/monsters/hover/gibs/foot.md2", gib_type_t::SKINNED),
		gib_def_t("models/monsters/hover/gibs/head.md2", gib_type_t(gib_type_t::SKINNED | gib_type_t::HEAD))
	});
}

void hover_deadthink(ASEntity &self)
{
	if (self.groundentity is null && level.time < self.timestamp)
	{
		self.nextthink = level.time + FRAME_TIME_S;
		return;
	}

	hover_gib(self);
}

void hover_dying(ASEntity &self)
{
	if (self.groundentity !is null)
	{
		hover_deadthink(self);
		return;
	}

	if (brandom())
		return;

	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::PLAIN_EXPLOSION);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	if (brandom())
		ThrowGibs(self, 120, {
			gib_def_t("models/objects/gibs/sm_meat/tris.md2")
		});
	else
		ThrowGibs(self, 120, {
			gib_def_t("models/objects/gibs/sm_metal/tris.md2", gib_type_t::METALLIC)
		});
}

const array<mframe_t> hover_frames_death1 = {
	mframe_t(ai_move),
	mframe_t(ai_move, 0.f, hover_dying),
	mframe_t(ai_move),
	mframe_t(ai_move, 0.f, hover_dying),
	mframe_t(ai_move),
	mframe_t(ai_move, 0.f, hover_dying),
	mframe_t(ai_move, -10, hover_dying),
	mframe_t(ai_move, 3),
	mframe_t(ai_move, 5, hover_dying),
	mframe_t(ai_move, 4, hover_dying),
	mframe_t(ai_move, 7)
};
const mmove_t hover_move_death1 = mmove_t(hover::frames::death101, hover::frames::death111, hover_frames_death1, hover_dead);

const array<mframe_t> hover_frames_start_attack = {
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 1)
};
const mmove_t hover_move_start_attack = mmove_t(hover::frames::attak101, hover::frames::attak103, hover_frames_start_attack, hover_attack);

const array<mframe_t> hover_frames_attack1 = {
	mframe_t(ai_charge, -10, hover_fire_blaster),
	mframe_t(ai_charge, -10, hover_fire_blaster),
	mframe_t(ai_charge, 0, hover_reattack),
};
const mmove_t hover_move_attack1 = mmove_t(hover::frames::attak104, hover::frames::attak106, hover_frames_attack1, null);

const array<mframe_t> hover_frames_end_attack = {
	mframe_t(ai_charge, 1),
	mframe_t(ai_charge, 1)
};
const mmove_t hover_move_end_attack = mmove_t(hover::frames::attak107, hover::frames::attak108, hover_frames_end_attack, hover_run);

/* PMM - circle strafing code */
/*
const array<mframe_t> hover_frames_start_attack2 = {
	mframe_t(ai_charge, 15),
	mframe_t(ai_charge, 15),
	mframe_t(ai_charge, 15)
};
const mmove_t hover_move_start_attack2 = mmove_t(hover::frames::attak101, hover::frames::attak103, hover_frames_start_attack2, hover_attack);
*/

const array<mframe_t> hover_frames_attack2 = {
	mframe_t(ai_charge, 10, hover_fire_blaster),
	mframe_t(ai_charge, 10, hover_fire_blaster),
	mframe_t(ai_charge, 10, hover_reattack),
};
const mmove_t hover_move_attack2 = mmove_t(hover::frames::attak104, hover::frames::attak106, hover_frames_attack2, null);

/*
const array<mframe_t> hover_frames_end_attack2 = {
	mframe_t(ai_charge, 15),
	mframe_t(ai_charge, 15)
};
const mmove_t hover_move_end_attack2 = mmove_t(hover::frames::attak107, hover::frames::attak108, hover_frames_end_attack2, hover_run);
*/

// end of circle strafe

void hover_reattack(ASEntity &self)
{
	if (self.enemy.health > 0)
		if (visible(self, self.enemy))
			if (frandom() <= 0.6f)
			{
				if (self.monsterinfo.attack_state == ai_attack_state_t::STRAIGHT)
				{
					M_SetAnimation(self, hover_move_attack1);
					return;
				}
				else if (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING)
				{
					M_SetAnimation(self, hover_move_attack2);
					return;
				}
				else
					gi_Com_Print("hover_reattack: unexpected state {}\n", int(self.monsterinfo.attack_state));
			}
	M_SetAnimation(self, hover_move_end_attack);
}

void hover_fire_blaster(ASEntity &self)
{
	vec3_t	  start;
	vec3_t	  forward, right;
	vec3_t	  end;
	vec3_t	  dir;

	if (self.enemy is null || !self.enemy.e.inuse) // PGM
		return;								 // PGM

	AngleVectors(self.e.s.angles, forward, right);
	vec3_t o = monster_flash_offset[(self.e.s.frame & 1) != 0 ? monster_muzzle_t::HOVER_BLASTER_2 : monster_muzzle_t::HOVER_BLASTER_1];
	start = M_ProjectFlashSource(self, o, forward, right);

	end = self.enemy.e.s.origin;
	end[2] += self.enemy.viewheight;
	dir = end - start;
	dir.normalize();

	// PGM	- daedalus fires blaster2
	if (self.mass < 200)
		monster_fire_blaster(self, start, dir, 1, 1000, (self.e.s.frame & 1) != 0 ? monster_muzzle_t::HOVER_BLASTER_2 : monster_muzzle_t::HOVER_BLASTER_1, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::HYPERBLASTER);
	else
		monster_fire_blaster2(self, start, dir, 1, 1000, (self.e.s.frame & 1) != 0 ? monster_muzzle_t::DAEDALUS_BLASTER_2 : monster_muzzle_t::DAEDALUS_BLASTER, (self.e.s.frame % 4) != 0 ? effects_t::NONE : effects_t::BLASTER);
	// PGM
}

void hover_stand(ASEntity &self)
{
	M_SetAnimation(self, hover_move_stand);
}

void hover_run(ASEntity &self)
{
	if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
		M_SetAnimation(self, hover_move_stand);
	else
		M_SetAnimation(self, hover_move_run);
}

void hover_walk(ASEntity &self)
{
	M_SetAnimation(self, hover_move_walk);
}

void hover_start_attack(ASEntity &self)
{
	M_SetAnimation(self, hover_move_start_attack);
}

void hover_attack(ASEntity &self)
{
	float chance = 0.5f;

	if (self.mass > 150) // the daedalus strafes more
		chance += 0.1f;

	if (frandom() > chance)
	{
		M_SetAnimation(self, hover_move_attack1);
		self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
	}
	else // circle strafe
	{
		if (frandom() <= 0.5f) // switch directions
			self.monsterinfo.lefty = !self.monsterinfo.lefty;
		M_SetAnimation(self, hover_move_attack2);
		self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
	}
}

void hover_pain(ASEntity &self, ASEntity &other, float kick, int damage, const mod_t &in mod)
{
	if (level.time < self.pain_debounce_time)
		return;

	self.pain_debounce_time = level.time + time_sec(3);

	float r = frandom();

	//====
	if (r < 0.5f)
	{
		// PMM - daedalus sounds
		if (self.mass < 225)
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::pain1, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::pain1, 1, ATTN_NORM, 0);
	}
	else
	{
		// PMM - daedalus sounds
		if (self.mass < 225)
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::pain2, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::pain2, 1, ATTN_NORM, 0);
	}
	// PGM
	//====

	if (!M_ShouldReactToPain(self, mod))
		return; // no pain anims in nightmare

	r = frandom();

	if (damage <= 25)
	{
		if (r < 0.5f)
			M_SetAnimation(self, hover_move_pain3);
		else
			M_SetAnimation(self, hover_move_pain2);
	}
	else
	{
		//====
		// PGM pain sequence is WAY too long
		if (r < 0.3f)
			M_SetAnimation(self, hover_move_pain1);
		else
			M_SetAnimation(self, hover_move_pain2);
		// PGM
		//====
	}
}

void hover_setskin(ASEntity &self)
{
	if (self.health < (self.max_health / 2))
		self.e.s.skinnum |= 1; // PGM support for skins 2 & 3.
	else
		self.e.s.skinnum &= ~1; // PGM support for skins 2 & 3.
}

void hover_dead(ASEntity &self)
{
	self.e.mins = { -16, -16, -24 };
	self.e.maxs = { 16, 16, -8 };
	self.movetype = movetype_t::TOSS;
	@self.think = hover_deadthink;
	self.nextthink = level.time + FRAME_TIME_S;
	self.timestamp = level.time + time_sec(15);
	gi_linkentity(self.e);
}

void hover_die(ASEntity &self, ASEntity &inflictor, ASEntity &attacker, int damage, const vec3_t &in point, const mod_t &in mod)
{
	self.e.s.effects = effects_t::NONE;
	self.monsterinfo.power_armor_type = item_id_t::NULL;

	if (M_CheckGib(self, mod))
	{
		hover_gib(self);
		return;
	}

	if (self.deadflag)
		return;

	// regular death
	// PMM - daedalus sounds
	if (self.mass < 225)
	{
		if (frandom() < 0.5f)
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::death1, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, hover::sounds::death2, 1, ATTN_NORM, 0);
	}
	else
	{
		if (frandom() < 0.5f)
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::death1, 1, ATTN_NORM, 0);
		else
			gi_sound(self.e, soundchan_t::VOICE, daedalus::sounds::death2, 1, ATTN_NORM, 0);
	}
	self.deadflag = true;
	self.takedamage = true;
	M_SetAnimation(self, hover_move_death1);
}

void hover_set_fly_parameters(ASEntity &self)
{
	self.monsterinfo.fly_thrusters = false;
	self.monsterinfo.fly_acceleration = 20.f;
	self.monsterinfo.fly_speed = 120.f;
	// Icarus prefers to keep its distance, but flies slower than the flyer.
	// he never pins because of this.
	self.monsterinfo.fly_min_distance = 250.f;
	self.monsterinfo.fly_max_distance = 450.f;
}

/*QUAKED monster_hover (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
 */
/*QUAKED monster_daedalus (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn Sight
This is the improved icarus monster.
*/
void SP_monster_hover(ASEntity &self)
{
	const spawn_temp_t @st = ED_GetSpawnTemp();

	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.e.s.modelindex = gi_modelindex("models/monsters/hover/tris.md2");

	gi_modelindex("models/monsters/hover/gibs/chest.md2");
	gi_modelindex("models/monsters/hover/gibs/foot.md2");
	gi_modelindex("models/monsters/hover/gibs/head.md2");
	gi_modelindex("models/monsters/hover/gibs/ring.md2");

	self.e.mins = { -24, -24, -24 };
	self.e.maxs = { 24, 24, 32 };

	self.health = int(240 * st.health_multiplier);
	self.gib_health = -100;
	self.mass = 150;

	@self.pain = hover_pain;
	@self.die = hover_die;

	@self.monsterinfo.stand = hover_stand;
	@self.monsterinfo.walk = hover_walk;
	@self.monsterinfo.run = hover_run;
	@self.monsterinfo.attack = hover_start_attack;
	@self.monsterinfo.sight = hover_sight;
	@self.monsterinfo.search = hover_search;
	@self.monsterinfo.setskin = hover_setskin;

	// PGM
	if (self.classname == "monster_daedalus")
	{
		self.health = int(450 * st.health_multiplier);
		self.mass = 225;
		self.yaw_speed = 23;
		if (!st.was_key_specified("power_armor_type"))
			self.monsterinfo.power_armor_type = item_id_t::ITEM_POWER_SCREEN;
		if (!st.was_key_specified("power_armor_power"))
			self.monsterinfo.power_armor_power = 100;
		// PMM - daedalus sounds
		self.monsterinfo.engine_sound = gi_soundindex("daedalus/daedidle1.wav");
		daedalus::sounds::pain1.precache();
		daedalus::sounds::pain2.precache();
		daedalus::sounds::death1.precache();
		daedalus::sounds::death2.precache();
		daedalus::sounds::sight.precache();
		daedalus::sounds::search1.precache();
		daedalus::sounds::search2.precache();
		gi_soundindex("tank/tnkatck3.wav");
		// pmm
	}
	else
	{
		self.yaw_speed = 18;
		hover::sounds::pain1.precache();
		hover::sounds::pain2.precache();
		hover::sounds::death1.precache();
		hover::sounds::death2.precache();
		hover::sounds::sight.precache();
		hover::sounds::search1.precache();
		hover::sounds::search2.precache();
		gi_soundindex("hover/hovatck1.wav");

		self.monsterinfo.engine_sound = gi_soundindex("hover/hovidle1.wav");
	}
	// PGM

	gi_linkentity(self.e);

	M_SetAnimation(self, hover_move_stand);
	self.monsterinfo.scale = hover::SCALE;

	flymonster_start(self);

	// PGM
	if (self.classname == "monster_daedalus")
		self.e.s.skinnum = 2;
	// PGM

	self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::ALTERNATE_FLY);
	hover_set_fly_parameters(self);
}
