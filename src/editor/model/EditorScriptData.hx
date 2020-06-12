package editor.model;

class EditorScriptData extends EditorEditableElementData {

    /**
     * Script id
     */
    @serialize public var scriptId:String;

    /**
     * Script content
     */
    @serialize public var content:String = '';

    public function new() {

        super();

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.id = scriptId;
        json.content = content;

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid script id';
        scriptId = json.id;

        if (json.content != null) {
            if (!Std.is(json.content, String))
                throw 'Invalid script content';

            content = json.content;
        }
        else {
            content = '';
        }

    }

}