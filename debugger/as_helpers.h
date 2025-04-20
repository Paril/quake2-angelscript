// MIT Licensed
// see https://github.com/Paril/angelscript-debugger

#pragma once

#include <angelscript.h>
#include <vector>
#include <string_view>
#include <variant>

#ifdef __cpp_lib_format
#include <format>
namespace fmt = std;
#else
#include <fmt/format.h>
#endif

// simple std::expected-like
template<typename T>
struct asIDBExpected
{
private:
    std::variant<std::string_view, T> data;

public:
    constexpr asIDBExpected() :
        data("unknown error")
    {
    }

    constexpr asIDBExpected(const std::string_view v) :
        data(std::in_place_index<0>, v)
    {
    }

    constexpr asIDBExpected(T &&v) :
        data(std::in_place_index<1>, std::move(v))
    {
    }

    constexpr asIDBExpected(const T &v) :
        data(std::in_place_index<1>, v)
    {
    }

    constexpr asIDBExpected(asIDBExpected<void> &&v);

    asIDBExpected(const asIDBExpected<T> &) = default;
    asIDBExpected(asIDBExpected<T> &&) = default;
    asIDBExpected &operator=(const asIDBExpected<T> &) = default;
    asIDBExpected &operator=(asIDBExpected<T> &&) = default;

    constexpr asIDBExpected &operator=(const T &v)
    {
        data = v;
        return *this;
    }

    constexpr asIDBExpected &operator=(T &&v)
    {
        data = std::move(v);
        return *this;
    }

    constexpr bool has_value() const
    {
        return data.index() == 1;
    }
    constexpr explicit operator bool() const
    {
        return has_value();
    }

    constexpr const std::string_view &error() const
    {
        return std::get<0>(data);
    }
    constexpr const T &value() const
    {
        return std::get<1>(data);
    }
    constexpr T &value()
    {
        return std::get<1>(data);
    }
};

template<>
struct asIDBExpected<void>
{
private:
    std::string_view err;

public:
    constexpr asIDBExpected() :
        err("unknown error")
    {
    }

    constexpr asIDBExpected(const std::string_view v) :
        err(v)
    {
    }

    constexpr const std::string_view &error() const
    {
        return err;
    }
};

template<typename T>
constexpr asIDBExpected<T>::asIDBExpected(asIDBExpected<void> &&v) :
    data(std::in_place_index<0>, v.error())
{
}

template<class E>
asIDBExpected(E) -> asIDBExpected<void>;

// helper class that is similar to an any,
// storing a value of any type returned by AS
// and managing the ref count.
struct asIDBValue
{
public:
    asIScriptEngine *engine = nullptr;
    int              typeId = 0;
    asITypeInfo     *type = nullptr;

    union {
        asBYTE  u8;
        asWORD  u16;
        asDWORD u32;
        asQWORD u64;
        float   flt;
        double  dbl;
        void   *obj;
    } value {};

    asIDBValue() = default;
    asIDBValue(asIScriptEngine *engine, void *ptr, int typeId, bool reference = false);
    asIDBValue(const asIDBValue &other);
    asIDBValue(asIDBValue &&other) noexcept;

    asIDBValue &operator=(const asIDBValue &other);
    asIDBValue &operator=(asIDBValue &&other) noexcept;

    ~asIDBValue();
    void Release();

    bool IsValid() const
    {
        return typeId != 0;
    }

    template<typename T>
    T *GetPointer(bool as_reference = false) const
    {
        if (typeId == 0)
            return nullptr;
        else if (typeId & asTYPEID_MASK_OBJECT)
        {
            if ((typeId & asTYPEID_OBJHANDLE) && as_reference)
                return reinterpret_cast<T *>(const_cast<void **>(&value.obj));
            return reinterpret_cast<T *>(value.obj);
        }
        return reinterpret_cast<T *>(const_cast<asQWORD *>(&value.u64));
    }

    void SetArgument(asIScriptContext *ctx, asUINT index) const;
};

// helper class to deal with foreach iteration.
class asIDBObjectIteratorHelper
{
public:
    asITypeInfo                     *type;
    void                            *obj;
    asIScriptFunction               *opForBegin, *opForEnd, *opForNext;
    std::vector<asIScriptFunction *> opForValues;

    asITypeInfo *iteratorType = nullptr;
    int          iteratorTypeId = 0;

    std::string_view error;

    asIDBObjectIteratorHelper(asITypeInfo *type, void *obj);

    constexpr bool IsValid() const
    {
        return opForBegin != nullptr;
    }
    constexpr explicit operator bool() const
    {
        return IsValid();
    }

    // individual access
    asIDBValue Begin(asIScriptContext *ctx) const;
    void       Value(asIScriptContext *ctx, const asIDBValue &val, size_t index) const;
    asIDBValue Next(asIScriptContext *ctx, const asIDBValue &val) const;
    bool       End(asIScriptContext *ctx, const asIDBValue &val) const;

    // O(n) helper for length
    size_t CalculateLength(asIScriptContext *ctx) const;

private:
    bool Validate();
};
