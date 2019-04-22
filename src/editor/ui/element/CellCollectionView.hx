package editor.ui.element;

class CellCollectionView extends CollectionView {

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

        contentView.onLayout(this, updateBorderDepth);

        autorun(updateStyle);

    } //new

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
