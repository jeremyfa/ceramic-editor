package editor.model;

class ProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ImmutableArray<EditorFragmentData> = [];

    @serialize public var assets:ImmutableArray<EditorAsset> = [];

/// Settings

    @serialize public var colorPickerHsluv:Bool = false;

    @serialize public var paletteColors:ImmutableArray<Color> = [];/*(() -> {
        var res = [];
        for (i in 0...40)
            res.push(Color.random());
        return res;
    })();*/

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

        // Dummy fragments
        /*var fragments = [];
        for (i in 0...10) {
            var fragment = new EditorFragmentData();
            fragment.fragmentId = 'FRAGMENT_$i';
            fragment.name = 'Fragment $i';
            fragment.width = 800;
            fragment.height = 600;
            fragments.push(fragment);
        }
        this.fragments = cast fragments;*/

    } //new

/// Public API

    public function fragmentById(fragmentId:String):EditorFragmentData {

        for (i in 0...fragments.length) {
            var fragment = fragments[i];
            if (fragment.fragmentId == fragmentId) return fragment;
        }

        return null;

    } //fragmentById

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

        return fragment;

    } //addFragment

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

    } //addPaletteColor

    public function movePaletteColor(fromIndex:Int, toIndex:Int):Void {

        var paletteColors = [].concat(this.paletteColors.mutable);

        var colorToMove = paletteColors[fromIndex];

        paletteColors.splice(fromIndex, 1);
        paletteColors.insert(toIndex, colorToMove);

        this.paletteColors = cast paletteColors;

    } //movePaletteColor

    public function removePaletteColor(index:Int):Void {

        var paletteColors = [].concat(this.paletteColors.mutable);

        paletteColors.splice(index, 1);

        this.paletteColors = cast paletteColors;

    } //removePaletteColor

} //ProjectData
