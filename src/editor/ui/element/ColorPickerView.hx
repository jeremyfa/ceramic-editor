package editor.ui.element;

class ColorPickerView extends LayersLayout implements Observable {

/// Public properties

    @observe public var colorValue:Color = Color.WHITE;

/// Internal

    var gradientView:ColorPickerGradientView;

    var spectrumView:ColorPickerSpectrumView;

    var rgbRedField:TextFieldView;

    var rgbGreenField:TextFieldView;

    var rgbBlueField:TextFieldView;

/// Lifecycle

    public function new() {

        super();

        var pad = 6;
        var fieldAdvance = 25;

        padding(6, 6, 6, 6);
        transparent = false;

        autorun(updateStyle);

        onPointerDown(this, _ -> {});

        viewSize(250, 200);

        gradientView = new ColorPickerGradientView();
        gradientView.viewSize(140, 140);
        gradientView.onUpdateColorFromPointer(this, () -> {
            this.colorValue = gradientView.colorValue;
        });
        add(gradientView);

        spectrumView = new ColorPickerSpectrumView();
        spectrumView.viewSize(12, 140);
        spectrumView.offset(gradientView.viewWidth + pad, 0);
        add(spectrumView);

        rgbRedField = create256Field(setColorFromRgbFields);
        rgbRedField.offset(
            gradientView.viewWidth + spectrumView.viewWidth + pad * 2,
            0
        );
        add(rgbRedField);

        rgbGreenField = create256Field(setColorFromRgbFields);
        rgbGreenField.offset(
            rgbRedField.offsetX,
            rgbRedField.offsetY + fieldAdvance + pad
        );
        add(rgbGreenField);

        rgbBlueField = create256Field(setColorFromRgbFields);
        rgbBlueField.offset(
            rgbGreenField.offsetX,
            rgbGreenField.offsetY + fieldAdvance + pad
        );
        add(rgbBlueField);

        onColorValueChange(this, function(_, _) {
            updateFromColorValue();
        });

        updateFromColorValue();

    } //new

/// Layout

    override function layout() {

        super.layout();

    } //layout

/// Internal

    function updateFromColorValue() {

        var colorValue = this.colorValue;

        unobserve();

        // Update RGB fields
        rgbRedField.setTextValue(rgbRedField, '' + colorValue.red);
        rgbGreenField.setTextValue(rgbGreenField, '' + colorValue.green);
        rgbBlueField.setTextValue(rgbBlueField, '' + colorValue.blue);

        // Update gradient
        gradientView.colorValue = colorValue;

        reobserve();

    } //updateFromColorValue

    function create256Field(?applyValue:Void->Void) {

        var fieldView = new TextFieldView(NUMERIC);
        fieldView.inBubble = true;
        fieldView.textValue = '0';
        fieldView.viewWidth = 34;

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

    function setColorFromRgbFields() {

        this.colorValue = Color.fromRGB(
            Std.parseInt(rgbRedField.textValue),
            Std.parseInt(rgbGreenField.textValue),
            Std.parseInt(rgbBlueField.textValue)
        );

    } //setColorFromRgbFields

    function updateStyle() {

        color = theme.bubbleBackgroundColor;
        alpha = theme.bubbleBackgroundAlpha;

    } //updateStyle

} //ColorPickerView
