package editor.model;

class EditorTimelineKeyframe extends Model {

    @serialize public var index:Int = -1;

    @serialize public var easing:Easing = NONE;

    @serialize public var value:Dynamic = null;

    public function new() {

        super();

    }

}