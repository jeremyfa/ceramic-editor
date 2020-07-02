package editor.ui.element;

class NativeScriptEditorView extends View implements Observable {

    @event function contentChange(content:String);

    var textView:TextView;

    var editText:EditText;

    var content:String = '';

    var shouldSubmitContentChange:Bool = false;

    public function new() {

        super();

        textView = new TextView();
        textView.preRenderedSize = 20;
        textView.font = theme.mediumFont;
        textView.pointSize = 14;
        textView.maxLineDiff = -1;
        add(textView);

        editText = new EditText(theme.focusedFieldSelectionColor, theme.lightTextColor);
        editText.container = this;
        editText.multiline = true;
        textView.text.component('editText', editText);
        editText.onUpdate(this, updateFromEditText);
        editText.onStop(this, handleStopEditText);

        autorun(updateStyle);

        Timer.interval(this, 0.5, () -> {
            if (shouldSubmitContentChange) {
                shouldSubmitContentChange = false;
                emitContentChange(content);
            }
        });

    }

    public function setContent(scriptContent:String) {

        if (this.content == scriptContent)
            return;

        this.content = scriptContent;
        textView.content = scriptContent != null ? scriptContent : '';

    }

    function updateFromEditText(text:String) {

        if (this.content == text)
            return;

        this.content = text;
        shouldSubmitContentChange = true;

    }

    function handleStopEditText() {

        //

    }

    override function layout() {

        var pad = 10;

        textView.pos(pad, pad);
        textView.computeSize(width - pad * 2, height - pad * 2, ViewLayoutMask.INCREASE_HEIGHT, true);
        textView.applyComputedSize();

    }

    function updateStyle() {

        transparent = false;
        color = Color.BLACK;

        textView.textColor = theme.lightTextColor;

    }

}