package editor.ui.element;

class SectionTitleView extends TextView implements Observable {

/// Lifecycle

    public function new() {

        super();

        align = CENTER;
        verticalAlign = CENTER;
        pointSize = 10;
        borderBottomSize = 1;
        borderPosition = INSIDE;
        padding(5, 0);

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

        color = theme.lightBackgroundColor;
        borderBottomColor = theme.mediumBorderColor;
        font = theme.boldFont;

    } //updateStyle

} //SectionTitleView
