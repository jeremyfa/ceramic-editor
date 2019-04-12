package editor.ui.element;

class CellView extends LinearLayout implements Observable {

/// Public properties

    @observe public var selected:Bool = false;

    @observe public var title:String = null;

    @observe public var subTitle:String = null;

/// Internal

    var titleTextView:TextView;

    var subTitleTextView:TextView;

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        align = CENTER;
        
        titleTextView = new TextView();
        titleTextView.align = LEFT;
        titleTextView.pointSize = 10;
        add(titleTextView);
        
        subTitleTextView = new TextView();
        subTitleTextView.align = LEFT;
        subTitleTextView.pointSize = 9;
        add(subTitleTextView);

        autorun(updateTitle);
        autorun(updateSubTitle);
        autorun(updateStyle);

    } //new

/// Internal

    function updateTitle() {

        var title = this.title;
        if (title != null) {
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
        if (title != null) {
            subTitleTextView.content = subTitle;
            subTitleTextView.active = true;
        }
        else {
            subTitleTextView.content = '';
            subTitleTextView.active = false;
        }

    } //updateSubTitle

    function updateStyle() {

        titleTextView.textColor = theme.textColor;
        titleTextView.font = theme.mediumFont;

        subTitleTextView.textColor = theme.darkTextColor;
        subTitleTextView.font = theme.mediumFont;

    } //updateStyle

} //CellView
