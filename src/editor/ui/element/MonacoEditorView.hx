package editor.ui.element;

class MonacoEditorView extends View implements Observable {

    static var _point:Point = new Point(0, 0);

    @observe public var content:String = '';

    public var didUndoOrRedo:Bool = false;

#if web

    var iframe:Dynamic = null;

    var iframeReady:Bool = false;

    override function set_x(x:Float):Float {
        if (this.x == x) return x;
        super.set_x(x);
        if (iframe != null) {
            visualToScreen(0, 0, _point);
            iframe.style.left = _point.x + 'px';
        }
        return x;
    }

    override function set_y(y:Float):Float {
        if (this.y == y) return y;
        super.set_y(y);
        if (iframe != null) {
            visualToScreen(0, 0, _point);
            iframe.style.top = _point.y + 'px';
        }
        return y;
    }

    override function set_visible(visible:Bool):Bool {
        if (this.visible == visible) return visible;
        this.visible = visible;
        computeIframeVisibility();
        return visible;
    }

    function computeIframeVisibility() {
        if (iframe != null) {
            if (visibilityDirty) {
                computeVisibility();
            }
            if (computedVisible) {
                visualToScreen(0, 0, _point);
                iframe.style.left = _point.x + 'px';
                iframe.style.top = _point.y + 'px';
                iframe.style.display = 'block';
            }
            else {
                iframe.style.left = '-9999px';
                iframe.style.top = '-9999px';
                iframe.style.display = 'none';
            }
        }
    }

    public function new() {

        super();

        transparent = true;
        onPointerDown(this, _ -> {});

        app.onUpdate(this, _ -> {
            computeIframeVisibility();
        });

    }

    override function destroy() {

        super.destroy();

        if (iframe != null) {
            var document:Dynamic = untyped window.document;
            document.body.removeChild(iframe);
            iframe = null;
        }

    }

    function createIframe() {

        var document:Dynamic = untyped window.document;
        iframe = document.createElement('iframe');
        iframe.onload = function() {
            initMonaco();
        };
        iframe.setAttribute('id', 'monaco-editor');
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('src', 'monaco-editor.html');
        iframe.style.left = x + 'px';
        iframe.style.top = y + 'px';
        iframe.style.position = 'absolute';
        iframe.style.zIndex = '1000';
        iframe.setAttribute('width', '' + width);
        iframe.setAttribute('height', '' + height);
        document.body.appendChild(iframe);

        computeIframeVisibility();

    }

    function initMonaco() {

        // Fetch ceramic API
        Http.request({
            url: 'api/api.d.ts'
        }, response -> {

            // Extra libs
            var extraLibs = [];
            var dts = response.content;
            if (dts != null)
                extraLibs.push(dts);

            iframe.contentWindow.initMonaco(
                content,
                extraLibs,
                editorLog,
                handleChange,
                handleSave,
                handleSaveAs,
                handleUndo,
                handleRedo
            );

            iframeReady = true;
        });

    }

    function editorLog(message:String) {

        log.info(message);

    }

    function handleChange(lines:Array<String>, didUndoOrRedo:Bool) {

        content = lines.join('\n');
        this.didUndoOrRedo = didUndoOrRedo;

    }

    function handleSave() {

        model.saveProject();

    }

    function handleSaveAs() {

        model.saveProject(true);

    }

    function handleUndo() {

        //

    }

    function handleRedo() {

        //

    }

    public function setContent(content:String) {

        if (this.content == content)
            return;

        this.content = content;

        if (!iframeReady) {
            app.onceUpdate(this, _ -> {
                setContent(content);
            });
            return;
        }
        
        iframe.contentWindow.setEditorContent(content);

    }

    override function layout() {

        if (iframe == null)
            createIframe();

        iframe.setAttribute('width', '' + width);
        iframe.setAttribute('height', '' + height);

    }

#end

}