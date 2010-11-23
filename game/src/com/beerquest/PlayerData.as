package com.beerquest {
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.TokenEvent;
import com.beerquest.events.ValueChangedEvent;

import flash.events.EventDispatcher;

public class PlayerData extends EventDispatcher {

    public function PlayerData(game:Game) {
        _game = game;
        _capacities = new Array();
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.push(Capacity.NONE);
        }
        _stack = new Array();
    }

    public function get score():Number {
        return _score;
    }

    public function set score(value:Number):void {
        var previousValue:Number = score;
        _score = value;
        _game.execute(new ValueChangedEvent(ValueChangedEvent.SCORE_CHANGED, previousValue, score));
    }

    public function get piss():Number {
        return _piss;
    }

    internal function get pissLevel():int {
        if (_piss >= 100) {
            return 3;
        } else if (_piss >= 90) {
            return 2;
        } else if (_piss >= 80) {
            return 1;
        }
        return 0;
    }

    public function set piss(value:Number):void {
        var previousPiss:Number = piss;
        var previousPissLevel:int = pissLevel;
        if (value < 0) {
            _piss = 0;
        } else if (value > 100) {
            _piss = 100;
        } else {
            _piss = value;
        }
        _game.execute(new ValueChangedEvent(ValueChangedEvent.PISS_CHANGED, previousPiss, piss));
        if (pissLevel != previousPissLevel) {
            _game.pissLevel = pissLevel;
        }
    }

    public function get vomit():Number {
        return _vomit;
    }

    private function setVomit(value:Number):void {
        var oldValue:Number = vomit;
        _vomit = value;
        if (_vomit < 0) {
            _vomit = 0;
        } else if (_vomit > 101) {
            _vomit = 101;
        }
        _game.execute(new ValueChangedEvent(ValueChangedEvent.VOMIT_CHANGED, oldValue, vomit));
    }

    public function gainVomit(value:Number):void {
        setVomit(vomit + value);
    }

    public function checkVomit():void {
        if (vomit > 100) {
            _game.execute(new GameEvent(GameEvent.VOMIT));
            _game.board.createVomit(Constants.CELLS_CONTAMINATED_ON_VOMIT, InstantEventBuffer.INSTANCE);
            setVomit(30);
        }
    }

    public function get capacities():Array {
        return _capacities;
    }

    public function useCapacity(c:Capacity, targetToken:TokenType):Boolean {
        for (var i:int = Constants.MAX_CAPACITIES - 1; i >= 0; i--) {
            if (_capacities[i] == c) {
                _capacities[i] = Capacity.NONE;
                _game.execute(new CapacityEvent(CapacityEvent.CAPACITY_EXECUTED, c, i, targetToken));
                return true;
            }
        }
        return false;
    }

    public function get stack():Array {
        return _stack;
    }

    public function get stackCompletion():int {
        if (_stack.length <= 1) {
            return _stack.length;
        } else {
            return (_stack[_stack.length - 1] == _stack[_stack.length - 2]) ? 2 : 1;
        }
    }

    public function stackEncodedState():String {
        var res:String = "";
        for each (var pb:TokenType in stack) {
            res += pb.repr;
        }
        return res;
    }

    public function get preferredToken():TokenType {
        if (_stack.length == 0) {
            return TokenType.NONE;
        } else if (_stack.length == 1) {
            return _stack[0];
        } else if (_stack[0] == TokenType.TRIPLE) {
            return _stack[_stack.length - 2];
        } else {
            return _stack[_stack.length - 1];
        }
    }

    public function addToken(type:TokenType):void {
        // Add token
        _stack.push(type);
        _game.execute(new TokenEvent(TokenEvent.TOKEN_ADDED, type));

        // Check for completion
        if (_stack.length >= 3
                && TokenType.isCompatible(_stack[_stack.length - 1], _stack[_stack.length - 2])
                && TokenType.isCompatible(_stack[_stack.length - 2], _stack[_stack.length - 3])) {
            _stack.pop();
            _stack.pop();
            _stack.pop();
            score += Constants.TOKEN_GROUP_VALUE;
            _game.execute(new TokenEvent(TokenEvent.TOKEN_GROUP_COLLECTED, null));
        }

        // Check for overflow
        while (_stack.length + 3 - stackCompletion > Constants.MAX_STACK) {
            var overflowToken:TokenType = _stack.shift();
            _game.execute(new TokenEvent(TokenEvent.TOKEN_EJECTED, overflowToken));
        }
    }

    public function doPiss():void {
        _game.execute(new GameEvent(GameEvent.TURN_BEGIN)); // for the case of pissing last turn
        piss = Math.floor(piss * 0.4);
        _game.execute(new GameEvent(GameEvent.PISS));
        _game.newTurn();
        _game.execute(new GameEvent(GameEvent.TURN_END)); // for the case of pissing last turn
    }

    public function gainCapacity(capacity:Capacity):Boolean {
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            var c:Capacity = _capacities[i];
            if (!c.enabled) {
                _capacities[i] = capacity;
                _game.execute(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, capacity, i));
                return true;
            }
        }
        return false;
    }

    private var _game:Game;
    private var _score:Number = 0;
    private var _piss:Number = 0;
    private var _vomit:Number = 0;
    private var _stack:Array;
    private var _capacities:Array;

}
}