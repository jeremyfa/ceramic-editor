package editor.ui;

import editor.model.fragment.EditorFragmentData;

class EditorFragmentListItem {

    public var fragment(default,null):EditorFragmentData;

    public var title(get,never):String;
    function get_title():String {
        return fragment.fragmentId;
    }

    public var subTitle(get,never):String;
    function get_subTitle():String {
        return '';
    }

    public var locked(get,never):Bool;
    function get_locked():Bool {
        return fragment.locked;
    }

    public function new(fragment:EditorFragmentData) {
        this.fragment = fragment;
    }

}
