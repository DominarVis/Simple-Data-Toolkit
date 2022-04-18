package com.sdtk.table;

@:nativeGen
class Stopwatch {
    private static var _watches : Map<String, Stopwatch> = new Map<String, Stopwatch> ();
    private static var _defaultActual : Bool = false;
    private static var _null : Null<Stopwatch> = null;

    public function new() { }

    public function start() : Void {
    }

    public function end() : Void {
    }

    public function toString() : String {
        return null;
    }

    public static function getStopwatch(name : String) : Stopwatch {
        var watch : Null<Stopwatch> = _watches.get(name);

        if (watch == null) {
            if (_defaultActual) {
                watch = new StopwatchWrapper(new StopwatchActual(name));
            } else {
                if (_null == null) {
                    _null = new StopwatchNull();
                }
                watch = new StopwatchWrapper(_null);
            }
            _watches.set(name, watch);
        }

        return watch;
    }

    public static function setDefaultActual(defaultActual : Bool) : Void {
        _defaultActual = defaultActual;
        if (defaultActual) {
            #if (hax_ver >= 4)
            for (k => watch in _watches) {
            #else
            for (k in _watches.keys()) {
            #end
              setActual(k);
            }
        }
    }

    public static function setActual(name : String) : Void {
        var watch : Null<Stopwatch> = _watches.get(name);

        if (watch == null) {
            watch = new StopwatchWrapper(new StopwatchActual(name));
            _watches.set(name, watch);
        } else {
            if (watch.isNull()) {
                var wrapper : StopwatchWrapper = cast watch;
                wrapper.set(new StopwatchActual(name));
            }
        }
    }

    public static function printResults() : Void {
      var buffer : String = "";

      #if (hax_ver >= 4)
      for (k => watch in _watches) {
      #else
      for (k in _watches.keys()) {
        var watch : Null<Stopwatch> = _watches.get(k);
      #end
        if (watch != null) {
            var str : Null<String> = watch.toString();
            if (str != null) {
                buffer += str + "\n";
            }
        }
      }

      #if JS_BROWSER
        com.sdtk.std.JS_BROWSER.Console.log
      #elseif JS_SNOWFLAKE
        com.sdtk.std.JS_SNOWFLAKE.Logger.log
      #elseif JS_WSH
        com.sdtk.std.JS_WSH.WScript.Echo
      #elseif JS_NODE
        com.sdtk.std.JS_NODE.Console.log
      #else
        Sys.println
      #end
      (
        buffer
      );      
    }

    public function isNull() : Bool {
        return true;
    }
}

class StopwatchActual extends Stopwatch {
    private var _start : Null<Date>;
    private var _end : Null<Date>;
    private var _duration : Int = 0;
    private var _invocations : Int = 0;
    private var _name : String;

    public function new(name : String) {
        super();
        _name = name;
    }

    public override function start() : Void {
        _invocations++;
        _start = Date.now();
    }

    public override function end() : Void {
        _end = Date.now();
        _duration += Math.floor(_end.getTime() - _start.getTime());
    }

    public override function toString() : String {
        if (_invocations == 1) {
            return "Duration for " + _name + " was " + _duration + "ms";
        } else {
            return "Total duration for " + _name + " was " + _duration + "ms and it was invoked " + _invocations + " times.";
        }
    }

    public override function isNull() : Bool {
        return false;
    }    
}

class StopwatchNull extends Stopwatch {
    public function new() {
        super();
    }
}

class StopwatchWrapper extends Stopwatch {
    private var _watch : Null<Stopwatch>;
    
    public function new(watch : Stopwatch) {
        super();
        _watch = watch;
    }

    public override function start() : Void {
        _watch.start();
    }

    public override function end() : Void {
        _watch.end();
    }

    public override function toString() : String {
        return _watch.toString();
    }

    public function set(watch : Stopwatch) {
        _watch = watch;
    }

    public override function isNull() : Bool {
        return _watch.isNull();
    }    
}