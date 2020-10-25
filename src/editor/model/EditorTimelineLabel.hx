package editor.model;

class EditorTimelineLabel extends Model {

    @serialize public var index:Int;

    @serialize public var label:String;

    public function new(index:Int, label:String) {

        super();

        this.index = index;
        this.label = label;

    }

}
