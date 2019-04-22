package editor.ui.form;

class FieldView extends LinearLayout {

/// Public properties

    public var focused(get,never):Bool;
    inline function get_focused():Bool {
        return FieldManager.manager.focusedField == this;
    }

/// Lifecycle

    public function new() {

        super();

        transparent = true;
        direction = VERTICAL;

        bindPointerEvents();

    } //new

    function bindPointerEvents() {

        // To make it focusable
        onPointerDown(this, function(_) {});

    } //bindPointerEvents

} //FieldView
