package editor.ui.element;

class ScrollingLayout extends ScrollView {

    var layoutView:View;

    public function new(layoutView:View) {

        super();

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

    } //new

    override function layout() {

        scroller.pos(0, 0);
        scroller.size(width, height);

        if (direction == VERTICAL) {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_HEIGHT, true);
            trace('(INCREASE) COMPUTED FROM HEIGHT($height) TO ${layoutView.computedHeight}');
            //layoutView.computeSize(width, height, ViewLayoutMask.FLEXIBLE_HEIGHT, true);
            //trace('(FLEXIBLE) COMPUTED FROM HEIGHT($height) TO ${layoutView.computedHeight}');
            layoutView.applyComputedSize();
        } else {
            layoutView.computeSize(width, height, ViewLayoutMask.INCREASE_WIDTH, true);
            layoutView.applyComputedSize();
        }
        
        contentView.size(layoutView.width, layoutView.height);

    } //layout

} //ScrollingLayout
