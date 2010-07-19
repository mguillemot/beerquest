package com.beerquest.events {
import com.beerquest.PlayerData;

import flash.events.Event;

public class GameEvent extends Event {
    public function GameEvent(type:String, player:PlayerData) {
        super(type, true);
        _player = player;
    }

    public function get player():PlayerData {
        return _player;
    }

    private var _player:PlayerData;
}
}