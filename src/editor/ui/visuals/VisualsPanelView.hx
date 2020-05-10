package editor.ui.visuals;

import editor.utils.TextUtils;
import editor.visuals.Scrollbar;

class VisualsPanelView extends LinearLayout implements Observable {

/// Lifecycle

    public function new() {

        super();

        initAllVisualsSection();
        initSelectedVisualSection();
        initAddVisualButton();

        autorun(updateStyle);

    }

    function initAllVisualsSection() {

        var title = new SectionTitleView();
        title.content = 'All visuals';
        add(title);

        var dataSource = new VisualCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(25));
        collectionView.dataSource = dataSource;
        add(collectionView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.selectedFragment != null ? model.project.selectedFragment.visuals.length : 0;
            if (length != prevLength) {
                var scrollToBottom = prevLength > 0 && length > prevLength;

                prevLength = length;
                collectionView.reloadData();

                if (scrollToBottom) {
                    collectionView.layoutDirty = true;
                    collectionView.onceLayout(this, function() {
                        collectionView.scroller.scrollTo(
                            collectionView.scroller.scrollX,
                            collectionView.scroller.content.height - collectionView.scroller.height
                        );
                        collectionView.scroller.scrollToBounds();
                    });
                }
                else {
                    collectionView.layoutDirty = true;
                    collectionView.onceLayout(this, function() {
                        collectionView.scroller.scrollToBounds();
                    });
                }
            }
        });

        autorun(function() {
            var active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
            title.active = active;
            collectionView.active = active;
        });

        var prevSelectedVisualIndex = -1;
        autorun(function() {
            var selectedFragment = model.project.selectedFragment;
            var selectedVisualIndex = selectedFragment != null ? selectedFragment.selectedVisualIndex : -1;
            unobserve();
            if (selectedVisualIndex != prevSelectedVisualIndex) {
                prevSelectedVisualIndex = selectedVisualIndex;
                if (selectedVisualIndex != -1) {
                    app.oncePostFlushImmediate(() -> {
                        if (destroyed)
                            return;
                        scrollToSelectedVisual(collectionView);
                        app.onceUpdate(collectionView, _ -> {
                            scrollToSelectedVisual(collectionView);
                            app.onceUpdate(collectionView, _ -> {
                                scrollToSelectedVisual(collectionView);
                            });
                        });
                    });
                }
            }
        });

    }

    function scrollToSelectedVisual(collectionView:CollectionView) {

        var selectedFragment = model.project.selectedFragment;
        var selectedVisualIndex = selectedFragment != null ? selectedFragment.selectedVisualIndex : -1;
        if (selectedVisualIndex != -1) {
            collectionView.scrollToItem(selectedVisualIndex);
        }

    }

    function initSelectedVisualSection() {

        var title = new SectionTitleView();
        title.content = 'Selected visual';
        add(title);

        var container = new ColumnLayout();
        container.paddingRight = 12;

        var form = new FormLayout();
        container.add(form);

        var scroll = new ScrollingLayout(container, true);
        scroll.scroller.scrollbar = new Scrollbar();
        scroll.autorun(() -> {
            scroll.transparent = false;
            scroll.color = theme.darkBackgroundColor;
        });
        scroll.viewSize(fill(), fill());
        add(scroll);

        autorun(function() {
            var active = model.project.selectedFragment != null && model.project.selectedFragment.selectedVisual != null;
            title.active = active;
            scroll.active = active;
            form.clear();
            scroll.scroller.scrollTo(scroll.scroller.scrollX, 0);

            if (active) {
                var visual = model.project.selectedFragment.selectedVisual;
                var entityClass = visual.entityClass;
                unobserve();
                fillVisualForm(form, visual);
                reobserve();
            }
        });

    }

    function fillVisualForm(form:FormLayout, visual:EditorVisualData) {

        var editableType = editor.getEditableType(visual.entityClass);

        if (editableType == null) {
            log.error('No editable type info for entity class: ${visual.entityClass}');
            return;
        }

        var usedGroups:Map<String,Bool> = new Map();

        inline function createFieldView(field:EditableTypeField) {

            var editableMeta:Dynamic = field.meta.editable != null ? field.meta.editable[0] : null;

            var fieldView = EditorFieldUtils.createEditableField(editableType, field, visual);
            if (fieldView != null) {
                
                var item = new LabeledFieldView(fieldView);
                if (editableMeta.label != null) {
                    item.label = editableMeta.label;
                }
                else {
                    item.label = TextUtils.toFieldLabel(field.name);
                }

                return item;
            }

            return null;

        }

        inline function createFieldGroupView(group:String, fields:Array<EditableTypeField>) {

            var fieldViews = [];

            for (field in fields) {
                var item = createFieldView(field);
                if (item != null) {
                    fieldViews.push(item);
                }
            }

            var item = new LabeledFieldGroupView(fieldViews);
            item.label = group;
            
            return item;

        }

        // Entity id
        {
            var fieldView = EditorFieldUtils.createEditableEntityIdField(visual);
            if (fieldView != null) {
                
                var item = new LabeledFieldView(fieldView);
                item.label = 'Id';

                form.add(item);
            }
        }

        for (i in 0...editableType.fields.length) {
            var field = editableType.fields[i];
            var editableMeta:Dynamic = field.meta.editable != null ? field.meta.editable[0] : null;
            var group = editableMeta != null ? editableMeta.group : null;

            if (group != null) {
                if (usedGroups.exists(group))
                    continue;
                usedGroups.set(group, true);

                var fieldsInGroup = [];
                for (j in 0...editableType.fields.length) {
                    var fieldInGroup = editableType.fields[j];
                    var fieldEditableMeta:Dynamic = fieldInGroup.meta.editable != null ? fieldInGroup.meta.editable[0] : null;
                    if (fieldEditableMeta != null && fieldEditableMeta.group == group) {
                        fieldsInGroup.push(fieldInGroup);
                    }
                }
                var item = createFieldGroupView(group, fieldsInGroup);
                if (item != null)
                    form.add(item);
            }
            else {
                var item = createFieldView(field);
                if (item != null) {
                    //item.paddingLeft = 4;
                    //item.paddingRight = 4;
                    form.add(item);
                }
            }
        }

    }

    function initAddVisualButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add visual';
        button.onClick(this, function() {
            var choices = [];
            for (i in 0...editor.editableVisuals.length) {
                choices.push(editor.editableVisuals[i].entity);
            }
            choices.sort(TextUtils.compareStrings);
            Choice.choose('Add visual', choices, true, (index, text) -> {
                log.debug('ADD VISUAL ' + choices[index]);
                model.project.selectedFragment.selectedVisual = model.project.selectedFragment.addVisual(choices[index]);
            });
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
        });

    }

    function updateStyle() {

        //

    }

}
