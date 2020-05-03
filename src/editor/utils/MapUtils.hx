package editor.utils;

class MapUtils {

    public static function stringMapToDynamic(map:Map<String,Dynamic>):Dynamic {

        var result:Dynamic = {};
        for (key => val in map) {
            Reflect.field(result, key, val);
        }
        return result;

    }

}