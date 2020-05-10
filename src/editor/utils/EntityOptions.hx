package editor.utils;

class EntityOptions {

    public var highlightPoints:String = null;

    public var highlightMinPoints:Int = -1;

    public var highlightMaxPoints:Int = -1;

    static var cache = new Map<String,EntityOptions>();

    private function new() {}

    public static function get(entity:Entity):EntityOptions {
        
        var clazz = Type.getClass(entity);
        if (clazz != null) {
            var className = Type.getClassName(clazz);
            var result = cache.get(className);
            if (result == null) {
                result = new EntityOptions();
                if (Reflect.hasField(clazz, 'editorEntityOptions')) {
                    var method = Reflect.field(clazz, 'editorEntityOptions');
                    var info:Dynamic = method();
                    if (info != null) {
                        if (info.highlightPoints != null)
                            result.highlightPoints = info.highlightPoints;
                        if (info.highlightMinPoints != null)
                            result.highlightMinPoints = info.highlightMinPoints;
                        if (info.highlightMaxPoints != null)
                            result.highlightMaxPoints = info.highlightMaxPoints;
                    }
                }
                cache.set(className, result);
            }
            return result;
        }

        return null;

    }
    
}