package;

import ceramic.Entity;
import ceramic.InitSettings;
import editor.Editor;

class Project extends Entity {

    function new(settings:InitSettings) {

        super();

        settings.title = 'Ceramic Editor';
        settings.antialiasing = 2;
        settings.background = 0x000000;
        settings.targetWidth = 1280;
        settings.targetHeight = 800;
        settings.scaling = FIT;
        settings.resizable = true;

        app.onceReady(this, ready);

    }

    function ready() {

        app.scenes.main = new Editor();

    }

}
