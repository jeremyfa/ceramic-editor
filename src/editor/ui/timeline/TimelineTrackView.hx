package editor.ui.timeline;

class TimelineTrackView extends View implements Observable {

    @observe public var timelineTrack:EditorTimelineTrack = null;

    var timelineEditorView:TimelineEditorView;

    var titleView:TextView;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        this.timelineEditorView = timelineEditorView;

        titleView = new TextView();
        titleView.depth = 1;
        titleView.pointSize = 13;
        titleView.verticalAlign = CENTER;
        titleView.align = RIGHT;
        titleView.viewSize(fill(), fill());
        add(titleView);

        autorun(updateFromTimelineTrack);
        autorun(updateStyle);

    }

    function updateFromTimelineTrack() {

        var timelineTrack = this.timelineTrack;

        unobserve();

        if (timelineTrack != null) {
            titleView.content = timelineTrack.targetField;
        }

        reobserve();

    }

    override function layout() {

        titleView.pos(0, 0);
        titleView.computeSizeIfNeeded(TimelineEditorView.TRACK_TITLE_WIDTH, height, ViewLayoutMask.FIXED, true);
        titleView.applyComputedSize();

    }

    function updateStyle() {

        titleView.textColor = theme.lightTextColor;
        titleView.font = theme.boldFont;

        transparent = false;
        color = theme.lightBackgroundColor;

        borderPosition = OUTSIDE;
        borderBottomSize = 1;
        borderBottomColor = theme.mediumBorderColor;

    }

}