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

            var selected = (cell.itemIndex == project.selectedEditableIndex);

            if (Std.is(editable, EditorFragmentData)) {
                var fragment:EditorFragmentData = cast editable;
                var bundle = fragment.bundle;

                if (!selected && project.lastSelectedFragment == fragment) {
                    selected = true;
                }
    
                cell.title = fragment.fragmentId;
                cell.subTitle = bundle != null ? bundle + '.fragments' : project.defaultBundle + '.fragments';
                cell.kindIcon = DOC;
            }
            /*else if (Std.is(editable, EditorScriptData)) {
                var script:EditorScriptData = cast editable;

                if (!selected && project.selectedScript == script) {
                    selected = true;
                }

                cell.title = script.scriptId;
                cell.subTitle = 'script';
                cell.kindIcon = DOC_TEXT;
            }*/
            else if (Std.is(editable, EditorTilemapData)) {
                // TODO
            }

            cell.selected = selected;

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            if (cell.locked)
                return;

            if (model.project.selectedEditableIndex != cell.itemIndex) {

                var editable = model.project.editables[cell.itemIndex];
                if (Std.is(editable, EditorFragmentData)) {
                    var fragment:EditorFragmentData = cast editable;
                    if (model.project.lastSelectedFragment == fragment) {
                        model.project.selectedEditableIndex = -1;
                        model.project.selectedFragment = null;
                    }
                    else {
                        model.project.selectedEditableIndex = cell.itemIndex;
                        model.project.selectedFragment = fragment;

                        var item = fragment.get(fragment.fragmentId);
                        if (item != null && fragment.entities.indexOf(item) != -1) {
                            var entityData:EditorEntityData = cast item;
                            // Auto-select related script (if any)
                            trace('SELECT SCRIPT FROM ENTITY');
                            var scriptId = entityData.props.get('scriptContent');
                            if (scriptId != null) {
                                var script = model.project.scriptById(scriptId);
                                if (script != null) {
                                    model.project.selectedScript = script;
                                }
                            }
                        }
                    }
                }
                /*else if (Std.is(editable, EditorScriptData)) {
                    var script:EditorScriptData = cast editable;
                    if (model.project.selectedScript == script) {
                        model.project.selectedEditableIndex = -1;
                        model.project.selectedScript = null;
                    }
                    else {
                        model.project.selectedEditableIndex = cell.itemIndex;
                        model.project.selectedScript = script;
                    }
                }*/
                else if (Std.is(editable, EditorTilemapData)) {
                    // TODO
                }

            }
            else {

                var editable = model.project.editables[cell.itemIndex];
                if (Std.is(editable, EditorFragmentData)) {
                    model.project.selectedFragment = null;
                }
                /*else if (Std.is(editable, EditorScriptData)) {
                    var script:EditorScriptData = cast editable;
                    model.project.selectedScript = null;
                }*/
                else if (Std.is(editable, EditorTilemapData)) {
                    // TODO
                }

                model.project.selectedEditableIndex = -1;
            }

        });

        cell.bindDragDrop(click, function(itemIndex) {
            if (itemIndex != cell.itemIndex) {

                var editable = model.project.editables[cell.itemIndex];
                if (editable == null)
                    return;
                var otherEditable = model.project.editables[itemIndex];
                if (otherEditable == null)
                    return;

                if (itemIndex > cell.itemIndex) {
                    model.project.moveEditableAboveEditable(editable, otherEditable);
                }
                else {
                    model.project.moveEditableBelowEditable(editable, otherEditable);
                }
            }
        });

        cell.handleTrash = function() {

            var editable = model.project.editables[cell.itemIndex];
            if (Std.is(editable, EditorFragmentData)) {
                model.project.removeFragment(cast editable);
            }
            /*else if (Std.is(editable, EditorScriptData)) {
                model.project.removeScript(cast editable);
            }*/
            else if (Std.is(editable, EditorTilemapData)) {
                // TODO
            }
        };

        cell.handleDuplicate = function() {

            var editable = model.project.editables[cell.itemIndex];
            if (Std.is(editable, EditorFragmentData)) {
                model.project.duplicateFragment(cast editable);
            }
            /*else if (Std.is(editable, EditorScriptData)) {
                model.project.duplicateScript(cast editable);
            }*/
            else if (Std.is(editable, EditorTilemapData)) {
                // TODO
            }
        };

    }

}
