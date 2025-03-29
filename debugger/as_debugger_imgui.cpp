// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#ifdef ENABLE_UI_DEBUGGER

#include "as_debugger_imgui.h"
#include <optional>
#include "imgui.h"
#include "imgui_internal.h"

void asIDBImGuiFrontend::SetupImGui()
{
    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = nullptr;
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();

    viewport = ImGui::GetMainViewport();

    SetupImGuiBackend();

    // add default font as fallback for ui
    io.Fonts->AddFontDefault();

    editor.SetReadOnlyEnabled(true);
    editor.SetLanguage(TextEditor::Language::AngelScript());
    editor.SetLineDecorator(17.f, [this](TextEditor::Decorator &decorator) {
        auto size = decorator.height - 1.0f;
        auto pos = ImGui::GetCursorScreenPos();
        auto drawlist = ImGui::GetWindowDrawList();

        if (ImGui::InvisibleButton("##Toggle", ImVec2(size, size)))
            debugger->ToggleBreakpoint(selected_stack_section, decorator.line + 1);

        if (auto it = debugger->breakpoints.find(selected_stack_section); it != debugger->breakpoints.end())
        {
            for (auto &bp : it->second)
            {
                if (decorator.line + 1 == bp.line)
                {
                    drawlist->AddCircleFilled(
                        ImVec2(pos.x - 1 + size * 0.5, pos.y + size * 0.5f),
                        (size - 6.0f) * 0.5f,
                        IM_COL32(255, 0, 0, 255));
                    break;
                }
            }
        }

        if (decorator.line == update_row - 1)
        {
            float end = size * 0.7;
            const ImVec2 points[] = {
                pos,
                ImVec2(pos.x + end, pos.y),
                ImVec2(pos.x + size, pos.y + size * 0.5f),
                ImVec2(pos.x + end, pos.y + size),
                ImVec2(pos.x, pos.y + size),
                pos
            };
            drawlist->AddPolyline(points, std::extent_v<decltype(points)>,
                (debugger->cache->call_stack[selected_stack_entry].scope.offset != SCOPE_SYSTEM) ? IM_COL32(255, 255, 0, 255) : IM_COL32(0, 255, 255, 255),
                ImDrawFlags_RoundCornersAll, 1.5);
        }
    });
    // TODO: text callback for watch/breakpoints

    if (debugger->cache)
        ChangeScript();
}

// script changed, so clear stuff that
// depends on the old script.
void asIDBImGuiFrontend::ChangeScript()
{
    editor.ClearCursors();
    editor.ClearMarkers();

    asIScriptContext *ctx = debugger->cache->ctx;
    
    asIScriptFunction *func = nullptr;

    if (selected_stack_entry == 0 && debugger->cache->call_stack.front().scope.offset == SCOPE_SYSTEM)
        selected_stack_entry = 1;

    auto &stack = debugger->cache->call_stack[selected_stack_entry];
    update_row = stack.row;
    std::string_view sec = stack.section;

    if (!sec.empty())
    {
        if (selected_stack_section != sec)
        {
            selected_stack_section = sec;

            auto file = debugger->FetchSource(sec.data());
            editor.SetText(file);
        }

        editor.SetCursor(update_row - 1, 0);
        editor.ScrollToLine(update_row - 1, TextEditor::Scroll::alignMiddle);
        editor.AddMarker(update_row - 1, 0, IM_COL32(127, 127, 0, 127), "", "");
    }

    resetOpenStates = true;
}

// this is the loop for the thread.
// return false if the UI has decided to exit.
bool asIDBImGuiFrontend::Render(bool full)
{
    // check if we need to defer or exit
    {
        asIDBFrameResult result = BackendNewFrame();

        if (result == asIDBFrameResult::Exit)
            return false;
        else if (result == asIDBFrameResult::Defer)
            full = false;
    }

    bool resetText = false;

    ImGui::NewFrame();
    
    dockspace_id = ImGui::DockSpaceOverViewport(0, viewport);

    if (setupDock)
    {
        ImGui::DockBuilderAddNode(dockspace_id, ImGuiDockNodeFlags_DockSpace);
        ImGui::DockBuilderSetNodeSize(dockspace_id, viewport->WorkSize);

        {
            ImGuiID dock_id_down = 0, dock_id_top = 0;
            ImGui::DockBuilderSplitNode(dockspace_id, ImGuiDir_Down, 0.20f, &dock_id_down, &dock_id_top);
            ImGui::DockBuilderDockWindow("Call Stack", dock_id_down);
            ImGui::DockBuilderDockWindow("Breakpoints", dock_id_down);
            ImGui::DockBuilderDockWindow("Exception", dock_id_down);

            {
                ImGuiID dock_id_left = 0, dock_id_right = 0;
                ImGui::DockBuilderSplitNode(dock_id_top, ImGuiDir_Left, 0.20f, &dock_id_left, &dock_id_right);
                
                ImGui::DockBuilderDockWindow("Sections", dock_id_left);
                ImGui::DockBuilderDockWindow("Source", dock_id_right);
            }

            {
                ImGuiID dock_id_left = 0, dock_id_right = 0;
                ImGui::DockBuilderSplitNode(dock_id_down, ImGuiDir_Right, 0.5f, &dock_id_right, &dock_id_left);
                ImGui::DockBuilderDockWindow("Parameters", dock_id_right);
                ImGui::DockBuilderDockWindow("Locals", dock_id_right);
                ImGui::DockBuilderDockWindow("Temporaries", dock_id_right);
                ImGui::DockBuilderDockWindow("Globals", dock_id_right);
                ImGui::DockBuilderDockWindow("Watch", dock_id_right);
            }
        }

        ImGui::DockBuilderFinish(dockspace_id);

        setupDock = false;
    }
    
    ImGuiWindowFlags windowFlags = ImGuiWindowFlags_NoBringToFrontOnFocus |
        ImGuiWindowFlags_NoNavFocus |
        ImGuiWindowFlags_NoDocking |
        ImGuiWindowFlags_NoTitleBar |
        ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_MenuBar |
        ImGuiWindowFlags_NoBackground;     
    bool show = ImGui::Begin("DockSpace", NULL, windowFlags);
    asIDBAction new_action = asIDBAction::None;

    if (show)
    {
        this->debugger->mutex.lock();

        auto *cache = this->debugger->cache.get();

        asIScriptContext *ctx = cache ? cache->ctx : nullptr;
        bool isException = ctx ? (ctx->GetState() == asEXECUTION_EXCEPTION) : false;

        if (!full || isException)
            ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);

        if (ImGui::BeginMainMenuBar())
        {
            if (ImGui::MenuItem("Continue"))
                new_action = asIDBAction::Continue;
            else if (ImGui::MenuItem("Step Into"))
                new_action = asIDBAction::StepInto;
            else if (ImGui::MenuItem("Step Over"))
                new_action = asIDBAction::StepOver;
            else if (ImGui::MenuItem("Step Out"))
                new_action = asIDBAction::StepOut;
            else if (ImGui::MenuItem("Toggle Breakpoint"))
            {
                int line, col;
                editor.GetMainCursor(line, col);
                debugger->ToggleBreakpoint(selected_stack_section, line + 1);
            }
            ImGui::EndMainMenuBar();
        }

        if (full && isException)
            ImGui::PopItemFlag();

        if (ImGui::Begin("Call Stack", nullptr, ImGuiWindowFlags_HorizontalScrollbar))
        {
            if (cache)
            {
                int n = 0;
                for (auto &stack : cache->call_stack)
                {
                    bool sel = selected_stack_entry == n;
                    if (ImGui::Selectable(stack.declaration.c_str(), &sel, stack.scope.offset == SCOPE_SYSTEM ? ImGuiSelectableFlags_Disabled : 0))
                    {
                        selected_stack_entry = n;
                        resetText = true;
                    }

                    n++;
                }
            }
        }
        ImGui::End();

        if (!full)
            ImGui::PopItemFlag();

        if (ImGui::Begin("Breakpoints", nullptr, ImGuiWindowFlags_HorizontalScrollbar))
        {
            if (ImGui::BeginTable("##bp", 2,
                ImGuiTableFlags_BordersV | ImGuiTableFlags_BordersOuterH |
                ImGuiTableFlags_Resizable | ImGuiTableFlags_RowBg |
                ImGuiTableFlags_NoBordersInBody))
            {
                ImGui::TableSetupColumn("Breakpoint", ImGuiTableColumnFlags_WidthStretch);
                ImGui::TableSetupColumn("Delete", ImGuiTableColumnFlags_WidthFixed);
                ImGui::TableHeadersRow();

                int n = 0;

                std::string_view remove_breakpoint_name;
                int remove_breakpoint_line;

                for (auto &sbp : debugger->breakpoints)
                {
                    for (auto &l : sbp.second)
                    {
                        ImGui::PushID(n++);
                        ImGui::TableNextRow();
                        ImGui::TableNextColumn();
                        ImGui::Text(fmt::format("{} : {}", sbp.first, l.line).c_str());
                        ImGui::TableNextColumn();
                        if (ImGui::Button("X"))
                        {
                            remove_breakpoint_name = sbp.first;
                            remove_breakpoint_line = l.line;
                        }
                        ImGui::PopID();
                    }
                }

                if (!remove_breakpoint_name.empty())
                    debugger->ToggleBreakpoint(remove_breakpoint_name, remove_breakpoint_line);

                ImGui::EndTable();
            }
        }
        ImGui::End();

        if (isException)
        {
            if (ImGui::Begin("Exception", nullptr, ImGuiWindowFlags_HorizontalScrollbar))
            {
                ImGui::TextWrapped("%s", ctx->GetExceptionString());
            }
            ImGui::End();
        }

        if (!full)
            ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);

        asIDBCallStackEntry *stack = cache ? &cache->call_stack[selected_stack_entry] : nullptr;

        if (ImGui::Begin("Parameters"))
        {
            ImGui::PushItemWidth(-1);

            static char filterBuf[256] {};
            ImGui::InputText("##Filter", filterBuf, sizeof(filterBuf));
            if (cache)
                RenderLocals(filterBuf, stack->scope, stack->scope.parameters);
            ImGui::PopItemWidth();
        }
        ImGui::End();
        
        if (ImGui::Begin("Locals"))
        {
            ImGui::PushItemWidth(-1);

            static char filterBuf[256] {};
            ImGui::InputText("##Filter", filterBuf, sizeof(filterBuf));
            if (cache)
                RenderLocals(filterBuf, stack->scope, stack->scope.locals);
            ImGui::PopItemWidth();
        }
        ImGui::End();
        
        if (ImGui::Begin("Temporaries"))
        {
            ImGui::PushItemWidth(-1);

            static char filterBuf[256] {};
            ImGui::InputText("##Filter", filterBuf, sizeof(filterBuf));
            if (cache)
                RenderLocals(filterBuf, stack->scope, stack->scope.registers);
            ImGui::PopItemWidth();
        }
        ImGui::End();
        
        if (ImGui::Begin("Globals"))
        {
            static char filterBuf[256] {};
            static bool showConstants = false, showNamespaced = false;
            
            ImGui::PushItemWidth(ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize("Filter").x);
            ImGui::InputText("Filter", filterBuf, sizeof(filterBuf));
            ImGui::PopItemWidth();
            
            ImGui::Checkbox("Show Constants", &showConstants);
            ImGui::SameLine();
            ImGui::Checkbox("Show Namespaced", &showNamespaced);
            
            ImGui::PushItemWidth(-1);
            if (cache)
                RenderGlobals(filterBuf, showConstants, showNamespaced);
            ImGui::PopItemWidth();

        }
        ImGui::End();
        
        if (ImGui::Begin("Watch"))
        {
            ImGui::PushItemWidth(-1);
            if (cache)
                RenderWatch();
            ImGui::PopItemWidth();
        }
        ImGui::End();

        if (!full)
            ImGui::PopItemFlag();

        std::string_view change_section;

        if (ImGui::Begin("Sections", nullptr, ImGuiWindowFlags_HorizontalScrollbar))
        {
            for (auto &section : debugger->workspace.sections)
            {
                if (ImGui::Selectable(section.c_str(), selected_stack_section == section))
                    change_section = section;
            }
        }
        ImGui::End();
        
        if (ImGui::Begin("Source"))
            editor.Render("Source", ImVec2(-1, -1));
        ImGui::End();

        if (isException)
        {
            if (showExceptionWindow)
            {
                showExceptionWindow = false;
                ImGui::OpenPopup("Exception Thrown");
                ImGui::SetNextWindowPos(viewport->GetCenter(), ImGuiCond_Appearing, ImVec2(0.5f, 0.5f));
                ImGui::SetNextWindowSize(ImVec2(300, -1));
            }

            if (ImGui::BeginPopupModal("Exception Thrown"))
            {
                ImGui::TextWrapped("An exception was thrown:");
                ImGui::BulletText(ctx->GetExceptionString());
                ImGui::TextWrapped("Note that the debugger is in a state that does not allow re-execution - some features are unavailable.");

                if (ImGui::Button("OK", ImVec2(70, 20)))
                {
                    editor.ScrollToLine(update_row - 1, TextEditor::Scroll::alignMiddle);
                    ImGui::CloseCurrentPopup();
                }

                ImGui::EndPopup();
            }
        }

        if (cache && openVariablePopup != asIDBPopupState::Closed)
        {
            if (openVariablePopup == asIDBPopupState::Opening)
            {
                ImGui::OpenPopup("var_rightclick");
                openVariablePopup = asIDBPopupState::Open;
            }
        
            if (ImGui::BeginPopup("var_rightclick"))
            {
                enum class asIDBVarPopupAction
                {
                    None,
                    CopyPath,
                    CopyValue,
                    AddToWatch,
                    Paste,
                    Delete,
                    ClearAll
                };

                asIDBVarPopupAction action = asIDBVarPopupAction::None;

                // all items
                bool disabled = false;
                if (disabled = rightClickedVariableStack.empty())
                    ImGui::BeginDisabled(true);
                if (ImGui::Selectable("Copy Path"))
                    action = asIDBVarPopupAction::CopyPath;
                if (disabled)
                    ImGui::EndDisabled();
                // disabled if not value-copyable
                ImGui::Separator();
                if (disabled = (rightClickedVariableStack.empty() ||
                    !rightClickedVariableStack.front()->IsValid() ||
                    rightClickedVariableStack.front()->GetState().value.value.empty()))
                    ImGui::BeginDisabled(true);
                if (ImGui::Selectable("Copy Value"))
                    action = asIDBVarPopupAction::CopyValue;
                if (disabled)
                    ImGui::EndDisabled();
                if (ImGui::Selectable("Add To Watch"))
                    action = asIDBVarPopupAction::AddToWatch;
                // watch only
                if (variablePopupWindow == asIDBVarPopupWindow::Watch)
                {
                    ImGui::Separator();
                    if (disabled = rightClickedVariableStack.empty())
                        ImGui::BeginDisabled(true);
                    if (ImGui::Selectable("Delete"))
                        action = asIDBVarPopupAction::Delete;
                    if (disabled)
                        ImGui::EndDisabled();
                    if (ImGui::Selectable("Clear All"))
                        action = asIDBVarPopupAction::ClearAll;
                    ImGui::Separator();
                    if (ImGui::Selectable("Paste"))
                        action = asIDBVarPopupAction::Paste;
                }

                if (action != asIDBVarPopupAction::None)
                {
                    switch (action)
                    {
                    case asIDBVarPopupAction::CopyValue: {
                        std::string s = rightClickedVariableStack.front()->GetState().value.value.c_str();

                        for (auto &entry : rightClickedVariableStack.front()->GetState().entries)
                            s += "\n" + entry.value;

                        ImGui::SetClipboardText(s.c_str());
                        break; }
                    case asIDBVarPopupAction::AddToWatch:
                    case asIDBVarPopupAction::CopyPath: {
                            std::string path;

                            for (auto it = rightClickedVariableStack.rbegin(); it != rightClickedVariableStack.rend(); ++it)
                            {
                                auto &entry = *it;

                                if (!path.empty() && entry->name[0] != '[')
                                    path += '.';

                                if (path.empty())
                                    path += entry->name.substr(0, entry->name.find_first_of(' '));
                                else
                                    path += entry->name;
                            }

                            if (action == asIDBVarPopupAction::CopyPath)
                                ImGui::SetClipboardText(path.c_str());
                            else
                                watch.emplace_back(path.c_str());
                        break; }
                    case asIDBVarPopupAction::Paste:
                        watch.emplace_back(ImGui::GetClipboardText());
                        break;
                    case asIDBVarPopupAction::Delete: {
                        for (auto it = watch.begin(); it != watch.end(); it++)
                        {
                            if (&(*it) == rightClickedVariableStack.back())
                            {
                                watch.erase(it);
                                break;
                            }
                        }
                        break;
                    }
                    case asIDBVarPopupAction::ClearAll:
                        watch.clear();
                        break;
                    default:
                        break;
                    }

                    ImGui::CloseCurrentPopup();
                }

                ImGui::EndPopup();
            }
            else
            {
                rightClickedVariableStack.clear();
                openVariablePopup = asIDBPopupState::Closed;
            }
        }

        if (!change_section.empty())
        {
            if (selected_stack_section != change_section)
            {
                selected_stack_section = change_section;

                auto file = debugger->FetchSource(selected_stack_section.data());
                editor.SetText(file);

                resetOpenStates = true;
            }
        }

        this->debugger->mutex.unlock();
    }
    
    ImGui::End();

    // Rendering
    ImGui::EndFrame();

    BackendRender();

    if (resetText)
        ChangeScript();
    
    auto mods = ImGui::GetIO().KeyMods;
    if (full)
    {
        if (ImGui::IsKeyPressed(ImGuiKey::ImGuiKey_F5, false))
            new_action = asIDBAction::Continue;
        else if (ImGui::IsKeyPressed(ImGuiKey::ImGuiKey_F10))
            new_action = asIDBAction::StepOver;
        else if (ImGui::IsKeyPressed(ImGuiKey::ImGuiKey_F11) && (mods & ImGuiKey::ImGuiMod_Shift) == 0)
            new_action = asIDBAction::StepInto;
        else if (ImGui::IsKeyPressed(ImGuiKey::ImGuiKey_F11) && (mods & ImGuiKey::ImGuiMod_Shift) == ImGuiKey::ImGuiMod_Shift)
            new_action = asIDBAction::StepOut;

        wasVisible = true;
    }

    if (ImGui::IsKeyPressed(ImGuiKey::ImGuiKey_F9, false))
    {
        int line, col;
        editor.GetMainCursor(line, col);
        debugger->ToggleBreakpoint(selected_stack_section, line + 1);
    }

    if (new_action != asIDBAction::None)
        debugger->SetAction(new_action);

    return true;
}

void asIDBImGuiFrontend::RenderVariableTable(const char *label, std::function<void()> render_variables)
{
    if (ImGui::BeginTable(label, 3,
        ImGuiTableFlags_BordersV | ImGuiTableFlags_BordersOuterH |
        ImGuiTableFlags_Resizable | ImGuiTableFlags_RowBg |
        ImGuiTableFlags_NoBordersInBody))
    {
        ImGui::TableSetupColumn("Name", ImGuiTableColumnFlags_WidthStretch);
        ImGui::TableSetupColumn("Value", ImGuiTableColumnFlags_WidthStretch);
        ImGui::TableSetupColumn("Type", ImGuiTableColumnFlags_WidthStretch);
        ImGui::TableHeadersRow();

        render_variables();

        ImGui::EndTable();
    }
}

void asIDBImGuiFrontend::RenderLocals(const char *filter, asIDBScope &scope, asIDBLocalScopeVariables &variables)
{
    asIDBCache *cache = debugger->cache.get();

    cache->CacheLocals(scope, variables);

    auto &f = variables.variables;

    RenderVariableTable("##Locals", [&]() {
        for (int n = 0; n < f.size(); n++)
        {
            ImGui::PushID(n);
            auto &local = f[n];
            RenderDebuggerVariable(local.var, filter);
            ImGui::PopID();
        }
    });

    if (openVariablePopup == asIDBPopupState::Closed && ImGui::IsWindowHovered() && ImGui::IsMouseReleased(ImGuiMouseButton_Right))
        openVariablePopup = asIDBPopupState::Opening;

    if (openVariablePopup == asIDBPopupState::Opening)
        variablePopupWindow = asIDBVarPopupWindow::Variables;
}

void asIDBImGuiFrontend::RenderGlobals(const char *filter, bool showConstants, bool showNamespaced)
{
    asIDBCache *cache = debugger->cache.get();

    cache->CacheGlobals();

    auto &f = cache->global.variables;
    
    RenderVariableTable("##Globals", [&]() {
        for (int n = 0; n < f.size(); n++)
        {
            auto &global = f[n];

            if (!showConstants && global.var.id.constant)
                continue;
            else if (!showNamespaced && global.var.name.find_first_of(':') != std::string_view::npos)
                continue;

            ImGui::PushID(n);
            RenderDebuggerVariable(global.var, filter);
            ImGui::PopID();
        }
    });

    if (openVariablePopup == asIDBPopupState::Closed && ImGui::IsWindowHovered() && ImGui::IsMouseReleased(ImGuiMouseButton_Right))
        openVariablePopup = asIDBPopupState::Opening;

    if (openVariablePopup == asIDBPopupState::Opening)
        variablePopupWindow = asIDBVarPopupWindow::Variables;
}

void asIDBImGuiFrontend::RenderWatch()
{
    asIDBCache *cache = debugger->cache.get();
    auto &f = watch;

    RenderVariableTable("##Watch", [&]() {
        for (int n = 0; n < f.size(); n++)
        {
            ImGui::PushID(n);
            auto &val = f[n];

            if (val.dirty)
            {
                val.result = cache->ResolveExpression(val.name, selected_stack_entry);

                // TODO: modifier passed through resolve expression?
                if (val.result)
                    val.type = cache->GetTypeNameFromType({ val.result.value().idKey.typeId });
                else
                    val.type = val.result.error();

                val.dirty = false;
            }

            RenderDebuggerVariable(val, nullptr);

            ImGui::PopID();
        }
    });

    static char buf[128];
    ImGui::InputTextWithHint("##AddToWatch", "Expression...", buf, sizeof(buf));

    if (ImGui::IsItemDeactivatedAfterEdit())
    {
        watch.emplace_back(buf);
        buf[0] = '\0';
    }

    if (openVariablePopup == asIDBPopupState::Closed && ImGui::IsWindowHovered() && ImGui::IsMouseReleased(ImGuiMouseButton_Right))
        openVariablePopup = asIDBPopupState::Opening;

    if (openVariablePopup == asIDBPopupState::Opening)
        variablePopupWindow = asIDBVarPopupWindow::Watch;
}

bool asIDBImGuiFrontend::RenderDebuggerVariable(asIDBVarViewBase &varView, const char *filter)
{
    asIDBCache *cache = debugger->cache.get();

    int opened = ImGui::GetStateStorage()->GetInt(ImGui::GetID(varView.name.data(), varView.name.data() + varView.name.size()), 0);
                    
    if (!opened && filter && *filter && varView.name.find(filter) == std::string::npos)
        return false;
        
    ImGui::PushID(varView.name.data(), varView.name.data() + varView.name.size());

    ImGui::TableNextRow();
    ImGui::TableNextColumn();
    int startY = ImGui::GetCursorScreenPos().y;
    bool open = ImGui::TreeNodeEx(varView.name.data(),
        ImGuiTreeNodeFlags_OpenOnArrow | ImGuiTreeNodeFlags_SpanAllColumns |
        ((!varView.IsValid() || varView.GetState().value.expandable == asIDBExpandType::None) ? ImGuiTreeNodeFlags_Leaf : ImGuiTreeNodeFlags_None));
    bool add_to_stack = false;

    ImGui::TableNextColumn();
    
    if (!varView.IsValid())
    {
        ImGui::TextDisabled(varView.type.empty() ? std::string_view("invalid expression").data() : varView.type.data());
        ImGui::TableNextColumn();
    }
    else
    {
        auto varId = varView.GetID();
        auto &var = varView.GetState();

        if (open)
        {
            if ((var.value.expandable == asIDBExpandType::Children ||
                 var.value.expandable == asIDBExpandType::Entries) && !var.queriedChildren)
            {
                cache->evaluators.Expand(*cache, varId, var);
                var.queriedChildren = true;
            }
        }

        if (!var.value.value.empty())
        {
            if (var.value.disabled)
                ImGui::BeginDisabled(true);
            auto s = var.value.value.substr(0, 32);
            ImGui::TextUnformatted(s.data(), s.data() + s.size());
            if (var.value.disabled)
                ImGui::EndDisabled();
        }
        ImGui::TableNextColumn();
        ImGui::TextUnformatted(varView.type.data(), varView.type.data() + varView.type.size());

        if (open)
        {
            if (var.value.expandable == asIDBExpandType::Children)
            {
                int i = 0;

                for (auto &child : var.children)
                {
                    ImGui::PushID(i);
                    if (RenderDebuggerVariable(child, filter))
                        add_to_stack = true;
                    ImGui::PopID();

                    i++;
                }
            }
            else if (var.value.expandable == asIDBExpandType::Value ||
                     var.value.expandable == asIDBExpandType::Entries)
            {
                // FIXME: how to make this span the entire column?
                // any samples I could find don't deal with long text.
                // I guess we could have a separate "value viewer" tab that
                // can be used if you click a button on an entry or something.
                // Sort of like Watch but specifically for values.

                ImGui::TableNextRow();
                ImGui::TableNextColumn();
                ImGui::PushTextWrapPos(0.0f);

                if (var.value.expandable == asIDBExpandType::Value)
                {
                    const std::string_view s = var.value.value;
                    ImGui::TextUnformatted(s.data(), s.data() + s.size());
                }
                else
                {
                    for (auto &entry : var.entries)
                    {
                        ImGui::Bullet();
                        ImGui::SameLine();
                        ImGui::TextUnformatted(entry.value.data(), entry.value.data() + entry.value.size());
                    }
                }

                ImGui::PopTextWrapPos();
            }
        }
    }

    int endY = ImGui::GetCursorScreenPos().y;

    if (ImGui::IsWindowHovered() &&
        ImGui::GetIO().MousePos.y >= startY && ImGui::GetIO().MousePos.y < endY &&
        ImGui::IsMouseReleased(ImGuiMouseButton_Right))
    {
        if (openVariablePopup == asIDBPopupState::Closed)
        {
            openVariablePopup = asIDBPopupState::Opening;
            add_to_stack = true;
        }
    }

    if (open)
         ImGui::TreePop();

    ImGui::PopID();

    if (add_to_stack)
        rightClickedVariableStack.push_back(&varView);

    return add_to_stack;
}

#endif