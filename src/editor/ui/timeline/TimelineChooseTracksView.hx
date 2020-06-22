package editor.ui.timeline;

class TimelineChooseTracksView extends FlowLayout implements Observable {

    @observe public var selectedItem:EditorEntityData = null;

    var timelineEditorView:TimelineEditorView;

    public function new(timelineEditorView:TimelineEditorView) {

        super();

        this.timelineEditorView = timelineEditorView;

        onPointerDown(this, _ -> {});

        transparent = false;
        itemSpacing = 4;

        padding(16);

        autorun(updateList);
        autorun(updateStyle);

        component(new FieldsTabFocus());

    }

    function updateList() {

        var selectedItem = this.selectedItem;

        unobserve();

        if (subviews != null) {
            for (view in [].concat(subviews.original)) {
                view.destroy();
            }
        }

        if (selectedItem != null) {

            var editableType = selectedItem.editableType;
            if (editableType != null) {

                var fields = editableType.fields;
                for (i in 0...fields.length) {

                    var field = fields[i];
                    if (TimelineUtils.canTypeBeAnimated(field.type)) {

                        (function(i:Int, field:EditableTypeField) {

                            var itemView = new RowLayout();
                            itemView.viewSize(120, 25);
                            itemView.itemSpacing = 8;
                            itemView.align = LEFT;
                            
                            var checkbox = new BooleanFieldView();
                            checkbox.viewSize(25, 25);
                            checkbox.inputStyle = OVERLAY;
                            itemView.add(checkbox);
    
                            checkbox.setValue = function(_, value) {
                                if (value) {
                                    selectedItem.ensureTimelineTrack(field.name);
                                }
                                else {
                                    selectedItem.removeTimelineTrack(field.name);
                                }
                            };

                            checkbox.autorun(() -> {
                                checkbox.value = selectedItem.timelineTrackForField(field.name) != null;
                            });
    
                            var text = new TextView();
                            text.content = field.name;
                            text.preRenderedSize = 20;
                            text.pointSize = 13;
                            text.viewSize(fill(), 25);
                            text.verticalAlign = CENTER;
                            itemView.add(text);
    
                            text.autorun(() -> {
                                text.textColor = theme.lightTextColor;
                                text.font = theme.mediumFont;
                            });

                            add(itemView);

                        })(i, field);

                    }

                }

            }

            var okRow = new RowLayout();
            okRow.align = LEFT;
            okRow.paddingTop = 15;
            okRow.viewSize(fill(), 40);

            var button = new Button();
            button.inputStyle = OVERLAY;
            button.content = 'Done';
            button.padding(0, 12);
            button.onClick(this, () -> {
                timelineEditorView.choosingTracks = false;
            });
            okRow.add(button);

            add(okRow);
        }

        reobserve();

    }

    function updateStyle() {

        color = Color.interpolate(theme.mediumBackgroundColor, Color.BLACK, 0.5);

    }

}