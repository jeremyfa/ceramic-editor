package editor.model.fragment;

import editor.ui.EditorVisualDataView;
import editor.ui.EditorVisualListItem;
import editor.utils.Validate;

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

    @compute public function resizeInsteadOfScale():Bool {
        return shouldResizeInsteadOfScale();
    }

    public static function create(fragment:EditorFragmentData, kind:String):EditorVisualData {

        return switch kind {
            case 'visual': new EditorVisualData(fragment);
            case 'quad': new EditorQuadData(fragment);
            case _:
                throw 'Unknown fragment visual kind: ' + kind;
        }

    }

    public function new(fragment:EditorFragmentData) {
        super(fragment);
        entityClass = 'ceramic.Visual';
        init();
    }

    override function didDeserialize() {
        super.didDeserialize();
        init();
    }

    function init() {
        this.listItem = new EditorVisualListItem(this);
    }

    function shouldResizeInsteadOfScale():Bool {
        return true;
    }

    override function clone(?toEntity:EditorEntityData) {

        if (toEntity == null)
            toEntity = new EditorVisualData(fragment);

        if (!Std.isOfType(toEntity, EditorVisualData))
            throw "Cannot clone to " + Type.getClass(toEntity);

        toEntity.fromJson(toJson());

        historyStep();

    }

    override function clear() {

        super.clear();

        entityClass = 'ceramic.Visual';
        x = 0;
        y = 0;
        width = 100;
        height = 100;
        scaleX = 1;
        scaleY = 1;
        anchorX = 0.5;
        anchorY = 0.5;
        rotation = 0;
        skewX = 0;
        skewY = 0;
        roundTranslation = 0;
        depth = 1;
        depthRange = 1;
        alpha = 1;
        visible = true;
        touchable = true;
        translateX = 0;
        translateY = 0;
        shader = null;

    }

    override function fromJson(json:Dynamic):Void {

        super.fromJson(json);

        if (!Validate.float(json.x)) {
            throw 'Invalid visual x: ' + json.x;
        }
        this.x = json.x;

        if (!Validate.float(json.y)) {
            throw 'Invalid visual y: ' + json.y;
        }
        this.y = json.y;

        if (!Validate.floatDimension(json.width)) {
            throw 'Invalid visual width: ' + json.width;
        }
        this.width = json.width;

        if (!Validate.floatDimension(json.height)) {
            throw 'Invalid visual height: ' + json.height;
        }
        this.height = json.height;

        if (Reflect.hasField(json, 'scaleX')) {
            if (!Validate.float(json.scaleX)) {
                throw 'Invalid visual scaleX: ' + json.scaleX;
            }
            this.scaleX = json.scaleX;
        }

        if (Reflect.hasField(json, 'scaleY')) {
            if (!Validate.float(json.scaleY)) {
                throw 'Invalid visual scaleY: ' + json.scaleY;
            }
            this.scaleY = json.scaleY;
        }

        if (Reflect.hasField(json, 'anchorX')) {
            if (!Validate.float(json.anchorX)) {
                throw 'Invalid visual anchorX: ' + json.anchorX;
            }
            this.anchorX = json.anchorX;
        }

        if (Reflect.hasField(json, 'anchorY')) {
            if (!Validate.float(json.anchorY)) {
                throw 'Invalid visual anchorY: ' + json.anchorY;
            }
            this.anchorY = json.anchorY;
        }

        if (Reflect.hasField(json, 'rotation')) {
            if (!Validate.float(json.rotation)) {
                throw 'Invalid visual rotation: ' + json.rotation;
            }
            this.rotation = json.rotation;
        }

        if (Reflect.hasField(json, 'skewX')) {
            if (!Validate.float(json.skewX)) {
                throw 'Invalid visual skewX: ' + json.skewX;
            }
            this.skewX = json.skewX;
        }

        if (Reflect.hasField(json, 'skewY')) {
            if (!Validate.float(json.skewY)) {
                throw 'Invalid visual skewY: ' + json.skewY;
            }
            this.skewY = json.skewY;
        }

        if (Reflect.hasField(json, 'roundTranslation')) {
            if (!Validate.int(json.roundTranslation)) {
                throw 'Invalid visual roundTranslation: ' + json.roundTranslation;
            }
            this.roundTranslation = json.roundTranslation;
        }

        if (Reflect.hasField(json, 'depth')) {
            if (!Validate.float(json.depth)) {
                throw 'Invalid visual depth: ' + json.depth;
            }
            this.depth = json.depth;
        }

        if (Reflect.hasField(json, 'depthRange')) {
            if (!Validate.float(json.depthRange)) {
                throw 'Invalid visual depthRange: ' + json.depthRange;
            }
            this.depthRange = json.depthRange;
        }

        if (Reflect.hasField(json, 'alpha')) {
            if (!Validate.float(json.alpha)) {
                throw 'Invalid visual alpha: ' + json.alpha;
            }
            this.alpha = json.alpha;
        }

        if (Reflect.hasField(json, 'visible')) {
            if (!Validate.boolean(json.visible)) {
                throw 'Invalid visual visible: ' + json.visible;
            }
            this.visible = json.visible;
        }

        if (Reflect.hasField(json, 'touchable')) {
            if (!Validate.boolean(json.touchable)) {
                throw 'Invalid visual touchable: ' + json.touchable;
            }
            this.touchable = json.touchable;
        }

        if (Reflect.hasField(json, 'translateX')) {
            if (!Validate.float(json.translateX)) {
                throw 'Invalid visual translateX: ' + json.translateX;
            }
            this.translateX = json.translateX;
        }

        if (Reflect.hasField(json, 'translateY')) {
            if (!Validate.float(json.translateY)) {
                throw 'Invalid visual translateY: ' + json.translateY;
            }
            this.translateY = json.translateY;
        }

        if (Reflect.hasField(json, 'shader')) {
            if (json.shader != null && !Std.isOfType(json.shader, String)) {
                throw 'Invalid visual shader: ' + json.shader;
            }
            this.shader = json.shader;
        }

    }

    override function toJson():Dynamic {
        var json:Dynamic = super.toJson();

        json.kind = this.kind;
        json.x = this.x;
        json.y = this.y;
        json.width = this.width;
        json.height = this.height;
        json.scaleX = this.scaleX;
        json.scaleY = this.scaleY;
        json.anchorX = this.anchorX;
        json.anchorY = this.anchorY;
        json.rotation = this.rotation;
        json.skewX = this.skewX;
        json.skewY = this.skewY;
        json.roundTranslation = this.roundTranslation;
        json.depth = this.depth;
        json.depthRange = this.depthRange;
        json.alpha = this.alpha;
        json.visible = this.visible;
        json.touchable = this.touchable;
        json.translateX = this.translateX;
        json.translateY = this.translateY;
        json.shader = this.shader;

        return json;
    }

    override function schema():Dynamic {
        var schema = super.schema();

        schema.x = 'Float';
        schema.y = 'Float';
        schema.width = 'Float';
        schema.height = 'Float';
        schema.scaleX = 'Float';
        schema.scaleY = 'Float';
        schema.anchorX = 'Float';
        schema.anchorY = 'Float';
        schema.rotation = 'Float';
        schema.skewX = 'Float';
        schema.skewY = 'Float';
        schema.roundTranslation = 'Int';
        schema.depth = 'Float';
        schema.depthRange = 'Float';
        schema.alpha = 'Float';
        schema.visible = 'Bool';
        schema.touchable = 'Bool';
        schema.translateX = 'Float';
        schema.translateY = 'Float';
        schema.shader = 'ceramic.Shader';

        return schema;
    }

}
