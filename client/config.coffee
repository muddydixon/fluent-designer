############################################################
#  Config class
class Config
  _servers: []
  constructor: () ->
  _encodeFluentds: (fluentds) ->
    json = []
    for fluentd in fluentds
      json.push
        name: fluentd.name
        sources: @_encodeSources(fluentd._sources)
        matches: @_encodeMatches(fluentd._matches)
        includes: @_encodeIncludes(fluentd._includes)
        
    return json
    
  _encodeSources: (sources) ->
    json = []
    for source in sources
      json.push
        type: source.type
        config: source.config
    return json
    
  _encodeMatches: (matches) ->
    json = []
    for match in matches
      json.push
        type: match.type
        tag: match.tag
        config: match.config
    return json

  _encodeIncludes: (includes) ->
    return []
    
  save: ()->
    json =
      servers: []

    for server in @_servers
      json.servers.push
        name: server.name
        fluentds: @_encodeFluentds(server._fluentds)

    alert JSON.stringify(json)

    
  load: (name, target)->
    unless target instanceof jQuery
      target = $(target)

    self = this 
    $.get(name).done((json)->
      self.json = json
      for conf in json.servers
        item = new Server(conf)
        self._servers.push item
        item.render(pane)
        
      ).fail((err)->
        console.log err
        )
