package editor.components;

using ceramic.Extensions;

class SelectText extends Component implements Observable {

/// Internal statics

    static var _point = new Point();

/// Events

    @event function selection(selectionStart:Int, selectionEnd:Int, inverted:Bool);

/// Public properties

    public var entity:Text;

    @observe public var allowSelectingFromPointer:Bool = false;

    @observe public var showCursor:Bool = false;

    @observe public var selectionStart:Int = -1;

    @observe public var selectionEnd:Int = -1;

    @observe public var invertedSelection:Bool = false;

/// Internal properties

    var selectionBackgrounds:Array<Quad> = [];

    var willUpdateSelection:Bool = false;

    var textCursor:Quad = null;

    var textCursorToggleVisibilityTime:Float = 1.0;

/// Lifecycle

    public function new() {

        super();

    } //new

    override function init() {

        entity.onGlyphQuadsChange(updateSelectionGraphics);

        app.onUpdate(this, updateCursorVisibility);
        onShowCursorChange(this, handleShowCursorChange);

        onAllowSelectingFromPointerChange(this, handleAllowSelectingFromPointerChange);

        autorun(updateFromSelection);

        onSelectionStartChange(this, function(_, _) { updateSelectionGraphics(); });
        onSelectionEndChange(this, function(_, _) { updateSelectionGraphics(); });
        
    } //init

/// Internal

    function updateFromSelection() {
        
        var selectionStart = this.selectionStart;
        var selectionEnd = this.selectionEnd;
        var invertedSelection = this.invertedSelection;

        unobserve();

        emitSelection(selectionStart, selectionEnd, invertedSelection);
        resetCursorVisibility();
        updateSelectionGraphics();

        reobserve();

    } //updateFromSelection

    function updateSelectionGraphics():Void {

        if (willUpdateSelection) return;

        willUpdateSelection = true;
        app.onceImmediate(doUpdateSelectionGraphics);

    } //updateSelectionGraphics

    function doUpdateSelectionGraphics():Void {

        willUpdateSelection = false;

        if (selectionStart == -1 || selectionEnd == -1) {
            clearSelectionGraphics();
            return;
        }

        var glyphQuads = entity.glyphQuads;

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

    } //updateSelectionGraphics

    function clearSelectionGraphics() {

        if (textCursor != null) {
            textCursor.destroy();
            textCursor = null;
        }

        while (selectionBackgrounds.length > 0) {
            var bg = selectionBackgrounds.pop();
            bg.destroy();
        }

    } //clearSelectionGraphics

    function handleShowCursorChange(_, _) {

        resetCursorVisibility();

    } //handleShowCursorChange

    function updateCursorVisibility(delta:Float):Void {

        if (textCursor == null) return;

        if (!showCursor) {
            textCursor.visible = false;
            return;
        }

        textCursorToggleVisibilityTime -= delta;
        while (textCursorToggleVisibilityTime <= 0) {
            textCursorToggleVisibilityTime += 0.5;
            textCursor.visible = !textCursor.visible;
        }

    } //updateCursorVisibility

    function resetCursorVisibility() {

        textCursorToggleVisibilityTime = 0.5;
        if (textCursor != null) {
            textCursor.visible = showCursor;
        }

    } //resetCursorVisibility

    function handleAllowSelectingFromPointerChange(_, _) {

        entity.offPointerDown(handlePointerDown);
        entity.offPointerUp(handlePointerUp);

        if (allowSelectingFromPointer) {
            entity.onPointerDown(this, handlePointerDown);
            entity.onPointerUp(this, handlePointerUp);
        }
        else {
            screen.offPointerMove(handlePointerMove);
        }

    } //handleAllowSelectingFromPointerChange

/// Selecting from pointer

    function indexFromScreenPosition(x, y):Int {

        entity.screenToVisual(x, y, _point);

        x = _point.x;
        y = _point.y;

        var line = entity.lineForYPosition(y);
        var posInLine = entity.posInLineForX(line, x);

        return entity.indexForPosInLine(line, posInLine);

    } //indexFromScreenPosition

    function handlePointerDown(info:TouchInfo):Void {

        var x = screen.pointerX;
        var y = screen.pointerY;
        
        var cursorPosition = indexFromScreenPosition(x, y);
        
        selectionStart = cursorPosition;
        selectionEnd = cursorPosition;
        invertedSelection = false;

        resetCursorVisibility();

        screen.onPointerMove(this, handlePointerMove);

    } //handlePointerDown

    function handlePointerMove(info:TouchInfo):Void {

        updateSelectionFromMovingPointer(screen.pointerX, screen.pointerY);

    } //handlePointerMove

    function handlePointerUp(info:TouchInfo):Void {

        screen.offPointerMove(handlePointerMove);

        updateSelectionFromMovingPointer(screen.pointerX, screen.pointerY);

    } //handlePointerUp

    function updateSelectionFromMovingPointer(x:Float, y:Float):Void {

        var index = indexFromScreenPosition(x, y);

        if (invertedSelection) {
            if (index >= selectionEnd) {
                invertedSelection = false;
                selectionStart = selectionEnd;
                selectionEnd = index;
            }
            else {
                selectionStart = index;
            }
        }
        else {
            if (index < selectionStart) {
                invertedSelection = true;
                selectionEnd = selectionStart;
                selectionStart = index;
            }
            else {
                selectionEnd = index;
            }
        }

        resetCursorVisibility();

    } //updateSelectionFromMovingPointer

} //SelectText
