package editor.model;

class EditorFragmentData extends Model {

/// Main data

    @serialize public var fragmentId:String;

    @serialize public var name:String;

    @serialize public var width:Int;

    @serialize public var height:Int;

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

/// Lifecycle

    public function new() {

        super();

        // Reset computed values when their source value changes
        onItemsChange(this, function(_, _) {
            visuals = null;
            selectedVisualIndex = -2;
        });
        onSelectedItemIndexChange(this, function(newValue, prevValue) {
            selectedVisualIndex = -2;
        });

    } //new

/// Public API

    public function visualById(entityId:String):EditorVisualData {

        for (i in 0...visuals.length) {
            var visuals = visuals[i];
            if (visuals.entityId == entityId) return visuals;
        }

        return null;

    } //visualById

    public function addVisual(entityClass:String):EditorVisualData {

        // Compute visual id
        var i = 0;
        while (visualById('VISUAL_$i') != null) {
            i++;
        }

        // Create and add visual data
        //
        var visual = new EditorVisualData();
        visual.entityId = 'VISUAL_$i';
        visual.entityClass = entityClass;

        var items = [].concat(this.items.mutable);
        items.push(visual);
        this.items = cast items;

        return visual;

    } //addVisual

} //EditorFragmentData
