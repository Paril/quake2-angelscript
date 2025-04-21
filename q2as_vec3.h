#pragma once

struct vec3
{
    union {
        struct
        {
            float x;
            float y;
            float z;
        };

        std::array<float, 3> elements;
    };

    constexpr float &operator[](unsigned int i)
    {
        i = i > 2 ? 0 : i;

        return elements[i];
    }

    constexpr const float &operator[](unsigned int i) const
    {
        i = i > 2 ? 0 : i;

        return elements[i];
    }

    constexpr bool operator==(const vec3 &v) const
    {
        return elements[0] == v.elements[0] && elements[1] == v.elements[1] && elements[2] == v.elements[2];
    }

    bool equals(const vec3 &v, const float relative_tolerance, const float absolute_tolerance) const
    {
        bool rx = abs(x - v.x) <= max(relative_tolerance * max(abs(x), abs(v.x)), absolute_tolerance);
        bool ry = abs(y - v.y) <= max(relative_tolerance * max(abs(y), abs(v.y)), absolute_tolerance);
        bool rz = abs(z - v.z) <= max(relative_tolerance * max(abs(z), abs(v.z)), absolute_tolerance);

        return rx && ry && rz;
    }

    bool equals(const vec3 &v, const float relative_tolerance) const
    {
        return equals(v, relative_tolerance, 0.0f);
    }

    constexpr explicit operator bool() const
    {
        return x || y || z;
    }

    constexpr float dot(const vec3 &v) const
    {
        return x * v.x + y * v.y + z * v.z;
    }

    constexpr vec3 scaled(const vec3 &v) const
    {
        return { x * v.x, y * v.y, z * v.z };
    }

    constexpr vec3 &scale(const vec3 &v)
    {
        x *= v.x;
        y *= v.y;
        z *= v.z;

        return *this;
    }

    constexpr vec3 operator-(const vec3 &v) const
    {
        return { x - v.x, y - v.y, z - v.z };
    }

    constexpr vec3 operator+(const vec3 &v) const
    {
        return { x + v.x, y + v.y, z + v.z };
    }

    constexpr vec3 operator/(const vec3 &v) const
    {
        return { x / v.x, y / v.y, z / v.z };
    }

    constexpr vec3 operator/(const float &v) const
    {
        return { x / v, y / v, z / v };
    }

    constexpr vec3 operator/(const int &v) const
    {
        return { x / v, y / v, z / v };
    }

    constexpr vec3 operator*(const float &v) const
    {
        return { x * v, y * v, z * v };
    }

    constexpr vec3 operator*(const int &v) const
    {
        return { x * v, y * v, z * v };
    }

    constexpr vec3 operator-() const
    {
        return { -x, -y, -z };
    }

    constexpr vec3 &operator-=(const vec3 &v)
    {
        x -= v.x;
        y -= v.y;
        z -= v.z;

        return *this;
    }

    constexpr vec3 &operator+=(const vec3 &v)
    {
        x += v.x;
        y += v.y;
        z += v.z;

        return *this;
    }

    constexpr vec3 &operator/=(const vec3 &v)
    {
        x /= v.x;
        y /= v.y;
        z /= v.z;

        return *this;
    }

    constexpr vec3 &operator/=(const float &v)
    {
        x /= v;
        y /= v;
        z /= v;

        return *this;
    }

    constexpr vec3 &operator/=(const int &v)
    {
        x /= v;
        y /= v;
        z /= v;

        return *this;
    }

    constexpr vec3 &operator*=(const float &v)
    {
        x *= v;
        y *= v;
        z *= v;

        return *this;
    }

    constexpr vec3 &operator*=(const int &v)
    {
        x *= v;
        y *= v;
        z *= v;

        return *this;
    }

    float length() const
    {
        return sqrtf(lengthSquared());
    }

    constexpr float lengthSquared() const
    {
        return (x * x + y * y + z * z);
    }

    vec3 normalized() const
    {
        vec3 result = { x, y, z };
        result.normalize();

        return result;
    }

    vec3 normalized(float &v) const
    {
        vec3 result = { x, y, z };
        v = result.normalize();

        return result;
    }

    float normalize()
    {
        float len = length();

        float f = len;
        if (len > 0.0f)
        {
            f = 1.0f / len;
        }

        x *= f;
        y *= f;
        z *= f;

        return len;
    }

    constexpr vec3 cross(const vec3 &v) const
    {
        return { y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x };
    }
};