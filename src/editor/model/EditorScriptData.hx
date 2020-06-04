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

}