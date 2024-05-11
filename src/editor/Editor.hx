package editor;

import ceramic.Color;
import ceramic.Key;
import ceramic.KeyBindings;
import ceramic.Layer;
import ceramic.Quad;
import ceramic.ScanCode;
import ceramic.Scene;
import ceramic.StateMachine;
import ceramic.Timer;
import editor.model.EditorData;
import editor.model.fragment.EditorFragmentData;
import editor.model.fragment.EditorVisualData;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorFragmentView;
import editor.ui.EditorSidebar;
import editor.utils.Validate;
import elements.FieldSystem;
import elements.Im;
import elements.Theme;
import haxe.Json;

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

    var lastPastedDepth:Float = -1;

    var lastPastedClipboardText:String = null;

    @component var machine = new StateMachine<EditorState>();

    @component var keyBindings:KeyBindings;

    @component var sidebar:EditorSidebar;

    @component public var fragmentView:EditorFragmentView;

    @owner var nativeLayer:Layer;

    var pendingOpenFilePath:String = null;

    public function new() {
        super();
        checkOpenWithPath();
    }

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

        bindKeyBindings();

        if (pendingOpenFilePath != null) {
            model.openProjectWithPath(pendingOpenFilePath);
            pendingOpenFilePath = null;
        }

    }

    function checkOpenWithPath() {

        var projectFilePath:String = null;

        #if cpp

        final argv = Sys.args();
        if (argv.length > 1 && sys.FileSystem.exists(argv[1])) {
            projectFilePath = argv[1];
        }

        #if linc_sdl
        app.backend.onSdlEvent(this, sdlEvent -> {
            if (sdlEvent.type == SDL_DROPFILE) {
                var filePath:String = sdlEvent.drop.file;
                if (sys.FileSystem.exists(filePath)) {
                    if (status == READY) {
                        model.openProjectWithPath(filePath);
                    }
                    else {
                        pendingOpenFilePath = filePath;
                    }
                }
            }
        });
        #end

        #end

        if (projectFilePath != null) {
            if (status == READY) {
                model.openProjectWithPath(projectFilePath);
            }
            else {
                pendingOpenFilePath = projectFilePath;
            }
        }

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

    function bindKeyBindings() {

        input.onKeyDown(this, handleKeyDown);

        keyBindings = new KeyBindings();

        keyBindings.bind([CMD_OR_CTRL, KEY(KEY_Z)], function() {
            model.history.undo();
        });

        keyBindings.bind([CMD_OR_CTRL, SHIFT, KEY(KEY_Z)], function() {
            model.history.redo();
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KEY_C)], function() {
            if (FieldSystem.shared.focusedField == null && screen.focusedVisual != null && screen.focusedVisual.hasIndirectParent(fragmentView)) {
                final selectedFragment = model.project.selectedFragment;
                if (selectedFragment != null) {
                    final selectedVisual = selectedFragment.selectedVisual;
                    if (selectedVisual != null) {
                        log.debug('Copy to clipboard: visual "${selectedVisual.entityId}"');
                        app.backend.clipboard.setText('{"ceramic-editor":{"visual":' + Json.stringify(selectedVisual.toJson()) + '}}');
                    }
                }
            }
        });

        keyBindings.bind([CMD_OR_CTRL, KEY(KEY_V)], function() {
            if (FieldSystem.shared.focusedField == null) {
                final clipboardText = app.backend.clipboard.getText();
                final isSameClipboardText = (clipboardText != null && lastPastedClipboardText == clipboardText);
                if (clipboardText != null && clipboardText.startsWith('{"ceramic-editor":')) {
                    final selectedFragment = model.project.selectedFragment;
                    if (selectedFragment != null) {
                        try {
                            final parsed:Dynamic = Reflect.field(Json.parse(clipboardText), 'ceramic-editor');
                            if (parsed.visual != null) {
                                // Paste visual
                                final visual = EditorVisualData.create(selectedFragment, parsed.visual.kind);
                                if (parsed.visual.depth != null && Validate.float(parsed.visual.depth)) {
                                    if (isSameClipboardText) {
                                        visual.depth = lastPastedDepth;
                                    }
                                    else {
                                        visual.depth = parsed.visual.depth;
                                    }
                                }
                                selectedFragment.add(visual);
                                visual.fromJson(parsed.visual);
                                visual.x += 25;
                                visual.y += 25;
                                selectedFragment.selectVisual(visual);

                                model.history.step();
                                app.oncePostFlushImmediate(this, () -> {
                                    lastPastedClipboardText = clipboardText;
                                    lastPastedDepth = visual.depth;
                                });
                            }
                        }
                        catch (e:Dynamic) {
                            log.error('Failed to parse clipboard text: $e');
                        }
                    }
                }
            }
        });

    }

    function handleKeyDown(key:Key) {

        if (key.scanCode == ScanCode.BACKSPACE) {
            if (FieldSystem.shared.focusedField == null && screen.focusedVisual != null && screen.focusedVisual.hasIndirectParent(fragmentView)) {
                final selectedFragment = model.project.selectedFragment;
                if (selectedFragment != null) {
                    final selectedVisual = selectedFragment.selectedVisual;
                    if (selectedVisual != null) {
                        // Remove visual
                        selectedFragment.selectedVisualIndex = -1;
                        selectedFragment.remove(selectedVisual);
                        selectedVisual.destroy();

                        model.history.step();
                    }
                }
            }
        }

    }

/// State: DEFAULT

    function DEFAULT_update(delta) {

        sidebar.DEFAULT_update(delta);

    }

}
