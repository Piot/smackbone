
	smackbone = require '../out/smackbone'
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

		it 'should clone itself', ->
			@model.set 'space', 'is big'

			clone = @model.clone()
			clone.get('space').should.equal 'is big'
			@model.get('space').should.equal 'is big'

			clone.set 'space', 'is infinite'
			@model.get('space').should.equal 'is big'
			clone.get('space').should.equal 'is infinite'

		it 'should set properties', ->
			@model.set
				name: 'test'
				value: 42

			@model.get('name').should.equal 'test'

		it 'should unset properties', ->
			@model.set
				color: 'red'

			@model.get('color').should.eql 'red'
			@model.unset 'color'
			should.equal @model.get('color'), undefined

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
			class VectorPosition extends smackbone.Model

				toPositionString: ->
					"#{@get('x')}:#{@get('y')}"

			class Airplane extends smackbone.Model
				models:
					position: VectorPosition

			airplane = new Airplane
				position:
					x: 422
					y: -10

			position = airplane.get('position')
			position.should.be.an.instanceof VectorPosition
			position.toPositionString().should.eql '422:-10'

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

		it 'should not replace models, even when they are in a hierarchy', ->
			age = new smackbone.Model
				years: 43

			car = new smackbone.Model
				age: age

			@model.set 'car', car

			@model.set
				car:
					age:
						years: 99

			age.get('years').should.equal(99)

		it 'should produce toJSON() objects', ->
			age = new smackbone.Model
				years: 43

			car = new smackbone.Model
				age: age

			@model.set 'car', car

			@model.set
				car:
					age:
						years: 99

			age.get('years').should.equal(99)

			json = JSON.stringify @model.toJSON()
			json.should.equal '{"car":{"age":{"years":99}}}'

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

		it 'should report path for multiple sub models', ->
			first = new smackbone.Model
			second = new smackbone.Model

			first.set
				second: second

			@model.set
				first: first

			second.path().should.eql '/first/second'

		it 'should report path for newly created models', ->
			@model.path().should.eql ''

		it 'should create models from hierarchy', ->
			class Flower extends smackbone.Model

			class Flowers extends smackbone.Collection
				model: Flower

				flowerCount: ->
					@length

			class Garden extends smackbone.Model
				models:
					flowers: Flowers

				numberOfFlowers: ->
					@get('flowers').flowerCount()


			class Gardens extends smackbone.Collection
				model: Garden

			owner = new smackbone.Model
			owner.models =
				gardens: Gardens

			owner.set
				gardens: [
					id: -1
					flowers: [
						id: 10
						name: 'rose'
					,
						id: 96
						name: 'tulip'
					]
				,
					id: 2
					flowers: [
						id: 0
						name: 'sunflower'
					,
						id: 1
						name: 'orchid'
					,
						id: 4
						name: 'dahlia'
					]

				]
				name: 'peter'

			gardens = owner.get('gardens')
			gardens.should.be.instanceof Gardens

			garden = owner.get('gardens').get('-1')
			garden.should.be.instanceof Garden
			garden.numberOfFlowers().should.equal 2

			garden = owner.get('gardens').get('2')
			garden.should.be.instanceof Garden
			garden.numberOfFlowers().should.equal 3

			dahlia = owner.get('gardens').get('2').get('flowers').get(4)
			dahlia.get('name').should.equal 'dahlia'

		it 'should be able to overwrite a property with another model', ->
			first = new smackbone.Model
				name: 'firstOne'
			@model.set 'object', first
			@model.get('object').should.equal first

			second = new smackbone.Model
				speed: 33

			@model.set 'object', second
			@model.get('object').should.equal second

		it 'should reset', ->
			@model.set 'hello', 'world'
			@model.get('hello').should.equal 'world'
			@model.reset()
			should.equal @model.get('hello'), undefined

		it 'should reset with values', ->
			@model.set 'hello', 'world'
			@model.get('hello').should.equal 'world'
			@model.reset
				hello: 'new value'
			@model.get('hello').should.equal 'new value'

		it 'should detect change', (done) ->
			count = 0
			@model.on 'change:rabbit', (rabbit) ->
				count += 1
				if count is 2
					should.equal rabbit, null
					done()

			model = new smackbone.Model
			@model.set 'rabbit', model
			@model.set 'rabbit', null

		it 'should handle setting undefined', ->
			@model.set 'rabbit', 2
			@model.set 'rabbit', undefined
			should.equal @model.get 'rabbit', undefined

		it 'can return sub models from path', ->
			@model.set
				desk:
					computer:
						monitor:
							size: '24 inch'
			@model.get('desk/computer/monitor/size').should.equal '24 inch'

		it 'should handle changes to id', ->
			@model.set
				name: 'kalle'

			@model.set
				id: 4
				name: 'kalle'

			@model.get('id').should.equal 4
			@model.id.should.equal 4

			@model.set
				id: 6
				name: 'test'

			@model.get('id').should.equal 6
			@model.id.should.equal 6

		it 'should not include transient properties in toJSON', ->
			@model.set 'important', 44
			@model.set 'not_important', 'temp'

			@model.toJSON().important.should.equal 44
			@model.toJSON().not_important.should.equal 'temp'
			@model.transients =
				not_important: true
			@model.toJSON().important.should.equal 44
			should.equal @model.toJSON().not_important, undefined
