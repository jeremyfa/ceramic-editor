package editor.utils;

class EntityHelpers {

    public static function run(helper:EntityHelperOptions, item:EditorEntityData) {

        if (helper.params == null || helper.params.length == 0) {
            // Run right away
            var entity = editor.view.fragmentEditorView.getEntity(item.entityId);
            if (entity != null) {
                var method:Void->Void = Reflect.field(entity, helper.method);
                Reflect.callMethod(entity, method, []);
            }
            else {
                log.error('Cannot run ${helper.name} helper because there is no entity with id ${item.entityId}');
            }
        }
        else {
            // Need to resolve params before running
            Prompt.promptWithParams(
                helper.name,
                helper.params,
                true,
                function(result) {
                    // Run
                    var entity = editor.view.fragmentEditorView.getEntity(item.entityId);
                    if (entity != null) {
                        var method:Void->Void = Reflect.field(entity, helper.method);
                        Reflect.callMethod(entity, method, result);
                    }
                    else {
                        log.error('Cannot run ${helper.name} helper because there is no entity with id ${item.entityId}');
                    }
                }
            );
        }

    }

}