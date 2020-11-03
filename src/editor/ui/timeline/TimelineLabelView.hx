package editor.ui.timeline;

class TimelineLabelView extends TextView implements Observable {

    static var _point:Point = new Point(0, 0);

    public var index:Int;

    var timelineLabelsView:TimelineLabelsView;

    @observe var dragging:Bool = false;

    var draggingAllAfter:Bool = false;

    var draggingOffsetX:Float = 0;

    var draggingLabel:String = null;

    @observe public var labelName(default, set):String = '';
    function set_labelName(labelName:String):String {
        this.labelName = labelName;
        this.content = labelName;
        return labelName;
    }

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

        if (dragging && timelineLabelsView.draggingLabel == draggingLabel) {
            timelineLabelsView.draggingLabel = null;
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
            draggingLabel = labelName;
            screen.onPointerMove(this, handlePointerMove);
        }

    }

    function handlePointerMove(info:TouchInfo) {

        if (!dragging) {
            timelineLabelsView.draggingLabel = draggingLabel;
        }
        dragging = true;
        draggingAllAfter = input.keyCodePressed(KeyCode.LALT) || input.keyCodePressed(KeyCode.RALT);

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

            var canMove = true;
            var mainLabel = selectedItem.timelineLabelWithName(draggingLabel);
            var prevFrame = mainLabel.index;

            if (frame != prevFrame) {

                if (draggingAllAfter) {
                    
                    if (frame < prevFrame) {
                        var f = prevFrame - 1;
                        while (f >= frame) {
                            var labelToOverwrite = selectedItem.timelineLabelAtIndex(f);
                            if (labelToOverwrite != null) {
                                canMove = false;
                                break;
                            }
                            f--;
                        }
                    }
            
                    if (canMove) {
                        var frameIndexes = [];
                        for (aLabel in selectedItem.timelineLabels) {
                            if (aLabel.index >= prevFrame) {
                                frameIndexes.push(aLabel.index);
                            }
                        }
                        if (frame < prevFrame) {
                            // Sort ascending
                            frameIndexes.sort((a, b) -> a - b);
                        }
                        else {
                            // Sort descending
                            frameIndexes.sort((a, b) -> b - a);
                        }
                        for (f in frameIndexes) {
                            var labelToMove = selectedItem.timelineLabelAtIndex(f);
                            //var keyframeToOverwrite = track.keyframeAtIndex(f + frame - prevFrame);
                            if (labelToMove != null) {// && keyframeToOverwrite == null) {
                                selectedItem.removeTimelineLabel(f);
                                selectedItem.setTimelineLabel(f + frame - prevFrame, labelToMove.name);
                            }
                        }
                    }
                }
                else {

                    var labelToMove = selectedItem.timelineLabelAtIndex(prevFrame);
                    var labelToOverwrite = selectedItem.timelineLabelAtIndex(frame);
                    if (labelToMove != null && labelToOverwrite != null) {
                        canMove = false;
                    }
            
                    if (canMove) {
                        var labelToMove = selectedItem.timelineLabelAtIndex(prevFrame);
                        var labelToOverwrite = selectedItem.timelineLabelAtIndex(frame);
                        if (labelToMove != null && labelToOverwrite == null) {
                            selectedItem.removeTimelineLabel(prevFrame);
                            selectedItem.setTimelineLabel(frame, labelToMove.name);
                        }
                    }
                }
            }
                
        }

    }

    function handlePointerUp(info:TouchInfo) {

        if (dragging && timelineLabelsView.draggingLabel == draggingLabel) {
            timelineLabelsView.draggingLabel = null;
        }
        dragging = false;
        draggingLabel = null;

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
        color = (timelineLabelsView.draggingLabel == null && hover) || timelineLabelsView.draggingLabel == labelName ? theme.lightBackgroundColor : theme.darkBackgroundColor;

    }

}