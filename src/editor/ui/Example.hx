package editor.ui;

class ExampleView extends View implements Observable {

    @observe public var firstname:String = 'John';

    @observe public var lastname:String = 'Doe';

    public function new() {

        super();

        autorun(function() {

            // Called once to compute implicit bindings,
            // then anytime `firstname` or `lastname` changes
            trace('Hello, $firstname $lastname');

        });

    } //new

} //ExampleView