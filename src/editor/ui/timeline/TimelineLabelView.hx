package editor.ui.timeline;

class TimelineLabelView extends TextView implements Observable {

    static var _point:Point = new Point(0, 0);

    public var index:Int;

    var timelineLabelsView:TimelineLabelsView;

    @observe var dragging:Bool = false;

    var draggingAllAfter:Bool = false;

    var draggingOffsetX:Float = 0;

    var draggingStartIndex:Int = 0;

    @observe var hover:Bool = false;

    @component var click:Click;

    public function new(timelineLabelsView:TimelineLabelsView, index:Int) {

        super();

        this.timelineLabelsView = timelineLabelsView;
        this.index = index;

        preRenderedSize = 20;
        pointSize = 10;
        anchor(0, 0.5);
        align = LEFT;
        verticalAlign = CENTER;
        padding(0, 4);
        transparent = false;

        click = new Click();
        click.threshold = 4;
        click.onClick(this, handleClick);

        onPointerDown(this, handlePointerDown);
        onPointerUp(this, handlePointerUp);

        onPointerOver(this, handlePointerOver);
        onPointerOut(this, handlePointerOut);

        autorun(updateStyle);

    }

    override function destroy() {

        if (dragging) {
            @:privateAccess timelineLabelsView.draggingLabels--;
        }
        dragging = false;

        super.destroy();

    }

    function handlePointerDown(info:TouchInfo) {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
        
        if (selectedItem != null) {
            screenToVisual(info.x, info.y, _point);
            draggingOffsetX = _point.x;
            draggingStartIndex = index;
            screen.onPointerMove(this, handlePointerMove);
        }

    }

    function handlePointerMove(info:TouchInfo) {

        if (!dragging) {
            @:privateAccess timelineLabelsView.draggingLabels++;
        }
        dragging = true;
        draggingAllAfter = app.keyCodePressed(KeyCode.LALT) || app.keyCodePressed(KeyCode.RALT);

        var timelineLabelsView = this.timelineLabelsView;
        var rulerStart = @:privateAccess timelineLabelsView.rulerStart;
        var frameStepWidth = @:privateAccess timelineLabelsView.frameStepWidth;
        var timelineOffsetX = @:privateAccess timelineLabelsView.timelineOffsetX;

        timelineLabelsView.screenToVisual(info.x - draggingOffsetX, 0, _point);
        var x = _point.x;

        var frame = Math.round((x - rulerStart - timelineOffsetX) / frameStepWidth);
        if (frame < 0)
            frame = 0;

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;

        if (selectedItem != null) {
            var validFrame = draggingStartIndex;
            if (validFrame < frame) {
                while (validFrame < frame) {
                    var existingFrame = selectedItem.timelineLabelAtIndex(validFrame + 1);
                    if (existingFrame == null || existingFrame.label == content) {
                        validFrame++;
                    }
                    else {
                        break;
                    }
                }
            }
            else if (validFrame > frame) {
                while (validFrame > frame) {
                    var existingFrame = selectedItem.timelineLabelAtIndex(validFrame - 1);
                    if (existingFrame == null || existingFrame.label == content) {
                        validFrame--;
                    }
                    else {
                        break;
                    }
                }
            }
            selectedItem.setTimelineLabel(validFrame, content);
        }

    }

    function handlePointerUp(info:TouchInfo) {

        if (dragging) {
            @:privateAccess timelineLabelsView.draggingLabels--;
        }
        dragging = false;

        screen.offPointerMove(handlePointerMove);

    }

    function handlePointerOver(info:TouchInfo) {

        hover = true;

    }

    function handlePointerOut(info:TouchInfo) {

        hover = false;

    }

    function handleClick() {

        if (dragging) {
            return;
        }

        timelineLabelsView.promptLabel(index);

    }

    function updateStyle() {

        font = theme.boldFont;
        textColor = theme.lightTextColor;
        color = hover || dragging ? theme.lightBackgroundColor : theme.darkBackgroundColor;

    }

}