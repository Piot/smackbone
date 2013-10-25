
	class Smackbone.Model extends Smackbone.Event

		constructor: (attributes, options) ->
			@_properties = {}
			@cid = _.uniqueId 'm'
			@length = 0
			@idAttribute = 'id'
			@changed = {}
			@set attributes if attributes?
			if @models?
				for key, modelClass of @models
					if not @contains key
						@set key, new modelClass {}
			@initialize? attributes

		toJSON: ->
			_.clone @_properties

		isNew: ->
			not @[@idAttribute]?

		clone: ->
			new @constructor @_properties

		_createModelFromName: (name, value) ->
			modelClass = @models?[name] ? @model
			if modelClass? then new modelClass value else value

		move: (currentId, nextId) ->
			o = @get currentId
			throw new "Id '#{currentId}' didn't exist." if not o?
			@unset currentId
			@set nextId, o

		set: (key, value) ->
			throw new Error 'can not set with undefined' if not key?

			if typeof key is 'object'
				attributes = key
			else
				(attributes = {})[key] = value

			if attributes[@idAttribute]?
				@[@idAttribute] = attributes[@idAttribute]
				if not @_properties[@idAttribute]
					@_parent?.move @cid, @id

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

				if current[name]?.set? and not (value instanceof Smackbone.Model) and value?
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
			throw new Error 'Must have a valid object for get()' if not key?
			@_properties[key[@idAttribute] ? key.cid ? key]

		unset: (key) ->
			key = key[@idAttribute] ? key.cid ? key
			model = @_properties[key]
			delete @_properties[key]
			@length = _.keys(@_properties).length
			model?.trigger? 'unset', model
			@trigger 'remove', model, @

		path: ->
			if @_parent? then "#{@_parent.path()}/#{@[@idAttribute] ? ''}" else @rootPath ? ''

		_root: ->
			model = @
			while model._parent?
				model = model._parent
			model

		fetch: (queryObject) ->
			@_root().trigger 'fetch_request', @path(), @, queryObject
			@trigger 'fetch', @, queryObject

		save: ->
			@_root().trigger 'save_request', @path(), @
			@trigger 'save', @

		destroy: ->
			@trigger 'destroy', @
			if not @isNew()
				@_root().trigger 'destroy_request', @path(), @
			@_parent?.remove @

		reset: (a, b) ->
			@unset key for key, value of @_properties
			@set a, b if a?

		isEmpty: ->
			@length is 0
