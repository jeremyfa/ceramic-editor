package editor.ui.element;

class SectionTitleView extends TextView implements Observable {

/// Lifecycle

    public function new() {

        super();

        align = CENTER;
        verticalAlign = CENTER;
        pointSize = 12;
        preRenderedSize = 20;
        borderBottomSize = 1;
        borderPosition = INSIDE;
        padding(5, 0);

        autorun(updateStyle);

    }

/// Internal

    function updateStyle() {

        transparent = false;
        color = theme.lightBackgroundColor;
        borderBottomColor = theme.mediumBorderColor;
        font = theme.boldFont;

    }

}
