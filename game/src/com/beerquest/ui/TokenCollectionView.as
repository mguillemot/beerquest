package com.beerquest.ui {
import com.beerquest.*;
import com.greensock.TweenLite;

import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.BitmapAsset;
import mx.core.UIComponent;

public class TokenCollectionView extends UIComponent {

    private static const OPERATION_TIME_MS:Number = 200;

    public function TokenCollectionView() {
        width = 170;
        height = 11;
    }

    public function pushTokenIntoStack(token:TokenType):void {
        if (_currentAction != "") {
            trace("TokenView PENDING " + token);
            _pendingActions.push(token);
            return;
        }
        startAction("pushing");
        var s:BitmapAsset;
        var timer:Timer;
        var sprite:BitmapAsset = createSprite(token);
        sprite.x = width;
        sprite.y = 1;
        addChild(sprite);
        var currentCasierType:TokenType = null;
        if (_casiers.length >= 1) {
            if (_casiers.length == 2 && getSpriteType(_casiers[0]) == TokenType.TRIPLE) {
                currentCasierType = getSpriteType(_casiers[1]);
            } else {
                currentCasierType = getSpriteType(_casiers[0]);
            }
        }
        if (_casiers.length == 0 && token == TokenType.TRIPLE) {
            // Cas de merde très particulier
            _casiers.push(sprite);
            TweenLite.to(sprite, OPERATION_TIME_MS / 1000, {x:3 + (Constants.MAX_STACK - 3) * 11});
            timer = new Timer(OPERATION_TIME_MS, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                startAction("");
            });
            timer.start();
        } else if (TokenType.isCompatible(currentCasierType, token)) {
            if (_casiers.length == 1) {
                // Add to middle of casier
                TweenLite.to(sprite, OPERATION_TIME_MS / 1000, {x:3 + (Constants.MAX_STACK - 2) * 11});
                timer = new Timer(OPERATION_TIME_MS, 1);
                timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                    startAction("");
                });
                timer.start();
            } else {
                // Full casiers: collect them
                TweenLite.to(sprite, OPERATION_TIME_MS / 1000, {x:3 + (Constants.MAX_STACK - 1) * 11});
                timer = new Timer(OPERATION_TIME_MS, 1);
                timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                    // Collect!
                    startAction("collecting");
                    for each (s in _casiers) {
                        TweenLite.to(s, OPERATION_TIME_MS / 1000, {alpha: 0});
                    }
                    timer = new Timer(OPERATION_TIME_MS, 1);
                    timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                        startAction("collecting2");
                        for each (s in _casiers) {
                            removeChild(s);
                            _stack.pop();
                        }
                        _casiers = new Array();
                        if (_stack.length > 0) {
                            // Refill stack with old tokens
                            startAction("refilling");
                            var refillQty:int;
                            if (_stack.length >= 2 && TokenType.isCompatible(getSpriteType(_stack[_stack.length - 1]), getSpriteType(_stack[_stack.length - 2]))) {
                                refillQty = 2;
                                _casiers.push(_stack[_stack.length - 2]);
                                _casiers.push(_stack[_stack.length - 1]);
                            } else {
                                refillQty = 1;
                                _casiers.push(_stack[_stack.length - 1]);
                            }
                            var distance:int = refillQty * 11;
                            for each (s in _stack) {
                                TweenLite.to(s, OPERATION_TIME_MS / 1000, {x:"+" + distance});
                            }
                            timer = new Timer(OPERATION_TIME_MS, 1);
                            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                                startAction("");
                            });
                            timer.start();
                        } else {
                            startAction("");
                        }
                    });
                    timer.start();
                });
                timer.start();
            }
            _casiers.push(sprite);
        } else {
            // Push current casier content away
            var pushQty:int, availableSlot:int;
            if (_casiers.length == 2 && getSpriteType(_casiers[1]) == TokenType.TRIPLE) {
                pushQty = 1;
                availableSlot = 1;
            } else {
                pushQty = _casiers.length;
                availableSlot = 0;
            }
            var distance:int = pushQty * 11;
            for each (s in _stack) {
                TweenLite.to(s, OPERATION_TIME_MS / 1000, {x:"-" + distance});
            }
            TweenLite.to(sprite, OPERATION_TIME_MS / 1000, {x:3 + (Constants.MAX_STACK - 3 + availableSlot) * 11});
            _casiers = new Array();
            if (availableSlot == 1) {
                // Push back the last triple of the stack
                _casiers.push(_stack[_stack.length - 1]);
            }
            _casiers.push(sprite);
            timer = new Timer(OPERATION_TIME_MS, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                startAction("");
            });
            timer.start();
        }
        _stack.push(sprite);
        while ((_stack.length + 3 - _casiers.length) > Constants.MAX_STACK) {
            trace("TokenView EXPLUSE");
            s = _stack.shift();
            removeChild(s);
        }
    }

    public function get stageEntryPoint():Point {
        return localToGlobal(new Point(2 + Constants.MAX_STACK * 11, 0));
    }

    private static function createSprite(token:TokenType):BitmapAsset {
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
        t.width = t.height = 9;
        t.name = "token" + (nextId++);
        return t;
    }

    private static function getSpriteType(sprite:BitmapAsset):TokenType {
        if (sprite is SmallBlond) {
            return TokenType.BLOND_BEER;
        } else if (sprite is SmallAmber) {
            return TokenType.AMBER_BEER;
        } else if (sprite is SmallBrown) {
            return TokenType.BROWN_BEER;
        } else if (sprite is SmallTriple) {
            return TokenType.TRIPLE;
        }
        return null;
    }

    private function startAction(action:String):void {
        trace("TokenView START " + action);
        dump();
        _currentAction = action;
        if (action == "" && _pendingActions.length > 0) {
            var token:TokenType = _pendingActions.shift();
            trace("TokenView UNPENDING " + token);
            pushTokenIntoStack(token);
        }
    }

    public function dump():void {
        var sprite:BitmapAsset;
        var stack:String = "stack(" + _stack.length + ")=[";
        for each (sprite in _stack) {
            stack += getSpriteType(sprite) + "@" + sprite.name + ",";
        }
        var casiers:String = "casiers(" + _casiers.length + ")=[";
        for each (sprite in _casiers) {
            casiers += getSpriteType(sprite) + "@" + sprite.name + ",";
        }
        trace("TokenView CURRENT " + stack + " " + casiers);
    }

    private static var nextId:int = 1;

    private var _currentAction:String = "";
    private var _casiers:Array = new Array();
    private var _stack:Array = new Array();
    private var _pendingActions:Array = new Array();

    [Embed(source="../../../assets/image/small-blond.png")]
    private static var SmallBlond:Class;

    [Embed(source="../../../assets/image/small-amber.png")]
    private static var SmallAmber:Class;

    [Embed(source="../../../assets/image/small-brown.png")]
    private static var SmallBrown:Class;

    [Embed(source="../../../assets/image/small-triple.png")]
    private static var SmallTriple:Class;

}
}