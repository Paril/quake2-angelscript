#include "q2as_json.h"
#include "q2as_game.h"

static yyjson_alc q2as_yyjson_alcs = {
    [](void *, size_t size) { return q2as_sv_state_t::AllocStatic(size); },
    [](void *, void *ptr, size_t old_size, size_t size)
    {
        void *nptr = q2as_sv_state_t::AllocStatic(size);
        memcpy(nptr, ptr, old_size);
        q2as_sv_state_t::FreeStatic(ptr);
        return nptr;
    },
    [](void *, void *ptr) { q2as_sv_state_t::FreeStatic(ptr); }
};

q2as_yyjson_mut_val::q2as_yyjson_mut_val(yyjson_mut_val *val, q2as_yyjson_mut_doc *d) :
    val(val),
    doc_ref(d->doc)
{
}

// mutable doc
bool q2as_yyjson_mut_val::check_expire_and_throw() const
{
    if (!val)
    {
        asGetActiveContext()->SetException("Invalid JSON value");
        return true;
    }
    if (doc_ref.expired())
    {
        asGetActiveContext()->SetException("JSON document expired");
        return true;
    }

    return false;
}

// stringify
std::string q2as_yyjson_mut_val::as_string() const
{
    if (check_expire_and_throw()) return "";

    size_t len;
    char *p = yyjson_mut_val_write_opts(val, YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, &len, nullptr);
    std::string s(p, len);
    q2as_yyjson_alcs.free(nullptr, p);
    return s;
}

// create new document
q2as_yyjson_mut_doc::q2as_yyjson_mut_doc() :
    doc(yyjson_mut_doc_new(&q2as_yyjson_alcs), yyjson_mut_doc_free)
{
}

q2as_yyjson_mut_doc::q2as_yyjson_mut_doc(const q2as_yyjson_doc *src_doc) :
    doc(yyjson_doc_mut_copy(src_doc->doc.get(), &q2as_yyjson_alcs), yyjson_mut_doc_free)
{
}

char *q2as_yyjson_mut_doc::as_string(size_t *out_size) const
{
    return yyjson_mut_write_opts(doc.get(), YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, out_size, nullptr);
}

std::string q2as_yyjson_mut_doc::as_string() const
{
    size_t len;
    char *p = yyjson_mut_write_opts(doc.get(), YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, &len, nullptr);
    std::string s(p, len);
    q2as_yyjson_alcs.free(nullptr, p);
    return s;
}

q2as_yyjson_val::q2as_yyjson_val(yyjson_val *val, std::weak_ptr<yyjson_doc> doc_ref) :
    val(val),
    doc_ref(doc_ref)
{
}

q2as_yyjson_val::q2as_yyjson_val(yyjson_val *val, q2as_yyjson_doc *d) :
    val(val),
    doc_ref(d->doc)
{
}

bool q2as_yyjson_val::check_expire_and_throw() const
{
    if (!val)
    {
        asGetActiveContext()->SetException("Invalid JSON value");
        return true;
    }
    if (doc_ref.expired())
    {
        asGetActiveContext()->SetException("JSON document expired");
        return true;
    }

    return false;
}

std::string q2as_yyjson_val::as_string()
{
    if (!get_valid()) return "";

    size_t len;
    char *p = yyjson_val_write_opts(val, YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, &len, nullptr);
    std::string s(p, len);
    q2as_yyjson_alcs.free(nullptr, p);
    return s;
}

// parse doc from string view
q2as_yyjson_doc::q2as_yyjson_doc(std::string_view view) :
    doc(yyjson_read_opts((char *) view.data(), view.size(), YYJSON_READ_ALLOW_INF_AND_NAN, &q2as_yyjson_alcs, nullptr), yyjson_doc_free)
{
}

// copy from mutable
q2as_yyjson_doc::q2as_yyjson_doc(const q2as_yyjson_mut_doc *doc) :
    doc(yyjson_mut_doc_imut_copy(doc->doc.get(), &q2as_yyjson_alcs), yyjson_doc_free)
{
}

// stringify
char *q2as_yyjson_doc::as_string(size_t *out_size) const
{
    return yyjson_write_opts(doc.get(), YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, out_size, nullptr);
}

std::string q2as_yyjson_doc::as_string() const
{
    size_t len;
    char *p = yyjson_write_opts(doc.get(), YYJSON_WRITE_ALLOW_INF_AND_NAN | YYJSON_WRITE_PRETTY, &q2as_yyjson_alcs, &len, nullptr);
    std::string s(p, len);
    q2as_yyjson_alcs.free(nullptr, p);
    return s;
}

static void Q2AS_RegisterMutableJson(q2as_registry &registry)
{
    // mutable JSON value
    registry
        .type("json_mutval", sizeof(q2as_yyjson_mut_val), asOBJ_VALUE | asOBJ_APP_CLASS_CD)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                      asFUNCTION(Q2AS_init_construct<q2as_yyjson_mut_val>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const json_mutval &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()",                      asFUNCTION(Q2AS_destruct<q2as_yyjson_mut_val>),            asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "json_mutval &opAssign (const json_mutval &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST },

            // functions
            { "bool get_valid() const property", asMETHOD(q2as_yyjson_mut_val, get_valid), asCALL_THISCALL },
            { "string to_string() const",        asMETHOD(q2as_yyjson_mut_val, as_string), asCALL_THISCALL },

            { "bool get_is_obj() const property",   asMETHOD(q2as_yyjson_mut_val,   is_obj), asCALL_THISCALL },
            { "bool get_is_arr() const property",   asMETHOD(q2as_yyjson_mut_val,   is_arr), asCALL_THISCALL },
            { "bool get_is_ctn() const property",   asMETHOD(q2as_yyjson_mut_val,   is_ctn), asCALL_THISCALL },
            { "bool get_is_true() const property",  asMETHOD(q2as_yyjson_mut_val,  is_true), asCALL_THISCALL },
            { "bool get_is_false() const property", asMETHOD(q2as_yyjson_mut_val, is_false), asCALL_THISCALL },
            { "bool get_is_bool() const property",  asMETHOD(q2as_yyjson_mut_val,  is_bool), asCALL_THISCALL },
            { "bool get_is_str() const property",   asMETHOD(q2as_yyjson_mut_val,   is_str), asCALL_THISCALL },

            { "bool get_is_uint8() const property",  asMETHOD(q2as_yyjson_mut_val, is_uint8),  asCALL_THISCALL },
            { "bool get_is_uint16() const property", asMETHOD(q2as_yyjson_mut_val, is_uint16), asCALL_THISCALL },
            { "bool get_is_uint32() const property", asMETHOD(q2as_yyjson_mut_val, is_uint32), asCALL_THISCALL },
            { "bool get_is_uint64() const property", asMETHOD(q2as_yyjson_mut_val, is_uint64), asCALL_THISCALL },
            { "bool get_is_int8() const property",   asMETHOD(q2as_yyjson_mut_val, is_int8),   asCALL_THISCALL },
            { "bool get_is_int16() const property",  asMETHOD(q2as_yyjson_mut_val, is_int16),  asCALL_THISCALL },
            { "bool get_is_int32() const property",  asMETHOD(q2as_yyjson_mut_val, is_int32),  asCALL_THISCALL },
            { "bool get_is_int64() const property",  asMETHOD(q2as_yyjson_mut_val, is_int64),  asCALL_THISCALL },
            { "bool get_is_float() const property",  asMETHOD(q2as_yyjson_mut_val, is_float),  asCALL_THISCALL },
            { "bool get_is_double() const property", asMETHOD(q2as_yyjson_mut_val, is_double), asCALL_THISCALL },

            { "bool get_is_int() const property",  asMETHOD(q2as_yyjson_mut_val,   is_int), asCALL_THISCALL },
            { "bool get_is_uint() const property", asMETHOD(q2as_yyjson_mut_val,  is_uint), asCALL_THISCALL },
            { "bool get_is_sint() const property", asMETHOD(q2as_yyjson_mut_val,  is_sint), asCALL_THISCALL },
            { "bool get_is_real() const property", asMETHOD(q2as_yyjson_mut_val,  is_real), asCALL_THISCALL },
            { "bool get_is_null() const property", asMETHOD(q2as_yyjson_mut_val,  is_null), asCALL_THISCALL },
            { "bool get_is_num() const property",  asMETHOD(q2as_yyjson_mut_val,   is_num), asCALL_THISCALL },

            { "bool arr_insert(json_mutval v, uint64 index)",         asMETHOD(q2as_yyjson_mut_val, arr_insert),       asCALL_THISCALL },
            { "bool arr_append(json_mutval v)",                       asMETHOD(q2as_yyjson_mut_val, arr_append),       asCALL_THISCALL },
            { "bool arr_prepend(json_mutval v)",                      asMETHOD(q2as_yyjson_mut_val, arr_prepend),      asCALL_THISCALL },
            { "json_mutval arr_replace(uint64 index, json_mutval v)", asMETHOD(q2as_yyjson_mut_val, arr_replace),      asCALL_THISCALL },
            { "json_mutval arr_remove_first()",                       asMETHOD(q2as_yyjson_mut_val, arr_remove_first), asCALL_THISCALL },
            { "json_mutval arr_remove_last()",                        asMETHOD(q2as_yyjson_mut_val, arr_remove_last),  asCALL_THISCALL },
            { "bool arr_remove_range(uint64 index, uint64 len)",      asMETHOD(q2as_yyjson_mut_val, arr_remove_range), asCALL_THISCALL },
            { "bool arr_clear()",                                     asMETHOD(q2as_yyjson_mut_val, arr_clear),        asCALL_THISCALL },
            { "uint64 get_arr_size() const property",                 asMETHOD(q2as_yyjson_mut_val, arr_size),         asCALL_THISCALL },

            { "bool obj_add(const string &in, json_mutval v)",           asMETHOD(q2as_yyjson_mut_val, obj_add),        asCALL_THISCALL },
            { "bool obj_put(const string &in, json_mutval v)",           asMETHOD(q2as_yyjson_mut_val, obj_put),        asCALL_THISCALL },
            { "bool obj_remove(const string &in)",                       asMETHOD(q2as_yyjson_mut_val, obj_remove),     asCALL_THISCALL },
            { "bool obj_rename_key(const string &in, const string &in)", asMETHOD(q2as_yyjson_mut_val, obj_rename_key), asCALL_THISCALL },
            { "bool obj_clear()",                                        asMETHOD(q2as_yyjson_mut_val, obj_clear),      asCALL_THISCALL },
            { "uint64 get_obj_size() const property",                    asMETHOD(q2as_yyjson_mut_val, obj_size),       asCALL_THISCALL }
        });

    // AS_TODO iterators?

    // mutable JSON doc
    registry
        .type("json_mutdoc", sizeof(q2as_yyjson_mut_doc), asOBJ_REF)
        .behaviors({
            { asBEHAVE_FACTORY, "json_mutdoc@ f()", asFUNCTION((Q2AS_Factory<q2as_yyjson_mut_doc, q2as_sv_state_t>)), asCALL_GENERIC },
            { asBEHAVE_ADDREF,  "void f()",         asFUNCTION((Q2AS_AddRef<q2as_yyjson_mut_doc>)),                   asCALL_GENERIC },
            { asBEHAVE_RELEASE, "void f()",         asFUNCTION((Q2AS_Release<q2as_yyjson_mut_doc, q2as_sv_state_t>)), asCALL_GENERIC }
        })
        .methods({
            { "json_mutval get_root() property",                   asMETHOD(q2as_yyjson_mut_doc, get_root), asCALL_THISCALL },
            { "void set_root(const json_mutval &in val) property", asMETHOD(q2as_yyjson_mut_doc, set_root), asCALL_THISCALL },

            { "void set_str_pool_size(uint64 len)", asMETHOD(q2as_yyjson_mut_doc, set_str_pool_size), asCALL_THISCALL },
            { "void set_val_pool_size(uint64 len)", asMETHOD(q2as_yyjson_mut_doc, set_val_pool_size), asCALL_THISCALL },

            { "json_mutval val_null()",    asMETHOD(q2as_yyjson_mut_doc, mut_null),  asCALL_THISCALL },
            { "json_mutval val_true()",    asMETHOD(q2as_yyjson_mut_doc, mut_true),  asCALL_THISCALL },
            { "json_mutval val_false()",   asMETHOD(q2as_yyjson_mut_doc, mut_false), asCALL_THISCALL },

            { "json_mutval val(bool)",                       asMETHODPR(q2as_yyjson_mut_doc, val, (bool), q2as_yyjson_mut_val),     asCALL_THISCALL },
            { "json_mutval val(uint8)",                      asMETHODPR(q2as_yyjson_mut_doc, val, (uint8_t), q2as_yyjson_mut_val),  asCALL_THISCALL },
            { "json_mutval val(uint16)",                     asMETHODPR(q2as_yyjson_mut_doc, val, (uint16_t), q2as_yyjson_mut_val), asCALL_THISCALL },
            { "json_mutval val(uint32)",                     asMETHODPR(q2as_yyjson_mut_doc, val, (uint32_t), q2as_yyjson_mut_val), asCALL_THISCALL },
            { "json_mutval val(uint64)",                     asMETHODPR(q2as_yyjson_mut_doc, val, (uint64_t), q2as_yyjson_mut_val), asCALL_THISCALL },
            { "json_mutval val(int8)",                       asMETHODPR(q2as_yyjson_mut_doc, val, (int8_t), q2as_yyjson_mut_val),   asCALL_THISCALL },
            { "json_mutval val(int16)",                      asMETHODPR(q2as_yyjson_mut_doc, val, (int16_t), q2as_yyjson_mut_val),  asCALL_THISCALL },
            { "json_mutval val(int32)",                      asMETHODPR(q2as_yyjson_mut_doc, val, (int32_t), q2as_yyjson_mut_val),  asCALL_THISCALL },
            { "json_mutval val(int64)",                      asMETHODPR(q2as_yyjson_mut_doc, val, (int64_t), q2as_yyjson_mut_val),  asCALL_THISCALL },
            { "json_mutval val(float)",                      asMETHODPR(q2as_yyjson_mut_doc, val, (float), q2as_yyjson_mut_val),    asCALL_THISCALL },
            { "json_mutval val(double)",                     asMETHODPR(q2as_yyjson_mut_doc, val, (double), q2as_yyjson_mut_val),   asCALL_THISCALL },
            { "json_mutval val(const string &in, uint len)", asMETHOD(q2as_yyjson_mut_doc, mut_strl),                               asCALL_THISCALL },
            { "json_mutval val(const string &in)",           asMETHOD(q2as_yyjson_mut_doc, mut_str),                                asCALL_THISCALL },

            { "json_mutval val_obj()",                       asMETHOD(q2as_yyjson_mut_doc, mut_obj),  asCALL_THISCALL },
            { "json_mutval val_arr()",                       asMETHOD(q2as_yyjson_mut_doc, mut_arr),  asCALL_THISCALL },

            { "string to_string() const", asMETHODPR(q2as_yyjson_mut_doc, as_string, () const, std::string), asCALL_THISCALL },
        });
}

void q2as_json_doc_factory_str(asIScriptGeneric *gen)
{
    q2as_yyjson_doc *ptr = reinterpret_cast<q2as_yyjson_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc)));
    *(q2as_yyjson_doc **) gen->GetAddressOfReturnLocation() = ptr;
    new(ptr) q2as_yyjson_doc(*(std::string *) gen->GetArgAddress(0));
}

void q2as_yyjson_arr_iter_from_val(q2as_yyjson_val v, q2as_yyjson_arr_iter *self)
{
    new(self) q2as_yyjson_arr_iter(v);
}

void q2as_yyjson_obj_iter_from_val(q2as_yyjson_val v, q2as_yyjson_obj_iter *self)
{
    new(self) q2as_yyjson_obj_iter(v);
}

static void Q2AS_RegisterImmutableJson(q2as_registry &registry)
{
    // immutable JSON value
    registry
        .type("json_val", sizeof(q2as_yyjson_val), asOBJ_VALUE | asOBJ_APP_CLASS_CD)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                   asFUNCTION(Q2AS_init_construct<q2as_yyjson_val>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const json_val &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_val>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()",                   asFUNCTION(Q2AS_destruct<q2as_yyjson_val>),            asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "json_val &opAssign (const json_val &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_val>), asCALL_CDECL_OBJLAST },

            { "bool get_valid() const property", asMETHOD(q2as_yyjson_val, get_valid), asCALL_THISCALL },
            { "string to_string() const",        asMETHOD(q2as_yyjson_val, as_string), asCALL_THISCALL },

            { "bool get_is_obj() const property",   asMETHOD(q2as_yyjson_val, is_obj), asCALL_THISCALL },
            { "bool get_is_arr() const property",   asMETHOD(q2as_yyjson_val, is_arr), asCALL_THISCALL },
            { "bool get_is_ctn() const property",   asMETHOD(q2as_yyjson_val, is_ctn), asCALL_THISCALL },
            { "bool get_is_true() const property",  asMETHOD(q2as_yyjson_val, is_true), asCALL_THISCALL },
            { "bool get_is_false() const property", asMETHOD(q2as_yyjson_val, is_false), asCALL_THISCALL },
            { "bool get_is_bool() const property",  asMETHOD(q2as_yyjson_val, is_bool), asCALL_THISCALL },
            { "bool get_is_str() const property",   asMETHOD(q2as_yyjson_val, is_str), asCALL_THISCALL },

            { "bool get_is_uint8() const property",  asMETHOD(q2as_yyjson_val, is_uint8),  asCALL_THISCALL },
            { "bool get_is_uint16() const property", asMETHOD(q2as_yyjson_val, is_uint16), asCALL_THISCALL },
            { "bool get_is_uint32() const property", asMETHOD(q2as_yyjson_val, is_uint32), asCALL_THISCALL },
            { "bool get_is_uint64() const property", asMETHOD(q2as_yyjson_val, is_uint64), asCALL_THISCALL },
            { "bool get_is_int8() const property",   asMETHOD(q2as_yyjson_val, is_int8),   asCALL_THISCALL },
            { "bool get_is_int16() const property",  asMETHOD(q2as_yyjson_val, is_int16),  asCALL_THISCALL },
            { "bool get_is_int32() const property",  asMETHOD(q2as_yyjson_val, is_int32),  asCALL_THISCALL },
            { "bool get_is_int64() const property",  asMETHOD(q2as_yyjson_val, is_int64),  asCALL_THISCALL },
            { "bool get_is_float() const property",  asMETHOD(q2as_yyjson_val, is_float),  asCALL_THISCALL },
            { "bool get_is_double() const property", asMETHOD(q2as_yyjson_val, is_double), asCALL_THISCALL },

            { "bool get_is_int() const property",  asMETHOD(q2as_yyjson_val, is_int), asCALL_THISCALL },
            { "bool get_is_uint() const property", asMETHOD(q2as_yyjson_val, is_uint), asCALL_THISCALL },
            { "bool get_is_sint() const property", asMETHOD(q2as_yyjson_val, is_sint), asCALL_THISCALL },
            { "bool get_is_real() const property", asMETHOD(q2as_yyjson_val, is_real), asCALL_THISCALL },
            { "bool get_is_null() const property", asMETHOD(q2as_yyjson_val, is_null), asCALL_THISCALL },
            { "bool get_is_num() const property",  asMETHOD(q2as_yyjson_val, is_num), asCALL_THISCALL },

            { "bool get_bool_() const property", asMETHOD(q2as_yyjson_val,    get_bool), asCALL_THISCALL },

            { "uint8 get_uint8() const property", asMETHODPR(q2as_yyjson_val, get_uint8, () const, uint8_t),      asCALL_THISCALL },
            { "void get_uint8(uint8 &out) const", asMETHODPR(q2as_yyjson_val, get_uint8, (uint8_t &) const, void), asCALL_THISCALL },

            { "uint16 get_uint16() const property", asMETHODPR(q2as_yyjson_val, get_uint16, () const, uint16_t),      asCALL_THISCALL },
            { "void get_uint16(uint16 &out) const", asMETHODPR(q2as_yyjson_val, get_uint16, (uint16_t &) const, void), asCALL_THISCALL },

            { "uint32 get_uint32() const property", asMETHODPR(q2as_yyjson_val, get_uint32, () const, uint32_t),      asCALL_THISCALL },
            { "void get_uint32(uint32 &out) const", asMETHODPR(q2as_yyjson_val, get_uint32, (uint32_t &) const, void), asCALL_THISCALL },

            { "uint64 get_uint64() const property", asMETHODPR(q2as_yyjson_val, get_uint64, () const, uint64_t),      asCALL_THISCALL },
            { "void get_uint64(uint64 &out) const", asMETHODPR(q2as_yyjson_val, get_uint64, (uint64_t &) const, void), asCALL_THISCALL },

            { "int8 get_int8() const property", asMETHODPR(q2as_yyjson_val, get_int8, () const, int8_t),      asCALL_THISCALL },
            { "void get_int8(int8 &out) const", asMETHODPR(q2as_yyjson_val, get_int8, (int8_t &) const, void), asCALL_THISCALL },

            { "int16 get_int16() const property", asMETHODPR(q2as_yyjson_val, get_int16, () const, int16_t),      asCALL_THISCALL },
            { "void get_int16(int16 &out) const", asMETHODPR(q2as_yyjson_val, get_int16, (int16_t &) const, void), asCALL_THISCALL },

            { "int32 get_int32() const property", asMETHODPR(q2as_yyjson_val, get_int32, () const, int32_t),      asCALL_THISCALL },
            { "void get_int32(int32 &out) const", asMETHODPR(q2as_yyjson_val, get_int32, (int32_t &) const, void), asCALL_THISCALL },

            { "int64 get_int64() const property", asMETHODPR(q2as_yyjson_val, get_int64, () const, int64_t),      asCALL_THISCALL },
            { "void get_int64(int64 &out) const", asMETHODPR(q2as_yyjson_val, get_int64, (int64_t &) const, void), asCALL_THISCALL },

            { "float get_float() const property", asMETHODPR(q2as_yyjson_val, get_float, () const, float),      asCALL_THISCALL },
            { "void get_float(float &out) const", asMETHODPR(q2as_yyjson_val, get_float, (float &) const, void), asCALL_THISCALL },

            { "double get_double() const property", asMETHODPR(q2as_yyjson_val, get_double, () const, double),      asCALL_THISCALL },
            { "void get_double(double &out) const", asMETHODPR(q2as_yyjson_val, get_double, (double &) const, void), asCALL_THISCALL },

            { "void get(bool &out) const",   asMETHODPR(q2as_yyjson_val, get, (bool &) const, void),       asCALL_THISCALL },
            { "void get(uint8 &out) const",  asMETHODPR(q2as_yyjson_val, get, (uint8_t &) const, void),    asCALL_THISCALL },
            { "void get(uint16 &out) const", asMETHODPR(q2as_yyjson_val, get, (uint16_t &) const, void),   asCALL_THISCALL },
            { "void get(uint32 &out) const", asMETHODPR(q2as_yyjson_val, get, (uint32_t &) const, void),   asCALL_THISCALL },
            { "void get(uint64 &out) const", asMETHODPR(q2as_yyjson_val, get, (uint64_t &) const, void),   asCALL_THISCALL },
            { "void get(int8 &out) const",   asMETHODPR(q2as_yyjson_val, get, (int8_t &) const, void),     asCALL_THISCALL },
            { "void get(int16 &out) const",  asMETHODPR(q2as_yyjson_val, get, (int16_t &) const, void),    asCALL_THISCALL },
            { "void get(int32 &out) const",  asMETHODPR(q2as_yyjson_val, get, (int32_t &) const, void),    asCALL_THISCALL },
            { "void get(int64 &out) const",  asMETHODPR(q2as_yyjson_val, get, (int64_t &) const, void),    asCALL_THISCALL },
            { "void get(float &out) const",  asMETHODPR(q2as_yyjson_val, get, (float &) const, void),      asCALL_THISCALL },
            { "void get(double &out) const", asMETHODPR(q2as_yyjson_val, get, (double &) const, void),     asCALL_THISCALL },
            { "void get(string &out) const", asMETHOD(q2as_yyjson_val, get_str),                           asCALL_THISCALL },
            // TODO: this should be `get` but implicit conversion rules make that not work
            { "void get_enum(? &out) const", asMETHODPR(q2as_yyjson_val, get, (void *, int) const, void), asCALL_THISCALL },

            { "uint64 get_uint_() const property",  asMETHOD(q2as_yyjson_val, get_uint),   asCALL_THISCALL },
            { "int64 get_sint() const property",    asMETHOD(q2as_yyjson_val, get_sint),   asCALL_THISCALL },
            { "int32 get_int_() const property",    asMETHOD(q2as_yyjson_val, get_int),    asCALL_THISCALL },
            { "double get_real() const property",   asMETHOD(q2as_yyjson_val, get_real),   asCALL_THISCALL },
            { "double get_num() const property",    asMETHOD(q2as_yyjson_val, get_num),    asCALL_THISCALL },
            { "string get_str() const property",    asMETHOD(q2as_yyjson_val, get_str),    asCALL_THISCALL },
            { "uint64 get_length() const property", asMETHOD(q2as_yyjson_val, get_length), asCALL_THISCALL },

            { "json_val arr_get(uint64) const", asMETHOD(q2as_yyjson_val, arr_get),       asCALL_THISCALL },
            { "json_val arr_get_first() const", asMETHOD(q2as_yyjson_val, arr_get_first), asCALL_THISCALL },
            { "json_val arr_get_last() const",  asMETHOD(q2as_yyjson_val, arr_get_last),  asCALL_THISCALL },

            { "json_val obj_get(const string &in) const", asMETHOD(q2as_yyjson_val, obj_get), asCALL_THISCALL },

            { "json_val opIndex(const string &in) const", asMETHOD(q2as_yyjson_val, obj_get), asCALL_THISCALL },
            { "json_val opIndex(uint64) const",           asMETHOD(q2as_yyjson_val, arr_get), asCALL_THISCALL }
        });

    // immutable JSON doc
    registry
        .type("json_doc", sizeof(q2as_yyjson_doc), asOBJ_REF)
        .behaviors({
            { asBEHAVE_FACTORY, "json_doc@ f()",                 asFUNCTION((Q2AS_Factory<q2as_yyjson_doc, q2as_sv_state_t>)), asCALL_GENERIC },
            { asBEHAVE_FACTORY, "json_doc@ f(const string &in)", asFUNCTION(q2as_json_doc_factory_str),                        asCALL_GENERIC },
            { asBEHAVE_ADDREF,  "void f()",                      asFUNCTION((Q2AS_AddRef<q2as_yyjson_doc>)),                   asCALL_GENERIC },
            { asBEHAVE_RELEASE, "void f()",                      asFUNCTION((Q2AS_Release<q2as_yyjson_doc, q2as_sv_state_t>)), asCALL_GENERIC }
        })
        .methods({
            { "json_val get_root() property", asMETHOD(q2as_yyjson_doc, get_root), asCALL_THISCALL },

            { "uint64 get_read_size() const property", asMETHOD(q2as_yyjson_doc, get_read_size), asCALL_THISCALL },
            { "uint64 get_val_count() const property", asMETHOD(q2as_yyjson_doc, get_val_count), asCALL_THISCALL },

            { "string to_string() const", asMETHODPR(q2as_yyjson_doc, as_string, () const, std::string), asCALL_THISCALL }
        });

    // immutable JSON array iterator
    registry
        .type("json_arr_iter", sizeof(q2as_yyjson_arr_iter), asOBJ_VALUE | asOBJ_APP_CLASS_CD)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                        asFUNCTION(Q2AS_init_construct<q2as_yyjson_arr_iter>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const json_arr_iter &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(json_val)",                asFUNCTION(q2as_yyjson_arr_iter_from_val),                  asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()",                        asFUNCTION(Q2AS_destruct<q2as_yyjson_arr_iter>),            asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "json_arr_iter &opAssign (const json_arr_iter &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST },
            { "json_val get_next() const property",                asMETHOD(q2as_yyjson_arr_iter, get_next),      asCALL_THISCALL },
            { "bool get_has_next() const property",                asMETHOD(q2as_yyjson_arr_iter, has_next),      asCALL_THISCALL }
        });

    // immutable JSON object iterator
    registry
        .type("json_obj_iter", sizeof(q2as_yyjson_obj_iter), asOBJ_VALUE | asOBJ_APP_CLASS_CD)
        .behaviors({
            { asBEHAVE_CONSTRUCT, "void f()",                        asFUNCTION(Q2AS_init_construct<q2as_yyjson_obj_iter>),      asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(const json_obj_iter &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST },
            { asBEHAVE_CONSTRUCT, "void f(json_val)",                asFUNCTION(q2as_yyjson_obj_iter_from_val),                  asCALL_CDECL_OBJLAST },
            { asBEHAVE_DESTRUCT,  "void f()",                        asFUNCTION(Q2AS_destruct<q2as_yyjson_obj_iter>),            asCALL_CDECL_OBJLAST }
        })
        .methods({
            { "json_obj_iter &opAssign (const json_obj_iter &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST },
            { "json_val get_next() const property",                asMETHOD(q2as_yyjson_obj_iter, get_next),      asCALL_THISCALL },
            { "json_val get_val(const json_val &in key) const",    asMETHOD(q2as_yyjson_obj_iter, get_val),       asCALL_THISCALL },
            { "bool get_has_next() const property",                asMETHOD(q2as_yyjson_obj_iter, has_next),      asCALL_THISCALL }
        });
}

void q2as_json_doc_factory_mut(asIScriptGeneric *gen)
{
    q2as_yyjson_doc *ptr = reinterpret_cast<q2as_yyjson_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc)));
    *(q2as_yyjson_doc **) gen->GetAddressOfReturnLocation() = ptr;
    new(ptr) q2as_yyjson_doc((const q2as_yyjson_mut_doc *) gen->GetArgAddress(0));
}

void q2as_json_mut_doc_factory_imut(asIScriptGeneric *gen)
{
    q2as_yyjson_mut_doc *ptr = reinterpret_cast<q2as_yyjson_mut_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_mut_doc)));
    *(q2as_yyjson_mut_doc **) gen->GetAddressOfReturnLocation() = ptr;
    new(ptr) q2as_yyjson_mut_doc((const q2as_yyjson_doc *) gen->GetArgAddress(0));
}

void Q2AS_RegisterJson(q2as_registry &registry)
{
    Q2AS_RegisterMutableJson(registry);
    Q2AS_RegisterImmutableJson(registry);

    // conversion constructors
    registry
        .for_type("json_doc")
        .behavior({ asBEHAVE_FACTORY, "json_doc@ f(const json_mutdoc &in)", asFUNCTION(q2as_json_doc_factory_mut), asCALL_GENERIC });

    registry
        .for_type("json_mutdoc")
        .behavior({ asBEHAVE_FACTORY, "json_mutdoc@ f(const json_doc &in)", asFUNCTION(q2as_json_mut_doc_factory_imut), asCALL_GENERIC });
}