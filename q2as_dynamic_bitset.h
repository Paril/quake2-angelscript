#pragma once

#include <stdexcept>
#include <type_traits>
#include <vector>

struct dynamic_bitset
{
    std::vector<bool> _bitset;

    // zero-allocation
    dynamic_bitset()
    {
    }

    // pre-allocate for n bits
    dynamic_bitset(unsigned int n)
    {
        _bitset.reserve(n);
    }

    // Copy
    dynamic_bitset(const dynamic_bitset& in)
    {
        _bitset = in._bitset;
    }

    // copy-assign
    dynamic_bitset& operator=(const dynamic_bitset& in)
    {
        _bitset = in._bitset;
    }

    // resize internal array for 0 bits (no dealloc, like vector.clear())
    void clear()
    {
        _bitset.clear();
    }

    // resize internal array for n bits
    void resize(unsigned int n)
    {
        _bitset.resize(n);
    }


    // return internal array size in bits
    unsigned int size() const
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
    bool get_bit(unsigned int i) const
    {
        return _bitset[i];
    }

    // set bit, resizing if necessary
    void set_bit(unsigned int i, bool v)
    {
        if (i >= _bitset.size())
        {
            _bitset.resize(i + 1);
        }

        _bitset[i] = v;
    }

    // fetch bit (index operator)
    bool operator[](unsigned int i) const
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
    bool operator==(const dynamic_bitset& in) const
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
};