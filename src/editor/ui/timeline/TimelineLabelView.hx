package editor.ui.timeline;

class TimelineLabelView extends TextView implements Observable {

    public var index:Int;

    var timelineLabelsView:TimelineLabelsView;

    @observe var hover:Bool = false;

    @component var click:Click;

    public function new(timelineLabelsView:TimelineLabelsView, index:Int) {

        super();

        this.timelineLabelsView = timelineLabelsView;
        this.index = index;

        preRenderedSize = 20;
        pointSize = 10;
        anchor(0, 0.5);
        align = LEFT;
        verticalAlign = CENTER;
        padding(0, 4);
        transparent = false;

        click = new Click();
        click.threshold = 4;
        click.onClick(this, handleClick);

        onPointerOver(this, handlePointerOver);
        onPointerOut(this, handlePointerOut);

        autorun(updateStyle);

    }

    function handlePointerOver(info:TouchInfo) {

        hover = true;

    }

    function handlePointerOut(info:TouchInfo) {

        hover = false;

    }

    function handleClick() {

        trace('LABEL CLICK $index');

        timelineLabelsView.promptLabel(index);

    }

    function updateStyle() {

        font = theme.boldFont;
        textColor = theme.lightTextColor;
        color = hover ? theme.lightBackgroundColor : theme.darkBackgroundColor;

    }

}