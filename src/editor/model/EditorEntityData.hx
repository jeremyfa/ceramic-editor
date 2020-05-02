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

    override function destroy() {

        super.destroy();

        fragmentData = null;

        props.destroy();
        props = null;

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

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.id = entityId;
        json.entity = entityClass;

        if (Lambda.count(entityComponents) > 0) {
            json.components = {};
            for (key => val in entityComponents) {
                Reflect.setField(json.components, key, val);
            }
        }

        json.props = {};
        for (key in props.keys()) {
            Reflect.setField(json.props, key, props.get(key));
        }

        return json;

    }

}
