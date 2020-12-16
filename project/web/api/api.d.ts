
type Int = number;
type Float = number;
type Bool = boolean;
type String = string;
type Dynamic = any;
type Void = void;
type ReadOnlyArray = ReadonlyArray;

function trace(msg: any): Void;

function get(id: String): Entity;
function module(id: String): ScriptModule;

type AnyVisual = Visual & Text & Mesh & Quad;

const self: Entity;
const entity: Entity;
const visual: AnyVisual;
const fragment: Fragment;

const app: App;
const screen: Screen;
const audio: Audio;
const settings: Settings;
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
    serializedMap: haxe.ds.Map<K, V>;
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
    static isBusyKey(key: String): Bool;
    /** Load data from the given key. */
    static loadFromKey(model: Model, key: String): Bool;
    static autoSaveAsKey(model: Model, key: String, appendInterval?: Float, compactInterval?: Float): Void;
    /** Encode the given string `str` and return the result. */
    static encodeHashedString(str: String): String;
    /** Decode the given `encoded` string and return the result or null if it failed. */
    static decodeHashedString(encoded: String): String;
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
    /**undo event*/
    onUndo(owner: Entity?, handle: (() => Void)): Void;
    /**undo event*/
    onceUndo(owner: Entity?, handle: (() => Void)): Void;
    /**undo event*/
    offUndo(handle?: (() => Void)?): Void;
    /**Does it listen to undo event*/
    listensUndo(): Bool;
    /**redo event*/
    onRedo(owner: Entity?, handle: (() => Void)): Void;
    /**redo event*/
    onceRedo(owner: Entity?, handle: (() => Void)): Void;
    /**redo event*/
    offRedo(handle?: (() => Void)?): Void;
    /**Does it listen to redo event*/
    listensRedo(): Bool;
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
    disable(): Void;
    enable(): Void;
    /**
     * Undo last step, if any
     */
    undo(): Void;
    /**
     * Redo last undone step, if any
     */
    redo(): Void;
    initializerName: String;
    unbindEvents(): Void;
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
class DynamicEvents<T> extends Entity implements Component {
    constructor();
    emit(event: T, args?: Array<Dynamic>?): Void;
    on(event: T, owner: Entity?, cb: Dynamic): Void;
    once(event: T, owner: Entity?, cb: Dynamic): Void;
    off(event: T, cb?: Dynamic?): Void;
    listens(event: T): Bool;
    entity: Entity;
    initializerName: String;
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

class Bytes {
    constructor(data: ArrayBuffer);
    /**
		Returns the `Bytes` representation of the given `String`, using the
		specified encoding (UTF-8 by default).
	*/
    static ofString(s: String, encoding?: haxe.io.Encoding?): Bytes;
    /**
		Converts the given hexadecimal `String` to `Bytes`. `s` must be a string of
		even length consisting only of hexadecimal digits. For example:
		`"0FDA14058916052309"`.
	*/
    static ofHex(s: String): Bytes;
    length: Int;
    /**
		Returns the `len`-bytes long string stored at the given position `pos`,
		interpreted with the given `encoding` (UTF-8 by default).
	*/
    getString(pos: Int, len: Int, encoding?: haxe.io.Encoding?): String;
    /**
		Returns a `String` representation of the bytes interpreted as UTF-8.
	*/
    toString(): String;
}

/**
	StringMap allows mapping of String keys to arbitrary values.

	See `Map` for documentation details.

	@see https://haxe.org/manual/std-Map.html
*/
class StringMap<T> implements haxe.IMap {
    /**
		Creates a new StringMap.
	*/
    constructor();
    /**
		See `Map.exists`
	*/
    exists(key: String): Bool;
    /**
		See `Map.get`
	*/
    get(key: String): T?;
    /**
		See `Map.set`
	*/
    set(key: String, value: T): Void;
    /**
		See `Map.remove`
	*/
    remove(key: String): Bool;
    /**
		See `Map.keys`

		(cs, java) Implementation detail: Do not `set()` any new value while
		iterating, as it may cause a resize, which will break iteration.
	*/
    keys(): TAnonymous;
    /**
		See `Map.iterator`

		(cs, java) Implementation detail: Do not `set()` any new value while
		iterating, as it may cause a resize, which will break iteration.
	*/
    iterator(): TAnonymous;
    /**
		See `Map.keyValueIterator`
	*/
    keyValueIterator(): TAnonymous;
}

class RotateFrame {
    static NONE: Int;
    static ROTATE_90: Int;
}

/** A typed (mouse) button id */
class MouseButton {
    /** No mouse buttons */
    static NONE: Int;
    /** Left mouse button */
    static LEFT: Int;
    /** Middle mouse button */
    static MIDDLE: Int;
    /** Right mouse button */
    static RIGHT: Int;
    /** Extra button pressed (4) */
    static EXTRA1: Int;
    /** Extra button pressed (5) */
    static EXTRA2: Int;
}

class MeshColorMapping {
    /** Map a single color to the whole mesh. */
    static MESH: Int;
    /** Map a color to each indice. */
    static INDICES: Int;
    /** Map a color to each vertex. */
    static VERTICES: Int;
}

interface Map<K, V> {
    /**
		Maps `key` to `value`.

		If `key` already has a mapping, the previous value disappears.

		If `key` is `null`, the result is unspecified.
	*/
    set(key: K, value: V): Void;
    /**
		Returns the current mapping of `key`.

		If no such mapping exists, `null` is returned.

		Note that a check like `map.get(key) == null` can hold for two reasons:

		1. the map has no mapping for `key`
		2. the map has a mapping with a value of `null`

		If it is important to distinguish these cases, `exists()` should be
		used.

		If `key` is `null`, the result is unspecified.
	*/
    get(key: K): V;
    /**
		Returns true if `key` has a mapping, false otherwise.

		If `key` is `null`, the result is unspecified.
	*/
    exists(key: K): Bool;
    /**
		Removes the mapping of `key` and returns true if such a mapping existed,
		false otherwise.

		If `key` is `null`, the result is unspecified.
	*/
    remove(key: K): Bool;
    /**
		Returns an Iterator over the keys of `this` Map.

		The order of keys is undefined.
	*/
    keys(): TAnonymous;
    /**
		Returns an Iterator over the values of `this` Map.

		The order of values is undefined.
	*/
    iterator(): TAnonymous;
    /**
		Returns an Iterator over the keys and values of `this` Map.

		The order of values is undefined.
	*/
    keyValueIterator(): TAnonymous;
    /**
		Removes all keys from `this` Map.
	*/
    clear(): Void;
}

class Flags {
    static getBool(flags: Int, bit: Int): Bool;
    static setBoolAndGetFlags(flags: Int, bit: Int, bool: Bool): Int;
}

class DebugRendering {
    static DEFAULT: Int;
    static WIREFRAME: Int;
}

/**
 * Class representing a color, based on Int. Provides a variety of methods for creating and converting colors.
 *
 * Colors can be written as Ints. This means you can pass a hex value such as
 * 0x123456 to a function expecting a Color, and it will automatically become a Color "object".
 * Similarly, Colors may be treated as Ints.
 *
 * Note that when using properties of a Color other than RGB, the values are ultimately stored as
 * RGB values, so repeatedly manipulating HSB/HSL/CMYK values may result in a gradual loss of precision.
 */
class Color {
    static NONE: Color;
    static WHITE: Color;
    static GRAY: Color;
    static BLACK: Color;
    static GREEN: Color;
    static LIME: Color;
    static YELLOW: Color;
    static ORANGE: Color;
    static RED: Color;
    static PURPLE: Color;
    static BLUE: Color;
    static BROWN: Color;
    static PINK: Color;
    static MAGENTA: Color;
    static CYAN: Color;
    /**
     * Generate a random color (away from white or black)
     * @return The color as a Color
     */
    static random(minSatutation?: Float, minBrightness?: Float): Color;
    /**
     * Create a color from the least significant four bytes of an Int
     *
     * @param    value And Int with bytes in the format 0xRRGGBB
     * @return    The color as a Color
     */
    static fromInt(value: Int): Color;
    /**
     * Generate a color from integer RGB values (0 to 255)
     *
     * @param red    The red value of the color from 0 to 255
     * @param green    The green value of the color from 0 to 255
     * @param blue    The green value of the color from 0 to 255
     * @return The color as a Color
     */
    static fromRGB(red: Int, green: Int, blue: Int): Color;
    /**
     * Generate a color from float RGB values (0 to 1)
     *
     * @param red    The red value of the color from 0 to 1
     * @param green    The green value of the color from 0 to 1
     * @param blue    The green value of the color from 0 to 1
     * @return The color as a Color
     */
    static fromRGBFloat(red: Float, green: Float, blue: Float): Color;
    /**
     * Generate a color from CMYK values (0 to 1)
     *
     * @param cyan        The cyan value of the color from 0 to 1
     * @param magenta    The magenta value of the color from 0 to 1
     * @param yellow    The yellow value of the color from 0 to 1
     * @param black        The black value of the color from 0 to 1
     * @return The color as a Color
     */
    static fromCMYK(cyan: Float, magenta: Float, yellow: Float, black: Float): Color;
    /**
     * Generate a color from HSB (aka HSV) components.
     *
     * @param    hue            A number between 0 and 360, indicating position on a color strip or wheel.
     * @param    saturation    A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
     * @param    brightness    (aka value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
     * @return    The color as a Color
     */
    static fromHSB(hue: Float, saturation: Float, brightness: Float): Color;
    /**
     * Generate a color from HSL components.
     *
     * @param    hue            A number between 0 and 360, indicating position on a color strip or wheel.
     * @param    saturation    A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
     * @param    lightness    A number between 0 and 1, indicating the lightness of the color
     * @return    The color as a Color
     */
    static fromHSL(hue: Float, saturation: Float, lightness: Float): Color;
    /**
     * Parses a `String` and returns a `Color` or `null` if the `String` couldn't be parsed.
     *
     * Examples (input -> output in hex):
     *
     * - `0x00FF00`    -> `0x00FF00`
     * - `#0000FF`     -> `0x0000FF`
     * - `GRAY`        -> `0x808080`
     * - `blue`        -> `0x0000FF`
     *
     * @param    str     The string to be parsed
     * @return    A `Color` or `null` if the `String` couldn't be parsed
     */
    static fromString(str: String): Color?;
    /**
     * Get HSB color wheel values in an array which will be 360 elements in size
     *
     * @return    HSB color wheel as Array of Colors
     */
    static getHSBColorWheel(): Array<Color>;
    /**
     * Get an interpolated color based on two different colors.
     *
     * @param     color1 The first color
     * @param     color2 The second color
     * @param     factor value from 0 to 1 representing how much to shift color1 toward color2
     * @return    The interpolated color
     */
    static interpolate(color1: Color, color2: Color, factor?: Float): Color;
    /**
     * Create a gradient from one color to another
     *
     * @param color1 The color to shift from
     * @param color2 The color to shift to
     * @param steps How many colors the gradient should have
     * @param ease An optional easing function, such as those provided in FlxEase
     * @return An array of colors of length steps, shifting from color1 to color2
     */
    static gradient(color1: Color, color2: Color, steps: Int, ease?: ((arg1: Float) => Float)?): Array<Color>;
    /**
     * Multiply the RGB channels of two Colors
     */
    static multiply(lhs: Color, rhs: Color): Color;
    /**
     * Add the RGB channels of two Colors
     */
    static add(lhs: Color, rhs: Color): Color;
    /**
     * Subtract the RGB channels of one Color from another
     */
    static subtract(lhs: Color, rhs: Color): Color;
    /**
     * Return a String representation of the color in the format
     *
     * @param prefix Whether to include "0x" prefix at start of string
     * @return    A string of length 10 in the format 0xAARRGGBB
     */
    static toHexString(color: Color, prefix?: Bool): String;
    /**
     * Return a String representation of the color in the format #RRGGBB
     *
     * @return    A string of length 7 in the format #RRGGBB
     */
    static toWebString(color: Color): String;
    /**
     * Get a string of color information about this color
     *
     * @return A string containing information about this color
     */
    static getColorInfo(color: Color): String;
    /**
     * Get a darkened version of this color
     *
     * @param    factor value from 0 to 1 of how much to progress toward black.
     * @return     A darkened version of this color
     */
    static getDarkened(color: Color, factor?: Float): Color;
    /**
     * Get a lightened version of this color
     *
     * @param    factor value from 0 to 1 of how much to progress toward white.
     * @return     A lightened version of this color
     */
    static getLightened(color: Color, factor?: Float): Color;
    /**
     * Get the inversion of this color
     *
     * @return The inversion of this color
     */
    static getInverted(color: Color): Color;
    /**
     * Get the hue of the color in degrees (from 0 to 359)
     */
    static hue(color: Color): Float;
    /**
     * Get the saturation of the color (from 0 to 1)
     */
    static saturation(color: Color): Float;
    /**
     * Get the brightness (aka value) of the color (from 0 to 1)
     */
    static brightness(color: Color): Float;
    /**
     * Get the lightness of the color (from 0 to 1)
     */
    static lightness(color: Color): Float;
    static red(color: Color): Int;
    static green(color: Color): Int;
    static blue(color: Color): Int;
    static redFloat(color: Color): Float;
    static greenFloat(color: Color): Float;
    static blueFloat(color: Color): Float;
    /**
     * Generate a color from HSLuv components.
     *
     * @param    hue            A number between 0 and 360, indicating position on a color strip or wheel.
     * @param    saturation    A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
     * @param    lightness    A number between 0 and 1, indicating the lightness of the color
     * @return    The color as a Color
     */
    static fromHSLuv(hue: Float, saturation: Float, lightness: Float): Color;
    /**
     * Get HSLuv components from the color instance.
     *
     * @param result A pre-allocated array to store the result into.
     * @return    The HSLuv components as a float array
     */
    static getHSLuv(color: Color, result?: Array<Float>?): Array<Float>;
}

class Blending {
    /** Automatic/default blending in ceramic. Internally, this translates to premultiplied alpha blending as textures
        are already transformed for this blending at asset copy phase, except in some situations (render to texture) where
        ceramic may use some more specific blendings as needed. */
    static AUTO: Int;
    /** Explicit premultiplied alpha blending */
    static PREMULTIPLIED_ALPHA: Int;
    /** Additive blending */
    static ADD: Int;
    /** Set blending */
    static SET: Int;
    /** Blending used by ceramic when rendering to texture. */
    static RENDER_TO_TEXTURE: Int;
    /** Traditional alpha blending. This should only be used on very specific cases. Used instead of `NORMAL` blending
        when the visual is drawing a RenderTexture. */
    static ALPHA: Int;
}

/** RGBA Color stored as integer.
    Can be decomposed to Color/Int (RGB) + Float (A) and
    constructed from Color/Int (RGB) + Float (A). */
class AlphaColor {
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
    constructor(x: Float, y: Float, width: Float, height: Float, rotation: Float);
    static fromBody(body: Body): VisualArcadePhysics;
    /** Dispatched when this visual body collides with another body. */
    onCollideBody(owner: Entity?, handleVisualBody: ((visual: Visual, body: Body) => Void)): Void;
    /** Dispatched when this visual body collides with another body. */
    onceCollideBody(owner: Entity?, handleVisualBody: ((visual: Visual, body: Body) => Void)): Void;
    /** Dispatched when this visual body collides with another body. */
    offCollideBody(handleVisualBody?: ((visual: Visual, body: Body) => Void)?): Void;
    /** Dispatched when this visual body collides with another body. */
    listensCollideBody(): Bool;
    /** Dispatched when this visual body overlaps with another body. */
    onOverlapBody(owner: Entity?, handleVisualBody: ((visual: Visual, body: Body) => Void)): Void;
    /** Dispatched when this visual body overlaps with another body. */
    onceOverlapBody(owner: Entity?, handleVisualBody: ((visual: Visual, body: Body) => Void)): Void;
    /** Dispatched when this visual body overlaps with another body. */
    offOverlapBody(handleVisualBody?: ((visual: Visual, body: Body) => Void)?): Void;
    /** Dispatched when this visual body overlaps with another body. */
    listensOverlapBody(): Bool;
    /** Dispatched when this visual body collides with another visual's body. */
    onCollide(owner: Entity?, handleVisual1Visual2: ((visual1: Visual, visual2: Visual) => Void)): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    onceCollide(owner: Entity?, handleVisual1Visual2: ((visual1: Visual, visual2: Visual) => Void)): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    offCollide(handleVisual1Visual2?: ((visual1: Visual, visual2: Visual) => Void)?): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    listensCollide(): Bool;
    /** Dispatched when this visual body overlaps with another visual's body. */
    onOverlap(owner: Entity?, handleVisual1Visual2: ((visual1: Visual, visual2: Visual) => Void)): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    onceOverlap(owner: Entity?, handleVisual1Visual2: ((visual1: Visual, visual2: Visual) => Void)): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    offOverlap(handleVisual1Visual2?: ((visual1: Visual, visual2: Visual) => Void)?): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    listensOverlap(): Bool;
    /** Dispatched when this visual body collides with the world bounds. */
    onWorldBounds(owner: Entity?, handleVisualUpDownLeftRight: ((visual: Visual, up: Bool, down: Bool, left: Bool, right: Bool) => Void)): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    onceWorldBounds(owner: Entity?, handleVisualUpDownLeftRight: ((visual: Visual, up: Bool, down: Bool, left: Bool, right: Bool) => Void)): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    offWorldBounds(handleVisualUpDownLeftRight?: ((visual: Visual, up: Bool, down: Bool, left: Bool, right: Bool) => Void)?): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    listensWorldBounds(): Bool;
    visual: Visual;
    body: Body;
    world: ArcadeWorld;
    destroy(): Void;
    unbindEvents(): Void;
}

class Visual extends Entity implements Collidable {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
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
    /** The arcade physics body bound to this visual. */
    arcade: VisualArcadePhysics;
    /** Init arcade physics (body) bound to this visual. */
    initArcadePhysics(world?: ArcadeWorld?): VisualArcadePhysics;
    /** The arcade physics body linked to this visual */
    body: Body;
    /** Allow this visual to be rotated by arcade physics, via `angularVelocity`, etc... */
    allowRotation: Bool;
    /** An immovable visual will not receive any impacts from other visual bodies. **Two** immovable visuas can't separate or exchange momentum and will pass through each other. */
    immovable: Bool;
    /** The x velocity, or rate of change the visual position. Measured in points per second. */
    velocityX: Float;
    /** The y velocity, or rate of change the visual position. Measured in points per second. */
    velocityY: Float;
    /** The velocity, or rate of change the visual position. Measured in points per second. */
    velocity(velocityX: Float, velocityY: Float): Void;
    /** The maximum x velocity that the visual can reach. */
    maxVelocityX: Float;
    /** The maximum y velocity that the visual can reach. */
    maxVelocityY: Float;
    /** The maximum velocity that the visual can reach. */
    maxVelocity(maxVelocityX: Float, maxVelocityY: Float): Void;
    /** The x acceleration is the rate of change of the x velocity. Measured in points per second squared. */
    accelerationX: Float;
    /** The y acceleration is the rate of change of the y velocity. Measured in points per second squared. */
    accelerationY: Float;
    /** The acceleration is the rate of change of the y velocity. Measured in points per second squared. */
    acceleration(accelerationX: Float, accelerationY: Float): Void;
    /** Allow this visual to be influenced by drag */
    allowDrag: Bool;
    /** The x drag is the rate of reduction of the x velocity, kind of deceleration. Measured in points per second squared. */
    dragX: Float;
    /** The y drag is the rate of reduction of the y velocity, kind of deceleration. Measured in points per second squared. */
    dragY: Float;
    /** The drag is the rate of reduction of the velocity, kind of deceleration. Measured in points per second squared. */
    drag(dragX: Float, dragY: Float): Void;
    /** The x elasticity of the visual when colliding. `bounceX = 1` means full rebound, `bounceX = 0.5` means 50% rebound velocity. */
    bounceX: Float;
    /** The y elasticity of the visual when colliding. `bounceY = 1` means full rebound, `bounceY = 0.5` means 50% rebound velocity. */
    bounceY: Float;
    /** The elasticity of the visual when colliding. `1` means full rebound, `0.5` means 50% rebound velocity. */
    bounce(bounceX: Float, bounceY: Float): Void;
    /** Enable or disable world bounds specific bounce value with `worldBounceX` and `worldBounceY`.
        Disabled by default, meaning `bounceX` and `bounceY` are used by default. */
    useWorldBounce: Bool;
    /** The x elasticity of the visual when colliding with world bounds. Ignored if `useWorldBounce` is `false` (`bounceX` used instead). */
    worldBounceX: Float;
    /** The y elasticity of the visual when colliding with world bounds. Ignored if `useWorldBounce` is `false` (`bounceY` used instead). */
    worldBounceY: Float;
    /** The elasticity of the visual when colliding with world bounds. Ignored if `useWorldBounce` is `false` (`bounceY` used instead). */
    worldBounce(worldBounceX: Float, worldBounceY: Float): Void;
    /** The maximum x delta per frame. `0` (default) means no maximum delta. */
    maxDeltaX: Float;
    /** The maximum y delta per frame. `0` (default) means no maximum delta. */
    maxDeltaY: Float;
    /** The maxDelta, or rate of change the visual position. Measured in points per second. */
    maxDelta(maxDeltaX: Float, maxDeltaY: Float): Void;
    /** Allow this visual to be influenced by gravity, either world or local. */
    allowGravity: Bool;
    /** This visual's local y gravity, **added** to any world gravity, unless `allowGravity` is set to false. */
    gravityX: Float;
    /** This visual's local x gravity, **added** to any world gravity, unless `allowGravity` is set to false. */
    gravityY: Float;
    /** This visual's local gravity, **added** to any world gravity, unless `allowGravity` is set to false. */
    gravity(gravityX: Float, gravityY: Float): Void;
    /** If this visual is `immovable` and moving, and another visual body is 'riding' this one, this is the amount of motion the riding body receives on x axis. */
    frictionX: Float;
    /** If this visual is `immovable` and moving, and another visual body is 'riding' this one, this is the amount of motion the riding body receives on y axis. */
    frictionY: Float;
    /** If this visual is `immovable` and moving, and another visual body is 'riding' this one, this is the amount of motion the riding body receives on x & y axis. */
    friction(frictionX: Float, frictionY: Float): Void;
    /** The angular velocity is the rate of change of the visual's rotation. It is measured in degrees per second. */
    angularVelocity: Float;
    /** The maximum angular velocity in degrees per second that the visual can reach. */
    maxAngularVelocity: Float;
    /** The angular acceleration is the rate of change of the angular velocity. Measured in degrees per second squared. */
    angularAcceleration: Float;
    /** The angular drag is the rate of reduction of the angular velocity. Measured in degrees per second squared. */
    angularDrag: Float;
    /** The mass of the visual's body. When two bodies collide their mass is used in the calculation to determine the exchange of velocity. */
    mass: Float;
    /** The speed of the visual's body (read only). Equal to the magnitude of the velocity. */
    speed: Float;
    /** Whether the physics system should update the visual's position and rotation based on its velocity, acceleration, drag, and gravity. */
    moves: Bool;
    /** When this visual's body collides with another, the amount of overlap (x axis) is stored here. */
    overlapX: Float;
    /** When this visual's body collides with another, the amount of overlap (y axis) is stored here. */
    overlapY: Float;
    /** If a visual's body is overlapping with another body, but neither of them are moving (maybe they spawned on-top of each other?) this is set to `true`. */
    embedded: Bool;
    /** A visual body can be set to collide against the world bounds automatically and rebound back into the world if this is set to true. Otherwise it will leave the world. */
    collideWorldBounds: Bool;
    /** Dispatched when this visual body collides with another visual's body. */
    onCollide(owner: Entity, handleVisual1Visual2: ((arg1: Visual, arg2: Visual) => Void)): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    onceCollide(owner: Entity, handleVisual1Visual2: ((arg1: Visual, arg2: Visual) => Void)): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    offCollide(handleVisual1Visual2?: ((arg1: Visual, arg2: Visual) => Void)?): Void;
    /** Dispatched when this visual body collides with another visual's body. */
    listensCollide(): Bool;
    /** Dispatched when this visual body collides with another body. */
    onCollideBody(owner: Entity, handleVisualBody: ((arg1: Visual, arg2: Body) => Void)): Void;
    /** Dispatched when this visual body collides with another body. */
    onceCollideBody(owner: Entity, handleVisualBody: ((arg1: Visual, arg2: Body) => Void)): Void;
    /** Dispatched when this visual body collides with another body. */
    offCollideBody(handleVisualBody?: ((arg1: Visual, arg2: Body) => Void)?): Void;
    /** Dispatched when this visual body collides with another body. */
    listensCollideBody(): Bool;
    /** Dispatched when this visual body overlaps with another visual's body. */
    onOverlap(owner: Entity, handleVisual1Visual2: ((arg1: Visual, arg2: Visual) => Void)): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    onceOverlap(owner: Entity, handleVisual1Visual2: ((arg1: Visual, arg2: Visual) => Void)): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    offOverlap(handleVisual1Visual2?: ((arg1: Visual, arg2: Visual) => Void)?): Void;
    /** Dispatched when this visual body overlaps with another visual's body. */
    listensOverlap(): Bool;
    /** Dispatched when this visual body overlaps with another body. */
    onOverlapBody(owner: Entity, handleVisualBody: ((arg1: Visual, arg2: Body) => Void)): Void;
    /** Dispatched when this visual body overlaps with another body. */
    onceOverlapBody(owner: Entity, handleVisualBody: ((arg1: Visual, arg2: Body) => Void)): Void;
    /** Dispatched when this visual body overlaps with another body. */
    offOverlapBody(handleVisualBody?: ((arg1: Visual, arg2: Body) => Void)?): Void;
    /** Dispatched when this visual body overlaps with another body. */
    listensOverlapBody(): Bool;
    /** Dispatched when this visual body collides with the world bounds. */
    onWorldBounds(owner: Entity, handleVisualUpDownLeftRight: ((arg1: Visual, arg2: Bool, arg3: Bool, arg4: Bool, arg5: Bool) => Void)): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    onceWorldBounds(owner: Entity, handleVisualUpDownLeftRight: ((arg1: Visual, arg2: Bool, arg3: Bool, arg4: Bool, arg5: Bool) => Void)): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    offWorldBounds(handleVisualUpDownLeftRight?: ((arg1: Visual, arg2: Bool, arg3: Bool, arg4: Bool, arg5: Bool) => Void)?): Void;
    /** Dispatched when this visual body collides with the world bounds. */
    listensWorldBounds(): Bool;
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
    /**
     * Stop this visual, whatever that means (override in subclasses).
     * When arcade physics are enabled, they are also stopped from this call.
     */
    stop(): Void;
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
    /**
     * If `true`, matrix translation (tx & ty) will be rounded.
     * May be useful to render pixel perfect scenes onto `ceramic.Filter`.
     */
    roundTranslation: Bool;
    rotation: Float;
    alpha: Float;
    /**
     * Visual X translation.
     * This is a shorthand equivalent to assigning a `Transform` object to
     * the visual with a `tx` value of `translateX`
     */
    translateX: Float;
    /**
     * Visual Y translation.
     * This is a shorthand equivalent to assigning a `Transform` object to
     * the visual with a `ty` value of `translateY`
     */
    translateY: Float;
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
    translate(translateX: Float, translateY: Float): Void;
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
    screenToVisual(x: Float, y: Float, point: Point, handleFilters?: Bool): Void;
    /** Assign X and Y to given point after converting them from current visual coordinates to screen coordinates. */
    visualToScreen(x: Float, y: Float, point: Point, handleFilters?: Bool): Void;
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
    hasIndirectParent(targetParent: Visual): Bool;
    firstParentWithClass<T>(clazz: Class<T>): T;
    add(visual: Visual): Void;
    remove(visual: Visual): Void;
    /** Returns `true` if the current visual contains this child.
        When `recursive` option is `true`, will return `true` if
        the current visual contains this child or one of
        its direct or indirect children does. */
    contains(child: Visual, recursive?: Bool): Bool;
    /** Will set this visual size to screen size */
    bindToScreenSize(): Void;
    /** Will set this visual size to target size (`settings.targetWidth` and `settings.targetHeight`) */
    bindToTargetSize(): Void;
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
    static functionEquals(functionA: Dynamic, functionB: Dynamic): Bool;
    static decodeUriParams(raw: String): haxe.ds.Map<K, V>;
    /**
     * Transforms a value between 0 and 1 to another value between 0 and 1 following a sinusoidal curve
     * @param value a value between 0 and 1. If giving a value > 1, its modulo 1 will be used.
     * @return Float
     */
    static sinRatio(value: Float): Float;
    /**
     * Transforms a value between 0 and 1 to another value between 0 and 1 following a cosinusoidal curve
     * @param value a value between 0 and 1. If giving a value > 1, its modulo 1 will be used.
     * @return Float
     */
    static cosRatio(value: Float): Float;
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
    /**
     * Get storage directory (if any available)
     * @return directory as string or null if nothing available
     */
    storageDirectory(): String?;
    /**
     * Joins all paths in `paths` together.
     * @return joined paths as string
     */
    pathJoin(paths: Array<String>): String;
}

/** Utility to track a tree of entity objects and perform specific actions when some entities get untracked */
class TrackEntities extends Entity implements Component {
    constructor();
    entity: Entity;
    entityMap: haxe.ds.Map<K, V>;
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
    /** Track size. Default `0`, meaning this track won't do anything.
        By default, because `autoFitSize` is `true`, adding new keyframes to this
        track will update `size` accordingly so it may not be needed to update `size` explicitly.
        Setting `size` to `-1` means the track will never finish. */
    size: Int;
    /** If set to `true` (default), adding keyframes to this track will update
        its size accordingly to match last keyframe time. */
    autoFitSize: Bool;
    /** Whether this track should loop. Ignored if track's `size` is `-1` (not defined). */
    loop: Bool;
    /** Whether this track is locked or not.
        A locked track doesn't get updated by the timeline it is attached to, if any. */
    locked: Bool;
    /** Timeline on which this track is added to */
    timeline: Timeline;
    /** Position on this track.
        Gets back to zero when `loop=true` and position reaches a defined `size`. */
    position: Float;
    /** The key frames on this track. */
    keyframes: Array<K>;
    /** The keyframe right before or equal to current time, if any. */
    before: K;
    /** The keyframe right after current time, if any. */
    after: K;
    destroy(): Void;
    /** Seek the given position (in frames) in the track.
        Will take care of clamping `position` or looping it depending on `size` and `loop` properties. */
    seek(targetPosition: Float): Void;
    /** Add a keyframe to this track */
    add(keyframe: K): Void;
    /** Remove a keyframe from this track */
    remove(keyframe: K): Void;
    /** Update `size` property to make it fit
        the index of the last keyframe on this track. */
    fitSize(): Void;
    /** Apply changes that this track is responsible of. Usually called after `update(delta)` or `seek(time)`. */
    apply(forceChange?: Bool): Void;
    findKeyframeAtIndex(index: Int): K?;
    /** Find the keyframe right before or equal to given `position` */
    findKeyframeBefore(position: Float): K?;
    /** Find the keyframe right after given `position` */
    findKeyframeAfter(position: Float): K?;
}

class TimelineKeyframe {
    constructor(index: Int, easing: Easing);
    index: Int;
    easing: Easing;
}

class TimelineFloatTrack extends TimelineTrack<TimelineFloatKeyframe> {
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
    apply(forceChange?: Bool): Void;
    unbindEvents(): Void;
}

class TimelineFloatKeyframe extends TimelineKeyframe {
    constructor(value: Float, index: Int, easing: Easing);
    value: Float;
}

class TimelineDegreesTrack extends TimelineTrack<TimelineFloatKeyframe> {
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
    apply(forceChange?: Bool): Void;
    unbindEvents(): Void;
}

class TimelineColorTrack extends TimelineTrack<TimelineColorKeyframe> {
    constructor();
    /**change event*/
    onChange(owner: Entity?, handleTrack: ((track: TimelineColorTrack) => Void)): Void;
    /**change event*/
    onceChange(owner: Entity?, handleTrack: ((track: TimelineColorTrack) => Void)): Void;
    /**change event*/
    offChange(handleTrack?: ((track: TimelineColorTrack) => Void)?): Void;
    /**Does it listen to change event*/
    listensChange(): Bool;
    value: Color;
    apply(forceChange?: Bool): Void;
    unbindEvents(): Void;
}

class TimelineColorKeyframe extends TimelineKeyframe {
    constructor(value: Color, index: Int, easing: Easing);
    value: Color;
}

class Timeline extends Entity implements Component {
    constructor();
    /**
     * Triggered when position reaches an existing label
     * @param index label index (position)
     * @param name label name
     */
    onStartLabel(owner: Entity?, handleIndexName: ((index: Int, name: String) => Void)): Void;
    /**
     * Triggered when position reaches an existing label
     * @param index label index (position)
     * @param name label name
     */
    onceStartLabel(owner: Entity?, handleIndexName: ((index: Int, name: String) => Void)): Void;
    /**
     * Triggered when position reaches an existing label
     * @param index label index (position)
     * @param name label name
     */
    offStartLabel(handleIndexName?: ((index: Int, name: String) => Void)?): Void;
    /**
     * Triggered when position reaches an existing label
     * @param index label index (position)
     * @param name label name
     */
    listensStartLabel(): Bool;
    /**
     * Triggered when position reaches the end of an area following the given label.
     * Either when a new label was reached or when end of timeline was reached
     * @param index label index (position)
     * @param name label name
     */
    onEndLabel(owner: Entity?, handleIndexName: ((index: Int, name: String) => Void)): Void;
    /**
     * Triggered when position reaches the end of an area following the given label.
     * Either when a new label was reached or when end of timeline was reached
     * @param index label index (position)
     * @param name label name
     */
    onceEndLabel(owner: Entity?, handleIndexName: ((index: Int, name: String) => Void)): Void;
    /**
     * Triggered when position reaches the end of an area following the given label.
     * Either when a new label was reached or when end of timeline was reached
     * @param index label index (position)
     * @param name label name
     */
    offEndLabel(handleIndexName?: ((index: Int, name: String) => Void)?): Void;
    /**
     * Triggered when position reaches the end of an area following the given label.
     * Either when a new label was reached or when end of timeline was reached
     * @param index label index (position)
     * @param name label name
     */
    listensEndLabel(): Bool;
    /** Timeline size. Default `0`, meaning this timeline won't do anything.
        By default, because `autoFitSize` is `true`, adding or updating tracks on this
        timeline will update timeline `size` accordingly so it may not be needed to update `size` explicitly.
        Setting `size` to `-1` means the timeline will never finish. */
    size: Int;
    /** If set to `true` (default), adding or updating tracks on this timeline will update
        timeline size accordingly to match longest track size. */
    autoFitSize: Bool;
    /** Whether this timeline should loop. Ignored if timeline's `size` is `-1` (not defined). */
    loop: Bool;
    /** Whether this timeline should bind itself to update cycle automatically or not (default `true`). */
    autoUpdate: Bool;
    /**
     * Frames per second on this timeline.
     * Note: a lower fps doesn't mean animations won't be interpolated between frames.
     * Thus using 30 fps is still fine even if screen refreshes at 60 fps.
     */
    fps: Int;
    /** Position on this timeline.
        Gets back to zero when `loop=true` and position reaches a defined `size`. */
    position: Float;
    /** The tracks updated by this timeline */
    tracks: Array<TimelineTrack<TimelineKeyframe>>;
    /** Whether this timeline is paused or not. */
    paused: Bool;
    /**
     * Used in pair with `labelIndexes` to manage timeline labels
     */
    labels: Array<String>;
    /**
     * If >= 0, timeline will start from this index.
     * When timeline is looping, it will reset to this index as well at each iteration.
     */
    startPosition: Int;
    /**
     * If provided, timeline will stop at this index.
     * When timeline is looping, it will reset to startIndex (if >= 0).
     */
    endPosition: Int;
    update(delta: Float): Void;
    /** Seek the given position (in frames) in the timeline.
        Will take care of clamping `position` or looping it depending on `size` and `loop` properties. */
    seek(targetPosition: Float): Void;
    /**
     * Animate starting from the given label name and calls complete when
     * reaching the end of label area (= when animation finishes).
     * If animation is interrupted (by playing another animation, seeking another position...),
     * complete won't be called.
     * @param name Label name
     * @param complete callback fired when animation finishes.
     */
    animate(name: String, complete: (() => Void)): Void;
    /**
     * Seek position to match the given label
     * @param name Label name
     * @return The index (position) of the looping label, or -1 if no label was found
     */
    seekLabel(name: String): Int;
    /**
     * Reset `startPosition` and `endPosition`
     */
    resetStartAndEndPositions(): Void;
    /**
     * Seek position to match the given label and set startPosition and endPosition
     * so that it will loop through the whole area following this label, up to the
     * position of the next label or the end of the timeline.
     * @param name Label name
     * @return The index (position) of the looping label, or -1 if no label was found
     */
    loopLabel(name: String): Int;
    /** Apply (or re-apply) every track of this timeline at the current position */
    apply(forceChange?: Bool): Void;
    /** Add a track to this timeline */
    add(track: TimelineTrack<TimelineKeyframe>): Void;
    get(trackId: String): TimelineTrack<TimelineKeyframe>;
    /** Remove a track from this timeline */
    remove(track: TimelineTrack<TimelineKeyframe>): Void;
    /** Update `size` property to make it fit
        the size of the longuest track. */
    fitSize(): Void;
    indexOfLabelBeforeIndex(index: Int): Int;
    labelAtIndex(index: Int): String;
    indexOfLabel(name: String): Int;
    setLabel(index: Int, name: String): Void;
    removeLabelAtIndex(index: Int): Bool;
    removeLabel(name: String): Bool;
    entity: Entity;
    initializerName: String;
    unbindEvents(): Void;
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
    lshiftDown(): Void;
    lshiftUp(): Void;
    rshiftDown(): Void;
    rshiftUp(): Void;
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
    clipTextX: Float;
    clipTextY: Float;
    clipTextWidth: Float;
    clipTextHeight: Float;
    clipText(x: Float, y: Float, width: Float, height: Float): Void;
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
    /** Shared input instance */
    static input: ceramic.Input;
    /** Shared settings instance */
    static settings: Settings;
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
    /** Target width. Affects window size at startup (unless `windowWidth` is specified)
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
    /** Target height. Affects window size at startup (unless `windowHeight` is specified)
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
    /** Target window width at startup
        Use `targetWidth` as fallback if set to 0 (default) */
    windowWidth: Int;
    invalidateWindowWidth(): Void;
    /**Event when windowWidth field changes.*/
    onWindowWidthChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when windowWidth field changes.*/
    onceWindowWidthChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when windowWidth field changes.*/
    offWindowWidthChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when windowWidth field changes.*/
    listensWindowWidthChange(): Bool;
    /** Target window height at startup
        Use `targetHeight` as fallback if set to 0 (default) */
    windowHeight: Int;
    invalidateWindowHeight(): Void;
    /**Event when windowHeight field changes.*/
    onWindowHeightChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when windowHeight field changes.*/
    onceWindowHeightChange(owner: Entity?, handleCurrentPrevious: ((current: Int, previous: Int) => Void)): Void;
    /**Event when windowHeight field changes.*/
    offWindowHeightChange(handleCurrentPrevious?: ((current: Int, previous: Int) => Void)?): Void;
    /**Event when windowHeight field changes.*/
    listensWindowHeightChange(): Bool;
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
    /** App collections. */
    collections: (() => ceramic.AutoCollections);
    /** App info (useful when dynamically loaded, not needed otherwise). */
    appInfo: Dynamic;
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
    bounceScroll(): Void;
    unbindEvents(): Void;
}

enum ScrollDirection {
    VERTICAL,
    HORIZONTAL
}

/**
 * For now, just a way to identify a script module as a type, to resolve fields dynamically from scripts.
 * Might be extended later to link with "script converted to haxe compiled code"
 */
class ScriptModule {
    constructor(owner: Script);
    owner: Script;
}

type ScriptContent = String;

class Script extends Entity implements Component {
    constructor(content: String);
    static errorHandlers: Array<((error: String, line: Int, char: Int) => Void)>;
    static traceHandlers: Array<((v: Dynamic, pos?: TAnonymous) => Void)>;
    static log: Logger;
    content: String;
    program: hscript.Expr;
    interp: ceramic.Interp;
    module: ScriptModule;
    destroy(): Void;
    run(): Void;
    getEntity(itemId: String): Entity;
    getModule(itemId: String): ScriptModule;
    get(name: String): Dynamic;
    call(name: String, args?: Array<Dynamic>?): Dynamic;
    callScriptMethod(name: String, numArgs: Int, arg1?: Dynamic?, arg2?: Dynamic?, arg3?: Dynamic?): Dynamic;
    entity: Entity;
    initializerName: String;
}

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
    /**
     * Returns `true` if current running thread is main thread
     * @return Bool
     */
    static currentIsMainThread(): Bool;
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

class Particles<T extends ceramic.ParticleEmitter> extends Visual {
    constructor(emitter?: T?);
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    emitter: T;
    autoEmit: Bool;
    autoExplodeInterval: Float;
    autoExplodeQuantity: Int;
    /**
     * Determines whether the emitter is currently paused. It is totally safe to directly toggle this.
     */
    emitterPaused: Bool;
    /**
     * How often a particle is emitted, if currently emitting.
     * Can be modified at the middle of an emission safely;
     */
    emitterInterval: Float;
    /**
     * How particles should be launched. If `CIRCLE` (default), particles will use `launchAngle` and `speed`.
     * Otherwise, particles will just use `velocityX` and `velocityY`.
     */
    emitterLaunchMode: ParticlesLaunchMode;
    /**
     * Apply particle scale to underlying visual or not.
     */
    emitterVisualScaleActive: Bool;
    /**
     * Keep the scale ratio of the particle. Uses the `scaleX` value for reference.
     */
    emitterKeepScaleRatio: Bool;
    /**
     * Apply particle color to underlying visual or not.
     */
    emitterVisualColorActive: Bool;
    /**
     * Apply particle alpha to underlying visual or not.
     */
    emitterVisualAlphaActive: Bool;
    /**
     * Apply particle position (x & y) to underlying visual or not.
     */
    emitterVisualPositionActive: Bool;
    /**
     * Apply particle angle to underlying visual rotation or not.
     */
    emitterVisualRotationActive: Bool;
    /**
	 * The width of the emission area.
     * If not defined (`-1`), will use visual's width bound to this `ParticleEmitter` object, if any
	 */
    emitterWidth: Float;
    /**
	 * The height of the emission area.
     * If not defined (`-1`), will use visual's height bound to this `ParticleEmitter` object, if any
	 */
    emitterHeight: Float;
    /**
	 * The x position of the emission, relative to particles parent (if any)
	 */
    emitterX: Float;
    /**
	 * The y position of the emission, relative to particles parent (if any)
	 */
    emitterY: Float;
    /**
     * Enable or disable the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityActive: Bool;
    /**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
    emitterMaxVelocityX: Float;
    /**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
    emitterMaxVelocityY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityStartMinX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityStartMinY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityStartMaxX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityStartMaxY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityEndMinX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityEndMinY: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityEndMaxX: Float;
    /**
     * Sets the velocity range of particles launched from this emitter. Only used with `SQUARE`.
     */
    emitterVelocityEndMaxY: Float;
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

class Ngon extends Mesh {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    sides: Int;
    radius: Float;
    computeContent(): Void;
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
    /** On `Mesh` instances, can be used instead of colors array when the mesh is only composed of a single color. */
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
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
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

/**
 * Just a regular quad (transparent by default) with a few addition to make it more convenient when used as a layer
 */
class Layer extends Quad {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    /**resize event*/
    onResize(owner: Entity?, handleWidthHeight: ((width: Float, height: Float) => Void)): Void;
    /**resize event*/
    onceResize(owner: Entity?, handleWidthHeight: ((width: Float, height: Float) => Void)): Void;
    /**resize event*/
    offResize(handleWidthHeight?: ((width: Float, height: Float) => Void)?): Void;
    /**Does it listen to resize event*/
    listensResize(): Bool;
    unbindEvents(): Void;
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
    export function SCAN(scanCode: ScanCode): KeyAcceleratorItem;
    export function KEY(keyCode: KeyCode): KeyAcceleratorItem;
}

class Key {
    constructor(keyCode: KeyCode, scanCode: ScanCode);
    /** Key code (localized key) depends on keyboard mapping (QWERTY, AZERTY, ...) */
    keyCode: KeyCode;
    /** Name associated to the key code (localized key) */
    keyCodeName: String;
    /** Scan code (US international key) doesn't depend on keyboard mapping (QWERTY, AZERTY, ...) */
    scanCode: ScanCode;
    /** Name associated to the scan code (US international key) */
    scanCodeName: String;
}

class Json {
    static stringify(value: Dynamic, replacer?: ((key: Dynamic, value: Dynamic) => Dynamic)?, space?: String?): String;
    static parse(text: String): Dynamic;
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
    /** Target window width at startup
        Use `targetWidth` as fallback if set to 0 (default) */
    windowWidth: Int;
    /** Target window height at startup
        Use `targetHeight` as fallback if set to 0 (default) */
    windowHeight: Int;
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
    /** App collections. */
    collections: (() => ceramic.AutoCollections);
    /** App info (useful when dynamically loaded, not needed otherwise). */
    appInfo: Dynamic;
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

class HttpResponse {
    constructor(status: Int, content: String, error?: String?, headers: haxe.ds.Map<K, V>);
    status: Int;
    content: String;
    error: String;
    headers: haxe.ds.Map<K, V>;
}

    /** Augmented and higher level HTTP request options. */
interface HttpRequestOptions {
    content?: String?;
    headers?: haxe.ds.Map<K, V>?;
    method?: HttpMethod?;
    params?: haxe.ds.Map<K, V>?;
    timeout?: Int?;
    url: String;
}

/** A cross-platform and high level HTTP request utility */
class Http {
    static request(options: TAnonymous, done: ((arg1: HttpResponse) => Void)): Void;
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

/**
 * A group of entities, which is itself an entity.
 */
class Group<T extends Entity> extends Entity implements Collidable {
    constructor(id?: String?);
    /**
     * The order items are sorted before using the group to overlap or collide with over collidables.
     * Only relevant on groups of visuals, when using arcade physics.
     */
    sortDirection: SortDirection;
    items: haxe.ds.ReadOnlyArray<T>;
    add(item: T): Void;
    remove(item: T): Void;
    contains(item: T): Bool;
    clear(): Void;
    destroy(): Void;
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
    /** Fragment color (if not transparent, default `BLACK`) */
    color?: Color?;
    /** Fragment-level components */
    components: haxe.DynamicAccess<String>;
    /** Arbitrary data hold by this fragment. */
    data: Dynamic;
    /**
     * Frames per second (used in timeline, default is 30).
     * Note that this is only affecting how long a frame in the timeline lasts.
     * Using 30FPS doesn't mean the screen will be rendered at 30FPS.
     * Frame values are interpolated to match screen frame rate.
     */
    fps?: Int?;
    /** Fragment height */
    height: Float;
    /** Identifier of the fragment. */
    id: String;
    /** Fragment items (visuals or other entities) */
    items?: Array<TAnonymous>?;
    /** Timeline labels */
    labels?: haxe.DynamicAccess<Int>?;
    /** Whether fragment background overflows (no effect on fragment itself, depends on player implementation) */
    overflow?: Bool?;
    /** Timeline tracks */
    tracks?: Array<TAnonymous>?;
    /** Fragment being transparent or not (default `true`) */
    transparent?: Bool?;
    /** Fragment width */
    width: Float;
}

/** A fragment is a group of visuals rendered from data (.fragment file) */
class Fragment extends Layer {
    constructor(assets?: Assets?, editedItems?: Bool);
    static cacheData(fragmentData: TAnonymous): Void;
    /**
     * A static helper to get a fragment data object from fragment id.
     * Fragments need to be cached first with `cacheFragmentData()`,
     * unless an editor instance is being active.
     * @param fragmentId 
     * @return Null<FragmentData>
     */
    static getData(fragmentId: String): TAnonymous?;
    /**floatAChange event*/
    onFloatAChange(owner: Entity?, handleFloatAPrevFloatA: ((floatA: Float, prevFloatA: Float) => Void)): Void;
    /**floatAChange event*/
    onceFloatAChange(owner: Entity?, handleFloatAPrevFloatA: ((floatA: Float, prevFloatA: Float) => Void)): Void;
    /**floatAChange event*/
    offFloatAChange(handleFloatAPrevFloatA?: ((floatA: Float, prevFloatA: Float) => Void)?): Void;
    /**Does it listen to floatAChange event*/
    listensFloatAChange(): Bool;
    /**floatBChange event*/
    onFloatBChange(owner: Entity?, handleFloatBPrevFloatB: ((floatB: Float, prevFloatB: Float) => Void)): Void;
    /**floatBChange event*/
    onceFloatBChange(owner: Entity?, handleFloatBPrevFloatB: ((floatB: Float, prevFloatB: Float) => Void)): Void;
    /**floatBChange event*/
    offFloatBChange(handleFloatBPrevFloatB?: ((floatB: Float, prevFloatB: Float) => Void)?): Void;
    /**Does it listen to floatBChange event*/
    listensFloatBChange(): Bool;
    /**floatCChange event*/
    onFloatCChange(owner: Entity?, handleFloatCPrevFloatC: ((floatC: Float, prevFloatC: Float) => Void)): Void;
    /**floatCChange event*/
    onceFloatCChange(owner: Entity?, handleFloatCPrevFloatC: ((floatC: Float, prevFloatC: Float) => Void)): Void;
    /**floatCChange event*/
    offFloatCChange(handleFloatCPrevFloatC?: ((floatC: Float, prevFloatC: Float) => Void)?): Void;
    /**Does it listen to floatCChange event*/
    listensFloatCChange(): Bool;
    /**floatDChange event*/
    onFloatDChange(owner: Entity?, handleFloatDPrevFloatD: ((floatD: Float, prevFloatD: Float) => Void)): Void;
    /**floatDChange event*/
    onceFloatDChange(owner: Entity?, handleFloatDPrevFloatD: ((floatD: Float, prevFloatD: Float) => Void)): Void;
    /**floatDChange event*/
    offFloatDChange(handleFloatDPrevFloatD?: ((floatD: Float, prevFloatD: Float) => Void)?): Void;
    /**Does it listen to floatDChange event*/
    listensFloatDChange(): Bool;
    /**
     * Emit this event to change current location.
     * Behavior depends on how this event is handled and does nothing by default.
     */
    emitLocation(location: String): Void;
    /**
     * Emit this event to change current location.
     * Behavior depends on how this event is handled and does nothing by default.
     */
    onLocation(owner: Entity?, handleLocation: ((location: String) => Void)): Void;
    /**
     * Emit this event to change current location.
     * Behavior depends on how this event is handled and does nothing by default.
     */
    onceLocation(owner: Entity?, handleLocation: ((location: String) => Void)): Void;
    /**
     * Emit this event to change current location.
     * Behavior depends on how this event is handled and does nothing by default.
     */
    offLocation(handleLocation?: ((location: String) => Void)?): Void;
    /**
     * Emit this event to change current location.
     * Behavior depends on how this event is handled and does nothing by default.
     */
    listensLocation(): Bool;
    editedItems: Bool;
    assets: Assets;
    entities: Array<Entity>;
    items: Array<TAnonymous>;
    tracks: Array<TAnonymous>;
    fps: Int;
    fragmentData: TAnonymous;
    resizable: Bool;
    autoUpdateTimeline: Bool;
    /**
     * Custom float value that can be used in editor
     */
    floatA: Float;
    /**
     * Custom float value that can be used in editor
     */
    floatB: Float;
    /**
     * Custom float value that can be used in editor
     */
    floatC: Float;
    /**
     * Custom float value that can be used in editor
     */
    floatD: Float;
    pendingLoads: Int;
    timeline: Timeline;
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
    getItem(itemId: String): TAnonymous;
    getItemByName(name: String): TAnonymous;
    typeOfItem(itemId: String): String;
    removeItem(itemId: String): Void;
    removeAllItems(): Void;
    destroy(): Void;
    computeInstanceContentIfNeeded(itemId: String, entity?: Entity?): Void;
    updateEditableFieldsFromInstance(itemId: String, forceChange?: Bool): Void;
    /** Fragment components mapping. Does not contain components
        created separatelywith `component()` or macro-based components or components property. */
    fragmentComponents: Map<String, Component>;
    /**
     * Create or update a timeline track from the provided track data
     * @param entityType
     *      (optional) entity type being targeted by the track.
     *      If not provided, will try to resolve it from track's target entity id
     * @param track Track data used to create or update timeline track
     */
    putTrack(entityType?: String?, track: TAnonymous): Void;
    getTrack(entity: String, field: String): TAnonymous;
    removeTrack(entity: String, field: String): Void;
    createTimelineIfNeeded(): Void;
    /**
     * Create or update a timeline label from the provided label index and name
     * @param index Label index (position)
     * @param name Label name
     */
    putLabel(index: Int, name: String): Void;
    /**
     * Return the index (position) of the given label name or -1 if no such label exists.
     * @param name 
     * @return Int
     */
    indexOfLabel(name: String): Int;
    /**
     * Return the label at the given index (position), if any exists.
     * @param index 
     * @return Int
     */
    labelAtIndex(index: Int): String;
    /**
     * Remove label with the given name
     * @param name Label name
     */
    removeLabel(name: String): Void;
    /**
     * Remove label at the given index (position)
     * @param index Label index
     */
    removeLabelAtIndex(index: Int): Void;
    paused: Bool;
    unbindEvents(): Void;
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
    pages: haxe.ds.Map<K, V>;
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
class Filter extends Layer implements Observable {
    constructor();
    /**Event when any observable value as changed on this instance.*/
    onObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Filter, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    onceObservedDirty(owner: Entity?, handleInstanceFromSerializedField: ((instance: Filter, fromSerializedField: Bool) => Void)): Void;
    /**Event when any observable value as changed on this instance.*/
    offObservedDirty(handleInstanceFromSerializedField?: ((instance: Filter, fromSerializedField: Bool) => Void)?): Void;
    /**Event when any observable value as changed on this instance.*/
    listensObservedDirty(): Bool;
    /**Default is `false`, automatically set to `true` when any of this instance's observable variables has changed.*/
    observedDirty: Bool;
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
    invalidateRenderTexture(): Void;
    /**Event when renderTexture field changes.*/
    onRenderTextureChange(owner: Entity?, handleCurrentPrevious: ((current: RenderTexture, previous: RenderTexture) => Void)): Void;
    /**Event when renderTexture field changes.*/
    onceRenderTextureChange(owner: Entity?, handleCurrentPrevious: ((current: RenderTexture, previous: RenderTexture) => Void)): Void;
    /**Event when renderTexture field changes.*/
    offRenderTextureChange(handleCurrentPrevious?: ((current: RenderTexture, previous: RenderTexture) => Void)?): Void;
    /**Event when renderTexture field changes.*/
    listensRenderTextureChange(): Bool;
    density: Float;
    render(requestFullUpdate?: Bool, done?: (() => Void)?): Void;
    visualInContentHits(visual: Visual, x: Float, y: Float): Bool;
    computeContent(): Void;
    destroy(): Void;
    unbindEvents(): Void;
}

/** Filesystem-related utilities. Only work on sys targets and/or nodejs depending on the methods */
class Files {
    static haveSameContent(filePath1: String, filePath2: String): Bool;
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
    static types(targetClass: String, recursive?: Bool): haxe.ds.Map<K, V>;
    static typeOf(targetClass: String, field: String): String;
    static editableFieldInfo(targetClass: String, recursive?: Bool): haxe.ds.Map<K, V>;
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
    scriptContent: String;
    script: Script;
    events: DynamicEvents<String>;
    destroyed: Bool;
    disposed: Bool;
    /**dispose event*/
    onDispose(owner: Entity?, handleEntity: ((entity: Entity) => Void)): Void;
    /**dispose event*/
    onceDispose(owner: Entity?, handleEntity: ((entity: Entity) => Void)): Void;
    /**dispose event*/
    offDispose(handleEntity?: ((entity: Entity) => Void)?): Void;
    /**Does it listen to dispose event*/
    listensDispose(): Bool;
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
    /**
     * Schedules destroy, at the end of the current frame.
     */
    dispose(): Void;
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
    /**start event*/
    onStart(owner: Entity?, handle: (() => Void)): Void;
    /**start event*/
    onceStart(owner: Entity?, handle: (() => Void)): Void;
    /**start event*/
    offStart(handle?: (() => Void)?): Void;
    /**Does it listen to start event*/
    listensStart(): Bool;
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
    cancel(): Void;
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
    basicToField(assets: Assets, basic: haxe.DynamicAccess<T>, done: ((arg1: haxe.ds.Map<K, V>) => Void)): Void;
    fieldToBasic(value: haxe.ds.Map<K, V>): haxe.DynamicAccess<T>;
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
    basicToField(assets: Assets, basic: haxe.DynamicAccess<String>, done: ((arg1: haxe.ds.Map<K, V>) => Void)): Void;
    fieldToBasic(value: haxe.ds.Map<K, V>): haxe.DynamicAccess<String>;
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
    constructor(face: String, pointSize: Float, baseSize: Float, chars: haxe.ds.Map<K, V>, charCount: Int, distanceField: BitmapFontDistanceFieldData?, pages: Array<TAnonymous>, lineHeight: Float, kernings: haxe.ds.Map<K, V>);
    face: String;
    pointSize: Float;
    baseSize: Float;
    chars: haxe.ds.Map<K, V>;
    charCount: Int;
    distanceField: BitmapFontDistanceFieldData?;
    pages: Array<TAnonymous>;
    lineHeight: Float;
    kernings: haxe.ds.Map<K, V>;
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
    constructor(fontData: BitmapFontData, pages: haxe.ds.Map<K, V>);
    /** The map of font texture pages to their id. */
    pages: haxe.ds.Map<K, V>;
    face: String;
    pointSize: Float;
    baseSize: Float;
    chars: haxe.ds.Map<K, V>;
    charCount: Int;
    lineHeight: Float;
    kernings: haxe.ds.Map<K, V>;
    msdf: Bool;
    /** Cached reference of the ' '(32) character, for sizing on tabs/spaces */
    spaceChar: BitmapFontCharacter;
    /**
     * Shaders used to render the characters. If null, uses default shader.
     * When loading MSDF fonts, ceramic's MSDF shader will be assigned here.
     * Stored per page
     */
    pageShaders: haxe.ds.Map<K, V>;
    /**
     * When using MSDF fonts, or fonts with custom shaders, it is possible to pre-render characters
     * onto a RenderTexture to use it like a regular texture later with default shader.
     * Useful in some situations to reduce draw calls.
     */
    preRenderedPages: haxe.ds.Map<K, V>;
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
    static all: Array<String>;
    static allDirs: Array<String>;
    static allByName: haxe.ds.Map<K, V>;
    static allDirsByName: haxe.ds.Map<K, V>;
    static decodePath(path: String): AssetPathInfo;
    static addAssetKind(kind: String, add: ((arg1: Assets, arg2: String, arg3?: Dynamic) => Void), extensions: Array<String>, dir: Bool, types: Array<String>): Void;
    static assetNameFromPath(path: String): String;
    static realAssetPath(path: String, runtimeAssets?: RuntimeAssets?): String;
    static getReloadCount(realAssetPath: String): Int;
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
    /**progress event*/
    onProgress(owner: Entity?, handleLoadedTotalSuccess: ((loaded: Int, total: Int, success: Bool) => Void)): Void;
    /**progress event*/
    onceProgress(owner: Entity?, handleLoadedTotalSuccess: ((loaded: Int, total: Int, success: Bool) => Void)): Void;
    /**progress event*/
    offProgress(handleLoadedTotalSuccess?: ((loaded: Int, total: Int, success: Bool) => Void)?): Void;
    /**Does it listen to progress event*/
    listensProgress(): Bool;
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
    /**
     * If set to `true`, will ensure asset loading is non blocking, at least between each asset.
     * This is useful when we need to update screen during asset loading
     */
    nonBlocking: Bool;
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
    flags: haxe.ds.Map<K, V>;
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

class ArcadeWorld extends World {
    constructor(boundsX: Float, boundsY: Float, boundsWidth: Float, boundsHeight: Float);
    overlap(element1: Collidable, element2?: Collidable?, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    overlapCeramicGroupVsItself(group: Group<Visual>, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    overlapBodyVsCeramicGroup(body: Body, group: Group<Visual>, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collide(element1: Collidable, element2?: Collidable?, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collideCeramicGroupVsItself(group: Group<Visual>, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collideBodyVsCeramicGroup(body: Body, group: Group<Visual>, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    sortCeramicGroup(group: Group<Visual>, sortDirection?: SortDirection): Void;
}

class ArcadePhysics extends Entity {
    constructor();
    items: Array<VisualArcadePhysics>;
    /** All worlds used with arcade physics */
    worlds: Array<ArcadeWorld>;
    /** Default world used for arcade physics */
    world: ArcadeWorld;
    /** Groups by id */
    groups: haxe.ds.Map<K, V>;
    /** If `true`, default world (`world`) bounds will be
        updated automatically to match screen size. */
    autoUpdateWorldBounds: Bool;
    createWorld(autoAdd?: Bool): ArcadeWorld;
    addWorld(world: ArcadeWorld): Void;
    removeWorld(world: ArcadeWorld): Void;
}

/**
 * Convenience mesh subclass to draw arc, pie, ring or disc geometry
 */
class Arc extends Mesh {
    constructor();
    static editorSetupEntity(entityData: editor.model.EditorEntityData): Void;
    /**
     * Number of sides. Higher is smoother but needs more vertices
     */
    sides: Int;
    /**
     * Radius of the arc
     */
    radius: Float;
    /**
     * Angle (from 0 to 360). 360 will make it draw a full circle/ring
     */
    angle: Float;
    /**
     * Position of the drawn border
     */
    borderPosition: BorderPosition;
    /**
     * Thickness of the arc. If same value as radius and borderPosition is `INSIDE`, will draw a pie.
     */
    thickness: Float;
    computeContent(): Void;
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
    /**
     * Visuals (ordered)
     * Active list of visuals being managed by ceramic.
     * This list is ordered and updated at every frame.
     * In between, it could contain destroyed visuals as they
     * are removed only at the end of the frame for performance reasons.
     */
    visuals: Array<Visual>;
    /**
     * Pending visuals: visuals that have been created this frame
     * but were not added to the `visual` list yet
     */
    pendingVisuals: Array<Visual>;
    /**
     * Pending destroyed visuals: visuals that have been destroyed this frame
     * but were not removed to the `visual` list yet
     */
    destroyedVisuals: Array<Visual>;
    /** Groups */
    groups: Array<Group<Entity>>;
    /** Input */
    input: ceramic.Input;
    /** Render Textures */
    renderTextures: Array<RenderTexture>;
    /** App level assets. Used to load default bitmap font */
    assets: Assets;
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
    converters: haxe.ds.Map<K, V>;
    timelines: ceramic.Timelines;
    arcade: ArcadePhysics;
    group(id: String, createIfNeeded?: Bool): Group<Entity>;
    unbindEvents(): Void;
    /**App info extracted from `ceramic.yml`*/
    info: TAnonymous;
}

class Texts {
    /**RobotoMedium.fnt*/
    static ROBOTO_MEDIUM: AssetId<String>;
    /**RobotoBold.fnt*/
    static ROBOTO_BOLD: AssetId<String>;
    /**entypo.fnt*/
    static ENTYPO: AssetId<String>;
}

class Sounds {
}

class Shaders {
    /**tintBlack.vert, tintBlack.frag*/
    static TINT_BLACK: AssetId<String>;
    /**textured.frag, textured.vert*/
    static TEXTURED: AssetId<String>;
    /**pixelArt.vert, pixelArt.frag*/
    static PIXEL_ART: AssetId<String>;
    /**outline.vert, outline.frag*/
    static OUTLINE: AssetId<String>;
    /**msdf.frag, msdf.vert*/
    static MSDF: AssetId<String>;
    /**glow.vert, glow.frag*/
    static GLOW: AssetId<String>;
    /**fxaa.vert, fxaa.frag*/
    static FXAA: AssetId<String>;
    /**blur.vert, blur.frag*/
    static BLUR: AssetId<String>;
    /**bloom.vert, bloom.frag*/
    static BLOOM: AssetId<String>;
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

class Fonts {
    /**RobotoMedium.fnt*/
    static ROBOTO_MEDIUM: AssetId<String>;
    /**RobotoBold.fnt*/
    static ROBOTO_BOLD: AssetId<String>;
    /**entypo.fnt*/
    static ENTYPO: AssetId<String>;
}

class Databases {
}

/**
* @author       Richard Davey <rich@photonstorm.com>
* @copyright    2016 Photon Storm Ltd.
* @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
*/
class World {
    constructor(boundsX: Float, boundsY: Float, boundsWidth: Float, boundsHeight: Float);
    /** The World gravity X setting. Defaults to 0 (no gravity). */
    gravityX: Float;
    /** The World gravity Y setting. Defaults to 0 (no gravity). */
    gravityY: Float;
    boundsX: Float;
    boundsY: Float;
    boundsWidth: Float;
    boundsHeight: Float;
    checkCollisionNone: Bool;
    checkCollisionUp: Bool;
    checkCollisionDown: Bool;
    checkCollisionLeft: Bool;
    checkCollisionRight: Bool;
    /** Used by the QuadTree to set the maximum number of objects per quad. */
    maxObjects: Int;
    /** Used by the QuadTree to set the maximum number of iteration levels. */
    maxLevels: Int;
    /** A value added to the delta values during collision checks. Increase it to prevent sprite tunneling. */
    overlapBias: Float;
    /** If true World.separate will always separate on the X axis before Y. Otherwise it will check gravity totals first. */
    forceX: Bool;
    /** Used when colliding a Sprite vs. a Group, or a Group vs. a Group, this defines the direction the sort is based on. Default is `LEFT_RIGHT`. */
    sortDirection: SortDirection;
    /** If true the QuadTree will not be used for any collision. QuadTrees are great if objects are well spread out in your game, otherwise they are a performance hit. If you enable this you can disable on a per body basis via `Body.skipQuadTree`. */
    skipQuadTree: Bool;
    /** If `true` the `Body.preUpdate` method will be skipped, halting all motion for all bodies. Note that other methods such as `collide` will still work, so be careful not to call them on paused bodies. */
    isPaused: Bool;
    /** The world QuadTree. */
    quadTree: arcade.QuadTree;
    /** Elapsed time since last tick. */
    elapsed: Float;
    elapsedMS: Float;
    /**
     * Updates the size of this physics world.
     *
     * @method Phaser.Physics.Arcade#setBounds
     * @param {number} x - Top left most corner of the world.
     * @param {number} y - Top left most corner of the world.
     * @param {number} width - New width of the world. Can never be smaller than the Game.width.
     * @param {number} height - New height of the world. Can never be smaller than the Game.height.
     */
    setBounds(x: Float, y: Float, width: Float, height: Float): Void;
    /**
     * Creates an Arcade Physics body on the given game object.
     *
     * A game object can only have 1 physics body active at any one time, and it can't be changed until the body is nulled.
     *
     * When you add an Arcade Physics body to an object it will automatically add the object into its parent Groups hash array.
     *
     * @method Phaser.Physics.Arcade#enableBody
     * @param {object} object - The game object to create the physics body on. A body will only be created if this object has a null `body` property.
     */
    enableBody(body: Body): Void;
    /**
     * Called automatically by a Physics body, it updates all motion related values on the Body unless `World.isPaused` is `true`.
     *
     * @method Phaser.Physics.Arcade#updateMotion
     * @param {Phaser.Physics.Arcade.Body} The Body object to be updated.
     */
    updateMotion(body: Body): Void;
    /**
     * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
     * Based on a function in Flixel by @ADAMATOMIC
     *
     * @method Phaser.Physics.Arcade#computeVelocity
     * @param {number} axis - 0 for nothing, 1 for horizontal, 2 for vertical.
     * @param {Phaser.Physics.Arcade.Body} body - The Body object to be updated.
     * @param {number} velocity - Any component of velocity (e.g. 20).
     * @param {number} acceleration - Rate at which the velocity is changing.
     * @param {number} drag - Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
     * @param {number} [max=10000] - An absolute value cap for the velocity.
     * @return {number} The altered Velocity value.
     */
    computeVelocity(axis: arcade.Axis, body: Body, velocity: Float, acceleration: Float, drag: Float, max?: Float): Float;
    overlap(element1: Collidable, element2?: Collidable?, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    /**
     * Checks for overlaps between two bodies. The objects can be Sprites, Groups or Emitters.
     * Unlike {@link #collide} the objects are NOT automatically separated or have any physics applied, they merely test for overlap results.
     * @return {boolean} True if an overlap occurred otherwise false.
     */
    overlapBodyVsBody(body1: Body, body2: Body, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    overlapGroupVsGroup(group1: arcade.Group, group2: arcade.Group, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    overlapGroupVsItself(group: arcade.Group, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    overlapBodyVsGroup(body: Body, group: arcade.Group, overlapCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collide(element1: Collidable, element2?: Collidable?, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    /**
     * Checks for collision between two bodies and separates them if colliding ({@link https://gist.github.com/samme/cbb81dd19f564dcfe2232761e575063d details}). If you don't require separation then use {@link #overlap} instead.
     * @return {boolean} True if a collision occurred otherwise false.
     */
    collideBodyVsBody(body1: Body, body2: Body, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collideGroupVsGroup(group1: arcade.Group, group2: arcade.Group, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collideGroupVsItself(group: arcade.Group, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    collideBodyVsGroup(body: Body, group: arcade.Group, collideCallback?: ((arg1: Body, arg2: Body) => Void)?, processCallback?: ((arg1: Body, arg2: Body) => Bool)?): Bool;
    /**
     * This method will sort a Groups hash array.
     *
     * If the Group has `physicsSortDirection` set it will use the sort direction defined.
     *
     * Otherwise if the sortDirection parameter is undefined, or Group.physicsSortDirection is null, it will use Phaser.Physics.Arcade.sortDirection.
     *
     * By changing Group.physicsSortDirection you can customise each Group to sort in a different order.
     *
     * @method Phaser.Physics.Arcade#sort
     * @param {Phaser.Group} group - The Group to sort.
     * @param {integer} [sortDirection] - The sort direction used to sort this Group.
     */
    sort(group: arcade.Group, sortDirection?: SortDirection): Void;
    /**
     * Check for intersection against two bodies.
     *
     * @method Phaser.Physics.Arcade#intersects
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body object to check.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body object to check.
     * @return {boolean} True if they intersect, otherwise false.
     */
    intersects(body1: Body, body2: Body): Bool;
    /**
     * Given a Group and a location this will check to see which Group children overlap with the coordinates.
     * Each child will be sent to the given callback for further processing.
     * Note that the children are not checked for depth order, but simply if they overlap the coordinate or not.
     *
     * @method Phaser.Physics.Arcade#getObjectsAtLocation
     * @param {number} x - The x coordinate to check.
     * @param {number} y - The y coordinate to check.
     * @param {Phaser.Group} group - The Group to check.
     * @param {function} [callback] - A callback function that is called if the object overlaps the coordinates. The callback will be sent two parameters: the callbackArg and the Object that overlapped the location.
     * @param {object} [callbackContext] - The context in which to run the callback.
     * @param {object} [callbackArg] - An argument to pass to the callback.
     * @return {PIXI.DisplayObject[]} An array of the Sprites from the Group that overlapped the coordinates.
     */
    getObjectsAtLocation<T>(x: Float, y: Float, group: arcade.Group, callback?: ((arg1: T, arg2: Body) => Void)?, callbackArg?: T?): Array<Body>;
    /**
     * Move the given display object towards the destination object at a steady velocity.
     * If you specify a maxTime then it will adjust the speed (overwriting what you set) so it arrives at the destination in that number of seconds.
     * Timings are approximate due to the way browser timers work. Allow for a variance of +- 50ms.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     * Note: Doesn't take into account acceleration, maxVelocity or drag (if you've set drag or acceleration too high this object may not move at all)
     *
     * @method Phaser.Physics.Arcade#moveToObject
     * @param {any} displayObject - The display object to move.
     * @param {any} destination - The display object to move towards. Can be any object but must have visible x/y properties.
     * @param {number} [speed=60] - The speed it will move, in pixels per second (default is 60 pixels/sec)
     * @param {number} [maxTime=0] - Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the object will arrive at destination in the given number of ms.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new velocity.
     */
    moveToDestination(body: Body, destination: Body, speed?: Float, maxTime?: Float): Float;
    /**
     * Move the given display object towards the x/y coordinates at a steady velocity.
     * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
     * Timings are approximate due to the way browser timers work. Allow for a variance of +- 50ms.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     * Note: Doesn't take into account acceleration, maxVelocity or drag (if you've set drag or acceleration too high this object may not move at all)
     *
     * @method Phaser.Physics.Arcade#moveToXY
     * @param {any} displayObject - The display object to move.
     * @param {number} x - The x coordinate to move towards.
     * @param {number} y - The y coordinate to move towards.
     * @param {number} [speed=60] - The speed it will move, in pixels per second (default is 60 pixels/sec)
     * @param {number} [maxTime=0] - Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the object will arrive at destination in the given number of ms.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new velocity.
     */
    moveToXY(body: Body, x: Float, y: Float, speed?: Float, maxTime?: Float): Float;
    /**
     * Given the angle (in degrees) and speed calculate the velocity and return it as a Point object, or set it to the given point object.
     * One way to use this is: velocityFromAngle(angle, 200, sprite.velocity) which will set the values directly to the sprites velocity and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#velocityFromAngle
     * @param {number} angle - The angle in degrees calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated velocity.
     * @return {Phaser.Point} - A Point where point.x contains the velocity x value and point.y contains the velocity y value.
     */
    velocityFromAngle(angle: Float, speed?: Float, point?: arcade.Point?): arcade.Point;
    /**
     * Given the rotation (in radians) and speed calculate the velocity and return it as a Point object, or set it to the given point object.
     * One way to use this is: velocityFromRotation(rotation, 200, sprite.velocity) which will set the values directly to the sprites velocity and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#velocityFromRotation
     * @param {number} rotation - The angle in radians.
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated velocity.
     * @return {Phaser.Point} - A Point where point.x contains the velocity x value and point.y contains the velocity y value.
     */
    velocityFromRotation(rotation: Float, speed?: Float, point?: arcade.Point?): arcade.Point;
    /**
     * Given the rotation (in radians) and speed calculate the acceleration and return it as a Point object, or set it to the given point object.
     * One way to use this is: accelerationFromRotation(rotation, 200, sprite.acceleration) which will set the values directly to the sprites acceleration and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#accelerationFromRotation
     * @param {number} rotation - The angle in radians.
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated acceleration.
     * @return {Phaser.Point} - A Point where point.x contains the acceleration x value and point.y contains the acceleration y value.
     */
    accelerationFromRotation(rotation: Float, speed?: Float, point?: arcade.Point?): arcade.Point;
    /**
     * Sets the acceleration.x/y property on the display object so it will move towards the target at the given speed (in pixels per second sq.)
     * You must give a maximum speed value, beyond which the display object won't go any faster.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     *
     * @method Phaser.Physics.Arcade#accelerateToObject
     * @param {any} displayObject - The display object to move.
     * @param {any} destination - The display object to move towards. Can be any object but must have visible x/y properties.
     * @param {number} [speed=60] - The speed it will accelerate in pixels per second.
     * @param {number} [xSpeedMax=1000] - The maximum x velocity the display object can reach.
     * @param {number} [ySpeedMax=1000] - The maximum y velocity the display object can reach.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new trajectory.
     */
    accelerateToDestination(body: Body, destination: Body, speed?: Float, xSpeedMax?: Float, ySpeedMax?: Float): Float;
    /**
     * Sets the acceleration.x/y property on the display object so it will move towards the x/y coordinates at the given speed (in pixels per second sq.)
     * You must give a maximum speed value, beyond which the display object won't go any faster.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     *
     * @method Phaser.Physics.Arcade#accelerateToXY
     * @param {any} displayObject - The display object to move.
     * @param {number} x - The x coordinate to accelerate towards.
     * @param {number} y - The y coordinate to accelerate towards.
     * @param {number} [speed=60] - The speed it will accelerate in pixels per second.
     * @param {number} [xSpeedMax=1000] - The maximum x velocity the display object can reach.
     * @param {number} [ySpeedMax=1000] - The maximum y velocity the display object can reach.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new trajectory.
     */
    accelerateToXY(body: Body, x: Float, y: Float, speed?: Float, xSpeedMax?: Float, ySpeedMax?: Float): Float;
    /**
     * Find the distance between two display objects (like Sprites).
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * If you have nested objects and need to calculate the distance between their centers in World coordinates,
     * set their anchors to (0.5, 0.5) and use the `world` argument.
     *
     * If objects aren't nested or they share a parent's offset, you can calculate the distance between their
     * centers with the `useCenter` argument, regardless of their anchor values.
     *
     * @method Phaser.Physics.Arcade#distanceBetween
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {number} The distance between the source and target objects.
     */
    distanceBetween(source: Body, target: Body, useCenter?: Bool): Float;
    /**
     * Find the distance between a display object (like a Sprite) and the given x/y coordinates.
     * The calculation is made from the display objects x/y coordinate. This may be the top-left if its anchor hasn't been changed.
     * If you need to calculate from the center of a display object instead use {@link #distanceBetween} with the `useCenter` argument.
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#distanceToXY
     * @param {any} displayObject - The Display Object to test from.
     * @param {number} x - The x coordinate to move towards.
     * @param {number} y - The y coordinate to move towards.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The distance between the object and the x/y coordinates.
     */
    distanceToXY(body: Body, x: Float, y: Float): Float;
    /**
     * From a set of points or display objects, find the one closest to a source point or object.
     *
     * @method Phaser.Physics.Arcade#closest
     * @param {any} source - The {@link Phaser.Point Point} or Display Object distances will be measured from.
     * @param {any[]} targets - The {@link Phaser.Point Points} or Display Objects whose distances to the source will be compared.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {any} - The first target closest to the origin.
     */
    closest(source: Body, targets: Array<Body>, world?: Bool, useCenter?: Bool): Body;
    /**
     * From a set of points or display objects, find the one farthest from a source point or object.
     *
     * @method Phaser.Physics.Arcade#farthest
     * @param {any} source - The {@link Phaser.Point Point} or Display Object distances will be measured from.
     * @param {any[]} targets - The {@link Phaser.Point Points} or Display Objects whose distances to the source will be compared.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {any} - The target closest to the origin.
     */
    farthest(source: Body, targets: Array<Body>, useCenter?: Bool): Body;
    /**
     * Find the angle in radians between two display objects (like Sprites).
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#angleBetween
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @param {boolean} [world=false] - Calculate the angle using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The angle in radians between the source and target display objects.
     */
    angleBetween(source: Body, target: Body): Float;
    /**
     * Find the angle in radians between centers of two display objects (like Sprites).
     *
     * @method Phaser.Physics.Arcade#angleBetweenCenters
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @return {number} The angle in radians between the source and target display objects.
     */
    angleBetweenCenters(source: Body, target: Body): Float;
    /**
     * Find the angle in radians between a display object (like a Sprite) and the given x/y coordinate.
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#angleToXY
     * @param {any} displayObject - The Display Object to test from.
     * @param {number} x - The x coordinate to get the angle to.
     * @param {number} y - The y coordinate to get the angle to.
     * @param {boolean} [world=false] - Calculate the angle using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The angle in radians between displayObject.x/y to Pointer.x/y
     */
    angleToXY(body: Body, x: Float, y: Float): Float;
}

/**
 * Any class implementing this interface can be used on World.collide()
 */
interface Collidable {
}

/**
* @author       Richard Davey <rich@photonstorm.com>
* @copyright    2016 Photon Storm Ltd.
* @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
*/
class Body {
    constructor(x: Float, y: Float, width: Float, height: Float, rotation?: Float);
    /** A property to hold any data related to this body. Can be useful if building a system on top if this one. */
    data: Dynamic;
    /** The list of groups that contain this body (can be null if there are no groups). */
    groups: Array<arcade.Group>;
    /** A "main" group associated with this body. */
    group: arcade.Group;
    /**
    * @property {boolean} enable - A disabled body won't be checked for any form of collision or overlap or have its pre/post updates run.
    * @default
    */
    enable: Bool;
    /**
    * If `true` this Body is using circular collision detection. If `false` it is using rectangular.
    * Use `Body.setCircle` to control the collision shape this Body uses.
    * @property {boolean} isCircle
    * @default
    * @readOnly
    */
    isCircle: Bool;
    /**
    * The radius of the circular collision shape this Body is using if Body.setCircle has been enabled, relative to the Sprite's _texture_.
    * If you wish to change the radius then call {@link #setCircle} again with the new value.
    * If you wish to stop the Body using a circle then call {@link #setCircle} with a radius of zero (or undefined).
    * The actual radius of the Body (at any Sprite scale) is equal to {@link #halfWidth} and the diameter is equal to {@link #width}.
    * @property {number} radius
    * @default
    * @readOnly
    */
    radius: Float;
    x: Float;
    y: Float;
    prevX: Float;
    prevY: Float;
    /**
    * @property {boolean} allowRotation - Allow this Body to be rotated? (via angularVelocity, etc)
    * @default
    */
    allowRotation: Bool;
    /**
    * The Body's rotation in degrees, as calculated by its angularVelocity and angularAcceleration. Please understand that the collision Body
    * itself never rotates, it is always axis-aligned. However these values are passed up to the parent Sprite and updates its rotation.
    * @property {number} rotation
    */
    rotation: Float;
    /**
    * @property {number} preRotation - The previous rotation of the physics body, in degrees.
    * @readonly
    */
    preRotation: Float;
    /**
    * @property {number} width - The calculated width of the physics body.
    * @readonly
    */
    width: Float;
    /**
    * @property {number} height - The calculated height of the physics body.
    * @readonly
    */
    height: Float;
    /**
    * @property {number} halfWidth - The calculated width / 2 of the physics body.
    * @readonly
    */
    halfWidth: Float;
    /**
    * @property {number} halfHeight - The calculated height / 2 of the physics body.
    * @readonly
    */
    halfHeight: Float;
    centerX: Float;
    centerY: Float;
    velocityX: Float;
    velocityY: Float;
    /**
    * @property {Phaser.Point} newVelocity - The distanced traveled during the last update, equal to `velocity * physicsElapsed`. Calculated during the Body.preUpdate and applied to its position.
    * @readonly
    */
    newVelocityX: Float;
    newVelocityY: Float;
    maxDeltaX: Float;
    maxDeltaY: Float;
    accelerationX: Float;
    accelerationY: Float;
    /**
     * @property {boolean} allowDrag - Allow this Body to be influenced by {@link #drag}?
     * @default
     */
    allowDrag: Bool;
    dragX: Float;
    dragY: Float;
    /**
    * @property {boolean} allowGravity - Allow this Body to be influenced by gravity? Either world or local.
    * @default
    */
    allowGravity: Bool;
    gravityX: Float;
    gravityY: Float;
    bounceX: Float;
    bounceY: Float;
    /**
    * The elasticity of the Body when colliding with the World bounds.
    * By default this property is `null`, in which case `Body.bounce` is used instead. Set this property
    * to a Phaser.Point object in order to enable a World bounds specific bounce value.
    * @property {Phaser.Point} useWorldBounce
    */
    useWorldBounce: Bool;
    worldBounceX: Float;
    worldBounceY: Float;
    /**
    * A Signal that is dispatched when this Body collides with the world bounds.
    * Due to the potentially high volume of signals this could create it is disabled by default.
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onWorldBounds = new Phaser.Signal()`
    * and it will be called when a collision happens, passing five arguments:
    * `onWorldBounds(sprite, up, down, left, right)`
    * where the Sprite is a reference to the Sprite that owns this Body, and the other arguments are booleans
    * indicating on which side of the world the Body collided.
    * @property {Phaser.Signal} onWorldBounds
    */
    onWorldBounds: ((arg1: Body, arg2: Bool, arg3: Bool, arg4: Bool, arg5: Bool) => Void);
    /**
    * A Signal that is dispatched when this Body collides with another Body.
    *
    * You still need to call `game.physics.arcade.collide` in your `update` method in order
    * for this signal to be dispatched.
    *
    * Usually you'd pass a callback to the `collide` method, but this signal provides for
    * a different level of notification.
    *
    * Due to the potentially high volume of signals this could create it is disabled by default.
    *
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onCollide = new Phaser.Signal()`
    * and it will be called when a collision happens, passing two arguments: the sprites which collided.
    * The first sprite in the argument is always the owner of this Body.
    *
    * If two Bodies with this Signal set collide, both will dispatch the Signal.
    * @property {Phaser.Signal} onCollide
    */
    onCollide: ((arg1: Body, arg2: Body) => Void);
    /**
    * A Signal that is dispatched when this Body overlaps with another Body.
    *
    * You still need to call `game.physics.arcade.overlap` in your `update` method in order
    * for this signal to be dispatched.
    *
    * Usually you'd pass a callback to the `overlap` method, but this signal provides for
    * a different level of notification.
    *
    * Due to the potentially high volume of signals this could create it is disabled by default.
    *
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onOverlap = new Phaser.Signal()`
    * and it will be called when a collision happens, passing two arguments: the sprites which collided.
    * The first sprite in the argument is always the owner of this Body.
    *
    * If two Bodies with this Signal set collide, both will dispatch the Signal.
    * @property {Phaser.Signal} onOverlap
    */
    onOverlap: ((arg1: Body, arg2: Body) => Void);
    maxVelocityX: Float;
    maxVelocityY: Float;
    frictionX: Float;
    frictionY: Float;
    /**
    * @property {number} angularVelocity - The angular velocity is the rate of change of the Body's rotation. It is measured in degrees per second.
    * @default
    */
    angularVelocity: Float;
    /**
    * @property {number} angularAcceleration - The angular acceleration is the rate of change of the angular velocity. Measured in degrees per second squared.
    * @default
    */
    angularAcceleration: Float;
    /**
    * @property {number} angularDrag - The drag applied during the rotation of the Body. Measured in degrees per second squared.
    * @default
    */
    angularDrag: Float;
    /**
    * @property {number} maxAngularVelocity - The maximum angular velocity in degrees per second that the Body can reach.
    * @default
    */
    maxAngularVelocity: Float;
    /**
    * @property {number} mass - The mass of the Body. When two bodies collide their mass is used in the calculation to determine the exchange of velocity.
    * @default
    */
    mass: Float;
    /**
    * @property {number} angle - The angle of the Body's **velocity** in radians.
    * @readonly
    */
    angle: Float;
    /**
    * @property {number} speed - The speed of the Body in pixels per second, equal to the magnitude of the velocity.
    * @readonly
    */
    speed: Float;
    /**
    * @property {number} facing - A const reference to the direction the Body is traveling or facing: Phaser.NONE, Phaser.LEFT, Phaser.RIGHT, Phaser.UP, or Phaser.DOWN. If the Body is moving on both axes, UP and DOWN take precedence.
    * @default
    */
    facing: arcade.Direction;
    /**
    * @property {boolean} immovable - An immovable Body will not receive any impacts from other bodies. **Two** immovable Bodies can't separate or exchange momentum and will pass through each other.
    * @default
    */
    immovable: Bool;
    /**
    * Whether the physics system should update the Body's position and rotation based on its velocity, acceleration, drag, and gravity.
    *
    * If you have a Body that is being moved around the world via a tween or a Group motion, but its local x/y position never
    * actually changes, then you should set Body.moves = false. Otherwise it will most likely fly off the screen.
    * If you want the physics system to move the body around, then set moves to true.
    *
    * A Body with moves = false can still be moved slightly (but not accelerated) during collision separation unless you set {@link #immovable} as well.
    *
    * @property {boolean} moves - Set to true to allow the Physics system to move this Body, otherwise false to move it manually.
    * @default
    */
    moves: Bool;
    /**
    * This flag allows you to disable the custom x separation that takes place by Physics.Arcade.separate.
    * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
    * @property {boolean} customSeparateX - Use a custom separation system or the built-in one?
    * @default
    */
    customSeparateX: Bool;
    /**
    * This flag allows you to disable the custom y separation that takes place by Physics.Arcade.separate.
    * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
    * @property {boolean} customSeparateY - Use a custom separation system or the built-in one?
    * @default
    */
    customSeparateY: Bool;
    /**
    * When this body collides with another, the amount of overlap is stored here.
    * @property {number} overlapX - The amount of horizontal overlap during the collision.
    */
    overlapX: Float;
    /**
    * When this body collides with another, the amount of overlap is stored here.
    * @property {number} overlapY - The amount of vertical overlap during the collision.
    */
    overlapY: Float;
    /**
    * If `Body.isCircle` is true, and this body collides with another circular body, the amount of overlap is stored here.
    * @property {number} overlapR - The amount of overlap during the collision.
    */
    overlapR: Float;
    /**
    * If a body is overlapping with another body, but neither of them are moving (maybe they spawned on-top of each other?) this is set to true.
    * @property {boolean} embedded - Body embed value.
    */
    embedded: Bool;
    /**
    * A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
    * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
    */
    collideWorldBounds: Bool;
    checkCollisionNone: Bool;
    checkCollisionUp: Bool;
    checkCollisionDown: Bool;
    checkCollisionLeft: Bool;
    checkCollisionRight: Bool;
    touchingNone: Bool;
    touchingUp: Bool;
    touchingDown: Bool;
    touchingLeft: Bool;
    touchingRight: Bool;
    wasTouchingNone: Bool;
    wasTouchingUp: Bool;
    wasTouchingDown: Bool;
    wasTouchingLeft: Bool;
    wasTouchingRight: Bool;
    /**
    * @property {boolean} blockedNone - If this Body being blocked by world bounds or another immovable object?
    */
    blockedNone: Bool;
    /**
    * @property {boolean} blockedNone - If this Body being blocked by upper world bounds or another immovable object above it?
    */
    blockedUp: Bool;
    /**
    * @property {boolean} blockedNone - If this Body being blocked by lower world bounds or another immovable object below it?
    */
    blockedDown: Bool;
    /**
    * @property {boolean} blockedNone - If this Body being blocked by left world bounds or another immovable object on the left?
    */
    blockedLeft: Bool;
    /**
    * @property {boolean} blockedNone - If this Body being blocked by right world bounds or another immovable object on the right?
    */
    blockedRight: Bool;
    /**
    * @property {boolean} dirty - If this Body in a preUpdate (true) or postUpdate (false) state?
    */
    dirty: Bool;
    /**
    * @property {boolean} skipQuadTree - If true and you collide this Sprite against a Group, it will disable the collision check from using a QuadTree.
    */
    skipQuadTree: Bool;
    /**
    * @property {boolean} isMoving - Set by the `moveTo` and `moveFrom` methods.
    */
    isMoving: Bool;
    /**
    * @property {boolean} stopVelocityOnCollide - Set by the `moveTo` and `moveFrom` methods.
    */
    stopVelocityOnCollide: Bool;
    /**
    * @property {Phaser.Signal} onMoveComplete - Listen for the completion of `moveTo` or `moveFrom` events.
    */
    onMoveComplete: ((arg1: Body, arg2: Bool) => Void);
    /**
    * @property {function} movementCallback - Optional callback. If set, invoked during the running of `moveTo` or `moveFrom` events.
    */
    movementCallback: ((arg1: Body, arg2: Float, arg3: Float, arg4: Float) => Bool);
    updateHalfSize(): Void;
    /**
    * Update the Body's center from its position.
    *
    * @method Phaser.Physics.Arcade.Body#updateCenter
    * @protected
    */
    updateCenter(): Void;
    updateSize(width: Float, height: Float): Void;
    /**
    * If this Body is moving as a result of a call to `moveTo` or `moveFrom` (i.e. it
    * has Body.isMoving true), then calling this method will stop the movement before
    * either the duration or distance counters expire.
    *
    * The `onMoveComplete` signal is dispatched.
    *
    * @method Phaser.Physics.Arcade.Body#stopMovement
    * @param {boolean} [stopVelocity] - Should the Body.velocity be set to zero?
    */
    stopMovement(stopVelocity: Bool): Void;
    dx: Float;
    dy: Float;
    /**
    * Note: This method is experimental, and may be changed or removed in a future release.
    *
    * This method moves the Body in the given direction, for the duration specified.
    * It works by setting the velocity on the Body, and an internal timer, and then
    * monitoring the duration each frame. When the duration is up the movement is
    * stopped and the `Body.onMoveComplete` signal is dispatched.
    *
    * Movement also stops if the Body collides or overlaps with any other Body.
    *
    * You can control if the velocity should be reset to zero on collision, by using
    * the property `Body.stopVelocityOnCollide`.
    *
    * Stop the movement at any time by calling `Body.stopMovement`.
    *
    * You can optionally set a speed in pixels per second. If not specified it
    * will use the current `Body.speed` value. If this is zero, the function will return false.
    *
    * Please note that due to browser timings you should allow for a variance in
    * when the duration will actually expire. Depending on system it may be as much as
    * +- 50ms. Also this method doesn't take into consideration any other forces acting
    * on the Body, such as Gravity, drag or maxVelocity, all of which may impact the
    * movement.
    *
    * @method Phaser.Physics.Arcade.Body#moveFrom
    * @param  {number} duration  - The duration of the movement, in seconds.
    * @param  {number} [speed] - The speed of the movement, in pixels per second. If not provided `Body.speed` is used.
    * @param  {number} [direction] - The angle of movement in degrees. If not provided `Body.angle` is used.
    * @return {boolean} True if the movement successfully started, otherwise false.
    */
    moveFrom(duration: Float, speed?: Float, direction?: Float): Bool;
    /**
    * Note: This method is experimental, and may be changed or removed in a future release.
    *
    * This method moves the Body in the given direction, for the duration specified.
    * It works by setting the velocity on the Body, and an internal distance counter.
    * The distance is monitored each frame. When the distance equals the distance
    * specified in this call, the movement is stopped, and the `Body.onMoveComplete`
    * signal is dispatched.
    *
    * Movement also stops if the Body collides or overlaps with any other Body.
    *
    * You can control if the velocity should be reset to zero on collision, by using
    * the property `Body.stopVelocityOnCollide`.
    *
    * Stop the movement at any time by calling `Body.stopMovement`.
    *
    * Please note that due to browser timings you should allow for a variance in
    * when the distance will actually expire.
    *
    * Note: This method doesn't take into consideration any other forces acting
    * on the Body, such as Gravity, drag or maxVelocity, all of which may impact the
    * movement.
    *
    * @method Phaser.Physics.Arcade.Body#moveTo
    * @param  {float} duration - The duration of the movement, in seconds.
    * @param  {float} distance - The distance, in pixels, the Body will move.
    * @param  {float} [direction] - The angle of movement. If not provided `Body.angle` is used.
    * @return {boolean} True if the movement successfully started, otherwise false.
    */
    moveTo(duration: Float, distance: Float, direction?: Float): Bool;
    /**
    * Sets this Body as using a circle, of the given radius, for all collision detection instead of a rectangle.
    * The radius is given in pixels (relative to the Sprite's _texture_) and is the distance from the center of the circle to the edge.
    *
    * You can also control the x and y offset, which is the position of the Body relative to the top-left of the Sprite's texture.
    *
    * To change a Body back to being rectangular again call `Body.setSize`.
    *
    * Note: Circular collision only happens with other Arcade Physics bodies, it does not
    * work against tile maps, where rectangular collision is the only method supported.
    *
    * @method Phaser.Physics.Arcade.Body#setCircle
    * @param {number} [radius] - The radius of the Body in pixels. Pass a value of zero / undefined, to stop the Body using a circle for collision.
    */
    setCircle(radius: Float): Void;
    /**
    * Resets all Body values (velocity, acceleration, rotation, etc)
    *
    * @method Phaser.Physics.Arcade.Body#reset
    * @param {number} x - The new x position of the Body.
    * @param {number} y - The new y position of the Body.
    */
    reset(x: Float, y: Float, width: Float, height: Float, rotation?: Float): Void;
    /**
     * Sets acceleration, velocity, and {@link #speed} to 0.
     *
     * @method Phaser.Physics.Arcade.Body#stop
     */
    stop(): Void;
    /**
    * Tests if a world point lies within this Body.
    *
    * @method Phaser.Physics.Arcade.Body#hitTest
    * @param {number} x - The world x coordinate to test.
    * @param {number} y - The world y coordinate to test.
    * @return {boolean} True if the given coordinates are inside this Body, otherwise false.
    */
    hitTest(x: Float, y: Float): Bool;
    /**
    * Returns true if the bottom of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onFloor
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    isOnFloor(): Bool;
    /**
    * Returns true if the top of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onCeiling
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    isOnCeiling(): Bool;
    /**
    * Returns true if either side of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onWall
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    isOnWall(): Bool;
    /**
    * Returns the absolute delta x value.
    *
    * @method Phaser.Physics.Arcade.Body#deltaAbsX
    * @return {number} The absolute delta value.
    */
    deltaAbsX(): Float;
    /**
    * Returns the absolute delta y value.
    *
    * @method Phaser.Physics.Arcade.Body#deltaAbsY
    * @return {number} The absolute delta value.
    */
    deltaAbsY(): Float;
    /**
    * Returns the delta x value. The difference between Body.x now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaX
    * @return {number} The delta value. Positive if the motion was to the right, negative if to the left.
    */
    deltaX(): Float;
    /**
    * Returns the delta y value. The difference between Body.y now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaY
    * @return {number} The delta value. Positive if the motion was downwards, negative if upwards.
    */
    deltaY(): Float;
    /**
    * Returns the delta z value. The difference between Body.rotation now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaZ
    * @return {number} The delta value. Positive if the motion was clockwise, negative if anti-clockwise.
    */
    deltaZ(): Float;
    /**
    * Destroys this Body.
    *
    * First it calls Group.removeFromHash if the Game Object this Body belongs to is part of a Group.
    * Then it nulls the Game Objects body reference, and nulls this Body.sprite reference.
    *
    * @method Phaser.Physics.Arcade.Body#destroy
    */
    destroy(): Void;
    setVelocityToPolar(azimuth: Float, radius?: Float, asDegrees?: Bool): Void;
    setAccelerationToPolar(azimuth: Float, radius?: Float, asDegrees?: Bool): Void;
    left: Float;
    top: Float;
    right: Float;
    bottom: Float;
}

/**
	The Haxe Reflection API allows retrieval of type information at runtime.

	This class complements the more lightweight Reflect class, with a focus on
	class and enum instances.

	@see https://haxe.org/manual/types.html
	@see https://haxe.org/manual/std-reflection.html
*/
class Type {
    /**
		Creates an instance of class `cl`, using `args` as arguments to the
		class constructor.

		This function guarantees that the class constructor is called.

		Default values of constructors arguments are not guaranteed to be
		taken into account.

		If `cl` or `args` are null, or if the number of elements in `args` does
		not match the expected number of constructor arguments, or if any
		argument has an invalid type,  or if `cl` has no own constructor, the
		result is unspecified.

		In particular, default values of constructor arguments are not
		guaranteed to be taken into account.
	*/
    static createInstance<T>(cl: Class<T>, args: Array<Dynamic>): T;
    /**
		Creates an instance of enum `e` by calling its constructor `constr` with
		arguments `params`.

		If `e` or `constr` is null, or if enum `e` has no constructor named
		`constr`, or if the number of elements in `params` does not match the
		expected number of constructor arguments, or if any argument has an
		invalid type, the result is unspecified.
	*/
    static createEnum<T>(e: Enum<T>, constr: String, params?: Array<Dynamic>?): T;
    /**
		Returns a list of the instance fields of class `c`, including
		inherited fields.

		This only includes fields which are known at compile-time. In
		particular, using `getInstanceFields(getClass(obj))` will not include
		any fields which were added to `obj` at runtime.

		The order of the fields in the returned Array is unspecified.

		If `c` is null, the result is unspecified.
	*/
    static getInstanceFields(c: Class<Dynamic>): Array<String>;
    /**
		Returns the runtime type of value `v`.

		The result corresponds to the type `v` has at runtime, which may vary
		per platform. Assumptions regarding this should be minimized to avoid
		surprises.
	*/
    static typeof(v: Dynamic): ValueType;
    /**
		Recursively compares two enum instances `a` and `b` by value.

		Unlike `a == b`, this function performs a deep equality check on the
		arguments of the constructors, if exists.

		If `a` or `b` are null, the result is unspecified.
	*/
    static enumEq<T>(a: T, b: T): Bool;
    /**
		Returns a list of the constructor arguments of enum instance `e`.

		If `e` has no arguments, the result is [].

		Otherwise the result are the values that were used as arguments to `e`,
		in the order of their declaration.

		If `e` is null, the result is unspecified.
	*/
    static enumParameters(e: EnumValue): Array<Dynamic>;
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
    iterator(): haxe.iterators.ArrayIterator<T>;
}

