package editor.ui.visuals;

class VisualCellDataSource implements CollectionViewDataSource {

    public function new() {

    }

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return model.project.selectedFragment != null ? model.project.selectedFragment.visuals.length : 0;

    }

    /** Get the item frame at the requested index. */
    public function collectionViewItemFrameAtIndex(collectionView:CollectionView, itemIndex:Int, frame:CollectionViewItemFrame):Void {

        frame.width = collectionView.width;
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

            var visualData = model.project.selectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;

            cell.title = visualData.entityId;
            cell.subTitle = 'default';
            cell.selected = (cell.itemIndex == model.project.selectedFragment.selectedVisualIndex);

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (model.project.selectedFragment.selectedVisualIndex != cell.itemIndex) {
                model.project.selectedFragment.selectedVisualIndex = cell.itemIndex;
            }
            else {
                model.project.selectedFragment.selectedVisualIndex = -1;
            }

        });

    }

}
