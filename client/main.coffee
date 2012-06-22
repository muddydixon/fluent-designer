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
addItem = (ev)->
  button = $(this)
  button.addClass('active')
  control.find('a').off('click', addItem)
  type = $(this).attr('data-type')
  pane.css({cursor: 'crosshair'})
    
  if ev.data?
    target = ev.data.target
    console.log target
  pane.on('click', (ev) ->
    pane.off('click')
    pane.css({cursor: ''})

    if target?
      $('.modal[data-type='+type+']').data('target', target)
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
    item.render(modal.data('target') or pane, if modal.data('target') then null else modal.data('pos'))

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
  modal.find('.config .control-group').remove()
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
# modal Source
$('div.modal[data-type=source] form select.type').on('change', ()->
  modal = $($(this).parents('div.modal')[0])
  modal.find('.config .control-group').remove()
  item = $($('div.new').data('obj'))[0]
  config = modal.find('fieldset.config')
  cgrp = $('<div class="control-group">')
    .append($('<label class="control-label">'),
      $('<div class="controls">'))
  for plugin in plugins.in
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
    @html = $('.template.'+@_name).html()
    @el = $(@html)
    @el.data('obj', this)
    @bindEvent @el
    @el.addClass 'item'
    if pos?
      @el.css
        left: pos.x
        top: pos.y
    else
      @el.css
        position: 'static'
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
    @_name = 'server'
  setForm: (form) ->
    @hostname = form.find('input[name=hostname]').val()
    
    return {err: null}
  setHtml: ()->
    el = @el
    @el.find('h2.hostname').text(@hostname)
    @el.find('a.add').on 'click', {target: el.find('div.fluentds')}, addItem
    @el.droppable
      over: (ev, ui)->
      drop: (ev, ui)->
        el.find('div.fluentds').append ui.draggable[0]
    
############################################################
#  Fluentd class
class Fluentd extends Item
  constructor: ()->
    @_name = 'fluentd'
  setForm: (form) ->
    @filename = form.find('input[name=filename]').val()
    
    return {err: null}
  setHtml: ()->
    el = @el
    @el.find('h2.filename').text(@filename)
    @el.find('a.add[data-type=source]').on 'click', {target: el.find('div.sources')}, addItem
    @el.find('a.add[data-type=match]').on 'click', {target: el.find('div.matches')}, addItem
    @el.droppable
      over: (ev, ui)->
        type = $(ui.draggable[0]).data('obj')._name
        el.find('div.'+type).addClass 'hover'
      over: (ev, ui)->
        type = $(ui.draggable[0]).data('obj')._name
        el.find('div.'+type).addClass 'hover'
      drop: (ev, ui)->
        el.find('div.fluentds').append ui.draggable[0]
    
############################################################
#  Match class
class Match extends Item
  constructor: ()->
    @_name = 'match'
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
    @_name = 'source'
  setForm: (form) ->
    @type = form.find('select').val()
    if @type.match(/^[\s\r\t\b]*$/)
      return {err: 'type required'}

    @config = {}
    for input in form.find('.config input')
      @config[$(input).attr('name')] = $(input).val()
      
    return {err: null}
  setHtml: ()->
    @el.find('h3.type').text(@type)
    table = $('<table>')
    for conf of @config
      table.append $('<tr>').append($('<th>').text(conf), $('<td>').text(@config[conf]))
    @el.find('div.config').append table
    
