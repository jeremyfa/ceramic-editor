package editor.ui.form;

using StringTools;
using unifill.Unifill;

class TextFieldView extends FieldView implements Observable {

/// Hooks

    public dynamic function setTextValue(field:TextFieldView, textValue:String):Void {

        this.textValue = textValue;
        setValue(field, textValue);

    } //setTextValue

    public dynamic function setValue(field:TextFieldView, value:Dynamic):Void {

        // Default implementation does nothing

    } //setValue

/// Public properties

    public var multiline(default,set):Bool = false;
    function set_multiline(multiline:Bool):Bool {
        this.multiline = multiline;
        editText.multiline = multiline;
        return multiline;
    }

    @observe public var textValue:String = '';

/// Internal properties

    var textView:TextView;

    var editText:EditText;

    public function new() {

        super();

        padding(6, 6, 5, 6);
        borderSize = 1;
        borderPosition = INSIDE;
        transparent = false;

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.align = LEFT;
        textView.pointSize = 10;
        textView.text.maxLineDiff = -1;
        add(textView);

        editText = new EditText();
        editText.container = this;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);

        autorun(updateStyle);
        autorun(updateFromTextValue);

    } //new

/// Layout

    override function layout() {

        super.layout();
        
    } //layout

/// Internal

    function updateFromTextValue() {

        var displayedText = textValue;
        editText.updateText(displayedText);

        textView.content = displayedText;

    } //updateFromTextValue

    function updateFromEditText(text:String) {

        setTextValue(this, text);

    } //updateFromEditText

    function handleStopEditText() {

        // Release focus when stopping edition
        if (focused) {
            screen.focusedVisual = null;
        }

    } //handleStopEditText

    function updateStyle() {
        
        color = theme.darkBackgroundColor;

        textView.font = theme.mediumFont10;

        if (focused) {
            borderColor = theme.focusedFieldBorderColor;
        }
        else {
            borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //TextFieldView
