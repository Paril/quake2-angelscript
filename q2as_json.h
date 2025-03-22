#pragma once

#include "q2as_local.h"

#define YYJSON_DISABLE_UTILS 1
#define YYJSON_DISABLE_UTF8_VALIDATION 1

#include "yyjson.h"

#include <string_view>

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
    bool is_int() const { return get_valid() && yyjson_is_int(val); }
    bool is_sint() const { return get_valid() && yyjson_is_sint(val); }
    bool is_uint() const { return get_valid() && yyjson_is_uint(val); }
    bool is_real() const { return get_valid() && yyjson_is_real(val); }
    bool is_null() const { return get_valid() && yyjson_is_null(val); }
    bool is_num() const { return get_valid() && yyjson_is_num(val); }

    // "extended" integer api, because the original one is silly


    // value fetch
    bool get_bool() const { if (!get_valid()) return false; return yyjson_get_bool(val); }
    uint64_t get_uint() const { if (!get_valid()) return 0; return yyjson_get_uint(val); }
    int64_t get_sint() const { if (!get_valid()) return 0; return yyjson_get_sint(val); }
    int32_t get_int() const { if (!get_valid()) return 0; return yyjson_get_int(val); }
    double get_real() const { if (!get_valid()) return 0; return yyjson_get_real(val); }
    double get_num() const { if (!get_valid()) return 0; return yyjson_get_num(val); }
    std::string get_str() const { if (!get_valid() || !is_str()) return ""; return std::string(yyjson_get_str(val), get_length()); }
    uint64_t get_length() const { if (!get_valid()) return 0; return yyjson_get_len(val); }

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