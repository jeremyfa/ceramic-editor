package editor.ui.element;

class TabsView extends LinearLayout implements Observable {

/// Public properties

    @observe public var tabs:ImmutableArray<String> = [];

    @observe public var selectedIndex:Int = 0;

/// Internal properties

    var tabViews:Array<TabView> = [];

    var beforeBorder:Quad;

    var afterBorder:Quad;

/// Lifecycle

    public function new() {

        super();

        direction = HORIZONTAL;
        transparent = false;
        itemSpacing = 1;

        beforeBorder = new Quad();
        beforeBorder.transparent = false;
        beforeBorder.active = false;
        beforeBorder.depth = 100;
        add(beforeBorder);

        afterBorder = new Quad();
        afterBorder.transparent = false;
        afterBorder.active = false;
        afterBorder.depth = 100;
        add(afterBorder);

        autorun(updateTabViews);
        autorun(updateStyle);

    }

/// Layout

    override function layout() {

        super.layout();

        if (selectedIndex > 0 && tabViews.length > selectedIndex) {
            var selectedTabView = tabViews[selectedIndex];
            beforeBorder.active = true;
            beforeBorder.pos(0, height - 1);
            beforeBorder.size(selectedTabView.x, 1);
        }
        else {
            beforeBorder.active = false;
        }

        if (selectedIndex <= tabViews.length - 1) {
            var selectedTabView = tabViews[selectedIndex];
            afterBorder.active = true;
            afterBorder.pos(selectedTabView.x + selectedTabView.width, height - 1);
            afterBorder.size(width - selectedTabView.x - selectedTabView.width, 1);
        }
        else {
            afterBorder.active = false;
        }

    }

/// Manage tab views

    function updateTabViews() {

        var tabs = this.tabs;

        // Create or update tab views from tabs array
        for (i in 0...tabs.length) {
            var tabView = tabViews[i];
            if (tabView == null) {
                tabView = new TabView();
                tabView.depth = 1;
                tabViews.push(tabView);
                add(tabView);
                initTabView(i, tabView);
            }
        }

        // Remove any unused tab view
        while (tabViews.length > tabs.length) {
            var unusedTabView = tabViews.pop();
            unusedTabView.destroy();
        }

    }

    function initTabView(index:Int, tabView:TabView) {

        tabView.index = index;

        // Auto update name if tabs array changes
        autorun(function() {
            tabView.name = tabs[index];
            tabView.selected = (tabView.index == selectedIndex);
        });
        
        // Change selected index from tab click
        tabView.onPointerDown(this, function(_) {
            selectedIndex = index;
        });

    }

/// Internal

    function updateStyle() {

        color = theme.darkBackgroundColor;

        beforeBorder.color = theme.darkBorderColor;
        afterBorder.color = theme.darkBorderColor;

    }

}
