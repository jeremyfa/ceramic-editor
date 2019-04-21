package editor.model;

class EditorTheme extends Model {

/// Text colors

    @observe public var lightTextColor:Color = 0xF3F3F3;

    @observe public var mediumTextColor:Color = 0xCCCCCC;

    @observe public var darkTextColor:Color = 0x888888;

/// Text fonts

    @observe public var mediumFont:BitmapFont = editor.assets.font(Fonts.ROBOTO_MEDIUM_20);

    @observe public var boldFont:BitmapFont = editor.assets.font(Fonts.ROBOTO_BOLD_20);

/// Borders colors

    @observe public var darkBorderColor:Color = 0x383838;

    @observe public var mediumBorderColor:Color = 0x464646;

/// Backgrounds colors

    @observe public var windowBackgroundColor:Color = 0x282828;

    @observe public var lightBackgroundColor:Color = 0x4F4F4F;

    @observe public var mediumBackgroundColor:Color = 0x4A4A4A;

    @observe public var darkBackgroundColor:Color = 0x424242;

    @observe public var darkerBackgroundColor:Color = 0x282828;

/// Selection

    @observe public var selectionBorderColor:Color = Color.RED;

    public function new() {

        super();

    } //new

} //EditorTheme
