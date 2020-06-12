package editor.ui.visuals;

class VisualCellDataSource implements CollectionViewDataSource {

    public function new() {

    }

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return model.project.lastSelectedFragment != null ? model.project.lastSelectedFragment.visuals.length : 0;

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

            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;

            cell.title = visualData.entityId;
            cell.subTitle = visualData.entityClass;
            cell.locked = visualData.locked;
            cell.selected = (cell.itemIndex == model.project.lastSelectedFragment.selectedVisualIndex);

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (cell.locked)
                return;

            if (model.project.lastSelectedFragment.selectedVisualIndex != cell.itemIndex) {
                model.project.lastSelectedFragment.selectedVisualIndex = cell.itemIndex;
            }
            else {
                model.project.lastSelectedFragment.selectedVisualIndex = -1;
            }

        });

        cell.bindDragDrop(click, function(itemIndex) {
            if (itemIndex != cell.itemIndex) {
                var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
                if (visualData == null)
                    return;
                var otherVisualData = model.project.lastSelectedFragment.visuals[itemIndex];
                if (otherVisualData == null)
                    return;

                if (itemIndex > cell.itemIndex) {
                    model.project.lastSelectedFragment.moveVisualAboveVisual(visualData, otherVisualData);
                }
                else {
                    model.project.lastSelectedFragment.moveVisualBelowVisual(visualData, otherVisualData);
                }
            }
        });

        cell.handleTrash = function() {
            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;
            model.project.lastSelectedFragment.removeItem(visualData);
        };

        cell.handleLock = function() {
            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;
            visualData.locked = !visualData.locked;
        };

        cell.handleDuplicate = function() {
            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;
            model.project.lastSelectedFragment.duplicateItem(visualData);
        };

        /*
        cell.handleUp = function() {
            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;
            model.project.lastSelectedFragment.moveVisualUpInList(visualData);
        };

        cell.handleDown = function() {
            var visualData = model.project.lastSelectedFragment.visuals[cell.itemIndex];
            if (visualData == null)
                return;
            model.project.lastSelectedFragment.moveVisualDownInList(visualData);
        };
        */

    }

}
