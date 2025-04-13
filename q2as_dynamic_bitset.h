#pragma once

#include <stdexcept>
#include <type_traits>
#include <vector>

// TODO: use optimized uint32-backed bitset
struct dynamic_bitset
{
    std::vector<bool> _bitset;

    // zero-allocation
    dynamic_bitset() = default;

    ~dynamic_bitset()
    {
    }

    // pre-allocate for n bits
    explicit dynamic_bitset(uint32_t n)
    {
        _bitset.resize(n);
    }

    // load bits from string
    // TODO: compress this a bit more efficiently
    // maybe using nibbles
    explicit dynamic_bitset(const std::string_view str)
    {
        _bitset.resize(str.size());

        for (size_t i = 0; i < str.size(); i++)
            _bitset[i] = str[i] == '1';
    }

    // Copy
    dynamic_bitset(const dynamic_bitset &in) = default;

    // copy-assign
    dynamic_bitset &operator=(const dynamic_bitset &in) = default;

    // resize internal array for 0 bits (no dealloc, like vector.clear())
    void clear()
    {
        _bitset.clear();
    }

    // resize internal array for n bits
    void resize(uint32_t n)
    {
        _bitset.resize(n);
    }


    // return internal array size in bits
    uint32_t size() const
    {
        return _bitset.size();
    }

    // set all bits to specified value
    void set_all(bool v)
    {
        std::fill(_bitset.begin(), _bitset.end(), v);
    }

    // flip all bits
    void flip_all()
    {
        for (size_t i = 0; i < _bitset.size(); ++i)
        {
            _bitset[i] = !_bitset[i];
        }
    }

    // fetch bit
    bool get_bit(uint32_t i) const
    {
        return _bitset[i];
    }

    // set bit, resizing if necessary
    void set_bit(uint32_t i, bool v)
    {
        if (i >= _bitset.size())
        {
            _bitset.resize((size_t) i + 1);
        }

        _bitset[i] = v;
    }

    // fetch bit (index operator)
    bool operator[](uint32_t i) const
    {
        return _bitset[i];
    }

    // return true if any bit is 1
    bool any() const
    {
        bool result = false;

        for (bool b : _bitset)
        {
            if (b)
            {
                result = true;
                break;
            }
        }

        return result;
    }

    // return true if all bits are 1
    bool all() const
    {
        bool result = true;

        for (bool b : _bitset)
        {
            if (!b)
            {
                result = false;
                break;
            }
        }

        return result;
    }

    // return true if all bits are 0
    bool none() const
    {
        bool result = true;

        for (bool b : _bitset)
        {
            if (b)
            {
                result = false;
                break;
            }
        }

        return result;
    }

    // return true if sizes match and bits are equal
    bool operator==(const dynamic_bitset &in) const
    {
        if (_bitset.size() != in._bitset.size())
        {
            return false;
        }

        for (size_t i = 0; i < _bitset.size(); ++i)
        {
            if (_bitset[i] != in._bitset[i])
            {
                return false;
            }
        }

        return true;
    }
    
    // TODO: compress this a bit more efficiently
    // maybe using nibbles
    std::string to_string() const
    {
        std::string s(_bitset.size(), '0');

        for (size_t i = 0; i < s.size(); i++)
            if (_bitset[i])
                s[i] = '1';

        return s;
    }

    uint32_t opForBegin() const
    {
        return 0;
    }

    uint32_t opForNext(uint32_t v) const
    {
        return v + 1;
    }

    bool opForValue(uint32_t v) const
    {
        return (*this)[v];
    }

    bool opForEnd(uint32_t v) const
    {
        return v >= _bitset.size();
    }
};