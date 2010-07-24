package com.beerquest.ui {
import com.beerquest.*;
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.events.Event;

import mx.core.BitmapAsset;
import mx.core.MovieClipAsset;

public class Token extends Sprite {

    public function Token(type:TokenType) {
        super();

        _id = nextId++;

        var mask:Sprite = new Sprite();
        mask.graphics.drawRect(0, 0, 100, 100);
        addChild(mask);
        hitArea = mask;
        //graphics.clear();
        //graphics.lineStyle(3, 0xff000000);
        //graphics.beginFill(0x00000000);
        //graphics.lineStyle(1, 0x0);
        //graphics.beginFill(type.color);
        //graphics.drawCircle(50, 50, 40);
        //graphics.endFill();

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
            case TokenType.COASTER:
                _icon = new CoasterIcon();
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
            case TokenType.VOMIT:
                _icon = new VomitIcon();
                break;
        }
        _icon.x = 5;
        _icon.y = 5;
        _icon.width = 90;
        _icon.height = 90;
        addChild(_icon);
        //            _movieClip = new ImportBeerSymbol();
        //            _movieClip.x = 50;
        //            _movieClip.y = 50;
        //            _movieClip.width = 70;
        //            _movieClip.height = 70;
        //            _movieClip.stop();
        //            _movieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        //            addChild(_movieClip);

        _type = type;
        _mark = false;
    }

    private function onEnterFrame(e:Event):void {
        if (_movieClip != null && _movieClip.currentLabel == "end_explode") {
            removeChild(_movieClip);
            _movieClip = null;
        }
    }

    public function explode():void {
        if (_movieClip != null) {
            _movieClip.gotoAndPlay("start_explode");
        }
        if (_icon != null) {
            TweenLite.to(_icon, .25, {alpha: 0});
        }
    }

    public function get id():int {
        return _id;
    }

    public function get type():TokenType {
        return _type;
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

    public function get mark():Boolean {
        return _mark;
    }

    public function set mark(value:Boolean):void {
        _mark = value;
    }

    private static var nextId:int = 1;

    private var _id:int;
    private var _icon:BitmapAsset;
    private var _movieClip:MovieClipAsset;
    private var _type:TokenType;
    private var _boardX:int = int.MIN_VALUE;
    private var _boardY:int = int.MIN_VALUE;
    private var _mark:Boolean;
    private var _falling:Boolean = false;


    [Embed(source="../../../symbols.swf", symbol="Beer")]
    private static var ImportBeerSymbol:Class;

    [Embed(source="../../../biere-brune.png")]
    private static var BrownBeerIcon:Class;

    [Embed(source="../../../biere-blonde.png")]
    private static var BlondBeerIcon:Class;

    [Embed(source="../../../biere-ambree.png")]
    private static var WhiteBeerIcon:Class;

    [Embed(source="../../../cahouet.png")]
    private static var FoodIcon:Class;

    [Embed(source="../../../sous-bock.png")]
    private static var CoasterIcon:Class;

    [Embed(source="../../../digestif.png")]
    private static var LiquorIcon:Class;

    [Embed(source="../../../verre-eau.png")]
    private static var WaterIcon:Class;

    [Embed(source="../../../vomi.png")]
    private static var VomitIcon:Class;
}
}