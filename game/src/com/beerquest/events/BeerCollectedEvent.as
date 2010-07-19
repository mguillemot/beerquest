package com.beerquest.events {
import com.beerquest.PlayerData;

public class BeerCollectedEvent extends GameEvent {
    public static const BEER_COLLECTED:String = "BeerCollected";

    public function BeerCollectedEvent(player:PlayerData) {
        super(BEER_COLLECTED, player);
    }
}
}