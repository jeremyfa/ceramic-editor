package editor.ui.timeline;

class TimelineTracksView extends View implements Observable {

    @observe public var selectedItem:EditorEntityData = null;

    var timelineEditorView:TimelineEditorView;

    var trackViews:Array<TimelineTrackView> = [];

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        this.timelineEditorView = timelineEditorView;

        transparent = true;

        autorun(updateFromSelectedItem);

    }

    function updateFromSelectedItem() {

        var selectedItem = this.selectedItem;

        unobserve();

        if (selectedItem != null) {
            reobserve();
            var tracks = selectedItem.timelineTracks;
            unobserve();
            viewSize(fill(), TimelineEditorView.TRACK_HEIGHT * tracks.length);

            for (i in 0...tracks.length) {
                var trackView = trackViews[i];
                if (trackView == null) {
                    trackView = new TimelineTrackView(timelineEditorView);
                    trackView.depth = 1;
                    add(trackView);
                    trackViews[i] = trackView;
                }
                trackView.timelineTrack = tracks[i];
            }

            while (trackViews.length > tracks.length) {
                trackViews.pop().destroy();
            }
        }
        else {
            viewSize(fill(), fill());

            while (trackViews.length > 0) {
                trackViews.pop().destroy();
            }
        }

        reobserve();

    }

    override function layout() {

        var y = 0.0;
        var padRight = 12.0;

        for (i in 0...trackViews.length) {
            var trackView = trackViews[i];

            trackView.pos(0, y);
            trackView.size(width - padRight, TimelineEditorView.TRACK_HEIGHT);

            y += TimelineEditorView.TRACK_HEIGHT;
        }

    }

}