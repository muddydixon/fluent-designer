############################################################
#  Config class
class Config
  constructor: () ->
  save: ()->
  load: (name, target)->
    unless target instanceof jQuery
      target = $(target)
      
    $.get(name).done((json)->
      for server in json.servers
        _server = new Server(server)
        _server.render(target)

        for fluentd in server.fluentds
          _fluentd = new Fluentd(fluentd)
          _fluentd.render(_server.el.find('.fluentds'))

          for source in fluentd.plugins.sources
            _source = new Source(source)
            _source.render(_fluentd.el.find('.sources'))
          for match in fluentd.plugins.matches
            _match = new Match(match) 
            _match.render(_fluentd.el.find('.matches'))
          
      ).fail((err)->
        console.log err
        )
