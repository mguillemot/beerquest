package com.beerquest.events {
import flash.events.Event;

public class GameEvent extends Event {

    public static const VOMIT_CHANGED:String = "VomitChanged";
    public static const PISS_CHANGED:String = "PissChanged";
    public static const PARTIAL_BEERS_CHANGED:String = "PartialBeersChanged";
    public static const FULL_BEERS_CHANGED:String = "FullBeersChanged";
    public static const GAME_START:String = "GameStart";
    public static const GAME_OVER:String = "GameOver";
    public static const CURRENT_TURN_CHANGED:String = "CurrentTurnChanged";
    public static const PISS:String = "Piss";
    public static const BEER_COLLECTED:String = "BeerCollected";

    public function GameEvent(type:String) {
        super(type, true);
    }

}
}