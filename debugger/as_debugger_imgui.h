// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#pragma once

#ifdef ENABLE_UI_DEBUGGER

#include "as_debugger.h"
#include "TextEditor.h"

enum class asIDBFrameResult
{
    OK,    // render
    Exit,  // exit requested
    Defer  // don't render, but not quitting
};

enum class asIDBPopupState
{
    Closed,
    Opening,
    Open
};

enum class asIDBVarPopupWindow
{
    None,
    Variables,
    Watch
};

// watch entry name + result.
// set to dirty if the value is out of date.
struct asIDBWatchEntry : public asIDBVarViewBase
{
    bool                               dirty = true;
    asIDBExpected<asIDBExprResult>     result;

    inline asIDBWatchEntry(const char *expr) :
        asIDBVarViewBase(expr, "")
    {
    }

    virtual const asIDBVarAddr &GetID() const override { return result.value().idKey; }
    virtual asIDBVarState &GetState() override { return result.value().value; }
    virtual const asIDBVarState &GetState() const override { return result.value().value; }
    virtual bool IsValid() const override { return result.has_value(); }
};

using asIDBWatchEntryVector = std::vector<asIDBWatchEntry>;

// Front end base class for an ImGui debugger.
// Requires ImGui Docking and some third party
// stuff that is in the same folder here.
/*abstract*/ class asIDBImGuiFrontend
{
public:
    asIDBDebugger *debugger;

    // cached watch
    asIDBWatchEntryVector watch;

    asIDBImGuiFrontend(asIDBDebugger *debugger) :
        debugger(debugger)
    {
    }

    virtual ~asIDBImGuiFrontend()
    {
        ImGui::DestroyContext();
    }

    // this must be called some time before Render.
    void SetupImGui();

    // script changed, so clear stuff that
    // depends on the old script.
    void ChangeScript();

    // this is the loop for the thread.
    // return false if the UI has decided to exit.
    bool Render(bool full);

    // window renderings
    void RenderVariableTable(const char *label, std::function<void()> render_variables);
    void RenderLocals(const char *filter, asIDBScope &scope, asIDBLocalScopeVariables &variables);
    void RenderGlobals(const char *filter, bool showConstants, bool showNamespaced);
    void RenderWatch();

    virtual void SetWindowVisibility(bool visible) = 0;
    bool IsWindowVisible() { return isVisible; }

protected:
    bool show_demo_window = true;
    bool show_another_window = false;
    bool isVisible = true, wasVisible = false;
    bool showExceptionWindow = true;
    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
    TextEditor editor;

    int selected_context = 0;
    int selected_stack_entry = 0;
    std::string_view selected_stack_section;
    int update_row = 0;

    bool setupDock = true;
    ImGuiViewport* viewport = nullptr;
    ImGuiID dockspace_id = 0;

    bool resetOpenStates = false;

    // renders a single debugger variable
    asIDBPopupState openVariablePopup = asIDBPopupState::Closed;
    asIDBVarPopupWindow variablePopupWindow = asIDBVarPopupWindow::None;
    std::vector<const asIDBVarViewBase *> rightClickedVariableStack;
    bool RenderDebuggerVariable(asIDBVarViewBase &varView, const char *filter);

    // Setup the backend for ImGui.
    virtual void SetupImGuiBackend() = 0;

    // Called before ImGui new frame.
    // Return false to break from Render().
    virtual asIDBFrameResult BackendNewFrame() = 0;

    // Called at the end of render loop.
    virtual void BackendRender() = 0;
};

#endif