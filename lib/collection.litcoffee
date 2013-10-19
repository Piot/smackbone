
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
			objects = if _.isArray(objects) then objects else [objects]

			idAttribute = 'id'

			for object in objects
				id = object[idAttribute]
				if id?
					super id, object

				if object instanceof exports.Model
					super object.cid, object


		remove: (object) ->
			if object.id?
				@unset object.id

			@unset object.cid

