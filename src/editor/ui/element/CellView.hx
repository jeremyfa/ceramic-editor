package editor.ui.element;

using StringTools;
using ceramic.VisualTransition;
using editor.components.Tooltip;

class CellView extends LayersLayout implements Observable {

    static var _notVisibleTransform:Transform = null;

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

    @observe public var itemIndex(default, set):Int = -1;
    function set_itemIndex(itemIndex:Int):Int {
        if (this.itemIndex != itemIndex) {
            this.itemIndex = itemIndex;
            hover = false;
        }
        return itemIndex;
    }

    @observe public var collectionView:CellCollectionView = null;

    @observe public var inputStyle:Bool = false;

    @observe public var displaysEmptyValue:Bool = false;

    @observe public var locked:Bool = false;

    @observe public var kindIcon:Null<Entypo> = null;

    @observe public var handleTrash:Void->Void = null;

    @observe public var handleLock:Void->Void = null;

    @observe public var handleDuplicate:Void->Void = null;

    /*
    @observe public var handleUp:Void->Void = null;

    @observe public var handleDown:Void->Void = null;
    */

/// Internal

    var titleTextView:TextView;

    var subTitleTextView:TextView;

    var clearScrollDelay:Void->Void = null;

    var columnLayout:ColumnLayout;

    var iconsView:RowLayout = null;

    var dragTargetTy:Float = 0;

    var dragDrop:DragDrop;

    var dragAutoScroll:Float = 0;

    var dragStartScrollY:Float = 0;

    var draggingCellDragY:Float = 0;

    var draggingCell:CellView = null;

    var dragOnItemIndex:Int = -1;

    @observe var hover:Bool = false;

    @observe var appliedHoverItemIndex:Int = -1;

/// Lifecycle

    public function new() {

        super();

        columnLayout = new ColumnLayout();
        columnLayout.align = CENTER;
        columnLayout.itemSpacing = 1;
        columnLayout.viewSize(fill(), auto());
        add(columnLayout);

        borderBottomSize = 1;
        borderPosition = INSIDE;
        transparent = false;
        
        titleTextView = new TextView();
        titleTextView.align = LEFT;
        titleTextView.pointSize = 12;
        titleTextView.preRenderedSize = 20;
        titleTextView.viewSize(fill(), auto());
        columnLayout.add(titleTextView);
        
        subTitleTextView = new TextView();
        subTitleTextView.align = LEFT;
        subTitleTextView.pointSize = 11;
        subTitleTextView.preRenderedSize = 20;
        subTitleTextView.paddingLeft = 1;
        subTitleTextView.viewSize(fill(), auto());
        subTitleTextView.text.component('italicText', new ItalicText());
        columnLayout.add(subTitleTextView);

        autorun(updateTitle);
        autorun(updateSubTitle);
        autorun(updateStyle);
        autorun(updateIcons);

        onPointerOver(this, function(_) hover = true);
        onPointerOut(this, function(_) hover = false);

    }

    function updateTitle() {

        var title = this.title;
        if (title != null) {
            title = title.trim().replace("\n", ' ');
            if (title.length > 20) {
                title = title.substr(0, 20) + '...'; // TODO at textview level
            }
            titleTextView.content = title;
            titleTextView.active = true;
        }
        else {
            titleTextView.content = '';
            titleTextView.active = false;
        }

    }

    function updateSubTitle() {

        var subTitle = this.subTitle;
        if (subTitle != null) {
            subTitleTextView.content = subTitle;
            subTitleTextView.active = true;
        }
        else {
            subTitleTextView.content = '';
            subTitleTextView.active = false;
        }

    }

    function updateIcons() {

        var displayTrash = handleTrash != null;
        var displayLock = handleLock != null;
        var displayDuplicate = handleDuplicate != null;
        //var displayUp = handleUp != null;
        //var displayDown = handleDown != null;
        var displayKindIcon = kindIcon != null;
        var displayAnyIcon = displayTrash || displayLock || displayKindIcon;// || displayUp || displayDown;

        unobserve();

        if (iconsView != null) {
            iconsView.destroy();
        }

        if (displayAnyIcon) {
            iconsView = new RowLayout();
            iconsView.paddingRight = 8;
            iconsView.viewSize(fill(), fill());
            iconsView.align = RIGHT;
            add(iconsView);

            var w = 21;
            var s = 14;

            if (displayKindIcon) {
                titleTextView.paddingLeft = 22;
                subTitleTextView.paddingLeft = 22;

                var iconView = new EntypoIconView();
                iconView.icon = kindIcon;
                iconView.viewSize(25, fill());
                iconView.pointSize = 20;
                iconView.paddingLeft = 2;
                columnLayout.add(iconView);

                iconsView.add(iconView);

                var filler = new View();
                filler.transparent = true;
                filler.viewSize(fill(), fill());
                iconsView.add(filler);
            }
            else {
                titleTextView.paddingLeft = 0;
                subTitleTextView.paddingLeft = 0;
            }
            /*
            if (displayUp || displayDown) {
                titleTextView.paddingLeft = 16;
                subTitleTextView.paddingLeft = 16;

                var columnLayout = new ColumnLayout();
                columnLayout.align = CENTER;
                columnLayout.padding(4, 0);

                if (displayUp) {
                    var iconView = new ClickableIconView();
                    iconView.icon = UP_OPEN;
                    iconView.viewSize(w, fill());
                    iconView.pointSize = s;
                    iconView.onClick(this, handleUp);
                    columnLayout.add(iconView);
                }
    
                if (displayDown) {
                    var iconView = new ClickableIconView();
                    iconView.icon = DOWN_OPEN;
                    iconView.viewSize(w, fill());
                    iconView.pointSize = s;
                    iconView.onClick(this, handleDown);
                    columnLayout.add(iconView);
                }

                iconsView.add(columnLayout);

                var filler = new View();
                filler.transparent = true;
                filler.viewSize(fill(), fill());
                iconsView.add(filler);
            }
            else {
                titleTextView.paddingLeft = 0;
                subTitleTextView.paddingLeft = 0;
            }
            */

            if (displayDuplicate) {
                var iconView = new ClickableIconView();
                iconView.icon = DOCS;
                iconView.tooltip('Duplicate');
                iconView.viewSize(w, fill());
                iconView.pointSize = s;
                iconView.onClick(this, handleDuplicate);
                iconsView.add(iconView);
            }

            if (displayLock) {
                var iconView = new ClickableIconView();
                iconView.autorun(() -> {
                    iconView.icon = locked ? LOCK : LOCK_OPEN;
                    iconView.tooltip(locked ? 'Unlock' : 'Lock');
                });
                iconView.viewSize(w, fill());
                iconView.pointSize = s;
                iconView.onClick(this, handleLock);
                iconsView.add(iconView);
            }

            if (displayTrash) {
                var iconView = new ClickableIconView();
                iconView.icon = TRASH;
                iconView.viewSize(w, fill());
                iconView.pointSize = s;
                iconView.tooltip('Delete');
                iconView.onClick(this, handleTrash);
                iconsView.add(iconView);
            }
        }
        else {
            titleTextView.paddingLeft = 0;
            subTitleTextView.paddingLeft = 0;
        }

        reobserve();

    }

    function updateStyle() {

        if (inputStyle) {
            columnLayout.padding(6, 6);
        }
        else {
            columnLayout.padding(8, 8);
        }

        if (selected) {
            color = theme.lightBackgroundColor;
            transparent = false;
            alpha = 1;
            if (inputStyle) {
                borderLeftSize = 0;
                borderRightSize = 0;
            }
            else {
                borderLeftColor = theme.selectionBorderColor;
                borderLeftSize = 2;
                borderRightSize = 0;
            }
        }
        else if (locked && !inputStyle) {
            alpha = 1;
            transparent = false;
            borderLeftSize = 0;
            borderRightSize = 0;

            color = theme.darkBackgroundColor;
        }
        else {
            alpha = 1;
            transparent = false;
            borderLeftSize = 0;
            borderRightSize = 0;

            if (collectionView == null || !collectionView.scrolling) {
                if (hover) {
                    appliedHoverItemIndex = itemIndex;
                    color = theme.lightBackgroundColor;
                } else {
                    appliedHoverItemIndex = -1;
                    if (inputStyle) {
                        color = theme.darkBackgroundColor;
                    }
                    else {
                        color = theme.mediumBackgroundColor;
                    }
                }
            }
            else {
                if (appliedHoverItemIndex != -1 && appliedHoverItemIndex == itemIndex) {
                    color = theme.lightBackgroundColor;
                }
                else {
                    if (inputStyle) {
                        color = theme.darkBackgroundColor;
                    }
                    else {
                        color = theme.mediumBackgroundColor;
                    }
                }
            }
        }

        if (locked) {
            titleTextView.textColor = Color.interpolate(theme.lightTextColor, color, 0.4);
            subTitleTextView.textColor = Color.interpolate(theme.darkTextColor, color, 0.4);
        }
        else {
            titleTextView.textColor = theme.lightTextColor;
            subTitleTextView.textColor = theme.darkTextColor;
        }

        titleTextView.font = theme.mediumFont;
        subTitleTextView.font = theme.mediumFont;

        borderBottomColor = theme.mediumBorderColor;

        if (inputStyle && displaysEmptyValue) {
            titleTextView.text.skewX = 8;
            titleTextView.text.alpha = 0.8;
        }
        else {
            titleTextView.text.skewX = 0;
            titleTextView.text.alpha = 1;
        }

    }

/// Drag & Drop

    public function bindDragDrop(?click:Click, handleDrop:(itemIndex:Int)->Void) {

        if (_notVisibleTransform == null) {
            _notVisibleTransform = new Transform();
            _notVisibleTransform.translate(-99999999, -99999999);
        }

        dragDrop = new DragDrop(click,
            createDraggingVisual,
            releaseDraggingVisual
        );
        this.component('dragDrop', dragDrop);
        dragDrop.onDraggingChange(this, function(dragging:Bool, wasDragging:Bool) {
            if (wasDragging && !dragging) {
                handleDrop(dragOnItemIndex);
            }
            handleDragChange(dragging, wasDragging);
        });
        dragDrop.autorun(updateFromDrag);

    }

    function cloneForDragDrop():CellView {

        var cloned = new CellView();

        cloned.selected = selected;
        cloned.title = title;
        cloned.subTitle = subTitle;
        cloned.itemIndex = itemIndex;
        cloned.inputStyle = inputStyle;
        cloned.displaysEmptyValue = displaysEmptyValue;
        cloned.kindIcon = kindIcon;
        cloned.locked = locked;
        cloned.handleTrash = handleTrash;
        cloned.handleLock = handleLock;
        cloned.handleDuplicate = handleDuplicate;

        return cloned;

    }

    function createDraggingVisual():Visual {

        var visual = this.cloneForDragDrop();

        visual.touchable = false;
        visual.depth = 9999;
        visual.viewSize(this.width, this.height);
        visual.computeSize(this.width, this.height, ViewLayoutMask.FIXED, true);
        visual.applyComputedSize();
        visual.pos(this.x, this.y);
        this.parent.add(visual);

        return visual;

    }

    function releaseDraggingVisual(visual:Visual) {

        visual.destroy();

    }

    function handleDragChange(dragging:Bool, wasDragging:Bool) {
        if (dragging == wasDragging)
            return;

        if (dragging) {
            dragAutoScroll = 0;
            draggingCellDragY = 0;
            this.transform = _notVisibleTransform;
            var scroller = firstParentWithClass(Scroller);
            if (scroller != null) {
                dragStartScrollY = scroller.scrollY;
            }

            app.onUpdate(dragDrop, scrollFromDragIfNeeded);
        }
        else {
            dragAutoScroll = 0;
            this.transform = null;
            var parent = this.parent;
            for (child in parent.children) {
                if (child != this && Std.is(child, CellView)) {
                    var otherCell:CellView = cast child;
                    otherCell.transition(0.0, props -> {
                        props.transform = null;
                    });
                }
            }

            app.offUpdate(scrollFromDragIfNeeded);
        }
    }

    function updateFromDrag() {

        var dragging = dragDrop.dragging;
        draggingCellDragY = dragDrop.dragY;

        unobserve();

        if (dragging) {

            // Move other thiss from drag
            //

            var dragExtra = 0.0;
            var scroller = this.firstParentWithClass(Scroller);
            if (scroller != null) {
                dragExtra = scroller.scrollY - dragStartScrollY;
            }

            draggingCell = cast dragDrop.draggingVisual;
            draggingCell.pos(this.x, this.y + draggingCellDragY + dragExtra);

            updateOtherCellsFromDrag();

            // Scroll container if reaching bounds with drag
            //
            var scroller = this.firstParentWithClass(Scroller);
            if (scroller != null) {
                if (this.y + this.height + draggingCellDragY + dragExtra > scroller.height + scroller.scrollY) {
                    dragAutoScroll = (this.y + this.height + draggingCellDragY + dragExtra) - (scroller.height + scroller.scrollY);
                }
                else if (this.y + draggingCellDragY + dragExtra < scroller.scrollY) {
                    dragAutoScroll = (this.y + draggingCellDragY + dragExtra) - scroller.scrollY;
                }
                else {
                    dragAutoScroll = 0;
                }
            }
        }

        reobserve();

    }

    function updateOtherCellsFromDrag() {

        var thisStep = this.height;
        var transitionDuration = 0.1;

        dragOnItemIndex = this.itemIndex;

        var parent = this.parent;
        for (child in parent.children) {
            if (child != this && Std.is(child, CellView)) {
                var otherCell:CellView = cast child;
                if (otherCell.transform == null) {
                    otherCell.transform = new Transform();
                }
                var prevTargetTy = otherCell.dragTargetTy;
                var dragTargetTy = prevTargetTy;
                if (this.itemIndex > otherCell.itemIndex) {
                    if (draggingCell.y < otherCell.y + otherCell.height * 0.5) {
                        if (dragOnItemIndex > otherCell.itemIndex)
                            dragOnItemIndex = otherCell.itemIndex;
                        dragTargetTy = thisStep;
                    }
                    else {
                        dragTargetTy = 0;
                    }
                }
                else if (this.itemIndex < otherCell.itemIndex) {
                    if (draggingCell.y > otherCell.y - otherCell.height * 0.5) {
                        if (dragOnItemIndex < otherCell.itemIndex)
                            dragOnItemIndex = otherCell.itemIndex;
                        dragTargetTy = -thisStep;
                    }
                    else {
                        dragTargetTy = 0;
                    }
                }
                else {
                    dragTargetTy = 0;
                }
                if (dragTargetTy != prevTargetTy) {
                    otherCell.dragTargetTy = dragTargetTy;
                    otherCell.transition(transitionDuration, props -> {
                        props.transform.ty = dragTargetTy;
                        props.transform.changedDirty = true;
                    });
                }
            }
        }

    }

    function scrollFromDragIfNeeded(delta:Float) {

        if (dragAutoScroll != 0) {
            var scroller = this.firstParentWithClass(Scroller);
            if (scroller != null) {
                var prevScrollY = scroller.scrollY;
                scroller.scrollY += dragAutoScroll * delta * 10;
                scroller.scrollToBounds();

                if (scroller.scrollY != prevScrollY) {
                    if (draggingCell != null) {
                        var dragExtra = scroller.scrollY - dragStartScrollY;
                        draggingCell.pos(this.x, this.y + draggingCellDragY + dragExtra);
                    }

                    updateOtherCellsFromDrag();
                }
            }
        }

    }

}
