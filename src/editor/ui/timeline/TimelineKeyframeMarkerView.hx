package editor.ui.timeline;

class TimelineKeyframeMarkerView extends View implements Observable {

    @observe public var timelineTrackView:TimelineTrackView = null;

    @observe public var index:Int = -1;

    public function new() {

        super();

        onPointerDown(this, handlePointerDown);

        var doubleClick = new DoubleClick();
        component('doubleClick', doubleClick);
        doubleClick.onDoubleClick(this, handleDoubleClick);

        autorun(updateStyle);

    }

    function handlePointerDown(info:TouchInfo) {

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {
                var shiftPressed = app.keyCodePressed(KeyCode.LSHIFT) || app.keyCodePressed(KeyCode.RSHIFT);
                selectedItem.toggleTimelineTrack(timelineTrackView.timelineTrack, shiftPressed);
                model.animationState.currentFrame = index;
            }
        }

    }

    function handleDoubleClick() {

        if (timelineTrackView != null && timelineTrackView.timelineTrack != null && index != -1) {
            var selectedItem = timelineTrackView.selectedItem;
            if (selectedItem != null) {
                selectedItem.selectAllTracks();
                model.animationState.currentFrame = index;
            }
        }

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