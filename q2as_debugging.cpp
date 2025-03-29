#include "q2as_local.h"
#include <chrono>

// DEBUGGER

#include "debugger/as_debugger_imgui.h"

#define WIN32_LEAN_AND_MEAN
#include "debugger/imgui.h"
#include "debugger/imgui_impl_dx9.h"
#include "debugger/imgui_impl_win32.h"
#include <d3d9.h>
#include <tchar.h>

#pragma comment(lib, "d3d9.lib")

#undef min
#undef max
#undef hyper

#include "g_local.h"

#include "q2as_game.h"
#include "q2as_cgame.h"

#include <filesystem>

class q2as_asIDBStringTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override
    {
        const std::string *s = reinterpret_cast<const std::string *>(id.resolved);

        if (s->empty())
            return { "empty", true };

        return { *s, true, asIDBExpandType::Value };
    }
};

class q2as_asIDBVec3TypeEvaluator : public asIDBObjectTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override
    {
        const vec3_t *s = reinterpret_cast<const vec3_t *>(id.resolved);

        return { fmt::format("{} {} {}", s->x, s->y, s->z), false, asIDBExpandType::Children };
    }
};

class q2as_asIDBGTimeTypeEvaluator : public asIDBObjectTypeEvaluator
{
    static constexpr std::tuple<uint64_t, const char *> time_suffixes[] = {
        { 1000 * 60 * 60, "hr" },
        { 1000 * 60, "min" },
        { 1000, "sec" }
    };

public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override
    {
        const gtime_t *s = reinterpret_cast<const gtime_t *>(id.resolved);

        const char *sfx = "ms";
        uint64_t divisor = 1;

        for (auto &suffix : time_suffixes)
            if ((uint64_t) abs(s->milliseconds()) >= std::get<0>(suffix))
            {
                divisor = std::get<0>(suffix);
                sfx = std::get<1>(suffix);
                break;
            }

        return { fmt::format("{} {}", s->milliseconds() / (double) divisor, sfx), false, asIDBExpandType::Entries };
    }

    virtual void Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const override
    {
        const gtime_t *s = reinterpret_cast<const gtime_t *>(id.resolved);

        for (auto &suffix : time_suffixes)
            if ((uint64_t) abs(s->milliseconds()) >= std::get<0>(suffix))
                state.entries.push_back({ fmt::format("{} {}", s->milliseconds() / (double) std::get<0>(suffix), std::get<1>(suffix)) });
            
        state.entries.push_back({ fmt::format("{} ms", s->milliseconds()) });
    }
};

class q2as_asIDBArrayTypeEvaluator : public asIDBObjectTypeEvaluator
{
public:
    virtual void Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const override
    {
        QueryVariableForEach(cache, id, state, 0);
    }
};

class q2as_asIDBCache : public asIDBCache
{
public:
    q2as_asIDBCache(asIDBDebugger *dbg, asIScriptContext *ctx) :
        asIDBCache(dbg, ctx)
    {
        auto engine = ctx->GetEngine();
        
        evaluators.Register<q2as_asIDBStringTypeEvaluator>(engine, "string");
        evaluators.Register<q2as_asIDBVec3TypeEvaluator>(engine, "vec3_t");
        evaluators.Register<q2as_asIDBGTimeTypeEvaluator>(engine, "gtime_t");
        evaluators.Register<q2as_asIDBArrayTypeEvaluator>(engine, "array");
    }
};

#ifdef ENABLE_UI_DEBUGGER
#include <thread>

class q2as_imguiDebuggerUI : public asIDBImGuiFrontend
{
public:
    q2as_imguiDebuggerUI(asIDBDebugger *debugger) :
        asIDBImGuiFrontend(debugger)
    {
        ui = this;
    }

    virtual ~q2as_imguiDebuggerUI()
    {
        BackendShutdown();
    }

    bool SetupWindow();

    virtual void SetWindowVisibility(bool visible) override
    {
        ShowWindow(hWnd, visible ? SW_SHOW : SW_HIDE);
        isVisible = visible;
    }

protected:
    void BackendShutdown()
    {
        ImGui_ImplDX9_Shutdown();
        ImGui_ImplWin32_Shutdown();

        CleanupDeviceD3D();
        ::DestroyWindow(hWnd);
        ::UnregisterClassW(wc.lpszClassName, wc.hInstance);
    }

    bool resume = false;

    asIDBFrameResult BackendNewFrame() override
    {
        if (resume)
        {
            resume = false;
            debugger->SetAction(asIDBAction::Continue);
            return asIDBFrameResult::Defer;
        }

        // Poll and handle messages (inputs, window resize, etc.)
        // See the WndProc() function below for our to dispatch events to the Win32 backend.
        MSG msg;
        while (::PeekMessage(&msg, nullptr, 0U, 0U, PM_REMOVE))
        {
            ::TranslateMessage(&msg);
            ::DispatchMessage(&msg);
            
            if (msg.message == WM_QUIT)
            {
                return asIDBFrameResult::Exit;
            }
        }

        // Handle lost D3D9 device
        if (g_DeviceLost)
        {
            HRESULT hr = g_pd3dDevice->TestCooperativeLevel();
            if (hr == D3DERR_DEVICELOST)
            {
                ::Sleep(10);
                return asIDBFrameResult::Defer;
            }
            if (hr == D3DERR_DEVICENOTRESET)
                ResetDevice();
            g_DeviceLost = false;
        }

        // Handle window resize (we don't resize directly in the WM_SIZE handler)
        if (g_ResizeWidth != 0 && g_ResizeHeight != 0)
        {
            g_d3dpp.BackBufferWidth = g_ResizeWidth;
            g_d3dpp.BackBufferHeight = g_ResizeHeight;
            g_ResizeWidth = g_ResizeHeight = 0;
            ResetDevice();
        }

        ImGui_ImplDX9_NewFrame();
        ImGui_ImplWin32_NewFrame();

        return asIDBFrameResult::OK;
    }

    void BackendRender() override
    {
        g_pd3dDevice->SetRenderState(D3DRS_ZENABLE, FALSE);
        g_pd3dDevice->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
        g_pd3dDevice->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
        D3DCOLOR clear_col_dx = D3DCOLOR_RGBA((int)(clear_color.x*clear_color.w*255.0f), (int)(clear_color.y*clear_color.w*255.0f), (int)(clear_color.z*clear_color.w*255.0f), (int)(clear_color.w*255.0f));
        g_pd3dDevice->Clear(0, nullptr, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, clear_col_dx, 1.0f, 0);
        if (g_pd3dDevice->BeginScene() >= 0)
        {
            ImGui::Render();
            ImGui_ImplDX9_RenderDrawData(ImGui::GetDrawData());
            g_pd3dDevice->EndScene();
        }
        HRESULT result = g_pd3dDevice->Present(nullptr, nullptr, nullptr, nullptr);
        if (result == D3DERR_DEVICELOST)
            g_DeviceLost = true;
    }

    // Windows window
    HWND                    hWnd = {};
    WNDCLASSEXW             wc = {};
    
    // D3D
    LPDIRECT3D9              g_pD3D = nullptr;
    LPDIRECT3DDEVICE9        g_pd3dDevice = nullptr;
    bool                     g_DeviceLost = false;
    UINT                     g_ResizeWidth = 0, g_ResizeHeight = 0;
    D3DPRESENT_PARAMETERS    g_d3dpp = {};

    void SetupImGuiBackend() override;

    bool CreateDeviceD3D();
    void CleanupDeviceD3D();
    void ResetDevice();

    // TODO is there a better way of doing this?
    // we'll only ever have one UI...
    static q2as_imguiDebuggerUI *ui;

    static LRESULT WINAPI WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
    {
        // Forward declare message handler from imgui_impl_win32.cpp
        extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);

        // Win32 message handler
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        if (ImGui_ImplWin32_WndProcHandler(hWnd, msg, wParam, lParam))
            return true;

        switch (msg)
        {
        case WM_SIZE:
            if (wParam == SIZE_MINIMIZED)
                return 0;
            ui->g_ResizeWidth = (UINT)LOWORD(lParam); // Queue resize
            ui->g_ResizeHeight = (UINT)HIWORD(lParam);
            return 0;
        case WM_SYSCOMMAND:
            if ((wParam & 0xfff0) == SC_KEYMENU) // Disable ALT application menu
                return 0;
            break;
        case WM_DESTROY:
            ::PostQuitMessage(0);
            return 0;
        case WM_CLOSE:
            ui->resume = true;
            ui->SetWindowVisibility(false);
            return 0;
        }
        return ::DefWindowProcW(hWnd, msg, wParam, lParam);
    }
};

/*static*/ q2as_imguiDebuggerUI *q2as_imguiDebuggerUI::ui = nullptr;

class q2as_asIDBDebuggerUI : public asIDBDebugger
{
public:
    q2as_asIDBDebuggerUI()
    {
        workspace = debugger_state.workspace;
        ui = std::make_unique<q2as_imguiDebuggerUI>(this);
        ui_thread = std::thread(RunThread, this);
        ui->SetWindowVisibility(true);
    }

    ~q2as_asIDBDebuggerUI()
    {
        StopThread();
    }
    
    std::string FetchSource(const char *section) override
    {
        return (svas.mainModule ? (q2as_state_t &) svas : (q2as_state_t &)cgas).LoadFile(((workspace.base_path + "/") + section).c_str());
    }

protected:
    void StopThread()
    {
        wants_exit = true;
        wants_render = false;

        if (ui)
            ui_thread.join();

        ui.reset();
    }

    virtual std::unique_ptr<asIDBCache> CreateCache(asIScriptContext *ctx) override
    {
        auto cache = std::make_unique<q2as_asIDBCache>(this, ctx);
        
        cache->CacheCallstack();
        
        return cache;
    }

    std::atomic_bool wants_exit = false;
    std::atomic_bool wants_render = true;

    static void RunThread(q2as_asIDBDebuggerUI *dbg)
    {
        if (!dbg->ui->SetupWindow())
            return;

        dbg->ui->SetupImGui();

        while (!dbg->wants_exit)
        {
            if (!dbg->ui->Render(dbg->wants_render))
                break;
        }

        dbg->wants_exit = true;
        dbg->wants_render = false;
    }

    virtual void Suspend() override
    {
        // ping the UI that we want rendering again
        ui->SetWindowVisibility(true);
        ui->ChangeScript();
        wants_render = true;

        while (wants_render && ui_thread.joinable())
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    virtual void Resume() override
    {
        // this lock makes sure the renderer
        // is suspended at the top of the loop
        std::scoped_lock lock(ui->debugger->mutex);

        // ask the UI to stop
        wants_render = false;
    }

    std::unique_ptr<q2as_imguiDebuggerUI> ui;
    std::thread ui_thread;
};

// Data

bool q2as_imguiDebuggerUI::SetupWindow()
{
    wc = { sizeof(wc), CS_CLASSDC, WndProc, 0L, 0L, GetModuleHandle(nullptr), nullptr, nullptr, nullptr, nullptr, L"AngelScript Debugger Class", nullptr };
    ::RegisterClassExW(&wc);
    hWnd = ::CreateWindowW(wc.lpszClassName, L"AngelScript Debugger", WS_OVERLAPPEDWINDOW | WS_EX_TOPMOST, 100, 100, 1280, 800, GetActiveWindow(), nullptr, wc.hInstance, nullptr);

    // Initialize Direct3D
    if (!CreateDeviceD3D())
    {
        CleanupDeviceD3D();
        ::UnregisterClassW(wc.lpszClassName, wc.hInstance);
        return false;
    }

    // Show the window
    ::ShowWindow(hWnd, SW_SHOWDEFAULT);
    ::UpdateWindow(hWnd);

    return true;
}

bool q2as_imguiDebuggerUI::CreateDeviceD3D()
{
    if ((g_pD3D = Direct3DCreate9(D3D_SDK_VERSION)) == nullptr)
        return false;

    // Create the D3DDevice
    ZeroMemory(&g_d3dpp, sizeof(g_d3dpp));
    g_d3dpp.Windowed = TRUE;
    g_d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
    g_d3dpp.BackBufferFormat = D3DFMT_UNKNOWN; // Need to use an explicit format with alpha if needing per-pixel alpha composition.
    g_d3dpp.EnableAutoDepthStencil = TRUE;
    g_d3dpp.AutoDepthStencilFormat = D3DFMT_D16;
    g_d3dpp.PresentationInterval = D3DPRESENT_INTERVAL_ONE;           // Present with vsync
    //g_d3dpp.PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;   // Present without vsync, maximum unthrottled framerate
    if (g_pD3D->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd, D3DCREATE_HARDWARE_VERTEXPROCESSING, &g_d3dpp, &g_pd3dDevice) < 0)
        return false;

    return true;
}

void q2as_imguiDebuggerUI::CleanupDeviceD3D()
{
    if (g_pd3dDevice) { g_pd3dDevice->Release(); g_pd3dDevice = nullptr; }
    if (g_pD3D) { g_pD3D->Release(); g_pD3D = nullptr; }
}

void q2as_imguiDebuggerUI::ResetDevice()
{
    ImGui_ImplDX9_InvalidateDeviceObjects();
    HRESULT hr = g_pd3dDevice->Reset(&g_d3dpp);
    if (hr == D3DERR_INVALIDCALL)
        IM_ASSERT(0);
    ImGui_ImplDX9_CreateDeviceObjects();
}

void q2as_imguiDebuggerUI::SetupImGuiBackend()
{
    // Setup Platform/Renderer backends
    ImGui_ImplWin32_Init(hWnd);
    ImGui_ImplDX9_Init(g_pd3dDevice);
}
#endif

#include "debugger/as_debugger_dap.h"

// VSCode DAP, will be moved into a separate
// type eventually.
class q2as_asIDBDebuggerVSCode : public asIDBDebugger
{
public:
    std::unique_ptr<asIDBDAPServer> server;

    q2as_asIDBDebuggerVSCode()  :
        asIDBDebugger()
    {
        workspace = debugger_state.workspace;
        if (svas.engine)
            engines.insert(svas.engine);
        if (cgas.engine)
            engines.insert(cgas.engine);
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

        return server->ClientConnected() && asIDBDebugger::HasWork();
    }

protected:
    bool resume = false;

    virtual void Suspend() override
    {
        if (!server->ClientConnected())
            return;

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

        {
            dap::StoppedEvent stoppedEvent;
            stoppedEvent.reason = "breakpoint";
            stoppedEvent.threadId = 1;
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
        return std::make_unique<q2as_asIDBCache>(this, ctx);
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

    ((q2as_state_t *) asGetActiveContext()->GetEngine()->GetUserData())->Print(G_Fmt("{}\n", result.count()).data());
}

static std::string q2as_backtrace()
{
    std::string trace;
    auto ctx = asGetActiveContext();
    auto cs = ctx->GetCallstackSize();

    for (asUINT i = 0; i < cs; i++)
    {
        auto f = ctx->GetFunction(i);
        int col;
        int row = ctx->GetLineNumber(i, &col);
        trace += G_Fmt("{} [{}:{}]\n", f->GetDeclaration(true, false, true), row, col);
    }

    return trace;
}

q2as_dbg_state_t debugger_state;

void q2as_dbg_state_t::CheckDebugger(asIScriptContext *ctx)
{
    // check if the debugger needs to be changed
    if (debugger_state.debugger_type != debugger_state.debugger_cvar->integer)
    {
        debugger_state.debugger.reset();
        debugger_state.debugger_type = debugger_state.debugger_cvar->integer;
    }

    // we don't want debugging
    if (!debugger_state.debugger_cvar->integer)
        return;

    // create the debugger
    if (!debugger)
    {
#ifdef ENABLE_UI_DEBUGGER
        if (debugger_state.debugger_cvar->integer == 1)
            debugger = std::make_unique<q2as_asIDBDebuggerUI>();
        else
#endif
            debugger = std::make_unique<q2as_asIDBDebuggerVSCode>();
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
