package;

import ceramic.InitSettings;
import ceramic.Shortcuts.*;
import editor.Editor;

/** Minimal project to bootstrap default ceramic editor canvas. */
class Project {

    function new(settings:InitSettings) {

        #if luxe
        Luxe.core.update_rate = 1.0 / 30;
        #end

        #if editor
        new Editor(settings);
        #end

    } //new

} //Project
