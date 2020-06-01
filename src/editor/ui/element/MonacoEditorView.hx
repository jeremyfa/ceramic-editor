package editor.ui.element;

class MonacoEditorView extends View implements Observable {

#if web

    @observe public var content:String = '';

    var iframe:Dynamic = null;

    override function set_x(x:Float):Float {
        if (this.x == x) return x;
        super.set_x(x);
        if (iframe != null)
            iframe.style.left = x + 'px';
        return x;
    }

    override function set_y(y:Float):Float {
        if (this.y == y) return y;
        super.set_y(y);
        if (iframe != null)
            iframe.style.left = y + 'px';
        return y;
    }

    public function new() {

        super();

        transparent = true;
        onPointerDown(this, _ -> {});

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

            iframe.contentWindow.initMonaco(content, extraLibs, editorLog, handleChange);
        });

    }

    function editorLog(message:String) {

        log.info(message);

    }

    function handleChange(lines:Array<String>) {

        content = lines.join('\n');

        trace('CHANGE $content');

    }

    override function layout() {

        if (iframe == null)
            createIframe();

        iframe.setAttribute('width', '' + width);
        iframe.setAttribute('height', '' + height);

    }

#end

}