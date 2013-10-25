
	class Smackbone.Model extends Smackbone.Event

		constructor: (attributes, options) ->
			@_properties = {}
			@cid = _.uniqueId 'm'
			@length = 0
			@idAttribute = 'id'
			@changed = {}
			@set attributes if attributes?
			@initialize? attributes

		toJSON: ->
			_.clone @_properties

		isNew: ->
			not @[@idAttribute]?

		clone: ->
			new @constructor @_properties

		_createModelFromName: (name, value) ->
			modelClass = @models?[name] ? @model
			if modelClass?
				new modelClass value
			else
				value

		set: (key, value) ->
			throw new Error 'can not set with undefined' if not key?
			if value?
				(attributes = {})[key] = value
			else
				attributes = key

			if attributes[@idAttribute]?
				@[@idAttribute] = attributes[@idAttribute]

			@_previousProperties = _.clone @_properties
			current = @_properties
			previous = @_previousProperties

			changedPropertyNames = []
			@changed = {}

			for name, value of attributes
				if current[name] isnt value
					changedPropertyNames.push name

				if previous[name] isnt value
					@changed[name] = value

				if current[name]?.set? and not (value instanceof Smackbone.Model)
					existingObject = current[name]
					existingObject.set value
				else
					if not (value instanceof Smackbone.Model)
						value = @_createModelFromName name, value
					current[name] = value
					@length = _.keys(current).length

					if value instanceof Smackbone.Model and not value._parent?
						value._parent = @
						if not value[@idAttribute]?
							value[@idAttribute] = name

					@trigger 'add', value, @

			for changeName in changedPropertyNames
				@trigger "change:#{changeName}", @, current[changeName]

			@trigger 'change', @ if changedPropertyNames.length > 0

		contains: (key) ->
			@get(key)?

		add: (object) ->
			@set object

		remove: (object) ->
			@unset object

		get: (key) ->
			@_properties[key[@idAttribute] ? key.cid ? key]

		unset: (key) ->
			key = key[@idAttribute] ? key.cid ? key
			model = @_properties[key]
			delete @_properties[key]
			@length = _.keys(@_properties).length
			model?.trigger? 'unset', model
			@trigger 'remove', model, @

		path: ->
			if @_parent?
				"#{@_parent.path()}/#{@[@idAttribute] ? ''}"
			else
				@rootPath ? ''

		_root: ->
			model = @
			while model._parent?
				model = model._parent
			model

		fetch: ->
			@_root().trigger 'fetch_request', @path(), @
			@trigger 'fetch', @

		save: ->
			@_root().trigger 'save_request', @path(), @
			@trigger 'save', @

		destroy: ->
			@trigger 'destroy', @
			if not @isNew()
				@_root().trigger 'destroy_request', @path(), @
			@_parent?.remove @

		reset: ->
			for key, value of @_properties
				@unset key
		
		isEmpty: ->
			@length is 0
