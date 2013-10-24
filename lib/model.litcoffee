
	class Smackbone.Model extends Smackbone.Event

		constructor: (attributes, options) ->
			@_properties = {}
			@cid = _.uniqueId 'm'
			@length = 0
			@idAttribute = 'id'
			@changed = {}
			properties = attributes ? {}
			@set properties
			@initialize? properties

		toJSON: ->
			_.clone @_properties

		isNew: ->
			not @id?

		clone: ->
			new @constructor @_properties

		_createModelFromName: (name, value) ->
			modelClass = @models?[name]
			if not modelClass?
				modelClass = @model

			if modelClass?
				result = new modelClass value
			else
				result = value
			result

		set: (key, value) ->
			return if not key?

			if not value?
				return if _.isEmpty key
				if _.isArray key
					array = key
				else
					array = [key]

				attributes = {}
				for o in array
					_.extend attributes, o
			else
				(attributes = {})[key] = value

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

				if current[name]?.set?
					if value instanceof Smackbone.Model
						current[name] = value
					else
						existingObject = current[name]
						existingObject.set value
				else
					if not current[name]?
						if not (value instanceof Smackbone.Model)
							value = @_createModelFromName name, value

					current[name] = value
					@length = _.keys(current).length

					if value instanceof Smackbone.Model
						if not value._parent?
							value._parent = @
							value[@idAttribute] = name

						@trigger 'add', value, @

			for changeName in changedPropertyNames
				@trigger "change:#{changeName}", @, current[changeName]

			isChanged = changedPropertyNames.length > 0
			@trigger 'change', @ if isChanged

		contains: (key) ->
			@get(key)?

		add: (object) ->
			@set object

		remove: (object) ->
			if object.id?
				@unset object.id
			else
				@unset object.cid

		get: (key) ->
			if key.id?
				key = key.id
			else if key.cid?
				key = key.cid

			@_properties[key]

		unset: (key) ->
			model = @_properties[key]
			delete @_properties[key]
			@length = _.keys(@_properties).length
			model?.trigger? 'unset', model
			@trigger 'remove', model, @

		path: ->
			if @_parent?
				prefix = @_parent.path()
				"#{prefix}/#{@id ? ''}"
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
