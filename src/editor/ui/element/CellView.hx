package editor.ui.element;

using StringTools;
using unifill.Unifill;

class CellView extends LinearLayout implements Observable {

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

    @observe public var itemIndex:Int = -1;

/// Internal

    var titleTextView:TextView;

    var subTitleTextView:TextView;

    @observe var hover:Bool = false;

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
        titleTextView.pointSize = 10;
        titleTextView.viewSize(fill(), auto());
        add(titleTextView);
        
        subTitleTextView = new TextView();
        subTitleTextView.align = LEFT;
        subTitleTextView.pointSize = 9;
        subTitleTextView.viewSize(fill(), auto());
        subTitleTextView.text.component('italicText', new ItalicText());
        add(subTitleTextView);

        autorun(updateTitle);
        autorun(updateSubTitle);
        autorun(updateStyle);

        onPointerOver(this, function(_) hover = true);
        onPointerOut(this, function(_) hover = false);

    } //new

/// Internal

    function updateTitle() {

        var title = this.title;
        if (title != null) {
            title = title.trim().replace("\n", ' ');
            if (title.uLength() > 20) {
                title = title.uSubstr(0, 20) + '...'; // TODO at textview level
            }
            titleTextView.content = title;
            titleTextView.active = true;
        }
        else {
            titleTextView.content = '';
            titleTextView.active = false;
        }

    } //updateTitle

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

    } //updateSubTitle

    function updateStyle() {

        if (selected) {
            borderLeftColor = theme.selectionBorderColor;
            borderLeftSize = 2;
            color = theme.lightBackgroundColor;
        }
        else {
            borderLeftSize = 0;

            if (hover) {
                color = theme.lightBackgroundColor;
            } else {
                color = theme.mediumBackgroundColor;
            }
        }

        titleTextView.textColor = theme.lightTextColor;
        titleTextView.font = theme.mediumFont;

        subTitleTextView.textColor = theme.darkTextColor;
        subTitleTextView.font = theme.mediumFont;

        borderBottomColor = theme.mediumBorderColor;

    } //updateStyle

} //CellView
