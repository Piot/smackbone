
	smackbone = require '../lib/smackbone'
	should = require 'should'

	describe 'model', ->
		beforeEach ->
			@model = new smackbone.Model

		it 'should call initialize', (done) ->
			class Init extends smackbone.Model
				initialize: (options) ->
					done() if @get('hello') is 'world' and options.hello is 'world'

			new Init
				hello: 'world'


		it 'should set properties using their name', ->
			@model.set 'space', 'is big'
			@model.get('space').should.equal 'is big'


		it 'should set properties', ->
			@model.set
				name: 'test'
				value: 42

			@model.get('name').should.equal 'test'


		it 'should fire change events', (done) ->
			detectedChange = false

			@model.on 'change', ->
				detectedChange = true
				done()

			@model.set
				name: 'hello, world'

			done 'did not fire' if not detectedChange


		it 'should detect no change', (done) ->
			constantData =
				name: 'testing'

			model = new smackbone.Model constantData
			model.on 'change', ->
				done 'Change should not be triggered'

			model.set constantData
			done()


		it 'should keep track of changed properties', ->
			@model.changed.should.be.empty
			@model.set
				temp: 42
			@model.changed.should.eql {temp:42}
			@model.set
				something_else: 99
			@model.changed.should.eql {something_else:99}


		it 'should fire change for specific properties', (done) ->
			shouldFireNow = false
			@model.on 'change:something', ->
				if shouldFireNow
					done()
				else
					done 'fired at wrong time'

			@model.set
				wrong: 'it is'

			shouldFireNow = true

			@model.set
				wrong: 'something else'
				something: 42


		it 'should notify objects of change', (done) ->
			position = new smackbone.Model
				x: 42
				y: 99

			@model.set
				position: position

			position.on 'change', (model) ->
				done() if model.get('x') is -1

			@model.set
				position:
					x: -1
					y: 100


		it 'should create objects of correct type', ->
			class VectorPosition
				constructor: (options) ->
					@x = options.x
					@y = options.y
				
				toPositionString: ->
					"#{@x}:#{@y}"

			class Airplane extends smackbone.Model
				models:
					position: VectorPosition

			airplane = new Airplane
				position:
					x: 422
					y: -10

			airplane.get('position').toPositionString().should.eql '422:-10'


		it 'should not replace models during data updates', (done) ->
			subModel = new smackbone.Model
				age: 43

			@model.set
				sub: subModel

			@model.get('sub').get('age').should.equal(43)


			subModel.on 'change', (m) ->
				done() if m.get('age') is 44

			@model.set
				sub:
					age: 44


		it 'should fire unset when property is replaced', (done) ->
			subModel = new smackbone.Model
			@model.set
				sub: subModel

			@model.get('sub').on 'unset', ->
				done()

			@model.unset 'sub'

		it 'should report path for sub models', ->

			subModel = new smackbone.Model
			@model.set 
				sub: subModel

			subModel.path().should.eql '/sub'

		it 'should reoport path for multiple sub models', ->
			first = new smackbone.Model
			second = new smackbone.Model

			first.set
				second: second

			@model.set
				first: first

			second.path().should.eql '/first/second'

		it 'should be possible to access submodels using attribute', ->
			first = new smackbone.Model
			second = new smackbone.Model
			second.set 'secret', 'pepper'

			first.set
				second: second

			first.second.get('secret').should.eql 'pepper'
