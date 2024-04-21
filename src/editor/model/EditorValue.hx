package editor.model;

import tracker.Model;

class EditorValue extends Model {

    @serialize public var value(default,set):Any = null;
    function set_value(value:Any):Any {
        if (this.unobservedValue == value) return value;
        this.value = value;
        return value;
    }

    override function toString() {

        return 'EditorValue(' + value + ')';

    }

}
