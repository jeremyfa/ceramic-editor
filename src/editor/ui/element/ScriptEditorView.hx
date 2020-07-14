package editor.ui.element;

class ScriptEditorView extends View implements Observable {

    @observe public var selectedScript:EditorScriptData;

    public var hideMonacoEditor(default, set):Bool = false;
    function set_hideMonacoEditor(hideMonacoEditor:Bool):Bool {
        if (this.hideMonacoEditor != hideMonacoEditor) {
            this.hideMonacoEditor = hideMonacoEditor;
            layoutDirty = true;
        }
        return hideMonacoEditor;
    }

    #if web
    var monaco:MonacoEditorView;
    #else
    var nativeEditor:NativeScriptEditorView;
    #end

    var headerView:RowLayout;

    var titleText:TextView;

    public function new() {

        super();

        #if web
        monaco = new MonacoEditorView();
        add(monaco);
        #else
        nativeEditor = new NativeScriptEditorView();
        add(nativeEditor);
        #end

        headerView = new RowLayout();
        headerView.padding(0, 6);
        headerView.depth = 2;
        {
            var leftIconView = new ClickableIconView();
            leftIconView.viewSize(24, fill());
            leftIconView.icon = CANCEL;
            leftIconView.onClick(this, () -> {
                model.project.selectedScript = null;
            });
            headerView.add(leftIconView);

            titleText = new TextView();
            titleText.viewSize(fill(), fill());
            titleText.align = CENTER;
            titleText.verticalAlign = CENTER;
            titleText.preRenderedSize = 20;
            titleText.pointSize = 13;
            headerView.add(titleText);

            var filler = new View();
            filler.transparent = true;
            filler.viewSize(24, fill());
            headerView.add(filler);
        }
        add(headerView);

        autorun(updateFromSelectedScript);
        autorun(updateStyle);

        #if web
        monaco.onContentChange(this, (newContent, prevContent) -> {
            var selectedScript = this.selectedScript;
            if (selectedScript != null) {
                if (selectedScript.content != newContent) {
                    selectedScript.content = newContent;
                    if (!monaco.didUndoOrRedo) {
                        model.history.step();
                    }
                }
            }
        });
        #else
        nativeEditor.onContentChange(this, (newContent) -> {
            var selectedScript = this.selectedScript;
            if (selectedScript != null) {
                if (selectedScript.content != newContent) {
                    selectedScript.content = newContent;
                    if (true/*!monaco.didUndoOrRedo*/) {
                        model.history.step();
                    }
                }
            }
        });
        #end

    }

    function updateFromSelectedScript() {

        var selectedScript = this.selectedScript;

        unobserve();

        if (selectedScript != null) {
            reobserve();
            var scriptId = selectedScript.scriptId;
            var scriptContent = selectedScript.content;
            unobserve();
            titleText.content = scriptId;
            #if web
            monaco.setContent(scriptContent);
            monaco.active = true;
            #else
            nativeEditor.setContent(scriptContent);
            nativeEditor.active = true;
            #end
        }
        else {
            titleText.content = '';
            #if web
            monaco.setContent(null);
            monaco.active = false;
            #else
            nativeEditor.setContent(null);
            nativeEditor.active = false;
            #end
        }

        reobserve();

    }

    override function layout() {

        var headerViewHeight = 25;

        #if web
        monaco.pos(hideMonacoEditor ? -9999 : 0, hideMonacoEditor ? -9999 : headerViewHeight);
        monaco.size(width, height - headerViewHeight);
        #else
        nativeEditor.pos(0, headerViewHeight);
        nativeEditor.computeSize(width, height - headerViewHeight, ViewLayoutMask.FIXED, true);
        nativeEditor.applyComputedSize();
        #end

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