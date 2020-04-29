package editor.ui.element;

class PopupView extends View implements Observable {

    @event function cancel();

    var overlay:Quad;

    var containerView:ColumnLayout;

    var headerView:RowLayout;

    var titleView:TextView;

    var bodyView:View;

    var usedContentView:View = null;

    var leftIconView:ClickableIconView = null;

    var rightIconView:ClickableIconView = null;

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
        containerView.onPointerDown(this, _ -> {});
        add(containerView);
        {

            headerView = new RowLayout();
            headerView.transparent = false;
            headerView.depth = 3;
            headerView.viewSize(fill(), 28);
            headerView.align = CENTER;
            headerView.padding(5, 0);
            containerView.add(headerView);

            leftIconView = new ClickableIconView();
            leftIconView.viewSize(24, fill());
            leftIconView.icon = CANCEL;
            leftIconView.autorun(() -> {
                leftIconView.visible = cancelable;
            });
            leftIconView.onClick(this, () -> {
                if (cancelable) {
                    emitCancel();
                }
            });
            headerView.add(leftIconView);

            titleView = new TextView();
            titleView.viewSize(fill(), auto());
            titleView.align = CENTER;
            titleView.verticalAlign = CENTER;
            titleView.pointSize = 12;
            titleView.preRenderedSize = 20;
            titleView.padding(5, 0);
            autorun(() -> {
                var title = this.title;
                unobserve();
                titleView.content = title == null ? '' : title;
            });
            headerView.add(titleView);

            rightIconView = new ClickableIconView();
            rightIconView.viewSize(24, fill());
            rightIconView.visible = false;
            headerView.add(rightIconView);
    
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

        leftIconView.textColor = theme.mediumTextColor;
        rightIconView.textColor = theme.mediumTextColor;

        containerView.borderSize = 1;
        containerView.borderPosition = OUTSIDE;
        containerView.borderColor = theme.mediumBorderColor;
        containerView.transparent = false;
        containerView.color = theme.mediumBackgroundColor;

        headerView.color = theme.lightBackgroundColor;
        headerView.borderBottomColor = theme.mediumBorderColor;
        headerView.borderBottomSize = 1;
        headerView.borderPosition = INSIDE;

        titleView.font = theme.boldFont;

    }

    public function reset() {

        title = null;
        contentView = null;
        cancelable = false;

    }

}
