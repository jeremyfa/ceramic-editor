package editor.components;

class Click extends Component {

/// Events

    @event function click();

/// Public properties

    public var threshold = 4.0;

    public var entity:Visual;

/// Internal properties

    var pressed:Bool = false;

    var pointerStartX = 0.0;
    var pointerStartY = 0.0;

/// Lifecycle

    override function init():Void {

        entity.onPointerDown(this, handlePointerDown);

        entity.onPointerUp(this, handlePointerUp);

        entity.onBlur(this, handleBlur);

    } //init

/// Internal

    function handlePointerDown(info:TouchInfo) {

        pointerStartX = screen.pointerX;
        pointerStartY = screen.pointerY;

        pressed = true;

        screen.onPointerMove(handlePointerMove);

    } //handlePointerDown

    function handlePointerUp(info:TouchInfo) {

        if (pressed) {
            pressed = false;
            emitClick();
        }

    } //handlePointerUp

    function handlePointerMove(info:TouchInfo) {

        if (Math.abs(screen.pointerX - pointerStartX) > threshold || Math.abs(screen.pointerY - pointerStartY) > threshold) {
            screen.offPointerMove(handlePointerMove);
            pressed = false;
        }

    } //handlePointerMove

    function handleBlur() {
        
        pressed = false;

    } //handleBlur

} //Click
