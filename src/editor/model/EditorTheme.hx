package editor.model;

class EditorTheme extends Model {

/// Text colors

    @observe public var fieldTextColor:Color = 0xFFFFFF;

    @observe public var lightTextColor:Color = 0xF3F3F3;

    @observe public var mediumTextColor:Color = 0xCCCCCC;

    @observe public var darkTextColor:Color = 0x888888;

    @observe public var darkerTextColor:Color = 0x555555;

/// Text fonts

    public var mediumFont10(get,never):BitmapFont;
    function get_mediumFont10():BitmapFont return editor.assets.font(Fonts.ROBOTO_MEDIUM_10);

    public var mediumFont20(get,never):BitmapFont;
    function get_mediumFont20():BitmapFont return editor.assets.font(Fonts.ROBOTO_MEDIUM_20);

    public var boldFont10(get,never):BitmapFont;
    function get_boldFont10():BitmapFont return editor.assets.font(Fonts.ROBOTO_BOLD_10);

    public var boldFont20(get,never):BitmapFont;
    function get_boldFont20():BitmapFont return editor.assets.font(Fonts.ROBOTO_BOLD_20);

/// Borders colors

    @observe public var lightBorderColor:Color = 0x636363;

    @observe public var mediumBorderColor:Color = 0x464646;

    @observe public var darkBorderColor:Color = 0x383838;

/// Backgrounds colors

    @observe public var windowBackgroundColor:Color = 0x282828;

    @observe public var lightBackgroundColor:Color = 0x4F4F4F;

    @observe public var mediumBackgroundColor:Color = 0x4A4A4A;

    @observe public var darkBackgroundColor:Color = 0x424242;

    @observe public var darkerBackgroundColor:Color = 0x282828;

/// Selection

    @observe public var selectionBorderColor:Color = Color.RED;

/// Field

    @observe public var focusedFieldSelectionColor:Color = 0x3073C6;

    @observe public var focusedFieldBorderColor:Color = 0x4392E0;

/// Button

    @observe public var buttonBackgroundColor:Color = 0x515151;

    @observe public var buttonOverBackgroundColor:Color = 0x5A5A5A;

    @observe public var buttonPressedBackgroundColor:Color = 0x4798EB;

    public function new() {

        super();

    } //new

} //EditorTheme
