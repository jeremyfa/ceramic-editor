package editor.ui.element;

using ceramic.Extensions;

class ColorPickerSpectrumView extends View {

    static var PRECISION:Int = 16;

    var spectrum:Mesh;

    public function new() {

        super();
        
        transparent = true;

        spectrum = new Mesh();
        spectrum.colorMapping = VERTICES;
        spectrum.depth = 1;
        add(spectrum);

        spectrum.vertices = [
            0, 0,
            1, 0
        ];

        var vertices = spectrum.vertices;
        var indices = spectrum.indices;
        var colors = spectrum.colors;

        var color = new AlphaColor(Color.fromHSB(0, 1, 1));
        colors.push(color);
        colors.push(color);

        for (i in 0...PRECISION) {

            vertices.push(0);
            vertices.push(i + 1);
            vertices.push(1);
            vertices.push(i + 1);

            var color = new AlphaColor(Color.fromHSB(360 - (i + 1) * 360 / PRECISION, 1, 1));
            colors.push(color);
            colors.push(color);

            indices.push(i * 2);
            indices.push(i * 2 + 1);
            indices.push(i * 2 + 2);
            
            indices.push(i * 2 + 1);
            indices.push(i * 2 + 2);
            indices.push(i * 2 + 3);

        }

    } //new

    override function layout() {

        spectrum.scale(
            width,
            height / PRECISION
        );

    } //layout

} //ColorPickerSpectrumView
