coffee = require('gulp-coffee')
gulp = require('gulp')
runSequence = require('run-sequence')
w3cGulp = require('./dist/index.js')
figlet = require('figlet')

gulp.task 'coffee', ->
  gulp.src('./index.coffee').pipe(coffee(bare: true)).pipe gulp.dest('./dist')
  return
  
gulp.task 'default', (callback) ->
  runSequence 'coffee', callback
  return

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