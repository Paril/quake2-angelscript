// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

void ClearBounds(vec3_t &out mins, vec3_t &out maxs)
{
	mins.x = mins.y = mins.z = float_limits::infinity;
	maxs.x = maxs.y = maxs.z = -float_limits::infinity;
}

/*
void AddPointToBounds(const vec3_t &in v, const vec3_t &in in_mins, const vec3_t &in in_maxs,
    vec3_t &out out_mins, vec3_t &out out_maxs)
{
	for (int i = 0; i < 3; i++)
	{
		float val = v[i];
		if (val < in_mins[i])
			out_mins[i] = val;
        else
            out_mins[i] = in_mins[i];
		if (val > in_maxs[i])
			out_maxs[i] = val;
        else
            out_maxs[i] = in_maxs[i];
	}
}
*/
void AddPointToBounds(const vec3_t &in v, vec3_t &mins, vec3_t &maxs)
{
	for (int i = 0; i < 3; i++)
	{
		float val = v[i];
		if (val < mins[i])
			mins[i] = val;
        else
            mins[i] = mins[i];
		if (val > maxs[i])
			maxs[i] = val;
        else
            maxs[i] = maxs[i];
	}
}