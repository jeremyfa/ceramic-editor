package editor.ui;

class EditorView extends View implements Observable {

/// Properties

    @observe public var panelTabsView:PanelTabsView;

/// Lifecycle

    public function new() {

        super();

        // Panels tabs
        panelTabsView = new PanelTabsView();
        add(panelTabsView);

        autorun(updateTabs);
        autorun(updateTabsContentView);

        // Styles
        autorun(updateStyle);

    } //new

    override function layout() {
        
        var panelsTabsWidth = 300;

        panelTabsView.viewSize(panelsTabsWidth, height);
        panelTabsView.computeSize(panelsTabsWidth, height, ViewLayoutMask.FIXED, true);
        panelTabsView.applyComputedSize();
        panelTabsView.pos(width - panelTabsView.width, 0);

    } //layout

/// Internal

    function updateTabs() {

        var selectedFragment = model.project.selectedFragment;
        unobserve();

        // Keep selected tab name
        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        if (selectedFragment == null) {
            panelTabsView.tabViews.tabs = ['Fragments', 'Assets'];
        }
        else {
            panelTabsView.tabViews.tabs = ['Visuals', 'Fragments', 'Assets'];
        }

        // Restore selected tab name on new tab list
        var selectedIndex = panelTabsView.tabViews.tabs.indexOf(selectedName);
        panelTabsView.tabViews.selectedIndex = selectedIndex != -1 ? selectedIndex : 0;

    } //updateTabs

    function updateTabsContentView() {

        var selectedName = panelTabsView.tabViews.tabs[panelTabsView.tabViews.selectedIndex];

        unobserve();

        var contentViewClass:Class<View> = switch (selectedName) {
            case 'Visuals': VisualsPanelView;
            case 'Fragments': FragmentsPanelView;
            case 'Assets': null;
            default: null;
        }
        var prevContentViewClass = null;
        if (panelTabsView.contentView != null) {
            prevContentViewClass = Type.getClass(panelTabsView.contentView);
        }

        // Update content view if needed
        if (contentViewClass != prevContentViewClass) {
            if (panelTabsView.contentView != null) {
                panelTabsView.contentView.destroy();
                panelTabsView.contentView = null;
            }
            if (contentViewClass != null) {
                panelTabsView.contentView = Type.createInstance(contentViewClass, []);
            }
        }

    } //updateTabsContentView

    function updateStyle() {

        color = theme.windowBackgroundColor;

    } //updateStyle

} //EditorView
