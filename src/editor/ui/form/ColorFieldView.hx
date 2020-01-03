package editor.ui.form;

class ColorFieldView extends FieldView implements Observable {

    static var RE_HEX_COLOR = ~/^[0-F][0-F][0-F][0-F][0-F][0-F]$/;

    static var RE_HEX_COLOR_ANY_LENGTH = ~/^[0-F]+$/;

/// Hooks

    public dynamic function setValue(field:ColorFieldView, value:Color):Void {

        // Default implementation does nothing

    } //setValue

/// Public properties

    @observe public var value:Color = Color.WHITE;

/// Internal properties

    var container:RowLayout;

    var textView:TextView;

    var textPrefixView:TextView;

    var editText:EditText;

    var colorPreview:View;

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

        textPrefixView = new TextView();
        textPrefixView.viewSize(auto(), auto());
        textPrefixView.align = LEFT;
        textPrefixView.pointSize = 12;
        textPrefixView.content = '#';
        textPrefixView.padding(0, 3, 0, 2);
        textPrefixView.text.component(new ItalicText());
        container.add(textPrefixView);

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
        
        colorPreview = new View();
        colorPreview.viewSize(15, 15);
        colorPreview.transparent = false;
        container.add(colorPreview);

        autorun(updateStyle);
        autorun(updateFromValue);

        container.onLayout(this, layoutContainer);

    } //new

/// Layout

    override function focus() {

        super.focus();

        if (!focused) {
            editText.focus();
        }
        
    } //focus

    override function didLostFocus() {

        if (textView.content == '') {
            var emptyValue:Color = Color.WHITE;
            setValue(this, emptyValue);
            updateFromValue();
        }
        else if (!RE_HEX_COLOR.match(textView.content)) {
            updateFromValue();
        }

    } //didLostFocus

/// Layout

    override function layout() {

        super.layout();

    } //layout

    function layoutContainer() {

        //

    } //layoutContainer

/// Internal

    function updateFromEditText(text:String) {

        if (text == '')
            return;

        if (text.startsWith('#'))
            text = text.substr(1);
        if (text.startsWith('0x'))
            text = text.substr(2);
        if (text.length == 8)
            text = text.substr(0, 6);

        if (RE_HEX_COLOR.match(text)) {
            setValue(this, Sanitize.stringToColor('0x' + text));
        }

        if (!RE_HEX_COLOR_ANY_LENGTH.match(text) || text.length > 6) {
            updateFromValue();
        }

    } //updateFromEditText

    function handleStopEditText() {

        //

    } //handleStopEditText

    function updateFromValue() {

        var value = this.value;

        unobserve();

        var displayedText = value.toHexString(false);
        editText.updateText(displayedText);
        textView.content = displayedText;

        colorPreview.color = value;
        colorPreview.layoutDirty = true;

        reobserve();

    } //updateFromValue

    function updateStyle() {
        
        container.color = theme.darkBackgroundColor;

        textView.textColor = theme.fieldTextColor;
        textView.font = theme.mediumFont10;

        textPrefixView.textColor = theme.darkTextColor;
        textPrefixView.font = theme.mediumFont10;

        if (focused) {
            container.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            container.borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //SliderFieldView
