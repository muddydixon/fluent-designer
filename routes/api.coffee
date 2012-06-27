routes['/api/v0.0/plugins'] =
  get: (req, res) ->
    res.send
      plugins: {
        matches: [
          {type: 'forward', config: {}}
          {type: 'stdout', config: {}}
          {type: 'mongo', config: {
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
          {type: 'forest', config: {}}
          {type: 'datacounter', config: {}}
          {type: 'datacalculator', config: {}}
          {type: 's3', config: {}}
        ]
        sources: [
          {type: 'forward', config: {
            port:
              type: Number
              default: 24224
            }}
          {type: 'tail', config: {
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
