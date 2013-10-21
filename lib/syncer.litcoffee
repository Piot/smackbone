
	class Smackbone.Syncer extends Smackbone.Event

		constructor: (options) ->
			@root = options.model
			@root.on 'fetch_request', @_onFetchRequest
			@root.on 'save_request', @_onSaveRequest

		_onFetchRequest: (path) =>
			options = {}
			options.type = 'GET'
			options.done = (response) =>
				model = @_findModel path
				model.set response
			@_request options, path

		_findModel: (path) ->
			parts = (path.split '/')[1..-1]
			model = @root
			for part in parts
				model = model.get part
			model

		_onSaveRequest: (path, model) =>
			options = {}
			options.type = if model.isNew() then 'POST' else 'PUT'
			options.data = JSON.stringify model.toJSON()
			options.done = (response) =>
				model.set response
			@_request options, path

		_request: (options, path) ->
			options.url = (@urlRoot ? '') + path
			options.contentType = 'application/json'
			@trigger 'request', options
			Smackbone.$.ajax(options).done options.done
