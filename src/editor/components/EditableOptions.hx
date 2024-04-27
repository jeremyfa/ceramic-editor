package editor.components;

@:structInit
class EditableOptions {

    public var highlightPoints:String = null;

    public var highlightMinPoints:Int = -1;

    public var highlightMaxPoints:Int = -1;

    public var highlightMovePointsToZero:Bool = false;

    public var highlightResizeInsteadOfScale:Bool = true;

    public var highlightResizeInsteadOfScaleIfNull:String = null;

    public var highlightResizeInsteadOfScaleIfTrue:String = null;

}