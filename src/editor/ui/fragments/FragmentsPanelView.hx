package editor.ui.fragments;

class FragmentsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allFragmentsTitle:SectionTitleView;

    var allFragmentsCollectionView:CollectionView;

    var allFragmentsBottomBorderView:View;

    var selectedFragmentTitle:SectionTitleView;

/// Lifecycle

    public function new() {

        super();

        initAllFragmentsSection();
        initSelectedFragmentSection();
        initAddFragmentButton();

        autorun(updateStyle);

    } //new

    function initAllFragmentsSection() {

        allFragmentsTitle = new SectionTitleView();
        allFragmentsTitle.content = 'All fragments';
        add(allFragmentsTitle);

        allFragmentsCollectionView = new CollectionView();
        allFragmentsCollectionView.viewSize(fill(), percent(25));
        allFragmentsCollectionView.transparent = true;
        allFragmentsCollectionView.contentView.transparent = true;
        allFragmentsCollectionView.contentView.borderTopSize = 1;
        allFragmentsCollectionView.contentView.borderPosition = OUTSIDE;
        allFragmentsCollectionView.dataSource = new FragmentCellDataSource();
        allFragmentsCollectionView.clip = allFragmentsCollectionView;
        allFragmentsCollectionView.scroller.pointerEventsOutsideBounds = false;
        add(allFragmentsCollectionView);

        allFragmentsBottomBorderView = new View();
        allFragmentsBottomBorderView.viewSize(fill(), 0);
        allFragmentsBottomBorderView.borderPosition = OUTSIDE;
        allFragmentsBottomBorderView.borderTopSize = 1;
        add(allFragmentsBottomBorderView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.fragments.length;
            if (length != prevLength) {
                prevLength = length;
                allFragmentsCollectionView.reloadData();
            }
        });

    } //initAllFragmentsSection

    function initSelectedFragmentSection() {

        selectedFragmentTitle = new SectionTitleView();
        selectedFragmentTitle.content = 'Selected fragment';
        add(selectedFragmentTitle);

    } //initSelectedFragmentSection

    function initAddFragmentButton() {

        // TODO

    } //initAddFragmentButton

/// Layout

    override function layout() {

        super.layout();

        var dataSource:FragmentCellDataSource = cast allFragmentsCollectionView.dataSource;
        dataSource.width = width;

    } //layout

/// Internal

    function updateStyle() {

        allFragmentsCollectionView.contentView.borderTopColor = theme.mediumBorderColor;
        allFragmentsBottomBorderView.borderTopColor = theme.mediumBorderColor;

    } //updateStyle

} //FragmentsPanelView
