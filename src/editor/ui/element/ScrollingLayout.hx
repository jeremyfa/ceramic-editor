package editor.ui.element;

class ScrollingLayout extends ScrollView {

    var layoutView:View;

    public function new(layoutView:View, ?id:String) {

        super();

        this.id = id;

        this.layoutView = layoutView;
        contentView.add(layoutView);

        viewSize(fill(), fill());
        transparent = true;
        contentView.transparent = true;
        contentView.borderTopSize = 1;
        contentView.borderPosition = OUTSIDE;
        borderBottomSize = 1;
        borderPosition = INSIDE;
        clip = this;
        scroller.allowPointerOutside = false;

        #if !(ios || android)
        scroller.dragEnabled = false;
        #end

    } //new

    override function layout() {

        scroller.pos(0, 0);
        scroller.size(width, height);

        //if (id == 'DEB') {
            log.debug('ScrollingLayout($id) width=$width height=$height direction=$direction');
        //}

        if (direction == VERTICAL) {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_HEIGHT, true);
            layoutView.applyComputedSize();
        } else {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_WIDTH, true);
            layoutView.applyComputedSize();
        }
        
        contentView.size(layoutView.width, layoutView.height);

    } //layout

} //ScrollingLayout
