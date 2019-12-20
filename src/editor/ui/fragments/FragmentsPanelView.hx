package editor.ui.fragments;

using StringTools;

class FragmentsPanelView extends LinearLayout implements Observable {

/// Internal properties

    var allFragmentsCollectionView:CellCollectionView;

/// Lifecycle

    public function new() {

        super();

        initAllFragmentsSection();
        initSelectedFragmentSection();
        initAddFragmentButton();

    } //new

    function initAllFragmentsSection() {

        var title = new SectionTitleView();
        title.content = 'All fragments';
        add(title);

        var dataSource = new FragmentCellDataSource();

        var collectionView = new CellCollectionView();
        collectionView.viewSize(fill(), percent(25));
        collectionView.transparent = true;
        collectionView.dataSource = dataSource;
        add(collectionView);

        var prevLength = 0;
        autorun(function() {
            var length = model.project.fragments.length;
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
            var active = model.project.fragments.length > 0;
            title.active = active;
            collectionView.active = active;
        });

    } //initAllFragmentsSection

    function initSelectedFragmentSection() {

        var title = new SectionTitleView();
        title.content = 'Selected fragment';
        add(title);

        var form = new FormLayout();
        add(form);

        (function() {
            var item = new LabeledFieldView(new TextFieldView());
            item.label = 'Name';
            item.field.setValue = function(field, value) {
                var fragment = model.project.selectedFragment;
                if (fragment != null) fragment.name = value;
            };
            autorun(function() {
                var fragment = model.project.selectedFragment;
                if (fragment != null) item.field.textValue = fragment.name;
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView());
            item.label = 'Width';
            item.field.setTextValue = SanitizeTextField.setTextValueToInt;
            item.field.setEmptyValue = function(field) {
                var fragment = model.project.selectedFragment;
                if (fragment != null) fragment.width = 0;
            };
            item.field.setValue = function(field, value) {
                var fragment = model.project.selectedFragment;
                if (fragment != null) fragment.width = value;
            };
            autorun(function() {
                var fragment = model.project.selectedFragment;
                if (fragment != null) item.field.textValue = '' + fragment.width;
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView());
            item.label = 'Height';
            item.field.setTextValue = SanitizeTextField.setTextValueToInt;
            item.field.setEmptyValue = function(field) {
                var fragment = model.project.selectedFragment;
                if (fragment != null) fragment.height = 0;
            };
            item.field.setValue = function(field, value) {
                var fragment = model.project.selectedFragment;
                if (fragment != null) fragment.height = value;
            };
            autorun(function() {
                var fragment = model.project.selectedFragment;
                if (fragment != null) item.field.textValue = '' + fragment.height;
            });
            form.add(item);
        })();

        autorun(function() {
            var active = model.project.selectedFragment != null;
            title.active = active;
            form.active = active;
        });

    } //initSelectedFragmentSection

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

        autorun(function() {
            separator.active = model.project.fragments.length > 0;
        });

    } //initAddFragmentButton

} //FragmentsPanelView
