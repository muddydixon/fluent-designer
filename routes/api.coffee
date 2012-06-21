routes['/api/v0.0/plugins'] =
  get: (req, res) ->
    res.send
      plugins: {
        out: [
          {name: 'forward', config: {}}
          {name: 'stdout', config: {}}
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
        in: [
          {name: 'forward', config: {
            port:
              type: Number
              default: 24224
            }}
          {name: 'tail', config: {
            path:
              type: String
              required: true
            tag:
              type: String
              required: true
            format:
              type: String
              required: true
            pos_file:
              type: String
            }}
        ]
      }
