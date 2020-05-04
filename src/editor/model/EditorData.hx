package editor.model;

import tracker.Autorun;
import haxe.Json;
using tracker.SaveModel;
using tracker.History;

class EditorData extends Model {

    @component public var history:History;

    @serialize public var projectUnsaved:Bool = false;

    @serialize public var projectPath:String = null;

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:EditorProjectData = new EditorProjectData();

    @observe public var images:ImmutableArray<String> = [];

    @observe public var texts:ImmutableArray<String> = [];

    @observe public var sounds:ImmutableArray<String> = [];

    @observe public var fonts:ImmutableArray<String> = [];

    @observe public var databases:ImmutableArray<String> = [];

    @observe public var fragments:ImmutableMap<String,EditorValue> = new Map();

    @observe public var pendingChoice:EditorPendingChoice = null;

    @observe public var statusMessage(default, null):String = null;

    @observe public var loading(default, null):Int = 0;

    var clearStatusMessageDelay:Void->Void = null;
    
    var ignoreUnsaved:Int = 0;

    var fragmentAutoruns:Array<Autorun> = null;

    public function new() {

        super();

        //this.loadFromKey('editor');
        this.autoSaveAsKey('editor');

        history = new History();
        history.step();

        serializer.onChangeset(this, changeset -> {
            if (ignoreUnsaved == 0)
                projectUnsaved = true;
        });

        autorun(updateFragments);

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

    public function newProject() {

        if (projectUnsaved) {
            Confirmation.confirm(
                'New project?',
                'Any unsaved change will be lost.\nDo you want to continue?',
                true,
                confirmed -> {
                    if (confirmed) {
                        incrementLoading();
                        projectPath = null;
                        project.clear();
                        markProjectNotUnsaved();
                        scheduleDecrementLoading();
                    }
                }
            );
        }
        else {
            incrementLoading();
            projectPath = null;
            project.clear();
            markProjectNotUnsaved();
            scheduleDecrementLoading();
        }

    }

    public function openProject(?file:String) {

        if (projectUnsaved) {
            Confirmation.confirm(
                'Open project?',
                'Any unsaved change will be lost.\nDo you want to continue?',
                true,
                confirmed -> {
                    if (confirmed) {
                        incrementLoading();
                        if (file != null) {
                            openProjectFromFilePath(file);
                        }
                        else {
                            openProjectDialog();
                        }
                        scheduleDecrementLoading();
                    }
                }
            );
        }
        else {
            if (file != null) {
                openProjectFromFilePath(file);
            }
            else {
                openProjectDialog();
            }
        }

    }

    function openProjectDialog() {

        Dialogs.openFile('Open project', [{
            name: 'Ceramic project', extensions: ['ceramic']
        }], file -> {
            if (file != null) {
                openProjectFromFilePath(file);
            }
        });

    }

    public function openProjectFromFilePath(file:String) {

        log.debug('open: $file');
        try {
            incrementLoading();
            var json = Json.parse(Files.getContent(file));
            projectPath = null;
            project.clear();
            project.fromJson(json);
            projectPath = file;
            project.title = Path.withoutExtension(Path.withoutDirectory(file));
            markProjectNotUnsaved();
            status('Using project from path: $projectPath');
            scheduleDecrementLoading();
        }
        catch (e:Dynamic) {
            Message.message(
                'Error',
                'Failed to open project at path:\n$file\n$e',
                true
            );
        }

    }

    public function saveProject(forceSaveAs:Bool = false) {

        if (projectPath != null && !forceSaveAs) {
            Files.saveContent(projectPath, Json.stringify(project.toJson(), null, '    '));
            markProjectNotUnsaved();
            status('Project saved at path: $projectPath');
        }
        else {
            Dialogs.saveFile('Save project', [{
                name: 'Ceramic project', extensions: ['ceramic']
            }], file -> {
                if (file != null) {
                    trace('Save as file: $file');
                    project.title = Path.withoutExtension(Path.withoutDirectory(file));
                    Files.saveContent(file, Json.stringify(project.toJson(), null, '    '));
                    projectPath = file;
                    markProjectNotUnsaved();
                    status('Project saved at path: $projectPath');
                }
            });
        }

    }

    function markProjectNotUnsaved() {

        projectUnsaved = false;
        ignoreUnsaved++;
        Timer.delay(this, 1.1, () -> {
            ignoreUnsaved--;
        });

    }

    function updateFragments() {

        var project = this.project;
        if (project == null)
            return;

        var projectFragments = project.fragments;
        if (projectFragments == null)
            return;

        unobserve();

        if (fragmentAutoruns != null) {
            for (auto in fragmentAutoruns) {
                auto.destroy();
            }
        }

        fragmentAutoruns = [];

        for (projectFragment in projectFragments) {
            fragmentAutoruns.push(projectFragment.autorun(function() {
                bindFragmentData(projectFragment);
            }));
        }

        reobserve();

    }

    function bindFragmentData(fragmentData:EditorFragmentData) {

        if (loading == 0 && fragmentData.freezeEditorChanges > 0)
            return;

        var fragmentId = fragmentData.fragmentId;

        unobserve();

        var value = this.fragments.get(fragmentId);
        if (value == null) {
            value = new EditorValue();
            var newFragments = new Map<String,EditorValue>();
            var existingIds = new Map<String,Bool>();
            for (existingFragment in project.fragments) {
                existingIds.set(existingFragment.fragmentId, true);
            }
            for (key => val in this.fragments.mutable) {
                if (existingIds.exists(key))
                    newFragments.set(key, val);
            }
            newFragments.set(fragmentId, value);
            this.fragments = cast newFragments;
        }

        reobserve();
        value.value = fragmentData.toFragmentData();
        unobserve();

        reobserve();

    }

    function incrementLoading() {

        loading++;

    }

    function scheduleDecrementLoading() {
        
        app.onceUpdate(this, _ -> {
            app.onceUpdate(this, _ -> {
                loading--;
            });
        });

    }

}
