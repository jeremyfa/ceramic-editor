package editor.model.fragment;

import ceramic.ReadOnlyMap;

class EditorEntityData extends EditorBaseFragmentModel {

    @serialize public var entityId:String;

    @serialize public var entityClass:String;

    @serialize public var entityComponents:ReadOnlyMap<String, String> = new Map();

    @serialize public var props:EditorEntityProps;

    public function new(fragment:EditorFragmentData) {
        super(fragment);
        props = new EditorEntityProps(fragment);
    }

}
