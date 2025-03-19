ASEntity @monster_fakegoal = null;

bool    enemy_vis;
bool    enemy_infront;
float   enemy_yaw;

// ROGUE
const float MAX_SIDESTEP = 8.0f;
// ROGUE

//============================================================================

class active_players_t
{
    uint opForBegin() const
    {
        for (uint i = 1; i <= max_clients; i++)
        {
            ASEntity @e = entities[i];

            if (e.e.inuse && e.client !is null && e.client.pers.connected)
                return i;
        }

        return max_clients + 1;
    }

    bool opForEnd(uint i) const
    {
        return i > max_clients;
    }

    uint opForNext(uint i) const
    {
        for (i = i + 1; i <= max_clients; i++)
        {
            ASEntity @e = entities[i];

            if (e.e.inuse && e.client !is null && e.client.pers.connected)
                return i;
        }

        return max_clients + 1;
    }

    ASEntity @opForValue(uint i) const
    {
        return entities[i];
    }
}

active_players_t active_players;

/*
=================
AI_GetSightClient

For a given monster, check active players to see
who we can see. We don't care who we see, as long
as it's something we can shoot.
=================
*/
array<ASEntity @> sight_clients_visible_players;

ASEntity @AI_GetSightClient(ASEntity &self)
{
    if (level.intermissiontime)
        return null;

    foreach (ASEntity @player : active_players)
    {
        if (player.health <= 0 || player.deadflag || player.e.solid == solid_t::NOT)
            continue;
        else if (player.flags & (ent_flags_t::NOTARGET | ent_flags_t::DISGUISED) != 0)
            continue;

        // if we're touching them, allow to pass through
        if (!boxes_intersect(self.e.absmin, self.e.absmax, player.e.absmin, player.e.absmax))
        {
            if (((self.monsterinfo.aiflags & ai_flags_t::THIRD_EYE) == 0 && !infront(self, player)) || !visible(self, player))
                continue;
        }

        sight_clients_visible_players.push_back(player); // got one
    }

    if (sight_clients_visible_players.empty())
        return null;

    ASEntity @cl = sight_clients_visible_players[irandom(sight_clients_visible_players.length())];

    sight_clients_visible_players.resize(0);

    return cl;
}

//============================================================================

/*
=============
ai_move

Move the specified distance at current facing.
This replaces the QC functions: ai_forward, ai_back, ai_pain, and ai_painforward
==============
*/
void ai_move(ASEntity &self, float dist)
{
    M_walkmove(self, self.e.s.angles.yaw, dist);
}

/*
=============
ai_stand

Used for standing around and looking for players
Distance is for slight position adjustments needed by the animations
==============
*/
void ai_stand(ASEntity &self, float dist)
{
    vec3_t v;
    // ROGUE
    bool retval;
    // ROGUE

    if (dist != 0 || (self.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0)
        M_walkmove(self, self.e.s.angles.yaw, dist);

    if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
    {
        // [Paril-KEX] check if we've been pushed out of our point_combat
        if ((self.monsterinfo.aiflags & ai_flags_t::TEMP_STAND_GROUND) == 0 &&
            self.movetarget !is null && self.movetarget.classname == "point_combat")
        {
            if (!boxes_intersect(self.e.absmin, self.e.absmax, self.movetarget.e.absmin, self.movetarget.e.absmax))
            {
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::STAND_GROUND);
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::COMBAT_POINT);
                @self.goalentity = self.movetarget;
                self.monsterinfo.run(self);
                return;
            }
        }

        if (self.enemy !is null && (self.enemy.classname != "player_noise"))
        {
            v = self.enemy.e.s.origin - self.e.s.origin;
            self.ideal_yaw = vectoyaw(v);
            if (!FacingIdeal(self) && (self.monsterinfo.aiflags & ai_flags_t::TEMP_STAND_GROUND) != 0)
            {
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~(ai_flags_t::STAND_GROUND | ai_flags_t::TEMP_STAND_GROUND));
                self.monsterinfo.run(self);
            }
            // ROGUE
            if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
                // ROGUE
                M_ChangeYaw(self);
            // find out if we're going to be shooting
            retval = ai_checkattack(self, 0);
            // record sightings of player
            if (self.enemy !is null && (self.enemy.e.inuse))
            {
                if (visible(self, self.enemy))
                {
                    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);
                    self.monsterinfo.last_sighting = self.monsterinfo.saved_goal = self.enemy.e.s.origin;
                    self.monsterinfo.blind_fire_target = self.monsterinfo.last_sighting + (self.enemy.velocity * -0.1f);
                    self.monsterinfo.trail_time = level.time;
                    self.monsterinfo.blind_fire_delay = time_zero;
                }
                else
                {
                    if (FindTarget(self))
                        return;
                    
                    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::LOST_SIGHT);
                }

                // Paril: fixes rare cases of a stand ground monster being stuck
                // aiming at a sound target that they can still see
                if ((self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) != 0 && !retval)
                {
                    if (FindTarget(self))
                        return;
                }
            }
            // check retval to make sure we're not blindfiring
            else if (!retval)
            {
                FindTarget(self);
                return;
            }
            // ROGUE
        }
        else
            FindTarget(self);
        return;
    }

    // Paril: this fixes a bug somewhere else that sometimes causes
    // a monster to be given an enemy without ever calling HuntTarget.
    if (self.enemy !is null && (self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) == 0)
    {
        HuntTarget(self);
        return;
    }

    if (FindTarget(self))
        return;

    if (level.time > self.monsterinfo.pausetime)
    {
        self.monsterinfo.walk(self);
        return;
    }

    if (!(self.spawnflags.has(spawnflags::monsters::AMBUSH)) && self.monsterinfo.idle !is null &&
        (level.time > self.monsterinfo.idle_time))
    {
        if (self.monsterinfo.idle_time)
        {
            self.monsterinfo.idle(self);
            self.monsterinfo.idle_time = level.time + random_time(time_sec(15), time_sec(30));
        }
        else
        {
            self.monsterinfo.idle_time = level.time + random_time(time_sec(15));
        }
    }
}

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void ai_walk(ASEntity &self, float dist)
{
    ASEntity @temp_goal = null;

    if (self.goalentity is null && (self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
    {
        vec3_t fwd;
        AngleVectors(self.e.s.angles, fwd);

        if (monster_fakegoal is null)
            @monster_fakegoal = G_Spawn();

        @temp_goal = monster_fakegoal;
        temp_goal.e.s.origin = self.e.s.origin + fwd * 64;
        @self.goalentity = temp_goal;
    }

    M_MoveToGoal(self, dist);

    if (temp_goal !is null)
    {
        @self.goalentity = null;
    }

    // check for noticing a player
    if (FindTarget(self))
        return;

    if ((self.monsterinfo.search !is null) && (level.time > self.monsterinfo.idle_time))
    {
        if (self.monsterinfo.idle_time)
        {
            self.monsterinfo.search(self);
            self.monsterinfo.idle_time = level.time + random_time(time_sec(15), time_sec(30));
        }
        else
        {
            self.monsterinfo.idle_time = level.time + random_time(time_sec(15));
        }
    }
}

/*
=============
ai_charge

Turns towards target and advances
Use this call with a distance of 0 to replace ai_face
==============
*/
void ai_charge(ASEntity &self, float dist)
{
    vec3_t v;
    // ROGUE
    float ofs;

    // PMM - made AI_MANUAL_STEERING affect things differently here .. they turn, but
    // don't set the ideal_yaw

    // This is put in there so monsters won't move towards the origin after killing
    // a tesla. This could be problematic, so keep an eye on it.
    if (self.enemy is null || !self.enemy.e.inuse) // PGM
        return;                              // PGM

    // PMM - save blindfire target
    if (visible(self, self.enemy))
        self.monsterinfo.blind_fire_target = self.enemy.e.s.origin + (self.enemy.velocity * -0.1f);
    // pmm

    if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
    {
        // ROGUE
        v = self.enemy.e.s.origin - self.e.s.origin;
        self.ideal_yaw = vectoyaw(v);
        // ROGUE
    }
    // ROGUE
    M_ChangeYaw(self);

    if (dist != 0 || (self.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0)
    // ROGUE
    {
        if ((self.monsterinfo.aiflags & ai_flags_t::CHARGING) != 0)
        {
            M_MoveToGoal(self, dist);
            return;
        }
        // circle strafe support
        if (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING)
        {
            // if we're fighting a tesla, NEVER circle strafe
            if (self.enemy !is null && (self.enemy.classname == "tesla_mine"))
                ofs = 0;
            else if (self.monsterinfo.lefty)
                ofs = 90;
            else
                ofs = -90;

            dist *= self.monsterinfo.active_move.sidestep_scale;

            if (M_walkmove(self, self.ideal_yaw + ofs, dist))
                return;

            self.monsterinfo.lefty = !self.monsterinfo.lefty;
            M_walkmove(self, self.ideal_yaw - ofs, dist);
        }
        else
            // ROGUE
            M_walkmove(self, self.e.s.angles.yaw, dist);
        // ROGUE
    }
    // ROGUE

    // [Paril-KEX] if our enemy is literally right next to us, give
    // us more rotational speed so we don't get circled
    if (range_to(self, self.enemy) <= RANGE_MELEE * 2.5f)
        M_ChangeYaw(self);
}

const float RANGE_MELEE = 20; // bboxes basically touching
const float RANGE_NEAR = 440;
const float RANGE_MID = 940;

// [Paril-KEX] adjusted to return an actual distance, measured
// in a way that is consistent regardless of what is fighting what
float range_to(ASEntity &self, ASEntity &other)
{
    return distance_between_boxes(self.e.absmin, self.e.absmax, other.e.absmin, other.e.absmax);
}

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
bool visible(ASEntity &self, ASEntity &other, bool through_glass = true)
{
    // never visible
    if ((other.flags & ent_flags_t::NOVISIBLE) != 0)
        return false;

    // [Paril-KEX] bit of a hack, but we'll tweak monster-player visibility
    // if they have the invisibility powerup.
    if (other.client !is null)
    {
        // always visible in rtest
        if ((self.hackflags & HACKFLAG_ATTACK_PLAYER) != 0)
            return self.e.inuse;

        // fix intermission
        if (other.e.solid == solid_t::NOT)
            return false;

        if (other.client.invisible_time > level.time)
        {
            // can't see us at all after this time
            if (other.client.invisibility_fade_time <= level.time)
                return false;

            // otherwise, throw in some randomness
            if (frandom() > other.e.s.alpha)
                return false;
        }
    }

    vec3_t  spot1;
    vec3_t  spot2;
    trace_t trace;

    spot1 = self.e.s.origin;
    spot1.z += self.viewheight;
    spot2 = other.e.s.origin;
    spot2.z += other.viewheight;

    contents_t mask = contents_t(contents_t::MASK_OPAQUE | contents_t::PROJECTILECLIP);

    if (!through_glass)
        mask = contents_t(mask | contents_t::WINDOW);

    trace = gi_traceline(spot1, spot2, self.e, mask);
    return trace.fraction == 1.0f || trace.ent is other.e; // PGM
}

/*
============
FacingIdeal

============
*/
bool FacingIdeal(ASEntity &self)
{
    float delta = anglemod(self.e.s.angles.yaw - self.ideal_yaw);

    if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) != 0)
        return !(delta > 5 && delta < 355);

    return !(delta > 45 && delta < 315);
}

/*
=============
infront_cone

returns 1 if the entity is in front (in sight) of self
=============
*/
bool infront_cone(ASEntity &self, ASEntity &other, float cone)
{
    vec3_t forward;

    AngleVectors(self.e.s.angles, forward);

    vec3_t vec = (other.e.s.origin - self.e.s.origin).normalized();

    return vec.dot(forward) > cone;
}

/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
bool infront(ASEntity &self, ASEntity &other)
{
    float cone = self.vision_cone;

    if (self.vision_cone < -1.0f)
    {
        // [Paril-KEX] if we're an ambush monster, reduce our cone of
        // vision to not ruin surprises, unless we already had an enemy.
        if (self.spawnflags.has(spawnflags::monsters::AMBUSH) && !self.monsterinfo.trail_time && self.enemy is null)
            cone = 0.15f;
        else
            cone = -0.30f;
    }

    return infront_cone(self, other, cone);
}

//============================================================================

void HuntTarget(ASEntity &self, bool animate_state = true)
{
    vec3_t vec;

    @self.goalentity = self.enemy;
    if (animate_state)
    {
        if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
            self.monsterinfo.stand(self);
        else
            self.monsterinfo.run(self);
    }
    vec = self.enemy.e.s.origin - self.e.s.origin;
    self.ideal_yaw = vectoyaw(vec);
}

void FoundTarget(ASEntity &self)
{
    // let other monsters see this monster for a while
    if (self.enemy.client !is null)
    {
        // ROGUE
        if ((self.enemy.flags & ent_flags_t::DISGUISED) != 0)
            self.enemy.flags = ent_flags_t(self.enemy.flags & ~ent_flags_t::DISGUISED);
        // ROGUE

        @self.enemy.client.sight_entity = self;
        self.enemy.client.sight_entity_time = level.time;

        self.enemy.show_hostile = level.time + time_sec(1); // wake up other monsters
    }

    // [Paril-KEX] the first time we spot something, give us a bit of a grace
    // period on firing
    if (!self.monsterinfo.trail_time)
        self.monsterinfo.attack_finished = level.time + time_ms(600);

    // give easy/medium a little more reaction time
    self.monsterinfo.attack_finished += skill.integer == 0 ? time_ms(400) : skill.integer == 1 ? time_ms(200) : time_zero;

    self.monsterinfo.last_sighting = self.monsterinfo.saved_goal = self.enemy.e.s.origin;
    self.monsterinfo.trail_time = level.time;
    // ROGUE
    self.monsterinfo.blind_fire_target = self.monsterinfo.last_sighting + (self.enemy.velocity * -0.1f);
    self.monsterinfo.blind_fire_delay = time_zero;
    // ROGUE
    // [Paril-KEX] for alternate fly, pick a new position immediately
    self.monsterinfo.fly_position_time = time_zero;

    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::THIRD_EYE);

    // Paril: if we're heading to a combat point/path corner, don't
    // hunt the new target yet.
    if ((self.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) != 0)
        return;

    if (self.combattarget.empty())
    {
        HuntTarget(self);
        return;
    }

    @self.goalentity = @self.movetarget = G_PickTarget(self.combattarget);
    if (self.movetarget is null)
    {
        @self.goalentity = @self.movetarget = self.enemy;
        HuntTarget(self);
        gi_Com_Print("{}: combattarget {} not found\n", self, self.combattarget);
        return;
    }

    // clear out our combattarget, these are a one shot deal
    self.combattarget = "";
    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::COMBAT_POINT);

    // clear the targetname, that point is ours!
    // [Paril-KEX] not any more, we can re-use them
    //self.movetarget.targetname = nullptr;
    self.monsterinfo.pausetime = time_zero;

    // run for it
    self.monsterinfo.run(self);
}

// [Paril-KEX] monsters that were alerted by players will
// be temporarily stored on player entities, so we can
// check them & get mad at them even around corners
ASEntity @AI_GetMonsterAlertedByPlayers(ASEntity &self)
{
    foreach (ASEntity @player : active_players)
    {
        // dead
        if (player.health <= 0 || player.deadflag || player.e.solid == solid_t::NOT)
            continue;

        // we didn't alert any other monster, or it wasn't recently
        if (player.client.sight_entity is null || !(player.client.sight_entity_time >= (level.time - FRAME_TIME_S)))
            continue;

        // if we can't see the monster, don't bother
        if (!visible(self, player.client.sight_entity))
            continue;

        // probably good
        return player.client.sight_entity;
    }
    
    return null;
}

// [Paril-KEX] per-player sounds
ASEntity @AI_GetSoundClient(ASEntity &self, bool direct)
{
    ASEntity @best_sound = null;
    float best_distance = 0;

    foreach (ASEntity @player : active_players)
    {
        // dead
        if (player.health <= 0 || player.deadflag || player.e.solid == solid_t::NOT)
            continue;

        ASEntity @sound = direct ? player.client.sound_entity : player.client.sound2_entity;

        if (sound is null)
            continue;

        // too late
        gtime_t time = direct ? player.client.sound_entity_time : player.client.sound2_entity_time;

        if (!(time >= (level.time - FRAME_TIME_S)))
            continue;

        // prefer the closest one we heard
        float dist = (self.e.s.origin - sound.e.s.origin).length();

        if (best_sound is null || dist < best_distance)
        {
            best_distance = dist;
            @best_sound = sound;
        }
    }

    return best_sound;
}

bool G_MonsterSourceVisible(ASEntity &self, ASEntity &client)
{
    // this is where we would check invisibility
    float r = range_to(self, client);

    if (r > RANGE_MID)
        return false;

    // Paril: revised so that monsters can be woken up
    // by players 'seen' and attacked at by other monsters
    // if they are close enough. they don't have to be visible.
    bool is_visible =
        ((r <= RANGE_NEAR && client.show_hostile >= level.time && !self.spawnflags.has(spawnflags::monsters::AMBUSH)) ||
            (visible(self, client) && (r <= RANGE_MELEE || (self.monsterinfo.aiflags & ai_flags_t::THIRD_EYE) != 0 || infront(self, client))));

    return is_visible;
}

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
bool FindTarget(ASEntity &self)
{
    ASEntity @client = null;
    bool     heardit;
    bool     ignore_sight_sound = false;

    // [Paril-KEX] if we're in a level transition, don't worry about enemies
    if ((server_flags & server_flags_t::LOADING) != 0)
        return false;

    // N64 cutscene behavior
    if ((self.hackflags & HACKFLAG_END_CUTSCENE) != 0)
        return false;

    if ((self.monsterinfo.aiflags & ai_flags_t::GOOD_GUY) != 0)
    {
        if (self.goalentity !is null && self.goalentity.e.inuse && !self.goalentity.classname.empty())
        {
            if (self.goalentity.classname == "target_actor")
                return false;
        }

        // FIXME look for monsters?
        return false;
    }

    // if we're going to a combat point, just proceed
    if ((self.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) != 0)
        return false;

    // if the first spawnflag bit is set, the monster will only wake up on
    // really seeing the player, not another monster getting angry or hearing
    // something

    // revised behavior so they will wake up if they "see" a player make a noise
    // but not weapon impact/explosion noises
    heardit = false;
    
    // Paril: revised so that monsters will first try to consider
    // the current sight client immediately if they can see it.
    // this fixes them dancing in front of you if you fire every frame.
    if ((@client = AI_GetSightClient(self)) !is null)
    {
        if (client is self.enemy)
        {
            return false;
        }
    }

    // check indirect sources
    if (client is null)
    {
        // check monsters that were alerted by players; we can only be alerted if we
        // can see them
        if (!(self.spawnflags.has(spawnflags::monsters::AMBUSH)) && (@client = AI_GetMonsterAlertedByPlayers(self)) !is null)
        {
            // KEX_FIXME: when does this happen? 
            // [Paril-KEX] adjusted to clear the client
            // so we can try other things
            if (client.enemy is self.enemy ||
                !G_MonsterSourceVisible(self, client))
                @client = null;
        }
        // ROGUE

        if (client is null)
        {
            if (level.disguise_violation_time > level.time)
            {
                @client = level.disguise_violator;
            }
            // ROGUE
            else if ((@client = AI_GetSoundClient(self, true)) !is null)
            {
                heardit = true;
            }
            else if ((self.enemy is null) && !(self.spawnflags.has(spawnflags::monsters::AMBUSH)) &&
                (@client = AI_GetSoundClient(self, false)) !is null)
            {
                heardit = true;
            }
        }
    }

    if (client is null)
        return false; // no clients to get mad at

    // if the entity went away, forget it
    if (!client.e.inuse)
        return false;

    if (client is self.enemy)
    {
        bool skip_found = true;

        // [Paril-KEX] slight special behavior if we are currently going to a sound
        // and we hear a new one; because player noises are re-used, this can leave
        // us with the "same" enemy even though it's a different noise.
        if (heardit && (self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) != 0)
        {
            vec3_t temp = client.e.s.origin - self.e.s.origin;
            self.ideal_yaw = vectoyaw(temp);

            if (!FacingIdeal(self))
                skip_found = false;
            else if (!SV_CloseEnough(self, client, 8.0f))
                skip_found = false;

            if (!skip_found && (self.monsterinfo.aiflags & ai_flags_t::TEMP_STAND_GROUND) != 0)
            {
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~(ai_flags_t::STAND_GROUND | ai_flags_t::TEMP_STAND_GROUND));
            }
        }

        if (skip_found)
            return true; // JDC false;
    }

    if ((client.e.svflags & svflags_t::MONSTER) != 0)
    {
        if (client.enemy is null)
            return false;
        if ((client.enemy.flags & ent_flags_t::NOTARGET) != 0)
            return false;
    }
    else if (heardit)
    {
        // pgm - a little more paranoia won't hurt....
        if (client.owner !is null && (client.owner.flags & ent_flags_t::NOTARGET) != 0)
            return false;
    }
    else if (client.client is null)
        return false;

    if (!heardit)
    {
        // this is where we would check invisibility
        float r = range_to(self, client);

        if (r > RANGE_MID)
            return false;

        // Paril: revised so that monsters can be woken up
        // by players 'seen' and attacked at by other monsters
        // if they are close enough. they don't have to be visible.
        bool is_visible =
            ((r <= RANGE_NEAR && client.show_hostile >= level.time && !(self.spawnflags.has(spawnflags::monsters::AMBUSH))) ||
            (visible(self, client) && (r <= RANGE_MELEE || (self.monsterinfo.aiflags & ai_flags_t::THIRD_EYE) != 0 || infront(self, client))));

        if (!is_visible)
            return false;

        @self.enemy = client;

        if (self.enemy.classname != "player_noise")
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::SOUND_TARGET);

            if (self.enemy.client is null)
            {
                @self.enemy = self.enemy.enemy;
                if (self.enemy.client is null)
                {
                    @self.enemy = null;
                    return false;
                }
            }
        }

        if (self.enemy.client !is null && self.enemy.client.invisible_time > level.time && self.enemy.client.invisibility_fade_time <= level.time)
        {
            @self.enemy = null;
            return false;
        }

        if (self.monsterinfo.close_sight_tripped)
            ignore_sight_sound = true;
        else
            self.monsterinfo.close_sight_tripped = true;
    }
    else // heardit
    {
        vec3_t temp;

        if (self.spawnflags.has(spawnflags::monsters::AMBUSH))
        {
            if (!visible(self, client))
                return false;
        }
        else
        {
            if (!gi_inPHS(self.e.s.origin, client.e.s.origin, true))
                return false;
        }

        temp = client.e.s.origin - self.e.s.origin;

        if (temp.length() > 1000) // too far to hear
            return false;

        // check area portals - if they are different and not connected then we can't hear it
        if (client.e.areanum != self.e.areanum)
            if (!gi_AreasConnected(self.e.areanum, client.e.areanum))
                return false;

        self.ideal_yaw = vectoyaw(temp);
        // ROGUE
        if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
            // ROGUE
            M_ChangeYaw(self);

        // hunt the sound for a bit; hopefully find the real player
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::SOUND_TARGET);
        @self.enemy = client;
    }

    //
    // got one
    //
    FoundTarget(self);

    // ROGUE
    if ((self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) == 0 && self.monsterinfo.sight !is null &&
        // Paril: adjust to prevent monsters getting stuck in sight loops
        !ignore_sight_sound)
        self.monsterinfo.sight(self, self.enemy);

    return true;
}

//=============================================================================

// [Paril-KEX] split this out so we can use it for the other bosses
bool M_CheckAttack_Base(ASEntity &self, float stand_ground_chance, float melee_chance, float near_chance, float mid_chance, float far_chance, float strafe_scalar)
{
    vec3_t  spot1, spot2;
    float   chance;
    trace_t tr;

    if ((self.enemy.flags & ent_flags_t::NOVISIBLE) != 0)
        return false;

    if (self.enemy.health > 0)
    {
        if (self.enemy.client !is null)
        {
            if (self.enemy.client.invisible_time > level.time)
            {
                // can't see us at all after this time
                if (self.enemy.client.invisibility_fade_time <= level.time)
                    return false;
            }
        }

        spot1 = self.e.s.origin;
        spot1.z += self.viewheight;
        // see if any entities are in the way of the shot
        if (self.enemy.client is null || self.enemy.e.solid != solid_t::NOT)
        {
            spot2 = self.enemy.e.s.origin;
            spot2.z += self.enemy.viewheight;

            tr = gi_traceline(spot1, spot2, self.e,
                contents_t(contents_t::MASK_SOLID | contents_t::MONSTER | contents_t::PLAYER | contents_t::SLIME | contents_t::LAVA | contents_t::PROJECTILECLIP));
        }
        else
        {
            @tr.ent = world.e;
            tr.fraction = 0;
        }

        // do we have a clear shot?
        if ((self.hackflags & HACKFLAG_ATTACK_PLAYER) == 0 && !(tr.ent is self.enemy.e) && (tr.ent.svflags & svflags_t::PLAYER) == 0)
        {
            // ROGUE - we want them to go ahead and shoot at info_notnulls if they can.
            if (self.enemy.e.solid != solid_t::NOT || tr.fraction < 1.0f) // PGM
            {
                // PMM - if we can't see our target, and we're not blocked by a monster, go into blind fire if available
                // Paril - *and* we have at least seen them once
                if ((tr.ent.svflags & svflags_t::MONSTER) == 0 && !visible(self, self.enemy) && self.monsterinfo.had_visibility)
                {
                    if (self.monsterinfo.blindfire && (self.monsterinfo.blind_fire_delay <= time_sec(20)))
                    {
                        if (level.time < self.monsterinfo.attack_finished)
                        {
                            // ROGUE
                            return false;
                        }
                        // ROGUE
                        if (level.time < (self.monsterinfo.trail_time + self.monsterinfo.blind_fire_delay))
                        {
                            // wait for our time
                            return false;
                        }
                        else
                        {
                            // make sure we're not going to shoot a monster
                            tr = gi_traceline(spot1, self.monsterinfo.blind_fire_target, self.e,
                                contents_t::MONSTER);
                            if (tr.allsolid || tr.startsolid || ((tr.fraction < 1.0f) && !(tr.ent is self.enemy.e)))
                                return false;

                            self.monsterinfo.attack_state = ai_attack_state_t::BLIND;
                            return true;
                        }
                    }
                }
                // pmm
                return false;
            }
        }
    }
    // ROGUE

    float enemy_range = range_to(self, self.enemy);

    // melee attack
    if (enemy_range <= RANGE_MELEE)
    {
        if (self.monsterinfo.melee !is null && self.monsterinfo.melee_debounce_time <= level.time)
            self.monsterinfo.attack_state = ai_attack_state_t::MELEE;
        else
            self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
        return true;
    }

    // if we were in melee just before this but we're too far away, get out of melee state now
    if (self.monsterinfo.attack_state == ai_attack_state_t::MELEE && self.monsterinfo.melee_debounce_time > level.time)
        self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;

    // missile attack
    if (self.monsterinfo.attack is null)
    {
        // ROGUE - fix for melee only monsters & strafing
        self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
        // ROGUE
        return false;
    }

    if (level.time < self.monsterinfo.attack_finished)
        return false;

    if ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) != 0)
    {
        chance = stand_ground_chance;
    }
    else if (enemy_range <= RANGE_MELEE)
    {
        chance = melee_chance;
    }
    else if (enemy_range <= RANGE_NEAR)
    {
        chance = near_chance;
    }
    else if (enemy_range <= RANGE_MID)
    {
        chance = mid_chance;
    }
    else
    {
        chance = far_chance;
    }

    // PGM - go ahead and shoot every time if it's a info_notnull
    if (((self.enemy.client is null) && self.enemy.e.solid == solid_t::NOT) || (frandom() < chance))
    {
        self.monsterinfo.attack_state = ai_attack_state_t::MISSILE;
        self.monsterinfo.attack_finished = level.time;
        return true;
    }

    // ROGUE -daedalus should strafe more .. this can be done here or in a customized
    // check_attack code for the hover.
    if ((self.flags & ent_flags_t::FLY) != 0)
    {
        if (self.monsterinfo.strafe_check_time <= level.time)
        {
            // originally, just 0.3
            float strafe_chance;

            if (self.classname == "monster_daedalus")
                strafe_chance = 0.8f;
            else
                strafe_chance = 0.6f;

            // if enemy is tesla, never strafe
            if (self.enemy !is null && (self.enemy.classname == "tesla_mine"))
                strafe_chance = 0;
            else
                strafe_chance *= strafe_scalar;

            if (strafe_chance != 0)
            {
                ai_attack_state_t new_state = ai_attack_state_t::STRAIGHT;

                if (frandom() < strafe_chance)
                    new_state = ai_attack_state_t::SLIDING;

                if (new_state != self.monsterinfo.attack_state)
                {
                    self.monsterinfo.strafe_check_time = level.time + random_time(time_sec(1), time_sec(3));
                    self.monsterinfo.attack_state = new_state;
                }
            }
        }
    }
    // do we want the monsters strafing?
    // [Paril-KEX] no, we don't
    // [Paril-KEX] if we're pathing, don't immediately reset us to
    // straight; this allows us to turn to fire and not jerk back and
    // forth.
    else if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) == 0)
        self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
    // ROGUE

    return false;
}

bool M_CheckAttack(ASEntity &self)
{
    return M_CheckAttack_Base(self, 0.7f, 0.4f, 0.25f, 0.06f, 0.0f, 1.0f);
}


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void ai_run_melee(ASEntity &self)
{
    self.ideal_yaw = enemy_yaw;
    // ROGUE
    if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
        // ROGUE
        M_ChangeYaw(self);

    if (FacingIdeal(self))
    {
        self.monsterinfo.melee(self);
        self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
    }
}

/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void ai_run_missile(ASEntity &self)
{
    self.ideal_yaw = enemy_yaw;
    // ROGUE
    if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
        // ROGUE
        M_ChangeYaw(self);

    if (FacingIdeal(self))
    {
        if (self.monsterinfo.attack !is null)
        {
            self.monsterinfo.attack(self);
            self.monsterinfo.attack_finished = level.time + random_time(time_sec(1.0), time_sec(2.0));
        }

        // ROGUE
        if ((self.monsterinfo.attack_state == ai_attack_state_t::MISSILE) || (self.monsterinfo.attack_state == ai_attack_state_t::BLIND))
            // ROGUE
            self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
    }
}

/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
// ROGUE
void ai_run_slide(ASEntity &self, float distance)
{
    float ofs;
    float angle;

    self.ideal_yaw = enemy_yaw;

    angle = 90;

    if (self.monsterinfo.lefty)
        ofs = angle;
    else
        ofs = -angle;

    if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
        M_ChangeYaw(self);

    // PMM - clamp maximum sideways move for non flyers to make them look less jerky
    if ((self.flags & ent_flags_t::FLY) == 0)
        distance = min(distance, MAX_SIDESTEP / (gi_frame_time_ms / 10));
    if (M_walkmove(self, self.ideal_yaw + ofs, distance))
        return;
    // PMM - if we're dodging, give up on it and go straight
    if ((self.monsterinfo.aiflags & ai_flags_t::DODGING) != 0)
    {
        monster_done_dodge(self);
        // by setting as_straight, caller will know to try straight move
        self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
        return;
    }

    self.monsterinfo.lefty = !self.monsterinfo.lefty;
    if (M_walkmove(self, self.ideal_yaw - ofs, distance))
        return;
    // PMM - if we're dodging, give up on it and go straight
    if ((self.monsterinfo.aiflags & ai_flags_t::DODGING) != 0)
        monster_done_dodge(self);

    // PMM - the move failed, so signal the caller (ai_run) to try going straight
    self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
}
// ROGUE

/*
=============
ai_checkattack

Decides if we're going to attack or do something else
used by ai_run and ai_stand
=============
*/
bool ai_checkattack(ASEntity &self, float dist)
{
    vec3_t temp;
    bool   hesDeadJim;
    // ROGUE
    bool retval;
    // ROGUE

    if ((self.monsterinfo.aiflags & ai_flags_t::TEMP_STAND_GROUND) != 0)
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~(ai_flags_t::STAND_GROUND | ai_flags_t::TEMP_STAND_GROUND));

    // this causes monsters to run blindly to the combat point w/o firing
    if (self.goalentity !is null)
    {
        if ((self.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) != 0)
        {
            if (self.enemy !is null && range_to(self, self.enemy) > 100.0f)
                return false;
        }

        if ((self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) != 0)
        {
            if ((level.time - self.enemy.teleport_time) > time_sec(5))
            {
                if (self.goalentity is self.enemy)
                {
                    if (self.movetarget !is null)
                        @self.goalentity = self.movetarget;
                    else
                        @self.goalentity = null;
                }
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::SOUND_TARGET);
            }
            else
            {
                self.enemy.show_hostile = level.time + time_sec(1);
                return false;
            }
        }
    }

    enemy_vis = false;

    // see if the enemy is dead
    hesDeadJim = false;
    if ((self.enemy is null) || (!self.enemy.e.inuse))
    {
        hesDeadJim = true;
    }
    else if ( (self.monsterinfo.aiflags & ai_flags_t::FORGET_ENEMY ) != 0)
    {
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::FORGET_ENEMY);
        hesDeadJim = true;
    }
    else if ((self.monsterinfo.aiflags & ai_flags_t::MEDIC) != 0)
    {
        if (!(self.enemy.e.inuse) || (self.enemy.health > 0))
            hesDeadJim = true;
    }
    else
    {
        if ((self.monsterinfo.aiflags & ai_flags_t::BRUTAL) == 0)
        {
            if (self.enemy.health <= 0)
                hesDeadJim = true;
        }

        // [Paril-KEX] if our enemy was invisible, lose sight now
        if (self.enemy.client !is null && self.enemy.client.invisible_time > level.time && self.enemy.client.invisibility_fade_time <= level.time &&
            (self.monsterinfo.aiflags & ai_flags_t::PURSUE_NEXT) != 0)
        {
            hesDeadJim = true;
        }
    }

    if (hesDeadJim && (self.hackflags & HACKFLAG_ATTACK_PLAYER) == 0)
    {
        // ROGUE
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::MEDIC);
        // ROGUE
        @self.enemy = @self.goalentity = null;
        self.monsterinfo.close_sight_tripped = false;
        // FIXME: look all around for other targets
        if (self.oldenemy !is null && self.oldenemy.health > 0)
        {
            @self.enemy = self.oldenemy;
            @self.oldenemy = null;
            HuntTarget(self);
        }
        // ROGUE - multiple teslas make monsters lose track of the player.
        else if (self.monsterinfo.last_player_enemy !is null && self.monsterinfo.last_player_enemy.health > 0)
        {
            @self.enemy = self.monsterinfo.last_player_enemy;
            @self.oldenemy = null;
            @self.monsterinfo.last_player_enemy = null;
            HuntTarget(self);
        }
        // ROGUE
        else
        {
            if (self.movetarget !is null && (self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0)
            {
                @self.goalentity = self.movetarget;
                self.monsterinfo.walk(self);
            }
            else
            {
                // we need the pausetime otherwise the stand code
                // will just revert to walking with no target and
                // the monsters will wonder around aimlessly trying
                // to hunt the world entity
                self.monsterinfo.pausetime = HOLD_FOREVER;
                self.monsterinfo.stand(self);

                if ((self.monsterinfo.aiflags & ai_flags_t::TEMP_STAND_GROUND) != 0)
                    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~(ai_flags_t::STAND_GROUND | ai_flags_t::TEMP_STAND_GROUND));
            }
            return true;
        }
    }

    // check knowledge of enemy
    enemy_vis = visible(self, self.enemy);
    if (enemy_vis)
    {
        self.monsterinfo.had_visibility = visible(self, self.enemy, false);
        self.enemy.show_hostile = level.time + time_sec(1); // wake up other monsters
        self.monsterinfo.search_time = level.time + time_sec(5);
        self.monsterinfo.last_sighting = self.monsterinfo.saved_goal = self.enemy.e.s.origin;
        // ROGUE
        if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) != 0)
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);

            if (self.monsterinfo.move_block_change_time < level.time)
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TEMP_MELEE_COMBAT);

            self.monsterinfo.checkattack_time = level.time + random_time(time_ms(50), time_ms(200));
        }
        self.monsterinfo.trail_time = level.time;
        self.monsterinfo.blind_fire_target = self.monsterinfo.last_sighting + (self.enemy.velocity * -0.1f);
        self.monsterinfo.blind_fire_delay = time_zero;
        // ROGUE
    }

    enemy_infront = infront(self, self.enemy);
    temp = self.enemy.e.s.origin - self.e.s.origin;
    enemy_yaw = vectoyaw(temp);

    // PMM -- reordered so the monster specific checkattack is called before the run_missle/melee/checkvis
    // stuff .. this allows for, among other things, circle strafing and attacking while in ai_run
    retval = false;

    if (self.monsterinfo.checkattack_time <= level.time)
    {
        self.monsterinfo.checkattack_time = level.time + time_sec(0.1);
        retval = self.monsterinfo.checkattack(self);
    }

    if (retval || self.monsterinfo.attack_state >= ai_attack_state_t::MISSILE)
    {
        // PMM
        if (self.monsterinfo.attack_state == ai_attack_state_t::MISSILE)
        {
            ai_run_missile(self);
            return true;
        }
        if (self.monsterinfo.attack_state == ai_attack_state_t::MELEE)
        {
            ai_run_melee(self);
            return true;
        }
        // PMM -- added so monsters can shoot blind
        if (self.monsterinfo.attack_state == ai_attack_state_t::BLIND)
        {
            ai_run_missile(self);
            return true;
        }
        // pmm

        // if enemy is not currently visible, we will never attack
        if (!enemy_vis)
            return false;
        // PMM
    }

    return retval;
    // PMM
}

/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void ai_run(ASEntity &self, float dist)
{
    vec3_t   v;
    ASEntity @tempgoal;
    ASEntity @save;
    bool     newEnemy;
    ASEntity @marker = null;
    float    d1, d2;
    trace_t  tr;
    vec3_t   v_forward, v_right;
    float    left, center, right;
    vec3_t   left_target, right_target;
    // ROGUE
    bool     retval;
    bool     alreadyMoved = false;
    bool     gotcha = false;
    ASEntity @realEnemy;
    // ROGUE

    // if we're going to a combat point, just proceed
    if ((self.monsterinfo.aiflags & ai_flags_t::COMBAT_POINT) != 0)
    {
        ai_checkattack(self, dist);
        M_MoveToGoal(self, dist);

        if (self.movetarget !is null)
        {
            // nb: this is done from the centroid and not viewheight on purpose;
            tr = gi_trace((self.e.absmax + self.e.absmin) * 0.5f, { -2.0f, -2.0f, -2.0f }, { 2.0f, 2.0f, 2.0f }, self.movetarget.e.s.origin, self.e, contents_t::SOLID);

            // [Paril-KEX] special case: if we're stand ground & knocked way too far away
            // from our path_corner, or we can't see it any more, assume all
            // is lost.
            if ((self.monsterinfo.aiflags & ai_flags_t::REACHED_HOLD_COMBAT) != 0 &&
                   (((closest_point_to_box(self.movetarget.e.s.origin, self.e.absmin, self.e.absmax) - self.movetarget.e.s.origin).length() > 160.0f)
                || (tr.fraction < 1.0f && tr.plane.normal.z <= 0.7f))) // if we hit a climbable, ignore this result
            {
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::COMBAT_POINT);
                @self.movetarget = null;
                self.target = "";
                @self.goalentity = self.enemy;
            }
            else
                return;
        }
        else
            return;
    }

    // PMM
    if ((self.monsterinfo.aiflags & ai_flags_t::DUCKED) != 0 && self.monsterinfo.unduck !is null)
		self.monsterinfo.unduck(self);

    if ((self.monsterinfo.aiflags & ai_flags_t::SOUND_TARGET) != 0)
    {
        // PMM - paranoia checking
        if (self.enemy !is null)
            v = self.e.s.origin - self.enemy.e.s.origin;

        bool touching_noise = SV_CloseEnough(self, self.enemy, dist * (gi_tick_rate / 10));

        if ((self.enemy is null || !self.enemy.e.inuse) || (touching_noise && FacingIdeal(self)))
        // pmm
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | (ai_flags_t::STAND_GROUND | ai_flags_t::TEMP_STAND_GROUND));
            self.e.s.angles.yaw = self.ideal_yaw;
            self.monsterinfo.stand(self);
            self.monsterinfo.close_sight_tripped = false;
            return;
        }

        // if we're close to the goal, just turn
        if (touching_noise)
            M_ChangeYaw(self);
        else
            M_MoveToGoal(self, dist);

        // ROGUE - prevent double moves for sound_targets
        alreadyMoved = true;

        if (!self.e.inuse)
            return; // PGM - g_touchtrigger free problem
        // ROGUE

        if (!FindTarget(self))
            return;
    }

    // PMM -- moved ai_checkattack up here so the monsters can attack while strafing or charging

    // PMM -- if we're dodging, make sure to keep the attack_state AS_SLIDING
    retval = ai_checkattack(self, dist);

    // PMM - don't strafe if we can't see our enemy
    if ((!enemy_vis) && (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING))
        self.monsterinfo.attack_state = ai_attack_state_t::STRAIGHT;
    // unless we're dodging (dodging out of view looks smart)
    if ((self.monsterinfo.aiflags & ai_flags_t::DODGING) != 0)
        self.monsterinfo.attack_state = ai_attack_state_t::SLIDING;
    // pmm

    if (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING)
    {
        // PMM - protect against double moves
        if (!alreadyMoved)
            ai_run_slide(self, dist);
        // PMM
        // we're using attack_state as the return value out of ai_run_slide to indicate whether or not the
        // move succeeded.  If the move succeeded, and we're still sliding, we're done in here (since we've
        // had our chance to shoot in ai_checkattack, and have moved).
        // if the move failed, our state is as_straight, and it will be taken care of below
        if ((!retval) && (self.monsterinfo.attack_state == ai_attack_state_t::SLIDING))
            return;
    }
    else if ((self.monsterinfo.aiflags & ai_flags_t::CHARGING) != 0)
    {
        self.ideal_yaw = enemy_yaw;
        if ((self.monsterinfo.aiflags & ai_flags_t::MANUAL_STEERING) == 0)
            M_ChangeYaw(self);
    }
    if (retval)
    {
        // PMM - is this useful?  Monsters attacking usually call the ai_charge routine..
        // the only monster this affects should be the soldier
        if ((dist != 0 || (self.monsterinfo.aiflags & ai_flags_t::ALTERNATE_FLY) != 0) &&
            (!alreadyMoved) && (self.monsterinfo.attack_state == ai_attack_state_t::STRAIGHT) &&
            ((self.monsterinfo.aiflags & ai_flags_t::STAND_GROUND) == 0))
        {
            M_MoveToGoal(self, dist);
        }
        if (self.enemy !is null && (self.enemy.e.inuse) && (enemy_vis))
        {
            if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) != 0)
            {
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);

                if (self.monsterinfo.move_block_change_time < level.time)
                    self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TEMP_MELEE_COMBAT);
            }
            self.monsterinfo.last_sighting = self.monsterinfo.saved_goal = self.enemy.e.s.origin;
            self.monsterinfo.trail_time = level.time;
            // PMM
            self.monsterinfo.blind_fire_target = self.monsterinfo.last_sighting + (self.enemy.velocity * -0.1f);
            self.monsterinfo.blind_fire_delay = time_zero;
            // pmm
        }
        return;
    }
    // PMM

    // PGM - added a little paranoia checking here... 9/22/98
    if (self.enemy !is null && (self.enemy.e.inuse) && (enemy_vis))
    {
        // PMM - check for alreadyMoved
        if (!alreadyMoved)
            M_MoveToGoal(self, dist);
        if (!self.e.inuse)
            return; // PGM - g_touchtrigger free problem
        
        if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) != 0)
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::LOST_SIGHT);

            if (self.monsterinfo.move_block_change_time < level.time)
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::TEMP_MELEE_COMBAT);
        }
        self.monsterinfo.last_sighting = self.monsterinfo.saved_goal = self.enemy.e.s.origin;
        self.monsterinfo.trail_time = level.time;
        // PMM
        self.monsterinfo.blind_fire_target = self.monsterinfo.last_sighting + (self.enemy.velocity * -0.1f);
        self.monsterinfo.blind_fire_delay = time_zero;
        // pmm

        // [Paril-KEX] if our enemy is literally right next to us, give
        // us more rotational speed so we don't get circled
        if (range_to(self, self.enemy) <= RANGE_MELEE * 2.5f)
            M_ChangeYaw(self);

        return;
    }

    // PMM - moved down here to allow monsters to get on hint paths
    // coop will change to another enemy if visible
    if (coop.integer != 0)
        FindTarget(self);
    // pmm

    if ((self.monsterinfo.search_time) && (level.time > (self.monsterinfo.search_time + time_sec(20))))
    {
        // PMM - double move protection
        if (!alreadyMoved)
            M_MoveToGoal(self, dist);
        self.monsterinfo.search_time = time_zero;
        return;
    }

    @save = self.goalentity;

    if (monster_fakegoal is null)
        @monster_fakegoal = G_Spawn();

    @tempgoal = monster_fakegoal;
    @self.goalentity = tempgoal;

    newEnemy = false;

    if ((self.monsterinfo.aiflags & ai_flags_t::LOST_SIGHT) == 0)
    {
        // just lost sight of the player, decide where to go first
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | (ai_flags_t::LOST_SIGHT | ai_flags_t::PURSUIT_LAST_SEEN));
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~(ai_flags_t::PURSUE_NEXT | ai_flags_t::PURSUE_TEMP));
        newEnemy = true;
        
        // immediately try paths
		self.monsterinfo.path_blocked_counter = time_zero;
		self.monsterinfo.path_wait_time = time_zero;
    }

    if ((self.monsterinfo.aiflags & ai_flags_t::PURSUE_NEXT) != 0)
    {
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::PURSUE_NEXT);

        // give ourself more time since we got this far
        self.monsterinfo.search_time = level.time + time_sec(5);

        if ((self.monsterinfo.aiflags & ai_flags_t::PURSUE_TEMP) != 0)
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::PURSUE_TEMP);
            @marker = null;
            self.monsterinfo.last_sighting = self.monsterinfo.saved_goal;
            newEnemy = true;
        }
        else if ((self.monsterinfo.aiflags & ai_flags_t::PURSUIT_LAST_SEEN) != 0)
        {
            self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags & ~ai_flags_t::PURSUIT_LAST_SEEN);
            @marker = PlayerTrail_Pick(self, false);
        }
        else
        {
            @marker = PlayerTrail_Pick(self, true);
        }

        if (marker !is null)
        {
            self.monsterinfo.last_sighting = marker.e.s.origin;
            self.monsterinfo.trail_time = marker.timestamp;
            self.e.s.angles.yaw = self.ideal_yaw = marker.e.s.angles.yaw;

            newEnemy = true;
        }
    }

    if ((self.monsterinfo.aiflags & ai_flags_t::PATHING) == 0 &&
        boxes_intersect(self.monsterinfo.last_sighting, self.monsterinfo.last_sighting, self.e.s.origin + self.e.mins, self.e.s.origin + self.e.maxs))
    {
        self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::PURSUE_NEXT);
        dist = min(dist, (self.e.s.origin - self.monsterinfo.last_sighting).length());
        // [Paril-KEX] this helps them navigate corners when two next pursuits
        // are really close together
        self.monsterinfo.random_change_time = level.time + time_hz(10);
    }

    self.goalentity.e.s.origin = self.monsterinfo.last_sighting;

    if (newEnemy)
    {
        tr =
            gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, self.monsterinfo.last_sighting, self.e, contents_t::MASK_PLAYERSOLID);
        if (tr.fraction > 0 && tr.fraction < 1)
        {
            v = self.goalentity.e.s.origin - self.e.s.origin;
            d1 = v.length();
            center = tr.fraction;
            d2 = d1 * ((center + 1) / 2);

            float backup_yaw = self.e.s.angles.y;
            self.e.s.angles.yaw = self.ideal_yaw = vectoyaw(v);
            AngleVectors(self.e.s.angles, v_forward, v_right);

            v = { d2, -16, 0 };
            left_target = G_ProjectSource(self.e.s.origin, v, v_forward, v_right);
            tr = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, left_target, self.e, contents_t::MASK_PLAYERSOLID);
            left = tr.fraction;

            v = { d2, 16, 0 };
            right_target = G_ProjectSource(self.e.s.origin, v, v_forward, v_right);
            tr = gi_trace(self.e.s.origin, self.e.mins, self.e.maxs, right_target, self.e, contents_t::MASK_PLAYERSOLID);
            right = tr.fraction;

            center = (d1 * center) / (d2 == 0 ? 0.5f : d2);
            if (left >= center && left > right)
            {
                if (left < 1)
                {
                    v = { d2 * left * 0.5f, -16, 0 };
                    left_target = G_ProjectSource(self.e.s.origin, v, v_forward, v_right);
                }
                self.monsterinfo.saved_goal = self.monsterinfo.last_sighting;
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::PURSUE_TEMP);
                self.goalentity.e.s.origin = left_target;
                self.monsterinfo.last_sighting = left_target;
                v = self.goalentity.e.s.origin - self.e.s.origin;
                self.ideal_yaw = vectoyaw(v);
            }
            else if (right >= center && right > left)
            {
                if (right < 1)
                {
                    v = { d2 * right * 0.5f, 16, 0 };
                    right_target = G_ProjectSource(self.e.s.origin, v, v_forward, v_right);
                }
                self.monsterinfo.saved_goal = self.monsterinfo.last_sighting;
                self.monsterinfo.aiflags = ai_flags_t(self.monsterinfo.aiflags | ai_flags_t::PURSUE_TEMP);
                self.goalentity.e.s.origin = right_target;
                self.monsterinfo.last_sighting = right_target;
                v = self.goalentity.e.s.origin - self.e.s.origin;
                self.ideal_yaw = vectoyaw(v);
            }
            self.e.s.angles.yaw = backup_yaw;
        }
    }

    M_MoveToGoal(self, dist);

    if (!self.e.inuse)
        return; // PGM - g_touchtrigger free problem

    @self.goalentity = save;
}
