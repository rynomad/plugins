window.plugins.calculator =
  emit: (div, item) ->
    item.data = (field for field of wiki.getData())
    wiki.log 'calculator', item
    fetch(div, item)
    
  bind: (div, item) ->
    div.dblclick -> wiki.textEditor div, item

fetch = (div, names) ->
  face = new Face({host: "66.185.108.210"})
  for line in names.text.split "\n"
    name = new Name(line)
    onData = (interest, data) ->
      pre = $('<pre style="font-size: 16px;"/>').text "data recieved!" + interest.name.toUri()
      div.append pre
    face.expressInterest(name, onData)

