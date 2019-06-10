package editor.utils;

class AutoSizingViewDataSource implements CollectionViewDataSource {

    public var width:Float = 0;

    public var contentView(default,null):View;

    public function new(contentView:View) {

        this.contentView = contentView;

    } //new

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return 1;

    } //collectionViewSize

    /** Get the item frame at the requested index. */
    public function collectionViewItemFrameAtIndex(collectionView:CollectionView, itemIndex:Int, frame:CollectionViewItemFrame):Void {

        contentView.computeSize(
            collectionView.width,
            collectionView.height,
            collectionView.direction == VERTICAL ? ViewLayoutMask.INCREASE_HEIGHT : ViewLayoutMask.INCREASE_WIDTH,
            true
        );
        frame.width = contentView.computedWidth;
        frame.height = contentView.computedHeight;

    } //collectionViewItemFrameAtIndex

    /** Called when a view is not used anymore at the given index. Lets the dataSource
        do some cleanup if needed, before this view gets reused (if it can).
        Returns `true` if the view can be reused at another index of `false` otherwise. */
    public function collectionViewReleaseItemAtIndex(collectionView:CollectionView, itemIndex:Int, view:View):Bool {

        return true;

    } //collectionViewReleaseItemAtIndex

    /** Get a view at the given index. If `reusableView` is provided,
        it can be recycled as the new item to avoid creating new instances. */
    public function collectionViewItemAtIndex(collectionView:CollectionView, itemIndex:Int, reusableView:View):View {

        return contentView;

    } //collectionViewItemAtIndex

} //CollectionViewDataSource
