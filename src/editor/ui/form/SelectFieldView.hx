package editor.ui.form;

class SelectFieldView extends FieldView implements Observable {

/// Hooks

    public dynamic function setValue(field:SelectFieldView, value:String):Void {

        // Default implementation does nothing

    }

/// Public properties

    @observe public var value:String = null;

/// Internal properties

    var container:RowLayout;

    var textView:TextView;

    var editText:EditText;

    var bubbleTriangle:Triangle;

    public function new() {

        super();
        transparent = true;

        direction = HORIZONTAL;
        align = LEFT;

        container = new RowLayout();
        container.viewSize(90, auto());
        container.padding(6, 6, 6, 6);
        container.borderSize = 1;
        container.borderPosition = INSIDE;
        container.transparent = false;
        add(container);
        
        var filler = new View();
        filler.transparent = true;
        filler.viewSize(fill(), fill());
        add(filler);

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.align = LEFT;
        textView.pointSize = 12;
        container.add(textView);

        editText = new EditText();
        editText.container = textView;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);

        autorun(updateStyle);
        autorun(updateFromValue);

        container.onLayout(this, layoutContainer);

    }

/// Layout

    override function focus() {

        super.focus();

        if (!focused) {
            editText.focus();
        }
        
    }

    override function didLostFocus() {

        //

    }

/// Layout

    override function layout() {

        super.layout();

    }

    function layoutContainer() {

        //

    }

/// Internal

    override function destroy() {

        super.destroy();

    }

    function updateFromEditText(text:String) {

        // Code completion?

    }

    function handleStopEditText() {

        //

    }

    function updateFromValue() {

        var value = this.value;

        unobserve();

        /*
        var displayedText = value.toHexString(false);
        editText.updateText(displayedText);
        textView.content = displayedText;
        */

        reobserve();

    }

    function updateStyle() {
        
        container.color = theme.darkBackgroundColor;

        textView.textColor = theme.fieldTextColor;
        textView.font = theme.mediumFont10;

        if (focused) {
            container.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            container.borderColor = theme.lightBorderColor;
        }

    }

}
