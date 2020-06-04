package editor.ui.element;

using StringTools;

class CellView extends LayersLayout implements Observable {

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

    @observe public var itemIndex:Int = -1;

    @observe public var collectionView:CellCollectionView = null;

    @observe public var inputStyle:Bool = false;

    @observe public var displaysEmptyValue:Bool = false;

    @observe public var handleTrash:Void->Void = null;

/// Internal

    var titleTextView:TextView;

    var subTitleTextView:TextView;

    var clearScrollDelay:Void->Void = null;

    var columnLayout:ColumnLayout;

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

        unobserve();

        //

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

}
