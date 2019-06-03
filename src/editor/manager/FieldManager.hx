package editor.manager;

class FieldManager extends Entity implements Observable implements Lazy {

/// Statics

    @lazy public static var manager = new FieldManager();

/// Public properties

    @observe public var focusedField:FieldView = null;

/// Lifecycle

    public function new() {

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

        this.focusedField = focusedField;

        reobserve();

    } //updateFocusedField

} //FieldManager
