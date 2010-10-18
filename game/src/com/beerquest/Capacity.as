package com.beerquest {
import flash.events.EventDispatcher;

public class Capacity extends EventDispatcher {

    public static const NONE:Capacity = new Capacity("none");
    public static const BLOND_FURY_BAR:Capacity = new Capacity("blond-furybar", true, TokenType.BLOND_BEER);
    public static const BROWN_FURY_BAR:Capacity = new Capacity("brown-furybar", true, TokenType.BROWN_BEER);
    public static const AMBER_FURY_BAR:Capacity = new Capacity("amber-furybar", true, TokenType.AMBER_BEER);
    public static const DIVINE_PEANUTS:Capacity = new Capacity("divine-peanuts", true, TokenType.FOOD);
    public static const BIG_BANG:Capacity = new Capacity("big-bang", true, TokenType.LIQUOR);
    public static const WATERFALL:Capacity = new Capacity("waterfall", true, TokenType.WATER);
    public static const BLOODY_MARY:Capacity = new Capacity("bloody-mary", true, TokenType.TOMATO_JUICE);

    public static function fromToken(token:TokenType):Capacity {
        switch (token) {
            case TokenType.BLOND_BEER:
                return BLOND_FURY_BAR;
            case TokenType.BROWN_BEER:
                return BROWN_FURY_BAR;
            case TokenType.AMBER_BEER:
                return AMBER_FURY_BAR;
            case TokenType.FOOD:
                return DIVINE_PEANUTS;
            case TokenType.LIQUOR:
                return BIG_BANG;
            case TokenType.WATER:
                return WATERFALL;
            case TokenType.TOMATO_JUICE:
                return BLOODY_MARY;
        }
        return null;
    }

    function Capacity(translationKey:String, enabled:Boolean = false, correspondingToken:TokenType = null) {
        super();
        _translationKey = translationKey;
        _enabled = enabled;
        _correspondingToken = correspondingToken;
    }

    public function get name():String {
        return I18n.t("capacity." + _translationKey + ".name");
    }

    public function get tooltip():String {
        return I18n.t("capacity." + _translationKey + ".tooltip");
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function get correspondingToken():TokenType {
        return _correspondingToken;
    }

    public function encodedState():String {
        return (enabled) ? correspondingToken.repr : "";
    }

    private var _translationKey:String;
    private var _enabled:Boolean;
    private var _correspondingToken:TokenType;

}
}