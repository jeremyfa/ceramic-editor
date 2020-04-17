package editor.model;

using tracker.SaveModel;

class EditorData extends Model {

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:ProjectData = new ProjectData();

    @observe public var images:ImmutableArray<String> = [];

    @observe public var texts:ImmutableArray<String> = [];

    @observe public var sounds:ImmutableArray<String> = [];

    @observe public var fonts:ImmutableArray<String> = [];

    @observe public var databases:ImmutableArray<String> = [];

    @observe public var pendingChoice:EditorPendingChoice = null;

    public function new() {

        super();

        //this.loadSaved('editor');
        this.autoSaveAsKey('editor');

    }

}
