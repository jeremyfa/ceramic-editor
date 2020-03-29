package editor.ui.element;

using StringTools;

class CellView extends LinearLayout implements Observable {

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

    @observe public var itemIndex:Int = -1;

    @observe public var collectionView:CellCollectionView = null;

    @observe public var overlayStyle:Bool = false;

    @observe public var displaysEmptyValue:Bool = false;

/// Internal

    var titleTextView:TextView;

    var subTitleTextView:TextView;

    @observe var hover:Bool = false;

    @observe var appliedHoverItemIndex:Int = -1;

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        align = CENTER;
        padding(0, 8);
        borderBottomSize = 1;
        itemSpacing = 1;
        borderPosition = INSIDE;
        transparent = false;
        
        titleTextView = new TextView();
        titleTextView.align = LEFT;
        titleTextView.pointSize = 12;
        titleTextView.viewSize(fill(), auto());
        add(titleTextView);
        
        subTitleTextView = new TextView();
        subTitleTextView.align = LEFT;
        subTitleTextView.pointSize = 11;
        subTitleTextView.paddingLeft = 1;
        subTitleTextView.viewSize(fill(), auto());
        subTitleTextView.text.component('italicText', new ItalicText());
        add(subTitleTextView);

        autorun(updateTitle);
        autorun(updateSubTitle);
        autorun(updateStyle);

        onPointerOver(this, function(_) hover = true);
        onPointerOut(this, function(_) hover = false);

    }

/// Internal

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

    function updateStyle() {

        if (selected) {
            if (overlayStyle) {
                alpha = 0.125;
                color = Color.WHITE;
                transparent = false;
                borderLeftSize = 1;
                borderRightSize = 1;
                borderLeftColor = theme.lightBorderColor;
                borderRightColor = theme.lightBorderColor;
            }
            else {
                alpha = 1;
                borderLeftColor = theme.selectionBorderColor;
                borderLeftSize = 2;
                borderRightSize = 0;
                color = theme.lightBackgroundColor;
                transparent = false;
            }
        }
        else {
            alpha = 1;
            transparent = overlayStyle;
            if (overlayStyle) {
                borderLeftSize = 1;
                borderRightSize = 1;
                borderLeftColor = theme.lightBorderColor;
                borderRightColor = theme.lightBorderColor;
            }
            else {
                borderLeftSize = 0;
                borderRightSize = 0;
            }

            if (collectionView == null || !collectionView.scrolling) {
                if (hover) {
                    appliedHoverItemIndex = itemIndex;
                    color = theme.lightBackgroundColor;
                } else {
                    appliedHoverItemIndex = -1;
                    color = theme.mediumBackgroundColor;
                }
            }
            else {
                if (appliedHoverItemIndex != -1 && appliedHoverItemIndex == itemIndex) {
                    color = theme.lightBackgroundColor;
                }
                else {
                    color = theme.mediumBackgroundColor;
                }
            }
        }

        titleTextView.textColor = theme.lightTextColor;
        titleTextView.font = theme.mediumFont10;

        subTitleTextView.textColor = theme.darkTextColor;
        subTitleTextView.font = theme.mediumFont10;

        borderBottomColor = theme.mediumBorderColor;

        if (overlayStyle && displaysEmptyValue) {
            titleTextView.text.skewX = 8;
            titleTextView.text.alpha = 0.8;
        }
        else {
            titleTextView.text.skewX = 0;
            titleTextView.text.alpha = 1;
        }

    }

}
