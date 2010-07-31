package com.beerquest {
import flash.events.EventDispatcher;

public class Capacity extends EventDispatcher {

    public static const NONE:Capacity = new Capacity("?");
    public static const BLOND_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.BLOND_BEER);
    public static const BLOND_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières blondes du plateau, et les ajoute à ton score.\n+75 Caps", true, TokenType.BLOND_BEER);
    public static const BROWN_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.BROWN_BEER);
    public static const BROWN_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières brunes du plateau, et les ajoute à ton score.\n+75 Caps", true, TokenType.BROWN_BEER);
    public static const AMBER_STACK_ORDER:Capacity = new Capacity("Stack Order", "", true, TokenType.AMBER_BEER);
    public static const AMBER_FURY_BAR:Capacity = new Capacity("Fury Bar", "Récolte toutes les bières ambrées du plateau, et les ajoute à ton score.\n+75 Caps", true, TokenType.AMBER_BEER);
    public static const BIG_PEANUTS:Capacity = new Capacity("Big Peanuts", "Vide instantanément la jauge jaune.\n+100 Caps ", true, TokenType.FOOD);
    public static const BIG_BANG:Capacity = new Capacity("Big Bang", "Choisis un type d'objets sur le plateau et détruis les tous.\n150 Caps + valeur des objets détruits", true, TokenType.LIQUOR);
    public static const WATERFALL:Capacity = new Capacity("Waterfall", "Nettoie tout le vomito du plateau.\n+75 Caps ", true, TokenType.WATER);
    public static const BLOODY_MARY:Capacity = new Capacity("Bloody Mary", "Te fait gagner 6 tours supplémentaires au prix d'un peu de vomito. Burp !\n+150 Caps", true, TokenType.TOMATO_JUICE);
    public static const TCHIN_TCHIN:Capacity = new Capacity("Tchin Tchin!", "", true, TokenType.COASTER);

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

    private var _name:String;
    private var _tooltip:String;
    private var _enabled:Boolean;
    private var _correspondingToken:TokenType;

}
}