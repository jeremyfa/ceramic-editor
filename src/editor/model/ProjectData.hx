package editor.model;

import haxe.iterators.DynamicAccessIterator;
import haxe.DynamicAccess;
import tracker.SerializeModel;

class ProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ImmutableArray<EditorFragmentData> = [];

/// Settings

    @serialize public var colorPickerHsluv:Bool = false;

    @serialize public var paletteColors:ImmutableArray<Color> = [];

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
        fragment.name = 'Fragment $i';
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

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.title = title;

        json.paletteColors = paletteColors;
        json.colorPickerHsluv = colorPickerHsluv;
        json.selectedFragmentIndex = selectedFragmentIndex;

        var jsonFragments = [];
        for (fragment in fragments) {
            jsonFragments.push(fragment.toJson());
        }
        json.fragments = jsonFragments;

        return json;

    }

}
