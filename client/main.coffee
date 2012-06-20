$ () ->
  # 要素を保持
  pane = $('#pane')
  control = $('#control')

  # ボタン
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

  # modal dialog
  $('.modal .btn-primary').on('click', ()->
    modal = $($(this).parents('div.modal')[0])
    item = $($('div.new').data('obj'))[0]

    console.log item, item.name
    
    if item.name is 'match' or item.name is 'source'
      
      item.set('plugin', modal.find('select[name=plugin]').val())
      item.el.find('.type').text(modal.find('select[name=plugin]').val())
      
      if item.el.find('.tag')?
        item.el.find('.tag').text(modal.find('input[name=tag]').val())
    )
  
  return

############################################################
# 
# 
class Item
  constructor: ()->
  render: (target, pos)->
    @html = $('.template.'+@name).html()
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
    $('#edit.'+@name).modal()
  set: (attr, val) ->
    this[attr] = val
    return val
  get: (attr) ->
    return this[attr]
  bindEvent: ()->
    for event of @events or {}
      @el.on event, @events[event]
    
class Server extends Item
  constructor: ()->
    @name = 'server'
class Match extends Item
  constructor: ()->
    @name = 'match'
    @events =
      click: ()->
        alert(1)
      saveEdit: ()->
        alert(1)
      
class Source extends Item
  constructor: ()->
    @name = 'source'
    
class Fluentd extends Item
  constructor: ()->
    @name = 'fluentd'
        
    