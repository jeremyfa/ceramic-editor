package editor.components;

class Click extends Component {

/// Events

    @event function click();

/// Public properties

    public var entity:Visual;

/// Internal properties

    var pressed:Bool = false;

/// Lifecycle

    override function init():Void {

        entity.onPointerDown(this, function(info) {

            pressed = true;

        });

        entity.onPointerUp(this, function(info) {

            if (pressed) {
                pressed = false;
                emitClick();
            }

        });

        entity.onBlur(this, function() {

            pressed = false;

        });

    } //init

} //Click
