package editor.ui.element;

/**
 * A view that layouts its children as lines of elements.
 */
class FlowLayout extends View {

    public var itemSpacing(default, set):Float = 0.0;
    function set_itemSpacing(itemSpacing:Float):Float {
        if (this.itemSpacing != itemSpacing) {
            this.itemSpacing = itemSpacing;
            layoutDirty = true;
        }
        return itemSpacing;
    }

    public function new() {

        super();

        transparent = true;

    }

    // TODO compute size

    override function layout() {

        var paddingLeft = ViewSize.computeWithParentSize(paddingLeft, width);
        var paddingTop = ViewSize.computeWithParentSize(paddingTop, height);
        var paddingRight = ViewSize.computeWithParentSize(paddingRight, width);
        var paddingBottom = ViewSize.computeWithParentSize(paddingBottom, height);

        var x = paddingLeft;
        var y = paddingTop;
        var h = 0.0;

        var didPutOneInLine = false;

        if (subviews != null) {
            for (i in 0...subviews.length) {
                var view = subviews[i];
    
                view.computeSizeIfNeeded(width, height, ViewLayoutMask.FLEXIBLE, true);
                view.applyComputedSize();
    
                if (!didPutOneInLine || x + view.width + paddingRight <= width) {
                    // Insert in current line
                    didPutOneInLine = true;
                    view.pos(
                        x + view.width * view.anchorX + view.offsetX,
                        y + view.height * view.anchorY + view.offsetY
                    );
                    h = Math.max(view.height, h);
                }
                else {
                    // Move to next line and insert there
                    didPutOneInLine = false;
                    x = paddingLeft;
                    y += h + itemSpacing;
                    view.pos(
                        x + view.width * view.anchorX + view.offsetX,
                        y + view.height * view.anchorY + view.offsetY
                    );
                    h = view.height;
                }
                
                x += view.width + itemSpacing;
            }
        }

    }

}