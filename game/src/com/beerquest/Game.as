package com.beerquest {
import flash.events.EventDispatcher;

public class Game extends EventDispatcher{
    public function Game() {
        _me = new PlayerData();
        _opponent = new PlayerData();
        _board = new BoardState();
    }

    [Bindable]
    public function get me():PlayerData {
        return _me;
    }

    [Bindable]
    public function get opponent():PlayerData {
        return _opponent;
    }

    [Bindable]
    public function set board(value:BoardState):void {
        _board = value;
    }

    private var _me:PlayerData;
    private var _opponent:PlayerData;
    private var _board:BoardState;
}
}