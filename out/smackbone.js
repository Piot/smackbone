(function() {
  var Smackbone, _, root,
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (typeof exports !== "undefined" && exports !== null) {
    Smackbone = exports;
    _ = require('underscore');
    Smackbone.$ = {
      done: function(func) {
        return func({});
      },
      ajax: function(options) {
        return this;
      }
    };
  } else {
    root = this;
    _ = root._;
    Smackbone = root.Smackbone = {};
    Smackbone.$ = root.$;
  }

  Smackbone.Event = (function() {
    function Event() {}

    Event.prototype.trigger = function() {
      var allEvents, args, events, name, ref, ref1;
      name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      events = (ref = this._events) != null ? ref[name] : void 0;
      if (events != null) {
        this._triggerEvents.apply(this, [events].concat(slice.call(args)));
      }
      allEvents = (ref1 = this._events) != null ? ref1.all : void 0;
      if (allEvents != null) {
        this._triggerEvents.apply(this, [allEvents, name].concat(slice.call(args)));
      }
      return this;
    };

    Event.prototype.on = function(names, callback) {
      var events, j, len, name, nameArray;
      if (this._events == null) {
        this._events = {};
      }
      if (!_.isFunction(callback)) {
        throw new Error('Must have a valid function callback');
      }
      if (/\s/g.test(name)) {
        throw new Error('Illegal event name');
      }
      nameArray = names.split(' ');
      for (j = 0, len = nameArray.length; j < len; j++) {
        name = nameArray[j];
        events = this._events[name] || (this._events[name] = []);
        events.push({
          callback: callback,
          self: this
        });
      }
      return this;
    };

    Event.prototype.off = function(name, callback) {
      var event, events, j, k, key, l, len, len1, len2, names, newEvents, ref, ref1;
      if (this._events == null) {
        this._events = {};
      }
      if (callback == null) {
        this._events = {};
        return this;
      }
      ref = name.split(' ');
      for (j = 0, len = ref.length; j < len; j++) {
        name = ref[j];
        events = (ref1 = this._events[name]) != null ? ref1 : [];
        names = name ? [name] : (function() {
          var k, len1, ref2, results;
          ref2 = this._events;
          results = [];
          for (k = 0, len1 = ref2.length; k < len1; k++) {
            key = ref2[k];
            results.push(key);
          }
          return results;
        }).call(this);
        for (k = 0, len1 = names.length; k < len1; k++) {
          name = names[k];
          newEvents = [];
          this._events[name] = newEvents;
          for (l = 0, len2 = events.length; l < len2; l++) {
            event = events[l];
            if (callback !== event.callback) {
              newEvents.push(event);
            }
          }
          if (newEvents.length === 0) {
            delete this._events[name];
          }
        }
      }
      return this;
    };

    Event.prototype._triggerEvents = function() {
      var args, event, events, j, len, results;
      events = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      results = [];
      for (j = 0, len = events.length; j < len; j++) {
        event = events[j];
        results.push(event.callback.apply(event, args));
      }
      return results;
    };

    return Event;

  })();

  Smackbone.Model = (function(superClass) {
    extend(Model, superClass);

    function Model(attributes, options) {
      var key, modelClass, ref;
      this._properties = {};
      this.cid = _.uniqueId('m');
      this.length = 0;
      this.idAttribute = 'id';
      this.changed = {};
      this._indexToModel = [];
      if (attributes != null) {
        this.set(attributes);
      }
      if (this.models != null) {
        ref = this.models;
        for (key in ref) {
          modelClass = ref[key];
          if (!this.contains(key)) {
            this.set(key, new modelClass({}));
          }
        }
      }
      if (typeof this.initialize === "function") {
        this.initialize(attributes);
      }
    }

    Model.prototype.toJSON = function() {
      var key, properties;
      properties = _.clone(this._properties);
      for (key in this.transients) {
        delete properties[key];
      }
      return properties;
    };

    Model.prototype.isNew = function() {
      return this[this.idAttribute] == null;
    };

    Model.prototype.clone = function() {
      return new this.constructor(this._properties);
    };

    Model.prototype._createModelFromName = function(name, value, backupClass) {
      var modelClass, ref, ref1, ref2, ref3, ref4;
      modelClass = (ref = (ref1 = (ref2 = (ref3 = this.modelClasses) != null ? ref3[value[this.classField]] : void 0) != null ? ref2 : (ref4 = this.models) != null ? ref4[name] : void 0) != null ? ref1 : this.model) != null ? ref : backupClass;
      if (modelClass != null) {
        return new modelClass(value);
      } else {
        return value;
      }
    };

    Model.prototype.move = function(currentId, nextId) {
      var o;
      o = this.get(currentId);
      if (o == null) {
        throw new Error("Id '" + currentId + "' didn't exist.");
      }
      this.unset(currentId);
      return this.set(nextId, o);
    };

    Model.prototype.set = function(key, value, options) {
      var addedAttributes, attributes, changeName, changedPropertyNames, current, existingObject, j, k, l, len, len1, len2, n, name, oldId, previous, ref, ref1, ref2, removedAttributes, results, v;
      if (key == null) {
        throw new Error('can not set with undefined');
      }
      if (typeof key === 'object') {
        attributes = key;
        options = value;
        value = void 0;
      } else {
        (attributes = {})[key] = value;
      }
      if (attributes[this.idAttribute] != null) {
        oldId = this[this.idAttribute] || this.cid;
        this[this.idAttribute] = attributes[this.idAttribute];
        if ((ref = this._parent) != null) {
          ref.move(oldId, this[this.idAttribute]);
        }
      }
      this._previousProperties = _.clone(this._properties);
      current = this._properties;
      previous = this._previousProperties;
      changedPropertyNames = [];
      addedAttributes = [];
      removedAttributes = [];
      this.changed = {};
      ref1 = this._properties;
      for (name in ref1) {
        value = ref1[name];
        if (attributes[name] == null) {
          removedAttributes.push(name);
        }
      }
      for (name in attributes) {
        value = attributes[name];
        if (!_.isEqual(current[name], value)) {
          changedPropertyNames.push(name);
        }
        if (!_.isEqual(previous[name], value)) {
          this.changed[name] = value;
        }
        if ((((ref2 = current[name]) != null ? ref2.set : void 0) != null) && !(value instanceof Smackbone.Model) && (value != null)) {
          existingObject = current[name];
          existingObject.set(value, options);
        } else {
          if (!(value instanceof Smackbone.Model)) {
            value = this._createModelFromName(name, value);
          }
          current[name] = value;
          this.length = _.keys(current).length;
          if (value instanceof Smackbone.Model && (value._parent == null)) {
            value._parent = this;
            if (value[this.idAttribute] == null) {
              value[this.idAttribute] = name;
            }
          }
          addedAttributes.push(value);
        }
      }
      this._indexToModel = (function() {
        var ref3, results;
        ref3 = this._properties;
        results = [];
        for (n in ref3) {
          v = ref3[n];
          results.push(v);
        }
        return results;
      }).call(this);
      if (!(options != null ? options.silent : void 0)) {
        for (j = 0, len = addedAttributes.length; j < len; j++) {
          value = addedAttributes[j];
          this.trigger('add', value, this, options);
        }
        for (k = 0, len1 = changedPropertyNames.length; k < len1; k++) {
          changeName = changedPropertyNames[k];
          this.trigger("change:" + changeName, current[changeName], this, options);
        }
        if (changedPropertyNames.length > 0) {
          this.trigger('change', this, options);
        }
      }
      if (options != null ? options.triggerRemove : void 0) {
        results = [];
        for (l = 0, len2 = removedAttributes.length; l < len2; l++) {
          value = removedAttributes[l];
          results.push(this.unset(value));
        }
        return results;
      }
    };

    Model.prototype.contains = function(key) {
      return this.get(key) != null;
    };

    Model.prototype.add = function(object) {
      return this.set(object);
    };

    Model.prototype.remove = function(object) {
      return this.unset(object);
    };

    Model.prototype.each = function(func) {
      var key, ref, results, value;
      ref = this._properties;
      results = [];
      for (key in ref) {
        value = ref[key];
        results.push(func(value, key));
      }
      return results;
    };

    Model.prototype.get = function(key) {
      var id, j, len, model, parts, ref, ref1;
      if (key == null) {
        throw new Error('Must have a valid object for get()');
      }
      if (typeof key === 'string') {
        if (key[key.length - 1] === '/') {
          key = key.slice(0, -1);
        }
        parts = key.split('/');
        model = this;
        for (j = 0, len = parts.length; j < len; j++) {
          id = parts[j];
          if (model == null) {
            throw new Error("Couldn't lookup '" + id + "' in '" + key + "'");
          }
          if (model instanceof Smackbone.Model) {
            model = model._properties[id];
          } else {
            model = model[id];
          }
        }
        return model;
      } else {
        return this._properties[(ref = (ref1 = key[this.idAttribute]) != null ? ref1 : key.cid) != null ? ref : key];
      }
    };

    Model.prototype.at = function(index) {
      return this._indexToModel[index];
    };

    Model.prototype.first = function() {
      return this.at(0);
    };

    Model.prototype.last = function() {
      return this.at(this._indexToModel.length - 1);
    };

    Model.prototype.unset = function(key, options) {
      var model, n, ref, ref1, v;
      key = (ref = (ref1 = key[this.idAttribute]) != null ? ref1 : key.cid) != null ? ref : key;
      model = this._properties[key];
      delete this._properties[key];
      this._indexToModel = (function() {
        var ref2, results;
        ref2 = this._properties;
        results = [];
        for (n in ref2) {
          v = ref2[n];
          results.push(v);
        }
        return results;
      }).call(this);
      this.length = _.keys(this._properties).length;
      if (model != null) {
        if (typeof model.trigger === "function") {
          model.trigger('unset', model, this, options);
        }
      }
      return this.trigger('remove', model, this, key, options);
    };

    Model.prototype.path = function() {
      var ref, ref1;
      if (this._parent != null) {
        return (this._parent.path()) + "/" + ((ref = this[this.idAttribute]) != null ? ref : '');
      } else {
        return (ref1 = this.rootPath) != null ? ref1 : '';
      }
    };

    Model.prototype._root = function() {
      var i, j, model;
      model = this;
      for (i = j = 0; j <= 10; i = ++j) {
        if (model._parent == null) {
          break;
        }
        model = model._parent;
      }
      if (!model._parent) {
        return model;
      } else {
        console.warn("couldn't find root for:", this);
        return void 0;
      }
    };

    Model.prototype.fetch = function(queryObject, options) {
      this._root().trigger('fetch_request', this.path(), this, queryObject, options);
      return this.trigger('fetch', this, queryObject, options);
    };

    Model.prototype._triggerUp = function() {
      var args, i, j, model, name, path, ref, results;
      name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      model = this;
      path = '';
      results = [];
      for (i = j = 0; j <= 20; i = ++j) {
        if (model == null) {
          break;
        }
        model.trigger.apply(model, [name, path].concat(slice.call(args)));
        path = "/" + ((ref = model[this.idAttribute]) != null ? ref : '') + path;
        results.push(model = model._parent);
      }
      return results;
    };

    Model.prototype.save = function(options) {
      this._root().trigger('save_request', this.path(), this, options);
      return this._triggerUp('up_save_request', this, options);
    };

    Model.prototype.destroy = function(options) {
      var ref;
      this.trigger('destroy', this, options);
      if (!this.isNew()) {
        this._root().trigger('destroy_request', this.path(), this, options);
      }
      return (ref = this._parent) != null ? ref.remove(this) : void 0;
    };

    Model.prototype.reset = function(a, b, options) {
      var key, ref, value;
      ref = this._properties;
      for (key in ref) {
        value = ref[key];
        this.unset(key);
      }
      if (a != null) {
        this.set(a, b, options);
      }
      return this.trigger('reset', this, options);
    };

    Model.prototype.isEmpty = function() {
      return this.length === 0;
    };

    return Model;

  })(Smackbone.Event);

  Smackbone.Collection = (function(superClass) {
    extend(Collection, superClass);

    function Collection() {
      return Collection.__super__.constructor.apply(this, arguments);
    }

    Collection.prototype.create = function(object) {
      var model;
      model = this._createModelFromName(object.id, object);
      this.set(model);
      model.save();
      return model;
    };

    Collection.prototype.set = function(key, value, options) {
      var array, attributes, id, j, len, o, ref, ref1;
      if (typeof key === 'object') {
        array = _.isArray(key) ? key : [key];
        if (array.length === 0) {
          return this.reset();
        } else {
          attributes = {};
          options = value;
          for (j = 0, len = array.length; j < len; j++) {
            o = array[j];
            id = (ref = o[this.idAttribute]) != null ? ref : o.cid;
            if (id == null) {
              o = this._createModelFromName(void 0, o, Smackbone.Model);
              id = (ref1 = o[this.idAttribute]) != null ? ref1 : o.cid;
            }
            if (o instanceof Smackbone.Model) {
              if (o._parent == null) {
                o._parent = this;
              }
            }
            attributes[id] = o;
          }
        }
      } else {
        (attributes = {})[key] = value;
      }
      return Collection.__super__.set.call(this, attributes, options);
    };

    Collection.prototype.toJSON = function() {
      return _.toArray(Collection.__super__.toJSON.call(this));
    };

    return Collection;

  })(Smackbone.Model);

  Smackbone.Syncer = (function(superClass) {
    extend(Syncer, superClass);

    function Syncer(options) {
      this._onDestroyRequest = bind(this._onDestroyRequest, this);
      this._onSaveRequest = bind(this._onSaveRequest, this);
      this._onFetchRequest = bind(this._onFetchRequest, this);
      this.root = options.model;
      this.root.on('fetch_request', this._onFetchRequest);
      this.root.on('save_request', this._onSaveRequest);
      this.root.on('destroy_request', this._onDestroyRequest);
    }

    Syncer.prototype._onFetchRequest = function(path, model, queryObject, options) {
      var request;
      options = options != null ? options : {};
      request = {
        type: 'GET',
        done: (function(_this) {
          return function(response) {
            var method;
            method = options.reset ? 'reset' : 'set';
            return model[method](response);
          };
        })(this)
      };
      _.extend(request, options);
      return this._request(request, path, queryObject);
    };

    Syncer.prototype._onSaveRequest = function(path, model) {
      var options;
      options = {
        type: model.isNew() ? 'POST' : 'PUT',
        data: model,
        done: (function(_this) {
          return function(response) {
            return model.set(response);
          };
        })(this)
      };
      return this._request(options, path);
    };

    Syncer.prototype._onDestroyRequest = function(path, model) {
      var options;
      options = {
        type: 'DELETE',
        data: model,
        done: (function(_this) {
          return function(response) {
            return model.reset();
          };
        })(this)
      };
      return this._request(options, path);
    };

    Syncer.prototype._encodeQueryObject = function(queryObject) {
      var array, key, value;
      array = (function() {
        var results;
        results = [];
        for (key in queryObject) {
          value = queryObject[key];
          results.push(key + "=" + value);
        }
        return results;
      })();
      if (array.length) {
        return encodeURI('?' + array.join('&'));
      } else {
        return '';
      }
    };

    Syncer.prototype._request = function(options, path, queryObject) {
      var queryString, ref, ref1;
      queryString = this._encodeQueryObject(queryObject);
      options.url = ((ref = this.urlRoot) != null ? ref : '') + path + queryString;
      if (options.type === 'GET') {
        options.data = void 0;
      } else {
        options.data = JSON.stringify((ref1 = options.data) != null ? ref1.toJSON() : void 0);
      }
      options.contentType = 'application/json';
      this.trigger('request', options);
      return Smackbone.$.ajax(options).done(options.done);
    };

    return Syncer;

  })(Smackbone.Event);

}).call(this);
