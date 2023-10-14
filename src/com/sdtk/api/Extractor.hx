package com.sdtk.api;
/* TODO -
@:nativeGen
@:expose
interface Extractor extends com.sdtk.std.Reader {
    function extract(reader : Reader) : Reader;
}

@:nativeGen
@:expose
class AbstractExtractor implements Extractor {
    private var reader : Reader;
    private var _next : Null<String> = null;
    private var _nextRawIndex : Null<Int>;
    private var _rawIndex : Null<Int>;  
    
  
    public function new(iReader : Input) {
      super();
      _reader = iReader;
      _next = "";
      _nextRawIndex = 0;
    }
  
    public override function reset() : Void {
      _nextRawIndex = 0;
      reader.reset();
    }  
  
    public override function rawIndex() : Int {
      return _rawIndex;
    }
  
    public override function jumpTo(index : Int) : Void {
      if (index < _nextRawIndex) {
          reset();
      }
      _reader.readString(index - _nextRawIndex);
      _nextRawIndex = index;
    }  
  
    public override function start() : Void {
        moveToNext();
    }
  
    private function moveToNext() {
        var section : String = reader.next();
        while (section != null) {
            if (checkContinue(section)) {
                section = reader.next();
            } else {
                if (checkValid()) {
                    _next = finishExtract();
                    _rawIndex = _nextRawIndex;
                    _nextRawIndex++;
                    return;
                } else {
                    _next = null;
                    return;
                }
            }
        }
        while (checkContinue()) { 






            // TODO



        }
    }
  
    public override function next() : String {
      var sValue : Null<String> = _next;
      if (sValue != null) {
          moveToNext();
      }
      return sValue;
    }
  
    public override function peek() : String {
      return _next;
    }
  
    public function dispose() {
        if (_reader != null) {
            _reader.dispose();    
            _reader = null;
        }
    }
  
    public override function unwrapOne() : Reader {
        return this;
    }
  
    public override function unwrapAll() : Reader {
        return this;
    }
  
    public override function switchToLineReader() : Reader {
        return this;
    }
  
    public override function hasNext() : Bool {
      return (_next != null);
    }
    
    public function checkContinue(section : String) : Bool {
        return false;
    }

    public function checkValid() : Bool {
        return false;
    }

    public function finishExtract() : String {
        return null;
    }
}

@:nativeGen
@:expose
class URLExtractor extends AbstractExtractor {
    private static var _instance : URLExtractor = new URLExtractor();
    private var reader : Reader;
    private var _currentSection : Int = 0;
    private var _currentProtocol : String = "";
    private var _currentHost : String = "";
    private var _currentPort : String = "";
    private var _currentPath : String = "";

    public function new() { }

    public static function instance() : URLExtractor {
        return _instance;
    }

    public function extract(reader : Reader) : Extractor {
        var instance : URLExtractor = new URLExtractor();
        instance.reader = reader;
        return instance;
    }

    public override function checkContinue(section : String) : Bool {
        switch (_currentSection) {
            case 0:
                switch (_currentProtocol + section) {
                    case "h", "ht", "htt", "http", "https", "http:", "https:", "http:/", "https:/":
                        _currentProtocol += section;
                        return true;
                    case "http://", "https://":
                        _currentProtocol += section;
                        _currentSection = 1;
                        return true;
                    case "/":
                        _currentProtocol = null;
                        _currentHost = null;
                        _currentPort = null;
                        _currentPath = section;
                        _currentSection = 3;
                    default:
                        return false;
                }
            case 1:
                switch (section) {
                    case ":":
                        _currentSection = 2;
                    case "/":
                        _currentPath = section;
                        _currentSection = 3;
                    case " ", "\t", "\n", "\r", null:
                        return false;
                    default:
                        _currentHost += section;
                }
            case 2:
                switch (section) {
                    case "/":
                        _currentPath = section;
                        _currentSection = 3;
                    case " ", "\t", "\n", "\r", null:
                        return false;
                    default:
                        _currentPort += section;
                }
            case 3:
                switch (section) {
                    case " ", "\t", "\n", "\r", null:
                        return false;
                    default:
                        _currentPath += section;
                }
        }
    }

    public override function checkValid() : Bool {
        if (_currentProtocol == "") {
            _currentProtocol = null;
        }
        if (_currentHost == "") {
            _currentHost = null;
        }
        if (_currentPort == "") {
            _currentPort = null;
        } else {
            _currentPort = ":" + _currentPort;
        }
        if (_currentPath == "" || _currentPath == "/") {
            _currentPath = null;
        }
        return (_currentProtocol != null && _currentHost != null) || (_currentPath != null);
    }

    public override function finishExtract() : String {
        return (_currentProtocol != null ? _currentProtocol : "") + (_currentHost != null ? _currentHost : "") + (_currentPort != null ? _currentPort : "") + (_currentPath != null ? _currentPath : "");
    }
}
*/