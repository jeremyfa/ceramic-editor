package;

import ceramic.InitSettings;
import ceramic.Shortcuts.*;
import editor.Editor;

/** Minimal project to bootstrap default ceramic editor canvas. */
class Project {

    function new(settings:InitSettings) {

        #if editor
        new Editor(settings);
        #end

    } //new

} //Project
