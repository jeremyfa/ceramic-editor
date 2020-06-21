package editor.model;

class EditorTimelineTrack extends Model {

    @serialize public var targetId:String;

    @serialize public var targetField:String;

    @serialize public var keyframes:ImmutableMap<Int, EditorTimelineKeyframe> = new Map();

    @compute public function numFrames():Int {

        var size = 0;

        for (keyframe in keyframes) {
            var index = keyframe.index;
            if (index + 1 > size) {
                size = index + 1;
            }
        }

        return size;

    }

    public function new(targetId:String, targetField:String) {

        super();

        this.targetId = targetId;
        this.targetField = targetField;

    }

    public function keyframeByIndex(index:Int):EditorTimelineKeyframe {

        return keyframes.get(index);

    }

    public function setKeyframe(index:Int, keyframe:EditorTimelineKeyframe) {

        var prevKeyframe = keyframeByIndex(index);
        if (prevKeyframe != null && prevKeyframe != keyframe) {
            removeKeyframeAtIndex(index);
        }
        
        keyframe.index = index;

    }

    public function removeKeyframeAtIndex(index:Int) {

        var keyframes = this.keyframes;

        if (keyframes.exists(index)) {
            var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
            for (key => val in keyframes.mutable) {
                if (key != index) {
                    newKeyframes.set(key, val);
                }
                this.keyframes = cast newKeyframes;
            }
        }

    }

    public function removeKeyframe(index:Int, keyframe:EditorTimelineKeyframe) {

        var keyframes = this.keyframes;
        var exists = false;

        for (val in keyframes.mutable) {
            if (val == keyframe) {
                exists = true;
                break;
            }
        }

        if (exists) {
            var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
            for (key => val in keyframes.mutable) {
                if (val != keyframe) {
                    newKeyframes.set(key, val);
                }
                this.keyframes = cast newKeyframes;
            }
        }

    }

}