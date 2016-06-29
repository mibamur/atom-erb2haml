{CompositeDisposable} = require 'atom'
path = require('path')
exec = require('child_process').exec

module.exports = Erb2haml =
  subscriptions: null
  whitelist: ['.html', '.erb']
  config:
    executePath:
      type: 'string'
      default: 'html2haml'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'erb2haml:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    editor = atom.workspace.getActivePaneItem()
    filePath = editor.buffer.file.path

    sourceFileObj = path.parse(filePath)
    resultFile = "#{sourceFileObj.dir}/#{sourceFileObj.name}.html.haml"

    unless (sourceFileObj.ext in @whitelist)
      editor.notificationManager.addError("Converting only #{@whitelist} files")
      return

    execCommand = atom.config.get('erb2haml.executePath')
    exec "#{execCommand} #{filePath} #{resultFile}", (error, stdout, stderr) ->
      if stderr
        editor.notificationManager.addError(stderr)
        exec "rm #{resultFile}", {}
        return

      editor.notificationManager.addInfo(stdout) if stdout
      atom.workspace.open(resultFile)
