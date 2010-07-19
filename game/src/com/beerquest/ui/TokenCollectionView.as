package com.beerquest.ui {
import com.beerquest.*;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.core.BitmapAsset;
import mx.core.UIComponent;
import mx.events.CollectionEvent;

public class TokenCollectionView extends UIComponent {

    private static const APPEAR_TIME_MS:Number = 200;

    public function TokenCollectionView() {
        width = 170;
        height = 34;
    }

    [Bindable]
    public function set collection(value:ArrayCollection):void {
        if (_collection != null) {
            _collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        }
        _collection = value;
        _collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        compact();
    }

    private function onCollectionChange(e:CollectionEvent):void {
        switch (e.kind) {
            case "add":
                for each(var token:Object in e.items) {
                    var t:BitmapAsset;
                    switch (token) {
                        case TokenType.BLOND_BEER:
                            t = new SmallBlond();
                            break;
                        case TokenType.AMBER_BEER:
                            t = new SmallAmber();
                            break;
                        case TokenType.BROWN_BEER:
                            t = new SmallBrown();
                            break;
                        case TokenType.TRIPLE:
                            t = new SmallTriple();
                            break;
                    }
                    if (t != null) {
                        t.width = t.height = 9;
                        t.alpha = 0;
                        addChild(t);
                        TweenLite.to(t, APPEAR_TIME_MS / 1000, {alpha: 1});
                    }
                }
                recomputeCoords();
                compact();
                break;
            case "remove":
                removeChildAt(e.location);
                break;
        }
    }

    public function compact():void {
        if (_currentAction == "compact") {
            trace("Alreading compacting collected tokens");
            return;
        }
        trace("Compacting collected tokens");
        for (var i:int = 0; i < _collection.length - 2; i++) {
            if (isSeries(i)) {
                _compacting = i;
                startAction("compact");
                for (var k:int; k < 3; k++) {
                    TweenLite.to(getChildAt(i + k), APPEAR_TIME_MS / 1000, {alpha: 0});
                }
                var timer:Timer = new Timer(APPEAR_TIME_MS, 1);
                timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                    _collection.removeItemAt(i);
                    _collection.removeItemAt(i);
                    _collection.removeItemAt(i);
                    dispatchEvent(new BeerCollectedEvent());
                    startAction("");
                    compact();
                });
                timer.start();
                return;
            }
        }
        recomputeCoords();
        startAction("");
    }

    private function isSeries(i:int):Boolean {
        var commonType:TokenType = null;
        for (var k:int = 0; k < 3; k++) {
            var token:TokenType = _collection.getItemAt(i + k) as TokenType;
            if (token != TokenType.TRIPLE) {
                if (commonType == null) {
                    commonType = token;
                } else if (commonType != token) {
                    return false;
                }
            }
        }
        return true;
    }

    private function recomputeCoords():void {
        var cursorX:Number = 0;
        var cursorY:Number = 0;
        for (var i:int = 0; i < numChildren; i++) {
            var token:DisplayObject = getChildAt(i);
            token.x = 3 + cursorX * 11;
            token.y = 2 + cursorY * 11;
            cursorX++;
            if (cursorX == 15) {
                cursorX = 0;
                cursorY++;
            }
        }
    }

    private function startAction(action:String):void {
        trace("TokenView START " + action);
        _currentAction = action;
    }

    private var _collection:ArrayCollection;
    private var _currentAction:String;
    private var _compacting:int;

    [Embed(source="../../../small-blond.png")]
    private static var SmallBlond:Class;

    [Embed(source="../../../small-amber.png")]
    private static var SmallAmber:Class;

    [Embed(source="../../../small-brown.png")]
    private static var SmallBrown:Class;

    [Embed(source="../../../small-triple.png")]
    private static var SmallTriple:Class;
}
}