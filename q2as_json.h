#pragma once

#include "q2as_local.h"

#define YYJSON_DISABLE_UTILS 1
#define YYJSON_DISABLE_UTF8_VALIDATION 1

#include "yyjson.h"

#include <string_view>

template<typename TargetType, typename SourceType>
bool q2as_type_in_range(SourceType value)
{
    // Prevent bool as TargetType or SourceType to avoid edge cases
    static_assert(!std::is_same_v<TargetType, bool>, "TargetType cannot be bool");
    static_assert(!std::is_same_v<SourceType, bool>, "SourceType cannot be bool");

    if (std::is_same_v<TargetType, SourceType>)
    {
        return true;
    }

    constexpr bool is_target_integer = std::numeric_limits<TargetType>::is_integer;
    constexpr bool is_source_integer = std::numeric_limits<SourceType>::is_integer;
    constexpr bool is_target_signed = std::numeric_limits<TargetType>::is_signed;
    constexpr bool is_source_signed = std::numeric_limits<SourceType>::is_signed;

    constexpr TargetType max = std::numeric_limits<TargetType>::max();
    constexpr TargetType min = std::numeric_limits<TargetType>::lowest();

    // Target and Source are integers
    if constexpr (is_target_integer && is_source_integer)
    {
        if constexpr (is_target_signed && is_source_signed)
        {
            return value <= max && value >= min;
        }

        if constexpr (!is_target_signed && !is_source_signed)
        {
            return value <= max;
        }

        if constexpr (is_target_signed && !is_source_signed)
        {
            return value <= static_cast<SourceType>(max);
        }

        if constexpr (!is_target_signed && is_source_signed)
        {
            return value >= 0 && static_cast<uint64_t>(value) <= static_cast<uint64_t>(max);
        }
    }

    // Both floating-point
    if constexpr (!is_target_integer && !is_source_integer)
    {
        if constexpr (std::is_same_v<TargetType, float>)
        {
            float f_value = static_cast<float>(value);

            // Check for loss of precision.
            if (value != static_cast<double>(f_value))
            {
                return false;
            }
        }

        return value <= max && value >= min;
    }

    // Integer to floating point.
    if constexpr (!is_target_integer && is_source_integer)
    {
        if constexpr (std::is_same_v<TargetType, float>)
        {
            float f_value = static_cast<float>(value);
            
            // Check for loss of precision.
            if (value != static_cast<double>(f_value))
            {
                return false;
            }

            return f_value <= max && f_value >= min;
        }
        else
        {
            double d_value = static_cast<double>(value);
            
            // Check for loss of precision.
            if (static_cast<SourceType>(static_cast<double>(value)) != value)
            {
                return false;
            }

            return d_value <= max && d_value >= min;
        }
    }

    // Floating point to integer
    if constexpr (is_target_integer && !is_source_integer)
    {
        // Don't allow decimals
        if (std::trunc(value) != value) 
        {
            return false;
        }

        if (is_target_signed)
        {
            double double_max = static_cast<double>(max);
            double double_min = static_cast<double>(min);

            return value <= double_max && value >= double_min;
        }
        
        return value >= 0 && value <= static_cast<double>(max);    
    }

    // Should not hit this.
    return false;
}

template<typename T>
bool q2as_type_can_be(yyjson_mut_val* val)
{
    if (yyjson_mut_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_UINT))
    {
        return q2as_type_in_range<T, uint64_t>(val->uni.u64);
    }
    else if (yyjson_mut_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_SINT))
    {
        return q2as_type_in_range<T, int64_t>(val->uni.i64);
    }
    else if (yyjson_mut_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_REAL))
    {
        return q2as_type_in_range<T, double>(val->uni.f64);
    }

    return false;
}

template<typename T>
bool q2as_type_can_be(yyjson_val* val)
{
    if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_UINT))
    {
        return q2as_type_in_range<T, uint64_t>(val->uni.u64);
    }
    else if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_SINT))
    {
        return q2as_type_in_range<T, int64_t>(val->uni.i64);
    }
    else if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_REAL))
    {
        return q2as_type_in_range<T, double>(val->uni.f64);
    }

    return false;
}

template<typename T>
T q2as_get_value(yyjson_val* val)
{
    if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_UINT))
    {
        return (T)(val->uni.u64);
    }
    else if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_SINT))
    {
        return (T)(val->uni.i64);
    }
    else if (yyjson_get_tag(val) == (YYJSON_TYPE_NUM | YYJSON_SUBTYPE_REAL))
    {
        return (T)(val->uni.f64);
    }

    return 0;
}

struct q2as_yyjson_mut_doc;
struct q2as_yyjson_mut_val;
struct q2as_yyjson_doc;
struct q2as_yyjson_val;

struct q2as_yyjson_mut_val
{
    yyjson_mut_val *val = nullptr;         // always non-null, but...
    std::weak_ptr<yyjson_mut_doc> doc_ref; // ...will be empty if the doc is gone (who backs our memory)

    q2as_yyjson_mut_val() = default;
    q2as_yyjson_mut_val(const q2as_yyjson_mut_val &) = default;
    q2as_yyjson_mut_val(q2as_yyjson_mut_val &&) = default;
    q2as_yyjson_mut_val(yyjson_mut_val *val, q2as_yyjson_mut_doc *d);
    q2as_yyjson_mut_val(yyjson_mut_val *val, std::weak_ptr<yyjson_mut_doc> doc_ref) :
        val(val),
        doc_ref(doc_ref)
    {
    }

    q2as_yyjson_mut_val &operator=(const q2as_yyjson_mut_val &) = default;
    q2as_yyjson_mut_val &operator=(q2as_yyjson_mut_val &&) = default;

    bool get_valid() const
    {
        return !doc_ref.expired();
    }

    bool check_expire_and_throw() const;
    
    // type checking
    bool is_obj() const { return get_valid() && yyjson_mut_is_obj(val); }
    bool is_arr() const { return get_valid() && yyjson_mut_is_arr(val); }
    bool is_ctn() const { return get_valid() && yyjson_mut_is_ctn(val); }
    bool is_true() const { return get_valid() && yyjson_mut_is_true(val); }
    bool is_false() const { return get_valid() && yyjson_mut_is_false(val); }
    bool is_bool() const { return get_valid() && yyjson_mut_is_bool(val); }
    bool is_str() const { return get_valid() && yyjson_mut_is_str(val); }
    bool is_uint8() const { return get_valid() && q2as_type_can_be<uint8_t>(val); }
    bool is_uint16() const { return get_valid() && q2as_type_can_be<uint16_t>(val);}
    bool is_uint32() const { return get_valid() && q2as_type_can_be<uint32_t>(val); }
    bool is_uint64() const { return get_valid() && q2as_type_can_be<uint64_t>(val); }
    bool is_int8() const { return get_valid() && q2as_type_can_be<int8_t>(val); }
    bool is_int16() const { return get_valid() && q2as_type_can_be<int16_t>(val); }
    bool is_int32() const { return get_valid() && q2as_type_can_be<int32_t>(val); }
    bool is_int64() const { return get_valid() && q2as_type_can_be<int64_t>(val); }
    bool is_float() const { return get_valid() && q2as_type_can_be<float>(val); }
    bool is_double() const { return get_valid() && q2as_type_can_be<double>(val); }
    bool is_int() const { return get_valid() && yyjson_mut_is_int(val); }
    bool is_sint() const { return get_valid() && yyjson_mut_is_sint(val); }
    bool is_uint() const { return get_valid() && yyjson_mut_is_uint(val); }
    bool is_real() const { return get_valid() && yyjson_mut_is_real(val); }
    bool is_null() const { return get_valid() && yyjson_mut_is_null(val); }
    bool is_num() const { return get_valid() && yyjson_mut_is_num(val); }
    
    // array stuff
    bool arr_insert(q2as_yyjson_mut_val v, uint64_t index) { if (check_expire_and_throw()) return false; return yyjson_mut_arr_insert(val, v.val, index); }
    bool arr_append(q2as_yyjson_mut_val v) { if (check_expire_and_throw()) return false; return yyjson_mut_arr_append(val, v.val); }
    bool arr_prepend(q2as_yyjson_mut_val v) { if (check_expire_and_throw()) return false; return yyjson_mut_arr_prepend(val, v.val); }
    q2as_yyjson_mut_val arr_replace(uint64_t index, q2as_yyjson_mut_val v)
    {
        if (check_expire_and_throw()) return {};

        yyjson_mut_val *result = yyjson_mut_arr_replace(val, index, v.val);

        if (!result) return {};

        return q2as_yyjson_mut_val(result, doc_ref);
    }
    q2as_yyjson_mut_val arr_remove(uint64_t index)
    {
        if (check_expire_and_throw()) return {};

        yyjson_mut_val *result = yyjson_mut_arr_remove(val, index);

        if (!result) return {};

        return q2as_yyjson_mut_val(result, doc_ref);
    }
    q2as_yyjson_mut_val arr_remove_first()
    {
        if (check_expire_and_throw()) return {};

        yyjson_mut_val *result = yyjson_mut_arr_remove_first(val);

        if (!result) return {};

        return q2as_yyjson_mut_val(result, doc_ref);
    }
    q2as_yyjson_mut_val arr_remove_last()
    {
        if (check_expire_and_throw()) return {};

        yyjson_mut_val *result = yyjson_mut_arr_remove_last(val);

        if (!result) return {};

        return q2as_yyjson_mut_val(result, doc_ref);
    }
    bool arr_remove_range(uint64_t index, uint64_t len)
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_arr_remove_range(val, index, len);
    }
    bool arr_clear()
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_arr_clear(val);
    }
    uint64_t arr_size() const
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_arr_size(val);
    }

    // object stuff
    bool obj_add(const std::string &key, q2as_yyjson_mut_val v)
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_add(val, yyjson_mut_strncpy(doc_ref.lock().get(), key.c_str(), key.size()), v.val);
    }
    bool obj_put(const std::string &key, q2as_yyjson_mut_val v)
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_put(val, yyjson_mut_strncpy(doc_ref.lock().get(), key.c_str(), key.size()), v.val);
    }
    bool obj_remove(const std::string &key)
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_remove_strn(val, key.c_str(), key.size());
    }
    bool obj_rename_key(const std::string &oldkey, const std::string &newkey)
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_rename_keyn(doc_ref.lock().get(), val, oldkey.c_str(), oldkey.size(), newkey.c_str(), newkey.size());
    }
    bool obj_clear()
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_clear(val);
    }
    uint64_t obj_size() const
    {
        if (check_expire_and_throw()) return false;

        return yyjson_mut_obj_size(val);
    }

    // stringify
    std::string as_string() const;
};

struct q2as_yyjson_mut_doc : q2as_ref_t
{
    std::shared_ptr<yyjson_mut_doc> doc;

    // create new document
    q2as_yyjson_mut_doc();

    // copy from immutable
    q2as_yyjson_mut_doc(const q2as_yyjson_doc *src_doc);

    ~q2as_yyjson_mut_doc()
    {
    }

    char *as_string(size_t *out_size) const;

    std::string as_string() const;

    q2as_yyjson_mut_val get_root()
    {
        return { yyjson_mut_doc_get_root(doc.get()), this };
    }

    void set_root(const q2as_yyjson_mut_val &v)
    {
        if (v.check_expire_and_throw())
            return;

        yyjson_mut_doc_set_root(doc.get(), v.val);
    }

    void set_str_pool_size(uint64_t len)
    {
        yyjson_mut_doc_set_str_pool_size(doc.get(), len);
    }

    void set_val_pool_size(uint64_t len)
    {
        yyjson_mut_doc_set_val_pool_size(doc.get(), len);
    }
    
    q2as_yyjson_mut_val mut_null() { return q2as_yyjson_mut_val(yyjson_mut_null(doc.get()), this); }
    q2as_yyjson_mut_val mut_true() { return q2as_yyjson_mut_val(yyjson_mut_true(doc.get()), this); }
    q2as_yyjson_mut_val mut_false() { return q2as_yyjson_mut_val(yyjson_mut_false(doc.get()), this); }
    q2as_yyjson_mut_val mut_bool(bool v) { return q2as_yyjson_mut_val(yyjson_mut_bool(doc.get(), v), this); }
    q2as_yyjson_mut_val mut_uint(uint64_t v) { return q2as_yyjson_mut_val(yyjson_mut_uint(doc.get(), v), this); }
    q2as_yyjson_mut_val mut_sint(int64_t v) { return q2as_yyjson_mut_val(yyjson_mut_sint(doc.get(), v), this); }
    q2as_yyjson_mut_val mut_int(int64_t v) { return q2as_yyjson_mut_val(yyjson_mut_int(doc.get(), v), this); }
    q2as_yyjson_mut_val mut_real(double v) { return q2as_yyjson_mut_val(yyjson_mut_real(doc.get(), v), this); }
    q2as_yyjson_mut_val mut_strl(const std::string &v, size_t len) { return q2as_yyjson_mut_val(yyjson_mut_strncpy(doc.get(), v.data(), min(len, v.size())), this); }
    q2as_yyjson_mut_val mut_str(const std::string &v) { return q2as_yyjson_mut_val(yyjson_mut_strncpy(doc.get(), v.data(), v.size()), this); }
    q2as_yyjson_mut_val mut_obj() { return q2as_yyjson_mut_val(yyjson_mut_obj(doc.get()), this); }
    q2as_yyjson_mut_val mut_arr() { return q2as_yyjson_mut_val(yyjson_mut_arr(doc.get()), this); }

    q2as_yyjson_mut_val val(bool v) { return q2as_yyjson_mut_val(yyjson_mut_bool(doc.get(), v), this); }
    q2as_yyjson_mut_val val(uint8_t v) { return q2as_yyjson_mut_val(yyjson_mut_uint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(uint16_t v) { return q2as_yyjson_mut_val(yyjson_mut_uint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(uint32_t v) { return q2as_yyjson_mut_val(yyjson_mut_uint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(uint64_t v) { return q2as_yyjson_mut_val(yyjson_mut_uint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(int8_t v) { return q2as_yyjson_mut_val(yyjson_mut_sint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(int16_t v) { return q2as_yyjson_mut_val(yyjson_mut_sint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(int32_t v) { return q2as_yyjson_mut_val(yyjson_mut_sint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(int64_t v) { return q2as_yyjson_mut_val(yyjson_mut_sint(doc.get(), v), this); }
    q2as_yyjson_mut_val val(float v) { return q2as_yyjson_mut_val(yyjson_mut_real(doc.get(), v), this); }
    q2as_yyjson_mut_val val(double v) { return q2as_yyjson_mut_val(yyjson_mut_real(doc.get(), v), this); }
};

struct q2as_yyjson_val
{
    yyjson_val *val = nullptr;         // always non-null, but...
    std::weak_ptr<yyjson_doc> doc_ref; // ...will be empty if the doc is gone (who backs our memory)

    q2as_yyjson_val() = default;
    q2as_yyjson_val(const q2as_yyjson_val &) = default;
    q2as_yyjson_val(q2as_yyjson_val &&) = default;
    q2as_yyjson_val(yyjson_val *val, q2as_yyjson_doc *d);
    q2as_yyjson_val(yyjson_val *val, std::weak_ptr<yyjson_doc> doc_ref);

    q2as_yyjson_val &operator=(const q2as_yyjson_val &) = default;
    q2as_yyjson_val &operator=(q2as_yyjson_val &&) = default;

    bool get_valid() const
    {
        return !doc_ref.expired();
    }

    bool check_expire_and_throw() const;
    
    // type checking
    bool is_obj() const { return get_valid() && yyjson_is_obj(val); }
    bool is_arr() const { return get_valid() && yyjson_is_arr(val); }
    bool is_ctn() const { return get_valid() && yyjson_is_ctn(val); }
    bool is_true() const { return get_valid() && yyjson_is_true(val); }
    bool is_false() const { return get_valid() && yyjson_is_false(val); }
    bool is_bool() const { return get_valid() && yyjson_is_bool(val); }
    bool is_str() const { return get_valid() && yyjson_is_str(val); }
    bool is_uint8() const { return get_valid() && q2as_type_can_be<uint8_t>(val); }
    bool is_uint16() const { return get_valid() && q2as_type_can_be<uint16_t>(val); }
    bool is_uint32() const { return get_valid() && q2as_type_can_be<uint32_t>(val); }
    bool is_uint64() const { return get_valid() && q2as_type_can_be<uint64_t>(val); }
    bool is_int8() const { return get_valid() && q2as_type_can_be<int8_t>(val); }
    bool is_int16() const { return get_valid() && q2as_type_can_be<int16_t>(val); }
    bool is_int32() const { return get_valid() && q2as_type_can_be<int32_t>(val); }
    bool is_int64() const { return get_valid() && q2as_type_can_be<int64_t>(val); }
    bool is_float() const { return get_valid() && q2as_type_can_be<float>(val); }
    bool is_double() const { return get_valid() && q2as_type_can_be<double>(val); }
    bool is_int() const { return get_valid() && yyjson_is_int(val); }
    bool is_sint() const { return get_valid() && yyjson_is_sint(val); }
    bool is_uint() const { return get_valid() && yyjson_is_uint(val); }
    bool is_real() const { return get_valid() && yyjson_is_real(val); }
    bool is_null() const { return get_valid() && yyjson_is_null(val); }
    bool is_num() const { return get_valid() && yyjson_is_num(val); }

    // "extended" integer api, because the original one is silly


    // value fetch
    bool get_bool() const { if (!get_valid()) return false; return yyjson_get_bool(val); }
    uint8_t get_uint8() const   { if (!get_valid()) return 0; return q2as_get_value<uint8_t>(val); }
    uint16_t get_uint16() const { if (!get_valid()) return 0; return q2as_get_value<uint16_t>(val); }
    uint32_t get_uint32() const { if (!get_valid()) return 0; return q2as_get_value<uint32_t>(val); }
    uint64_t get_uint64() const { if (!get_valid()) return 0; return q2as_get_value<uint64_t>(val); }
    int8_t get_int8() const     { if (!get_valid()) return 0; return q2as_get_value<int8_t>(val); }
    int16_t get_int16() const   { if (!get_valid()) return 0; return q2as_get_value<int16_t>(val); }
    int32_t get_int32() const   { if (!get_valid()) return 0; return q2as_get_value<int32_t>(val); }
    int64_t get_int64() const   { if (!get_valid()) return 0; return q2as_get_value<int64_t>(val); }
    float get_float() const { if (!get_valid()) return 0; return q2as_get_value<float>(val); }
    double get_double() const { if (!get_valid()) return 0; return q2as_get_value<double>(val); }
    void get_uint8(uint8_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint8_t>(val); }
    void get_uint16(uint16_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint16_t>(val); }
    void get_uint32(uint32_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint32_t>(val); }
    void get_uint64(uint64_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint64_t>(val); }
    void get_int8(int8_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<int8_t>(val); }
    void get_int16(int16_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<int16_t>(val); }
    void get_int32(int32_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<int32_t>(val); }
    void get_int64(int64_t &out) const { if (!get_valid()) out = 0; out = q2as_get_value<int64_t>(val); }
    void get_float(float& out) const { if (!get_valid()) out = 0; out = q2as_get_value<float>(val); }
    void get_double(double &out) const { if (!get_valid()) out = 0; out = q2as_get_value<double>(val); }
    uint64_t get_uint() const { if (!get_valid()) return 0; return yyjson_get_uint(val); }
    int64_t get_sint() const { if (!get_valid()) return 0; return yyjson_get_sint(val); }
    int32_t get_int() const { if (!get_valid()) return 0; return yyjson_get_int(val); }
    double get_real() const { if (!get_valid()) return 0; return yyjson_get_real(val); }
    double get_num() const { if (!get_valid()) return 0; return yyjson_get_num(val); }
    std::string get_str() const { if (!get_valid() || !is_str()) return ""; return std::string(yyjson_get_str(val), get_length()); }
    uint64_t get_length() const { if (!get_valid()) return 0; return yyjson_get_len(val); }

    void get(bool &out) const { if (!get_valid()) out = false; out = yyjson_get_bool(val); }
    void get(uint8_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint8_t>(val); }
    void get(uint16_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint16_t>(val); }
    void get(uint32_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint32_t>(val); }
    void get(uint64_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<uint64_t>(val); }
    void get(int8_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<int8_t>(val); }
    void get(int16_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<int16_t>(val); }
    void get(int32_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<int32_t>(val); }
    void get(int64_t& out) const { if (!get_valid()) out = 0; out = q2as_get_value<int64_t>(val); }
    void get(float& out) const { if (!get_valid()) out = 0; out = q2as_get_value<float>(val); }
    void get(double& out) const { if (!get_valid()) out = 0; out = q2as_get_value<double>(val); }
    void get(void* ref, int refTypeId) const 
    { 
        auto ctx = asGetActiveContext();
        auto type = ctx->GetEngine()->GetTypeInfoById(refTypeId);

        if (!(type->GetFlags() & asOBJ_ENUM))
        {
            ctx->SetException("Type is not an enum");
            return;
        }

        switch (type->GetTypedefTypeId())
        {
            case asTYPEID_INT8:
                get(*(int8_t*)ref);
                break;
            case asTYPEID_UINT8:
                get(*(uint8_t*)ref);
                break;
            case asTYPEID_INT16:
                get(*(int16_t*)ref);
                break;
            case asTYPEID_UINT16:
                get(*(uint16_t*)ref);
                break;
            case asTYPEID_INT32:
                get(*(int32_t*)ref);
                break;
            case asTYPEID_UINT32:
                get(*(uint32_t*)ref);
                break;
            case asTYPEID_INT64:
                get(*(int64_t*)ref);
                break;
            case asTYPEID_UINT64:
                get(*(uint64_t*)ref);
                break;
            default:
                ctx->SetException("Unsupported type");
                return;
        }
    }

    // "extended" integer api, because the original one is silly


    // AS_TODO str equals?

    // array
    q2as_yyjson_val arr_get(uint64_t index) const { if (!get_valid()) return {}; return { yyjson_arr_get(val, index), doc_ref }; }
    q2as_yyjson_val arr_get_first() const { if (!get_valid()) return {}; return { yyjson_arr_get_first(val), doc_ref }; }
    q2as_yyjson_val arr_get_last() const { if (!get_valid()) return {}; return { yyjson_arr_get_last(val), doc_ref }; }

    // object
    q2as_yyjson_val obj_get(const std::string &key) const { if (!get_valid()) return {}; return { yyjson_obj_getn(val, key.c_str(), key.size()), doc_ref }; }
    
    // stringify
    std::string as_string();
};

struct q2as_yyjson_doc : q2as_ref_t
{
    std::shared_ptr<yyjson_doc> doc;

    // null document
    q2as_yyjson_doc()
    {
    }

    // parse doc from string view
    q2as_yyjson_doc(std::string_view view);

    // parse doc from string
    q2as_yyjson_doc(const std::string &str) :
        q2as_yyjson_doc(std::string_view(str))
    {
    }

    // copy from mutable
    q2as_yyjson_doc(const q2as_yyjson_mut_doc *doc);

    ~q2as_yyjson_doc()
    {
    }
    
    q2as_yyjson_val get_root() { return q2as_yyjson_val { yyjson_doc_get_root(doc.get()), this }; }
    uint64_t get_read_size() const { return yyjson_doc_get_read_size(doc.get()); }
    uint64_t get_val_count() const { return yyjson_doc_get_val_count(doc.get()); }

    // stringify
    char *as_string(size_t *out_size) const;
    std::string as_string() const;
};

// array iterator
// AS_TODO steal the "foreach" macro
// it's probably faster
struct q2as_yyjson_arr_iter
{
    q2as_yyjson_val arr;
    yyjson_arr_iter iter {};

    q2as_yyjson_arr_iter(q2as_yyjson_val arr) :
        arr(arr),
        iter(yyjson_arr_iter_with(arr.get_valid() ? arr.val : nullptr))
    {
    }
    
    q2as_yyjson_arr_iter() = default;
    q2as_yyjson_arr_iter(const q2as_yyjson_arr_iter &) = default;
    q2as_yyjson_arr_iter(q2as_yyjson_arr_iter &&) = default;
    q2as_yyjson_arr_iter &operator=(const q2as_yyjson_arr_iter &) = default;
    q2as_yyjson_arr_iter &operator=(q2as_yyjson_arr_iter &&) = default;

    q2as_yyjson_val get_next()
    {
        if (arr.check_expire_and_throw())
            return {};

        return { yyjson_arr_iter_next(&iter), arr.doc_ref };
    }

    bool has_next()
    {
        if (arr.check_expire_and_throw())
            return {};

        return yyjson_arr_iter_has_next(&iter);
    }
};

// object iterator
// AS_TODO steal the "foreach" macro
// it's probably faster
struct q2as_yyjson_obj_iter
{
    q2as_yyjson_val obj;
    yyjson_obj_iter iter {};

    q2as_yyjson_obj_iter(q2as_yyjson_val obj) :
        obj(obj),
        iter(yyjson_obj_iter_with(obj.get_valid() ? obj.val : nullptr))
    {
    }
    
    q2as_yyjson_obj_iter() = default;
    q2as_yyjson_obj_iter(const q2as_yyjson_obj_iter &) = default;
    q2as_yyjson_obj_iter(q2as_yyjson_obj_iter &&) = default;
    q2as_yyjson_obj_iter &operator=(const q2as_yyjson_obj_iter &) = default;
    q2as_yyjson_obj_iter &operator=(q2as_yyjson_obj_iter &&) = default;

    q2as_yyjson_val get_next()
    {
        if (obj.check_expire_and_throw())
            return {};

        return { yyjson_obj_iter_next(&iter), obj.doc_ref };
    }

    q2as_yyjson_val get_val(const q2as_yyjson_val &key)
    {
        // AS_TODO make sure obj and key are the same doc; any
        // way to do this fast?
        if (obj.check_expire_and_throw() ||
            key.check_expire_and_throw() ||
            obj.doc_ref.lock() != key.doc_ref.lock())
            return {};

        return { yyjson_obj_iter_get_val(key.val), obj.doc_ref };
    }

    bool has_next()
    {
        if (obj.check_expire_and_throw())
            return {};

        return yyjson_obj_iter_has_next(&iter);
    }
};