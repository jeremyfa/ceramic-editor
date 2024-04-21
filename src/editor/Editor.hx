package editor;

import ceramic.Color;
import ceramic.KeyBindings;
import ceramic.Layer;
import ceramic.Quad;
import ceramic.Scene;
import ceramic.StateMachine;
import ceramic.Timer;
import editor.model.EditorData;
import editor.model.fragment.EditorEntityData;
import editor.model.fragment.EditorFragmentData;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorSidebar;
import elements.Im;
import elements.Theme;

using StringTools;

enum EditorState {

    DEFAULT;

    EDIT_ENTITY(entity:EditorEntityData);

}

@:allow(editor.ui.EditorSidebar)
class Editor extends Scene {

    public var model:EditorData;

    var theme:Theme;

    @component var machine = new StateMachine<EditorState>();

    @component var keyBindings:KeyBindings;

    @component var sidebar:EditorSidebar;

    var nativeLayer:Layer;

    override function preload() {

        assets.add(Fonts.ROBOTO_BOLD);

    }

    override function create() {

        Im.allow(this);

        theme = Im.defaultTheme.clone();
        theme.windowBorderAlpha = 0;
        theme.windowBackgroundAlpha = 0;
        theme.tabsMarginY = 6;
        theme.formPadding = 12;
        theme.customBoldFont = assets.font(Fonts.ROBOTO_BOLD);

        model = new EditorData();

        initNativeLayer();
        initComponents();

        machine.autoUpdate = false;
        machine.state = DEFAULT;

    }

    function initComponents() {

        sidebar = new EditorSidebar();

    }

    function initNativeLayer() {

        nativeLayer = new Layer();
        nativeLayer.depth = 10;
        nativeLayer.bindToNativeScreenSize();

    }

    override function update(delta:Float) {

        machine.update(delta);

    }

/// State: DEFAULT

    function DEFAULT_update(delta) {

        sidebar.DEFAULT_update(delta);

    }

}
