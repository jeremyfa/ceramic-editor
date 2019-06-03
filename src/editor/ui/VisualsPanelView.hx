package editor.ui;

class VisualsPanelView extends LinearLayout implements Observable {

/// Lifecycle

    public function new() {

        super();

        initAllVisualsSection();
        initAddVisualButton();

    } //new

    function initAllVisualsSection() {

        var linear = new LinearLayout();
        add(linear);

        autorun(function() {
            var enabled = model.project.selectedFragment != null;
            unobserve();
            linear.clear();

            if (enabled) {

                var title = new TextView();
                title.content = 'All visuals';
                title.align = CENTER;
                title.verticalAlign = CENTER;
                title.pointSize = 10;
                title.borderBottomSize = 1;
                title.padding(5, 0);
                add(title);

                title.autorun(function() {
                    title.color = theme.lightBackgroundColor;
                    title.borderBottomColor = theme.darkBackgroundColor;
                    title.font = theme.boldFont10;
                });

            }
        });

    } //initAllVisualsSection

    function initAddVisualButton() {

        // TODO

    } //initAddVisualButton

} //VisualsPanelView
