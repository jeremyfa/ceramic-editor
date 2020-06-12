package editor.ui.element;

class FragmentEditorView extends View implements Observable {

    @observe var prevSelectedFragment:EditorFragmentData = null;

    @observe public var selectedFragment:EditorFragmentData = null;

    @observe var resettingFragment:Bool = false;

    @observe var editedFragment:Fragment = null;

    public var fragmentOverlay(default, null):Quad;

    var fragmentBackground(default, null):Quad;

    var titleText:TextView;

    var headerView:RowLayout;

    var editorView:EditorView;

    public function new(editorView:EditorView) {
        
        super();

        this.editorView = editorView;
        color = theme.windowBackgroundColor;

        // Fragment background
        fragmentBackground = new Quad();
        fragmentBackground.transparent = false;
        fragmentBackground.depth = 1;
        add(fragmentBackground);

        headerView = new RowLayout();
        headerView.padding(0, 6);
        headerView.depth = 3;
        {
            titleText = new TextView();
            titleText.viewSize(fill(), fill());
            titleText.align = CENTER;
            titleText.verticalAlign = CENTER;
            titleText.preRenderedSize = 20;
            titleText.pointSize = 13;
            headerView.add(titleText);
        }
        add(headerView);

        // Fragment area
        fragmentOverlay = new Quad();
        fragmentOverlay.transparent = true;
        fragmentOverlay.depth = 8;
        add(fragmentOverlay);

        // Fragment
        createEditedFragment();

        autorun(updateEditedFragment);
        autorun(updateFragmentItems);

        autorun(() -> updateSelectedEditable(true));

        // Styles
        autorun(updateStyle);

    }

    public function getEntity(entityId:String):Null<Entity> {

        var editedFragment = this.editedFragment;

        if (editedFragment == null)
            return null;

        return editedFragment.get(entityId);

    }

    public function resetFragment() {

        if (resettingFragment)
            return;

        createEditedFragment();

    }

    function createEditedFragment() {

        if (editedFragment != null) {
            editedFragment.destroy();
            editedFragment = null;
        }

        editedFragment = new Fragment({
            assets: editor.contentAssets,
            editedItems: true
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        onPointerDown(this, (_) -> deselectItems());
        editedFragment.depth = 2;
        add(editedFragment);
        editedFragment.clip = fragmentOverlay;

    }

    function updateEditedFragment() {

        var selectedFragment = this.selectedFragment;
        var editedFragment = this.editedFragment;

        if (selectedFragment == null) {
            unobserve();
            editedFragment.active = false;
            editedFragment.fragmentData = null;
            titleText.content = '';
            reobserve();
        }
        else {
            var copied = Reflect.copy(selectedFragment.fragmentDataWithoutItems);
            var transparent = selectedFragment.transparent;
            var overflow = selectedFragment.overflow;
            var color = selectedFragment.color;
            unobserve();
            titleText.content = selectedFragment.fragmentId;
            if (prevSelectedFragment != selectedFragment) {
                #if ceramic_editor_debug_fragment
                trace('this is a new fragment being loaded, reset items');
                #end
                copied.items = [];
                prevSelectedFragment = selectedFragment;
            }
            #if ceramic_editor_debug_fragment
            trace('update fragment data');
            #end
            editedFragment.active = true;
            editedFragment.fragmentData = copied;
            //editedFragment.transparent = transparent;
            //editedFragment.color = color;
            if (overflow) {
                this.color = transparent ? theme.darkBackgroundColor : color;
            }
            else {
                this.color = theme.windowBackgroundColor;
            }
            fragmentBackground.transparent = !transparent;
            reobserve();
        }

    }

    function updateFragmentItems() {

        if (model.loading > 0)
            return;

        var selectedFragment = this.selectedFragment;
        var prevSelectedFragment = this.prevSelectedFragment; // Used for invalidation
        var editedFragment = this.editedFragment;

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

        var item = this.selectedFragment.get(fragmentItem.id);

        var props = fragmentItem.props;
        if (item != null && props != null) {
            for (key in Reflect.fields(fragmentItem.props)) {
                var value = Reflect.field(props, key);

                unobserve();
                var propType = item.typeOfProp(key);
                if (propType == 'ceramic.FragmentData') {
                    item.props.set(key, value != null ? value.id : null);
                }
                else if (propType == 'ceramic.ScriptContent') {
                    // Nothing to do here
                }
                else {
                    item.props.set(key, value);
                }
                reobserve();
            }
        }

    }

    function deselectItems() {

        if (this.selectedFragment != null)
            this.selectedFragment.selectedItem = null;

    }

    function updateSelectedEditable(runAfterUpdate:Bool) {

        var selectedFragment = this.selectedFragment;
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
            
            var fragmentData = this.selectedFragment;
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

            var fragmentData = this.selectedFragment;
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

        fragmentBackground.anchor(0.5, 0.5);
        fragmentBackground.pos(
            editedFragment.x,
            editedFragment.y
        );
        fragmentBackground.size(
            editedFragment.width * editedFragment.scaleX,
            editedFragment.height * editedFragment.scaleY
        );

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

        fragmentBackground.color = theme.darkBackgroundColor;

        headerView.transparent = false;
        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomSize = 1;
        headerView.borderBottomColor = theme.darkBorderColor;
        headerView.borderPosition = INSIDE;

        titleText.color = theme.lightTextColor;
        titleText.font = theme.boldFont;

    }

    override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float):Bool {

        // Forbid touch outside fragment editor bounds
        if (!hits(x, y)) {
            return true;
        }
        
        // Forbid touch on locked visuals
        var hittingEntityData:EditorEntityData = null;
        if (model.project.lastSelectedFragment != null && editedFragment != null && editedFragment.entities.indexOf(hittingVisual) != -1) {
            hittingEntityData = model.project.lastSelectedFragment.get(hittingVisual.id);
            if (hittingEntityData != null && hittingEntityData.locked) {
                return true;
            }
        }

        // If selected visual still hits, do not allow touch on another visual
        if (model.project.lastSelectedFragment != null && editedFragment != null && hittingEntityData != null) {
            var selectedVisualData = model.project.lastSelectedFragment.selectedVisual;
            if (selectedVisualData != null) {
                var selectedVisual:Visual = cast editedFragment.get(selectedVisualData.entityId);
                if (selectedVisual != null && selectedVisual != hittingVisual && selectedVisual.hits(x, y)) {
                    return true;
                }
            }
        }

        return false;
        
    }

    override function interceptPointerOver(hittingVisual:Visual, x:Float, y:Float):Bool {

        if (!hits(x, y)) {
            return true;
        }

        return false;
        
    }

}