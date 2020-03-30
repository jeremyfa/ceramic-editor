package editor.ui.form;

using ceramic.Extensions;

class LabeledFieldGroupView<T:LabeledFieldView<U>,U:FieldView> extends LinearLayout implements Observable {

/// Public properties

    @observe public var label:String = '';

    @observe public var disabled:Bool = false;

    public var fields(default,set):Array<T>;
    function set_fields(fields:Array<T>):Array<T> {
        this.fields = fields;
        invalidateDisabled();
        return fields;
    }

/// Lifecycle

    public function new(fields:Array<T>) {

        super();

        direction = HORIZONTAL;
        itemSpacing = 8;
        //padding(4, 4);

        this.fields = fields;
        //app.onceUpdate(this, _ -> {
            for (i in 0...fields.length) {
                var field = fields[i];
                field.viewSize(fill(), auto());
                add(field);
            }
        //});

        viewSize(fill(), auto());

        autorun(updateDisabled);
        autorun(updateStyle);

    }

/// Internal

    override function layout() {

        if (fields.length > 0) {

            var itemWidth = ((width - paddingLeft - paddingRight - 65 + 50 - 8 * (fields.length - 1)) / fields.length);
    
            for (i in 0...fields.length) {
                var field = fields[i];
                if (i == 0) {
                    field.labelViewWidth = 65;
                    field.viewSize(itemWidth + 65 - 50, auto());
                }
                else {
                    field.labelViewWidth = 50;
                    field.viewSize(itemWidth, auto());
                }
            }
        }

        super.layout();
        
    }

    function updateDisabled() {

        var fields = this.fields;
        var allDisabled = true;
        unobserve();

        for (field in fields) {
            reobserve();
            if (!field.field.getProperty('disabled')) {
                unobserve();
                allDisabled = false;
                break;
            }
            unobserve();
        }

        this.disabled = allDisabled;

        reobserve();

    }

    function updateStyle() {

        /*
        transparent = false;
        color = Color.interpolate(
            theme.mediumBackgroundColor,
            theme.lightBackgroundColor,
            1
        );
        borderColor = theme.mediumBorderColor;
        borderSize = 1;
        borderPosition = INSIDE;
        */

    }

}
