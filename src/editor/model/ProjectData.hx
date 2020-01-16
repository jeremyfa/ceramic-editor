package editor.model;

class ProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ImmutableArray<EditorFragmentData> = [];

    @serialize public var assets:ImmutableArray<EditorAsset> = [];

/// Settings

    @serialize public var colorPickerHsluv:Bool = false;

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

} //ProjectData
