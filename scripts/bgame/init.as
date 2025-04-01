// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

void Test(vec3_t v)
{
    vec3_t a, b, c;

    v.x = 50 + b.x + a.x + c.x;
}

bool Check() { return true; }

void main(bool is_cgame)
{
    vec3_t(1, 2, 3);
    vec3_t(1, 2, 3);

    {
        vec3_t test_a;
        test_a.x++;
    }

    if (Check())
    {
        if (!is_cgame)
        {
            vec3_t test;
            Test(test);
        }
    }
}