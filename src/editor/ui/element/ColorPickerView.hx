package editor.ui.element;

using editor.components.VisualTransition;

class ColorPickerView extends LayersLayout implements Observable {

    static final FIELD_ROW_WIDTH = 41.0;

    static final FIELD_ADVANCE = 26.0;

    static final BUTTON_ADVANCE = 24.0;

    static final FIELD_Y_GAP = 1.0;

    static final PADDING = 6.0;

    static final GRADIENT_SIZE = 158.0;

    static final SPECTRUM_WIDTH = 12.0;

    static final PALETTE_COLOR_SIZE = ColorPickerPaletteColorView.PALETTE_COLOR_SIZE;

    static final PALETTE_COLOR_GAP = 2.0;

    static var _tuple:Array<Float> = [0, 0, 0];

/// Public properties

    @observe public var colorValue(default, null):Color = Color.WHITE;

/// Internal

    @observe var paletteHeight:Float = 0;

    var hsluv(get, set):Bool;
    inline function get_hsluv():Bool return model.project.colorPickerHsluv;
    inline function set_hsluv(hsluv:Bool) return model.project.colorPickerHsluv = hsluv;

    var paletteColors(get, set):ImmutableArray<Color>;
    inline function get_paletteColors():ImmutableArray<Color> return model.project.paletteColors;
    inline function set_paletteColors(paletteColors:ImmutableArray<Color>) return model.project.paletteColors = paletteColors;

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

    var paletteAddButton:Button;

    var paletteEditButton:Button;

    var paletteColorPreviews:Array<ColorPickerPaletteColorView> = [];

/// Lifecycle

    public function new() {

        super();

        padding(PADDING);
        transparent = false;

        onPointerDown(this, _ -> {});

        component(new FieldsTabFocus());

        hsbGradientView = new ColorPickerHSBGradientView();
        hsbGradientView.viewSize(GRADIENT_SIZE, GRADIENT_SIZE);
        hsbGradientView.onUpdateColorFromPointer(this, () -> {
            setColorFromHSB(
                hsbGradientView.hue,
                hsbGradientView.getSaturationFromPointer(),
                hsbGradientView.getBrightnessFromPointer()
            );
        });
        add(hsbGradientView);

        hsluvGradientView = new ColorPickerHSLuvGradientView();
        hsluvGradientView.viewSize(GRADIENT_SIZE, GRADIENT_SIZE);
        hsluvGradientView.onUpdateColorFromPointer(this, () -> {
            setColorFromHSLuv(
                hsluvGradientView.getHueFromPointer(),
                hsluvGradientView.getSaturationFromPointer(),
                hsluvGradientView.lightness
            );
        });
        add(hsluvGradientView);

        hsbSpectrumView = new ColorPickerHSBSpectrumView();
        hsbSpectrumView.viewSize(SPECTRUM_WIDTH, GRADIENT_SIZE);
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
        hsluvSpectrumView.viewSize(SPECTRUM_WIDTH, GRADIENT_SIZE);
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
        var offsetY = initHSLFields(offsetX);

        offsetX = hsbGradientView.viewWidth + hsbSpectrumView.viewWidth + PADDING * 2;
        initPaletteUI(offsetX, offsetY);

        autorun(updateStyle);
        autorun(updateColorPreviews);
        autorun(updateSize);

    } //new

    function getColorPickerWidth() {

        return GRADIENT_SIZE + FIELD_ROW_WIDTH * 2 + SPECTRUM_WIDTH + PADDING * 5;

    } //getAvailableWidth

    function updateSize() {

        var w = getColorPickerWidth();
        var h = GRADIENT_SIZE + PADDING * 2;

        var paletteHeight = this.paletteHeight;

        unobserve();

        if (paletteHeight > 0) {
            h += PADDING + paletteHeight;
        }

        viewSize(
            w,
            h
        );

        reobserve();

    } //updateSize

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

        return rgbBlueField.offsetY + FIELD_ADVANCE + PADDING;

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

        return hslLightnessField.offsetY + FIELD_ADVANCE + PADDING;

    } //initHSLFields

    function initPaletteUI(offsetX:Float, offsetY:Float) {

        paletteAddButton = new Button();
        paletteAddButton.content = 'Save color';
        paletteAddButton.inBubble = true;
        paletteAddButton.viewWidth = FIELD_ROW_WIDTH * 2 + PADDING;
        paletteAddButton.offset(offsetX, offsetY);
        paletteAddButton.onClick(this, saveColor);
        add(paletteAddButton);

        offsetY += BUTTON_ADVANCE + PADDING;

        paletteEditButton = new Button();
        paletteEditButton.content = 'Edit palette';
        paletteEditButton.inBubble = true;
        paletteEditButton.viewWidth = FIELD_ROW_WIDTH * 2 + PADDING;
        paletteEditButton.offset(offsetX, offsetY);
        add(paletteEditButton);


    } //initPaletteUI

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
        fieldView.textAlign = CENTER;
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

    function saveColor() {

        model.project.addPaletteColor(colorValue, false);

    } //saveColor

    function updateColorPreviews() {

        var paletteColors = this.paletteColors;

        unobserve();

        while (paletteColorPreviews.length > paletteColors.length) {
            var toRemove = paletteColorPreviews.pop();
            toRemove.destroy();
        }

        while (paletteColorPreviews.length < paletteColors.length) {
            var toAdd = createColorPreview();
            add(toAdd);
            paletteColorPreviews.push(toAdd);
        }

        if (paletteColors.length > 0) {

            var w = getColorPickerWidth();
            var availableWidth = w - PADDING * 2;
    
            var x = -(PALETTE_COLOR_SIZE + PALETTE_COLOR_GAP);
            var y = PADDING + GRADIENT_SIZE;
    
            for (i in 0...paletteColors.length) {
                x += PALETTE_COLOR_SIZE + PALETTE_COLOR_GAP;
                if (x + PALETTE_COLOR_SIZE > availableWidth) {
                    x = 0;
                    y += PALETTE_COLOR_SIZE + PALETTE_COLOR_GAP;
                }
    
                var colorPreview = paletteColorPreviews[i];
                colorPreview.colorValue = paletteColors[i];
                colorPreview.offset(x, y);
            }
    
            this.paletteHeight = y + PALETTE_COLOR_SIZE - GRADIENT_SIZE - PADDING;
        }
        else {
            this.paletteHeight = 0;
        }

        reobserve();

    } //updateColorPreviews

    function createColorPreview():ColorPickerPaletteColorView {

        var colorPreview = new ColorPickerPaletteColorView();

        colorPreview.onClick(this, handlePaletteColorClick);
        //colorPreview.onLongPress(this, handlePaletteColorLongPress);

        return colorPreview;

    } //createColorPreview

    function handlePaletteColorClick(colorPreview:ColorPickerPaletteColorView) {

        var colorValue = colorPreview.colorValue;

        setColorFromRGB(
            colorValue.red,
            colorValue.green,
            colorValue.blue
        );

    } //handlePaletteColorClick

    // function handlePaletteColorLongPress(colorPreview:ColorPickerPaletteColorView, info:TouchInfo) {

    //     log.debug('long press ' + colorPreview.colorValue);

    //     colorPreview.drag(info.x, info.y);

    // } //handlePaletteColorLongPress

} //ColorPickerView
