package editor.ui.element;

class FragmentEditorView extends View {

    @observe var prevSelectedFragment:EditorFragmentData = null;

    public var fragmentOverlay(default, null):Quad;

    var editedFragment:Fragment = null;

    var fragmentTitleText:TextView;

    var headerView:RowLayout;

    var editorView:EditorView;

    public function new(editorView:EditorView) {
        
        super();

        this.editorView = editorView;

        // Fragment
        editedFragment = new Fragment({
            assets: editor.contentAssets,
            editedItems: true
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        editedFragment.onPointerDown(this, (_) -> deselectItems());
        editedFragment.depth = 1;
        add(editedFragment);

        headerView = new RowLayout();
        headerView.padding(0, 6);
        headerView.depth = 2;
        {
            fragmentTitleText = new TextView();
            fragmentTitleText.viewSize(fill(), fill());
            fragmentTitleText.align = CENTER;
            fragmentTitleText.verticalAlign = CENTER;
            fragmentTitleText.preRenderedSize = 20;
            fragmentTitleText.pointSize = 13;
            headerView.add(fragmentTitleText);
        }
        add(headerView);

        // Fragment area
        fragmentOverlay = new Quad();
        fragmentOverlay.transparent = true;
        fragmentOverlay.depth = 8;
        editedFragment.clip = fragmentOverlay;
        add(fragmentOverlay);

        autorun(updateEditedFragment);
        autorun(updateFragmentItems);

        autorun(() -> updateSelectedEditable(true));

        // Styles
        autorun(updateStyle);

    }

    function updateEditedFragment() {

        var selectedFragment = model.project.selectedFragment;

        if (selectedFragment == null) {
            unobserve();
            editedFragment.active = false;
            editedFragment.fragmentData = null;
            fragmentTitleText.content = '';
            reobserve();
        }
        else {
            var copied = Reflect.copy(selectedFragment.fragmentDataWithoutItems);
            unobserve();
            fragmentTitleText.content = selectedFragment.fragmentId;
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

    function deselectItems() {

        if (model.project.selectedFragment != null)
            model.project.selectedFragment.selectedItem = null;

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

    function bindEditableVisualComponent(visual:Visual, editedFragment:Fragment) {

        var editable = new Editable();

        visual.component('editable', editable);

        editable.onSelect(this, function(visual, fromPointer) {
            
            var fragmentData = model.project.selectedFragment;
            var entityData = fragmentData.get(visual.id);
            fragmentData.selectedItem = entityData;

            if (fromPointer) {
                // Ensure we are on Visuals tab
                var selectedIndex = editorView.panelTabsView.tabViews.tabs.indexOf('Visuals');
                if (selectedIndex != -1)
                    editorView.panelTabsView.tabViews.selectedIndex = selectedIndex;
            }

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

    override function layout() {

        var headerViewHeight = 25;
        var availableFragmentWidth = width;
        var availableFragmentHeight = height - headerViewHeight;

        if (editedFragment.width > 0 && editedFragment.height > 0) {
            editedFragment.anchor(0.5, 0.5);
            editedFragment.scale(Math.min(
                availableFragmentWidth / editedFragment.width,
                availableFragmentHeight / editedFragment.height
            ));
            editedFragment.pos(
                availableFragmentWidth * 0.5,
                headerViewHeight + availableFragmentHeight * 0.5
            );
        }

        fragmentOverlay.pos(
            editedFragment.x - availableFragmentWidth * 0.5,
            editedFragment.y - availableFragmentHeight * 0.5
        );
        fragmentOverlay.size(availableFragmentWidth, availableFragmentHeight);

        headerView.viewSize(availableFragmentWidth, headerViewHeight);
        headerView.computeSize(availableFragmentWidth, headerViewHeight, ViewLayoutMask.FIXED, true);
        headerView.applyComputedSize();
        headerView.pos(0, 0);

    }

    function updateStyle() {

        color = theme.windowBackgroundColor;

        editedFragment.transparent = false;
        editedFragment.color = theme.darkBackgroundColor;

        headerView.transparent = false;
        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomSize = 1;
        headerView.borderBottomColor = theme.darkBorderColor;
        headerView.borderPosition = INSIDE;

        fragmentTitleText.color = theme.lightTextColor;
        fragmentTitleText.font = theme.boldFont;

    }

}