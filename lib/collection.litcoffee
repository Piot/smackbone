
	class Smackbone.Collection extends Smackbone.Model

		create: (object) ->
			model = @_createModelFromName object.id, object
			@set model
			model.save()
			model

If the receiver is a collection, then it uses the id of the objects to set the properties.

		set: (key, value) ->
			if value?
				(attributes = {})[key] = value
			else
				array = if _.isArray key then array = key else array = [key]

				attributes = {}
				for o in array
					id = o[@idAttribute] ? o.cid
					throw new Error 'In collection you must have a valid id or cid' if not id?
					if not o._parent?
						o._parent = @
					attributes[id] = o

			super attributes
		
		toJSON: ->
			_.toArray super()
