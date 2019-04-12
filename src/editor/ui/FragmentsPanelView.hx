package editor.ui;

class FragmentsPanelView extends LinearLayout implements Observable {

/// Lifecycle

    public function new() {

        super();

        initAllFragmentsSection();
        initAddFragmentButton();

    } //new

    function initAllFragmentsSection() {

        var title = new SectionTitleView();
        title.content = 'All fragments';
        add(title);

        

    } //initAllFragmentsSection

    function initAddFragmentButton() {

        // TODO

    } //initAddFragmentButton

} //FragmentsPanelView
