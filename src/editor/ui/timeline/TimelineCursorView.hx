package editor.ui.timeline;

class TimelineCursorView extends View implements Observable {

    @observe public var verticalLineExtraHeight:Float = 0;

    var timelineEditorView:TimelineEditorView;

    var verticalLine:Quad;

    var triangle:Triangle;

    var text:TextView;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        this.timelineEditorView = timelineEditorView;

        transparent = true;

        text = new TextView();
        text.anchor(0.5, 1);
        text.align = CENTER;
        text.verticalAlign = BOTTOM;
        text.preRenderedSize = 20;
        text.pointSize = 11;
        text.transparent = false;
        text.content = '';
        add(text);
        
        triangle = new Triangle();
        add(triangle);

        verticalLine = new Quad();
        add(verticalLine);

        autorun(updateInfo);
        autorun(updateStyle);

    }

    function updateInfo() {
        
        if (model.animationState.animating)
            return;

        var verticalLineExtraHeight = this.verticalLineExtraHeight;
        var frame = model.animationState.currentFrame;

        unobserve();

        text.content = '' + frame;

        reobserve();

    }

    public function updateFrame(frame:Int) {

        text.content = '' + frame;
        layoutDirty = true;

    }

    override function layout() {

        var spikeY = TimelineEditorView.RULER_HEIGHT * 0.6;

        text.pos(1, spikeY - 1);
        text.autoComputeSizeIfNeeded(true);

        triangle.size(11, 8);
        triangle.anchor(0.5, 1);
        triangle.rotation = 180;
        triangle.pos(0.5, spikeY);

        verticalLine.pos(0, spikeY);
        verticalLine.size(1, TimelineEditorView.RULER_HEIGHT - spikeY + verticalLineExtraHeight);

    }

    function updateStyle() {

        triangle.color = theme.timelineCursorColor;
        verticalLine.color = theme.timelineCursorColor;
        text.textColor = theme.timelineCursorColor;
        text.color = theme.darkBackgroundColor;
        text.font = theme.mediumFont;

    }

}
