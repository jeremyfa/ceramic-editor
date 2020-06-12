package editor.ui.element;

class RowSeparator extends View {

    var border1:Quad;

    public function new() {

        super();

        transparent = true;

        border1 = new Quad();
        add(border1);

        autorun(updateStyle);

    }

    override function layout() {

        border1.size(1, height);
        border1.pos(width * 0.5, 0);

    }

    function updateStyle() {

        border1.color = theme.darkBorderColor;

    }

}