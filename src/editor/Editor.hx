package editor;

import haxe.rtti.Meta;
//import haxe.rtti.Rtti;
import haxe.DynamicAccess;

import editor.model.*;
import editor.ui.*;

import ceramic.SpinePlugin;

/** Turns the app into an editor. */
class Editor extends Entity {

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

/// Internal properties

    var renders:Int = 0;

    var options:EditorOptions;

    var editableTypes:Array<EditableType> = [];

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
        settings.targetWidth = 1024;
        settings.targetHeight = 768;
        settings.resizable = true;
        settings.scaling = FIT;
        settings.title = 'Ceramic Editor';

        app.onceReady(this, loadAssets);

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
                    contentAssets.runtimeAssets = RuntimeAssets.fromPath(options.assets);
                }
            } 
        }

        editorAssets = new Assets();
        
        editorAssets.add(Fonts.ROBOTO_MEDIUM_20);
        editorAssets.add(Fonts.ROBOTO_BOLD_20);

        editorAssets.add(Images.ROBOTO_BOLD_10); // TODO remove

        editorAssets.onceComplete(this, assetsLoaded);

        editorAssets.load();

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

        initView();

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
        model.databases = cast databases;

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
                isVisual: true // TODO handle non-visuals
            });

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
                                options.push(item.toLowerCase());
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
        
    }

    function initView() {

        view = new EditorView();

        screen.onResize(this, function() {

            settings.targetWidth = Std.int(screen.nativeWidth);
            settings.targetHeight = Std.int(screen.nativeHeight);
            settings.targetDensity = Std.int(screen.nativeDensity);

            layout();

        });

        layout();
        
    }

    function layout() {

        view.pos(0, 0);
        view.size(settings.targetWidth, settings.targetHeight);

    }

    function updateWindow() {

        // Update window title
        settings.title = model.project.title;

    }

}
