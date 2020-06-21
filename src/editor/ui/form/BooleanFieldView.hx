package editor.ui.form;

class BooleanFieldView extends FieldView implements Observable {

    var switchContainer:View;

    var switchSquare:View;

/// Hooks

    public dynamic function setValue(field:BooleanFieldView, value:Bool):Void {

        // Default implementation does nothing

    }

/// Public properties

    @observe public var value:Bool = false;

    @observe public var overlayStyle:Bool = false;

/// Internal properties

    public function new() {

        super();

        direction = HORIZONTAL;
        align = LEFT;
        
        var pad = 7;
        var w = 25;
        
        switchContainer = new View();
        switchContainer.padding(pad);
        switchContainer.viewSize(w, w);
        switchContainer.borderSize = 1;
        switchContainer.borderPosition = INSIDE;
        switchContainer.transparent = false;
        add(switchContainer);

        switchSquare = new View();
        switchSquare.transparent = false;
        switchSquare.size(w - pad * 2, w - pad * 2);
        switchContainer.add(switchSquare);

        switchContainer.onLayout(this, () -> {
            app.oncePostFlushImmediate(layoutSwitchContainer);
        });

        autorun(updateStyle);
        onValueChange(this, function(_, _) {
            switchContainer.layoutDirty = true;
        });

        #if !(ios || android)
        switchContainer.onPointerDown(this, function(_) {
            toggleValue();
        });
        #else
        var click = new Click();
        switchContainer.component('click', click);
        click.onClick(this, function() {
            toggleValue();
        });
        #end

        app.onKeyDown(this, handleKeyDown);

    }

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

    }

/// Internal

    function handleKeyDown(key:Key) {

        if (FieldManager.manager.focusedField != this) return;

        if (key.scanCode == ScanCode.SPACE) {
            toggleValue();
        }
        else if (key.scanCode == ScanCode.ENTER) {
            if (!this.value) {
                this.value = true;
                setValue(this, true);
            }
        }
        else if (key.scanCode == ScanCode.BACKSPACE || key.scanCode == ScanCode.DELETE) {
            if (this.value) {
                this.value = false;
                setValue(this, false);
            }
        }

    }

    function toggleValue() {

        this.value = !value;
        setValue(this, this.value);

    }

    function updateStyle() {
        
        if (overlayStyle) {
            switchContainer.transparent = true;
        }
        else {
            switchContainer.transparent = false;
            switchContainer.color = theme.darkBackgroundColor;
        }

        if (value) {
            switchSquare.transparent = false;
            switchSquare.color = theme.mediumTextColor;
        }
        else {
            switchSquare.transparent = overlayStyle;
            switchSquare.color = theme.darkBackgroundColor;//theme.darkerTextColor.getDarkened(0.1);
        }

        if (focused) {
            switchContainer.borderColor = theme.focusedFieldBorderColor;
        }
        else {
            switchContainer.borderColor = theme.lightBorderColor;
        }

    }

}
