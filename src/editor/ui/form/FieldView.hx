package editor.ui.form;

class FieldView extends LinearLayout {

/// Public properties

    public var focused(get,never):Bool;
    inline function get_focused():Bool {
        FieldManager.manager.updateFocusedField();
        return FieldManager.manager.focusedField == this;
    }

/// Lifecycle

    public function new() {

        super();

        transparent = true;
        direction = HORIZONTAL;

        bindPointerEvents();

    } //new

/// Public API

    public function focus():Void {

        screen.focusedVisual = this;

    } //focus

/// Internal

    @:allow(editor.manager.FieldManager)
    function didLostFocus():Void {

        // Override in subclasses

    } //didLostFocus

    function bindPointerEvents() {

        // To make it focusable
        onPointerDown(this, function(_) {});

    } //bindPointerEvents

} //FieldView
