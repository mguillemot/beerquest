package com.beerquest {
import flash.events.EventDispatcher;

public class Capacity extends EventDispatcher {

    public static const NONE:Capacity = new Capacity("?");
    public static const BLOND_STACK_ORDER:Capacity = new Capacity("Stack Order", true, TokenType.BLOND_BEER);
    public static const BLOND_FURY_BAR:Capacity = new Capacity("Fury Bar", true, TokenType.BLOND_BEER);
    public static const BROWN_STACK_ORDER:Capacity = new Capacity("Stack Order", true, TokenType.BROWN_BEER);
    public static const BROWN_FURY_BAR:Capacity = new Capacity("Fury Bar", true, TokenType.BROWN_BEER);
    public static const AMBER_STACK_ORDER:Capacity = new Capacity("Stack Order", true, TokenType.AMBER_BEER);
    public static const AMBER_FURY_BAR:Capacity = new Capacity("Fury Bar", true, TokenType.AMBER_BEER);
    public static const BIG_PEANUTS:Capacity = new Capacity("Big Peanuts", true, TokenType.FOOD);
    public static const BIG_BANG:Capacity = new Capacity("Big Bang", true, TokenType.LIQUOR);
    public static const WATERFALL:Capacity = new Capacity("Waterfall", true, TokenType.WATER);
    public static const BLOODY_MARY:Capacity = new Capacity("Bloody Mary", true, TokenType.TOMATO_JUICE);
    public static const TCHIN_TCHIN:Capacity = new Capacity("Tchin Tchin!", true, TokenType.COASTER);

    public static function fromToken(token:TokenType):Capacity {
        switch (token) {
            case TokenType.BLOND_BEER:
                return BLOND_FURY_BAR;
            case TokenType.BROWN_BEER:
                return BROWN_FURY_BAR;
            case TokenType.AMBER_BEER:
                return AMBER_FURY_BAR;
            case TokenType.FOOD:
                return BIG_PEANUTS;
            case TokenType.LIQUOR:
                return BIG_BANG;
            case TokenType.WATER:
                return WATERFALL;
            case TokenType.COASTER:
                return TCHIN_TCHIN;
            case TokenType.TOMATO_JUICE:
                return BLOODY_MARY;
        }
        return null;
    }

    function Capacity(name:String, enabled:Boolean = false, correspondingToken:TokenType = null) {
        super();
        _name = name;
        _enabled = enabled;
        _correspondingToken = correspondingToken;
    }

    public function get name():String {
        return _name;
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function get correspondingToken():TokenType {
        return _correspondingToken;
    }

    private var _name:String;
    private var _enabled:Boolean;
    private var _correspondingToken:TokenType;

}
}