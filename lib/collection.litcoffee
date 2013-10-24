
	class Smackbone.Collection extends Smackbone.Model
		create: (object) ->
			model = @_createModelFromName object.id, object
			@set model
			model.save()
			model

		set: (key, value) ->

If the receiver is a collection, then it uses the id of the objects to set the properties.

			attributes = {}
			if value?
				(attributes = {})[key] = value
			else
				return if _.isEmpty key
				if _.isArray key
					array = key
				else
					array = [key]

				for o in array
					id = o[@idAttribute] ? o.cid
					throw new Error 'In collection you must have a valid id or cid' if not id?
					if not o._parent?
						o._parent = @
					attributes[id] = o

			delete attributes[@idAttribute]
			# console.log 'collection set', attributes
			super attributes


		each: (func) ->
			for object, x of @_properties
				func x

		toJSON: ->
			_.toArray super()
