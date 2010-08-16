package com.beerquest {
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.PissEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function Game(mode:String, me:PlayerData, seed:int) {
        _mode = mode;
        _me = me;
        _totalTurns = Constants.INITIAL_TOTAL_TURNS;
        _rand = new MersenneTwister(seed);
        _board = new BoardState(_rand);
    }

    public function handleEvent(e:GameEvent):void {
        switch (e.type) {
            case PissEvent.PISS:
                e.player.doPiss();
                Constants.STATS.pissed();
                newTurn();
                break;
            case CapacityEvent.CAPACITY_GAINED:
                var ce:CapacityEvent = e as CapacityEvent;
                e.player.doGainCapacity(ce.capacity);
                break;
        }
    }

    public function get mode():String {
        return _mode;
    }

    public function get me():PlayerData {
        return _me;
    }

    [Bindable(event="boardChanged")]
    public function get board():BoardState {
        return _board;
    }

    [Bindable(event="gameOverChanged")]
    public function get gameOver():Boolean {
        return _gameOver;
    }

    public function set gameOver(value:Boolean):void {
        _gameOver = value;
        dispatchEvent(new Event("gameOverChanged"));
        if (_gameOver) {
            Constants.STATS.gameOver = true;
            dispatchEvent(new GameEvent(GameEvent.GAME_OVER, null));
        }
    }

    public function get totalTurns():int {
        return _totalTurns;
    }

    [Bindable(event="CurrentTurnChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    [Bindable(event="CurrentTurnChanged")]
    public function get currentTurn():int {
        return _currentTurn;
    }

    public function gainAdditionalTurns(t:int):void {
        if (t != 0) {
            _currentTurn -= t;
            dispatchEvent(new GameEvent(GameEvent.CURRENT_TURN_CHANGED, me));
        }
    }

    public function newTurn():void {
        _currentTurn++;
        dispatchEvent(new GameEvent(GameEvent.CURRENT_TURN_CHANGED, me));
        if (remainingTurns <= 0) {
            gameOver = true;
        }
        Constants.STATS.startTurn(this);
    }

    public function get rand():MersenneTwister {
        return _rand;
    }

    private var _mode:String;
    private var _me:PlayerData;
    private var _totalTurns:int;
    private var _currentTurn:int = 0;
    private var _board:BoardState;
    private var _gameOver:Boolean = false;
    private var _rand:MersenneTwister;
}
}