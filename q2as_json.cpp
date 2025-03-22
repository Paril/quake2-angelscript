#include "q2as_json.h"
#include "q2as_reg.h"
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

static bool Q2AS_RegisterMutableJson(asIScriptEngine *engine)
{
    // mutable JSON value
    EnsureRegisteredTypeRaw("json_mutval", sizeof(q2as_yyjson_mut_val), asOBJ_VALUE | asOBJ_APP_CLASS_CD);
    EnsureRegisteredBehaviourRaw("json_mutval", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_mutval", asBEHAVE_CONSTRUCT, "void f(const json_mutval &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_mutval", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(Q2AS_destruct<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("json_mutval", "json_mutval &opAssign (const json_mutval &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_mut_val>), asCALL_CDECL_OBJLAST);

    // functions
    EnsureRegisteredMethodRaw("json_mutval", "bool get_valid() const property", asMETHOD(q2as_yyjson_mut_val, get_valid), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "string to_string() const", asMETHOD(q2as_yyjson_mut_val, as_string), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_obj() const property", asMETHOD(q2as_yyjson_mut_val,   is_obj), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_arr() const property", asMETHOD(q2as_yyjson_mut_val,   is_arr), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_ctn() const property", asMETHOD(q2as_yyjson_mut_val,   is_ctn), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_true() const property", asMETHOD(q2as_yyjson_mut_val,  is_true), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_false() const property", asMETHOD(q2as_yyjson_mut_val, is_false), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_bool() const property", asMETHOD(q2as_yyjson_mut_val,  is_bool), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_str() const property", asMETHOD(q2as_yyjson_mut_val,   is_str), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_int() const property", asMETHOD(q2as_yyjson_mut_val,   is_int), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_uint() const property", asMETHOD(q2as_yyjson_mut_val,  is_uint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_sint() const property", asMETHOD(q2as_yyjson_mut_val,  is_sint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_real() const property", asMETHOD(q2as_yyjson_mut_val,  is_real), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_null() const property", asMETHOD(q2as_yyjson_mut_val,  is_null), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool get_is_num() const property", asMETHOD(q2as_yyjson_mut_val,   is_num), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_mutval", "bool arr_insert(json_mutval v, uint64 index)", asMETHOD(q2as_yyjson_mut_val, arr_insert), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool arr_append(json_mutval v)", asMETHOD(q2as_yyjson_mut_val, arr_append), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool arr_prepend(json_mutval v)", asMETHOD(q2as_yyjson_mut_val, arr_prepend), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "json_mutval arr_replace(uint64 index, json_mutval v)", asMETHOD(q2as_yyjson_mut_val, arr_replace), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "json_mutval arr_remove_first()", asMETHOD(q2as_yyjson_mut_val, arr_remove_first), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "json_mutval arr_remove_last()", asMETHOD(q2as_yyjson_mut_val, arr_remove_last), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool arr_remove_range(uint64 index, uint64 len)", asMETHOD(q2as_yyjson_mut_val, arr_remove_range), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool arr_clear()", asMETHOD(q2as_yyjson_mut_val, arr_clear), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "uint64 get_arr_size() const property", asMETHOD(q2as_yyjson_mut_val, arr_size), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_mutval", "bool obj_add(const string &in, json_mutval v)", asMETHOD(q2as_yyjson_mut_val, obj_add), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool obj_put(const string &in, json_mutval v)", asMETHOD(q2as_yyjson_mut_val, obj_put), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool obj_remove(const string &in)", asMETHOD(q2as_yyjson_mut_val, obj_remove), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool obj_rename_key(const string &in, const string &in)", asMETHOD(q2as_yyjson_mut_val, obj_rename_key), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "bool obj_clear()", asMETHOD(q2as_yyjson_mut_val, obj_clear), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutval", "uint64 get_obj_size() const property", asMETHOD(q2as_yyjson_mut_val, obj_size), asCALL_THISCALL);

    // AS_TODO iterators?
    
    // mutable JSON doc
    EnsureRegisteredTypeRaw("json_mutdoc", sizeof(q2as_yyjson_mut_doc), asOBJ_REF);

	// behaviors
	EnsureRegisteredBehaviourRaw("json_mutdoc", asBEHAVE_FACTORY, "json_mutdoc@ f()", asFUNCTION((Q2AS_Factory<q2as_yyjson_mut_doc, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_mutdoc", asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<q2as_yyjson_mut_doc, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_mutdoc", asBEHAVE_RELEASE, "void f()", asFUNCTION((Q2AS_Release<q2as_yyjson_mut_doc, q2as_sv_state_t>)), asCALL_GENERIC);

    // functions
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval get_root() property", asMETHOD(q2as_yyjson_mut_doc, get_root), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "void set_root(const json_mutval &in val) property", asMETHOD(q2as_yyjson_mut_doc, set_root), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_mutdoc", "void set_str_pool_size(uint64 len)", asMETHOD(q2as_yyjson_mut_doc, set_str_pool_size), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "void set_val_pool_size(uint64 len)", asMETHOD(q2as_yyjson_mut_doc, set_val_pool_size), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval null_()", asMETHOD(q2as_yyjson_mut_doc, mut_null), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval true_()", asMETHOD(q2as_yyjson_mut_doc, mut_true), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval false_()", asMETHOD(q2as_yyjson_mut_doc, mut_false), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval bool_(bool)", asMETHOD(q2as_yyjson_mut_doc, mut_bool), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval uint_(uint64)", asMETHOD(q2as_yyjson_mut_doc, mut_uint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval sint(int64)", asMETHOD(q2as_yyjson_mut_doc, mut_sint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval int_(int64)", asMETHOD(q2as_yyjson_mut_doc, mut_int), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval real(double)", asMETHOD(q2as_yyjson_mut_doc, mut_real), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval str(const string &in, uint len)", asMETHOD(q2as_yyjson_mut_doc, mut_strl), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval str(const string &in)", asMETHOD(q2as_yyjson_mut_doc, mut_str), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval obj()", asMETHOD(q2as_yyjson_mut_doc, mut_obj), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_mutdoc", "json_mutval arr()", asMETHOD(q2as_yyjson_mut_doc, mut_arr), asCALL_THISCALL);

    EnsureRegisteredMethodRaw("json_mutdoc", "string to_string() const", asMETHODPR(q2as_yyjson_mut_doc, as_string, () const, std::string), asCALL_THISCALL);

    return true;
}

void q2as_json_doc_factory_str(asIScriptGeneric *gen)
{
	q2as_yyjson_doc *ptr = reinterpret_cast<q2as_yyjson_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc)));
	*(q2as_yyjson_doc **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) q2as_yyjson_doc(*(std::string *)gen->GetArgAddress(0));
}

void q2as_yyjson_arr_iter_from_val(q2as_yyjson_val v, q2as_yyjson_arr_iter *self)
{
	new(self) q2as_yyjson_arr_iter(v);
}

void q2as_yyjson_obj_iter_from_val(q2as_yyjson_val v, q2as_yyjson_obj_iter *self)
{
	new(self) q2as_yyjson_obj_iter(v);
}

static bool Q2AS_RegisterImmutableJson(asIScriptEngine *engine)
{
    // immutable JSON value
    EnsureRegisteredTypeRaw("json_val", sizeof(q2as_yyjson_val), asOBJ_VALUE | asOBJ_APP_CLASS_CD);
    EnsureRegisteredBehaviourRaw("json_val", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<q2as_yyjson_val>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_val", asBEHAVE_CONSTRUCT, "void f(const json_val &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_val>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_val", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(Q2AS_destruct<q2as_yyjson_val>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("json_val", "json_val &opAssign (const json_val &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_val>), asCALL_CDECL_OBJLAST);

    // functions
    EnsureRegisteredMethodRaw("json_val", "bool get_valid() const property", asMETHOD(q2as_yyjson_val, get_valid), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "string to_string() const", asMETHOD(q2as_yyjson_val, as_string), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_val", "bool get_is_obj() const property", asMETHOD(q2as_yyjson_val,   is_obj), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_arr() const property", asMETHOD(q2as_yyjson_val,   is_arr), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_ctn() const property", asMETHOD(q2as_yyjson_val,   is_ctn), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_true() const property", asMETHOD(q2as_yyjson_val,  is_true), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_false() const property", asMETHOD(q2as_yyjson_val, is_false), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_bool() const property", asMETHOD(q2as_yyjson_val,  is_bool), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_str() const property", asMETHOD(q2as_yyjson_val,   is_str), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_int() const property", asMETHOD(q2as_yyjson_val,   is_int), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_uint() const property", asMETHOD(q2as_yyjson_val,  is_uint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_sint() const property", asMETHOD(q2as_yyjson_val,  is_sint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_real() const property", asMETHOD(q2as_yyjson_val,  is_real), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_null() const property", asMETHOD(q2as_yyjson_val,  is_null), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "bool get_is_num() const property", asMETHOD(q2as_yyjson_val,   is_num), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_val", "bool get_bool_() const property", asMETHOD(q2as_yyjson_val,    get_bool), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "uint64 get_uint_() const property", asMETHOD(q2as_yyjson_val,  get_uint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "int64 get_sint() const property", asMETHOD(q2as_yyjson_val,    get_sint), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "int32 get_int_() const property", asMETHOD(q2as_yyjson_val,    get_int), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "double get_real() const property", asMETHOD(q2as_yyjson_val,   get_real), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "double get_num() const property", asMETHOD(q2as_yyjson_val,    get_num), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "string get_str() const property", asMETHOD(q2as_yyjson_val,    get_str), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "uint64 get_length() const property", asMETHOD(q2as_yyjson_val, get_length), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_val", "json_val arr_get(uint64) const", asMETHOD(q2as_yyjson_val, arr_get), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "json_val arr_get_first() const", asMETHOD(q2as_yyjson_val, arr_get_first), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_val", "json_val arr_get_last() const", asMETHOD(q2as_yyjson_val, arr_get_last), asCALL_THISCALL);

    EnsureRegisteredMethodRaw("json_val", "json_val obj_get(const string &in) const", asMETHOD(q2as_yyjson_val, obj_get), asCALL_THISCALL);
    
    // immutable JSON doc
    EnsureRegisteredTypeRaw("json_doc", sizeof(q2as_yyjson_doc), asOBJ_REF);

	// behaviors
	EnsureRegisteredBehaviourRaw("json_doc", asBEHAVE_FACTORY, "json_doc@ f()", asFUNCTION((Q2AS_Factory<q2as_yyjson_doc, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_doc", asBEHAVE_FACTORY, "json_doc@ f(const string &in)", asFUNCTION(q2as_json_doc_factory_str), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_doc", asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<q2as_yyjson_doc, q2as_sv_state_t>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_doc", asBEHAVE_RELEASE, "void f()", asFUNCTION((Q2AS_Release<q2as_yyjson_doc, q2as_sv_state_t>)), asCALL_GENERIC);

    // functions
    EnsureRegisteredMethodRaw("json_doc", "json_val get_root() property", asMETHOD(q2as_yyjson_doc, get_root), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_doc", "uint64 get_read_size() const property", asMETHOD(q2as_yyjson_doc, get_read_size), asCALL_THISCALL);
    EnsureRegisteredMethodRaw("json_doc", "uint64 get_val_count() const property", asMETHOD(q2as_yyjson_doc, get_val_count), asCALL_THISCALL);
    
    EnsureRegisteredMethodRaw("json_doc", "string to_string() const", asMETHODPR(q2as_yyjson_doc, as_string, () const, std::string), asCALL_THISCALL);

    // immutable JSON array iterator
    EnsureRegisteredTypeRaw("json_arr_iter", sizeof(q2as_yyjson_arr_iter), asOBJ_VALUE | asOBJ_APP_CLASS_CD);
    EnsureRegisteredBehaviourRaw("json_arr_iter", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_arr_iter", asBEHAVE_CONSTRUCT, "void f(const json_arr_iter &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_arr_iter", asBEHAVE_CONSTRUCT, "void f(json_val)", asFUNCTION(q2as_yyjson_arr_iter_from_val), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_arr_iter", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(Q2AS_destruct<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("json_arr_iter", "json_arr_iter &opAssign (const json_arr_iter &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_arr_iter>), asCALL_CDECL_OBJLAST);
    
	EnsureRegisteredMethodRaw("json_arr_iter", "json_val get_next() const property", asMETHOD(q2as_yyjson_arr_iter, get_next), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("json_arr_iter", "bool get_has_next() const property", asMETHOD(q2as_yyjson_arr_iter, has_next), asCALL_THISCALL);

    // immutable JSON object iterator
    EnsureRegisteredTypeRaw("json_obj_iter", sizeof(q2as_yyjson_obj_iter), asOBJ_VALUE | asOBJ_APP_CLASS_CD);
    EnsureRegisteredBehaviourRaw("json_obj_iter", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Q2AS_init_construct<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_obj_iter", asBEHAVE_CONSTRUCT, "void f(const json_obj_iter &in)", asFUNCTION(Q2AS_init_construct_copy<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_obj_iter", asBEHAVE_CONSTRUCT, "void f(json_val)", asFUNCTION(q2as_yyjson_obj_iter_from_val), asCALL_CDECL_OBJLAST);
    EnsureRegisteredBehaviourRaw("json_obj_iter", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(Q2AS_destruct<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST);
	EnsureRegisteredMethodRaw("json_obj_iter", "json_obj_iter &opAssign (const json_obj_iter &in)", asFUNCTION(Q2AS_assign<q2as_yyjson_obj_iter>), asCALL_CDECL_OBJLAST);
    
	EnsureRegisteredMethodRaw("json_obj_iter", "json_val get_next() const property", asMETHOD(q2as_yyjson_obj_iter, get_next), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("json_obj_iter", "json_val get_val(const json_val &in key) const", asMETHOD(q2as_yyjson_obj_iter, get_val), asCALL_THISCALL);
	EnsureRegisteredMethodRaw("json_obj_iter", "bool get_has_next() const property", asMETHOD(q2as_yyjson_obj_iter, has_next), asCALL_THISCALL);

    return true;
}

void q2as_json_doc_factory_mut(asIScriptGeneric *gen)
{
	q2as_yyjson_doc *ptr = reinterpret_cast<q2as_yyjson_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_doc)));
	*(q2as_yyjson_doc **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) q2as_yyjson_doc((const q2as_yyjson_mut_doc *)gen->GetArgAddress(0));
}

void q2as_json_mut_doc_factory_imut(asIScriptGeneric *gen)
{
	q2as_yyjson_mut_doc *ptr = reinterpret_cast<q2as_yyjson_mut_doc *>(q2as_sv_state_t::AllocStatic(sizeof(q2as_yyjson_mut_doc)));
	*(q2as_yyjson_mut_doc **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) q2as_yyjson_mut_doc((const q2as_yyjson_doc *)gen->GetArgAddress(0));
}

bool Q2AS_RegisterJson(asIScriptEngine *engine)
{
    if (!Q2AS_RegisterMutableJson(engine))
        return false;
    if (!Q2AS_RegisterImmutableJson(engine))
        return false;

    // conversion constructors
	EnsureRegisteredBehaviourRaw("json_doc", asBEHAVE_FACTORY, "json_doc@ f(const json_mutdoc &in)", asFUNCTION(q2as_json_doc_factory_mut), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("json_mutdoc", asBEHAVE_FACTORY, "json_mutdoc@ f(const json_doc &in)", asFUNCTION(q2as_json_mut_doc_factory_imut), asCALL_GENERIC);

    return true;
}