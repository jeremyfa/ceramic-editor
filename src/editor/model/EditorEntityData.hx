package editor.model;

class EditorEntityData extends Model {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var entityComponents:Map<String, String> = new Map();

    @serialize public var props:EditorProps = new EditorProps();

    @observe public var fragmentData:EditorFragmentData = null;

    public function new() {

        super();

        props.entityData = this;

    }

    override function didDeserialize() {

        props.entityData = this;

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

        for (key in entityComponents.keys()) {
            Reflect.setField(result, key, entityComponents.get(key));
        }

        return result;

    }

}
