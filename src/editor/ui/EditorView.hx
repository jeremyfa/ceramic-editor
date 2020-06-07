package editor.ui;

import haxe.Json;
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
            settingsButton.icon = DOC;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s;
            settingsButton.tooltip('New project');
            settingsButton.onClick(this, () -> {
                model.newProject();
            });
            editorMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = PUBLISH;
            settingsButton.viewSize(w, fill());
            settingsButton.pointSize = s - 2;
            settingsButton.tooltip('Export');
            settingsButton.onClick(this, () -> {
                model.exportFragments();
            });
            editorMenu.add(settingsButton);
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
        fragmentEditorView.depth = 8;
        autorun(() -> {
            fragmentEditorView.selectedFragment = model.project.lastSelectedFragment;
        });
        add(fragmentEditorView);

        // Monaco editor view
        scriptEditorView = new ScriptEditorView();
        scriptEditorView.depth = 8;
        autorun(() -> {
            scriptEditorView.selectedScript = model.project.lastSelectedScript;
        });
        add(scriptEditorView);

        editorsSeparator = new View();
        editorsSeparator.active = false;
        editorsSeparator.depth = 9;
        add(editorsSeparator);

        // Popup
        popup = new PopupView();
        popup.depth = 10;
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

    }

    override function layout() {
        
        var editorMenuHeight = 40;
        var panelsTabsWidth = 300;
        var bottomBarHeight = 18;
        var leftSpacerSize = 6;
        var availableViewportWidth = width - panelsTabsWidth - leftSpacerSize - 2;
        var availableViewportHeight = height - bottomBarHeight - editorMenuHeight;

        leftSpacerView.size(leftSpacerSize, height);
        leftSpacerView.pos(0, 0);

        leftSpacerBorder.size(1, availableViewportHeight);
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
            panelTabsView.tabViews.tabs = ['Editables'];
        }
        else {
            panelTabsView.tabViews.tabs = ['Visuals', 'Editables'];
        }

        // Restore selected tab name on new tab list
        var selectedIndex = panelTabsView.tabViews.tabs.indexOf(selectedName);
        panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;

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

        reobserve();

    }

    function updateTabsContentView() {

        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        unobserve();

        var contentViewClass:Class<View> = switch (selectedName) {
            case 'Visuals': VisualsPanelView;
            case 'Editables': EditableElementsPanelView;
            //case 'Assets': null;
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
            log.debug('COPY');
            var selectedItem = getSelectedItemIfFocusedInFragment();
            if (selectedItem != null) {
                app.backend.clipboard.setText('{"ceramic-editor":{"entity":' + Json.stringify(selectedItem.toJson()) + '}}');
            }
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_V)], () -> {
            var clipboardText = app.backend.clipboard.getText();
            log.debug('PASTE $clipboardText');
            if (clipboardText != null && clipboardText.startsWith('{"ceramic-editor":')) {
                try {
                    var parsed:Dynamic = Reflect.field(Json.parse(clipboardText), 'ceramic-editor');
                    if (parsed.entity != null) {
                        if (FieldManager.manager.focusedField == null && popup.contentView == null) {
                            var fragment = model.project.selectedFragment;
                            if (fragment != null) {
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
                            }
                        }
                    }
                }
                catch (e:Dynamic) {
                    log.error('PASTE ERROR $e');
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
            var fragment = model.project.lastSelectedFragment;
            if (fragment != null) {
                var selectedItem = getSelectedItemIfFocusedInFragment();
                if (selectedItem != null) {
                    fragment.removeItem(selectedItem);
                    app.onceUpdate(this, _ -> {
                        selectedItem.destroy();
                        selectedItem = null;
                    });
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
                    var selectedTab = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];
                    if (selectedTab == 'Visuals' || (screen.focusedVisual != null && screen.focusedVisual.hasIndirectParent(fragmentEditorView))) {
                        return selectedItem;
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

    function updateTouchable() {

        this.touchable = model.loading == 0;

    }

}
