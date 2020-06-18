package editor.ui.scripts;

using StringTools;

class ScriptsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allScriptsCollectionView:CellCollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllScriptsSection();
        initSelectedScriptSection();
        initAddButton();

        autorun(updateStyle);

    }

    function initAllScriptsSection() {

        var title = new SectionTitleView();
        title.content = 'All scripts';
        add(title);

        var dataSource = new ScriptCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(50));
        collectionView.dataSource = dataSource;
        add(collectionView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.scripts.length;
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
            var active = model.project.scripts.length > 0;
            title.active = active;
            collectionView.active = active;
        });

        var prevSelectedScriptIndex = -1;
        autorun(function() {
            var selectedScriptIndex = model.project.selectedScriptIndex;
            unobserve();
            if (selectedScriptIndex != prevSelectedScriptIndex) {
                prevSelectedScriptIndex = selectedScriptIndex;
                if (selectedScriptIndex != -1) {
                    app.oncePostFlushImmediate(() -> {
                        if (destroyed)
                            return;
                        scrollToSelectedScript(collectionView);
                        app.onceUpdate(collectionView, _ -> {
                            scrollToSelectedScript(collectionView);
                            app.onceUpdate(collectionView, _ -> {
                                scrollToSelectedScript(collectionView);
                            });
                        });
                    });
                }
            }
        });

    }

    function scrollToSelectedScript(collectionView:CollectionView) {

        var selectedScriptIndex = model.project.selectedScriptIndex;
        if (selectedScriptIndex != -1) {
            collectionView.scrollToItem(selectedScriptIndex);
        }

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
                var script = model.project.selectedScript;
                unobserve();
                if (script != null && !script.destroyed) {
                    item.field = EntityFieldUtils.createEditableScriptIdField(script);
                }
            });
            form.add(item);
        })();

        autorun(function() {
            var active = model.project.selectedScript != null;
            title.active = active;
            form.active = active;
        });

    }

    function initAddButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add script';
        button.onClick(this, function() {
            model.project.selectedScript = model.project.addScript();
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.scripts.length > 0;
        });

    }

    function updateStyle() {

        //

    }

}
