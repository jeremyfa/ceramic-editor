package editor.ui.form;

class SelectFieldView extends FieldView implements Observable {

    static var _point = new Point();

/// Hooks

    public dynamic function setValue(field:SelectFieldView, value:String):Void {

        // Default implementation does nothing

    }

/// Public properties

    @observe public var value:String = null;

    @observe public var list:ImmutableArray<String> = [];

/// Internal properties

    var container:RowLayout;

    var textView:TextView;

    var listView:SelectListView;

    var listContainer:View;

    var tip:Line;

    var listVisible:Bool = true;

    public function new() {

        super();
        transparent = true;

        direction = HORIZONTAL;
        align = LEFT;

        container = new RowLayout();
        container.viewSize(fill(), auto());
        container.padding(6, 6, 6, 6);
        container.borderSize = 1;
        container.borderPosition = INSIDE;
        container.transparent = false;
        container.depth = 1;
        add(container);

        listContainer = new View();
        listContainer.transparent = true;
        listContainer.viewSize(0, 0);
        listContainer.active = false;
        listContainer.depth = 10;
        editor.view.add(listContainer);

        tip = new Line();
        tip.points = [
            -5, -5,
            0, 0,
            5, -5
        ];
        tip.thickness = 1;
        tip.depth = 1;
        container.onLayout(tip, () -> {
            tip.pos(
                container.x + container.width - 13,
                container.y + container.height - 10
            );
        });
        add(tip);
        
        /*var filler = new View();
        filler.transparent = true;
        filler.viewSize(fill(), fill());
        add(filler);*/

        textView = new TextView();
        textView.viewSize(fill(), auto());
        textView.align = LEFT;
        textView.pointSize = 12;
        container.add(textView);

        /*
        editText = new EditText();
        editText.container = textView;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);
        */

        autorun(updateStyle);
        autorun(updateFromValue);
        autorun(updateListContainer);

        container.onLayout(this, layoutContainer);
        listContainer.onLayout(this, layoutListContainer);

        // Update list view value & list when it changes on the field
        onValueChange(listView, (value, _) -> {
            if (listView != null)
                listView.value = value;
        });
        onListChange(listView, (list, _) -> {
            if (listView != null)
                listView.list = list;
        });

        app.onUpdate(this, _ -> updateListVisibility());
        app.onPostUpdate(this, _ -> updateListPosition());

        // If the field is put inside a scrolling layout right after being initialized,
        // check its scroll transform to update position instantly (without loosing a frame)
        app.onceUpdate(this, function(_) {
            var scrollingLayout = getScrollingLayout();
            if (scrollingLayout != null) {
                scrollingLayout.scroller.scrollTransform.onChange(this, updateListPosition);
            }
        });

    }

/// Layout

    override function focus() {

        super.focus();

        /*
        if (!focused) {
            editText.focus();
        }
        */
        
    }

    override function didLostFocus() {

        //

    }

/// Layout

    override function layout() {

        super.layout();

        /*
        listView.pos(0, container.height);
        listView.size(width, 100);
        */

    }

    function layoutContainer() {

        //

    }

    function layoutListContainer() {
        
        if (listView != null) {

            listView.size(
                container.width,
                200
            );
        }

    }

/// Internal

    override function destroy() {

        super.destroy();

        if (listContainer != null) {
            listContainer.destroy();
            listContainer = null;
        }

    }

    /*
    function updateFromEditText(text:String) {

        //

    }

    function handleStopEditText() {

        //

    }
    */

    function updateFromValue() {

        var value = this.value;

        unobserve();

        if (value != null) {
            textView.content = value;
        }
        else {
            textView.content = '';
        }

        reobserve();

    }

    function updateStyle() {
        
        container.color = theme.darkBackgroundColor;

        textView.font = theme.mediumFont10;
        if (value == null) {
            textView.textColor = theme.mediumTextColor;
            textView.text.skewX = 10;
        }
        else {
            textView.textColor = theme.fieldTextColor;
            textView.text.skewX = 0;
        }

        if (focused) {
            tip.color = theme.lightTextColor;
            container.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            tip.color = theme.lighterBorderColor;
            container.borderColor = theme.lightBorderColor;
        }

    }

    /// List

    function updateListVisibility() {

        if (listView == null || !listVisible)
            return;

        if (FieldManager.manager.focusedField == this)
            return;

        var parent = screen.focusedVisual;
        var keepFocus = false;
        while (parent != null) {
            if (parent == listView) {
                keepFocus = true;
                break;
            }
            parent = parent.parent;
        }

        if (!keepFocus) {
            listVisible = false;
        }

    }

    function updateListPosition() {

        if (!listContainer.active)
            return;
        
        container.visualToScreen(
            0,
            container.height,
            _point
        );

        editor.view.screenToVisual(_point.x, _point.y, _point);
        
        var x = _point.x;
        var y = _point.y;

        if (x != listContainer.x || y != listContainer.y)
            listContainer.layoutDirty = true;
    
        listContainer.pos(x, y);

    }

    function toggleListVisible() {

        listVisible = !listVisible;

    }

    function updateListContainer() {

        var listVisible = this.listVisible;
        var value = this.value;

        unobserve();

        if (listVisible) {

            if (listView == null) {
                listView = new SelectListView();
                listView.color = Color.BLACK;
                listView.depth = 10;
                listView.value = this.value;
                listView.list = this.list;
                listContainer.add(listView);

                // Update value from list view if a new value is selected
                listView.onValueChange(this, (value, _) -> this.value = value);
    
                listContainer.active = true;
                updateListPosition();
            }

        }
        else if (!listVisible && listView != null) {

            listView.destroy();
            listView = null;

            listContainer.active = false;
        }

        reobserve();

    }

}
