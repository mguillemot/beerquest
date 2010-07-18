package com.beerquest {
public class TokenType {

    public static const NONE:TokenType = new TokenType(0, 0x0);
    public static const BLOND_BEER:TokenType = new TokenType(1, 0xFFEF19);
    public static const BROWN_BEER:TokenType = new TokenType(2, 0x7F3300);
    public static const AMBER_BEER:TokenType = new TokenType(3, 0xFCFFE2);
    public static const WATER:TokenType = new TokenType(4, 0xB7FFFF);
    public static const FOOD:TokenType = new TokenType(5, 0x60FF16);
    public static const LIQUOR:TokenType = new TokenType(6, 0xFF0C1C);
    public static const COASTER:TokenType = new TokenType(7, 0xFF70EE);
    public static const TRIPLE:TokenType = new TokenType(8, 0xff00c6);

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
                return TRIPLE;
            default:
                return NONE;
        }
    }

    function TokenType(value:int, color:uint) {
        super();

        _value = value;
        _color = color;
    }

    public function get value():int {
        return _value;
    }

    public function get color():uint {
        return _color;
    }

    private var _value:int;
    private var _color:uint;
}
}