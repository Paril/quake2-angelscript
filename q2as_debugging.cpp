#include "q2as_local.h"
#include <chrono>

// DEBUGGER

#include "g_local.h"

#include "q2as_game.h"
#include "q2as_cgame.h"

#include "debugger/as_debugger_dap.h"

class q2as_asIDBCache : public asIDBCache
{
public:
    using asIDBCache::asIDBCache;

    const asIDBTypeEvaluator &GetEvaluator(const asIDBVarAddr &id) const
    {
        if (id.ResolveAs<void>() == nullptr)
            return asIDBCache::GetEvaluator(id);
    
        auto type = ctx->GetEngine()->GetTypeInfoById(id.typeId);

        // do we have a custom evaluator?
        if (auto f = debugger_state.evaluators.find(id.typeId & (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR)); f != debugger_state.evaluators.end())
            return *f->second.get();

        // are we a template?
        if (id.typeId & asTYPEID_TEMPLATE)
        {
            // fetch the base type, see if we have a
            // evaluator for that one
            auto baseType = ctx->GetEngine()->GetTypeInfoByName(type->GetName());

            if (auto f = debugger_state.evaluators.find(baseType->GetTypeId() & (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR)); f != debugger_state.evaluators.end())
                return *f->second.get();
        }

        return asIDBCache::GetEvaluator(id);
    }
};

// VSCode DAP, will be moved into a separate
// type eventually.
class q2as_asIDBDebuggerVSCode : public asIDBDebugger
{
public:
    std::unique_ptr<asIDBDAPServer> server;

    q2as_asIDBDebuggerVSCode(asIDBWorkspace *workspace) :
        asIDBDebugger(workspace)
    {
        server = std::make_unique<asIDBDAPServer>(27979, this);
        server->StartServer();
    }

    virtual ~q2as_asIDBDebuggerVSCode()
    {
    }

    virtual std::string FetchSource(const char *section) override
    {
        // not necessary since the sources are already
        // available in vscode
        return "";
    }

    virtual bool HasWork() override
    {
        server->Tick();

        if (debugger_state.attach_type->integer)
        {
            while (!server->ClientConnected())
            {
                server->Tick();
                std::this_thread::sleep_for(std::chrono::milliseconds(2));
            }

            if (debugger_state.suspend_immediately)
            {
                Suspend();
                debugger_state.suspend_immediately = false;
            }
        }

        return server->ClientConnected() && asIDBDebugger::HasWork();
    }

protected:
    bool resume = false;

    virtual void Suspend() override
    {
        if (!server->ClientConnected())
            return;

        if (cache)
        {
            auto ctx = cache->ctx;

            asIScriptFunction *func = nullptr;
            int col = 0;
            const char *sec = nullptr;
            int row = 0;

            if (ctx->GetState() == asEXECUTION_EXCEPTION)
            {
                func = ctx->GetExceptionFunction();

                if (func)
                    row = ctx->GetExceptionLineNumber(&col, &sec);
            }
            else
            {
                func = ctx->GetFunction(0);

                if (func)
                    row = ctx->GetLineNumber(0, &col, &sec);
            }
        }

        {
            dap::StoppedEvent stoppedEvent;
            stoppedEvent.description = "Paused on breakpoint";
            stoppedEvent.allThreadsStopped = true;
            server->SendEventToClient(stoppedEvent);
        }

        resume = false;

        while (server->ClientConnected() && !resume)
        {
            // TODO: we can use a condition var or something at some point
            std::this_thread::sleep_for(std::chrono::milliseconds(2));

            server->Tick();
        }

        server->Tick();
    }

    // called when the debugger is being asked to resume.
    // don't call directly, use Continue.
    virtual void Resume() override
    {
        resume = true;
    }

    // create a cache for the given context.
    virtual std::unique_ptr<asIDBCache> CreateCache(asIScriptContext *ctx) override
    {
        return std::make_unique<q2as_asIDBCache>(*this, ctx);
    }
};

static std::chrono::high_resolution_clock profile_clock;
static std::chrono::high_resolution_clock::time_point profile_time;

static void q2as_profile_start(const std::string &s)
{
    profile_time = profile_clock.now();
}

static void q2as_profile_end()
{
    auto result = profile_clock.now() - profile_time;

    ((q2as_state_t *) asGetActiveContext()->GetEngine()->GetUserData())->Print(fmt::format("{}\n", result.count()).data());
}

std::string q2as_backtrace()
{
    std::string trace;
    auto ctx = asGetActiveContext();
    auto cs = ctx->GetCallstackSize();

    for (asUINT i = 0; i < cs; i++)
    {
        auto f = ctx->GetFunction(i);
        int col;
        const char *section;
        int row = ctx->GetLineNumber(i, &col, &section);
        fmt::format_to(std::back_inserter(trace), "{} {}[{}:{}]\n", f->GetDeclaration(true, false, true), section, row, col);
    }

    return trace;
}

q2as_dbg_state_t debugger_state;

void q2as_dbg_state_t::CheckDebugger(asIScriptContext *ctx)
{
    // check if the debugger needs to be changed
    if (debugger_state.active_type != debugger_state.cvar->integer)
    {
        debugger_state.debugger.reset();
        debugger_state.workspace.reset();
        debugger_state.active_type = debugger_state.cvar->integer;
    }

    // we don't want debugging
    if (!debugger_state.cvar->integer)
        return;

    // create the debugger
    if (!debugger)
    {
        debugger_state.workspace = std::make_unique<asIDBWorkspace>(std::filesystem::path(Q2AS_ScriptPath()).generic_string(), std::initializer_list<asIScriptEngine *> { svas.engine, cgas.engine });
        debugger = std::make_unique<q2as_asIDBDebuggerVSCode>(debugger_state.workspace.get());
    }

    // hook the context if the debugger
    // has work to do (breakpoints, etc)
    if (debugger->HasWork())
        debugger->HookContext(ctx);
}

void q2as_dbg_state_t::DebugBreak(asIScriptContext *ctx)
{
    if (!ctx)
        ctx = asGetActiveContext();

    if (!debugger)
        CheckDebugger(ctx);

    if (debugger)
        debugger->DebugBreak(ctx);
}

// Register an evaluator.
void q2as_dbg_state_t::RegisterEvaluator(int typeId, std::unique_ptr<asIDBTypeEvaluator> evaluator)
{
    typeId &= asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR;
    evaluators.insert_or_assign(typeId, std::move(evaluator));
}

static void q2as_debugbreak()
{
    debugger_state.DebugBreak();
}

static void q2as_sleep(int sec)
{
    std::this_thread::sleep_for(std::chrono::seconds(sec));
}

static void q2as_typeof(asIScriptGeneric *gen)
{
    int typeId = gen->GetArgTypeId(0);
    std::string s;

    asITypeInfo *ti = gen->GetEngine()->GetTypeInfoById(typeId);

    if (!ti)
    {
        switch (typeId & asTYPEID_MASK_SEQNBR)
        {
        case asTYPEID_BOOL: s = "bool"; break;
        case asTYPEID_INT8: s = "int8"; break;
        case asTYPEID_INT16: s = "int16"; break;
        case asTYPEID_INT32: s = "int32"; break;
        case asTYPEID_INT64: s = "int64"; break;
        case asTYPEID_UINT8: s = "uint8"; break;
        case asTYPEID_UINT16: s = "uint16"; break;
        case asTYPEID_UINT32: s = "uint32"; break;
        case asTYPEID_UINT64: s = "uint64"; break;
        case asTYPEID_FLOAT: s = "float"; break;
        case asTYPEID_DOUBLE: s = "double"; break;
        default: asGetActiveContext()->SetException("bad type"); return;
        }
    }
    else
        s = ti->GetName();

    new(gen->GetAddressOfReturnLocation()) std::string(std::move(s));
}

static void q2as_print(const std::string &s)
{
    auto state = ((q2as_state_t *) asGetActiveContext()->GetEngine()->GetUserData());
    state->Print(s.c_str());
    state->Print("\n");
}

void Q2AS_RegisterDebugging(q2as_registry &registry)
{
    registry
        .for_global()
        .functions({
            { "void profile_start(const string &in)", asFUNCTION(q2as_profile_start), asCALL_CDECL },
            { "void profile_end()",                   asFUNCTION(q2as_profile_end),   asCALL_CDECL },
            { "string backtrace()",                   asFUNCTION(q2as_backtrace),     asCALL_CDECL },
            { "void debugbreak()",                    asFUNCTION(q2as_debugbreak),    asCALL_CDECL },
            { "void sleep(int)",                      asFUNCTION(q2as_sleep),         asCALL_CDECL },
            { "void print(const string &in s)",       asFUNCTION(q2as_print),         asCALL_CDECL },
            { "string typeof(const ? &in)",           asFUNCTION(q2as_typeof),        asCALL_GENERIC }
        });
}
