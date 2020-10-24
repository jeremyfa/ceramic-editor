package editor.ui.timeline;

class TimelineLabelsView extends View {

    static var _point = new Point(0, 0);

    var timelineEditorView:TimelineEditorView;

    var frameStepWidth:Float;

    var timelineOffsetX:Float;

    var newLabelPointer:Quad;

    var newLabelPointerX:Float = 0;
        
    var rulerStart = TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP + TimelineEditorView.TRACK_LEFT_PADDING;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        transparent = false;
        this.timelineEditorView = timelineEditorView;

        newLabelPointer = new Quad();
        newLabelPointer.active = false;
        add(newLabelPointer);

        autorun(updateFromTimelineEditorView);
        autorun(updateStyle);

        screen.onPointerMove(this, handlePointerMove);

        onPointerDown(this, handlePointerDown);

    }

    function handlePointerMove(info:TouchInfo) {

        if (hits(info.x, info.y)) {
            updateNewLabelPointerX(info.x, info.y);
        }
        else {
            newLabelPointer.active = false;
        }

    }

    function handlePointerDown(info:TouchInfo) {

        if (newLabelPointer.active) {

            Prompt.promptWithParams(
                'Label name',
                'Enter label name',
                [
                    {
                        name: 'Label',
                        type: 'String',
                        value: ''
                    }
                ],
                result -> {
                    trace('RESULT: $result');
                }
            );

        }

    }

    function updateNewLabelPointerX(screenX:Float, screenY:Float):Void {

        screenToVisual(screenX, screenY, _point);
        var x = _point.x;

        var newLabelPointerX = Math.round((x - rulerStart) / frameStepWidth) * frameStepWidth;
        if (this.newLabelPointerX != Math.max(0, newLabelPointerX)) {
            this.newLabelPointerX = Math.max(0, newLabelPointerX);
            layoutDirty = true;
        }

        if (newLabelPointerX < -frameStepWidth || newLabelPointerX > width - rulerStart) {
            newLabelPointer.active = false;
        }
        else {
            newLabelPointer.active = true;
        }

    }

    function updateFromTimelineEditorView() {

        frameStepWidth = timelineEditorView.frameStepWidth;
        timelineOffsetX = timelineEditorView.timelineOffsetX;

    }

    override function layout() {

        var labelPad = 4;
        newLabelPointer.pos(rulerStart + newLabelPointerX, labelPad);
        newLabelPointer.size(1, height - labelPad * 2);

    }

    function updateStyle() {

        color = theme.darkBackgroundColor;//Color.interpolate(theme.darkBackgroundColor, theme.darkerBackgroundColor, 0.1);

        newLabelPointer.color = theme.mediumTextColor;

    }

}