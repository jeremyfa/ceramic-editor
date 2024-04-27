package editor.ui;

import ceramic.Color;
import ceramic.Component;
import ceramic.Entity;
import ceramic.View;
import ceramic.Visual;
import editor.components.Editable;
import editor.model.fragment.EditorVisualData;

class EditorVisualDataView extends View implements Component {

    @entity public var visualData:EditorVisualData;

    @component public var editable:Editable;

    function bindAsComponent() {

        transparent = true;

        editable = new Editable();

        editable.onSelect(this, handleEditableSelect);
        visualData.fragment.onSelectedVisualChange(this, handleSelectedVisualChange);
        if (visualData.fragment.selectedVisual == visualData) {
            editable.select();
        }

        autorun(autoUpdateLocked);

        autorun(autoUpdateSize);
        autorun(autoUpdatePosition);
        autorun(autoUpdateAnchor);
        autorun(autoUpdateDepth);

    }

    function handleEditableSelect(visual:Visual, fromPointer:Bool) {

        visualData.fragment.selectVisual(visualData);

        if (fromPointer)
            visualData.fragment.project.sidebarTab = VISUALS;

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
                borderAlpha = 0.5;
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

    function autoUpdateDepth() {

        final visualData = this.visualData;
        final depth = visualData.depth;
        unobserve();

        this.depth = depth;

    }

}
