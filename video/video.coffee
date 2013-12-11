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
  
onInterest = (prefix, interest, transport) ->
  dataURL = "data:image/webp;base64," + interest.name.components[interest.name.components.length - 1].toEscapedString()
  console.log dataURL
  canvas = document.getElementById("output" + interest.name.components[interest.name.components.length - 2].toEscapedString())
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
      frames = document.getElementById("output" + App.hash).toDataURL("image/webp", 0.05)
      frame = frames.split(",")[1]
      uri = "push/MIME/image/webp/" + App.hash
      console.log uri
      name = (new Name(uri)).append(new Name.Component(frame))
      faces[App.hash].expressInterest name, null, null  if faces[App.hash].readyStatus is 1
      requestAnimationFrame App.drawToCanvas

  App.init = () ->
    faces[App.hash] = new Face({host: "66.185.108.210"})
    App.video = document.createElement("video")
    App.backCanvas = document.createElement("canvas")
    App.canvas = document.getElementById("output" + App.hash)
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

    faces[App.hash].registerPrefix new Name("/MIME/image/webp/something"), null


class window.plugins.video
  @emit: (div, item) ->
    faces["local"] = new Face({host: '66.185.108.210'})
    width = $(".story").width()
    callback = (hash) ->
      faces["local"].registerPrefix new Name('push/MIME/image/webp/' + hash), onInterest
    if div.parent().parent().hasClass('remote')
      hasher = () ->
        hash = div.parent().parent().children()[1].children[0].title
        console.log App.hash
        div.append("<canvas id='output" + hash + "' width='#{width}' height='#{width * .75}'></canvas>")
        faces["local"].registerPrefix new Name('push/MIME/image/webp/' + hash), onInterest
      setTimeout(hasher, 1000)
    else if div.parent().parent().hasClass('local')
      hasher = () ->
        console.log('hasher')
        App.hash = div.parent().parent().children()[1].children[0].title
        console.log App.hash
        div.append("<canvas id='output" + App.hash + "' width='#{width}' height='#{width * .75}'></canvas>")
        App.init()
      setTimeout(hasher, 1000)
    else if loggedInUser
      App.hash = location.host.split(':')[0]
      div.append("<canvas id='output" + App.hash + "' width='#{width}' height='#{width * .75}'></canvas>")
      App.init()
    else 
      hash = location.host.split(':')[0]
      div.append("<canvas id='output" + hash + "' width='#{width}' height='#{width * .75}'></canvas>")
      setTimeout(callback, 1000, hash) 
    
      
  @bind: (div, item) ->
    div.dblclick -> wiki.textEditor div, item

