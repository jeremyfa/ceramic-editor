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

    public function keyframeAtIndex(index:Int):Null<EditorTimelineKeyframe> {

        return keyframes.get(index);

    }

    /**
     * Find the keyframe right before or equal to given `index`
     * @param index 
     * @return Null<EditorTimelineKeyframe>
     */
    public function keyframeBeforeIndex(index:Int):Null<EditorTimelineKeyframe> {

        var keyframes = this.keyframes;
        while (index >= 0) {

            if (keyframes.exists(index)) {
                var keyframe = keyframes.get(index);
                if (keyframe != null) {
                    return keyframe;
                }
            }

            index--;
        }

        return null;

    }

    /**
     * Find the keyframe right after given `index`
     * @param index 
     * @return Null<EditorTimelineKeyframe>
     */
    public function keyframeAfterIndex(index:Int):Null<EditorTimelineKeyframe> {

        var keyframes = this.keyframes;
        
        var bestIndex = -1;
        var bestDiff = 999999999;

        for (anIndex in keyframes.keys()) {
            if (anIndex > index) {
                var diff = anIndex - index;
                if (diff < bestDiff) {
                    bestDiff = diff;
                    bestIndex = anIndex;
                }
            }
        }

        if (bestIndex != -1) {
            return keyframes.get(bestIndex);
        }

        return null;

    }

    public function setKeyframe(index:Int, keyframe:EditorTimelineKeyframe) {

        var prevKeyframe = keyframeAtIndex(index);
        if (prevKeyframe != null && prevKeyframe != keyframe) {
            removeKeyframeAtIndex(index);
        }
        
        keyframe.index = index;
        var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
        newKeyframes.set(index, keyframe);
        for (key => val in keyframes.mutable) {
            if (key != index) {
                newKeyframes.set(key, val);
            }
        }
        this.keyframes = cast newKeyframes;

    }

    public function removeKeyframeAtIndex(index:Int) {

        var keyframes = this.keyframes;

        if (keyframes.exists(index)) {
            var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
            for (key => val in keyframes.mutable) {
                if (key != index) {
                    newKeyframes.set(key, val);
                }
            }
            this.keyframes = cast newKeyframes;
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
            }
            this.keyframes = cast newKeyframes;
        }

    }

}