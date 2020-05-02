package editor.model;

class EditorValue extends Model {

    @serialize public var value(default,set):Dynamic = null;
    function set_value(value:Dynamic):Dynamic {
        if (this.value == value) return value;
        this.value = value;
        return value;
    }

    override function toString() {

        return 'EditorValue(' + value + ')';

    }

}
