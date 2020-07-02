package editor.model;

class EditorTimelineKeyframe extends Model {

    @serialize public var index:Int = -1;

    @serialize public var easing:Easing = NONE;

    @serialize public var value:Dynamic = null;

    public function new() {

        super();

    }

    public function toTimelineKeyframeData():TimelineKeyframeData {

        return {
            index: this.index,
            easing: EasingUtils.easingToString(easing),
            value: value
        };

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.index = index;
        json.easing = EasingUtils.easingToString(easing);
        json.value = value;

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.int(json.index))
            throw 'Invalid keyframe index';
        index = json.index;

        if (json.easing != null) {
            var easing = EasingUtils.easingFromString(json.easing);
            if (easing == null)
                throw 'Invalid keyframe easing';
            this.easing = easing;
        }

        value = json.value;

    }

}