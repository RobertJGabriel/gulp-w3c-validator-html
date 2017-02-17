
through = require('through2')
w3cjs = require('w3cjs')
gutil = require('gulp-util')
chalk = require('chalk')

handleMessages = (file, messages, options) ->
  success = true
  errorText = chalk.red.bgRed.bold('Error:')
  warningText = chalk.blue.bgRed.bold('Warning:')
  infoText = chalk.blue.bgRed.bold('Info -')
  lines = file.contents.toString().split(/\r\n|\r|\n/g)


  messages.forEach (message) ->
    
    if options.verifyMessage and !options.verifyMessage(message.type, message.message)
      return
    if message.type == 'info' and !options.showInfo
      return
    if message.type == 'error'
      success = false
      
    type = if message.type == 'error' then errorText else if message.type == 'info' then infoText else warningText
    location = 'Line ' + (message.lastLine or 0) + ', Column ' + (message.lastColumn or 0) + ':'
    erroredLine = lines[message.lastLine - 1]
    
    if erroredLine
      errorColumn = message.lastColumn
      # Trim before if the error is too late in the line
      if errorColumn > 60
        erroredLine = erroredLine.slice(errorColumn - 50)
        errorColumn = 50
      erroredLine = erroredLine.slice(0, 60)
      erroredLine = gutil.colors.grey(erroredLine.substring(0, errorColumn - 1)) + gutil.colors.red.bold(erroredLine[errorColumn - 1]) + gutil.colors.grey(erroredLine.substring(errorColumn))
    if typeof message.lastLine != 'undefined' or typeof lastColumn != 'undefined'
      gutil.log type, file.relative, location, message.message
    else
      gutil.log type, file.relative, message.message
    if erroredLine
      gutil.log erroredLine
      return
    return success

reporter = ->
  through.obj (file, enc, cb) ->
    cb null, file
    if file.w3cjs and !file.w3cjs.success
      throw new (gutil.PluginError)('gulp-w3cjs', 'HTML validation error(s) found')
    return


module.exports = (options) ->
  options = options or {}
  if typeof options.url == 'string'
    w3cjs.setW3cCheckUrl options.url
  through.obj (file, enc, callback) ->
    if file.isNull()
      return callback(null, file)
    if file.isStream()
      return callback(new (gutil.PluginError)('gulp-w3cjs', 'Streaming not supported'))
    w3cjs.validate
      proxy: if options.proxy then options.proxy else undefined
      input: file.contents
      callback: (res) ->
        file.w3cjs =
          success: handleMessages(file, res.messages, options)
          messages: res.messages
        callback null, file
        return
    return

module.exports.reporter = reporter
module.exports.setW3cCheckUrl = w3cjs.setW3cCheckUrl
