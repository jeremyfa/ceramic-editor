package editor.utils;

class TimelineUtils {

    public static function canTypeBeAnimated(type:String):Bool {

        return switch type {
            case 'Float': true;
            case 'Int': true;
            default: false;
        }

    }

}