package editor.ui.entities;

class EntityCellDataSource implements CollectionViewDataSource {

    public function new() {

    }

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return model.project.lastSelectedFragment != null ? model.project.lastSelectedFragment.entities.length : 0;

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

            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;

            cell.title = entityData.entityId;
            cell.subTitle = entityData.entityClass;
            cell.locked = entityData.locked;
            cell.selected = (cell.itemIndex == model.project.lastSelectedFragment.selectedEntityIndex);

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (cell.locked)
                return;

            if (model.project.lastSelectedFragment.selectedEntityIndex != cell.itemIndex) {
                var entity = model.project.lastSelectedFragment.entities[cell.itemIndex];
                model.project.lastSelectedFragment.selectedEntity = entity;

                // Auto-select related script (if any)
                var scriptId = entity.props.get('scriptContent');
                if (scriptId != null) {
                    var script = model.project.scriptById(scriptId);
                    if (script != null) {
                        model.project.selectedScript = script;
                    }
                }
            }
            else {
                model.project.lastSelectedFragment.selectedEntity = null;
            }

        });

        cell.handleTrash = function() {
            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;
            model.project.lastSelectedFragment.removeItem(entityData);
        };

        cell.handleLock = function() {
            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;
            entityData.locked = !entityData.locked;
        };

        cell.handleDuplicate = function() {
            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;
            model.project.lastSelectedFragment.duplicateItem(entityData);
        };

        /*
        cell.handleUp = function() {
            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;
            model.project.lastSelectedFragment.moveEntityUpInList(entityData);
        };

        cell.handleDown = function() {
            var entityData = model.project.lastSelectedFragment.entities[cell.itemIndex];
            if (entityData == null)
                return;
            model.project.lastSelectedFragment.moveEntityDownInList(entityData);
        };
        */

    }

}
