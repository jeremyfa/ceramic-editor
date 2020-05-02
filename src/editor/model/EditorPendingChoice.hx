package editor.model;

class EditorPendingChoice extends Model {

    public var title:String;

    public var message:String;

    public var choices:Array<String>;

    public var cancelable:Bool;

    public var callback:(index:Int, text:String)->Void;

    public function new(title:String, message:String, choices:Array<String>, cancelable:Bool = false, callback:(index:Int, text:String)->Void) {

        super();

        this.title = title;
        this.message = message;
        this.choices = choices;
        this.callback = callback;
        this.cancelable = cancelable;

    }

}