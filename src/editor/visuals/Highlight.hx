package editor.visuals;

import ceramic.Visual;
import ceramic.Quad;
import ceramic.Color;
import ceramic.Point;
import ceramic.TouchInfo;
import ceramic.Shortcuts.*;

using ceramic.Extensions;

enum HighlightCorner {
    TOP_LEFT;
    TOP_RIGHT;
    BOTTOM_LEFT;
    BOTTOM_RIGHT;
}

class Highlight extends Visual {

    static var _point:Point = new Point(0, 0);

/// Events

    @event function cornerDown(corner:HighlightCorner, info:TouchInfo);

    @event function cornerOver(corner:HighlightCorner, info:TouchInfo);

    @event function cornerOut(corner:HighlightCorner, info:TouchInfo);

    @event function pointHandleDown(index:Int, info:TouchInfo);

    @event function pointHandleOver(index:Int, info:TouchInfo);

    @event function pointHandleOut(index:Int, info:TouchInfo);

    @event function pointSegmentsDown(info:TouchInfo);

    @event function pointSegmentsOver(info:TouchInfo);

    @event function pointSegmentsOut(info:TouchInfo);

    @event function pendingPointHandleDown(info:TouchInfo);

/// Properties

    public var cornerTopLeft = new View();

    public var cornerTopRight = new View();

    public var cornerBottomLeft = new View();

    public var cornerBottomRight = new View();

    public var anchorCrossVBar = new View();

    public var anchorCrossHBar = new View();

    public var pointHandles:Array<View> = [];

    public var pendingPointHandle:View = null;

    public var pointSegments:Line = null;

    public var topDistance(default,null):Float;

    public var rightDistance(default,null):Float;

    public var bottomDistance(default,null):Float;

    public var leftDistance(default,null):Float;

    var wrappedVisual:Visual = null;

    var wrappedPoints:Array<Float> = null;

    var localPoints:Array<Float> = [];

    var borderTop = new Quad();

    var borderRight = new Quad();

    var borderBottom = new Quad();

    var borderLeft = new Quad();

    public var pointTopLeft(default,null) = new Point();

    public var pointTopRight(default,null) = new Point();

    public var pointBottomLeft(default,null) = new Point();

    public var pointBottomRight(default,null) = new Point();

    public var pointAnchor(default,null) = new Point();

    public var cornerSize(default,set):Float = 8;
    function set_cornerSize(cornerSize:Float):Float {
        if (this.cornerSize == cornerSize) return cornerSize;
        this.cornerSize = cornerSize;
        updateCornersAndBorders();
        return cornerSize;
    }

    public var borderSize(default,set):Float = 1;
    function set_borderSize(borderSize:Float):Float {
        if (this.borderSize == borderSize) return borderSize;
        this.borderSize = borderSize;
        updateCornersAndBorders();
        return borderSize;
    }

    public var crossWidth(default,set):Float = 2;
    function set_crossWidth(crossWidth:Float):Float {
        if (this.crossWidth == crossWidth) return crossWidth;
        this.crossWidth = crossWidth;
        updateCornersAndBorders();
        return crossWidth;
    }

    public var pendingColor(default,set):Color;
    function set_pendingColor(pendingColor:Color):Color {
        this.pendingColor = pendingColor;
        if (pendingPointHandle != null) {
            pendingPointHandle.color = pendingColor;
        }
        return pendingColor;
    }

    public var color(default,set):Color;
    function set_color(color:Color):Color {
        if (this.color == color) return color;
        this.color = color;
        cornerTopLeft.color = color;
        cornerTopRight.color = color;
        cornerBottomLeft.color = color;
        cornerBottomRight.color = color;
        borderTop.color = color;
        borderRight.color = color;
        borderBottom.color = color;
        borderLeft.color = color;
        anchorCrossVBar.color = color;
        anchorCrossHBar.color = color;
        for (i in 0...pointHandles.length) {
            pointHandles[i].color = color;
        }
        return color;
    }

    public var cornersActive(default, set):Bool = true;
    function set_cornersActive(cornersActive:Bool):Bool {
        cornerTopLeft.active = cornersActive;
        cornerTopRight.active = cornersActive;
        cornerBottomLeft.active = cornersActive;
        cornerBottomRight.active = cornersActive;
        return cornersActive;
    }

    public var bordersActive(default, set):Bool = true;
    function set_bordersActive(cornersActive:Bool):Bool {
        borderTop.active = cornersActive;
        borderRight.active = cornersActive;
        borderBottom.active = cornersActive;
        borderLeft.active = cornersActive;
        return cornersActive;
    }

    public var pointHandleSize(default,set):Float = 8;
    function set_pointHandleSize(pointHandleSize:Float):Float {
        if (this.pointHandleSize == pointHandleSize) return pointHandleSize;
        this.pointHandleSize = pointHandleSize;
        updatePointHandles();
        return pointHandleSize;
    }

    public var pendingPointHandleActive(default,set):Bool = false;
    function set_pendingPointHandleActive(pendingPointHandleActive:Bool):Bool {
        if (this.pendingPointHandleActive != pendingPointHandleActive) {
            this.pendingPointHandleActive = pendingPointHandleActive;
            updatePendingPointHandle();
        }
        return pendingPointHandleActive;
    }

    public var pendingPointHandleX(default,set):Float = 0;
    function set_pendingPointHandleX(pendingPointHandleX:Float):Float {
        if (this.pendingPointHandleX != pendingPointHandleX) {
            this.pendingPointHandleX = pendingPointHandleX;
            updatePendingPointHandle();
        }
        return pendingPointHandleX;
    }

    public var pendingPointHandleY(default,set):Float = 0;
    function set_pendingPointHandleY(pendingPointHandleY:Float):Float {
        if (this.pendingPointHandleY != pendingPointHandleY) {
            this.pendingPointHandleY = pendingPointHandleY;
            updatePendingPointHandle();
        }
        return pendingPointHandleY;
    }

/// Lifecycle

    public function new() {

        super();

        depthRange = 0.5;

        cornerTopLeft.depth = 2;
        cornerTopRight.depth = 2;
        cornerBottomLeft.depth = 2;
        cornerBottomRight.depth = 2;

        cornerTopLeft.borderColor = Color.WHITE;
        cornerTopRight.borderColor = Color.WHITE;
        cornerBottomLeft.borderColor = Color.WHITE;
        cornerBottomRight.borderColor = Color.WHITE;

        cornerTopLeft.borderPosition = INSIDE;
        cornerTopRight.borderPosition = INSIDE;
        cornerBottomLeft.borderPosition = INSIDE;
        cornerBottomRight.borderPosition = INSIDE;

        cornerTopLeft.borderSize = 1;
        cornerTopRight.borderSize = 1;
        cornerBottomLeft.borderSize = 1;
        cornerBottomRight.borderSize = 1;

        borderTop.depth = 1.5;
        borderRight.depth = 1.5;
        borderBottom.depth = 1.5;
        borderLeft.depth = 1.5;
        anchorCrossVBar.depth = 1.75;
        anchorCrossHBar.depth = 1.75;

        /*
        anchorCrossVBar.borderRightSize = crossWidth * 0.5;
        anchorCrossVBar.borderPosition = INSIDE;
        anchorCrossVBar.borderRightColor = Color.WHITE;

        anchorCrossHBar.borderTopSize = crossWidth * 0.5;
        anchorCrossHBar.borderPosition = INSIDE;
        anchorCrossHBar.borderTopColor = Color.WHITE;
        */

        add(cornerTopLeft);
        add(cornerTopRight);
        add(cornerBottomLeft);
        add(cornerBottomRight);
        add(borderTop);
        add(borderRight);
        add(borderBottom);
        add(borderLeft);
        add(anchorCrossVBar);
        add(anchorCrossHBar);

        cornerTopLeft.onPointerDown(this, function(info) {
            emitCornerDown(TOP_LEFT, info);
        });
        cornerTopRight.onPointerDown(this, function(info) {
            emitCornerDown(TOP_RIGHT, info);
        });
        cornerBottomLeft.onPointerDown(this, function(info) {
            emitCornerDown(BOTTOM_LEFT, info);
        });
        cornerBottomRight.onPointerDown(this, function(info) {
            emitCornerDown(BOTTOM_RIGHT, info);
        });

        cornerTopLeft.onPointerOver(this, function(info) {
            emitCornerOver(TOP_LEFT, info);
        });
        cornerTopRight.onPointerOver(this, function(info) {
            emitCornerOver(TOP_RIGHT, info);
        });
        cornerBottomLeft.onPointerOver(this, function(info) {
            emitCornerOver(BOTTOM_LEFT, info);
        });
        cornerBottomRight.onPointerOver(this, function(info) {
            emitCornerOver(BOTTOM_RIGHT, info);
        });

        cornerTopLeft.onPointerOut(this, function(info) {
            emitCornerOut(TOP_LEFT, info);
        });
        cornerTopRight.onPointerOut(this, function(info) {
            emitCornerOut(TOP_RIGHT, info);
        });
        cornerBottomLeft.onPointerOut(this, function(info) {
            emitCornerOut(BOTTOM_LEFT, info);
        });
        cornerBottomRight.onPointerOut(this, function(info) {
            emitCornerOut(BOTTOM_RIGHT, info);
        });

        autorun(() -> {
            color = theme.highlightColor;
            pendingColor = theme.highlightPendingColor;
        });

        updateCornersAndBorders();

    }

/// Overrides

    override function set_width(width:Float):Float {
        if (this.width == width) return width;
        super.set_width(width);

        updateCornersAndBorders();

        return width;
    }

    override function set_height(height:Float):Float {
        if (this.height == height) return height;
        super.set_height(height);

        updateCornersAndBorders();

        return height;
    }

/// Public API

    public function wrapVisual(visual:Visual):Void {

        wrappedVisual = visual;

        if (visual != null) {
            doWrapVisual(visual);
            contentDirty = true;
        }

    }

    function doWrapVisual(visual:Visual) {

        visual.visualToScreen(0, 0, pointTopLeft);
        this.screenToVisual(pointTopLeft.x, pointTopLeft.y, pointTopLeft);

        visual.visualToScreen(visual.width, 0, pointTopRight);
        this.screenToVisual(pointTopRight.x, pointTopRight.y, pointTopRight);

        visual.visualToScreen(0, visual.height, pointBottomLeft);
        this.screenToVisual(pointBottomLeft.x, pointBottomLeft.y, pointBottomLeft);

        visual.visualToScreen(visual.width, visual.height, pointBottomRight);
        this.screenToVisual(pointBottomRight.x, pointBottomRight.y, pointBottomRight);

        visual.visualToScreen(visual.width * visual.anchorX, visual.height * visual.anchorY, pointAnchor);
        this.screenToVisual(pointAnchor.x, pointAnchor.y, pointAnchor);

        updateCornersAndBorders();

    }

    /**
     * Note: should be called AFTER wrapVisual(), not before.
     * @param points 
     */
    public function wrapPoints(points:Array<Float>) {

        wrappedPoints = points;
        if (points != null) {
            doWrapPoints(points);
            contentDirty = true;
        }

    }

    function doWrapPoints(points:Array<Float>) {

        if (wrappedVisual == null || wrappedVisual.destroyed)
            return;

        var i = 0;
        while (i * 2 < points.length) {
            var pointX = points[i * 2];
            var pointY = points[i * 2 + 1];
            wrappedVisual.visualToScreen(pointX, pointY, _point);
            this.screenToVisual(_point.x, _point.y, _point);
            localPoints[i * 2] = _point.x;
            localPoints[i * 2 + 1] = _point.y;
            i++;
        }

        if (localPoints.length > points.length)
            localPoints.setArrayLength(points.length);

        updatePointHandles();
        updatePointSegments();

    }

/// Internal

    override function computeContent() {

        if (wrappedVisual != null) {
            if (wrappedVisual.destroyed) {
                wrappedVisual = null;
            }
            else {
                doWrapVisual(wrappedVisual);
            }
        }

        if (wrappedPoints != null) {
            doWrapPoints(wrappedPoints);
        }

        contentDirty = false;

    }

    function updateCornersAndBorders() {

        anchorCrossVBar.anchor(0.5, 0.5);
        anchorCrossVBar.pos(pointAnchor.x, pointAnchor.y);
        anchorCrossVBar.size(crossWidth, 8);

        anchorCrossHBar.anchor(0.5, 0.5);
        anchorCrossHBar.pos(pointAnchor.x, pointAnchor.y);
        anchorCrossHBar.size(8, crossWidth);

        cornerTopLeft.size(cornerSize, cornerSize);
        cornerTopLeft.anchor(0.5, 0.5);
        cornerTopLeft.pos(pointTopLeft.x, pointTopLeft.y);

        cornerTopRight.size(cornerSize, cornerSize);
        cornerTopRight.anchor(0.5, 0.5);
        cornerTopRight.pos(pointTopRight.x, pointTopRight.y);

        cornerBottomLeft.size(cornerSize, cornerSize);
        cornerBottomLeft.anchor(0.5, 0.5);
        cornerBottomLeft.pos(pointBottomLeft.x, pointBottomLeft.y);

        cornerBottomRight.size(cornerSize, cornerSize);
        cornerBottomRight.anchor(0.5, 0.5);
        cornerBottomRight.pos(pointBottomRight.x, pointBottomRight.y);

        var a = pointTopRight.x - pointTopLeft.x;
        var b = pointTopRight.y - pointTopLeft.y;
        var r = Math.atan2(pointTopRight.y - pointTopLeft.y, pointTopRight.x - pointTopLeft.x) * 180.0 / Math.PI;

        topDistance = Math.sqrt(a * a + b * b);
        borderTop.size(topDistance, borderSize);
        borderTop.anchor(0, 0.5);
        borderTop.pos(pointTopLeft.x, pointTopLeft.y);
        borderTop.rotation = r;

        a = pointBottomRight.x - pointTopRight.x;
        b = pointBottomRight.y - pointTopRight.y;
        r = Math.atan2(pointBottomRight.y - pointTopRight.y, pointBottomRight.x - pointTopRight.x) * 180.0 / Math.PI;

        rightDistance = Math.sqrt(a * a + b * b);
        borderRight.size(rightDistance, borderSize);
        borderRight.anchor(0, 0.5);
        borderRight.pos(pointTopRight.x, pointTopRight.y);
        borderRight.rotation = r;

        a = pointBottomLeft.x - pointBottomRight.x;
        b = pointBottomLeft.y - pointBottomRight.y;
        r = Math.atan2(pointBottomLeft.y - pointBottomRight.y, pointBottomLeft.x - pointBottomRight.x) * 180.0 / Math.PI;

        bottomDistance = Math.sqrt(a * a + b * b);
        borderBottom.size(bottomDistance, borderSize);
        borderBottom.anchor(0, 0.5);
        borderBottom.pos(pointBottomRight.x, pointBottomRight.y);
        borderBottom.rotation = r;

        a = pointTopLeft.x - pointBottomLeft.x;
        b = pointTopLeft.y - pointBottomLeft.y;
        r = Math.atan2(pointTopLeft.y - pointBottomLeft.y, pointTopLeft.x - pointBottomLeft.x) * 180.0 / Math.PI;

        leftDistance = Math.sqrt(a * a + b * b);
        borderLeft.size(leftDistance, borderSize);
        borderLeft.anchor(0, 0.5);
        borderLeft.pos(pointBottomLeft.x, pointBottomLeft.y);
        borderLeft.rotation = r;

    }

    function updatePointHandles() {

        var i = 0;
        while (i * 2 < localPoints.length) {
            var handle = pointHandles[i];
            
            if (handle == null) {
                handle = new View();
                handle.depth = 2;
                handle.borderColor = Color.WHITE;
                handle.borderPosition = INSIDE;
                handle.borderSize = 1;
                handle.color = color;
                handle.size(pointHandleSize, pointHandleSize);
                (function(i) {
                    handle.onPointerDown(this, function(info) {
                        emitPointHandleDown(i, info);
                    });
                    handle.onPointerOver(this, function(info) {
                        emitPointHandleOver(i, info);
                    });
                    handle.onPointerOut(this, function(info) {
                        emitPointHandleOut(i, info);
                    });
                })(i);
                pointHandles[i] = handle;
                add(handle);
            }

            var pointX = localPoints[i * 2];
            var pointY = localPoints[i * 2 + 1];

            handle.pos(pointX, pointY);
            handle.anchor(0.5, 0.5);
            handle.size(pointHandleSize, pointHandleSize);

            i++;
        }

        while (localPoints.length < pointHandles.length * 2) {
            var handle = pointHandles.pop();
            handle.destroy();
        }

    }

    function updatePendingPointHandle() {

        if (pendingPointHandleActive) {
            if (pendingPointHandle == null) {
                pendingPointHandle = new View();
                pendingPointHandle.depth = 2;
                pendingPointHandle.borderColor = Color.WHITE;
                pendingPointHandle.borderPosition = INSIDE;
                pendingPointHandle.borderSize = 1;
                pendingPointHandle.color = pendingColor;
                pendingPointHandle.size(pointHandleSize, pointHandleSize);
                pendingPointHandle.anchor(0.5, 0.5);
                pendingPointHandle.onPointerDown(this, emitPendingPointHandleDown);
                add(pendingPointHandle);
            }
            pendingPointHandle.active = true;
            pendingPointHandle.pos(pendingPointHandleX, pendingPointHandleY);
        }
        else {
            if (pendingPointHandle != null) {
                pendingPointHandle.active = false;
            }
        }

    }

    function updatePointSegments() {

        if (pointSegments == null) {
            pointSegments = new Line();
            pointSegments.complexHit = true;
            pointSegments.thickness = 24;
            pointSegments.color = Color.WHITE;
            pointSegments.alpha = 0;
            pointSegments.points = [];
            pointSegments.depth = 1.75;
            pointSegments.onPointerDown(this, emitPointSegmentsDown);
            pointSegments.onPointerOver(this, emitPointSegmentsOver);
            pointSegments.onPointerOut(this, emitPointSegmentsOut);
            add(pointSegments);
        }

        for (i in 0...localPoints.length) {
            pointSegments.points[i] = localPoints[i];
        }
        var len = localPoints.length;
        if (len >= 2) {
            pointSegments.points[len] = localPoints[0];
            pointSegments.points[len + 1] = localPoints[1];
        }

        if (pointSegments.points.length > len + 2) {
            pointSegments.points.setArrayLength(len + 2);
        }

        pointSegments.contentDirty = true;
        pointSegments.computeContent();
        
    }

}
