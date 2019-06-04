package editor.ui.form;

using StringTools;

class SanitizeTextField {

    public static function setTextValueToInt(field:TextFieldView, textValue:String):Void {

        if (textValue.trim() != '') {
            var intValue = Std.parseInt(textValue);
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

} //SanitizeTextField
