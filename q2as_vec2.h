struct vec2
{
    union {
        struct
        {
            float x;
            float y;
        };

        std::array<float, 2> elements;
    };

    constexpr float &operator[](unsigned int i)
    {
        i = i > 1 ? 0 : i;

        return elements[i];
    }

    constexpr const float &operator[](unsigned int i) const
    {
        i = i > 1 ? 0 : i;

        return elements[i];
    }

    constexpr bool operator==(const vec2 &v) const
    {
        return elements[0] == v.elements[0] && elements[1] == v.elements[1];
    }

    bool equals(const vec2 &v, const float relative_tolerance, const float absolute_tolerance) const
    {
        bool rx = abs(x - v.x) <= max(relative_tolerance * max(abs(x), abs(v.x)), absolute_tolerance);
        bool ry = abs(y - v.y) <= max(relative_tolerance * max(abs(y), abs(v.y)), absolute_tolerance);

        return rx && ry;
    }

    bool equals(const vec2 &v, const float relative_tolerance) const
    {
        return equals(v, relative_tolerance, 0.0f);
    }

    constexpr explicit operator bool() const
    {
        return x || y;
    }

    constexpr vec2 operator-(const vec2 &v) const
    {
        return { x - v.x, y - v.y };
    }

    constexpr vec2 operator+(const vec2 &v) const
    {
        return { x + v.x, y + v.y };
    }

    constexpr vec2 operator/(const vec2 &v) const
    {
        return { x / v.x, y / v.y };
    }

    constexpr vec2 operator/(const float &v) const
    {
        return { x / v, y / v };
    }

    constexpr vec2 operator/(const int &v) const
    {
        return { x / v, y / v };
    }

    constexpr vec2 operator*(const float &v) const
    {
        return { x * v, y * v };
    }

    constexpr vec2 operator*(const int &v) const
    {
        return { x * v, y * v };
    }

    constexpr vec2 operator-() const
    {
        return { -x, -y };
    }

    constexpr vec2 &operator-=(const vec2 &v)
    {
        x -= v.x;
        y -= v.y;

        return *this;
    }

    constexpr vec2 &operator+=(const vec2 &v)
    {
        x += v.x;
        y += v.y;

        return *this;
    }

    constexpr vec2 &operator/=(const vec2 &v)
    {
        x /= v.x;
        y /= v.y;

        return *this;
    }

    constexpr vec2 &operator/=(const float &v)
    {
        x /= v;
        y /= v;

        return *this;
    }

    constexpr vec2 &operator/=(const int &v)
    {
        x /= v;
        y /= v;

        return *this;
    }

    constexpr vec2 &operator*=(const float &v)
    {
        x *= v;
        y *= v;

        return *this;
    }

    constexpr vec2 &operator*=(const int &v)
    {
        x *= v;
        y *= v;

        return *this;
    }

    constexpr vec2 scaled(const vec2 &v) const
    {
        return { x * v.x, y * v.y };
    }

    constexpr vec2 &scale(const vec2 &v)
    {
        x *= v.x;
        y *= v.y;

        return *this;
    }

    float length() const
    {
        return sqrtf(lengthSquared());
    }

    constexpr float lengthSquared() const
    {
        return (x * x + y * y);
    }

    float distance(const vec2 &v) const
    {
        return sqrtf(distanceSquared(v));
    }

    constexpr float distanceSquared(const vec2 &v) const
    {
        auto dv = v - *this;
        return (dv.x * dv.x + dv.y * dv.y);
    }

    vec2 normalized() const
    {
        vec2 result = { x, y };
        result.normalize();

        return result;
    }

    vec2 normalized(float &v) const
    {
        vec2 result = { x, y };
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

        return len;
    }

    constexpr float dot(const vec2 &v) const
    {
        return x * v.x + y * v.y;
    }
};