## Synopsis

A simple project to check for errors and that your HTML meets the w3c standard.

## Code Example

``
coffee = require('gulp-coffee')
gulp = require('gulp')
runSequence = require('run-sequence')
w3cGulp = require('./index.js')
figlet = require('figlet')

gulp.task 'test', ->
  figlet 'W3C Checks', (err, data) ->
    if err
      console.log 'Something went wrong...'
      console.dir err
      return
    console.log data
    return
  gulp.src('tests/bad.html').pipe(w3cGulp())
  return

``

## Motivation

I needed this for a project and wanted to try and remake it.

## Installation
1. Include the index.js file.
2. Include it
3. Add a pipe ``.pipe(w3cGulp())``

## Tests

``npm run test``

## Contributors

Hat tip to https://www.npmjs.com/package/gulp-w3c-html

## License

A short snippet describing the license (MIT, Apache, etc.)