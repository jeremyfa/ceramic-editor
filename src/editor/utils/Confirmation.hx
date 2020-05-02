package editor.utils;

class Confirmation {

    public static function confirm(
        title:String,
        message:String,
        cancelable:Bool = false,
        callback:(confirmed:Bool)->Void) {

        Choice.choose(title, message, [
            'Yes', 'No'
        ], cancelable, (index, text) -> {
            if (callback != null) {
                callback(index == 0);
            }
        });

    }

}