
	class Smackbone.Syncer extends Smackbone.Event

		constructor: (options) ->
			@root = options.model
			@root.on 'fetch_request', @_onFetchRequest
			@root.on 'save_request', @_onSaveRequest
			@root.on 'destroy_request', @_onDestroyRequest

		_onFetchRequest: (path, model) =>
			options = {}
			options.type = 'GET'
			options.done = (response) =>
				model.set response
			@_request options, path

		_onSaveRequest: (path, model) =>
			options = {}
			options.type = if model.isNew() then 'POST' else 'PUT'
			options.data = model
			options.done = (response) =>
				model.set response
			@_request options, path

		_onDestroyRequest: (path, model) =>
			options = {}
			options.type = 'DELETE'
			options.data = model
			options.done = (response) =>
				model.reset()
			@_request options, path

		_request: (options, path) ->
			options.url = (@urlRoot ? '') + path
			options.data = JSON.stringify options.data?.toJSON()
			options.contentType = 'application/json'
			@trigger 'request', options
			Smackbone.$.ajax(options).done options.done
