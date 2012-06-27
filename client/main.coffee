# 要素を保持
pane = $('#pane')
control = $('#control')

# pluginsを取得/保持
plugins = new Plugins((sources, matches)->
  matchPane = $('.edit[data-type=match] form select')
  for match in matches
    matchPane.append $('<option>').text(match.type)
  sourcePane = $('.edit[data-type=source] form select')
  for source in sources
    sourcePane.append $('<option>').text(source.type)
  )
plugins.load('/api/v0.0/plugins')

# アイテム追加ボタン
addItem = (ev)->
  button = $(this)
  button.addClass('active')
  control.find('a').off('click', addItem)
  type = $(this).attr('data-type')
  pane.css({cursor: 'crosshair'})
    
  if ev.data?
    target = ev.data.target
  pane.on('click', (ev) ->
    pane.off('click')
    pane.css({cursor: ''})

    if target?
      $('.modal[data-type='+type+']').data('target', target)
    $('.modal[data-type='+type+']').data('pos', {x: ev.clientX, y: ev.clientY}).modal()
    
    control.find('a').on('click', addItem)
    button.removeClass('active')
    return 
    )
  return
control.find('a').on('click', addItem)

############################################################
#  main
conf = new Config()
conf.load('/sample.json', pane)