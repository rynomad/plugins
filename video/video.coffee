escape = (str) ->
	String(str)
		.replace(/&/g, '&amp')
		.replace(/"/g, '&quot')
		.replace(/'/g, '&#39')
		.replace(/</g, '&lt')
		.replace(/>/g, '&gt')
$('<style type="text/css"></style>')
  .html('@import url("/plugins/video/video.css")')
  .appendTo("head");
   
face = new Face({host: '66.185.108.210'})
onInterest = (prefix, interest, transport) ->
  dataURL = "data:image/webp;base64," + interest.name.components[interest.name.components.length - 1].toEscapedString()
  console.log dataURL
  canvas = document.getElementById("output")
  ctx = canvas.getContext("2d")
  img = new Image()
  img.onload = -> 
    ctx.drawImage(img, 0,0,canvas.width ,canvas.height)
  img.src = dataURL

(->
  i = 0
  lastTime = 0
  vendors = ["ms", "moz", "webkit", "o"]
  while i < vendors.length and not window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[i] + "RequestAnimationFrame"]
    i++
  unless window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max(0, 1000 / 60 - currTime + lastTime)
      id = setTimeout(->
        callback currTime + timeToCall
      , timeToCall)
      lastTime = currTime + timeToCall
      id
)()
App =
  start: (stream) ->
    App.video.addEventListener "canplay", (->
      App.video.removeEventListener "canplay"
      setTimeout (->
        App.video.play()
        App.canvas.width = $(".story").width()
        App.canvas.height = $(".story").width() *.75
        App.backCanvas.width = App.video.videoWidth / 4
        App.backCanvas.height = App.video.videoHeight / 4
        App.backContext = App.backCanvas.getContext("2d")
        w = 300 / 4 * 0.8
        h = 270 / 4 * 0.8
        App.comp = [
          x: (App.video.videoWidth / 4 - w) / 2
          y: (App.video.videoHeight / 4 - h) / 2
          width: w
          height: h
        ]
        App.drawToCanvas()
      ), 500
    ), true
    domURL = window.URL or window.webkitURL
    App.video.src = (if domURL then domURL.createObjectURL(stream) else stream)

  denied: ->
    App.info.innerHTML = "Camera access denied!<br>Please reload and try again."

  error: (e) ->
    console.error e  if e
    App.info.innerHTML = "Please go to about:flags in Google Chrome and enable the &quot;MediaStream&quot; flag."

  drawToCanvas: ->
    video = App.video
    ctx = App.context
    backCtx = App.backContext
    m = 4
    w = 4
    i = undefined
    comp = undefined
    ctx.drawImage video, 0, 0, App.canvas.width, App.canvas.height
    frames = document.getElementById("output").toDataURL("image/webp", 0.05)
    frame = frames.split(",")[1]
    name = (new Name("push/MIME/image/webp")).append(new Name.Component(frame))
    face.expressInterest name, null, null  if face.readyStatus is 1
    requestAnimationFrame App.drawToCanvas

App.init = ->
  App.video = document.createElement("video")
  App.backCanvas = document.createElement("canvas")
  App.canvas = document.getElementById("output")
  App.context = App.canvas.getContext("2d")
  App.info = document.querySelector("#info")
  navigator.getUserMedia_ = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia
  try
    navigator.getUserMedia_
      video: true
      audio: false
    , App.start, App.denied
  catch e
    try
      navigator.getUserMedia_ "video", App.start, App.denied
    catch e
      App.error e
  App.video.loop = App.video.muted = true
  App.video.load()
  App.video.onloadedmetadata = (e) ->
    console.log e # Ready to go. Do some stuff.

  face.registerPrefix new Name("/MIME/image/webp/something"), null


class window.plugins.video
  load = (callback) ->
  
  @emit: (div, item) ->
    width = $(".story").width()
    div.append "<canvas id='output' width='#{width}' height='#{width * .75}'></canvas>"
    console.log loggedInUser
    callback = () ->
      face.registerPrefix new Name('push/MIME/image/webp'), onInterest
    if div.parent().parent().hasClass('remote')
      setTimeout(callback, 1000)
    else if div.parent().parent().hasClass('local')
      console.log div.parent().parent()
      App.init()
    else if loggedInUser
      App.init()
    else 
      setTimeout(callback, 1000) 
    
      
  @bind: (div, item) ->
    load -> div.dblclick -> wiki.textEditor div, item

