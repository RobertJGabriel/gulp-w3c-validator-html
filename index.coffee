through = require('through2')
w3cJavascript = require('w3cjs')
gutil = require('gulp-util')
chalk = require('chalk')

handleMessages = (file, messages, options) ->
  success = true
  errorText = chalk.red.bold('ERROR')
  warningText = chalk.blue.bold('WARNING')
  infoText = chalk.blue.bold('INFO')
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
      if errorColumn > 60
        erroredLine = erroredLine.slice(errorColumn - 50)
        errorColumn = 50
      erroredLine = erroredLine.slice(0, 60)
      erroredLine = gutil.colors.grey(erroredLine.substring(0, errorColumn - 1)) + gutil.colors.red.bold(erroredLine[errorColumn - 1]) + gutil.colors.grey(erroredLine.substring(errorColumn))
    if typeof message.lastLine != 'undefined' or typeof lastColumn != 'undefined'
      gutil.log "\r\n"
      gutil.log type
      gutil.log "File - " + file.relative
      gutil.log "Location - " + location
      gutil.log "Message - " + message.message
    else
      gutil.log type, file.relative, message.message
    if erroredLine
      gutil.log "Line - " + erroredLine
      return
    return success



module.exports = (options) ->
  options = options or {}
  if typeof options.url == 'string'
    w3cJavascript.w3cCheckUrl options.url
  through.obj (file, enc, callback) ->
    if file.isNull()
      return callback(null, file)
    w3cJavascript.validate
      proxy: if options.proxy then options.proxy else undefined
      input: file.contents
      callback: (res) ->
        file.w3cJavascript =
          success: handleMessages(file, res.messages, options)
          messages: res.messages
        callback null, file
        return
    return


module.exports.w3cCheckUrl = w3cJavascript.w3cCheckUrl
