package editor.utils;

class Validate {

    static var RE_IDENTIFIER = ~/^[a-zA-Z_][a-zA-Z_0-9]*$/;

    static var RE_WEB_COLOR = ~/^#[0-9a-fA-F]{6}$/;

    public static function nonEmptyString(input:Dynamic) {

        if (input == null || !Std.isOfType(input, String))
            return false;

        var str:String = input;
        if (str == '')
            return false;

        return true;

    }

    public static function identifier(input:Dynamic) {

        if (input == null || !Std.isOfType(input, String))
            return false;

        if (!RE_IDENTIFIER.match(input))
            return false;

        return true;

    }

    public static function webColor(input:Dynamic) {

        if (input == null || !Std.isOfType(input, String))
            return false;

        if (!RE_WEB_COLOR.match(input))
            return false;

        return true;

    }

    public static function intColorArray(input:Dynamic) {

        if (input == null || !Std.isOfType(input, Array))
            return false;

        var array:Array<Dynamic> = input;
        if (array.length == 0)
            return true;

        for (i in 0...array.length) {
            if (!int(array[i]))
                return false;
            var c:Int = array[i];
            if (c < 0x000000 || c > 0xFFFFFF) {
                return false;
            }
        }

        return true;

    }

    public static function array(input:Dynamic) {

        if (input == null || !Std.isOfType(input, Array))
            return false;

        return true;

    }

    public static function boolean(input:Dynamic) {

        if (input == null || !Std.isOfType(input, Bool))
            return false;

        return true;

    }

    public static function int(input:Dynamic) {

        if (input == null || (!Std.isOfType(input, Int) && (!Std.isOfType(input, Float) || input != Math.floor(input))))
            return false;

        return true;

    }

    public static function float(input:Dynamic) {

        if (input == null || (!Std.isOfType(input, Int) && !Std.isOfType(input, Float)))
            return false;

        return true;

    }

    public static function intDimension(input:Dynamic) {

        if (!int(input))
            return false;

        return input >= 0;

    }

    public static function floatDimension(input:Dynamic) {

        if (!float(input))
            return false;

        return input >= 0.0;

    }

}
