package editor.ui;

class EditorPlayView extends View {

    public var fragment:Fragment = null;

    public function new() {

        super();

        // Ensure 60FPS
        #if luxe
        Luxe.core.update_rate = 0;
        #end

        color = Color.BLACK;
        transparent = true;

        autorun(updateFragment);

    }

    function updateFragment() {

        var location = model.location;

        unobserve();

        switch location {
            case PLAY(fragmentId):
                initFragment(fragmentId);
            default:
        }

    }

    function initFragment(fragmentId:String) {

        if (fragment != null) {
            fragment.destroy();
        }

        var editorFragmentData = model.project.fragmentById(fragmentId);
        if (editorFragmentData == null) {
            log.error('Failed to init fragment: no fragment with id $fragmentId');
            return;
        }

        var fragmentData = editorFragmentData.toFragmentData();

        fragment = new Fragment(editor.contentAssets, false);
        fragment.onLocation(this, handleFragmentLocation);
        add(fragment);

        fragment.fragmentData = fragmentData;

        if (editorFragmentData.overflow && !editorFragmentData.transparent) {
            color = editorFragmentData.color;
            transparent = false;
        }
        else {
            color = Color.BLACK;
            transparent = true;
        }

    }

    function handleFragmentLocation(location:String) {

        switch model.location {
            case PLAY(fragmentId):
                if (location != fragmentId) {
                    model.location = PLAY(location);
                }
            default:
        }

    }

    override function layout() {

        if (fragment != null) {
            var fragmentScale = Math.min(width / fragment.width, height / fragment.height);
            fragment.scale(fragmentScale);
            fragment.anchor(0.5, 0.5);
            fragment.pos(width * 0.5, height * 0.5);
        }

    }

}