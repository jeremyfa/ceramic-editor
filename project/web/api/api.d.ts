
type Int = number;
type Float = number;
type Bool = boolean;
type String = string;
type Dynamic = any;
type Void = void;

function trace(str: String): Void;

const self: Entity;
const entity: Entity;
const visual: Visual;

const app: App;
const screen: Screen;
const audio: Audio;
const settings: Settings;
const collections: Collections;
const log: Logger;

interface Array<T> {
    [index: number]: T;
}

var a: number;
var b: number;
var c: number;
var d: number;
var e: number;
var f: number;
var g: number;
var h: number;
var i: number;
var j: number;
var k: number;
var l: number;
var m: number;
var n: number;
var o: number;
var p any;
var q: number;
var r: number;
var s: number;
var t: number;
var u: number;
var v: number;
var w: number;
var x: number;
var y: number;
var z: number;

class Tracker {
    static backend: TrackerBackend;
}

/** Utility to serialize a model object (and its children) continuously and efficiently */
class SerializeModel extends Entity implements Component {
    constructor();
    static loadFromData(model: Model, data: String, hotReload?: Bool): Bool;
    /** Triggered when serialized data is updated.
        If `append` is true, the given string should be appended to the existing one. */
    onChangeset(owner: Entity?, handleChangeset: ((changeset: SerializeChangeset) => Void)): Void;
    /** Triggered when serialized data is updated.
        If `append` is true, the given string should be appended to the existing one. */
    onceChangeset(owner: Entity?, handleChangeset: ((changeset: SerializeChangeset) => Void)): Void;
    /** Triggered when serialized data is updated.
        If `append` is true, the given string should be appended to the existing one. */
    offChangeset(handleChangeset?: ((changeset: SerializeChangeset) => Void)?): Void;
    /** Triggered when serialized data is updated.
        If `append` is true, the given string should be appended to the existing one. */
    listensChangeset(): Bool;
    checkInterval: Float;
    compactInterval: Float;
    destroyModelOnUntrack: Bool;
    serializedMap: Map<K, V>;
    model: Model;
    entity: Model;
    /** Recompute the whole object tree instead of appending. This will untrack every object not on the model anymore
        and generate a new changeset with the whole serialized object tree. */
    compact(done?: ((arg1: String) => Void)?): Void;
    /** Synchronize (expected to be called at regular intervals or when something important needs to be serialized) */
    synchronize(): Void;
    initializerName: String;
    unbindEvents(): Void;
}

class SerializeChangeset {
    constructor(data: String, append?: Bool);
    data: String;
    append: Bool;
}

interface Serializable {
}

class SaveModel {
    static getSavedOrCreate<T>(modelClass: Class<T>, key: String, args?: Array<Dynamic>?): T;
    /** Load data from the given key. */
    static loadFromKey(model: Model, key: String): Bool;
    static autoSaveAsKey(model: Model, key: String, appendInterval?: Float, compactInterval?: Float): Void;
}

/** Observable allows to observe properties of an object. */
interface Observable {
}

class Model extends Entity implements Serializable, Observable {
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Model, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Model, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Model, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /**modelDirty event*/
    onModelDirty(owner: Entity?, handleModel: ((model: Model) => Void)): Void;
    /**modelDirty event*/
    onceModelDirty(owner: Entity?, handleModel: ((model: Model) => Void)): Void;
    /**modelDirty event*/
    offModelDirty(handleModel?: ((model: Model) => Void)?): Void;
    /**Does it listen to modelDirty event*/
    listensModelDirty(): Bool;
    serializer: SerializeModel;
    dirty: Bool;
    /**Event when this object gets serialized.*/
    onSerialize(owner: Entity?, handle: (() => Void)): Void;
    /**Event when this object gets serialized.*/
    onceSerialize(owner: Entity?, handle: (() => Void)): Void;
    /**Event when this object gets serialized.*/
    offSerialize(handle?: (() => Void)?): Void;
    /**Event when this object gets serialized.*/
    listensSerialize(): Bool;
    unbindEvents(): Void;
    /**Event when this object gets deserialized.*/
    onDeserialize(owner: Entity?, handle: (() => Void)): Void;
    /**Event when this object gets deserialized.*/
    onceDeserialize(owner: Entity?, handle: (() => Void)): Void;
    /**Event when this object gets deserialized.*/
    offDeserialize(handle?: (() => Void)?): Void;
    /**Event when this object gets deserialized.*/
    listensDeserialize(): Bool;
}

class History extends Entity implements Component {
    constructor();
    entity: Model;
    /**
     * If provided, number of available steps will be limited to this value,
     * meaning older steps will be removed and not recoverable if reaching the limit.
     * Default is: store as many steps as possible, no limit (except available memory?)
     */
    maxSteps: Int;
    /**
     * Manually clear previous steps outside the given limit
     * @param maxSteps 
     */
    clearPreviousStepsOutsideLimit(maxSteps: Int): Void;
    bindAsComponent(): Void;
    /**
     * Record a step in the undo stack
     */
    step(): Void;
    /**
     * Undo last step, if any
     */
    undo(): Void;
    /**
     * Redo last undone step, if any
     */
    redo(): Void;
    initializerName: String;
}

/** Events allows to add strictly typed events to classes.
    Generates related methods: on|once|off|emit{EventName}() */
interface Events {
}

/** Event dispatcher used by DynamicEvents and Events macro as an alternative implementation
    that doesn't require to add a lot of methods on classes with events.
    This is basically the same code as what is statically generated by Events macro,
    but made dynamic and usable for any type.
    This is not really supposed to be used as is as it is pretty low-level. */
class EventDispatcher {
    constructor();
    setWillEmit(index: Int, cb: Dynamic): Void;
    setDidEmit(index: Int, cb: Dynamic): Void;
    setWillListen(index: Int, cb: Dynamic): Void;
    wrapEmit(index: Int, numArgs: Int): Dynamic;
    emit(index: Int, numArgs: Int, arg1?: Dynamic?, arg2?: Dynamic?, arg3?: Dynamic?): Void;
    wrapOn(index: Int): Dynamic;
    on(index: Int, owner: Entity?, cb: Dynamic): Void;
    wrapOnce(index: Int): Dynamic;
    once(index: Int, owner: Entity?, cb: Dynamic): Void;
    wrapOff(index: Int): Dynamic;
    off(index: Int, cb: Dynamic): Void;
    wrapListens(index: Int): Dynamic;
    listens(index: Int): Bool;
}

/** Fire and listen to dynamic events. Works similarly to static events, but dynamic.
    If you can know the event names at compile time, using static events (`@event function myEvent();`) is preferred. */
class DynamicEvents<T> extends Entity {
    constructor();
    emit(event: T, args?: Array<Dynamic>?): Void;
    on(event: T, owner: Entity?, cb: Dynamic): Void;
    once(event: T, owner: Entity?, cb: Dynamic): Void;
    off(event: T, cb?: Dynamic?): Void;
    listens(event: T): Bool;
}

class Autorun extends Entity {
    /**
     * Initialize a new autorun.
     * @param onRun The callback that will be executed and used to compute implicit bindings
     * @param afterRun
     *     (optional) A callback run right after `onRun`, not affecting implicit bindings.
     *     Useful when generating side effects without messing up binding dependencies.
     */
    constructor(onRun: (() => Void), afterRun?: (() => Void)?);
    static current: Autorun;
    /** Ensures current `autorun` won't be affected by the code after this call.
        `reobserve()` should be called to restore previous state. */
    static unobserve(): Void;
    /** Resume observing values and resume affecting current `autorun` scope.
        This should be called after an `unobserve()` call. */
    static reobserve(): Void;
    /** Executes the given function synchronously and ensures the
        current `autorun` scope won't be affected */
    static unobserved(func: (() => Void)): Void;
    static getAutorunArray(): Array<Autorun>;
    static recycleAutorunArray(array: Array<Autorun>): Void;
    static getArrayOfAutorunArrays(): Array<Array<Autorun>>;
    static recycleArrayOfAutorunArrays(array: Array<Array<Autorun>>): Void;
    /**reset event*/
    onReset(owner: Entity?, handle: (() => Void)): Void;
    /**reset event*/
    onceReset(owner: Entity?, handle: (() => Void)): Void;
    /**reset event*/
    offReset(handle?: (() => Void)?): Void;
    /**Does it listen to reset event*/
    listensReset(): Bool;
    invalidated: Bool;
    destroy(): Void;
    run(): Void;
    invalidate(): Void;
    bindToAutorunArray(autorunArray: Array<Autorun>): Void;
    unbindFromAllAutorunArrays(): Void;
    unbindEvents(): Void;
}

class WatchDirectory extends Entity {
    constructor(updateInterval?: Float);
    /**directoryChange event*/
    onDirectoryChange(owner: Entity?, handlePathNewFilesPreviousFiles: ((path: String, newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)): Void;
    /**directoryChange event*/
    onceDirectoryChange(owner: Entity?, handlePathNewFilesPreviousFiles: ((path: String, newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)): Void;
    /**directoryChange event*/
    offDirectoryChange(handlePathNewFilesPreviousFiles?: ((path: String, newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)?): Void;
    /**Does it listen to directoryChange event*/
    listensDirectoryChange(): Bool;
    updateInterval: Float;
    watchedDirectories: Map<String, Map<String, Float>>;
    watchDirectory(path: String): Void;
    stopWatchingDirectory(path: String): Bool;
    unbindEvents(): Void;
}

class VisualTransition extends Entity implements Component {
    constructor(easing?: Easing?, duration?: Float);
    static transition(visual: Visual, easing?: Easing?, duration: Float, cb: ((arg1: ceramic.VisualTransitionProperties) => Void)): Tween?;
    entity: Visual;
    easing: Easing;
    duration: Float;
    run(easing?: Easing?, duration: Float, cb: ((arg1: ceramic.VisualTransitionProperties) => Void)): Tween?;
    destroy(): Void;
    initializerName: String;
}

class VisualNapePhysics extends Entity {
    constructor();
}

class VisualArcadePhysics extends Entity {
    constructor();
}

class Visual extends Entity {
    constructor();
    /**pointerDown event*/
    onPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerDown event*/
    oncePointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerDown event*/
    offPointerDown(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerDown event*/
    listensPointerDown(): Bool;
    /**pointerUp event*/
    onPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerUp event*/
    oncePointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerUp event*/
    offPointerUp(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerUp event*/
    listensPointerUp(): Bool;
    /**pointerOver event*/
    onPointerOver(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerOver event*/
    oncePointerOver(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerOver event*/
    offPointerOver(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerOver event*/
    listensPointerOver(): Bool;
    /**pointerOut event*/
    onPointerOut(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerOut event*/
    oncePointerOut(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerOut event*/
    offPointerOut(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerOut event*/
    listensPointerOut(): Bool;
    /**focus event*/
    onFocus(owner: Entity?, handle: (() => Void)): Void;
    /**focus event*/
    onceFocus(owner: Entity?, handle: (() => Void)): Void;
    /**focus event*/
    offFocus(handle?: (() => Void)?): Void;
    /**Does it listen to focus event*/
    listensFocus(): Bool;
    /**blur event*/
    onBlur(owner: Entity?, handle: (() => Void)): Void;
    /**blur event*/
    onceBlur(owner: Entity?, handle: (() => Void)): Void;
    /**blur event*/
    offBlur(handle?: (() => Void)?): Void;
    /**Does it listen to blur event*/
    listensBlur(): Bool;
    /** Get this visual typed as `Quad` or null if it isn't a `Quad` */
    asQuad: Quad;
    /** Get this visual typed as `Mesh` or null if it isn't a `Mesh` */
    asMesh: Mesh;
    /** When enabled, this visual will receive as many up/down/click/over/out events as
        there are fingers or mouse pointer interacting with it.
        Default is `false`, ensuring there is never multiple up/down/click/over/out that
        overlap each other. In that case, it triggers `pointer down` when the first finger/pointer hits
        the visual and trigger `pointer up` when the last finger/pointer stops touching it. Behavior is
        similar for `pointer over` and `pointer out` events. */
    multiTouch: Bool;
    /** Whether this visual is between a `pointer down` and an `pointer up` event or not. */
    isPointerDown: Bool;
    /** Whether this visual is between a `pointer over` and an `pointer out` event or not. */
    isPointerOver: Bool;
    /** Use the given visual's bounds as clipping area. */
    clip: Visual;
    /** Whether this visual should inherit its parent alpha state or not. */
    inheritAlpha: Bool;
    /** Computed flag that tells whether this visual is only translated,
        thus not rotated, skewed nor scaled.
        When this is `true`, matrix computation may be a bit faster as it
        will skip some unneeded matrix computation. */
    translatesOnly: Bool;
    /** Whether we should re-check if this visual is only translating or having a more complex transform */
    translatesOnlyDirty: Bool;
    /** Setting this to true will force the visual to recompute its displayed content */
    contentDirty: Bool;
    /** Setting this to true will force the visual's matrix to be re-computed */
    matrixDirty: Bool;
    /** Setting this to true will force the visual's computed render target to be re-computed */
    renderTargetDirty: Bool;
    /** Setting this to true will force the visual to compute it's visility in hierarchy */
    visibilityDirty: Bool;
    /** Setting this to true will force the visual to compute it's touchability in hierarchy */
    touchableDirty: Bool;
    /** Setting this to true will force the visual to compute it's clipping state in hierarchy */
    clipDirty: Bool;
    /** If set, the visual will be rendered into this target RenderTexture instance
        instead of being drawn onto screen directly. */
    renderTarget: RenderTexture;
    blending: Blending;
    visible: Bool;
    touchable: Bool;
    depth: Float;
    /** If set, children will be sort by depth and their computed depth
        will be within range [parent.depth, parent.depth + depthRange] */
    depthRange: Float;
    x: Float;
    y: Float;
    scaleX: Float;
    scaleY: Float;
    skewX: Float;
    skewY: Float;
    anchorX: Float;
    anchorY: Float;
    width: Float;
    height: Float;
    rotation: Float;
    alpha: Float;
    /** Set additional matrix-based transform to this visual. Default is null. */
    transform: Transform;
    /** Assign a shader to this visual. */
    shader: Shader;
    /** Read and write arbitrary boolean flags on this visual.
        Index should be between 0 (included) and 16 (excluded) or result is undefined. */
    flag(index: Int, value?: Bool?): Bool;
    /** Whether this visual is `active`. Default is **true**. When setting it to **false**,
        the visual won't be `visible` nor `touchable` anymore (these get set to **false**).
        When restoring `active` to **true**, `visible` and `touchable` will also get back
        their previous state. */
    active: Bool;
    computedVisible: Bool;
    computedAlpha: Float;
    computedDepth: Float;
    computedRenderTarget: RenderTexture;
    computedTouchable: Bool;
    computedClip: Bool;
    children: Array<Visual>;
    parent: Visual;
    size(width: Float, height: Float): Void;
    anchor(anchorX: Float, anchorY: Float): Void;
    pos(x: Float, y: Float): Void;
    scale(scaleX: Float, scaleY?: Float): Void;
    skew(skewX: Float, skewY: Float): Void;
    /** Change the visual's anchor but update its x and y values to make
        it keep its current position. */
    anchorKeepPosition(anchorX: Float, anchorY: Float): Void;
    /** Returns the first child matching the requested `id` or `null` otherwise. */
    childWithId(id: String, recursive?: Bool): Visual;
    destroy(): Void;
    clear(): Void;
    /** Returns true if screen (x, y) screen coordinates hit/intersect this visual visible bounds */
    hits(x: Float, y: Float): Bool;
    /** Assign X and Y to given point after converting them from screen coordinates to current visual coordinates. */
    screenToVisual(x: Float, y: Float, point: Point): Void;
    /** Assign X and Y to given point after converting them from current visual coordinates to screen coordinates. */
    visualToScreen(x: Float, y: Float, point: Point): Void;
    /** Assign X and Y to given point after converting them from current visual coordinates to screen coordinates. */
    visualToTransform(transform: Transform): Void;
    computeContent(): Void;
    /**
     * Will walk on every children and set their depths starting from 
     * `start` and incrementing depth by `step`.
     * @param start the depth starting value (default 1). First child will have this depth, next child `depthStart + depthStep` etc...
     * @param step the depth step to use when increment depth for each child
     */
    autoChildrenDepth(start?: Float, step?: Float): Void;
    add(visual: Visual): Void;
    remove(visual: Visual): Void;
    /** Returns `true` if the current visual contains this child.
        When `recursive` option is `true`, will return `true` if
        the current visual contains this child or one of
        its direct or indirect children does. */
    contains(child: Visual, recursive?: Bool): Bool;
    unbindEvents(): Void;
}

class Velocity {
    constructor();
    reset(): Void;
    add(position: Float, minusDelta?: Float): Void;
    get(): Float;
}

/** A collection entry that can hold any value */
class ValueEntry<T> extends CollectionEntry {
    constructor(value: T, id?: String?, name?: String?);
    value: T;
}

/** Various utilities. Some of them are used by ceramic itself or its backends. */
class Utils {
    static realPath(path: String): String;
    static getRtti<T>(c: Class<T>): TAnonymous;
    /** Provides an identifier which is garanteed to be unique on this local device.
        It however doesn't garantee that this identifier is not predictable. */
    static uniqueId(): String;
    /** Provides a random identifier which should be fairly unpredictable and
        should have an extremely low chance to provide the same identifier twice. */
    static randomId(size?: Int?): String;
    /** Return a persistent identifier for this device. The identifier is expected
        to stay the same as long as the user keeps the app installed.
        Multiple identifiers can be generated/retrieved by using different slots (default 0).
        Size of the persistent identifier can be provided, but will only have effect when
        generating a new identifier. */
    static persistentId(slot?: Int?, size?: Int?): String;
    static resetPersistentId(slot?: Int?): Void;
    static base62Id(val?: Int?): String;
    static printStackTrace(): String;
    static stackItemToString(item: haxe.StackItem): String;
    static radToDeg(rad: Float): Float;
    static degToRad(deg: Float): Float;
    /** Clamp an degrees (angle) value between 0 (included) and 360 (excluded) */
    static clampDegrees(deg: Float): Float;
    static distance(x1: Float, y1: Float, x2: Float, y2: Float): Float;
    /**
	 * Java's String.hashCode() method implemented in Haxe.
	 * source: https://github.com/rjanicek/janicek-core-haxe/blob/master/src/co/janicek/core/math/HashCore.hx
	 */
    static hashCode(s: String): Int;
    /** Generate an uniform list of the requested size,
        containing values uniformly repartited from frequencies.
        @param values the values to put in list
        @param probabilities the corresponding probability for each value
        @param size the size of the final list */
    static uniformFrequencyList(values: Array<Int>, frequencies: Array<Float>, size: Int): Array<Int>;
    /** Transforms `SOME_IDENTIFIER` to `SomeIdentifier` */
    static upperCaseToCamelCase(input: String, firstLetterUppercase?: Bool): String;
    /** Transforms `SomeIdentifier`/`someIdentifier`/`some identifier` to `SOME_IDENTIFIER` */
    static camelCaseToUpperCase(input: String, firstLetterUppercase?: Bool): String;
}

type UInt8Array = snow.api.buffers.Uint8Array;

class Tween extends Entity {
    constructor(owner: Entity?, easing: Easing, duration: Float, fromValue: Float, toValue: Float);
    static start(owner: Entity?, easing?: Easing?, duration: Float, fromValue: Float, toValue: Float, handleValueTime: ((arg1: Float, arg2: Float) => Void)): Tween;
    static ease(easing: Easing, value: Float): Float;
    /** Get a tween easing function as a plain Float->Float function. */
    static easingFunction(easing: Easing): ((arg1: Float) => Float);
    /**update event*/
    onUpdate(owner: Entity?, handleValueTime: ((value: Float, time: Float) => Void)): Void;
    /**update event*/
    onceUpdate(owner: Entity?, handleValueTime: ((value: Float, time: Float) => Void)): Void;
    /**update event*/
    offUpdate(handleValueTime?: ((value: Float, time: Float) => Void)?): Void;
    /**Does it listen to update event*/
    listensUpdate(): Bool;
    /**complete event*/
    onComplete(owner: Entity?, handle: (() => Void)): Void;
    /**complete event*/
    onceComplete(owner: Entity?, handle: (() => Void)): Void;
    /**complete event*/
    offComplete(handle?: (() => Void)?): Void;
    /**Does it listen to complete event*/
    listensComplete(): Bool;
    destroy(): Void;
    unbindEvents(): Void;
}

enum TriangulateMethod {
    /**
     * A bit slower, usually more precise
     */
    POLY2TRI    /**
     * Fast, but sometimes approximate
     */
,
    EARCUT
}

/** An utility to triangulate indices from a set of vertices */
class Triangulate {
    /** Triangulate the given vertices and fills the indices array accordingly */
    static triangulate(vertices: Array<Float>, indices: Array<Int>, holes?: Array<Int>?, method?: TriangulateMethod): Void;
}

/** A simple colored triangle, to fulfill all your triangle-shaped needs.
    The triangle is facing top and fits exactly in `width` and `height` */
class Triangle extends Mesh {
    constructor();
}

/** An utility to reuse transform matrix object at application level. */
class TransformPool {
    /** Get or create a transform. The transform object is ready to be used. */
    static get(): Transform;
    /** Recycle an existing transform. The transform will be cleaned up. */
    static recycle(transform: Transform): Void;
    static clear(): Void;
}

/** Transform holds matrix data to make 2d rotate, translate, scale and skew transformations.
    Angles are in degrees.
    Representation:
    | a | c | tx |
    | b | d | ty |
    | 0 | 0 | 1  | */
class Transform implements Events {
    constructor(a?: Float, b?: Float, c?: Float, d?: Float, tx?: Float, ty?: Float);
    /**change event*/
    emitChange(): Void;
    /**change event*/
    onChange(owner: Entity?, handle: (() => Void)): Void;
    /**change event*/
    onceChange(owner: Entity?, handle: (() => Void)): Void;
    /**change event*/
    offChange(handle?: (() => Void)?): Void;
    /**Does it listen to change event*/
    listensChange(): Bool;
    changedDirty: Bool;
    a: Float;
    b: Float;
    c: Float;
    d: Float;
    tx: Float;
    ty: Float;
    changed: Bool;
    computeChanged(): Void;
    cleanChangedState(): Void;
    clone(): Transform;
    concat(m: Transform): Void;
    decompose(output?: DecomposedTransform?): DecomposedTransform;
    setFromDecomposed(decomposed: DecomposedTransform): Void;
    setFromValues(x?: Float, y?: Float, scaleX?: Float, scaleY?: Float, rotation?: Float, skewX?: Float, skewY?: Float, pivotX?: Float, pivotY?: Float): Void;
    setFromInterpolated(transform1: Transform, transform2: Transform, ratio: Float): Void;
    deltaTransformX(x: Float, y: Float): Float;
    deltaTransformY(x: Float, y: Float): Float;
    equals(transform: Transform): Bool;
    identity(): Void;
    invert(): Void;
    /** Rotate by angle (in radians) */
    rotate(angle: Float): Void;
    scale(x: Float, y: Float): Void;
    translate(x: Float, y: Float): Void;
    skew(skewX: Float, skewY: Float): Void;
    setRotation(angle: Float, scale?: Float): Void;
    setTo(a: Float, b: Float, c: Float, d: Float, tx: Float, ty: Float): Void;
    setToTransform(transform: Transform): Void;
    toString(): String;
    transformX(x: Float, y: Float): Float;
    transformY(x: Float, y: Float): Float;
    unbindEvents(): Void;
}

class TrackerBackend {
    constructor();
    /**
     * Schedule immediate callback. These callbacks need to be flushed at some point by the backend
     * @param handleImmediate the callback to schedule
     */
    onceImmediate(handleImmediate: (() => Void)): Void;
    /**
     * Read a string for the given key
     * @param key the key to use
     * @return String or null of no string was found
     */
    readString(key: String): String;
    /**
     * Save a string for the given key
     * @param key the key to use
     * @param str the string to save
     * @return Bool `true` if the save was successful
     */
    saveString(key: String, str: String): Bool;
    /**
     * Append a string on the given key. If the key doesn't exist,
     * creates a new one with the string to append.
     * @param key the key to use
     * @param str the string to append
     * @return Bool `true` if the save was successful
     */
    appendString(key: String, str: String): Bool;
    /**
     * Log a warning message
     * @param message the warning message
     */
    warning(message: Dynamic, pos?: TAnonymous?): Void;
    /**
     * Log an error message
     * @param error the error message
     */
    error(error: Dynamic, pos?: TAnonymous?): Void;
    /**
     * Log a success message
     * @param message the success message
     */
    success(message: Dynamic, pos?: TAnonymous?): Void;
    /**
     * Run the given callback in background, if there is any background thread available
     * on this backend. Run it on the main thread otherwise like any other code
     * @param callback 
     */
    runInBackground(callback: (() => Void)): Void;
    /**
     * Run the given callback in main thread
     * @param callback 
     */
    runInMain(callback: (() => Void)): Void;
    /**
     * Execute a callback periodically at the given interval in seconds.
     * @param owner The entity that owns this interval
     * @param seconds The time in seconds between each call
     * @param callback The callback to call
     * @return Void->Void A callback to cancel the interval
     */
    interval(owner: Entity, seconds: Float, callback: (() => Void)): (() => Void);
    /**
     * Execute a callback after the given delay in seconds.
     * @param owner The entity that owns this delayed call
     * @param seconds The time in seconds of delay before the call
     * @param callback The callback to call
     * @return Void->Void A callback to cancel the delayed call
     */
    delay(owner: Entity, seconds: Float, callback: (() => Void)): (() => Void);
}

/** Utility to track a tree of entity objects and perform specific actions when some entities get untracked */
class TrackEntities extends Entity implements Component {
    constructor();
    entity: Entity;
    entityMap: Map<K, V>;
    /** Compute the whole object tree to see which entities are in it.
        It will then be possible to compare the result with a previous scan and detect new and unused entities. */
    scan(): Void;
    initializerName: String;
}

type Touches = IntMap<Touch>;

class TouchInfo {
    constructor(touchIndex: Int, buttonId: Int, x: Float, y: Float, hits: Bool);
    /** If the input is a touch input, this is the index of the touch.
        Otherwise it will be -1.*/
    touchIndex: Int;
    /** If the input is a mouse input, this is the id of the mouse button.
        Otherwise it will be -1.*/
    buttonId: Int;
    /** X coordinate of the input (relative to screen). */
    x: Float;
    /** Y coordinate of the input (relative to screen). */
    y: Float;
    /** Whether these info do hit the related visual. This is usually `true`,
        Except when we have touch/mouse up events outside of a visual that
        initially received a down event. */
    hits: Bool;
}

class Touch {
    constructor(index: Int, x: Float, y: Float);
    index: Int;
    x: Float;
    y: Float;
}

class Timer {
    /** Current time, relative to app.
        (number of active seconds since app was started) */
    static now: Float;
    /** Current unix time synchronized with ceramic Timer.
        `Timer.now` and `Timer.timestamp` are garanteed to get incremented
        exactly at the same rate.
        (number of seconds since January 1st, 1970) */
    static timestamp: Float;
    static startTimestamp: Float;
    /** Execute a callback after the given delay in seconds.
        @return a function to cancel this timer delay */
    static delay(owner: Entity?, seconds: Float, callback: (() => Void)): (() => Void);
    /** Execute a callback periodically at the given interval in seconds.
        @return a function to cancel this timer interval */
    static interval(owner: Entity?, seconds: Float, callback: (() => Void)): (() => Void);
}

/** A track meant to be updated by a timeline.
    Base implementation doesn't do much by itself.
    Create subclasses to implement details */
class TimelineTrack<K extends TimelineKeyframe> extends Entity {
    constructor();
    /** Track duration. Default `0`, meaning this track won't do anything.
        By default, because `autoFitDuration` is `true`, adding new keyframes to this
        track will update `duration` accordingly so it may not be needed to update `duration` explicitly.
        Setting `duration` to `-1` means the track will never finish. */
    duration: Float;
    /** If set to `true` (default), adding keyframes to this track will update
        its duration accordingly to match last keyframe time. */
    autoFitDuration: Bool;
    /** Whether this track should loop. Ignored if track's `duration` is `-1` (not defined). */
    loop: Bool;
    /** Whether this track is locked or not.
        A locked track doesn't get updated by the timeline it is attached to, if any. */
    locked: Bool;
    /** Timeline on which this track is added to */
    timeline: Timeline;
    /** Elapsed time on this track.
        Gets back to zero when `loop=true` and time reaches a defined `duration`. */
    time: Float;
    /** The key frames on this track. */
    keyframes: Array<K>;
    /** The keyframe right before or equal to current time, if any. */
    before: K;
    /** The keyframe right after current time, if any. */
    after: K;
    /** Seek the given time (in seconds) in the track.
        Will take care of clamping `time` or looping it depending on `duration` and `loop` properties. */
    seek(targetTime: Float): Void;
    /** Add a keyframe to this track */
    add(keyframe: K): Void;
    /** Update `duration` property to make it fit
        the time of the last keyframe on this track. */
    fitDuration(): Void;
    /** Apply changes that this track is responsible of. Usually called after `update(delta)` or `seek(time)`. */
    apply(): Void;
    /** Find the keyframe right before or equal to given `time` */
    findKeyframeBefore(time: Float): K?;
    /** Find the keyframe right after given `time` */
    findKeyframeAfter(time: Float): K?;
}

class TimelineKeyframe {
    constructor(time: Float, easing: Easing);
    time: Float;
    easing: Easing;
}

class TimelineFloatTrack extends TimelineTrack {
    constructor();
    /**change event*/
    onChange(owner: Entity?, handleTrack: ((track: TimelineFloatTrack) => Void)): Void;
    /**change event*/
    onceChange(owner: Entity?, handleTrack: ((track: TimelineFloatTrack) => Void)): Void;
    /**change event*/
    offChange(handleTrack?: ((track: TimelineFloatTrack) => Void)?): Void;
    /**Does it listen to change event*/
    listensChange(): Bool;
    value: Float;
    apply(): Void;
    unbindEvents(): Void;
}

class TimelineFloatKeyframe extends TimelineKeyframe {
    constructor(value: Float, time: Float, easing: Easing);
    value: Float;
}

class TimelineDegreesTrack extends TimelineTrack {
    constructor();
    /**change event*/
    onChange(owner: Entity?, handleTrack: ((track: TimelineDegreesTrack) => Void)): Void;
    /**change event*/
    onceChange(owner: Entity?, handleTrack: ((track: TimelineDegreesTrack) => Void)): Void;
    /**change event*/
    offChange(handleTrack?: ((track: TimelineDegreesTrack) => Void)?): Void;
    /**Does it listen to change event*/
    listensChange(): Bool;
    value: Float;
    apply(): Void;
    unbindEvents(): Void;
}

class TimelineColorTrack extends TimelineTrack {
    constructor();
    /**change event*/
    onChange(owner: Entity?, handleTrack: ((track: TimelineTrack<TimelineColorKeyframe>) => Void)): Void;
    /**change event*/
    onceChange(owner: Entity?, handleTrack: ((track: TimelineTrack<TimelineColorKeyframe>) => Void)): Void;
    /**change event*/
    offChange(handleTrack?: ((track: TimelineTrack<TimelineColorKeyframe>) => Void)?): Void;
    /**Does it listen to change event*/
    listensChange(): Bool;
    value: Color;
    apply(): Void;
    unbindEvents(): Void;
}

class TimelineColorKeyframe extends TimelineKeyframe {
    constructor(value: Color, time: Float, easing: Easing);
    value: Color;
}

class Timeline extends Entity implements Component {
    constructor();
    /** Timeline duration. Default `0`, meaning this timeline won't do anything.
        By default, because `autoFitDuration` is `true`, adding or updating tracks on this
        timeline will update timeline `duration` accordingly so it may not be needed to update `duration` explicitly.
        Setting `duration` to `-1` means the timeline will never finish. */
    duration: Float;
    /** If set to `true` (default), adding or updating tracks on this timeline will update
        timeline duration accordingly to match longest track duration. */
    autoFitDuration: Bool;
    /** Whether this timeline should loop. Ignored if timeline's `duration` is `-1` (not defined). */
    loop: Bool;
    /** Elapsed time on this timeline.
        Gets back to zero when `loop=true` and time reaches a defined `duration`. */
    time: Float;
    /** The tracks updated by this timeline */
    tracks: Array<TimelineTrack<Dynamic>>;
    /** Whether this timeline is paused or not. */
    paused: Bool;
    /** Seek the given time (in seconds) in the timeline.
        Will take care of clamping `time` or looping it depending on `duration` and `loop` properties. */
    seek(targetTime: Float): Void;
    /** Add a track to this timeline */
    add(track: TimelineTrack<Dynamic>): Void;
    /** Remove a track from this timeline */
    remove(track: TimelineTrack<Dynamic>): Void;
    /** Update `duration` property to make it fit
        the duration of the longuest track. */
    fitDuration(): Void;
    entity: Entity;
    initializerName: String;
}

/** Incremental texture tile packer that allows to alloc, release and reuse tiles as needed. */
class TextureTilePacker extends Entity {
    constructor(autoRender: Bool, maxPixelTextureWidth?: Int, maxPixelTextureHeight?: Int, padWidth?: Int, padHeight?: Int, margin?: Int);
    texture: RenderTexture;
    padWidth: Int;
    padHeight: Int;
    margin: Int;
    nextPacker: TextureTilePacker;
    destroy(): Void;
    allocTile(width: Int, height: Int): TextureTile;
    releaseTile(tile: TextureTile): Void;
    stamp(tile: TextureTile, visual: Visual, done: (() => Void)): Void;
    managesTexture(texture: Texture): Bool;
}

class TextureTile {
    constructor(texture: Texture, frameX: Float, frameY: Float, frameWidth: Float, frameHeight: Float);
    texture: Texture;
    frameX: Float;
    frameY: Float;
    frameWidth: Float;
    frameHeight: Float;
}

enum TextureFilter {
    NEAREST,
    LINEAR
}

/** A texture is an image ready to be drawn. */
class Texture extends Entity {
    constructor(backendItem: backend.Texture, density?: Float);
    isRenderTexture: Bool;
    width: Float;
    height: Float;
    density: Float;
    filter: TextureFilter;
    backendItem: backend.Texture;
    asset: ImageAsset;
    destroy(): Void;
    fetchPixels(result?: snow.api.buffers.Uint8Array?): snow.api.buffers.Uint8Array;
    submitPixels(pixels: snow.api.buffers.Uint8Array): Void;
}

class Texts {
    /**RobotoMedium.fnt*/
    static ROBOTO_MEDIUM: AssetId<String>;
    /**RobotoBold.fnt*/
    static ROBOTO_BOLD: AssetId<String>;
    /**entypo.fnt*/
    static ENTYPO: AssetId<String>;
}

interface TextInputDelegate {
    /** Returns the position in `toLine` which is closest
        to the position in `fromLine`/`fromPosition` (in X coordinates).
        Positions are relative to their line. */
    textInputClosestPositionInLine(fromPosition: Int, fromLine: Int, toLine: Int): Int;
    textInputNumberOfLines(): Int;
    textInputIndexForPosInLine(lineNumber: Int, lineOffset: Int): Int;
    textInputLineForIndex(index: Int): Int;
    textInputPosInLineForIndex(index: Int): Int;
}

class TextInput implements Events {
    constructor();
    /**update event*/
    onUpdate(owner: Entity?, handleText: ((text: String) => Void)): Void;
    /**update event*/
    onceUpdate(owner: Entity?, handleText: ((text: String) => Void)): Void;
    /**update event*/
    offUpdate(handleText?: ((text: String) => Void)?): Void;
    /**Does it listen to update event*/
    listensUpdate(): Bool;
    /**enter event*/
    onEnter(owner: Entity?, handle: (() => Void)): Void;
    /**enter event*/
    onceEnter(owner: Entity?, handle: (() => Void)): Void;
    /**enter event*/
    offEnter(handle?: (() => Void)?): Void;
    /**Does it listen to enter event*/
    listensEnter(): Bool;
    /**escape event*/
    onEscape(owner: Entity?, handle: (() => Void)): Void;
    /**escape event*/
    onceEscape(owner: Entity?, handle: (() => Void)): Void;
    /**escape event*/
    offEscape(handle?: (() => Void)?): Void;
    /**Does it listen to escape event*/
    listensEscape(): Bool;
    /**selection event*/
    onSelection(owner: Entity?, handleSelectionStartSelectionEnd: ((selectionStart: Int, selectionEnd: Int) => Void)): Void;
    /**selection event*/
    onceSelection(owner: Entity?, handleSelectionStartSelectionEnd: ((selectionStart: Int, selectionEnd: Int) => Void)): Void;
    /**selection event*/
    offSelection(handleSelectionStartSelectionEnd?: ((selectionStart: Int, selectionEnd: Int) => Void)?): Void;
    /**Does it listen to selection event*/
    listensSelection(): Bool;
    /**stop event*/
    onStop(owner: Entity?, handle: (() => Void)): Void;
    /**stop event*/
    onceStop(owner: Entity?, handle: (() => Void)): Void;
    /**stop event*/
    offStop(handle?: (() => Void)?): Void;
    /**Does it listen to stop event*/
    listensStop(): Bool;
    allowMovingCursor: Bool;
    multiline: Bool;
    text: String;
    selectionStart: Int;
    selectionEnd: Int;
    delegate: TextInputDelegate;
    start(text: String, x: Float, y: Float, w: Float, h: Float, multiline?: Bool, selectionStart?: Int, selectionEnd?: Int, allowMovingCursor?: Bool, delegate?: TextInputDelegate?): Void;
    stop(): Void;
    updateSelection(selectionStart: Int, selectionEnd: Int, inverted?: Bool?): Void;
    appendText(text: String): Void;
    space(): Void;
    backspace(): Void;
    moveLeft(): Void;
    moveRight(): Void;
    moveUp(): Void;
    moveDown(): Void;
    enter(): Void;
    escape(): Void;
    shiftDown(): Void;
    shiftUp(): Void;
    unbindEvents(): Void;
}

class TextAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    text: String;
    invalidateText(): Void;
    /**Event when text field changes.*/
    onTextChange(owner: Entity?, handleCurrentPrevious: ((current: String, previous: String) => Void)): Void;
    /**Event when text field changes.*/
    onceTextChange(owner: Entity?, handleCurrentPrevious: ((current: String, previous: String) => Void)): Void;
    /**Event when text field changes.*/
    offTextChange(handleCurrentPrevious?: ((current: String, previous: String) => Void)?): Void;
    /**Event when text field changes.*/
    listensTextChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

enum TextAlign {
    RIGHT,
    LEFT,
    CENTER
}

/** A visual to layout and display text.
    Works with UTF-8 strings. */
class Text extends Visual {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    /**glyphQuadsChange event*/
    onGlyphQuadsChange(owner: Entity?, handle: (() => Void)): Void;
    /**glyphQuadsChange event*/
    onceGlyphQuadsChange(owner: Entity?, handle: (() => Void)): Void;
    /**glyphQuadsChange event*/
    offGlyphQuadsChange(handle?: (() => Void)?): Void;
    /**Does it listen to glyphQuadsChange event*/
    listensGlyphQuadsChange(): Bool;
    glyphQuads: Array<GlyphQuad>;
    numLines: Int;
    color: Color;
    content: String;
    pointSize: Float;
    lineHeight: Float;
    letterSpacing: Float;
    font: BitmapFont;
    preRenderedSize: Int;
    align: TextAlign;
    /** If set to `true`, text will be displayed with line breaks
        as needed so that it fits in the requested width. */
    fitWidth: Float;
    maxLineDiff: Float;
    destroy(): Void;
    computeContent(): Void;
    /** Get the line number matching the given `y` position.
        `y` is relative this `Text` visual. */
    lineForYPosition(y: Float): Int;
    /** Get the character index position relative to `line` at the requested `x` value.
        `x` is relative this `Text` visual. */
    posInLineForX(line: Int, x: Float): Int;
    /** Get the _global_ character index from the given `line` and `posInLine` index position relative to `line` */
    indexForPosInLine(line: Int, posInLine: Int): Int;
    /** Get an `x` position from the given character `index`.
        `x` is relative to this `Text` visual. */
    xPositionAtIndex(index: Int): Float;
    /** Get the line number (starting from zero) of the character at the given `index` */
    lineForIndex(index: Int): Int;
    /** Get a character index position relative to its line from its _global_ `index` position. */
    posInLineForIndex(index: Int): Int;
    unbindEvents(): Void;
}

class Sounds {
}

class SoundAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    /**replaceSound event*/
    onReplaceSound(owner: Entity?, handleNewSoundPrevSound: ((newSound: Sound, prevSound: Sound) => Void)): Void;
    /**replaceSound event*/
    onceReplaceSound(owner: Entity?, handleNewSoundPrevSound: ((newSound: Sound, prevSound: Sound) => Void)): Void;
    /**replaceSound event*/
    offReplaceSound(handleNewSoundPrevSound?: ((newSound: Sound, prevSound: Sound) => Void)?): Void;
    /**Does it listen to replaceSound event*/
    listensReplaceSound(): Bool;
    stream: Bool;
    sound: Sound;
    invalidateSound(): Void;
    /**Event when sound field changes.*/
    onSoundChange(owner: Entity?, handleCurrentPrevious: ((current: Sound, previous: Sound) => Void)): Void;
    /**Event when sound field changes.*/
    onceSoundChange(owner: Entity?, handleCurrentPrevious: ((current: Sound, previous: Sound) => Void)): Void;
    /**Event when sound field changes.*/
    offSoundChange(handleCurrentPrevious?: ((current: Sound, previous: Sound) => Void)?): Void;
    /**Event when sound field changes.*/
    listensSoundChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

class Sound extends Entity {
    constructor(backendItem: backend.AudioResource);
    backendItem: backend.AudioResource;
    asset: SoundAsset;
    group: Int;
    destroy(): Void;
    /** Default volume when playing this sound. */
    volume: Float;
    /** Default pan when playing this sound. */
    pan: Float;
    /** Default pitch when playing this sound. */
    pitch: Float;
    /** Sound duration. */
    duration: Float;
    /** Play the sound at requested position. If volume/pan/pitch are not provided,
        sound instance properties will be used instead. */
    play(position?: Float, loop?: Bool, volume?: Float?, pan?: Float?, pitch?: Float?): SoundPlayer;
}

/**
    SortVisuals provides a stable implementation of merge sort through its `sort`
    method. It should be used instead of `Array.sort` in cases where the order
    of equal elements has to be retained on all targets.
    
    This specific implementation has been modified to be exclusively used with array of `ceramic.Visual` instances.
    The compare function (and the rest of the implementation) are inlined to get the best performance out of it.
*/
class SortVisuals {
    /**
        Sorts Array `a` according to the comparison function `cmp`, where
        `cmp(x,y)` returns 0 if `x == y`, a positive Int if `x > y` and a
        negative Int if `x < y`.

        This operation modifies Array `a` in place.

        This operation is stable: The order of equal elements is preserved.

        If `a` or `cmp` are null, the result is unspecified.
    */
    static sort(a: Array<Visual>): Void;
}

/**
    SortRenderTextures provides a stable implementation of merge sort through its `sort`
    method. It should be used instead of `Array.sort` in cases where the order
    of equal elements has to be retained on all targets.
    
    This specific implementation has been modified to be exclusively used with array of `ceramic.RenderTexture` instances.
    The compare function (and the rest of the implementation) are inlined to get the best performance out of it.
*/
class SortRenderTextures {
    /**
        Sorts Array `a` according to the comparison function `cmp`, where
        `cmp(x,y)` returns 0 if `x == y`, a positive Int if `x > y` and a
        negative Int if `x < y`.

        This operation modifies Array `a` in place.

        This operation is stable: The order of equal elements is preserved.

        If `a` or `cmp` are null, the result is unspecified.
    */
    static sort(a: Array<RenderTexture>): Void;
}

/** Shortcuts adds convenience identifiers to access ceramic app, screen, ...
    Use it by adding `import ceramic.Shortcuts.*;` in your files. */
class Shortcuts {
    /** Shared app instance */
    static app: App;
    /** Shared screen instance */
    static screen: Screen;
    /** Shared audio instance */
    static audio: Audio;
    /** Shared settings instance */
    static settings: Settings;
    /** Shared collections instance */
    static collections: Collections;
    /** Shared logger instance */
    static log: Logger;
}

/** Draw shapes by triangulating vertices automatically, with optional holes in it. */
class Shape extends Mesh {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    /** A flat array of vertex coordinates to describe the shape.
        `points = ...` is identical to `vertices = ... ; contentDirty = true ;`
        Note: when editing array content without reassigning it,
        `contentDirty` must be set to `true` to let the shape being updated accordingly. */
    points: Array<Float>;
    triangulation: TriangulateMethod;
    /** An array of hole indices, if any.
        (e.g. `[5, 8]` for a 12-vertex input would mean
        one hole with vertices 5–7 and another with 8–11).
        Note: when editing array content without reassigning it,
        `contentDirty` must be set to `true` to let the shape being updated accordingly. */
    holes: Array<Int>;
    /** If set to `true`, width and heigh will be computed from shape points. */
    autoComputeSize: Bool;
    computeContent(): Void;
}

class Shaders {
    /**tintBlack.vert, tintBlack.frag*/
    static TINT_BLACK: AssetId<String>;
    /**textured.frag, textured.vert*/
    static TEXTURED: AssetId<String>;
    /**pixelArt.vert, pixelArt.frag*/
    static PIXEL_ART: AssetId<String>;
    /**msdf.frag, msdf.vert*/
    static MSDF: AssetId<String>;
    /**fxaa.vert, fxaa.frag*/
    static FXAA: AssetId<String>;
}

class ShaderAttribute {
    constructor(size: Int, name: String);
    size: Int;
    name: String;
}

class ShaderAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    shader: Shader;
    load(): Void;
    destroy(): Void;
}

class Shader extends Entity {
    constructor(backendItem: backend.Shader, customAttributes?: Array<ShaderAttribute>?);
    /** Instanciates a shader from source.
        Although it would expect `GLSL` code in default ceramic backends (luxe backend),
        Expected shading language could be different in some future backend implementations. */
    static fromSource(vertSource: String, fragSource: String): Shader;
    backendItem: backend.Shader;
    asset: ShaderAsset;
    attributes: Array<ShaderAttribute>;
    customAttributes: Array<ShaderAttribute>;
    customFloatAttributesSize: Int;
    destroy(): Void;
    clone(): Shader;
    setInt(name: String, value: Int): Void;
    setFloat(name: String, value: Float): Void;
    setColor(name: String, color: Color): Void;
    setAlphaColor(name: String, color: AlphaColor): Void;
    setVec2(name: String, x: Float, y: Float): Void;
    setVec3(name: String, x: Float, y: Float, z: Float): Void;
    setVec4(name: String, x: Float, y: Float, z: Float, w: Float): Void;
    setFloatArray(name: String, array: Array<Float>): Void;
    setTexture(name: String, texture: Texture): Void;
    setMat4FromTransform(name: String, transform: Transform): Void;
}

class Settings implements Observable {
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Settings, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Settings, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Settings, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /** Target width. Affects window size at startup
        and affects screen scaling at any time.
        Ignored if set to 0 (default) */
    targetWidth: Int;
    invalidateTargetWidth(): Void;
    /**Event when targetWidth field changes.*/
    onTargetWidthChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetWidth field changes.*/
    onceTargetWidthChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetWidth field changes.*/
    offTargetWidthChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when targetWidth field changes.*/
    listensTargetWidthChange(): Bool;
    /** Target height. Affects window size at startup
        and affects screen scaling at any time.
        Ignored if set to 0 (default) */
    targetHeight: Int;
    invalidateTargetHeight(): Void;
    /**Event when targetHeight field changes.*/
    onTargetHeightChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetHeight field changes.*/
    onceTargetHeightChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetHeight field changes.*/
    offTargetHeightChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when targetHeight field changes.*/
    listensTargetHeightChange(): Bool;
    /** Target density. Affects the quality of textures
        being loaded. Changing it at runtime will update
        texture quality if needed.
        Ignored if set to 0 (default) */
    targetDensity: Int;
    invalidateTargetDensity(): Void;
    /**Event when targetDensity field changes.*/
    onTargetDensityChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetDensity field changes.*/
    onceTargetDensityChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when targetDensity field changes.*/
    offTargetDensityChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when targetDensity field changes.*/
    listensTargetDensityChange(): Bool;
    /** Background color. */
    background: Color;
    invalidateBackground(): Void;
    /**Event when background field changes.*/
    onBackgroundChange(owner: Entity?, handleCurrentPrevious: ((current: Color, previous: Color) => Void)): Void;
    /**Event when background field changes.*/
    onceBackgroundChange(owner: Entity?, handleCurrentPrevious: ((current: Color, previous: Color) => Void)): Void;
    /**Event when background field changes.*/
    offBackgroundChange(handleCurrentPrevious?: ((current: Color, previous: Color) => Void)?): Void;
    /**Event when background field changes.*/
    listensBackgroundChange(): Bool;
    /** Screen scaling (FIT, FILL, RESIZE or FIT_RESIZE). */
    scaling: ScreenScaling;
    invalidateScaling(): Void;
    /**Event when scaling field changes.*/
    onScalingChange(owner: Entity?, handleCurrentPrevious: ((current: ScreenScaling, previous: ScreenScaling) => Void)): Void;
    /**Event when scaling field changes.*/
    onceScalingChange(owner: Entity?, handleCurrentPrevious: ((current: ScreenScaling, previous: ScreenScaling) => Void)): Void;
    /**Event when scaling field changes.*/
    offScalingChange(handleCurrentPrevious?: ((current: ScreenScaling, previous: ScreenScaling) => Void)?): Void;
    /**Event when scaling field changes.*/
    listensScalingChange(): Bool;
    /** App window title. */
    title: String;
    invalidateTitle(): Void;
    /**Event when title field changes.*/
    onTitleChange(owner: Entity?, handleCurrentPrevious: ((current: String, previous: String) => Void)): Void;
    /**Event when title field changes.*/
    onceTitleChange(owner: Entity?, handleCurrentPrevious: ((current: String, previous: String) => Void)): Void;
    /**Event when title field changes.*/
    offTitleChange(handleCurrentPrevious?: ((current: String, previous: String) => Void)?): Void;
    /**Event when title field changes.*/
    listensTitleChange(): Bool;
    /** Antialiasing value (0 means disabled). */
    antialiasing: Int;
    /** Whether the window can be resized or not. */
    resizable: Bool;
    /** Assets path. */
    assetsPath: String;
    /** Settings passed to backend. */
    backend: Dynamic;
    /** Default font */
    defaultFont: AssetId<String>;
    /** Default shader */
    defaultShader: AssetId<String>;
    unbindEvents(): Void;
}

class SelectText extends Entity implements Observable, Component {
    constructor(selectionColor: Color, textCursorColor: Color);
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: SelectText, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: SelectText, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: SelectText, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /**selection event*/
    onSelection(owner: Entity?, handleSelectionStartSelectionEndInverted: ((selectionStart: Int, selectionEnd: Int, inverted: Bool) => Void)): Void;
    /**selection event*/
    onceSelection(owner: Entity?, handleSelectionStartSelectionEndInverted: ((selectionStart: Int, selectionEnd: Int, inverted: Bool) => Void)): Void;
    /**selection event*/
    offSelection(handleSelectionStartSelectionEndInverted?: ((selectionStart: Int, selectionEnd: Int, inverted: Bool) => Void)?): Void;
    /**Does it listen to selection event*/
    listensSelection(): Bool;
    entity: Text;
    selectionColor: Color;
    textCursorColor: Color;
    /** Optional container on which pointer events are bound */
    container: Visual;
    invalidateContainer(): Void;
    /**Event when container field changes.*/
    onContainerChange(owner: Entity?, handleCurrentPrevious: ((current: Visual, previous: Visual) => Void)): Void;
    /**Event when container field changes.*/
    onceContainerChange(owner: Entity?, handleCurrentPrevious: ((current: Visual, previous: Visual) => Void)): Void;
    /**Event when container field changes.*/
    offContainerChange(handleCurrentPrevious?: ((current: Visual, previous: Visual) => Void)?): Void;
    /**Event when container field changes.*/
    listensContainerChange(): Bool;
    allowSelectingFromPointer: Bool;
    invalidateAllowSelectingFromPointer(): Void;
    /**Event when allowSelectingFromPointer field changes.*/
    onAllowSelectingFromPointerChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when allowSelectingFromPointer field changes.*/
    onceAllowSelectingFromPointerChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when allowSelectingFromPointer field changes.*/
    offAllowSelectingFromPointerChange(handleCurrentPrevious?: ((current: Bool, previous: Bool) => Void)?): Void;
    /**Event when allowSelectingFromPointer field changes.*/
    listensAllowSelectingFromPointerChange(): Bool;
    showCursor: Bool;
    invalidateShowCursor(): Void;
    /**Event when showCursor field changes.*/
    onShowCursorChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when showCursor field changes.*/
    onceShowCursorChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when showCursor field changes.*/
    offShowCursorChange(handleCurrentPrevious?: ((current: Bool, previous: Bool) => Void)?): Void;
    /**Event when showCursor field changes.*/
    listensShowCursorChange(): Bool;
    selectionStart: Int;
    invalidateSelectionStart(): Void;
    /**Event when selectionStart field changes.*/
    onSelectionStartChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when selectionStart field changes.*/
    onceSelectionStartChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when selectionStart field changes.*/
    offSelectionStartChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when selectionStart field changes.*/
    listensSelectionStartChange(): Bool;
    selectionEnd: Int;
    invalidateSelectionEnd(): Void;
    /**Event when selectionEnd field changes.*/
    onSelectionEndChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when selectionEnd field changes.*/
    onceSelectionEndChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when selectionEnd field changes.*/
    offSelectionEndChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when selectionEnd field changes.*/
    listensSelectionEndChange(): Bool;
    invertedSelection: Bool;
    invalidateInvertedSelection(): Void;
    /**Event when invertedSelection field changes.*/
    onInvertedSelectionChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when invertedSelection field changes.*/
    onceInvertedSelectionChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when invertedSelection field changes.*/
    offInvertedSelectionChange(handleCurrentPrevious?: ((current: Bool, previous: Bool) => Void)?): Void;
    /**Event when invertedSelection field changes.*/
    listensInvertedSelectionChange(): Bool;
    pointerIsDown: Bool;
    invalidatePointerIsDown(): Void;
    /**Event when pointerIsDown field changes.*/
    onPointerIsDownChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when pointerIsDown field changes.*/
    oncePointerIsDownChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when pointerIsDown field changes.*/
    offPointerIsDownChange(handleCurrentPrevious?: ((current: Bool, previous: Bool) => Void)?): Void;
    /**Event when pointerIsDown field changes.*/
    listensPointerIsDownChange(): Bool;
    unbindEvents(): Void;
    initializerName: String;
}

/** Seeded random number generator to get reproducible sequences of values. */
class SeedRandom {
    constructor(seed: Float);
    seed: Float;
    initialSeed: Float;
    /** Returns a float number between [0,1) */
    random(): Float;
    /** Return an integer between [min, max). */
    between(min: Int, max: Int): Int;
    /** Reset the initial value to that of the current seed. */
    reset(initialSeed?: Float?): Void;
}

enum ScrollerStatus {
    /** Being touched, but not dragging yet */
    TOUCHING    /** Scrolling after dragging has ended */
,
    SCROLLING    /** Nothing happening */
,
    IDLE    /** Being dragged by a touch/mouse event */
,
    DRAGGING
}

class Scroller extends Visual {
    constructor(content?: Visual?);
    static threshold: Float;
    /**dragStart event*/
    onDragStart(owner: Entity?, handle: (() => Void)): Void;
    /**dragStart event*/
    onceDragStart(owner: Entity?, handle: (() => Void)): Void;
    /**dragStart event*/
    offDragStart(handle?: (() => Void)?): Void;
    /**Does it listen to dragStart event*/
    listensDragStart(): Bool;
    /**dragEnd event*/
    onDragEnd(owner: Entity?, handle: (() => Void)): Void;
    /**dragEnd event*/
    onceDragEnd(owner: Entity?, handle: (() => Void)): Void;
    /**dragEnd event*/
    offDragEnd(handle?: (() => Void)?): Void;
    /**Does it listen to dragEnd event*/
    listensDragEnd(): Bool;
    /**wheelStart event*/
    onWheelStart(owner: Entity?, handle: (() => Void)): Void;
    /**wheelStart event*/
    onceWheelStart(owner: Entity?, handle: (() => Void)): Void;
    /**wheelStart event*/
    offWheelStart(handle?: (() => Void)?): Void;
    /**Does it listen to wheelStart event*/
    listensWheelStart(): Bool;
    /**wheelEnd event*/
    onWheelEnd(owner: Entity?, handle: (() => Void)): Void;
    /**wheelEnd event*/
    onceWheelEnd(owner: Entity?, handle: (() => Void)): Void;
    /**wheelEnd event*/
    offWheelEnd(handle?: (() => Void)?): Void;
    /**Does it listen to wheelEnd event*/
    listensWheelEnd(): Bool;
    /**click event*/
    onClick(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**click event*/
    onceClick(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**click event*/
    offClick(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to click event*/
    listensClick(): Bool;
    /**scrollerPointerDown event*/
    onScrollerPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**scrollerPointerDown event*/
    onceScrollerPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**scrollerPointerDown event*/
    offScrollerPointerDown(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to scrollerPointerDown event*/
    listensScrollerPointerDown(): Bool;
    /**scrollerPointerUp event*/
    onScrollerPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**scrollerPointerUp event*/
    onceScrollerPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**scrollerPointerUp event*/
    offScrollerPointerUp(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to scrollerPointerUp event*/
    listensScrollerPointerUp(): Bool;
    content: Visual;
    scrollbar: Visual;
    direction: ScrollDirection;
    allowPointerOutside: Bool;
    scrollTransform: Transform;
    scrollEnabled: Bool;
    dragEnabled: Bool;
    status: ScrollerStatus;
    /** When set to `true`, vertical mouse wheel event
        will also work on horizontal scroller. */
    verticalToHorizontalWheel: Bool;
    deceleration: Float;
    wheelDeceleration: Float;
    wheelFactor: Float;
    wheelMomentum: Bool;
    wheelEndDelay: Float;
    overScrollResistance: Float;
    maxClickMomentum: Float;
    bounceMomentumFactor: Float;
    bounceMinDuration: Float;
    bounceDurationFactor: Float;
    bounceNoMomentumDuration: Float;
    dragFactor: Float;
    touchableStrictHierarchy: Bool;
    scrollToBounds(): Void;
    isContentPositionInBounds(x: Float, y: Float): Bool;
    ensureContentPositionIsInBounds(x: Float, y: Float): Void;
    scrollX: Float;
    scrollY: Float;
    scrollVelocity: Velocity;
    momentum: Float;
    isOverScrollingTop(): Bool;
    isOverScrollingBottom(): Bool;
    isOverScrollingLeft(): Bool;
    isOverScrollingRight(): Bool;
    stop(): Void;
    stopTweens(): Void;
    scrollTo(scrollX: Float, scrollY: Float): Void;
    smoothScrollTo(scrollX: Float, scrollY: Float, duration?: Float, easing?: Easing?): Void;
    snapTo(scrollX: Float, scrollY: Float, duration?: Float, easing?: Easing?): Void;
    bounce(): Void;
    unbindEvents(): Void;
}

enum ScrollDirection {
    VERTICAL,
    HORIZONTAL
}

type ScriptContent = String;

enum ScreenScaling {
    /** Screen width and height are automatically resized
        to exactly match native screen size. */
    RESIZE    /** Either width or height is increased so that aspect ratio
        becomes the same as as native screen's aspect ratio.
        Result is scaled to fit exactly into native screen bounds. */
,
    FIT_RESIZE    /** Screen width and height match target size in settings.
        Result is scaled to fit into native screen bounds. */
,
    FIT    /** Screen width and height match target size in settings.
        Result is scaled to fill native screen area. */
,
    FILL
}

class Screen extends Entity implements Observable {
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Screen, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Screen, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Screen, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /** Screen density computed from app's logical width/height
        settings and native width/height. */
    density: Float;
    /** Logical width used in app to position elements.
        Updated when the screen is resized. */
    width: Float;
    /** Logical height used in app to position elements.
        Updated when the screen is resized. */
    height: Float;
    /** The actual width available on screen, including offsets, in the same unit as `width`.
        Updated when the screen is resized. */
    actualWidth: Float;
    /** The actual height available on screen, including offsets, in the same unit as `width`.
        Updated when the screen is resized. */
    actualHeight: Float;
    /** Logical x offset.
        Updated when the screen is resized. */
    offsetX: Float;
    /** Logical y offset.
        Updated when the screen is resized. */
    offsetY: Float;
    /** Native width */
    nativeWidth: Float;
    /** Native height */
    nativeHeight: Float;
    /** Native pixel ratio/density. */
    nativeDensity: Float;
    /** Pointer x coordinate, computed from mouse and touch events.
        When using multiple touch inputs at the same time, x will be
        the mean value of all touches x value. Use this as a
        convenience when you don't want to deal with multiple positions. */
    pointerX: Float;
    /** Pointer y coordinate, computed from mouse and touch events.
        When using multiple touch inputs at the same time, y will be
        the mean value of all touches y value. Use this as a
        convenience when you don't want to deal with multiple positions. */
    pointerY: Float;
    /** Mouse x coordinate, computed from mouse events. */
    mouseX: Float;
    /** Mouse y coordinate, computed from mouse events. */
    mouseY: Float;
    /** Touches x and y coordinates by touch index. */
    touches: IntMap<Touch>;
    /** Focused visual */
    focusedVisual: Visual;
    /** Ideal textures density, computed from settings
        targetDensity and current screen state. */
    texturesDensity: Float;
    invalidateTexturesDensity(): Void;
    /**Event when texturesDensity field changes.*/
    onTexturesDensityChange(owner: Entity?, handleCurrentPrevious: ((current: Float, previous: Float) => Void)): Void;
    /**Event when texturesDensity field changes.*/
    onceTexturesDensityChange(owner: Entity?, handleCurrentPrevious: ((current: Float, previous: Float) => Void)): Void;
    /**Event when texturesDensity field changes.*/
    offTexturesDensityChange(handleCurrentPrevious?: ((current: Float, previous: Float) => Void)?): Void;
    /**Event when texturesDensity field changes.*/
    listensTexturesDensityChange(): Bool;
    /** Whether the screen is between a `pointer down` and an `pointer up` event or not. */
    isPointerDown: Bool;
    /** Resize event occurs once at startup, then each time any
        of native width, height or density changes. */
    onResize(owner: Entity?, handle: (() => Void)): Void;
    /** Resize event occurs once at startup, then each time any
        of native width, height or density changes. */
    onceResize(owner: Entity?, handle: (() => Void)): Void;
    /** Resize event occurs once at startup, then each time any
        of native width, height or density changes. */
    offResize(handle?: (() => Void)?): Void;
    /** Resize event occurs once at startup, then each time any
        of native width, height or density changes. */
    listensResize(): Bool;
    /**mouseDown event*/
    onMouseDown(owner: Entity?, handleButtonIdXY: ((buttonId: Int, x: Float, y: Float) => Void)): Void;
    /**mouseDown event*/
    onceMouseDown(owner: Entity?, handleButtonIdXY: ((buttonId: Int, x: Float, y: Float) => Void)): Void;
    /**mouseDown event*/
    offMouseDown(handleButtonIdXY?: ((buttonId: Int, x: Float, y: Float) => Void)?): Void;
    /**Does it listen to mouseDown event*/
    listensMouseDown(): Bool;
    /**mouseUp event*/
    onMouseUp(owner: Entity?, handleButtonIdXY: ((buttonId: Int, x: Float, y: Float) => Void)): Void;
    /**mouseUp event*/
    onceMouseUp(owner: Entity?, handleButtonIdXY: ((buttonId: Int, x: Float, y: Float) => Void)): Void;
    /**mouseUp event*/
    offMouseUp(handleButtonIdXY?: ((buttonId: Int, x: Float, y: Float) => Void)?): Void;
    /**Does it listen to mouseUp event*/
    listensMouseUp(): Bool;
    /**mouseWheel event*/
    onMouseWheel(owner: Entity?, handleXY: ((x: Float, y: Float) => Void)): Void;
    /**mouseWheel event*/
    onceMouseWheel(owner: Entity?, handleXY: ((x: Float, y: Float) => Void)): Void;
    /**mouseWheel event*/
    offMouseWheel(handleXY?: ((x: Float, y: Float) => Void)?): Void;
    /**Does it listen to mouseWheel event*/
    listensMouseWheel(): Bool;
    /**mouseMove event*/
    onMouseMove(owner: Entity?, handleXY: ((x: Float, y: Float) => Void)): Void;
    /**mouseMove event*/
    onceMouseMove(owner: Entity?, handleXY: ((x: Float, y: Float) => Void)): Void;
    /**mouseMove event*/
    offMouseMove(handleXY?: ((x: Float, y: Float) => Void)?): Void;
    /**Does it listen to mouseMove event*/
    listensMouseMove(): Bool;
    /**touchDown event*/
    onTouchDown(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchDown event*/
    onceTouchDown(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchDown event*/
    offTouchDown(handleTouchIndexXY?: ((touchIndex: Int, x: Float, y: Float) => Void)?): Void;
    /**Does it listen to touchDown event*/
    listensTouchDown(): Bool;
    /**touchUp event*/
    onTouchUp(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchUp event*/
    onceTouchUp(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchUp event*/
    offTouchUp(handleTouchIndexXY?: ((touchIndex: Int, x: Float, y: Float) => Void)?): Void;
    /**Does it listen to touchUp event*/
    listensTouchUp(): Bool;
    /**touchMove event*/
    onTouchMove(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchMove event*/
    onceTouchMove(owner: Entity?, handleTouchIndexXY: ((touchIndex: Int, x: Float, y: Float) => Void)): Void;
    /**touchMove event*/
    offTouchMove(handleTouchIndexXY?: ((touchIndex: Int, x: Float, y: Float) => Void)?): Void;
    /**Does it listen to touchMove event*/
    listensTouchMove(): Bool;
    /**pointerDown event*/
    onPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerDown event*/
    oncePointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerDown event*/
    offPointerDown(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerDown event*/
    listensPointerDown(): Bool;
    /**pointerUp event*/
    onPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerUp event*/
    oncePointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerUp event*/
    offPointerUp(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerUp event*/
    listensPointerUp(): Bool;
    /**pointerMove event*/
    onPointerMove(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerMove event*/
    oncePointerMove(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**pointerMove event*/
    offPointerMove(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to pointerMove event*/
    listensPointerMove(): Bool;
    /**multiTouchPointerDown event*/
    onMultiTouchPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerDown event*/
    onceMultiTouchPointerDown(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerDown event*/
    offMultiTouchPointerDown(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to multiTouchPointerDown event*/
    listensMultiTouchPointerDown(): Bool;
    /**multiTouchPointerUp event*/
    onMultiTouchPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerUp event*/
    onceMultiTouchPointerUp(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerUp event*/
    offMultiTouchPointerUp(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to multiTouchPointerUp event*/
    listensMultiTouchPointerUp(): Bool;
    /**multiTouchPointerMove event*/
    onMultiTouchPointerMove(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerMove event*/
    onceMultiTouchPointerMove(owner: Entity?, handleInfo: ((info: TouchInfo) => Void)): Void;
    /**multiTouchPointerMove event*/
    offMultiTouchPointerMove(handleInfo?: ((info: TouchInfo) => Void)?): Void;
    /**Does it listen to multiTouchPointerMove event*/
    listensMultiTouchPointerMove(): Bool;
    /**focus event*/
    onFocus(owner: Entity?, handleVisual: ((visual: Visual) => Void)): Void;
    /**focus event*/
    onceFocus(owner: Entity?, handleVisual: ((visual: Visual) => Void)): Void;
    /**focus event*/
    offFocus(handleVisual?: ((visual: Visual) => Void)?): Void;
    /**Does it listen to focus event*/
    listensFocus(): Bool;
    /**blur event*/
    onBlur(owner: Entity?, handleVisual: ((visual: Visual) => Void)): Void;
    /**blur event*/
    onceBlur(owner: Entity?, handleVisual: ((visual: Visual) => Void)): Void;
    /**blur event*/
    offBlur(handleVisual?: ((visual: Visual) => Void)?): Void;
    /**Does it listen to blur event*/
    listensBlur(): Bool;
    addHitVisual(visual: Visual): Void;
    removeHitVisual(visual: Visual): Void;
    isHitVisual(visual: Visual): Bool;
    unbindEvents(): Void;
}

/** The scanCode class. The values below come directly from SDL header include files,
but they aren't specific to SDL so they are used generically */
class ScanCode {
    /** Convert a scanCode to a readable name */
    static name(scanCode: Int): String;
    static MASK: Int;
    static UNKNOWN: Int;
    static KEY_A: Int;
    static KEY_B: Int;
    static KEY_C: Int;
    static KEY_D: Int;
    static KEY_E: Int;
    static KEY_F: Int;
    static KEY_G: Int;
    static KEY_H: Int;
    static KEY_I: Int;
    static KEY_J: Int;
    static KEY_K: Int;
    static KEY_L: Int;
    static KEY_M: Int;
    static KEY_N: Int;
    static KEY_O: Int;
    static KEY_P: Int;
    static KEY_Q: Int;
    static KEY_R: Int;
    static KEY_S: Int;
    static KEY_T: Int;
    static KEY_U: Int;
    static KEY_V: Int;
    static KEY_W: Int;
    static KEY_X: Int;
    static KEY_Y: Int;
    static KEY_Z: Int;
    static KEY_1: Int;
    static KEY_2: Int;
    static KEY_3: Int;
    static KEY_4: Int;
    static KEY_5: Int;
    static KEY_6: Int;
    static KEY_7: Int;
    static KEY_8: Int;
    static KEY_9: Int;
    static KEY_0: Int;
    static ENTER: Int;
    static ESCAPE: Int;
    static BACKSPACE: Int;
    static TAB: Int;
    static SPACE: Int;
    static MINUS: Int;
    static EQUALS: Int;
    static LEFTBRACKET: Int;
    static RIGHTBRACKET: Int;
    static BACKSLASH: Int;
    static NONUSHASH: Int;
    static SEMICOLON: Int;
    static APOSTROPHE: Int;
    static GRAVE: Int;
    static COMMA: Int;
    static PERIOD: Int;
    static SLASH: Int;
    static CAPSLOCK: Int;
    static F1: Int;
    static F2: Int;
    static F3: Int;
    static F4: Int;
    static F5: Int;
    static F6: Int;
    static F7: Int;
    static F8: Int;
    static F9: Int;
    static F10: Int;
    static F11: Int;
    static F12: Int;
    static PRINTSCREEN: Int;
    static SCROLLLOCK: Int;
    static PAUSE: Int;
    static INSERT: Int;
    static HOME: Int;
    static PAGEUP: Int;
    static DELETE: Int;
    static END: Int;
    static PAGEDOWN: Int;
    static RIGHT: Int;
    static LEFT: Int;
    static DOWN: Int;
    static UP: Int;
    static NUMLOCKCLEAR: Int;
    static KP_DIVIDE: Int;
    static KP_MULTIPLY: Int;
    static KP_MINUS: Int;
    static KP_PLUS: Int;
    static KP_ENTER: Int;
    static KP_1: Int;
    static KP_2: Int;
    static KP_3: Int;
    static KP_4: Int;
    static KP_5: Int;
    static KP_6: Int;
    static KP_7: Int;
    static KP_8: Int;
    static KP_9: Int;
    static KP_0: Int;
    static KP_PERIOD: Int;
    static NONUSBACKSLASH: Int;
    static APPLICATION: Int;
    static POWER: Int;
    static KP_EQUALS: Int;
    static F13: Int;
    static F14: Int;
    static F15: Int;
    static F16: Int;
    static F17: Int;
    static F18: Int;
    static F19: Int;
    static F20: Int;
    static F21: Int;
    static F22: Int;
    static F23: Int;
    static F24: Int;
    static EXECUTE: Int;
    static HELP: Int;
    static MENU: Int;
    static SELECT: Int;
    static STOP: Int;
    static AGAIN: Int;
    static UNDO: Int;
    static CUT: Int;
    static COPY: Int;
    static PASTE: Int;
    static FIND: Int;
    static MUTE: Int;
    static VOLUMEUP: Int;
    static VOLUMEDOWN: Int;
    static KP_COMMA: Int;
    static KP_EQUALSAS400: Int;
    static INTERNATIONAL1: Int;
    static INTERNATIONAL2: Int;
    static INTERNATIONAL3: Int;
    static INTERNATIONAL4: Int;
    static INTERNATIONAL5: Int;
    static INTERNATIONAL6: Int;
    static INTERNATIONAL7: Int;
    static INTERNATIONAL8: Int;
    static INTERNATIONAL9: Int;
    static LANG1: Int;
    static LANG2: Int;
    static LANG3: Int;
    static LANG4: Int;
    static LANG5: Int;
    static LANG6: Int;
    static LANG7: Int;
    static LANG8: Int;
    static LANG9: Int;
    static ALTERASE: Int;
    static SYSREQ: Int;
    static CANCEL: Int;
    static CLEAR: Int;
    static PRIOR: Int;
    static RETURN2: Int;
    static SEPARATOR: Int;
    static OUT: Int;
    static OPER: Int;
    static CLEARAGAIN: Int;
    static CRSEL: Int;
    static EXSEL: Int;
    static KP_00: Int;
    static KP_000: Int;
    static THOUSANDSSEPARATOR: Int;
    static DECIMALSEPARATOR: Int;
    static CURRENCYUNIT: Int;
    static CURRENCYSUBUNIT: Int;
    static KP_LEFTPAREN: Int;
    static KP_RIGHTPAREN: Int;
    static KP_LEFTBRACE: Int;
    static KP_RIGHTBRACE: Int;
    static KP_TAB: Int;
    static KP_BACKSPACE: Int;
    static KP_A: Int;
    static KP_B: Int;
    static KP_C: Int;
    static KP_D: Int;
    static KP_E: Int;
    static KP_F: Int;
    static KP_XOR: Int;
    static KP_POWER: Int;
    static KP_PERCENT: Int;
    static KP_LESS: Int;
    static KP_GREATER: Int;
    static KP_AMPERSAND: Int;
    static KP_DBLAMPERSAND: Int;
    static KP_VERTICALBAR: Int;
    static KP_DBLVERTICALBAR: Int;
    static KP_COLON: Int;
    static KP_HASH: Int;
    static KP_SPACE: Int;
    static KP_AT: Int;
    static KP_EXCLAM: Int;
    static KP_MEMSTORE: Int;
    static KP_MEMRECALL: Int;
    static KP_MEMCLEAR: Int;
    static KP_MEMADD: Int;
    static KP_MEMSUBTRACT: Int;
    static KP_MEMMULTIPLY: Int;
    static KP_MEMDIVIDE: Int;
    static KP_PLUSMINUS: Int;
    static KP_CLEAR: Int;
    static KP_CLEARENTRY: Int;
    static KP_BINARY: Int;
    static KP_OCTAL: Int;
    static KP_DECIMAL: Int;
    static KP_HEXADECIMAL: Int;
    static LCTRL: Int;
    static LSHIFT: Int;
    static LALT: Int;
    static LMETA: Int;
    static RCTRL: Int;
    static RSHIFT: Int;
    static RALT: Int;
    static RMETA: Int;
    static MODE: Int;
    static AUDIONEXT: Int;
    static AUDIOPREV: Int;
    static AUDIOSTOP: Int;
    static AUDIOPLAY: Int;
    static AUDIOMUTE: Int;
    static MEDIASELECT: Int;
    static WWW: Int;
    static MAIL: Int;
    static CALCULATOR: Int;
    static COMPUTER: Int;
    static AC_SEARCH: Int;
    static AC_HOME: Int;
    static AC_BACK: Int;
    static AC_FORWARD: Int;
    static AC_STOP: Int;
    static AC_REFRESH: Int;
    static AC_BOOKMARKS: Int;
    static BRIGHTNESSDOWN: Int;
    static BRIGHTNESSUP: Int;
    static DISPLAYSWITCH: Int;
    static KBDILLUMTOGGLE: Int;
    static KBDILLUMDOWN: Int;
    static KBDILLUMUP: Int;
    static EJECT: Int;
    static SLEEP: Int;
    static APP1: Int;
    static APP2: Int;
}

/** Runtime utilities to compute asset lists/names from raw (relative) file list.
    Code is very similar to AssetsMacro, but for runtime execution, with any list of asset. */
class RuntimeAssets {
    constructor(allAssets: Array<String>, path?: String?);
    static fromPath(path: String): RuntimeAssets;
    path: String;
    reset(allAssets: Array<String>, path?: String?): Void;
    getNames(kind: String, extensions?: Array<String>?, dir?: Bool): Array<TAnonymous>;
    getLists(): TAnonymous;
    /** Same as getLists(), but will transform Maps into JSON-encodable raw objects. */
    getEncodableLists(): TAnonymous;
}

/** 
A simple Haxe class for easily running threads and calling functions on the primary thread.
from https://github.com/underscorediscovery/

Usage:
- call Runner.init() from your primary thread 
- call Runner.tick() periodically to service callbacks (i.e inside your main loop)
- use Runner.thread(function() { ... }) to make a thread
- use Runner.runInMainThread(function() { ... }) to run code on the main thread
- use runInMainThreadBlocking to run code on the main thread and wait for the return value

*/
class Runner {
    /** Returns `true` if _running in background_ is emulated on this platform by
        running _background_ code in main thread instead of using background thread. */
    static isEmulatingBackgroundWithMain(): Bool;
    /** Call a function on the primary thread without waiting or blocking.
        If you want return values see runInMainBlocking */
    static runInMain(_fn: (() => Void)): Void;
    /** Create a background thread using the given function, or just run (deferred) the function if threads are not supported */
    static runInBackground(fn: (() => Void)): Void;
}

/** A reusable array to use in places that need a temporary array many times.
    Changing array size only increases the backing array size but never decreases it. */
class ReusableArray<T> {
    constructor(length: Int);
    length: Int;
    get(index: Int): T;
    set(index: Int, value: T): Void;
}

/** An implementation-independant GPU 2D renderer.
    To be used in pair with a draw backend implementation. */
class Renderer extends Entity {
    constructor();
    maxVerts: Int;
    render(isMainRender: Bool, ceramicVisuals: Array<Visual>): Void;
}

class RenderTexture extends Texture {
    constructor(width: Int, height: Int, density?: Float);
    autoRender: Bool;
    clearOnRender: Bool;
    renderDirty: Bool;
    dependingTextures: IntIntMap;
    priority: Float;
    destroy(): Void;
    /** Draws the given visual onto the render texture.
        The drawing operation is not done synchronously.
        It waits for the next draw stage of the app to perform it,
        then calls done() when finished.
        This is expected to be used with a texture `autoRender` set to `false`. */
    stamp(visual: Visual, done: (() => Void)): Void;
    /** Clears the texture, or a specific area of it with a fill color and alpha.
        The drawing operation is not done synchronously.
        It waits for the next draw stage of the app to perform it,
        then calls done() when finished.
        This is expected to be used with a texture `autoRender` set to `false`. */
    clear(color?: Color, alpha?: Float, clipX?: Float, clipY?: Float, clipWidth?: Float, clipHeight?: Float, done: (() => Void)): Void;
}

class Quad extends Visual {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    color: Color;
    /** If set to `true`, this quad will be considered
        transparent thus won't be draw on screen. 
        Children still behave and get drawn as before:
        they don't inherit this property. */
    transparent: Bool;
    tile: TextureTile;
    texture: Texture;
    rotateFrame: RotateFrame;
    frameX: Float;
    frameY: Float;
    frameWidth: Float;
    frameHeight: Float;
    destroy(): Void;
    frame(frameX: Float, frameY: Float, frameWidth: Float, frameHeight: Float): Void;
}

class Point {
    constructor(x?: Float, y?: Float);
    x: Float;
    y: Float;
}

class PersistentData {
    constructor(id: String);
    id: String;
    get(key: String): Dynamic;
    set(key: String, value: Dynamic): Void;
    remove(key: String): Void;
    exists(key: String): Bool;
    keys(): Array<String>;
    save(): Void;
}

/**
	This class provides a convenient way of working with paths. It supports the
	common path formats:

	- directory1/directory2/filename.extension
	- directory1\directory2\filename.extension
*/
class Path {
    /**
		Creates a new Path instance by parsing `path`.

		Path information can be retrieved by accessing the dir, file and ext
		properties.
	*/
    constructor(path: String);
    /**
		Returns the String representation of `path` without the file extension.

		If `path` is null, the result is unspecified.
	*/
    static withoutExtension(path: String): String;
    /**
		Returns the String representation of `path` without the directory.

		If `path` is null, the result is unspecified.
	*/
    static withoutDirectory(path: String): String;
    /**
		Returns the directory of `path`.

		If the directory is null, the empty String `""` is returned.

		If `path` is null, the result is unspecified.
	*/
    static directory(path: String): String;
    /**
		Returns the extension of `path`.

		If the extension is null, the empty String `""` is returned.

		If `path` is null, the result is unspecified.
	*/
    static extension(path: String): String;
    /**
		Returns a String representation of `path` where the extension is `ext`.

		If `path` has no extension, `ext` is added as extension.

		If `path` or `ext` are null, the result is unspecified.
	*/
    static withExtension(path: String, ext: String): String;
    /**
		Joins all paths in `paths` together.

		If `paths` is empty, the empty String `""` is returned. Otherwise the
		paths are joined with a slash between them.

		If `paths` is null, the result is unspecified.
	*/
    static join(paths: Array<String>): String;
    /**
		Normalize a given `path` (e.g. make '/usr/local/../lib' to '/usr/lib').

		Also replaces backslashes \ with slashes / and afterwards turns
		multiple slashes into a single one.

		If `path` is null, the result is unspecified.
	*/
    static normalize(path: String): String;
    /**
		Adds a trailing slash to `path`, if it does not have one already.

		If the last slash in `path` is a backslash, a backslash is appended to
		`path`.

		If the last slash in `path` is a slash, or if no slash is found, a slash
		is appended to `path`. In particular, this applies to the empty String
		`""`.

		If `path` is null, the result is unspecified.
	*/
    static addTrailingSlash(path: String): String;
    /**
		Removes trailing slashes from `path`.

		If `path` does not end with a `/` or `\`, `path` is returned unchanged.

		Otherwise the substring of `path` excluding the trailing slashes or
		backslashes is returned.

		If `path` is null, the result is unspecified.
	*/
    static removeTrailingSlashes(path: String): String;
    /**
		Returns true if the path is an absolute path, and false otherwise.
	*/
    static isAbsolute(path: String): Bool;
    /**
		The directory.

		This is the leading part of the path that is not part of the file name
		and the extension.

		Does not end with a `/` or `\` separator.

		If the path has no directory, the value is null.
	*/
    dir: String;
    /**
		The file name.

		This is the part of the part between the directory and the extension.

		If there is no file name, e.g. for ".htaccess" or "/dir/", the value
		is the empty String "".
	*/
    file: String;
    /**
		The file extension.

		It is separated from the file name by a dot. This dot is not part of
		the extension.

		If the path has no extension, the value is null.
	*/
    ext: String;
    /**
		True if the last directory separator is a backslash, false otherwise.
	*/
    backslash: Bool;
    /**
		Returns a String representation of `this` path.

		If `this.backslash` is true, backslash is used as directory separator,
		otherwise slash is used. This only affects the separator between
		`this.dir` and `this.file`.

		If `this.directory` or `this.extension` is null, their representation
		is the empty String "".
	*/
    toString(): String;
}

    /** Which status a `Particles` emitter object has. */
enum ParticlesStatus {
    /** Not emitting particles, but previously emitted particles are still spreading */
    SPREADING    /** Not emitting particles, and no particle is visible. */
,
    IDLE    /** Emitting particles. */
,
    EMITTING
}

    /**
 * How particles should be launched. If `CIRCLE`, particles will use `launchAngle` and `speed`.
 * Otherwise, particles will just use `velocityX` and `velocityY`.
 */
enum ParticlesLaunchMode {
    /** Particles will use `velocityX` and `velocityY` to be launched */
    SQUARE    /** Particles will use `launchAngle` and `speed` to be launched */
,
    CIRCLE
}

/** A visual that act as a particle emitter. */
class Particles extends Visual implements Observable {
    /**
     * Creates a new `Particles` object.
     */
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Particles, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Particles, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Particles, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /**emitParticle event*/
    onEmitParticle(owner: Entity?, handleParticle: ((particle: ParticleItem) => Void)): Void;
    /**emitParticle event*/
    onceEmitParticle(owner: Entity?, handleParticle: ((particle: ParticleItem) => Void)): Void;
    /**emitParticle event*/
    offEmitParticle(handleParticle?: ((particle: ParticleItem) => Void)?): Void;
    /**Does it listen to emitParticle event*/
    listensEmitParticle(): Bool;
    /**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
    maxVelocity(maxVelocityX: Float, maxVelocityY: Float): Void;
    /**
     * Sets the velocity starting range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityStart(startMinX: Float, startMinY: Float, startMaxX?: Float?, startMaxY?: Float?): Void;
    /**
     * Sets the velocity ending range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityEnd(endMinX: Float, endMinY: Float, endMaxX?: Float?, endMaxY?: Float?): Void;
    /**
     * Set the speed starting range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedStart(startMin: Float, startMax?: Float?): Void;
    /**
     * Set the speed ending range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedEnd(endMin: Float, endMax?: Float?): Void;
    /**
     * Set the angular acceleration range of particles launched from this emitter.
     */
    angularAcceleration(startMin: Float, startMax: Float): Void;
    /**
     * Set the angular drag range of particles launched from this emitter.
     */
    angularDrag(startMin: Float, startMax: Float): Void;
    /**
     * The angular velocity starting range of particles launched from this emitter.
     */
    angularVelocityStart(startMin: Float, startMax?: Float?): Void;
    /**
     * The angular velocity ending range of particles launched from this emitter.
     */
    angularVelocityEnd(endMin: Float, endMax?: Float?): Void;
    /**
     * The angle starting range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleStart(startMin: Float, startMax?: Float?): Void;
    /**
     * The angle ending range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleEnd(endMin: Float, endMax?: Float?): Void;
    /**
     * The angle range at which particles will be launched from this emitter.
     * Ignored unless `launchMode` is set to `CIRCLE`.
     */
    launchAngle(min: Float, max: Float): Void;
    /**
     * The life, or duration, range of particles launched from this emitter.
     */
    lifespan(min: Float, max: Float): Void;
    /**
     * Sets `scale` starting range of particles launched from this emitter.
     */
    scaleStart(startMinX: Float, startMinY: Float, startMaxX?: Float?, startMaxY?: Float?): Void;
    /**
     * Sets `scale` ending range of particles launched from this emitter.
     */
    scaleEnd(endMinX: Float, endMinY: Float, endMaxX?: Float?, endMaxY?: Float?): Void;
    /**
     * Sets `acceleration` starting range of particles launched from this emitter.
     */
    accelerationStart(startMinX: Float, startMinY: Float, startMaxX?: Float?, startMaxY?: Float?): Void;
    /**
     * Sets `acceleration` ending range of particles launched from this emitter.
     */
    accelerationEnd(endMinX: Float, endMinY: Float, endMaxX?: Float?, endMaxY?: Float?): Void;
    /**
     * Sets `drag` starting range of particles launched from this emitter.
     */
    dragStart(startMinX: Float, startMinY: Float, startMaxX?: Float?, startMaxY?: Float?): Void;
    /**
     * Sets `drag` ending range of particles launched from this emitter.
     */
    dragEnd(endMinX: Float, endMinY: Float, endMaxX?: Float?, endMaxY?: Float?): Void;
    /**
     * Sets `color` starting range of particles launched from this emitter.
     */
    colorStart(startMin: Color, startMax?: Color?): Void;
    /**
     * Sets `color` ending range of particles launched from this emitter.
     */
    colorEnd(endMin: Color, endMax?: Color?): Void;
    /**
     * Sets `alpha` starting range of particles launched from this emitter.
     */
    alphaStart(startMin: Float, startMax?: Float?): Void;
    /**
     * Sets `alpha` ending range of particles launched from this emitter.
     */
    alphaEnd(endMin: Float, endMax?: Float?): Void;
    /**
     * Determines whether the emitter is currently emitting particles or not
     */
    status: ParticlesStatus;
    invalidateStatus(): Void;
    /**Event when status field changes.*/
    onStatusChange(owner: Entity?, handleCurrentPrevious: ((current: ParticlesStatus, previous: ParticlesStatus) => Void)): Void;
    /**Event when status field changes.*/
    onceStatusChange(owner: Entity?, handleCurrentPrevious: ((current: ParticlesStatus, previous: ParticlesStatus) => Void)): Void;
    /**Event when status field changes.*/
    offStatusChange(handleCurrentPrevious?: ((current: ParticlesStatus, previous: ParticlesStatus) => Void)?): Void;
    /**Event when status field changes.*/
    listensStatusChange(): Bool;
    /**
     * Determines whether the emitter is currently paused. It is totally safe to directly toggle this.
     */
    paused: Bool;
    /**
     * How often a particle is emitted, if currently emitting.
     * Can be modified at the middle of an emission safely;
     */
    frequency: Float;
    /**
     * How particles should be launched. If `CIRCLE` (default), particles will use `launchAngle` and `speed`.
     * Otherwise, particles will just use `velocityX` and `velocityY`.
     */
    launchMode: ParticlesLaunchMode;
    /**
     * Keep the scale ratio of the particle. Uses the `scaleX` value for reference.
     */
    keepScaleRatio: Bool;
    /**
     * Apply particle scale to underlying visual or not.
     */
    visualScaleActive: Bool;
    /**
     * Apply particle color to underlying visual or not.
     */
    visualColorActive: Bool;
    /**
     * Apply particle position (x & y) to underlying visual or not.
     */
    visualPositionActive: Bool;
    /**
     * Apply particle angle to underlying visual rotation or not.
     */
    visualRotationActive: Bool;
    /**
     * Apply particle alpha to underlying visual or not.
     */
    visualAlphaActive: Bool;
    /**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
    maxVelocityX: Float;
    /**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
    maxVelocityY: Float;
    /**
     * Enable or disable the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityActive: Bool;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityStartMinX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityStartMinY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityStartMaxX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityStartMaxY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityEndMinX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityEndMinY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityEndMaxX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    velocityEndMaxY: Float;
    /**
     * Set the speed range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedStartMin: Float;
    /**
     * Set the speed range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedStartMax: Float;
    /**
     * Set the speed range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedEndMin: Float;
    /**
     * Set the speed range of particles launched from this emitter. Only used with `CIRCLE`.
     */
    speedEndMax: Float;
    /**
	 * Use in conjunction with angularAcceleration for fluid spin speed control.
	 */
    maxAngularVelocity: Float;
    /**
     * Enable or disable the angular acceleration range of particles launched from this emitter.
     */
    angularAccelerationActive: Bool;
    /**
     * Set the angular acceleration range of particles launched from this emitter.
     */
    angularAccelerationStartMin: Float;
    /**
     * Set the angular acceleration range of particles launched from this emitter.
     */
    angularAccelerationStartMax: Float;
    /**
     * Enable or disable the angular drag range of particles launched from this emitter.
     */
    angularDragActive: Bool;
    /**
     * Set the angular drag range of particles launched from this emitter.
     */
    angularDragStartMin: Float;
    /**
     * Set the angular drag range of particles launched from this emitter.
     */
    angularDragStartMax: Float;
    /**
     * Enable or disable the angular velocity range of particles launched from this emitter.
     */
    angularVelocityActive: Bool;
    /**
     * The angular velocity range of particles launched from this emitter.
     */
    angularVelocityStartMin: Float;
    /**
     * The angular velocity range of particles launched from this emitter.
     */
    angularVelocityStartMax: Float;
    /**
     * The angular velocity range of particles launched from this emitter.
     */
    angularVelocityEndMin: Float;
    /**
     * The angular velocity range of particles launched from this emitter.
     */
    angularVelocityEndMax: Float;
    /**
     * Enable or disable the angle range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleActive: Bool;
    /**
     * The angle range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleStartMin: Float;
    /**
     * The angle range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleStartMax: Float;
    /**
     * The angle range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleEndMin: Float;
    /**
     * The angle range of particles launched from this emitter.
     * `angleEndMin` and `angleEndMax` are ignored unless `ignoreAngularVelocity` is set to `true`.
     */
    angleEndMax: Float;
    /**
     * Set this if you want to specify the beginning and ending value of angle,
     * instead of using `angularVelocity` (or `angularAcceleration`).
     */
    ignoreAngularVelocity: Bool;
    /**
     * Enable or disable the angle range at which particles will be launched from this emitter.
     * Ignored unless `launchMode` is set to `CIRCLE`.
     */
    launchAngleActive: Bool;
    /**
     * The angle range at which particles will be launched from this emitter.
     * Ignored unless `launchMode` is set to `CIRCLE`.
     */
    launchAngleMin: Float;
    /**
     * The angle range at which particles will be launched from this emitter.
     * Ignored unless `launchMode` is set to `CIRCLE`.
     */
    launchAngleMax: Float;
    /**
     * Enable or disable the life, or duration, range of particles launched from this emitter.
     */
    lifespanActive: Bool;
    /**
     * The life, or duration, range of particles launched from this emitter.
     */
    lifespanMin: Float;
    /**
     * The life, or duration, range of particles launched from this emitter.
     */
    lifespanMax: Float;
    /**
     * Enable or disable `scale` range of particles launched from this emitter.
     */
    scaleActive: Bool;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleStartMinX: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleStartMinY: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleStartMaxX: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleStartMaxY: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleEndMinX: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleEndMinY: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleEndMaxX: Float;
    /**
     * Sets `scale` range of particles launched from this emitter.
     */
    scaleEndMaxY: Float;
    /**
     * Enable or disable `alpha` range of particles launched from this emitter.
     */
    alphaActive: Bool;
    /**
     * Sets `alpha` range of particles launched from this emitter.
     */
    alphaStartMin: Float;
    /**
     * Sets `alpha` range of particles launched from this emitter.
     */
    alphaStartMax: Float;
    /**
     * Sets `alpha` range of particles launched from this emitter.
     */
    alphaEndMin: Float;
    /**
     * Sets `alpha` range of particles launched from this emitter.
     */
    alphaEndMax: Float;
    /**
     * Enable or disable `color` range of particles launched from this emitter.
     */
    colorActive: Bool;
    /**
     * Sets `color` range of particles launched from this emitter.
     */
    colorStartMin: Color;
    /**
     * Sets `color` range of particles launched from this emitter.
     */
    colorStartMax: Color;
    /**
     * Sets `color` range of particles launched from this emitter.
     */
    colorEndMin: Color;
    /**
     * Sets `color` range of particles launched from this emitter.
     */
    colorEndMax: Color;
    /**
     * Enable or disable X and Y drag component of particles launched from this emitter.
     */
    dragActive: Bool;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragStartMinX: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragStartMinY: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragStartMaxX: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragStartMaxY: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragEndMinX: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragEndMinY: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragEndMaxX: Float;
    /**
     * Sets X and Y drag component of particles launched from this emitter.
     */
    dragEndMaxY: Float;
    /**
     * Enable or disable the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationActive: Bool;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationStartMinX: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationStartMinY: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationStartMaxX: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationStartMaxY: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationEndMinX: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationEndMinY: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationEndMaxX: Float;
    /**
     * Sets the `acceleration` range of particles launched from this emitter.
     * Set acceleration y-values to give particles gravity.
     */
    accelerationEndMaxY: Float;
    /**
     * A random seed used to generated particles.
     * Provide a custom seed to reproduce same chain of particles.
     */
    seed: Float;
    /**
     * Custom particle visual creation. Use this to emit custom visuals as particle. Another option
     * is to create a subclass of `Particles` and override `getParticleVisual()` method.
     */
    getCustomParticleVisual: ((existingVisual: Visual) => Visual);
    /**
     * Start emitting particles continuously.
     *
     * @param   frequency   How often to emit a particle.
     *                      `0` = never emit, `0.1` = 1 particle every 0.1 seconds, `5` = 1 particle every 5 seconds.
     * @param   quantity    How many particles to launch before stopping. `-1` (default) = never stop
     */
    emitContinuously(frequency?: Float, quantity?: Int): Void;
    /**
     * Burst a given quantity number of particles at once
     *
     * @param   quantity    How many particles to launch. Does nothing if lower than `1`
     */
    explode(quantity: Int): Void;
    /** Stop emitting (if it was emitting) */
    stop(): Void;
    /**
     * This function can be used both internally and externally to emit the next particle.
     */
    emitParticle(): Void;
    unbindEvents(): Void;
}

/** A particle item.
    You should not instanciate this yourself as
    it is managed by a `Particles` emitter object. */
class ParticleItem {
    constructor();
    visual: Visual;
    visualScaleActive: Bool;
    visualColorActive: Bool;
    visualPositionActive: Bool;
    visualRotationActive: Bool;
    visualAlphaActive: Bool;
    active: Bool;
    lifespan: Float;
    age: Float;
    /** The time relative to app when this particule was emitted */
    time: Float;
    /** Convenience: hold a random value between 0 and 1 for each particle */
    random: Float;
    /** In case implementation needs to keep a status for each particle, this property can be used for that */
    status: Int;
    colorRangeActive: Bool;
    colorRangeStart: Color;
    colorRangeEnd: Color;
    color: Color;
    accelerationRangeActive: Bool;
    accelerationRangeStartX: Float;
    accelerationRangeStartY: Float;
    accelerationRangeEndX: Float;
    accelerationRangeEndY: Float;
    accelerationX: Float;
    accelerationY: Float;
    dragRangeActive: Bool;
    dragRangeStartX: Float;
    dragRangeStartY: Float;
    dragRangeEndX: Float;
    dragRangeEndY: Float;
    dragX: Float;
    dragY: Float;
    velocityRangeActive: Bool;
    velocityRangeStartX: Float;
    velocityRangeStartY: Float;
    velocityRangeEndX: Float;
    velocityRangeEndY: Float;
    velocityX: Float;
    velocityY: Float;
    angularVelocityRangeActive: Bool;
    angularVelocityRangeStart: Float;
    angularVelocityRangeEnd: Float;
    angularVelocity: Float;
    angularAccelerationRangeActive: Bool;
    angularAccelerationRangeStart: Float;
    angularAccelerationRangeEnd: Float;
    angularAcceleration: Float;
    angularDrag: Float;
    scaleRangeActive: Bool;
    scaleRangeStartX: Float;
    scaleRangeStartY: Float;
    scaleRangeEndX: Float;
    scaleRangeEndY: Float;
    scaleX: Float;
    scaleY: Float;
    scale(scaleX: Float, scaleY: Float): Void;
    x: Float;
    y: Float;
    pos(x: Float, y: Float): Void;
    angle: Float;
    alphaRangeActive: Bool;
    alphaRangeStart: Float;
    alphaRangeEnd: Float;
    alpha: Float;
    reset(): Void;
}

class NapePhysics extends Entity {
    constructor();
}

/** An utility to reuse meshes at application level. */
class MeshPool {
    /** Get or create a mesh. The mesh is active an ready to be displayed. */
    static get(): Mesh;
    /** Recycle an existing mesh. The mesh will be cleaned up and marked as inactive (e.g. not displayed) */
    static recycle(mesh: Mesh): Void;
    static clear(): Void;
}

/** Draw anything composed of triangles/vertices. */
class Mesh extends Visual {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    colorMapping: MeshColorMapping;
    /** The number of floats to add to fill float attributes in vertices array.
        Default is zero: no custom attributes. Update this value when using shaders with custom attributes. */
    customFloatAttributesSize: Int;
    /** When set to `true` hit test on this mesh will be performed at vertices level instead
        of simply using bounds. This make the test substancially more expensive however.
        Use only when needed. */
    complexHit: Bool;
    destroy(): Void;
    /** Can be used instead of colors array when the mesh is only composed of a single color. */
    color: Color;
    /** An array of floats where each pair of numbers is treated as a coordinate location (x,y) */
    vertices: Array<Float>;
    /** An array of integers or indexes, where every three indexes define a triangle. */
    indices: Array<Int>;
    /** An array of colors for each vertex. */
    colors: Array<AlphaColor>;
    /** The texture used on the mesh (optional) */
    texture: Texture;
    /** An array of normalized coordinates used to apply texture mapping.
        Required if the texture is set. */
    uvs: Array<Float>;
    /** Compute width and height from vertices */
    computeSize(): Void;
    /**
     * Compute vertices and indices to obtain a grid with `cols` columns
     * and `rows` rows at the requested `width` and `height`.
     * @param cols The number of columnns in the grid
     * @param rows The number of rows in the grid
     * @param width The width of the grid
     * @param height The height of the grid
     */
    grid(cols: Int, rows: Int, width?: Float, height?: Float): Void;
    /**
     * Compute vertices, indices and uvs to obtain a grid with `cols` columns
     * and `rows` rows to fit the given texture or mesh's current texture.
     * @param cols The number of columnns in the grid
     * @param rows The number of rows in the grid
     * @param texture The texture used to generate the grid. If not provided, will use mesh's current texture
     */
    gridFromTexture(cols: Int, rows: Int, texture?: Texture?): Void;
}

class Logger extends Entity {
    constructor();
    /**info event*/
    onInfo(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**info event*/
    onceInfo(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**info event*/
    offInfo(handleValuePos?: ((value: Dynamic, pos: TAnonymous) => Void)?): Void;
    /**Does it listen to info event*/
    listensInfo(): Bool;
    /**debug event*/
    onDebug(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**debug event*/
    onceDebug(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**debug event*/
    offDebug(handleValuePos?: ((value: Dynamic, pos: TAnonymous) => Void)?): Void;
    /**Does it listen to debug event*/
    listensDebug(): Bool;
    /**success event*/
    onSuccess(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**success event*/
    onceSuccess(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**success event*/
    offSuccess(handleValuePos?: ((value: Dynamic, pos: TAnonymous) => Void)?): Void;
    /**Does it listen to success event*/
    listensSuccess(): Bool;
    /**warning event*/
    onWarning(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**warning event*/
    onceWarning(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**warning event*/
    offWarning(handleValuePos?: ((value: Dynamic, pos: TAnonymous) => Void)?): Void;
    /**Does it listen to warning event*/
    listensWarning(): Bool;
    /**error event*/
    onError(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**error event*/
    onceError(owner: Entity?, handleValuePos: ((value: Dynamic, pos: TAnonymous) => Void)): Void;
    /**error event*/
    offError(handleValuePos?: ((value: Dynamic, pos: TAnonymous) => Void)?): Void;
    /**Does it listen to error event*/
    listensError(): Bool;
    debug(value: Dynamic, pos?: TAnonymous?): Void;
    info(value: Dynamic, pos?: TAnonymous?): Void;
    success(value: Dynamic, pos?: TAnonymous?): Void;
    warning(value: Dynamic, pos?: TAnonymous?): Void;
    error(value: Dynamic, pos?: TAnonymous?): Void;
    pushIndent(): Void;
    popIndent(): Void;
    unbindEvents(): Void;
}

type LineJoin = polyline.StrokeJoin;

type LineCap = polyline.StrokeCap;

/** Display lines composed of multiple segments, curves... */
class Line extends Mesh {
    constructor();
    /** Line points.
        Note: when editing array content without reassigning it,
        `contentDirty` must be set to `true` to let the line being updated accordingly. */
    points: Array<Float>;
    /** The limit before miters turn into bevels. Default 10 */
    miterLimit: Float;
    /** The line thickness */
    thickness: Float;
    /** The join type, can be `MITER` or `BEVEL`. Default `BEVEL` */
    join: polyline.StrokeJoin;
    /** The cap type. Can be `BUTT` or `SQUARE`. Default `BUTT` */
    cap: polyline.StrokeCap;
    /** If `loop` is `true`, will try to join the first and last
        points together if they are identical. Default `false` */
    loop: Bool;
    /** If set to `true`, width and heigh will be computed from line points. */
    autoComputeSize: Bool;
    computeContent(): Void;
    computeSize(): Void;
}

/** Lazy allows to mark any property as lazy.
    Lazy properties are initialized only at first access. */
interface Lazy {
}

/** The keyCode class, with conversion helpers for scanCodes. The values below come directly from SDL header include files,
but they aren't specific to SDL so they are used generically */
class KeyCode {
    /** Convert a scanCode to a keyCode for comparison */
    static fromScanCode(scanCode: Int): Int;
    /** Convert a keyCode to a scanCode if possible.
        NOTE - this will only map a large % but not all keys,
        there is a list of unmapped keys commented in the code. */
    static toScanCode(keyCode: Int): Int;
    /** Convert a keyCode to string */
    static name(keyCode: Int): String;
    static UNKNOWN: Int;
    static ENTER: Int;
    static ESCAPE: Int;
    static BACKSPACE: Int;
    static TAB: Int;
    static SPACE: Int;
    static EXCLAIM: Int;
    static QUOTEDBL: Int;
    static HASH: Int;
    static PERCENT: Int;
    static DOLLAR: Int;
    static AMPERSAND: Int;
    static QUOTE: Int;
    static LEFTPAREN: Int;
    static RIGHTPAREN: Int;
    static ASTERISK: Int;
    static PLUS: Int;
    static COMMA: Int;
    static MINUS: Int;
    static PERIOD: Int;
    static SLASH: Int;
    static KEY_0: Int;
    static KEY_1: Int;
    static KEY_2: Int;
    static KEY_3: Int;
    static KEY_4: Int;
    static KEY_5: Int;
    static KEY_6: Int;
    static KEY_7: Int;
    static KEY_8: Int;
    static KEY_9: Int;
    static COLON: Int;
    static SEMICOLON: Int;
    static LESS: Int;
    static EQUALS: Int;
    static GREATER: Int;
    static QUESTION: Int;
    static AT: Int;
    static LEFTBRACKET: Int;
    static BACKSLASH: Int;
    static RIGHTBRACKET: Int;
    static CARET: Int;
    static UNDERSCORE: Int;
    static BACKQUOTE: Int;
    static KEY_A: Int;
    static KEY_B: Int;
    static KEY_C: Int;
    static KEY_D: Int;
    static KEY_E: Int;
    static KEY_F: Int;
    static KEY_G: Int;
    static KEY_H: Int;
    static KEY_I: Int;
    static KEY_J: Int;
    static KEY_K: Int;
    static KEY_L: Int;
    static KEY_M: Int;
    static KEY_N: Int;
    static KEY_O: Int;
    static KEY_P: Int;
    static KEY_Q: Int;
    static KEY_R: Int;
    static KEY_S: Int;
    static KEY_T: Int;
    static KEY_U: Int;
    static KEY_V: Int;
    static KEY_W: Int;
    static KEY_X: Int;
    static KEY_Y: Int;
    static KEY_Z: Int;
    static CAPSLOCK: Int;
    static F1: Int;
    static F2: Int;
    static F3: Int;
    static F4: Int;
    static F5: Int;
    static F6: Int;
    static F7: Int;
    static F8: Int;
    static F9: Int;
    static F10: Int;
    static F11: Int;
    static F12: Int;
    static PRINTSCREEN: Int;
    static SCROLLLOCK: Int;
    static PAUSE: Int;
    static INSERT: Int;
    static HOME: Int;
    static PAGEUP: Int;
    static DELETE: Int;
    static END: Int;
    static PAGEDOWN: Int;
    static RIGHT: Int;
    static LEFT: Int;
    static DOWN: Int;
    static UP: Int;
    static NUMLOCKCLEAR: Int;
    static KP_DIVIDE: Int;
    static KP_MULTIPLY: Int;
    static KP_MINUS: Int;
    static KP_PLUS: Int;
    static KP_ENTER: Int;
    static KP_1: Int;
    static KP_2: Int;
    static KP_3: Int;
    static KP_4: Int;
    static KP_5: Int;
    static KP_6: Int;
    static KP_7: Int;
    static KP_8: Int;
    static KP_9: Int;
    static KP_0: Int;
    static KP_PERIOD: Int;
    static APPLICATION: Int;
    static POWER: Int;
    static KP_EQUALS: Int;
    static F13: Int;
    static F14: Int;
    static F15: Int;
    static F16: Int;
    static F17: Int;
    static F18: Int;
    static F19: Int;
    static F20: Int;
    static F21: Int;
    static F22: Int;
    static F23: Int;
    static F24: Int;
    static EXECUTE: Int;
    static HELP: Int;
    static MENU: Int;
    static SELECT: Int;
    static STOP: Int;
    static AGAIN: Int;
    static UNDO: Int;
    static CUT: Int;
    static COPY: Int;
    static PASTE: Int;
    static FIND: Int;
    static MUTE: Int;
    static VOLUMEUP: Int;
    static VOLUMEDOWN: Int;
    static KP_COMMA: Int;
    static KP_EQUALSAS400: Int;
    static ALTERASE: Int;
    static SYSREQ: Int;
    static CANCEL: Int;
    static CLEAR: Int;
    static PRIOR: Int;
    static RETURN2: Int;
    static SEPARATOR: Int;
    static OUT: Int;
    static OPER: Int;
    static CLEARAGAIN: Int;
    static CRSEL: Int;
    static EXSEL: Int;
    static KP_00: Int;
    static KP_000: Int;
    static THOUSANDSSEPARATOR: Int;
    static DECIMALSEPARATOR: Int;
    static CURRENCYUNIT: Int;
    static CURRENCYSUBUNIT: Int;
    static KP_LEFTPAREN: Int;
    static KP_RIGHTPAREN: Int;
    static KP_LEFTBRACE: Int;
    static KP_RIGHTBRACE: Int;
    static KP_TAB: Int;
    static KP_BACKSPACE: Int;
    static KP_A: Int;
    static KP_B: Int;
    static KP_C: Int;
    static KP_D: Int;
    static KP_E: Int;
    static KP_F: Int;
    static KP_XOR: Int;
    static KP_POWER: Int;
    static KP_PERCENT: Int;
    static KP_LESS: Int;
    static KP_GREATER: Int;
    static KP_AMPERSAND: Int;
    static KP_DBLAMPERSAND: Int;
    static KP_VERTICALBAR: Int;
    static KP_DBLVERTICALBAR: Int;
    static KP_COLON: Int;
    static KP_HASH: Int;
    static KP_SPACE: Int;
    static KP_AT: Int;
    static KP_EXCLAM: Int;
    static KP_MEMSTORE: Int;
    static KP_MEMRECALL: Int;
    static KP_MEMCLEAR: Int;
    static KP_MEMADD: Int;
    static KP_MEMSUBTRACT: Int;
    static KP_MEMMULTIPLY: Int;
    static KP_MEMDIVIDE: Int;
    static KP_PLUSMINUS: Int;
    static KP_CLEAR: Int;
    static KP_CLEARENTRY: Int;
    static KP_BINARY: Int;
    static KP_OCTAL: Int;
    static KP_DECIMAL: Int;
    static KP_HEXADECIMAL: Int;
    static LCTRL: Int;
    static LSHIFT: Int;
    static LALT: Int;
    static LMETA: Int;
    static RCTRL: Int;
    static RSHIFT: Int;
    static RALT: Int;
    static RMETA: Int;
    static MODE: Int;
    static AUDIONEXT: Int;
    static AUDIOPREV: Int;
    static AUDIOSTOP: Int;
    static AUDIOPLAY: Int;
    static AUDIOMUTE: Int;
    static MEDIASELECT: Int;
    static WWW: Int;
    static MAIL: Int;
    static CALCULATOR: Int;
    static COMPUTER: Int;
    static AC_SEARCH: Int;
    static AC_HOME: Int;
    static AC_BACK: Int;
    static AC_FORWARD: Int;
    static AC_STOP: Int;
    static AC_REFRESH: Int;
    static AC_BOOKMARKS: Int;
    static BRIGHTNESSDOWN: Int;
    static BRIGHTNESSUP: Int;
    static DISPLAYSWITCH: Int;
    static KBDILLUMTOGGLE: Int;
    static KBDILLUMDOWN: Int;
    static KBDILLUMUP: Int;
    static EJECT: Int;
    static SLEEP: Int;
}

class KeyBindings extends Entity {
    constructor();
    destroy(): Void;
    bind(accelerator: Array<KeyAcceleratorItem>, callback?: (() => Void)?): KeyBinding;
}

class KeyBinding extends Entity {
    constructor(accelerator: Array<KeyAcceleratorItem>);
    /**trigger event*/
    onTrigger(owner: Entity?, handle: (() => Void)): Void;
    /**trigger event*/
    onceTrigger(owner: Entity?, handle: (() => Void)): Void;
    /**trigger event*/
    offTrigger(handle?: (() => Void)?): Void;
    /**Does it listen to trigger event*/
    listensTrigger(): Bool;
    unbindEvents(): Void;
}

enum KeyAcceleratorItem {
    SHIFT,
    CMD_OR_CTRL
}

namespace KeyAcceleratorItem {
    export function SCAN(scanCode: Int): KeyAcceleratorItem;
    export function KEY(keyCode: Int): KeyAcceleratorItem;
}

class Key {
    constructor(keyCode: Int, scanCode: Int);
    /** Key code (localized key) depends on keyboard mapping (QWERTY, AZERTY, ...) */
    keyCode: Int;
    /** Name associated to the key code (localized key) */
    keyCodeName: String;
    /** Scan code (US international key) doesn't depend on keyboard mapping (QWERTY, AZERTY, ...) */
    scanCode: Int;
    /** Name associated to the scan code (US international key) */
    scanCodeName: String;
}

/** An object map that uses integers as key. */
class IntMap<V> {
    constructor(size?: Int, fillFactor?: Float, iterable?: Bool);
    /** When this map is marked as iterable, this array will contain every key. */
    iterableKeys: Array<Int>;
    /** Values as they are stored.
        Can be used to iterate on values directly,
        but can contain null values. */
    values: haxe.ds.Vector<V>;
    get(key: Int): V;
    getInline(key: Int): V;
    exists(key: Int): Bool;
    existsInline(key: Int): Bool;
    set(key: Int, value: V): Void;
    remove(key: Int): Void;
}

/** Same as Settings, but for app startup (inside Project.new(settings)).
    Read-only values can still
    be edited at that stage. */
class InitSettings {
    constructor(settings: Settings);
    /** Target width. Affects window size at startup
        and affects screen scaling at any time.
        Ignored if set to 0 (default) */
    targetWidth: Int;
    /** Target height. Affects window size at startup
        and affects screen scaling at any time.
        Ignored if set to 0 (default) */
    targetHeight: Int;
    /** Target density. Affects the quality of textures
        being loaded. Changing it at runtime will update
        texture quality if needed.
        Ignored if set to 0 (default) */
    targetDensity: Int;
    /** Background color. */
    background: Color;
    /** Screen scaling (FIT, FILL, RESIZE, FIT_RESIZE). */
    scaling: ScreenScaling;
    /** App window title. */
    title: String;
    /** Antialiasing value (0 means disabled). */
    antialiasing: Int;
    /** Whether the window can be resized or not. */
    resizable: Bool;
    /** Assets path. */
    assetsPath: String;
    /** Settings passed to backend. */
    backend: Dynamic;
    /** Default font asset */
    defaultFont: AssetId<String>;
    /** Default shader asset */
    defaultShader: AssetId<String>;
}

class Images {
    /**white.png*/
    static WHITE: AssetId<String>;
    /**RobotoMedium.png*/
    static ROBOTO_MEDIUM: AssetId<String>;
    /**RobotoBold.png*/
    static ROBOTO_BOLD: AssetId<String>;
    /**entypo.png*/
    static ENTYPO: AssetId<String>;
}

class ImageAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    /**replaceTexture event*/
    onReplaceTexture(owner: Entity?, handleNewTexturePrevTexture: ((newTexture: Texture, prevTexture: Texture) => Void)): Void;
    /**replaceTexture event*/
    onceReplaceTexture(owner: Entity?, handleNewTexturePrevTexture: ((newTexture: Texture, prevTexture: Texture) => Void)): Void;
    /**replaceTexture event*/
    offReplaceTexture(handleNewTexturePrevTexture?: ((newTexture: Texture, prevTexture: Texture) => Void)?): Void;
    /**Does it listen to replaceTexture event*/
    listensReplaceTexture(): Bool;
    texture: Texture;
    invalidateTexture(): Void;
    /**Event when texture field changes.*/
    onTextureChange(owner: Entity?, handleCurrentPrevious: ((current: Texture, previous: Texture) => Void)): Void;
    /**Event when texture field changes.*/
    onceTextureChange(owner: Entity?, handleCurrentPrevious: ((current: Texture, previous: Texture) => Void)): Void;
    /**Event when texture field changes.*/
    offTextureChange(handleCurrentPrevious?: ((current: Texture, previous: Texture) => Void)?): Void;
    /**Event when texture field changes.*/
    listensTextureChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

/** An utility to encode strings with hashes, allowing to check their validity on decode. */
class HashedString {
    /** Encode the given string `str` and return the result. */
    static encode(str: String): String;
    /** Encode and append `str` to the already encoded string `encoded` and return the results.
        This is equivalent to `result = encoded + HashedString.encode(str)` */
    static append(encoded: String, str: String): String;
    /** Decode the given `encoded` string and return the result. */
    static decode(encoded: String): String;
    isLastDecodeIncomplete(): Bool;
}

class GlyphQuad extends Quad {
    constructor();
    /**clear event*/
    onClear(owner: Entity?, handleQuad: ((quad: GlyphQuad) => Void)): Void;
    /**clear event*/
    onceClear(owner: Entity?, handleQuad: ((quad: GlyphQuad) => Void)): Void;
    /**clear event*/
    offClear(handleQuad?: ((quad: GlyphQuad) => Void)?): Void;
    /**Does it listen to clear event*/
    listensClear(): Bool;
    char: String;
    glyph: BitmapFontCharacter;
    index: Int;
    posInLine: Int;
    line: Int;
    code: Int;
    glyphX: Float;
    glyphY: Float;
    glyphAdvance: Float;
    clear(): Void;
    unbindEvents(): Void;
}

/** Geometry-related utilities. */
class GeometryUtils {
    /** Returns `true` if the point `(x,y)` is inside the given (a,b,c) triangle */
    static pointInTriangle(x: Float, y: Float, ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float): Bool;
}

class FragmentsAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    fragments: haxe.DynamicAccess<TAnonymous>;
    invalidateFragments(): Void;
    /**Event when fragments field changes.*/
    onFragmentsChange(owner: Entity?, handleCurrentPrevious: ((current: haxe.DynamicAccess<TAnonymous>, previous: haxe.DynamicAccess<TAnonymous>) => Void)): Void;
    /**Event when fragments field changes.*/
    onceFragmentsChange(owner: Entity?, handleCurrentPrevious: ((current: haxe.DynamicAccess<TAnonymous>, previous: haxe.DynamicAccess<TAnonymous>) => Void)): Void;
    /**Event when fragments field changes.*/
    offFragmentsChange(handleCurrentPrevious?: ((current: haxe.DynamicAccess<TAnonymous>, previous: haxe.DynamicAccess<TAnonymous>) => Void)?): Void;
    /**Event when fragments field changes.*/
    listensFragmentsChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

class Fragments {
}

interface FragmentItem {
    /** Entity components. */
    components: Dynamic;
    /** Arbitrary data hold by this item. */
    data?: Dynamic?;
    /** Entity class (ex: ceramic.Visual, ceramic.Quad, ...). */
    entity: String;
    /** Entity identifier. */
    id: String;
    /** Entity name. */
    name?: String?;
    /** Properties assigned after creating entity. */
    props: Dynamic;
}

interface FragmentData {
    /** Fragment-level components */
    components: haxe.DynamicAccess<String>;
    /** Arbitrary data hold by this fragment. */
    data: Dynamic;
    /** Fragment height */
    height: Float;
    /** Identifier of the fragment. */
    id: String;
    /** Fragment items (visuals or other entities) */
    items?: Array<TAnonymous>?;
    /** Fragment width */
    width: Float;
}

class FragmentContext {
    constructor(assets: Assets, editedItems?: Bool?);
    /** The assets registry used to load/unload assets in this fragment */
    assets: Assets;
    /** Whether the items are edited items or not */
    editedItems: Bool;
}

/** A fragment is a group of visuals rendered from data (.fragment file) */
class Fragment extends Quad {
    constructor(context: FragmentContext);
    entities: Array<Entity>;
    items: Array<TAnonymous>;
    context: FragmentContext;
    fragmentData: TAnonymous;
    pendingLoads: Int;
    /**ready event*/
    onReady(owner: Entity?, handle: (() => Void)): Void;
    /**ready event*/
    onceReady(owner: Entity?, handle: (() => Void)): Void;
    /**ready event*/
    offReady(handle?: (() => Void)?): Void;
    /**Does it listen to ready event*/
    listensReady(): Bool;
    /**editableItemUpdate event*/
    onEditableItemUpdate(owner: Entity?, handleItem: ((item: TAnonymous) => Void)): Void;
    /**editableItemUpdate event*/
    onceEditableItemUpdate(owner: Entity?, handleItem: ((item: TAnonymous) => Void)): Void;
    /**editableItemUpdate event*/
    offEditableItemUpdate(handleItem?: ((item: TAnonymous) => Void)?): Void;
    /**Does it listen to editableItemUpdate event*/
    listensEditableItemUpdate(): Bool;
    putItem(item: TAnonymous): Entity;
    get(itemId: String): Entity;
    getItemInstanceByName(name: String): Entity;
    getItem(itemId: String): TAnonymous;
    getItemByName(name: String): TAnonymous;
    removeItem(itemId: String): Void;
    removeAllItems(): Void;
    destroy(): Void;
    updateEditableFieldsFromInstance(itemId: String): Void;
    /** Fragment components mapping. Does not contain components
        created separatelywith `component()` or macro-based components or components property. */
    fragmentComponents: Map<String, Component>;
    unbindEvents(): Void;
}

class Fonts {
    /**RobotoMedium.fnt*/
    static ROBOTO_MEDIUM: AssetId<String>;
    /**RobotoBold.fnt*/
    static ROBOTO_BOLD: AssetId<String>;
    /**entypo.fnt*/
    static ENTYPO: AssetId<String>;
}

class FontAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    /**replaceFont event*/
    onReplaceFont(owner: Entity?, handleNewFontPrevFont: ((newFont: BitmapFont, prevFont: BitmapFont) => Void)): Void;
    /**replaceFont event*/
    onceReplaceFont(owner: Entity?, handleNewFontPrevFont: ((newFont: BitmapFont, prevFont: BitmapFont) => Void)): Void;
    /**replaceFont event*/
    offReplaceFont(handleNewFontPrevFont?: ((newFont: BitmapFont, prevFont: BitmapFont) => Void)?): Void;
    /**Does it listen to replaceFont event*/
    listensReplaceFont(): Bool;
    fontData: BitmapFontData;
    pages: Map<K, V>;
    font: BitmapFont;
    invalidateFont(): Void;
    /**Event when font field changes.*/
    onFontChange(owner: Entity?, handleCurrentPrevious: ((current: BitmapFont, previous: BitmapFont) => Void)): Void;
    /**Event when font field changes.*/
    onceFontChange(owner: Entity?, handleCurrentPrevious: ((current: BitmapFont, previous: BitmapFont) => Void)): Void;
    /**Event when font field changes.*/
    offFontChange(handleCurrentPrevious?: ((current: BitmapFont, previous: BitmapFont) => Void)?): Void;
    /**Event when font field changes.*/
    listensFontChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

type Float32Array = snow.api.buffers.Float32Array;

/** A visuals that displays its children through a filter. A filter draws its children into a `RenderTexture`
    allowing to process the result through a shader, apply blending or alpha on the final result... */
class Filter extends Quad {
    constructor();
    /** If provided, this id will be assigned to `renderTexture.id`. */
    textureId: String;
    content: Quad;
    /** If provided, visuals in content will react to hit tests
        and touch events as if they were inside this hit visual.
        By default, `hitVisual` is the `Filter` instance itself. */
    hitVisual: Visual;
    /** If `enabled` is set to `false`, no render texture will be used.
        The children will be displayed on screen directly.
        Useful to toggle a filter without touching visuals hierarchy. */
    enabled: Bool;
    /** Texture filter */
    textureFilter: TextureFilter;
    /** Auto render? */
    autoRender: Bool;
    /** If set to true, this filter will not render automatically its children.
        It will instead set their `active` state to `false` unless explicitly rendered.
        Note that when using explicit render, `active` property on children is managed
        by this filter. */
    explicitRender: Bool;
    textureTilePacker: TextureTilePacker;
    textureTile: TextureTile;
    renderTexture: RenderTexture;
    density: Float;
    render(requestFullUpdate?: Bool, done?: (() => Void)?): Void;
    visualInContentHits(visual: Visual, x: Float, y: Float): Bool;
    computeContent(): Void;
    destroy(): Void;
}

/** Filesystem-related utilities. Only work on sys targets and/or nodejs depending on the methods */
class Files {
    static haveSameContent(filePath1: String, filePath2: String): Bool;
    /** Only works in nodejs for now. */
    static haveSameLastModified(filePath1: String, filePath2: String): Bool;
    /** Only works in nodejs for now. */
    static setToSameLastModified(srcFilePath: String, dstFilePath: String): Void;
    static getFlatDirectory(dir: String, excludeSystemFiles?: Bool, subCall?: Bool): Array<String>;
    /**
     * Get file last modified time (in seconds) or `-1` if not available
     * @param path 
     * @return Float
     */
    static getLastModified(path: String): Float;
    static removeEmptyDirectories(dir: String, excludeSystemFiles?: Bool): Void;
    static isEmptyDirectory(dir: String, excludeSystemFiles?: Bool): Bool;
    static deleteRecursive(toDelete: String): Void;
    static getRelativePath(absolutePath: String, relativeTo: String): String;
    static copyFileWithIntermediateDirs(srcPath: String, dstPath: String): Void;
    static copyDirectory(srcDir: String, dstDir: String, removeExisting?: Bool): Void;
    static getContent(path: String): String?;
    static saveContent(path: String, content: String): Void;
    static createDirectory(path: String): Void;
    static exists(path: String): Bool;
    static isDirectory(path: String): Bool;
}

/** A file watcher for ceramic compatible with `interpret.Watcher`. */
class FileWatcher extends Entity {
    constructor();
    static UPDATE_INTERVAL: Float;
    canWatch(): Bool;
    watch(path: String, onUpdate: ((arg1: String) => Void)): (() => Void);
    destroy(): Void;
}

/**
 * Extract field information from a given class type.
 * This is expected to only work with Entity subclasses marked with @editable, @fieldInfo or @autoFieldInfo
 * or classes using FieldInfoMacro. 
 */
class FieldInfo {
    static types(targetClass: String, recursive?: Bool): Map<K, V>;
    static typeOf(targetClass: String, field: String): String;
    static editableFieldInfo(targetClass: String, recursive?: Bool): Map<K, V>;
}

/** A bunch of static extensions to make life easier. */
class Extensions<T> {
    static unsafeGet<T>(array: Array<T>, index: Int): T;
    static unsafeSet<T>(array: Array<T>, index: Int, value: T): Void;
    static setArrayLength<T>(array: Array<T>, length: Int): Void;
    /** Return a random element contained in the given array */
    static randomElement<T>(array: Array<T>): T;
    /** Return a random element contained in the given array that is not equal to the `except` arg.
        @param array  The array in which we extract the element from
        @param except The element we don't want
        @param unsafe If set to `true`, will prevent allocating a new array (and may be faster) but will loop forever if there is no element except the one we don't want
        @return The random element or `null` if nothing was found */
    static randomElementExcept<T>(array: Array<T>, except: T, unsafe?: Bool): T;
    /** Return a random element contained in the given array that is validated by the provided validator.
        If no item is valid, returns null.
        @param array  The array in which we extract the element from
        @param validator A function that returns true if the item is valid, false if not
        @return The random element or `null` if nothing was found */
    static randomElementMatchingValidator<T>(array: Array<T>, validator: ((arg1: T) => Bool)): T;
    /** Shuffle an Array. This operation affects the array in place.
        The shuffle algorithm used is a variation of the [Fisher Yates Shuffle](http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle) */
    static shuffle<T>(arr: Array<T>): Void;
    static swapElements<T>(arr: Array<T>, index0: Int, index1: Int): Void;
}

class Errors {
}

class Enums {
}

class Entity implements Lazy, Events {
    /** Create a new entity */
    constructor();
    data: Dynamic;
    id: String;
    script: String;
    destroyed: Bool;
    /**destroy event*/
    onDestroy(owner: Entity?, handleEntity: ((entity: Entity) => Void)): Void;
    /**destroy event*/
    onceDestroy(owner: Entity?, handleEntity: ((entity: Entity) => Void)): Void;
    /**destroy event*/
    offDestroy(handleEntity?: ((entity: Entity) => Void)?): Void;
    /**Does it listen to destroy event*/
    listensDestroy(): Bool;
    /** Destroy this entity. This method is automatically protected from duplicate calls. That means
        calling multiple times an entity's `destroy()` method will run the destroy code only one time.
        As soon as `destroy()` is called, the entity is marked `destroyed=true`, even when calling `destroy()`
        method on a subclass (a macro is inserting a code to marke the object
        as destroyed at the beginning of every `destroy()` override function. */
    destroy(): Void;
    /** Remove all events handlers from this entity. */
    unbindEvents(): Void;
    autoruns: Array<Autorun>;
    /** Creates a new `Autorun` instance with the given callback associated with the current entity.
        @param run The run callback
        @return The autorun instance */
    autorun(run: (() => Void), afterRun?: (() => Void)?): Autorun;
    tween(easing?: Easing?, duration: Float, fromValue: Float, toValue: Float, update: ((arg1: Float, arg2: Float) => Void)): Tween;
    className(): String;
    clearComponents(): Void;
    /** Public components mapping. Contain components
        created separately with `component()` or macro-based components as well. */
    components: Map<String, Component>;
    component(name?: String?, component?: Component?): Component;
    hasComponent(name: String): Bool;
    removeComponent(name: String): Void;
    /** If set to true, that means this entity is managed by editor. */
    edited: Bool;
}

class EditText extends Entity implements TextInputDelegate, Component {
    constructor(selectionColor: Color, textCursorColor: Color);
    /**update event*/
    onUpdate(owner: Entity?, handleContent: ((content: String) => Void)): Void;
    /**update event*/
    onceUpdate(owner: Entity?, handleContent: ((content: String) => Void)): Void;
    /**update event*/
    offUpdate(handleContent?: ((content: String) => Void)?): Void;
    /**Does it listen to update event*/
    listensUpdate(): Bool;
    /**stop event*/
    onStop(owner: Entity?, handle: (() => Void)): Void;
    /**stop event*/
    onceStop(owner: Entity?, handle: (() => Void)): Void;
    /**stop event*/
    offStop(handle?: (() => Void)?): Void;
    /**Does it listen to stop event*/
    listensStop(): Bool;
    entity: Text;
    multiline: Bool;
    selectionColor: Color;
    textCursorColor: Color;
    disabled: Bool;
    /** Optional container on which pointer events are bound */
    container: Visual;
    startInput(selectionStart?: Int, selectionEnd?: Int): Void;
    stopInput(): Void;
    updateText(text: String): Void;
    focus(): Void;
    textInputClosestPositionInLine(fromPosition: Int, fromLine: Int, toLine: Int): Int;
    textInputNumberOfLines(): Int;
    textInputIndexForPosInLine(lineNumber: Int, lineOffset: Int): Int;
    textInputLineForIndex(index: Int): Int;
    textInputPosInLineForIndex(index: Int): Int;
    destroy(): Void;
    initializerName: String;
    unbindEvents(): Void;
}

enum Easing {
    SINE_EASE_OUT,
    SINE_EASE_IN_OUT,
    SINE_EASE_IN,
    QUINT_EASE_OUT,
    QUINT_EASE_IN_OUT,
    QUINT_EASE_IN,
    QUART_EASE_OUT,
    QUART_EASE_IN_OUT,
    QUART_EASE_IN,
    QUAD_EASE_OUT,
    QUAD_EASE_IN_OUT,
    QUAD_EASE_IN,
    NONE,
    LINEAR,
    EXPO_EASE_OUT,
    EXPO_EASE_IN_OUT,
    EXPO_EASE_IN,
    ELASTIC_EASE_OUT,
    ELASTIC_EASE_IN_OUT,
    ELASTIC_EASE_IN,
    CUBIC_EASE_OUT,
    CUBIC_EASE_IN_OUT,
    CUBIC_EASE_IN,
    BOUNCE_EASE_OUT,
    BOUNCE_EASE_IN_OUT,
    BOUNCE_EASE_IN,
    BACK_EASE_OUT,
    BACK_EASE_IN_OUT,
    BACK_EASE_IN
}

namespace Easing {
    export function CUSTOM(easing: ((arg1: Float) => Float)): Easing;
    export function BEZIER(x1: Float, y1: Float, x2: Float, y2: Float): Easing;
}

class DoubleClick extends Entity implements Component {
    constructor();
    /**doubleClick event*/
    onDoubleClick(owner: Entity?, handle: (() => Void)): Void;
    /**doubleClick event*/
    onceDoubleClick(owner: Entity?, handle: (() => Void)): Void;
    /**doubleClick event*/
    offDoubleClick(handle?: (() => Void)?): Void;
    /**Does it listen to doubleClick event*/
    listensDoubleClick(): Bool;
    threshold: Float;
    maxDelay: Float;
    entity: Visual;
    initializerName: String;
    unbindEvents(): Void;
}

/** Decomposed transform holds rotation, translation, scale, skew and pivot informations.
    Provided by Transform.decompose() method.
    Angles are in radians. */
class DecomposedTransform {
    constructor();
    pivotX: Float;
    pivotY: Float;
    x: Float;
    y: Float;
    rotation: Float;
    scaleX: Float;
    scaleY: Float;
    skewX: Float;
    skewY: Float;
}

class Databases {
}

class DatabaseAsset extends Asset {
    constructor(name: String, options?: Dynamic?);
    database: Array<haxe.DynamicAccess<String>>;
    invalidateDatabase(): Void;
    /**Event when database field changes.*/
    onDatabaseChange(owner: Entity?, handleCurrentPrevious: ((current: Array<haxe.DynamicAccess<String>>, previous: Array<haxe.DynamicAccess<String>>) => Void)): Void;
    /**Event when database field changes.*/
    onceDatabaseChange(owner: Entity?, handleCurrentPrevious: ((current: Array<haxe.DynamicAccess<String>>, previous: Array<haxe.DynamicAccess<String>>) => Void)): Void;
    /**Event when database field changes.*/
    offDatabaseChange(handleCurrentPrevious?: ((current: Array<haxe.DynamicAccess<String>>, previous: Array<haxe.DynamicAccess<String>>) => Void)?): Void;
    /**Event when database field changes.*/
    listensDatabaseChange(): Bool;
    load(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

class CustomAssetKind {
    constructor(kind: String, add: ((arg1: Assets, arg2: String, arg3?: Dynamic) => Void), extensions: Array<String>, dir: Bool, types: Array<String>);
    kind: String;
    add: ((arg1: Assets, arg2: String, arg3?: Dynamic) => Void);
    extensions: Array<String>;
    dir: Bool;
    types: Array<String>;
}

/** Utilities to parse CSV and related */
class Csv {
    static parse(csv: String): Array<haxe.DynamicAccess<String>>;
    static stringify(items: Array<Dynamic>, fields?: Array<String>?): String;
}

class ConvertTexture implements ConvertField {
    constructor();
    basicToField(assets: Assets, basic: String, done: ((arg1: Texture) => Void)): Void;
    fieldToBasic(value: Texture): String;
}

class ConvertMap<T> implements ConvertField {
    constructor();
    basicToField(assets: Assets, basic: haxe.DynamicAccess<T>, done: ((arg1: Map<K, V>) => Void)): Void;
    fieldToBasic(value: Map<K, V>): haxe.DynamicAccess<T>;
}

class ConvertFragmentData implements ConvertField {
    constructor();
    basicToField(assets: Assets, basic: Dynamic, done: ((arg1: TAnonymous) => Void)): Void;
    fieldToBasic(value: TAnonymous): Dynamic;
}

class ConvertFont implements ConvertField {
    constructor();
    basicToField(assets: Assets, basic: String, done: ((arg1: BitmapFont) => Void)): Void;
    fieldToBasic(value: BitmapFont): String;
}

/** Interface to convert basic type `T` to field type `U` and vice versa. */
interface ConvertField<T, U> {
    /** Get field value from basic type. As this may require loading assets,
        A usable `Assets` instance must be provided and the result will only be
        provided asynchronously by calling `done` callback. */
    basicToField(assets: Assets, basic: T, done: ((arg1: U) => Void)): Void;
    /** Get a basic type from the field value. */
    fieldToBasic(value: U): T;
}

class ConvertComponentMap implements ConvertField {
    constructor();
    basicToField(assets: Assets, basic: haxe.DynamicAccess<String>, done: ((arg1: Map<K, V>) => Void)): Void;
    fieldToBasic(value: Map<K, V>): haxe.DynamicAccess<String>;
}

class ComputeFps {
    constructor(size?: Int);
    fps: Int;
    addFrame(delta: Float): Void;
}

/** A Component is and Entity that can be bound to another Entity.
    Any Entity can be used as a Component, given that it implement Component interface.
    A Component must be an Entity subclass. */
interface Component {
    /** If this component was created from an initializer,
        its initializer name is provided to retrieve the
        initializer from the component.
        This field is automatically added to implementing class by ComponentMacro */
    initializerName: String;
}

class Collections {
    constructor();
    /** Converts an array to an equivalent collection */
    static toCollection<T>(array: Array<T>): Collection<ValueEntry<T>>;
    /** Returns a filtered collection from the provided collection and filter. */
    static filtered<T>(collection: Collection<T>, filter: ((arg1: Array<T>) => Array<T>), cacheKey?: String?): Collection<T>;
    /** Returns a combined collection from the provided ones. */
    static combined<T>(collections: Array<Collection<T>>, cache?: Bool): Collection<T>;
}

class CollectionEntry {
    /** Constructor */
    constructor(id?: String?, name?: String?);
    id: String;
    name: String;
    /** A unique index for this collection entry instance.
        Warning:
            this index is in no way predictable and may vary
            for each entry between each run of the app!
            This is intended to be used as a fast integer-typed runtime identifier,
            but do not use this to identify entries when persisting data to disk etc... */
    index: Int;
    /** Set entry fields from given raw data.
        Takes care of converting types when needed, and possible.
        It's ok if raw field are strings, like when stored in CSV files.
        Raw types can be converted to: `Bool`, `Int`, `Float`, `Color` (`Int`), `String` and `enum` types */
    setRawData(data: Dynamic): Void;
    /** Override this method to perform custom deserialisation on a specific field. If the overrided method
        returns `true`, default behavior will be skipped for the related field.*/
    setRawField(name: String, rawValue: Dynamic): Bool;
    getEditableData(): TAnonymous;
}

class Click extends Entity implements Observable, Component {
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Click, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Click, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Click, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /**click event*/
    onClick(owner: Entity?, handle: (() => Void)): Void;
    /**click event*/
    onceClick(owner: Entity?, handle: (() => Void)): Void;
    /**click event*/
    offClick(handle?: (() => Void)?): Void;
    /**Does it listen to click event*/
    listensClick(): Bool;
    threshold: Float;
    entity: Visual;
    pressed: Bool;
    invalidatePressed(): Void;
    /**Event when pressed field changes.*/
    onPressedChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when pressed field changes.*/
    oncePressedChange(owner: Entity?, handleCurrentPrevious: ((current: Bool, previous: Bool) => Void)): Void;
    /**Event when pressed field changes.*/
    offPressedChange(handleCurrentPrevious?: ((current: Bool, previous: Bool) => Void)?): Void;
    /**Event when pressed field changes.*/
    listensPressedChange(): Bool;
    cancel(): Void;
    unbindEvents(): Void;
    initializerName: String;
}

enum BorderPosition {
    OUTSIDE,
    MIDDLE,
    INSIDE
}

/** A rectangle visual that display a border */
class Border extends Mesh {
    constructor();
    borderPosition: BorderPosition;
    borderSize: Float;
    borderTopSize: Float;
    borderBottomSize: Float;
    borderLeftSize: Float;
    borderRightSize: Float;
    borderColor: Color;
    borderTopColor: Color;
    borderBottomColor: Color;
    borderLeftColor: Color;
    borderRightColor: Color;
}

class BitmapFontParser {
    static parse(rawFontData: String): BitmapFontData;
}

class BitmapFontDistanceFieldData {
    constructor(fieldType: String, distanceRange: Int);
    fieldType: String;
    distanceRange: Int;
}

class BitmapFontData {
    constructor(face: String, pointSize: Float, baseSize: Float, chars: Map<K, V>, charCount: Int, distanceField: BitmapFontDistanceFieldData?, pages: Array<TAnonymous>, lineHeight: Float, kernings: Map<K, V>);
    face: String;
    pointSize: Float;
    baseSize: Float;
    chars: Map<K, V>;
    charCount: Int;
    distanceField: BitmapFontDistanceFieldData?;
    pages: Array<TAnonymous>;
    lineHeight: Float;
    kernings: Map<K, V>;
}

class BitmapFontCharacter {
    constructor(id: Int, x: Float, y: Float, width: Float, height: Float, xOffset: Float, yOffset: Float, xAdvance: Float, page: Int);
    id: Int;
    x: Float;
    y: Float;
    width: Float;
    height: Float;
    xOffset: Float;
    yOffset: Float;
    xAdvance: Float;
    page: Int;
}

class BitmapFont extends Entity {
    constructor(fontData: BitmapFontData, pages: Map<K, V>);
    /** The map of font texture pages to their id. */
    pages: Map<K, V>;
    face: String;
    pointSize: Float;
    baseSize: Float;
    chars: Map<K, V>;
    charCount: Int;
    lineHeight: Float;
    kernings: Map<K, V>;
    msdf: Bool;
    /** Cached reference of the ' '(32) character, for sizing on tabs/spaces */
    spaceChar: BitmapFontCharacter;
    /**
     * Shaders used to render the characters. If null, uses default shader.
     * When loading MSDF fonts, ceramic's MSDF shader will be assigned here.
     * Stored per page
     */
    pageShaders: Map<K, V>;
    /**
     * When using MSDF fonts, or fonts with custom shaders, it is possible to pre-render characters
     * onto a RenderTexture to use it like a regular texture later with default shader.
     * Useful in some situations to reduce draw calls.
     */
    preRenderedPages: Map<K, V>;
    asset: Asset;
    destroy(): Void;
    needsToPreRenderAtSize(pixelSize: Int): Bool;
    preRenderAtSize(pixelSize: Int, done: (() => Void)): Void;
    /** Returns the kerning between two glyphs, or 0 if none.
        A glyph int id is the value from 'c'.charCodeAt(0) */
    kerning(first: Int, second: Int): Float?;
}

/** Bezier curve easing, ported from https://github.com/gre/bezier-easing
    then extended to work with both cubic and quadratic settings */
class BezierEasing {
    /** Create a new instance with the given arguments.
        If only `x1` and `y1` are provided, the curve is treated as quadratic.
        If all four values `x1`, `y1`, `x2`, `y2` are provided,
        the curve is treated as cubic. */
    constructor(x1: Float, y1: Float, x2?: Float?, y2?: Float?);
    static clearCache(): Void;
    /** Get or create a `BezierEasing` instance with the given parameters.
        Created instances are cached and reused. */
    static get(x1: Float, y1: Float, x2?: Float?, y2?: Float?): BezierEasing;
    /** Configure the instance with the given arguments.
        If only `x1` and `y1` are provided, the curve is treated as quadratic.
        If all four values `x1`, `y1`, `x2`, `y2` are provided,
        the curve is treated as cubic. */
    configure(x1: Float, y1: Float, x2?: Float?, y2?: Float?): Void;
    ease(x: Float): Float;
}

/** An utility to enqueue functions and execute them in bbackground, in a serialized way,
    meaning it is garanteed that no function in this queue will be run in parallel. An enqueued
    function will always be started after every previous function has finished executing. */
class BackgroundQueue extends Entity {
    constructor(checkInterval?: Float);
    /** Time interval between each checks to see if there is something to run. */
    checkInterval: Float;
    schedule(fn: (() => Void)): Void;
    destroy(): Void;
}

class AudioMixer extends Entity {
    constructor(index: Int);
    volume: Float;
    pan: Float;
    pitch: Float;
    mute: Bool;
    index: Int;
}

class Audio extends Entity {
    constructor();
    mixer(index: Int): AudioMixer;
}

class Assets extends Entity {
    constructor();
    static decodePath(path: String): AssetPathInfo;
    static addAssetKind(kind: String, add: ((arg1: Assets, arg2: String, arg3?: Dynamic) => Void), extensions: Array<String>, dir: Bool, types: Array<String>): Void;
    static assetNameFromPath(path: String): String;
    static realAssetPath(path: String, runtimeAssets?: RuntimeAssets?): String;
    static getReloadCount(realAssetPath: String): Int;
    /**All asset file paths array*/
    static all: Array<String>;
    /**All asset directory paths array*/
    static allDirs: Array<String>;
    /**Assets by base name*/
    static allByName: Map<K, V>;
    /**Asset directories by base name*/
    static allDirsByName: Map<K, V>;
    /**complete event*/
    onComplete(owner: Entity?, handleSuccess: ((success: Bool) => Void)): Void;
    /**complete event*/
    onceComplete(owner: Entity?, handleSuccess: ((success: Bool) => Void)): Void;
    /**complete event*/
    offComplete(handleSuccess?: ((success: Bool) => Void)?): Void;
    /**Does it listen to complete event*/
    listensComplete(): Bool;
    /**update event*/
    onUpdate(owner: Entity?, handleAsset: ((asset: Asset) => Void)): Void;
    /**update event*/
    onceUpdate(owner: Entity?, handleAsset: ((asset: Asset) => Void)): Void;
    /**update event*/
    offUpdate(handleAsset?: ((asset: Asset) => Void)?): Void;
    /**Does it listen to update event*/
    listensUpdate(): Bool;
    /**assetFilesChange event*/
    onAssetFilesChange(owner: Entity?, handleNewFilesPreviousFiles: ((newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)): Void;
    /**assetFilesChange event*/
    onceAssetFilesChange(owner: Entity?, handleNewFilesPreviousFiles: ((newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)): Void;
    /**assetFilesChange event*/
    offAssetFilesChange(handleNewFilesPreviousFiles?: ((newFiles: Map<String, Float>, previousFiles: Map<String, Float>) => Void)?): Void;
    /**Does it listen to assetFilesChange event*/
    listensAssetFilesChange(): Bool;
    /** If set, will be provided to each added asset in this `Assets` instance. */
    runtimeAssets: RuntimeAssets;
    defaultImageOptions: Dynamic;
    destroy(): Void;
    /** Destroy assets that have their refCount at `0`. */
    flush(): Void;
    add(id: AssetId<Dynamic>, options?: Dynamic?): Void;
    /**
     * Add all assets matching given path pattern (if provided)
     * @param pathPattern 
     */
    addAll(pathPattern?: EReg?): Void;
    addImage(name: String, options?: Dynamic?): Void;
    addFont(name: String, options?: Dynamic?): Void;
    addText(name: String, options?: Dynamic?): Void;
    addSound(name: String, options?: Dynamic?): Void;
    addDatabase(name: String, options?: Dynamic?): Void;
    addFragments(name: String, options?: Dynamic?): Void;
    addShader(name: String, options?: Dynamic?): Void;
    /** Add the given asset. If a previous asset was replaced, return it. */
    addAsset(asset: Asset): Asset;
    asset(idOrName: Dynamic, kind?: String?): Asset;
    removeAsset(asset: Asset): Void;
    load(): Void;
    /** Ensures and asset is loaded and return it on the callback.
        This will check if the requested asset is currently being loaded,
        already loaded or should be added and loaded. In all cases, it will try
        its best to deliver the requested asset or `null` if something went wrong. */
    ensure(id: AssetId<Dynamic>, options?: Dynamic?, done: ((arg1: Asset) => Void)): Void;
    ensureImage(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: ImageAsset) => Void)): Void;
    ensureFont(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: FontAsset) => Void)): Void;
    ensureText(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: TextAsset) => Void)): Void;
    ensureSound(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: SoundAsset) => Void)): Void;
    ensureDatabase(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: DatabaseAsset) => Void)): Void;
    ensureShader(name: ceramic.Either<String, AssetId<String>>, options?: Dynamic?, done: ((arg1: ShaderAsset) => Void)): Void;
    texture(name: ceramic.Either<String, AssetId<String>>): Texture;
    font(name: ceramic.Either<String, AssetId<String>>): BitmapFont;
    sound(name: ceramic.Either<String, AssetId<String>>): Sound;
    text(name: ceramic.Either<String, AssetId<String>>): String;
    shader(name: ceramic.Either<String, AssetId<String>>): Shader;
    database(name: ceramic.Either<String, AssetId<String>>): Array<haxe.DynamicAccess<String>>;
    fragments(name: ceramic.Either<String, AssetId<String>>): haxe.DynamicAccess<TAnonymous>;
    iterator(): TAnonymous;
    /**
     * Set to `true` to enable hot reload.
     * Note: this won't do anything unless used in pair with `watchDirectory(path)`
     */
    hotReload: Bool;
    /**
     * Watch the given asset directory. Any change will fire `assetFilesChange` event.
     * If `hotReload` is set to `true` (its default), related assets will be hot reloaded
     * when their file changes on disk.
     * Behavior may differ depending on the platfom.
     * When using web target via electron, be sure to add `ceramic_use_electron` define.
     * @param path
     *     The assets path to watch. You could use `ceramic.macros.DefinesMacro.getDefine('assets_path')`
     *     to watch default asset path in project.
     * @param hotReload 
     *     `true` by default. Will enable hot reload of assets when related file changes on disk
     * @return WatchDirectory instance used internally
     */
    watchDirectory(path: String, hotReload?: Bool): WatchDirectory;
    unbindEvents(): Void;
}

enum AssetStatus {
    READY,
    NONE,
    LOADING,
    BROKEN
}

class AssetPathInfo {
    constructor(path: String);
    density: Float;
    extension: String;
    name: String;
    path: String;
    flags: Map<K, V>;
}

type AssetOptions = Dynamic;

class Asset extends Entity implements Observable {
    constructor(kind: String, name: String, options?: Dynamic?);
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Asset, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Asset, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Asset, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
    /**complete event*/
    onComplete(owner: Entity?, handleSuccess: ((success: Bool) => Void)): Void;
    /**complete event*/
    onceComplete(owner: Entity?, handleSuccess: ((success: Bool) => Void)): Void;
    /**complete event*/
    offComplete(handleSuccess?: ((success: Bool) => Void)?): Void;
    /**Does it listen to complete event*/
    listensComplete(): Bool;
    /** Asset kind */
    kind: String;
    /** Asset name */
    name: String;
    /** Asset path */
    path: String;
    /** Asset target density. Some assets depend on current screen density,
        like bitmap fonts, textures. Default is 1.0 */
    density: Float;
    /** Asset owner. The owner is a group of assets (Assets instance). When the owner gets
        destroyed, every asset it owns get destroyed as well. */
    owner: Assets;
    /** Optional runtime assets, used to compute path. */
    runtimeAssets: RuntimeAssets;
    /** Asset options. Depends on asset kind and even backend in some cases. */
    options: Dynamic;
    /** Sub assets-list. Defaults to null but some kind of assets (like bitmap fonts) instanciate it to load sub-assets it depends on. */
    assets: Assets;
    /** Manage asset retain count. Increase it by calling `retain()` and decrease it by calling `release()`.
        This can be used when mutliple objects are using the same assets
        without knowing in advance when they will be needed. */
    refCount: Int;
    status: AssetStatus;
    invalidateStatus(): Void;
    /**Event when status field changes.*/
    onStatusChange(owner: Entity?, handleCurrentPrevious: ((current: AssetStatus, previous: AssetStatus) => Void)): Void;
    /**Event when status field changes.*/
    onceStatusChange(owner: Entity?, handleCurrentPrevious: ((current: AssetStatus, previous: AssetStatus) => Void)): Void;
    /**Event when status field changes.*/
    offStatusChange(handleCurrentPrevious?: ((current: AssetStatus, previous: AssetStatus) => Void)?): Void;
    /**Event when status field changes.*/
    listensStatusChange(): Bool;
    load(): Void;
    destroy(): Void;
    computePath(extensions?: Array<String>?, dir?: Bool?, runtimeAssets?: RuntimeAssets?): Void;
    retain(): Void;
    release(): Void;
    unbindEvents(): Void;
}

class ArcadePhysics extends Entity {
    constructor();
}

/**
 * `App` class is the starting point of any ceramic app.
 */
class App extends Entity {
    constructor();
    /**
     * Shared `App` instance singleton.
     */
    static app: App;
    static init(): InitSettings;
    /**
     * @event ready
     * Ready event is triggered when the app is ready
     * and the game logic can be started.
     */
    onReady(owner: Entity?, handle: (() => Void)): Void;
    /**
     * @event ready
     * Ready event is triggered when the app is ready
     * and the game logic can be started.
     */
    onceReady(owner: Entity?, handle: (() => Void)): Void;
    /**
     * @event ready
     * Ready event is triggered when the app is ready
     * and the game logic can be started.
     */
    offReady(handle?: (() => Void)?): Void;
    /**
     * @event ready
     * Ready event is triggered when the app is ready
     * and the game logic can be started.
     */
    listensReady(): Bool;
    /**
     * @event update
     * Update event is triggered as many times as there are frames per seconds.
     * It is in sync with screen FPS but used for everything that needs
     * to get updated depending on time (ceramic.Timer relies on it).
     * Use this event to update your contents before they get drawn again.
     * @param delta The elapsed delta time since last frame
     */
    onUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event update
     * Update event is triggered as many times as there are frames per seconds.
     * It is in sync with screen FPS but used for everything that needs
     * to get updated depending on time (ceramic.Timer relies on it).
     * Use this event to update your contents before they get drawn again.
     * @param delta The elapsed delta time since last frame
     */
    onceUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event update
     * Update event is triggered as many times as there are frames per seconds.
     * It is in sync with screen FPS but used for everything that needs
     * to get updated depending on time (ceramic.Timer relies on it).
     * Use this event to update your contents before they get drawn again.
     * @param delta The elapsed delta time since last frame
     */
    offUpdate(handleDelta?: ((delta: Float) => Void)?): Void;
    /**
     * @event update
     * Update event is triggered as many times as there are frames per seconds.
     * It is in sync with screen FPS but used for everything that needs
     * to get updated depending on time (ceramic.Timer relies on it).
     * Use this event to update your contents before they get drawn again.
     * @param delta The elapsed delta time since last frame
     */
    listensUpdate(): Bool;
    /**
     * @event preUpdate
     * Pre-update event is triggered right before update event and
     * can be used when you want to run garantee your code
     * will be run before regular update event.
     * @param delta The elapsed delta time since last frame
     */
    onPreUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event preUpdate
     * Pre-update event is triggered right before update event and
     * can be used when you want to run garantee your code
     * will be run before regular update event.
     * @param delta The elapsed delta time since last frame
     */
    oncePreUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event preUpdate
     * Pre-update event is triggered right before update event and
     * can be used when you want to run garantee your code
     * will be run before regular update event.
     * @param delta The elapsed delta time since last frame
     */
    offPreUpdate(handleDelta?: ((delta: Float) => Void)?): Void;
    /**
     * @event preUpdate
     * Pre-update event is triggered right before update event and
     * can be used when you want to run garantee your code
     * will be run before regular update event.
     * @param delta The elapsed delta time since last frame
     */
    listensPreUpdate(): Bool;
    /**
     * @event postUpdate
     * Post-update event is triggered right after update event and
     * can be used when you want to run garantee your code
     * will be run after regular update event.
     * @param delta The elapsed delta time since last frame
     */
    onPostUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event postUpdate
     * Post-update event is triggered right after update event and
     * can be used when you want to run garantee your code
     * will be run after regular update event.
     * @param delta The elapsed delta time since last frame
     */
    oncePostUpdate(owner: Entity?, handleDelta: ((delta: Float) => Void)): Void;
    /**
     * @event postUpdate
     * Post-update event is triggered right after update event and
     * can be used when you want to run garantee your code
     * will be run after regular update event.
     * @param delta The elapsed delta time since last frame
     */
    offPostUpdate(handleDelta?: ((delta: Float) => Void)?): Void;
    /**
     * @event postUpdate
     * Post-update event is triggered right after update event and
     * can be used when you want to run garantee your code
     * will be run after regular update event.
     * @param delta The elapsed delta time since last frame
     */
    listensPostUpdate(): Bool;
    /**
     * @event keyDown
     * Triggered when a key from the keyboard is being pressed.
     * @param key The key being pressed
     */
    onKeyDown(owner: Entity?, handleKey: ((key: Key) => Void)): Void;
    /**
     * @event keyDown
     * Triggered when a key from the keyboard is being pressed.
     * @param key The key being pressed
     */
    onceKeyDown(owner: Entity?, handleKey: ((key: Key) => Void)): Void;
    /**
     * @event keyDown
     * Triggered when a key from the keyboard is being pressed.
     * @param key The key being pressed
     */
    offKeyDown(handleKey?: ((key: Key) => Void)?): Void;
    /**
     * @event keyDown
     * Triggered when a key from the keyboard is being pressed.
     * @param key The key being pressed
     */
    listensKeyDown(): Bool;
    /**
     * @event keyUp
     * Triggered when a key from the keyboard is being released.
     * @param key The key being released
     */
    onKeyUp(owner: Entity?, handleKey: ((key: Key) => Void)): Void;
    /**
     * @event keyUp
     * Triggered when a key from the keyboard is being released.
     * @param key The key being released
     */
    onceKeyUp(owner: Entity?, handleKey: ((key: Key) => Void)): Void;
    /**
     * @event keyUp
     * Triggered when a key from the keyboard is being released.
     * @param key The key being released
     */
    offKeyUp(handleKey?: ((key: Key) => Void)?): Void;
    /**
     * @event keyUp
     * Triggered when a key from the keyboard is being released.
     * @param key The key being released
     */
    listensKeyUp(): Bool;
    /**controllerAxis event*/
    onControllerAxis(owner: Entity?, handleControllerIdAxisIdValue: ((controllerId: Int, axisId: Int, value: Float) => Void)): Void;
    /**controllerAxis event*/
    onceControllerAxis(owner: Entity?, handleControllerIdAxisIdValue: ((controllerId: Int, axisId: Int, value: Float) => Void)): Void;
    /**controllerAxis event*/
    offControllerAxis(handleControllerIdAxisIdValue?: ((controllerId: Int, axisId: Int, value: Float) => Void)?): Void;
    /**Does it listen to controllerAxis event*/
    listensControllerAxis(): Bool;
    /**controllerDown event*/
    onControllerDown(owner: Entity?, handleControllerIdButtonId: ((controllerId: Int, buttonId: Int) => Void)): Void;
    /**controllerDown event*/
    onceControllerDown(owner: Entity?, handleControllerIdButtonId: ((controllerId: Int, buttonId: Int) => Void)): Void;
    /**controllerDown event*/
    offControllerDown(handleControllerIdButtonId?: ((controllerId: Int, buttonId: Int) => Void)?): Void;
    /**Does it listen to controllerDown event*/
    listensControllerDown(): Bool;
    /**controllerUp event*/
    onControllerUp(owner: Entity?, handleControllerIdButtonId: ((controllerId: Int, buttonId: Int) => Void)): Void;
    /**controllerUp event*/
    onceControllerUp(owner: Entity?, handleControllerIdButtonId: ((controllerId: Int, buttonId: Int) => Void)): Void;
    /**controllerUp event*/
    offControllerUp(handleControllerIdButtonId?: ((controllerId: Int, buttonId: Int) => Void)?): Void;
    /**Does it listen to controllerUp event*/
    listensControllerUp(): Bool;
    /**controllerEnable event*/
    onControllerEnable(owner: Entity?, handleControllerIdName: ((controllerId: Int, name: String) => Void)): Void;
    /**controllerEnable event*/
    onceControllerEnable(owner: Entity?, handleControllerIdName: ((controllerId: Int, name: String) => Void)): Void;
    /**controllerEnable event*/
    offControllerEnable(handleControllerIdName?: ((controllerId: Int, name: String) => Void)?): Void;
    /**Does it listen to controllerEnable event*/
    listensControllerEnable(): Bool;
    /**controllerDisable event*/
    onControllerDisable(owner: Entity?, handleControllerId: ((controllerId: Int) => Void)): Void;
    /**controllerDisable event*/
    onceControllerDisable(owner: Entity?, handleControllerId: ((controllerId: Int) => Void)): Void;
    /**controllerDisable event*/
    offControllerDisable(handleControllerId?: ((controllerId: Int) => Void)?): Void;
    /**Does it listen to controllerDisable event*/
    listensControllerDisable(): Bool;
    /** Assets events */
    onDefaultAssetsLoad(owner: Entity?, handleAssets: ((assets: Assets) => Void)): Void;
    /** Assets events */
    onceDefaultAssetsLoad(owner: Entity?, handleAssets: ((assets: Assets) => Void)): Void;
    /** Assets events */
    offDefaultAssetsLoad(handleAssets?: ((assets: Assets) => Void)?): Void;
    /** Assets events */
    listensDefaultAssetsLoad(): Bool;
    /** Fired when the app hits an critical (uncaught) error. Can be used to perform custom crash reporting.
        If this even is handled, app exit should be performed by the event handler. */
    onCriticalError(owner: Entity?, handleErrorStack: ((error: Dynamic, stack: Array<haxe.StackItem>) => Void)): Void;
    /** Fired when the app hits an critical (uncaught) error. Can be used to perform custom crash reporting.
        If this even is handled, app exit should be performed by the event handler. */
    onceCriticalError(owner: Entity?, handleErrorStack: ((error: Dynamic, stack: Array<haxe.StackItem>) => Void)): Void;
    /** Fired when the app hits an critical (uncaught) error. Can be used to perform custom crash reporting.
        If this even is handled, app exit should be performed by the event handler. */
    offCriticalError(handleErrorStack?: ((error: Dynamic, stack: Array<haxe.StackItem>) => Void)?): Void;
    /** Fired when the app hits an critical (uncaught) error. Can be used to perform custom crash reporting.
        If this even is handled, app exit should be performed by the event handler. */
    listensCriticalError(): Bool;
    /**beginEnterBackground event*/
    onBeginEnterBackground(owner: Entity?, handle: (() => Void)): Void;
    /**beginEnterBackground event*/
    onceBeginEnterBackground(owner: Entity?, handle: (() => Void)): Void;
    /**beginEnterBackground event*/
    offBeginEnterBackground(handle?: (() => Void)?): Void;
    /**Does it listen to beginEnterBackground event*/
    listensBeginEnterBackground(): Bool;
    /**finishEnterBackground event*/
    onFinishEnterBackground(owner: Entity?, handle: (() => Void)): Void;
    /**finishEnterBackground event*/
    onceFinishEnterBackground(owner: Entity?, handle: (() => Void)): Void;
    /**finishEnterBackground event*/
    offFinishEnterBackground(handle?: (() => Void)?): Void;
    /**Does it listen to finishEnterBackground event*/
    listensFinishEnterBackground(): Bool;
    /**beginEnterForeground event*/
    onBeginEnterForeground(owner: Entity?, handle: (() => Void)): Void;
    /**beginEnterForeground event*/
    onceBeginEnterForeground(owner: Entity?, handle: (() => Void)): Void;
    /**beginEnterForeground event*/
    offBeginEnterForeground(handle?: (() => Void)?): Void;
    /**Does it listen to beginEnterForeground event*/
    listensBeginEnterForeground(): Bool;
    /**finishEnterForeground event*/
    onFinishEnterForeground(owner: Entity?, handle: (() => Void)): Void;
    /**finishEnterForeground event*/
    onceFinishEnterForeground(owner: Entity?, handle: (() => Void)): Void;
    /**finishEnterForeground event*/
    offFinishEnterForeground(handle?: (() => Void)?): Void;
    /**Does it listen to finishEnterForeground event*/
    listensFinishEnterForeground(): Bool;
    /**beginSortVisuals event*/
    onBeginSortVisuals(owner: Entity?, handle: (() => Void)): Void;
    /**beginSortVisuals event*/
    onceBeginSortVisuals(owner: Entity?, handle: (() => Void)): Void;
    /**beginSortVisuals event*/
    offBeginSortVisuals(handle?: (() => Void)?): Void;
    /**Does it listen to beginSortVisuals event*/
    listensBeginSortVisuals(): Bool;
    /**finishSortVisuals event*/
    onFinishSortVisuals(owner: Entity?, handle: (() => Void)): Void;
    /**finishSortVisuals event*/
    onceFinishSortVisuals(owner: Entity?, handle: (() => Void)): Void;
    /**finishSortVisuals event*/
    offFinishSortVisuals(handle?: (() => Void)?): Void;
    /**Does it listen to finishSortVisuals event*/
    listensFinishSortVisuals(): Bool;
    /**beginDraw event*/
    onBeginDraw(owner: Entity?, handle: (() => Void)): Void;
    /**beginDraw event*/
    onceBeginDraw(owner: Entity?, handle: (() => Void)): Void;
    /**beginDraw event*/
    offBeginDraw(handle?: (() => Void)?): Void;
    /**Does it listen to beginDraw event*/
    listensBeginDraw(): Bool;
    /**finishDraw event*/
    onFinishDraw(owner: Entity?, handle: (() => Void)): Void;
    /**finishDraw event*/
    onceFinishDraw(owner: Entity?, handle: (() => Void)): Void;
    /**finishDraw event*/
    offFinishDraw(handle?: (() => Void)?): Void;
    /**Does it listen to finishDraw event*/
    listensFinishDraw(): Bool;
    /**lowMemory event*/
    onLowMemory(owner: Entity?, handle: (() => Void)): Void;
    /**lowMemory event*/
    onceLowMemory(owner: Entity?, handle: (() => Void)): Void;
    /**lowMemory event*/
    offLowMemory(handle?: (() => Void)?): Void;
    /**Does it listen to lowMemory event*/
    listensLowMemory(): Bool;
    /**terminate event*/
    onTerminate(owner: Entity?, handle: (() => Void)): Void;
    /**terminate event*/
    onceTerminate(owner: Entity?, handle: (() => Void)): Void;
    /**terminate event*/
    offTerminate(handle?: (() => Void)?): Void;
    /**Does it listen to terminate event*/
    listensTerminate(): Bool;
    /** Schedule immediate callback that is garanteed to be executed before the next time frame
        (before elements are drawn onto screen) */
    onceImmediate(handleImmediate: (() => Void)): Void;
    /** Schedule callback that is garanteed to be executed when no immediate callback are pending anymore.
        @param defer if `true` (default), will box this call into an immediate callback */
    oncePostFlushImmediate(handlePostFlushImmediate: (() => Void), defer?: Bool): Void;
    /** Execute and flush every awaiting immediate callback, including the ones that
        could have been added with `onceImmediate()` after executing the existing callbacks. */
    flushImmediate(): Bool;
    inUpdate: Bool;
    requestFullUpdateAndDrawInFrame(): Void;
    /** Computed fps of the app. Read only.
        Value is automatically computed from last second of frame updates. */
    computedFps: Int;
    /** Current frame delta time */
    delta: Float;
    /** Backend instance */
    backend: backend.Backend;
    /** Screen instance */
    screen: Screen;
    /** Audio instance */
    audio: Audio;
    /** App settings */
    settings: Settings;
    /** Logger. Used by log.info() shortcut */
    logger: Logger;
    /** Visuals (ordered) */
    visuals: Array<Visual>;
    /** Render Textures */
    renderTextures: Array<RenderTexture>;
    /** App level assets. Used to load default bitmap font */
    assets: Assets;
    /** App level collections */
    collections: Collections;
    /** Default textured shader */
    defaultTexturedShader: Shader;
    /** Default white texture */
    defaultWhiteTexture: Texture;
    /** Default font */
    defaultFont: BitmapFont;
    /** Project directory. May be null depending on the platform. */
    projectDir: String;
    /** App level persistent data */
    persistent: PersistentData;
    /** Text input manager */
    textInput: TextInput;
    converters: Map<K, V>;
    componentInitializers: Map<K, V>;
    isKeyPressed(key: Key): Bool;
    isKeyJustPressed(key: Key): Bool;
    unbindEvents(): Void;
    /**App info extracted from `ceramic.yml`*/
    info: TAnonymous;
}

/**
	This class provides advanced methods on Strings. It is ideally used with
	`using StringTools` and then acts as an [extension](https://haxe.org/manual/lf-static-extension.html)
	to the `String` class.

	If the first argument to any of the methods is null, the result is
	unspecified.
*/
class StringTools {
    /**
		Escapes HTML special characters of the string `s`.

		The following replacements are made:

		- `&` becomes `&amp`;
		- `<` becomes `&lt`;
		- `>` becomes `&gt`;

		If `quotes` is true, the following characters are also replaced:

		- `"` becomes `&quot`;
		- `'` becomes `&#039`;
	*/
    static htmlEscape(s: String, quotes?: Bool?): String;
    /**
		Tells if the string `s` starts with the string `start`.

		If `start` is `null`, the result is unspecified.

		If `start` is the empty String `""`, the result is true.
	*/
    static startsWith(s: String, start: String): Bool;
    /**
		Tells if the string `s` ends with the string `end`.

		If `end` is `null`, the result is unspecified.

		If `end` is the empty String `""`, the result is true.
	*/
    static endsWith(s: String, end: String): Bool;
    /**
		Tells if the character in the string `s` at position `pos` is a space.

		A character is considered to be a space character if its character code
		is 9,10,11,12,13 or 32.

		If `s` is the empty String `""`, or if pos is not a valid position within
		`s`, the result is false.
	*/
    static isSpace(s: String, pos: Int): Bool;
    /**
		Removes leading space characters of `s`.

		This function internally calls `isSpace()` to decide which characters to
		remove.

		If `s` is the empty String `""` or consists only of space characters, the
		result is the empty String `""`.
	*/
    static ltrim(s: String): String;
    /**
		Removes trailing space characters of `s`.

		This function internally calls `isSpace()` to decide which characters to
		remove.

		If `s` is the empty String `""` or consists only of space characters, the
		result is the empty String `""`.
	*/
    static rtrim(s: String): String;
    /**
		Removes leading and trailing space characters of `s`.

		This is a convenience function for `ltrim(rtrim(s))`.
	*/
    static trim(s: String): String;
    /**
		Appends `c` to `s` until `s.length` is at least `l`.

		If `c` is the empty String `""` or if `l` does not exceed `s.length`,
		`s` is returned unchanged.

		If `c.length` is 1, the resulting String length is exactly `l`.

		Otherwise the length may exceed `l`.

		If `c` is null, the result is unspecified.
	*/
    static rpad(s: String, c: String, l: Int): String;
    /**
		Replace all occurrences of the String `sub` in the String `s` by the
		String `by`.

		If `sub` is the empty String `""`, `by` is inserted after each character
		of `s` except the last one. If `by` is also the empty String `""`, `s`
		remains unchanged.

		If `sub` or `by` are null, the result is unspecified.
	*/
    static replace(s: String, sub: String, by: String): String;
    /**
		Encodes `n` into a hexadecimal representation.

		If `digits` is specified, the resulting String is padded with "0" until
		its `length` equals `digits`.
	*/
    static hex(n: Int, digits?: Int?): String;
}

/**
	The Std class provides standard methods for manipulating basic types.
*/
class Std {
    /**
		Converts any value to a String.

		If `s` is of `String`, `Int`, `Float` or `Bool`, its value is returned.

		If `s` is an instance of a class and that class or one of its parent classes has
		a `toString` method, that method is called. If no such method is present, the result
		is unspecified.

		If `s` is an enum constructor without argument, the constructor's name is returned. If
		arguments exists, the constructor's name followed by the String representations of
		the arguments is returned.

		If `s` is a structure, the field names along with their values are returned. The field order
		and the operator separating field names and values are unspecified.

		If s is null, "null" is returned.
	*/
    static string(s: Dynamic): String;
    /**
		Converts a `String` to an `Int`.

		Leading whitespaces are ignored.

		If `x` starts with 0x or 0X, hexadecimal notation is recognized where the following digits may
		contain 0-9 and A-F.

		Otherwise `x` is read as decimal number with 0-9 being allowed characters. `x` may also start with
		a - to denote a negative value.

		In decimal mode, parsing continues until an invalid character is detected, in which case the
		result up to that point is returned. For hexadecimal notation, the effect of invalid characters
		is unspecified.

		Leading 0s that are not part of the 0x/0X hexadecimal notation are ignored, which means octal
		notation is not supported.

		If `x` is null, the result is unspecified.
		If `x` cannot be parsed as integer, the result is `null`.
	*/
    static parseInt(x: String): Int?;
    /**
		Return a random integer between 0 included and `x` excluded.

		If `x <= 1`, the result is always 0.
	*/
    static random(x: Int): Int;
}

class Math {
    static PI: Float;
    static abs(v: Float): Float;
    static acos(v: Float): Float;
    static asin(v: Float): Float;
    static atan(v: Float): Float;
    static atan2(y: Float, x: Float): Float;
    static ceil(v: Float): Int;
    static cos(v: Float): Float;
    static exp(v: Float): Float;
    static floor(v: Float): Int;
    static log(v: Float): Float;
    static max(a: Float, b: Float): Float;
    static min(a: Float, b: Float): Float;
    static pow(v: Float, exp: Float): Float;
    static random(): Float;
    static round(v: Float): Int;
    static sin(v: Float): Float;
    static sqrt(v: Float): Float;
    static tan(v: Float): Float;
}

/**
	An Array is a storage for values. You can access it using indexes or
	with its API.

	@see https://haxe.org/manual/std-Array.html
	@see https://haxe.org/manual/lf-array-comprehension.html
*/
interface Array<T> {
    /**
		Creates a new Array.
	*/
    constructor();
    /**
		The length of `this` Array.
	*/
    length: Int;
    /**
		Returns a new Array by appending the elements of `a` to the elements of
		`this` Array.

		This operation does not modify `this` Array.

		If `a` is the empty Array `[]`, a copy of `this` Array is returned.

		The length of the returned Array is equal to the sum of `this.length`
		and `a.length`.

		If `a` is `null`, the result is unspecified.
	*/
    concat(a: Array<T>): Array<T>;
    /**
		Returns a string representation of `this` Array, with `sep` separating
		each element.

		The result of this operation is equal to `Std.string(this[0]) + sep +
		Std.string(this[1]) + sep + ... + sep + Std.string(this[this.length-1])`

		If `this` is the empty Array `[]`, the result is the empty String `""`.
		If `this` has exactly one element, the result is equal to a call to
		`Std.string(this[0])`.

		If `sep` is null, the result is unspecified.
	*/
    join(sep: String): String;
    /**
		Removes the last element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this.length` will decrease by 1.

		If `this` is the empty Array `[]`, null is returned and the length
		remains 0.
	*/
    pop(): T?;
    /**
		Adds the element `x` at the end of `this` Array and returns the new
		length of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` increases by 1.
	*/
    push(x: T): Int;
    /**
		Reverse the order of elements of `this` Array.

		This operation modifies `this` Array in place.

		If `this.length < 2`, `this` remains unchanged.
	*/
    reverse(): Void;
    /**
		Removes the first element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this`.length and the index of each
		remaining element is decreased by 1.

		If `this` is the empty Array `[]`, `null` is returned and the length
		remains 0.
	*/
    shift(): T?;
    /**
		Creates a shallow copy of the range of `this` Array, starting at and
		including `pos`, up to but not including `end`.

		This operation does not modify `this` Array.

		The elements are not copied and retain their identity.

		If `end` is omitted or exceeds `this.length`, it defaults to the end of
		`this` Array.

		If `pos` or `end` are negative, their offsets are calculated from the
		end of `this` Array by `this.length + pos` and `this.length + end`
		respectively. If this yields a negative value, 0 is used instead.

		If `pos` exceeds `this.length` or if `end` is less than or equals
		`pos`, the result is `[]`.
	*/
    slice(pos: Int, end?: Int?): Array<T>;
    /**
		Sorts `this` Array according to the comparison function `f`, where
		`f(x,y)` returns 0 if x == y, a positive Int if x > y and a
		negative Int if x < y.

		This operation modifies `this` Array in place.

		The sort operation is not guaranteed to be stable, which means that the
		order of equal elements may not be retained. For a stable Array sorting
		algorithm, `haxe.ds.ArraySort.sort()` can be used instead.

		If `f` is null, the result is unspecified.
	*/
    sort(f: ((arg1: T, arg2: T) => Int)): Void;
    /**
		Removes `len` elements from `this` Array, starting at and including
		`pos`, an returns them.

		This operation modifies `this` Array in place.

		If `len` is < 0 or `pos` exceeds `this`.length, an empty Array [] is
		returned and `this` Array is unchanged.

		If `pos` is negative, its value is calculated from the end	of `this`
		Array by `this.length + pos`. If this yields a negative value, 0 is
		used instead.

		If the sum of the resulting values for `len` and `pos` exceed
		`this.length`, this operation will affect the elements from `pos` to the
		end of `this` Array.

		The length of the returned Array is equal to the new length of `this`
		Array subtracted from the original length of `this` Array. In other
		words, each element of the original `this` Array either remains in
		`this` Array or becomes an element of the returned Array.
	*/
    splice(pos: Int, len: Int): Array<T>;
    /**
		Returns a string representation of `this` Array.

		The result will include the individual elements' String representations
		separated by comma. The enclosing [ ] may be missing on some platforms,
		use `Std.string()` to get a String representation that is consistent
		across platforms.
	*/
    toString(): String;
    /**
		Adds the element `x` at the start of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` and the index of each Array element increases by 1.
	*/
    unshift(x: T): Void;
    /**
		Returns position of the first occurrence of `x` in `this` Array, searching front to back.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with zero index. If it is negative, it will be taken as the
		offset from the end of `this` Array to compute the starting index. If given or computed
		starting index is less than 0, the whole array will be searched, if it is greater than
		or equal to the length of `this` Array, the function returns -1.
	*/
    indexOf(x: T, fromIndex?: Int?): Int;
    /**
		Returns an iterator of the Array values.
	*/
    iterator(): TAnonymous;
}

