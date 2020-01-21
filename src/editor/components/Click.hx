package editor.components;

class Click extends Entity implements Component implements Observable {

/// Events

    @event function click();

/// Public properties

    public var threshold:Float = -1; // 4

    public var entity:Visual;

    @observe public var pressed(default,null):Bool = false;

/// Internal properties

    var pointerStartX = 0.0;
    var pointerStartY = 0.0;

/// Lifecycle

    function bindAsComponent():Void {

        entity.onPointerDown(this, handlePointerDown);

        entity.onPointerUp(this, handlePointerUp);

        entity.onBlur(this, handleBlur);

    } //bindAsComponent

/// Public API

    public function cancel():Void {

        pressed = false;

    } //cancel

/// Internal

    function handlePointerDown(info:TouchInfo) {

        pointerStartX = screen.pointerX;
        pointerStartY = screen.pointerY;

        pressed = true;

        screen.onPointerMove(this, handlePointerMove);

    } //handlePointerDown

    function handlePointerUp(info:TouchInfo) {

        if (pressed) {
            pressed = false;
            if (entity.hits(info.x, info.y)) {
                emitClick();
            }
        }

    } //handlePointerUp

    function handlePointerMove(info:TouchInfo) {

        if (threshold != -1 && (Math.abs(screen.pointerX - pointerStartX) > threshold || Math.abs(screen.pointerY - pointerStartY) > threshold)) {
            screen.offPointerMove(handlePointerMove);
            pressed = false;
        }

    } //handlePointerMove

    function handleBlur() {
        
        pressed = false;

    } //handleBlur

} //Click
