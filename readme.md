	     _______..___  ___.      ___       ______  __  ___ .______     ______   .__   __.  _______
	    /       ||   \/   |     /   \     /      ||  |/  / |   _  \   /  __  \  |  \ |  | |   ____|
	   |   (----`|  \  /  |    /  ^  \   |  ,----'|  '  /  |  |_)  | |  |  |  | |   \|  | |  |__
	    \   \    |  |\/|  |   /  /_\  \  |  |     |    <   |   _  <  |  |  |  | |  . `  | |   __|
	.----)   |   |  |  |  |  /  _____  \ |  `----.|  .  \  |  |_)  | |  `--'  | |  |\   | |  |____
	|_______/    |__|  |__| /__/     \__\ \______||__|\__\ |______/   \______/  |__| \__| |_______|

An attempt to make a more object oriented model framework.

### Installation

		npm install smackbone

### Event
The ability to trigger events and add and remove listeners.

**on** `on(event, callback)`
Adds the callback function for the event specified. The event string can contain multiple space-separated event names.

**off** `off([event], [callback])`
Removes the callback for the specified event. If no callback is specified, then all callbacks for that event is removed. If event isn't specified, all callbacks are removed for this object.

**trigger** `trigger(event[,args...])`

### Model

**set** `set(attributes, [options])`

*Example*

		cat.set("name", "Ella");

		cat.set({name: "Ella"});

**unset** `unset(attribute, [options])`

*Example*

		cat.unset("name");

**reset** `reset(attributes, [options])`
Unsets all objects and performs a set with the attributes. See `set` function.

**get** `get(attribute)`
Returns the object with the specified attribute or id.

*Example*

		cat.get("name");

		cat.get(1337);

**path** `path()`
Returns the relative path for the model.

### Collection
**each** `each(func)`
Calls the function for each object stored with set.

*Example*

		cat.each(function(object) {
			console.log("object:", object);
		});

**contains** `contains(attribute)`
Checks if the specified attribute or id is stored in the model.

**isEmpty** `isEmpty()`
Returns true if it doesn't contain any objects.

**at** `at(index)`
Fetches a object from the index (in the order that they were set or added).

**first** `first()`
Returns the first object stored in the model.

**last** `last()`
Returns the last object stored in the model.

#### Sync

**fetch** `fetch()`
Fetches the model from the backend (using one or more `Syncer`s).

**save** `save()`
Saves the model to the backend.

**destroy** `destroy()`
Destroys the model in the backend.

#### Other

**toJSON** `toJSON()`
Returns a copy of the stored objects that is useful for serialization (e.g. JSON.stringify).

#### Collection
Inherits from `Model`, so all functions available on `Model` can be called on a `Collection`.

**add** `add(model)`
Adds the model to the collection. The key used is the .id attribute if it is present, otherwise the internal .cid attribute.

**remove** `remove(model)`
Removes the model from the collection.

### Syncer
Performs sync to and from the backend. The sync commands are `fetch`, `save` and `destroy`.

*Example*

	cat = new Model({id:42});
	var syncer = new Syncer({model: cat});
	syncer.urlRoot = "http://some.server:32000/cats";
	cat.fetch(); // Fetches the cat with id 42
