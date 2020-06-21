package editor.ui.timeline;

class TimelineTrackView extends View implements Observable {

    @observe public var selectedItem:EditorEntityData = null;

    @observe public var timelineTrack:EditorTimelineTrack = null;

    var timelineEditorView:TimelineEditorView;

    var titleView:TextView;

    var toggleKeyframeFieldView:BooleanFieldView;

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

        toggleKeyframeFieldView = new BooleanFieldView();
        toggleKeyframeFieldView.anchor(0, 0);
        toggleKeyframeFieldView.depth = 3;
        toggleKeyframeFieldView.inputStyle = MINIMAL;
        toggleKeyframeFieldView.setValue = function(_, value) {
            var currentFrame = model.animationState.currentFrame;
            if (value) {
                selectedItem.ensureKeyframe(timelineTrack.targetField, currentFrame);
            }
            else {
                selectedItem.removeKeyframe(timelineTrack.targetField, currentFrame);
            }
        };

        toggleKeyframeFieldView.autorun(() -> {
            var currentFrame = model.animationState.currentFrame;
            var timelineTrack = this.timelineTrack;
            var value = timelineTrack != null && timelineTrack.keyframeAtIndex(currentFrame) != null;
            unobserve();
            log.debug('toggle value $value ($currentFrame)');
            toggleKeyframeFieldView.value = value;
        });
        add(toggleKeyframeFieldView);

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
        titleView.paddingRight = TimelineEditorView.TRACK_TITLE_GAP + height;
        titleView.computeSizeIfNeeded(TimelineEditorView.TRACK_TITLE_WIDTH + TimelineEditorView.TRACK_TITLE_GAP, height, ViewLayoutMask.FIXED, true);
        titleView.applyComputedSize();

        toggleKeyframeFieldView.pos(TimelineEditorView.TRACK_TITLE_WIDTH - 20, 1);
        toggleKeyframeFieldView.computeSizeIfNeeded(height, height, ViewLayoutMask.FIXED, true);
        toggleKeyframeFieldView.applyComputedSize();

    }

    function updateStyle() {

        titleView.textColor = theme.lightTextColor;
        titleView.font = theme.boldFont;
        titleView.transparent = false;
        titleView.color = theme.mediumBackgroundColor;

        transparent = false;
        color = theme.lightBackgroundColor;

        borderPosition = OUTSIDE;
        borderBottomSize = 1;
        borderBottomColor = theme.mediumBorderColor;

    }

}