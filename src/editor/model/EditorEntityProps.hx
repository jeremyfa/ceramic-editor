package editor.model;

/** A map model that wraps every value into their own model object to make them observable. */
class EditorEntityProps extends Model {

    @serialize var values:Map<String,EditorValue> = new Map();

    @observe public var entityData:EditorEntityData;

    public function new() {
        
        super();

    }

    override function serializeShouldDestroy() {
        
        log.debug('DESTROY PROPS ${entityData != null ? ${entityData.entityId} : '-'} #${_serializeId}');

        return true;

    }

    public function toFragmentProps():Dynamic<Dynamic> {
        
        var result:Dynamic<Dynamic> = {};
        var implicitSize = this.implicitSize;
        var entityData = this.entityData;
        var model = editor.model;

        for (key in values.keys()) {
            // Skip width & height if size is implicit
            if (implicitSize && (key == 'width' || key == 'height'))
                continue;

            var value:Dynamic = get(key);

            // Fetch real fragment data
            if (entityData != null) {
                var propType = entityData.typeOfProp(key);
                if (propType == 'ceramic.FragmentData') {
                    var fragmentId:String = value;
                    unobserve();
                    if (fragmentId != null && model.canReferenceFragmentId(fragmentId)) {
                        reobserve();
                        var fragmentValue = model != null ? model.fragments.get(value) : null;
                        if (fragmentValue != null) {
                            value = fragmentValue.value;
                        }
                        else {
                            value = null;
                        }
                    }
                    else {
                        reobserve();
                        value = null;
                    }
                }
                else if (propType == 'ceramic.ScriptContent') {
                    var scriptId:String = value;
                    unobserve();
                    if (scriptId != null) {
                        if (entityData.fragmentData != null && entityData.fragmentData.selectedItem == entityData) {
                            model.project.selectedScript = model.project.scriptById(scriptId);
                        }
                        reobserve();
                        var scriptValue = model != null ? model.scripts.get(value) : null;
                        if (scriptValue != null) {
                            value = scriptValue.value;
                        }
                        else {
                            value = null;
                        }
                    }
                    else {
                        reobserve();
                        value = null;
                    }
                }
            }

            Reflect.setField(result, key, value);
        }

        return result;

    }

    public function keys():Iterator<String> {

        return values.keys();

    }

    public function set(key:String, value:Dynamic):Void {

        unobserve();
        var valueHasChanged = false;
        var prevValue = get(key);
        if (prevValue != value)
            valueHasChanged = true;

        // TODO cache?
        var editableType = editor.getEditableType(entityData.entityClass);
        if (editableType.meta != null && editableType.meta.editable != null && Std.is(editableType.meta.editable, Array)) {
            var editableMeta:Dynamic = editableType.meta.editable[0];
            if (editableMeta != null && editableMeta.disable != null) {
                var list:Array<String> = editableMeta.disable;
                if (list.indexOf(key) != -1) {
                    return;
                }
            }
        }
        reobserve();

        if (values.exists(key)) {
            values.get(key).value = value;
        }
        else {
            var aValue = new EditorValue();
            aValue.value = value;
            values.set(key, aValue);
            invalidateValues();
        }

        unobserve();
        if (valueHasChanged && key == 'depth' && Std.is(entityData, EditorVisualData)) {
            var visualData:EditorVisualData = cast entityData;
            visualData.depthDidChange();
        }
        reobserve();

        if (valueHasChanged) {
            unobserve();
            model.history.step();
            reobserve();
        }

        unobserve();
        if (entityData != null)
            entityData.freezeEditorChanges();
        reobserve();

    }

    public function get(key:String):Dynamic {

        if (values.exists(key)) {
            var v = values.get(key);
            return v.value;
        }
        else {
            return null;
        }

    }

    public function exists(key:String):Bool {

        return values.exists(key);

    }

    public function remove(key:String):Void {

        if (values.exists(key)) {
            values.get(key).value = null;
            values.remove(key);
        }

    }

    @compute public function implicitSize():Bool {

        if (entityData == null)
            return false;

        var editableType = editor.getEditableType(entityData.entityClass);

        if (editableType.meta != null && editableType.meta.editable != null && Std.is(editableType.meta.editable, Array)) {
            var editableMeta:Array<Dynamic> = editableType.meta.editable;
            if (editableMeta.length > 0) {
                if (editableMeta[0].implicitSize) {
                    return true;
                }
                else if (editableMeta[0].implicitSizeUnlessNull != null) {
                    var field:String = editableMeta[0].implicitSizeUnlessNull;
                    if (get(field) != null) {
                        return true;
                    }
                }
                else if (editableMeta[0].implicitSizeUnlessTrue != null) {
                    var field:String = editableMeta[0].implicitSizeUnlessTrue;
                    if (get(field) != true) {
                        return true;
                    }
                }
            }
        }

        return false;

    }

    override function toString() {

        /*
        var valuesDyn:Dynamic = {};
        for (key in values.keys()) {
            valuesDyn.set(key, values.get(key));
        }*/
        return '' + values;

    }

}