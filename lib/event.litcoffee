

	class Smackbone.Event
		trigger: (name, args...) ->
			events = @_events?[name]
			@_triggerEvents events, args... if events?

			allEvents = @_events?.all
			@_triggerEvents allEvents, name, args... if allEvents?
			@

		on: (names, callback) ->
			@_events ?= {}
			throw new Error 'Must have a valid function callback' if not _.isFunction callback
			throw new Error 'Illegal event name' if /\s/g.test name 
			nameArray = names.split ' '
			for name in nameArray
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
