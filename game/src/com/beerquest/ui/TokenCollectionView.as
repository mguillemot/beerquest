package com.beerquest.ui {
import com.beerquest.*;
import com.beerquest.events.BeerCollectedEvent;
import com.beerquest.events.CapacityEvent;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.TimerEvent;
import flash.system.Capabilities;
import flash.utils.Timer;

import mx.core.BitmapAsset;
import mx.core.UIComponent;
import mx.events.CollectionEvent;

public class TokenCollectionView extends UIComponent {

    private static const APPEAR_TIME_MS:Number = 200;

    public function TokenCollectionView() {
        width = 170;
        height = 34;
    }


    public function get player():PlayerData {
        return _player;
    }

    public function set player(value:PlayerData):void {
        _player = value;
        _player.partialBeers.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        _player.addEventListener(CapacityEvent.CAPACITY_EXECUTED, onCapacityExecuted);
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

    private function onCapacityExecuted(e:CapacityEvent):void {
        if (e.capacity == Capacity.BLOND_STACK_ORDER || e.capacity == Capacity.BROWN_STACK_ORDER || e.capacity == Capacity.AMBER_STACK_ORDER) {
            collectType(e.capacity.correspondingToken);
            player.score += 75;
            player.clearCapacities();
        }
    }

    public function compact():void {
        if (_currentAction == "compact") {
            trace("Alreading compacting collected tokens");
            return;
        }
        trace("Compacting collected tokens");
        for (var i:int = 0; i < player.partialBeers.length - 2; i++) {
            if (isSeries(i)) {
                _compacting = i;
                startAction("compact");
                for (var k:int; k < 3; k++) {
                    TweenLite.to(getChildAt(i + k), APPEAR_TIME_MS / 1000, {alpha: 0});
                }
                var timer:Timer = new Timer(APPEAR_TIME_MS, 1);
                timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                    player.partialBeers.removeItemAt(i);
                    player.partialBeers.removeItemAt(i);
                    player.partialBeers.removeItemAt(i);
                    dispatchEvent(new BeerCollectedEvent(player));
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

    private function collectType(type:TokenType):void {
        var count:Number = 0;
        for each (var partial:TokenType in player.partialBeers) {
            if (partial == type) {
                count++;
            }
        }
        var series:Number = Math.floor(count / 3);
        if (series > 0) {
            var compactable:Number = series * 3;
            for (var i:int = 0; i < player.partialBeers.length && compactable > 0; i++) {
                if (player.partialBeers.getItemAt(i) == type) {
                    TweenLite.to(getChildAt(i), APPEAR_TIME_MS / 1000, {alpha: 0});
                    compactable--;
                }
            }
            var timer:Timer = new Timer(APPEAR_TIME_MS, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                for (var j:int = 0; j < series; j++) {
                    dispatchEvent(new BeerCollectedEvent(player));
                }
                var k:int = 0;
                while (k < player.partialBeers.length) {
                    if (getChildAt(k).alpha < 1) {
                        player.partialBeers.removeItemAt(k);
                    } else {
                        k++;
                    }
                }
                recomputeCoords();
                compact();
            });
            timer.start();
        }
    }

    private function isSeries(i:int):Boolean {
        var commonType:TokenType = null;
        for (var k:int = 0; k < 3; k++) {
            var token:TokenType = player.partialBeers.getItemAt(i + k) as TokenType;
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

    private var _player:PlayerData;
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