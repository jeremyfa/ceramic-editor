package editor.ui.fragment;

import tracker.Autorun;

using ceramic.Extensions;

class FragmentEditorView extends View implements Observable {

    static var _point = new Point(0, 0);

    static var _decomposed = new DecomposedTransform();

    @observe var prevSelectedFragment:EditorFragmentData = null;

    @observe public var selectedFragment:EditorFragmentData = null;

    @observe var resettingFragment:Bool = false;

    @observe public var editedFragment(default, null):Fragment = null;

    @observe var editedFragmentTimelineTime:Float = 0;

    public var fragmentOverlay(default, null):Quad;

    var fragmentBackground(default, null):Quad;

    var titleText:TextView;

    var headerView:RowLayout;

    var editorView:EditorView;

    var itemAutoruns:Array<Autorun> = null;

    var trackAutoruns:Array<Autorun> = null;

    var fragmentTransform:Transform = new Transform();

    var draggingFragment:Bool = false;

    var dragStartX:Float = 0;

    var dragStartY:Float = 0;

    var fragmentDragStartTransform:Transform = new Transform();

    public function new(editorView:EditorView) {
        
        super();

        this.editorView = editorView;
        color = theme.windowBackgroundColor;

        // Fragment background
        fragmentBackground = new Quad();
        fragmentBackground.transparent = false;
        fragmentBackground.depth = 1;
        fragmentBackground.transform = fragmentTransform;
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

        fragmentTransform.onChange(this, handleFragmentTransformChange);

        autorun(updateEditedFragment);
        autorun(updateFragmentItems);
        autorun(updateFragmentTracks);

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
        editedFragment.transform = fragmentTransform;
        editedFragment.timeline = new Timeline();
        var wasAnimating = model.animationState.animating;
        editedFragment.autorun(() -> {
            var animating = model.animationState.animating;
            unobserve();
            editedFragment.timeline.paused = !animating;
            TimelineUtils.setEveryTimelinePaused(editedFragment, !animating);
            if (wasAnimating && !animating) {
                model.animationState.currentFrame = Math.floor(editedFragment.timeline.time * editedFragment.fps);
                model.animationState.invalidateCurrentFrame();
            }
            wasAnimating = animating;
        });
        editedFragment.onEditableItemUpdate(this, handleEditableItemUpdate);
        onPointerDown(editedFragment, handlePointerDown);
        screen.onMouseWheel(editedFragment, handleMouseWheel);
        editedFragment.depth = 2;
        add(editedFragment);

        editedFragment.timeline.autorun(() -> {
            var time = model.animationState.currentFrame / editedFragment.fps;
            var prevTime = this.editedFragmentTimelineTime;
            unobserve();

            // Update timeline position
            editedFragment.timeline.seek(time);
            TimelineUtils.setEveryTimelineTime(editedFragment, time);

            // Invalidate timeline time
            this.editedFragmentTimelineTime = time;

            // Then retrieve changes made from timeline to report them to edited data
            app.oncePostFlushImmediate(() -> {
                var selectedFragment = model.project.lastSelectedFragment;
                if (selectedFragment != null && editedFragment != null) {
                    for (item in selectedFragment.items) {
                        var entity = null;
                        if (item.timelineTracks != null && item.timelineTracks.length > 0) {
                            for (timelineTrack in item.timelineTracks) {

                                // Before dispatching change, force arrays to be copied when changing time
                                var propType = item.typeOfProp(timelineTrack.field);
                                if (propType != null && propType.startsWith('Array<')) {
                                    if (entity == null) {
                                        entity = editedFragment.get(item.entityId);
                                    }
                                    if (entity != null) {
                                        var array:Array<Dynamic> = entity.getProperty(timelineTrack.field);
                                        entity.setProperty(timelineTrack.field, [].concat(array));
                                    }
                                }

                            }

                            editedFragment.computeInstanceContentIfNeeded(item.entityId);
                            editedFragment.updateEditableFieldsFromInstance(item.entityId);
                        }
                    }
                }
            });
        });

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
                fragmentTransform.identity();
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

    function handleFragmentTransformChange() {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;

        if (editedFragment != null && selectedItem != null) {
            var entityId = selectedItem.entityId;
            var entity = editedFragment.get(entityId);
            if (entity != null) {
                var rawEditable = entity.component('editable');
                if (rawEditable != null && Std.is(rawEditable, Editable)) {
                    var editable:Editable = cast rawEditable;
                    editable.syncVisual();
                }
            }
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

        if (itemAutoruns != null) {
            for (auto in itemAutoruns) {
                auto.destroy();
            }
        }

        itemAutoruns = []; 

        if (selectedFragment != null) {
            // Add or update items
            reobserve();
            var selectedFragmentItems = selectedFragment.items;
            unobserve();
            for (item in selectedFragmentItems) {

                var entityId = item.entityId;
                toCheck.push(entityId);

                itemAutoruns.push(item.autorun(function() {
                    bindItemData(item);
                }));
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

    function bindItemData(item:EditorEntityData) {

        if (model.loading > 0)
            return;

        var selectedFragment = this.selectedFragment;
        if (selectedFragment == null || editedFragment == null || editedFragment.destroyed)
            return;

        unobserve();
        model.pushUsedFragmentId(selectedFragment.fragmentId);
        reobserve();
        var fragmentItem = item.toFragmentItem();
        unobserve();
        model.popUsedFragmentId();
        editedFragment.putItem(fragmentItem);
        app.oncePostFlushImmediate(() -> {
            if (!destroyed) {
                TimelineUtils.setEveryTimelinePaused(editedFragment, !model.animationState.animating);
            }
        });
        app.onceUpdate(this, _ -> {
            TimelineUtils.setEveryTimelinePaused(editedFragment, !model.animationState.animating);
        });
        reobserve();

    }

    function handleEditableItemUpdate(fragmentItem:FragmentItem) {

        #if editor_debug_item_update
        log.debug('ITEM UPDATED: ${fragmentItem.id} w=${fragmentItem.props.width} h=${fragmentItem.props.height}');
        #end

        var editedFragment = editedFragment;
        if (editedFragment == null) {
            return;
        }

        if (model.animationState.animating) {
            // Ignore changes when animating
            return;
        }

        var currentFrame = model.animationState.currentFrame;
        var timelineFrame = 0;
        if (editedFragment.timeline != null) {
            timelineFrame = Math.round(editedFragment.timeline.time * editedFragment.fps);
        }
        var item = this.selectedFragment.get(fragmentItem.id);

        var props = fragmentItem.props;
        var shouldInvalidateTimelineTime = false;
        if (item != null && props != null) {
            for (key in Reflect.fields(fragmentItem.props)) {
                var value:Dynamic = Reflect.field(props, key);

                unobserve();
                var timelineTrack = null;
                if (currentFrame > 0) {
                    timelineTrack = item.timelineTrackForField(key);
                    if (timelineTrack != null) {
                        // Got a timeline track. Ensure fragment also has a track in sync
                        // otherwise ignore changes for now
                        var track = editedFragment.getTrack(item.entityId, key);
                        if (track == null || timelineFrame != currentFrame) {
                            shouldInvalidateTimelineTime = true;
                            //log.warning('Ignore entity changes because tracks are not in sync $timelineFrame');
                            reobserve();
                            continue;
                        }
                    }
                }

                var propType = item.typeOfProp(key);
                if (propType == 'ceramic.FragmentData') {
                    item.props.set(key, value != null ? value.id : null);
                }
                else if (propType == 'ceramic.ScriptContent') {
                    // Nothing to do here
                }
                else if (propType == 'Float') {
                    item.props.set(key, Math.round(value * 1000) / 1000);
                }
                else {
                    item.props.set(key, value);
                }
                reobserve();
            }
        }

        // When fragment's timeline is not in sync with edited data, explicitly invalidate
        // timeline time to recompute it
        if (shouldInvalidateTimelineTime) {
            app.oncePostFlushImmediate(() -> {
                if (!destroyed) {
                    invalidateEditedFragmentTimelineTime();
                }
            });
            app.onceUpdate(this, _ -> {
                invalidateEditedFragmentTimelineTime();
            });
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

            // Auto-select related script (if any)
            var scriptId = entityData.props.get('scriptContent');
            if (scriptId != null) {
                var script = model.project.scriptById(scriptId);
                if (script != null) {
                    model.project.selectedScript = script;
                }
            }

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
                    entityData.props.set(key, value, true);
                }
            }

        });

    }

    function updateFragmentTracks() {

        if (model.loading > 0)
            return;

        var selectedFragment = this.selectedFragment;
        var editedFragment = this.editedFragment;

        unobserve();

        var stillUsed = new Map<String,Map<String,Bool>>();

        if (trackAutoruns != null) {
            for (auto in trackAutoruns) {
                auto.destroy();
            }
        }

        trackAutoruns = []; 

        if (selectedFragment != null) {
            // Add or update item tracks
            reobserve();
            var selectedFragmentItems = selectedFragment.items;
            unobserve();
            for (item in selectedFragmentItems) {
                reobserve();
                var tracks = item.timelineTracks;
                unobserve();
                for (track in tracks) {
                    reobserve();
                    var trackEntity = track.entity;
                    var trackField = track.field;
                    unobserve();

                    var forEntity = stillUsed.get(trackEntity);
                    if (forEntity == null) {
                        forEntity = new Map();
                        stillUsed.set(trackEntity, forEntity);
                    }
                    forEntity.set(trackField, true);

                    trackAutoruns.push(track.autorun(function() {
                        bindTrackData(track);
                    }));
                }
            }

            // Remove missing items
            var toRemove:Array<Array<String>> = null;
            if (editedFragment.tracks != null) {
                for (fragmentTrack in editedFragment.tracks) {
                    if (!stillUsed.exists(fragmentTrack.entity) || !stillUsed.get(fragmentTrack.entity).exists(fragmentTrack.field)) {
                        if (toRemove == null)
                            toRemove = [];
                        toRemove.push([fragmentTrack.entity, fragmentTrack.field]);
                    }
                }
                if (toRemove != null) {
                    for (info in toRemove) {
                        editedFragment.removeTrack(info[0], info[1]);
                    }
                }
            }
        }

    }

    function bindTrackData(track:EditorTimelineTrack) {

        if (model.loading > 0)
            return;

        var editedFragmentTimelineTime = this.editedFragmentTimelineTime;

        var selectedFragment = this.selectedFragment;
        if (selectedFragment == null)
            return;

        var trackItem = track.toTimelineTrackData();
        unobserve();
        if (editedFragment.get(trackItem.entity) != null) {
            //log.warning('PUT TRACK ' + trackItem.entity + '#' + trackItem.field);
            editedFragment.putTrack(trackItem);
        }
        reobserve();

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

    function handlePointerDown(info:TouchInfo) {

        if (info.buttonId == 3) {
            // Right click
            draggingFragment = true;
            screenToVisual(info.x, info.y, _point);
            dragStartX = _point.x;
            dragStartY = _point.y;
            fragmentDragStartTransform.setToTransform(fragmentTransform);
            screen.onPointerMove(this, handlePointerMove);
            screen.oncePointerUp(this, _ -> {
                draggingFragment = false;
            });
        }
        else if (info.buttonId == 2) {
            // Middle click
            fragmentTransform.identity();
        }
        else {
            deselectItems();
        }

    }

    function handleMouseWheel(x:Float, y:Float) {

        if (hits(screen.pointerX, screen.pointerY)) {

            screenToVisual(screen.pointerX, screen.pointerY, _point);
            var pointerX = _point.x;
            var pointerY = _point.y;
            
            var scaleFactor = 1.0;

            if (y > 0) {
                scaleFactor = 1.0 + y * 0.001;
            }
            else if (y < 0) {
                scaleFactor = 1.0 / (1.0 - y * 0.001);
            }

            if (scaleFactor != 1.0) {

                fragmentTransform.decompose(_decomposed);
                var prevScale = _decomposed.scaleX;
                var newScale = prevScale * scaleFactor;

                if (newScale < 0.1 || newScale > 100.0)
                    return;
                
                var tx = pointerX;
                var ty = pointerY;

                fragmentTransform.translate(-tx, -ty);
    
                fragmentTransform.scale(
                    scaleFactor,
                    scaleFactor
                );

                fragmentTransform.translate(tx, ty);
            }
        }

    }

    function handlePointerMove(info:TouchInfo) {

        if (!draggingFragment)
            return;

        screenToVisual(info.x, info.y, _point);
        var dragX = _point.x;
        var dragY = _point.y;

        fragmentTransform.tx = fragmentDragStartTransform.tx + dragX - dragStartX;
        fragmentTransform.ty = fragmentDragStartTransform.ty + dragY - dragStartY;
        fragmentTransform.changedDirty = true;

    }

    override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float, touchIndex:Int, buttonId:Int):Bool {

        // Forbid touch outside fragment editor bounds or if currently animating its content
        if (model.animationState.animating || !hits(x, y)) {
            return true;
        }

        // Do not accept right or middle click unless hittingVisual is the fragment editor view itself
        if (buttonId == 3 || buttonId == 2) {
            if (hittingVisual == this) {
                // Handle right click
                return false;
            }
            else {
                // Forbid right click on this hitting visual
                return true;
            }
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