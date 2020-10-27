package editor.model;

class EditorTimelineLabel extends Model {

    @serialize public var index:Int;

    @serialize public var name:String;

    public function new(index:Int, name:String) {

        super();

        this.index = index;
        this.name = name;

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.index = index;
        json.name = name;

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (json.index != null && !Validate.int(json.index))
            throw 'Invalid label index';
        index = json.index;

        if (!Validate.nonEmptyString(json.name))
            throw 'Invalid label name';
        name = json.name;

    }

}
