package editor;

import haxe.rtti.Meta;
//import haxe.rtti.Rtti;
import haxe.DynamicAccess;

import editor.model.*;
import editor.ui.*;
import editor.utils.TextUtils;

#if spine
import ceramic.SpinePlugin;
#end

/** Turns the app into an editor. */
class Editor extends Entity implements Observable {

    public static var editor(default,null):Editor = null;

/// Public properties

    /**
     * Assets used to make the editor work properly (fonts/icons, mostly)
     */
    public var editorAssets:Assets;

    /**
     * Assets used by the content being edited (fragments)
     */
    public var contentAssets:Assets;

    public var model:EditorData;

    public var view:EditorView;

    public var playView:EditorPlayView;

    public var editableTypes:ImmutableArray<EditableType> = [];

    public var editableVisuals:ImmutableArray<EditableType> = [];

    public var editableEntities:ImmutableArray<EditableType> = [];

/// Internal properties

    @observe var pendingFile:String = null;

    var renders:Int = 0;

    var options:EditorOptions;

    @owner var dropFile:DropFile;

/// Internal statics

    static var BASIC_TYPES:Map<String,Bool> = [
        'Bool' => true,
        'Int' => true,
        'Float' => true,
        'String' => true
    ];

/// Lifecycle

    public function new(settings:InitSettings, options:EditorOptions) {

        super();

        if (editor != null) throw 'Only one single editor can be created.';
        editor = this;

        this.options = options;

        settings.antialiasing = 4;
        settings.background = 0x282828;
        settings.targetWidth = 1400;
        settings.targetHeight = 860;
        settings.resizable = true;
        settings.scaling = FIT;
        settings.title = 'Ceramic Editor';

        app.onceReady(this, loadAssets);

        dropFile = new DropFile();
        dropFile.onDropFile(this, filePath -> {
            pendingFile = filePath;
        });

    }

    function loadAssets() {

        trace('LOAD EDITOR ASSETS & INIT CONTENT ASSETS');

        contentAssets = new Assets();
        contentAssets.defaultImageOptions = {
            premultiplyAlpha: true
        };
        if (options != null) {
            if (options.assets != null) {
                if (options.assets != settings.assetsPath) {
                    trace('new runtime assets ${options.assets}');
                    contentAssets.watchDirectory(options.assets);
                    //contentAssets.runtimeAssets = RuntimeAssets.fromPath(options.assets);
                }
            } 
        }

        editorAssets = new Assets();
        
        editorAssets.add(Fonts.ROBOTO_BOLD);

        editorAssets.add(Fonts.ENTYPO);

        editorAssets.onceComplete(this, assetsLoaded);

        editorAssets.load();

        /*
        contentAssets.add(Images.ICONS); // TODO remove?
        contentAssets.add(Texts.SOME_TEXT); // TODO remove?
        contentAssets.onceComplete(this, success -> {

            var quad = new Quad();
            quad.depth = 99998;
            quad.texture = contentAssets.texture(Images.ICONS);
            quad.pos(screen.width * 0.5, screen.height * 0.5);
            quad.anchor(0.5, 0.5);
            quad.scale(0.25);
            quad.skewX = 20;

            var text = new Text();
            text.depth = 99999;
            text.pointSize = 40;
            text.color = Color.RED;
            text.align = CENTER;
            text.anchor(0.5, 0.5);
            text.pos(screen.width * 0.5, screen.height * 0.5);
            text.autorun(() -> {
                text.content = contentAssets.text(Texts.SOME_TEXT);
            });
        });
        contentAssets.load();
        //*/

    }

    function assetsLoaded(isSuccess:Bool) {

        if (!isSuccess) {
            log.error('Failed to load editor assets');
            return;
        }

        start();

    }

    public function start():Void {

        computeEditableTypes();

        initModel();

        app.onceUpdate(this, _ -> {
            app.onceUpdate(this, _ -> {
            
                bindKeyBindings();
    
                initView();
            });
        });

    }

/// Helpers

    public function getEditableType(entityClass:String):EditableType {

        for (i in 0...editableTypes.length) {
            var type = editableTypes[i];
            if (type.entity == entityClass) {
                return type;
            }
        }

        return null;

    }

    public function getEditableMeta(entityClass:String, ?key:String):Dynamic {

        var editableType = getEditableType(entityClass);
        if (editableType == null)
            return null;
        
        if (editableType.meta != null && editableType.meta.editable != null && Std.is(editableType.meta.editable, Array)) {
            var editableMeta:Dynamic = editableType.meta.editable[0];
            if (editableMeta == null)
                return null;
            if (key != null) {
                return Reflect.field(editableMeta, key);
            }
            else {
                return editableMeta;
            }
        }

        return null;

    }

    public function computeLists(model:EditorData) {

        // Images
        var images:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('image')) {
                images.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Images)) {
                var value:Dynamic = Reflect.field(Images, key);
                if (value != null && Std.is(value, String) && value.startsWith('image:')) {
                    images.push(value.substring(6));
                }
            }
        }
        images.sort(TextUtils.compareStrings);
        model.images = cast images;

        // Texts
        var texts:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('text')) {
                texts.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Texts)) {
                var value:Dynamic = Reflect.field(Texts, key);
                if (value != null && Std.is(value, String) && value.startsWith('text:')) {
                    texts.push(value.substring(5));
                }
            }
        }
        texts.sort(TextUtils.compareStrings);
        model.texts = cast texts;

        // Sounds
        var sounds:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('sound')) {
                sounds.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Sounds)) {
                var value:Dynamic = Reflect.field(Sounds, key);
                if (value != null && Std.is(value, String) && value.startsWith('sound:')) {
                    sounds.push(value.substring(6));
                }
            }
        }
        sounds.sort(TextUtils.compareStrings);
        model.sounds = cast sounds;

        // Fonts
        var fonts:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('font')) {
                fonts.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Fonts)) {
                var value:Dynamic = Reflect.field(Fonts, key);
                if (value != null && Std.is(value, String) && value.startsWith('font:')) {
                    fonts.push(value.substring(5));
                }
            }
        }
        fonts.sort(TextUtils.compareStrings);
        model.fonts = cast fonts;

        // Databases
        var databases:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('database')) {
                databases.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Databases)) {
                var value:Dynamic = Reflect.field(Databases, key);
                if (value != null && Std.is(value, String) && value.startsWith('database:')) {
                    databases.push(value.substring(9));
                }
            }
        }
        databases.sort(TextUtils.compareStrings);
        model.databases = cast databases;

        // Shaders
        var shaders:Array<String> = [];
        if (contentAssets.runtimeAssets != null) {
            for (item in contentAssets.runtimeAssets.getNames('shader')) {
                shaders.push(item.name);
            }
        }
        else {
            for (key in Reflect.fields(Shaders)) {
                var value:Dynamic = Reflect.field(Shaders, key);
                if (value != null && Std.is(value, String) && value.startsWith('shader:')) {
                    shaders.push(value.substring(7));
                }
            }
        }
        shaders.sort(TextUtils.compareStrings);
        model.shaders = cast shaders;

        // Custom assets
        var customAssets:DynamicAccess<Dynamic> = {};
        for (kindName in @:privateAccess Assets.customAssetKinds.keys()) {
            var assetKind = @:privateAccess Assets.customAssetKinds.get(kindName);
            if (contentAssets.runtimeAssets != null) {
                var info = contentAssets.runtimeAssets.getNames(
                    assetKind.kind,
                    assetKind.extensions,
                    assetKind.dir
                );
                customAssets.set(assetKind.kind, {
                    lists: info,
                    types: assetKind.types
                });
            }
        }

    }

/// Internal

    function computeEditableTypes():Void {

        var editableTypes:Array<EditableType> = [];
        var editableVisuals:Array<EditableType> = [];
        var editableEntities:Array<EditableType> = [];

        // Compute editable types
        for (key in Reflect.fields(app.info.editable)) {

            var classPath = Reflect.field(app.info.editable, key);

            var clazz = Type.resolveClass(classPath);
            var usedFields = new Map();
            var fields:Array<EditableTypeField> = [];
            var fieldInfo = FieldInfo.editableFieldInfo(classPath);

            var isVisual = (classPath == 'ceramic.Visual');
            if (!isVisual) {
                var parentClazz = Type.getSuperClass(clazz);
                while (parentClazz != null) {
                    if (Type.getClassName(parentClazz) == 'ceramic.Visual') {
                        isVisual = true;
                        break;
                    }
                    parentClazz = Type.getSuperClass(parentClazz);
                }
            }

            editableTypes.push({
                meta: Meta.getType(clazz),
                entity: classPath,
                fields: fields,
                isVisual: isVisual
            });

            if (isVisual) {
                editableVisuals.push(editableTypes[editableTypes.length - 1]);
            }
            else {
                editableEntities.push(editableTypes[editableTypes.length - 1]);
            }

            var fieldKeys = [];
            for (k in fieldInfo.keys()) {
                fieldKeys.push(k);
            }
            fieldKeys.sort((a, b) -> {
                var indexA = fieldInfo.get(a).index;
                var indexB = fieldInfo.get(b).index;
                if (indexA > indexB)
                    return 1;
                else if (indexA < indexB)
                    return -1;
                else
                    return 0;
            });

            for (k in fieldKeys) {

                var v = fieldInfo.get(k);
                var meta = v.meta;
                var type = v.type;

                if (v != null && Reflect.hasField(meta, 'editable') && !usedFields.exists(k)) {
                    usedFields.set(k, true);

                    var fieldMeta:Dynamic = {};
                    var origMeta = meta;
                    for (mk in Reflect.fields(origMeta)) {
                        Reflect.setField(fieldMeta, mk, Reflect.field(origMeta, mk));
                    }

                    var fieldType = type;

                    var editable:Array<Dynamic> = fieldMeta.editable;
                    if (editable == null) {
                        fieldMeta.editable = [{}];
                        editable = fieldMeta.editable;
                    }
                    else if (editable.length == 0) editable.push({});

                    if (!BASIC_TYPES.exists(fieldType)) {

                        // Enum?
                        var resolvedEnum = Type.resolveEnum(fieldType);
                        if (resolvedEnum != null && editable[0].options == null) {
                            var rawOptions = Type.getEnumConstructs(resolvedEnum);
                            var options = [];
                            for (item in rawOptions) {
                                options.push(TextUtils.upperCaseToCamelCase(item, true, ' '));
                            }
                            editable[0].options = options;
                        }
                    }

                    fields.push({
                        name: k,
                        meta: fieldMeta,
                        type: fieldType
                    });
                }
            }

            // Process parent class fields as well
            clazz = Type.getSuperClass(clazz);

        }

        this.editableTypes = cast editableTypes;
        this.editableVisuals = cast editableVisuals;
        this.editableEntities = cast editableEntities;

    }

    function initModel() {

        model = new EditorData();
        computeLists(model);

        trace('images: ' + model.images);
        trace('texts: ' + model.texts);
        trace('sounds: ' + model.sounds);
        trace('fonts: ' + model.fonts);
        trace('databases: ' + model.databases);

        app.flushImmediate();

        autorun(updateWindow);
        autorun(handlePendingFile);
        
    }

    function initView() {

        autorun(updateView);

        screen.onResize(this, function() {

            layout();

        });

        layout();

        /*
        Timer.interval(this, 3.0, function() {
            switch model.location {
                case PLAY(fragmentId):
                    model.location = DEFAULT;
                default:
                    model.location = PLAY('FRAGMENT_0');
            }
        });
        */
        
    }

    function layout() {

        settings.targetWidth = Std.int(screen.nativeWidth);
        settings.targetHeight = Std.int(screen.nativeHeight);
        settings.targetDensity = Std.int(screen.nativeDensity);

        if (view != null) {
            view.pos(0, 0);
            view.size(settings.targetWidth, settings.targetHeight);
        }

        if (playView != null) {
            playView.pos(0, 0);
            playView.size(settings.targetWidth, settings.targetHeight);
        }

    }

    function updateView() {

        var location = model.location;

        unobserve();

        if (view != null) {
            view.destroy();
            view = null;
        }
        if (playView != null) {
            playView.destroy();
            playView != null;
        }

        var location = model.location;
        switch location {
            case PLAY(fragmentId):
                playView = new EditorPlayView();
            default:
                view = new EditorView();
        }

        layout();

        reobserve();

    }

    function updateWindow() {

        var projectUnsaved = model.projectUnsaved;

        // Update window title
        settings.title = model.project.title + (projectUnsaved ? ' *' : '');

    }

    function handlePendingFile() {

        var pendingFile = this.pendingFile;

        unobserve();

        if (pendingFile!= null) {
            this.pendingFile = null;
            model.openProject(pendingFile);
        }

        reobserve();

    }

/// Key bindings

    function bindKeyBindings() {

        var keyBindings = new KeyBindings();

        keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_Z)], function() {
            model.history.undo();
        });


        keyBindings.bind([CMD_OR_CTRL, SHIFT, KEY(KeyCode.KEY_Z)], function() {
            model.history.redo();
        });

        onDestroy(keyBindings, function(_) {
            keyBindings.destroy();
            keyBindings = null;
        });

    }

}
