package editor.ui.element;

class SelectListView extends View implements CollectionViewDataSource implements Observable {

    @observe public var value:String = null;

    @observe public var list:ImmutableArray<String> = [];

    var collectionView:CellCollectionView;

    public function new() {

        super();

        collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), fill());
        collectionView.transparent = true;
        collectionView.dataSource = this;
        add(collectionView);

        autorun(() -> {
            var size = list.length;
            log.debug('list size: $size');
            unobserve();
            collectionView.reloadData();
        });

    }

    /// Layout

    override function layout() {

        collectionView.size(width, height);
        
    }

    /// Data source

    /** Get the number of elements. */
    public function collectionViewSize(collectionView:CollectionView):Int {

        return list.length;

    }

    /** Get the item frame at the requested index. */
    public function collectionViewItemFrameAtIndex(collectionView:CollectionView, itemIndex:Int, frame:CollectionViewItemFrame):Void {

        frame.width = collectionView.width;
        frame.height = 30;

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

            var value = list[cell.itemIndex];

            cell.title = value;
            cell.selected = (value == this.value);

        });

        var click = new Click();
        cell.component('click', click);
        click.onClick(cell, function() {

            this.value = list[cell.itemIndex];

        });

    }

}  