package editor.model;

class EditorTimelineKeyframe extends Model {

    @serialize public var index:Int = -1;

    @serialize public var easing:Easing = NONE;

    @serialize public var value(default, set):Dynamic = null;
    function set_value(value:Dynamic):Dynamic {
        if (Std.is(value, Array)) {
            if (this.unobservedValue == null || !Equal.arrayEqual(this.unobservedValue, value)) {
                // Make a copy, when providing array
                this.value = [].concat(value);
            }
            else {
                // Arrays have same content, do nothing then
            }
        }
        else {
            this.value = value;
        }
        return value;
    }

    public function new() {

        super();

    }

    public function toTimelineKeyframeData():TimelineKeyframeData {

        var keyframeValue:Dynamic = value;
        if (Std.is(keyframeValue, Array)) {
            keyframeValue = [].concat(keyframeValue);
        }

        return {
            index: this.index,
            easing: EasingUtils.easingToString(easing),
            value: keyframeValue
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