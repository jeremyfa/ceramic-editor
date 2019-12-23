package editor.model;

class EditorEntityData extends Model {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var entityComponents:Map<String, String> = new Map();

    @serialize public var props:EditorProps = new EditorProps();

    public function new() {

        super();

    } //new

    public function toFragmentItem():FragmentItem {
        
        return {
            entity: entityClass,
            id: entityId,
            components: entityComponentsToDynamic(),
            props: props.toFragmentProps()
        };

    } //toFragmentItem

    public function entityComponentsToDynamic():Dynamic<String> {

        var result:Dynamic<String> = {};

        for (key in entityComponents.keys()) {
            Reflect.setField(result, key, entityComponents.get(key));
        }

        return result;

    } //entityComponentsToDynamic

} //EditorEntityData
