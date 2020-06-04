package editor.ui.element;

class ScriptEditorView extends View implements Observable {

    @observe public var selectedScript:EditorScriptData;

    var monaco:MonacoEditorView;

    var headerView:RowLayout;

    var titleText:TextView;

    public function new() {

        super();

        monaco = new MonacoEditorView();
        add(monaco);

        headerView = new RowLayout();
        headerView.padding(0, 6);
        headerView.depth = 2;
        {
            titleText = new TextView();
            titleText.viewSize(fill(), fill());
            titleText.align = CENTER;
            titleText.verticalAlign = CENTER;
            titleText.preRenderedSize = 20;
            titleText.pointSize = 13;
            headerView.add(titleText);
        }
        add(headerView);

        autorun(updateFromSelectedScript);
        autorun(updateStyle);

        monaco.onContentChange(this, (newContent, prevContent) -> {
            var selectedScript = this.selectedScript;
            if (selectedScript != null) {
                selectedScript.content = newContent;
            }
        });

    }

    function updateFromSelectedScript() {

        var selectedScript = this.selectedScript;

        unobserve();

        if (selectedScript != null) {
            titleText.content = selectedScript.scriptId;
            monaco.setContent(selectedScript.content);
            monaco.active = true;
        }
        else {
            titleText.content = '';
            monaco.setContent(null);
            monaco.active = false;
        }

        reobserve();

    }

    override function layout() {

        var headerViewHeight = 25;

        monaco.pos(0, headerViewHeight);
        monaco.size(width, height - headerViewHeight);

        headerView.viewSize(width, headerViewHeight);
        headerView.computeSize(width, height - headerViewHeight, ViewLayoutMask.FIXED, true);
        headerView.applyComputedSize();
        headerView.pos(0, 0);

    }

    function updateStyle() {

        color = theme.windowBackgroundColor;

        headerView.transparent = false;
        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomSize = 1;
        headerView.borderBottomColor = theme.darkBorderColor;
        headerView.borderPosition = INSIDE;

    }

}