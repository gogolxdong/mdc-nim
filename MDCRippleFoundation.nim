import karax / [karax, karaxdsl,vdom, vstyles]
import dom
import math
import jsffi, tables
from sugar import `=>`

type MDCFoundation {.importc.} = object

var mdc = MDCFoundation()
echo get(mdc,"cssClasses")

type
    MDCRippleFoundation = object
        cssClasses : Table[string, string]
        strings: Table[string,string]
        numbers: Table[string, float]

var mdcRipple* = MDCRippleFoundation()
mdcRipple.cssClasses = {
    "ROOT": "mdc-ripple-upgraded",
    "UNBOUNDED": "mdc-ripple-upgraded--unbounded",
    "BG_FOCUSED": "mdc-ripple-upgraded--background-focused",
    "FG_ACTIVATION": "mdc-ripple-upgraded--foreground-activation",
    "FG_DEACTIVATION": "mdc-ripple-upgraded--foreground-deactivation"}.toTable

mdcRipple.strings = {
    "VAR_LEFT": "--mdc-ripple-left",
    "VAR_TOP": "--mdc-ripple-top",
    "VAR_FG_SIZE": "--mdc-ripple-fg-size",
    "VAR_FG_SCALE": "--mdc-ripple-fg-scale",
    "VAR_FG_TRANSLATE_START": "--mdc-ripple-fg-translate-start",
    "VAR_FG_TRANSLATE_END": "--mdc-ripple-fg-translate-end"}.toTable

mdcRipple.numbers = {
    "PADDING": 10.0,
    "INITIAL_ORIGIN_SCALE": 0.6,
    "DEACTIVATION_TIMEOUT_MS": 225.0,
    "FG_DEACTIVATION_MS": 150.0,
    "TAP_DELAY_MS": 300.0 }.toTable

var activationAnimationHasEnded : bool
var fgDeactivationRemovalTimer: Timeout
var activationTimer: Timeout

proc rmBoundedActivationClasses(element: Element) =
    element.classList.remove mdcRipple.cssClasses["FG_ACTIVATION"]

proc activationTimerCallback(element: Element) = 
    activationAnimationHasEnded = true
    if activationAnimationHasEnded:
        rmBoundedActivationClasses(element)
        element.classList.add mdcRipple.cssClasses["FG_DEACTIVATION"]
        fgDeactivationRemovalTimer = 
            setTimeout(() => element.classList.add(mdcRipple.cssClasses["FG_DEACTIVATION"]), mdcRipple.numbers["FG_DEACTIVATION_MS"].int)

proc addRipple*(e:Event, n: VNode) = 
    var mouseEvent = cast[MouseEvent](e)
    var element = cast[Element](n.dom)
    element.classList.add mdcRipple.cssClasses["ROOT"]
    var frame = n.dom.getBoundingClientRect()
    var maxDim = max(frame.width, frame.height)
    var initialSize = floor(maxDim * mdcRipple.numbers["INITIAL_ORIGIN_SCALE"])
    n.dom.style.setProperty(mdcRipple.strings["VAR_FG_SIZE"], $initialSize & "px")

    var hypotenuse = sqrt(frame.width.pow(2) + frame.height.pow(2))
    var fgScale = hypotenuse / initialSize
    n.dom.style.setProperty(mdcRipple.strings["VAR_FG_SCALE"], $fgScale)

    var top = mouseEvent.pageY.float - frame.top - n.dom.offsetHeight / 2 - document.body.scrollTop.float
    var left = mouseEvent.pageX.float - frame.left - n.dom.offsetWidth / 2 - document.body.scrollLeft.float

    n.dom.style.setProperty(mdcRipple.strings["VAR_TOP"], $top)
    n.dom.style.setProperty(mdcRipple.strings["VAR_LEFT"], $left)

    var translateStart =  $(mouseEvent.pageX.float - frame.left - window.pageXOffset.float - initialSize / 2) & "px, " & 
        $(mouseEvent.pageY.float - frame.top - window.pageYOffset.float - initialSize / 2) & "px"
    var translateEnd = $(frame.width / 2 - initialSize / 2) & "px, " & $(frame.height / 2 - initialSize / 2) & "px"
    n.dom.style.setProperty(mdcRipple.strings["VAR_FG_TRANSLATE_START"], translateStart)
    n.dom.style.setProperty(mdcRipple.strings["VAR_FG_TRANSLATE_END"], translateEnd)
    clearTimeout activationTimer
    clearTimeout fgDeactivationRemovalTimer
    rmBoundedActivationClasses(element)
    element.classList.remove mdcRipple.cssClasses["FG_DEACTIVATION"]
    element.classList.add mdcRipple.cssClasses["FG_ACTIVATION"]
    activationTimer = setTimeout(() => activationTimerCallback(element), mdcRipple.numbers["DEACTIVATION_TIMEOUT_MS"].int)

proc blurHandler*(e: Event, n:VNode) = 
    cast[Element](n.dom).classList.remove mdcRipple.cssClasses["BG_FOCUSED"]

proc focusHandler*(e:Event, n:VNode) = 
    cast[Element](n.dom).classList.add mdcRipple.cssClasses["BG_FOCUSED"]