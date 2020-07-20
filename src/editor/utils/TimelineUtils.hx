package editor.utils;

class TimelineUtils {

    public static function canTypeBeAnimated(type:String):Bool {

        return switch type {
            case 'Float': true;
            case 'Int': true;
            case 'ceramic.Color': true;
            case 'Bool': true;
            case 'Array<Float>': true;
            default: false;
        }

    }

    public static function setEveryTimelinePaused(fragment:Fragment, paused:Bool) {

        var entities = fragment.entities;
        for (i in 0...entities.length) {
            var entity = entities[i];
            if (Std.is(entity, Fragment)) {
                var subFragment:Fragment = cast entity;
                if (subFragment.timeline != null) {
                    subFragment.timeline.paused = paused;
                }
                setEveryTimelinePaused(subFragment, paused);
            }
        }

    }

    public static function setEveryTimelineTime(fragment:Fragment, time:Float) {

        var entities = fragment.entities;
        for (i in 0...entities.length) {
            var entity = entities[i];
            if (Std.is(entity, Fragment)) {
                var subFragment:Fragment = cast entity;
                if (subFragment.timeline != null && subFragment.autoUpdateTimeline) {
                    subFragment.timeline.seek(time);
                }
                setEveryTimelineTime(subFragment, time);
            }
        }

    }

}