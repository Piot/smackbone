
	class Smackbone.Syncer extends Smackbone.Event
		constructor: (options) ->
			@root = options.model
			@root.on 'fetch_request', @_onFetchRequest
			@root.on 'save_request', @_onSaveRequest
			@root.on 'destroy_request', @_onDestroyRequest

		_onFetchRequest: (path, model, queryObject, options) =>
			options = options ? {}
			request =
				type: 'GET'
				done: (response) =>
					method = if options.reset then 'reset' else 'set'
					model[method] response
			_.extend request, options
			@_request request, path, queryObject

		_onSaveRequest: (path, model) =>
			options =
				type: if model.isNew() then 'POST' else 'PUT'
				data: model
				done: (response) =>
					model.set response
			@_request options, path

		_onDestroyRequest: (path, model) =>
			options =
				type: 'DELETE'
				data: model
				done: (response) =>
					model.reset()
			@_request options, path

		_encodeQueryObject: (queryObject) ->
			array = ("#{key}=#{value}" for key, value of queryObject)
			if array.length then encodeURI('?' + array.join('&')) else ''

		_request: (options, path, queryObject) ->
			queryString = @_encodeQueryObject queryObject
			options.url = (@urlRoot ? '') + path + queryString
			if options.type is 'GET'
				options.data = undefined
			else
				options.data = JSON.stringify options.data?.toJSON()

			options.contentType = 'application/json'
			@trigger 'request', options
			Smackbone.$.ajax(options).done options.done
