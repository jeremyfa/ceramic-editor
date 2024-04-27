package editor.model.fragment;

import ceramic.AssetId;
import ceramic.Color;

class EditorQuadData extends EditorVisualData {

    @serialize public var color:Color = Color.WHITE;

    @serialize public var transparent:Bool = false;

    @serialize public var texture:String = null;

}
