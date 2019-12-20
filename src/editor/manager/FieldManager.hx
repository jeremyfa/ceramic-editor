package editor.manager;

class FieldManager extends Entity implements Observable {

/// Statics

    @lazy public static var manager = new FieldManager();

/// Public properties

    @observe public var focusedField:FieldView = null;

/// Lifecycle

    public function new() {

        super();

        app.onUpdate(this, function(_) {
            updateFocusedField();
        });

    } //new

    public function updateFocusedField():Void {

        unobserve();

        var focusedVisual = screen.focusedVisual;
        var focusedField:FieldView = null;

        var testedVisual:Visual = focusedVisual;
        while (testedVisual != null) {
            if (Std.is(testedVisual, FieldView)) {
                focusedField = cast testedVisual;
                break;
            }
            testedVisual = testedVisual.parent;
        }

        var prevFocusedField = this.focusedField;

        this.focusedField = focusedField;

        if (prevFocusedField != focusedField && Std.is(prevFocusedField, FieldView)) {
            var prevFieldView:FieldView = cast prevFocusedField;
            prevFieldView.didLostFocus();
        }

        reobserve();

    } //updateFocusedField

} //FieldManager
