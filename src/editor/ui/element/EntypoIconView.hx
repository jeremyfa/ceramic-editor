package editor.ui.element;

class EntypoIconView extends TextView implements Observable {

    @observe public var icon:Entypo = NOTE_BEAMED;

    public function new() {

        super();

        anchor(0.5, 0.5);
        align = CENTER;
        verticalAlign = CENTER;
        pointSize = 16;
        font = editor.editorAssets.font(Fonts.ENTYPO);
        
        autorun(updateContent);

    }

    function updateContent() {

        this.content = String.fromCharCode(icon);

    }

}