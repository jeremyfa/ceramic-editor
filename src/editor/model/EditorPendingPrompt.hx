package editor.model;

class EditorPendingPrompt extends Model {

    public var title:String;

    public var message:String;

    public var params:Array<PromptParam>;

    public var cancelable:Bool;

    public var callback:(result:Array<Dynamic>)->Void;

    public function new(title:String, message:String, params:Array<PromptParam>, cancelable:Bool = false, callback:(result:Array<Dynamic>)->Void) {

        super();

        this.title = title;
        this.message = message;
        this.params = params;
        this.callback = callback;
        this.cancelable = cancelable;

    }

}