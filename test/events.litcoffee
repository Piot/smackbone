
	smackbone = require '../out/smackbone'
	should = require 'should'

	describe 'events', ->
		beforeEach ->
			@event = new smackbone.Event

		it 'should add events', ->
			@event.on 'something', (data) ->
			@event._events.something.length.should.equal(1)

		it 'should fire events', (done) ->
			@event.on 'something', (name) ->
				name.should.equal 'world'
				done()

			@event.trigger 'something', 'world'

		it 'should not listen', (done) ->
			@event.on 'something_else', (name) ->
				done "Error!"

			@event.off 'something_else'
			@event.trigger 'something_else', 'name'
			done()

		it 'should listen to correct event', (done) ->
			@event.on 'do_it', (name) ->
				done 'Wrong argument' if name isnt 'worked!'

			@event.on 'wrong', (name) ->
				done 'Listened to wrong argument'

			@event.trigger 'do_it', 'worked!'
			done()

		it 'should listen to correct event not depending on order', (done) ->
			@event.on 'wrong', (name) ->
				done 'Listened to wrong argument'

			@event.on 'do_it', (name) ->
				done 'Wrong argument' if name isnt 'worked!'

			@event.trigger 'do_it', 'worked!'
			done()

		it 'should not listen to anything', (done) ->
			@event.on 'something', ->
				done 'Should not have been listening'

			@event.off()
			@event.trigger 'something'
			done()

		it 'should trigger multiple listeners', (done) ->
			first = false
			second = false
			@event.on 'something', ->
				done 'triggered first multiple times' if first
				first = true

			@event.on 'something', ->
				done 'first did not receive it' if not first
				done 'triggered second multiple times' if second
				second = true

			@event.trigger 'something'

			done 'did not trigger' if not first or not second
			done()


		it 'should remove a specific listener', (done) ->
			secondWasTriggered = false

			first = ->
				done 'first should not be called'

			second = ->
				secondWasTriggered = true
				done()

			@event.on 'something', first
			@event.on 'something', second
			@event.off 'something', first
			@event.trigger 'something', 'tjoho'
			done 'did not trigger' if not secondWasTriggered

		it 'should report all events', (done) ->
			@event.on 'all', (method, param) ->
				if method is 'something' and param is 'hello'
					done()
				else
					done 'wrong parameter called'

			@event.trigger 'something', 'hello'

		it 'should be safe to trigger without listeners', ->
			event = @event
			(->
				event.trigger 'not_existing'
			).should.not.throwError()

		it 'should handle event names with spaces', ->
			event = @event
			(->
				event.on 'spaces are bad for you', ->
			).should.throwError 'Illegal event name'

		it 'should handle multiple triggers', ->
			count = 0
			@event.on 'multiple', ->
				count++

			@event.trigger 'multiple'
			@event.trigger 'multiple'
			@event.trigger 'not correct'
			@event.trigger 'multiple'
			count.should.equal(3) 
