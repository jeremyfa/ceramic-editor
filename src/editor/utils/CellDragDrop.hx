package editor.utils;

using ceramic.VisualTransition;

class CellDragDrop {

    static var _notVisibleTransform:Transform = null;

    public static function bindCellDragDrop(cell:CellView, ?click:Click) {

        if (_notVisibleTransform == null) {
            _notVisibleTransform = new Transform();
            _notVisibleTransform.translate(-99999999, -99999999);
        }

        var dragDrop = new DragDrop(click,
            function() {
                var visual = cell.cloneForDragDrop();
                visual.touchable = false;
                visual.depth = 9999;
                visual.viewSize(cell.width, cell.height);
                visual.computeSize(cell.width, cell.height, ViewLayoutMask.FIXED, true);
                visual.applyComputedSize();
                visual.pos(cell.x, cell.y);
                cell.parent.add(visual);
                return visual;
            },
            function(visual) {
                visual.destroy();
            }
        );
        cell.component('dragDrop', dragDrop);
        dragDrop.onDraggingChange(cell, function(dragging:Bool, wasDragging:Bool) {
            if (dragging) {
                cell.transform = _notVisibleTransform;
            }
            else {
                cell.transform = null;
                var parent = cell.parent;
                for (child in parent.children) {
                    if (child != cell && Std.is(child, CellView)) {
                        var otherCell:CellView = cast child;
                        otherCell.transition(0.0, props -> {
                            props.transform = null;
                        });
                    }
                }
            }
        });
        dragDrop.autorun(() -> {
            var dragging = dragDrop.dragging;
            var dragX = dragDrop.dragX;
            var dragY = dragDrop.dragY;

            unobserve();
            if (dragging) {

                // Move other cells from drag
                //

                var draggingCell:CellView = cast dragDrop.draggingVisual;
                draggingCell.pos(cell.x, cell.y + dragY);

                var cellStep = cell.height;
                var transitionDuration = 0.1;

                var parent = cell.parent;
                for (child in parent.children) {
                    if (child != cell && Std.is(child, CellView)) {
                        var otherCell:CellView = cast child;
                        if (otherCell.transform == null) {
                            otherCell.transform = new Transform();
                        }
                        var prevTargetTy = otherCell.targetTy;
                        var targetTy = prevTargetTy;
                        if (cell.itemIndex > otherCell.itemIndex) {
                            if (draggingCell.y < otherCell.y + otherCell.height * 0.5) {
                                targetTy = cellStep;
                            }
                            else {
                                targetTy = 0;
                            }
                        }
                        else if (cell.itemIndex < otherCell.itemIndex) {
                            if (draggingCell.y > otherCell.y - otherCell.height * 0.5) {
                                targetTy = -cellStep;
                            }
                            else {
                                targetTy = 0;
                            }
                        }
                        else {
                            targetTy = 0;
                        }
                        if (targetTy != prevTargetTy) {
                            otherCell.targetTy = targetTy;
                            otherCell.transition(transitionDuration, props -> {
                                props.transform.ty = targetTy;
                                props.transform.changedDirty = true;
                            });
                        }
                    }
                }

                // Scroll container if reaching bounds with drag
                //
                var scroller = cell.firstParentWithClass(Scroller);
                trace('scroller: $scroller');
            }
        });

    }

}