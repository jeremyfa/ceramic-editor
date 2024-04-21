package editor.model.fragment;

import ceramic.Equal;
import ceramic.ReadOnlyMap;
import tracker.Autorun.unobserve;

/**
 * A map model that wraps every value into their own model object to make them observable.
 */
class EditorEntityProps extends EditorBaseFragmentModel {

    /**
     * Actual setup values
     */
    @serialize var values:ReadOnlyMap<String,EditorValue> = new Map();

    public function keys():Iterator<String> {

        return values.keys();

    }

    public function get(key:String):Any {

        if (values.exists(key)) {
            var v = values.get(key);
            return v.value;
        }
        else {
            return null;
        }

    }

    public function set(key:String, value:Any):Void {

        unobserve();

        var value = this.values;
        var valueHasChanged = false;
        var prevValue:Dynamic = get(key);
        if (!Equal.equal(prevValue, value))
            valueHasChanged = true;

        if (values.exists(key)) {
            values.get(key).value = value;
        }
        else {
            final aValue = new EditorValue();
            aValue.value = value;

            // Create a new copy
            final newValues = new Map<String,EditorValue>();
            for (k => v in values) {
                newValues.set(k, v);
            }
            newValues.set(key, aValue);

            this.values = newValues;
        }

        if (valueHasChanged) {
            history.step();
        }

        reobserve();

    }

}
