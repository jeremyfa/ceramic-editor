package editor.model.fragment;

import ceramic.Color;
import ceramic.ReadOnlyArray;
import ceramic.ReadOnlyMap;
import ceramic.Utils;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorVisualListItem;
import editor.utils.Regex;
import editor.utils.Validate;
import elements.TextUtils;

using StringTools;

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

    @serialize public var selectedEntityIndex:Int = -1;

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

    public function addVisual(?visualClass:Class<EditorVisualData>) {

        var visual:EditorVisualData = if (visualClass != null) {
            Type.createInstance(visualClass, [this]);
        }
        else {
            new EditorVisualData(this);
        }

        final prefix = Utils.camelCaseToUpperCase(visual.kind);

        var i = 0;
        while (getVisual(prefix + '_' + i) != null) {
            i++;
        }
        visual.entityId = prefix + '_' + i;

        var newVisuals = [].concat(this.visuals.original);
        newVisuals.push(visual);
        this.visuals = newVisuals;

        return visual;

    }

    public function addQuad() {

        var visual = new EditorQuadData(this);
        var i = 0;
        while (getVisual('QUAD_$i') != null) {
            i++;
        }
        visual.entityId = 'QUAD_$i';

        var newVisuals = [].concat(this.visuals.original);
        newVisuals.push(visual);
        this.visuals = newVisuals;

        return visual;

    }

    public function addText() {

        // TODO
        /*
        var visual = new EditorQuadData(this);
        var i = 0;
        while (getVisual('QUAD_$i') != null) {
            i++;
        }
        visual.entityId = 'QUAD_$i';

        var newVisuals = [].concat(this.visuals.original);
        newVisuals.push(visual);
        this.visuals = newVisuals;

        return visual;
        */
        return null;

    }

    public function changeFragmentId(newFragmentId:String) {
        final prevFragmentId = this.unobservedFragmentId;
        if (prevFragmentId != newFragmentId) {
            newFragmentId = TextUtils.sanitizeToIdentifier(newFragmentId);
            if (prevFragmentId != newFragmentId) {
                var i = 0;
                var baseId = newFragmentId;
                if (RE_NUMBER_SUFFIX.match(baseId)) {
                    baseId = baseId.substr(0, baseId.length - RE_NUMBER_SUFFIX.matched(1).length - 1);
                    i = Std.parseInt(RE_NUMBER_SUFFIX.matched(1));
                }
                var existing = project.getFragment(newFragmentId);
                var i = 0;
                while (existing != null && existing != this) {
                    newFragmentId = baseId + '_' + i;
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

        toFragment.fromJson(toJson());

    }

    public function clear():Void {

        fragmentId = Utils.uniqueId();
        locked = false;
        width = 800;
        height = 600;
        transparent = true;
        color = Color.BLACK;

        var prevEntities = entities;
        entities = [];
        for (entity in prevEntities) {
            entity.destroy();
        }

        var prevVisuals = visuals;
        visuals = [];
        for (visual in prevVisuals) {
            visual.destroy();
        }

        fragmentComponents = new Map();
        selectedVisualIndex = -1;
        selectedEntityIndex = -1;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid fragment id: ' + json.id;
        this.fragmentId = json.id;

        if (Reflect.hasField(json, 'locked')) {
            if (!Validate.boolean(json.locked)) {
                throw 'Invalid fragment locked value: ' + json.locked;
            }
            this.locked = json.locked;
        }

        if (!Validate.intDimension(json.width)) {
            throw 'Invalid fragment width: ' + json.width;
        }
        this.width = Std.int(json.width);

        if (!Validate.intDimension(json.height)) {
            throw 'Invalid fragment height: ' + json.height;
        }
        this.height = Std.int(json.height);

        if (Reflect.hasField(json, 'transparent')) {
            if (!Validate.boolean(json.transparent)) {
                throw 'Invalid fragment transparent value: ' + json.transparent;
            }
            this.transparent = json.transparent;
        }

        if (Reflect.hasField(json, 'color')) {
            if (!Validate.webColor(json.color)) {
                throw 'Invalid fragment color: ' + json.color;
            }
            this.color = Color.fromString(json.color);
        }

        if (Reflect.hasField(json, 'entities')) {
            if (!Validate.array(json.entities))
                throw 'Invalid fragment entities';

            var jsonEntities:Array<Dynamic> = json.entities;
            var parsedEntities = [];
            for (jsonEntity in jsonEntities) {
                if (jsonEntity == null || jsonEntity.kind == null) {
                    throw 'Invalid fragment entity';
                }
                var entity = switch jsonEntity.kind {
                    case 'entity': new EditorEntityData(this);
                    case _:
                        throw 'Unknown fragment entity kind: ' + jsonEntity.kind;
                }
                entity.fromJson(jsonEntity);
                parsedEntities.push(entity);
            }
            this.entities = cast parsedEntities;
        }
        else {
            this.entities = [];
        }

        if (Reflect.hasField(json, 'visuals')) {
            if (!Validate.array(json.visuals))
                throw 'Invalid fragment visuals';

            var jsonVisuals:Array<Dynamic> = json.visuals;
            var parsedVisuals = [];
            for (jsonVisual in jsonVisuals) {
                if (jsonVisual == null || jsonVisual.kind == null) {
                    throw 'Invalid fragment visual';
                }
                var visual = switch jsonVisual.kind {
                    case 'visual': new EditorVisualData(this);
                    case 'quad': new EditorQuadData(this);
                    case _:
                        throw 'Unknown fragment visual kind: ' + jsonVisual.kind;
                }
                visual.fromJson(jsonVisual);
                parsedVisuals.push(visual);
            }
            this.visuals = cast parsedVisuals;
        }
        else {
            this.visuals = [];
        }

        var fragmentComponents = new Map<String,String>();
        if (Reflect.hasField(json, 'components')) {
            for (key in Reflect.fields(json.components)) {
                fragmentComponents.set(key, Reflect.field(json.components, key));
            }
        }
        this.fragmentComponents = fragmentComponents;

        var selectedEntityIndex = -1;
        if (Reflect.hasField(json, 'selectedEntity')) {
            if (!Validate.int(json.selectedEntity))
                throw 'Invalid fragment selected entity';

            selectedEntityIndex = Std.int(json.selectedEntity);
        }
        else {
            selectedEntityIndex = -1;
        }
        if (selectedEntityIndex >= entities.length || selectedEntityIndex < -1) {
            selectedEntityIndex = -1;
        }
        this.selectedEntityIndex = selectedEntityIndex;

        var selectedVisualIndex = -1;
        if (Reflect.hasField(json, 'selectedVisual')) {
            if (!Validate.int(json.selectedVisual))
                throw 'Invalid fragment selected visual';

            selectedVisualIndex = Std.int(json.selectedVisual);
        }
        else {
            selectedVisualIndex = -1;
        }
        if (selectedVisualIndex >= visuals.length || selectedVisualIndex < -1) {
            selectedVisualIndex = -1;
        }
        this.selectedVisualIndex = selectedVisualIndex;

    }

    public function toJson():Dynamic {
        var json:Dynamic = {};

        json.kind = 'fragment';
        json.locked = (this.locked == true);
        json.width = this.width;
        json.height = this.height;
        json.transparent = (this.transparent == true);
        json.color = this.color.toWebString();
        json.selectedVisual = this.selectedVisualIndex;
        json.selectedEntity = this.selectedEntityIndex;

        var jsonComponents:Dynamic = {};
        for (key => val in this.fragmentComponents) {
            Reflect.setField(jsonComponents, key, val);
        }
        json.components = jsonComponents;

        json.entities = this.entities.map(entity -> entity.toJson());
        json.visuals = this.visuals.map(visual -> visual.toJson());

        return json;
    }

}

