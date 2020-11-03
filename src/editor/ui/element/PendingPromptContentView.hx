package editor.ui.element;

import haxe.DynamicAccess;

class PendingPromptContentView extends View {

    var pendingPrompt:EditorPendingPrompt;

    var scrollingLayout:ScrollingLayout<ColumnLayout>;

    var messageText:TextView = null;

    var result:Array<Dynamic> = [];

    public function new(pendingPrompt:EditorPendingPrompt) {

        super();

        this.pendingPrompt = pendingPrompt;
        transparent = true;

        scrollingLayout = new ScrollingLayout(new ColumnLayout());
        scrollingLayout.layoutView.padding(4, 0);

        var maxHeight = 350;
        viewWidth = 250;

        if (pendingPrompt.message != null) {
            messageText = new TextView();
            messageText.preRenderedSize = 20;
            messageText.pointSize = 12;
            messageText.viewSize(fill(), auto());
            messageText.padding(6);
            messageText.align = CENTER;
            messageText.content = pendingPrompt.message;
            scrollingLayout.layoutView.add(messageText);
        }

        fillParams();
        fillButtons();

        autorun(updateStyle);

        scrollingLayout.onLayout(this, () -> {
            app.oncePostFlushImmediate(() -> {
                viewHeight = Math.min(maxHeight, scrollingLayout.layoutView.computedHeight);
            });
        });

        add(scrollingLayout);

    }

    function fillParams() {
        
        var form = new FormLayout();

        for (i in 0...pendingPrompt.params.length) {

            var param = pendingPrompt.params[i];

            (function(param:PromptParam, i:Int) {
                result[i] = param.value;
                if (param.slider != null) {
                    var isInt = param.type == 'Int';
                    var decimals = isInt ? 0 : 3;
                    var minValue:Float = isInt ? Math.round(param.slider[0]) : param.slider[0];
                    var maxValue:Float = isInt ? Math.round(param.slider[1]) : param.slider[1];
                    var item = new LabeledFieldView(new SliderFieldView(minValue, maxValue));
                    item.label = param.name;
                    item.field.setValue = function(field, value) {
                        if (value > maxValue)
                            value = maxValue;
                        if (value < minValue)
                            value = minValue;
                        if (decimals == 0) {
                            value = Math.round(value);
                        }
                        else if (decimals >= 1) {
                            var power = Math.pow(10, decimals);
                            value = Math.round(value * power) / power;
                        }
                        item.field.value = value;
                        result[i] = isInt ? Std.int(value) : value;
                    };
                    item.field.value = param.value;
                    form.add(item);
                }
                else if (param.type == 'Int' || param.type == 'Float') {
                    var isInt = param.type == 'Int';
                    var item = new LabeledFieldView(new TextFieldView(NUMERIC));
                    item.label = param.name;
                    item.field.setTextValue = isInt ? SanitizeTextField.setTextValueToFloat(0, 999999999) : SanitizeTextField.setTextValueToInt(0, 999999999);
                    item.field.setEmptyValue = function(field) {
                        result[i] = param.value;
                    };
                    item.field.setValue = function(field, value) {
                        result[i] = isInt ? Std.int(value) : value;
                    };
                    item.field.textValue = '' + (isInt ? Std.int(param.value) : param.value);
                    form.add(item);
                }
                else if (param.type == 'String') {
                    var field:TextFieldView;
                    if (param.name != null) {
                        var item = new LabeledFieldView(new TextFieldView(TEXT));
                        item.label = param.name;
                        field = item.field;
                        form.add(item);
                    }
                    else {
                        field = new TextFieldView(TEXT);
                        form.add(field);
                    }
                    field.setValue = function(field, value) {
                        result[i] = value;
                    };
                    field.textValue = '' + param.value;

                    if (pendingPrompt.params.length == 1) {
                        // Focus if this is the only field to display
                        field.focus();

                        // Also confirm on enter
                        input.onKeyDown(this, key -> {
                            if (key.scanCode == ScanCode.ENTER) {
                                pendingPrompt.callback(result);
                            }
                        });
                    }
                }
            })(param, i);

        }

        scrollingLayout.layoutView.add(form);

    }

    function fillButtons() {

        var buttonContainer = new ColumnLayout();
        buttonContainer.padding(4, 8);

        var button = new Button();
        button.content = 'Ok';
        button.onClick(this, () -> {
            pendingPrompt.callback(result);
        });

        buttonContainer.add(button);

        scrollingLayout.layoutView.add(buttonContainer);

    }

    override function layout() {

        scrollingLayout.size(width, height);

    }
    
    function updateStyle() {
        
        if (messageText != null) {
            messageText.color = theme.lightTextColor;
            messageText.font = theme.mediumFont;
        }

    }

}