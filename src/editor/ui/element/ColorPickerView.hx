package editor.ui.element;

class ColorPickerView extends LayersLayout implements Observable {

    final FIELD_ROW_WIDTH = 34.0;

    final FIELD_ADVANCE = 25.0;

    final PADDING = 6.0;

/// Public properties

    @observe public var colorValue(default, null):Color = Color.WHITE;

/// Internal

    var gradientView:ColorPickerGradientView;

    var spectrumView:ColorPickerSpectrumView;

    var rgbRedField:TextFieldView;

    var rgbGreenField:TextFieldView;

    var rgbBlueField:TextFieldView;

    var rgbLabel:TextView;

    var updatingFromRGB:Int = 0;

    var updatingFromHSL:Int = 0;

    var updatingFromHSB:Int = 0;

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

        rgbRedField = create256Field(setColorFromRGBFields);
        rgbRedField.offset(
            offsetX,
            rgbLabel.offsetY + rgbLabel.viewHeight + PADDING
        );
        add(rgbRedField);

        rgbGreenField = create256Field(setColorFromRGBFields);
        rgbGreenField.offset(
            offsetX,
            rgbRedField.offsetY + FIELD_ADVANCE + PADDING
        );
        add(rgbGreenField);

        rgbBlueField = create256Field(setColorFromRGBFields);
        rgbBlueField.offset(
            offsetX,
            rgbGreenField.offsetY + FIELD_ADVANCE + PADDING
        );
        add(rgbBlueField);

    } //initRGBFields

    function initHSLFields(offsetX:Float) {

        /*
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

        rgbRedField = create256Field(setColorFromRGBFields);
        rgbRedField.offset(
            offsetX,
            rgbLabel.offsetY + rgbLabel.viewHeight + pad
        );
        add(rgbRedField);

        rgbGreenField = create256Field(setColorFromRGBFields);
        rgbGreenField.offset(
            offsetX,
            rgbRedField.offsetY + fieldAdvance + pad
        );
        add(rgbGreenField);

        rgbBlueField = create256Field(setColorFromRGBFields);
        rgbBlueField.offset(
            offsetX,
            rgbGreenField.offsetY + fieldAdvance + pad
        );
        add(rgbBlueField);
        */

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

    function updateGradientAndSpectrum(colorValue:Color, hue:Float) {

        // Update gradient
        gradientView.colorValue = colorValue;
        gradientView.updateTintColor(hue);

        // Update spectrum
        spectrumView.hue = hue;

    } //updateGradientAndSpectrum

    function setColorFromRGBFields() {

        if (updatingFromHSL > 0 || updatingFromHSB > 0 || updatingFromRGB > 0)
            return;

        setColorFromRGB(
            Std.parseInt(rgbRedField.textValue),
            Std.parseInt(rgbGreenField.textValue),
            Std.parseInt(rgbBlueField.textValue)
        );

    } //setColorFromRGBFields

    function create256Field(?applyValue:Void->Void) {

        var fieldView = new TextFieldView(NUMERIC);
        fieldView.inBubble = true;
        fieldView.textValue = '0';
        fieldView.viewWidth = FIELD_ROW_WIDTH;

        var sanitize = SanitizeTextField.setTextValueToInt(0, 255);
        fieldView.setTextValue = function(field, textValue) {
            if (applyValue != null) {
                app.oncePostFlushImmediate(applyValue);
            }
            return sanitize(field, textValue);
        };
        fieldView.setEmptyValue = function(field) {
            var value:Int = 0;
            if (value < 0) {
                value = 0;
            }
            if (value > 255) {
                value = 255;
            }
            fieldView.textValue = '' + value;
            if (applyValue != null) {
                applyValue();
            }
        };

        return fieldView;

    } //create256Field

    function updateStyle() {

        color = theme.bubbleBackgroundColor;
        alpha = theme.bubbleBackgroundAlpha;

        rgbLabel.textColor = theme.lightTextColor;
        rgbLabel.font = theme.mediumFont10;

    } //updateStyle

} //ColorPickerView
