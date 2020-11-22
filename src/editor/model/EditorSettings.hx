package editor.model;

class EditorSettings extends Model {

    @serialize public var enableScriptEditor:Bool = #if web true #else false #end;

    @serialize public var autoKeyframe:Bool = true;

    @serialize public var editorsSeparatorOffset:Float = 0;

    @serialize public var maximizeViewport:Bool = false;

}