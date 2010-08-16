package com.beerquest.events {
import com.beerquest.PlayerData;

import flash.events.Event;

public class GameEvent extends Event {
    public static const VOMIT_CHANGED:String = "VomitChanged";
    public static const PISS_CHANGED:String = "PissChanged";
    public static const PARTIAL_BEERS_CHANGED:String = "PartialBeersChanged";
    public static const FULL_BEERS_CHANGED:String = "FullBeersChanged";
    public static const GAME_OVER:String = "GameOver";
    public static const CURRENT_TURN_CHANGED:String = "CurrentTurnChanged";

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