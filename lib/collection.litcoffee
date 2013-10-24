
	class Smackbone.Collection extends Smackbone.Model
		constructor: (args...) ->
			@_requiresIdForMembers = true
			super args...

		create: (object) ->
			model = @_createModelFromName object.id, object
			@set model
			model.save()
			model

		each: (func) ->
			for object, x of @_properties
				func x

		toJSON: ->
			_.toArray super()
