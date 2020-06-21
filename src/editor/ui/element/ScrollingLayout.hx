package editor.ui.element;

class ScrollingLayout<T:View> extends ScrollView {

    public var layoutView(default, null):T;

    public function new(layoutView:T, withBorders:Bool = false) {

        super();

        this.layoutView = layoutView;
        contentView.add(layoutView);

        viewSize(fill(), fill());
        transparent = true;
        contentView.transparent = true;
        clip = this;
        scroller.allowPointerOutside = false;
        scroller.bounceMinDuration = 0;
        scroller.bounceDurationFactor = 0;
        
        if (withBorders) {
            contentView.borderTopSize = 1;
            contentView.borderPosition = OUTSIDE;
            borderBottomSize = 1;
            borderPosition = INSIDE;
        }

        #if !(ios || android)
        scroller.dragEnabled = false;
        #end

    }

    override function layout() {

        scroller.pos(0, 0);
        scroller.size(width, height);

        if (direction == VERTICAL) {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_HEIGHT, true);
            layoutView.size(layoutView.computedWidth, Math.max(layoutView.computedHeight, height));
            
            if (layoutView.computedHeight - scroller.scrollY < height) {
                scroller.scrollY = layoutView.computedHeight - height;
            }

        } else {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_WIDTH, true);
            layoutView.size(Math.max(layoutView.computedWidth, width), layoutView.computedHeight);
            
            if (layoutView.computedWidth - scroller.scrollX < width) {
                scroller.scrollX = layoutView.computedWidth - width;
            }
        }
        
        contentView.size(layoutView.width, layoutView.height);

        scroller.scrollToBounds();

    }

}
