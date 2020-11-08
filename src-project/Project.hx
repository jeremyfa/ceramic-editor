package;

#if !macro
import ceramic.AllApi;
#end

import ceramic.Dialogs;
import ceramic.macros.DefinesMacro;
import ceramic.ImageAsset;
import ceramic.Assets;
import tracker.Model;

import ceramic.Line;
import ceramic.Shape;
import ceramic.Color;
import ceramic.AlphaColor;
import ceramic.Mesh;
import ceramic.Timer;
import ceramic.InitSettings;
import ceramic.Shortcuts.*;
import editor.Editor;

import ceramic.Shape;

import editor.ui.form.SelectFieldView;

/** Minimal project to bootstrap default ceramic editor canvas. */
class Project {

    function new(settings:InitSettings) {

        var webWithoutElectron = false;
        #if web
        webWithoutElectron = (ceramic.PlatformSpecific.resolveElectron() == null);
        #end
        
        #if editor
        new Editor(settings, {
            #if (cpp || (web && ceramic_use_electron))
            //assets: webWithoutElectron ? null : DefinesMacro.getDefine('assets_path')
            #end
        });
        #end

        app.onceReady(null, ready);

    }

    function ready() {

        /*
        var quad = new ceramic.Quad();
        quad.size(100, 100);
        quad.color = Color.WHITE;
        quad.depth = 9999;
        quad.anchor(0.5, 0.5);
        quad.pos(screen.width * 0.5, screen.height * 0.5);

        var script1 = "
app.onUpdate(self, delta -> {
    entity.rotation = (entity.rotation + delta * 100) % 360;
});
";
        var script2 = "
app.onUpdate(self, delta -> {
    entity.rotation = (entity.rotation - delta * 100) % 360;
});
";

        quad.script = script1;
        Timer.interval(null, 1.5, () -> {
            if (quad.script == script1) {
                quad.script = script2;
            }
            else {
                quad.script = script1;
            }
        });
        */

        /*
        var shape = new Shape();

        shape.points = [
            0, 0,
            100, 15,
            80, 120,
            60, 60
        ]; 
 
        shape.color = Color.RED;

        shape.depth = 999;
        shape.pos(screen.width * 0.5, screen.height * 0.5);
        */

        /*
        var mesh = new Mesh();

        mesh.colorMapping = VERTICES;
        mesh.vertices = [
            0, 0,
            100, 0,
            100, 100,
            0, 100
        ];
        mesh.indices = [
            0, 1, 2,
            0, 2, 3
        ];
        mesh.colors = [
            new AlphaColor(Color.RED),
            new AlphaColor(Color.GREEN),
            new AlphaColor(Color.BLUE),
            new AlphaColor(Color.WHITE)
        ];

        mesh.depth = 999;
        mesh.pos(screen.width * 0.5, screen.height * 0.5);
        */

    }

}
