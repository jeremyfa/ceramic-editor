package editor.model.fragment;

import ceramic.ReadOnlyMap;
import elements.TextUtils;

class EditorEntityData extends EditorBaseFragmentModel {

    @serialize public var entityId(default, set):String;
    function set_entityId(entityId:String):String {
        if (this.entityId != entityId) {
            this.entityId = entityId;
            edit_entityId = entityId;
        }
        return entityId;
    }
    public var edit_entityId:String;

    @serialize public var entityClass:String;

    @serialize public var entityComponents:ReadOnlyMap<String, String> = new Map();

    @serialize public var locked:Bool;

    public function changeEntityId(newEntityId:String) {
        final prevEntityId = this.unobservedEntityId;
        if (prevEntityId != newEntityId) {
            newEntityId = TextUtils.sanitizeToIdentifier(newEntityId);
            if (prevEntityId != newEntityId) {
                var baseFragmentId = newEntityId;
                var existing = fragment.getVisualOrEntity(newEntityId);
                var i = 0;
                while (existing != null && existing != this) {
                    newEntityId = baseFragmentId + '_' + i;
                    i++;
                    existing = fragment.getVisualOrEntity(newEntityId);
                }
                this.entityId = newEntityId;
            }
        }
        return newEntityId;
    }

}
