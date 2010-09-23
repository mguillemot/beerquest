package com.beerquest.ui {
import com.beerquest.*;
import com.greensock.TweenLite;

import flash.display.Sprite;

import mx.core.BitmapAsset;

public class Token extends Sprite {

    private static const HINT_CYCLE_MS:Number = 800;
    private static const SUPER_CYCLE_MS:Number = 1000;

    public function Token(type:TokenType, superToken:Boolean) {
        super();

        _superToken = superToken;
        _type = type;
        _mark = 0;

        var hit:Sprite = new Sprite();
        hit.graphics.drawRect(0, 0, 100, 100);
        addChild(hit);
        hitArea = hit;

        switch (type) {
            case TokenType.BROWN_BEER:
                _icon = new BrownBeerIcon();
                break;
            case TokenType.BLOND_BEER:
                _icon = new BlondBeerIcon();
                break;
            case TokenType.AMBER_BEER:
                _icon = new WhiteBeerIcon();
                break;
            case TokenType.FOOD:
                _icon = new FoodIcon();
                break;
            case TokenType.WATER:
                _icon = new WaterIcon();
                break;
            case TokenType.LIQUOR:
                _icon = new LiquorIcon();
                break;
            case TokenType.TOMATO_JUICE:
                _icon = new TomatoIcon();
                break;
            case TokenType.VOMIT:
                var vtype:Number = Math.floor(Math.random() * 3);
                if (vtype == 0) {
                    _icon = new VomitIcon1();
                } else if (vtype == 1) {
                    _icon = new VomitIcon2();
                } else {
                    _icon = new VomitIcon3();
                }
                _icon.x = 0;
                _icon.y = 0;
                _icon.width = 100;
                _icon.height = 100;
                //_icon.rotation = 90;
                break;
        }
        if (type != TokenType.VOMIT) {
            _icon.x = 5;
            _icon.y = 5;
            _icon.width = 90;
            _icon.height = 90;
        }
        addChild(_icon);

        if (superToken) {
            _superTween = new TweenLite(this, SUPER_CYCLE_MS / 2 / 1000, {colorTransform:{tint:0xff0000, tintAmount:0.7}, onComplete:function():void {
                _superTween.reverse();
            }, onReverseComplete:function():void {
                _superTween.restart();
            }});
        }
    }

    public function get type():TokenType {
        return _type;
    }

    public function get superToken():Boolean {
        return _superToken;
    }

    public function get boardX():int {
        return _boardX;
    }

    public function set boardX(value:int):void {
        _boardX = value;
    }

    public function get boardY():int {
        return _boardY;
    }

    public function set boardY(value:int):void {
        _boardY = value;
    }

    public function get falling():Boolean {
        return _falling;
    }

    public function set falling(value:Boolean):void {
        _falling = value;
    }

    public function get mark():int {
        return _mark;
    }

    public function set mark(value:int):void {
        _mark = value;
    }

    public function get hint():Boolean {
        return _hint;
    }

    public function set hint(value:Boolean):void {
        trace("hint=" + value + " on " + boardX + ":" + boardY);
        if (value) {
            if (_hintTween == null) {
                _hintTween = new TweenLite(this, HINT_CYCLE_MS / 2 / 1000, {alpha:0.5, overwrite:0, delay:5, onComplete:function():void {
                    _hintTween.reverse();
                }, onReverseComplete:function():void {
                    _hintTween.restart();
                }});
            }
        } else {
            if (_hintTween != null) {
                _hintTween.setEnabled(false);
                _hintTween = null;
            }
            alpha = 1;
        }
        _hint = value;
    }

    private var _icon:BitmapAsset;
    private var _type:TokenType;
    private var _superToken:Boolean = false;
    private var _boardX:int = int.MIN_VALUE;
    private var _boardY:int = int.MIN_VALUE;
    private var _mark:int = 0;
    private var _hint:Boolean = false;
    private var _hintTween:TweenLite;
    private var _superTween:TweenLite;
    private var _falling:Boolean = false;


    [Embed(source="../../../assets/image/biere-brune.png")]
    private static var BrownBeerIcon:Class;

    [Embed(source="../../../assets/image/biere-blonde.png")]
    private static var BlondBeerIcon:Class;

    [Embed(source="../../../assets/image/biere-ambree.png")]
    private static var WhiteBeerIcon:Class;

    [Embed(source="../../../assets/image/cahouet.png")]
    private static var FoodIcon:Class;

    [Embed(source="../../../assets/image/digestif.png")]
    private static var LiquorIcon:Class;

    [Embed(source="../../../assets/image/verre-eau.png")]
    private static var WaterIcon:Class;

    [Embed(source="../../../assets/image/jus-tomate.png")]
    private static var TomatoIcon:Class;

    [Embed(source="../../../assets/image/vomi-1.png")]
    private static var VomitIcon1:Class;

    [Embed(source="../../../assets/image/vomi-2.png")]
    private static var VomitIcon2:Class;

    [Embed(source="../../../assets/image/vomi-3.png")]
    private static var VomitIcon3:Class;
}
}