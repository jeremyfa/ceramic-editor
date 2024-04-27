package editor.ui;

import ceramic.Pool;
import ceramic.Transform;
import elements.CrossX;
import elements.Im;

class EditorImExtensions {

    static var crossXPool = new Pool<CrossX>();

    // These are a bit hardcoded values, but at least they
    // are located here and don't pollute the rest of the codebase

    public static function beginTwoFieldsRow(im:Class<Im>):Void {

        Im.beginRow();
        Im.flex(510);

    }

    public static function betweenTwoFieldsRow(im:Class<Im>, text:String):Void {

        Im.flex(40);
        Im.text(text);
        Im.flex(510);

    }

    public static function crossX(im:Class<Im>, internalScale:Float = 1):Void {

        var crossX = crossXPool.get();
        if (crossX == null) {
            crossX = new CrossX();
        }
        crossX.active = true;
        crossX.internalScale = internalScale;
        Im.visual(crossX, true, false, false);
        app.onceFinishDraw(crossX, () -> {
            crossX.active = false;
            crossXPool.recycle(crossX);
        });

    }

    public static function sectionTitle(im:Class<Im>, title:String):Void {

        Im.space(-5);
        Im.pointSize(13);
        Im.bold(true);
        Im.text(title, CENTER);
        Im.bold(false);
        Im.pointSize();
        Im.space(-1);

    }

    public static function betweenTwoFieldsCross(im:Class<Im>):Void {

        Im.flex(40);
        final crossScale = 1.0 / 0.37941176470588234;
        crossX(im, crossScale * 0.75);
        Im.flex(510);

    }

    public static function endTwoFieldsRow(im:Class<Im>, ?label:String):Void {

        if (Im.current.scrollable) {
            Im.flex(632);
        }
        else {
            Im.flex(640);
        }
        Im.text(label ?? '');
        Im.endRow();

    }

}
