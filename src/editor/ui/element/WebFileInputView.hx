package editor.ui.element;

class WebFileInputView extends View {

    @event function open(name:String, contents:String);

    static var _point:Point = new Point(0, 0);

#if web

    var input:Dynamic = null;

    override function set_x(x:Float):Float {
        if (this.x == x) return x;
        super.set_x(x);
        if (input != null) {
            visualToScreen(0, 0, _point);
            input.style.left = _point.x + 'px';
        }
        return x;
    }

    override function set_y(y:Float):Float {
        if (this.y == y) return y;
        super.set_y(y);
        if (input != null) {
            visualToScreen(0, 0, _point);
            input.style.top = _point.y + 'px';
        }
        return y;
    }

    override function set_visible(visible:Bool):Bool {
        if (this.visible == visible) return visible;
        this.visible = visible;
        computeInputVisibility();
        return visible;
    }

    function computeInputVisibility() {
        if (input != null) {
            if (visibilityDirty) {
                computeVisibility();
            }
            if (computedVisible) {
                visualToScreen(0, 0, _point);
                input.style.left = _point.x + 'px';
                input.style.top = _point.y + 'px';
                input.style.display = 'block';
            }
            else {
                input.style.left = '-9999px';
                input.style.top = '-9999px';
                input.style.display = 'none';
            }
        }
    }

    public function new() {

        super();

        transparent = true;
        onPointerDown(this, _ -> {});

        app.onUpdate(this, _ -> {
            computeInputVisibility();
        });

    }

    override function destroy() {

        super.destroy();

        if (input != null) {
            var document:Dynamic = untyped window.document;
            document.body.removeChild(input);
            input = null;
        }

    }

    function createInput() {

        var document:Dynamic = untyped window.document;
        input = document.createElement('input');
        input.setAttribute('id', 'file-input');
        input.setAttribute('type', 'file');
        input.style.left = x + 'px';
        input.style.top = y + 'px';
        input.style.position = 'absolute';
        input.style.outline = 'none';
        input.style.zIndex = '1001';
        input.style.opacity = '0';
        input.style.width = width + 'px';
        input.style.height = height + 'px';
        document.body.appendChild(input);

        input.addEventListener('change', function(e) {
            var file:Dynamic = e.target.files[0];
            if (!file) {
                return;
            }
            var reader = new js.html.FileReader();
            reader.onload = function(e) {
                var contents:String = e.target.result;
                emitOpen(file.name, contents);
            };
            reader.readAsText(file);
        }, false);

        computeInputVisibility();

    }

    override function layout() {

        if (input == null)
            createInput();

        input.style.width = width + 'px';
        input.style.height = height + 'px';

    }

#end

}