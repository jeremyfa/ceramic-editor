package editor.ui.element;

class PendingChoiceContentView extends View {

    var pendingChoice:EditorPendingChoice;

    var scrollingLayout:ScrollingLayout<ColumnLayout>;

    public function new(pendingChoice:EditorPendingChoice) {

        super();

        this.pendingChoice = pendingChoice;
        transparent = true;

        scrollingLayout = new ScrollingLayout(new ColumnLayout());
        scrollingLayout.layoutView.padding(4, 0);

        var maxHeight = 350;
        viewWidth = 250;

        scrollingLayout.onLayout(this, () -> {
            app.oncePostFlushImmediate(() -> {
                viewHeight = Math.min(maxHeight, scrollingLayout.layoutView.computedHeight);
            });
        });

        add(scrollingLayout);

        fillChoices();

    }

    function fillChoices() {

        for (i in 0...pendingChoice.choices.length) {

            var choice = pendingChoice.choices[i];

            var buttonContainer = new LinearLayout();
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

}