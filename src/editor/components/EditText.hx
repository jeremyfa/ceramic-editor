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

    var selectText:SelectText = null;

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

        // Get or init SelectText component
        selectText = cast entity.component('selectText');
        if (selectText == null) {
            selectText = new SelectText();
            entity.component('selectText', selectText);
        }

        selectText.onSelection(this, updateFromSelection);
        
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

    } //startInput

    public function stopInput():Void {

        error('STOP INPUT');

        inputActive = false;

        app.textInput.offUpdate(updateFromTextInput);
        app.textInput.offStop(handleStop);
        app.textInput.offSelection(updateFromInputSelection);

        app.textInput.stop();

        selectText.showCursor = false;
        selectText.allowSelectingFromPointer = false;
        selectText.selectionStart = -1;
        selectText.selectionEnd = -1;

        emitStop();

    } //stopInput

/// Internal

    function handleStop():Void {

        stopInput();

    } //handleStop

    function updateFromTextInput(text:String):Void {

        emitUpdate(text);

    } //updateFromTextInput

    function updateFromSelection(selectionStart:Int, selectionEnd:Int, inverted:Bool):Void {

        app.textInput.updateSelection(selectionStart, selectionEnd, inverted);

    } //updateFromSelection

    function updateFromInputSelection(selectionStart:Int, selectionEnd:Int):Void {

        selectText.selectionStart = selectionStart;
        selectText.selectionEnd = selectionEnd;

    } //updateFromInputSelection

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
