package editor.model;

using ceramic.SaveModel;

class EditorData extends Model {

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:ProjectData = new ProjectData();

    public function new() {

        super();

        //this.loadSaved('editor');
        this.autoSave('editor');

    } //new

} //EditorData
