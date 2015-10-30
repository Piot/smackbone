
	smackbone = require '../out/smackbone'
	should = require 'should'

	describe 'collection', ->
		beforeEach ->
			@collection = new smackbone.Collection

		it 'should hold models', ->
			model = new smackbone.Model
			@collection.add model

			returnedModel = @collection.get model
			returnedModel.should.equal.model

			returnedModel = @collection.get 2
			should.not.exist returnedModel

		it 'should hold the right amount of models', ->
			model = new smackbone.Model
				id: 128
				distance: 99.3
			@collection.length.should.equal 0
			@collection.add model
			@collection.length.should.equal 1
			returnedModel = @collection.get model
			returnedModel.should.equal.model

			@collection.set
				id: 128
				distance: 42.2

			count = 0
			@collection.each (distanceObject) ->
				distanceObject.get('distance').should.equal 42.2
				count += 1

			count.should.equal 1

			@collection.length.should.equal 1
			returnedModel = @collection.get 128
			returnedModel.should.equal.model
			returnedModel.get('distance').should.equal 42.2
			returnedModel = @collection.remove returnedModel
			@collection.length.should.equal 0
			returnedModel = @collection.get 128
			should.not.exist returnedModel

		it 'should report path for newly added models', ->
			model = new smackbone.Model
			model.path().should.eql ''

		it 'should fire add event for added models', (done) ->
			model = new smackbone.Model
			@collection.on 'add', (addedModel, addedToCollection) =>
				addedModel.should.equal model
				addedToCollection.should.equal @collection
				done()
			@collection.add model

		it 'should fire remove event for removed models', (done) ->
			model = new smackbone.Model
			@collection.on 'remove', (addedModel, addedToCollection) =>
				addedModel.should.equal model
				addedToCollection.should.equal @collection
				done()
			@collection.add model
			@collection.remove model

		it 'should report path for newly added model in a sub collection', ->
			root = new smackbone.Model
			car = new smackbone.Model
			cars = new smackbone.Collection
			cars.add car
			root.set 'cars', cars
			car.path().should.eql '/cars/'

		it 'should update existing models', ->
			vehicle = new smackbone.Model
			vehicle.set 'wheels', @collection

			wheel1 = new smackbone.Model
				id: 1
				radius: -2.0
			wheel1.secret = 1337
			@collection.add wheel1

			wheel2 = new smackbone.Model
				id: 2
				radius: -1.0
			@collection.add wheel2

			@collection.set [{id:2, radius:2}, {id:1, radius:4}]

			wheel1.get('radius').should.equal 4
			wheel1.secret.should.equal 1337
			@collection.get(2).get('radius').should.equal 2

		it 'should remove models', ->
			model = new smackbone.Model
			@collection.add model
			@collection.get(model).should.equal model
			@collection.remove model
			should.not.exist @collection.get(model)

		it 'should report event when removed', (done) ->
			model = new smackbone.Model
			model.on 'unset', ->
				done()

			@collection.add model
			@collection.remove model

		it 'should report a correct path', ->
			flower = new smackbone.Model
				id: 'wallflower'

			root = new smackbone.Model
				flowers: @collection

			@collection.add flower
			flower.path().should.equal '/flowers/wallflower'

		it 'should report a correct json', ->
			flower = new smackbone.Model
				id: '128'
				name: 'tulip'

			root = new smackbone.Model
				flowers: @collection

			@collection.add flower
			json = JSON.stringify root.toJSON()
			json.should.equal '{"flowers":[{"id":"128","name":"tulip"}]}'

		it 'should be possible to enumerate', ->
			model = new smackbone.Model
				id: 'test1'

			model2 = new smackbone.Model
				id: 'test2'

			@collection.add model2
			@collection.add model

			ids = []
			@collection.each (model) ->
				ids.push model.id

			ids.should.eql ['test2', 'test1']

		it 'should create models from array', ->
			class PriceTag
				constructor: (data) ->
					@price = data.price

				priceWithTax: ->
					@price * 1.5

			data = [
				id: 1
				price: 3.5
			,
				id: 4
				price: 100.0
			]
			@collection.model = PriceTag

			@collection.set data
			@collection.get(4).priceWithTax().should.equal 150.0

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

			@collection.model = Garden

			smackbone.Model.debug = true
			@collection.set [
				id: 0
				flowers: [
					id: 10
					name: 'rose'
				,
					id: 96
					name: 'tulip'
				]
			]
			smackbone.Model.debug = false

			garden = @collection.get(0)
			garden.should.be.an.instanceof Garden
			garden.get('flowers').should.be.an.instanceof Flowers
			tulip = garden.get('flowers').get('96')
			tulip.should.be.an.instanceof Flower
			garden.numberOfFlowers().should.equal 2

		it 'should create models and issue a save request', (done) ->
			class Toy extends smackbone.Model
			@collection.model = Toy
			@collection.on 'save_request', (path, model) =>
				model.should.instanceof Toy
				path.should.equal '/'
				model.get('name').should.equal 'ambulance'
				should.not.exist model.get('id')
				@collection.get(model).should.equal model
				done()

			model = @collection.create
				name: 'ambulance'

		it 'should be able to check if it contains models or model ids', ->
			model = new smackbone.Model
				id: 1

			@collection.contains(model).should.be.false
			@collection.add model
			@collection.contains(model).should.be.true
			@collection.contains(1).should.be.true
			@collection.contains(2).should.be.false

		it 'should not overwrite sub models from collection model class', ->
			class WrongClass extends smackbone.Model
			class Position extends smackbone.Model
				currentPosition: ->
					p =
						x: @get('x')
						y: @get('y')

			class Light extends smackbone.Model

			position = new Position
				x: 10
				y: 10

			light = new Light
				id: 1
			light.set 'position', position
			position.klass = 'position'

			@collection.model = WrongClass
			@collection.add light
			fetchedLight = @collection.get(1)
			fetchedLight.should.be.instanceof Light

			@collection.set
				id: 1
				position:
					x: 20
					y: 20

			fetchedLight = @collection.get(1)
			fetchedPosition = fetchedLight.get('position')
			fetchedPosition.should.be.instanceof Position
			fetchedPosition.get('x').should.equal 20

Not so sure about the usefulness of adding objects to a collection where their id is unknown.
You can not lookup a specific object after it is added, only enumerate the collection.

		it 'should be possible to add a simple object without id to collection', (done) ->
			@collection.add
				test: 42
				name: 'something'

			model = @collection._properties[undefined]
			should.not.exist model
			@collection.each (model) ->
				model.get('test').should.equal 42
				done()

		it 'should save with only one id in collection', ->
			model = new smackbone.Model
			cid = model.cid
			@collection.add model
			@collection.get(cid).should.equal model
			model.set
				id: 4
			should.not.exist @collection.get cid
			@collection.get(model.id).should.equal model
			model.id?.should.be.ok

		it 'can return sub models from path', ->
			car = new smackbone.Model
				id: 256
				make: 'sportscar'
			collection = new smackbone.Collection
			collection.add car
			@collection.set 'cars', collection
			@collection.get("cars/#{car.id}/make").should.be.equal 'sportscar'
			@collection.get('cars').should.be.equal collection

		it 'triggers reset', (done) ->
			@collection.on 'reset', =>
				@collection.get(replacedDiamond).get('carat').should.equal 900
				done()

			originalDiamond = new smackbone.Model
				carat: 800

			replacedDiamond = new smackbone.Model
				carat: 900

			@collection.add originalDiamond
			@collection.reset replacedDiamond

		it 'should create models depending on type field', ->
			class Planet extends smackbone.Model
				myName: ->
					@get 'name'

			@collection.classField = 'type'
			@collection.modelClasses =
				Planet: Planet

			@collection.add
				id: 42
				type: 'Planet'
				name: 'earth'
			planet = @collection.get(42)
			planet.should.be.instanceof Planet
			planet.myName().should.equal 'earth'

		it 'should be able to access using index', ->
			lamp = new smackbone.Model
			sun = new smackbone.Model

			should.not.exist @collection.at 0
			should.not.exist @collection.at 1

			@collection.add sun
			@collection.at(0).should.equal sun
			should.not.exist @collection.at 1

			@collection.add lamp
			@collection.first().should.equal sun
			@collection.at(1).should.equal lamp
			should.not.exist @collection.at 2

			@collection.remove sun
			@collection.at(0).should.equal lamp
			@collection.last().should.equal lamp

		it 'should set internal _parent', ->
			@collection.add
				type: 'moon'

			model = @collection.at 0
			model._parent.should.equal @collection

			jupiter = new smackbone.Model
			should.not.exist jupiter._parent
			@collection.add jupiter
			jupiter._parent.should.equal @collection

			anotherCollection = new smackbone.Collection
			anotherCollection.add jupiter

			jupiter._parent.should.equal @collection

		it 'should use specified model for objects without id', ->
			class Saturn extends smackbone.Model

			@collection.model = Saturn
			@collection.add
				temperature: 134

			@collection.first().should.be.instanceof Saturn

		it 'should accept empty object', ->
			@collection.add {}

		it 'should accept empty array', ->
			@collection.add []

		it 'should handle changes to id', ->
			@collection.add
				name: 'john'

			model = @collection.first()

			model.set
				id: 4
				name: 'paul'

			model.get('id').should.equal 4
			model.id.should.equal 4
			@collection.get(4).should.equal model

			model.set
				id: 6
				name: 'george'

			should.not.exist @collection.get 4
			model.get('id').should.equal 6
			model.id.should.equal 6
			@collection.get(6).should.equal model

		it 'should not trigger anything if silent is set', (done) ->
			@collection.on 'all', (e) ->
				done 'should not fire'

			data =
				name: 'hello, world'
			options =
				silent: true
			@collection.set [data], options

			done()

		it 'should handle an empty array replacement', ->
			@collection.add {id:43, something: 'world'}
			@collection.should.have.length 1
			@collection.get(43).something.should.equal 'world'
			@collection.set []
			@collection.should.have.length 1
			@collection.set [],
				triggerRemove: true
			@collection.should.have.length 0

		it 'should not report change on empty array replacement', ->
			@collection.on 'change', ->
				console.log 'fail!!'
				assert.fail()
			@collection.set [],
				triggerRemove: true

		it 'should handle an array replacement', ->
			@collection.add {id:43, something: 'world'}
			@collection.add {id:44, something: 'hello'}
			@collection.should.have.length 2
			@collection.get(43).something.should.equal 'world'
			@collection.set [{id:44, something: 'else'}]
			@collection.get(44).something.should.equal 'else'

			@collection.set [{id:44, something: 'else'}],
				triggerRemove: true
			@collection.first().something.should.equal 'else'
			@collection.should.have.length 1

		describe 'isEmpty', ->
			it 'should respond if its empty or not', ->
				@collection.isEmpty().should.be.true
				@collection.add smackbone.Model()
				@collection.isEmpty().should.be.false

		describe 'toJSON', ->
			it 'should respond with a correct object literal representation', ->
				leo =
					name: 'Leo'
					gender: 'male'
				noah =
					name: 'Noah'
					gender: 'male'
				@collection.add leo
				@collection.add noah

				json = JSON.stringify @collection.toJSON()
				json.should.eql '[{"name":"Leo","gender":"male"},{"name":"Noah","gender":"male"}]'
