console.log("play-fullscreen-canvas")

main = ->
  console.log("main()")
  setup_canvases()
  wait_page_load( 3000, start_play )
  console.log("main")

# to prevent animation lag
#   during page load time,
#   this function waits until
#   there were enough consecutive frames
#   which met their time
#   or until a timeout.
wait_page_load = (time_out, cb) ->
  last_time = 0
  diff_time = 0
  good_time = 0 # :)
  wait_time = 500
  func = (now_time) ->
    diff_time = now_time - last_time
    last_time = now_time
    time_out  = time_out - diff_time
    if diff_time < wait_time
      good_time = good_time + diff_time
    else
      good_time = 0
    if good_time > wait_time or time_out < 0
      console.log time_out
      cb()
    else
      requestAnimationFrame(func)
  requestAnimationFrame(func)

setup_canvases = ->
  console.log("setup_canvases()")
  gamediv = document.querySelector( "#gamediv" )
  width   = gamediv.clientWidth
  height  = gamediv.clientHeight

  for i in [0..3]
    canvas = create_some_canvas( "canvas_"+i, width, height )
    attach_some_canvas( canvas, gamediv )

  canvases = document.querySelectorAll( "#gamediv canvas" )
  console.log( "setup_canvases", canvases )

start_play = ->
  requestAnimationFrame ->
    canvases = document.querySelectorAll( "#gamediv canvas" )
    for canvas in canvases
      canvas.my.raf()

canvas_colors = ["#ff9", "#f9f", "#9ff", "#ffc", "#fcf", "#cff"]

create_some_canvas = (id, width, height) ->
  color         = canvas_colors.pop() || "red"
  canvas        = document.createElement( "canvas" )
  canvas.width  = width
  canvas.height = height
  canvas.setAttribute( "id", id )
  canvas.my     = {}
  ctx           = canvas.getContext( "2d" )
  canvas.my.raf = ->
    ctx.clearRect( 0, 0, canvas.width, canvas.height )
    ctx.fillStyle = color
    ctx.beginPath()
    ctx_some_rects( ctx )
    ctx.closePath()
    ctx.fill()
    requestAnimationFrame( canvas.my.raf )
  canvas

attach_some_canvas = (canvas, parent) ->
  parent.appendChild( canvas )
  canvas.my.onresize = ->
    canvas.width = canvas.clientWidth
    canvas.height = canvas.clientHeight
  window.addEventListener "resize-throttled", canvas.my.onresize



# https://developer.mozilla.org/en-US/docs/Web/Events/resize#requestAnimationFrame_customEvent
add_throttled_event_source = ( obj, event ) ->
  name = event+"-throttled"
  running = false
  func = ->
    return if running
    running = true
    requestAnimationFrame ->
      obj.dispatchEvent( new CustomEvent( name ) )
      running = false
  obj.addEventListener( event, func, { "passive" } )
  name

resize_throttled = add_throttled_event_source( window, "resize" )


ctx_some_rects = ( ctx ) ->
  r = Math.random
  w = ctx.canvas.width
  h = ctx.canvas.height
  for i in [0...100]
    size_x = 20
    size_y = 20
    x = r() * (w-size_x)
    y = r() * (h-size_y)
    ctx.rect( x, y, size_x, size_y )

main()
