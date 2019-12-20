package editor.model;

class EditorEntityData extends Model {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var props:EditorProps = new EditorProps();

    public function new() {

        super();

    } //new

    public function toFragmentItem():FragmentItem {
        
        return {
            entity: entityClass,
            id: entityId,
            props: props.toFragmentProps()
        };

    } //toFragmentItem

} //EditorEntityData
