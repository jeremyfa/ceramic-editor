package editor.utils;

class TextUtils {

    public static function toFieldLabel(str:String):String {

        var result = new StringBuf();

        for (i in 0...str.length) {
            var char = str.charAt(i);

            if (i == 0) {
                result.add(char.toUpperCase());
            }
            else if (char.toUpperCase() == char) {
                result.add(' ');
                result.add(char);
            }
            else {
                result.add(char);
            }
        }

        return result.toString();

    }

    public static function compareStrings(a:String, b:String) {
        a = a.toUpperCase();
        b = b.toUpperCase();
      
        if (a < b) {
          return -1;
        }
        else if (a > b) {
          return 1;
        }
        else {
          return 0;
        }
    }

}