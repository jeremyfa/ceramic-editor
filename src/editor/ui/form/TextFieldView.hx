package editor.ui.form;

using StringTools;
using unifill.Unifill;

class TextFieldView extends FieldView implements Observable {

/// Hooks

    public dynamic function updateTextValue(textValue:String):Void {

        this.textValue = textValue;

    } //updateTextValue

/// Public properties

    @observe public var textValue:String = '';

/// Internal properties

    var textView:TextView;

    var editText:EditText;

    public function new() {

        super();

        error(' --- NEW TextFieldView ---');

        padding(6, 6);
        borderSize = 1;
        borderPosition = INSIDE;
        transparent = false;

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.align = LEFT;
        textView.pointSize = 9;
        textView.text.maxLineDiff = -1;
        add(textView);

        editText = new EditText();
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);

        autorun(updateStyle);
        autorun(updateFromTextValue);
        autorun(updateFromFocused);

    } //new

/// Layout

    override function layout() {

        super.layout();
        
    } //layout

/// Internal

    function updateFromTextValue() {

        var displayedText = textValue;
        if (displayedText == '' || displayedText.endsWith("\n")) {
            displayedText += ' ';
        }

        textView.content = displayedText;

    } //updateFromTextValue

    function updateFromFocused() {
        
        var focused = this.focused;

        unobserve();

        if (focused) {

            warning('focused: true');

            app.onceImmediate(function() {
                // This way of calling will ensure any previous text input
                // can be stopped before we start this new one
                editText.startInput(textValue, 0, textValue.uLength());
            });

        }
        else {

            warning('focused: false');

            editText.stopInput();
        }

        reobserve();

    } //updateFromFocused

    function updateFromEditText(text:String) {

        updateTextValue(text);

    } //updateFromEditText

    function updateStyle() {
        
        color = theme.darkBackgroundColor;

        if (focused) {
            borderColor = theme.focusedFieldBorderColor;
        }
        else {
            borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //TextFieldView
