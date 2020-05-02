package editor.ui.element;

class PendingChoiceContentView extends View {

    var pendingChoice:EditorPendingChoice;

    var scrollingLayout:ScrollingLayout<ColumnLayout>;

    var messageText:TextView = null;

    public function new(pendingChoice:EditorPendingChoice) {

        super();

        this.pendingChoice = pendingChoice;
        transparent = true;

        scrollingLayout = new ScrollingLayout(new ColumnLayout());
        scrollingLayout.layoutView.padding(4, 0);

        var maxHeight = 350;
        viewWidth = 250;

        if (pendingChoice.message != null) {
            messageText = new TextView();
            messageText.preRenderedSize = 20;
            messageText.pointSize = 12;
            messageText.viewSize(fill(), auto());
            messageText.padding(6);
            messageText.align = CENTER;
            messageText.content = pendingChoice.message;
            scrollingLayout.layoutView.add(messageText);
        }

        fillChoices();

        autorun(updateStyle);

        scrollingLayout.onLayout(this, () -> {
            app.oncePostFlushImmediate(() -> {
                viewHeight = Math.min(maxHeight, scrollingLayout.layoutView.computedHeight);
            });
        });

        add(scrollingLayout);

    }

    function fillChoices() {

        for (i in 0...pendingChoice.choices.length) {

            var choice = pendingChoice.choices[i];

            var buttonContainer = new ColumnLayout();
            buttonContainer.padding(4, 8);

            var button = new Button();
            button.content = choice;
            ((i, choice) -> {
                button.onClick(this, () -> {
                    pendingChoice.callback(i, choice);
                });
            })(i, choice);

            buttonContainer.add(button);

            scrollingLayout.layoutView.add(buttonContainer);

        }

    }

    override function layout() {

        scrollingLayout.size(width, height);

    }
    
    function updateStyle() {
        
        if (messageText != null) {
            messageText.color = theme.lightTextColor;
            messageText.font = theme.mediumFont;
        }

    }

}