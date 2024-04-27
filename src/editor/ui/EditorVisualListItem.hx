package editor.ui;

import editor.model.fragment.EditorVisualData;

class EditorVisualListItem {

    public var visual(default,null):EditorVisualData;

    public var title(get,never):String;
    function get_title():String {
        return visual.entityId;
    }

    public var subTitle(get,never):String;
    function get_subTitle():String {
        return '';
    }

    public var locked(get,never):Bool;
    function get_locked():Bool {
        return visual.locked;
    }

    public function new(visual:EditorVisualData) {
        this.visual = visual;
    }

}
