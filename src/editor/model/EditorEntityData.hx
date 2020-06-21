package editor.model;

class EditorEntityData extends Model {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var entityComponents:Map<String, String> = new Map();

    @serialize public var locked(default, set):Bool = false;
    function set_locked(locked:Bool):Bool {
        if (this.locked != locked) {
            this.locked = locked;
            if (locked && fragmentData != null && fragmentData.selectedItem == this) {
                fragmentData.selectedItem = null;
            }
            if (model != null)
                model.history.step();
        }
        return locked;
    }

    @serialize public var props:EditorEntityProps = new EditorEntityProps();

    @observe public var fragmentData:EditorFragmentData = null;

    @compute public function editableType():EditableType {
        return editor.getEditableType(entityClass);
    }

    @compute public function fieldTypes():ImmutableMap<String,String> {
        var map = new Map<String,String>();
        for (field in editableType.fields) {
            map.set(field.name, field.type);
        }
        return map;
    }

    var didInit:Bool = false;

    public function new() {

        super();

        if (!didInit) {
            init();
        }

    }

    override function didDeserialize() {

        if (!didInit) {
            init();
        }

    }

    function init() {

        didInit = true;

        props.entityData = this;

        autorun(() -> {
            var entityId = this.entityId;
            unobserve();

            for (track in timelineTracks) {
                track.targetId = entityId;
            }
        });

    }

    override function destroy() {

        super.destroy();

        fragmentData = null;

        props.destroy();
        props = null;

    }

    public function typeOfProp(key:String):String {

        return fieldTypes.get(key);

    }

    public function toFragmentItem():FragmentItem {
        
        return {
            entity: entityClass,
            id: entityId,
            components: entityComponentsToDynamic(),
            props: props.toFragmentProps()
        };

    }

    public function entityComponentsToDynamic():Dynamic<String> {

        var result:Dynamic<String> = {};

        var entityComponents = this.entityComponents;
        for (key in entityComponents.keys()) {
            Reflect.setField(result, key, entityComponents.get(key));
        }

        return result;

    }

    public function freezeEditorChanges():Void {

        if (fragmentData != null) {
            fragmentData.freezeEditorChanges++;
            var _fragmentData = fragmentData;
            Timer.delay(fragmentData, 0.5, () -> {
                if (_fragmentData.freezeEditorChanges > 0)
                    _fragmentData.freezeEditorChanges--;
            });
        }

    }

    public function editorChangesFrozen():Bool {

        return (fragmentData != null && fragmentData.freezeEditorChanges > 0);

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.id = entityId;
        json.entity = entityClass;
        json.isVisual = Std.is(this, EditorVisualData);
        json.locked = locked;

        if (Lambda.count(entityComponents) > 0) {
            json.components = {};
            for (key => val in entityComponents) {
                Reflect.setField(json.components, key, val);
            }
        }

        json.props = {};
        for (key in props.keys()) {
            var propValue = props.get(key);
            Reflect.setField(json.props, key, propValue);
        }

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid entity id';
        entityId = json.id;

        if (!Validate.nonEmptyString(json.entity))
            throw 'Invalid entity type';
        entityClass = json.entity;

        if (json.locked != null) {
            if (!Validate.boolean(json.locked))
                throw 'Invalid locked type';
            locked = json.locked;
        }
        else {
            locked = false;
        }

        if (json.components != null) {
            var parsedComponents = new Map<String,String>();
            for (key in Reflect.fields(json.components)) {
                var value:Dynamic = Reflect.field(json.components, key);
                if (!Validate.nonEmptyString(value))
                    throw 'Invalid component';
                parsedComponents.set(key, value);
            }
            entityComponents = cast parsedComponents;
        }
        else {
            entityComponents = cast new Map<String,String>();
        }

        if (json.props != null) {
            for (key in Reflect.fields(json.props)) {
                var value:Dynamic = Reflect.field(json.props, key);
                props.set(key, value);
            }
        }

    }

/// Timeline

    /**
     * The number of frames of this entity's timeline.
     * Automatically computed from timeline tracks
     * @return Int
     */
    @compute public function numTimelineFrames():Int {

        var tracks = timelineTracks;
        var size = 0;

        for (i in 0...tracks.length) {
            var track = tracks[i];
            var trackFrames = track.numFrames;
            if (trackFrames > size) {
                size = trackFrames;
            }
        }

        return size;

    }

    @serialize public var timelineTracks:ImmutableArray<EditorTimelineTrack> = [];

    public function timelineTrackForField(field:String):EditorTimelineTrack {

        var tracks = this.timelineTracks;
        for (i in 0...tracks.length) {
            var track = tracks[i];
            if (track.targetField == field && track.targetId == entityId) {
                return track;
            }
        }

        return null;

    }

    public function ensureTimelineTrack(field:String):Void {

        if (timelineTrackForField(field) == null) {
            var track = new EditorTimelineTrack(entityId, field);
            var newTracks = [].concat(this.timelineTracks.mutable);
            newTracks.push(track);
            newTracks.sort(compareTimelineTracks);
            this.timelineTracks = cast newTracks;
        }
        
    }

    public function removeTimelineTrack(field:String):Void {

        var track = timelineTrackForField(field);
        if (track != null) {
            var newTracks = [].concat(this.timelineTracks.mutable);
            newTracks.remove(track);
            this.timelineTracks = cast newTracks;
        }
        
    }

    function compareTimelineTracks(trackA:EditorTimelineTrack, trackB:EditorTimelineTrack):Int {

        var fieldA = trackA.targetField;
        var fieldB = trackB.targetField;

        var editableType = this.editableType;
        if (editableType == null) {
            return 0;
        }
        
        var fields = editableType.fields;
        for (i in 0...fields.length) {
            var field = fields[i];
            if (field.name == fieldA) return -1;
            else if (field.name == fieldB) return 1;
        }
        return 0;

    }

}
