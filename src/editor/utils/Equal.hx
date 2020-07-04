package editor.utils;

using ceramic.Extensions;

class Equal {

    public static function equal(a:Dynamic, b:Dynamic):Bool {

        if (a == b)
            return true;

        if (Std.is(a, Array)) {
            if (Std.is(b, Array)) {
                return arrayEqual(a, b);
            }
            return false;
        }

        return false;

    }

    public static function arrayEqual(a:Array<Dynamic>, b:Array<Dynamic>):Bool {

        var lenA = a.length;
        var lenB = b.length;
        if (lenA != lenB)
            return false;
        for (i in 0...lenA) {
            if (a.unsafeGet(i) != b.unsafeGet(i)) {
                return false;
            }
        }
        return true;

    }

}