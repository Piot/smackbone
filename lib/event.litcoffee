

	class exports.Event
		trigger: (name, args...) ->
			events = @_events?[name]
			@_triggerEvents events, args... if events?

			allEvents = @_events?.all
			@_triggerEvents allEvents, name, args... if allEvents?
			@

		on: (name, callback) ->
			@_events ?= {}
			throw Error 'Illegal event name' if /\s/g.test name 
			events = @_events[name] or @_events[name] = []
			events.push
				callback: callback
				self: @
			@

		off: (name, callback) ->
			if not callback?
				@_events = {}
				return @

			events = @_events[name]
			names = if name then [name] else (key for key in @_events)

			for name in names
				newEvents = []
				@_events[name] = newEvents
				for event in events
					if callback isnt event.callback
						newEvents.push event
				
				if newEvents.length is 0
					delete @_events[name] 
			@

		_triggerEvents: (events, args...) ->
			for event in events
				event.callback args...
