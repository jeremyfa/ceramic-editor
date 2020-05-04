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

            // Skip temporary keys
            if (key.startsWith('_tmp_'))
                continue;

            var value = get(key);

            // Fetch real fragment data
            if (entityData != null && entityData.typeOfProp(key) == 'ceramic.FragmentData') {
                var fragmentValue = model != null ? model.fragments.get(value) : null;
                if (fragmentValue != null) {
                    value = fragmentValue.value;
                }
                else
                    value = null;
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
        var shouldScheduleStep = false;
        var prevValue = get(key);
        if (prevValue != value)
            shouldScheduleStep = true;
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

        if (shouldScheduleStep) {
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