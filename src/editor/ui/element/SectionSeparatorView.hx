package editor.ui.element;

class SectionSeparatorView extends View {

/// Lifecycle

    public function new() {

        super();

        viewSize(fill(), 1);

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

        color = theme.mediumBorderColor;

    } //updateStyle

} //SectionTitleView
