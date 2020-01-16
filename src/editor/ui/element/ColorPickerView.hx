package editor.ui.element;

class ColorPickerView extends LayersLayout implements Observable {

    final FIELD_ROW_WIDTH = 34.0;

    final FIELD_ADVANCE = 26.0;

    final FIELD_Y_GAP = 1.0;

    final PADDING = 6.0;

    static var _tuple:Array<Float> = [0, 0, 0];

/// Public properties

    @observe public var colorValue(default, null):Color = Color.WHITE;

/// Internal

    var hsluv(get, set):Bool;
    inline function get_hsluv():Bool return model.project.colorPickerHsluv;
    inline function set_hsluv(hsluv:Bool) return model.project.colorPickerHsluv = hsluv;

    var hsbGradientView:ColorPickerHSBGradientView;

    var hsbSpectrumView:ColorPickerHSBSpectrumView;

    var hsluvGradientView:ColorPickerHSLuvGradientView;

    var hsluvSpectrumView:ColorPickerHSLuvSpectrumView;

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

    var updatingColor:Int = 0;

    var hslFieldsLocked:Int = 0;

/// Lifecycle

    public function new() {

        super();

        padding(PADDING);
        transparent = false;

        onPointerDown(this, _ -> {});

        viewSize(250, 200);

        hsbGradientView = new ColorPickerHSBGradientView();
        hsbGradientView.viewSize(140, 140);
        hsbGradientView.onUpdateColorFromPointer(this, () -> {
            setColorFromHSB(
                hsbGradientView.hue,
                hsbGradientView.getSaturationFromPointer(),
                hsbGradientView.getBrightnessFromPointer()
            );
        });
        add(hsbGradientView);

        hsluvGradientView = new ColorPickerHSLuvGradientView();
        hsluvGradientView.viewSize(140, 140);
        hsluvGradientView.onUpdateColorFromPointer(this, () -> {
            setColorFromHSLuv(
                hsluvGradientView.getHueFromPointer(),
                hsluvGradientView.getSaturationFromPointer(),
                hsluvGradientView.lightness
            );
        });
        add(hsluvGradientView);

        hsbSpectrumView = new ColorPickerHSBSpectrumView();
        hsbSpectrumView.viewSize(12, 140);
        hsbSpectrumView.offset(hsbGradientView.viewWidth + PADDING, 0);
        hsbSpectrumView.onUpdateHueFromPointer(this, () -> {
            hsbGradientView.savePointerPosition();
            hsbGradientView.updateTintColor(hsbSpectrumView.hue);
            setColorFromHSB(
                hsbGradientView.hue,
                hsbGradientView.getSaturationFromPointer(),
                hsbGradientView.getBrightnessFromPointer()
            );
            hsbGradientView.restorePointerPosition();
        });
        add(hsbSpectrumView);

        hsluvSpectrumView = new ColorPickerHSLuvSpectrumView();
        hsluvSpectrumView.viewSize(12, 140);
        hsluvSpectrumView.offset(hsluvGradientView.viewWidth + PADDING, 0);
        hsluvSpectrumView.onUpdateHueFromPointer(this, () -> {
            hsluvGradientView.savePointerPosition();
            hsluvGradientView.updateGradientColors(hsluvSpectrumView.lightness);
            setColorFromHSLuv(
                hsluvGradientView.getHueFromPointer(),
                hsluvGradientView.getSaturationFromPointer(),
                hsluvGradientView.lightness
            );
            hsluvGradientView.restorePointerPosition();
        });
        add(hsluvSpectrumView);

        var offsetX = hsbGradientView.viewWidth + hsbSpectrumView.viewWidth + PADDING * 2;
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
        hslLabel.offset(
            offsetX,
            0
        );
        hslLabel.viewSize(FIELD_ROW_WIDTH, 12);
        add(hslLabel);

        hslLabel.autorun(() -> {
            var hsluv = this.hsluv;
            unobserve();

            if (hsluv) {
                hslLabel.content = 'HSLuv';
                hsbGradientView.active = false;
                hsbSpectrumView.active = false;
                hsluvGradientView.active = true;
                hsluvSpectrumView.active = true;
            }
            else {
                hslLabel.content = 'HSL';
                hsbGradientView.active = true;
                hsbSpectrumView.active = true;
                hsluvGradientView.active = false;
                hsluvSpectrumView.active = false;
            }
        });

        hslLabel.onPointerDown(this, _ -> {
            this.hsluv = !this.hsluv;
            setColorFromRGB(colorValue.red, colorValue.green, colorValue.blue);
        });

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

        updatingColor++;

        colorValue = Color.fromRGB(r, g, b);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue);

        app.onceUpdate(this, _ -> {
            updatingColor--;
        });

    } //setColorFromRGB

    public function setColorFromHSL(h:Float, s:Float, l:Float) {

        updatingColor++;

        colorValue = Color.fromHSL(h, s, l);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, h, s, l);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, h, s, l);

        app.onceUpdate(this, _ -> {
            updatingColor--;
        });

    } //setColorFromHSL

    public function setColorFromHSB(h:Float, s:Float, b:Float) {

        updatingColor++;

        colorValue = Color.fromHSB(h, s, b);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, h);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, h);

        app.onceUpdate(this, _ -> {
            updatingColor--;
        });

    } //setColorFromHSB

    public function setColorFromHSLuv(h:Float, s:Float, l:Float) {

        log.debug('setColorFromHSLuv($h, $s, $l)');

        updatingColor++;

        colorValue = Color.fromHSLuv(h, s, l);

        // Update RGB fields
        updateRGBFields(colorValue);

        // Update HSL fields
        updateHSLFields(colorValue, h, s, l);

        // Update gradient & spectrum
        updateGradientAndSpectrum(colorValue, h, s, l);

        app.onceUpdate(this, _ -> {
            updatingColor--;
        });

    } //setColorFromHSLuv

/// Internal

    function updateRGBFields(colorValue:Color) {

        rgbRedField.setTextValue(rgbRedField, '' + colorValue.red);
        rgbGreenField.setTextValue(rgbGreenField, '' + colorValue.green);
        rgbBlueField.setTextValue(rgbBlueField, '' + colorValue.blue);

    } //updateRGBFields

    function updateHSLFields(colorValue:Color, ?hue:Float, ?saturation:Float, ?lightness:Float) {

        if (hslFieldsLocked > 0)
            return;

        if (hsluv) {
            colorValue.getHSLuv(_tuple);
            if (hue == null)
                hue = _tuple[0];
            if (saturation == null)
                saturation = _tuple[1];
            if (lightness == null)
                lightness = _tuple[2];
        }
        else {
            if (hue == null)
                hue = colorValue.hue;
            if (saturation == null)
                saturation = colorValue.saturation;
            if (lightness == null)
                lightness = colorValue.lightness;
        }

        hslHueField.setTextValue(hslHueField, '' + Math.round(hue));
        hslSaturationField.setTextValue(hslSaturationField, '' + (Math.round(saturation * 1000) / 10));
        hslLightnessField.setTextValue(hslLightnessField, '' + (Math.round(lightness * 1000) / 10));

    } //updateHSLFields

    function updateGradientAndSpectrum(colorValue:Color, ?hue:Float, ?saturation:Float, ?lightness:Float) {

        if (hsluv) {
            colorValue.getHSLuv(_tuple);
            if (hue == null)
                hue = _tuple[0];
            if (saturation == null)
                saturation = _tuple[1];
            if (lightness == null)
                lightness = _tuple[2];

            // Update gradient
            hsluvGradientView.colorValue = colorValue;
            hsluvGradientView.updateGradientColors(lightness);
            hsbGradientView.colorValue = colorValue;
            hsbGradientView.updateTintColor(colorValue.hue);
    
            // Update spectrum
            hsluvSpectrumView.lightness = lightness;
            hsluvSpectrumView.hue = hue;
            hsbSpectrumView.hue = colorValue.hue;
        }
        else {
            if (hue == null)
                hue = colorValue.hue;
            if (saturation == null)
                saturation = colorValue.saturation;
            if (lightness == null)
                lightness = colorValue.lightness;
            colorValue.getHSLuv(_tuple);
        
            // Update gradient
            hsbGradientView.colorValue = colorValue;
            hsbGradientView.updateTintColor(hue);
            hsluvGradientView.colorValue = colorValue;
            hsluvGradientView.updateGradientColors(_tuple[2]);
    
            // Update spectrum
            hsbSpectrumView.hue = hue;
            hsluvSpectrumView.hue = _tuple[0];
            hsluvSpectrumView.lightness = _tuple[2];
        }

    } //updateGradientAndSpectrum

    function setColorFromRGBFields() {

        if (rgbRedField.textValue == rgbRedFieldValue
            && rgbGreenField.textValue == rgbGreenFieldValue
            && rgbBlueField.textValue == rgbBlueFieldValue)
            return;
        
        rgbRedFieldValue = rgbRedField.textValue;
        rgbGreenFieldValue = rgbGreenField.textValue;
        rgbBlueFieldValue = rgbBlueField.textValue;

        if (updatingColor > 0)
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

        if (updatingColor > 0)
            return;

        hslFieldsLocked++;

        var hue = Std.parseFloat(hslHueField.textValue);
        var saturation = Std.parseFloat(hslSaturationField.textValue) * 0.01;

        if (hsluv) {
            setColorFromHSLuv(
                hue,
                saturation,
                hsluvGradientView.lightness
            );
        }
        else {
            hsbGradientView.savePointerPosition();
            hsbGradientView.updateTintColor(hue);
            setColorFromHSB(
                hsbGradientView.hue,
                hsbGradientView.getSaturationFromPointer(),
                hsbGradientView.getBrightnessFromPointer()
            );
            hsbGradientView.restorePointerPosition();
        }

        app.onceUpdate(this, _ -> {
            hslFieldsLocked--;
        });

    } //setColorFromHSLFieldHue

    function setColorFromHSLFieldSaturation() {

        if (hslSaturationField.textValue == hslSaturationFieldValue)
            return;

        hslSaturationFieldValue = hslSaturationField.textValue;

        if (updatingColor > 0)
            return;

        hslFieldsLocked++;

        var hue = Std.parseFloat(hslHueField.textValue);
        var saturation = Std.parseFloat(hslSaturationField.textValue) * 0.01;
        var lightness = Std.parseFloat(hslLightnessField.textValue) * 0.01;

        if (hsluv) {
            setColorFromHSLuv(
                hue,
                saturation,
                hsluvGradientView.lightness
            );
        }
        else {
            setColorFromHSL(
                hsbGradientView.hue,
                saturation,
                lightness
            );
        }

        app.onceUpdate(this, _ -> {
            hslFieldsLocked--;
        });

    } //setColorFromHSLFieldSaturation

    function setColorFromHSLFieldLightness() {

        if (hslLightnessField.textValue == hslLightnessFieldValue)
            return;

        hslLightnessFieldValue = hslLightnessField.textValue;

        if (updatingColor > 0)
            return;

        hslFieldsLocked++;

        var saturation = Std.parseFloat(hslSaturationField.textValue) * 0.01;
        var lightness = Std.parseFloat(hslLightnessField.textValue) * 0.01;

        if (hsluv) {
            hsluvGradientView.savePointerPosition();
            hsluvGradientView.updateGradientColors(lightness);
            setColorFromHSLuv(
                hsluvGradientView.getHueFromPointer(),
                hsluvGradientView.getSaturationFromPointer(),
                hsluvGradientView.lightness
            );
            hsluvGradientView.restorePointerPosition();
        }
        else {
            setColorFromHSL(
                hsbGradientView.hue,
                saturation,
                lightness
            );
        }

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

        hslLabel.textColor = theme.lightTextColor;
        hslLabel.font = theme.mediumFont10;

    } //updateStyle

} //ColorPickerView
