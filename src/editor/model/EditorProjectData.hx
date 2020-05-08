package editor.model;

import haxe.iterators.DynamicAccessIterator;
import haxe.DynamicAccess;
import tracker.SerializeModel;

class EditorProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ImmutableArray<EditorFragmentData> = [];

    @serialize public var exportPath:String = null;

/// Settings

    @serialize public var colorPickerHsluv:Bool = false;

    @serialize public var paletteColors:ImmutableArray<Color> = [];

/// Computed data

    @compute public function defaultBundle():String {
        return TextUtils.slugify(title);
    }

/// UI info

    @serialize public var selectedFragmentIndex:Int = -1;

    public var selectedFragment(get,set):EditorFragmentData;
    function get_selectedFragment():EditorFragmentData {
        if (selectedFragmentIndex == -1) return null;
        return fragments[selectedFragmentIndex];
    }
    function set_selectedFragment(selectedFragment:EditorFragmentData):EditorFragmentData {
        selectedFragmentIndex = fragments.indexOf(selectedFragment);
        return selectedFragment;
    }

    public function new() {

        super();

    }

    public function clear() {

        title = 'New Project';

        clearFragments();

        colorPickerHsluv = false;

        paletteColors = [];

    }

    function clearFragments() {
        
        var prevFragments = fragments;
        selectedFragmentIndex = -1;
        fragments = [];
        for (fragment in prevFragments) {
            fragment.destroy();
        }

    }

    override function destroy() {

        super.destroy();

        clearFragments();

    }

/// Public API

    public function fragmentById(fragmentId:String):EditorFragmentData {

        for (i in 0...fragments.length) {
            var fragment = fragments[i];
            if (fragment.fragmentId == fragmentId) return fragment;
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

        var fragments = [].concat(this.fragments.mutable);
        fragments.push(fragment);
        this.fragments = cast fragments;

        model.history.step();

        return fragment;

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
        var paletteColors = [].concat(prevPaletteColors.mutable);
        paletteColors.push(color);
        this.paletteColors = cast paletteColors;

    }

    public function movePaletteColor(fromIndex:Int, toIndex:Int):Void {

        var paletteColors = [].concat(this.paletteColors.mutable);

        var colorToMove = paletteColors[fromIndex];

        paletteColors.splice(fromIndex, 1);
        paletteColors.insert(toIndex, colorToMove);

        this.paletteColors = cast paletteColors;

    }

    public function removePaletteColor(index:Int):Void {

        var paletteColors = [].concat(this.paletteColors.mutable);

        paletteColors.splice(index, 1);

        this.paletteColors = cast paletteColors;

    }

    public function toJson(projectPath:String):Dynamic {

        var projectDir = projectPath != null ? Path.directory(projectPath) : null;

        var json:Dynamic = {};

        json.title = title;

        json.paletteColors = paletteColors;
        json.colorPickerHsluv = colorPickerHsluv;
        json.selectedFragmentIndex = selectedFragmentIndex;

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

        if (json.selectedFragmentIndex != null) {
            if (!Validate.int(json.selectedFragmentIndex))
                throw 'Invalid project selected fragment index';

            selectedFragmentIndex = json.selectedFragmentIndex;
        }
        else {
            selectedFragmentIndex = -1;
        }
        if (selectedFragmentIndex >= fragments.length || selectedFragmentIndex < -1) {
            selectedFragmentIndex = -1;
        }

    }

}
