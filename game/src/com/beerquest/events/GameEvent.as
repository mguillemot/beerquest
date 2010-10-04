package com.beerquest.events {
import com.beerquest.BoardState;

import flash.events.Event;

public class GameEvent extends Event {

    public static const PHASE_BEGIN:String = "PhaseBegin";
    public static const PHASE_END:String = "PhaseEnd";
    public static const TURN_BEGIN:String = "TurnBegin";
    public static const TURN_END:String = "TurnEnd";
    public static const VOMIT:String = "Vomit";
    public static const PISS:String = "Piss";
    public static const GAME_START:String = "GameStart";
    public static const GAME_OVER:String = "GameOver";
    public static const RESYNC:String = "Resync"; // for debug
    public static const CURRENT_TURN_CHANGED:String = "CurrentTurnChanged";

    // TODO vérifier s'ils ont raison d'exizster
    public static const PARTIAL_BEERS_CHANGED:String = "PartialBeersChanged";
    public static const BEER_COLLECTED:String = "BeerCollected";
    public static const FULL_BEERS_CHANGED:String = "FullBeersChanged";

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