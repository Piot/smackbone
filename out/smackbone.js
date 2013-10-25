(function() {
  var Smackbone, root, _, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
      var allEvents, args, events, name, _ref, _ref1;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      events = (_ref = this._events) != null ? _ref[name] : void 0;
      if (events != null) {
        this._triggerEvents.apply(this, [events].concat(__slice.call(args)));
      }
      allEvents = (_ref1 = this._events) != null ? _ref1.all : void 0;
      if (allEvents != null) {
        this._triggerEvents.apply(this, [allEvents, name].concat(__slice.call(args)));
      }
      return this;
    };

    Event.prototype.on = function(names, callback) {
      var events, name, nameArray, _i, _len;
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
      for (_i = 0, _len = nameArray.length; _i < _len; _i++) {
        name = nameArray[_i];
        events = this._events[name] || (this._events[name] = []);
        events.push({
          callback: callback,
          self: this
        });
      }
      return this;
    };

    Event.prototype.off = function(name, callback) {
      var event, events, key, names, newEvents, _i, _j, _len, _len1;
      if (callback == null) {
        this._events = {};
        return this;
      }
      events = this._events[name];
      names = name ? [name] : (function() {
        var _i, _len, _ref, _results;
        _ref = this._events;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _results.push(key);
        }
        return _results;
      }).call(this);
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        newEvents = [];
        this._events[name] = newEvents;
        for (_j = 0, _len1 = events.length; _j < _len1; _j++) {
          event = events[_j];
          if (callback !== event.callback) {
            newEvents.push(event);
          }
        }
        if (newEvents.length === 0) {
          delete this._events[name];
        }
      }
      return this;
    };

    Event.prototype._triggerEvents = function() {
      var args, event, events, _i, _len, _results;
      events = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _results = [];
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        event = events[_i];
        _results.push(event.callback.apply(event, args));
      }
      return _results;
    };

    return Event;

  })();

  Smackbone.Model = (function(_super) {
    __extends(Model, _super);

    function Model(attributes, options) {
      this._properties = {};
      this.cid = _.uniqueId('m');
      this.length = 0;
      this.idAttribute = 'id';
      this.changed = {};
      if (attributes != null) {
        this.set(attributes);
      }
      if (typeof this.initialize === "function") {
        this.initialize(attributes);
      }
    }

    Model.prototype.toJSON = function() {
      return _.clone(this._properties);
    };

    Model.prototype.isNew = function() {
      return this[this.idAttribute] == null;
    };

    Model.prototype.clone = function() {
      return new this.constructor(this._properties);
    };

    Model.prototype._createModelFromName = function(name, value) {
      var modelClass, _ref, _ref1;
      modelClass = (_ref = (_ref1 = this.models) != null ? _ref1[name] : void 0) != null ? _ref : this.model;
      if (modelClass != null) {
        return new modelClass(value);
      } else {
        return value;
      }
    };

    Model.prototype.set = function(key, value) {
      var attributes, changeName, changedPropertyNames, current, existingObject, name, previous, _i, _len, _ref;
      if (key == null) {
        throw new Error('can not set with undefined');
      }
      if (value != null) {
        (attributes = {})[key] = value;
      } else {
        attributes = key;
      }
      if (attributes[this.idAttribute] != null) {
        this[this.idAttribute] = attributes[this.idAttribute];
      }
      this._previousProperties = _.clone(this._properties);
      current = this._properties;
      previous = this._previousProperties;
      changedPropertyNames = [];
      this.changed = {};
      for (name in attributes) {
        value = attributes[name];
        if (current[name] !== value) {
          changedPropertyNames.push(name);
        }
        if (previous[name] !== value) {
          this.changed[name] = value;
        }
        if ((((_ref = current[name]) != null ? _ref.set : void 0) != null) && !(value instanceof Smackbone.Model)) {
          existingObject = current[name];
          existingObject.set(value);
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
          this.trigger('add', value, this);
        }
      }
      for (_i = 0, _len = changedPropertyNames.length; _i < _len; _i++) {
        changeName = changedPropertyNames[_i];
        this.trigger("change:" + changeName, this, current[changeName]);
      }
      if (changedPropertyNames.length > 0) {
        return this.trigger('change', this);
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

    Model.prototype.get = function(key) {
      var _ref, _ref1;
      return this._properties[(_ref = (_ref1 = key[this.idAttribute]) != null ? _ref1 : key.cid) != null ? _ref : key];
    };

    Model.prototype.unset = function(key) {
      var model, _ref, _ref1;
      key = (_ref = (_ref1 = key[this.idAttribute]) != null ? _ref1 : key.cid) != null ? _ref : key;
      model = this._properties[key];
      delete this._properties[key];
      this.length = _.keys(this._properties).length;
      if (model != null) {
        if (typeof model.trigger === "function") {
          model.trigger('unset', model);
        }
      }
      return this.trigger('remove', model, this);
    };

    Model.prototype.path = function() {
      var _ref, _ref1;
      if (this._parent != null) {
        return "" + (this._parent.path()) + "/" + ((_ref = this[this.idAttribute]) != null ? _ref : '');
      } else {
        return (_ref1 = this.rootPath) != null ? _ref1 : '';
      }
    };

    Model.prototype._root = function() {
      var model;
      model = this;
      while (model._parent != null) {
        model = model._parent;
      }
      return model;
    };

    Model.prototype.fetch = function() {
      this._root().trigger('fetch_request', this.path(), this);
      return this.trigger('fetch', this);
    };

    Model.prototype.save = function() {
      this._root().trigger('save_request', this.path(), this);
      return this.trigger('save', this);
    };

    Model.prototype.destroy = function() {
      var _ref;
      this.trigger('destroy', this);
      if (!this.isNew()) {
        this._root().trigger('destroy_request', this.path(), this);
      }
      return (_ref = this._parent) != null ? _ref.remove(this) : void 0;
    };

    Model.prototype.reset = function() {
      var key, value, _ref, _results;
      _ref = this._properties;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this.unset(key));
      }
      return _results;
    };

    Model.prototype.isEmpty = function() {
      return this.length === 0;
    };

    return Model;

  })(Smackbone.Event);

  Smackbone.Collection = (function(_super) {
    __extends(Collection, _super);

    function Collection() {
      _ref = Collection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Collection.prototype.create = function(object) {
      var model;
      model = this._createModelFromName(object.id, object);
      this.set(model);
      model.save();
      return model;
    };

    Collection.prototype.set = function(key, value) {
      var array, attributes, id, o, _i, _len, _ref1;
      attributes = {};
      if (value != null) {
        (attributes = {})[key] = value;
      } else {
        if (_.isEmpty(key)) {
          return;
        }
        if (_.isArray(key)) {
          array = key;
        } else {
          array = [key];
        }
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          o = array[_i];
          id = (_ref1 = o[this.idAttribute]) != null ? _ref1 : o.cid;
          if (id == null) {
            throw new Error('In collection you must have a valid id or cid');
          }
          if (o._parent == null) {
            o._parent = this;
          }
          attributes[id] = o;
        }
      }
      delete attributes[this.idAttribute];
      return Collection.__super__.set.call(this, attributes);
    };

    Collection.prototype.each = function(func) {
      var object, x, _ref1, _results;
      _ref1 = this._properties;
      _results = [];
      for (object in _ref1) {
        x = _ref1[object];
        _results.push(func(x));
      }
      return _results;
    };

    Collection.prototype.toJSON = function() {
      return _.toArray(Collection.__super__.toJSON.call(this));
    };

    return Collection;

  })(Smackbone.Model);

  Smackbone.Syncer = (function(_super) {
    __extends(Syncer, _super);

    function Syncer(options) {
      this._onDestroyRequest = __bind(this._onDestroyRequest, this);
      this._onSaveRequest = __bind(this._onSaveRequest, this);
      this._onFetchRequest = __bind(this._onFetchRequest, this);
      this.root = options.model;
      this.root.on('fetch_request', this._onFetchRequest);
      this.root.on('save_request', this._onSaveRequest);
      this.root.on('destroy_request', this._onDestroyRequest);
    }

    Syncer.prototype._onFetchRequest = function(path, model) {
      var options,
        _this = this;
      options = {};
      options.type = 'GET';
      options.done = function(response) {
        return model.set(response);
      };
      return this._request(options, path);
    };

    Syncer.prototype._onSaveRequest = function(path, model) {
      var options,
        _this = this;
      options = {};
      options.type = model.isNew() ? 'POST' : 'PUT';
      options.data = model;
      options.done = function(response) {
        return model.set(response);
      };
      return this._request(options, path);
    };

    Syncer.prototype._onDestroyRequest = function(path, model) {
      var options,
        _this = this;
      options = {};
      options.type = 'DELETE';
      options.data = model;
      options.done = function(response) {
        return model.reset();
      };
      return this._request(options, path);
    };

    Syncer.prototype._request = function(options, path) {
      var _ref1, _ref2;
      options.url = ((_ref1 = this.urlRoot) != null ? _ref1 : '') + path;
      options.data = JSON.stringify((_ref2 = options.data) != null ? _ref2.toJSON() : void 0);
      options.contentType = 'application/json';
      this.trigger('request', options);
      return Smackbone.$.ajax(options).done(options.done);
    };

    return Syncer;

  })(Smackbone.Event);

}).call(this);
