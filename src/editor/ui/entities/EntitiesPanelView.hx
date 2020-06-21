package editor.ui.entities;

import editor.utils.TextUtils;
import editor.visuals.Scrollbar;

class EntitiesPanelView extends LinearLayout implements Observable {

/// Lifecycle

    public function new() {

        super();

        initAllEntitiesSection();
        initSelectedEntitySection();
        initAddEntityButton();

        autorun(updateStyle);

    }

    function initAllEntitiesSection() {

        var title = new SectionTitleView();
        title.content = 'All entities';
        add(title);

        var dataSource = new EntityCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.itemsBehavior = LAZY;
        collectionView.viewSize(fill(), percent(25));
        collectionView.dataSource = dataSource;
        add(collectionView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.lastSelectedFragment != null ? model.project.lastSelectedFragment.entities.length : 0;
            if (length != prevLength) {
                //var scrollToBottom = false;//prevLength > 0 && length > prevLength;

                prevLength = length;
                collectionView.reloadData();

                /*if (scrollToBottom) {
                    collectionView.layoutDirty = true;
                    collectionView.onceLayout(this, function() {
                        collectionView.scroller.scrollTo(
                            collectionView.scroller.scrollX,
                            collectionView.scroller.content.height - collectionView.scroller.height
                        );
                        collectionView.scroller.scrollToBounds();
                    });
                }
                else {*/
                    collectionView.layoutDirty = true;
                    collectionView.onceLayout(this, function() {
                        collectionView.scroller.scrollToBounds();
                    });
                //}
            }
        });

        autorun(function() {
            var active = model.project.lastSelectedFragment != null && model.project.lastSelectedFragment.entities.length > 0;
            title.active = active;
            collectionView.active = active;
        });

        var prevSelectedEntityIndex = -1;
        var prevSelectListSize = -1;
        var prevSelectedFragment = null;
        autorun(function() {
            var selectedFragment = model.project.lastSelectedFragment;
            var selectedEntityIndex = selectedFragment != null ? selectedFragment.selectedEntityIndex : -1;
            var selectListSize = selectedFragment != null ? selectedFragment.entities.length : -1;
            unobserve();
            if (selectedEntityIndex != prevSelectedEntityIndex || prevSelectListSize != selectListSize || prevSelectedFragment != selectedFragment) {
                prevSelectedEntityIndex = selectedEntityIndex;
                prevSelectListSize = selectListSize;
                prevSelectedFragment = selectedFragment;
                if (selectedEntityIndex != -1) {
                    app.oncePostFlushImmediate(() -> {
                        if (destroyed)
                            return;
                        scrollToSelectedEntity(collectionView);
                        app.onceUpdate(collectionView, _ -> {
                            scrollToSelectedEntity(collectionView);
                            app.onceUpdate(collectionView, _ -> {
                                scrollToSelectedEntity(collectionView);
                            });
                        });
                    });
                }
            }
        });

    }

    function scrollToSelectedEntity(collectionView:CollectionView) {

        var selectedFragment = model.project.lastSelectedFragment;
        var selectedEntityIndex = selectedFragment != null ? selectedFragment.selectedEntityIndex : -1;
        if (selectedEntityIndex != -1) {
            collectionView.scrollToItem(selectedEntityIndex);
        }

    }

    function initSelectedEntitySection() {

        var title = new SectionTitleView();
        title.content = 'Selected entity';
        add(title);

        var layers = new LayersLayout();
        layers.viewSize(fill(), fill());

        var background = new RowLayout();
        background.viewSize(fill(), fill());
        layers.add(background);

        var formBackground = new View();
        formBackground.transparent = false;
        formBackground.color = Color.RED;
        formBackground.viewSize(fill(), fill());
        background.add(formBackground);

        var scrollbarBackground = new View();
        scrollbarBackground.transparent = false;
        scrollbarBackground.viewSize(12, fill());
        background.add(scrollbarBackground);

        background.autorun(() -> {
            formBackground.color = theme.mediumBackgroundColor;
            scrollbarBackground.color = theme.darkBackgroundColor;
        });

        var container = new ColumnLayout();
        container.paddingRight = 12;

        var form = new FormLayout();

        container.add(form);
        layers.add(container);

        var scroll = new ScrollingLayout(container, true);
        scroll.scroller.scrollbar = new Scrollbar();
        scroll.transparent = true;
        scroll.viewSize(fill(), fill());

        layers.add(scroll);
        add(layers);

        var prevSelectedEntity = null;
        autorun(function() {
            var active = model.project.lastSelectedFragment != null && model.project.lastSelectedFragment.selectedEntity != null;
            var entity = active ? model.project.lastSelectedFragment.selectedEntity : null;

            // Needed when changing depth, triggering list sorting and invalidation
            if (entity == prevSelectedEntity && entity != null)
                return;

            prevSelectedEntity = entity;

            title.active = active;
            layers.active = active;
            form.clear();
            scroll.scroller.scrollTo(scroll.scroller.scrollX, 0);

            if (active) {
                var entityClass = entity.entityClass;
                unobserve();
                fillEntityForm(form, entity);
                reobserve();
            }
        });

    }

    function fillEntityForm(form:FormLayout, entity:EditorEntityData) {

        var editableType = editor.getEditableType(entity.entityClass);

        if (editableType == null) {
            log.error('No editable type info for entity class: ${entity.entityClass}');
            return;
        }

        var usedGroups:Map<String,Bool> = new Map();

        var disabledFields:Map<String, Bool> = null;
        var list:Array<String> = editor.getEditableMeta(entity.entityClass, 'disable');
        if (list != null) {
            disabledFields = new Map();
            for (item in list) {
                disabledFields.set(item, true);
            }
        }

        inline function createFieldView(field:EditableTypeField) {

            if (disabledFields != null && disabledFields.exists(field.name))
                return null;

            var editableMeta:Dynamic = field.meta.editable != null ? field.meta.editable[0] : null;

            var fieldView = EntityFieldUtils.createEditableField(editableType, field, entity);
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
            var fieldView = EntityFieldUtils.createEditableEntityIdField(entity);
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

        var helpers:Array<Dynamic> = editor.getEditableMeta(entity.entityClass, 'helpers');
        if (helpers != null && helpers.length > 0) {

            var spacing = new View();
            spacing.transparent = true;
            spacing.viewSize(fill(), 8);
            form.add(spacing);

            var container = new ColumnLayout();
            container.itemSpacing = 4;
            container.paddingTop = 8;
            container.borderTopSize = 1;
            container.borderPosition = OUTSIDE;
            container.autorun(() -> {
                container.borderTopColor = theme.mediumBorderColor;
            });
            form.add(container);

            for (helper in helpers) {
                ((helper:Dynamic) -> {
    
                    var button = new Button();
                    button.content = helper.name;
                    button.onClick(this, function() {
                        log.debug('RUN HELPER ${helper.method}');
                        EntityHelpers.run(helper, entity);
                    });
                    container.add(button);

                })(helper);
            }
        }

    }

    function initAddEntityButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add entity';
        button.onClick(this, function() {
            var choices = [];
            for (i in 0...editor.editableEntities.length) {
                choices.push(editor.editableEntities[i].entity);
            }
            choices.sort(TextUtils.compareStrings);
            Choice.choose('Add entity', choices, true, (index, text) -> {
                log.debug('ADD ENTITY ' + choices[index]);
                model.project.lastSelectedFragment.selectedEntity = model.project.lastSelectedFragment.addItem(choices[index]);
            });
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.lastSelectedFragment != null && model.project.lastSelectedFragment.entities.length > 0;
        });

    }

    function updateStyle() {

        //

    }

}