package editor;

import haxe.rtti.Meta;
import haxe.rtti.Rtti;
import haxe.DynamicAccess;

import editor.model.*;
import editor.ui.*;

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

        /*
        texts: runtimeAssets.getNames('text'),
        sounds: runtimeAssets.getNames('sound'),
        fonts: runtimeAssets.getNames('font'),
        databases: runtimeAssets.getNames('database'),
        */

    }

/// Internal

    function computeEditableTypes():Void {

        // Compute editable types
        for (key in Reflect.fields(app.info.editable)) {

            var classPath = Reflect.field(app.info.editable, key);

            trace('EDITABLE $classPath');

            var clazz = Type.resolveClass(classPath);
            var usedFields = new Map();
            var fields:Array<EditableTypeField> = [];
            var rtti = Utils.getRtti(clazz);

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

            while (clazz != null) {

                // Process every field marked `@editable`
                var meta = Meta.getFields(clazz);
                for (field in rtti.fields) {
                    var k = field.name;
                    var v = Reflect.field(meta, k);

                    if (v != null && Reflect.hasField(v, 'editable') && !usedFields.exists(k)) {
                        usedFields.set(k, true);

                        var fieldMeta:Dynamic = {};
                        var origMeta = v;
                        for (mk in Reflect.fields(origMeta)) {
                            Reflect.setField(fieldMeta, mk, Reflect.field(origMeta, mk));
                        }

                        var fieldType = FieldInfo.stringFromCType(field.type);

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
                if (clazz != null) rtti = Utils.getRtti(clazz);

            }

        }

    }

    function initModel() {

        model = new EditorData();
        computeLists(model);
        trace('images: ' + model.images);

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
