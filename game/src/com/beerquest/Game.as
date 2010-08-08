package com.beerquest {
import com.beerquest.TokenType;
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.PissEvent;
import com.beerquest.events.VomitEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function Game(mode:String, me:PlayerData, opponent:PlayerData, barName:String, barLocation:String, barOpen:String, barClose:String, highScores:Array) {
        _mode = mode;
        _me = me;
        _opponent = opponent;
        _board = new BoardState();
        _barName = barName;
        _barLocation = barLocation;
        var openParts:Array = barOpen.split(":");
        _barOpenHour = parseInt(openParts[0]);
        _barOpenMinute = parseInt(openParts[1]);
        var closeParts:Array = barClose.split(":");
        _barCloseHour = parseInt(closeParts[0]);
        _barCloseMinute = parseInt(closeParts[1]);
        _highScores = highScores;
        _currentTurn = 0;
    }

    public function handleEvent(e:GameEvent):void {
        switch (e.type) {
            case PissEvent.PISS:
                e.player.doPiss();
                newTurn();
                Constants.STATS.pissCount++;
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

    public function get opponent():PlayerData {
        return _opponent;
    }

    public function get highScores():Array {
        return _highScores;
    }

    public function set board(value:BoardState):void {
        _board = value;
        dispatchEvent(new Event("boardChanged"));
    }

    [Bindable(event="boardChanged")]
    public function get board():BoardState {
        return _board;
    }

    public function get barName():String {
        return _barName;
    }

    public function get barLocation():String {
        return _barLocation;
    }

    public function get barOperationTime():String {
        return getFormattedTime(_barOpenHour, _barOpenMinute) + " - " + getFormattedTime(_barCloseHour, _barCloseMinute);
    }

    [Bindable(event="gameOverChanged")]
    public function get gameOver():Boolean {
        return _gameOver;
    }

    public function set gameOver(value:Boolean):void {
        _gameOver = value;
        dispatchEvent(new Event("gameOverChanged"));
        if (_gameOver) {
            dispatchEvent(new GameEvent(GameEvent.GAME_OVER, null));
        }
    }

    public function get totalTurns():int {
        var closeHour:int = _barCloseHour;
        if (_barCloseHour < _barOpenHour) {
            closeHour += 24;
        }
        return ((closeHour * 60 + _barCloseMinute) - (_barOpenHour * 60 + _barOpenMinute)) / 5;
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentTime():String {
        return getFormattedTime(currentHour, currentMinute);
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentHour():int {
        var hour:int = _barOpenHour;
        var minute:int = _barOpenMinute;
        minute += 5 * _currentTurn;
        hour += Math.floor(minute / 60);
        return (hour % 24);
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentMinute():int {
        var minute:int = _barOpenMinute;
        minute += 5 * _currentTurn;
        minute %= 60;
        while (minute < 0) {
            minute += 60;
        }
        return minute;
    }

    [Bindable(event="currentTurnChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentTurn():int {
        return _currentTurn;
    }

    public function gainAdditionalTurns(t:int):void {
        _currentTurn -= t;
        dispatchEvent(new Event("currentTurnChanged"));
    }

    public function newTurn():void {
        _currentTurn++;
        dispatchEvent(new Event("currentTurnChanged"));
        if (remainingTurns <= 0) {
            gameOver = true;
        }
        Constants.STATS.startTurn(board.pissLevel, board.count(TokenType.VOMIT));
    }

    private function getFormattedTime(hour:int, minute:int):String {
        var res:String = "";
        if (hour < 10) {
            res += "0";
        }
        res += hour.toString();
        res += ":";
        if (minute < 10) {
            res += "0";
        }
        res += minute.toString();
        return res;
    }

    private var _mode:String;
    private var _me:PlayerData;
    private var _opponent:PlayerData;
    private var _board:BoardState;
    private var _barName:String;
    private var _barLocation:String;
    private var _barOpenHour:int;
    private var _barOpenMinute:int;
    private var _barCloseHour:int;
    private var _barCloseMinute:int;
    private var _gameOver:Boolean = false;
    private var _highScores:Array;

    private var _currentTurn:int;
}
}