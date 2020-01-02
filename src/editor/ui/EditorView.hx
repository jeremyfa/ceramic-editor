package editor.ui;

class EditorView extends View implements Observable {

/// Properties

    @observe public var panelTabsView:PanelTabsView;

    var editedFragment:Fragment = null;

/// Lifecycle

    public function new() {

        super();

        // Panels tabs
        panelTabsView = new PanelTabsView();
        add(panelTabsView);

        // Fragment
        editedFragment = new Fragment({
            assets: editor.assets,
            editedItems: true
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        add(editedFragment);

        autorun(updateTabs);
        autorun(updateEditedFragment);
        autorun(updateTabsContentView);

        autorun(updateFragmentItems);

        autorun(() -> updateSelectedEditable(true));

        // Styles
        autorun(updateStyle);

    } //new

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

    } //layout

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

    } //updateTabs

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
            trace('update fragment data');
            editedFragment.active = true;
            editedFragment.fragmentData = copied;
            reobserve();
        }

    } //updateEditedFragment

    function updateFragmentItems() {

        var selectedFragment = model.project.selectedFragment;

        var toCheck = [];

        if (selectedFragment != null) {
            for (item in selectedFragment.items) {
                var entityId = item.entityId;
                toCheck.push(entityId);
                editedFragment.putItem(item.toFragmentItem());
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

    } //updateFragmentItems

    function bindEditableVisualComponent(visual:Visual, editedFragment:Fragment) {

        var editable = new Editable();

        visual.component('editable', editable);

        editable.onSelect(this, function(visual) {

            trace('ON SELECT ${visual != null}');
            
            var fragmentData = model.project.selectedFragment;
            var entityData = fragmentData.get(visual.id);
            fragmentData.selectedItem = entityData;

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

    } //bindEditableVisualComponent

    function handleEditableItemUpdate(fragmentItem:FragmentItem) {

        log.debug('ITEM UPDATED: ${fragmentItem.id}');

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

    } //handleEditableItemUpdate

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

    } //updateTabsContentView

    function updateSelectedEditable(runAfterUpdate:Bool) {

        var selectedFragment = model.project.selectedFragment;
        var selectedVisual = selectedFragment != null ? selectedFragment.selectedVisual : null;
        var items = editedFragment.items;

        unobserve();

        if (selectedVisual == null)
            return;

        for (item in items) {
            var entity = editedFragment.get(item.id);
            var editable:Editable = cast entity.component('editable');
            if (editable != null) {
                if (entity.id == selectedVisual.entityId) {
                    unobserve();
                    editable.select();
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

    } //updateSelectedEditable

    function updateStyle() {

        color = theme.windowBackgroundColor;

        editedFragment.transparent = false;
        editedFragment.color = theme.darkBackgroundColor;

    } //updateStyle

} //EditorView
