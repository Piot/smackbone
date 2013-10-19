
	_ = require 'underscore'

	class exports.Collection extends exports.Model

		add: (object) ->
			@set object


		get: (object) ->
			if object.id?
				super object.id
			else if object.cid?
				super object.cid
			else
				super object


		set: (objects) ->

 We have to check if it is called with an empty object from Model constructor

			return if _.isEmpty objects

			objects = if _.isArray(objects) then objects else [objects]

			idAttribute = 'id'

			for object in objects
				id = object[idAttribute]
				if id?
					super id, object
				else
					model = object
					throw "illegal" if not model.cid?
					super model.cid, model


		remove: (object) ->
			if object.id?
				@unset object.id
			else
				@unset object.cid

		toJSON: ->
			_.toArray super()
