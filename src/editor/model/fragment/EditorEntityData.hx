package editor.model.fragment;

import ceramic.ReadOnlyMap;
import ceramic.Utils;
import editor.utils.Regex;
import editor.utils.Validate;
import elements.TextUtils;

using StringTools;

class EditorEntityData extends EditorBaseFragmentModel {

    public var kind(get,null):String;
    function get_kind():String {
        if (this.kind == null) {
            var result = Type.getClassName(Type.getClass(this));
            var dotIndex = result.lastIndexOf('.');
            if (dotIndex != -1) {
                result = result.substr(dotIndex + 1);
            }
            if (result.startsWith('Editor')) {
                result = result.substr(6);
            }
            if (result.endsWith('Data')) {
                result = result.substr(0, result.length - 4);
            }
            this.kind = result;
        }
        return this.kind;
    }

    @serialize public var entityId(default, set):String;
    function set_entityId(entityId:String):String {
        if (this.entityId != entityId) {
            this.entityId = entityId;
            edit_entityId = entityId;
        }
        return entityId;
    }
    public var edit_entityId:String;

    @serialize public var entityClass:String = 'ceramic.Entity';

    @serialize public var entityComponents:ReadOnlyMap<String, String> = new Map();

    @serialize public var locked:Bool = false;

    public function changeEntityId(newEntityId:String) {
        final prevEntityId = this.unobservedEntityId;
        if (prevEntityId != newEntityId) {
            newEntityId = TextUtils.sanitizeToIdentifier(newEntityId);
            if (prevEntityId != newEntityId) {
                if (fragment != null) {
                    var i = 0;
                    var baseId = newEntityId;
                    if (RE_NUMBER_SUFFIX.match(baseId)) {
                        baseId = baseId.substr(0, baseId.length - RE_NUMBER_SUFFIX.matched(1).length - 1);
                        i = Std.parseInt(RE_NUMBER_SUFFIX.matched(1));
                    }
                    var existing = fragment.getVisualOrEntity(newEntityId);
                    while (existing != null && existing != this) {
                        newEntityId = baseId + '_' + i;
                        i++;
                        existing = fragment.getVisualOrEntity(newEntityId);
                    }
                    this.entityId = newEntityId;
                }
            }
        }
        return newEntityId;
    }

    public function clone(?toEntity:EditorEntityData) {

        if (toEntity == null)
            toEntity = new EditorEntityData(fragment);

        toEntity.fromJson(toJson());

    }

    public function clear():Void {

        entityId = Utils.uniqueId();
        entityClass = 'ceramic.Entity';
        entityComponents = new Map();
        locked = false;

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.identifier(json.id))
            throw 'Invalid entity id: ' + json.id;
        this.changeEntityId(json.id);

        if (Reflect.hasField(json, 'locked')) {
            if (!Validate.boolean(json.locked)) {
                throw 'Invalid entity locked value: ' + json.locked;
            }
            this.locked = json.locked;
        }

        var entityComponents = new Map<String,String>();
        if (Reflect.hasField(json, 'components')) {
            for (key in Reflect.fields(json.components)) {
                entityComponents.set(key, Reflect.field(json.components, key));
            }
        }
        this.entityComponents = entityComponents;

    }

    public function toJson():Dynamic {
        var json:Dynamic = {};

        json.kind = this.kind;
        json.id = this.entityId;
        json.entity = this.entityClass;
        json.locked = (this.locked == true);

        var jsonComponents:Dynamic = {};
        for (key => val in this.entityComponents) {
            Reflect.setField(jsonComponents, key, val);
        }
        json.components = jsonComponents;

        return json;
    }

}
