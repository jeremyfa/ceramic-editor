package editor;

import ceramic.Color;
import ceramic.KeyBindings;
import ceramic.Layer;
import ceramic.Quad;
import ceramic.Scene;
import ceramic.StateMachine;
import ceramic.Timer;
import editor.model.EditorData;
import editor.model.fragment.EditorFragmentData;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorFragmentView;
import editor.ui.EditorSidebar;
import elements.Im;
import elements.Theme;

using StringTools;

enum EditorState {

    DEFAULT;

    EDIT_VISUAL;

}

@:allow(editor.ui.EditorSidebar)
@:allow(editor.ui.EditorFragmentView)
class Editor extends Scene {

    public static final VERSION:Int = 1;

    public var model:EditorData;

    var theme:Theme;

    var themeWithBackground:Theme;

    @component var machine = new StateMachine<EditorState>();

    @component var keyBindings:KeyBindings;

    @component var sidebar:EditorSidebar;

    @component public var fragmentView:EditorFragmentView;

    @owner var nativeLayer:Layer;

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

        themeWithBackground = theme.clone();
        themeWithBackground.windowBackgroundAlpha = 1;

        model = new EditorData();

        initNativeLayer();
        initComponents();

        machine.autoUpdate = false;
        machine.state = DEFAULT;

        autorun(updateFromSelectedFragment);

    }

    function initComponents() {

        sidebar = new EditorSidebar();

        fragmentView = new EditorFragmentView();

    }

    function initNativeLayer() {

        nativeLayer = new Layer();
        nativeLayer.depth = 10;
        nativeLayer.bindToNativeScreenSize();

    }

    override function layout() {
        super.layout();

        if (fragmentView != null) {
            fragmentView.pos(
                sidebar.sidebarWidth,
                0
            );
            fragmentView.size(
                screen.nativeWidth - sidebar.sidebarWidth,
                screen.nativeHeight
            );
        }
    }

    function updateFromSelectedFragment() {

        final selectedFragment = model.project.selectedFragment;
        if (selectedFragment != null) {
            unobserve();
            fragmentView.active = true;
        }
        else {
            unobserve();
            fragmentView.active = false;
        }

    }

    override function update(delta:Float) {

        machine.update(delta);

    }

/// State: DEFAULT

    function DEFAULT_update(delta) {

        sidebar.DEFAULT_update(delta);

    }

}
