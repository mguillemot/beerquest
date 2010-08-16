package com.beerquest {
public class TokenType {

    public static const NONE:TokenType = new TokenType(0, " ");
    public static const BLOND_BEER:TokenType = new TokenType(1, "b", 1, 3, 3, true);
    public static const BROWN_BEER:TokenType = new TokenType(2, "r", 1, 3, 3, true);
    public static const AMBER_BEER:TokenType = new TokenType(3, "a", 1, 3, 3, true);
    public static const WATER:TokenType = new TokenType(4, "w", 0, 3, 0, true);
    public static const FOOD:TokenType = new TokenType(5, "f", 0, 0, -7, true);
    public static const LIQUOR:TokenType = new TokenType(6, "l", 0, 0, 6, true);
    public static const TOMATO_JUICE:TokenType = new TokenType(7, "t", 0, 0, 0, true);
    public static const TRIPLE:TokenType = new TokenType(10, "");
    public static const VOMIT:TokenType = new TokenType(11, "v");

    public static function fromValue(value:int):TokenType {
        switch (value) {
            case 1:
                return BLOND_BEER;
            case 2:
                return BROWN_BEER;
            case 3:
                return AMBER_BEER;
            case 4:
                return WATER;
            case 5:
                return FOOD;
            case 6:
                return LIQUOR;
            case 7:
                return TOMATO_JUICE;
            case 10:
                return TRIPLE;
            case 11:
                return VOMIT;
            default:
                return NONE;
        }
    }

    public static function isCompatible(t1:TokenType, t2:TokenType):Boolean {
        return (t1 == t2 || t1 == TokenType.TRIPLE || t2 == TokenType.TRIPLE);
    }

    function TokenType(value:int, repr:String, score:Number = 0, piss:Number = 0, vomit:Number = 0, collectible:Boolean = false) {
        _value = value;
        _repr = repr;
        _score = score;
        _piss = piss;
        _vomit = vomit;
        _collectible = collectible;
    }

    public function get value():int {
        return _value;
    }

    public function get repr():String {
        return _repr;
    }

    public function get score():Number {
        return _score;
    }

    public function get piss():Number {
        return _piss;
    }

    public function get vomit():Number {
        return _vomit;
    }

    public function get collectible():Boolean {
        return _collectible;
    }

    public function toString():String {
        return "TT" + _value;
    }

    private var _value:int;
    private var _repr:String;
    private var _score:Number;
    private var _piss:Number;
    private var _vomit:Number;
    private var _collectible:Boolean;
}
}