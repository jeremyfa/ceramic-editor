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

        var entityComponents = this.entityComponents;
        for (key in entityComponents.keys()) {
            Reflect.setField(result, key, entityComponents.get(key));
        }

        return result;

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.id = entityId;
        json.entity = entityClass;
        json.isVisual = Std.is(this, EditorVisualData);

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

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid entity id';
        entityId = json.id;

        if (!Validate.nonEmptyString(json.entity))
            throw 'Invalid entity type';
        entityClass = json.entity;

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

}
