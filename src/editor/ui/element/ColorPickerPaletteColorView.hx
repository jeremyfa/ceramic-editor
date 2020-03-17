package editor.ui.element;

class ColorPickerPaletteColorView extends View implements Observable {

/// Components
    
    @component var click:Click;
    
    @component var longPress:LongPress;

    @component var dragDrop:DragDrop;

/// Events

    @event function click(instance:ColorPickerPaletteColorView);

    @event function drop(instance:ColorPickerPaletteColorView);

    @event function longPress(instance:ColorPickerPaletteColorView, info:TouchInfo);

/// Properties

    public var dragging(get, never):Bool;
    inline function get_dragging():Bool return dragDrop.dragging;

    public var dragX(get, never):Float;
    inline function get_dragX():Float return dragDrop.dragX;

    public var dragY(get, never):Float;
    inline function get_dragY():Float return dragDrop.dragY;

    @:allow(editor.ui.element.ColorPickerView)
    static final PALETTE_COLOR_SIZE = 14.0;

    public var colorValue(default, set):Color;
    function set_colorValue(colorValue:Color):Color {
        if (this.colorValue == colorValue)
            return colorValue;
        this.colorValue = colorValue;
        this.color = colorValue;
        return colorValue;
    }

/// Lifecycle

    public function new(colorValue:Color = Color.WHITE) {

        super();

        viewSize(PALETTE_COLOR_SIZE, PALETTE_COLOR_SIZE);

        this.colorValue = colorValue;

        click = new Click();
        click.onClick(this, () -> emitClick(this));

        longPress = new LongPress(click);
        longPress.onLongPress(this, (info) -> emitLongPress(this, info));

        dragDrop = new DragDrop(click, getDraggingVisual, releaseDraggingVisual);
        dragDrop.onDraggingChange(this, handleDraggingChange);

        transform = new Transform();

        autorun(updateStyle);

        bindDraggingDepth();

    }

    function updateStyle() {

        if (dragging) {
            transform.tx = dragX;
            transform.ty = dragY;
            transform.changedDirty = true;
        }
        else if (click.pressed) {
            transform.tx = 0;
            transform.ty = 1;
            transform.changedDirty = true;
        }
        else {
            transform.tx = 0;
            transform.ty = 0;
            transform.changedDirty = true;
        }

    }

/// Drag & Drop

    function bindDraggingDepth() {

        var originalComputedDepth:Float = computedDepth;

        app.onBeginSortVisuals(this, () -> {
            originalComputedDepth = computedDepth;
            if (dragging) {
                computedDepth = 9999999;
            }
        });

        app.onFinishSortVisuals(this, () -> {
            computedDepth = originalComputedDepth;
        });

    }

    function getDraggingVisual() {

        return this;

    }

    function releaseDraggingVisual(visual:Visual) {

        // Nothing to do

    }

    function handleDraggingChange(dragging:Bool, wasDragging:Bool) {

        trace('dragging change dragging=$dragging wasDragging=$wasDragging');

        if (wasDragging && !dragging) {
            emitDrop(this);
        }

    }

    public function drag(pointerX:Float, pointerY:Float) {

        dragDrop.drag(pointerX, pointerY);

    }

    override function toString() {

        return 'ColorPickerPaletteColorView(' + colorValue + ')';

    }

}
