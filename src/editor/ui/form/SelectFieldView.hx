package editor.ui.form;

class SelectFieldView extends FieldView implements Observable {

    static var _point = new Point();

    static final LIST_HEIGHT = 220;

/// Hooks

    public dynamic function setValue(field:SelectFieldView, value:String):Void {

        // Default implementation does nothing

    }

/// Public properties

    @observe public var value:String = null;

    @observe public var list:ImmutableArray<String> = [];

    @observe public var nullValueText:String = null;

/// Internal properties

    @observe var listVisible:Bool = false;

    var container:RowLayout;

    var textView:TextView;

    var listView:SelectListView;

    var listContainer:View;

    var tip:Line;

    var listIsAbove:Bool = false;

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

        container.onPointerDown(this, _ -> toggleListVisible());

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
        onNullValueTextChange(listView, (nullValueText, _) -> {
            if (listView != null)
                listView.nullValueText = nullValueText;
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

        // Some keyboard shortcuts
        app.onKeyDown(this, key -> {
            if (key.scanCode == ScanCode.ESCAPE) {
                listVisible = false;
            }
            else if (focused && key.scanCode == ScanCode.DOWN) {
                if (list != null) {
                    if (value == null) {
                        if (list.length > 0) {
                            value = list[0];
                        }
                    }
                    else if (list.indexOf(value) < list.length - 1) {
                        value = list[list.indexOf(value) + 1];
                    }
                }
            }
            else if (focused && key.scanCode == ScanCode.UP) {
                if (list != null) {
                    if (list.indexOf(value) > 0) {
                        value = list[list.indexOf(value) - 1];
                    }
                    else if (nullValueText != null) {
                        value = null;
                    }
                }
            }
            else if (focused && key.scanCode == ScanCode.ENTER) {
                listVisible = true;
            }
            else if (focused && key.scanCode == ScanCode.SPACE) {
                listVisible = !listVisible;
            }
            else if (focused && key.scanCode == ScanCode.BACKSPACE) {
                if (nullValueText != null) {
                    this.value = null;
                }
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
                LIST_HEIGHT
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
        var nullValueText = this.nullValueText;

        unobserve();

        if (value != null) {
            var displayedValue = value.trim().replace("\n", ' ');
            if (displayedValue.length > 20) {
                displayedValue = displayedValue.substr(0, 20) + '...'; // TODO at textview level
            }
            textView.content = displayedValue;
        }
        else {
            textView.content = nullValueText != null ? nullValueText : '';
        }

        setValue(this, value);

        reobserve();

    }

    function updateStyle() {
        
        container.color = theme.darkBackgroundColor;

        textView.font = theme.mediumFont10;
        if (value == null) {
            textView.textColor = theme.mediumTextColor;
            textView.text.skewX = 8;
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
            0,
            _point
        );
        editor.view.screenToVisual(_point.x, _point.y, _point);

        if (editor.view.height - _point.y <= LIST_HEIGHT) {
            listIsAbove = true;
            container.visualToScreen(
                0,
                container.height - LIST_HEIGHT,
                _point
            );
            editor.view.screenToVisual(_point.x, _point.y, _point);
        }
        else {
            listIsAbove = false;
        }
        
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
                listView.nullValueText = this.nullValueText;
                listContainer.add(listView);

                // Update value from list view if a new value is selected
                listView.onValueChange(this, (value, _) -> {
                    this.value = value;
                    this.listVisible = false;
                    focus();
                });
    
                listContainer.active = true;
                updateListPosition();

                listView.scrollToValue(listIsAbove ? END : START);
                app.oncePostFlushImmediate(() -> {
                    if (destroyed)
                        return;
                    listView.scrollToValue(listIsAbove ? END : START);
                    app.onceUpdate(this, _ -> {
                        listView.scrollToValue(listIsAbove ? END : START);
                    });
                });
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
