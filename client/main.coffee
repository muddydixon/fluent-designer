# 要素を保持
pane = $('#pane')
control = $('#control')

# pluginsを取得/保持
plugins = null
$.get('/api/v0.0/plugins').done((res)->
  plugins = res.plugins
  match = $('.edit[data-type=match] form select')
  for plugin in plugins.out
    match.append $('<option>').text(plugin.name)
  source = $('.edit[data-type=source] form select')
  for plugin in plugins.in
    source.append $('<option>').text(plugin.name)
  ).fail((err) ->
    )

# アイテム追加ボタン
addItem = ()->
  button = $(this)
  button.addClass('active')
  control.find('a').off('click', addItem)
  type = $(this).attr('data-type')
  pane.css({cursor: 'crosshair'})
    
  pane.on('click', (ev) ->
    pane.off('click')
    pane.css({cursor: ''})

    $('.modal[data-type='+type+']').data('pos', {x: ev.clientX, y: ev.clientY}).modal()
    
    control.find('a').on('click', addItem)
    button.removeClass('active')
    return 
    )
  return
control.find('a').on('click', addItem)

############################################################
# 
# modal
$('div.modal a.btn-primary').on('click', (ev)->
  modal = $($(this).parents('div.modal')[0])
  type = modal.attr('data-type')
  
  item = null
  switch type
    when 'server'
      item = new Server()
    when 'fluentd'
      item = new Fluentd()
    when 'match'
      item = new Match()
    when 'source'
      item = new Source()
  res = item.setForm modal.find('form')
  if res.err?
    # 異常
    console.log res.err
  else
    # 正常完了
    item.render(pane, modal.data('pos'))

    # modal 初期化
    modal.find('input').val('')
    $(modal.find('select option')[0]).attr('selected', true)
    modal.find('.config .control-group').remove()

    # modal 完了
    modal.modal('hide')
  return
  )
  
# event proxy
$('div.modal form').on('submit', () ->
  $($(this).parents('div.modal')[0]).find('a.btn-primary').trigger('click')
  return false
  )

############################################################
# 
# modal Match
$('div.modal[data-type=match] form select.type').on('change', ()->
  modal = $($(this).parents('div.modal')[0])
  item = $($('div.new').data('obj'))[0]
  config = modal.find('fieldset.config')
  cgrp = $('<div class="control-group">')
    .append($('<label class="control-label">'),
      $('<div class="controls">'))
  for plugin in plugins.out
    if plugin.name is $(this).val()
      for conf of plugin.config
        c = cgrp.clone()
        c.find('label').text(conf)
        if plugin.config[conf].required?
          c.find('label').append $('<span>').addClass('required').text('*')
        c.find('div.controls').append $('<input type="text">').attr('name', conf)
        config.append c
  )

############################################################
# 
# base Class: Item 
class Item
  constructor: ()->
  render: (target, pos)->
    @html = $('.template.'+@name).html()
    @el = $(@html)
    @el.data('obj', this)
    @bindEvent @el
    @el.addClass 'item'
    @el.css
      left: pos.x
      top: pos.y
    @setHtml()
    $(target).append @el
    @el.draggable()
    return
  set: (attr, val) ->
    this[attr] = val
    return val
  setForm: (form) ->
    
  get: (attr) ->
    return this[attr]
  bindEvent: ()->
    for event in @events or {}
      @el.find(event.target).on event.event, event.handler
    
############################################################
# Server class
class Server extends Item
  constructor: ()->
    @name = 'server'
    
############################################################
#  Match class
class Match extends Item
  constructor: ()->
    @name = 'match'
    @events = []
  setForm: (form) ->
    @tag = form.find('input[name=tag]').val()
    @type = form.find('select').val()

    if @tag.match(/^[\s\r\t\b]*$/)
      return {err: 'tag required'}
    if @type.match(/^[\s\r\t\b]*$/)
      return {err: 'type required'}

    @config = {}
    for input in form.find('.config input')
      @config[$(input).attr('name')] = $(input).val()
      
    return {err: null}
  setHtml: ()->
    @el.find('h2.tag').text(@tag)
    @el.find('h3.type').text(@type)
    table = $('<table>')
    for conf of @config
      table.append $('<tr>').append($('<th>').text(conf), $('<td>').text(@config[conf]))
    @el.find('div.config').append table
    
    
      
############################################################
#  Source class
class Source extends Item
  constructor: ()->
    @name = 'source'
  setForm: (form) ->
    @type = form.find('select').val()
  setHtml: ()->
    @el.find('h3.type').text(@type)
    table = $('<table>')
    for conf of @config
      table.append $('<tr>').append($('<th>').text(conf), $('<td>').text(@config[conf]))
    @el.find('div.config').append table
    
############################################################
#  Fluentd class
class Fluentd extends Item
  constructor: ()->
    @name = 'fluentd'
        
    