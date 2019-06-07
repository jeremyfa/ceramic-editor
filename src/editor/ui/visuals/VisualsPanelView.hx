package editor.ui.visuals;

class VisualsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allVisualsCollectionView:CellCollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllVisualsSection();
        initSelectedVisualSection();
        initAddVisualButton();

    } //new

    function initAllVisualsSection() {

        var title = new SectionTitleView();
        title.content = 'All visuals';
        add(title);

        var dataSource = new VisualCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(25));
        collectionView.transparent = true;
        collectionView.dataSource = dataSource;
        add(collectionView);

        onLayout(this, function() {
            dataSource.width = width;
        });

        var prevLength = 0;
        autorun(function() {
            var length = model.project.selectedFragment != null ? model.project.selectedFragment.visuals.length : 0;
            if (length != prevLength) {
                var scrollToBottom = prevLength > 0 && length > prevLength;

                prevLength = length;
                collectionView.reloadData();

                if (scrollToBottom) {
                    collectionView.layoutDirty = true;
                    collectionView.onceLayout(this, function() {
                        collectionView.scroller.scrollTo(
                            collectionView.scroller.scrollX,
                            collectionView.scroller.content.height - collectionView.scroller.height
                        );
                        collectionView.scroller.scrollToBounds();
                    });
                }
            }
        });

        autorun(function() {
            var active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
            title.active = active;
            collectionView.active = active;
        });

    } //initAllFragmentsSection

    function initSelectedVisualSection() {

        var title = new SectionTitleView();
        title.content = 'Selected visual';
        add(title);

        var form = new FormLayout();
        add(form);

        autorun(function() {
            var active = model.project.selectedFragment != null && model.project.selectedFragment.selectedVisual != null;
            title.active = active;
            form.active = active;
        });

    } //initSelectedVisualSection

    function initAddVisualButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add visual';
        button.onClick(this, function() {
            model.project.selectedFragment.selectedVisual = model.project.selectedFragment.addVisual();
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
        });

    } //initAddVisualButton

} //VisualsPanelView
