package editor.model;

import ceramic.ReadOnlyArray;
import editor.model.fragment.EditorFragmentData;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorSidebarTab;
import tracker.History;
import tracker.Model;

class EditorProjectData extends Model {

    var editorData(default, null):EditorData;

    public var history(get,never):History;
    function get_history():History {
        return editorData.history;
    }

    @serialize public var name:String;

    @serialize public var displayName:String;

    @serialize public var fragments:ReadOnlyArray<EditorFragmentData> = [];

    @serialize public var selectedFragmentIndex:Int = -1;

    @serialize public var sidebarTab:EditorSidebarTab = NONE;

    @compute public function selectedFragment():EditorFragmentData {
        final selectedFragmentIndex = this.selectedFragmentIndex;
        if (selectedFragmentIndex >= 0) {
            return fragments[selectedFragmentIndex];
        }
        return null;
    }

    public function new(editorData:EditorData, name:String = 'Untitled') {
        super();

        this.editorData = editorData;
        this.name = name;
    }

    public function syncFromFragmentsList(fragmentsList:Array<EditorFragmentListItem>):Void {
        var result = [];
        for (fragmentItem in fragmentsList) {
            var fragment = getFragment(fragmentItem.fragment.fragmentId);
            result.push(fragment);
        }
        var prevFragments = this.fragments;
        this.fragments = result;
        for (fragment in prevFragments) {
            if (getFragment(fragment.fragmentId) == null) {
                fragment.destroy();
            }
        }
    }

    public function getFragment(fragmentId:String) {
        var fragments = this.fragments;
        for (i in 0...fragments.length) {
            if (fragments[i].fragmentId == fragmentId) {
                return fragments[i];
            }
        }
        return null;
    }

    public function addFragment() {

        var fragment = new EditorFragmentData(this);
        var i = 0;
        while (getFragment('FRAGMENT_$i') != null) {
            i++;
        }
        fragment.fragmentId = 'FRAGMENT_$i';

        var newFragments = [].concat(this.fragments.original);
        newFragments.push(fragment);
        this.fragments = newFragments;

        return fragment;

    }

    public function clear():Void {

        name = 'Untitled';
        displayName = null;

        var prevFragments = fragments;
        fragments = [];
        for (fragment in prevFragments) {
            fragment.destroy();
        }

    }

    public function fromJson(json:Dynamic):Void {

        clear();

    }

    public function toJson():Dynamic {
        var json:Dynamic = {};

        // TODO

        return json;
    }

}
