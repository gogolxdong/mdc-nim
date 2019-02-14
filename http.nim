import jester, os, asyncdispatch

settings:
    port = Port(8080)
    staticDir = getCurrentDir()

routes:
    get "/":
        redirect(uri("button.html"))
        