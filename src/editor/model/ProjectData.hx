package editor.model;

class ProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:Array<EditorFragmentData> = [];

    @serialize public var assets:Array<EditorAsset> = [];

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

    } //new

} //ProjectData
