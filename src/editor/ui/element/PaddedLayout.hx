package editor.ui.element;

class PaddedLayout extends LinearLayout {

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        itemSpacing = 4;
        transparent = true;

        padding(10, 10);

        autorun(updateStyle);

    }

/// Internal

    function updateStyle() {

    }

}
