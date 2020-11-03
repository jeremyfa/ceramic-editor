package editor.ui.timeline;

class TimelineTrackView extends View implements Observable {

    @observe public var selectedItem:EditorEntityData = null;

    @observe public var timelineTrack:EditorTimelineTrack = null;

    var timelineEditorView:TimelineEditorView;

    var frameStepWidth:Float;

    var timelineOffsetX:Float;

    var titleView:TextView;

    var toggleKeyframeFieldView:BooleanFieldView;

    var keyframeMarkers:Array<TimelineKeyframeMarkerView> = [];

    var quads:Array<Quad> = [];

    var keyframes:ReadOnlyMap<Int, EditorTimelineKeyframe> = null;

    var keyframeIndexes:ReadOnlyArray<Int> = null;
        
    var rulerStart = TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP + TimelineEditorView.TRACK_LEFT_PADDING;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        depthRange = -1;

        this.timelineEditorView = timelineEditorView;

        onPointerDown(this, handlePointerDown);

        var doubleClick = new DoubleClick();
        component('doubleClick', doubleClick);
        doubleClick.onDoubleClick(this, handleDoubleClick);

        titleView = new TextView();
        titleView.depth = 21;
        titleView.preRenderedSize = 20;
        titleView.pointSize = 13;
        titleView.verticalAlign = CENTER;
        titleView.align = RIGHT;
        titleView.viewSize(fill(), fill());
        add(titleView);

        toggleKeyframeFieldView = new BooleanFieldView();
        toggleKeyframeFieldView.anchor(0, 0);
        toggleKeyframeFieldView.depth = 22;
        toggleKeyframeFieldView.inputStyle = MINIMAL;
        toggleKeyframeFieldView.setValue = function(_, value) {
            var currentFrame = model.animationState.currentFrame;
            if (value) {
                selectedItem.ensureKeyframe(timelineTrack.field, currentFrame);
            }
            else {
                selectedItem.removeKeyframe(timelineTrack.field, currentFrame);
            }
        };

        toggleKeyframeFieldView.autorun(() -> {
            var currentFrame = model.animationState.currentFrame;
            var timelineTrack = this.timelineTrack;
            var value = timelineTrack != null && timelineTrack.keyframeAtIndex(currentFrame) != null;
            unobserve();
            toggleKeyframeFieldView.value = value;
        });
        add(toggleKeyframeFieldView);

        autorun(updateFromTimelineEditorView);
        autorun(updateFromTimelineTrack);
        autorun(updateStyle);

    }

    function handlePointerDown(info:TouchInfo) {

        if (selectedItem != null) {
            var shiftPressed = input.keyCodePressed(KeyCode.LSHIFT) || input.keyCodePressed(KeyCode.RSHIFT);
            selectedItem.toggleTimelineTrack(timelineTrack, shiftPressed);
        }
        
    }

    function handleDoubleClick() {

        if (selectedItem != null) {
            selectedItem.selectAllTracks();
        }
        
    }

    function updateFromTimelineEditorView() {

        frameStepWidth = timelineEditorView.frameStepWidth;
        timelineOffsetX = timelineEditorView.timelineOffsetX;

    }

    function updateFromTimelineTrack() {

        var timelineTrack = this.timelineTrack;
        keyframes = timelineTrack != null ? timelineTrack.keyframes : null;
        keyframeIndexes = timelineTrack != null ? timelineTrack.keyframeIndexes : null;

        // Also update from easing
        if (keyframes != null) {
            var easing:Easing = NONE;
            for (keyframe in keyframes) {
                easing = keyframe.easing;
            }
        }

        unobserve();

        if (timelineTrack != null) {
            titleView.content = timelineTrack.field;
        }

        reobserve();

    }

    override function layout() {

        titleView.pos(0, 0);
        titleView.paddingRight = TimelineEditorView.TRACK_TITLE_GAP + height;
        titleView.computeSizeIfNeeded(TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP, height, ViewLayoutMask.FIXED, true);
        titleView.applyComputedSize();

        toggleKeyframeFieldView.pos(TimelineEditorView.TRACK_TITLE_WIDTH - 20, 1);
        toggleKeyframeFieldView.computeSizeIfNeeded(height, height, ViewLayoutMask.FIXED, true);
        toggleKeyframeFieldView.applyComputedSize();

        var minIndex = Math.round((0 - timelineOffsetX - rulerStart + titleView.width) / frameStepWidth);
        if (minIndex < 0)
            minIndex = 0;

        var maxIndex = Math.round((width - rulerStart - timelineOffsetX) / frameStepWidth);

        var n = 0;
        var q = 0;
        var lastUsedIndex = -1;

        inline function addInterpolationQuad(prevIndex:Int, index:Int) {

            if ((index >= minIndex && index <= maxIndex) || (prevIndex >= minIndex && prevIndex <= maxIndex)) {

                var quad = quads[q];
                if (quad == null) {
                    quad = new Quad();
                    quads[q] = quad;
                    add(quad);
                }
                quad.depth = 19;
                quad.anchor(0, 0.5);
                quad.pos(
                    rulerStart + prevIndex * frameStepWidth + timelineOffsetX + 0.5,
                    height * 0.5 + 0.5
                );
                quad.size(
                    (index - prevIndex) * frameStepWidth,
                    1
                );
                if (quad.x < titleView.width) {
                    var diff = titleView.width - quad.x;
                    quad.x += diff;
                    quad.width -= diff;
                }
                if (quad.x + quad.width > width) {
                    quad.width = width - quad.x;
                }
                quad.color = theme.timelineKeyframeInterpolationColor;
                q++;

            }

        }

        if (keyframes != null) {
            for (keyframe in keyframes) {
                var index = keyframe.index;

                //if (index >= minIndex && index <= maxIndex) {
                    if (index > lastUsedIndex) {
                        lastUsedIndex = index;
                    }

                    var marker = keyframeMarkers[n];
                    if (marker == null) {
                        marker = new TimelineKeyframeMarkerView();
                        add(marker);
                        keyframeMarkers[n] = marker;
                    }

                    marker.active = (index >= minIndex && index <= maxIndex);
    
                    if (marker.active) {
                        marker.depth = 20;
                        marker.anchor(0.5, 0.5);
                        marker.size(
                            Math.min(TimelineEditorView.KEYFRAME_MARKER_WIDTH, width * 0.5),
                            TimelineEditorView.KEYFRAME_MARKER_HEIGHT
                        );
                        marker.pos(
                            rulerStart + index * frameStepWidth + timelineOffsetX + 0.5,
                            height * 0.5 + 0.5
                        );
                        marker.index = index;
                        marker.timelineTrackView = this;
                    }
    
                    n++;

                    if (keyframe.easing != NONE) {
                        var posInList = keyframeIndexes.indexOf(index);
                        var prevIndex = posInList > 0 ? keyframeIndexes[posInList - 1] : -1;
                        if (prevIndex != -1) {
                            addInterpolationQuad(prevIndex, index);
                        }
                    }
                //}
            }

            if (lastUsedIndex != -1) {
                var posInList = keyframeIndexes.indexOf(lastUsedIndex);
                var nextIndex = posInList >= 0 && posInList < keyframeIndexes.length - 1 ? keyframeIndexes[posInList + 1] : -1;
                if (nextIndex != -1) {
                    addInterpolationQuad(lastUsedIndex, nextIndex);
                }
            }
        }

        while (quads.length > q) {
            quads.pop().destroy();
        }

        while (keyframeMarkers.length > n) {
            keyframeMarkers.pop().destroy();
        }

    }

    function updateStyle() {

        titleView.textColor = theme.lightTextColor;
        titleView.font = theme.boldFont;
        titleView.transparent = false;

        borderPosition = OUTSIDE;
        borderBottomSize = 1;
        borderBottomColor = theme.mediumBorderColor;
        borderDepth = 11;

        var selectedItem = this.selectedItem;
        var timelineTrack = this.timelineTrack;
        var selected = selectedItem != null && selectedItem.selectedTimelineTracks.indexOf(timelineTrack) != -1 && timelineTrack != null;

        transparent = false;
        color = selected ? theme.mediumBackgroundColor : theme.lightBackgroundColor;
        titleView.color = selected ? theme.darkBackgroundColor : theme.mediumBackgroundColor;


    }

}