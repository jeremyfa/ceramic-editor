package editor.model;

import haxe.Json;
using tracker.SaveModel;
using tracker.History;

class EditorData extends Model {

    @component public var history:History;

    @observe public var projectUnsaved:Bool = false;

    @observe public var projectPath:String = null;

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:ProjectData = new ProjectData();

    @observe public var images:ImmutableArray<String> = [];

    @observe public var texts:ImmutableArray<String> = [];

    @observe public var sounds:ImmutableArray<String> = [];

    @observe public var fonts:ImmutableArray<String> = [];

    @observe public var databases:ImmutableArray<String> = [];

    @observe public var pendingChoice:EditorPendingChoice = null;

    @observe public var statusMessage(default, null):String = null;

    var clearStatusMessageDelay:Void->Void = null;

    public function new() {

        super();

        this.loadFromKey('editor');
        this.autoSaveAsKey('editor');

        history = new History();
        history.step();

        serializer.onChangeset(this, changeset -> {
            projectUnsaved = true;
        });

    }

    override function destroy() {

        super.destroy();

        trace('MODEL DESTROY');
        
    }

    public function status(message:String, duration:Float = 60) {

        if (clearStatusMessageDelay != null) {
            clearStatusMessageDelay();
        }

        this.statusMessage = message;

        clearStatusMessageDelay = Timer.delay(this, duration, () -> {
            this.statusMessage = null;
        });

    }

    public function saveProject() {

        if (projectPath != null) {
            // TODO save
        }
        else {
            trace('save file dialog...');
            Dialogs.saveFile('Save project', [{
                name: 'Ceramic project', extensions: ['ceramic']
            }], file -> {
                if (file != null) {
                    trace('Save as file: $file');
                    project.title = Path.withoutExtension(Path.withoutDirectory(file));
                    Files.saveContent(file, Json.stringify(project.toJson(), null, '    '));
                }
            });
        }

    }

}
