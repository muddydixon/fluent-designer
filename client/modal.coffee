############################################################
# 
# modal
$('div.modal a.btn-primary').on('click', (ev)->
  modal = $($(this).parents('div.modal')[0])
  type = modal.attr('data-type')
  
  item = null
  switch type
    when 'server'
      item = new Server()
    when 'fluentd'
      item = new Fluentd()
    when 'match'
      item = new Match()
    when 'source'
      item = new Source()
  res = item.setForm modal.find('form')
  if res.err?
    # 異常
    console.log res.err
  else
    # 正常完了
    item.render(modal.data('target') or pane, if modal.data('target') then null else modal.data('pos'))

    # modal 初期化
    modal.find('input').val('')
    $(modal.find('select option')[0]).attr('selected', true)
    modal.find('.config .control-group').remove()

    # modal 完了
    modal.modal('hide')
  return false
  )
  
# event proxy
$('div.modal form').on('submit', () ->
  $($(this).parents('div.modal')[0]).find('a.btn-primary').trigger('click')
  return false
  )

############################################################
# 
# modal Match
$('div.modal[data-type=match] form select.type').on('change', ()->
  modal = $($(this).parents('div.modal')[0])
  modal.find('.config .control-group').remove()
  item = $($('div.new').data('obj'))[0]
  config = modal.find('fieldset.config')
  cgrp = $('<div class="control-group">')
    .append($('<label class="control-label">'),
      $('<div class="controls">'))
      
  plugin = plugins.getMatchConfig($(this).val())
  for conf of plugin.config
    c = cgrp.clone()
    c.find('label').text(conf)
    if plugin.config[conf].required?
      c.find('label').append $('<span>').addClass('required').text('*')
    c.find('div.controls').append $('<input type="text">').attr('name', conf)
    config.append c
  )

############################################################
# 
# modal Source
$('div.modal[data-type=source] form select.type').on('change', ()->
  modal = $($(this).parents('div.modal')[0])
  modal.find('.config .control-group').remove()
  item = $($('div.new').data('obj'))[0]
  config = modal.find('fieldset.config')
  cgrp = $('<div class="control-group">')
    .append($('<label class="control-label">'),
      $('<div class="controls">'))
      
  plugin = plugins.getSourceConfig($(this).val())
      
  for conf of plugin.config
    c = cgrp.clone()
    c.find('label').text(conf)
    if plugin.config[conf].required?
      c.find('label').append $('<span>').addClass('required').text('*')
    c.find('div.controls').append $('<input type="text">').attr('name', conf)
    config.append c
  )

