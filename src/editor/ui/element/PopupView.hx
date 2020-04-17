package editor.ui.element;

class PopupView extends View implements Observable {

    @event function cancel();

    var overlay:Quad;

    var containerView:ColumnLayout;

    var headerView:TextView;

    var bodyView:View;

    var usedContentView:View = null;

    @observe public var cancelable:Bool = false;

    @observe public var title:String;

    @observe public var contentView:View;

    public function new(?contentView:View) {

        super();

        this.contentView = contentView;

        transparent = true;

        overlay = new Quad();
        overlay.depth = 1;
        overlay.onPointerDown(this, _ -> {
            if (cancelable) {
                emitCancel();
            }
        });
        overlay.onPointerOver(this, _ -> {});
        add(overlay);

        containerView = new ColumnLayout();
        containerView.depth = 2;
        containerView.transparent = true;
        add(containerView);
        {
            headerView = new TextView();
            headerView.depth = 3;
            headerView.viewSize(fill(), auto());
            headerView.align = CENTER;
            headerView.verticalAlign = CENTER;
            headerView.pointSize = 12;
            headerView.padding(5, 0);
            autorun(() -> {
                var title = this.title;
                unobserve();
                headerView.content = title == null ? '' : title;
            });
            containerView.add(headerView);
    
            bodyView = new View();
            bodyView.depth = 4;
            containerView.add(bodyView);
        }

        autorun(updateContentView);
        autorun(updateStyle);

    }

    override function layout() {

        containerView.computeSizeIfNeeded(width, height, ViewLayoutMask.FLEXIBLE, true);
        containerView.size(containerView.computedWidth, containerView.computedHeight);
        containerView.pos(width * 0.5, height * 0.5);
        containerView.anchor(0.5, 0.5);

        overlay.pos(0, 0);
        overlay.size(width, height);

    }

    function updateContentView() {

        var contentView = this.contentView;

        unobserve();

        if (usedContentView != null && usedContentView != contentView) {
            usedContentView.destroy();
        }

        usedContentView = contentView;

        if (contentView != null) {
            containerView.add(contentView);
        }

        active = contentView != null;

        reobserve();

    }

    function updateStyle() {

        overlay.alpha = 0.5;
        overlay.color = Color.BLACK;

        containerView.borderSize = 1;
        containerView.borderPosition = OUTSIDE;
        containerView.borderColor = theme.mediumBorderColor;
        containerView.transparent = false;
        containerView.color = theme.mediumBackgroundColor;

        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomColor = theme.mediumBorderColor;
        headerView.borderBottomSize = 1;
        headerView.borderPosition = INSIDE;
        headerView.font = theme.boldFont10;

    }

    public function reset() {

        title = null;
        contentView = null;
        cancelable = false;

    }

}
