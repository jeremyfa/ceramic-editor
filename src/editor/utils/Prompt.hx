package editor.utils;

import haxe.DynamicAccess;

class Prompt {

    public static function promptWithParams(
        title:String,
        ?message:String,
        params:Array<PromptParam>,
        cancelable:Bool = false,
        callback:(result:Array<Dynamic>)->Void) {

        model.pendingPrompt = new EditorPendingPrompt(
            title, message, params, cancelable, (result) -> {
                model.pendingPrompt = null;
                if (callback != null) {
                    callback(result);
                }
            }
        );

    }

}