package editor.model;

class EditorVisualData extends EditorEntityData {

    public function new() {

        super();

    }

    override function serializeShouldDestroy() {
        
        log.info('DESTROY VISUAL DATA ${entityId}');

        return true;

    }

    public function depthDidChange() {

        if (fragmentData != null) {
            fragmentData.sortItems();
        }

    }

}
