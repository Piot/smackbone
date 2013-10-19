
	_ = require 'underscore'

	class exports.Model extends exports.Event

		constructor: (attributes, options) ->
			@_properties = {}
			properties = attributes ? {}
			@set properties
			@initialize? properties


		set: (key, value) ->
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

					current[name] = value

			for changeName in changedPropertyNames
				@trigger "change:#{changeName}", @, current[changeName]

			isChanged = changedPropertyNames.length > 0
			@trigger 'change', @ if isChanged


		get: (key) ->
			@_properties[key]


		unset: (key) ->
			model = @_properties[key]
			model?.trigger? 'unset', model


		fetch: ->
			@trigger 'fetch', @


		destroy: ->
			@trigger 'destroy', @
