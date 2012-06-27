class Plugin
  constructor: (@type, @config)->

class Plugins
  _plugins: []
  constructor: (@cb)->
  load: (path)->
    self = this
    $.get(path).done((json)->
      if json?
        @_sources = json.plugins.sources
        @_matches = json.plugins.matches
        self.cb(@_sources, @_matches)
      ).fail((err)->
        console.log err
        )
  getMatchConfig: (type)->
    for match in @_matches
      if match.type = type
        return match
    return null
  getSourceConfig: (type)->
    for source in @_sources
      if source.type = type
        return source
    return null
          