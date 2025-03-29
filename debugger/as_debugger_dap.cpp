// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#include "as_debugger.h"
#include "as_debugger_dap.h"

class asIDBDAPClient
{
public:
    asIDBDebugger                 *dbg;
    std::atomic_bool              configuration_complete = false;
    std::atomic_bool              terminate = false;
    std::unique_ptr<dap::Session> session;

    asIDBDAPClient(asIDBDebugger *dbg, const std::shared_ptr<dap::ReaderWriter> &socket) :
        dbg(dbg),
        session(dap::Session::create())
    {
        session->setOnInvalidData(dap::kClose);
        session->bind(socket);

        session->registerHandler([&](const dap::InitializeRequest &request) {
            dap::InitializeResponse response;
            response.supportsClipboardContext = true;
            response.supportsCompletionsRequest = true;
            response.supportsConfigurationDoneRequest = true;
            response.supportsDelayedStackTraceLoading = true;
            response.supportsEvaluateForHovers = true;
            response.supportsFunctionBreakpoints = true;
            response.supportsBreakpointLocationsRequest = true;
            return response;
        });

        session->registerHandler([&](const dap::DisconnectRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::SetBreakpointsRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::SetFunctionBreakpointsRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::ConfigurationDoneRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::ThreadsRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::StackTraceRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::ScopesRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::VariablesRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::ContinueRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::StepOutRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::StepInRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::NextRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::EvaluateRequest &request) { return this->HandleRequest(request); });
        session->registerHandler([&](const dap::BreakpointLocationsRequest &request) { return this->HandleRequest(request); });
        
        session->registerSentHandler([&](const dap::ResponseOrError<dap::InitializeResponse> &response) { OnResponseSent(response); });
        session->registerSentHandler([&](const dap::ResponseOrError<dap::ConfigurationDoneResponse> &response) { OnResponseSent(response); });
    }

    dap::BreakpointLocationsResponse HandleRequest(const dap::BreakpointLocationsRequest &request)
    {
        dap::BreakpointLocationsResponse response;

        for (auto &engine : dbg->engines)
        {
        }

        return response;
    }

    dap::DisconnectResponse HandleRequest(const dap::DisconnectRequest &request)
    {
        terminate = true;
        return dap::DisconnectResponse {};
    }

    dap::SetBreakpointsResponse HandleRequest(const dap::SetBreakpointsRequest &request)
    {
        dap::SetBreakpointsResponse response;

        if (request.source.path) {
            auto rel = std::filesystem::relative(request.source.path.value(), dbg->workspace.base_path);
            auto pathstr = rel.generic_string();

            std::scoped_lock lock(dbg->mutex);

            dbg->workspace.sections.insert(pathstr);

            if (auto it = dbg->breakpoints.find(pathstr); it != dbg->breakpoints.end())
                dbg->breakpoints.erase(it);

            if (request.breakpoints && !request.breakpoints->empty()) {
                auto it = dbg->breakpoints.insert({ *dbg->workspace.sections.find(pathstr), asIDBSectionBreakpoints {} });
                for (auto &bp : *request.breakpoints) {
                    it.first->second.push_back({ (int) bp.line });
                }
            }
        }

        return response;
    }

    dap::SetFunctionBreakpointsResponse HandleRequest(const dap::SetFunctionBreakpointsRequest &request)
    {
        return {};
    }

    dap::ConfigurationDoneResponse HandleRequest(const dap::ConfigurationDoneRequest &request)
    {
        return {};
    }

    dap::ThreadsResponse HandleRequest(const dap::ThreadsRequest &request)
    {
        dap::ThreadsResponse response {};
        response.threads.push_back({
            1, "Main"
        });
        return response;
    }

    dap::StackTraceResponse HandleRequest(const dap::StackTraceRequest &request)
    {
        dap::StackTraceResponse response {};

        if (!dbg->cache || !dbg->cache->ctx)
            return response;

        dbg->cache->CacheCallstack();

        int64_t start = request.startFrame.has_value() ? (int64_t)(*request.startFrame) : (int64_t)0;
        int64_t levels = (request.levels.has_value() && request.levels.value() > 0) ? (int64_t)(*request.levels) : (int64_t) 9999;

        response.totalFrames = dbg->cache->call_stack.size();
                
        for (asUINT i = 0; i < levels && (size_t) (i + start) < dbg->cache->call_stack.size(); i++)
        {
            auto &frame = response.stackFrames.emplace_back();
            auto &stack = dbg->cache->call_stack[i + start];
            frame.id = stack.id;
            if (stack.scope.offset != SCOPE_SYSTEM)
            {
                frame.line = stack.row;
                frame.column = stack.column;
                dap::Source src;
                src.path = dbg->workspace.SectionToPath(stack.section);
                src.name = std::string(stack.section);
                frame.source = std::move(src);
            }
            else
                frame.presentationHint = "label";
            frame.name = stack.declaration;
        }

        return response;
    }

    dap::ResponseOrError<dap::ScopesResponse> HandleRequest(const dap::ScopesRequest &request)
    {
        dap::ScopesResponse response {};
        bool found = false;

        for (auto &stack : dbg->cache->call_stack)
        {
            if (stack.id != request.frameId)
                continue;

            if (stack.scope.locals)
            {
                auto &scope = response.scopes.emplace_back();
                scope.name = "Locals";
                scope.presentationHint = "locals";
                scope.namedVariables = stack.scope.locals->named_variables.size();
                scope.variablesReference = stack.scope.locals->ref_id;
            }
            if (stack.scope.parameters)
            {
                auto &scope = response.scopes.emplace_back();
                scope.name = "Parameters";
                scope.presentationHint = "parameters";
                scope.namedVariables = stack.scope.parameters->named_variables.size();
                scope.variablesReference = stack.scope.parameters->ref_id;
            }
            if (stack.scope.registers)
            {
                auto &scope = response.scopes.emplace_back();
                scope.name = "Registers";
                scope.presentationHint = "registers";
                scope.namedVariables = stack.scope.registers->named_variables.size();
                scope.variablesReference = stack.scope.registers->ref_id;
            }
#if 0
            {
                auto &scope = response.scopes.emplace_back();
                scope.name = "Globals";
                scope.presentationHint = "globals";
                scope.namedVariables = dbg->cache->global.count;
                scope.expensive = true;
                scope.variablesReference = dbg->cache->global.variable_ref;
            }
#endif
            found = true;
            break;
        }

        if (!found)
            return dap::Error { "invalid stack ID" };

        return response;
    }

    dap::ResponseOrError<dap::VariablesResponse> HandleRequest(const dap::VariablesRequest &request)
    {
        auto varit = dbg->cache->variables.find(request.variablesReference);

        if (varit == dbg->cache->variables.end())
            return dap::Error("invalid variablesReference");

        dap::VariablesResponse response {};
        auto &varContainer = *varit->second.get();

        varContainer.Cache();
                
        for (auto &local : varContainer.named_variables)
        {
            auto &var = response.variables.emplace_back();
            var.name = local.name;
            var.type = dap::string(local.type);
            var.value = local.value.empty() ? dbg->cache->GetTypeNameFromType({ local.address.source.typeId, asTM_NONE }) : local.value;
            var.variablesReference = local.container ? local.container->ref_id : 0;
        }

        return response;
    }

    dap::ContinueResponse HandleRequest(const dap::ContinueRequest &request)
    {
        dbg->SetAction(asIDBAction::Continue);
        return {};
    }

    dap::StepOutResponse HandleRequest(const dap::StepOutRequest &request)
    {
        dbg->SetAction(asIDBAction::StepOut);
        return {};
    }

    dap::StepInResponse HandleRequest(const dap::StepInRequest &request)
    {
        dbg->SetAction(asIDBAction::StepInto);
        return {};
    }

    dap::NextResponse HandleRequest(const dap::NextRequest &request)
    {
        dbg->SetAction(asIDBAction::StepOver);
        return {};
    }

    dap::EvaluateResponse HandleRequest(const dap::EvaluateRequest &request)
    {
        dap::EvaluateResponse response {};
        auto result = dbg->cache->ResolveExpression(request.expression, 0);

        if (result.has_value())
        {
            response.result = result.value().value.value.value;
            response.type = std::string(dbg->cache->GetTypeNameFromType({ result.value().idKey.typeId }));
        }
        return response;
    }

    void OnResponseSent(const dap::ResponseOrError<dap::InitializeResponse> &response)
    {
        {
            std::scoped_lock lock(dbg->mutex);
            dbg->breakpoints.clear();
        }
        session->send(dap::InitializedEvent());
    }

    void OnResponseSent(const dap::ResponseOrError<dap::ConfigurationDoneResponse> &response)
    {
        dap::ThreadEvent threadStartedEvent;
        threadStartedEvent.reason = "started";
        threadStartedEvent.threadId = 1;
        session->send(threadStartedEvent);

        configuration_complete = true;
    }
};

asIDBDAPServer::asIDBDAPServer(int port, asIDBDebugger *debugger) :
    port(port),
    dbg(debugger)
{
}

/*virtual*/ asIDBDAPServer::~asIDBDAPServer()
{
    StopServer();
}

void asIDBDAPServer::ClientConnected(const std::shared_ptr<dap::ReaderWriter> &socket)
{
    client = std::make_unique<asIDBDAPClient>(dbg, socket);
}

void asIDBDAPServer::ClientError(const char *msg)
{
}

void asIDBDAPServer::StartServer()
{
    server = dap::net::Server::create();

    server->start(port,
        [&](const std::shared_ptr<dap::ReaderWriter> &socket) { this->ClientConnected(socket); },
        [&](const char *msg) { this->ClientError(msg); }
    );
}

void asIDBDAPServer::StopServer()
{
    server.reset();
    client.reset();
}

void asIDBDAPServer::Tick()
{
    if (client && client->terminate)
        client.reset();
}

void asIDBDAPServer::SendEventToClient(const dap::TypeInfo *typeinfo, const void *event)
{
    if (client)
        client->session->send(typeinfo, event);
}