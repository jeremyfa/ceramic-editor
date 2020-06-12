package editor.ui.editables;

using StringTools;

class EditableElementsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allEditablesCollectionView:CellCollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllEditablesSection();
        initSelectedEditableSection();
        initSelectedScriptSection();
        initAddFragmentButton();

        autorun(updateStyle);

    }

    function initAllEditablesSection() {

        var title = new SectionTitleView();
        title.content = 'All editables';
        add(title);

        var dataSource = new EditableElementCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(25));
        collectionView.dataSource = dataSource;
        add(collectionView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.editables.length;
            unobserve();
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
            var active = model.project.editables.length > 0;
            title.active = active;
            collectionView.active = active;
        });

        var prevSelectedEditableIndex = -1;
        autorun(function() {
            var selectedEditableIndex = model.project.selectedEditableIndex;
            unobserve();
            if (selectedEditableIndex != prevSelectedEditableIndex) {
                prevSelectedEditableIndex = selectedEditableIndex;
                if (selectedEditableIndex != -1) {
                    app.oncePostFlushImmediate(() -> {
                        if (destroyed)
                            return;
                        scrollToSelectedEditable(collectionView);
                        app.onceUpdate(collectionView, _ -> {
                            scrollToSelectedEditable(collectionView);
                            app.onceUpdate(collectionView, _ -> {
                                scrollToSelectedEditable(collectionView);
                            });
                        });
                    });
                }
            }
        });

    }

    function scrollToSelectedEditable(collectionView:CollectionView) {

        var selectedEditableIndex = model.project.selectedEditableIndex;
        if (selectedEditableIndex != -1) {
            collectionView.scrollToItem(selectedEditableIndex);
        }

    }

    function initSelectedEditableSection() {

        var title = new SectionTitleView();
        title.content = 'Selected fragment';
        add(title);

        var form = new FormLayout();
        add(form);

        (function() {
            var item = new LabeledFieldView(null);
            item.label = 'Id';
            item.autorun(() -> {
                var fragment = model.project.lastSelectedFragment;
                unobserve();
                if (fragment != null) {
                    item.field = EntityFieldUtils.createEditableFragmentIdField(fragment);
                }
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView(NUMERIC));
            item.label = 'Width';
            item.field.setTextValue = SanitizeTextField.setTextValueToInt(0, 999999999);
            item.field.setEmptyValue = function(field) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.width = 0;
            };
            item.field.setValue = function(field, value) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.width = value;
            };
            autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) item.field.textValue = '' + fragment.width;
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView(NUMERIC));
            item.label = 'Height';
            item.field.setTextValue = SanitizeTextField.setTextValueToInt(0, 999999999);
            item.field.setEmptyValue = function(field) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.height = 0;
            };
            item.field.setValue = function(field, value) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.height = value;
            };
            autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) item.field.textValue = '' + fragment.height;
            });
            form.add(item);
        })();

        var inGroup:Array<Dynamic> = [];

        (function() {
            var item = new LabeledFieldView(new BooleanFieldView());
            item.label = 'Transparent';
            item.field.setValue = function(field, value) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.transparent = value;
            };
            item.field.autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) item.field.value = fragment.transparent;
            });
            inGroup.push(item);
        })();

        (function() {
            var item = new LabeledFieldView(new BooleanFieldView());
            item.label = 'Overflow';
            item.field.setValue = function(field, value) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.overflow = value;
            };
            item.field.autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) item.field.value = fragment.overflow;
            });
            inGroup.push(item);
        })();

        var group = new LabeledFieldGroupView(inGroup);
        form.add(group);

        (function() {
            var item = new LabeledFieldView(new ColorFieldView());
            item.label = 'Color';
            item.field.setValue = function(field, value) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.color = value;
            };
            item.field.autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) item.field.value = fragment.color;
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView());
            item.label = 'Bundle';
            item.field.placeholder = 'default';
            item.field.setTextValue = SanitizeTextField.setTextValueToIdentifier;
            item.field.setEmptyValue = function(field) {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.bundle = null;
            };
            item.field.setValue = function(field, value) {
                if (value == '')
                    value = null;
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null) fragment.bundle = value;
            };
            item.autorun(function() {
                var fragment = model.project.lastSelectedFragment;
                if (fragment != null && !fragment.destroyed) item.field.textValue = fragment.bundle != null ? '' + fragment.bundle : '';
            });
            form.add(item);
        })();

        autorun(function() {
            var active = model.project.lastSelectedFragment != null;
            title.active = active;
            form.active = active;
        });

    }

    function initSelectedScriptSection() {

        var title = new SectionTitleView();
        title.content = 'Selected script';
        add(title);

        var form = new FormLayout();
        add(form);

        (function() {
            var item = new LabeledFieldView(null);
            item.label = 'Id';
            item.autorun(() -> {
                var script = model.project.lastSelectedScript;
                unobserve();
                if (script != null && !script.destroyed) {
                    item.field = EntityFieldUtils.createEditableScriptIdField(script);
                }
            });
            form.add(item);
        })();

        autorun(function() {
            var active = model.project.lastSelectedScript != null;
            title.active = active;
            form.active = active;
        });

    }

    function initAddFragmentButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add fragment';
        button.onClick(this, function() {
            model.project.selectedFragment = model.project.addFragment();
        });
        container.add(button);

        var button = new Button();
        button.content = 'Add script';
        button.onClick(this, function() {
            model.project.selectedScript = model.project.addScript();
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.editables.length > 0;
        });

    }

    function updateStyle() {

        //

    }

}
