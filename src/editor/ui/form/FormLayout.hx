package editor.ui.form;

class FormLayout extends LinearLayout {

/// Internal properties

    var leftShiftPressed:Bool = false;
    var rightShiftPressed:Bool = false;

    var findingWithFocused:Visual = null;

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        itemSpacing = 4;
        transparent = false;

        padding(10, 10);

        autorun(updateStyle);

        app.onKeyDown(this, handleKeyDown);
        app.onKeyUp(this, handleKeyUp);

    } //new

/// Internal

    function handleKeyDown(key:Key) {

        // Handle tab key to switch focus to next field
        if (screen.focusedVisual != null && hasIndirectParent(screen.focusedVisual, this)) {
            if (key.scanCode == ScanCode.TAB) {
                if (leftShiftPressed || rightShiftPressed) {
                    focusPrevField();
                }
                else {
                    focusNextField();
                }
            }
        }

        // Use shift pressed state to invert order of tab focus selection
        if (key.scanCode == ScanCode.LSHIFT) {
            leftShiftPressed = true;
        }
        else if (key.scanCode == ScanCode.RSHIFT) {
            rightShiftPressed = true;
        }

    } //handleKeyDown

    function handleKeyUp(key:Key) {

        // Use shift pressed state to invert order of tab focus selection
        if (key.scanCode == ScanCode.LSHIFT) {
            leftShiftPressed = false;
        }
        else if (key.scanCode == ScanCode.RSHIFT) {
            rightShiftPressed = false;
        }

    } //handleKeyDown

    function focusNextField() {

        // Look after currently focused field
        findingWithFocused = screen.focusedVisual;
        var field:FieldView = findNextField(this);
        if (field != null) {
            field.focus();
        }
        else if (screen.focusedVisual != null) {
            // Nothing found, walk from beginning
            findingWithFocused = null;
            field = findNextField(this);
            if (field != null) {
                field.focus();
            }
        }
        findingWithFocused = null;

    } //focusNextField

    function focusPrevField() {

        trace('FOCUS PREV FIELD');

        // Look before currently focused field
        findingWithFocused = screen.focusedVisual;
        var field:FieldView = findPrevField(this);
        if (field != null) {
            field.focus();
        }
        else if (screen.focusedVisual != null) {
            // Nothing found, walk from end
            findingWithFocused = null;
            field = findPrevField(this);
            if (field != null) {
                field.focus();
            }
        }
        findingWithFocused = null;

    } //focusPrevField

    function findNextField(walkVisual:Visual):FieldView {

        if (walkVisual == null) return null;
        if (walkVisual.children == null) return null;

        for (i in 0...walkVisual.children.length) {
            var child = walkVisual.children[i];
            if (findingWithFocused != null) {
                if (child == findingWithFocused) {
                    findingWithFocused = null;
                }
                else {
                    var inside = findNextField(child);
                    if (inside != null) return inside;
                }
            }
            else {
                if (Std.is(child, FieldView)) {
                    return cast child;
                }
                else {
                    var inside = findNextField(child);
                    if (inside != null) return inside;
                }
            }
        }

        return null;

    } //findNextField

    function findPrevField(walkVisual:Visual):FieldView {

        if (walkVisual == null) return null;
        if (walkVisual.children == null) return null;

        var i = walkVisual.children.length - 1;
        while (i >= 0) {
            var child = walkVisual.children[i];
            if (findingWithFocused != null) {
                if (child == findingWithFocused) {
                    findingWithFocused = null;
                }
                else {
                    var inside = findPrevField(child);
                    if (inside != null) return inside;
                }
            }
            else {
                if (Std.is(child, FieldView)) {
                    return cast child;
                }
                else {
                    var inside = findPrevField(child);
                    if (inside != null) return inside;
                }
            }
            i--;
        }

        return null;

    } //findPrevField

    function hasIndirectParent(visual:Visual, targetParent:Visual):Bool {

        var parent = visual.parent;
        do {
            if (parent == targetParent) return true;
            parent = parent.parent;
        }
        while (parent != null);

        return false;

    } //hasIndirectParent

    function updateStyle() {

        color = theme.mediumBackgroundColor;

    } //updateStyle

} //FormLayout
