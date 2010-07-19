package com.beerquest {
import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function Game(me:PlayerData, opponent:PlayerData, barName:String, barLocation:String, barOpenHour:int, barOpenMinute:int, barCloseHour:int, barCloseMinute:int) {
        _me = me;
        _opponent = opponent;
        _board = new BoardState();
        _barName = barName;
        _barLocation = barLocation;
        _barOpenHour = barOpenHour;
        _barOpenMinute = barOpenMinute;
        _barCloseHour = barCloseHour;
        _barCloseMinute = barCloseMinute;

        _currentTurn = 0;
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

    public function get totalTurns():int {
        return ((_barCloseHour * 60 + _barCloseMinute) - (_barOpenHour * 60 + _barOpenMinute)) / 5;
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentTime():String {
        var hour:int = _barOpenHour;
        var minute:int = _barOpenMinute;
        minute += 5 * _currentTurn;
        hour += Math.floor(minute/60);
        minute = minute % 60;
        return getFormattedTime(hour, minute);
    }

    [Bindable(event="currentTurnChanged")]
    public function get remainingTurns():int {
        return (totalTurns - _currentTurn);
    }

    [Bindable(event="currentTurnChanged")]
    public function get currentTurn():int {
        return _currentTurn;
    }

    public function set currentTurn(value:int):void {
        _currentTurn = value;
        dispatchEvent(new Event("currentTurnChanged"));
    }

    private function getFormattedTime(hour:int, minute:int) {
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

    private var _currentTurn:int;
}
}