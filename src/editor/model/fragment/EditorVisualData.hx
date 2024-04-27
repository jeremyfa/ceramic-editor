package editor.model.fragment;

import editor.ui.EditorVisualDataView;
import editor.ui.EditorVisualListItem;

class EditorVisualData extends EditorEntityData {

    /**
     * List item for UI
     */
    public var listItem:EditorVisualListItem;

    /**
     * The view associated to this visual data, when editing
     * it through UI's `EditorFragmentView`
     */
    @component public var view:EditorVisualDataView;

    @serialize public var x:Float = 0;

    @serialize public var y:Float = 0;

    @serialize public var width:Float = 100;

    @serialize public var height:Float = 100;

    @serialize public var scaleX:Float = 1;

    @serialize public var scaleY:Float = 1;

    @serialize public var anchorX:Float = 0.5;

    @serialize public var anchorY:Float = 0.5;

    @serialize public var rotation:Float = 0;

    @serialize public var skewX:Float = 0;

    @serialize public var skewY:Float = 0;

    @serialize public var roundTranslation:Int = 0;

    @serialize public var depth:Float = 1;

    @serialize public var depthRange:Float = 1;

    @serialize public var alpha:Float = 1;

    @serialize public var visible:Bool = true;

    @serialize public var touchable:Bool = true;

    @serialize public var translateX:Float = 0;

    @serialize public var translateY:Float = 0;

    @serialize public var shader:String = null;

    public function new(fragment:EditorFragmentData) {
        super(fragment);

        init();
    }

    override function didDeserialize() {
        super.didDeserialize();
        init();
    }

    function init() {
        this.listItem = new EditorVisualListItem(this);
    }

}
