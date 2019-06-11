package editor.ui.element;

class CellCollectionView extends CollectionView implements Observable {

    @observe public var scrolling(default,null):Bool = false;

    public function new() {

        super();

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

        contentView.onLayout(this, updateBorderDepth);

        autorun(updateStyle);

        app.onUpdate(this, updateScrollingFlag);

    } //new

    function updateScrollingFlag(delta:Float) {

        scrolling = (scroller.status != IDLE);
        
    } //updateScrollingFlag

    override function layout() {

        super.layout();

    } //layout

    function updateBorderDepth() {

        borderDepth = contentView.children.length + 10;

    } //updateBorderDepth

    function updateStyle() {

        contentView.borderTopColor = theme.mediumBorderColor;
        borderBottomColor = theme.mediumBorderColor;
        
    } //updateStyle

} //CellCollectionView
