package editor.utils;

class EntityOptions {

    public var highlightPoints:String = null;

    public var highlightMinPoints:Int = -1;

    public var highlightMaxPoints:Int = -1;

    public var highlightMovePointsToZero:Bool = false;

    static var cache = new Map<String,EntityOptions>();

    private function new() {}

    public static function get(entity:Entity):EntityOptions {
        
        var clazz = Type.getClass(entity);
        if (clazz != null) {
            var className = Type.getClassName(clazz);
            var result = cache.get(className);
            if (result == null) {
                result = new EntityOptions();
                var editableType = editor.getEditableType(className);
                if (editableType != null && editableType.meta != null && editableType.meta.editable != null && Std.is(editableType.meta.editable, Array)) {
                    var info:Dynamic = editableType.meta.editable[0];
                    if (info != null && info.highlight != null) {
                        if (info.highlight.points != null)
                            result.highlightPoints = info.highlight.points;
                        if (info.highlight.minPoints != null)
                            result.highlightMinPoints = info.highlight.minPoints;
                        if (info.highlight.maxPoints != null)
                            result.highlightMaxPoints = info.highlight.maxPoints;
                        if (info.highlight.movePointsToZero != null)
                            result.highlightMovePointsToZero = info.highlight.movePointsToZero;
                    }
                }
                cache.set(className, result);
            }
            return result;
        }

        return null;

    }
    
}