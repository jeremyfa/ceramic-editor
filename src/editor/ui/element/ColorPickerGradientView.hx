package editor.ui.element;

using ceramic.Extensions;

class ColorPickerGradientView extends View {

    @event function updateColorFromPointer();

    static var _point = new Point();

    public var colorValue(default, set):Color = Color.WHITE;
    function set_colorValue(colorValue:Color):Color {
        if (this.colorValue == colorValue) return colorValue;
        this.colorValue = colorValue;
        var tintColor = Color.fromHSL(colorValue.hue, 1, 0.5);
        tintGradient.colors[1] = new AlphaColor(tintColor);
        tintGradient.colors[2] = new AlphaColor(tintColor);
        updatePointerFromColor();
        return colorValue;
    }

    var blackGradient:Mesh;

    var tintGradient:Mesh;

    var colorPointer:Quad;

    public function new() {

        super();
        
        transparent = true;

        tintGradient = new Mesh();
        tintGradient.colorMapping = VERTICES;
        tintGradient.depth = 1;
        add(tintGradient);

        blackGradient = new Mesh();
        blackGradient.colorMapping = VERTICES;
        blackGradient.depth = 2;
        add(blackGradient);

        colorPointer = new Quad();
        colorPointer.anchor(0.5, 0.5);
        colorPointer.size(4, 4);
        colorPointer.depth = 3;
        colorPointer.color = Color.BLACK;
        {
            var internal = new Quad();
            internal.color = Color.WHITE;
            internal.size(2, 2);
            internal.pos(1, 1);
            colorPointer.add(internal);
        }
        add(colorPointer);

        blackGradient.vertices = [
            0, 0,
            1, 0,
            1, 1,
            0, 1
        ];

        blackGradient.indices = [
            0, 1, 2,
            0, 2, 3
        ];

        blackGradient.colors[0] = new AlphaColor(Color.WHITE, 0);
        blackGradient.colors[1] = new AlphaColor(Color.WHITE, 0);
        blackGradient.colors[2] = new AlphaColor(Color.BLACK);
        blackGradient.colors[3] = new AlphaColor(Color.BLACK);

        tintGradient.vertices = blackGradient.vertices;
        tintGradient.indices = blackGradient.indices;

        tintGradient.colors[0] = new AlphaColor(Color.WHITE);

        var tintColor = Color.fromHSL(colorValue.hue, 1, 0.5);
        tintGradient.colors[1] = new AlphaColor(tintColor);
        tintGradient.colors[2] = new AlphaColor(tintColor);

        tintGradient.colors[3] = new AlphaColor(Color.WHITE);

        updatePointerFromColor();

        onPointerDown(this, handlePointerDown);
        onPointerUp(this, handlePointerUp);

    } //new

    function updatePointerFromColor() {

        var lightness = colorValue.lightness;
        var saturation = colorValue.saturation;

        colorPointer.pos(
            width * saturation,
            height * (1.0 - lightness)
        );

    } //updatePointerFromColor

    override function layout() {

        blackGradient.scale(width, height);
        tintGradient.scale(width, height);

        updatePointerFromColor();

    } //layout

/// Pointer events

    function handlePointerDown(info:TouchInfo) {
        
        screen.onPointerMove(this, handlePointerMove);
        
        updateColorFromTouchInfo(info);

    } //handlePointerDown

    function handlePointerMove(info:TouchInfo) {

        updateColorFromTouchInfo(info);

    } //handlePointerMove

    function handlePointerUp(info:TouchInfo) {

        screen.offPointerMove(handlePointerMove);

        updateColorFromTouchInfo(info);

    } //handlePointerUp

    function updateColorFromTouchInfo(info:TouchInfo) {

        screenToVisual(info.x, info.y, _point);

        var hue = colorValue.hue;

        var lightness = 1 - (_point.x / height);
        if (lightness < 0)
            lightness = 0;
        if (lightness > 1)
            lightness = 1;

        var saturation = _point.y / width;
        if (saturation < 0)
            saturation = 0;
        if (saturation > 1)
            saturation = 1;

        this.colorValue = Color.fromHSL(
            hue, saturation, lightness
        );

        updatePointerFromColor();

        emitUpdateColorFromPointer();

    } //updateColorFromTouchInfo

} //ColorPickerGradientView
