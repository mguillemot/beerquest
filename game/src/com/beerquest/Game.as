package com.beerquest {
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.PissEvent;
import com.beerquest.events.VomitEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function Game(me:PlayerData, opponent:PlayerData, barName:String, barLocation:String, barOpen:String, barClose:String) {
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
        _currentTurn = 0;
    }

    public function handleEvent(e:GameEvent):void {
        switch (e.type) {
            case GemsSwappedEvent.GEMS_SWAPPED:
                currentTurn++;
                break;
            case VomitEvent.VOMIT:
                //e.player.doVomit();
                //currentTurn++;
                break;
            case PissEvent.PISS:
                e.player.doPiss();
                currentTurn++;
                break;
            case CapacityEvent.CAPACITY_GAINED:
                var ce:CapacityEvent = e as CapacityEvent;
                e.player.doGainCapacity(ce.capacity);
                break;
        }
    }

    public function get me():PlayerData {
        return _me;
    }

    public function get opponent():PlayerData {
        return _opponent;
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
        var hour:int = _barOpenHour;
        var minute:int = _barOpenMinute;
        minute += 5 * _currentTurn;
        hour += Math.floor(minute / 60);
        minute = minute % 60;
        return getFormattedTime(hour, minute);
    }

    [Bindable(event="currentTurnChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentTurn():int {
        return _currentTurn;
    }

    public function set currentTurn(value:int):void {
        _currentTurn = value;
        dispatchEvent(new Event("currentTurnChanged"));
        if (remainingTurns <= 0) {
            gameOver = true;
        }
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

    private var _currentTurn:int;
}
}