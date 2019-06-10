package editor.utils;

class FieldUtils {

    public static function createEditableField(editableType:EditableType, field:EditableTypeField, item:EditorEntityData):FieldView {

        var type = field.type;
        var name = field.name;

        var options:Dynamic = field.meta.editable[0];
        /*if (options.collection != null) {
            // TODO
        }
        elseif (options.localCollection != null) {
            // TODO?
        }
        else if (optinos.options != null) {
            // TODO?
        }*/
        //else {

        if (type == 'String' || type == 'Float' || type == 'Int') {
            var fieldView = new TextFieldView();
            if (type == 'Float') {
                fieldView.setTextValue = SanitizeTextField.setTextValueToFloat;
            }
            else if (type == 'Int') {
                fieldView.setTextValue = SanitizeTextField.setTextValueToInt;
            }
            fieldView.setValue = function(field, value) {
                item.props.set(name, value);
            };
            fieldView.autorun(function() {
                var value:Dynamic = item.props.get(name);
                if (value == null) {
                    fieldView.textValue = '';
                }
                else {
                    fieldView.textValue = '' + value;
                }
            });
            return fieldView;
        }
        else if (type == 'Bool') {
            var fieldView = new BooleanFieldView();
            fieldView.setValue = function(field, value) {
                item.props.set(name, value);
            };
            fieldView.autorun(function() {
                var value:Dynamic = item.props.get(name);
                if (value == null || value == 0 || value == '' || value == false) {
                    fieldView.value = false;
                }
                else {
                    fieldView.value = true;
                }
            });
            return fieldView;
        }
        else if (type == 'ceramic.Color') {
            //
        }
        else if (type == 'ceramic.BitmapFont') {
            //
        }
        else {
            //
        }

        //}

        warning('Cannot create field for type: $type');

        return null;

    } //createEditableField

} //FieldUtils
