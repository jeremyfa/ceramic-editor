package editor.ui.element;

class CellCollectionView extends CollectionView implements Observable {

    @observe public var scrolling(default,null):Bool = false;

    @observe public var overlayStyle:Bool = false;

    public function new() {

        super();

        viewSize(fill(), fill());
        transparent = true;
        contentView.transparent = true;
        contentView.borderPosition = OUTSIDE;
        borderPosition = INSIDE;
        clip = this;
        scroller.allowPointerOutside = false;

        #if !(ios || android)
        scroller.dragEnabled = false;
        #end

        contentView.onLayout(this, updateBorderDepth);

        autorun(updateStyle);

        app.onUpdate(this, updateScrollingFlag);

    }

    function updateScrollingFlag(delta:Float) {

        scrolling = (scroller.status != IDLE);
        
    }

    override function layout() {

        super.layout();

    }

    function updateBorderDepth() {

        borderDepth = contentView.children.length + 10;

    }

    function updateStyle() {

        if (overlayStyle) {
            contentView.borderTopSize = 1;
            borderBottomSize = 1;
            borderTopSize = 1;
            borderBottomColor = theme.lightBorderColor;
        }
        else {
            contentView.borderTopSize = 1;
            borderBottomSize = 1;
            borderTopSize = 0;
            borderBottomColor = theme.mediumBorderColor;
        }

        contentView.borderTopColor = theme.mediumBorderColor;
        contentView.borderBottomColor = theme.mediumBorderColor;
        
    }

}
