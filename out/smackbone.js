(function() {
  var Smackbone, root, _,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (typeof exports !== "undefined" && exports !== null) {
    Smackbone = exports;
    _ = require('underscore');
    Smackbone.$ = {
      done: function(func) {
        return func();
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

    Event.prototype.on = function(name, callback) {
      var events;
      if (this._events == null) {
        this._events = {};
      }
      if (!_.isFunction(callback)) {
        throw new Error('Must have a valid function callback');
      }
      if (/\s/g.test(name)) {
        throw new Error('Illegal event name');
      }
      events = this._events[name] || (this._events[name] = []);
      events.push({
        callback: callback,
        self: this
      });
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
      var properties;
      this._properties = {};
      this.cid = _.uniqueId('m');
      this.length = 0;
      this.idAttribute = 'id';
      this.changed = {};
      properties = attributes != null ? attributes : {};
      this.set(properties);
      if (typeof this.initialize === "function") {
        this.initialize(properties);
      }
    }

    Model.prototype.toJSON = function() {
      return _.clone(this._properties);
    };

    Model.prototype.isNew = function() {
      return this.id == null;
    };

    Model.prototype.clone = function() {
      return new this.constructor(this._properties);
    };

    Model.prototype._createModelFromName = function(name, value) {
      var modelClass, result, _ref;
      modelClass = (_ref = this.models) != null ? _ref[name] : void 0;
      if (modelClass == null) {
        modelClass = this.model;
      }
      if (modelClass != null) {
        result = new modelClass(value);
      } else {
        result = value;
      }
      return result;
    };

    Model.prototype.set = function(key, value) {
      var array, attributes, changeName, changedPropertyNames, current, existingObject, id, isChanged, name, o, previous, _i, _j, _len, _len1, _ref, _ref1;
      if (key == null) {
        return;
      }
      if (value == null) {
        if (_.isEmpty(key)) {
          return;
        }
        if (_.isArray(key)) {
          array = key;
        } else {
          array = [key];
        }
        attributes = {};
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          o = array[_i];
          if (this._requiresIdForMembers != null) {
            id = (_ref = o[this.idAttribute]) != null ? _ref : o.cid;
            if (id == null) {
              throw new Error('In collection you must have a valid id or cid');
            }
            attributes[id] = o;
          } else {
            _.extend(attributes, o);
          }
        }
      } else {
        (attributes = {})[key] = value;
      }
      if (this._requiresIdForMembers == null) {
        if (attributes[this.idAttribute] != null) {
          this[this.idAttribute] = attributes[this.idAttribute];
        }
      }
      this._previousProperties = _.clone(this._properties);
      current = this._properties;
      previous = this._previousProperties;
      changedPropertyNames = [];
      this.changed = {};
      for (name in attributes) {
        value = attributes[name];
        if (typeof name === 'object') {
          throw new Error('key can not be object');
        }
        if (current[name] !== value) {
          changedPropertyNames.push(name);
        }
        if (previous[name] !== value) {
          this.changed[name] = value;
        }
        if (((_ref1 = current[name]) != null ? _ref1.set : void 0) != null) {
          if (value instanceof Smackbone.Model) {
            current[name] = value;
          } else {
            existingObject = current[name];
            existingObject.set(value);
          }
        } else {
          if (current[name] == null) {
            if (!(value instanceof Smackbone.Model)) {
              value = this._createModelFromName(name, value);
            }
          }
          current[name] = value;
          this.length = _.keys(current).length;
          if (value instanceof Smackbone.Model) {
            if (value._parent == null) {
              value._parent = this;
              if (this._requiresIdForMembers == null) {
                value[this.idAttribute] = name;
              }
            }
            this.trigger('add', value, this);
          }
        }
      }
      for (_j = 0, _len1 = changedPropertyNames.length; _j < _len1; _j++) {
        changeName = changedPropertyNames[_j];
        this.trigger("change:" + changeName, this, current[changeName]);
      }
      isChanged = changedPropertyNames.length > 0;
      if (isChanged) {
        this.trigger('change', this);
      }
      return value;
    };

    Model.prototype.contains = function(key) {
      return this.get(key) != null;
    };

    Model.prototype.add = function(object) {
      return this.set(object);
    };

    Model.prototype.remove = function(object) {
      if (object.id != null) {
        return this.unset(object.id);
      } else {
        return this.unset(object.cid);
      }
    };

    Model.prototype.get = function(key) {
      if (key.id != null) {
        key = key.id;
      } else if (key.cid != null) {
        key = key.cid;
      }
      return this._properties[key];
    };

    Model.prototype.unset = function(key) {
      var model;
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
      var prefix, _ref, _ref1;
      if (this._parent != null) {
        prefix = this._parent.path();
        return "" + prefix + "/" + ((_ref = this.id) != null ? _ref : '');
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
      return this.trigger('destroy', this);
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

    return Model;

  })(Smackbone.Event);

  Smackbone.Collection = (function(_super) {
    __extends(Collection, _super);

    function Collection() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._requiresIdForMembers = true;
      Collection.__super__.constructor.apply(this, args);
    }

    Collection.prototype.create = function(object) {
      var model;
      model = this._createModelFromName(object.id, object);
      this.set(model);
      model.save();
      return model;
    };

    Collection.prototype.each = function(func) {
      var object, x, _ref, _results;
      _ref = this._properties;
      _results = [];
      for (object in _ref) {
        x = _ref[object];
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
      this._onSaveRequest = __bind(this._onSaveRequest, this);
      this._onFetchRequest = __bind(this._onFetchRequest, this);
      this.root = options.model;
      this.root.on('fetch_request', this._onFetchRequest);
      this.root.on('save_request', this._onSaveRequest);
    }

    Syncer.prototype._onFetchRequest = function(path) {
      var options,
        _this = this;
      options = {};
      options.type = 'GET';
      options.done = function(response) {
        var model;
        model = _this._findModel(path);
        return model.set(response);
      };
      return this._request(options, path);
    };

    Syncer.prototype._findModel = function(path) {
      var model, part, parts, _i, _len;
      parts = (path.split('/')).slice(1);
      model = this.root;
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        model = model.get(part);
      }
      return model;
    };

    Syncer.prototype._onSaveRequest = function(path, model) {
      var options,
        _this = this;
      options = {};
      options.type = model.isNew() ? 'POST' : 'PUT';
      options.data = JSON.stringify(model.toJSON());
      options.done = function(response) {
        return model.set(response);
      };
      return this._request(options, path);
    };

    Syncer.prototype._request = function(options, path) {
      var _ref;
      options.url = ((_ref = this.urlRoot) != null ? _ref : '') + path;
      options.contentType = 'application/json';
      this.trigger('request', options);
      return Smackbone.$.ajax(options).done(options.done);
    };

    return Syncer;

  })(Smackbone.Event);

}).call(this);
