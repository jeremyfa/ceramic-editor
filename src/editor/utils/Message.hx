package editor.utils;

class Message {

    public static function message(
        title:String,
        ?message:String,
        cancelable:Bool = false,
        ?callback:()->Void) {

        Choice.choose(title, message, [
            'Ok'
        ], cancelable, (index, text) -> {
            if (callback != null) {
                callback();
            }
        });

    }

}