package com.beerquest {
import flash.display.Sprite;
import flash.events.Event;

import mx.core.MovieClipAsset;

public class Token extends Sprite {

    [Embed(source="../../symbols.swf", symbol="Beer")]
    private var ImportBeerSymbol:Class;

    public function Token(type:TokenType) {
        super();

        _id = nextId++;

        graphics.clear();
//        graphics.lineStyle(3, 0xff000000);
        graphics.drawRect(0, 0, 100, 100);
        graphics.lineStyle(1, 0x0);
        graphics.beginFill(type.color);
        graphics.drawCircle(50, 50, 40);
        graphics.endFill();

        _movieClip = new ImportBeerSymbol();
        _movieClip.x = 50;
        _movieClip.y = 50;
        _movieClip.width = 70;
        _movieClip.height = 70;
        _movieClip.stop();
        _movieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addChild(_movieClip);

        _type = type;
        markX = 0;
        markY = 0;
    }

    private function onEnterFrame(e:Event):void {
        if (_movieClip != null && _movieClip.currentLabel == "end_explode") {
            removeChild(_movieClip);
            _movieClip = null;
        }
    }

    public function explode():void {
        _movieClip.gotoAndPlay("start_explode");                              
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

    public function get markX():int {
        return _markX;
    }

    public function set markX(value:int):void {
        _markX = value;
    }

    public function get markY():int {
        return _markY;
    }

    public function set markY(value:int):void {
        _markY = value;
    }

    public function resetMarks():void {
        markX = 0;
        markY = 0;
    }

    public function get marked():Boolean {
        return (_markX != 0 || _markY != 0);
    }

    private static var nextId:int = 1;

    private var _id:int;
    private var _movieClip:MovieClipAsset;
    private var _type:TokenType;
    private var _boardX:int = int.MIN_VALUE;
    private var _boardY:int = int.MIN_VALUE;
    private var _markX:int;
    private var _markY:int;
    private var _falling:Boolean = false;
}
}