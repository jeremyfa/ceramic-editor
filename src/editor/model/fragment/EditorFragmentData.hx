package editor.model.fragment;

import ceramic.Color;
import ceramic.ReadOnlyArray;
import ceramic.ReadOnlyMap;
import ceramic.Utils;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorVisualListItem;
import elements.TextUtils;

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
    @serialize public var fragmentId(default, set):String;
    function set_fragmentId(fragmentId:String):String {
        if (this.fragmentId != fragmentId) {
            this.fragmentId = fragmentId;
            edit_fragmentId = fragmentId;
        }
        return fragmentId;
    }
    public var edit_fragmentId:String;

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
     * Whether the fragment is transparent or not
     */
    @serialize public var transparent:Bool = true;

    /**
     * Background color (if not transparent)
     */
    @serialize public var color:Color = Color.BLACK;

    /**
     * Fragments entities (the ones that are not visuals)
     */
    @serialize public var entities:ReadOnlyArray<EditorEntityData> = [];

    /**
     * Fragments visuals
     */
    @serialize public var visuals:ReadOnlyArray<EditorVisualData> = [];

    /**
     * Fragment components
     */
    @serialize public var fragmentComponents:ReadOnlyMap<String, String> = new Map();

    @serialize public var selectedVisualIndex:Int = -1;

    @compute public function selectedVisual():EditorVisualData {
        final selectedVisualIndex = this.selectedVisualIndex;
        if (selectedVisualIndex >= 0) {
            return visuals[selectedVisualIndex];
        }
        return null;
    }

    public function deselectVisual():Void {
        this.selectedVisualIndex = -1;
    }

    public function selectVisual(visual:EditorVisualData):Void {
        this.selectedVisualIndex = visuals.indexOf(visual);
    }

    public function new(project:EditorProjectData) {
        super();

        this.project = project;
        this.fragmentId = Utils.uniqueId();
        this.width = 800;
        this.height = 600;

        init();
    }

    override function didDeserialize() {
        super.didDeserialize();
        init();
    }

    function init() {
        this.listItem = new EditorFragmentListItem(this);

        autorun(autoDeselectLockedVisual);
        autorun(autoUpdateVisualsDepth);
    }

    function autoDeselectLockedVisual() {

        final selectedVisual = this.selectedVisual;
        unobserve();

        if (selectedVisual != null && selectedVisual.locked) {
            this.deselectVisual();
        }

    }

    function autoUpdateVisualsDepth() {

        final visuals = this.visuals;
        unobserve();

        var depth = visuals.length;
        for (i in 0...visuals.length) {
            final visual = visuals[i];
            visual.depth = depth--;
        }

    }

    public function syncFromVisualsList(visualsList:Array<EditorVisualListItem>):Void {
        var result = [];
        for (visualItem in visualsList) {
            var visual = getVisual(visualItem.visual.entityId);
            result.push(visual);
        }
        var prevVisuals = this.visuals;
        this.visuals = result;
        for (visual in prevVisuals) {
            if (getVisual(visual.entityId) == null) {
                visual.destroy();
            }
        }
    }

    public function getVisual(entityId:String) {
        var visuals = this.visuals;
        for (i in 0...visuals.length) {
            if (visuals[i].entityId == entityId) {
                return visuals[i];
            }
        }
        return null;
    }

    public function getEntity(entityId:String) {
        var entities = this.entities;
        for (i in 0...entities.length) {
            if (entities[i].entityId == entityId) {
                return entities[i];
            }
        }
        return null;
    }

    public function getVisualOrEntity(entityId:String) {
        var result:EditorEntityData = getVisual(entityId);
        if (result == null) {
            result = getEntity(entityId);
        }
        return result;
    }

    public function addVisual() {

        var visual = new EditorVisualData(this);
        var i = 0;
        while (getVisual('VISUAL_$i') != null) {
            i++;
        }
        visual.entityId = 'VISUAL_$i';

        var newVisuals = [].concat(this.visuals.original);
        newVisuals.push(visual);
        this.visuals = newVisuals;

        return visual;

    }

    public function changeFragmentId(newFragmentId:String) {
        final prevFragmentId = this.unobservedFragmentId;
        if (prevFragmentId != newFragmentId) {
            newFragmentId = TextUtils.sanitizeToIdentifier(newFragmentId);
            if (prevFragmentId != newFragmentId) {
                var baseFragmentId = newFragmentId;
                var existing = project.getFragment(newFragmentId);
                var i = 0;
                while (existing != null && existing != this) {
                    newFragmentId = baseFragmentId + '_' + i;
                    i++;
                    existing = project.getFragment(newFragmentId);
                }
                this.fragmentId = newFragmentId;
            }
        }
        return newFragmentId;
    }

    public function clone(?toFragment:EditorFragmentData) {

        if (toFragment == null)
            toFragment = new EditorFragmentData(project);

        toFragment.width = width;
        toFragment.height = height;

        var visuals = [];
        for (visual in this.visuals) {
            // TODO
            //items.push(item.clone());
        }
        toFragment.visuals = visuals;

        var fragmentComponents = new Map();
        for (key => val in this.fragmentComponents) {
            fragmentComponents.set(key, val);
        }
        toFragment.fragmentComponents = fragmentComponents;
    }

}

