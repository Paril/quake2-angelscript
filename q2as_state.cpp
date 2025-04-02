#include "q2as_local.h"
#include "q_std.h"
#include "thirdparty/scripthelper/scripthelper.h"
#include "q2as_platform.h"

//#define RUNFRAME_PROFILING

#ifdef RUNFRAME_PROFILING
#include "ctrack.hpp"
#endif

#define INSTRUMENTATION 1

#if defined(INSTRUMENTATION) && INSTRUMENTATION == 1
#define PL_IMPLEMENTATION 1
#define USE_PL 1
#define PL_IMPL_COLLECTION_BUFFER_BYTE_QTY 10000000
#define PL_COMPACT_MODEL 1
#include "thirdparty/palanteer/palinteer.h"

#undef min
#undef max
#undef GetObject

#include "debugger/as_debugger.h"

static void InstrumentationCallback(asSFunctionInfo *info)
{
    q2as_state_t *state = (q2as_state_t *) info->context->GetEngine()->GetUserData(0);

    if (!plIsEnabled() || !state->InstrumentationEnabled())
        return;

    static std::unordered_map<asIScriptFunction *, declhash_t> decls;

    declhash_t *hashed;

    if (auto f = decls.find(info->function); f != decls.end())
        hashed = &f->second;
    else
    {
        const char *decl = info->function->GetDeclaration();
        hashed = &decls.emplace(info->function, declhash_t { decl, plPriv::hashString(decl) }).first->second;
    }

    if (info->popped)
        plPriv::eventLogRaw(PL_STRINGHASH(PL_BASEFILENAME), hashed->h, PL_EXTERNAL_STRINGS?0:PL_BASEFILENAME, PL_EXTERNAL_STRINGS?0:(hashed->s.c_str()), __LINE__,
                            PL_STORE_COLLECT_CASE_, PL_FLAG_SCOPE_END | PL_FLAG_TYPE_DATA_TIMESTAMP, PL_GET_CLOCK_TICK_FUNC());
    else
        plPriv::eventLogRaw(PL_STRINGHASH(PL_BASEFILENAME), hashed->h, PL_EXTERNAL_STRINGS?0:PL_BASEFILENAME, PL_EXTERNAL_STRINGS?0:(hashed->s.c_str()), __LINE__,
                            PL_STORE_COLLECT_CASE_, PL_FLAG_SCOPE_BEGIN | PL_FLAG_TYPE_DATA_TIMESTAMP, PL_GET_CLOCK_TICK_FUNC());
}

static void InstrumentationGarbageCallback(q2as_state_t *state, bool pop)
{
    static declhash_t garbage_hash { "GC", plPriv::hashString("GC") };

    if (!plIsEnabled() || !state->InstrumentationEnabled())
        return;

    if (pop)
        plPriv::eventLogRaw(PL_STRINGHASH(PL_BASEFILENAME), garbage_hash.h, PL_EXTERNAL_STRINGS?0:PL_BASEFILENAME, PL_EXTERNAL_STRINGS?0:(garbage_hash.s.c_str()), __LINE__,
                            PL_STORE_COLLECT_CASE_, PL_FLAG_SCOPE_END | PL_FLAG_TYPE_DATA_TIMESTAMP, PL_GET_CLOCK_TICK_FUNC());
    else
        plPriv::eventLogRaw(PL_STRINGHASH(PL_BASEFILENAME), garbage_hash.h, PL_EXTERNAL_STRINGS?0:PL_BASEFILENAME, PL_EXTERNAL_STRINGS?0:(garbage_hash.s.c_str()), __LINE__,
                            PL_STORE_COLLECT_CASE_, PL_FLAG_SCOPE_BEGIN | PL_FLAG_TYPE_DATA_TIMESTAMP, PL_GET_CLOCK_TICK_FUNC());
}

static void WriteInstrumentation()
{
    plStopAndUninit();
}

static void FlushInstrumentation()
{
}

static void StartInstrumentation(q2as_state_t &as)
{
    if (!plIsEnabled())
    {
        plSetFilename("record.pltraw");
        plInitAndStart("q2as", PL_MODE_STORE_IN_FILE);
        plDeclareThread("main");
        plFreezePoint();
    }
}
#elif defined(INSTRUMENTATION) && INSTRUMENTATION == 2
#include "spall.h"

static SpallProfile spall_ctx;
static SpallBuffer spall_buffer;

#include <Windows.h>
double get_time_in_micros(void)
{
    static double invfreq;
    if (!invfreq) {
        LARGE_INTEGER frequency;
        QueryPerformanceFrequency(&frequency);
        invfreq = 1000000.0 / frequency.QuadPart;
    }
    LARGE_INTEGER counter;
    QueryPerformanceCounter(&counter);
    return counter.QuadPart * invfreq;
}

#undef GetObject

static void InstrumentationCallback(asSFunctionInfo *info)
{
    q2as_state_t *state = (q2as_state_t *) info->context->GetEngine()->GetUserData(0);
    int bit = state == &svas ? 1 : 2;

    if ((q2as_instrumentation->integer & bit) == 0)
        return;

    static std::chrono::high_resolution_clock clk;

    if (info->popped)
    {
        spall_buffer_end_ex(&spall_ctx, &spall_buffer, get_time_in_micros(), 0, 0);
    }
    else
    {

        static std::unordered_map<asIScriptFunction *, std::string> decls;

        std::string *hashed;

        if (auto f = decls.find(info->function); f != decls.end())
            hashed = &f->second;
        else
        {
            const char *decl = info->function->GetDeclaration();
            hashed = &decls.emplace(info->function, std::string(decl)).first->second;
        }

        spall_buffer_begin_ex(&spall_ctx, &spall_buffer, hashed->c_str(), hashed->size(), get_time_in_micros(), 0, 0);
    }
}

static void FlushInstrumentation()
{
    if (!q2as_instrumentation->integer)
        return;

    spall_flush(&spall_ctx);
}

static void WriteInstrumentation()
{
    if (!q2as_instrumentation->integer)
        return;

    spall_buffer_flush(&spall_ctx, &spall_buffer);
    spall_quit(&spall_ctx);
}

static void StartInstrumentation(q2as_state_t &as)
{
    if (!q2as_instrumentation->integer)
        return;

    spall_ctx = spall_init_file("spall_sample.spall", 1);

    /*
        Fun fact: You don't actually *need* a buffer, you can just pass NULL!
        Passing a buffer clumps flushing overhead, so individual functions are faster and less noisy

        If you notice big variance in events, you can try bumping the buffer size so you do fewer flushes
        while your code runs, or you can shrink it if you need to save some memory
    */
#define BUFFER_SIZE (10 * 1024 * 1024)
    unsigned char *buffer = (unsigned char *) malloc(BUFFER_SIZE);
    spall_buffer = {
        buffer,
        BUFFER_SIZE
    };

    /*
        Here's another neat trick:
        We're touching the pages ahead of time here, so we get a smoother trace.
        By pre-faulting all the pages in our event buffer, we avoid waiting for pages to load
        while user code runs. This can make a noticable difference for data consistency, especially
        with bigger buffers
    */
    memset(spall_buffer.data, 1, spall_buffer.length);

    spall_buffer_init(&spall_ctx, &spall_buffer);

    as.context->SetFunctionCallback(asFUNCTION(InstrumentationCallback), nullptr, asCALL_CDECL);
}
#else
#define WriteInstrumentation()
#define FlushInstrumentation()
#define StartInstrumentation(a)
#endif

static void MessageCallback(const asSMessageInfo *msg, void *param)
{
    const char *type = "ERR ";

    if (msg->type == asMSGTYPE_WARNING)
        type = "WARN";
    else if (msg->type == asMSGTYPE_INFORMATION)
        type = "INFO";

    ((q2as_state_t *) param)->Print(G_Fmt("{} ({}, {}) : {} : {}\n", msg->section, msg->row, msg->col, type, msg->message).data());

    //if (msg->type == asMSGTYPE_ERROR)
        //__debugbreak();
}

static void GarbageCallback(const asSGarbageCollectionInfo *msg, void *param)
{
    InstrumentationGarbageCallback((q2as_state_t *) param, msg->popped);
}

bool q2as_state_t::CreateEngine()
{
    engine = asCreateScriptEngine();

    if (!engine)
    {
        Print("Can't create AS engine.\n");
        return false;
    }

    engine->SetUserData(this);

    engine->SetEngineProperty(asEP_USE_CHARACTER_LITERALS, true);
    engine->SetEngineProperty(asEP_DISALLOW_EMPTY_LIST_ELEMENTS, true);
    engine->SetEngineProperty(asEP_BOOL_CONVERSION_MODE, 1);

    if (int r = engine->SetMessageCallback(asFUNCTION(MessageCallback), this, asCALL_CDECL); r < 0)
    {
        Print("Couldn't set AngelScript message callback.\n");
        Destroy();
        return false;
    }

    if (int r = engine->SetGarbageCollectionCallback(asFUNCTION(GarbageCallback), this, asCALL_CDECL); r < 0)
    {
        Print("Couldn't set AngelScript garbage callback.\n");
        Destroy();
        return false;
    }

    return true;
}

#include "cg_local.h"
#include "g_local.h"

#include <filesystem>
namespace fs = std::filesystem;

static std::string Q2AS_ScriptPathFromBaseDir()
{
    cvar_t *bp = (gi.cvar ? gi.cvar : cgi.cvar)("basedir", "", CVAR_NOFLAGS);
    cvar_t *gn = (gi.cvar ? gi.cvar : cgi.cvar)("game", "", CVAR_NOFLAGS);

    fs::path path = bp->string;

    if (*gn->string)
        path /= gn->string;
    else
        path /= "baseq2";

    path /= "scripts";

    return path.generic_string();
}

std::string Q2AS_ScriptPath()
{
    cvar_t *cv = (gi.cvar ? gi.cvar : cgi.cvar)("q2as_path", "", CVAR_NOFLAGS);

    if (*cv->string)
        return cv->string;

    auto module_path = Q2AS_GetModulePath();
    if (!module_path.success)
    {
        return Q2AS_ScriptPathFromBaseDir();
    }

    fs::path alongside_dll = module_path.path;
    alongside_dll = alongside_dll.parent_path();
    alongside_dll /= "scripts";

    if (fs::exists(alongside_dll))
        return alongside_dll.generic_string();

    return Q2AS_ScriptPathFromBaseDir();
}

bool q2as_state_t::Load(asALLOCFUNC_t allocFunc, asFREEFUNC_t freeFunc)
{
    // already loaded
    if (engine)
        return true;

    Print("Loading AS engine...\n");

    fs::path script_dir(Q2AS_ScriptPath());

    if (debugger_state.workspace.base_path.empty())
        debugger_state.workspace.base_path = script_dir.generic_string();

    Print("Searching for AS scripts in \"");
    Print(script_dir.string().c_str());
    Print("\"\n");

    // TODO: need File API extension for this to work properly.
    // for now, just using hardcoded paths.
    fs::path script_path = script_dir / "bgame";

    if (!fs::exists(script_path / "init.as"))
        return false;

    asSetGlobalMemoryFunctions(allocFunc, freeFunc);

    if (!debugger_state.debugger_cvar)
        debugger_state.debugger_cvar = Cvar("q2as_debugger", "0", CVAR_NOFLAGS);
    if (!debugger_state.attach_type)
        debugger_state.attach_type = Cvar("q2as_debugger_wait_attach", "0", CVAR_NOFLAGS);

    return CreateEngine();
}

bool q2as_state_t::CreateMainModule()
{
    mainModule = engine->GetModule("main", asGM_ALWAYS_CREATE);

    if (!mainModule)
    {
        Print("Couldn't create AngelScript main module.\n");
        Destroy();
        return false;
    }

    return true;
}

bool q2as_state_t::LoadLibraries(library_reg_t *const *const libraries, size_t num_libs)
{
    q2as_registry registry(engine);

    for (size_t i = 0; i < num_libs; i++)
    {
        try
        {
            (libraries[i])(registry);
        }
        catch (q2as_registry_exception)
        {
            Print("Couldn't register built-in library.\n");
            Destroy();
            return false;
        }
    }

    return true;
}

std::string q2as_state_t::LoadFile(const char *path)
{
    FILE *fp = fopen(path, "rb");

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    std::string script_str;
    script_str.resize(size);
    fread(script_str.data(), sizeof(char), size, fp);
    fclose(fp);

    return script_str;
}

bool q2as_state_t::LoadFilesFromPath(const char *base, const char *path, asIScriptModule *module)
{
    fs::path basePath(base);

    for (const fs::directory_entry &entry : std::filesystem::recursive_directory_iterator(path))
    {
        if (!entry.is_regular_file())
            continue;
        else if (!entry.path().has_extension())
            continue;
        else if (entry.path().extension() != ".as")
            continue;

        std::string path = entry.path().string();
        std::string script_str = LoadFile(path.c_str());

        path = entry.path().generic_string();

        std::string relative_section = fs::relative(path, basePath).generic_string();

        if (module->AddScriptSection(relative_section.c_str(), script_str.c_str(), script_str.size(), 0) < 0)
        {
            Print("Error loading script section.\n");
            Destroy();
            return false;
        }

        debugger_state.workspace.sections.insert(relative_section);
    }

    return true;
}

bool q2as_state_t::LoadFiles(const char *self_scripts, asIScriptModule *module)
{
    fs::path script_path(Q2AS_ScriptPath());
    fs::path bg_path = script_path / "bgame";
    fs::path g_path = script_path / self_scripts;

    if (!LoadFilesFromPath(script_path.string().c_str(), bg_path.string().c_str(), module))
        return false;
    else if (!LoadFilesFromPath(script_path.string().c_str(), g_path.string().c_str(), module))
        return false;

    return true;
}

bool q2as_state_t::Build()
{
    if (mainModule->Build() < 0)
    {
        Print("Error compiling script module.\n");
        Destroy();
        return false;
    }

    stringTypeId = engine->GetStringFactory();
    vec3TypeId = engine->GetTypeInfoByName("vec3_t")->GetTypeId();
    edict_tTypeId = engine->GetTypeInfoByName("edict_t")->GetTypeId();
    timeTypeId = engine->GetTypeInfoByName("gtime_t")->GetTypeId();

    if (auto iface = engine->GetTypeInfoByName("IASEntity"))
        IASEntityTypeId = iface->GetTypeId();

    {
        asIScriptFunction *func = mainModule->GetFunctionByDecl("void main(bool)");
        if (func)
        {
            auto ctx = RequestContext();
            ctx->Prepare(func);
            ctx->SetArgByte(0, 0);
            ctx.Execute();
        }
    }

    StartInstrumentation();

    return true;
}

void q2as_state_t::Destroy()
{
    // destroy debugger
    debugger_state.debugger.reset();

    if (engine)
        engine->ShutDownAndRelease();

    WriteInstrumentation();
    instru.clear();

    mainModule = nullptr;
    engine = nullptr;
}

q2as_ctx_t q2as_state_t::RequestContext()
{
    auto ctx = engine->RequestContext();

#ifdef INSTRUMENTATION
    if (InstrumentationEnabled())
        ctx->SetFunctionCallback(asFUNCTION(InstrumentationCallback), nullptr, asCALL_CDECL);
#endif

    debugger_state.CheckDebugger(ctx);

    return { ctx, this };
}

static std::string exceptionInfo;

bool q2as_state_t::Execute(asIScriptContext *context)
{
    int r = context->Execute();

    if (r == asEXECUTION_FINISHED)
        return true;

    if (r == asEXECUTION_EXCEPTION)
    {
        Print("AngelScript Exception\n");
        Print((exceptionInfo = GetExceptionInfo(context, true)).c_str());
        debugger_state.DebugBreak(context);
        return false;
    }

    return true;
}

void q2as_state_t::StartInstrumentation()
{
    if (InstrumentationEnabled())
        ::StartInstrumentation(*this);
}

/*static*/ bool q2as_state_t::CheckExceptionState()
{
    return !exceptionInfo.empty();
}

/*static*/ std::string q2as_state_t::GetExceptionData()
{
    return exceptionInfo;
}

bool q2as_ctx_t::Execute()
{
    return state->Execute(context);
}
