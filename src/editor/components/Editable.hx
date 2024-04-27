package editor.components;

import ceramic.Component;
import ceramic.Entity;
import ceramic.KeyCode;
import ceramic.Point;
import ceramic.Shortcuts.*;
import ceramic.TouchInfo;
import ceramic.Transform;
import ceramic.Visual;
import editor.visuals.Highlight;
import tracker.Observable;

using ceramic.Extensions;

class Editable extends Entity implements Component implements Observable {

    @:noCompletion public static var canSkipRender:Bool = false;

    static var _point:Point = new Point(0, 0);

    @event function select(visual:Visual, selectFromPointer:Bool);

    @event function change(visual:Visual, changed:Dynamic);

    public static var highlight:Highlight;

    static var activeEditable:Editable = null;

    var entity:Visual;

    var entityOptions:EditableOptions = {}; // TODO

    var point:Point = { x: 0, y: 0 };

    var xKeyPressed:Bool = false;
    var yKeyPressed:Bool = false;
    var rKeyPressed:Bool = false;
    var wKeyPressed:Bool = false;
    var hKeyPressed:Bool = false;
    var aKeyPressed:Bool = false;
    var sKeyPressed:Bool = false;
    var leftShiftPressed:Bool = false;
    var rightShiftPressed:Bool = false;

    @observe var shiftPressed:Bool = false;

    public function new() {

        super();

    }

    function bindAsComponent() {

        entity.onPointerDown(this, handleDown);

        bindKeyboard();

    }

    override function destroy() {

        super.destroy();

        if (activeEditable == this && highlight != null) {
            highlight.destroy();
        }

    }

    function update(_) {

        if (activeEditable != this) return;

        wrapVisual(entity);

    }

/// Public API

    public function select(selectFromPointer:Bool = false) {

        if (activeEditable == this) return;
        activeEditable = this;

        if (highlight != null) {
            highlight.destroy();
        }
        highlight = new Highlight();
        highlight.onceDestroy(this, function(_) {

            highlight.offCornerDown(handleCornerDown);

            if (activeEditable == this) {
                activeEditable = null;

                emitSelect(null, false);
            }
            app.offUpdate(update);
            highlight = null;
        });

        if (entityOptions.highlightMaxPoints != entityOptions.highlightMinPoints) {
            highlight.needsPointSegments = true;
        }

        highlight.anchor(0, 0);
        highlight.pos(0, 0);
        highlight.transform = new Transform();
        wrapVisual(entity);

        highlight.onCornerDown(this, handleCornerDown);

        if (entityOptions.highlightPoints != null) {
            highlight.bordersActive = false;
            highlight.cornersActive = false;

            highlight.onPointHandleDown(this, handlePointHandleDown);
            highlight.onPointSegmentsOver(this, handlePointSegmentsOver);
            highlight.onPointSegmentsOut(this, handlePointSegmentsOut);
            highlight.onPointSegmentsDown(this, handlePendingPointHandleDown);
            highlight.onPendingPointHandleDown(this, handlePendingPointHandleDown);
            onShiftPressedChange(highlight, handleShiftPressedChange);
        }

        highlight.depth = 1;

        var editor:Editor = cast app.scenes.main;
        editor.fragmentView.overlay.add(highlight);

        app.onUpdate(this, update);

        // Set selected item
        emitSelect(entity, selectFromPointer);

    }

    public function deselect():Void {

        if (activeEditable != this) return;

        activeEditable = null;
        if (highlight != null) {
            highlight.destroy();
        }

    }

    public function syncVisual():Void {

        if (activeEditable != this) return;

        wrapVisual(entity);

    }

/// Keyboard

    function bindKeyboard() {

        // Keyboard events
        input.onKeyDown(this, function(key) {

            if (key.keyCode == KeyCode.LSHIFT) {
                leftShiftPressed = true;
            }
            else if (key.keyCode == KeyCode.RSHIFT) {
                rightShiftPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_R) {
                rKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_A) {
                aKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_X) {
                xKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_Y) {
                yKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_W) {
                wKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_H) {
                hKeyPressed = true;
            }
            else if (key.keyCode == KeyCode.KEY_S) {
                sKeyPressed = true;
            }

            shiftPressed = leftShiftPressed || rightShiftPressed;

        });

        input.onKeyUp(this, function(key) {

            if (key.keyCode == KeyCode.LSHIFT) {
                leftShiftPressed = false;
            }
            else if (key.keyCode == KeyCode.RSHIFT) {
                rightShiftPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_R) {
                rKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_A) {
                aKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_X) {
                xKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_Y) {
                yKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_W) {
                wKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_H) {
                hKeyPressed = false;
            }
            else if (key.keyCode == KeyCode.KEY_S) {
                sKeyPressed = false;
            }

            shiftPressed = leftShiftPressed || rightShiftPressed;

        });

    }

/// Clicked

    function handleDown(info:TouchInfo) {

        // Ensure this item is selected
        select(true);

        // Start dragging
        var parent = entity.parent;
        if (parent == null) {
            log.warning('Skip pointer down event because entity has no parent');
            return;
        }

        var entityStartX = entity.x;
        var entityStartY = entity.y;
        parent.screenToVisual(screen.pointerX, screen.pointerY, point);
        var dragStartX = point.x;
        var dragStartY = point.y;

        function onPointerMove(info:TouchInfo) {

            parent.screenToVisual(screen.pointerX, screen.pointerY, point);
            entity.x = entityStartX + point.x - dragStartX;
            entity.y = entityStartY + point.y - dragStartY;

        }
        screen.onPointerMove(this, onPointerMove);

        screen.oncePointerUp(this, function(info) {

            screen.offPointerMove(onPointerMove);

            entity.x = Math.round(entity.x);
            entity.y = Math.round(entity.y);

            emitChange(entity, {
                x: entity.x,
                y: entity.y
            });

        });

    }

/// Corner clicked

    function handleCornerDown(corner:HighlightCorner, info:TouchInfo) {

        var cornerPoint = switch (corner) {
            case TOP_LEFT: highlight.pointTopLeft;
            case TOP_RIGHT: highlight.pointTopRight;
            case BOTTOM_LEFT: highlight.pointBottomLeft;
            case BOTTOM_RIGHT: highlight.pointBottomRight;
        }

        var scaleTests = [
            [1, -1],
            [1, 0],
            [1, 1],
            [0, 1],
            [0, -1],
            [-1, -1],
            [-1, 0],
            [-1, 1]
        ];
        var resizeTests = scaleTests;
        var rotateTests = [
            1,
            0,
            -1
        ];
        var skewTests = [
            1,
            0,
            -1
        ];
        var singleScaleTests = [
            1,
            -1
        ];

        var anchorX = entity.anchorX;
        var anchorY = entity.anchorY;
        var tmpAnchorX = anchorX;
        var tmpAnchorY = anchorY;

        if (anchorX < 0.01 || anchorX > 0.99) {
            tmpAnchorX = switch (corner) {
                case TOP_LEFT: 1;
                case TOP_RIGHT: 0;
                case BOTTOM_LEFT: 1;
                case BOTTOM_RIGHT: 0;
            }
        }

        if (anchorY < 0.01 || anchorY > 0.99) {
            tmpAnchorY = switch (corner) {
                case TOP_LEFT: 1;
                case TOP_RIGHT: 1;
                case BOTTOM_LEFT: 0;
                case BOTTOM_RIGHT: 0;
            }
        }

        var scaleRatio = entity.scaleY / entity.scaleX;
        var startRotation = entity.rotation;
        var startScaleX = entity.scaleX;
        var startScaleY = entity.scaleY;
        var startSkewX = entity.skewX;
        var startSkewY = entity.skewY;

        var startWidth = entity.width;
        var startHeight = entity.height;

        var resizeInsteadOfScale = false;
        if (entityOptions.highlightResizeInsteadOfScale) {
            resizeInsteadOfScale = true;
        }
        else if (entityOptions.highlightResizeInsteadOfScaleIfNull != null) {
            resizeInsteadOfScale = Reflect.getProperty(entity, entityOptions.highlightResizeInsteadOfScaleIfNull) == null;
        }
        else if (entityOptions.highlightResizeInsteadOfScaleIfTrue != null) {
            resizeInsteadOfScale = Reflect.getProperty(entity, entityOptions.highlightResizeInsteadOfScaleIfTrue) == true;
        }

        entity.anchorKeepPosition(tmpAnchorX, tmpAnchorY);

        inline function distanceMain() {
            highlight.visualToScreen(cornerPoint.x, cornerPoint.y, _point);
            var a = screen.pointerX - _point.x;
            var b = screen.pointerY - _point.y;
            return Math.sqrt(a * a + b * b);
        }

        function onPointerMove(info:TouchInfo) {

            if (xKeyPressed) {
                // Skew
                var skewStep = 0.5;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.scaleX = startScaleX;
                entity.scaleY = startScaleY;
                entity.rotation = startRotation;
                entity.skewY = startSkewY;
                if (resizeInsteadOfScale) {
                    entity.width = startWidth;
                    entity.height = startHeight;
                }

                while (n++ < 100) {

                    // Skew the visual to make the corner point closer
                    var skewX = entity.skewX;
                    var bestSkewX = skewX;
                    var bestDistance = distanceMain();

                    for (i in 0...skewTests.length) {
                        var test = skewTests[i];

                        var newSkewX = skewX + switch(test) {
                            case 1: skewStep;
                            case -1: -skewStep;
                            default: 0;
                        }

                        entity.skewX = newSkewX;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestSkewX = entity.skewX;
                        }
                    }

                    // Apply best transform
                    entity.skewX = bestSkewX;
                    wrapVisual(entity);

                    if (best == -1) {
                        skewStep *= 0.6;
                    }
                }

                // Snap to `common` skews?
                if (sKeyPressed) {
                    entity.skewX = Math.round(entity.skewX / 22.5) * 22.5;
                    wrapVisual(entity);
                }
            }
            else if (yKeyPressed) {
                // Skew
                var skewStep = 0.5;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.scaleX = startScaleX;
                entity.scaleY = startScaleY;
                entity.rotation = startRotation;
                entity.skewX = startSkewX;
                if (resizeInsteadOfScale) {
                    entity.width = startWidth;
                    entity.height = startHeight;
                }

                while (n++ < 100) {

                    // Skew the visual to make the corner point closer
                    var skewY = entity.skewY;
                    var bestSkewY = skewY;
                    var bestDistance = distanceMain();

                    for (i in 0...skewTests.length) {
                        var test = skewTests[i];

                        var newSkewY = skewY + switch(test) {
                            case 1: skewStep;
                            case -1: -skewStep;
                            default: 0;
                        }

                        entity.skewY = newSkewY;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestSkewY = entity.skewY;
                        }
                    }

                    // Apply best transform
                    entity.skewY = bestSkewY;
                    wrapVisual(entity);

                    if (best == -1) {
                        skewStep *= 0.6;
                    }
                }

                // Snap to `common` skews?
                if (sKeyPressed) {
                    entity.skewY = Math.round(entity.skewY / 22.5) * 22.5;
                    wrapVisual(entity);
                }
            }
            else if (rKeyPressed) {
                // Rotate
                var rotateStep = 0.5;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.scaleX = startScaleX;
                entity.scaleY = startScaleY;
                entity.skewX = startSkewX;
                entity.skewY = startSkewY;
                if (resizeInsteadOfScale) {
                    entity.width = startWidth;
                    entity.height = startHeight;
                }

                while (n++ < 100) {

                    // Rotate the visual to make the corner point closer
                    var rotation = entity.rotation;
                    var bestRotation = rotation;
                    var bestDistance = distanceMain();

                    for (i in 0...rotateTests.length) {
                        var test = rotateTests[i];

                        var newRotation = rotation + switch(test) {
                            case 1: rotateStep;
                            case -1: -rotateStep;
                            default: 0;
                        }

                        entity.rotation = newRotation;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestRotation = entity.rotation;
                        }
                    }

                    // Apply best transform
                    entity.rotation = bestRotation;
                    wrapVisual(entity);

                    if (best == -1) {
                        rotateStep *= 0.6;
                    }
                }

                // Snap to `common` angles?
                if (sKeyPressed) {
                    entity.rotation = Math.round(entity.rotation / 22.5) * 22.5;
                    wrapVisual(entity);
                }
            }
            else if (wKeyPressed) {
                // Scale
                var scaleStep = 0.1;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.rotation = startRotation;
                entity.skewX = startSkewX;
                entity.skewY = startSkewY;
                entity.scaleY = startScaleY;
                if (resizeInsteadOfScale) {
                    entity.height = startHeight;
                }

                while (n++ < 100) {

                    // Scale the visual to make the corner point closer
                    best = -1;
                    var scaleX = entity.scaleX;
                    var bestScaleX = scaleX;
                    var bestDistance = distanceMain();

                    for (i in 0...singleScaleTests.length) {
                        var test = singleScaleTests[i];

                        var newScaleX = scaleX + switch(test) {
                            case 1: scaleStep;
                            case -1: -scaleStep;
                            default: 0;
                        }

                        entity.scaleX = newScaleX;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestScaleX = entity.scaleX;
                        }
                    }

                    // Apply best transform
                    entity.scaleX = bestScaleX;
                    wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (sKeyPressed) {
                    entity.scaleX = Math.round(entity.scaleX * 10) / 10;
                    wrapVisual(entity);
                }

            }
            else if (hKeyPressed) {
                // Scale
                var scaleStep = 0.1;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.rotation = startRotation;
                entity.skewX = startSkewX;
                entity.skewY = startSkewY;
                entity.scaleX = startScaleX;
                if (resizeInsteadOfScale) {
                    entity.width = startWidth;
                }

                while (n++ < 100) {

                    // Scale the visual to make the corner point closer
                    best = -1;
                    var scaleY = entity.scaleY;
                    var bestScaleY = scaleY;
                    var bestDistance = distanceMain();

                    for (i in 0...singleScaleTests.length) {
                        var test = singleScaleTests[i];

                        var newScaleY = scaleY + switch(test) {
                            case 1: scaleStep;
                            case -1: -scaleStep;
                            default: 0;
                        }

                        entity.scaleY = newScaleY;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestScaleY = entity.scaleY;
                        }
                    }

                    // Apply best transform
                    entity.scaleY = bestScaleY;
                    wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (sKeyPressed) {
                    entity.scaleY = Math.round(entity.scaleY * 10) / 10;
                    wrapVisual(entity);
                }

            }
            else if (resizeInsteadOfScale) {
                // Size
                var sizeStep = 16.0;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.rotation = startRotation;
                entity.skewX = startSkewX;
                entity.skewY = startSkewY;

                while (n++ < 100) {

                    // Scale the visual to make the corner point closer
                    best = -1;
                    var width = entity.width;
                    var height = entity.height;
                    var bestWidth = width;
                    var bestHeight = height;
                    var bestDistance = distanceMain();

                    for (i in 0...resizeTests.length) {
                        var test = resizeTests[i];

                        var newWidth = width + switch(test[0]) {
                            case 1: sizeStep;
                            case -1: -sizeStep;
                            default: 0;
                        }
                        var newHeight = height + switch(test[1]) {
                            case 1: sizeStep;
                            case -1: -sizeStep;
                            default: 0;
                        }

                        entity.width = newWidth;
                        entity.height = newHeight;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestWidth = entity.width;
                            bestHeight = entity.height;
                        }
                    }

                    // Apply best transform
                    entity.width = bestWidth;
                    entity.height = bestHeight;
                    wrapVisual(entity);

                    if (best == -1) {
                        sizeStep *= 0.9;
                    }
                }

                // Round size?
                if (sKeyPressed) {
                    entity.width = Math.round(entity.width / 10) * 10;
                    entity.height = Math.round(entity.height / 10) * 10;
                    wrapVisual(entity);
                }

                // Keep aspect ratio?
                if (shiftPressed && startWidth != 0) {
                    var bestWidth = entity.width;
                    entity.width = bestWidth;
                    entity.height = (bestWidth / startWidth) * startHeight;
                    wrapVisual(entity);
                }
            }
            else {
                // Scale
                var scaleStep = 0.1;
                var n = 0;
                var best = -1;

                // Put other values as started
                entity.rotation = startRotation;
                entity.skewX = startSkewX;
                entity.skewY = startSkewY;

                while (n++ < 100) {

                    // Scale the visual to make the corner point closer
                    best = -1;
                    var scaleX = entity.scaleX;
                    var scaleY = entity.scaleY;
                    var bestScaleX = scaleX;
                    var bestScaleY = scaleY;
                    var bestDistance = distanceMain();

                    for (i in 0...scaleTests.length) {
                        var test = scaleTests[i];

                        var newScaleX = scaleX + switch(test[0]) {
                            case 1: scaleStep;
                            case -1: -scaleStep;
                            default: 0;
                        }
                        var newScaleY = scaleY + switch(test[1]) {
                            case 1: scaleStep;
                            case -1: -scaleStep;
                            default: 0;
                        }

                        entity.scaleX = newScaleX;
                        entity.scaleY = newScaleY;
                        wrapVisual(entity);

                        // Is it better?
                        var dist = distanceMain();
                        if (dist < bestDistance) {
                            bestDistance = dist;
                            best = i;
                            bestScaleX = entity.scaleX;
                            bestScaleY = entity.scaleY;
                        }
                    }

                    // Apply best transform
                    entity.scaleX = bestScaleX;
                    entity.scaleY = bestScaleY;
                    wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (sKeyPressed) {
                    entity.scaleX = Math.round(entity.scaleX * 10) / 10;
                    entity.scaleY = Math.round(entity.scaleY * 10) / 10;
                    wrapVisual(entity);
                }

                // Keep aspect ratio?
                if (shiftPressed) {
                    var bestScaleX = entity.scaleX;
                    entity.scaleX = bestScaleX;
                    entity.scaleY = bestScaleX * scaleRatio;
                    wrapVisual(entity);
                }
            }

        }
        screen.onPointerMove(this, onPointerMove);

        screen.oncePointerUp(this, function(info) {
            //editor.render();

            screen.offPointerMove(onPointerMove);

            entity.anchorKeepPosition(anchorX, anchorY);
            entity.x = Math.round(entity.x);
            entity.y = Math.round(entity.y);
            entity.scaleX = Math.round(entity.scaleX * 1000) / 1000.0;
            entity.scaleY = Math.round(entity.scaleY * 1000) / 1000.0;
            if (resizeInsteadOfScale) {
                entity.width = Math.round(entity.width);
                entity.height = Math.round(entity.height);
            }
            var skewX = entity.skewX;
            while (skewX <= -360) skewX += 360;
            while (skewX >= 360) skewX -= 360;
            entity.skewX = Math.round(skewX * 100) / 100.0;
            var skewY = entity.skewY;
            while (skewY <= -360) skewY += 360;
            while (skewY >= 360) skewY -= 360;
            entity.skewY = Math.round(skewY * 100) / 100.0;
            var rotation = entity.rotation;
            while (rotation <= -360) rotation += 360;
            while (rotation >= 360) rotation -= 360;
            entity.rotation = Math.round(rotation * 100) / 100.0;

            if (resizeInsteadOfScale) {
                emitChange(entity, {
                    x: entity.x,
                    y: entity.y,
                    width: entity.width,
                    height: entity.height,
                    skewX: entity.skewX,
                    skewY: entity.skewY,
                    rotation: entity.rotation
                });
            }
            else {
                emitChange(entity, {
                    x: entity.x,
                    y: entity.y,
                    scaleX: entity.scaleX,
                    scaleY: entity.scaleY,
                    skewX: entity.skewX,
                    skewY: entity.skewY,
                    rotation: entity.rotation
                });
            }

        });

    }

    function handlePointHandleDown(index:Int, info:TouchInfo) {

        var points:Array<Float> = null;

        var options = entityOptions;
        if (options != null) {
            if (options.highlightPoints != null) {
                points = entity.getProperty(options.highlightPoints);
            }
        }

        if (points == null) {
            log.error('Invalid points property!');
            return;
        }

        var didChangePoints = false;

        var translateTests = [
            -1, -1,
            -1, 0,
            -1, 1,
            0, -1,
            0, 1,
            1, -1,
            1, 0,
            1, 1
        ];

        if (shiftPressed) {
            if (options != null) {
                if (options.highlightMinPoints >= 0) {
                    points = entity.getProperty(options.highlightPoints);

                    // Reached min number of points?
                    if (points.length <= 0 || points.length <= options.highlightMinPoints * 2) {
                        log.warning('Cannot remove point!');
                    }
                    else {
                        var copy = [].concat(points);
                        copy.splice(index * 2, 2);
                        entity.setProperty(options.highlightPoints, copy);
                        applyPointChanges();
                    }
                }
            }
            return;
        }

        var originalPoints:Array<Float> = [].concat(points);

        var pointStartX = points[index * 2];
        var pointStartY = points[index * 2 + 1];
        entity.visualToScreen(pointStartX, pointStartY, _point);
        var pointStartScreenX = _point.x;
        var pointStartScreenY = _point.y;
        var startX = info.x;
        var startY = info.y;

        wrapVisual(entity);

        inline function distanceMain() {
            var handle = highlight.pointHandles[index];
            highlight.visualToScreen(handle.x, handle.y, _point);
            var a = screen.pointerX - _point.x;
            var b = screen.pointerY - _point.y;
            return Math.sqrt(a * a + b * b);
        }

        function onPointerMove(info:TouchInfo) {

            points = entity.getProperty(options.highlightPoints);

            if (!didChangePoints) {
                didChangePoints = true;
                points = [].concat(points);
                entity.setProperty(options.highlightPoints, points);
            }

            canSkipRender = true;

            var moveStep = 16.0;
            var n = 0;
            var best = -1;

            while (n++ < 100) {

                for (j in 0...points.length) {
                    originalPoints[j] = points[j];
                }

                best = -1;
                var pointX = points[index * 2];
                var pointY = points[index * 2 + 1];
                var bestDistance = distanceMain();
                var bestPointX = pointX;
                var bestPointY = pointY;

                var i = 0;
                while (i * 2 < translateTests.length) {
                    var testX = translateTests[i * 2] * moveStep;
                    var testY = translateTests[i * 2 + 1] * moveStep;

                    for (j in 0...originalPoints.length) {
                        points[j] = originalPoints[j];
                    }

                    points[index * 2] = pointX + testX;
                    points[index * 2 + 1] = pointY + testY;
                    entity.contentDirty = true;
                    entity.computeContent();
                    wrapVisual(entity);

                    // Is it better?
                    var dist = distanceMain();
                    if (dist < bestDistance) {
                        bestDistance = dist;
                        best = i;
                        bestPointX = points[index * 2];
                        bestPointY = points[index * 2 + 1];
                    }

                    i++;
                }

                // Apply best transform
                points[index * 2] = Math.round(bestPointX * 1000) / 1000;
                points[index * 2 + 1] = Math.round(bestPointY * 1000) / 1000;
                entity.contentDirty = true;
                entity.computeContent();
                wrapVisual(entity);

                if (best == -1) {
                    moveStep *= 0.5;
                }
            }

            canSkipRender = false;
            entity.contentDirty = true;
            entity.computeContent();
            wrapVisual(entity);

        }

        screen.onPointerMove(this, onPointerMove);
        screen.oncePointerUp(this, function(info) {
            points = entity.getProperty(options.highlightPoints);

            screen.offPointerMove(onPointerMove);

            applyPointChanges();
        });

    }

    function applyPointChanges() {

        var points:Array<Float> = null;

        var options = entityOptions;
        if (options != null) {
            if (options.highlightPoints != null) {
                points = entity.getProperty(options.highlightPoints);
            }
        }

        if (points == null) {
            log.error('Invalid points property!');
            return;
        }

        // Adjust points?
        if (options.highlightMovePointsToZero) {
            var minX = 999999999.0;
            var minY = 999999999.0;
            var i = 0;
            while (i * 2 < points.length) {
                var pointX = points[i * 2];
                var pointY = points[i * 2 + 1];

                if (pointX < minX)
                    minX = pointX;

                if (pointY < minY)
                    minY = pointY;

                i++;
            }

            if (minX == 999999999.0)
                minX = 0;

            if (minY == 999999999.0)
                minY = 0;

            if (minX != 0 || minY != 0) {
                i = 0;
                while (i * 2 < points.length) {
                    var pointX = points[i * 2];
                    var pointY = points[i * 2 + 1];
                    points[i * 2] = Math.round((pointX - minX) * 1000) / 1000;
                    points[i * 2 + 1] = Math.round((pointY - minY) * 1000) / 1000;

                    i++;
                }
            }
        }

        entity.setProperty(options.highlightPoints, [].concat(entity.getProperty(options.highlightPoints)));
        entity.contentDirty = true;
        entity.computeContent();
        wrapVisual(entity);

        var changes:Dynamic = {
            x: entity.x,
            y: entity.y,
            width: entity.width,
            height: entity.height
        };
        Reflect.setField(changes, options.highlightPoints, entity.getProperty(options.highlightPoints));

        //log.debug('EMIT CHANGES ${entity.getProperty(options.highlightPoints).length}');
        emitChange(entity, changes);

    }

    var pointerBetweenPointHandles:Bool = false;

    var insertPointAtIndex:Int = -1;

    function handlePointSegmentsOver(info:TouchInfo) {

        pointerBetweenPointHandles = true;
        if (shiftPressed)
            highlightBetweenHandles(true);

        screen.onPointerMove(this, handlePointSegmentsMove);

    }

    function handlePointSegmentsOut(info:TouchInfo):Void {

        screen.offPointerMove(handlePointSegmentsMove);
        pointerBetweenPointHandles = false;
        highlightBetweenHandles(false);

    }

    function handlePointSegmentsMove(info:TouchInfo) {

        highlightBetweenHandles(shiftPressed && pointerBetweenPointHandles);

    }

    function handlePendingPointHandleDown(info:TouchInfo) {

        var points:Array<Float> = null;
        var options = entityOptions;
        if (options != null) {
            if (options.highlightPoints != null) {
                points = entity.getProperty(options.highlightPoints);
            }
        }

        if (points == null) {
            log.error('Invalid points property!');
            return;
        }

        if (shiftPressed && pointerBetweenPointHandles && insertPointAtIndex != -1) {
            var copy:Array<Float> = [];
            var i = 0;
            while (i <= insertPointAtIndex) {
                copy.push(points[i * 2]);
                copy.push(points[i * 2 + 1]);
                i++;
            }
            highlight.visualToScreen(highlight.pendingPointHandleX, highlight.pendingPointHandleY, _point);
            entity.screenToVisual(_point.x, _point.y, _point);
            copy.push(Math.round(_point.x * 1000) / 1000);
            copy.push(Math.round(_point.y * 1000) / 1000);
            var n = i * 2;
            while (n < points.length) {
                copy.push(points[n]);
                n++;
            }

            entity.setProperty(options.highlightPoints, copy);
            applyPointChanges();
        }

    }

    function handleShiftPressedChange(pressed:Bool, wasPressed:Bool):Void {

        if (highlight.pointSegments != null) {
            highlight.pointSegments.touchable = pressed;
        }

        if (pointerBetweenPointHandles && pressed)
            highlightBetweenHandles(true);
        else
            highlightBetweenHandles(false);

    }

    function highlightBetweenHandles(doHighlight:Bool):Void {

        if (highlight == null)
            return;

        var options = entityOptions;
        if (options != null) {
            if (options.highlightMaxPoints >= 0) {
                var points:Array<Float> = entity.getProperty(options.highlightPoints);
                if (points == null) {
                    log.error('Invalid points property!');
                    return;
                }

                // Reached max number of points?
                if (points.length >= options.highlightMaxPoints * 2)
                    doHighlight = false;
            }
            else {
                // Adding points is forbidden
                doHighlight = false;
            }
        }
        else
            return;

        // Source: https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
        inline function sqr(x:Float):Float {
            return x * x;
        }
        inline function dist2(vx:Float, vy:Float, wx:Float, wy:Float):Float {
            return sqr(vx - wx) + sqr(vy - wy);
        }
        function segmentDist(px:Float, py:Float, vx:Float, vy:Float, wx:Float, wy:Float):Float {
          var l2 = dist2(vx, vy, wx, wy);
          if (l2 == 0) return dist2(px, py, vx, vy);
          var t = ((px - vx) * (wx - vx) + (py - vy) * (wy - vy)) / l2;
          t = Math.max(0, Math.min(1, t));
          return dist2(px, py, vx + t * (wx - vx), vy + t * (wy - vy));
        }

        var pointHandles = highlight.pointHandles;
        if (doHighlight && pointHandles != null && pointHandles.length >= 2) {
            highlight.screenToVisual(screen.pointerX, screen.pointerY, _point);
            var bestIndex = -1;
            var bestDistance:Float = 999999999;
            for (i in 0...pointHandles.length) {
                var handle0 = pointHandles[i];
                var handle1 = pointHandles[i == pointHandles.length - 1 ? 0 : i + 1];
                var dist = segmentDist(_point.x, _point.y, handle0.x, handle0.y, handle1.x, handle1.y);
                if (bestDistance >= dist) {
                    bestDistance = dist;
                    bestIndex = i;
                }
            }
            if (bestIndex != -1) {
                insertPointAtIndex = bestIndex;
                var handle0 = pointHandles[bestIndex];
                var handle1 = pointHandles[bestIndex == pointHandles.length - 1 ? 0 : bestIndex + 1];
                var distance0 = Math.abs(_point.x - handle0.x);
                var distance1 = Math.abs(_point.x - handle1.x);
                if (Math.abs(handle0.y - handle1.y) > Math.abs(handle0.x - handle1.x)) {
                    distance0 = Math.abs(_point.y - handle0.y);
                    distance1 = Math.abs(_point.y - handle1.y);
                }
                highlight.pendingPointHandleX = (handle0.x * distance1 + handle1.x * distance0) / (distance0 + distance1);
                highlight.pendingPointHandleY = (handle0.y * distance1 + handle1.y * distance0) / (distance0 + distance1);
                highlight.pendingPointHandleActive = true;
            }
            else {
                highlight.pendingPointHandleActive = false;
            }
        }
        else {
            highlight.pendingPointHandleActive = false;
        }

    }

    function wrapVisual(visual:Visual) {

        if (highlight != null) {
            highlight.wrapVisual(visual);

            var options = entityOptions;
            if (options != null) {
                if (options.highlightPoints != null) {
                    var points:Array<Float> = visual.getProperty(options.highlightPoints);
                    highlight.wrapPoints(points);
                    if (highlight.pointSegments != null) {
                        highlight.pointSegments.touchable = shiftPressed;
                    }
                }
            }
        }

    }

}
