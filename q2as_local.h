// Local stuff shared between different Q2AS module files
#pragma once

#include "q_std.h"
#define USE_VEC3_TYPE
#include "game.h"
#include "angelscript.h"
#include <set>
#include <memory>
#include "q2as_reg.h"

// auto-destruct wrapper for an execution context
struct q2as_ctx_t
{
    asIScriptContext    *context;
    struct q2as_state_t *state;

    inline q2as_ctx_t(asIScriptContext *ctx, struct q2as_state_t *state) :
        context(ctx),
        state(state)
    {
    }

    inline ~q2as_ctx_t()
    {
        context->GetEngine()->ReturnContext(context);
    }

    // execute the given context
	bool Execute();

    asIScriptContext *operator->() { return context; }
};

struct declhash_t
{
    std::string s;
    uint32_t h;
};

using library_reg_t = void(q2as_registry &);

// stores the state for each Q2AS engine.
struct q2as_state_t
{
    std::unordered_map<asIScriptFunction *, declhash_t> instru;
	asIScriptEngine *engine;
	asIScriptModule *mainModule; // the main module
	
	int stringTypeId;
	int vec3TypeId;
	int timeTypeId;
    // only for SV
	int edict_tTypeId;
	int IASEntityTypeId;

    virtual ~q2as_state_t() {}

    bool LoadLibraries(library_reg_t *const *const libraries, size_t num_libs);
    bool Load(asALLOCFUNC_t allocFunc, asFREEFUNC_t freeFunc);
    bool CreateMainModule();
    std::string LoadFile(const char *path);
    bool LoadFilesFromPath(const char *base, const char *path, asIScriptModule *module);
    bool LoadFiles(const char *self_scripts, asIScriptModule *module);
    bool Build();

    // called on shutdown
	void Destroy();

    // send to proper print function
    virtual void Print(const char *text) = 0;
    virtual void Error(const char *text) = 0;
    virtual bool InstrumentationEnabled() = 0;
    virtual void *Alloc(size_t size) = 0;
    virtual void Free(void *ptr) = 0;
    virtual cvar_t *Cvar(const char *name, const char *value, cvar_flags_t flags) = 0;

    q2as_ctx_t RequestContext();
    bool Execute(asIScriptContext *context);

    // both the game & cgame will pause on exceptions.
    // the AS system will then run some code to
    // display the exception to the user instead of
    // dropping to console.
    static bool CheckExceptionState();
    static std::string GetExceptionData();

private:
    void StartInstrumentation();
    bool CreateEngine();
};

// base class for our own ref-counted stuff
class q2as_ref_t
{
public:
	int	refs = 1;
};

// basic memcmp implementation for type equality.
// only use on POD.
template<typename T>
static bool Q2AS_type_equals(const T &a, T &b)
{
	return !memcmp(&a, &b, sizeof(T));
}

template<typename T>
static void Q2AS_init_construct(T *self)
{
	new(self) T{};
}

template<typename T>
static void Q2AS_destruct(T *self)
{
	self->~T();
}

template<typename T>
static void Q2AS_init_construct_copy(const T &in, T *self)
{
	new(self) T(in);
}

template<typename T>
static T *Q2AS_assign(const T &in, T *self)
{
	*self = in;
	return self;
}

#include "debugger/as_debugger.h"

// stores the debugger state for both Q2AS modules.
// no need to have a debugger for each one.
struct q2as_dbg_state_t
{
    std::unique_ptr<asIDBDebugger>       debugger;
    asIDBWorkspace                       workspace;
    struct cvar_t                        *debugger_cvar, *attach_type;
    int                                  debugger_type; // active debugger type

    void CheckDebugger(asIScriptContext *ctx);
    void DebugBreak(asIScriptContext *ctx = nullptr);
};

extern q2as_dbg_state_t debugger_state;

std::string Q2AS_ScriptPath();
