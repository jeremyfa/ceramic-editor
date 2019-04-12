package editor.ui.element;

class TabView extends TextView implements Observable {

/// Public properties

    @observe public var name:String = null;

    @observe public var index:Int = -1;

    @observe public var selected:Bool = false;

/// Lifecycle

    public function new() {

        super();

        borderPosition = OUTSIDE;
        transparent = false;
        pointSize = 12;
        padding(5, 10);

        autorun(updateStyle);
        autorun(updateText);

    } //new

/// Internal

    function updateText() {

        var name = this.name;
        content = name != null ? name : '';

    } //updateText

    function updateStyle() {

        if (selected) {
            borderColor = theme.darkBorderColor;
            color = theme.lightBackgroundColor;
            textColor = theme.textColor;
        } else {
            borderColor = theme.darkBorderColor;
            color = theme.darkBackgroundColor;
            textColor = theme.darkTextColor;
        }

        borderLeftSize = index == 0 ? 0 : 1;
        borderTopSize = 1;
        borderRightSize = 1;
        font = theme.boldFont;

    } //updateStyle

} //TabView
