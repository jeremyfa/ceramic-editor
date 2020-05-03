package editor.utils;

class DropFile extends Entity {

    @event function dropFile(filePath:String);

    public function new() {

        super();

        #if (cpp && linc_sdl)
        app.backend.onSdlEvent(null, function(event) {
            switch event.type {
                default:
                case SDL_DROPFILE:
                    var filePath:String = event.drop.file;
                    if (filePath != null && filePath.trim() != '')
                        emitDropFile(filePath);
            }
        });
        #elseif (web && ceramic_use_electron)
        var ondragover = function(ev:Dynamic) {
            ev.preventDefault();
        };
        var ondrop = function(ev:Dynamic) {
            ev.preventDefault();

            try {
                var filePath:String = ev.dataTransfer.files[0].path;
                if (filePath != null && filePath.trim() != '')
                    emitDropFile(filePath);
            }
            catch (e:Dynamic) {}
        };
        untyped document.addEventListener('dragover', ondragover);
        untyped document.body.ondrop = ondrop;
        #end

    }

}