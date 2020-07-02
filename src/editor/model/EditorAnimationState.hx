package editor.model;

class EditorAnimationState extends Model {

    @observe public var currentFrame:Int = 0;

    @observe public var animating(default, set):Bool = false;
    function set_animating(animating:Bool):Bool {
        if (this.animating != animating) {
            if (!animating)
                wasJustAnimating++;
            this.animating = animating;
            if (!animating) {
                Timer.delay(this, 0.1, () -> {
                    wasJustAnimating--;
                });
            }
        }
        return animating;
    }

    @observe public var wasJustAnimating:Int = 0;

}