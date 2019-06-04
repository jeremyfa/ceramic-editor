package editor.ui.form;

class FormLayout extends LinearLayout {

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        itemSpacing = 4;
        transparent = false;

        padding(10, 10);

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

        color = theme.mediumBackgroundColor;

    } //updateStyle

} //FormLayout
