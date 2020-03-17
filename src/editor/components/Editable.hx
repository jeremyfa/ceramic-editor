package editor.components;

import ceramic.Component;
import ceramic.Visual;
import ceramic.Fragment;
import ceramic.Point;
import ceramic.Color;
import ceramic.Quad;
import ceramic.Transform;
import ceramic.TouchInfo;
import ceramic.Shortcuts.*;

import editor.visuals.Highlight;

class Editable extends Entity implements Component {

    @event function select(visual:Visual);

    @event function change(visual:Visual, changed:Dynamic);

    public static var highlight:Highlight;

    static var activeEditable:Editable = null;

    var entity:Visual;

    //var fragment:Fragment;

    var point:Point = { x: 0, y: 0 };

    var xKeyPressed:Bool = false;
    var yKeyPressed:Bool = false;
    var rKeyPressed:Bool = false;
    var wKeyPressed:Bool = false;
    var hKeyPressed:Bool = false;
    var aKeyPressed:Bool = false;
    var shiftPressed:Bool = false;

    function new() {
        
        super();
        //this.fragment = fragment;

    }

    function bindAsComponent() {

        entity.onPointerDown(this, handleDown);

    }

    override function destroy() {

        Utils.printStackTrace();
        log.error('DESTROY EDITABLE COMPONENT');

        super.destroy();

        if (activeEditable == this && highlight != null) {
            highlight.destroy();
        }

    }

/// Public API

    public function select() {

        /*
        editor.send({
            type: 'set/ui.fragmentTab',
            value: 'visuals'
        });
        */

        if (activeEditable == this) return;
        activeEditable = this;
        
        if (highlight != null) {
            highlight.destroy();
        }
        highlight = new Highlight();
        highlight.onceDestroy(this, function(_) {

            highlight.offCornerDown(handleCornerDown);
            highlight.offCornerOver(handleCornerOver);
            highlight.offCornerOut(handleCornerOut);

            if (activeEditable == this) {
                activeEditable = null;

                emitSelect(null);
                // Set selected item
                /*
                editor.send({
                    type: 'set/ui.selectedItemId',
                    value: null
                });
                */
            }
            app.offUpdate(update);
            highlight = null;
        });

        highlight.anchor(0, 0);
        highlight.pos(0, 0);
        highlight.depth = 500;
        highlight.transform = new Transform();
        highlight.wrapVisual(entity);

        highlight.onCornerDown(this, handleCornerDown);
        highlight.onCornerOver(this, handleCornerOver);
        highlight.onCornerOut(this, handleCornerOut);

        app.onUpdate(this, update);

        // Set selected item
        /*
        editor.send({
            type: 'set/ui.selectedItemId',
            value: entity.id
        });
        */
        emitSelect(entity);

    }

    function update(_) {

        if (activeEditable != this) return;

        highlight.wrapVisual(entity);

    }

/// Clicked

    function handleDown(info:TouchInfo) {

        // Ensure this item is selected
        select();

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
            //editor.render();

            parent.screenToVisual(screen.pointerX, screen.pointerY, point);
            entity.x = entityStartX + point.x - dragStartX;
            entity.y = entityStartY + point.y - dragStartY;

        }
        screen.onPointerMove(this, onPointerMove);

        screen.oncePointerUp(this, function(info) {
            //editor.render();

            screen.offPointerMove(onPointerMove);

            entity.x = Math.round(entity.x);
            entity.y = Math.round(entity.y); 

            /*
            // Update pos on react side
            editor.send({
                type: 'set/ui.selectedItem.x',
                value: entity.x
            });
            editor.send({
                type: 'set/ui.selectedItem.y',
                value: entity.y
            });
            */

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

        entity.anchorKeepPosition(tmpAnchorX, tmpAnchorY);

        inline function distanceMain() {
            var a = screen.pointerX - cornerPoint.x;
            var b = screen.pointerY - cornerPoint.y;
            return Math.sqrt(a * a + b * b);
        }

        function onPointerMove(info:TouchInfo) {
            //editor.render();
            
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        skewStep *= 0.6;
                    }
                }

                // Snap to `common` skews?
                if (shiftPressed) {
                    entity.skewX = Math.round(entity.skewX / 22.5) * 22.5;
                    highlight.wrapVisual(entity);
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        skewStep *= 0.6;
                    }
                }

                // Snap to `common` skews?
                if (shiftPressed) {
                    entity.skewY = Math.round(entity.skewY / 22.5) * 22.5;
                    highlight.wrapVisual(entity);
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        rotateStep *= 0.6;
                    }
                }

                // Snap to `common` angles?
                if (shiftPressed) {
                    entity.rotation = Math.round(entity.rotation / 22.5) * 22.5;
                    highlight.wrapVisual(entity);
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (shiftPressed) {
                    entity.scaleX = Math.round(entity.scaleX * 10) / 10;
                    highlight.wrapVisual(entity);
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (shiftPressed) {
                    entity.scaleY = Math.round(entity.scaleY * 10) / 10;
                    highlight.wrapVisual(entity);
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
                        highlight.wrapVisual(entity);

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
                    highlight.wrapVisual(entity);

                    if (best == -1) {
                        scaleStep *= 0.9;
                    }
                }

                // Round scales?
                if (shiftPressed) {
                    entity.scaleX = Math.round(entity.scaleX * 10) / 10;
                    entity.scaleY = Math.round(entity.scaleY * 10) / 10;
                    highlight.wrapVisual(entity);
                }

                // Keep aspect ratio?
                if (aKeyPressed) {
                    var bestScaleX = entity.scaleX;
                    entity.scaleX = bestScaleX;
                    entity.scaleY = bestScaleX * scaleRatio;
                    highlight.wrapVisual(entity);
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

            log.debug('SEND VISUAL CHANGE');

            emitChange(entity, {
                x: entity.x,
                y: entity.y,
                scaleX: entity.scaleX,
                scaleY: entity.scaleY,
                skewX: entity.skewX,
                skewY: entity.skewY,
                rotation: entity.rotation
            });

            /*
            // Update pos & scale on react side
            editor.send({
                type: 'set/ui.selectedItem.x',
                value: entity.x
            });
            editor.send({
                type: 'set/ui.selectedItem.y',
                value: entity.y
            });
            editor.send({
                type: 'set/ui.selectedItem.scaleX',
                value: entity.scaleX
            });
            editor.send({
                type: 'set/ui.selectedItem.scaleY',
                value: entity.scaleY
            });
            editor.send({
                type: 'set/ui.selectedItem.skewX',
                value: entity.skewX
            });
            editor.send({
                type: 'set/ui.selectedItem.skewY',
                value: entity.skewY
            });
            editor.send({
                type: 'set/ui.selectedItem.rotation',
                value: entity.rotation
            });
            */

        });

    }

    function handleCornerOver(corner:HighlightCorner, info:TouchInfo) {

        //

    }

    function handleCornerOut(corner:HighlightCorner, info:TouchInfo) {

        //

    }

}
