package editor.ui.element;

class TabView extends TextView implements Observable {

/// Public properties

    @observe public var name:String = null;

    @observe public var index:Int = -1;

    @observe public var selected:Bool = false;

/// Internal

    @observe var hover:Bool = false;

/// Lifecycle

    public function new() {

        super();

        borderPosition = OUTSIDE;
        transparent = false;
        pointSize = 14;
        preRenderedSize = 20;
        padding(5, 10);

        autorun(updateStyle);
        autorun(updateText);

        onPointerOver(this, function(_) hover = true);
        onPointerOut(this, function(_) hover = false);

    }

/// Internal

    function updateText() {

        var name = this.name;
        content = name != null ? name : '';

    }

    function updateStyle() {

        if (selected) {
            borderColor = theme.darkBorderColor;
            color = theme.lightBackgroundColor;
            textColor = theme.lightTextColor;
        } else {
            borderColor = theme.darkBorderColor;
            if (hover) {
                color = theme.mediumBackgroundColor;
                textColor = theme.mediumTextColor;
            }
            else {
                color = theme.darkBackgroundColor;
                textColor = theme.darkTextColor;
            }
        }

        borderLeftSize = index == 0 ? 0 : 1;
        borderTopSize = 1;
        borderRightSize = 1;
        font = theme.boldFont;

    }

}
