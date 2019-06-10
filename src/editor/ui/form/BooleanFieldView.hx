package editor.ui.form;

class BooleanFieldView extends FieldView implements Observable {

    var switchContainer:View;

    var switchSquare:View;

/// Hooks

    public dynamic function setValue(field:BooleanFieldView, value:Bool):Void {

        // Default implementation does nothing

    } //setValue

/// Public properties

    @observe public var value:Bool = false;

/// Internal properties

    public function new() {

        super();

        direction = HORIZONTAL;
        align = LEFT;
        
        switchContainer = new View();
        switchContainer.padding(4);
        switchContainer.viewSize(23 * 2, 23);
        switchContainer.borderSize = 1;
        switchContainer.borderPosition = INSIDE;
        switchContainer.transparent = false;
        add(switchContainer);

        switchSquare = new View();
        switchSquare.transparent = false;
        switchSquare.size(19, 15);
        switchContainer.add(switchSquare);

        switchContainer.onLayout(this, layoutSwitchContainer);

        autorun(updateStyle);
        onValueChange(this, function(_, _) {
            switchContainer.layoutDirty = true;
        });

        switchContainer.onPointerDown(this, function(_) {
            this.value = !value;
            setValue(this, this.value);
        });

    } //new

/// Layout

    function layoutSwitchContainer() {

        if (value) {
            switchSquare.pos(
                switchContainer.width - switchSquare.width - switchContainer.paddingRight,
                switchContainer.paddingTop
            );
        }
        else {
            switchSquare.pos(
                switchContainer.paddingLeft,
                switchContainer.paddingTop
            );
        }

    } //layoutSwitchContainer

/// Internal

    function updateStyle() {
        
        switchContainer.color = theme.darkBackgroundColor;

        if (value) {
            switchSquare.color = theme.lightTextColor;
        }
        else {
            switchSquare.color = theme.darkerTextColor;
        }

        if (focused) {
            switchContainer.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            switchContainer.borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //BooleanFieldView
