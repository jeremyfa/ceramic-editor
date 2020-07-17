package editor.model;

class EditorTimelineTrack extends Model {

    @serialize public var entityData:EditorEntityData;

    @serialize public var loop:Bool = true;

    @serialize public var entity:String;

    @serialize public var field:String;

    @serialize public var keyframes:ReadOnlyMap<Int, EditorTimelineKeyframe> = new Map();

    @compute public function keyframeIndexes():ReadOnlyArray<Int> {

        var result = [];

        for (index in keyframes.keys()) {
            result.push(index);
        }

        result.sort((a, b) -> {
            if (a > b)
                return 1;
            else if (a < b)
                return -1;
            else
                return 0;
        });

        return cast result;

    }

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

    public function new(entityData:EditorEntityData, entity:String, field:String) {

        super();

        this.entityData = entityData;
        this.entity = entity;
        this.field = field;

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
        for (key => val in keyframes.original) {
            if (key != index) {
                newKeyframes.set(key, val);
            }
        }
        this.keyframes = cast newKeyframes;

        model.history.step();

    }

    public function removeKeyframeAtIndex(index:Int) {

        var keyframes = this.keyframes;

        if (keyframes.exists(index)) {
            var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
            for (key => val in keyframes.original) {
                if (key != index) {
                    newKeyframes.set(key, val);
                }
            }
            this.keyframes = cast newKeyframes;

            model.history.step();
        }

    }

    public function removeKeyframe(index:Int, keyframe:EditorTimelineKeyframe) {

        var keyframes = this.keyframes;
        var exists = false;

        for (val in keyframes.original) {
            if (val == keyframe) {
                exists = true;
                break;
            }
        }

        if (exists) {
            var newKeyframes = new Map<Int, EditorTimelineKeyframe>();
            for (key => val in keyframes.original) {
                if (val != keyframe) {
                    newKeyframes.set(key, val);
                }
            }
            this.keyframes = cast newKeyframes;

            model.history.step();
        }

    }

    public function toTimelineTrackData():TimelineTrackData {

        return {
            loop: this.loop,
            entity: this.entity,
            field: this.field,
            keyframes: keyframesToTimelineKeyframesData(),
            options: timelineOptions()
        };

    }

    function timelineOptions():Dynamic<Dynamic> {

        var fieldName = this.field;
        if (entityData != null && entityData.editableType != null) {
            for (field in entityData.editableType.fields) {
                if (field.name == fieldName) {
                    if (field.meta != null && field.meta.editable != null) {
                        return field.meta.editable[0];
                    }
                }
            }
        }

        return null;

    }

    function keyframesToTimelineKeyframesData():Array<TimelineKeyframeData> {

        var result = [];
        for (keyframe in keyframes) {
            result.push(keyframe.toTimelineKeyframeData());
        }
        return result;

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.loop = loop;
        json.entity = entity;
        json.field = field;
        
        var jsonKeyframes = [];
        for (keyframe in keyframes) {
            jsonKeyframes.push(keyframe.toJson());
        }
        json.keyframes = jsonKeyframes;

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (json.loop != null && !Validate.boolean(json.loop))
            throw 'Invalid timeline loop';
        loop = json.loop;

        if (!Validate.identifier(json.entity))
            throw 'Invalid timeline entity';
        entity = json.entity;

        if (!Validate.identifier(json.field))
            throw 'Invalid timeline field';
        field = json.field;

        if (json.keyframes != null) {
            if (!Validate.array(json.keyframes))
                throw 'Invalid timeline keyframes';
            var jsonKeyframes:Array<Dynamic> = json.keyframes;
            var keyframes = new Map<Int, EditorTimelineKeyframe>();
            for (jsonKeyframe in jsonKeyframes) {
                var keyframe = new EditorTimelineKeyframe();
                keyframe.fromJson(jsonKeyframe);
                keyframes.set(keyframe.index, keyframe);
            }
            this.keyframes = cast keyframes;
        }

    }

}