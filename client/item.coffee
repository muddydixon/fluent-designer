############################################################
# 
# base Class: Item 
class Item
  render: (target, pos)->
    unless target instanceof jQuery
      target = $(target)
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
  _name: 'server'
  constructor: (@data)->
  setForm: (form) ->
    @hostname = form.find('input[name=hostname]').val()
    
    return {err: null}
  setHtml: ()->
    el = @el
    @el.find('h2.hostname').text(@hostname or @data.name)
    @el.find('a.add').on 'click', {target: el.find('div.fluentds')}, addItem
    @el.droppable
      over: (ev, ui)->
      drop: (ev, ui)->
        el.find('div.fluentds').append ui.draggable[0]
    
############################################################
#  Fluentd class
class Fluentd extends Item
  _name: 'fluentd'
  constructor: (@data)->
  setForm: (form) ->
    @filename = form.find('input[name=filename]').val()
    
    return {err: null}
  setHtml: ()->
    el = @el
    @el.find('h2.filename').text(@filename or @data.name)
    @el.find('a.add[data-type=source]').on 'click', {target: el.find('div.sources')}, addItem
    @el.find('a.add[data-type=match]').on 'click', {target: el.find('div.matches')}, addItem
    @el.droppable
      over: (ev, ui)->
        type = $(ui.draggable[0]).data('obj')._name
        el.find('div.'+type).addClass 'hover'
      drop: (ev, ui)->
        el.find('div.fluentds').append ui.draggable[0]
    
############################################################
#  Match class
class Match extends Item
  _name: 'match'
  constructor: (@data)->
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
    @el.find('h3.tag').text(@tag or @data.tag)
    @el.find('span.type').text(@type or @data.type)
    table = $('<table>')
    for conf of @config
      table.append $('<tr>').append($('<th>').text(conf), $('<td>').text(@config[conf]))
    @el.find('div.config').append table
    
############################################################
#  Source class
class Source extends Item
  _name: 'source'
  constructor: (@data)->
  setForm: (form) ->
    @type = form.find('select').val()
    if @type.match(/^[\s\r\t\b]*$/)
      return {err: 'type required'}
    @config = {}
    for input in form.find('.config input')
      @config[$(input).attr('name')] = $(input).val()
      
    return {err: null}
  setHtml: ()->
    @el.find('span.type').text(@type or @data.type)
    table = $('<table>')

    config = @config or @data.config
    for conf of config
      table.append $('<tr>').append($('<th>').text(conf), $('<td>').text(config[conf]))
    @el.find('div.config').append table
    

