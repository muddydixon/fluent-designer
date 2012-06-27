class Plugin
  constructor: (@type, @config)->

class Plugins
  _plugins: []
  constructor: (@cb)->
  load: (path)->
    self = this
    $.get(path).done((json)->
      if json?
        self._sources = json.plugins.sources
        self._matches = json.plugins.matches
        self.cb(self._sources, self._matches)
      ).fail((err)->
        console.log err
        )
  getMatchConfig: (type)->
    for match in @_matches
      if match.type is type
        return match
    return null
  getSourceConfig: (type)->
    for source in @_sources
      if source.type is type
        return source
    return null
          