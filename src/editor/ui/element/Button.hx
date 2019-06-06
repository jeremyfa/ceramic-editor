package editor.ui.element;

class Button extends TextView implements Observable {

/// Components

    @component var click:Click;

/// Events

    @event function click();

/// Properties

    public var pressed(get,never):Bool;
    inline function get_pressed():Bool {
        return click.pressed;
    }

/// Internal

    @observe var hover:Bool = false;

/// Lifecycle

    public function new() {

        super();

        click = new Click();
        click.threshold = -1;
        click.onClick(this, emitClick);

        align = CENTER;
        verticalAlign = CENTER;
        pointSize = 10;
        borderSize = 1;
        borderPosition = INSIDE;
        transparent = false;
        padding(5, 2);

        transform = new Transform();

        onPointerOver(this, function(_) hover = true);
        onPointerOut(this, function(_) hover = false);

        autorun(updateStyle);

    } //new

/// Internal

    function updateStyle() {

        if (pressed) {
            transform.ty = 1;
            transform.changedDirty = true;
        }
        else {
            transform.ty = 0;
            transform.changedDirty = true;
        }

        font = theme.mediumFont10;
        textColor = theme.lightTextColor;

        if (pressed) {
            color = theme.buttonPressedBackgroundColor;
            borderColor = theme.buttonPressedBackgroundColor;
        }
        else if (hover) {
            color = theme.buttonOverBackgroundColor;
            borderColor = theme.lightBorderColor;
        }
        else {
            color = theme.buttonBackgroundColor;
            borderColor = theme.lightBorderColor;
        }

    } //updateStyle

} //Button
