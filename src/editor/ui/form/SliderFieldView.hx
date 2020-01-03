package editor.ui.form;

using StringTools;

class SliderFieldView extends FieldView implements Observable {

    static var _point = new Point();

/// Hooks

    public dynamic function setValue(field:SliderFieldView, value:Float):Void {

        // Default implementation does nothing

    } //setValue

/// Public properties

    @observe public var value:Float = 0.0;

    @observe public var minValue:Float = 0.0;

    @observe public var maxValue:Float = 0.0;

    /*
    @compute public function remaining():Float {
        return (maxValue - value);
    }
    */

/// Internal properties

    var textView:TextView;

    var editText:EditText;

    var sliderContainer:View;

    var sliderSquare:View;

    var textRatio:Float = 0.5;

    public function new(minValue:Float = 0, maxValue:Float = 1) {

        super();

        padding(6, 6, 6, 6);
        borderSize = 1;
        borderPosition = INSIDE;
        transparent = false;

        this.minValue = minValue;
        this.maxValue = maxValue;

        direction = HORIZONTAL;
        align = LEFT;

        textView = new TextView();
        textView.viewSize(40, auto());
        textView.align = LEFT;
        textView.pointSize = 12;
        textView.text.maxLineDiff = -1;
        add(textView);

        editText = new EditText();
        editText.container = textView;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);
        
        sliderContainer = new View();
        sliderContainer.viewSize(fill(), 15);
        sliderContainer.transparent = false;
        add(sliderContainer);

        sliderSquare = new View();
        sliderSquare.transparent = false;
        sliderSquare.size(19, 15);
        sliderContainer.add(sliderSquare);

        sliderContainer.onPointerDown(this, handleSliderDown);
        sliderContainer.onLayout(this, layoutSliderContainer);

        autorun(updateStyle);
        autorun(updateFromValue);

    } //new

/// Layout

    override function focus() {

        if (!focused) {
            editText.focus();
        }
        
    } //focus

    override function didLostFocus() {

        if (textView.content == '' || textView.content == '-') {
            var emptyValue:Float = 0;
            if (emptyValue < minValue)
                emptyValue = minValue;
            if (emptyValue > maxValue)
                emptyValue = maxValue;
            setValue(this, emptyValue);
            updateFromValue();
        }
        else if (textView.content.endsWith('.')) {
            updateFromValue();
        }

        screen.offPointerMove(handleSliderMove);
        screen.offPointerUp(handleSliderUp);

    } //didLostFocus

/// Overrides

    override function layout() {

        super.layout();

    } //layout

    function layoutSliderContainer() {

        var minX = sliderContainer.paddingLeft;
        var maxX = (sliderContainer.width - sliderSquare.width - sliderContainer.paddingRight);

        var usedValue = value;
        if (maxValue < 0) {
            usedValue -= maxValue;
        }
        else if (minValue < 0) {
            usedValue -= minValue;
        }

        sliderSquare.pos(
            minX + (maxX - minX) * usedValue / (maxValue - minValue),
            sliderContainer.paddingTop
        );

    } //layoutSliderContainer

/// Internal

    function updateFromEditText(text:String) {

        if (text != '' && text != '-') {
            var textValue = text.replace(',', '.');
            var endsWithDot = textValue.endsWith('.');
            if (!endsWithDot) {
                setValue(this, Sanitize.stringToFloat(textValue));
                updateFromValue();
            }
            else {
                textView.content = textValue;
                editText.updateText(textValue);
            }
        }

    } //updateFromEditText

    function handleStopEditText() {

        //

    } //handleStopEditText

    function updateFromValue() {

        var value = this.value;

        unobserve();

        var displayedText = '' + value;
        editText.updateText(displayedText);
        textView.content = displayedText;

        sliderContainer.layoutDirty = true;

        reobserve();

    } //updateFromValue

    function updateStyle() {
        
        color = theme.darkBackgroundColor;

        textView.font = theme.mediumFont10;

        if (focused) {
            sliderSquare.color = theme.mediumTextColor;
            sliderContainer.color = theme.lightBackgroundColor;
            borderColor = theme.focusedFieldBorderColor;
        }
        else {
            sliderSquare.color = theme.darkTextColor;
            sliderContainer.color = theme.mediumBackgroundColor;
            borderColor = theme.lightBorderColor;
        }

    } //updateStyle

/// Slider

    function handleSliderDown(info:TouchInfo) {

        sliderContainer.screenToVisual(info.x, info.y, _point);
        setValueFromSliderX(_point.x);

        screen.onPointerMove(this, handleSliderMove);
        screen.oncePointerUp(this, handleSliderUp);

    } //handleSliderDown

    function handleSliderMove(info:TouchInfo) {

        sliderContainer.screenToVisual(info.x, info.y, _point);
        setValueFromSliderX(_point.x);

    } //handleSliderMove

    function handleSliderUp(info:TouchInfo) {

        screen.offPointerMove(handleSliderMove);
        screen.offPointerUp(handleSliderUp);

    } //handleSliderUp

    function setValueFromSliderX(sliderX:Float) {

        var leftMargin = sliderContainer.paddingLeft + sliderSquare.width * 0.5;
        var rightMargin = sliderContainer.paddingRight + sliderSquare.width * 0.5;

        var newValue =
            (maxValue - minValue)
            *
            (sliderX - leftMargin)
            /
            (sliderContainer.width - leftMargin - rightMargin);

        if (maxValue < 0) {
            newValue += maxValue;
        }
        else if (minValue < 0) {
            newValue += minValue;
        }

        if (newValue < minValue)
            newValue = minValue;
        if (newValue > maxValue)
            newValue = maxValue;

        setValue(this, newValue);
        updateFromValue();

    } //setValueFromSliderX

} //SliderFieldView