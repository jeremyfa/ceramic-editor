package editor.ui.form;

class FormLayout extends LinearLayout {

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        itemSpacing = 4;
        transparent = false;

        component(new FieldsTabFocus());

        padding(10, 10);

        autorun(updateStyle);

    }

/// Internal

    function updateStyle() {

        color = theme.mediumBackgroundColor;

    }

}
