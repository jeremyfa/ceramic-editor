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

    public dynamic function setEmptyValue(field:TextFieldView):Void {

        // Default implementation does nothing

    } //setEmptyValue

/// Overrides

    override function didLostFocus() {

        if (textValue == '' || (kind == NUMERIC && textValue == '-')) {
            setEmptyValue(this);
        }

    } //didLostFocus

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

    public var kind(default, null):TextFieldKind;

    public function new(kind:TextFieldKind = TEXT) {

        super();

        this.kind = kind != null ? kind : TEXT;

        padding(6, 6, 6, 6);
        borderSize = 1;
        borderPosition = INSIDE;
        transparent = false;

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.align = LEFT;
        textView.pointSize = 12;
        textView.maxLineDiff = -1;
        add(textView);

        editText = new EditText();
        editText.container = this;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);

        autorun(updateStyle);
        autorun(updateFromTextValue);

    } //new

/// Public API

    override function focus() {

        super.focus();

        editText.focus();
        
    } //focus

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

        textView.textColor = theme.fieldTextColor;
        textView.font = theme.mediumFont10;

        if (focused) {
            borderColor = theme.focusedFieldBorderColor;
        }
        else {
            borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //TextFieldView

enum TextFieldKind {

    TEXT;

    NUMERIC;

} //TextFieldKind
