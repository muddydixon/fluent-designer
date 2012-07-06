# Cakefile

{exec, spawn} = require 'child_process'
cs = require 'coffee-script'

run = (args, cb) ->
  proc = spawn 'node', ['./node_modules/coffee-script/bin/coffee'].concat(args)
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on 'exit', (status)->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'

task "build", "build coffee", ->
  run ['-c', 'app.coffee'], ()-> console.log 'compile app.coffee'
  run ['-j', 'public/js/main.js', '-c', 'client/config.coffee', 'client/plugin.coffee', 'client/item.coffee', 'client/modal.coffee', 'client/main.coffee' ], ()-> console.log 'compile client/main.coffee'
  run ['-j', 'routes/index.js', '-c', 'routes/index.coffee', 'routes/path.coffee', 'routes/api.coffee'], ()-> console.log 'compile routes/*.coffee'

task "test", "test nirvana", ->
  console.log "some test"
  