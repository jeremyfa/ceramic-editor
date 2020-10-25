package editor.ui.timeline;

class TimelineLabelsView extends View {

    static var _point = new Point(0, 0);

    var timelineEditorView:TimelineEditorView;

    var frameStepWidth:Float;

    var timelineOffsetX:Float;

    var editedLabelPointer:Quad;

    var editedLabelPointerX:Float = 0;

    var editedLabelFrame:Int = 0;

    var lastUsedScreenX:Float = -1;

    var lastUsedScreenY:Float = -1;
        
    var rulerStart = TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP + TimelineEditorView.TRACK_LEFT_PADDING;

    var labelVisuals:Array<TimelineLabelView> = [];

    var labelDelimiters:Array<Quad> = [];

    @component var click:Click;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        depthRange = -1;

        transparent = false;
        this.timelineEditorView = timelineEditorView;

        editedLabelPointer = new Quad();
        editedLabelPointer.active = false;
        editedLabelPointer.depth = 4.1;
        editedLabelPointer.depthRange = 0.1;
        add(editedLabelPointer);

        autorun(updateFromTimelineEditorView);
        autorun(updateFromTimelineLabels);
        autorun(updateStyle);

        screen.onPointerMove(this, handlePointerMove);

        click = new Click();
        click.threshold = 4;
        click.onClick(this, handleClick);

    }

    function handlePointerMove(info:TouchInfo) {

        if (editedLabelFrozen())
            return;

        if (hits(info.x, info.y)) {
            updateEditedLabelPointerX(info.x, info.y);
        }
        else {
            editedLabelPointer.active = false;
        }

    }

    function handleClick() {

        if (editedLabelPointer.active) {

            promptLabel(editedLabelFrame);

        }

    }

    public function promptLabel(frame:Int) {

        this.editedLabelFrame = frame;

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;

        if (selectedItem != null) {
            var existingLabel = selectedItem.timelineLabelAtIndex(editedLabelFrame);
            var frame = editedLabelFrame;

            Prompt.promptWithParams(
                'Label at frame $frame',
                null,
                [
                    {
                        name: null,
                        type: 'String',
                        value: existingLabel != null ? existingLabel.label : ''
                    }
                ],
                true,
                result -> {
                    trace('result: $result');
                    editedLabelPointer.active = false;
                    var labelName:String = result[0];
                    if (labelName == null || labelName.trim() == '') {
                        selectedItem.removeTimelineLabel(frame);
                    }
                    else {
                        selectedItem.setTimelineLabel(frame, labelName.trim());
                    }
                }
            );
        }

    }

    function editedLabelFrozen():Bool {

        return editor.view.popup != null && editor.view.popup.contentView != null;

    }

    function updateEditedLabelPointerX(screenX:Float, screenY:Float):Void {

        if (editedLabelFrozen())
            return;

        lastUsedScreenX = screenX;
        lastUsedScreenY = screenY;

        screenToVisual(screenX, screenY, _point);
        var x = _point.x;

        var editedLabelPointerX = Math.round((x - rulerStart) / frameStepWidth) * frameStepWidth + timelineOffsetX - Math.round(timelineOffsetX / frameStepWidth) * frameStepWidth;
        if (this.editedLabelPointerX != Math.max(timelineOffsetX, editedLabelPointerX)) {
            this.editedLabelPointerX = Math.max(timelineOffsetX, editedLabelPointerX);
            editedLabelFrame = Math.floor((this.editedLabelPointerX - timelineOffsetX) / frameStepWidth);
            layoutDirty = true;
        }

        if (editedLabelPointerX < Math.min(-frameStepWidth, timelineOffsetX) || editedLabelPointerX > width - rulerStart) {
            editedLabelPointer.active = false;
        }
        else {
            editedLabelPointer.active = true;
        }

    }

    function updateFromTimelineEditorView() {

        frameStepWidth = timelineEditorView.frameStepWidth;
        timelineOffsetX = timelineEditorView.timelineOffsetX;

        unobserve();
        if (lastUsedScreenX != -1 || lastUsedScreenY != -1) {
            if (editedLabelPointer.active) {
                updateEditedLabelPointerX(lastUsedScreenX, lastUsedScreenY);
            }
        }
        reobserve();

    }

    function updateFromTimelineLabels() {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
        var timelineLabels = selectedItem != null ? selectedItem.timelineLabels : null;

        var usedVisuals = 0;

        var minFrame = Std.int(Math.max(0, -timelineOffsetX - rulerStart) / frameStepWidth);
        var maxFrame = minFrame + Std.int((width + Math.min(0, -timelineOffsetX - rulerStart)) / frameStepWidth);

        if (timelineLabels != null) {
            for (timelineLabel in timelineLabels) {
                var labelIndex = timelineLabel.index;
                if (labelIndex >= minFrame && labelIndex <= maxFrame) {
                    
                    var labelText = timelineLabel.label;

                    unobserve();

                    var labelVisual = labelVisuals[usedVisuals];
                    if (labelVisual == null) {
                        labelVisual = new TimelineLabelView(this, labelIndex);
                        labelVisuals[usedVisuals] = labelVisual;
                        labelVisual.depth = 4.3;
                        labelVisual.depthRange = 0.1;
                        labelVisual.viewSize(auto(), height - 8);
                        add(labelVisual);
                    }

                    var labelDelimiter = labelDelimiters[usedVisuals];
                    if (labelDelimiter == null) {
                        labelDelimiter = new Quad();
                        labelDelimiters[usedVisuals] = labelDelimiter;
                        labelDelimiter.color = theme.lightBorderColor;
                        labelDelimiter.anchor(0, 0);
                        labelDelimiter.depth = 17;
                        add(labelDelimiter);
                    }

                    usedVisuals++;

                    labelVisual.index = labelIndex;
                    labelVisual.content = labelText;
                    labelVisual.pos(
                        1 + rulerStart + timelineOffsetX + labelIndex * frameStepWidth,
                        height * 0.5
                    );
                    labelVisual.autoComputeSizeIfNeeded(true);

                    labelDelimiter.pos(labelVisual.x - 1, 0);
                    labelDelimiter.size(1, timelineEditorView.height - 0);

                    reobserve();

                }
            }
        }

        while (usedVisuals < labelVisuals.length) {
            var labelVisual = labelVisuals.pop();
            labelVisual.destroy();
            var labelDelimiter = labelDelimiters.pop();
            labelDelimiter.destroy();
        }

    }

    override function layout() {

        var labelPad = 4;
        editedLabelPointer.pos(rulerStart + editedLabelPointerX, labelPad);
        editedLabelPointer.size(1, height - labelPad * 2);

        updateFromTimelineLabels();

    }

    function updateStyle() {

        color = theme.darkBackgroundColor;//Color.interpolate(theme.darkBackgroundColor, theme.darkerBackgroundColor, 0.1);

        editedLabelPointer.color = theme.mediumTextColor;

    }

}