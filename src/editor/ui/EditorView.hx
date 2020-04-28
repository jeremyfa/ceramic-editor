package editor.ui;

class EditorView extends View implements Observable {

/// Properties

    @observe public var panelTabsView:PanelTabsView;

    @observe var prevSelectedFragment:EditorFragmentData = null;

    public var fragmentOverlay(default, null):Quad;

    var editedFragment:Fragment = null;

    var popup:PopupView = null;

/// Lifecycle

    public function new() {

        super();

        app.onceImmediate(() -> init());

    }

    function init() {

        // Panels tabs
        panelTabsView = new PanelTabsView();
        panelTabsView.depth = 3;
        add(panelTabsView);

        // Fragment
        editedFragment = new Fragment({
            assets: editor.contentAssets,
            editedItems: true
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        editedFragment.depth = 1;
        editedFragment.onPointerDown(this, (_) -> deselectItems());
        add(editedFragment);

        // Fragment area
        fragmentOverlay = new Quad();
        fragmentOverlay.transparent = true;
        fragmentOverlay.depth = 2;
        add(fragmentOverlay);

        // Popup
        popup = new PopupView();
        popup.depth = 4;
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
        app.onKeyDown(this, handleKeyDown);

    }

    override function layout() {
        
        var panelsTabsWidth = 300;
        var availableFragmentWidth = width - panelsTabsWidth;
        var availableFragmentHeight = height;

        panelTabsView.viewSize(panelsTabsWidth, height);
        panelTabsView.computeSize(panelsTabsWidth, height, ViewLayoutMask.FIXED, true);
        panelTabsView.applyComputedSize();
        panelTabsView.pos(width - panelTabsView.width, 0);

        if (editedFragment.width > 0 && editedFragment.height > 0) {
            editedFragment.anchor(0.5, 0.5);
            editedFragment.scale(Math.min(
                availableFragmentWidth / editedFragment.width,
                availableFragmentHeight / editedFragment.height
            ));
            editedFragment.pos(
                availableFragmentWidth * 0.5,
                availableFragmentHeight * 0.5
            );
        }

        fragmentOverlay.pos(0, 0);
        fragmentOverlay.size(availableFragmentWidth, availableFragmentHeight);

        popup.anchor(0.5, 0.5);
        popup.pos(width * 0.5, height * 0.5);
        popup.size(width, height);

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

        var selectedFragment = model.project.selectedFragment;
        var prevSelectedFragment = this.prevSelectedFragment; // Used for invalidation

        var toCheck = [];

        if (selectedFragment != null) {
            // Add or update items
            for (item in selectedFragment.items) {
                var entityId = item.entityId;
                toCheck.push(entityId);
                var fragmentItem = item.toFragmentItem();
                trace('PUT ITEM $entityId');
                editedFragment.putItem(fragmentItem);
            }
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
                item.props.set(key, value);
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
    
    function handleKeyDown(key:Key) {

        if (key.scanCode == ScanCode.BACKSPACE) {
            var fragment = model.project.selectedFragment;
            if (fragment != null) {
                var selectedItem = fragment.selectedItem;
                if (selectedItem != null) {
                    if (FieldManager.manager.focusedField == null && popup.contentView == null) {
                        fragment.removeItem(selectedItem);
                    }
                }
            }
        }

    }

    function updateStyle() {

        color = theme.windowBackgroundColor;

        editedFragment.transparent = false;
        editedFragment.color = theme.darkBackgroundColor;

    }

}
