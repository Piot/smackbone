
	_ = require 'underscore'

	class exports.Model extends exports.Event

		constructor: (attributes, options) ->
			@_properties = {}
			@cid = _.uniqueId 'm'

			properties = attributes ? {}
			@set properties
			@initialize? properties

		toJSON: ->
			@_properties

		set: (key, value) ->
			return if not key?

			idAttribute = 'id'
			if typeof key is 'object'
				attributes = key
				options = value
			else
				(attributes = {})[key] = value

			@_previousProperties = _.clone @_properties
			current = @_properties
			previous = @_previousProperties
			
			changedPropertyNames = []
			@changed = {}

			for name, value of attributes
				if name is idAttribute
					@[idAttribute] = value

				if current[name] isnt value
					changedPropertyNames.push name

				if previous[name] isnt value
					@changed[name] = value

				if current[name]?.set?
					current[name].set value
				else 
					if not current[name]?
						modelClass = @models?[name]
						if modelClass?
							value = new modelClass value
	
					if value instanceof exports.Model
						if not value._parent?
							value._parent = @
							value.id = name
							@[name] = value

					current[name] = value

			for changeName in changedPropertyNames
				@trigger "change:#{changeName}", @, current[changeName]

			isChanged = changedPropertyNames.length > 0
			@trigger 'change', @ if isChanged
			value

		get: (key) ->
			@_properties[key]


		unset: (key) ->
			model = @_properties[key]
			delete @_properties[key]
			model?.trigger? 'unset', model
			model?.trigger? 'remove', model

		path: ->
			if @_parent?
				prefix = @_parent.path()
				"#{prefix}/#{@id}"
			else
				@rootPath ? ''

		fetch: ->
			@trigger 'fetch', @


		destroy: ->
			@trigger 'destroy', @

		each: (func) ->
			for object, x of @_properties
				func x
