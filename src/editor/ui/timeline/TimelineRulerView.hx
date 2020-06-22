package editor.ui.timeline;

class TimelineRulerView extends View {

    static var _point = new Point(0, 0);

    var quads:Array<Quad> = [];

    var texts:Array<Text> = [];

    var timelineEditorView:TimelineEditorView;

    var frameStepWidth:Float;

    var timelineOffsetX:Float;

    var lastPointerX:Float = -1;
        
    var rulerStart = TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        this.timelineEditorView = timelineEditorView;

        onPointerDown(this, handlePointerDown);
        onPointerUp(this, handlePointerUp);

        autorun(updateFromTimelineEditorView);
        autorun(updateStyle);

        app.onUpdate(this, update);

    }

    function update(delta:Float) {

        // When moving the cursor near left or right borders, scroll!

        var scrollThreshold:Float = Math.min(100.0, width * 0.1);

        if (isPointerDown) {
            var x = lastPointerX;

            var moveRatio:Float = 0;
            if (x - rulerStart < scrollThreshold) {
                moveRatio = 1.0 - Math.max(0, x - rulerStart) / scrollThreshold;
            }
            else if (x >= width - scrollThreshold) {
                moveRatio = -Math.min(scrollThreshold, (x - (width - scrollThreshold))) / scrollThreshold;
            }

            if (moveRatio != 0) {
                var speed = 1000.0;
                var newOffsetX = timelineEditorView.timelineOffsetX + delta * moveRatio * speed;
                if (newOffsetX > 0)
                    newOffsetX = 0;
                timelineEditorView.timelineOffsetX = newOffsetX;
            }

            updateFrameFromLastPointerXAndOffset();
        }

    }

    function updateFromTimelineEditorView() {

        frameStepWidth = timelineEditorView.frameStepWidth;
        timelineOffsetX = timelineEditorView.timelineOffsetX;

    }

    override function layout() {

        var minGap = 5.0;
        var unitPerStep = 1;

        while (frameStepWidth * unitPerStep < minGap) {

            if (unitPerStep == 1)
                unitPerStep = 2;
            else if (unitPerStep == 2)
                unitPerStep = 5;
            else if (unitPerStep == 5)
                unitPerStep = 10;
            else
                unitPerStep *= 2;
        }

        var q = 0;
        var t = 0;

        var unit = 0;
        var x = 0.0;
        var i = 0;
        while (rulerStart + timelineOffsetX + x < width) {

            var quad = quads[q];
            if (quad == null) {
                quad = new Quad();
                quad.depth = 2;
                quads[q] = quad;
                add(quad);
            }
            q++;

            quad.color = theme.lightBorderColor;
            quad.anchor(0, 1);
            quad.pos(rulerStart + timelineOffsetX + x, height);

            if (i % 5 == 0) {
                quad.size(1, height * 0.4);

                var text = texts[t];
                if (text == null) {
                    text = new Text();
                    text.depth = 3;
                    texts[t] = text;
                    add(text);
                }
                t++;

                text.anchor(0.5, 1);
                text.color = quad.color;
                text.content = '' + unit;
                text.preRenderedSize = 20;
                text.pointSize = 11;
                text.font = theme.mediumFont;
                text.pos(quad.x + 1, quad.y - quad.height - 1);
            }
            else {
                quad.size(1, height * 0.2);
            }

            i++;
            x += frameStepWidth * unitPerStep;
            unit += unitPerStep;
        }

        while (quads.length > q) {
            quads.pop().destroy();
        }

        while (texts.length > t) {
            texts.pop().destroy();
        }

    }

    function handlePointerDown(info:TouchInfo) {

        screen.onPointerMove(this, handlePointerMove);

        updateCursor(info.x, info.y);
        
    }

    function handlePointerMove(info:TouchInfo) {

        updateCursor(info.x, info.y);
        
    }

    function handlePointerUp(info:TouchInfo) {

        screen.offPointerMove(handlePointerMove);

        updateCursor(info.x, info.y);
        
    }

    function updateCursor(screenX:Float, screenY:Float):Void {

        screenToVisual(screenX, screenY, _point);
        var x = _point.x;
        lastPointerX = x;

        updateFrameFromLastPointerXAndOffset();

    }

    function updateFrameFromLastPointerXAndOffset() {

        var x = lastPointerX;

        var frame = Math.round((x - rulerStart - timelineEditorView.timelineOffsetX) / frameStepWidth);
        if (frame < 0)
            frame = 0;

        model.animationState.currentFrame = frame;

    }

    function updateStyle() {

        transparent = false;
        color = theme.darkBackgroundColor;

        borderPosition = INSIDE;
        borderBottomSize = 1;
        borderBottomColor = theme.darkBorderColor;

    }

}