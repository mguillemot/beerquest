package com.beerquest {
public class TokenType {

    public static const NONE:TokenType = new TokenType(0);
    public static const BLOND_BEER:TokenType = new TokenType(1, 1, true);
    public static const BROWN_BEER:TokenType = new TokenType(2, 1, true);
    public static const AMBER_BEER:TokenType = new TokenType(3, 1, true);
    public static const WATER:TokenType = new TokenType(4, 2, true);
    public static const FOOD:TokenType = new TokenType(5, 2, true);
    public static const LIQUOR:TokenType = new TokenType(6, 5, true);
    public static const COASTER:TokenType = new TokenType(7, 10, true);
    public static const TOMATO_JUICE:TokenType = new TokenType(8, 10, true);
    public static const TRIPLE:TokenType = new TokenType(9);
    public static const VOMIT:TokenType = new TokenType(10);

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
                return COASTER;
            case 8:
                return TOMATO_JUICE;
            case 9:
                return TRIPLE;
            case 10:
                return VOMIT;
            default:
                return NONE;
        }
    }

    function TokenType(value:int, score:Number = 0, collectible:Boolean = false) {
        _value = value;
        _score = score;
        _collectible = collectible;
    }

    public function get value():int {
        return _value;
    }

    public function get score():Number {
        return _score;
    }

    public function get collectible():Boolean {
        return _collectible;
    }

    private var _value:int;
    private var _score:Number;
    private var _collectible:Boolean;
}
}