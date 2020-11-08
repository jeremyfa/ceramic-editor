package editor.utils;

class Validate {

    static var RE_IDENTIFIER = ~/^[a-zA-Z_][a-zA-Z_0-9]*$/;

    public static function nonEmptyString(input:Dynamic) {

        if (input == null || !Std.is(input, String))
            return false;

        var str:String = input;
        if (str == '')
            return false;

        return true;

    }

    public static function identifier(input:Dynamic) {

        if (input == null || !Std.is(input, String))
            return false;

        if (!RE_IDENTIFIER.match(input))
            return false;

        return true;

    }

    public static function colorArray(input:Dynamic) {

        if (input == null || !Std.is(input, Array))
            return false;

        var array:Array<Dynamic> = input;
        if (array.length == 0)
            return true;

        for (i in 0...array.length) {
            if (!Std.is(array[i], Int))
                return false;
            var c:Int = array[i];
            if (c < 0x000000 || c > 0xFFFFFF) {
                return false;
            }
        }

        return true;

    }

    public static function array(input:Dynamic) {

        if (input == null || !Std.is(input, Array))
            return false;

        return true;

    }

    public static function boolean(input:Dynamic) {

        if (input == null || !Std.is(input, Bool))
            return false;

        return true;

    }

    public static function int(input:Dynamic) {

        if (input == null || !Std.is(input, Int))
            return false;

        return true;

    }

    public static function float(input:Dynamic) {

        if (input == null || (!Std.is(input, Int) && !Std.is(input, Float)))
            return false;

        return true;

    }

    public static function intDimension(input:Dynamic) {

        if (input == null || !Std.is(input, Int))
            return false;

        return input >= 0;

    }

}