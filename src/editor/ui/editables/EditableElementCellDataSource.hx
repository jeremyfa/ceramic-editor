package editor.ui.editables;

class EditableElementCellDataSource implements CollectionViewDataSource {

    public function new() {

    }

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return model.project.editables.length;

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
            var editable = project.editables[cell.itemIndex];
            if (editable == null)
                return;

            cell.selected = (cell.itemIndex == project.selectedEditableIndex);

            if (Std.is(editable, EditorFragmentData)) {
                var fragment:EditorFragmentData = cast editable;
                var bundle = fragment.bundle;
    
                cell.title = fragment.fragmentId;
                cell.subTitle = bundle != null ? bundle + '.fragments' : project.defaultBundle + '.fragments';
            }
            else if (Std.is(editable, EditorTilemapData)) {
                // TODO
            }

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (model.project.selectedEditableIndex != cell.itemIndex) {
                model.project.selectedEditableIndex = cell.itemIndex;
            }
            else {
                model.project.selectedEditableIndex = -1;
            }

        });

    }

}
