package editor.ui.form;

using ceramic.Extensions;

class LabeledFieldView<T:FieldView> extends LinearLayout implements Observable {

/// Public properties

    @observe public var label:String = '';

    @observe public var disabled:Bool = false;

    public var field(default,set):T;
    function set_field(field:T):T {
        this.field = field;
        invalidateDisabled();
        return field;
    }

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

        autorun(updateDisabled);
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

    function updateDisabled() {

        var field = this.field;
        unobserve();

        if (field != null) {
            var disabled = false;
            reobserve();
            if (field.getProperty('disabled')) {
                disabled = true;
            }
            unobserve();
            this.disabled = disabled;
        }
        else {
            this.disabled = false;
        }

        reobserve();

    }

    function updateStyle() {

        if (disabled) {
            labelText.textColor = theme.mediumTextColor;
        }
        else {
            labelText.textColor = theme.lightTextColor;
        }

        labelText.font = theme.mediumFont10;

    }

}
