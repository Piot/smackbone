  ____                       _    _                      
 / ___| _ __ ___   __ _  ___| | _| |__   ___  _ __   ___
 \___ \| '_ ` _ \ / _` |/ __| |/ / '_ \ / _ \| '_ \ / _ \
  ___) | | | | | | (_| | (__|   <| |_) | (_) | | | |  __/
 |____/|_| |_| |_|\__,_|\___|_|\_\_.__/ \___/|_| |_|\___|

An attempt to make a more object oriented model framework.

# Installation

		npm install smackbone

# Usage
		smackbone = require("smackbone"); // AMD or CommonJS

## Model
Should hold the data (attributes) of the application. When a attribute is changed, it fires a change event and a keyed change event. It has support for transient properties.

**set** `set(attributes, [options])`
Sets the attributes according to input.

**unset** `unset(attribute, [options])`
Unsets all objects and performs a set with the attributes. See `set` function.

**reset** `reset(attributes, [options])`

**get** `get(attribute)`
Returns the value of the given attribute.

**path** `path()`
Returns the relative path for the model.

**clone** `clone()`
Returns a new but identical object.

**toJSON** `toJSON`
Returns an object literal containing the attributes.

**fetch** `fetch()`
Fetches the model from the backend (using one or more `Syncer`s). Triggers a GET request to the server.

**save** `save()`
Saves the model to the backend. Triggers a POST or PUT request to the server.

**destroy** `destroy()`
Destroys the model in the backend. Triggers a DELETE request to the server.

		sheep = new smackbone.Model();

		sheep.set("name", "Shaun");
		sheep.set({name: "Shaun", material: "Clay"});

		sheep.unset("name");

		sheep.get("name");

		dolly = sheep.clone();
		dolly.set("name", "Dolly");

		dolly.toJSON();

		sheep.fetch();

		sheep.save();

		sheep.destroy();

## Collection
An ordered set of models. It fires add and remove events when adding and removing. You can populate it by adding single models, arrays of objects or model hierarchies. It inherits from `Model`, so all functions available on `Model` can be called on a `Collection`.

**add** `add(model)`
Adds the model to the collection. The key used is the .id attribute if it is present, otherwise the internal .cid attribute.

**remove** `remove(model)`
Removes the model from the collection.

**each** `each(func)`
Calls the function for each model stored with set.

**contains** `contains(attribute)`
Checks if the specified model or id is stored in the collection.

**isEmpty** `isEmpty()`
Returns true if it doesn't contain any objects.

**at** `at(index)`
Fetches an object at the given index (in the order that they were set or added).

**first** `first()`
Returns the first object stored in the model.

**last** `last()`
Returns the last object stored in the model.

**toJSON** `toJSON()`
Returns a copy of the stored objects that is useful for serialization (e.g. JSON.stringify).

		collection = new smackbone.Collection();
		model = new smackbone.Model();

		@collection.add(model);

		@collection.remove(model);

		collection.each(function(object) {
			console.log("object:", object);
		});

		collection.contains(model);

		collection.isEmpty();

		collection.at(0);

		collection.first();

		collection.last();

		collection.toJSON();

## Event
Use to enable triggering and binding of custom events.

		class EventEmitter extends smackbone.Event
		emitter = new EventEmitter


**on** `on("event", callback)`
Adds the callback for the specified event. The event string can contain multiple space-separated event names.


**off** `off([event], [callback])`
Removes the callback for the specified event. If no callback is specified, then all callbacks for that event is removed. If event isn't specified, all callbacks are removed for this object.

**trigger** `trigger("event"[,args...])`
Triggers the callbacks for the specified event.

		emitter.on("event", function(data) {
			console.log("data:", data);
		});
		emitter.trigger("event");
		emitter.off("event");

## Syncer
Performs sync to and from the backend. The sync commands are `fetch`, `save` and `destroy`.

	cat = new Model({id:42});
	var syncer = new Syncer({model: cat});
	syncer.urlRoot = "http://some.server:32000/cats";
	cat.fetch(); // Fetches the cat with id 42
