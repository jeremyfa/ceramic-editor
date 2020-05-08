package editor.ui.project;

import ceramic.Path;

class ProjectSettingsView extends LinearLayout implements Observable {

    static final LABEL_WIDTH = 74;

/// Lifecycle

    public function new() {

        super();

        viewSize(500, auto());

        initForm();

        autorun(updateStyle);

    }

    function initForm() {

        var form = new FormLayout();
        add(form);

        (function() {

            var item = new LabeledFieldView(new TextFieldView(PATH()));
            item.label = 'Export path';
            item.autorun(function() {
                var projectPath = model.projectPath;
                unobserve();
                item.field.placeholder = projectPath != null ? Path.directory(projectPath) : '.';
            });
            item.field.setTextValue = SanitizeTextField.setTextValueToIdentifier;
            item.field.setEmptyValue = function(field) {
                model.project.exportPath = null;
            };
            item.field.setValue = function(field, value) {
                if (value == '')
                    value = null;
                model.project.exportPath = value;
            };
            item.autorun(function() {
                var project = model.project;
                item.field.textValue = project.exportPath != null ? '' + project.exportPath : '';
            });
            form.add(item);

            var description = new TextView();
            description.preRenderedSize = 20;
            description.pointSize = 11;
            description.align = LEFT;
            description.verticalAlign = CENTER;
            description.paddingLeft = LABEL_WIDTH;
            description.autorun(() -> {
                description.font = theme.mediumFont;
                description.textColor = theme.darkTextColor;
            });
            description.content = 'The path where fragments get exported as usable assets (relative to project).';
            form.add(description);

        })();

    }

    function updateStyle() {

        //

    }

}