package editor.ui.visuals;

class VisualsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allVisualsCollectionView:CellCollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllVisualsSection();
        initSelectedVisualSection();
        initAddVisualButton();

    } //new

    function initAllVisualsSection() {

        var title = new SectionTitleView();
        title.content = 'All visuals';
        add(title);

        var dataSource = new VisualCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(25));
        collectionView.transparent = true;
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
            }
        });

        autorun(function() {
            var active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
            title.active = active;
            collectionView.active = active;
        });

    } //initAllFragmentsSection

    function initSelectedVisualSection() {

        var title = new SectionTitleView();
        title.content = 'Selected visual';
        add(title);

        var form = new FormLayout();

        var scroll = new ScrollingLayout(form);
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

    } //initSelectedVisualSection

    function fillVisualForm(form:FormLayout, visual:EditorVisualData) {

        var editableType = editor.getEditableType(visual.entityClass);

        if (editableType == null) {
            log.error('No editable type info for entity class: ${visual.entityClass}');
            return;
        }

        for (i in 0...editableType.fields.length) {
            var field = editableType.fields[i];

            var fieldView = FieldUtils.createEditableField(editableType, field, visual);
            if (fieldView != null) {
                
                var item = new LabeledFieldView(fieldView);
                item.label = field.name;
                form.add(item);
            }
        }

    } //fillVisualForm

    function initAddVisualButton() {

        var separator = new SectionSeparatorView();
        add(separator);

        var container = new PaddedLayout();
        add(container);

        var button = new Button();
        button.content = 'Add visual';
        button.onClick(this, function() {
            model.project.selectedFragment.selectedVisual = model.project.selectedFragment.addVisual('ceramic.Quad');
        });
        container.add(button);

        autorun(function() {
            separator.active = model.project.selectedFragment != null && model.project.selectedFragment.visuals.length > 0;
        });

    } //initAddVisualButton

} //VisualsPanelView
