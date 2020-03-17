package editor.model;

using tracker.SaveModel;

class EditorData extends Model {

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:ProjectData = new ProjectData();

    @observe public var images:ImmutableArray<String> = [];

    public function new() {

        super();

        //this.loadSaved('editor');
        this.autoSaveAsKey('editor');

    }

}
