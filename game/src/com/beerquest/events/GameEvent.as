package com.beerquest.events {
import com.beerquest.BoardState;

import flash.events.Event;

public class GameEvent extends Event {

    public static const VOMIT:String = "Vomit";
    public static const PISS:String = "Piss";
    public static const PARTIAL_BEERS_CHANGED:String = "PartialBeersChanged";
    public static const BEER_COLLECTED:String = "BeerCollected";
    public static const FULL_BEERS_CHANGED:String = "FullBeersChanged";
    public static const GAME_START:String = "GameStart";
    public static const GAME_OVER:String = "GameOver";
    public static const CURRENT_TURN_CHANGED:String = "CurrentTurnChanged";
    public static const RESYNC:String = "Resync";

    public function GameEvent(type:String, board:BoardState = null) {
        super(type, true);
        _board = board;
    }

    public function get board():BoardState {
        return _board;
    }

    private var _board:BoardState;
}
}