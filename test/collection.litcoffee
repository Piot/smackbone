
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
			should.equal returnedModel, undefined

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
			should.equal returnedModel, undefined

		it 'should report path for newly added models', ->
			model = new smackbone.Model
			@collection.add model
			model.path().should.eql '/'

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
			should.equal @collection.get(model), undefined

		it 'should report event when removed', (done) ->
			model = new smackbone.Model
			model.on 'remove', ->
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

			class Flower

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

			garden = @collection.get(0)
			garden.should.be.an.instanceof Garden
			garden.flowers.should.be.an.instanceof Flowers
			tulip = garden.flowers.get('96')
			tulip.should.be.an.instanceof Flower
			garden.numberOfFlowers().should.equal 2


		it 'should create models and issue a save request', (done) ->
			class Toy extends smackbone.Model
			@collection.model = Toy

			@collection.on 'save_request', (path, model) =>
				model.should.instanceof Toy
				path.should.equal '/'
				model.get('name').should.equal 'ambulance'
				should.strictEqual model.get('id'), undefined
				@collection.get(model).should.equal model
				done()

			model = @collection.create
				name: 'ambulance'

		it 'should check contains', ->
			model = new smackbone.Model
			@collection.contains(model).should.be.false
			@collection.add model
			@collection.contains(model).should.be.true

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

			@collection.model = WrongClass
			@collection.add light
			@collection.set
				id: 1
				position:
					x: 20
					y: 20

			fetchedLight = @collection.get(1)
			fetchedPosition = fetchedLight.get('position')
			fetchedPosition.should.be.instanceof Position
			fetchedPosition.get('x').should.equal 20

