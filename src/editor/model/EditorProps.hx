package editor.model;

/** A map model that wraps every value into their own model object to make them observable. */
class EditorProps extends Model {

    @serialize var values:Map<String,EditorValue> = new Map();

    public function new() {
        
        super();

    } //new

    public function set(key:String, value:Dynamic):Void {

        if (values.exists(key)) {
            values.get(key).value = value;
        }
        else {
            var aValue = new EditorValue();
            aValue.value = value;
            values.set(key, aValue);
        }

    } //set

    public function get(key:String):Dynamic {

        if (values.exists(key)) {
            return values.get(key).value;
        }
        else {
            return null;
        }

    } //get

    public function exists(key:String):Bool {

        return values.exists(key);

    } //exists

    public function remove(key:String):Void {

        if (values.exists(key)) {
            values.get(key).value = null;
            values.remove(key);
        }

    } //remove

} //EditorProps