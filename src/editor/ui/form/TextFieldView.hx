package editor.ui.form;

using StringTools;
using unifill.Unifill;

class TextFieldView extends FieldView implements Observable {

/// Hooks

    public dynamic function setTextValue(field:TextFieldView, textValue:String):Void {

        this.textValue = textValue;
        setValue(field, textValue);

    }

    public dynamic function setValue(field:TextFieldView, value:Dynamic):Void {

        // Default implementation does nothing

    }

    public dynamic function setEmptyValue(field:TextFieldView):Void {

        // Default implementation does nothing

    }

/// Overrides

    override function didLostFocus() {

        if (textValue == '' || (kind == NUMERIC && textValue == '-')) {
            setEmptyValue(this);
        }

    }

/// Public properties

    public var multiline(default,set):Bool = false;
    function set_multiline(multiline:Bool):Bool {
        this.multiline = multiline;
        editText.multiline = multiline;
        return multiline;
    }

    @observe public var textValue:String = '';

    @observe public var inBubble:Bool = false;

    @observe public var textAlign:TextAlign = LEFT;

/// Internal properties

    var textView:TextView;

    var editText:EditText;

    public var kind(default, null):TextFieldKind;

    public function new(kind:TextFieldKind = TEXT) {

        super();

        this.kind = kind != null ? kind : TEXT;

        padding(6, 6, 6, 6);

        textView = new TextView();
        textView.viewSize(fill(), auto());
        autorun(() -> {
            textView.align = textAlign;
        });
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

    }

/// Public API

    override function focus() {

        super.focus();

        editText.focus();
        
    }

/// Layout

    override function layout() {

        super.layout();
        
    }

/// Internal

    function updateFromTextValue() {

        var displayedText = textValue;
        editText.updateText(displayedText);

        textView.content = displayedText;

    }

    function updateFromEditText(text:String) {

        setTextValue(this, text);

    }

    function handleStopEditText() {

        // Release focus when stopping edition
        if (focused) {
            screen.focusedVisual = null;
        }

    }

    function updateStyle() {

        if (inBubble) {
            color = Color.WHITE;
            alpha = 0.1;
        
            borderSize = 0;
            borderPosition = INSIDE;
            transparent = false;
    
            textView.textColor = theme.fieldTextColor;
            textView.font = theme.mediumFont10;
        }
        else {
            color = theme.darkBackgroundColor;
            alpha = 1;
        
            borderSize = 1;
            borderPosition = INSIDE;
            transparent = false;
    
            textView.textColor = theme.fieldTextColor;
            textView.font = theme.mediumFont10;
    
            if (focused) {
                borderColor = theme.focusedFieldBorderColor;
            }
            else {
                borderColor = theme.lightBorderColor;
            }
        }

    }

}

enum TextFieldKind {

    TEXT;

    NUMERIC;

}
