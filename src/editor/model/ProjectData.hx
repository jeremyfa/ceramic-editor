package editor.model;

class ProjectData extends Model {

/// Main data

    @serialize public var title:String = 'New Project';

    @serialize public var fragments:ImmutableArray<EditorFragmentData> = [];

    @serialize public var assets:ImmutableArray<EditorAsset> = [];

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
        var fragments = [];
        for (i in 0...10) {
            var fragment = new EditorFragmentData();
            fragment.fragmentId = 'FRAGMENT_$i';
            fragment.name = 'Fragment $i\nBlah\n\n\nBlih blue, jérémy';
            fragments.push(fragment);
        }
        this.fragments = cast fragments;

    } //new

} //ProjectData
