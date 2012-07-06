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
    @setHtml()
    if pos?
      @el.css
        left: pos.x
        top: pos.y
    
    $(target).append @el
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
    @_fluentds = []
    if @data?
      @name = @data.name
      for conf in @data.fluentds
        @_fluentds.push new Fluentd(conf)
      
  setForm: (form) ->
    @hostname = form.find('input[name=hostname]').val()
    return {err: null}
    
  setHtml: ()->
    el = @el
    @el.find('h2.hostname').text(@hostname or @data.name)
    @el.find('a.add').on 'click', {target: el.find('div.fluentds')}, addItem

    #####
    # draggable
    @el.draggable
      scope: 'server'
      
    #####
    # droppable
    @el.find('.fluentds').droppable
      scope: 'fluentd'
      hoverClass: 'hover'
      drop: (ev, ui)->
        console.log 'fluentd', ui.draggable[0]
        $(ui.draggable[0]).css
          left: 0
          top: 0
          
        from = $(ui.draggable[0].parentNode).parents('div.server').data('obj')
        to = $(this).parents('div.server').data('obj')
        target = $(ui.draggable[0]).data('obj')

        for obj, id in from._fluentds
           if obj is target
            from._fluentds.splice(id, 1)
        to._fluentds.push target
        
        $(this).append ui.draggable[0]
    
    for fluentd in @_fluentds
      fluentd.render(@el.find('.fluentds'))
      
############################################################
#  Fluentd class
class Fluentd extends Item
  _name: 'fluentd'
  constructor: (@data)->
    @_sources = []
    @_matches = []
    if @data
      @name = @data.name
      
      for match in @data.matches
        @_matches.push new Match(match)
      for source in @data.sources
        @_sources.push new Source(source)

  setForm: (form) ->
    @filename = form.find('input[name=filename]').val()
    
    return {err: null}
  setHtml: ()->
    el = @el
    @el.find('h2.filename').text(@filename or @data.name)
    @el.find('a.add[data-type=source]').on 'click', {target: el.find('div.sources')}, addItem
    @el.find('a.add[data-type=match]').on 'click', {target: el.find('div.matches')}, addItem
    
    @el.find('.plugins.matches').droppable
      hoverClass: 'hover'
      scope: 'match'
      drop: (ev, ui)->
        $(ui.draggable[0]).css
          left: 0
          top: 0

        from = $(ui.draggable[0].parentNode).parents('div.fluentd').data('obj')
        to = $(this).parents('div.fluentd').data('obj')
        target = $(ui.draggable[0]).data('obj')

        for obj, id in from._matches
           if obj is target
            from._matches.splice(id, 1)
        to._matches.push target
        
        $(this).append ui.draggable[0]
        
    @el.find('.plugins.sources').droppable
      hoverClass: 'hover'
      scope: 'source'
      drop: (ev, ui)->
        $(ui.draggable[0]).css
          left: 0
          top: 0

        from = $(ui.draggable[0].parentNode).parents('div.fluentd').data('obj')
        to = $(this).parents('div.fluentd').data('obj')
        target = $(ui.draggable[0]).data('obj')

        for obj, id in from._sources
           if obj is target
            from._sources.splice(id, 1)
        to._sources.push target
        
        $(this).append ui.draggable[0]
  
    @el.draggable
      revert: 'valid'
      scope: 'fluentd'

    for match in @_matches
      match.render(@el.find('.matches'))
    for source in @_sources
      source.render(@el.find('.sources'))
    
############################################################
#  Source class
class Source extends Item
  _name: 'source'
  constructor: (@data)->
    if @data?
      @type = @data.type
      @config = @data.config
  setForm: (form) ->
    @type = form.find('select').val() 
    if @type.match(/^[\s\r\t\b]*$/)
      return {err: 'type required'}
    @config = @config or {}
    for input in form.find('.config input')
      @config[$(input).attr('name')] = $(input).val()
      
    return {err: null}
  setHtml: ()->
    @el.find('span.type').text(@type or @data.type)
    
    plugin = plugins.getSourceConfig(@type or @data.type)
    pConfig = if plugin.config? then plugin.config else {}
    config = @config or @data.config
    
    table = $('<table>')
    for attr of pConfig
      val = config[attr] or pConfig[attr]['default'] or ''
      table.append $('<tr>').append($('<th>').text(attr), $('<td>').text(val))
      
    @el.draggable
      revert: 'valid'
      scope: 'source'
      
    @el.find('div.config').append table
    
############################################################
#  Match class
class Match extends Item
  _name: 'match'
  constructor: (@data)->
    if @data?
      @type = @data.type or {}
      @config = @data.config or {}
      @tag = @data.tag or null
      if @data? and @data.type?
        unless plugins.getMatchConfig(@data.type)?
          throw 'no plugin info '+ @data.type
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
    tag = @tag or @data.tag
    type = @type or @data.type
    
    @el.find('h3.tag').text(tag)
    @el.find('span.type').text(type)
    
    plugin = plugins.getMatchConfig(@type or @data.type)
    pConfig = if plugin.config? then plugin.config else {}
    config = @config or @data.config
    
    table = $('<table>')
    for attr of pConfig
      val = config[attr] or pConfig[attr]['default'] or ''
      table.append $('<tr>').append($('<th>').text(attr), $('<td>').text(val))
      
    @el.draggable
      revert: 'valid'
      scope: 'match'
    @el.find('div.config').append table
