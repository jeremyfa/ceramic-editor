package editor.ui.element;

class ColorPickerView extends LayersLayout {

    public function new() {

        super();

        padding(6, 6, 6, 6);
        transparent = false;

        autorun(updateStyle);

        onPointerDown(this, _ -> {});

        viewSize(250, 200);

    } //new

/// Layout

    override function layout() {

        super.layout();

    } //layout

/// Internal

    function updateStyle() {

        color = theme.bubbleBackgroundColor;
        alpha = theme.bubbleBackgroundAlpha;

    } //updateStyle

} //ColorPickerView
