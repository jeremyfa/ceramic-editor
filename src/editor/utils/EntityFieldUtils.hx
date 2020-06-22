package editor.utils;

class EntityFieldUtils {

    public static function createEditableField(editableType:EditableType, field:EditableTypeField, item:EditorEntityData):FieldView {

        var type = field.type;
        var name = field.name;

        var options:Dynamic = field.meta.editable[0];

        if (options.slider != null) {
            return createEditableSliderField(options, item, name);
        }
        else if (type == 'String' || type == 'Float' || type == 'Int') {// || type == 'Array<Float>' || type == 'Array<Int>') {
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
                return model.images;
            }, 'no texture');
        }
        else if (type == 'ceramic.Shader') {
            return createEditableSelectField(options, item, name, () -> {
                return model.shaders;
            }, 'default shader');
        }
        else if (type == 'ceramic.BitmapFont') {
            return createEditableSelectField(options, item, name, () -> {
                return model.fonts;
            });
        }
        else if (type == 'ceramic.FragmentData') {
            return createEditableSelectField(options, item, name, () -> {
                var items = [];
                var fragments = model.fragments;
                for (key in fragments.keys())
                    items.push(key);
                items.sort(TextUtils.compareStrings);
                return items;
            }, 'no data');
        }
        else if (type == 'ceramic.ScriptContent') {
            return createEditableSelectField(options, item, name, () -> {
                var items = [];
                var scripts = model.scripts;
                for (key in scripts.keys())
                    items.push(key);
                items.sort(TextUtils.compareStrings);
                return items;
            }, 'no script');
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
        else if (type == 'Array<Float>' || type == 'Array<Int>') {
            fieldView.multiline = true;
            fieldView.setEmptyValue = function(field) {
                item.props.set(name, []);
                fieldView.textValue = '';
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
        if (type == 'Array<Float>') {
            var isPoints = (options.points == true);
            var minItems = 0;
            if (options.minItems != null)
                minItems = options.minItems;
            var extra:Null<Float> = null;
            fieldView.setValue = function(field, value) {
                var strArray:Array<String> = value.split(' ');
                var array:Array<Float> = [];
                for (i in 0...strArray.length) {
                    var val:Null<Float> = Std.parseFloat(strArray[i]);
                    if (val != null && !Math.isNaN(val))
                        array.push(val);
                }
                while (array.length < minItems) {
                    array.push(0);
                }
                if (isPoints && array.length % 2 == 1) {
                    extra = array.pop();
                }
                else {
                    extra = null;
                }
                item.props.set(name, array);
            };
            fieldView.autorun(function() {
                var value:Array<Float> = item.props.get(name);
                unobserve();
                if (value == null) {
                    fieldView.textValue = '';
                }
                else {
                    fieldView.textValue = '' + value.join(' ') + (extra != null ? ' ' + extra : '') + (fieldView.textValue.endsWith(' ') ? ' ' : '');
                }
            });
        }
        else if (type == 'Array<Int>') {
            var isPoints = (options.points == true);
            var minItems = 0;
            if (options.minItems != null)
                minItems = options.minItems;
            var extra:Null<Int> = null;
            fieldView.setValue = function(field, value) {
                var strArray:Array<String> = value.split(' ');
                var array:Array<Int> = [];
                for (i in 0...strArray.length) {
                    var val:Null<Int> = Std.parseInt(strArray[i]);
                    if (val != null && !Math.isNaN(val))
                        array.push(val);
                }
                while (array.length < minItems) {
                    array.push(0);
                }
                if (isPoints && array.length % 2 == 1) {
                    extra = array.pop();
                }
                else {
                    extra = null;
                }
                item.props.set(name, array);
            };
            fieldView.autorun(function() {
                var value:Array<Float> = item.props.get(name);
                unobserve();
                if (value == null) {
                    fieldView.textValue = '';
                }
                else {
                    fieldView.textValue = '' + value.join(' ') + (extra != null ? ' ' + extra : '') + (fieldView.textValue.endsWith(' ') ? ' ' : '');
                }
            });
        }
        else {
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
        }
        if (name == 'width' || name == 'height') {
            fieldView.autorun(function() {
                var implicitSize = item.props.implicitSize;
                unobserve();
                fieldView.disabled = implicitSize;
            });
        }
        return fieldView;

    }

    public static function createEditableEntityIdField(item:EditorEntityData) {
        
        var fieldView = new TextFieldView(TEXT);
        fieldView.setTextValue = SanitizeTextField.setTextValueToIdentifier;
        fieldView.setValue = function(field, value) {
            fieldView.textValue = value;
        };
        var valueOnFocus = null;
        fieldView.autorun(function() {
            fieldView.textValue = item.entityId;
            valueOnFocus = item.entityId;
        });
        valueOnFocus = null;
        var wasFocused = fieldView.focused;
        inline function applyChange() {
            var value = fieldView.textValue;
            if (value == '') {
                // Empty value, restore previous value
                fieldView.setValue(fieldView, valueOnFocus);
                fieldView.textValue = valueOnFocus;
            }
            else if (item.fragmentData != null) {
                var itemForId = item.fragmentData.get(value);
                if (itemForId != null && itemForId != item) {
                    log.warning('Ignoring value: $value (duplicate entity id in fragment)');
                    
                    fieldView.setValue(fieldView, valueOnFocus);
                    fieldView.textValue = valueOnFocus;
                }
                else {
                    if (item.entityId != value) {
                        item.entityId = value;
                        model.history.step();
                    }
                }
            }
            else {
                if (item.entityId != value) {
                    item.entityId = value;
                    model.history.step();
                }
            }
        }
        fieldView.autorun(function() {
            var isFocused = fieldView.focused;
            unobserve();
            if (wasFocused && !isFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
            else if (!wasFocused && isFocused) {
                valueOnFocus = item.entityId;
            }
            wasFocused = isFocused;
            reobserve();
        });
        fieldView.onDestroy(item, function(_) {
            if (wasFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
        });
        return fieldView;

    }

    public static function createEditableFragmentIdField(item:EditorFragmentData) {
        
        var fieldView = new TextFieldView(TEXT);
        fieldView.setTextValue = SanitizeTextField.setTextValueToIdentifier;
        fieldView.setValue = function(field, value) {
            fieldView.textValue = value;
        };
        var valueOnFocus = null;
        fieldView.autorun(function() {
            fieldView.textValue = item.fragmentId;
            valueOnFocus = item.fragmentId;
        });
        valueOnFocus = null;
        var wasFocused = fieldView.focused;
        inline function applyChange() {
            var value = fieldView.textValue;
            if (value == '') {
                // Empty value, restore previous value
                fieldView.setValue(fieldView, valueOnFocus);
                fieldView.textValue = valueOnFocus;
            }
            else if (model != null && model.project != null) {
                var itemForId = model.project.fragmentById(value);
                if (itemForId != null && itemForId != item) {
                    log.warning('Ignoring value: $value (duplicate fragment id in model)');
                    
                    fieldView.setValue(fieldView, valueOnFocus);
                    fieldView.textValue = valueOnFocus;
                }
                else {
                    if (item.fragmentId != value) {
                        var prevFragmentId = item.fragmentId;
                        item.fragmentId = value;
                        model.didRenameFragment(item, prevFragmentId, item.fragmentId);
                        model.history.step();
                    }
                }
            }
            else {
                if (item.fragmentId != value) {
                    var prevFragmentId = item.fragmentId;
                    item.fragmentId = value;
                    model.didRenameFragment(item, prevFragmentId, item.fragmentId);
                    model.history.step();
                }
            }
        }
        fieldView.autorun(function() {
            var isFocused = fieldView.focused;
            unobserve();
            if (wasFocused && !isFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
            else if (!wasFocused && isFocused) {
                valueOnFocus = item.fragmentId;
            }
            wasFocused = isFocused;
            reobserve();
        });
        fieldView.onDestroy(item, function(_) {
            if (wasFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
        });
        return fieldView;

    }

    public static function createEditableScriptIdField(item:EditorScriptData) {
        
        var fieldView = new TextFieldView(TEXT);
        fieldView.setTextValue = SanitizeTextField.setTextValueToIdentifier;
        fieldView.setValue = function(field, value) {
            fieldView.textValue = value;
        };
        var valueOnFocus = null;
        fieldView.autorun(function() {
            fieldView.textValue = item.scriptId;
            valueOnFocus = item.scriptId;
        });
        valueOnFocus = null;
        var wasFocused = fieldView.focused;
        inline function applyChange() {
            var value = fieldView.textValue;
            if (value == '') {
                // Empty value, restore previous value
                fieldView.setValue(fieldView, valueOnFocus);
                fieldView.textValue = valueOnFocus;
            }
            else if (model != null && model.project != null) {
                var itemForId = model.project.scriptById(value);
                if (itemForId != null && itemForId != item) {
                    log.warning('Ignoring value: $value (duplicate script id in model)');
                    
                    fieldView.setValue(fieldView, valueOnFocus);
                    fieldView.textValue = valueOnFocus;
                }
                else {
                    if (item.scriptId != value) {
                        var prevScriptId = item.scriptId;
                        item.scriptId = value;
                        model.didRenameScript(item, prevScriptId, item.scriptId);
                        model.history.step();
                    }
                }
            }
            else {
                if (item.scriptId != value) {
                    var prevScriptId = item.scriptId;
                    item.scriptId = value;
                    model.didRenameScript(item, prevScriptId, item.scriptId);
                    model.history.step();
                }
            }
        }
        fieldView.autorun(function() {
            var isFocused = fieldView.focused;
            unobserve();
            if (wasFocused && !isFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
            else if (!wasFocused && isFocused) {
                valueOnFocus = item.scriptId;
            }
            wasFocused = isFocused;
            reobserve();
        });
        fieldView.onDestroy(item, function(_) {
            if (wasFocused) {
                if (valueOnFocus != null) {
                    applyChange();
                }
            }
        });
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

    public static function createEditableSelectField(options:Dynamic, item:EditorEntityData, name:String, getter:Void->ReadOnlyArray<Dynamic>, ?nullValueText:String) {

        var rawList:ReadOnlyArray<Dynamic> = null;
        var fieldView = new SelectFieldView();
        fieldView.nullValueText = nullValueText;
        fieldView.setValue = function(field, value) {
            if (rawList.length > 0 && !Std.is(rawList[0], String)) {
                for (listItem in rawList) {
                    if (listItem[0] == value) {
                        var toAssign = listItem[1];
                        item.props.set(name, toAssign);
                        break;
                    }
                }
            }
            else {
                item.props.set(name, value);
            }
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
            rawList = getter();
            if (rawList.length > 0 && !Std.is(rawList[0], String)) {
                var list:Array<String> = [];
                for (listItem in rawList) {
                    list.push(listItem[0]);
                }
                fieldView.list = cast list;
            }
            else {
                fieldView.list = cast rawList;
            }
        });
        return fieldView;

    }

}
