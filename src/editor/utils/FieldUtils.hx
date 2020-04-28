package editor.utils;

class FieldUtils {

    public static function createEditableField(editableType:EditableType, field:EditableTypeField, item:EditorEntityData):FieldView {

        var type = field.type;
        var name = field.name;

        var options:Dynamic = field.meta.editable[0];

        if (options.slider != null) {
            return createEditableSliderField(options, item, name);
        }
        else if (type == 'String' || type == 'Float' || type == 'Int') {
            return createEditableTextField(options, item, name, type);
        }
        else if (type == 'Bool') {
            return createEditableBooleanField(options, item, name);
        }
        else if (type == 'ceramic.Color') {
            return createEditableColorField(options, item, name);
        }
        else if (type == 'ceramic.Texture') {
            return createEditableSelectField(options, item, name, () -> {
                return editor.model.images;
            }, 'no texture');
        }
        else if (type == 'ceramic.BitmapFont') {
            return createEditableSelectField(options, item, name, () -> {
                return editor.model.fonts;
            });
        }
        else if (options.options != null) {
            return createEditableSelectField(options, item, name, () -> {
                return options.options;
            });
        }
        else {
            //
        }

        //}

        log.warning('Cannot create field for type: $type');

        return null;

    }

    public static function createEditableSliderField(options:Dynamic, item:EditorEntityData, name:String):SliderFieldView {

        var minValue:Float = 0;
        var maxValue:Float = 1;
        var decimals:Int = -1;
        var hasDecimalsValue = false;
        if (Std.is(options.slider, Array)) {
            minValue = options.slider[0];
            maxValue = options.slider[1];
        }
        else {
            if (options.slider.range != null) {
                minValue = options.slider.range[0];
                maxValue = options.slider.range[1];
            }
            if (options.slider.decimals != null) {
                decimals = options.slider.decimals;
                hasDecimalsValue = true;
            }
        }
        if (!hasDecimalsValue) {
            if (maxValue - minValue >= 100) {
                decimals = 0;
            }
            else {
                decimals = 3;
            }
        }
        var fieldView = new SliderFieldView(minValue, maxValue);
        fieldView.setValue = function(field, value) {
            if (value > maxValue)
                value = maxValue;
            if (value < minValue)
                value = minValue;
            if (decimals == 0) {
                value = Math.round(value);
            }
            else if (decimals >= 1) {
                var power = Math.pow(10, decimals);
                value = Math.round(value * power) / power;
            }
            fieldView.value = value;
            item.props.set(name, value);
        };
        fieldView.autorun(function() {
            var value:Dynamic = item.props.get(name);
            if (value == null) {
                fieldView.value = minValue;
            }
            else {
                fieldView.value = value;
            }
        });

        return fieldView;

    }

    public static function createEditableTextField(options:Dynamic, item:EditorEntityData, name:String, type:String) {

        var fieldView = new TextFieldView(
            (type == 'Float' || type == 'Int')
            ? NUMERIC
            : TEXT
        );
        var minValue:Float = -999999999;
        var maxValue:Float = 999999999;
        if (options.min != null) {
            minValue = options.min;
        }
        if (options.max != null) {
            maxValue = options.max;
        }
        if (type == 'Float') {
            fieldView.setTextValue = SanitizeTextField.setTextValueToFloat(minValue, maxValue);
            fieldView.setEmptyValue = function(field) {
                var value:Float = 0.0;
                if (value < minValue) {
                    value = minValue;
                }
                if (value > maxValue) {
                    value = maxValue;
                }
                item.props.set(name, value);
                fieldView.textValue = '' + value;
            };
        }
        else if (type == 'Int') {
            fieldView.setTextValue = SanitizeTextField.setTextValueToInt(Std.int(minValue), Std.int(maxValue));
            fieldView.setEmptyValue = function(field) {
                var value:Int = 0;
                if (value < minValue) {
                    value = Std.int(minValue);
                }
                if (value > maxValue) {
                    value = Std.int(maxValue);
                }
                item.props.set(name, value);
                fieldView.textValue = '' + value;
            };
        }
        else {
            if (options != null && options.multiline) {
                fieldView.multiline = true;
            }
            if (options != null && options.identifier) {
                fieldView.setTextValue = SanitizeTextField.setTextValueToIdentifier;
            }
        }
        fieldView.setValue = function(field, value) {
            item.props.set(name, value);
        };
        fieldView.autorun(function() {
            var value:Dynamic = item.props.get(name);
            if (value == null) {
                fieldView.textValue = '';
            }
            else {
                fieldView.textValue = '' + value;
            }
        });
        if (name == 'width' || name == 'height') {
            fieldView.autorun(function() {
                var implicitSize = item.props.implicitSize;
                unobserve();
                fieldView.disabled = implicitSize;
            });
        }
        return fieldView;

    }

    public static function createEditableBooleanField(options:Dynamic, item:EditorEntityData, name:String) {

        var fieldView = new BooleanFieldView();
        fieldView.setValue = function(field, value) {
            item.props.set(name, value);
        };
        fieldView.autorun(function() {
            var value:Dynamic = item.props.get(name);
            if (value == null || value == 0 || value == '' || value == false) {
                fieldView.value = false;
            }
            else {
                fieldView.value = true;
            }
        });
        return fieldView;

    }

    public static function createEditableColorField(options:Dynamic, item:EditorEntityData, name:String) {

        var fieldView = new ColorFieldView();
        fieldView.setValue = function(field, value) {
            item.props.set(name, value);
        };
        fieldView.autorun(function() {
            var value:Dynamic = item.props.get(name);
            if (value == null) {
                fieldView.value = Color.WHITE;
            }
            else {
                fieldView.value = value;
            }
        });
        return fieldView;

    }

    public static function createEditableSelectField(options:Dynamic, item:EditorEntityData, name:String, getter:Void->ImmutableArray<String>, ?nullValueText:String) {

        var fieldView = new SelectFieldView();
        fieldView.nullValueText = nullValueText;
        fieldView.setValue = function(field, value) {
            item.props.set(name, value);
        };
        fieldView.autorun(function() {
            var value:Dynamic = item.props.get(name);
            if (Std.is(value, String)) {
                fieldView.value = value;
            }
            else {
                fieldView.value = null;
            }
        });
        fieldView.autorun(function() {
            fieldView.list = getter();
        });
        return fieldView;

    }

}
