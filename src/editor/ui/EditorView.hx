package editor.ui;

import haxe.Json;
import haxe.DynamicAccess;

using editor.components.Tooltip;

class EditorView extends View implements Observable {

/// Properties

    @observe public var panelTabsView:PanelTabsView;

    var editorMenu:RowLayout;

    var bottomBar:RowLayout;

    var popup:PopupView = null;

    var statusText:TextView;

    var leftSpacerView:View;

    var leftSpacerBorder:View;

    var editorsSeparator:View;

    public var fragmentEditorView(default, null):FragmentEditorView;

    public var scriptEditorView(default, null):ScriptEditorView;

    public var timelineEditorView(default, null):TimelineEditorView;

    //var scriptEditorView:ScriptEditorView;

/// Lifecycle

    public function new() {

        super();

        app.onceImmediate(() -> init());

    }

    function init() {

        bottomBar = new RowLayout();
        bottomBar.padding(0, 6);
        bottomBar.depth = 3;
        add(bottomBar);

        leftSpacerView = new View();
        leftSpacerView.depth = 4;
        add(leftSpacerView);

        leftSpacerBorder = new View();
        leftSpacerBorder.depth = 4;
        add(leftSpacerBorder);

        // Panels tabs
        panelTabsView = new PanelTabsView();
        panelTabsView.depth = 5;
        add(panelTabsView);

        // Left side menu
        editorMenu = new RowLayout();
        editorMenu.depth = 6;
        editorMenu.padding(0, 6, 0, 12);
        {
            var w = 38;
            var s = 20;

            var settingsButton = new ClickableIconView();
            settingsButton.icon = COG;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('Settings');
            settingsButton.onClick(this, () -> {
                model.location = SETTINGS;
            });
            editorMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = FLOPPY;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.autorun(() -> {
                if (model.projectPath == null) {
                    settingsButton.tooltip('Save As...');
                }
                else {
                    settingsButton.tooltip('Save');
                }
            });
            settingsButton.onClick(this, () -> {
                model.saveProject();
            });
            settingsButton.onLongPress(this, () -> {
                model.saveProject(true);
            });
            editorMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = FOLDER;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s - 2;
            settingsButton.tooltip('Open project...');
            settingsButton.onClick(this, () -> {
                model.openProject();
            });
            editorMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = WINDOW;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('New project');
            settingsButton.onClick(this, () -> {
                model.newProject();
            });
            editorMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = DOWNLOAD;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s - 2;
            settingsButton.tooltip('Export');
            settingsButton.onClick(this, () -> {
                model.exportFragments();
            });
            editorMenu.add(settingsButton);

            var filler = new RowSeparator();
            filler.viewSize(16, fill());
            editorMenu.add(filler);

            var settingsButton = new ClickableIconView();
            settingsButton.icon = REPLY;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('Undo');
            settingsButton.onClick(this, () -> {
                model.history.undo();
            });
            editorMenu.add(settingsButton);

            var settingsButton = new ClickableIconView();
            settingsButton.icon = FORWARD;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('Redo');
            settingsButton.onClick(this, () -> {
                model.history.redo();
            });
            editorMenu.add(settingsButton);

            var filler = new RowSeparator();
            filler.viewSize(16, fill());
            editorMenu.add(filler);

            var settingsButton = new ClickableIconView();
            settingsButton.icon = TO_START;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('Reset');
            var playButton = settingsButton;
            playButton.autorun(() -> {
                playButton.disabled = (model.project.lastSelectedFragment == null);
            });
            settingsButton.onClick(this, () -> {
                fragmentEditorView.resetFragment();
            });
            editorMenu.add(settingsButton);

            var settingsButton = new ClickableIconView();
            settingsButton.icon = PLAY;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('Play');
            var playButton = settingsButton;
            playButton.autorun(() -> {
                playButton.disabled = (model.project.lastSelectedFragment == null);
            });
            settingsButton.onClick(this, () -> {
                model.play();
            });
            editorMenu.add(settingsButton);

            var filler = new RowSeparator();
            filler.viewSize(16, fill());
            editorMenu.add(filler);
        }
        add(editorMenu);

        statusText = new TextView();
        statusText.preRenderedSize = 20;
        statusText.pointSize = 11;
        statusText.align = LEFT;
        statusText.verticalAlign = CENTER;
        statusText.viewSize(auto(), fill());
        statusText.depth = 7;
        statusText.autorun(() -> {
            var message = model.statusMessage;
            var color = model.statusColor;
            unobserve();
            statusText.content = message != null ? message : '';
            statusText.textColor = color;
        });
        bottomBar.add(statusText);

        // Fragment editor view
        fragmentEditorView = new FragmentEditorView(this);
        fragmentEditorView.depth = 2;
        autorun(() -> {
            fragmentEditorView.selectedFragment = model.project.lastSelectedFragment;
        });
        add(fragmentEditorView);

        // Script editor view
        scriptEditorView = new ScriptEditorView();
        scriptEditorView.depth = 9;
        autorun(() -> {
            scriptEditorView.selectedScript = model.project.selectedScript;
        });
        add(scriptEditorView);

        // Timeline editor view
        timelineEditorView = new TimelineEditorView(this);
        timelineEditorView.depth = 10;
        autorun(() -> {
            timelineEditorView.selectedFragment = model.project.lastSelectedFragment;
        });
        add(timelineEditorView);

        editorsSeparator = new View();
        editorsSeparator.active = false;
        editorsSeparator.depth = 11;
        add(editorsSeparator);

        // Popup
        popup = new PopupView();
        popup.depth = 12;
        add(popup);

        /*
        scriptEditorView = new ScriptEditorView();
        scriptEditorView.depth = 10;
        add(scriptEditorView);
        */

        autorun(updateTabs);
        autorun(updateTabsContentView);
        autorun(updatePopupContentView);

        // Styles
        autorun(updateStyle);

        // Keyboard shortcuts
        bindKeyBindings();

        // Touchable state
        autorun(updateTouchable);

        bindAutoFps();

        computeInitialSelectedTab();

    }

    @observe var isScreenPointerDown:Bool = false;

    function bindAutoFps() {

        // TODO multitouch?

        screen.onPointerDown(this, _ -> {
            isScreenPointerDown = true;
        });

        screen.onPointerUp(this, _ -> {
            isScreenPointerDown = false;
        });

        autorun(() -> {
            var highFps = isScreenPointerDown || model.animationState.animating || model.requireHighFps > 0;
            unobserve();
            if (highFps) {
                #if luxe
                Luxe.core.update_rate = 1.0 / 30;
                #end
            }
            else {
                #if luxe
                Luxe.core.update_rate = 1.0 / 10;
                #end
            }
        });

    }

    override function layout() {
        
        var editorMenuHeight = 40;
        var panelsTabsWidth = 320;
        var bottomBarHeight = 18;
        var leftSpacerSize = 6;
        var timelineHeight = Math.max(height * 0.2, 220);
        var availableViewportWidth = width - panelsTabsWidth - leftSpacerSize - 2;
        var availableViewportHeight = height - bottomBarHeight - editorMenuHeight - timelineHeight;

        leftSpacerView.size(leftSpacerSize, height);
        leftSpacerView.pos(0, 0);

        leftSpacerBorder.size(1, availableViewportHeight + timelineHeight);
        leftSpacerBorder.pos(leftSpacerSize, editorMenuHeight);

        panelTabsView.viewSize(panelsTabsWidth, height - editorMenuHeight);
        panelTabsView.computeSize(panelsTabsWidth, height - editorMenuHeight, ViewLayoutMask.FIXED, true);
        panelTabsView.applyComputedSize();
        panelTabsView.pos(width - panelTabsView.width, editorMenuHeight);

        editorMenu.viewSize(width, editorMenuHeight);
        editorMenu.computeSize(width, editorMenuHeight, ViewLayoutMask.FIXED, true);
        editorMenu.applyComputedSize();
        editorMenu.pos(0, 0);

        var shouldDisplayScriptEditor = scriptEditorView.selectedScript != null;
        var shouldDisplayFragmentEditor = fragmentEditorView.selectedFragment != null;
        if (shouldDisplayScriptEditor && shouldDisplayFragmentEditor) {

            var scriptEditorWidth = Math.min(650, availableViewportWidth * 0.5) - 1;

            scriptEditorView.active = true;
            scriptEditorView.size(scriptEditorWidth, availableViewportHeight);
            scriptEditorView.pos(1 + leftSpacerSize, editorMenuHeight);

            editorsSeparator.active = true;
            editorsSeparator.pos(scriptEditorView.x + scriptEditorWidth, editorMenuHeight);
            editorsSeparator.size(1, availableViewportHeight);

            fragmentEditorView.active = true;
            fragmentEditorView.size(availableViewportWidth - scriptEditorWidth - 1, availableViewportHeight);
            fragmentEditorView.pos(1 + scriptEditorView.x + scriptEditorWidth, editorMenuHeight);
        }
        else if (shouldDisplayScriptEditor) {

            editorsSeparator.active = false;

            scriptEditorView.active = true;
            scriptEditorView.size(availableViewportWidth, availableViewportHeight);
            scriptEditorView.pos(1 + leftSpacerSize, editorMenuHeight);

            fragmentEditorView.active = false;
        }
        else if (shouldDisplayFragmentEditor) {

            editorsSeparator.active = false;

            scriptEditorView.active = false;

            fragmentEditorView.active = true;
            fragmentEditorView.size(availableViewportWidth, availableViewportHeight);
            fragmentEditorView.pos(1 + leftSpacerSize, editorMenuHeight);
        }
        else {
            editorsSeparator.active = false;
            scriptEditorView.active = false;
            fragmentEditorView.active = false;
        }

        timelineEditorView.size(availableViewportWidth, timelineHeight);
        timelineEditorView.pos(1 + leftSpacerSize, editorMenuHeight + availableViewportHeight);

        popup.anchor(0.5, 0.5);
        popup.pos(width * 0.5, height * 0.5);
        popup.size(width, height);

        bottomBar.viewSize(availableViewportWidth + leftSpacerSize + 2, bottomBarHeight);
        bottomBar.computeSize(availableViewportWidth + leftSpacerSize + 2, bottomBarHeight, ViewLayoutMask.FIXED, true);
        bottomBar.applyComputedSize();
        bottomBar.pos(0, height - bottomBarHeight);

        /*
        scriptEditorView.pos(
            fragmentOverlay.x,
            fragmentOverlay.y
        );
        scriptEditorView.size(
            fragmentOverlay.width,
            fragmentOverlay.height
        );
        */

    }

/// Internal

    function updateTabs() {

        var selectedFragment = model.project.lastSelectedFragment;
        unobserve();

        // Keep selected tab name
        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        if (selectedFragment == null) {
            panelTabsView.tabViews.tabs = ['Containers', 'Scripts'];
        }
        else {
            panelTabsView.tabViews.tabs = ['Entities', 'Visuals', 'Containers', 'Scripts'];
        }

        // Restore selected tab name on new tab list
        var selectedIndex = panelTabsView.tabViews.tabs.indexOf(selectedName);
        panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;

    }

    function computeInitialSelectedTab() {

        var selectedFragment = model.project.lastSelectedFragment;
        if (selectedFragment != null) {
            var selectedItem = selectedFragment.selectedItem;
            if (selectedItem != null) {
                if (Std.is(selectedItem, EditorVisualData)) {
                    var selectedIndex = panelTabsView.tabViews.tabs.indexOf('Visuals');
                    panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;
                }
                else {
                    var selectedIndex = panelTabsView.tabViews.tabs.indexOf('Entities');
                    panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;
                }
            }
        }

    }

    function updatePopupContentView() {

        var pendingChoice = model.pendingChoice;
        var pendingPrompt = model.pendingPrompt;
        var location = model.location;

        unobserve();

        popup.reset();

        if (pendingChoice != null) {
            popup.title = pendingChoice.title;
            popup.contentView = new PendingChoiceContentView(pendingChoice);
            popup.cancelable = pendingChoice.cancelable;
            if (pendingChoice.cancelable) {
                popup.onCancel(popup.contentView, () -> {
                    model.pendingChoice = null;
                });
            }
        }
        else if (pendingPrompt != null) {
            popup.title = pendingPrompt.title;
            popup.contentView = new PendingPromptContentView(pendingPrompt);
            popup.cancelable = pendingPrompt.cancelable;
            if (pendingPrompt.cancelable) {
                popup.onCancel(popup.contentView, () -> {
                    model.pendingPrompt = null;
                });
            }
        }
        else if (location == SETTINGS) {
            popup.title = 'Project Settings';
            popup.contentView = new ProjectSettingsView();
            popup.cancelable = true;
            popup.onCancel(popup.contentView, () -> {
                model.location = DEFAULT;
            });
        }

        if (popup.contentView != null) {
            scriptEditorView.hideMonacoEditor = true;
        }
        else {
            scriptEditorView.hideMonacoEditor = false;
        }

        reobserve();

    }

    function updateTabsContentView() {

        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        unobserve();

        var contentViewClass:Class<View> = switch (selectedName) {
            case 'Entities': EntitiesPanelView;
            case 'Visuals': VisualsPanelView;
            case 'Containers': EditableElementsPanelView;
            case 'Scripts': ScriptsPanelView;
            default: null;
        }
        var prevContentViewClass = null;
        if (panelTabsView.contentView != null) {
            prevContentViewClass = Type.getClass(panelTabsView.contentView);
        }

        // Update content view if needed
        if (contentViewClass != prevContentViewClass) {
            if (panelTabsView.contentView != null) {
                panelTabsView.contentView.destroy();
                panelTabsView.contentView = null;
            }
            if (contentViewClass != null) {
                panelTabsView.contentView = Type.createInstance(contentViewClass, []);
            }
        }

    }

    function bindKeyBindings() {

        app.onKeyDown(this, handleKeyDown);

        var keyBindings = new KeyBindings();

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_C)], () -> {
            var selectedItem = getSelectedItemIfFocusedInFragment();
            if (selectedItem != null) {
                log.debug('COPY selected item');
                app.backend.clipboard.setText('{"ceramic-editor":{"entity":' + Json.stringify(selectedItem.toJson()) + '}}');
            }
            else {
                var selectedKeyframes = getSelectedKeyframesIfFocusedInTimeline();
                if (selectedKeyframes != null) {
                    log.debug('COPY keyframes');
                    var keyframesData:DynamicAccess<Dynamic> = {};
                    for (key => val in selectedKeyframes) {
                        trace(' - $key');
                        keyframesData.set(key, val.toJson());
                    }
                    app.backend.clipboard.setText('{"ceramic-editor":{"keyframes":' + Json.stringify(keyframesData) + '}}');
                }
            }
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.ENTER)], () -> {
            log.debug('PLAY');
            model.play();
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_V)], () -> {
            var clipboardText = app.backend.clipboard.getText();
            log.debug('PASTE $clipboardText');
            if (clipboardText != null && clipboardText.startsWith('{"ceramic-editor":')) {
                try {
                    var parsed:Dynamic = Reflect.field(Json.parse(clipboardText), 'ceramic-editor');
                    if (FieldManager.manager.focusedField == null && popup.contentView == null) {
                        if (parsed.entity != null) {
                            // Paste entity
                            var fragment = model.project.lastSelectedFragment;
                            if (fragment != null) {

                                // When pasting entity, we need to reset timeline position
                                model.animationState.currentFrame = 0;

                                var item:EditorEntityData;
                                if (parsed.entity.isVisual) {
                                    item = new EditorVisualData();
                                }
                                else {
                                    item = new EditorEntityData();
                                }
                                item.fragmentData = fragment;
                                parsed.entity.props.x = fragment.width * 0.5;
                                parsed.entity.props.y = fragment.height * 0.5;
                                item.fromJson(parsed.entity);
                                fragment.addEntityData(item);
                                fragment.selectedItem = item;

                                model.history.step();
                            }
                            else {
                                log.warning('Failed to paste entity: no selected fragment');
                            }
                        }
                        else if (parsed.keyframes != null) {
                            // Paste keyframes
                            var fragment = model.project.lastSelectedFragment;
                            if (fragment != null) {
                                var selectedItem = fragment.selectedItem;
                                if (selectedItem != null) {
                                    var currentFrame = model.animationState.currentFrame;
                                    var didUpdateKeyframe = false;
                                    for (key in Reflect.fields(parsed.keyframes)) {
                                        var track = selectedItem.timelineTrackForField(key);
                                        if (track != null) {
                                            var keyframeJson = Reflect.field(parsed.keyframes, key);
                                            var keyframe = new EditorTimelineKeyframe();
                                            keyframe.fromJson(keyframeJson);
                                            track.setKeyframe(currentFrame, keyframe);
                                            didUpdateKeyframe = true;
                                        }
                                    }
                                    if (didUpdateKeyframe) {
                                        model.history.step();
                                        app.onceImmediate(() -> {
                                            if (destroyed) return;
                                            model.animationState.invalidateCurrentFrame();
                                        });
                                        app.onceUpdate(this, _ -> {
                                            model.animationState.invalidateCurrentFrame();
                                        });
                                    }
                                }
                            }
                        }
                        else {
                            log.warning('Failed to parse clipboard text: nothing valid to paste');
                        }
                    }
                    else {
                        log.warning('Failed to paste entity: focus not matching');
                    }
                }
                catch (e:Dynamic) {
                    log.error('Failed to parse clipboard text: $e');
                }
            }
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_S)], () -> {
            log.debug('SAVE');
            model.saveProject();
        });

        keyBindings.bind([CMD_OR_CTRL, SHIFT, KEY(KeyCode.KEY_S)], () -> {
            log.debug('SAVE AS');
            model.saveProject(true);
        });

        keyBindings.bind([CMD_OR_CTRL, SHIFT, KEY(KeyCode.KEY_O)], () -> {
            log.debug('OPEN');
            model.openProject();
        });

        keyBindings.bind([CMD_OR_CTRL, SHIFT, KEY(KeyCode.KEY_N)], () -> {
            log.debug('NEW PROJECT');
            model.newProject();
        });

        onDestroy(keyBindings, function(_) {
            keyBindings.destroy();
            keyBindings = null;
        });

    }
    
    function handleKeyDown(key:Key) {

        if (key.scanCode == ScanCode.BACKSPACE) {
            // Delete selected item?
            var selectedItem = getSelectedItemIfFocusedInFragment();
            if (selectedItem != null) {
                var fragment = model.project.lastSelectedFragment;
                fragment.removeItem(selectedItem);
                app.onceUpdate(this, _ -> {
                    selectedItem.destroy();
                    selectedItem = null;
                });
                return;
            }

            // Delete keyframes?
            var fragment = model.project.lastSelectedFragment;
            if (fragment != null) {
                var selectedItem = fragment.selectedItem;
                if (selectedItem != null) {
                    var currentFrame = model.animationState.currentFrame;
                    for (track in selectedItem.timelineTracks) {
                        if (selectedItem.selectedTimelineTracks.indexOf(track) != -1) {
                            track.removeKeyframeAtIndex(currentFrame);
                        }
                    }
                }
            }
        }

    }

    function getSelectedItemIfFocusedInFragment():Null<EditorEntityData> {

        var fragment = model.project.lastSelectedFragment;

        if (fragment != null) {
            var selectedItem = fragment.selectedItem;
            if (selectedItem != null) {
                if (FieldManager.manager.focusedField == null && popup.contentView == null && screen.focusedVisual != null) {
                    if (!screen.focusedVisual.hasIndirectParent(timelineEditorView)) {
                        var selectedTab = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];
                        if (selectedTab == 'Visuals' || (screen.focusedVisual != null && screen.focusedVisual.hasIndirectParent(fragmentEditorView))) {
                            return selectedItem;
                        }
                    }
                }
            }
        }

        return null;

    }

    function getSelectedKeyframesIfFocusedInTimeline():Null<Map<String,EditorTimelineKeyframe>> {

        var fragment = model.project.lastSelectedFragment;

        if (fragment != null) {
            var selectedItem = fragment.selectedItem;
            if (selectedItem != null) {
                if (FieldManager.manager.focusedField == null && popup.contentView == null && screen.focusedVisual != null) {
                    if (screen.focusedVisual.hasIndirectParent(timelineEditorView)) {
                        var result:Map<String,EditorTimelineKeyframe> = null;
                        var currentFrame = model.animationState.currentFrame;
                        for (track in selectedItem.timelineTracks) {
                            var keyframe = track.keyframeAtIndex(currentFrame);
                            if (keyframe != null) {
                                if (result == null) {
                                    result = new Map();
                                }
                                result.set(track.field, keyframe);
                            }
                        }
                        return result;
                    }
                }
            }
        }

        return null;

    }

    function updateStyle() {

        color = theme.windowBackgroundColor;

        leftSpacerView.transparent = false;
        leftSpacerView.color = theme.lightBackgroundColor;

        leftSpacerBorder.transparent = false;
        leftSpacerBorder.color = theme.darkBorderColor;

        editorsSeparator.transparent = false;
        editorsSeparator.color = theme.darkBorderColor;

        editorMenu.transparent = false;
        editorMenu.color = theme.lightBackgroundColor;
        editorMenu.borderBottomSize = 1;
        editorMenu.borderBottomColor = theme.darkBorderColor;
        editorMenu.borderPosition = INSIDE;
        
        bottomBar.transparent = false;
        bottomBar.color = theme.lightBackgroundColor;
        bottomBar.borderTopSize = 1;
        bottomBar.borderTopColor = theme.darkBorderColor;
        bottomBar.borderPosition = INSIDE;

    }

    override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float, touchIndex:Int, buttonId:Int):Bool {

        // Forbid touch outside timeline editor view when animating
        if (model.animationState.animating && !hittingVisual.hasIndirectParent(timelineEditorView)) {
            model.animationState.animating = false;
        }

        return false;

    }

    function updateTouchable() {

        this.touchable = model.loading == 0;

    }

}
