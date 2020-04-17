package;

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

import editor.ui.form.SelectFieldView;

/** Minimal project to bootstrap default ceramic editor canvas. */
class Project {

    function new(settings:InitSettings) {

        #if luxe
        Luxe.core.update_rate = 1.0 / 30;
        #end

        #if editor
        new Editor(settings, {
            //assets: DefinesMacro.getDefine('assets_path')
            assets: '/Users/jeremyfa/Developer/clicktube/assets'
        });
        #end

        app.onceReady(null, ready);

    }

    function ready() { 

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
