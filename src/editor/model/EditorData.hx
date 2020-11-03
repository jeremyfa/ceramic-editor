package editor.model;

import tracker.Autorun;
import haxe.Json;
import haxe.DynamicAccess;

using tracker.SaveModel;
using tracker.History;

@:allow(editor.Editor)
class EditorData extends Model {

    @event function scriptLog(color:Color, message:String);

    @component public var history:History;

    @serialize public var projectUnsaved:Bool = false;

    @serialize public var projectPath:String = null;

    @serialize public var settings:EditorSettings = new EditorSettings();

    @observe public var theme:EditorTheme = new EditorTheme();

    @serialize public var project:EditorProjectData = new EditorProjectData();

    @observe public var images:ReadOnlyArray<String> = [];

    @observe public var texts:ReadOnlyArray<String> = [];

    @observe public var sounds:ReadOnlyArray<String> = [];

    @observe public var fonts:ReadOnlyArray<String> = [];

    @observe public var databases:ReadOnlyArray<String> = [];

    @observe public var shaders:ReadOnlyArray<String> = [];

    @observe public var fragments:ReadOnlyMap<String,EditorValue> = new Map();

    @observe public var scripts:ReadOnlyMap<String,EditorValue> = new Map();

    @observe public var pendingChoice:EditorPendingChoice = null;

    @observe public var pendingPrompt:EditorPendingPrompt = null;

    @observe public var statusMessage(default, null):String = null;

    @observe public var statusColor(default, null):Color = Color.WHITE;

    @observe public var loading(default, null):Int = 0;

    @observe public var location:EditorLocation = DEFAULT;

    @observe public var animationState:EditorAnimationState = new EditorAnimationState();

    @observe public var requireHighFps(default,null):Int = 0;

    @observe public var numUndo(default,null):Int = 0;

    @observe public var numRedo(default,null):Int = 0;

    public var didUndoOrRedo(default,null):Int = 0;

    public var lockKeyframes:Int = 0;

    var clearStatusMessageDelay:Void->Void = null;
    
    var ignoreUnsaved:Int = 0;

    var fragmentAutoruns:Array<Autorun> = null;

    var scriptAutoruns:Array<Autorun> = null;

    /**
     * Internal mapping used to prevent circular references when walking through nested fragment data
     */
    var referencedFragmentIds:Array<String> = [];

    public function new() {

        super();

        this.loadFromKey('editor');
        this.autoSaveAsKey('editor');

        history = new History();
        history.step();
        history.onUndo(this, handleHistoryUndo);
        history.onRedo(this, handleHistoryRedo);

        serializer.onChangeset(this, changeset -> {
            if (ignoreUnsaved == 0)
                projectUnsaved = true;
        });

        app.oncePostFlushImmediate(() -> {
            autorun(updateFragments);
            autorun(updateScripts);
        });

        bindScriptHandlers();

    }

    override function destroy() {

        super.destroy();

        Script.errorHandlers.remove(handleScriptError);
        Script.traceHandlers.remove(handleScriptTrace);

        trace('MODEL DESTROY');
        
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

    public function status(message:String, color:Color = Color.WHITE, duration:Float = 60) {

        if (clearStatusMessageDelay != null) {
            clearStatusMessageDelay();
        }

        this.statusColor = color;
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
                        animationState.currentFrame = 0;
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
            animationState.currentFrame = 0;
            projectPath = null;
            project.clear();
            markProjectNotUnsaved();
            scheduleDecrementLoading();
        }

    }

    public function openProject(?file:String, ?contents:String) {

        if (projectUnsaved) {
            Confirmation.confirm(
                'Open project?',
                'Any unsaved change will be lost.\nDo you want to continue?',
                true,
                confirmed -> {
                    if (confirmed) {
                        if (file != null && contents != null) {
                            openProjectFromNameAndContents(file, contents);
                        }
                        else if (file != null) {
                            openProjectFromFilePath(file);
                        }
                        else {
                            openProjectDialog();
                        }
                    }
                }
            );
        }
        else {
            if (file != null && contents != null) {
                openProjectFromNameAndContents(file, contents);
            }
            else if (file != null) {
                openProjectFromFilePath(file);
            }
            else {
                openProjectDialog();
            }
        }

    }

    function openProjectDialog() {

        log.debug('open project dialog');

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
            animationState.currentFrame = 0;
            projectPath = null;
            project.clear();
            project.fromJson(json, file);
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

    public function openProjectFromNameAndContents(name:String, contents:String) {

        log.debug('open: $name');
        try {
            incrementLoading();
            var json = Json.parse(contents);
            animationState.currentFrame = 0;
            projectPath = null;
            project.clear();
            project.fromJson(json, name);
            projectPath = name;
            project.title = Path.withoutExtension(name);
            markProjectNotUnsaved();
            status('Using project with name: $projectPath');
            scheduleDecrementLoading();
        }
        catch (e:Dynamic) {
            Message.message(
                'Error',
                'Failed to open project with name:\n$name\n$e',
                true
            );
        }

    }

    public function saveProject(forceSaveAs:Bool = false) {

        var webWithoutElectron = false;
        #if web
        if (PlatformSpecific.resolveElectron() == null) {
            webWithoutElectron = true;
        }
        #end
        if (webWithoutElectron) {
            #if web
            if (projectPath == null) {
                projectPath = 'Project.ceramic';
                project.title = 'Project';
            }
            var file = new js.html.File(
                [Json.stringify(project.toJson(projectPath), null, '  ')],
                Path.withoutDirectory(projectPath),
                { type: "text/plain;charset=utf-8" }
            );
            untyped saveAs(file);
            markProjectNotUnsaved();
            #end
        }
        else if (projectPath != null && !forceSaveAs) {
            Files.saveContent(projectPath, Json.stringify(project.toJson(projectPath), null, '  '));
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
                    Files.saveContent(file, Json.stringify(project.toJson(file), null, '  '));
                    projectPath = file;
                    markProjectNotUnsaved();
                    status('Project saved at path: $projectPath');
                }
            });
        }

    }

    public function play() {
        
        if (location == DEFAULT && project.lastSelectedFragment != null) {
            location = PLAY(project.lastSelectedFragment.fragmentId);
            function handlePlayEscape(key:Key) {
                if (key.scanCode == ScanCode.ESCAPE) {
                    input.offKeyDown(handlePlayEscape);
                    location = DEFAULT;
                }
            }
            input.onKeyDown(null, handlePlayEscape);
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
            for (key => val in this.fragments.original) {
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

    function updateScripts() {

        var project = this.project;
        if (project == null)
            return;

        var projectScripts = project.scripts;
        if (projectScripts == null)
            return;

        unobserve();

        scriptAutoruns = [];

        for (projectScript in projectScripts) {
            if (projectScript != null) {
                scriptAutoruns.push(projectScript.autorun(function() {
                    bindScriptData(projectScript);
                }));
            }
        }

        reobserve();

    }

    function bindScriptData(scriptData:EditorScriptData) {

        var scriptId = scriptData.scriptId;

        unobserve();

        var value = this.scripts.get(scriptId);
        if (value == null) {
            value = new EditorValue();
            var newScripts = new Map<String,EditorValue>();
            var existingIds = new Map<String,Bool>();
            for (existingScript in project.scripts) {
                existingIds.set(existingScript.scriptId, true);
            }
            for (key => val in this.scripts.original) {
                if (existingIds.exists(key))
                    newScripts.set(key, val);
            }
            newScripts.set(scriptId, value);
            this.scripts = cast newScripts;
        }

        reobserve();
        value.value = scriptData.content;
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

    inline public function pushUsedFragmentId(fragmentId:String) {
        
        referencedFragmentIds.push(fragmentId);

    }

    inline public function popUsedFragmentId():String {
        
        return referencedFragmentIds.pop();

    }

    inline public function isFragmentIdUsed(fragmentId:String):Bool {

        return referencedFragmentIds.indexOf(fragmentId) != -1;

    }

    public function canReferenceFragmentId(fragmentId:String, ?fragmentData:FragmentData):Bool {

        if (isFragmentIdUsed(fragmentId))
            return false;

        pushUsedFragmentId(fragmentId);

        if (fragmentData == null) {
            var fragmentValue:EditorValue = fragments.get(fragmentId);
            if (fragmentValue != null) {
                fragmentData = fragmentValue.value;
            }
        }

        if (fragmentData != null) {
            if (fragmentData.items != null) {
                var items = fragmentData.items;
                for (i in 0...items.length) {
                    var item = items[i];
                    if (item.entity == 'ceramic.Fragment') {
                        var props:Dynamic = item.props;
                        if (props != null) {
                            var fragmentData:FragmentData = props.fragmentData;
                            if (fragmentData != null) {
                                var fragmentId:String = fragmentData.id;
                                if (fragmentId != null) {
                                    var canReference = canReferenceFragmentId(fragmentId, fragmentData);
                                    if (!canReference) {
                                        popUsedFragmentId();
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        popUsedFragmentId();

        return true;

    }

    public function exportFragments():Void {

        var output:Map<String,DynamicAccess<FragmentData>> = new Map();

        var exportPath = project.exportPath;
        if (exportPath == null) {
            if (projectPath == null || !Path.isAbsolute(projectPath)) {
                Message.message(
                    'Error',
                    'Failed to resolve export path',
                    true
                );
                return;
            }
            exportPath = Path.directory(projectPath);
        }

        var defaultBundle = project.defaultBundle;

        for (fragment in project.fragments) {

            var bundle = fragment.bundle;
            var fragmentId = fragment.fragmentId;
            var fragmentData = fragment.toFragmentData();

            if (bundle == null) {
                bundle = defaultBundle;
            }

            var exportBundlePath = Path.join([exportPath, bundle]) + '.fragments';

            var bundleOutput = output.get(exportBundlePath);
            if (bundleOutput == null) {
                bundleOutput = {};
                output.set(exportBundlePath, bundleOutput);
            }
            bundleOutput.set(fragmentId, fragmentData);

        }

        try {
            for (exportBundlePath in output.keys()) {
                // Create directories if needed
                if (!Files.exists(Path.directory(exportBundlePath))) {
                    Files.createDirectory(Path.directory(exportBundlePath));
                }
                else if (!Files.isDirectory(Path.directory(exportBundlePath))) {
                    log.error('Cannot write fragment bundle at path $exportBundlePath because it is not inside a directory!');
                    continue;
                }

                // Save file
                Files.saveContent(
                    exportBundlePath,
                    Json.stringify(output.get(exportBundlePath), null, '  ')
                );
            }

            status('Exported fragments at path: $exportPath');
        }
        catch (e:Dynamic) {
            log.error('Failed to export fragment bundles: $e');
        }

    }

    public function didRenameFragment(renamed:EditorFragmentData, prevId:String, newId:String) {

        unobserve();

        // Update fragment references
        for (fragment in project.fragments) {
            for (item in fragment.items) {
                if (item.entityClass == 'ceramic.FragmentData') {
                    var key:String = item.props.get('fragmentData');
                    if (key != null && key == prevId) {
                        item.props.set('fragmentData', newId);
                    }
                }
            }
        }

        reobserve();

    }

    public function didRenameScript(renamed:EditorScriptData, prevId:String, newId:String) {

        // Update script references
        for (fragment in project.fragments) {
            for (item in fragment.items) {
                var key:String = item.props.get('scriptContent');
                if (key != null && key == prevId) {
                    item.props.set('scriptContent', newId);
                }
            }
        }

    }

    function bindScriptHandlers() {

        Script.errorHandlers.push(handleScriptError);
        Script.traceHandlers.push(handleScriptTrace);
        Script.log.onInfo(this, handleScriptLogInfo);
        Script.log.onDebug(this, handleScriptLogDebug);
        Script.log.onSuccess(this, handleScriptLogSuccess);
        Script.log.onWarning(this, handleScriptLogWarning);
        Script.log.onError(this, handleScriptLogError);
        
    }

    function handleScriptError(error:String, line:Int, char:Int) {

        status(error, Color.RED);

    }

    function handleScriptTrace(v:Dynamic, ?pos:haxe.PosInfos) {
        
        emitScriptLog(0xACACAC, '' + v);

    }

    function handleScriptLogInfo(v:Dynamic, ?pos:haxe.PosInfos) {
        
        emitScriptLog(0x14829D, '' + v);
        
    }

    function handleScriptLogDebug(v:Dynamic, ?pos:haxe.PosInfos) {
        
        emitScriptLog(0xA039A0, '' + v);
        
    }

    function handleScriptLogSuccess(v:Dynamic, ?pos:haxe.PosInfos) {
        
        emitScriptLog(0x0DBC79, '' + v);
        
    }

    function handleScriptLogWarning(v:Dynamic, ?pos:haxe.PosInfos) {
        
        emitScriptLog(0xADAD14, '' + v);
        
    }

    function handleScriptLogError(v:Dynamic, ?pos:haxe.PosInfos) {

        // Do not display parse script errors as log
        if (Std.is(v, String)) {
            var str:String = v;
            if (str.startsWith('Failed to parse script: ')) {
                return;
            }
        }
        
        emitScriptLog(0xC32F2F, '' + v);
        
    }

}
