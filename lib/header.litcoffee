
	if exports?
		Smackbone = exports
		_ = require 'underscore'
		Smackbone.$ =
			done: (func) ->
				func {}

			ajax: (options) ->
				# console.log "method:#{options.type} url:#{options.url}"
				@
	else
		root = this
		_ = root._
		Smackbone = root.Smackbone = {}
		Smackbone.$ = root.$
