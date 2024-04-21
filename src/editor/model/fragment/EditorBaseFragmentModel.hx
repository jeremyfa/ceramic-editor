package editor.model.fragment;

import tracker.History;

class EditorBaseFragmentModel extends EditorBaseModel {

    var history(get,never):History;
    function get_history():History {
        return fragment.project.history;
    }

    @serialize public var fragment:EditorFragmentData;

    public function new(fragment:EditorFragmentData) {
        super();
        this.fragment = fragment;
    }

}