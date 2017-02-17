coffee = require('gulp-coffee')
gulp = require('gulp')
runSequence = require('run-sequence')


gulp.task 'coffee', ->
  gulp.src('./index.coffee').pipe(coffee(bare: true)).pipe gulp.dest('./')
  return
  
gulp.task 'default', (callback) ->
  runSequence 'coffee', callback
  return

