gulp = require 'gulp'
plugins = require('gulp-load-plugins')(pattern: [
	'*{-,.}*'
	'cssnano'
])
mainBowerFiles = require('main-bower-files');
notifier = require('node-notifier');
stylish = require('jshint-stylish');
path = require('path');

###For main-fails of other plugins###

gulp.task 'lib', ['mainfilesJs', 'mainfilesCss'];

gulp.task 'mainfilesJs', ->
		return gulp.src(mainBowerFiles('**/*.js'))
		.pipe gulp.dest 'frontend/js/lib/'

gulp.task 'mainfilesCss', ->
		return gulp.src(mainBowerFiles('**/*.css'))
		.pipe gulp.dest 'frontend/styles/lib/'


###Build styles###

gulp.task 'styles', ->
	processors = [
		plugins.autoprefixerCore browsers: ['last 2 versions','ie 8', 'ie 9', 'ie 10', 'ie 11']
		plugins.cssMqpacker
		# plugins.cssnano
	]
	gulp.src 'frontend/styles/*.styl'
	.pipe plugins.plumber errorHandler: plugins.notify.onError("Error: <%= error.message %>")
	.pipe plugins.stylus
		errors: true
		'include css': true
	.pipe plugins.postcss processors
	.pipe plugins.rename suffix: '.min'
	.pipe gulp.dest 'public_html/assets/css'
	return

###Build scripts###
gulp.task 'scripts', ->
	gulp.src ['frontend/js/lib/jquery.js','frontend/js/lib/*.js','frontend/js/modules/*.js','frontend/js/app.js']
		.pipe plugins.plumber errorHandler: plugins.notify.onError("Error: <%= error.message %>")
		.pipe plugins.concat 'scripts.min.js'
		#.pipe plugins.uglify()
		.pipe gulp.dest 'public_html/assets/js'
	return


###STATICS###
gulp.task 'jade', ->
	gulp.src ['frontend/jade/**/*.jade']
		.pipe plugins.plumber errorHandler: plugins.notify.onError("Error: <%= error.message %>")
		.pipe(plugins.changed('public_html/static/', {extension: '.html'}))
		.pipe(plugins.jadeInheritance({basedir: 'frontend/jade'}))
		.pipe(plugins.jade({
				pretty: true
		}))
		.pipe(plugins.posthtml([ require('posthtml-bem')(
			elemPrefix: '__'
			modPrefix: '--'
			modDlmtr: '-') ]))
		.pipe(plugins.typograf({lang: 'ru'}))
		.pipe plugins.plumber errorHandler: plugins.notify.onError("Error: <%= error.message %>")
		.pipe gulp.dest 'public_html/static'
	return

###Copy Fonts###
gulp.task 'fonts',->
	gulp.src([
			'frontend/fonts/**/*',
	])
	.pipe gulp.dest 'public_html/assets/fonts';
	return

###Copy and compression img###
gulp.task 'img', ->
	gulp.src('frontend/img/**/*')
		.pipe(plugins.imagemin({
				progressive: true,
				svgoPlugins: [{removeViewBox: false}],
				use: [plugins.imageminPngquant()]
		}))
		.pipe gulp.dest 'public_html/assets/img';
	return

###SVG sprites###
gulp.task 'svg', ['svgSprite'];

gulp.task 'svgSprite', ->
	gulp.src 'frontend/_svg/*.svg'
	.pipe plugins.svgmin
		js2svg:
			pretty: true
	.pipe plugins.svgSprite
		mode:
			symbol:
				dest: 'frontend'
				dimensions: '-icon'
				sprite: '../public_html/assets/svg/sprite.svg'
				example: true
				render:
					styl:
						dest: 'styles/global/sprite.styl'
		svg:
			xmlDeclaration: false
			doctypeDeclaration: false
	.pipe gulp.dest '.'
	return



###LINT TASK###
gulp.task 'lint', ['jscs', 'jshint'];

gulp.task 'jshint', ->
	errorReporter = ->
		map (file, cb) ->
			if !file.plugins.jshint.success
				process.exit 1 # jshint ignore:line
			cb null, file
			return
			gulp.src 'frontend/js/modules/*.js'
				.pipe(plugins.jshint())
				.pipe(plugins.jshint.reporter(stylish))
				.pipe errorReporter()


gulp.task 'jscs', ->
	gulp.src 'frontend/js/modules/*.js'
		.pipe(plugins.jscs())
		.pipe plugins.jscs.reporter()



###Notify task###
gulp.task 'pre-commit-notify', ->
	notifier.notify
		message: 'Fix errors first'
		title: 'Commit failed'
	return


###Hook tasks###
gulp.task 'hooks', ->
	gulp.src('hooks/*')
		.pipe(plugins.chmod(execute: true))
		.pipe gulp.dest('.git/hooks/')
	return


###WATCH###
gulp.task 'watch',  ->
	gulp.watch 'frontend/styles/**/*.styl', ['styles']
	gulp.watch ['frontend/js/lib/*.js','frontend/js/modules/*.js','frontend/js/app.js'], ['scripts']
	gulp.watch ['frontend/jade/**/**/*.jade'], ['jade']
	return

gulp.task 'browser-sync', ->
	plugins.browserSync.init ['public_html/static/*.html','public_html/assets/css/*.css','public_html/assets/js/*.js'],
	server: baseDir: './public_html/'
	return

###BUILD TASK###
gulp.task 'build', ['svg', 'scripts', 'styles', 'jade'];

###MAIN###

gulp.task 'default', ['browser-sync'], ->
	gulp.watch 'frontend/styles/**/*.{styl,css}', ['styles']
	gulp.watch ['frontend/js/lib/*.js','frontend/js/modules/*.js','frontend/js/app.js'], ['scripts']
	gulp.watch ['frontend/jade/**/*.jade'], ['jade']
	return
