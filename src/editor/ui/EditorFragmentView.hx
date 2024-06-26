package editor.ui;

import ceramic.Color;
import ceramic.Component;
import ceramic.DecomposedTransform;
import ceramic.MouseButton;
import ceramic.Point;
import ceramic.Quad;
import ceramic.TouchInfo;
import ceramic.Transform;
import ceramic.View;
import ceramic.Visual;
import editor.model.EditorData;
import editor.model.fragment.EditorFragmentData;
import tracker.Observable;

class EditorFragmentView extends View implements Component implements Observable {

    static var _point = new Point();

    static var _decomposed = new DecomposedTransform();

    @compute function fragmentData():EditorFragmentData {
        return editor.model.project.selectedFragment;
    }

    var model(get,never):EditorData;
    inline function get_model():EditorData {
        return editor.model;
    }

    @entity var editor:Editor;

    public var overlay(default, null):Visual;

    public var content(default, null):Quad;

    var fragmentTransform:Transform = new Transform();

    var draggingFragment:Bool = false;

    var dragStartX:Float = 0;

    var dragStartY:Float = 0;

    var fragmentDragStartTransform:Transform = new Transform();

    var shouldResetPosition:Bool = false;

    function bindAsComponent() {

        editor.nativeLayer.add(this);
        customParentView = editor;
        transparent = true;
        depth = 1;

        content = new Quad();
        content.transform = fragmentTransform;
        content.depth = 1;
        content.clip = content;
        add(content);

        overlay = new Visual();
        overlay.transform = fragmentTransform;
        overlay.depth = 2;
        add(overlay);

        onPointerDown(this, handlePointerDown);
        screen.onPointerMove(this, handlePointerMove);
        screen.onMouseWheel(this, handleMouseWheel);

        autorun(updateColor);
        autorun(updateContentSize);
        autorun(updateVisuals);

        onFragmentDataChange(this, (fragmentData, _) -> {
            shouldResetPosition = true;
            layoutDirty = true;
        });

        shouldResetPosition = true;
        layoutDirty = true;

    }

    override function layout() {
        super.layout();

        if (content != null) {
            content.anchor(0.5, 0.5);
            content.pos(width * 0.5, height * 0.5);
        }

        if (editor != null && shouldResetPosition) {
            shouldResetPosition = false;
            resetPosition();
        }
    }

    function resetPosition() {

        final scaleFactor = model.fragmentZoom;
        fragmentTransform.identity();
        fragmentTransform.translate(-width * 0.5, -height * 0.5);
        fragmentTransform.scale(
            scaleFactor,
            scaleFactor
        );
        fragmentTransform.translate(width * 0.5, height * 0.5);

    }

    function updateColor() {

        final fragmentData = this.fragmentData;
        unobserve();

        if (fragmentData == null)
            return;

        reobserve();
        final transparent = fragmentData.transparent;
        unobserve();

        var color:Color = 0x424242;
        if (!transparent) {
            reobserve();
            color = fragmentData.color;
            unobserve();
        }
        content.color = color;

    }

    function updateContentSize() {

        final fragmentData = this.fragmentData;
        unobserve();

        if (fragmentData == null)
            return;

        reobserve();
        final fragmentWidth = fragmentData.width;
        final fragmentHeight = fragmentData.height;
        unobserve();
        content.size(fragmentWidth, fragmentHeight);

    }

    function updateVisuals() {

        final fragmentData = this.fragmentData;
        unobserve();

        if (fragmentData == null)
            return;

        reobserve();
        final visualsData = fragmentData.visuals;
        unobserve();

        // Add new views as needed
        for (visualData in visualsData) {
            if (visualData.view == null) {
                log.debug('add view for fragment visual: ' + visualData.entityId + ' (' + fragmentData.fragmentId + ')');
                visualData.view = new EditorVisualDataView();
                content.add(visualData.view);
            }
        }

        // Remove views that are not needed anymore
        var toMaybeRemove:Array<EditorVisualDataView> = null;
        if (content.children != null) {
            for (child in content.children) {
                if (child is EditorVisualDataView) {
                    if (toMaybeRemove == null) {
                        toMaybeRemove = [];
                    }
                    toMaybeRemove.push(cast child);
                }
            }
        }
        if (toMaybeRemove != null) {
            for (view in toMaybeRemove) {
                final visualData = view.visualData;
                if (visualData.destroyed || visualData.fragment != fragmentData) {
                    log.debug('destroy view for fragment visual: ' + visualData.entityId + ' (' + visualData.fragment.fragmentId + ')');
                    view.destroy();
                }
            }
        }

    }

    function handlePointerDown(info:TouchInfo) {

        if (info.buttonId == MouseButton.RIGHT) {
            // Right click
            draggingFragment = true;
            screenToVisual(info.x, info.y, _point);
            dragStartX = _point.x;
            dragStartY = _point.y;
            fragmentDragStartTransform.setToTransform(fragmentTransform);
            screen.oncePointerUp(this, _ -> {
                draggingFragment = false;
            });
        }
        else if (info.buttonId == MouseButton.MIDDLE) {
            // Middle click
            if (input.keyPressed(LSHIFT) || input.keyPressed(RSHIFT)) {
                fragmentTransform.identity();
            }
            else {
                resetPosition();
            }
        }
        else {
            deselectVisuals();
        }

    }

    function deselectVisuals() {

        final fragmentData = this.fragmentData;
        if (fragmentData == null)
            return;

        fragmentData.deselectVisual();

    }

    function handleMouseWheel(x:Float, y:Float) {

        if (hits(screen.pointerX, screen.pointerY)) {

            screenToVisual(screen.pointerX, screen.pointerY, _point);
            var pointerX = _point.x;
            var pointerY = _point.y;

            var scaleFactor = 1.0;

            if (y > 0) {
                scaleFactor = 1.0 + y * 0.0025;
            }
            else if (y < 0) {
                scaleFactor = 1.0 / (1.0 - y * 0.0025);
            }

            if (scaleFactor != 1.0) {

                fragmentTransform.decompose(_decomposed);
                var prevScale = _decomposed.scaleX;
                var newScale = prevScale * scaleFactor;

                if (newScale < 0.1 || newScale > 100.0)
                    return;

                var tx = pointerX;
                var ty = pointerY;

                fragmentTransform.translate(-tx, -ty);

                fragmentTransform.scale(
                    scaleFactor,
                    scaleFactor
                );

                fragmentTransform.translate(tx, ty);

                model.fragmentZoom = newScale;
            }
        }

    }

    function handlePointerMove(info:TouchInfo) {

        if (!draggingFragment)
            return;

        screenToVisual(info.x, info.y, _point);
        var dragX = _point.x;
        var dragY = _point.y;

        fragmentTransform.tx = fragmentDragStartTransform.tx + dragX - dragStartX;
        fragmentTransform.ty = fragmentDragStartTransform.ty + dragY - dragStartY;
        fragmentTransform.changedDirty = true;

    }

    override function interceptPointerDown(hittingVisual:Visual, x:Float, y:Float, touchIndex:Int, buttonId:Int):Bool {

        if (buttonId == MouseButton.RIGHT || buttonId == MouseButton.MIDDLE) {
            if (hittingVisual == this) {
                // Handle right or middle click
                return false;
            }
            else {
                // Forbid right or middle click on this hitting visual
                return true;
            }
        }

        return false;

    }

}
