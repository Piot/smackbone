
	smackbone = require '../out/smackbone'
	should = require 'should'

	describe 'syncer', ->
		beforeEach ->
			@root = new smackbone.Model
			@syncer = new smackbone.Syncer
				model: @root

		it 'should report save request for sub models', (done) ->
			model = new smackbone.Model
			@root.set 'sub', model
			@syncer.urlRoot = 'http://some_site.com'
			@syncer.on 'request', (options) ->
				if options.type is 'PUT' and options.url is 'http://some_site.com/sub'
					done()
				else
					done 'wrong parameters in request'
			model.save()

		it 'should report save request for collection', (done) ->
			car = new smackbone.Model
				year: 2000
			cars = new smackbone.Collection
			cars.add car
			@root.set 'cars', cars
			@syncer.urlRoot = 'http://some_site.com'
			@syncer.on 'request', (options) ->
				if options.type is 'POST' and options.url is 'http://some_site.com/cars/' and options.data is '{"year":2000}'
					done()
				else
					done 'wrong parameters in request'
			car.save()

		it 'should report fetch request', (done) ->
			@root.id = 2
			@syncer.on 'request', (options) ->
				done() if options.type is 'GET' and options.url is ''
			@root.fetch()

		it 'should report save request (PUT)', (done) ->
			@root.id = 2
			@syncer.on 'request', (options) ->
				done() if options.type is 'PUT' and options.url is ''
			@root.save()
