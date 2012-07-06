Plugin = {}
Plugin.Type =
  Password: String
  Server: String
routes['/'] =
  get: (req, res) ->
    res.render 'index',
      title: 'Fluentd Designer'
      outPlugins: [
        {name: 'mongo', config: {
          database:
            type: String
            required: true
          collection:
            type: String
            required: true
          capped:
            type: Boolean
          capped_size:
            type: Number
          host:
            type: String
            required: true
          port:
            type: Number
            default: 27017
          user:
            type: String
          password:
            type: Plugin.Type.Password
          }}
        {name: 'forest', config: {}}
        {name: 'datacounter', config: {}}
        {name: 'datacalculator', config: {}}
        {name: 's3', config: {}}
        ]
      