package editor.model;

import ceramic.Dialogs;
import ceramic.Files;
import ceramic.Path;
import ceramic.Timer;
import editor.model.fragment.EditorFragmentData;
import elements.Im;
import tracker.Model;

using StringTools;
using tracker.History;
using tracker.SaveModel;

class EditorData extends Model {

    @component public var history:History;

    @serialize public var project:EditorProjectData;

    @serialize public var projectUnsavedChanges:Bool = false;

    @serialize public var projectFilePath:String = null;

    @observe public var numUndo(default,null):Int = 0;

    @observe public var numRedo(default,null):Int = 0;

    public var didUndoOrRedo(default,null):Int = 0;

    var ignoreChanges:Int = 0;

    public function new() {

        super();

        newProject();

        this.loadFromKey('ceramic-fragments-editor');
        this.autoSaveAsKey('ceramic-fragments-editor');

        history = new History();
        history.step();
        history.onUndo(this, handleHistoryUndo);
        history.onRedo(this, handleHistoryRedo);

        serializer.onChangeset(this, changeset -> {
            if (ignoreChanges == 0)
                projectUnsavedChanges = true;
        });

    }

    function handleHistoryUndo() {

        numUndo++;

        didUndoOrRedo++;
        Timer.delay(this, 0.25, () -> {
            didUndoOrRedo--;
        });

    }

    function handleHistoryRedo() {

        numRedo++;

        didUndoOrRedo++;
        Timer.delay(this, 0.25, () -> {
            didUndoOrRedo--;
        });

    }

    function markChangesClean() {

        ignoreChanges++;
        projectUnsavedChanges = false;
        Timer.delay(this, serializer.checkInterval + 0.5, () -> {
            ignoreChanges--;
        });

    }

/// Open / Save / New

    public function openProject() {

        Dialogs.openFile('Open fragments file', [{
            name: 'Ceramic fragments file', extensions: ['fragments']
        }], file -> {
            if (file != null) {
                _openProject(file);
            }
        });

    }

    function _openProject(file:String) {

        try {
            var data = Files.getContent(file);
            var name = Path.withoutDirectory(Path.withoutExtension(file));

            var prevProject = project;
            var newProject = new EditorProjectData(this, name);

            if (data.startsWith('{')) {
                log.debug('Load fragments project with JSON format...');
                newProject.fromJson(haxe.Json.parse(data));
            }
            else {
                throw 'Invalid fragments project';
            }

            project = newProject;
            prevProject?.destroy();

            projectFilePath = file;

            markChangesClean();
        }
        catch (e:Dynamic) {
            Im.info('Invalid file', 'Failed to open file at path: $file');
            log.error(e);
        }

    }

    public function saveProjectAs() {

        saveProject(true);

    }

    public function saveProject(forceChooseFile:Bool = false) {

        if (projectFilePath == null || forceChooseFile) {
            Dialogs.saveFile('Save fragments file', [{
                name: 'Fragments file', extensions: ['fragments']
            }], file -> {
                if (file != null) {
                    projectFilePath = file;
                    project.name = Path.withoutDirectory(Path.withoutExtension(file));
                    saveProject();
                }
            });

            return;
        }

        app.oncePostFlushImmediate(this, () -> {
            var data = haxe.Json.stringify(project.toJson(), null, '  ');
            log.info('Save fragments project at path: ${projectFilePath}');
            Files.saveContent(projectFilePath, data);
            markChangesClean();
        });

    }

    public function newProject() {

        var prevProject = project;
        var newProject = new EditorProjectData(this);

        project = newProject;
        prevProject?.destroy();

        projectFilePath = null;

    }

}