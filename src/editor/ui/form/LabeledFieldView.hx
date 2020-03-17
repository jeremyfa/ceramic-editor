package editor.ui.form;

class LabeledFieldView<T:FieldView> extends LinearLayout implements Observable {

/// Public properties

    @observe public var label:String = '';

    public var field(default,null):T;

/// Internal properties

    var labelText:TextView;

/// Lifecycle

    public function new(field:T) {

        super();

        direction = HORIZONTAL;
        itemSpacing = 8;

        labelText = new TextView();
        labelText.viewSize(percent(30), auto());
        labelText.align = RIGHT;
        labelText.verticalAlign = CENTER;
        labelText.pointSize = 12;
        add(labelText);

        this.field = field;
        field.viewSize(fill(), auto());
        add(field);

        autorun(updateLabel);
        autorun(updateStyle);

        // Focus field on label click
        #if !(ios || android)
        labelText.onPointerDown(this, _ -> handleLabelClick());
        #else
        var labelClick = new Click();
        labelText.component(labelClick);
        labelClick.onClick(this, handleLabelClick);
        #end

    }

/// Internal

    function handleLabelClick() {

        field.focus();

    }

    function updateLabel() {

        labelText.content = label;

    }

    function updateStyle() {

        labelText.textColor = theme.lightTextColor;
        labelText.font = theme.mediumFont10;

    }

}
