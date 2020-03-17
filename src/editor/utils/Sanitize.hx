package editor.utils;

using StringTools;

class Sanitize {

    public static function stringToFloat(textValue:String):Float {

        if (textValue.trim() != '') {
            textValue = textValue.replace(',', '.');
            var endsWithDot = false;
            if (textValue.endsWith('.')) {
                endsWithDot = true;
                textValue = textValue.substring(0, textValue.length - 1);
            }
            var floatValue:Null<Float> = Std.parseFloat(textValue);
            if (floatValue != null && !Math.isNaN(floatValue) && Math.isFinite(floatValue)) {
                return floatValue;
            }
        }

        return 0;

    }

    public static function stringToColor(textValue:String):Color {

        return Color.fromString(textValue);

    }

}
