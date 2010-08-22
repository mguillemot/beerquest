package com.beerquest {
import flash.events.EventDispatcher;

public class Capacity extends EventDispatcher {

    public static const NONE:Capacity = new Capacity("?");
    public static const BLOND_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.BLOND_BEER);
    public static const BLOND_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières blondes du plateau, et les ajoute à ton score.", true, TokenType.BLOND_BEER);
    public static const BROWN_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.BROWN_BEER);
    public static const BROWN_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières brunes du plateau, et les ajoute à ton score.", true, TokenType.BROWN_BEER);
    public static const AMBER_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.AMBER_BEER);
    public static const AMBER_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières ambrées du plateau, et les ajoute à ton score.", true, TokenType.AMBER_BEER);
    public static const DIVINE_PEANUTS:Capacity = new Capacity("Divine Peanuts", "Transforme la liqueur en eau.", true, TokenType.FOOD);
    public static const BIG_BANG:Capacity = new Capacity("Big Bang", "Choisis un type d'objets sur le plateau et détruis les tous.", true, TokenType.LIQUOR);
    public static const WATERFALL:Capacity = new Capacity("Waterfall", "Nettoie tout le vomito du plateau.", true, TokenType.WATER);
    public static const BLOODY_MARY:Capacity = new Capacity("Bloody Mary", "Te fait gagner 6 tours supplémentaires au prix d'un peu de vomito. Burp !", true, TokenType.TOMATO_JUICE);

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

    function Capacity(name:String, tooltip:String = "", enabled:Boolean = false, correspondingToken:TokenType = null) {
        super();
        _name = name;
        _tooltip = tooltip;
        _enabled = enabled;
        _correspondingToken = correspondingToken;
    }

    public function get name():String {
        return _name;
    }

    public function get tooltip():String {
        return _tooltip;
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

    private var _name:String;
    private var _tooltip:String;
    private var _enabled:Boolean;
    private var _correspondingToken:TokenType;

}
}