package editor.ui.element;

class VerticalLayout extends LinearLayout {

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        itemSpacing = 4;
        transparent = true;

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

    } //updateStyle

} //VerticalLayout