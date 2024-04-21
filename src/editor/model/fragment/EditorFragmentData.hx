package editor.model.fragment;

import ceramic.ReadOnlyArray;
import ceramic.ReadOnlyMap;
import clay.Utils;
import editor.ui.EditorFragmentListItem;

class EditorFragmentData extends EditorBaseModel {

    /**
     * List item for UI
     */
    public var listItem:EditorFragmentListItem;

    /**
     * The project on which this fragment is attached to
     */
    @serialize public var project(default, null):EditorProjectData;

    /**
     * Fragment id
     */
    @serialize public var fragmentId:String;

    /**
     * Fragment locked
     */
    @serialize public var locked:Bool;

    /**
     * Fragment width
     */
    @serialize public var width:Int;

    /**
     * Fragment height
     */
    @serialize public var height:Int;

    /**
     * Fragments items
     */
    @serialize public var items:ReadOnlyArray<EditorEntityData> = [];

    /**
     * Fragment components
     */
    @serialize public var fragmentComponents:ReadOnlyMap<String, String> = new Map();

    public function new(project:EditorProjectData) {
        super();

        this.fragmentId = Utils.uniqueId();
        this.listItem = new EditorFragmentListItem(this);
        this.project = project;
    }

    override function didDeserialize() {
        this.listItem = new EditorFragmentListItem(this);
    }

    public function clone(?toFragment:EditorFragmentData) {

        if (toFragment == null)
            toFragment = new EditorFragmentData(project);

        toFragment.width = width;
        toFragment.height = height;

        var items = [];
        for (item in this.items) {
            // TODO
            //items.push(item.clone());
        }
        toFragment.items = items;

        var fragmentComponents = new Map();
        for (key => val in this.fragmentComponents) {
            fragmentComponents.set(key, val);
        }
        toFragment.fragmentComponents = fragmentComponents;
    }

}

