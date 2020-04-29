package editor.model;

class EditorFragmentData extends Model {

/// Main data

    /**
     * Fragment id
     */
    @serialize public var fragmentId:String;

    /**
     * Fragment name
     */
    @serialize public var name:String;

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

    @observe public var fragmentDataWithoutItems(default,null):FragmentData = null;

/// Lifecycle

    var didInit = false;

    public function new() {

        super();

        if (!didInit)
            init();

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
            name: null,
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
        fragmentDataWithoutItems.name = this.name;
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

}
