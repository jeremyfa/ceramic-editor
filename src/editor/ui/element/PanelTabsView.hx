package editor.ui.element;

class PanelTabsView extends LinearLayout implements Observable {

/// Properties

    public var tabViews(default,null):TabsView;

    @observe public var contentView:View = null;

/// Lifecycle

    public function new() {

        super();

        direction = VERTICAL;
        transparent = false;
        borderPosition = OUTSIDE;

        tabViews = new TabsView();
        add(tabViews);

        autorun(updateContentView);
        autorun(updateStyle);

    } //new

/// Layout

    override function layout() {

        super.layout();

    } //layout

/// Internal

    function updateContentView() {

        var contentView = this.contentView;

        if (contentView != null) {
            add(contentView);
            contentView.viewSize(fill(), fill());
        }

    } //updateContentView

    function updateStyle() {

        color = theme.lightBackgroundColor;

        borderLeftSize = 1;
        borderLeftColor = theme.darkBorderColor;

    } //updateStyle

} //PanelTabsView
