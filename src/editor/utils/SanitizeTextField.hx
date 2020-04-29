package editor.utils;

using StringTools;

class SanitizeTextField {

    static final RE_SPACES = ~/\s+/;

    static final RE_NUMERIC_PREFIX = ~/^[0-9]+/;

    static final RE_SLUG_UNSAFE = ~/[$*+~.()'"!\\:@\?§]/g;

    public static function setTextValueToInt(minValue:Int, maxValue:Int) {
        
        return function(field:TextFieldView, textValue:String):Void {

            var trimmedValue = textValue.trim();
            if (trimmedValue != '' && trimmedValue != '-') {
                var intValue:Null<Int> = Std.parseInt(textValue);
                if (intValue != null && !Math.isNaN(intValue) && Math.isFinite(intValue)) {
                    if (intValue < minValue) {
                        intValue = minValue;
                    }
                    if (intValue > maxValue) {
                        intValue = maxValue;
                    }
                    field.setValue(field, intValue);
                    field.textValue = '' + intValue;
                }
            }
            else {
                field.textValue = trimmedValue;
            }
            field.invalidateTextValue();

        };

    }

    public static function setTextValueToEmptyInt(field:TextFieldView):Void {

        field.textValue = '0';
        field.invalidateTextValue();

    }

    public static function setTextValueToFloat(minValue:Float, maxValue:Float) {
        
        return function(field:TextFieldView, textValue:String):Void {

            var trimmedValue = textValue.trim();
            if (trimmedValue != '' && trimmedValue != '-') {
                var textValue = textValue.replace(',', '.');
                var endsWithDot = false;
                if (textValue.endsWith('.')) {
                    endsWithDot = true;
                    textValue = textValue.substring(0, textValue.length - 1);
                }
                var floatValue:Null<Float> = Std.parseFloat(textValue);
                if (floatValue != null && !Math.isNaN(floatValue) && Math.isFinite(floatValue)) {
                    if (floatValue < minValue) {
                        floatValue = minValue;
                    }
                    if (floatValue > maxValue) {
                        floatValue = maxValue;
                    }
                    field.setValue(field, floatValue);
                    field.textValue = '' + floatValue + (endsWithDot ? '.' : '');
                }
            }
            else {
                field.textValue = trimmedValue;
            }
            field.invalidateTextValue();

        };

    }

    public static function setTextValueToEmptyFloat(field:TextFieldView):Void {

        field.textValue = '0';
        field.invalidateTextValue();

    }

    public static function setTextValueToIdentifier(field:TextFieldView, textValue:String):Void {

        textValue = RE_NUMERIC_PREFIX.replace(textValue, '');
        textValue = RE_SPACES.replace(textValue, '_');
        textValue = Slug.encode(textValue, {
            lower: false,
            replacement: '_',
            remove: RE_SLUG_UNSAFE
        });
        field.setValue(field, textValue);
        field.textValue = textValue;
        field.invalidateTextValue();

    }

}
