package editor.ui.scripts;

class ScriptCellDataSource implements CollectionViewDataSource {

    public function new() {

    }

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return model.project.scripts.length;

    }

    /** Get the item frame at the requested index. */
    public function collectionViewItemFrameAtIndex(collectionView:CollectionView, itemIndex:Int, frame:CollectionViewItemFrame):Void {

        frame.width = collectionView.width - 12;
        frame.height = 39;

    }

    /** Called when a view is not used anymore at the given index. Lets the dataSource
        do some cleanup if needed, before this view gets reused (if it can).
        Returns `true` if the view can be reused at another index of `false` otherwise. */
    public function collectionViewReleaseItemAtIndex(collectionView:CollectionView, itemIndex:Int, view:View):Bool {

        return true;

    }

    /** Get a view at the given index. If `reusableView` is provided,
        it can be recycled as the new item to avoid creating new instances. */
    public function collectionViewItemAtIndex(collectionView:CollectionView, itemIndex:Int, reusableView:View):View {

        var cell:CellView = null;
        if (reusableView != null) {
            cell = cast reusableView;
            cell.itemIndex = itemIndex;
        }
        else {
            cell = new CellView();
            cell.itemIndex = itemIndex;
            cell.collectionView = cast collectionView;
            bindCellView(cell);
        }

        return cell;

    }

    function bindCellView(cell:CellView):Void {

        cell.autorun(function() {

            var project = model.project;
            var script = project.scripts[cell.itemIndex];
            if (script == null)
                return;

            var selected = (cell.itemIndex == project.selectedScriptIndex);

            if (!selected && project.selectedScript == script) {
                selected = true;
            }

            cell.title = script.scriptId;
            cell.subTitle = 'script';
            cell.kindIcon = DOC_TEXT;

            cell.selected = selected;

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (cell.locked)
                return;

            if (model.project.selectedScriptIndex != cell.itemIndex) {

                var script = model.project.scripts[cell.itemIndex];
                if (model.project.selectedScript == script) {
                    model.project.selectedScriptIndex = -1;
                    model.project.selectedScript = null;
                }
                else {
                    model.project.selectedScriptIndex = cell.itemIndex;
                    model.project.selectedScript = script;
                }

            }
            else {

                model.project.selectedScript = null;
                model.project.selectedScriptIndex = -1;
            }

        });

        cell.bindDragDrop(click, function(itemIndex) {
            if (itemIndex != cell.itemIndex) {

                var script = model.project.scripts[cell.itemIndex];
                if (script == null)
                    return;
                var otherScript = model.project.scripts[itemIndex];
                if (otherScript == null)
                    return;

                if (itemIndex > cell.itemIndex) {
                    model.project.moveScriptAboveScript(script, otherScript);
                }
                else {
                    model.project.moveScriptBelowScript(script, otherScript);
                }
            }
        });

        cell.handleTrash = function() {

            var script = model.project.scripts[cell.itemIndex];
            model.project.removeScript(script);
        };

        cell.handleDuplicate = function() {

            var script = model.project.scripts[cell.itemIndex];
            model.project.duplicateScript(cast script);
        };

    }

}
