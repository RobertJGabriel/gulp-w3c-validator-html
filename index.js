var chalk, gutil, handleMessages, reporter, through, w3cjs;

through = require('through2');

w3cjs = require('w3cjs');

gutil = require('gulp-util');

chalk = require('chalk');

handleMessages = function(file, messages, options) {
  var errorText, infoText, lines, success, warningText;
  success = true;
  errorText = chalk.red.bgRed.bold('Error:');
  warningText = chalk.blue.bgRed.bold('Warning:');
  infoText = chalk.blue.bgRed.bold('Info -');
  lines = file.contents.toString().split(/\r\n|\r|\n/g);
  return messages.forEach(function(message) {
    var errorColumn, erroredLine, location, type;
    if (options.verifyMessage && !options.verifyMessage(message.type, message.message)) {
      return;
    }
    if (message.type === 'info' && !options.showInfo) {
      return;
    }
    if (message.type === 'error') {
      success = false;
    }
    type = message.type === 'error' ? errorText : message.type === 'info' ? infoText : warningText;
    location = 'Line ' + (message.lastLine || 0) + ', Column ' + (message.lastColumn || 0) + ':';
    erroredLine = lines[message.lastLine - 1];
    if (erroredLine) {
      errorColumn = message.lastColumn;
      if (errorColumn > 60) {
        erroredLine = erroredLine.slice(errorColumn - 50);
        errorColumn = 50;
      }
      erroredLine = erroredLine.slice(0, 60);
      erroredLine = gutil.colors.grey(erroredLine.substring(0, errorColumn - 1)) + gutil.colors.red.bold(erroredLine[errorColumn - 1]) + gutil.colors.grey(erroredLine.substring(errorColumn));
    }
    if (typeof message.lastLine !== 'undefined' || typeof lastColumn !== 'undefined') {
      gutil.log(type, file.relative, location, message.message);
    } else {
      gutil.log(type, file.relative, message.message);
    }
    if (erroredLine) {
      gutil.log(erroredLine);
      return;
    }
    return success;
  });
};

reporter = function() {
  return through.obj(function(file, enc, cb) {
    cb(null, file);
    if (file.w3cjs && !file.w3cjs.success) {
      throw new gutil.PluginError('gulp-w3cjs', 'HTML validation error(s) found');
    }
  });
};

module.exports = function(options) {
  options = options || {};
  if (typeof options.url === 'string') {
    w3cjs.setW3cCheckUrl(options.url);
  }
  return through.obj(function(file, enc, callback) {
    if (file.isNull()) {
      return callback(null, file);
    }
    if (file.isStream()) {
      return callback(new gutil.PluginError('gulp-w3cjs', 'Streaming not supported'));
    }
    w3cjs.validate({
      proxy: options.proxy ? options.proxy : void 0,
      input: file.contents,
      callback: function(res) {
        file.w3cjs = {
          success: handleMessages(file, res.messages, options),
          messages: res.messages
        };
        callback(null, file);
      }
    });
  });
};

module.exports.reporter = reporter;

module.exports.setW3cCheckUrl = w3cjs.setW3cCheckUrl;
