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

    @observe public var inBubble:Bool = false;

/// Internal

    @observe var hover:Bool = false;

/// Lifecycle

    public function new() {

        super();

        click = new Click();
        click.onClick(this, emitClick);

        align = CENTER;
        verticalAlign = CENTER;
        pointSize = 12;
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

        if (inBubble) {
            borderSize = 1;
            borderPosition = INSIDE;
            border.alpha = 0.2;
        }
        else {
            borderSize = 1;
            borderPosition = INSIDE;
            transparent = false;
            border.alpha = 1;
        }

        if (inBubble) {
            borderColor = theme.lightTextColor;
            if (pressed) {
                transparent = false;
                color = Color.WHITE;
                alpha = 0.05;
                border.alpha = 0.33;
            }
            else if (hover) {
                transparent = false;
                color = Color.WHITE;
                alpha = 0.025;
                border.alpha = 0.25;
            }
            else {
                transparent = true;
            }
        }
        else {
            alpha = 1;
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
        }

    } //updateStyle

} //Button
