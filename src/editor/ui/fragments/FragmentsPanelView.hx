package editor.ui.fragments;

class FragmentsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allFragmentsTitle:SectionTitleView;

    var allFragmentsCollectionView:CollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllFragmentsSection();
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
        allFragmentsCollectionView.borderBottomSize = 1;
        allFragmentsCollectionView.dataSource = new FragmentCellDataSource();
        allFragmentsCollectionView.clip = allFragmentsCollectionView;
        add(allFragmentsCollectionView);

    } //initAllFragmentsSection

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

        allFragmentsCollectionView.borderBottomColor = theme.mediumBorderColor;

    } //updateStyle

} //FragmentsPanelView
