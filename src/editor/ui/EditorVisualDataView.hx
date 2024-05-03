package editor.ui;

import ceramic.Color;
import ceramic.Component;
import ceramic.Entity;
import ceramic.Quad;
import ceramic.View;
import ceramic.Visual;
import editor.components.Editable;
import editor.model.fragment.EditorQuadData;
import editor.model.fragment.EditorVisualData;

class EditorVisualDataView extends View implements Component {

    @entity public var visualData:EditorVisualData;

    @component public var editable:Editable;

    @owner public var visual:Visual = null;

    function bindAsComponent() {

        transparent = true;

        editable = new Editable();

        editable.onSelect(this, handleEditableSelect);
        editable.onChange(this, handleEditableChange);
        visualData.fragment.onSelectedVisualChange(this, handleSelectedVisualChange);
        if (visualData.fragment.selectedVisual == visualData) {
            editable.select();
        }
        autorun(autoUpdateResizeInsteadOfScale);

        onResize(this, handleResize);

        autorun(autoUpdateLocked);

        autorun(autoUpdateSize);
        autorun(autoUpdatePosition);
        autorun(autoUpdateAnchor);
        autorun(autoUpdateScale);
        autorun(autoUpdateSkew);
        autorun(autoUpdateDepth);
        autorun(autoUpdateRotation);
        autorun(autoUpdateAlpha);

        switch Type.getClass(visualData) {

            case EditorVisualData:
                // Nothing to do

            case EditorQuadData:
                visual = new Quad();
                add(visual);
                autorun(autoUpdateQuadColor);
                autorun(autoUpdateQuadTransparent);
                autorun(autoUpdateQuadTexture);

        }

        if (visual != null) {
            visual.inheritAlpha = true;
        }

    }

    function handleResize(width:Float, height:Float) {

        switch Type.getClass(visualData) {

            case EditorVisualData:
                // Nothing to do

            case _:
                if (visual != null) {
                    visual.size(width, height);
                }

        }

    }

    function autoUpdateResizeInsteadOfScale() {

        final resizeInsteadOfScale = visualData.resizeInsteadOfScale;
        unobserve();

        editable.highlightResizeInsteadOfScale = resizeInsteadOfScale;

    }

    function handleEditableSelect(visual:Visual, fromPointer:Bool) {

        visualData.fragment.selectVisual(visualData);

        if (fromPointer)
            visualData.fragment.project.selectedTab = VISUALS;

    }

    function handleEditableChange(visual:Visual, changes:Dynamic) {

        for (key in Reflect.fields(changes)) {
            final value = Reflect.field(changes, key);
            Reflect.setProperty(visualData, key, value);
        }

    }

    function handleSelectedVisualChange(visual:EditorVisualData, prevVisual:EditorVisualData) {

        if (prevVisual == visualData && visual != visualData) {
            editable.deselect();
        }
        else if (prevVisual != visualData && visual == visualData) {
            editable.select();
        }

    }

    function autoUpdateLocked() {

        final visualData = this.visualData;
        final locked = visualData.locked;
        unobserve();

        if (locked) {
            touchable = false;
            borderSize = 0;
        }
        else {
            reobserve();
            final selected = (visualData.fragment.selectedVisual == visualData);
            unobserve();

            touchable = true;
            if (selected) {
                // When selected, we don't show these borders because
                // the highlight borders are already visible
                borderSize = 0;
            }
            else {
                borderSize = 1;
                borderPosition = MIDDLE;
                borderColor = Color.WHITE;
                borderAlpha = 0.15;
            }
        }

    }

    function autoUpdateSize() {

        final visualData = this.visualData;
        final width = visualData.width;
        final height = visualData.height;
        unobserve();

        size(width, height);

    }

    function autoUpdatePosition() {

        final visualData = this.visualData;
        final x = visualData.x;
        final y = visualData.y;
        unobserve();

        pos(x, y);

    }

    function autoUpdateAnchor() {

        final visualData = this.visualData;
        final anchorX = visualData.anchorX;
        final anchorY = visualData.anchorY;
        unobserve();

        anchor(anchorX, anchorY);

    }

    function autoUpdateScale() {

        final visualData = this.visualData;
        final scaleX = visualData.scaleX;
        final scaleY = visualData.scaleY;
        unobserve();

        scale(scaleX, scaleY);

    }

    function autoUpdateSkew() {

        final visualData = this.visualData;
        final skewX = visualData.skewX;
        final skewY = visualData.skewY;
        unobserve();

        skew(skewX, skewY);

    }

    function autoUpdateVisible() {

        final visualData = this.visualData;
        final visible = visualData.visible;
        unobserve();

        this.visible = visible;

    }

    function autoUpdateDepth() {

        final visualData = this.visualData;
        final depth = visualData.depth;
        unobserve();

        this.depth = depth;

    }

    function autoUpdateRotation() {

        final visualData = this.visualData;
        final rotation = visualData.rotation;
        unobserve();

        this.rotation = rotation;

    }

    function autoUpdateAlpha() {

        final visualData = this.visualData;
        final alpha = visualData.alpha;
        unobserve();

        this.alpha = alpha;

    }

    function autoUpdateTranslate() {

        final visualData = this.visualData;
        final translateX = visualData.translateX;
        final translateY = visualData.translateY;
        unobserve();

        translate(translateX, translateY);

    }

    function autoUpdateQuadColor() {

        final quadData:EditorQuadData = cast this.visualData;
        final color = quadData.color;
        unobserve();

        final quad:Quad = cast visual;
        quad.color = color;

    }

    function autoUpdateQuadTransparent() {

        final quadData:EditorQuadData = cast this.visualData;
        final transparent = quadData.transparent;
        unobserve();

        final quad:Quad = cast visual;
        quad.transparent = transparent;

    }

    function autoUpdateQuadTexture() {

        final quadData:EditorQuadData = cast this.visualData;
        final textureName = quadData.texture;
        unobserve();

        final quad:Quad = cast visual;
        if (textureName != null) {
            reobserve();
            final texture = quadData.fragment.project.texture(textureName);
            unobserve();

            quad.texture = texture;
            if (texture != null) {
                quadData.width = texture.width;
                quadData.height = texture.height;
            }
        }
        else {
            quad.texture = null;
        }

    }

}
