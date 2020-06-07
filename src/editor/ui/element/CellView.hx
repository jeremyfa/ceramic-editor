package editor.ui.element;

using StringTools;
using editor.components.Tooltip;

class CellView extends LayersLayout implements Observable {

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

    @observe public var itemIndex:Int = -1;

    @observe public var collectionView:CellCollectionView = null;

    @observe public var inputStyle:Bool = false;

    @observe public var displaysEmptyValue:Bool = false;

    @observe public var locked:Bool = false;

    @observe public var handleTrash:Void->Void = null;

    @observe public var handleLock:Void->Void = null;

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

    @:noCompletion
    public var targetTy:Float = 0;

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
        //var displayUp = handleUp != null;
        //var displayDown = handleDown != null;
        var displayAnyIcon = displayTrash || displayLock;// || displayUp || displayDown;

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
        /*else {
            titleTextView.paddingLeft = 0;
            subTitleTextView.paddingLeft = 0;
        }*/

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

        titleTextView.textColor = theme.lightTextColor;
        titleTextView.font = theme.mediumFont;

        subTitleTextView.textColor = theme.darkTextColor;
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

    public function cloneForDragDrop():CellView {

        var cloned = new CellView();

        cloned.selected = selected;
        cloned.title = title;
        cloned.subTitle = subTitle;
        cloned.itemIndex = itemIndex;
        cloned.inputStyle = inputStyle;
        cloned.displaysEmptyValue = displaysEmptyValue;
        cloned.locked = locked;
        cloned.handleTrash = handleTrash;
        cloned.handleLock = handleLock;

        return cloned;

    }

}
