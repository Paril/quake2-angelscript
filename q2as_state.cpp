#include "debugger/as_debugger.h"
#include "q2as_local.h"
#include "q2as_platform.h"
#include "q_std.h"
#include "thirdparty/scripthelper/scripthelper.h"
#include <fstream>

#define TRACY_ENABLE
#define TRACY_ON_DEMAND
#define TRACY_DELAYED_INIT
#define TRACY_MANUAL_LIFETIME

#include "thirdparty/tracy/TracyClient.cpp"
#include "thirdparty/tracy/tracy/Tracy.hpp"
#include "thirdparty/tracy/tracy/TracyC.h"

static std::chrono::high_resolution_clock cl;

struct TracyCallerHashedData
{
    asIScriptFunction *self;
    asIScriptFunction *caller;
    int                caller_line;

    TracyCallerHashedData(asSFunctionInfo *info)
    {
        self = info->function;
        caller = info->context->GetFunction(0);
        caller_line = info->context->GetLineNumber(0);
    }

    bool operator==(const TracyCallerHashedData &b) const
    {
        return self == b.self && caller == b.caller && caller_line == b.caller_line;
    }
};

struct TracyCallerInfo
{
    std::string                   decl;
    ___tracy_source_location_data source;

    TracyCallerInfo(const TracyCallerHashedData &hashed)
    {
        decl = hashed.self->GetDeclaration();

        source.color = 0;
        hashed.self->GetDeclaredAt(&source.file, nullptr, nullptr);
        source.function = decl.c_str();
        source.line = hashed.caller_line;
        source.name = nullptr;
    }
};

template<>
struct std::hash<TracyCallerHashedData>
{
    inline size_t operator()(const TracyCallerHashedData &a) const
    {
        size_t s = std::hash<void *>()(a.self);
        asIDBHashCombine(s, std::hash<void *>()(a.caller));
        asIDBHashCombine(s, std::hash<int>()(a.caller_line));
        return s;
    }
};

static std::unordered_map<TracyCallerHashedData, TracyCallerInfo> tracy_caller_info;
static std::vector<TracyCZoneCtx>                                 tracy_zone_ctx;

static void InstrumentationCallback(asSFunctionInfo *info)
{
    if (debugger_state.instrumentation_granularity->integer == 0 && info->function->GetFuncType() == asFUNC_SYSTEM)
        return;

    q2as_state_t *state = (q2as_state_t *) info->context->GetEngine()->GetUserData(0);

    if (debugger_state.instrumentation_type->integer == 1)
    {
        if (info->popped)
        {
            ___tracy_emit_zone_end(tracy_zone_ctx.back());
            tracy_zone_ctx.pop_back();
        }
        else
        {
            TracyCallerHashedData data(info);
            auto                  it = tracy_caller_info.find(data);

            if (it == tracy_caller_info.end())
                it = tracy_caller_info.emplace(data, TracyCallerInfo(data)).first;

            tracy_zone_ctx.push_back(___tracy_emit_zone_begin(&it->second.source, 1));
        }
    }
    else
    {
        debugger_state.events.push_back(
            { cl.now().time_since_epoch().count(), info->function, !info->popped, debugger_state.current_tid });
    }
}

static void InstrumentationGarbageCallback(q2as_state_t *state, bool pop)
{
    if (debugger_state.instrumentation_type->integer == 1)
    {
    }
    else
    {
        debugger_state.events.push_back({ cl.now().time_since_epoch().count(), nullptr, !pop, 4 });
    }
}

struct declhash_t
{
    std::string s;
    size_t      h;
};

static void WriteInstrumentation()
{
    if (debugger_state.active_instrumentation == 1)
    {
        tracy::ShutdownProfiler();
    }
    else
    {
        std::unordered_map<asIScriptFunction *, declhash_t> decls;

        std::ofstream               instru_of("profile.trace");
        std::ostream_iterator<char> it(instru_of);

        fmt::format_to(
            it, "packet {{ track_descriptor: {{ uuid: 5 process: {{ pid: 1 process_name: \"Angelscript\" }} }} }}\n");
        fmt::format_to(
            it, "packet {{ track_descriptor: {{ uuid: 1 thread: {{ pid: 1 tid: 1 thread_name: \"Server\" }} }} }}\n");
        fmt::format_to(
            it, "packet {{ track_descriptor: {{ uuid: 2 thread: {{ pid: 1 tid: 2 thread_name: \"Client\" }} }} }}\n");
        fmt::format_to(
            it, "packet {{ track_descriptor: {{ uuid: 3 thread: {{ pid: 1 tid: 3 thread_name: \"Movement\" }} }} }}\n");
        fmt::format_to(
            it, "packet {{ track_descriptor: {{ uuid: 4 thread: {{ pid: 1 tid: 4 thread_name: \"GC\" }} }} }}\n");
        fmt::format_to(it,
                       "packet {{ timestamp: {} trusted_packet_sequence_id: 1 first_packet_on_sequence: true "
                       "previous_packet_dropped: true sequence_flags: 3 }}\n",
                       cl.now().time_since_epoch().count());

        for (auto &event : debugger_state.events)
        {
            declhash_t *hashed;

            if (auto f = decls.find(event.func); f != decls.end())
            {
                hashed = &f->second;

                if (!event.begin)
                    fmt::format_to(it,
                                   "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_END track_uuid: {} }} "
                                   "trusted_packet_sequence_id: 1 sequence_flags: 2 }}\n",
                                   event.stamp, (uint8_t) event.tid);
                else
                    fmt::format_to(it,
                                   "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_BEGIN track_uuid: {} "
                                   "name_iid: {} }} trusted_packet_sequence_id: 1 }}\n",
                                   event.stamp, (uint8_t) event.tid, hashed->h);
            }
            else
            {
                const char *decl = event.func ? event.func->GetDeclaration() : "GC";
                hashed = &decls.emplace(event.func, declhash_t { decl, decls.size() + 1 }).first->second;

                if (!event.begin)
                    fmt::format_to(it,
                                   "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_END track_uuid: {} }} "
                                   "trusted_packet_sequence_id: 1 sequence_flags: 2 }}\n",
                                   event.stamp, (uint8_t) event.tid);
                else
                    fmt::format_to(it,
                                   "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_BEGIN track_uuid: {} "
                                   "name_iid: {} }} trusted_packet_sequence_id: 1 interned_data {{ event_names: {{ "
                                   "iid: {} name: \"{}\" }} }} }}\n",
                                   event.stamp, (uint8_t) event.tid, hashed->h, hashed->h, hashed->s);
            }
        }

        debugger_state.events.clear();
        debugger_state.events.shrink_to_fit();
    }

    debugger_state.active_instrumentation = 0;
}

static void StartInstrumentation(q2as_state_t &as)
{
    if (debugger_state.active_instrumentation)
        return;

    debugger_state.active_instrumentation = debugger_state.instrumentation_type->integer;

    if (debugger_state.active_instrumentation == 1)
    {
        tracy::StartupProfiler();
        TracyCSetThreadName("AngelScript");
    }
}

static void MessageCallback(const asSMessageInfo *msg, void *param)
{
    const char *type = "ERR ";

    if (msg->type == asMSGTYPE_WARNING)
        type = "WARN";
    else if (msg->type == asMSGTYPE_INFORMATION)
        type = "INFO";

    ((q2as_state_t *) param)
        ->Print(fmt::format("{} ({}, {}) : {} : {}\n", msg->section, msg->row, msg->col, type, msg->message).data());

    // if (msg->type == asMSGTYPE_ERROR)
    //__debugbreak();
}

static void GarbageCallback(const asSGarbageCollectionInfo *msg, void *param)
{
    InstrumentationGarbageCallback((q2as_state_t *) param, msg->popped);
}

static int engines_alive = 0;

bool q2as_state_t::CreateEngine()
{
    engine = asCreateScriptEngine();

    if (!engine)
    {
        Print("Can't create AS engine.\n");
        return false;
    }

    engines_alive++;

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

    return true;
}

#include "g_local.h"
#include "q2as_cgame.h"

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

    Print("Searching for AS scripts in \"");
    Print(script_dir.string().c_str());
    Print("\"\n");

    // TODO: need File API extension for this to work properly.
    // for now, just using hardcoded paths.
    fs::path script_path = script_dir / "bgame";

    if (!fs::exists(script_path / "init.as"))
        return false;

    asSetGlobalMemoryFunctions(allocFunc, freeFunc);

    if (!debugger_state.cvar)
        debugger_state.cvar = Cvar("q2as_debugger", "0", CVAR_NOFLAGS);
    if (!debugger_state.attach_type)
        debugger_state.attach_type = Cvar("q2as_debugger_wait_attach", "0", CVAR_NOFLAGS);
    if (!debugger_state.instrumentation_type)
        debugger_state.instrumentation_type = Cvar("q2as_instrumentation_type", "0", CVAR_NOFLAGS);
    if (!debugger_state.instrumentation_modules)
        debugger_state.instrumentation_modules = Cvar("q2as_instrumentation_modules", "1", CVAR_NOFLAGS);
    if (!debugger_state.instrumentation_granularity)
        debugger_state.instrumentation_granularity = Cvar("q2as_instrumentation_granularity", "0", CVAR_NOFLAGS);

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
    debugger_state.outdated = true;

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

    return true;
}

void q2as_state_t::Destroy()
{
    // destroy debugger
    debugger_state.debugger.reset();

    if (engine)
        engine->ShutDownAndRelease();

    mainModule = nullptr;
    engine = nullptr;

    engines_alive--;

    if (!engines_alive)
    {
        // FIXME: this can't be done currently because of
        // Kex limitations (custom memory tags don't work)
        //(gi.FreeTags ? gi.FreeTags : cgi.FreeTags)(TAG_LEVEL);
        //(gi.FreeTags ? gi.FreeTags : cgi.FreeTags)(TAG_GAME);
    }
}

q2as_ctx_t q2as_state_t::RequestContext()
{
    auto ctx = engine->RequestContext();

    if (debugger_state.instrumentation_type->integer)
    {
        if (debugger_state.instrumentation_modules->integer & instrumentation_bit)
        {
            if (!debugger_state.active_instrumentation)
                StartInstrumentation();
            ctx->SetFunctionCallback(asFUNCTION(InstrumentationCallback), nullptr, asCALL_CDECL);

            if (int r = engine->SetGarbageCollectionCallback(asFUNCTION(GarbageCallback), this, asCALL_CDECL); r < 0)
            {
                Print("Couldn't set AngelScript garbage callback.\n");
            }
        }
    }
    else if (debugger_state.active_instrumentation)
    {
        WriteInstrumentation();
        engine->ClearGarbageCollectionCallback();
    }

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
        return false;
    }

    return true;
}

void q2as_state_t::StartInstrumentation()
{
    if (debugger_state.instrumentation_modules->integer & instrumentation_bit)
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
