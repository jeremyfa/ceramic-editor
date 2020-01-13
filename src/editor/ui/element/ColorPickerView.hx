package editor.ui.element;

class ColorPickerView extends LayersLayout implements Observable {

    final FIELD_ROW_WIDTH = 34.0;

    final FIELD_ADVANCE = 26.0;

    final FIELD_Y_GAP = 1.0;

    final PADDING = 6.0;

/// Public properties

    @observe public var colorValue(default, null):Color = Color.WHITE;

/// Internal

    var gradientView:ColorPickerGradientView;

    var spectrumView:ColorPickerSpectrumView;

    var rgbRedField:TextFieldView;

    var rgbGreenField:TextFieldView;

    var rgbBlueField:TextFieldView;

    var rgbRedFieldValue:String = '255';

    var rgbGreenFieldValue:String = '255';

    var rgbBlueFieldValue:String = '255';

    var rgbLabel:TextView;

    var hslHueField:TextFieldView;

    var hslSaturationField:TextFieldView;

    var hslLightnessField:TextFieldView;

    var hslHueFieldValue:String = '0';

    var hslSaturationFieldValue:String = '0';

    var hslLightnessFieldValue:String = '0';

    var hslLabel:TextView;

    var updatingFromRGB:Int = 0;

    var updatingFromHSL:Int = 0;

    var updatingFromHSB:Int = 0;

    var hslFieldsLocked:Int = 0;

/// Lifecycle

    public function new() {

        super();

        padding(PADDING);
        transparent = false;

        onPointerDown(this, _ -> {});

        viewSize(250, 200);

        gradientView = new ColorPickerGradientView();
        gradientView.viewSize(140, 140);
        gradientView.onUpdateColorFromPointer(this, () -> {
            setColorFromHSB(
                gradientView.hue,
                gradientView.getSaturationFromPointer(),
                gradientView.getBrightnessFromPointer()
            );
        });
        add(gradientView);

        spectrumView = new ColorPickerSpectrumView();
        spectrumView.viewSize(12, 140);
        spectrumView.offset(gradientView.viewWidth + PADDING, 0);
        spectrumView.onUpdateHueFromPointer(this, () -> {
            gradientView.savePointerPosition();
            gradientView.updateTintColor(spectrumView.hue);
            setColorFromHSB(
                gradientView.hue,
                gradientView.getSaturationFromPointer(),
                gradientView.getBrightnessFromPointer()
            );
            gradientView.restorePointerPosition();
        });
        add(spectrumView);

        var offsetX = gradientView.viewWidth + spectrumView.viewWidth + PADDING * 2;
        initRGBFields(offsetX);
        offsetX += FIELD_ROW_WIDTH + PADDING;
        initHSLFields(offsetX);

        autorun(updateStyle);

    } //new

    function initRGBFields(offsetX:Float) {

        rgbLabel = new TextView();
        rgbLabel.align = CENTER;
        rgbLabel.verticalAlign = CENTER;
        rgbLabel.pointSize = 12;
        rgbLabel.content = 'RGB';
        rgbLabel.offset(
            offsetX,
            0
        );
        rgbLabel.viewSize(FIELD_ROW_WIDTH, 12);
        add(rgbLabel);

        rgbRedField = createTextField(setColorFromRGBFields, 0, 256);
        rgbRedField.offset(
            offsetX,
            rgbLabel.offsetY + rgbLabel.viewHeight + PADDING
        );
        add(rgbRedField);

        rgbGreenField = createTextField(setColorFromRGBFields, 0, 256);
        rgbGreenField.offset(
            offsetX,
            rgbRedField.offsetY + FIELD_ADVANCE + FIELD_Y_GAP
        );
        add(rgbGreenField);

        rgbBlueField = createTextField(setColorFromRGBFields, 0, 256);
        rgbBlueField.offset(
            offsetX,
            rgbGreenField.offsetY + FIELD_ADVANCE + FIELD_Y_GAP
        );
        add(rgbBlueField);

    } //initRGBFields

    function initHSLFields(offsetX:Float) {

        hslLabel = new TextView();
        hslLabel.align = CENTER;
        hslLabel.verticalAlign = CENTER;
        hslLabel.pointSize = 12;
        hslLabel.content = 'HSL';
        hslLabel.offset(
            offsetX,
            0
        );
        hslLabel.viewSize(FIELD_ROW_WIDTH, 12);
        add(hslLabel);

        hslHueField = createTextField(setColorFromHSLFieldHue, 0, 360);
        hslHueField.offset(
            offsetX,
            hslLabel.offsetY + hslLabel.viewHeight + PADDING
        );
        add(hslHueField);

        hslSaturationField = createTextField(setColorFromHSLFieldSaturation, 0, 100);
        hslSaturationField.offset(
            offsetX,
            hslHueField.offsetY + FIELD_ADVANCE + FIELD_Y_GAP
        );
        add(hslSaturationField);

        hslLightnessField = createTextField(setColorFromHSLFieldLightness, 0, 100);
        hslLightnessField.offset(
            offsetX,
            hslSaturationField.offsetY + FIELD_ADVANCE + FIELD_Y_GAP
        );
        add(hslLightnessField);

    } //initHSLFields

/// Layout

    override function layout() {

        super.layout();

    } //layout

/// Public API

    public function setColorFromRGB(r:Int, g:Int, b:Int) {

        log.debug('setColorFromRGB($r, $g, $b)');

        updatingFromRGB++;

        colorValue = Color.fromRGB(r, g, b);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, colorValue.hue);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, colorValue.hue);

        app.onceUpdate(this, _ -> {
            updatingFromRGB--;
        });

    } //setColorFromRGB

    public function setColorFromHSL(h:Float, s:Float, l:Float) {

        updatingFromHSL++;

        colorValue = Color.fromHSL(h, s, l);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, h);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, h);

        app.onceUpdate(this, _ -> {
            updatingFromHSL--;
        });

    } //setColorFromRGB

    public function setColorFromHSB(h:Float, s:Float, b:Float) {

        updatingFromHSB++;

        colorValue = Color.fromHSB(h, s, b);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, h);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, h);

        app.onceUpdate(this, _ -> {
            updatingFromHSB--;
        });

    } //setColorFromRGB

/// Internal

    function updateRGBFields(colorValue:Color) {

        rgbRedField.setTextValue(rgbRedField, '' + colorValue.red);
        rgbGreenField.setTextValue(rgbGreenField, '' + colorValue.green);
        rgbBlueField.setTextValue(rgbBlueField, '' + colorValue.blue);

    } //updateRGBFields

    function updateHSLFields(colorValue:Color, hue:Float) {

        if (hslFieldsLocked > 0)
            return;

        hslHueField.setTextValue(hslHueField, '' + Math.round(hue));
        hslSaturationField.setTextValue(hslSaturationField, '' + (Math.round(colorValue.saturation * 1000) / 10));
        hslLightnessField.setTextValue(hslLightnessField, '' + (Math.round(colorValue.lightness * 1000) / 10));

    } //updateHSLFields

    function updateGradientAndSpectrum(colorValue:Color, hue:Float) {

        // Update gradient
        gradientView.colorValue = colorValue;
        gradientView.updateTintColor(hue);

        // Update spectrum
        spectrumView.hue = hue;

    } //updateGradientAndSpectrum

    function setColorFromRGBFields() {

        if (rgbRedField.textValue == rgbRedFieldValue
            && rgbGreenField.textValue == rgbGreenFieldValue
            && rgbBlueField.textValue == rgbBlueFieldValue)
            return;
        
        rgbRedFieldValue = rgbRedField.textValue;
        rgbGreenFieldValue = rgbGreenField.textValue;
        rgbBlueFieldValue = rgbBlueField.textValue;

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        setColorFromRGB(
            Std.parseInt(rgbRedField.textValue),
            Std.parseInt(rgbGreenField.textValue),
            Std.parseInt(rgbBlueField.textValue)
        );

    } //setColorFromRGBFields

    function setColorFromHSLFieldHue() {

        if (hslHueField.textValue == hslHueFieldValue)
            return;

        hslHueFieldValue = hslHueField.textValue;

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        hslFieldsLocked++;

        var hue = Std.parseFloat(hslHueField.textValue);

        gradientView.savePointerPosition();
        gradientView.updateTintColor(hue);
        setColorFromHSB(
            gradientView.hue,
            gradientView.getSaturationFromPointer(),
            gradientView.getBrightnessFromPointer()
        );
        gradientView.restorePointerPosition();

        app.onceUpdate(this, _ -> {
            hslFieldsLocked--;
        });

    } //setColorFromHSLFieldHue

    function setColorFromHSLFieldSaturation() {

        if (hslSaturationField.textValue == hslSaturationFieldValue)
            return;

        hslSaturationFieldValue = hslSaturationField.textValue;

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        hslFieldsLocked++;

        var saturation = Std.parseFloat(hslSaturationField.textValue) * 0.01;
        var lightness = Std.parseFloat(hslLightnessField.textValue) * 0.01;

        setColorFromHSL(
            gradientView.hue,
            saturation,
            lightness
        );

        app.onceUpdate(this, _ -> {
            hslFieldsLocked--;
        });

    } //setColorFromHSLFieldSaturation

    function setColorFromHSLFieldLightness() {

        if (hslLightnessField.textValue == hslLightnessFieldValue)
            return;

        hslLightnessFieldValue = hslLightnessField.textValue;

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        hslFieldsLocked++;

        var saturation = Std.parseFloat(hslSaturationField.textValue) * 0.01;
        var lightness = Std.parseFloat(hslLightnessField.textValue) * 0.01;

        setColorFromHSL(
            gradientView.hue,
            saturation,
            lightness
        );

        app.onceUpdate(this, _ -> {
            hslFieldsLocked--;
        });

    } //setColorFromHSLFieldLightness

    /*
    function setColorFromHSLFields() {

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        setColorFromHSL(
            Std.parseInt(hslHueField.textValue),
            Std.parseFloat(hslSaturationField.textValue) * 0.01,
            Std.parseFloat(hslLightnessField.textValue) * 0.01
        );

    } //setColorFromHSLFields
    */

    function createTextField(?applyValue:Void->Void, minValue:Int = 0, maxValue:Int = 100) {

        var fieldView = new TextFieldView(NUMERIC);
        fieldView.inBubble = true;
        fieldView.textValue = '0';
        fieldView.viewWidth = FIELD_ROW_WIDTH;

        var sanitize = SanitizeTextField.setTextValueToInt(minValue, maxValue);
        fieldView.setTextValue = function(field, textValue) {
            if (applyValue != null) {
                app.oncePostFlushImmediate(applyValue);
            }
            return sanitize(field, textValue);
        };
        fieldView.setEmptyValue = function(field) {
            var value:Int = 0;
            if (value < minValue) {
                value = minValue;
            }
            if (value > maxValue) {
                value = maxValue;
            }
            fieldView.textValue = '' + value;
            if (applyValue != null) {
                applyValue();
            }
        };

        return fieldView;

    } //createTextField

    function updateStyle() {

        color = theme.bubbleBackgroundColor;
        alpha = theme.bubbleBackgroundAlpha;

        rgbLabel.textColor = theme.lightTextColor;
        rgbLabel.font = theme.mediumFont10;

    } //updateStyle

} //ColorPickerView
