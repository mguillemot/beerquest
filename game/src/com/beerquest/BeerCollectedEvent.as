package com.beerquest {
import flash.events.Event;

public class BeerCollectedEvent extends Event {
    public static const BEER_COLLECTED:String = "BeerCollected";

    public function BeerCollectedEvent() {
        super(BEER_COLLECTED, true);
    }
}
}