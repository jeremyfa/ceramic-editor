package editor.components;

using ceramic.Extensions;
using unifill.Unifill;
using StringTools;

class EditText extends Entity implements Component implements TextInputDelegate {

/// Internal statics

    static var _point = new Point();

    static var _activeEditTextInput:EditText = null;

/// Events

    @event function update(content:String);

    @event function stop();

/// Public properties

    public var entity:Text;

    public var multiline:Bool = false;

    /** Optional container on which pointer events are bound */
    public var container(default,set):Visual = null;
    function set_container(container:Visual):Visual {
        if (this.container == container) return container;
        this.container = container;
        if (selectText != null) {
            selectText.container = container;
        }
        if (entity != null) bindPointerEvents();
        return container;
    }

/// Internal properties

    var boundContainer:Visual = null;

    var selectText:SelectText = null;

    var selectionBackgrounds:Array<Quad> = [];

    var inputActive:Bool = false;

    var willUpdateSelection:Bool = false;

    var textCursor:Quad = null;

    var textCursorToggleVisibilityTime:Float = 1.0;

/// Lifecycle

    public function new() {

        super();

        id = Utils.uniqueId();

    }

    function bindAsComponent() {

        // Get or init SelectText component
        selectText = cast entity.component('selectText');
        if (selectText == null) {
            selectText = new SelectText();
            entity.component('selectText', selectText);
        }

        selectText.container = container;
        selectText.onSelection(this, updateFromSelection);

        bindPointerEvents();
        bindKeyBindings();

        app.onUpdate(this, handleAppUpdate);
        
    }

/// Public API

    public function startInput(selectionStart:Int = -1, selectionEnd:Int = -1):Void {

        if (_activeEditTextInput != null) {
            _activeEditTextInput.stopInput();
            _activeEditTextInput = null;
            app.onceImmediate(function() {
                startInput(selectionStart, selectionEnd);
            });
            return;
        }

        _activeEditTextInput = this;

        var content = entity.content;

        var x = entity.x;
        var y = entity.y;
        var width = entity.width;
        var height = entity.height;
        var anchorX = entity.anchorX;
        var anchorY = entity.anchorY;

        entity.visualToScreen(x - width * anchorX, y - height * anchorY, _point);
        var screenLeft = _point.x;
        var screenTop = _point.y;
        entity.visualToScreen(x - width * anchorX + width, y - height * anchorY + height, _point);
        var screenRight = _point.x;
        var screenBottom = _point.y;

        app.textInput.onUpdate(this, updateFromTextInput);
        app.textInput.onStop(this, handleStop);
        app.textInput.onSelection(this, updateFromInputSelection);

        selectText.showCursor = true;
        selectText.allowSelectingFromPointer = true;

        inputActive = true;

        app.textInput.start(
            content,
            screenLeft,
            screenTop,
            screenRight - screenLeft,
            screenBottom - screenTop,
            multiline,
            selectionStart,
            selectionEnd,
            true,
            this
        );

    }

    public function stopInput():Void {

        inputActive = false;

        app.textInput.offUpdate(updateFromTextInput);
        app.textInput.offStop(handleStop);
        app.textInput.offSelection(updateFromInputSelection);

        if (_activeEditTextInput == this) {
            app.textInput.stop();
            _activeEditTextInput = null;
        }

        selectText.showCursor = false;
        selectText.allowSelectingFromPointer = false;
        selectText.selectionStart = -1;
        selectText.selectionEnd = -1;

        emitStop();

    }

    public function updateText(text:String):Void {

        if (!inputActive) return;

        app.textInput.text = text;

    }

    public function focus() {

        screen.focusedVisual = entity;
        if (!inputActive) {
            app.onceImmediate(function() {
                // This way of calling will ensure any previous text input
                // can be stopped before we start this new one
                startInput(0, entity.content.uLength());
            });
        }

    }

/// Internal

    function handleStop():Void {

        stopInput();

    }

    function updateFromTextInput(text:String):Void {

        // Update text content ourself
        entity.content = text;

        // But allow external code to put another processed value if needed
        emitUpdate(text);

    }

    function updateFromSelection(selectionStart:Int, selectionEnd:Int, inverted:Bool):Void {

        app.textInput.updateSelection(selectionStart, selectionEnd, inverted);

    }

    function updateFromInputSelection(selectionStart:Int, selectionEnd:Int):Void {

        selectText.selectionStart = selectionStart;
        selectText.selectionEnd = selectionEnd;

    }

/// TextInput delegate

    public function textInputClosestPositionInLine(fromPosition:Int, fromLine:Int, toLine:Int):Int {

        var indexFromLine = entity.indexForPosInLine(fromLine, fromPosition);
        var xPosition = entity.xPositionAtIndex(indexFromLine);

        return entity.posInLineForX(toLine, xPosition);

    }

    public function textInputNumberOfLines():Int {

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 1;

        return glyphQuads[glyphQuads.length - 1].line + 1;

    }

    public function textInputIndexForPosInLine(lineNumber:Int, lineOffset:Int):Int {

        return entity.indexForPosInLine(lineNumber, lineOffset);

    }

    public function textInputLineForIndex(index:Int):Int {

        return entity.lineForIndex(index);

    }

    public function textInputPosInLineForIndex(index:Int):Int {

        return entity.posInLineForIndex(index);

    }

/// Pointer events and focus

    function bindPointerEvents() {

        if (boundContainer != null) {
            boundContainer.offPointerDown(handlePointerDown);
            boundContainer = null;
        }
        else {
            entity.offPointerDown(handlePointerDown);
        }

        if (container != null) {
            container.onPointerDown(this, handlePointerDown);
            boundContainer = container;
        }
        else {
            entity.onPointerDown(this, handlePointerDown);
        }

    }

    function handlePointerDown(info:TouchInfo) {

        focus();

    }

    function handleAppUpdate(delta:Float) {

        // Check focus
        if (inputActive && screen.focusedVisual != entity && (container == null || screen.focusedVisual != container)) {
            stopInput();
        }

    }

/// Key bindings

    function bindKeyBindings() {

        var keyBindings = new KeyBindings();

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_V)], function() {
            // CMD/CTRL + C
            if (screen.focusedVisual != entity) return;
            var pasteText = app.backend.clipboard.getText();
            if (pasteText == null) pasteText = '';
            if (!multiline) pasteText = pasteText.replace("\n", ' ');
            pasteText.replace("\r", '');
            var newText = entity.content.uSubstring(0, selectText.selectionStart) + pasteText + entity.content.uSubstring(selectText.selectionEnd);
            selectText.selectionStart += pasteText.uLength();
            selectText.selectionEnd = selectText.selectionStart;

            // Update text content
            entity.content = newText;
            emitUpdate(newText);
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_X)], function() {
            // CMD/CTRL + X
            if (screen.focusedVisual != entity || selectText.selectionEnd - selectText.selectionStart <= 0) return;
            var selectedText = entity.content.uSubstring(selectText.selectionStart, selectText.selectionEnd);
            app.backend.clipboard.setText(selectedText);

            var newText = entity.content.uSubstring(0, selectText.selectionStart) + entity.content.uSubstring(selectText.selectionEnd);
            selectText.selectionEnd = selectText.selectionStart;

            // Update text content
            entity.content = newText;
            emitUpdate(newText);
        });

        onDestroy(keyBindings, function(_) {
            keyBindings.destroy();
            keyBindings = null;
        });

    }

}
