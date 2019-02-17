import karax / [karax, karaxdsl,vdom, vstyles,kbase]
import dom
import math
import jsffi, tables
from sugar import `=>`
import mdcRippleFoundation


proc login(e:Event, n: VNode) = 
    echo n.dom.nodeName

proc loginButton():VNode = 
    buildHtml button(class="mdc-button mdc-button--raised", onmousedown = ripple, onblur = blurHandler, onfocus = focusHandler, onclick = login):
        span(class = "mdc-button__label"):text "LOG IN"

type
  State = ref object
    originalTitle: cstring
    url: Location

proc copyLocation(loc: Location): Location =
  Location(
    hash: loc.hash,
    host: loc.host,
    hostname: loc.hostname,
    href: loc.href,
    pathname: loc.pathname,
    port: loc.port,
    protocol: loc.protocol,
    search: loc.search
  )

proc newState(): State =
  State(
    originalTitle: document.title,
    url: copyLocation(window.location),
  )

var state = newState()

proc createDom(): VNode = 
    buildHtml tdiv(class = "login"):
        loginButton()

proc onPopState(event: Event) =
  document.title = state.originalTitle
  if state.url.href != window.location.href:
    state = newState() 
  state.url = copyLocation(window.location)

window.onpopstate = onpopstate              
setRenderer createDom