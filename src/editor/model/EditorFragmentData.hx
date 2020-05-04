package editor.model;

class EditorFragmentData extends Model {

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
     * The bundle name this fragment belongs to.
     * A fragment bundle is a file where one ore more fragments are saved together.
     * An empty value with save fragments into default bundle.
     */
    @serialize public var bundle:String;

    /**
     * Fragments items
     */
    @serialize public var items:ImmutableArray<EditorEntityData> = [];

    @serialize public var selectedItemIndex:Int = -1;

    @serialize public var fragmentComponents:Map<String, String> = new Map();

    public var selectedItem(get,set):EditorEntityData;
    function get_selectedItem():EditorEntityData {
        if (selectedItemIndex >= 0) return items[selectedItemIndex];
        return null;
    }
    function set_selectedItem(selectedItem:EditorEntityData):EditorEntityData {
        selectedItemIndex = items.indexOf(selectedItem);
        //invalidateSelectedItemIndex();
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

    @:isVar public var selectedVisualIndex(get,set):Int = -2;
    function get_selectedVisualIndex():Int {
        var selectedItemIndex = this.selectedItemIndex;
        var items = this.items;

        if (this.selectedVisualIndex != -2) {
            return this.selectedVisualIndex;
        }
        if (selectedItemIndex == -1) {
            this.selectedVisualIndex = -1;
        }
        else {
            var n = 0;
            for (i in 0...items.length) {
                var item = items[i];
                if (i == selectedItemIndex) {
                    if (Std.is(item, EditorVisualData)) {
                        this.selectedVisualIndex = n;
                        return this.selectedVisualIndex;
                    }
                    else {
                        this.selectedVisualIndex = -1;
                        return this.selectedVisualIndex;
                    }
                }
                else {
                    if (Std.is(item, EditorVisualData)) {
                        n++;
                    }
                }
            }
            this.selectedVisualIndex = n;
        }
        return this.selectedVisualIndex;
    }
    function set_selectedVisualIndex(selectedVisualIndex:Int):Int {
        if (selectedVisualIndex != -2) {
            if (selectedVisualIndex == -1) {
                selectedItemIndex = -1;
            }
            else {
                var visualData = visuals[selectedVisualIndex];
                if (visualData == null) {
                    selectedItemIndex = -1;
                    selectedVisualIndex = -1;
                }
                else {
                    selectedItemIndex = items.indexOf(visualData);
                }
            }
        }
        return this.selectedVisualIndex = selectedVisualIndex;
    }

    public var visuals(get,null):ImmutableArray<EditorVisualData> = null;
    function get_visuals():ImmutableArray<EditorVisualData> {
        var items = this.items;

        if (this.visuals != null) return this.visuals;
        var result = [];
        for (i in 0...items.length) {
            var item = items[i];
            if (Std.is(item, EditorVisualData)) {
                result.push(item);
            }
        }
        this.visuals = cast result;
        return this.visuals;
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

        // Reset computed values when their source value changes
        onItemsChange(this, function(_, _) {
            visuals = null;
            selectedVisualIndex = -2;
        });
        onSelectedItemIndexChange(this, function(newValue, prevValue) {
            selectedVisualIndex = -2;
        });

        fragmentDataWithoutItems = {
            id: null,
            width: 0.0,
            height: 0.0,
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
        while (visualById('VISUAL_$i') != null) {
            i++;
        }

        // Create and add visual data
        //
        var visual = new EditorVisualData();
        visual.fragmentData = this;
        visual.entityId = 'VISUAL_$i';
        visual.entityClass = entityClass;

        var maxDepth = 0.0;
        for (otherVisual in visuals) {
            maxDepth = Math.max(otherVisual.props.get('depth'), maxDepth);
        }

        visual.props.set('x', Math.round(width / 2));
        visual.props.set('y', Math.round(height / 2));
        visual.props.set('depth', maxDepth + 1);
        visual.props.set('depthRange', 1);
        visual.props.set('anchorX', 0.5);
        visual.props.set('anchorY', 0.5);
        visual.props.set('scaleX', 1);
        visual.props.set('scaleY', 1);
        visual.props.set('alpha', 1);
        visual.props.set('visible', true);
        visual.props.set('touchable', true);

        // Specific cases
        if (entityClass == 'ceramic.Text') {
            visual.props.set('content', visual.entityId);
        }
        else if (entityClass == 'ceramic.Quad') {
            visual.props.set('width', 100);
            visual.props.set('height', 100);
        }

        var items = [].concat(this.items.mutable);
        items.push(visual);
        this.items = cast items;

        model.history.step();

        return visual;

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
            items = cast newItems;

            model.history.step();
        }

        return didRemove;

    }

    public function toFragmentData():FragmentData {

        return {
            id: fragmentId,
            data: null, // TODO?
            width: width,
            height: height,
            components: fragmentComponentsToDynamic(),
            items: fragmentItems()
        };
        
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

}
