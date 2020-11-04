package editor.model;

import haxe.ds.ArraySort;

class EditorFragmentData extends EditorEditableElementData {

/// Main data

    /**
     * Fragment id
     */
    @serialize public var fragmentId:String;

    /**
     * Fragment width
     */
    @serialize public var width:Int;

    /**
     * Fragment height
     */
    @serialize public var height:Int;

    /**
     * Scaling when fragment is viewed fullscreen
     */
    @serialize public var screenScaling:ScreenScaling = FIT;

    /**
     * Whether the fragment is transparent or not
     */
    @serialize public var transparent:Bool = true;

    /**
     * Whether the fragment's background overflows its whole container area
     * when it is a root fragment / fullscreen fragment
     */
    @serialize public var overflow:Bool = false;

    /**
     * Background color (if not transparent)
     */
    @serialize public var color:Color = Color.BLACK;

    /**
     * The bundle name this fragment belongs to.
     * A fragment bundle is a file where one ore more fragments are saved together.
     * An empty value with save fragments into default bundle.
     */
    @serialize public var bundle:String;

    /**
     * Fragments items
     */
    @serialize public var items:ReadOnlyArray<EditorEntityData> = [];

    @serialize public var selectedItemIndex:Int = -1;

    @serialize public var fragmentComponents:Map<String, String> = new Map();

    var lockSortItems:Bool = false;

    public var selectedItem(get,set):EditorEntityData;
    function get_selectedItem():EditorEntityData {
        if (selectedItemIndex >= 0) return items[selectedItemIndex];
        return null;
    }
    function set_selectedItem(selectedItem:EditorEntityData):EditorEntityData {
        selectedItemIndex = items.indexOf(selectedItem);
        return selectedItem;
    }

    public var selectedVisual(get,set):EditorVisualData;
    function get_selectedVisual():EditorVisualData {
        var selectedItem = this.selectedItem;
        if (Std.is(selectedItem, EditorVisualData)) return cast selectedItem;
        return null;
    }
    function set_selectedVisual(selectedVisual:EditorVisualData):EditorVisualData {
        selectedItem = selectedVisual;
        return selectedVisual;
    }

    @compute public function selectedVisualIndex():Int {

        var item = this.selectedItem;
        if (item == null || !Std.is(item, EditorVisualData)) {
            return -1;
        }
        else {
            return visuals.indexOf(cast item);
        }

    }

    @compute public function visuals():Array<EditorVisualData> {

        var result:Array<EditorVisualData> = [];
        for (i in 0...items.length) {
            var item = items[i];
            if (Std.is(item, EditorVisualData)) {
                result.push(cast item);
            }
        }
        return result;

    }

    public var selectedEntity(get,set):EditorEntityData;
    function get_selectedEntity():EditorEntityData {
        var selectedItem = this.selectedItem;
        if (!Std.is(selectedItem, EditorVisualData)) return selectedItem;
        return null;
    }
    function set_selectedEntity(selectedEntity:EditorEntityData):EditorEntityData {
        selectedItem = selectedEntity;
        return selectedEntity;
    }

    @compute public function selectedEntityIndex():Int {

        var item = this.selectedItem;
        if (item == null || Std.is(item, EditorVisualData)) {
            return -1;
        }
        else {
            return entities.indexOf(item);
        }

    }

    @compute public function entities():Array<EditorEntityData> {

        var result:Array<EditorEntityData> = [];
        for (i in 0...items.length) {
            var item = items[i];
            if (!Std.is(item, EditorVisualData)) {
                result.push(item);
            }
        }
        return result;

    }

/// Computed fragment data

    @observe public var fragmentDataWithoutItems(default, null):FragmentData = null;

    @:allow(editor.model.EditorEntityData)
    @observe public var freezeEditorChanges(default, null):Int = 0;

/// Lifecycle

    var didInit = false;

    public function new() {

        super();

        if (!didInit)
            init();

    }

    override function destroy() {

        super.destroy();

        var prevItems = items;
        items = null;
        selectedItemIndex = -1;
        for (item in prevItems) {
            item.destroy();
        }

        fragmentDataWithoutItems = null;

    }

    override function didDeserialize() {

        if (!didInit)
            init();

    }

    function init() {

        didInit = true;

        /*
        // Reset computed values when their source value changes
        onItemsChange(this, function(_, _) {
            visuals = null;
            entities = null;
            selectedVisualIndex = -2;
            selectedEntityIndex = -2;
        });
        onSelectedItemIndexChange(this, function(newValue, prevValue) {
            selectedVisualIndex = -2;
            selectedEntityIndex = -2;
        });
        */

        fragmentDataWithoutItems = {
            id: null,
            width: 0.0,
            height: 0.0,
            color: Color.BLACK,
            transparent: true,
            data: {},
            components: {}
        };

        autorun(updateFragmentDataWithoutItems);
        autorun(updateItemsFragmentData);

    }

/// Internal

    function updateFragmentDataWithoutItems() {

        unobserve();
        var fragmentDataWithoutItems = this.fragmentDataWithoutItems;
        reobserve();

        fragmentDataWithoutItems.id = this.fragmentId;
        fragmentDataWithoutItems.width = this.width;
        fragmentDataWithoutItems.height = this.height;
        fragmentDataWithoutItems.color = this.color;
        fragmentDataWithoutItems.transparent = this.transparent;

        unobserve();
        invalidateFragmentDataWithoutItems();
        reobserve();

    }

    function updateItemsFragmentData() {

        var items = this.items;

        unobserve();

        for (i in 0...items.length) {
            items[i].fragmentData = this;
        }

        reobserve();

    }

/// Public API

    public function visualById(entityId:String):EditorVisualData {

        for (i in 0...visuals.length) {
            var visuals = visuals[i];
            if (visuals.entityId == entityId) return visuals;
        }

        return null;

    }

    public function addVisual(entityClass:String):EditorVisualData {

        // Compute visual id
        var i = 0;
        var prefix = TextUtils.uppercasePrefixFromClass(entityClass);
        while (get(prefix + '_' + i) != null) {
            i++;
        }

        // Create and add visual data
        //
        var visual = new EditorVisualData();
        visual.fragmentData = this;
        visual.entityId = prefix + '_' + i;
        visual.entityClass = entityClass;

        var maxDepth = 0.0;
        for (otherVisual in visuals) {
            maxDepth = Math.max(otherVisual.props.get('depth'), maxDepth);
        }

        visual.props.set('x', Math.round(width / 2));
        visual.props.set('y', Math.round(height / 2));
        visual.props.set('depth', maxDepth + 1);
        visual.props.set('depthRange', 1);
        visual.props.set('anchorX', 0);
        visual.props.set('anchorY', 0);
        visual.props.set('scaleX', 1);
        visual.props.set('scaleY', 1);
        visual.props.set('alpha', 1);
        visual.props.set('visible', true);
        visual.props.set('touchable', true);

        var clazz = Type.resolveClass(entityClass);
        if (clazz != null) {
            if (Reflect.hasField(clazz, 'editorSetupEntity')) {
                var setup = Reflect.field(clazz, 'editorSetupEntity');
                setup(visual);
            }
        }

        var items = [].concat(this.items.original);
        items.push(visual);
        this.items = cast sortItemsArray(items);

        model.history.step();

        return visual;

    }

    public function addItem(entityClass:String):EditorEntityData {

        // Compute entity id
        var i = 0;
        var prefix = TextUtils.uppercasePrefixFromClass(entityClass);
        while (get(prefix + '_' + i) != null) {
            i++;
        }

        // Create and add entity data
        //
        var entity = new EditorEntityData();
        entity.fragmentData = this;
        entity.entityId = prefix + '_' + i;
        entity.entityClass = entityClass;

        var clazz = Type.resolveClass(entityClass);
        if (clazz != null) {
            if (Reflect.hasField(clazz, 'editorSetupEntity')) {
                var setup = Reflect.field(clazz, 'editorSetupEntity');
                setup(entity);
            }
        }

        var items = [].concat(this.items.original);
        items.push(entity);
        this.items = cast sortItemsArray(items);

        model.history.step();

        return entity;

    }

    public function duplicateItem(item:EditorEntityData):Void {

        lockSortItems = true;

        var jsonItem = item.toJson();

        // Compute duplicated id
        var i = 0;
        var prefix = TextUtils.getPrefix(item.entityId);
        while (get(prefix + '_' + i) != null) {
            i++;
        }
        jsonItem.id = prefix + '_' + i;

        // Create instance
        var duplicatedItem:EditorEntityData;
        if (jsonItem.isVisual) {
            duplicatedItem = new EditorVisualData();
        }
        else {
            duplicatedItem = new EditorEntityData();
        }
        duplicatedItem.fragmentData = this;
        duplicatedItem.fromJson(jsonItem);
        duplicatedItem.props.set('depth', item.props.get('depth') + 0.001);

        var items = [].concat(this.items.original);
        items.insert(items.indexOf(item) + 1, duplicatedItem);
        this.items = cast items;

        duplicatedItem.locked = false;
        selectedItem = duplicatedItem;

        lockSortItems = false;

        normalizeVisualsDepth();

    }
    
    public function computeAvailableId(targetId:String):String {

        if (get(targetId) != null) {
            var prefix = TextUtils.getPrefix(targetId);
            if (prefix == null || prefix.length == 0)
                prefix = 'ITEM';
            var i = 0;
            while (get(prefix + '_' + i) != null) {
                i++;
            }
            return prefix + '_' + i;
        }
        else {
            return targetId;
        }

    }

    public function addEntityData(entityData:EditorEntityData):Void {

        entityData.entityId = computeAvailableId(entityData.entityId);

        var items = [].concat(this.items.original);
        items.push(entityData);
        this.items = cast sortItemsArray(items);

    }

    public function get(entityId:String):EditorEntityData {

        for (item in items) {
            if (item.entityId == entityId) {
                return item;
            }
        }

        return null;

    }

    public function removeItem(item:EditorEntityData):Bool {

        var didRemove = false;

        var newItems = [];
        for (anItem in items) {
            if (item == anItem) {
                didRemove = true;
                if (item.fragmentData == this) {
                    item.fragmentData = null;
                }
            }
            else {
                newItems.push(anItem);
            }
        }

        if (didRemove) {
            if (selectedItem == item) {
                selectedItem = null;
            }

            items = cast newItems;

            model.history.step();
        }

        return didRemove;

    }

    public function toFragmentData(includeTracks:Bool = true):FragmentData {

        if (model.isFragmentIdUsed(fragmentId)) {
            return null;
        }

        model.pushUsedFragmentId(fragmentId);

        var result:FragmentData = {
            id: fragmentId,
            data: null, // TODO?
            width: width,
            height: height,
            color: color,
            overflow: overflow,
            transparent: transparent,
            components: fragmentComponentsToDynamic(),
            items: fragmentItems()
        };

        if (includeTracks) {
            var tracks = [];
            for (item in items) {
                var timelineTracks = item.timelineTracks;
                if (timelineTracks != null) {
                    for (track in timelineTracks) {
                        tracks.push(track.toTimelineTrackData());
                    }
                }
            }
            if (tracks.length > 0) {
                result.tracks = tracks;
            }
        }

        model.popUsedFragmentId();

        return result;
        
    }

    public function fragmentComponentsToDynamic():Dynamic<String> {

        var result:Dynamic<String> = {};

        var fragmentComponents = this.fragmentComponents;
        for (key in fragmentComponents.keys()) {
            Reflect.setField(result, key, fragmentComponents.get(key));
        }

        return result;

    }

    public function fragmentItems():Array<FragmentItem> {

        var result = [];
        for (item in items) {
            result.push(item.toFragmentItem());
        }
        return result;

    }

    public function toJson():Dynamic {

        var json:Dynamic = {};

        json.id = fragmentId;
        json.width = width;
        json.height = height;
        json.bundle = bundle;
        json.color = color;
        json.overflow = overflow;
        json.transparent = transparent;
        json.selectedItemIndex = selectedItemIndex;

        if (Lambda.count(fragmentComponents) > 0) {
            json.components = {};
            for (key => val in fragmentComponents) {
                Reflect.setField(json.components, key, val);
            }
        }

        var jsonItems = [];
        for (item in items) {
            jsonItems.push(item.toJson());
        }
        json.items = jsonItems;

        return json;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid fragment id';
        fragmentId = json.id;

        if (!Validate.intDimension(json.width))
            throw 'Invalid fragment width';
        width = json.width;

        if (!Validate.intDimension(json.height))
            throw 'Invalid fragment height';
        height = json.height;

        if (json.bundle != null) {
            if (!Validate.nonEmptyString(json.bundle))
                throw 'Invalid fragment bundle';
            bundle = json.bundle;
        }
        else {
            bundle = null;
        }

        if (json.color != null) {
            if (!Validate.int(json.color))
                throw 'Invalid fragment color';
            color = json.color;
        }
        else {
            color = Color.BLACK;
        }

        if (json.transparent != null) {
            if (!Validate.boolean(json.transparent))
                throw 'Invalid fragment transparent';
            transparent = json.transparent;
        }
        else {
            transparent = true;
        }

        if (json.overflow != null) {
            if (!Validate.boolean(json.overflow))
                throw 'Invalid fragment overflow';
            overflow = json.overflow;
        }
        else {
            overflow = false;
        }

        if (json.components != null) {
            var parsedComponents = new Map<String,String>();
            for (key in Reflect.fields(json.components)) {
                var value:Dynamic = Reflect.field(json.components, key);
                if (!Validate.nonEmptyString(value))
                    throw 'Invalid component';
                parsedComponents.set(key, value);
            }
            fragmentComponents = cast parsedComponents;
        }
        else {
            fragmentComponents = cast new Map<String,String>();
        }

        if (json.items != null) {
            if (!Validate.array(json.items))
                throw 'Invalid project items';

            var jsonItems:Array<Dynamic> = json.items;
            var parsedItems = [];
            for (jsonItem in jsonItems) {
                var item:EditorEntityData;
                if (jsonItem.isVisual) {
                    item = new EditorVisualData();
                }
                else {
                    item = new EditorEntityData();
                }
                item.fragmentData = this;
                item.fromJson(jsonItem);
                parsedItems.push(item);
            }
            items = cast parsedItems;
        }
        else {
            items = [];
        }
        
        json.selectedItemIndex = selectedItemIndex;

    }

    public function moveVisualUpInList(visual:EditorVisualData) {

        var items = this.items;

        var visualDepth:Float = visual.props.get('depth');

        lockSortItems = true;

        var visualIndex = items.indexOf(visual);
        if (visualIndex > 0) {
            var i = visualIndex - 1;
            while (i >= 0) {
                var entity = items[i];
                if (Std.is(entity, EditorVisualData)) {
                    var aVisual:EditorVisualData = cast entity;
                    var aVisualDepth:Float = aVisual.props.get('depth');
                    if (aVisualDepth < visualDepth) {
                        aVisual.props.set('depth', visualDepth);
                        visual.props.set('depth', aVisualDepth);
                    }
                    else {
                        visual.props.set('depth', aVisualDepth - 0.001);
                    }
                    break;
                }
                i--;
            }
        }

        lockSortItems = false;

        normalizeVisualsDepth();

    }

    public function moveVisualDownInList(visual:EditorVisualData) {

        var items = this.items;

        var visualDepth:Float = visual.props.get('depth');

        lockSortItems = true;

        var visualIndex = items.indexOf(visual);
        if (visualIndex < items.length - 1) {
            var i = visualIndex + 1;
            while (i < items.length) {
                var entity = items[i];
                if (Std.is(entity, EditorVisualData)) {
                    var aVisual:EditorVisualData = cast entity;
                    var aVisualDepth:Float = aVisual.props.get('depth');
                    if (aVisualDepth > visualDepth) {
                        aVisual.props.set('depth', visualDepth);
                        visual.props.set('depth', aVisualDepth);
                    }
                    else {
                        visual.props.set('depth', aVisualDepth + 0.001);
                    }
                    break;
                }
                i++;
            }
        }

        lockSortItems = false;

        normalizeVisualsDepth();

    }

    public function moveVisualAboveVisual(visual:EditorVisualData, otherVisual:EditorVisualData) {

        lockSortItems = true;

        visual.props.set('depth', otherVisual.props.get('depth') + 0.001);

        lockSortItems = false;

        normalizeVisualsDepth();

    }

    public function moveVisualBelowVisual(visual:EditorVisualData, otherVisual:EditorVisualData) {

        lockSortItems = true;

        visual.props.set('depth', otherVisual.props.get('depth') - 0.001);

        lockSortItems = false;

        normalizeVisualsDepth();

    }

    public function normalizeVisualsDepth() {

        sortItems();

        lockSortItems = true;

        var startDepth:Float = 1;
        var itemsCopy = [].concat(this.items.original);
        for (item in itemsCopy) {
            if (Std.is(item, EditorVisualData)) {
                item.props.set('depth', startDepth++);
            }
        }

        lockSortItems = false;

    }

    public function sortItems() {

        if (lockSortItems)
            return;

        var prevSelectedItem = this.selectedItem;

        var newItems = [].concat(this.items.original);
        this.items = cast sortItemsArray(newItems);

        this.selectedItem = prevSelectedItem;

    }

    static function sortItemsArray(items:Array<EditorEntityData>):Array<EditorEntityData> {

        ArraySort.sort(items, compareItems);
        return items;

    }

    static function compareItems(itemA:EditorEntityData, itemB:EditorEntityData) {
        
        var isVisualA = Std.is(itemA, EditorVisualData);
        var isVisualB = Std.is(itemB, EditorVisualData);

        if (isVisualA && isVisualB) {
            var depthA:Float = 1.0 * itemA.props.get('depth');
            var depthB:Float = 1.0 * itemB.props.get('depth');
            trace('compare visuals ${itemA.entityId}=$depthA ${itemB.entityId}=$depthB');
            if (depthA > depthB)
                return 1;
            else if (depthA < depthB)
                return -1;
            else
                return TextUtils.compareStrings(itemA.entityId, itemB.entityId);
        }
        else {
            trace('compare anything');
            if (isVisualA) {
                return 1;
            }
            else if (isVisualB) {
                return -1;
            }
            else if (itemA.entityClass != itemB.entityClass) {
                return TextUtils.compareStrings(itemA.entityClass, itemB.entityClass);
            }
            else {
                return TextUtils.compareStrings(itemA.entityId, itemB.entityId);
            }
        }

    }

}
