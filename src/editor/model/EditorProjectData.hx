package editor.model;

import haxe.iterators.DynamicAccessIterator;
import haxe.DynamicAccess;
import tracker.SerializeModel;

class EditorProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ReadOnlyArray<EditorFragmentData> = [];

    @serialize public var scripts:ReadOnlyArray<EditorScriptData> = [];

    @serialize public var tilemaps:ReadOnlyArray<EditorTilemapData> = [];

    @serialize public var lastSelectedEasing:Easing = NONE;

    @compute public function editables():ReadOnlyArray<EditorEditableElementData> {
        var result:Array<EditorEditableElementData> = [];
        var fragments = this.fragments;
        for (i in 0...fragments.length) {
            result.push(fragments[i]);
        }
        /*
        var scripts = this.scripts;
        for (i in 0...scripts.length) {
            result.push(scripts[i]);
        }
        */
        var tilemaps = this.tilemaps;
        for (i in 0...tilemaps.length) {
            result.push(tilemaps[i]);
        }
        return cast result;
    }

    /*
    @serialize public var scripts:ReadOnlyArray<EditorScriptData> = [];


    @serialize public var tilesets:ReadOnlyArray<Tileset> = [];
    */

    @serialize public var exportPath:String = null;

/// Settings

    @serialize public var colorPickerHsluv:Bool = false;

    @serialize public var paletteColors:ReadOnlyArray<Color> = [];

/// Computed data

    @compute public function defaultBundle():String {
        return TextUtils.slugify(title);
    }

/// UI info

    @serialize public var selectedEditableIndex:Int = -1;

    @serialize public var lastSelectedFragmentIndex(default, null):Int = -1;

    public var lastSelectedFragment(get,never):EditorFragmentData;
    function get_lastSelectedFragment():EditorFragmentData {
        if (lastSelectedFragmentIndex == -1) return null;
        var item = fragments[lastSelectedFragmentIndex];
        if (item != null) {
            return item;
        }
        else {
            return null;
        }
    }

    public var selectedFragment(get,set):EditorFragmentData;
    function get_selectedFragment():EditorFragmentData {
        if (selectedEditableIndex == -1) return null;
        var item = editables[selectedEditableIndex];
        if (item != null && Std.is(item, EditorFragmentData)) {
            return cast item;
        }
        else {
            return null;
        }
    }
    function set_selectedFragment(selectedFragment:EditorFragmentData):EditorFragmentData {
        selectedEditableIndex = editables.indexOf(selectedFragment);
        lastSelectedFragmentIndex = fragments.indexOf(selectedFragment);
        return selectedFragment;
    }

    @serialize public var selectedScriptIndex:Int = -1;

    public var selectedScript(get,set):EditorScriptData;
    function get_selectedScript():EditorScriptData {
        if (selectedScriptIndex == -1) return null;
        var item = scripts[selectedScriptIndex];
        if (item != null) {
            return item;
        }
        else {
            return null;
        }
    }
    function set_selectedScript(selectedScript:EditorScriptData):EditorScriptData {
        selectedScriptIndex = scripts.indexOf(selectedScript);
        return selectedScript;
    }

    public function new() {

        super();

    }

    public function clear() {

        title = 'New Project';

        clearEditables();

        colorPickerHsluv = false;

        paletteColors = [];

    }

    function clearEditables() {
        
        var prevEditables = this.editables;

        selectedEditableIndex = -1;
        
        fragments = [];
        tilemaps = [];

        for (editable in prevEditables) {
            editable.destroy();
        }

    }

    override function destroy() {

        super.destroy();

        clearEditables();

    }

/// Public API

    public function fragmentById(fragmentId:String):EditorFragmentData {

        for (i in 0...fragments.length) {
            var fragment = fragments[i];
            if (fragment.fragmentId == fragmentId) return fragment;
        }

        return null;

    }

    public function scriptById(scriptId:String):EditorScriptData {

        for (i in 0...scripts.length) {
            var script = scripts[i];
            if (script.scriptId == scriptId) return script;
        }

        return null;

    }

    public function addFragment():EditorFragmentData {

        // Compute fragment id
        var i = 0;
        while (fragmentById('FRAGMENT_$i') != null) {
            i++;
        }

        // Create and add fragment data
        //
        var fragment = new EditorFragmentData();
        fragment.fragmentId = 'FRAGMENT_$i';
        fragment.width = 800;
        fragment.height = 600;

        var fragments = [].concat(this.fragments.original);
        fragments.push(fragment);
        this.fragments = cast fragments;

        model.history.step();

        return fragment;

    }

    public function removeFragment(fragment:EditorFragmentData):Void {

        var fragments = [].concat(this.fragments.original);
        fragments.remove(fragment);
        this.fragments = cast fragments;

        model.history.step();

    }

    public function duplicateFragment(fragment:EditorFragmentData):Void {

        var jsonFragment = fragment.toJson();

        // Compute duplicated id
        var i = 0;
        var prefix = TextUtils.getPrefix(fragment.fragmentId);
        while (fragmentById(prefix + '_' + i) != null) {
            i++;
        }
        jsonFragment.id = prefix + '_' + i;

        // Create instance
        var duplicatedFragment = new EditorFragmentData();
        duplicatedFragment.fromJson(jsonFragment);

        var fragments = [].concat(this.fragments.original);
        fragments.insert(fragments.indexOf(fragment) + 1, duplicatedFragment);
        this.fragments = cast fragments;

        selectedFragment = duplicatedFragment;

    }

    public function addScript():EditorScriptData {

        // Compute fragment id
        var i = 0;
        while (scriptById('SCRIPT_$i') != null) {
            i++;
        }

        // Create and add fragment data
        //
        var script = new EditorScriptData();
        script.scriptId = 'SCRIPT_$i';
        script.content = '';

        var scripts = [].concat(this.scripts.original);
        scripts.push(script);
        this.scripts = cast scripts;

        model.history.step();

        return script;

    }

    public function removeScript(script:EditorScriptData):Void {

        var scripts = [].concat(this.scripts.original);
        scripts.remove(script);
        this.scripts = cast scripts;

        model.history.step();

    }

    public function duplicateScript(script:EditorScriptData):Void {

        var jsonScript = script.toJson();

        // Compute duplicated id
        var i = 0;
        var prefix = TextUtils.getPrefix(script.scriptId);
        while (scriptById(prefix + '_' + i) != null) {
            i++;
        }
        jsonScript.id = prefix + '_' + i;

        // Create instance
        var duplicatedScript = new EditorScriptData();
        duplicatedScript.fromJson(jsonScript);

        var scripts = [].concat(this.scripts.original);
        scripts.insert(scripts.indexOf(script) + 1, duplicatedScript);
        this.scripts = cast scripts;

        selectedScript = duplicatedScript;

    }

    public function addPaletteColor(color:Color, forbidDuplicate:Bool = true):Void {

        var prevPaletteColors = this.paletteColors;

        // Ensure the color is not already listed if needed
        if (forbidDuplicate) {
            for (i in 0...prevPaletteColors.length) {
                if (color == prevPaletteColors[i]) {
                    log.warning('Cannot add color $color in palette because it already exists. Ignoring.');
                    return;
                }
            }
        }

        // Add color
        var paletteColors = [].concat(prevPaletteColors.original);
        paletteColors.push(color);
        this.paletteColors = cast paletteColors;

    }

    public function movePaletteColor(fromIndex:Int, toIndex:Int):Void {

        var paletteColors = [].concat(this.paletteColors.original);

        var colorToMove = paletteColors[fromIndex];

        paletteColors.splice(fromIndex, 1);
        paletteColors.insert(toIndex, colorToMove);

        this.paletteColors = cast paletteColors;

    }

    public function removePaletteColor(index:Int):Void {

        var paletteColors = [].concat(this.paletteColors.original);

        paletteColors.splice(index, 1);

        this.paletteColors = cast paletteColors;

    }

    public function toJson(projectPath:String):Dynamic {

        var projectDir = projectPath != null ? Path.directory(projectPath) : null;

        var json:Dynamic = {};

        json.title = title;

        json.paletteColors = paletteColors;
        json.colorPickerHsluv = colorPickerHsluv;
        json.selectedEditableIndex = selectedEditableIndex;
        json.lastSelectedFragmentIndex = lastSelectedFragmentIndex;
        json.selectedScriptIndex = selectedScriptIndex;
        json.lastSelectedEasing = EasingUtils.easingToString(lastSelectedEasing);

        if (exportPath != null) {
            if (projectDir != null) {
                json.exportPath = Files.getRelativePath(exportPath, projectDir);
            }
            else {
                json.exportPath = exportPath;
            }
        }
        else {
            json.exportPath = null;
        }

        var jsonFragments = [];
        for (fragment in fragments) {
            jsonFragments.push(fragment.toJson());
        }
        json.fragments = jsonFragments;

        var jsonScripts = [];
        for (script in scripts) {
            jsonScripts.push(script.toJson());
        }
        json.scripts = jsonScripts;

        return json;

    }

    public function fromJson(json:Dynamic, projectPath:String):Void {

        if (!Validate.nonEmptyString(json.title))
            throw 'Invalid project title';

        var projectDir = projectPath != null ? Path.directory(projectPath) : null;

        title = json.title;

        if (json.paletteColors != null) {
            if (!Validate.colorArray(json.paletteColors))
                throw 'Invalid project palette';
            
            paletteColors = json.paletteColors;
        }
        else {
            paletteColors = [];
        }

        if (json.colorPickerHsluv != null) {
            if (!Validate.boolean(json.colorPickerHsluv))
                throw 'Invalid project hsluv state';
            
            colorPickerHsluv = json.colorPickerHsluv;
        }
        else {
            colorPickerHsluv = false;
        }

        if (json.exportPath != null) {
            var exportPathStr:String = json.exportPath;
            if (projectDir != null && !Path.isAbsolute(exportPathStr)) {
                exportPath = Path.join([projectDir, exportPathStr]);
            }
            else {
                exportPath = exportPathStr;
            }
        }
        else {
            exportPath = null;
        }

        if (json.fragments != null) {
            if (!Validate.array(json.fragments))
                throw 'Invalid project fragments';

            var jsonFragments:Array<Dynamic> = json.fragments;
            var parsedFragments = [];
            for (jsonFragment in jsonFragments) {
                var fragment = new EditorFragmentData();
                fragment.fromJson(jsonFragment);
                parsedFragments.push(fragment);
            }
            fragments = cast parsedFragments;
        }
        else {
            fragments = [];
        }

        if (json.scripts != null) {
            if (!Validate.array(json.scripts))
                throw 'Invalid project scripts';

            var jsonScripts:Array<Dynamic> = json.scripts;
            var parsedScripts = [];
            for (jsonScript in jsonScripts) {
                var script = new EditorScriptData();
                script.fromJson(jsonScript);
                parsedScripts.push(script);
            }
            scripts = cast parsedScripts;
        }
        else {
            scripts = [];
        }

        if (json.selectedEditableIndex != null) {
            if (!Validate.int(json.selectedEditableIndex))
                throw 'Invalid project selected editable index';

            selectedEditableIndex = json.selectedEditableIndex;
        }
        else {
            selectedEditableIndex = -1;
        }
        if (selectedEditableIndex >= editables.length || selectedEditableIndex < -1) {
            selectedEditableIndex = -1;
        }

        if (json.lastSelectedFragmentIndex != null) {
            if (!Validate.int(json.lastSelectedFragmentIndex))
                throw 'Invalid project last selected fragment index';

            lastSelectedFragmentIndex = json.lastSelectedFragmentIndex;
        }
        else {
            lastSelectedFragmentIndex = -1;
        }
        if (lastSelectedFragmentIndex >= fragments.length || lastSelectedFragmentIndex < -1) {
            lastSelectedFragmentIndex = -1;
        }

        if (json.selectedScriptIndex != null) {
            if (!Validate.int(json.selectedScriptIndex))
                throw 'Invalid project last selected script index';

            selectedScriptIndex = json.selectedScriptIndex;
        }
        else {
            selectedScriptIndex = -1;
        }
        if (selectedScriptIndex >= scripts.length || selectedScriptIndex < -1) {
            selectedScriptIndex = -1;
        }

        if (json.lastSelectedEasing != null) {
            var easing = EasingUtils.easingFromString(json.lastSelectedEasing);
            if (easing == null) {
                throw 'Invalid project last selected easing';
            }
            lastSelectedEasing = easing;
        }

    }

}
