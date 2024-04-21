package editor.ui;

import ceramic.Component;
import ceramic.Entity;
import ceramic.Quad;
import editor.model.EditorData;
import editor.model.fragment.EditorFragmentData;
import elements.Im;
import tracker.Observable;

using StringTools;

enum abstract EditorSidebarTab(Int) {

    var NONE;

    var PROJECT;

    var EDITION;

}

@:allow(editor.Editor)
@stateMachine({ checkFields: false })
class EditorSidebar extends Entity implements Component implements Observable {

    var model(get,never):EditorData;
    inline function get_model():EditorData {
        return editor.model;
    }

    @entity var editor:Editor;

    @compute function sidebarTitle():String {
        return 'Fragments: ${model.project.displayName ?? model.project.name}${model.projectUnsavedChanges ? '*' : ''}';
    }

    @compute function fragmentsList():Array<EditorFragmentListItem> {
        return model.project.fragments.original.map(fragment -> fragment.listItem);
    }

    var sidebarWidth:Int = 300;

    function bindAsComponent() {

        final sidebarBackground = new Quad();
        sidebarBackground.color = editor.theme.windowBackgroundColor;
        sidebarBackground.pos(0, 0);
        editor.nativeLayer.add(sidebarBackground);

        final sidebarRightBorder = new Quad();
        sidebarRightBorder.pos(sidebarWidth, 0);
        sidebarRightBorder.color = editor.theme.windowBorderColor;
        sidebarRightBorder.alpha = Im.defaultTheme.windowBorderAlpha;
        editor.nativeLayer.add(sidebarRightBorder);

        function layout(nativeWidth:Float, nativeHeight:Float) {
            sidebarBackground.size(sidebarWidth, nativeHeight);
            sidebarRightBorder.size(1, nativeHeight);
        }

        editor.nativeLayer.onResize(this, layout);
        layout(screen.nativeWidth, screen.nativeHeight);

    }

    function DEFAULT_update(delta:Float) {

        Im.theme(editor.theme);

        final window = Im.begin(
            'Fragments', sidebarTitle,
            sidebarWidth
        );

        Im.position(0, 0);
        Im.expanded();

        Im.beginRow();

        if (Im.button('Open')) {
            if (model.projectUnsavedChanges) {
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
        if (input.scanPressed(LSHIFT, window) || input.scanPressed(RSHIFT, window)) {
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
            if (model.projectUnsavedChanges) {
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
        Im.beginTabs(Im.string());

        var tab:EditorSidebarTab = NONE;

        if (Im.tab('Project')) tab = PROJECT;
        if (Im.tab('Edition')) tab = EDITION;

        Im.endTabs();

        Im.end();

        Im.begin('Fragments_Content', sidebarWidth, screen.nativeHeight - 96);

        Im.header(false);
        Im.expanded();
        Im.position(0, 96);

        if (tab == PROJECT) {

            // Project display name
            var displayName = model.project.displayName;
            Im.editText('Name', Im.string(displayName), false, model.project.name);
            model.project.displayName = displayName != null && displayName.trim().length > 0 ? displayName : null;

            Im.space(0);

            Im.bold(true);
            Im.text('Fragments');
            Im.bold(false);

            var fragmentsList = this.fragmentsList;
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

        }

        Im.space(0);
        Im.end();
        Im.theme(null);

    }

}
