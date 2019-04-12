package editor;

class Shortcuts {

    #if editor

    public static var editor(get,never):Editor;
    inline static function get_editor():Editor return Editor.editor;

    public static var model(get,never):editor.model.EditorData;
    inline static function get_model():editor.model.EditorData return Editor.editor.model;

    public static var theme(get,never):editor.model.EditorTheme;
    inline static function get_theme():editor.model.EditorTheme return Editor.editor.model.theme;

    #end

} //Shortcuts
