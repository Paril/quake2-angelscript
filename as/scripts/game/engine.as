//==============================================

/*
enum svc_poi_flags
{
    POI_FLAG_NONE = 0,
    POI_FLAG_HIDE_ON_AIM = 1, // hide the POI if we get close to it with our aim
};

// data for svc_fog
struct svc_fog_data_t
{
    enum bits_t : uint16_t
    {
        // global fog
        BIT_DENSITY     = bit_v<0>,
        BIT_R           = bit_v<1>,
        BIT_G           = bit_v<2>,
        BIT_B           = bit_v<3>,
        BIT_TIME        = bit_v<4>, // if set, the transition takes place over N milliseconds

        // height fog
        BIT_HEIGHTFOG_FALLOFF   = bit_v<5>,
        BIT_HEIGHTFOG_DENSITY   = bit_v<6>,
        BIT_MORE_BITS           = bit_v<7>, // read additional bit
        BIT_HEIGHTFOG_START_R   = bit_v<8>,
        BIT_HEIGHTFOG_START_G   = bit_v<9>,
        BIT_HEIGHTFOG_START_B   = bit_v<10>,
        BIT_HEIGHTFOG_START_DIST= bit_v<11>,
        BIT_HEIGHTFOG_END_R     = bit_v<12>,
        BIT_HEIGHTFOG_END_G     = bit_v<13>,
        BIT_HEIGHTFOG_END_B     = bit_v<14>,
        BIT_HEIGHTFOG_END_DIST  = bit_v<15>
    };

    bits_t      bits;
    float       density; // bits & BIT_DENSITY
    uint8_t     skyfactor; // bits & BIT_DENSITY
    uint8_t     red; // bits & BIT_R
    uint8_t     green; // bits & BIT_G
    uint8_t     blue; // bits & BIT_B
    uint16_t    time; // bits & BIT_TIME
    
    float       hf_falloff; // bits & BIT_HEIGHTFOG_FALLOFF
    float       hf_density; // bits & BIT_HEIGHTFOG_DENSITY
    uint8_t     hf_start_r; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_START_R)
    uint8_t     hf_start_g; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_START_G)
    uint8_t     hf_start_b; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_START_B)
    int32_t     hf_start_dist; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_START_DIST)
    uint8_t     hf_end_r; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_END_R)
    uint8_t     hf_end_g; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_END_G)
    uint8_t     hf_end_b; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_END_B)
    int32_t     hf_end_dist; // bits & (BIT_MORE_BITS | BIT_HEIGHTFOG_END_DIST)
};

MAKE_ENUM_BITFLAGS(svc_fog_data_t::bits_t);
    
// bit masks
static constexpr svc_fog_data_t::bits_t BITS_GLOBAL_FOG = (svc_fog_data_t::BIT_DENSITY | svc_fog_data_t::BIT_R | svc_fog_data_t::BIT_G | svc_fog_data_t::BIT_B);
static constexpr svc_fog_data_t::bits_t BITS_HEIGHTFOG = (svc_fog_data_t::BIT_HEIGHTFOG_FALLOFF | svc_fog_data_t::BIT_HEIGHTFOG_DENSITY | svc_fog_data_t::BIT_HEIGHTFOG_START_R | svc_fog_data_t::BIT_HEIGHTFOG_START_G |
                                            svc_fog_data_t::BIT_HEIGHTFOG_START_B | svc_fog_data_t::BIT_HEIGHTFOG_START_DIST | svc_fog_data_t::BIT_HEIGHTFOG_END_R | svc_fog_data_t::BIT_HEIGHTFOG_END_G |
                                            svc_fog_data_t::BIT_HEIGHTFOG_END_B | svc_fog_data_t::BIT_HEIGHTFOG_END_DIST);
*/

// convenience overloads

bool gi_inPHS(const vec3_t &in a, const vec3_t &in b) nodiscard
{
    return gi_inPHS(a, b, true);
}
bool gi_inPVS(const vec3_t &in a, const vec3_t &in b) nodiscard
{
    return gi_inPVS(a, b, true);
}

// [Paril-KEX] get the current unique unicast key
namespace internal
{
    uint unicast_key = 1;
}

uint GetUnicastKey()
{
	if (internal::unicast_key == 0)
		return internal::unicast_key = 1;

	return internal::unicast_key++;
}

void gi_unicast(edict_t @ent, bool reliable)
{
    gi_unicast(ent, reliable, 0);
}

void gi_local_sound(edict_t @target, const vec3_t &in origin, edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs)
{
    gi_local_sound(target, origin, ent, channel, soundindex, volume, attenuation, timeofs, 0);
}

void gi_local_sound(edict_t @target, edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs)
{
    gi_local_sound(target, ent, channel, soundindex, volume, attenuation, timeofs);
}

void gi_local_sound(const vec3_t &in origin, edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs, uint32 dupe_key = 0)
{
    gi_local_sound(ent, origin, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
}

void gi_local_sound(edict_t @ent, soundchan_t channel, int soundindex, float volume, float attenuation, float timeofs, uint32 dupe_key = 0)
{
    gi_local_sound(ent, ent, channel, soundindex, volume, attenuation, timeofs, dupe_key);
}