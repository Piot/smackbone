module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-mocha-test'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-concat'

	grunt.initConfig
		mochaTest:
			test:
				options:
					reporter: 'spec'
					require: 'coffee-script'
				
				src: ['test/**/*.litcoffee']

		concat:
			options:
				separator: ''
			dist:
				src: [
					'lib/header.litcoffee'
					'lib/event.litcoffee'
					'lib/model.litcoffee'
					'lib/collection.litcoffee'
					'lib/syncer.litcoffee'
				]
				dest: 'out/smackbone.litcoffee'

		coffee:
			compile:
				files:
					'out/smackbone.js': 'out/smackbone.litcoffee'

	grunt.registerTask 'default', [
		'concat'
		'coffee'
		'mochaTest'
	]
