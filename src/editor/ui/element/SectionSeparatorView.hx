package editor.ui.element;

class SectionSeparatorView extends View {

/// Lifecycle

    public function new() {

        super();

        viewSize(fill(), 0);

        borderTopSize = 1;
        borderPosition = OUTSIDE;

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

        borderColor = theme.mediumBorderColor;

    } //updateStyle

} //SectionTitleView
