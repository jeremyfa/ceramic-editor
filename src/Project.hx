package;

import ceramic.Entity;
import ceramic.InitSettings;
import editor.Editor;

class Project extends Entity {

    function new(settings:InitSettings) {

        super();

        settings.title = 'Ceramic Editor';
        settings.antialiasing = 2;
        settings.background = 0x252525;
        settings.targetWidth = 1800;
        settings.targetHeight = 1200;
        settings.scaling = RESIZE;
        settings.resizable = true;

        app.onceReady(this, ready);

    }

    function ready() {

        app.scenes.main = new Editor();

    }

}
