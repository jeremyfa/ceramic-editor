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

        entity.onPointerDown(this, handlePointerDown);

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

        entity.offPointerDown(handlePointerDown);

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

    function handlePointerDown(info:TouchInfo):Void {

        var x = screen.pointerX;
        var y = screen.pointerY;
        
        entity.screenToVisual(x, y, _point);

        x = _point.x;
        y = _point.y;

        var line = entity.lineForYPosition(y);
        var posInLine = entity.posInLineForX(line, x);

        var cursorPosition = entity.indexForPosInLine(line, posInLine);
        
        app.textInput.updateSelection(cursorPosition, cursorPosition);
        resetCursorVisibility();

    } //handlePointerDown

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
                                var startLine = entity.lineForIndex(selectionStart);
                                var endLine = entity.lineForIndex(selectionEnd);
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
                    var realLine = entity.lineForIndex(selectionStart);
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

/// TextInput delegate

    public function textInputClosestPositionInLine(fromPosition:Int, fromLine:Int, toLine:Int):Int {

        var indexFromLine = entity.indexForPosInLine(fromLine, fromPosition);
        var xPosition = entity.xPositionAtIndex(indexFromLine);

        return entity.posInLineForX(toLine, xPosition);

    } //textInputClosestPositionInLine

    public function textInputNumberOfLines():Int {

        var glyphQuads = entity.glyphQuads;
        if (glyphQuads.length == 0) return 1;

        return glyphQuads[glyphQuads.length - 1].line + 1;

    } //textInputNumberOfLines

    public function textInputIndexForPosInLine(lineNumber:Int, lineOffset:Int):Int {

        return entity.indexForPosInLine(lineNumber, lineOffset);

    } //textInputIndexForPosInLine

    public function textInputLineForIndex(index:Int):Int {

        return entity.lineForIndex(index);

    } //textInputLineForIndex

    public function textInputPosInLineForIndex(index:Int):Int {

        return entity.posInLineForIndex(index);

    } //textInputPosInLineForIndex

} //EditText
