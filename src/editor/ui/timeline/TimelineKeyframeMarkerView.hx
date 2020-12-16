package editor.ui.timeline;

class TimelineKeyframeMarkerView extends View implements Observable {

    static var _point = new Point(0, 0);

    @observe public var timelineTrackView:TimelineTrackView = null;

    @observe public var index:Int = -1;

    @component var click:Click;

    @component var doubleClick:DoubleClick;

    var didDoubleClick:Bool = false;

    var dragging:Bool = false;

    var draggingAllAfter:Bool = false;

    public function new() {

        super();

        click = new Click();
        click.onClick(this, handleClick);

        doubleClick = new DoubleClick();
        doubleClick.onDoubleClick(this, handleDoubleClick);

        onPointerDown(this, handlePointerDown);
        onPointerUp(this, handlePointerUp);

        autorun(updateStyle);

    }

    function handleClick() {

        if (didDoubleClick || dragging) {
            return;
        }

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {
                var shiftPressed = input.keyPressed(LSHIFT) || input.keyPressed(RSHIFT);
                if (model.animationState.currentFrame != index) {
                    model.animationState.currentFrame = index;
                    selectedItem.selectTimelineTrack(timelineTrackView.timelineTrack, shiftPressed);
                }
                else {
                    selectedItem.toggleTimelineTrack(timelineTrackView.timelineTrack, shiftPressed);
                }
            }
        }

    }

    function handleDoubleClick() {

        if (dragging) {
            return;
        }

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {
                selectedItem.selectAllTracks();
                model.animationState.currentFrame = index;
            }
            didDoubleClick = true;
            oncePointerUp(this, _ -> {
                app.onceUpdate(this, _ -> {
                    didDoubleClick = false;
                });
            });
        }

    }

    function handlePointerDown(info:TouchInfo) {

        if (didDoubleClick) {
            return;
        }

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {

                screen.onPointerMove(this, handlePointerMove);
            }
        }

    }

    function handlePointerMove(info:TouchInfo) {

        if (!dragging) {
            // Update keyframe selection
            if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
                var selectedItem = timelineTrackView.selectedItem;
                if (selectedItem != null) {
                    var shiftPressed = input.keyPressed(LSHIFT) || input.keyPressed(RSHIFT);
                    if (model.animationState.currentFrame != index) {
                        model.animationState.currentFrame = index;
                    }
                    if (selectedItem.selectedTimelineTracks.indexOf(timelineTrackView.timelineTrack) == -1) {
                        selectedItem.selectTimelineTrack(timelineTrackView.timelineTrack, shiftPressed);
                    }
                    else {
                        selectedItem.selectTimelineTrack(timelineTrackView.timelineTrack, true);
                    }
                }
            }
        }

        dragging = true;
        draggingAllAfter = input.keyPressed(LALT) || input.keyPressed(RALT);

        click.cancel();
        doubleClick.cancel();

        var timelineEditorView = @:privateAccess timelineTrackView.timelineEditorView;
        var rulerView = @:privateAccess timelineEditorView.rulerView;
        var rulerStart = @:privateAccess rulerView.rulerStart;
        var frameStepWidth = timelineEditorView.frameStepWidth;
        var timelineOffsetX = timelineEditorView.timelineOffsetX;

        rulerView.screenToVisual(info.x, 0, _point);
        var x = _point.x;

        var frame = Math.round((x - rulerStart - timelineOffsetX) / frameStepWidth);
        if (frame < 0)
            frame = 0;

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {

                var prevFrame = model.animationState.currentFrame;
                if (prevFrame != frame) {

                    if (draggingAllAfter) {

                        var canMove = true;

                        for (track in selectedItem.selectedTimelineTracks) {
                            //var keyframeToMove = track.keyframeAtIndex(prevFrame);
                            if (frame < prevFrame) {
                                var f = prevFrame - 1;
                                while (f >= frame) {
                                    var keyframeToOverwrite = track.keyframeAtIndex(f);
                                    if (keyframeToOverwrite != null) {
                                        canMove = false;
                                        break;
                                    }
                                    f--;
                                }
                                if (!canMove)
                                    break;
                            }
                        }
                
                        if (canMove) {
                            for (track in selectedItem.selectedTimelineTracks) {
                                var frameIndexes = [];
                                for (f in track.keyframes.keys()) {
                                    if (f >= prevFrame) {
                                        frameIndexes.push(f);
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
                                    var keyframeToMove = track.keyframeAtIndex(f);
                                    //var keyframeToOverwrite = track.keyframeAtIndex(f + frame - prevFrame);
                                    if (keyframeToMove != null) {// && keyframeToOverwrite == null) {
                                        track.removeKeyframeAtIndex(f);
                                        track.setKeyframe(f + frame - prevFrame, keyframeToMove);
                                    }
                                }
                            }
                    
                            model.animationState.currentFrame = frame;
                        }

                    }
                    else {

                        var canMove = true;

                        for (track in selectedItem.selectedTimelineTracks) {
                            var keyframeToMove = track.keyframeAtIndex(prevFrame);
                            var keyframeToOverwrite = track.keyframeAtIndex(frame);
                            if (keyframeToMove != null && keyframeToOverwrite != null) {
                                canMove = false;
                                break;
                            }
                        }
                
                        if (canMove) {
                            for (track in selectedItem.selectedTimelineTracks) {
                                var keyframeToMove = track.keyframeAtIndex(prevFrame);
                                var keyframeToOverwrite = track.keyframeAtIndex(frame);
                                if (keyframeToMove != null && keyframeToOverwrite == null) {
                                    track.removeKeyframeAtIndex(prevFrame);
                                    track.setKeyframe(frame, keyframeToMove);
                                }
                            }
                    
                            model.animationState.currentFrame = frame;
                        }
                    }
                }
            }
        }

    }

    function handlePointerUp(info:TouchInfo) {

        dragging = false;

        screen.offPointerMove(handlePointerMove);

    }

    function updateStyle() {

        var selected = false;

        var timelineTrackView = this.timelineTrackView;
        var index = this.index;

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null && selectedItem.selectedTimelineTracks.indexOf(timelineTrackView.timelineTrack) != -1) {
                if (index == model.animationState.currentFrame) {
                    selected = true;
                }
            }
        }

        transparent = false;
        color = theme.timelineKeyframeMarkerColor;

        if (selected) {
            borderSize = 1;
            borderPosition = OUTSIDE;
            borderColor = theme.timelineKeyframeMarkerSelectedBorderColor;
            borderDepth = 1;
        }
        else {
            borderSize = 0;
        }

    }

}