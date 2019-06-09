package editor.model;

class EditorEntityData extends Model {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var props:EditorProps = new EditorProps();

    public function new() {

        super();

    } //new

} //EditorEntityData
