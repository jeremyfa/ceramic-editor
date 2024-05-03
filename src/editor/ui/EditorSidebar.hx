package editor.ui;

import ceramic.Color;
import ceramic.Component;
import ceramic.Entity;
import ceramic.Quad;
import ceramic.ReadOnlyArray;
import editor.model.EditorData;
import editor.model.fragment.EditorFragmentData;
import editor.model.fragment.EditorQuadData;
import editor.model.fragment.EditorVisualData;
import elements.Im;
import tracker.Observable;

using StringTools;
using editor.ui.EditorImExtensions;

@:allow(editor.Editor)
@stateMachine({ checkFields: false })
class EditorSidebar extends Entity implements Component implements Observable {

    var model(get,never):EditorData;
    inline function get_model():EditorData {
        return editor.model;
    }

    var visualTypeList:ReadOnlyArray<String> = ['Visual', 'Quad'/*, 'Text'*/];

    @entity var editor:Editor;

    @compute function sidebarTitle():String {
        return 'Fragments: ${model.project.displayName ?? model.project.name}${model.project.unsavedChanges ? '*' : ''}';
    }

    @compute function visualsTitle():String {
        var selectedFragment = model.project.selectedFragment;
        if (selectedFragment != null) {
            return 'Visuals (' + selectedFragment.fragmentId + ')';
        }
        else {
            return 'Visuals';
        }
    }

    @compute function fragmentsList():Array<EditorFragmentListItem> {
        return model.project.fragments.original.map(fragment -> fragment.listItem);
    }

    @compute function visualsList():Array<EditorVisualListItem> {
        var selectedFragment = model.project.selectedFragment;
        if (selectedFragment != null) {
            return selectedFragment.visuals.original.map(visual -> visual.listItem);
        }
        else {
            return [];
        }
    }

    @compute function imagesList():Array<String> {
        return model.project.images.map(image -> image.name);
    }

    var sidebarWidth:Int = 300;

    var sidebarTopHeight:Int = 96;

    function bindAsComponent() {

        final sidebarBackground = new Quad();
        sidebarBackground.color = editor.theme.windowBackgroundColor;
        sidebarBackground.pos(0, 0);
        sidebarBackground.depth = 100;
        editor.nativeLayer.add(sidebarBackground);

        final sidebarRightBorder = new Quad();
        sidebarRightBorder.pos(sidebarWidth, 0);
        sidebarRightBorder.color = 0x404040;
        sidebarRightBorder.alpha = Im.defaultTheme.windowBorderAlpha;
        sidebarRightBorder.depth = 100;
        editor.nativeLayer.add(sidebarRightBorder);

        function layout(nativeWidth:Float, nativeHeight:Float) {
            sidebarBackground.size(sidebarWidth, nativeHeight);
            sidebarRightBorder.size(1, nativeHeight);
        }

        editor.nativeLayer.onResize(this, layout);
        layout(screen.nativeWidth, screen.nativeHeight);

    }

    function DEFAULT_update(delta:Float) {

        var selectedFragment = model.project.selectedFragment;

        Im.theme(editor.theme);

        final window = Im.begin(
            'Fragments', sidebarTitle,
            sidebarWidth
        );

        Im.position(0, 0);
        Im.expanded();

        Im.beginRow();

        if (Im.button('Open')) {
            if (model.project.unsavedChanges) {
                app.onceImmediate(this, () -> {
                    Im.confirm(
                        'Unsaved changes', 'You have unsaved changes that will be lost if you continue.',
                        'Confirm open', 'Cancel',
                        model.openProject
                    );
                });
            }
            else {
                model.openProject();
            }
        }
        if ((input.scanPressed(LSHIFT, window) || input.scanPressed(RSHIFT, window)) && window.hits(screen.pointerX, screen.pointerY)) {
            if (Im.button('Save as')) {
                model.saveProjectAs();
            }
        }
        else {
            if (Im.button('Save')) {
                model.saveProject();
            }
        }
        if (Im.button('New')) {
            if (model.project.unsavedChanges) {
                app.onceImmediate(this, () -> {
                    Im.confirm(
                        'Unsaved changes', 'You have unsaved changes that will be lost if you continue.',
                        'Confirm new', 'Cancel',
                        model.newProject
                    );
                });
            }
            else {
                model.newProject();
            }
        }

        Im.endRow();

        Im.space(0);
        Im.beginTabs(Im.string(model.project.selectedTab));

        Im.tab(EditorSidebarTab.PROJECT);

        Im.disabled(selectedFragment == null);
        Im.tab(EditorSidebarTab.VISUALS);
        Im.disabled(false);

        Im.endTabs();

        Im.end();

        if (model.project.selectedTab == PROJECT) {

            Im.begin('Fragments_Project', sidebarWidth, screen.nativeHeight - sidebarTopHeight);

            Im.header(false);
            Im.expanded();
            Im.position(0, sidebarTopHeight);

            // Project display name
            var displayName = model.project.displayName;
            Im.editText('Project Name', Im.string(displayName), false, model.project.name);
            model.project.displayName = displayName != null && displayName.trim().length > 0 ? displayName : null;

            Im.separator();

            var fragmentsList = this.fragmentsList;

            if (fragmentsList.length > 0) {

                Im.disabled(selectedFragment == null);

                Im.sectionTitle('Current Fragment');

                if (selectedFragment == null) {
                    Im.editText('Name', Im.string(), 'Select a fragment in list');

                    Im.beginTwoFieldsRow();
                    Im.editText(Im.string());
                    Im.betweenTwoFieldsCross();
                    Im.editText(Im.string());
                    Im.endTwoFieldsRow('Size');

                    var transparent = false;
                    Im.check('Transparent', Im.bool(transparent));
                    Im.editText('Color', Im.string());
                }
                else {
                    final status = Im.editText('Name', Im.string(selectedFragment.edit_fragmentId));
                    if (status.blurred || status.submitted) {
                        // Assigning will ensure the fragment id doesn't collide with any existing one,
                        // and it will also ensure only allowed characters are accepted
                        selectedFragment.changeFragmentId(selectedFragment.edit_fragmentId);
                        selectedFragment.edit_fragmentId = selectedFragment.fragmentId;
                    }

                    Im.beginTwoFieldsRow();
                    Im.editInt(Im.int(selectedFragment.width), null, 0, 999999999);
                    Im.betweenTwoFieldsCross();
                    Im.editInt(Im.int(selectedFragment.height), null, 0, 999999999);
                    Im.endTwoFieldsRow('Size');

                    Im.check('Transparent', Im.bool(selectedFragment.transparent));

                    Im.disabled(selectedFragment.transparent);
                    Im.editColor('Color', Im.color(selectedFragment.color));
                    Im.disabled(false);
                }

                Im.disabled(false);

                Im.separator();
            }

            Im.sectionTitle('Fragments');

            if (fragmentsList.length > 0) {
                final status = Im.list(Im.array(fragmentsList), Im.int(model.project.selectedFragmentIndex), true, true, true, true);
                final lockedItems = status.lockedItems;
                final unlockedItems = status.unlockedItems;
                final duplicateItems = status.duplicateItems;
                for (i in 0...lockedItems.length) {
                    final item:EditorFragmentListItem = lockedItems[i];
                    item.fragment.locked = true;
                }
                for (i in 0...unlockedItems.length) {
                    final item:EditorFragmentListItem = unlockedItems[i];
                    item.fragment.locked = false;
                }
                for (i in 0...duplicateItems.length) {
                    final item:EditorFragmentListItem = duplicateItems[i];
                    final fragment = item.fragment;
                    ((fragment:EditorFragmentData) -> {
                        app.onceImmediate(this, () -> {
                            final newFragment = model.project.addFragment();
                            fragment.clone(newFragment);
                            model.project.selectedFragmentIndex = model.project.fragments.length - 1;
                        });
                    })(fragment);
                }
                if (fragmentsList != this.fragmentsList) {
                    model.project.syncFromFragmentsList(fragmentsList);
                }
            }

            if (Im.button('Add Fragment')) {
                app.onceImmediate(this, () -> {
                    model.project.addFragment();
                    model.project.selectedFragmentIndex = model.project.fragments.length - 1;
                });
            }

            Im.space(0);
            Im.end();
        }

        if (model.project.selectedTab == VISUALS && selectedFragment != null) {

            Im.begin('Fragments_Visuals', sidebarWidth, screen.nativeHeight - sidebarTopHeight);

            Im.header(false);
            Im.expanded();
            Im.position(0, sidebarTopHeight);

            Im.scrollbar(AUTO_ADD_STAY);

            Im.sectionTitle(visualsTitle);

            var visualsList = this.visualsList;
            var selectedVisual = selectedFragment.selectedVisual;

            if (visualsList.length > 0) {
                final status = Im.list(Im.array(visualsList), Im.int(selectedFragment.selectedVisualIndex), true, true, true, true);
                final lockedItems = status.lockedItems;
                final unlockedItems = status.unlockedItems;
                final duplicateItems = status.duplicateItems;
                for (i in 0...lockedItems.length) {
                    final item:EditorVisualListItem = lockedItems[i];
                    item.visual.locked = true;
                }
                for (i in 0...unlockedItems.length) {
                    final item:EditorVisualListItem = unlockedItems[i];
                    item.visual.locked = false;
                }
                for (i in 0...duplicateItems.length) {
                    final item:EditorVisualListItem = duplicateItems[i];
                    final visual = item.visual;
                    ((visual:EditorVisualData) -> {
                        app.onceImmediate(this, () -> {
                            final newVisual = selectedFragment.addVisual(Type.getClass(visual));
                            visual.clone(newVisual);
                            selectedFragment.selectedVisualIndex = selectedFragment.visuals.length - 1;
                        });
                    })(visual);
                }
                if (visualsList != this.visualsList) {
                    selectedFragment.syncFromVisualsList(visualsList);
                }
            }

            if (Im.button('Add Visual')) {
                app.onceImmediate(this, addVisualChoice);
            }

            if (visualsList.length > 0) {

                Im.separator();

                Im.disabled(selectedVisual == null);

                if (selectedVisual != null) {
                    switch Type.getClass(selectedVisual) {
                        case EditorVisualData:
                            Im.sectionTitle('Current Visual');
                        case EditorQuadData:
                            Im.sectionTitle('Current Quad');
                    }
                }
                else {
                    Im.sectionTitle('Current Visual');
                }

                if (selectedVisual == null) {
                    Im.editText('Name', Im.string(), 'Select a visual in list');

                    Im.beginTwoFieldsRow();
                    Im.editText(Im.string());
                    Im.betweenTwoFieldsCross(true);
                    Im.editText(Im.string());
                    Im.endTwoFieldsRow('Size');

                    Im.text('Position');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editText('x', Im.string());
                    Im.betweenTwoFieldsRow('');
                    Im.editText('y', Im.string());
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Scale');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editText('x', Im.string());
                    Im.betweenTwoFieldsRow('');
                    Im.editText('y', Im.string());
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Anchor');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editText('x', Im.string());
                    Im.betweenTwoFieldsRow('');
                    Im.editText('y', Im.string());
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Skew');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editText('x', Im.string());
                    Im.betweenTwoFieldsRow('');
                    Im.editText('y', Im.string());
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Rotation');

                    Im.editText(Im.string());

                    Im.text('Alpha');

                    Im.editText(Im.string());
                }
                else {

                    final status = Im.editText('Name', Im.string(selectedVisual.edit_entityId));
                    if (status.blurred || status.submitted) {
                        // Assigning will ensure the fragment id doesn't collide with any existing one,
                        // and it will also ensure only allowed characters are accepted
                        selectedVisual.changeEntityId(selectedVisual.edit_entityId);
                        selectedVisual.edit_entityId = selectedVisual.entityId;
                    }

                    Im.disabled(!selectedVisual.resizeInsteadOfScale);

                    Im.beginTwoFieldsRow();
                    Im.editFloat(Im.float(selectedVisual.width), null, 0, 999999999, 100);
                    Im.betweenTwoFieldsCross();
                    Im.editFloat(Im.float(selectedVisual.height), null, 0, 999999999, 100);
                    Im.endTwoFieldsRow('Size');

                    Im.disabled(false);

                    Im.text('Position');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editFloat('x', Im.float(selectedVisual.x), null, -999999999, 999999999, 100);
                    Im.betweenTwoFieldsRow('');
                    Im.editFloat('y', Im.float(selectedVisual.y), null, -999999999, 999999999, 100);
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Scale');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editFloat('x', Im.float(selectedVisual.scaleX), null, -1, 1, 100);
                    Im.betweenTwoFieldsRow('');
                    Im.editFloat('y', Im.float(selectedVisual.scaleY), null, -1, 1, 100);
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Anchor');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editFloat('x', Im.float(selectedVisual.anchorX), null, -1, 1, 100);
                    Im.betweenTwoFieldsRow('');
                    Im.editFloat('y', Im.float(selectedVisual.anchorY), null, -1, 1, 100);
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Skew');

                    Im.beginTwoFieldsRow();
                    Im.labelPosition(LEFT);
                    Im.labelWidth(5);
                    Im.editFloat('x', Im.float(selectedVisual.skewX), null, -360, 360, 100);
                    Im.betweenTwoFieldsRow('');
                    Im.editFloat('y', Im.float(selectedVisual.skewY), null, -360, 360, 100);
                    Im.labelPosition();
                    Im.labelWidth();
                    Im.endTwoFieldsRow();

                    Im.text('Rotation');

                    Im.slideFloat(Im.float(selectedVisual.rotation), -360, 360, 1);

                    Im.text('Alpha');

                    Im.slideFloat(Im.float(selectedVisual.alpha), 0, 1, 100);


                    switch Type.getClass(selectedVisual) {

                        case EditorQuadData:
                            final selectedQuad:EditorQuadData = cast selectedVisual;

                            Im.separator();
                            Im.sectionTitle('Quad settings');

                            Im.editColor('Color', Im.color(selectedQuad.color));
                            Im.check('Transparent', Im.bool(selectedQuad.transparent));

                            Im.text('Texture');
                            Im.editText(Im.string(selectedQuad.texture), false, null, imagesList);

                    }
                }

                Im.disabled(false);
            }

            Im.space(0);
            Im.end();

        }

        Im.theme(null);

    }

    function addVisualChoice() {

        var selectedFragment = model.project.selectedFragment;
        if (selectedFragment == null)
            return;

        Im.choice('Add Visual', 'Choose the type of visual to add:', true, visualTypeList.original, (index, text) -> {
            final added:EditorVisualData = switch text {
                case 'Visual': selectedFragment.addVisual();
                case 'Quad': selectedFragment.addQuad();
                case 'Text': selectedFragment.addText();
                case _: null;
            }
            if (added != null) {
                added.x = selectedFragment.width * 0.5;
                added.y = selectedFragment.height * 0.5;
            }
            selectedFragment.selectedVisualIndex = selectedFragment.visuals.length - 1;
        });

    }

}
