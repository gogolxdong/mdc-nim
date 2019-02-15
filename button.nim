import karax / [karax, karaxdsl,vdom, vstyles]
import dom
import math
import jsffi, tables
from sugar import `=>`
import mdcRippleFoundation


proc login(e:Event, n: VNode) = 
    echo n.dom.nodeName

proc createDom(): VNode = 
    buildHtml tdiv(style={width:"100px",height:"100px",margin:"auto",padding:"50px"}):
            button(class="mdc-button mdc-button--raised", onclick = login, onmousedown = addRipple, onblur = blurHandler, onfocus = focusHandler):
                span(class = "mdc-button__label"):text "LOG IN"
                
setRenderer createDom