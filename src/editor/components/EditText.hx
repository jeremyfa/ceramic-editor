package editor.components;

using ceramic.Extensions;
using unifill.Unifill;
using StringTools;

class EditText extends Component implements TextInputDelegate {

/// Internal statics

    static var _point = new Point();

/// Events

    @event function update(content:String);

    @event function stop();

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

    public function startInput(content:String, multiline:Bool, selectionStart:Int = -1, selectionEnd:Int = -1):Void {

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
        app.textInput.onStop(this, handleStop);
        app.textInput.onSelection(this, updateFromSelection);

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

    } //startInput

    public function stopInput():Void {

        error('STOP INPUT');

        inputActive = false;

        app.textInput.offUpdate(updateFromTextInput);
        app.textInput.offStop(handleStop);
        app.textInput.offSelection(updateFromSelection);
        app.textInput.stop();

        updateSelectionUI();

        emitStop();

    } //stopInput

/// Internal

    function handleStop():Void {

        stopInput();

    } //handleStop

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
        var backgroundPad = Math.round(entity.pointSize * 0.1);
        var cursorPad = Math.round(entity.pointSize * 0.2);
        var selectionHeight = Math.ceil(entity.pointSize * 1.1);
        var cursorWidth:Float = 1;
        var cursorHeight:Float = Math.ceil(entity.pointSize);
        var computedLineHeight = entity.lineHeight * entity.font.lineHeight * entity.pointSize / entity.font.pointSize;
        var lineBreakWidth:Float = entity.pointSize * 0.4;

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
            if (backgroundLeft == 0) {
                bg.pos(backgroundLeft - backgroundPad, backgroundTop - backgroundPad);
                bg.size(backgroundRight + backgroundPad - backgroundLeft, backgroundBottom + backgroundPad * 2 - backgroundTop);
            } 
            else {
                bg.pos(backgroundLeft, backgroundTop - backgroundPad);
                bg.size(backgroundRight - backgroundLeft, backgroundBottom + backgroundPad * 2 - backgroundTop);
            }

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
                            if (i > 0 && index > selectionStart && glyphQuad.posInLine == 0) {
                                // Selected a line break
                                var prevGlyphQuad = glyphQuads[i - 1];
                                var startLine = textInputLineForIndex(selectionStart);
                                var endLine = textInputLineForIndex(selectionEnd);
                                var matchedLine = glyphQuad.line;
                                if (endLine > startLine && startLine == prevGlyphQuad.line) {
                                    // Selection begins with a line break
                                    backgroundCurrentLine = line - 1;
                                    backgroundLeft = prevGlyphQuad.glyphX + prevGlyphQuad.glyphAdvance;
                                    backgroundRight = prevGlyphQuad.glyphX + prevGlyphQuad.glyphAdvance + lineBreakWidth;
                                    backgroundTop = prevGlyphQuad.glyphY;
                                    backgroundBottom = prevGlyphQuad.glyphY + selectionHeight;
                                    addSelectionBackground();
                                }
                                backgroundCurrentLine = -1;
                                if (index >= selectionStart && index < selectionEnd) {
                                    backgroundCurrentLine = line;
                                    backgroundLeft = glyphQuad.glyphX;
                                    backgroundRight = 0;
                                    backgroundTop = glyphQuad.glyphY;
                                    backgroundBottom = glyphQuad.glyphY + selectionHeight;
                                }
                            }
                            else if (index <= selectionEnd) {
                                backgroundCurrentLine = line;
                                backgroundLeft = glyphQuad.glyphX;
                                backgroundRight = glyphQuad.glyphX + glyphQuad.glyphAdvance;
                                backgroundTop = glyphQuad.glyphY;
                                backgroundBottom = glyphQuad.glyphY + selectionHeight;
                            }
                        }
                    }
                    if (backgroundCurrentLine != -1) {
                        if (line > backgroundCurrentLine || index >= selectionEnd) {
                            if (i > 0 && glyphQuad.posInLine == 0 && selectionEnd - 1 > glyphQuads[i-1].index) {
                                // Line break inside selection
                                var prevGlyphQuad = glyphQuads[i - 1];
                                backgroundRight = prevGlyphQuad.glyphX + prevGlyphQuad.glyphAdvance + lineBreakWidth;
                            }
                            addSelectionBackground();
                            backgroundCurrentLine = -1;
                            if (index >= selectionStart && index < selectionEnd) {
                                backgroundCurrentLine = line;
                                backgroundLeft = glyphQuad.glyphX;
                                backgroundRight = glyphQuad.glyphX + glyphQuad.glyphAdvance;
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
                        glyphQuad.glyphY - cursorPad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + cursorPad * 2
                    );
                    break;
                }
                else if (index >= selectionStart) {
                    createTextCursorIfNeeded();
                    textCursor.pos(
                        glyphQuad.glyphX,
                        glyphQuad.glyphY - cursorPad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + cursorPad * 2
                    );
                    var glyphLine = glyphQuad.line;
                    var realLine = textInputLineForIndex(selectionStart);
                    while (realLine < glyphLine) {
                        textCursor.pos(
                            0,
                            textCursor.y - computedLineHeight
                        );
                        glyphLine--;
                    }
                    break;
                }
                else if (i == glyphQuads.length - 1) {
                    createTextCursorIfNeeded();
                    textCursor.pos(
                        glyphQuad.glyphX + glyphQuad.glyphAdvance,
                        glyphQuad.glyphY - cursorPad * 0.5
                    );
                    textCursor.size(
                        cursorWidth,
                        cursorHeight + cursorPad * 2
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

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 0;

        for (i in 0...glyphQuads.length) {
            var glyphQuad = glyphQuads.unsafeGet(i);
            if (glyphQuad.line == targetLine && glyphQuad.posInLine >= posInLine) {
                return glyphQuad.index + posInLine - glyphQuad.posInLine;
            }
            else if (glyphQuad.line > targetLine) {
                return glyphQuad.index - glyphQuad.posInLine - (glyphQuad.line - targetLine);
            }
        }

        return text.uLength();

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

    public function textInputClosestPositionInLine(fromPosition:Int, fromLine:Int, toLine:Int):Int {

        var text = app.textInput.text;

        var indexFromLine = indexForPosInLine(text, fromLine, fromPosition);
        var xPosition = xPositionAtIndex(indexFromLine);

        return posInLineForX(toLine, xPosition);

    } //textInputClosestPositionInLine

    public function textInputNumberOfLines():Int {

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 1;

        return glyphQuads[glyphQuads.length - 1].line + 1;

    } //textInputNumberOfLines

    public function textInputIndexForPosInLine(lineNumber:Int, lineOffset:Int):Int {

        var text = app.textInput.text;

        return indexForPosInLine(text, lineNumber, lineOffset);

    } //textInputIndexForPosInLine

    public function textInputLineForIndex(index:Int):Int {

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 0;

        for (i in 0...glyphQuads.length) {
            var glyphQuad = glyphQuads.unsafeGet(i);
            if (glyphQuad.index >= index) {
                if (glyphQuad.posInLine > index - glyphQuad.index) {
                    var currentLineIndex = glyphQuad.index - glyphQuad.posInLine;
                    var line = glyphQuad.line;
                    while (currentLineIndex > index) {
                        currentLineIndex--;
                        line--;
                    }
                    return line;
                }
                else {
                    return glyphQuad.line;
                }
            }
        }

        return glyphQuads[glyphQuads.length-1].line;

    } //textInputLineForIndex

    public function textInputPosInLineForIndex(index:Int):Int {

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 0;

        for (i in 0...glyphQuads.length) {
            var glyphQuad = glyphQuads.unsafeGet(i);
            if (glyphQuad.index >= index) {
                var pos = glyphQuad.posInLine + index - glyphQuad.index;
                if (pos < 0) {
                    var targetLine = textInputLineForIndex(index);
                    var j = i - 1;
                    while (j >= 0) {
                        var glyphQuadBefore = glyphQuads.unsafeGet(j);
                        if (glyphQuadBefore.line == targetLine) {
                            pos = glyphQuadBefore.posInLine + index - glyphQuadBefore.index;
                            return pos;
                        }
                        else if (glyphQuadBefore.line < targetLine) {
                            return 0;
                        }
                        j--;
                    }
                }
                return pos >= 0 ? pos : 0;
            }
        }

        return 0;

    } //textInputPosInLineForIndex

} //EditText
