coffee = require('gulp-coffee')
gulp = require('gulp')
runSequence = require('run-sequence')
w3cGulp = require('./lib/index.js')
figlet = require('figlet')


gulp.task 'test', ->
  gulp.src('./lib/__tests__/bad.html').pipe(w3cGulp())
  return


gulp.task 'default', (callback) ->
  runSequence 'test', callback
  return
