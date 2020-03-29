package editor.model;

/** A map model that wraps every value into their own model object to make them observable. */
class EditorProps extends Model {

    @serialize var values:Map<String,EditorValue> = new Map();

    @observe public var entityData:EditorEntityData;

    public function new() {
        
        super();

    }

    public function toFragmentProps():Dynamic<Dynamic> {
        
        var result:Dynamic<Dynamic> = {};
        var implicitSize = this.implicitSize;

        for (key in values.keys()) {
            if (implicitSize && (key == 'width' || key == 'height'))
                continue;

            var value = get(key);
            Reflect.setField(result, key, value);
        }

        return result;

    }

    public function set(key:String, value:Dynamic):Void {

        if (values.exists(key)) {
            values.get(key).value = value;
        }
        else {
            var aValue = new EditorValue();
            aValue.value = value;
            values.set(key, aValue);
            invalidateValues();
        }

    }

    public function get(key:String):Dynamic {

        if (values.exists(key)) {
            return values.get(key).value;
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

}