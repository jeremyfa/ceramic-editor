package editor.model.fragment;

import ceramic.AssetId;
import ceramic.Color;
import editor.utils.Validate;

class EditorQuadData extends EditorVisualData {

    @serialize public var color:Color = Color.WHITE;

    @serialize public var transparent:Bool = false;

    @serialize public var texture:String = null;

    public function new(fragment:EditorFragmentData) {
        super(fragment);
        entityClass = 'ceramic.Quad';
    }

    override function shouldResizeInsteadOfScale():Bool {
        var result = true;

        final textureName = this.texture;
        if (textureName != null && fragment.project.imagesByName.get(textureName) != null) {
            return false;
        }

        return result;
    }

    override function clone(?toEntity:EditorEntityData) {

        if (toEntity == null)
            toEntity = new EditorQuadData(fragment);

        if (!Std.isOfType(toEntity, EditorQuadData))
            throw "Cannot clone to " + Type.getClass(toEntity);

        toEntity.fromJson(toJson());

    }

    override function clear() {

        super.clear();

        entityClass = 'ceramic.Quad';
        color = Color.WHITE;
        transparent = false;
        texture = null;

    }

    override function fromJson(json:Dynamic):Void {

        super.fromJson(json);

        if (Reflect.hasField(json, 'color')) {
            if (!Validate.webColor(json.color)) {
                throw 'Invalid quad color: ' + json.color;
            }
            this.color = Color.fromString(json.color);
        }
        if (Reflect.hasField(json, 'transparent')) {
            if (!Validate.boolean(json.transparent)) {
                throw 'Invalid quad transparent value: ' + json.transparent;
            }
            this.transparent = json.transparent;
        }

        if (Reflect.hasField(json, 'texture')) {
            if (json.texture != null && !Std.isOfType(json.texture, String)) {
                throw 'Invalid quad shader: ' + json.texture;
            }
            this.texture = json.texture;
        }

    }

    override function toJson():Dynamic {
        var json:Dynamic = super.toJson();

        json.kind = this.kind;
        json.color = this.color.toWebString();
        json.transparent = (this.transparent == true);
        json.texture = this.texture;

        return json;
    }

}
