package editor.ui.element;

class HorizontalLayout extends LinearLayout {

/// Lifecycle

    public function new() {

        super();

        direction = HORIZONTAL;
        itemSpacing = 4;
        transparent = true;

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

    } //updateStyle

} //HorizontalLayout
