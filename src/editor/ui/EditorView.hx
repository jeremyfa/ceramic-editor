package editor.ui;

import haxe.Json;
using editor.components.Tooltip;

class EditorView extends View implements Observable {

/// Properties

    @observe public var panelTabsView:PanelTabsView;

    @observe var prevSelectedFragment:EditorFragmentData = null;

    public var fragmentOverlay(default, null):Quad;

    var leftSideMenu:ColumnLayout;

    var topBar:RowLayout;

    var bottomBar:RowLayout;

    var editedFragment:Fragment = null;

    var popup:PopupView = null;

    var statusText:TextView;

/// Lifecycle

    public function new() {

        super();

        app.onceImmediate(() -> init());

    }

    function init() {

        // Fragment
        editedFragment = new Fragment({
            assets: editor.contentAssets,
            editedItems: true
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        editedFragment.onPointerDown(this, (_) -> deselectItems());
        editedFragment.depth = 1;
        add(editedFragment);

        topBar = new RowLayout();
        topBar.padding(0, 6);
        topBar.depth = 2;
        add(topBar);

        bottomBar = new RowLayout();
        bottomBar.padding(0, 6);
        bottomBar.depth = 3;
        add(bottomBar);

        // Panels tabs
        panelTabsView = new PanelTabsView();
        panelTabsView.depth = 4;
        add(panelTabsView);

        // Left side menu
        leftSideMenu = new ColumnLayout();
        leftSideMenu.depth = 5;
        leftSideMenu.padding(6, 0);
        {
            var h = 34;
            var s = 20;

            var settingsButton = new ClickableIconView();
            settingsButton.icon = COG;
            settingsButton.viewSize(fill(), h);
            settingsButton.pointSize = s;
            settingsButton.tooltip('Settings');
            leftSideMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = FLOPPY;
            settingsButton.viewSize(fill(), h);
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
            leftSideMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = FOLDER;
            settingsButton.viewSize(fill(), h);
            settingsButton.pointSize = s - 2;
            settingsButton.tooltip('Open project...');
            settingsButton.onClick(this, () -> {
                model.openProject();
            });
            leftSideMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = DOC;
            settingsButton.viewSize(fill(), h);
            settingsButton.pointSize = s;
            settingsButton.tooltip('New project');
            settingsButton.onClick(this, () -> {
                model.newProject();
            });
            leftSideMenu.add(settingsButton);
            
            var settingsButton = new ClickableIconView();
            settingsButton.icon = PUBLISH;
            settingsButton.viewSize(fill(), h);
            settingsButton.pointSize = s - 2;
            settingsButton.tooltip('Export fragments');
            leftSideMenu.add(settingsButton);
        }
        add(leftSideMenu);

        statusText = new TextView();
        statusText.preRenderedSize = 20;
        statusText.pointSize = 11;
        statusText.align = LEFT;
        statusText.verticalAlign = CENTER;
        statusText.viewSize(auto(), fill());
        statusText.depth = 6;
        statusText.autorun(() -> {
            var message = model.statusMessage;
            unobserve();
            statusText.content = message != null ? message : '';
        });
        bottomBar.add(statusText);

        // Fragment area
        fragmentOverlay = new Quad();
        fragmentOverlay.transparent = true;
        fragmentOverlay.depth = 7;
        editedFragment.clip = fragmentOverlay;
        add(fragmentOverlay);

        // Popup
        popup = new PopupView();
        popup.depth = 8;
        add(popup);

        autorun(updateTabs);
        autorun(updateEditedFragment);
        autorun(updateTabsContentView);
        autorun(updatePopupContentView);
        autorun(updateFragmentItems);

        autorun(() -> updateSelectedEditable(true));

        // Styles
        autorun(updateStyle);

        // Keyboard shortcuts
        bindKeyBindings();

        // Touchable state
        autorun(updateTouchable);

    }

    override function layout() {
        
        var leftSideMenuWidth = 40;
        var panelsTabsWidth = 300;
        var bottomBarHeight = 18;
        var topBarHeight = 25;
        var availableFragmentWidth = width - panelsTabsWidth - leftSideMenuWidth;
        var availableFragmentHeight = height - bottomBarHeight - topBarHeight;

        panelTabsView.viewSize(panelsTabsWidth, height);
        panelTabsView.computeSize(panelsTabsWidth, height, ViewLayoutMask.FIXED, true);
        panelTabsView.applyComputedSize();
        panelTabsView.pos(width - panelTabsView.width, 0);

        leftSideMenu.viewSize(leftSideMenuWidth, height);
        leftSideMenu.computeSize(leftSideMenuWidth, height, ViewLayoutMask.FIXED, true);
        leftSideMenu.applyComputedSize();
        leftSideMenu.pos(0, 0);

        if (editedFragment.width > 0 && editedFragment.height > 0) {
            editedFragment.anchor(0.5, 0.5);
            editedFragment.scale(Math.min(
                availableFragmentWidth / editedFragment.width,
                availableFragmentHeight / editedFragment.height
            ));
            editedFragment.pos(
                leftSideMenuWidth + availableFragmentWidth * 0.5,
                topBarHeight + availableFragmentHeight * 0.5
            );
        }

        fragmentOverlay.pos(
            editedFragment.x - availableFragmentWidth * 0.5,
            editedFragment.y - availableFragmentHeight * 0.5
        );
        fragmentOverlay.size(availableFragmentWidth, availableFragmentHeight);

        popup.anchor(0.5, 0.5);
        popup.pos(width * 0.5, height * 0.5);
        popup.size(width, height);

        topBar.viewSize(availableFragmentWidth, topBarHeight);
        topBar.computeSize(availableFragmentWidth, topBarHeight, ViewLayoutMask.FIXED, true);
        topBar.applyComputedSize();
        topBar.pos(leftSideMenuWidth, 0);

        bottomBar.viewSize(availableFragmentWidth, bottomBarHeight);
        bottomBar.computeSize(availableFragmentWidth, bottomBarHeight, ViewLayoutMask.FIXED, true);
        bottomBar.applyComputedSize();
        bottomBar.pos(leftSideMenuWidth, height - bottomBarHeight);

    }

/// Internal

    function updateTabs() {

        var selectedFragment = model.project.selectedFragment;
        unobserve();

        // Keep selected tab name
        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        if (selectedFragment == null) {
            panelTabsView.tabViews.tabs = ['Fragments', 'Assets'];
        }
        else {
            panelTabsView.tabViews.tabs = ['Visuals', 'Fragments', 'Assets'];
        }

        // Restore selected tab name on new tab list
        var selectedIndex = panelTabsView.tabViews.tabs.indexOf(selectedName);
        panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;

    }

    function updateEditedFragment() {

        var selectedFragment = model.project.selectedFragment;

        if (selectedFragment == null) {
            unobserve();
            editedFragment.active = false;
            editedFragment.fragmentData = null;
            reobserve();
        }
        else {
            var copied = Reflect.copy(selectedFragment.fragmentDataWithoutItems);
            unobserve();
            if (prevSelectedFragment != selectedFragment) {
                trace('this is a new fragment being loaded, reset items');
                copied.items = [];
                prevSelectedFragment = selectedFragment;
            }
            trace('update fragment data');
            editedFragment.active = true;
            editedFragment.fragmentData = copied;
            reobserve();
        }

    }

    function updateFragmentItems() {

        if (model.loading > 0)
            return;

        var selectedFragment = model.project.selectedFragment;
        var prevSelectedFragment = this.prevSelectedFragment; // Used for invalidation

        unobserve();

        var toCheck = [];

        if (selectedFragment != null) {
            // Add or update items
            reobserve();
            for (item in selectedFragment.items) {
                var entityId = item.entityId;
                unobserve();
                toCheck.push(entityId);
                model.pushUsedFragmentId(selectedFragment.fragmentId);
                reobserve();
                var fragmentItem = item.toFragmentItem();
                unobserve();
                model.popUsedFragmentId();
                //trace('PUT ITEM $entityId');
                editedFragment.putItem(fragmentItem);
                reobserve();
            }
            unobserve();
            // Remove missing items
            var toRemove = null;
            for (fragmentItem in editedFragment.items) {
                if (selectedFragment.get(fragmentItem.id) == null) {
                    if (toRemove == null)
                        toRemove = [];
                    toRemove.push(fragmentItem.id);
                }
            }
            if (toRemove != null) {
                for (id in toRemove) {
                    //trace('REMOVE ITEM $id');
                    editedFragment.removeItem(id);
                }
            }
        }

        app.onceUpdate(this, (_) -> {
            if (editedFragment != null) {
                for (entityId in toCheck) {
                    var entity = editedFragment.get(entityId);
                    if (Std.is(entity, Visual) && !entity.hasComponent('editable')) {
                        bindEditableVisualComponent(cast entity, editedFragment);
                    }
                }
            }
        });

    }

    function updatePopupContentView() {

        var pendingChoice = model.pendingChoice;

        unobserve();

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
        else {
            popup.reset();
        }

        reobserve();

    }

    function bindEditableVisualComponent(visual:Visual, editedFragment:Fragment) {

        var editable = new Editable();

        visual.component('editable', editable);

        editable.onSelect(this, function(visual) {

            trace('ON SELECT ${visual != null}');
            
            var fragmentData = model.project.selectedFragment;
            var entityData = fragmentData.get(visual.id);
            fragmentData.selectedItem = entityData;

            // // Ensure we are on Visuals tab
            // var selectedIndex = panelTabsView.tabViews.tabs.indexOf('Visuals');
            // if (selectedIndex != -1)
            //     panelTabsView.tabViews.selectedIndex = selectedIndex;

        });

        editable.onChange(this, function(visual, changed) {

            var fragmentData = model.project.selectedFragment;
            var entityData = fragmentData.get(visual.id);
            if (entityData != null) {
                for (key in Reflect.fields(changed)) {
                    var value = Reflect.field(changed, key);
                    entityData.props.set(key, value);
                }
            }

        });

    }

    function handleEditableItemUpdate(fragmentItem:FragmentItem) {

        #if editor_debug_item_update
        log.debug('ITEM UPDATED: ${fragmentItem.id} w=${fragmentItem.props.width} h=${fragmentItem.props.height}');
        #end

        var item = model.project.selectedFragment.get(fragmentItem.id);

        var props = fragmentItem.props;
        if (item != null && props != null) {
            for (key in Reflect.fields(fragmentItem.props)) {
                var value = Reflect.field(props, key);

                unobserve();
                if (item.typeOfProp(key) == 'ceramic.FragmentData') {
                    item.props.set(key, value != null ? value.id : null);
                }
                else {
                    item.props.set(key, value);
                }
                reobserve();
            }
        }

    }

    function updateTabsContentView() {

        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        unobserve();

        var contentViewClass:Class<View> = switch (selectedName) {
            case 'Visuals': VisualsPanelView;
            case 'Fragments': FragmentsPanelView;
            case 'Assets': null;
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

    function updateSelectedEditable(runAfterUpdate:Bool) {

        var selectedFragment = model.project.selectedFragment;
        var selectedVisual = selectedFragment != null ? selectedFragment.selectedVisual : null;
        var items = editedFragment.items;

        unobserve();

        for (item in items) {
            var entity = editedFragment.get(item.id);
            var editable:Editable = cast entity.component('editable');
            if (editable != null) {
                if (selectedVisual == null) {
                    editable.deselect();
                }
                else if (entity.id == selectedVisual.entityId) {
                    unobserve();
                    editable.select();
                    Editable.highlight.clip = fragmentOverlay;
                    reobserve();
                }
            }
        }

        if (runAfterUpdate) {
            // Somehow, this is needed because Fragment may need
            // a whole update cycle to get updated properly,
            // so we need to re-process selection after this update cycle
            app.oncePostFlushImmediate(() -> {
                updateSelectedEditable(false);
                app.onceUpdate(this, _ -> {
                    updateSelectedEditable(false);
                    app.onceUpdate(this, _ -> updateSelectedEditable(false));
                });
            });
        }

        reobserve();

    }

    function deselectItems() {

        if (model.project.selectedFragment != null)
            model.project.selectedFragment.selectedItem = null;

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

        onDestroy(keyBindings, function(_) {
            keyBindings.destroy();
            keyBindings = null;
        });

    }
    
    function handleKeyDown(key:Key) {

        if (key.scanCode == ScanCode.BACKSPACE) {
            var fragment = model.project.selectedFragment;
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

        var fragment = model.project.selectedFragment;

        if (fragment != null) {
            var selectedItem = fragment.selectedItem;
            if (selectedItem != null) {
                if (FieldManager.manager.focusedField == null && popup.contentView == null) {
                    return selectedItem;
                }
            }
        }

        return null;

    }

    function updateStyle() {

        color = theme.windowBackgroundColor;

        leftSideMenu.transparent = false;
        leftSideMenu.color = theme.lightBackgroundColor;
        leftSideMenu.borderRightSize = 1;
        leftSideMenu.borderRightColor = theme.darkBorderColor;
        leftSideMenu.borderPosition = INSIDE;

        editedFragment.transparent = false;
        editedFragment.color = theme.darkBackgroundColor;

        topBar.transparent = false;
        topBar.color = theme.lightBackgroundColor;
        topBar.borderBottomSize = 1;
        topBar.borderBottomColor = theme.darkBorderColor;
        topBar.borderPosition = INSIDE;

        bottomBar.transparent = false;
        bottomBar.color = theme.lightBackgroundColor;
        bottomBar.borderTopSize = 1;
        bottomBar.borderTopColor = theme.darkBorderColor;
        bottomBar.borderPosition = INSIDE;

        statusText.color = theme.lightTextColor;
        statusText.font = theme.mediumFont;

    }

    function updateTouchable() {

        this.touchable = model.loading == 0;

    }

}
