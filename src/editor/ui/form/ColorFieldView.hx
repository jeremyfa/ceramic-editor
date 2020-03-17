package editor.ui.form;

class ColorFieldView extends FieldView implements Observable {

    static var _point = new Point();

    static var RE_HEX_COLOR = ~/^[0-F][0-F][0-F][0-F][0-F][0-F]$/;

    static var RE_HEX_COLOR_ANY_LENGTH = ~/^[0-F]+$/;

/// Hooks

    public dynamic function setValue(field:ColorFieldView, value:Color):Void {

        // Default implementation does nothing

    }

/// Public properties

    @observe public var value:Color = Color.WHITE;

/// Internal properties

    @observe var pickerVisible:Bool = false;

    var container:RowLayout;

    var textView:TextView;

    var textPrefixView:TextView;

    var editText:EditText;

    var colorPreview:View;

    var pickerContainer:View;

    var pickerView:ColorPickerView;

    var bubbleTriangle:Triangle;

    var updatingFromPicker:Int = 0;

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

        pickerContainer = new View();
        pickerContainer.transparent = true;
        pickerContainer.viewSize(0, 0);
        pickerContainer.active = false;
        pickerContainer.depth = 10;
        editor.view.add(pickerContainer);
        
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
        autorun(updatePickerContainer);

        container.onLayout(this, layoutContainer);
        pickerContainer.onLayout(this, layoutPickerContainer);

        colorPreview.onPointerDown(this, _ -> togglePickerVisible());

        app.onUpdate(this, _ -> updatePickerVisibility());
        app.onPostUpdate(this, _ -> updatePickerPosition());

        // If the field is put inside a scrolling layout right after being initialized,
        // check its scroll transform to update position instantly (without loosing a frame)
        app.onceUpdate(this, function(_) {
            var scrollingLayout = getScrollingLayout();
            if (scrollingLayout != null) {
                scrollingLayout.scroller.scrollTransform.onChange(this, updatePickerPosition);
            }
        });

    }

/// Layout

    override function focus() {

        super.focus();

        if (!focused) {
            editText.focus();
        }
        
    }

    override function didLostFocus() {

        if (textView.content == '') {
            var emptyValue:Color = Color.WHITE;
            setValue(this, emptyValue);
            updateFromValue();
        }
        else if (!RE_HEX_COLOR.match(textView.content)) {
            updateFromValue();
        }

    }

/// Layout

    override function layout() {

        super.layout();

    }

    function layoutContainer() {

        //

    }

    function updatePickerVisibility() {

        if (pickerView == null || !pickerVisible)
            return;

        if (FieldManager.manager.focusedField == this)
            return;

        var parent = screen.focusedVisual;
        var keepFocus = false;
        while (parent != null) {
            if (parent == pickerView) {
                keepFocus = true;
                break;
            }
            parent = parent.parent;
        }

        if (!keepFocus) {
            pickerVisible = false;
        }

    }

    function updatePickerPosition() {

        if (!pickerContainer.active)
            return;
        
        colorPreview.visualToScreen(
            colorPreview.width * 0.5,
            colorPreview.height * 0.5,
            _point
        );

        editor.view.screenToVisual(_point.x, _point.y, _point);
        
        var x = _point.x;
        var y = _point.y;

        if (x != pickerContainer.x || y != pickerContainer.y)
            pickerContainer.layoutDirty = true;
    
        pickerContainer.pos(x, y);

    }

    function layoutPickerContainer() {

        if (pickerView != null) {

            var editorMargin = 40;
            var previewMargin = 12;

            pickerView.autoComputeSizeIfNeeded(true);

            pickerView.visualToScreen(pickerView.width, pickerView.height, _point);
            editor.view.screenToVisual(_point.x, _point.y, _point);

            pickerView.x = Math.min(
                editor.view.width - pickerView.width - editorMargin - pickerContainer.x,
                colorPreview.width * 0.5
            );

            var availableHeightAfter = editor.view.height - pickerContainer.y - colorPreview.height * 0.5 - editorMargin - previewMargin;

            bubbleTriangle.size(14, 7);

            if (pickerView.height <= availableHeightAfter) {
                pickerView.y = colorPreview.height * 0.5 + previewMargin;
                bubbleTriangle.pos(0, pickerView.y);
            }
            else {
                pickerView.y = -pickerView.height - colorPreview.height * 0.5 - previewMargin;
                bubbleTriangle.pos(0, 0);
            }
        }

    }

/// Internal

    override function destroy() {

        super.destroy();

        if (pickerContainer != null) {
            pickerContainer.destroy();
            pickerContainer = null;
        }

    }

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

    }

    function handleStopEditText() {

        //

    }

    function updateFromValue() {

        var value = this.value;

        unobserve();

        var displayedText = value.toHexString(false);
        editText.updateText(displayedText);
        textView.content = displayedText;

        colorPreview.color = value;
        colorPreview.layoutDirty = true;

        reobserve();

    }

    function updateStyle() {
        
        container.color = theme.darkBackgroundColor;

        textView.textColor = theme.fieldTextColor;
        textView.font = theme.mediumFont10;

        textPrefixView.textColor = theme.darkTextColor;
        textPrefixView.font = theme.mediumFont10;

        if (focused || pickerVisible) {
            container.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            container.borderColor = theme.lightBorderColor;
        }

    }

/// Picker

    function togglePickerVisible() {

        pickerVisible = !pickerVisible;

    }

    function updatePickerContainer() {

        var pickerVisible = this.pickerVisible;
        var value = this.value;

        unobserve();

        if (pickerVisible) {

            if (pickerView == null) {
                pickerView = new ColorPickerView();
                pickerView.depth = 10;
                pickerView.onColorValueChange(pickerView, (color, _) -> {
                    updatingFromPicker++;
                    this.setValue(this, color);
                    app.onceUpdate(this, _ -> {
                        updatingFromPicker--;
                    });
                });
                pickerContainer.add(pickerView);
    
                bubbleTriangle = new Triangle();
                bubbleTriangle.anchor(0.5, 1);
                bubbleTriangle.autorun(() -> {
                    bubbleTriangle.color = theme.bubbleBackgroundColor;
                    bubbleTriangle.alpha = theme.bubbleBackgroundAlpha;
                });
                pickerContainer.add(bubbleTriangle);
    
                pickerContainer.active = true;
                updatePickerPosition();
            }

            if (updatingFromPicker == 0) {
                pickerView.setColorFromRGB(
                    value.red, value.green, value.blue
                );
            }

        }
        else if (!pickerVisible && pickerView != null) {

            pickerView.destroy();
            pickerView = null;

            bubbleTriangle.destroy();
            bubbleTriangle = null;

            pickerContainer.active = false;
        }

        reobserve();

    }

}
