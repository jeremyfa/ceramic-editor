package editor.model;

import ceramic.Assets;
import ceramic.Equal;
import ceramic.Files;
import ceramic.Path;
import ceramic.ReadOnlyArray;
import ceramic.ReadOnlyMap;
import ceramic.Texture;
import editor.model.fragment.EditorFragmentData;
import editor.ui.EditorFragmentListItem;
import editor.ui.EditorSidebarTab;
import editor.utils.Validate;
import tracker.History;
import tracker.Model;

class EditorProjectData extends Model {

    var editorData(default, null):EditorData;

    public var history(get,never):History;
    function get_history():History {
        return editorData.history;
    }

    @serialize public var name:String;

    @serialize public var displayName:String;

    @serialize public var filePath:String = null;

    @serialize public var unsavedChanges:Bool = false;

    @serialize public var fragments:ReadOnlyArray<EditorFragmentData> = [];

    @serialize public var selectedFragmentIndex:Int = -1;

    @serialize public var selectedTab:EditorSidebarTab = NONE;

    @compute public function assetsDirectory():String {

        var filePath = this.filePath;
        if (filePath == null) {
            return null;
        }

        return Path.directory(filePath);

    }

    var lastAssetsDirectory:String = null;
    @compute public function assets():Assets {

        final assetsDirectory = this.assetsDirectory;
        unobserve();

        // Do not do anything if previous assets directory is the same
        if (lastAssetsDirectory == assetsDirectory) {
            return this.unobservedAssets;
        }
        lastAssetsDirectory = assetsDirectory;

        // Destroy previous assets instance
        if (this.unobservedAssets != null) {
            final prevAssets = this.unobservedAssets;
            app.onceImmediate(prevAssets, prevAssets.destroy);
        }

        // Check that assets directory exists
        if (!Files.exists(assetsDirectory) || !Files.isDirectory(assetsDirectory)) {
            log.warning('Not a valid assets directory: ' + assetsDirectory);
            return null;
        }

        // Create new assets
        var assets = new Assets();
        assets.parent = app.assets;
        assets.watchDirectory(assetsDirectory);

        return assets;

    }

    @compute public function images():ReadOnlyArray<{
        name: String,
        paths: Array<String>,
        constName: String
    }> {

        final assets = this.assets;
        unobserve();

        final result = if (assets != null) {
            assets.runtimeAssets.getNames('image');
        }
        else {
            [];
        }

        return Equal.equal(unobservedImages, result) ? unobservedImages : result;

    }

    @compute public function imagesByName():ReadOnlyMap<String,{
        name: String,
        paths: Array<String>,
        constName: String
    }> {

        final images = this.images;
        unobserve();

        var result = new Map();

        for (image in images) {
            result.set(image.name, image);
        }

        return result;

    }

    @compute public function selectedFragment():EditorFragmentData {
        final selectedFragmentIndex = this.selectedFragmentIndex;
        if (selectedFragmentIndex >= 0) {
            return fragments[selectedFragmentIndex];
        }
        return null;
    }

    @observe public var loadingImages:ReadOnlyArray<String> = [];

    public function texture(name:String):Texture {

        final assets = this.assets;
        if (assets != null) {
            final image = imagesByName.get(name);
            if (image != null) {
                final texture = assets.texture(name);
                if (texture == null) {
                    final loadingImages = this.loadingImages;
                    if (!loadingImages.contains(name)) {
                        loadTexture(name);
                    }
                }
                else {
                    return texture;
                }
            }
        }

        return null;

    }

    public function loadTexture(name:String) {
        unobserve();
        final assets = this.assets;
        if (assets != null) {
            final image = imagesByName.get(name);
            if (image != null) {
                var loadingImages = this.loadingImages.original;
                if (!loadingImages.contains(name)) {
                    loadingImages = [].concat(loadingImages);
                    loadingImages.push(name);
                    this.loadingImages = loadingImages;
                }
                assets.ensureImage(name, null, null, imageAsset -> {
                    if (imageAsset != null) {
                        if (this.assets == assets) {
                            var loadingImages = [].concat(this.loadingImages.original);
                            final nameIndex = loadingImages.indexOf(name);
                            if (nameIndex != -1) {
                                loadingImages.splice(nameIndex, 1);
                                this.loadingImages = loadingImages;
                            }
                        }
                    }
                });
            }
        }
        reobserve();
    }

    public function new(editorData:EditorData, name:String = 'Untitled') {
        super();

        this.editorData = editorData;
        this.name = name;

        init();
    }

    override function didDeserialize() {
        super.didDeserialize();

        init();
    }

    function init() {
        onAssetsChange(this, (_, _) -> {
            loadingImages = [];
        });
    }

    public function syncFromFragmentsList(fragmentsList:Array<EditorFragmentListItem>):Void {
        var result = [];
        for (fragmentItem in fragmentsList) {
            var fragment = getFragment(fragmentItem.fragment.fragmentId);
            result.push(fragment);
        }
        var prevFragments = this.fragments;
        this.fragments = result;
        for (fragment in prevFragments) {
            if (getFragment(fragment.fragmentId) == null) {
                fragment.destroy();
            }
        }
    }

    public function getFragment(fragmentId:String) {
        var fragments = this.fragments;
        for (i in 0...fragments.length) {
            if (fragments[i].fragmentId == fragmentId) {
                return fragments[i];
            }
        }
        return null;
    }

    public function addFragment() {

        var fragment = new EditorFragmentData(this);
        var i = 0;
        while (getFragment('FRAGMENT_$i') != null) {
            i++;
        }
        fragment.fragmentId = 'FRAGMENT_$i';

        var newFragments = [].concat(this.fragments.original);
        newFragments.push(fragment);
        this.fragments = newFragments;

        return fragment;

    }

    public function clone(?toProject:EditorProjectData) {

        if (toProject == null)
            toProject = new EditorProjectData(editorData);

        toProject.fromJson(toJson());

    }

    public function clear():Void {

        name = 'Untitled';
        displayName = null;
        filePath = null;
        selectedFragmentIndex = -1;
        selectedTab = NONE;

        var prevFragments = fragments;
        fragments = [];
        for (fragment in prevFragments) {
            fragment.destroy();
        }

    }

    public function fromJson(json:Dynamic):Void {

        if (!Validate.int(json.version) || json.version > Editor.VERSION) {
            throw "Unsupported fragments file version: " + json.version;
        }

        if (!Validate.identifier(json.name))
            throw 'Invalid project name: ' + json.name;
        this.name = json.name;

        if (json.displayName != null) {
            if (!Validate.nonEmptyString(json.displayName))
                throw 'Invalid project display name: ' + json.displayName;
            this.displayName = json.displayName;
        }

        if (Reflect.hasField(json, 'fragments')) {
            if (!Validate.array(json.fragments))
                throw 'Invalid project fragments';

            var jsonFragments:Array<Dynamic> = json.fragments;
            var parsedFragments = [];
            for (jsonFragment in jsonFragments) {
                var fragment = new EditorFragmentData(this);
                fragment.fromJson(jsonFragment);
                parsedFragments.push(fragment);
            }
            this.fragments = cast parsedFragments;
        }
        else {
            this.fragments = [];
        }

        var selectedFragmentIndex = -1;
        if (Reflect.hasField(json, 'selectedFragment')) {
            if (!Validate.int(json.selectedFragment))
                throw 'Invalid project selected fragment';

            selectedFragmentIndex = Std.int(json.selectedFragment);
        }
        else {
            selectedFragmentIndex = -1;
        }
        if (selectedFragmentIndex >= fragments.length || selectedFragmentIndex < -1) {
            selectedFragmentIndex = -1;
        }
        this.selectedFragmentIndex = selectedFragmentIndex;

    }

    public function toJson():Dynamic {
        var json:Dynamic = {};

        json.version = Editor.VERSION;
        json.name = this.name;
        if (this.displayName != null) {
            json.displayName = this.displayName;
        }
        json.fragments = this.fragments.map(fragment -> fragment.toJson());
        json.selectedFragment = this.selectedFragmentIndex;
        json.selectedTab = this.selectedTab;

        json.schema = {};
        var usedEntityClasses = new Map<String,Bool>();
        for (fragment in this.fragments) {

            for (visual in fragment.visuals) {
                final entityClass = visual.entityClass;
                if (!usedEntityClasses.exists(entityClass)) {
                    usedEntityClasses.set(entityClass, true);
                    Reflect.setField(
                        json.schema, entityClass,
                        visual.schema()
                    );
                }
            }

            for (entity in fragment.entities) {
                final entityClass = entity.entityClass;
                if (!usedEntityClasses.exists(entityClass)) {
                    usedEntityClasses.set(entityClass, true);
                    Reflect.setField(
                        json.schema, entityClass,
                        entity.schema()
                    );
                }
            }
        }

        return json;
    }

}
