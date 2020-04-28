package editor.ui.element;

class ClickableIconView extends EntypoIconView {

    @event function click();

    public function new() {

        super();
        
        transform = new Transform();

        var click = new Click();
        component('click', click);
        click.onClick(this, () -> {
            emitClick();
        });

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