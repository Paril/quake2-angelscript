#!/bin/bash

sed -r \
\
-e \
's/MONSTERINFO_(IDLE|WALK|RUN|ATTACK|MELEE|SETSKIN|STAND|SEARCH)\((.*?)\) \(edict_t \*self\) -> void/void \2(ASEntity \&self)/g' \
-e \
's/PRETHINK\((.*?)\) \(edict_t \*self\) -> void/void \1(ASEntity \&self)/g' \
-e \
's/MONSTERINFO_SIDESTEP\((.*?)\) \(edict_t \*self\) -> bool/bool \1(ASEntity \&self)/g' \
-e \
's/MONSTERINFO_SIGHT\((.*?)\) \(edict_t \*self, edict_t \*other\) -> void/void \1(ASEntity \&self, ASEntity \&other)/g' \
-e \
's/MONSTERINFO_DUCK\((.*?)\) \(edict_t \*self, gtime_t eta\) -> bool/bool \1(ASEntity \&self, gtime_t eta)/g' \
-e \
's/MONSTERINFO_BLOCKED\((.*?)\) \(edict_t \*self, float dist\) -> bool/bool \1(ASEntity \&self, float dist)/g' \
-e \
's/DIE\((.*?)\) \(edict_t \*self, edict_t \*inflictor, edict_t \*attacker, int damage, const vec3_t \&point, const mod_t \&mod\) -> void/void \1(ASEntity \&self, ASEntity \&inflictor, ASEntity \&attacker, int damage, const vec3_t \&in point, const mod_t \&in mod)/g' \
-e \
's/PAIN\((.*?)\) \(edict_t \*self, edict_t \*other, float kick, int damage, const mod_t \&mod\) -> void/void \1(ASEntity \&self, ASEntity \&other, float kick, int damage, const mod_t \&in mod)/g' \
-e \
's/mframe_t (.*?)\[\] = \{/array<mframe_t> \1 = {/g' \
-e \
's/\[\]\(edict_t \*self\W?\)/function(self)/g' \
-e \
's/\{ (ai_.*?) \}/mframe_t(\1)/g' \
-e \
's/MMOVE_T\((.*?)\) = \{ (.*?) \};/mmove_t \1 = mmove_t(\2);/g' \
-e \
's/static //g' \
-e \
's/constexpr /const /g' \
-e \
's/edict_t \*/ASEntity \&/g' \
-e \
's/(NULL|nullptr)/null/g' \
-e \
's/->/./g' \
-e \
's/gi\.sound\(self/gi_sound(self.e/g' \
-e \
's/(\b)CHAN_/\1soundchan_t::/g' \
-e \
's/(\b)SVF_/\1svflags_t::/g' \
-e \
's/(\b)FL_/\1ent_flags_t::/g' \
-e \
's/(\b)AI_([A-Z])/\1ai_flags_t::\2/g' \
-e \
's/M_SetAnimation\(self, \&/M_SetAnimation(self, /g' \
-e \
's/\.active_move == \&/\.active_move is /g' \
-e \
's/\.active_move != \&/\.active_move !is /g' \
-e \
's/\.next_move == \&/\.next_move is /g' \
-e \
's/\.next_move != \&/\.next_move !is /g' \
-e \
's/\.think == /\.think is /g' \
-e \
's/\.think != /\.think !is /g' \
-e \
's/([-0-9.]*+)_(sec|ms|hz|min)/time_\2(\1)/g' \
-e \
"s/FRAME_([a-z])/$1::frames::\1/g" \
-e \
's/gi\.linkentity\(self\)/gi_linkentity(self.e)/g' \
-e \
's/const spawn_temp_t \&st/const spawn_temp_t @st/g' \
-e \
's/\.s\.(skinnum|origin|angles|frame|modelindex|sound|scale|alpha|old_origin)\b/.e.s.\1/g' \
-e \
's/\.(inuse|svflags|mins|maxs|solid|absmin|absmax|size|clipmask)\b/.e.\1/g' \
-e \
's/gi\.(model|sound|image)index/gi_\1index/g' \
-e \
's/static_cast<(.*?)>/\1/g' \
-e \
's/monster_muzzleflash_id_t/monster_muzzle_t/g' \
-e \
's/MZ2_/monster_muzzle_t::/g' \
-e \
's/SPAWNFLAG_MONSTER_/spawnflags::monsters::/g' \
-e \
"s/SOLID_/solid_t::/g" \
-e \
"s/MOVETYPE_/movetype_t::/g" \
-e \
"s/(\b)AS_/\1ai_attack_state_t::/g" \
$1.src > $1.tmp.as