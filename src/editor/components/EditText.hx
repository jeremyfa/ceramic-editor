package editor.components;

using ceramic.Extensions;
using unifill.Unifill;

class EditText extends Component implements TextInputDelegate {

/// Internal statics

    static var _point = new Point();

/// Events

    @event function update(content:String);

/// Public properties

    public var entity:Text;

/// Internal properties

    var selectionBackgrounds:Array<Quad> = [];

    var inputActive:Bool = false;

    var willUpdateSelection:Bool = false;

    var textCursor:Quad = null;

    var textCursorToggleVisibilityTime:Float = 1.0;

/// Lifecycle

    public function new() {

        super();

    } //new

    override function init() {

        entity.onGlyphQuadsChange(updateSelectionUI);

        app.onUpdate(this, updateCursorVisibility);
        
    } //init

/// Public API

    public function startInput(content:String, selectionStart:Int = -1, selectionEnd:Int = -1):Void {

        success('START INPUT $content');

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
        app.textInput.onSelection(this, updateFromSelection);

        inputActive = true;

        app.textInput.start(
            content,
            screenLeft,
            screenTop,
            screenRight - screenLeft,
            screenBottom - screenTop,
            true,
            selectionStart,
            selectionEnd,
            true,
            this
        );

    } //startInput

    public function stopInput():Void {

        error('STOP INPUT');

        inputActive = false;

        app.textInput.offUpdate(updateFromTextInput);
        app.textInput.offSelection(updateFromSelection);
        app.textInput.stop();

        updateSelectionUI();

    } //stopInput

/// Internal

    function updateCursorVisibility(delta:Float):Void {

        if (textCursor == null) return;

        textCursorToggleVisibilityTime -= delta;
        while (textCursorToggleVisibilityTime <= 0) {
            textCursorToggleVisibilityTime += 0.5;
            textCursor.visible = !textCursor.visible;
        }

    } //updateCursorVisibility

    function resetCursorVisibility() {

        textCursorToggleVisibilityTime = 0.5;
        if (textCursor != null) textCursor.visible = true;

    } //resetCursorVisibility

    function updateFromTextInput(text:String):Void {

        emitUpdate(text);

    } //updateFromTextInput

    function updateFromSelection(selectionStart:Int, selectionEnd:Int):Void {

        warning('SELECTION $selectionStart $selectionEnd');

        resetCursorVisibility();
        updateSelectionUI();

    } //updateFromSelection

    function updateSelectionUI():Void {

        if (willUpdateSelection) return;

        willUpdateSelection = true;
        app.onceImmediate(doUpdateSelectionUI);

    }

    function doUpdateSelectionUI():Void {

        willUpdateSelection = false;

        if (!inputActive) {
            clearSelectionUI();
            return;
        }

        var glyphQuads = entity.glyphQuads;
        var selectionStart = app.textInput.selectionStart;
        var selectionEnd = app.textInput.selectionEnd;

        var backgroundIndex = -1;
        var backgroundCurrentLine = -1;
        var backgroundLeft:Float = -1;
        var backgroundTop:Float = -1;
        var backgroundRight:Float = -1;
        var backgroundBottom:Float = -1;
        var pad = Math.round(entity.pointSize * 0.2);
        var selectionHeight = Math.ceil(entity.pointSize * 1.1);
        var cursorWidth:Float = 1;
        var cursorHeight:Float = Math.ceil(entity.pointSize);

        var hasCharsSelection = selectionEnd > selectionStart;

        inline function addSelectionBackground() {

            backgroundIndex++;

            var bg = selectionBackgrounds[backgroundIndex];
            if (bg == null) {
                bg = new Quad();
                selectionBackgrounds[backgroundIndex] = bg;

                bg.depth = -1;
                entity.add(bg);
                bg.autorun(function() {
                    bg.color = theme.focusedFieldSelectionColor;
                });
            }
            bg.pos(backgroundLeft - pad, backgroundTop - pad);
            bg.size(backgroundRight + pad * 2 - backgroundLeft, backgroundBottom + pad * 2 - backgroundTop);

        } //addSelectionBackground

        inline function createTextCursorIfNeeded() {

            if (textCursor == null) {
                textCursor = new Quad();
                textCursor.autorun(function() {
                    textCursor.color = theme.lightTextColor;
                });
                textCursor.depth = 0;
                entity.add(textCursor);
            }

        } //createTextCursorIfNeeded

        if (hasCharsSelection) {

            // Clear cursor as we display a selection
            if (textCursor != null) {
                textCursor.destroy();
                textCursor = null;
            }

            // Compute selection bacgkrounds
            for (i in 0...glyphQuads.length) {
                var glyphQuad = glyphQuads.unsafeGet(i);
                var index = glyphQuad.index;
                var line = glyphQuad.line;

                if (selectionEnd > selectionStart) {
                    if (backgroundCurrentLine == -1) {
                        if (index >= selectionStart) {
                            backgroundCurrentLine = line;
                            backgroundLeft = glyphQuad.glyphX;
                            backgroundRight = 0;
                            backgroundTop = glyphQuad.glyphY;
                            backgroundBottom = glyphQuad.glyphX + selectionHeight;
                        }
                    }
                    if (backgroundCurrentLine != -1) {
                        if (line > backgroundCurrentLine || index >= selectionEnd) {
                            addSelectionBackground();
                            backgroundCurrentLine = -1;
                            if (index >= selectionStart) {
                                backgroundCurrentLine = line;
                                backgroundLeft = glyphQuad.glyphX;
                                backgroundRight = 0;
                                backgroundTop = glyphQuad.glyphY;
                                backgroundBottom = glyphQuad.glyphY + selectionHeight;
                            }
                        }
                        else {
                            backgroundTop = Math.min(backgroundTop, glyphQuad.glyphY);
                            backgroundRight = glyphQuad.glyphX + glyphQuad.glyphAdvance;
                            backgroundBottom = Math.max(backgroundBottom, glyphQuad.glyphY + selectionHeight);
                        }
                    }
                }
            }
        }
        else {
            // Compute text cursor position
            for (i in 0...glyphQuads.length) {
                var glyphQuad = glyphQuads.unsafeGet(i);
                var index = glyphQuad.index;
                if (index == selectionStart - 1) {
                    createTextCursorIfNeeded();
                    textCursor.pos(
                        glyphQuad.glyphX + glyphQuad.glyphAdvance,
                        glyphQuad.glyphY - pad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + pad * 2
                    );
                    break;
                }
                else if (index >= selectionStart) {
                    createTextCursorIfNeeded();
                    textCursor.pos(
                        glyphQuad.glyphX,
                        glyphQuad.glyphY - pad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + pad * 2
                    );
                    break;
                }
                else if (i == glyphQuads.length - 1) {
                    createTextCursorIfNeeded();
                    textCursor.pos(
                        glyphQuad.glyphX + glyphQuad.glyphAdvance,
                        glyphQuad.glyphY - pad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + pad * 2
                    );
                }
            }
        }

        if (backgroundCurrentLine != -1) {
            addSelectionBackground();
        }

        // Cleanup unused
        while (backgroundIndex < selectionBackgrounds.length - 1) {
            var bg = selectionBackgrounds.pop();
            bg.destroy();
        }

    } //updateSelectionUI

    function clearSelectionUI() {

        if (textCursor != null) {
            textCursor.destroy();
            textCursor = null;
        }

        while (selectionBackgrounds.length > 0) {
            var bg = selectionBackgrounds.pop();
            bg.destroy();
        }

    } //clearSelectionUI

    function indexForPosInLine(text:String, targetLine:Int, posInLine:Int):Int {

        var index = 0;
        var len = text.uLength();
        var currentLine = 0;
        var charsBeforeLine = 0;

        while (index < len) {
            var char = text.uCharAt(index);
            if (targetLine == currentLine) {
                var relativePosition = index - charsBeforeLine;
                if (relativePosition >= posInLine || (relativePosition > 0 && char == "\n")) {
                    break;
                }
            }
            else {
                if (char == "\n") {
                    currentLine++;
                    if (targetLine == currentLine) {
                        charsBeforeLine = index + 1;
                    }
                }
            }
            index++;
        }

        return index;

    } //indexForPosInLine

    function xPositionAtIndex(index:Int):Float {

        var glyphQuads = entity.glyphQuads;

        if (glyphQuads.length == 0) return 0;

        for (i in 0...glyphQuads.length) {
            var glyphQuad = glyphQuads.unsafeGet(i);
            if (glyphQuad.index >= index) {
                if (glyphQuad.glyphX == 0 && glyphQuad.index > index) {
                    if (i >= 1) {
                        var glyphQuadBefore = glyphQuads[i-1];
                        return glyphQuadBefore.glyphX + glyphQuadBefore.glyphAdvance;
                    }
                    else {
                        return 0;
                    }
                }
                else {
                    return glyphQuad.glyphX;
                }
            }
        }

        var lastGlyphQuad = glyphQuads[glyphQuads.length-1];
        return lastGlyphQuad.glyphX + lastGlyphQuad.glyphAdvance;

        return 0;

    } //xPositionAtIndex

    function posInLineForX(targetLine:Int, x:Float):Int {

        var glyphQuads = entity.glyphQuads;
        var pos:Int = 0;

        if (glyphQuads.length == 0 || x == 0) return pos;

        for (i in 0...glyphQuads.length) {
            var glyphQuad = glyphQuads.unsafeGet(i);
            if (glyphQuad.line == targetLine) {
                if (glyphQuad.glyphX >= x) return pos;
                else if (glyphQuad.glyphX + glyphQuad.glyphAdvance >= x) {
                    var distanceAfter = glyphQuad.glyphX + glyphQuad.glyphAdvance - x;
                    var distanceBefore = x - glyphQuad.glyphX;
                    if (distanceBefore <= distanceAfter) {
                        return pos;
                    }
                }
                pos++;
            }
            else if (glyphQuad.line > targetLine) {
                break;
            }
        }

        return pos;

    } //posInLineForX

/// TextInput delegate

    public function textInputClosestPositionInLine(text:String, fromPosition:Int, fromLine:Int, toLine:Int):Int {

        var indexFromLine = indexForPosInLine(text, fromLine, fromPosition);
        var xPosition = xPositionAtIndex(indexFromLine);

        return posInLineForX(toLine, xPosition);

    } //textInputClosestPositionInLine

} //EditText
