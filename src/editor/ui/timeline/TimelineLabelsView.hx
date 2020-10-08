package editor.ui.timeline;

class TimelineLabelsView extends View {

    var timelineEditorView:TimelineEditorView;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        transparent = false;
        this.timelineEditorView = timelineEditorView;

        autorun(updateStyle);

    }

    function updateStyle() {

        color = theme.darkBackgroundColor;//Color.interpolate(theme.darkBackgroundColor, theme.darkerBackgroundColor, 0.1);

    }

}