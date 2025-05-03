// Local stuff shared between different Q2AS module files
#pragma once

#include "q_std.h"
#define USE_VEC3_TYPE
#include "angelscript.h"
#include "game.h"
#include "q2as_reg.h"
#include <memory>

// file wrapper for bytecode
class q2as_FileBinaryStream : public asIBinaryStream
{
    FILE *fp = nullptr;

public:
    q2as_FileBinaryStream(const char *filename, const char *mode) :
        fp(fopen(filename, mode))
    {
    }

    ~q2as_FileBinaryStream()
    {
        fclose(fp);
    }
    
	virtual int Read(void *ptr, asUINT size) override
    {
        return fread(ptr, 1, size, fp);
    }

	virtual int Write(const void *ptr, asUINT size) override
    {
        return fwrite(ptr, 1, size, fp);
    }
};

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

    asIScriptContext *operator->()
    {
        return context;
    }
};

using library_reg_t = void(q2as_registry &);

using formatter_map = std::unordered_map<int, asIScriptFunction *>;

// stores the state for each Q2AS engine.
struct q2as_state_t
{
    const char      *name; // state name
    asIScriptEngine *engine;
    asIScriptModule *mainModule; // the main module
    formatter_map    formatters;
#ifdef Q2AS_DEBUGGER
    int              instrumentation_bit = 0;
#endif

    int stringTypeId;

protected:
    q2as_state_t(const char *state_name) :
        name(state_name)
    {
    }

public:
    virtual ~q2as_state_t()
    {
    }

    bool        LoadLibraries(library_reg_t *const *const libraries, size_t num_libs);
    bool        Load(asALLOCFUNC_t allocFunc, asFREEFUNC_t freeFunc);
    bool        CreateMainModule();
    std::string LoadFile(const char *path);
    bool        LoadFilesFromPath(const char *base, const char *path, asIScriptModule *module);
    bool        LoadFiles(const char *self_scripts, asIScriptModule *module);
    bool        Build();

    // called on shutdown
    void Destroy();

    // send to proper print function
    virtual void    Print(const char *text) = 0;
    virtual void    Error(const char *text) = 0;
    virtual void   *Alloc(size_t size) = 0;
    virtual void    Free(void *ptr) = 0;
    virtual cvar_t *Cvar(const char *name, const char *value, cvar_flags_t flags) = 0;

    q2as_ctx_t RequestContext();
    bool       Execute(asIScriptContext *context);

    // both the game & cgame will pause on exceptions.
    // the AS system will then run some code to
    // display the exception to the user instead of
    // dropping to console.
    static bool        CheckExceptionState();
    static std::string GetExceptionData();

private:
#ifdef Q2AS_DEBUGGER
    void StartInstrumentation();
#endif
    bool CreateEngine();
};

// base class for our own ref-counted stuff
class q2as_ref_t
{
public:
    int refs = 1;
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
    new (self) T {};
}

template<typename T>
static void Q2AS_destruct(T *self)
{
    self->~T();
}

template<typename T>
static void Q2AS_init_construct_copy(const T &in, T *self)
{
    new (self) T(in);
}

template<typename T>
static T *Q2AS_assign(const T &in, T *self)
{
    *self = in;
    return self;
}

#ifdef Q2AS_DEBUGGER
#include "debugger/as_debugger.h"

struct instrumentation_event_t
{
    int64_t            stamp;
    asIScriptFunction *func;
    bool               begin : 1;
    uint8_t            tid : 7;
};

constexpr int INSTRU_SERVER = 1;
constexpr int INSTRU_CLIENT = 2;
constexpr int INSTRU_MOVEMENT = 4;
constexpr int INSTRU_GC = 8;

// stores the debugger state for both Q2AS modules.
// no need to have a debugger for each one.
struct q2as_dbg_state_t
{
    // set to true to re-set the workspace.
    bool outdated = false;

    std::unique_ptr<asIDBDebugger>  debugger;
    std::unique_ptr<asIDBWorkspace> workspace;

    cvar_t                              *instrumentation_type, *instrumentation_modules, *instrumentation_granularity;
    int                                  active_instrumentation = 0;
    std::vector<instrumentation_event_t> events;
    uint8_t                              current_tid = 0;

    // evaluators don't take up much memory so we'll just
    // always keep them around.
    std::unordered_map<int, std::unique_ptr<asIDBTypeEvaluator>> evaluators;

    // Register an evaluator.
    void RegisterEvaluator(int typeId, std::unique_ptr<asIDBTypeEvaluator> evaluator);

    // A quick shortcut to make a templated instantiation
    // of T from the given type name.
    template<typename T>
    void RegisterEvaluator(asIScriptEngine *engine, const char *name)
    {
        RegisterEvaluator(engine->GetTypeInfoByName(name)->GetTypeId(), std::make_unique<T>());
    }

    struct cvar_t *cvar, *attach_type;
    int            active_type; // active debugger type
    bool           suspend_immediately = true;

    void CheckDebugger(asIScriptContext *ctx);
    void DebugBreak(asIScriptContext *ctx = nullptr);
};

extern q2as_dbg_state_t debugger_state;
#endif

std::string Q2AS_ScriptPath();
std::string q2as_backtrace();