package com.beerquest {
public class TokenType {

    public static const NONE:TokenType = new TokenType(" ");
    public static const BLOND_BEER:TokenType = new TokenType("b", 1, 3, 3, true);
    public static const BROWN_BEER:TokenType = new TokenType("r", 1, 3, 3, true);
    public static const AMBER_BEER:TokenType = new TokenType("a", 1, 3, 3, true);
    public static const WATER:TokenType = new TokenType("w", 0, 3, 0, true);
    public static const FOOD:TokenType = new TokenType("f", 0, 0, -7, true);
    public static const LIQUOR:TokenType = new TokenType("l", 0, 0, 6, true);
    public static const TOMATO_JUICE:TokenType = new TokenType("t", 0, 0, 0, true);
    public static const TRIPLE:TokenType = new TokenType("*");
    public static const VOMIT:TokenType = new TokenType("v");

    public static function isCompatible(t1:TokenType, t2:TokenType):Boolean {
        return (t1 == t2 || t1 == TokenType.TRIPLE || t2 == TokenType.TRIPLE);
    }

    public static function fromRepr(repr:String):TokenType {
        switch (repr.toLowerCase()) {
            case "b":
                return BLOND_BEER;
            case "r":
                return BROWN_BEER;
            case "a":
                return AMBER_BEER;
            case "w":
                return WATER;
            case "f":
                return FOOD;
            case "l":
                return LIQUOR;
            case "t":
                return TOMATO_JUICE;
            case "v":
                return VOMIT;
        }
        return NONE;
    }

    function TokenType(repr:String, score:Number = 0, piss:Number = 0, vomit:Number = 0, collectible:Boolean = false) {
        _repr = repr;
        _score = score;
        _piss = piss;
        _vomit = vomit;
        _collectible = collectible;
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
        return "[" + repr + "]";
    }

    private var _repr:String;
    private var _score:Number;
    private var _piss:Number;
    private var _vomit:Number;
    private var _collectible:Boolean;
}
}