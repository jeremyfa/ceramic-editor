package editor.components;

@:allow(editor.components.VisualTransitionProperties)
class VisualTransition extends Entity implements Component {

    static var _currentTransform:Transform = new Transform();

    static var _targetTransform:Transform = new Transform();

    static var _identityTransform:Transform = new Transform();

    var entity:Visual;

    public var easing:Easing;

    public var duration:Float;

    var anyPropertyChanged:Bool = false;

    var xChanged:Bool = false;
    var xTween:Tween = null;
    var xTarget:Float = 0;
    var xStart:Float = 0;
    var xEnd:Float = 0;

    var yChanged:Bool = false;
    var yTween:Tween = null;
    var yTarget:Float = 0;
    var yStart:Float = 0;
    var yEnd:Float = 0;

    var scaleXChanged:Bool = false;
    var scaleXTween:Tween = null;
    var scaleXTarget:Float = 0;
    var scaleXStart:Float = 0;
    var scaleXEnd:Float = 0;

    var scaleYChanged:Bool = false;
    var scaleYTween:Tween = null;
    var scaleYTarget:Float = 0;
    var scaleYStart:Float = 0;
    var scaleYEnd:Float = 0;

    var anchorXChanged:Bool = false;
    var anchorXTween:Tween = null;
    var anchorXTarget:Float = 0;
    var anchorXStart:Float = 0;
    var anchorXEnd:Float = 0;

    var anchorYChanged:Bool = false;
    var anchorYTween:Tween = null;
    var anchorYTarget:Float = 0;
    var anchorYStart:Float = 0;
    var anchorYEnd:Float = 0;

    var rotationChanged:Bool = false;
    var rotationTween:Tween = null;
    var rotationTarget:Float = 0;
    var rotationStart:Float = 0;
    var rotationEnd:Float = 0;

    var widthChanged:Bool = false;
    var widthTween:Tween = null;
    var widthTarget:Float = 0;
    var widthStart:Float = 0;
    var widthEnd:Float = 0;

    var heightChanged:Bool = false;
    var heightTween:Tween = null;
    var heightTarget:Float = 0;
    var heightStart:Float = 0;
    var heightEnd:Float = 0;

    var colorChanged:Bool = false;
    var colorTween:Tween = null;
    var colorTarget:Color = Color.NONE;
    var colorStart:Color = Color.NONE;
    var colorEnd:Color = Color.NONE;

    var alphaChanged:Bool = false;
    var alphaTween:Tween = null;
    var alphaTarget:Float = 0;
    var alphaStart:Float = 0;
    var alphaEnd:Float = 0;

    var transformChanged:Bool = false;
    var transformAssigned:Bool = false;
    var transformAssignedInstance:Transform = null;
    var transformTween:Tween = null;
    var transformTarget:Transform = null;
    var transformStart:Transform = null;
    var transformEnd:Transform = null;
    var transformEndToNull:Bool = false;
    var transformInTransition:Transform = null;

    var offsetXChanged:Bool = false;
    var offsetXTween:Tween = null;
    var offsetXTarget:Float = 0;
    var offsetXStart:Float = 0;
    var offsetXEnd:Float = 0;

    var offsetYChanged:Bool = false;
    var offsetYTween:Tween = null;
    var offsetYTarget:Float = 0;
    var offsetYStart:Float = 0;
    var offsetYEnd:Float = 0;

    var viewWidthChanged:Bool = false;
    var viewWidthTween:Tween = null;
    var viewWidthTarget:Float = 0;
    var viewWidthStart:Float = 0;
    var viewWidthEnd:Float = 0;

    var viewHeightChanged:Bool = false;
    var viewHeightTween:Tween = null;
    var viewHeightTarget:Float = 0;
    var viewHeightStart:Float = 0;
    var viewHeightEnd:Float = 0;

    var isView:Bool = false;

    public function new(?easing:Easing, duration:Float = 0.3) {

        super();

        this.easing = easing;
        this.duration = duration;

    }

    function bindAsComponent() {

        isView = Std.is(entity, View);

    }

/// Public API

    public function run(?easing:Easing, duration:Float, cb:VisualTransitionProperties->Void) {

        final NO_VALUE_FLOAT:Float = -999999999;

        // Compute proper transition easing and duration
        if (easing == null)
            easing = this.easing;
        if (duration == -1)
            duration = this.duration;

        // Initial "change" flag values
        anyPropertyChanged = false;
        xChanged = false;
        yChanged = false;
        scaleXChanged = false;
        scaleYChanged = false;
        anchorXChanged = false;
        anchorYChanged = false;
        rotationChanged = false;
        widthChanged = false;
        heightChanged = false;
        colorChanged = false;
        alphaChanged = false;
        transformAssigned = false;
        transformAssignedInstance = null;
        transformChanged = false;
        offsetXChanged = false;
        offsetYChanged = false;
        viewWidthChanged = false;
        viewHeightChanged = false;

        inline function copyCurrentTransform(transform) {
            _currentTransform.setToTransform(transform);
            _currentTransform.cleanChangedState();
            _currentTransform.changedDirty = false;
            return _currentTransform;
        }

        inline function copyTargetTransform(transform) {
            _targetTransform.setToTransform(transform);
            _targetTransform.cleanChangedState();
            _targetTransform.changedDirty = false;
            return _targetTransform;
        }

        var asView:View = isView ? cast entity : null;

        // Initial visual values
        //
        var xCurrent = entity.x;
        var yCurrent = entity.y;
        var scaleXCurrent = entity.scaleX;
        var scaleYCurrent = entity.scaleY;
        var anchorXCurrent = entity.anchorX;
        var anchorYCurrent = entity.anchorY;
        var rotationCurrent = entity.rotation;
        var widthCurrent = entity.width;
        var heightCurrent = entity.height;
        var colorCurrent = entity.asQuad != null ? entity.asQuad.color : Color.NONE;
        var alphaCurrent = entity.alpha;
        var transformCurrent = entity.transform != null ? copyCurrentTransform(entity.transform) : null;
        var offsetXCurrent = isView ? asView.offsetX : 0.0;
        var offsetYCurrent = isView ? asView.offsetY : 0.0;
        var viewWidthCurrent = isView ? asView.viewWidth : 0.0;
        var viewHeightCurrent = isView ? asView.viewHeight : 0.0;

        // Update target values with initial values
        xTarget = xCurrent;
        yTarget = yCurrent;
        scaleXTarget = scaleXCurrent;
        scaleYTarget = scaleYCurrent;
        anchorXTarget = anchorXCurrent;
        anchorYTarget = anchorYCurrent;
        rotationTarget = rotationCurrent;
        widthTarget = widthCurrent;
        heightTarget = heightCurrent;
        colorTarget = colorCurrent;
        alphaTarget = alphaCurrent;
        transformTarget = transformCurrent != null ? copyTargetTransform(transformCurrent) : null;
        offsetXTarget = offsetXCurrent;
        offsetYTarget = offsetYCurrent;
        viewWidthTarget = viewWidthCurrent;
        viewHeightTarget = viewHeightCurrent;

        // Compute target values
        var props:VisualTransitionProperties = this;
        cb(props);

        // Check if transform was updated or not
        if (!transformChanged && transformTarget != null) {
            if (transformTarget.changedDirty)
                transformTarget.computeChanged();
            if (transformTarget.changed)
                transformChanged = true;
        }

        // Create tween if any value was changed
        if (anyPropertyChanged) {

            var propsTween:Tween = null;
            propsTween = entity.tween(easing, duration, 0, 1, (value, _) -> {

                // Change values linked to this tween
                //
                if (xTween == propsTween)
                    entity.x = xStart + (xEnd - xStart) * value;
                if (yTween == propsTween)
                    entity.y = yStart + (yEnd - yStart) * value;
                if (scaleXTween == propsTween)
                    entity.scaleX = scaleXStart + (scaleXEnd - scaleXStart) * value;
                if (scaleYTween == propsTween)
                    entity.scaleY = scaleYStart + (scaleYEnd - scaleYStart) * value;
                if (anchorXTween == propsTween)
                    entity.anchorX = anchorXStart + (anchorXEnd - anchorXStart) * value;
                if (anchorYTween == propsTween)
                    entity.anchorY = anchorYStart + (anchorYEnd - anchorYStart) * value;
                if (rotationTween == propsTween)
                    entity.rotation = rotationStart + (rotationEnd - rotationStart) * value;
                if (widthTween == propsTween)
                    entity.width = widthStart + (widthEnd - widthStart) * value;
                if (heightTween == propsTween)
                    entity.height = heightStart + (heightEnd - heightStart) * value;
                if (colorTween == propsTween)
                    entity.asQuad.color = Color.interpolate(colorStart, colorEnd, value);
                if (alphaTween == propsTween)
                    entity.alpha = alphaStart + (alphaEnd - alphaStart) * value;
                if (transformTween == propsTween) {
                    if (value == 1 && transformAssigned) {
                        entity.transform = transformAssignedInstance;
                    }
                    else {
                        if (transformAssigned && value == 0)
                            entity.transform = null;
                        if (entity.transform == null) {
                            if (transformInTransition == null)
                                transformInTransition = TransformPool.get();
                            entity.transform = transformInTransition;
                        }
                        entity.transform.setFromInterpolated(
                            transformStart != null ? transformStart : _identityTransform,
                            transformEnd != null ? transformEnd : _identityTransform,
                            value
                        );
                    }
                }
                if (offsetXTween == propsTween)
                    asView.offsetX = offsetXStart + (offsetXEnd - offsetXStart) * value;
                if (offsetYTween == propsTween)
                    asView.offsetY = offsetYStart + (offsetYEnd - offsetYStart) * value;
                if (viewWidthTween == propsTween)
                    asView.viewWidth = viewWidthStart + (viewWidthEnd - viewWidthStart) * value;
                if (viewHeightTween == propsTween)
                    asView.viewHeight = viewHeightStart + (viewHeightEnd - viewHeightStart) * value;
            });
            propsTween.onDestroy(this, propsTween -> {
                if (xTween == propsTween)
                    xTween = null;
                if (yTween == propsTween)
                    yTween = null;
                if (scaleXTween == propsTween)
                    scaleXTween = null;
                if (scaleYTween == propsTween)
                    scaleYTween = null;
                if (anchorXTween == propsTween)
                    anchorXTween = null;
                if (anchorYTween == propsTween)
                    anchorYTween = null;
                if (rotationTween == propsTween)
                    rotationTween = null;
                if (widthTween == propsTween)
                    widthTween = null;
                if (heightTween == propsTween)
                    heightTween = null;
                if (colorTween == propsTween)
                    colorTween = null;
                if (alphaTween == propsTween)
                    alphaTween = null;
                if (transformTween == propsTween)
                    transformTween = null;
                if (offsetXTween == propsTween)
                    offsetXTween = null;
                if (offsetYTween == propsTween)
                    offsetYTween = null;
                if (viewWidthTween == propsTween)
                    viewWidthTween = null;
                if (viewHeightTween == propsTween)
                    viewHeightTween = null;
            });

            if (xChanged) {
                xTween = propsTween;
                xStart = xCurrent;
                xEnd = xTarget;
            }
            if (yChanged) {
                yTween = propsTween;
                yStart = yCurrent;
                yEnd = yTarget;
            }
            if (scaleXChanged) {
                scaleXTween = propsTween;
                scaleXStart = scaleXCurrent;
                scaleXEnd = scaleXTarget;
            }
            if (scaleYChanged) {
                scaleYTween = propsTween;
                scaleYStart = scaleYCurrent;
                scaleYEnd = scaleYTarget;
            }
            if (anchorXChanged) {
                anchorXTween = propsTween;
                anchorXStart = anchorXCurrent;
                anchorXEnd = anchorXTarget;
            }
            if (anchorYChanged) {
                anchorYTween = propsTween;
                anchorYStart = anchorYCurrent;
                anchorYEnd = anchorYTarget;
            }
            if (rotationChanged) {
                rotationTween = propsTween;
                rotationStart = Utils.clampDegrees(rotationCurrent);
                rotationEnd = Utils.clampDegrees(rotationTarget);
                var rotationDelta = rotationEnd - rotationStart;
                if (rotationDelta > 180) {
                    rotationEnd -= 360;
                }
                else if (rotationDelta < -180) {
                    rotationEnd += 360;
                }
            }
            if (widthChanged) {
                widthTween = propsTween;
                widthStart = widthCurrent;
                widthEnd = widthTarget;
            }
            if (heightChanged) {
                heightTween = propsTween;
                heightStart = heightCurrent;
                heightEnd = heightTarget;
            }
            if (colorChanged) {
                colorTween = propsTween;
                colorStart = colorCurrent;
                colorEnd = colorTarget;
            }
            if (alphaChanged) {
                alphaTween = propsTween;
                alphaStart = alphaCurrent;
                alphaEnd = alphaTarget;
            }
            if (transformChanged) {
                transformTween = propsTween;
                if (transformCurrent != null) {
                    if (transformStart == null)
                        transformStart = TransformPool.get();
                    transformStart.setToTransform(transformCurrent);
                }
                else if (transformStart != null) {
                    transformStart.identity();
                }
                if (transformTarget != null) {
                    if (transformEnd == null)
                        transformEnd = TransformPool.get();
                    transformEnd.setToTransform(transformTarget);
                    transformEndToNull = false;
                }
                else if (transformEnd != null) {
                    transformEnd.identity();
                    transformEndToNull = true;
                }
            }
            if (offsetXChanged) {
                offsetXTween = propsTween;
                offsetXStart = offsetXCurrent;
                offsetXEnd = offsetXTarget;
            }
            if (offsetYChanged) {
                offsetYTween = propsTween;
                offsetYStart = offsetYCurrent;
                offsetYEnd = offsetYTarget;
            }
            if (viewWidthChanged) {
                viewWidthTween = propsTween;
                viewWidthStart = viewWidthCurrent;
                viewWidthEnd = viewWidthTarget;
            }
            if (viewHeightChanged) {
                viewHeightTween = propsTween;
                viewHeightStart = viewHeightCurrent;
                viewHeightEnd = viewHeightTarget;
            }
        }

    }

    override function destroy() {

        if (transformInTransition != null) {
            TransformPool.recycle(transformInTransition);
            transformInTransition = null;
        }

        if (transformStart != null) {
            TransformPool.recycle(transformStart);
            transformStart = null;
        }

        if (transformEnd != null) {
            TransformPool.recycle(transformEnd);
            transformEnd = null;
        }

        super.destroy();

    }

/// Static extension

    public static function transition(visual:Visual, ?easing:Easing, duration:Float, cb:VisualTransitionProperties->Void):Void {

        var transitionComponent:VisualTransition = cast visual.component('transition');
        if (transitionComponent == null) {
            transitionComponent = new VisualTransition();
            visual.component('transition', transitionComponent);
        }

        transitionComponent.run(easing, duration, cb);

    }

}

abstract VisualTransitionProperties(VisualTransition) from VisualTransition {

    public var x(get, set):Float;
    function get_x():Float return this.xTarget;
    function set_x(x:Float):Float {
        if (this.xTween == null || x != this.xEnd) {
            this.anyPropertyChanged = true;
            this.xChanged = true;
        }
        this.xTarget = x;
        return x;
    }

    public var y(get, set):Float;
    function get_y():Float return this.yTarget;
    function set_y(y:Float):Float {
        if (this.yTween == null || y != this.yEnd) {
            this.anyPropertyChanged = true;
            this.yChanged = true;
        }
        this.yTarget = y;
        return y;
    }

    public function pos(x:Float, y:Float):Void {
        inline set_x(x);
        inline set_y(y);
    }

    public var scaleX(get, set):Float;
    function get_scaleX():Float return this.scaleXTarget;
    function set_scaleX(scaleX:Float):Float {
        if (this.scaleXTween == null || scaleX != this.scaleXEnd) {
            this.anyPropertyChanged = true;
            this.scaleXChanged = true;
        }
        this.scaleXTarget = scaleX;
        return scaleX;
    }

    public var scaleY(get, set):Float;
    function get_scaleY():Float return this.scaleYTarget;
    function set_scaleY(scaleY:Float):Float {
        if (this.scaleYTween == null || scaleY != this.scaleYEnd) {
            this.anyPropertyChanged = true;
            this.scaleYChanged = true;
        }
        this.scaleYTarget = scaleY;
        return scaleY;
    }

    public function scale(scaleX:Float, scaleY:Float):Void {
        inline set_scaleX(scaleX);
        inline set_scaleY(scaleY);
    }

    public var anchorX(get, set):Float;
    function get_anchorX():Float return this.anchorXTarget;
    function set_anchorX(anchorX:Float):Float {
        if (this.anchorXTween == null || anchorX != this.anchorXEnd) {
            this.anyPropertyChanged = true;
            this.anchorXChanged = true;
        }
        this.anchorXTarget = anchorX;
        return anchorX;
    }

    public var anchorY(get, set):Float;
    function get_anchorY():Float return this.anchorYTarget;
    function set_anchorY(anchorY:Float):Float {
        if (this.anchorYTween == null || anchorY != this.anchorYEnd) {
            this.anyPropertyChanged = true;
            this.anchorYChanged = true;
        }
        this.anchorYTarget = anchorY;
        return anchorY;
    }

    public function anchor(anchorX:Float, anchorY:Float):Void {
        inline set_anchorX(anchorX);
        inline set_anchorY(anchorY);
    }

    public var rotation(get, set):Float;
    function get_rotation():Float return this.rotationTarget;
    function set_rotation(rotation:Float):Float {
        if (this.rotationTween == null || rotation != this.rotationEnd) {
            this.anyPropertyChanged = true;
            this.rotationChanged = true;
        }
        this.rotationTarget = rotation;
        return rotation;
    }

    public var width(get, set):Float;
    function get_width():Float return this.widthTarget;
    function set_width(width:Float):Float {
        if (this.widthTween == null || width != this.widthEnd) {
            this.anyPropertyChanged = true;
            this.widthChanged = true;
        }
        this.widthTarget = width;
        return width;
    }

    public var height(get, set):Float;
    function get_height():Float return this.heightTarget;
    function set_height(height:Float):Float {
        if (this.heightTween == null || height != this.heightEnd) {
            this.anyPropertyChanged = true;
            this.heightChanged = true;
        }
        this.heightTarget = height;
        return height;
    }

    public function size(width:Float, height:Float):Void {
        inline set_width(width);
        inline set_height(height);
    }

    public var color(get, set):Color;
    function get_color():Color return this.colorTarget;
    function set_color(color:Color):Color {
        if (this.colorTween == null || color != this.colorEnd) {
            this.anyPropertyChanged = true;
            this.colorChanged = true;
        }
        this.colorTarget = color;
        return color;
    }

    public var alpha(get, set):Float;
    function get_alpha():Float return this.alphaTarget;
    function set_alpha(alpha:Float):Float {
        if (this.alphaTween == null || alpha != this.alphaEnd) {
            this.anyPropertyChanged = true;
            this.alphaChanged = true;
        }
        this.alphaTarget = alpha;
        return alpha;
    }

    public var transform(get, set):Transform;
    function get_transform():Transform return this.transformTarget;
    function set_transform(transform:Transform):Transform {
        this.anyPropertyChanged = true;
        this.transformChanged = true;
        this.transformAssigned = true;
        this.transformAssignedInstance = transform;
        this.transformTarget = transform;
        return transform;
    }

    public var offsetX(get, set):Float;
    function get_offsetX():Float return this.offsetXTarget;
    function set_offsetX(offsetX:Float):Float {
        if (this.offsetXTween == null || offsetX != this.offsetXEnd) {
            this.anyPropertyChanged = true;
            this.offsetXChanged = true;
        }
        this.offsetXTarget = offsetX;
        return offsetX;
    }

    public var offsetY(get, set):Float;
    function get_offsetY():Float return this.offsetYTarget;
    function set_offsetY(offsetY:Float):Float {
        if (this.offsetYTween == null || offsetY != this.offsetYEnd) {
            this.anyPropertyChanged = true;
            this.offsetYChanged = true;
        }
        this.offsetYTarget = offsetY;
        return offsetY;
    }

    public function offset(offsetX:Float, offsetY:Float):Void {
        inline set_offsetX(offsetX);
        inline set_offsetY(offsetY);
    }

    public var viewWidth(get, set):Float;
    function get_viewWidth():Float return this.viewWidthTarget;
    function set_viewWidth(viewWidth:Float):Float {
        if (this.viewWidthTween == null || viewWidth != this.viewWidthEnd) {
            this.anyPropertyChanged = true;
            this.viewWidthChanged = true;
        }
        this.viewWidthTarget = viewWidth;
        return viewWidth;
    }

    public var viewHeight(get, set):Float;
    function get_viewHeight():Float return this.viewHeightTarget;
    function set_viewHeight(viewHeight:Float):Float {
        if (this.viewHeightTween == null || viewHeight != this.viewHeightEnd) {
            this.anyPropertyChanged = true;
            this.viewHeightChanged = true;
        }
        this.viewHeightTarget = viewHeight;
        return viewHeight;
    }

    public function viewSize(viewWidth:Float, viewHeight:Float):Void {
        inline set_viewWidth(viewWidth);
        inline set_viewHeight(viewHeight);
    }

}
