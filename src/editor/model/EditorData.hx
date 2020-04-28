package editor.model;

using tracker.SaveModel;
using tracker.History;

class EditorData extends Model {

    @component public var history:History;

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

        this.loadFromKey('editor');
        this.autoSaveAsKey('editor');

        history = new History();
        history.step();

    }

    override function destroy() {

        super.destroy();

        trace('MODEL DESTROY');
        
    }

}
