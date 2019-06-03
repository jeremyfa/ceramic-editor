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

        onLayout(this, function() {
            dataSource.width = width;
        });

        var prevLength = 0;
        autorun(function() {
            var length = model.project.fragments.length;
            if (length != prevLength) {
                prevLength = length;
                collectionView.reloadData();
            }
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
            item.field.updateTextValue = function(textValue:String) {
                var fragment = model.project.selectedFragment;
                if (fragment == null) return;
                fragment.name = textValue;
            };
            autorun(function() {
                var fragment = model.project.selectedFragment;
                if (fragment == null) return;
                item.field.textValue = fragment.name;
            });
            form.add(item);
        })();

        (function() {
            var item = new LabeledFieldView(new TextFieldView());
            item.label = 'Width';
            item.field.updateTextValue = function(textValue:String) {
                if (textValue.trim() != '') {
                    var fragment = model.project.selectedFragment;
                    if (fragment == null) return;
                    var intValue = Std.parseInt(textValue);
                    if (intValue != null && !Math.isNaN(intValue) && Math.isFinite(intValue)) {
                        fragment.width = intValue;
                        item.field.textValue = '' + fragment.width;
                    }
                }
                else {
                    item.field.textValue = '';
                }
                item.field.invalidateTextValue();
            };
            autorun(function() {
                var fragment = model.project.selectedFragment;
                if (fragment == null) return;
                var focused = item.field.focused;
                item.field.textValue = '' + fragment.width;
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

        // TODO

    } //initAddFragmentButton

} //FragmentsPanelView
