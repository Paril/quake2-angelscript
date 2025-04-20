#include "q2as_local.h"
#include "q_std.h"
#include "thirdparty/scripthelper/scripthelper.h"
#include "q2as_platform.h"
#include "debugger/as_debugger.h"

static std::chrono::high_resolution_clock cl;

static void InstrumentationCallback(asSFunctionInfo *info)
{
    q2as_state_t *state = (q2as_state_t *) info->context->GetEngine()->GetUserData(0);
    
    static std::unordered_map<asIScriptFunction *, declhash_t> decls;

    declhash_t *hashed;

    if (auto f = decls.find(info->function); f != decls.end())
    {
        hashed = &f->second;

        if (info->popped)
            fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_END track_uuid: 1 }} trusted_packet_sequence_id: 1 sequence_flags: 2 }}\n", cl.now().time_since_epoch().count());
        else
            fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_BEGIN track_uuid: 1 name_iid: {} }} trusted_packet_sequence_id: 1 }}\n", cl.now().time_since_epoch().count(), hashed->h);
    }
    else
    {
        const char *decl = info->function->GetDeclaration();
        hashed = &decls.emplace(info->function, declhash_t { decl, decls.size() + 1 }).first->second;

        if (info->popped)
            fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_END track_uuid: 1 }} trusted_packet_sequence_id: 1 sequence_flags: 2 }}\n", cl.now().time_since_epoch().count());
        else
            fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_BEGIN track_uuid: 1 name_iid: {} }} trusted_packet_sequence_id: 1 interned_data {{ event_names: {{ iid: {} name: \"{}\" }} }} }}\n", cl.now().time_since_epoch().count(), hashed->h, hashed->h, hashed->s);
    }

}

static void InstrumentationGarbageCallback(q2as_state_t *state, bool pop)
{
    static declhash_t garbage_hash { "GC", /*plPriv::hashString("GC")*/ 0 };

    if (pop)
        fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_END track_uuid: 4 }} trusted_packet_sequence_id: 1 }}\n", cl.now().time_since_epoch().count());
    else
        fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} track_event {{ type: TYPE_SLICE_BEGIN track_uuid: 4 name: \"{}\" }} trusted_packet_sequence_id: 1 }}\n", cl.now().time_since_epoch().count(), "GC");
}

static void WriteInstrumentation()
{
    debugger_state.instru_of.close();
    debugger_state.instrumenting = false;
}

static void FlushInstrumentation()
{
}

static void StartInstrumentation(q2as_state_t &as)
{
    if (debugger_state.instrumenting)
        return;

    debugger_state.instru_of.open("profile.trace");
    fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ track_descriptor: {{ uuid: 2 process: {{ pid: 1 process_name: \"Angelscript\" }} }} }}\n");
    fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ track_descriptor: {{ uuid: 1 thread: {{ pid: 1 tid: 2 thread_name: \"Server\" }} }} }}\n");
    fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ track_descriptor: {{ uuid: 4 thread: {{ pid: 1 tid: 3 thread_name: \"GC\" }} }} }}\n");
    fmt::format_to(std::ostream_iterator<char>(debugger_state.instru_of), "packet {{ timestamp: {} trusted_packet_sequence_id: 1 first_packet_on_sequence: true previous_packet_dropped: true sequence_flags: 3 }}\n", cl.now().time_since_epoch().count());
    debugger_state.instrumenting = true;
}

static void MessageCallback(const asSMessageInfo *msg, void *param)
{
    const char *type = "ERR ";

    if (msg->type == asMSGTYPE_WARNING)
        type = "WARN";
    else if (msg->type == asMSGTYPE_INFORMATION)
        type = "INFO";

    ((q2as_state_t *) param)->Print(fmt::format("{} ({}, {}) : {} : {}\n", msg->section, msg->row, msg->col, type, msg->message).data());

    //if (msg->type == asMSGTYPE_ERROR)
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

    if (int r = engine->SetGarbageCollectionCallback(asFUNCTION(GarbageCallback), this, asCALL_CDECL); r < 0)
    {
        Print("Couldn't set AngelScript garbage callback.\n");
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

    if (debugger_state.instrumentation->integer & instrumentation_bit)
        ctx->SetFunctionCallback(asFUNCTION(InstrumentationCallback), nullptr, asCALL_CDECL);

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
    if (debugger_state.instrumentation->integer & instrumentation_bit)
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
