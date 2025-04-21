#pragma once

#include <chrono>

struct q2as_gtime
{
    using _milliseconds = std::chrono::milliseconds;
    _milliseconds _duration = _milliseconds(0);

    q2as_gtime() = default;
    q2as_gtime(const _milliseconds &ms) :
        _duration(ms)
    {
    }
    q2as_gtime(const q2as_gtime &) = default;
    q2as_gtime &operator=(const q2as_gtime &) = default;

    template<typename T>
    T minutes() const
    {
        return std::chrono::duration_cast<std::chrono::duration<T, std::ratio<60>>>(_duration).count();
    }

    template<typename T>
    T seconds() const
    {
        return std::chrono::duration_cast<std::chrono::duration<T>>(_duration).count();
    }

    int64_t milliseconds() const
    {
        return _duration.count();
    }

    int64_t frames() const;

    static q2as_gtime from_ms(const int64_t &ms)
    {
        return q2as_gtime(_milliseconds(ms));
    }

    template<typename T>
    static q2as_gtime from_sec(const T &seconds)
    {
        return q2as_gtime(std::chrono::duration_cast<_milliseconds>(std::chrono::duration<T>(seconds)));
    }

    template<typename T>
    static q2as_gtime from_min(const T &minutes)
    {
        return q2as_gtime(std::chrono::duration_cast<_milliseconds>(std::chrono::duration<T, std::ratio<60>>(minutes)));
    }

    static q2as_gtime from_hz(uint64_t hz)
    {
        return from_sec(1.0 / hz);
    }

    explicit operator bool() const
    {
        return _duration.count() != 0;
    }

    q2as_gtime operator-(const q2as_gtime &rhs) const
    {
        return q2as_gtime(_duration - rhs._duration);
    }

    q2as_gtime operator+(const q2as_gtime &rhs) const
    {
        return q2as_gtime(_duration + rhs._duration);
    }

    template<typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
    q2as_gtime operator/(const T &rhs) const
    {
        return q2as_gtime(_milliseconds(static_cast<int64_t>(_duration.count() / rhs)));
    }

    template<typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
    q2as_gtime operator*(const T &rhs) const
    {
        return q2as_gtime(_milliseconds(static_cast<int64_t>(_duration.count() * rhs)));
    }

    q2as_gtime operator-() const
    {
        return q2as_gtime(-_duration);
    }

    q2as_gtime &operator-=(const q2as_gtime &rhs)
    {
        _duration -= rhs._duration;
        return *this;
    }

    q2as_gtime &operator+=(const q2as_gtime &rhs)
    {
        _duration += rhs._duration;
        return *this;
    }

    template<typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
    q2as_gtime &operator/=(const T &rhs)
    {
        _duration = _milliseconds(static_cast<int64_t>(_duration.count() / rhs));
        return *this;
    }

    template<typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
    q2as_gtime &operator*=(const T &rhs)
    {
        _duration = _milliseconds(static_cast<int64_t>(_duration.count() * rhs));
        return *this;
    }

    bool operator==(const q2as_gtime &rhs) const
    {
        return _duration == rhs._duration;
    }

    bool operator!=(const q2as_gtime &rhs) const
    {
        return _duration != rhs._duration;
    }

    bool operator<(const q2as_gtime &rhs) const
    {
        return _duration < rhs._duration;
    }

    bool operator>(const q2as_gtime &rhs) const
    {
        return _duration > rhs._duration;
    }

    bool operator<=(const q2as_gtime &rhs) const
    {
        return _duration <= rhs._duration;
    }

    bool operator>=(const q2as_gtime &rhs) const
    {
        return _duration >= rhs._duration;
    }
};