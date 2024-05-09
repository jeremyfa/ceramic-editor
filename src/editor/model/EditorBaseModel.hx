package editor.model;

import editor.model.fragment.EditorEntityData;
import editor.model.fragment.EditorFragmentData;
import tracker.History;
import tracker.Model;

class EditorBaseModel extends Model {

    public function new() {
        super();
    }

    function historyStep(tryDelayed:Bool = true):Void {
        unobserve();

        var history:History = null;
        if (this is EditorEntityData) {
            final entityData:EditorEntityData = cast this;
            history = entityData.fragment?.project?.history;
        }
        else if (this is EditorFragmentData) {
            final fragmentData:EditorFragmentData = cast this;
            history = fragmentData.project?.history;
        }
        else if (this is EditorProjectData) {
            final projectData:EditorProjectData = cast this;
            history = projectData.history;
        }

        if (history != null) {
            history.step();
        }
        else if (tryDelayed) {
            app.onceImmediate(this, () -> {
                historyStep(false);
            });
        }

        reobserve();
    }

}
