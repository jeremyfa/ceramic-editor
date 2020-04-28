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

    @observe public var placeholder:String = '';

    @observe public var overlayStyle:Bool = false;

    @observe public var textAlign:TextAlign = LEFT;

    @observe public var disabled:Bool = false;

/// Internal properties

    var layers:LayersLayout;

    var textView:TextView;

    var editText:EditText;

    var placeholderView:TextView;

    public var kind(default, null):TextFieldKind;

    public function new(kind:TextFieldKind = TEXT) {

        super();

        this.kind = kind != null ? kind : TEXT;

        padding(6, 6, 6, 6);

        layers = new LayersLayout();
        add(layers);

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.verticalAlign = CENTER;
        autorun(() -> {
            textView.align = textAlign;
        });
        textView.pointSize = 12;
        textView.maxLineDiff = -1;
        layers.add(textView);

        placeholderView = new TextView();
        placeholderView.viewSize(fill(), auto());
        placeholderView.verticalAlign = CENTER;
        placeholderView.skewX = 10;
        placeholderView.offsetX = 1;
        autorun(() -> {
            placeholderView.align = textAlign;
        });
        placeholderView.pointSize = 12;
        placeholderView.maxLineDiff = -1;
        layers.add(placeholderView);

        editText = new EditText(theme.focusedFieldSelectionColor, theme.lightTextColor);
        editText.container = this;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);

        autorun(updateStyle);
        autorun(updateFromTextValue);
        autorun(updatePlaceholder);

        onDisabledChange(this, (disabled, _) -> {
            trace('disabled: ' + disabled);
            editText.disabled = disabled;
        });

        bindKeyBindings();

    }

/// Public API

    override function focus() {

        super.focus();

        if (!disabled)
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

    function updatePlaceholder() {

        var displayedText = textValue;
        var placeholder = this.placeholder;
        var focused = this.focused;

        unobserve();
        
        placeholderView.content = placeholder != null ? placeholder : '';
        placeholderView.visible = (displayedText == '' && !focused);

        reobserve();

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

        if (editText != null) {
            editText.selectionColor = theme.focusedFieldSelectionColor;
            editText.textCursorColor = theme.lightTextColor;
        }

        if (overlayStyle) {
            color = Color.WHITE;
            alpha = 0.1;
        
            borderSize = 0;
            borderPosition = INSIDE;
            transparent = false;
    
            textView.textColor = theme.fieldTextColor;
            textView.font = theme.mediumFont;

            placeholderView.textColor = theme.fieldPlaceholderColor;
            placeholderView.font = theme.mediumFont;
        }
        else {
            color = theme.darkBackgroundColor;
            alpha = 1;
        
            borderSize = 1;
            borderPosition = INSIDE;
            transparent = false;
    
            textView.textColor = theme.fieldTextColor;
            textView.font = theme.mediumFont;

            placeholderView.textColor = theme.fieldPlaceholderColor;
            placeholderView.font = theme.mediumFont;
    
            if (disabled) {
                borderColor = theme.mediumBorderColor;
                textView.text.alpha = 0.5;
            }
            else {
                textView.text.alpha = 1;
                if (focused) {
                    borderColor = theme.focusedFieldBorderColor;
                }
                else {
                    borderColor = theme.lightBorderColor;
                }
            }
        }

    }

/// Key bindings

    function bindKeyBindings() {

        var keyBindings = new KeyBindings();

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_A)], function() {
            if (focused) {
                var selectText:SelectText = cast textView.text.component('selectText');
                selectText.selectionStart = 0;
                selectText.selectionEnd = textView.text.content.length;
            }
        });

        onDestroy(keyBindings, function(_) {
            keyBindings.destroy();
            keyBindings = null;
        });

    }

}

enum TextFieldKind {

    TEXT;

    NUMERIC;

}
