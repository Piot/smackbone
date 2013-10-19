
	if exports?
		Smackbone = exports
		_ = require 'underscore'
	else
		root = this
		_ = root._
		Smackbone = root.Smackbone = {}

