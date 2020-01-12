package editor.ui.element;

using ceramic.Extensions;

class ColorPickerGradientView extends View {

    @event function updateColorFromPointer();

    static var _point = new Point();

    public var colorValue(default, set):Color = Color.WHITE;
    function set_colorValue(colorValue:Color):Color {
        if (this.colorValue == colorValue) return colorValue;
        this.colorValue = colorValue;
        updateTintColor();
        updatePointerFromColor();
        return colorValue;
    }

    var blackGradient:Mesh;

    var tintGradient:Mesh;

    var colorPointer:Border;

    var targetPointerColor:Color = Color.NONE;

    var pointerColorTween:Tween = null;

    var movingPointer:Bool = false;

    var savedPointerX:Float = 0;

    var savedPointerY:Float = 0;

    public var hue(default, null):Float = 0;

    public function new() {

        super();
        
        clip = this;
        transparent = true;

        tintGradient = new Mesh();
        tintGradient.colorMapping = VERTICES;
        tintGradient.depth = 1;
        add(tintGradient);

        blackGradient = new Mesh();
        blackGradient.colorMapping = VERTICES;
        blackGradient.depth = 2;
        add(blackGradient);

        colorPointer = new Border();
        colorPointer.anchor(0.5, 0.5);
        colorPointer.size(10, 10);
        colorPointer.depth = 3;
        colorPointer.borderPosition = INSIDE;
        colorPointer.borderSize = 1;
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

    public function updateTintColor(?hue:Float) {

        if (hue != null) {
            this.hue = hue;
        }

        var tintColor = Color.fromHSL(this.hue, 1, 0.5);
        tintGradient.colors[1] = new AlphaColor(tintColor);
        tintGradient.colors[2] = new AlphaColor(tintColor);

    } //updateTintColor

    public function savePointerPosition() {

        savedPointerX = colorPointer.x;
        savedPointerY = colorPointer.y;

    } //savePointerPosition

    public function restorePointerPosition() {

        colorPointer.x = savedPointerX;
        colorPointer.y = savedPointerY;

    } //restorePointerPosition

    public function getBrightnessFromPointer():Float {

        var brightness = 1 - (colorPointer.y / height);
        if (brightness < 0)
            brightness = 0;
        if (brightness > 1)
            brightness = 1;

        return brightness;

    } //getBrightnessFromPointer

    public function getSaturationFromPointer():Float {

        var saturation = colorPointer.x / width;
        if (saturation < 0)
            saturation = 0;
        if (saturation > 1)
            saturation = 1;

        return saturation;

    } //getSaturationFromPointer

    function updatePointerFromColor() {

        var brightness = colorValue.brightness;
        var saturation = colorValue.saturation;

        colorPointer.pos(
            width * saturation,
            height * (1.0 - brightness)
        );

        var newPointerColor = Color.WHITE;
        if (brightness > 0.5) {
            newPointerColor = Color.BLACK;
        }

        if (movingPointer) {
            if (targetPointerColor != newPointerColor) {
                targetPointerColor = newPointerColor;
                if (pointerColorTween != null) {
                    pointerColorTween.destroy();
                    pointerColorTween = null;
                }
                var startColor = colorPointer.borderColor;
                pointerColorTween = tween(0.4, 0, 1, (v, t) -> {
                    colorPointer.borderColor = Color.interpolate(startColor, targetPointerColor, v);
                });
            }
        }
        else {
            targetPointerColor = newPointerColor;
            colorPointer.borderColor = targetPointerColor;
        }

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

        movingPointer = true;

    } //handlePointerDown

    function handlePointerMove(info:TouchInfo) {

        updateColorFromTouchInfo(info);

    } //handlePointerMove

    function handlePointerUp(info:TouchInfo) {

        screen.offPointerMove(handlePointerMove);

        updateColorFromTouchInfo(info);

        movingPointer = false;

    } //handlePointerUp

    function updateColorFromTouchInfo(info:TouchInfo) {

        screenToVisual(info.x, info.y, _point);

        var brightness = 1 - (_point.y / height);
        if (brightness < 0)
            brightness = 0;
        if (brightness > 1)
            brightness = 1;

        var saturation = _point.x / width;
        if (saturation < 0)
            saturation = 0;
        if (saturation > 1)
            saturation = 1;

        this.colorValue = Color.fromHSB(
            hue, saturation, brightness
        );

        updatePointerFromColor();

        emitUpdateColorFromPointer();

        colorPointer.pos(
            Math.max(0, Math.min(width, _point.x)),
            Math.max(0, Math.min(height, _point.y))
        );

    } //updateColorFromTouchInfo

} //ColorPickerGradientView
