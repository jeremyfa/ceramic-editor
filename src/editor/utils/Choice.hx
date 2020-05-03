package editor.utils;

class Choice {

    public static function choose(
        title:String,
        ?message:String,
        choices:Array<String>,
        cancelable:Bool = false,
        callback:(index:Int, text:String)->Void) {

        model.pendingChoice = new EditorPendingChoice(
            title, message, choices, cancelable, (index, text) -> {
                model.pendingChoice = null;
                if (callback != null) {
                    callback(index, text);
                }
            }
        );

    }

}