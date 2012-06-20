$ () ->
  pane = $('#pane')
  control = $('#control')
  addItem = ()->
    control.find('a').off('click', addItem)
    type = $(this).attr 'id'
    pane.css({cursor: 'crosshair'})
    pane.on('click', (ev) ->
      pane.off('click')
      pane.css({cursor: ''})
      switch type
        when 'addServer'
          elm = new Server()
        when 'addFluentd'
          elm = new Fluentd()
        when 'addMatch'
          elm = new Match()
        when 'addSource'
          elm = new Source()
        else
          elm = new Item()
      elm.render(pane, {x: ev.clientX, y: ev.clientY})
      control.find('a').on('click', addItem)
      return 
      )
    return
  control.find('a').on('click', addItem)

  $('.modal .btn-primary').on('click', ()->
    console.log $($('div.new').data('obj'))
    )
  
  return

############################################################
# 
# 
class Item
  constructor: ()->
  render: (target, pos)->
    @el = $(@html)
    @el.data('obj', this)
    @bindEvent @el
    @el.addClass 'item new'
    @el.css
      left: pos.x
      top: pos.y
    $(target).append @el
    @popupSettings()

  popupSettings: ()->
    $('#edit_'+@name).modal()
  bindEvent: ()->
    for event of @events or {}
      @el.on event, @events[event]
    
class Server extends Item
  constructor: ()->
    @name = 'server'
    @html = '<div class="server">Server</div>'
class Match extends Item
  constructor: ()->
    @name = 'match'
    @html = '<div class="match">Match</div>'
    @events =
      click: ()->
        alert(1)
      saveEdit: ()->
        alert(1)
      
class Source extends Item
  constructor: ()->
    @name = 'source'
    @html = '<div class="source">Source</div>'
class Fluentd extends Item
  constructor: ()->
    @name = 'fluentd'
    @html = '<div class="fluentd">Flentd</div>'
        
    