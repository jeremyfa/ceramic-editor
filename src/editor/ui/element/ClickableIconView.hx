package editor.ui.element;

class ClickableIconView extends EntypoIconView {

    @event function click();

    @event function longPress();

    public function new() {

        super();
        
        transform = new Transform();

        var click = new Click();
        component('click', click);
        click.onClick(this, () -> {
            emitClick();
        });

        var longPress = new LongPress(info -> {
            emitLongPress();
        }, click);
        component('longPress', longPress);

        onPointerDown(this, _ -> {
            transform.ty = 1;
            transform.changedDirty = true;
        });
        onPointerUp(this, _ -> {
            transform.ty = 0;
            transform.changedDirty = true;
        });

    }

}