package editor.components;

class ItalicText extends Component {

    public var entity:Text;

    public var skewX(default,set):Float = 10;
    function set_skewX(skewX:Float):Float {
        if (this.skewX == skewX) return skewX;
        if (entity != null) applyItalicTransform();
        return skewX;
    }

/// Lifecycle

    override function init():Void {

        entity.onGlyphQuadsChange(this, applyItalicTransform);

    } //init

/// Internal

    function applyItalicTransform() {

        if (entity.glyphQuads == null) return;

        for (i in 0...entity.glyphQuads.length) {
            var glyph = entity.glyphQuads[i];
            glyph.skewX = skewX;
        }

    } //applyItalicTransform

} //ItalicText
