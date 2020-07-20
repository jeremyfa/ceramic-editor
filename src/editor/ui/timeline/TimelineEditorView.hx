package editor.ui.timeline;

import editor.visuals.Scrollbar;
using editor.components.Tooltip;

class TimelineEditorView extends View implements Observable {

    public static final TRACK_TITLE_WIDTH:Float = 100;

    public static final TRACK_TITLE_GAP:Float = 10;

    public static final TRACK_LEFT_PADDING:Float = 8;

    public static final TRACK_HEIGHT:Float = 26;

    public static final RULER_HEIGHT:Float = 24;

    public static final MIN_FRAME_STEP_WIDTH:Float = 1;

    public static final MAX_FRAME_STEP_WIDTH:Float = 20;

    public static final KEYFRAME_MARKER_WIDTH:Float = 7;

    public static final KEYFRAME_MARKER_HEIGHT:Float = 13;

    @observe public var selectedFragment:EditorFragmentData = null;

    @observe public var choosingTracks:Bool = false;

    @observe public var timelineOffsetX:Float = 0;

    /**
     * The gap between eatch frame marker in the ruler.
     * Changing this value will make content zoom accordingly
     */
    @observe public var frameStepWidth:Float = 10.0;

    var headerView:RowLayout;

    var tracksLayout:ScrollingLayout<TimelineTracksView>;

    var editorView:EditorView;

    var titleText:TextView;

    var rulerView:TimelineRulerView;

    var chooseTracksView:TimelineChooseTracksView;

    var cursorView:TimelineCursorView;

    var cursorX:Float = 0;

    var frameStepSliderView:SliderFieldView;

    public function new(editorView:EditorView) {

        super();

        this.editorView = editorView;

        headerView = new RowLayout();
        headerView.padding(0, 6);
        headerView.align = LEFT;
        headerView.depth = 40;
        {
            titleText = new TextView();
            titleText.viewSize(auto(), fill());
            titleText.align = LEFT;
            titleText.verticalAlign = CENTER;
            titleText.preRenderedSize = 20;
            titleText.pointSize = 13;
            titleText.content = 'Timeline';
            titleText.padding(0, 8);
            headerView.add(titleText);

            var w = 30;
            var s = 16;

            var filler = new RowSeparator();
            filler.viewSize(16, fill());
            headerView.add(filler);

            var button = new ClickableIconView();
            button.autorun(() -> {
                var icon:Entypo = LIST_ADD;
                unobserve();
                button.icon = icon;
            });
            button.viewSize(w, fill());
            button.pointSize = s;
            button.tooltip('Tracks');
            button.onClick(this, function() {
                choosingTracks = !choosingTracks;
            });
            headerView.add(button);

            var filler = new RowSeparator();
            filler.viewSize(16, fill());
            headerView.add(filler);

            var button = new ClickableIconView();
            button.icon = TO_START;
            button.viewSize(w, fill());
            button.pointSize = s;
            button.tooltip('To start');
            button.onClick(this, () -> {
                model.animationState.currentFrame = 0;
                model.animationState.invalidateCurrentFrame();
            });
            headerView.add(button);

            var button = new ClickableIconView();
            button.icon = PLAY;
            button.viewSize(w, fill());
            button.pointSize = s;
            button.tooltip('Play');
            button.autorun(() -> {
                var animating = model.animationState.animating;
                unobserve();
                if (animating) {
                    button.tooltip('Pause');
                    button.icon = PAUSE;
                }
                else {
                    button.tooltip('Play');
                    button.icon = PLAY;
                }
            });
            button.onClick(this, () -> {
                model.animationState.animating = !model.animationState.animating;
            });
            headerView.add(button);

            var button = new ClickableIconView();
            button.icon = LOOP;
            button.viewSize(w, fill());
            button.pointSize = s;
            button.tooltip('Loop');
            button.onClick(this, () -> {
                //
            });
            headerView.add(button);

            initFrameStepSlider();

            initSelectedKeyframeActions();
        }
        add(headerView);

        tracksLayout = new ScrollingLayout(new TimelineTracksView(this));
        tracksLayout.depthRange = -1;
        tracksLayout.scroller.depthRange = -1;
        tracksLayout.contentView.depthRange = -1;
        tracksLayout.scroller.scrollbar = new Scrollbar();
        tracksLayout.layoutView.autorun(() -> {
            var selectedFragment = model.project.lastSelectedFragment;
            var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
            tracksLayout.layoutView.selectedItem = selectedItem;
        });
        add(tracksLayout);

        rulerView = new TimelineRulerView(this);
        rulerView.depth = 5;
        add(rulerView);

        cursorView = new TimelineCursorView(this);
        cursorView.depth = 18;
        add(cursorView);

        chooseTracksView = new TimelineChooseTracksView(this);
        chooseTracksView.active = choosingTracks;
        chooseTracksView.depth = 41;
        chooseTracksView.autorun(() -> {
            var selectedFragment = model.project.lastSelectedFragment;
            var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
            var choosingTracks = this.choosingTracks;
            unobserve();
            chooseTracksView.active = choosingTracks;
            chooseTracksView.selectedItem = choosingTracks ? selectedItem : null;
        });
        add(chooseTracksView);

        autorun(updateFromAnimationState);
        autorun(updateStyle);

        app.onUpdate(this, _ -> updateFromFragmentTimeline());

        onPointerDown(this, handlePointerDown);
        onPointerUp(this, handlePointerUp);

    }

    function initFrameStepSlider() {

        var filler = new RowSeparator();
        filler.viewSize(16, fill());
        headerView.add(filler);

        frameStepSliderView = new SliderFieldView(MIN_FRAME_STEP_WIDTH, MAX_FRAME_STEP_WIDTH);
        frameStepSliderView.inputStyle = MINIMAL;
        frameStepSliderView.enabledTextInput = false;
        frameStepSliderView.setValue = function(field, value) {
            if (value > MAX_FRAME_STEP_WIDTH)
                value = MAX_FRAME_STEP_WIDTH;
            if (value < MIN_FRAME_STEP_WIDTH)
                value = MIN_FRAME_STEP_WIDTH;
            value = Math.round(value);
            frameStepSliderView.value = value;
            frameStepWidth = value;
        };
        frameStepSliderView.autorun(function() {
            frameStepSliderView.value = frameStepWidth;
        });
        frameStepSliderView.viewSize(120, 27);
        frameStepSliderView.offsetY = 2;
        headerView.add(frameStepSliderView);

    }

    function initSelectedKeyframeActions() {

        var filler = new RowSeparator();
        filler.viewSize(16, fill());
        headerView.add(filler);

        var easingText = new TextView();
        easingText.content = 'Easing';
        easingText.pointSize = 13;
        easingText.viewSize(auto(), fill());
        easingText.verticalAlign = CENTER;
        easingText.padding(0, 8);
        easingText.autorun(() -> {
            easingText.font = theme.boldFont;
            easingText.textColor = theme.lightTextColor;
        });
        headerView.add(easingText);

        var selectEasing = new SelectFieldView();
        var list = [];
        for (item in Type.getEnumConstructs(ceramic.Easing)) {
            if (item != 'BEZIER' && item != 'CUSTOM') {
                list.push(item);
            }
        }
        selectEasing.list = list;
        selectEasing.autorun(() -> {
            var multipleEasings = hasMultipleEasingValuesSelected();
            unobserve();
            if (multipleEasings) {
                selectEasing.nullValueText = 'multiple values';
                selectEasing.value = null;
            }
            else {
                selectEasing.nullValueText = '';

                reobserve();
                var selectedKeyframe = getSelectedKeyframe();
                if (selectedKeyframe != null) {
                    var easingValue = selectedKeyframe.easing.getName();
                    unobserve();
                    selectEasing.value = easingValue;
                }
                else {
                    unobserve();
                }
            }
        });
        selectEasing.setValue = function(field, value) {
            var selectedKeyframes = getAllSelectedKeyframes();
            if (selectedKeyframes != null && value != null) {
                var enumValue = EasingUtils.easingFromString(value);
                model.project.lastSelectedEasing = enumValue;
                for (keyframe in selectedKeyframes) {
                    keyframe.easing = enumValue != null ? enumValue : NONE;
                }
            }
        };
        selectEasing.viewSize(150, 20);
        selectEasing.offsetY = 5;
        selectEasing.inputStyle = MINIMAL;
        headerView.add(selectEasing);

        autorun(() -> {
            var selectedKeyframe = getSelectedKeyframe();
            unobserve();

            var active = (selectedKeyframe != null);

            filler.active = active;
            easingText.active = active;
            selectEasing.active = active;
        });

    }

    function hasMultipleEasingValuesSelected() {

        var selectedEasings = [];
        var selectedKeyframes = getAllSelectedKeyframes();
        if (selectedKeyframes != null) {
            for (keyframe in selectedKeyframes) {
                var easing = keyframe.easing;
                if (selectedEasings.indexOf(easing) == -1) {
                    selectedEasings.push(easing);
                }
            }
        }

        return selectedEasings.length >= 2;

    }

    function getAllSelectedKeyframes() {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
        var selectedKeyframes = selectedItem != null ? selectedItem.selectedTimelineKeyframes : null;

        return selectedKeyframes;

    }

    function getSelectedKeyframe() {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedItem = selectedFragment != null ? selectedFragment.selectedItem : null;
        var selectedKeyframes = selectedItem != null ? selectedItem.selectedTimelineKeyframes : null;

        return selectedKeyframes != null && selectedKeyframes.length > 0 ? selectedKeyframes[selectedKeyframes.length-1] : null;

    }

    function updateFromAnimationState() {

        var animationState = model.animationState;
        var currentFrame = animationState.currentFrame;
        var frameStepWidth = this.frameStepWidth;
        var timelineOffsetX = this.timelineOffsetX;
        var animating = animationState.animating;

        unobserve();

        if (animating) {
            updateFromFragmentTimeline();
            return;
        }

        var cursorX = TRACK_TITLE_WIDTH + TRACK_TITLE_GAP + TRACK_LEFT_PADDING;
        cursorX += frameStepWidth * currentFrame + timelineOffsetX;

        this.cursorX = cursorX;

        reobserve();

    }

    function updateFromFragmentTimeline() {

        if (!model.animationState.animating)
            return;

        if (editorView.fragmentEditorView == null)
            return;
        var editedFragment = editorView.fragmentEditorView.editedFragment;
        if (editedFragment == null || editedFragment.timeline == null)
            return;

        var currentFrame = editedFragment.timeline.time * editedFragment.fps;

        var cursorX = TRACK_TITLE_WIDTH + TRACK_TITLE_GAP + TRACK_LEFT_PADDING;
        cursorX += frameStepWidth * currentFrame + timelineOffsetX;

        if (this.cursorX != cursorX) {
            this.cursorX = cursorX;
            layoutDirty = true;
        }

    }

    override function layout() {

        var headerViewHeight = 32;
        var rulerViewHeight = RULER_HEIGHT;

        headerView.viewSize(width, headerViewHeight);
        headerView.computeSize(width, headerViewHeight, ViewLayoutMask.FIXED, true);
        headerView.applyComputedSize();
        headerView.pos(0, 0);

        rulerView.pos(0, headerViewHeight);
        rulerView.size(width, rulerViewHeight);

        tracksLayout.pos(0, headerViewHeight + rulerViewHeight);
        tracksLayout.size(width + 1, height - headerViewHeight - rulerViewHeight);

        chooseTracksView.pos(0, headerViewHeight);
        chooseTracksView.size(width, height - headerViewHeight);

        cursorView.pos(cursorX, headerViewHeight);
        cursorView.verticalLineExtraHeight = height - headerViewHeight - rulerViewHeight;

    }

    override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float, touchIndex:Int, buttonId:Int):Bool {

        // When animating, only allow clicking on the header to update playback
        if (model.animationState.animating && !hittingVisual.hasIndirectParent(headerView)) {
            model.animationState.animating = false;
        }

        // Do not accept right or middle click unless hittingVisual is the timeline editor view itself
        if (buttonId == 3 || buttonId == 2) {
            if (hittingVisual == this && !headerView.hits(x, y)) {
                // Handle right click
                return false;
            }
            else {
                // Forbid right click on this hitting visual
                return true;
            }
        }

        return false;

    }

    function handlePointerDown(info:TouchInfo) {

        if (info.buttonId == 3) {
            // Right click
            @:privateAccess rulerView.handlePointerDown(info);
        }

    }

    function handlePointerUp(info:TouchInfo) {

        if (info.buttonId == 3) {
            // Right click
            @:privateAccess rulerView.handlePointerUp(info);
        }

    }

    function updateStyle() {

        transparent = false;
        color = theme.mediumBackgroundColor;

        headerView.transparent = false;
        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomSize = 1;
        headerView.borderBottomColor = theme.darkBorderColor;
        headerView.borderPosition = INSIDE;

        titleText.color = theme.lightTextColor;
        titleText.font = theme.boldFont;

        tracksLayout.transparent = false;
        tracksLayout.color = theme.darkBackgroundColor;

    }

}
