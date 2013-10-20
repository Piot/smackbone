
	class Smackbone.Collection extends Smackbone.Model
		idAttribute = 'id'

		add: (object) ->
			@set object


		get: (object) ->
			if object.id?
				super object.id
			else if object.cid?
				super object.cid
			else
				super object

		_toModel: (object) ->
			if object instanceof Smackbone.Model
				object
			else
				klass = @model ? Smackbone.Model
				model = new klass object
				model[idAttribute] = object.id
				if object.cid?
					model.cid = object.cid
				model

		create: (object) ->
			model = @_toModel object
			model._parent = @
			@set model
			model.save()
			model

		_isExistingModel: (object) ->
			id = object[idAttribute]
			if id?
				existingModel = @get id
			if not existingModel?
				cid = object['cid']
				if cid?
					existingModel = @get cid
			existingModel?

		set: (objects) ->

 We have to check if it is called with an empty object from Model constructor

			return if _.isEmpty objects

			objects = if _.isArray(objects) then objects else [objects]


			for object in objects
				if not @_isExistingModel object
					model = @_toModel object
				else
					model = object

				model._parent = @

				id = model[idAttribute]
				if id?
					super id, model
				else
					throw "An object in a collection must have an id or cid attribute" if not model.cid?
					super model.cid, model

		remove: (object) ->
			if object.id?
				@unset object.id
			else
				@unset object.cid

		toJSON: ->
			_.toArray super()
