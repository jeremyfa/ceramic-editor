package editor.utils;

using StringTools;

class SanitizeTextField {

    public static function setTextValueToInt(field:TextFieldView, textValue:String):Void {

        if (textValue.trim() != '') {
            var intValue:Null<Int> = Std.parseInt(textValue);
            if (intValue != null && !Math.isNaN(intValue) && Math.isFinite(intValue)) {
                field.setValue(field, intValue);
                field.textValue = '' + intValue;
            }
        }
        else {
            field.textValue = '';
        }
        field.invalidateTextValue();

    } //setTextValueToInt

    public static function setTextValueToFloat(field:TextFieldView, textValue:String):Void {

        if (textValue.trim() != '') {
            var textValue = textValue.replace(',', '.');
            var endsWithDot = false;
            if (textValue.endsWith('.')) {
                endsWithDot = true;
                textValue = textValue.substring(0, textValue.length - 1);
            }
            var floatValue:Null<Float> = Std.parseFloat(textValue);
            if (floatValue != null && !Math.isNaN(floatValue) && Math.isFinite(floatValue)) {
                field.setValue(field, floatValue);
                field.textValue = '' + floatValue + (endsWithDot ? '.' : '');
            }
        }
        else {
            field.textValue = '';
        }
        field.invalidateTextValue();

    } //setTextValueToFloat

} //SanitizeTextField
