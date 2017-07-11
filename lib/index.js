'use strict';

// Imported Modules
const through = require('through2');
const w3cValidator = require('w3cjs');
const gutil = require('gulp-util');
const chalk = require('chalk');

// Error Messages
const errorText = chalk.red.bold('ERROR');
const warningText = chalk.blue.bold('WARNING');
const infoText = chalk.blue.bold('INFO');

function handleMessages(file, messages, options) {
  var success = true;

  let lines = file.contents.toString().split(/\r\n|\r|\n/g);

  return messages.forEach(function (message) {
    let errorColumn;
    let erroredLine;
    let location;
    let type;

    let verifyMessage = options.verifyMessage(message.type, message.message);

    if (options.verifyMessage && !verifyMessage) {
      return;
    }

    // If there is info error
    if (message.type === 'info' && options.showInfo) {
      return;
    }

    // Was there an error ?
    if (message.type === 'error') {
      success = false;
    }

    // Switch statement for message type
    switch (message.type) {
      case 'error':
        type = errorText;
        break;
      case 'info':
        type = infoText;
        break;
      default:
        type = warningText;
    }

    // Warining Lines and columns
    location = 'Line ' + (message.lastLine || 0);
    location += ', Column ' + (message.lastColumn || 0) + ':';
    erroredLine = lines[message.lastLine - 1];

    // If there is a error lined.
    if (erroredLine) {
      // The error column
      errorColumn = message.lastColumn;

      // Slice messages columsn
      if (errorColumn > 60) {
        erroredLine = erroredLine.slice(errorColumn - 50);
        errorColumn = 50;
      }

      // Slice the message up
      erroredLine = erroredLine.slice(0, 60);
      erroredLine = gutil.colors.grey(erroredLine.substring(0, errorColumn - 1));
      erroredLine += gutil.colors.red.bold(erroredLine[errorColumn - 1]);
      erroredLine += gutil.colors.grey(erroredLine.substring(errorColumn));
    }

    if (typeof message.lastLine !== 'undefined' || typeof message.lastColumn !== 'undefined') {
      console.log(type);
      gutil.log('File - ' + file.relative);
      gutil.log('Location - ' + location);
      gutil.log('Message - ' + message.message);
    } else {
      gutil.log(type, file.relative, message.message);
    }
    if (erroredLine) {
      gutil.log('Line - ' + erroredLine);
      return;
    }
    return success;
  });
}

module.exports = function (options) {
  options = options || {};

  // Check if the options.url is a string
  if (typeof options.url === 'string' || options.url instanceof String) {
    w3cValidator.w3cCheckUrl(options.url);
  }

  // Run though the instance from gulp
  // though binary.
  return through.obj(function (file, enc, callback) {
    console.log(file.contents);
    // Insure the file isnt null
    if (file.isNull()) {
      return callback(null, file);
    }

    // Run the 3rd part w3cValidator
    // Check if there is a proxy running i
    w3cValidator.validate({
      proxy: options.proxy ? options.proxy : undefined,
      input: file.contents,
      callback: function (result) {
        if (result === null || result === 'null') {
          return;
        }
        file.w3cValidator = {
          success: handleMessages(file, result.messages, options),
          messages: result.messages
        };
        callback(null, file);
      }
    });
  });
};

module.exports.w3cCheckUrl = w3cValidator.w3cCheckUrl;
